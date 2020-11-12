/* TDInterface.vala
 *
 * Copyright 2020 MrSyabro
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

 namespace Telegraph
 {

 	delegate bool? CallbackType (Json.Node data);

 	class TDIRequest : Object
 	{

		public string? response_type { get; set; }
		public Json.Node? request_data { get; set; }
		public CallbackType? callback { get; set;}
		public bool online { get; set; default = false; }
		// TODO: public int? timeout { get; set; }

		public TDIRequest (string? response_type, Json.Node? request, CallbackType? callback, bool online)
		{

			this.response_type = response_type;
			this.request_data = request;
			if (this.response_type != null)
				this.callback = callback;
			this.online = online;

		}

 	}

 	class TDIClient : Object
 	{

 		public void* client { get; set; }
        public bool loop_stop { get; set; default = false; }
        public int client_uid { get; set; }
        public bool pending_requests { get; set; }
        public Thread<void> client_thread;
        public Gee.ArrayList<TDIRequest> request_queue;
		public uint offline_count { get; set; default = 0; }
		public MainLoop mainloop { get; set; }

		public void thread_func()
		{

			var timer = new Timer ();
        	timer.start ();

        	const double TIMEOUT = 1.0;

        	while(!loop_stop)
	        {

	            string response = Td_json.client_receive(client, TIMEOUT);

	            if (response != null && response != "(null)")
	            {

					//debug(response);
					receive_message_idle_func(response);

	            }

	            Thread.usleep(100);

	        }

			return;

		}

		void receive_message_idle_func (string data)
        {

            GLib.Idle.add (() => {

				var root_node = Json.from_string(data);
				var root_obj = root_node.get_object();
				string response_type = root_obj.get_string_member("@type");

                for (int i = 0; i < request_queue.size; i++)
                {

                	var request = request_queue.@get(i);

					//debug ("Received [%s] == [%s]", response_type, request.response_type);

					if (response_type == request.response_type)
					{

						bool del = request.callback(root_node);
						if (!request.online)
						{

							assert(request_queue.remove(request));
							offline_count--;
							i--;

							requests_pending (offline_count > 0);

						}
						else if (del == true)
						{

							assert(request_queue.remove(request));

						}

					}

                }

                //debug ("Requests in queue %s", request_queue.size.to_string());

                return false;
            });

        }

        public signal void requests_pending (bool stats);

 	}

    class TDI
    {

        // Ключ шифрования кеша базы данных. Временная мера.
        // TODO: Добавить генерацию и хранение ключа в хранилище Gnome
        public static string key = "MHcCAQEEIL4v10M//RqtlAglGrBCeB6snkyUxJH3+jid8MazaHiSoAoGCCqGSM49AwEHoUQDQgAEcEiPXejEv49kLtscGah+eyyHYsnHhYF2EskrNAsoYbiYVkmpQxNgeJojoPRyeM+2IrTH4QFcrNG6zoTelzI1TQ==";

		public static TDIClient? default_client;

		public static TDIClient create_client(int client_uid)
		{

			var client = new TDIClient();
			client.request_queue = new Gee.ArrayList<TDIRequest> ();

			client.client_uid = client_uid;
			client.client = Td_json.client_create();

			if (default_client == null) default_client = client;

			var tdidata_request = new TDIRequest("updateAuthorizationState", null, TDI.get_data_request, true);
			var tdierr_request = new TDIRequest("error", null, TDI.receive_errors, true);

			TDI.send_request(null, tdidata_request);
			TDI.send_request(null, tdierr_request);

			return client;

		}

        public static void client_run(TDIClient? client)
        {
			assert((client ?? TDI.default_client) != null);
			var temp = client ?? TDI.default_client;

        	temp.client_thread = new Thread<void> (string.join("_","TDLib_thread", temp.client_uid.to_string()), temp.thread_func);

			temp.mainloop = new MainLoop();
			temp.mainloop.run();

        }

        public static void client_stop(TDIClient? client)
        {

        	assert((client ?? TDI.default_client) != null);
			var temp = client ?? TDI.default_client;

			temp.loop_stop = true;

			temp.client_thread.join();
			temp.mainloop.quit();
			
            Td_json.client_destroy(temp.client);

        }

        /*public Json.Node Execute (string message)
        {

            return Json.from_string(Td_json.client_execute(client, message));

        }*/

        public static void send_request (TDIClient? client, TDIRequest request)
        {

        	assert((client ?? TDI.default_client) != null);
			var temp = client ?? TDI.default_client;

            if (request.request_data != null)
            {

            	Td_json.client_send(temp.client, Json.to_string(request.request_data, false));
            	request.request_data = null;

            }

            if (request.response_type != null)
            {

            	temp.request_queue.add(request);

            	//debug ("Added request %s", request.response_type);

            }


            if (!request.online)
            {

            	temp.offline_count++;
            	temp.requests_pending (true);

            }

        }

        public static void delete_request (TDIClient? client, TDIRequest request)
        {

        	assert((client ?? TDI.default_client) != null);
			var temp = client ?? TDI.default_client;

			assert(temp.request_queue.remove(request));

        }

        static bool? get_data_request(Json.Node data)
        {
            var resp_obj = data.get_object();
            var auth_obj = resp_obj.get_object_member("authorization_state");
            var auth_st = auth_obj.get_string_member("@type");

            if (auth_st == "authorizationStateWaitTdlibParameters")
            {

                var node = new Json.Node(Json.NodeType.OBJECT);
           		var obj = new Json.Object();
           		var parameters_obj = new Json.Object();

                obj.set_string_member("@type", "setTdlibParameters");
                parameters_obj.set_string_member("database_directory", Environment.get_user_data_dir() + "/" + Constants.PROJECT_NAME);
                parameters_obj.set_string_member("files_directory", Environment.get_user_cache_dir() + "/" + Constants.PROJECT_NAME);
                parameters_obj.set_boolean_member("use_message_database", true);
                parameters_obj.set_boolean_member("use_secret_chats",false);
                parameters_obj.set_int_member ("api_id", Constants.API_ID);
                parameters_obj.set_string_member("api_hash", Constants.API_HASH);
                parameters_obj.set_string_member("system_language_code", "en-UK");
                parameters_obj.set_string_member("device_model", "Desktop");
                parameters_obj.set_string_member("system_version", Environment.get_os_info("PRETTY_NAME"));
                parameters_obj.set_string_member("application_version", Constants.VERSION);
                obj.set_object_member("parameters", parameters_obj);
                node.set_object(obj);

                var tdidata_request = new TDIRequest("updateAuthorizationState", node, TDI.get_crypt_key, true);
                TDI.send_request(null, tdidata_request);

                return true;

            }

            return false;

        }

        static bool? get_crypt_key (Json.Node data)
        {

            var resp_obj = data.get_object();
            var auth_obj = resp_obj.get_object_member("authorization_state");
            var auth_st = auth_obj.get_string_member("@type");

            //debug ("Received if crypt_key %s", auth_st);

			if (auth_st == "authorizationStateWaitEncryptionKey")
            {

            	var node = new Json.Node(Json.NodeType.OBJECT);
            	var obj = new Json.Object();

                obj.set_string_member("@type", "checkDatabaseEncryptionKey");
                obj.set_string_member("encryption_key", TDI.key);
                node.set_object(obj);

                TDI.send_request(null, new TDIRequest(null, node, null, false));

				return true;

            }

            return false;

        }

        static bool? receive_errors (Json.Node data)
        {

			warning("[TDLib error]%s", Json.to_string(data, true));
			return false;

        }
    }
}
