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

 	public class AsyncResponse : Object
 	{
 		public string response { set; get; }

 		public AsyncResponse (string resp)
 		{
 			response = resp;
 		}
 	}

    class TDI : Object
    {

        static void* client;
        Json.Node response_node;
        bool tdlib_loop_stop = true;
        //FileOutputStream log_os;

		AsyncQueue<string> async_response;


        // Ключ шифрования кеша базы данных. Временная мера.
        // TODO: Добавить генерацию и хранение ключа в хранилище Gnome
        string key = "MHcCAQEEIL4v10M//RqtlAglGrBCeB6snkyUxJH3+jid8MazaHiSoAoGCCqGSM49AwEHoUQDQgAEcEiPXejEv49kLtscGah+eyyHYsnHhYF2EskrNAsoYbiYVkmpQxNgeJojoPRyeM+2IrTH4QFcrNG6zoTelzI1TQ==";

        public TDI()
        {

            client = Td_json.client_create();
            async_response = new AsyncQueue<string> ();

            this.receive_message.connect(sendTdlibParameters);

            //File log_file = File.new_for_path("tdlib.log");
            //log_os = log_file.create (FileCreateFlags.PRIVATE);
        }

        public void Run()
        {

        	new Thread<void> ("TDLib_thread", update);
        	//new Thread<void> ("TDLib_resonse", update_response);

        	new MainLoop().run();

        	/*MainLoop tdlib_loop = new MainLoop();
            update.begin((obj, res) => {
                    update.end(res);
                    tdlib_loop.quit();
                });
            tdlib_loop.run();*/

			/*MainLoop tdlib_resp_loop = new MainLoop();
            update_response.begin((obj, res) => {
                    update_response.end(res);
                    tdlib_resp_loop.quit();
                });
            tdlib_resp_loop.run();*/


        }

        public void Disconnect()
        {
        	tdlib_loop_stop = false;
        	//tdlib_loop.quit();
            Td_json.client_destroy(client);
        }

        void update()
        {

        	var timer = new Timer ();
        	timer.start ();

        	const double TIMEOUT = 10.0;

        	while(tdlib_loop_stop)
	        {

	            string response = Td_json.client_receive(client, TIMEOUT);

	            if (response != null && response != "(null)")
	            {

					receive_message_idle_func(response);

                    
	            }

	            Thread.usleep(100);

	        }

			return;
        }

        void receive_message_idle_func (string data)
        {
            
            GLib.Idle.add (() => {
                response_node = Json.from_string(data);
                Json.Object? json_object = response_node.get_object();
                string response_type = json_object.get_string_member("@type");

                receive_message(response_type, response_node);

                return false;
            });

        }

        public signal void receive_message (string type, Json.Node message);

        public Json.Node Execute (string message)
        {
            return Json.from_string(Td_json.client_execute(client, message));
        }

        public void Send (string message)
        {
            Td_json.client_send(client, message);
        }

        void sendTdlibParameters(string type, Json.Node data)
        {
            if (type == "updateAuthorizationState")
            {
                var node = new Json.Node(Json.NodeType.OBJECT);
                var obj = new Json.Object();

                var resp_obj = data.get_object();
                var auth_obj = resp_obj.get_object_member("authorization_state");
                var auth_st = auth_obj.get_string_member("@type");

                if (auth_st == "authorizationStateWaitTdlibParameters")
                {
                    obj.set_string_member("@type", "setTdlibParameters");
                    var parameters_obj = new Json.Object();
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
                    string mess = Json.to_string(node, false);
                    Send(mess);
                }
                else if (auth_st == "authorizationStateWaitEncryptionKey")
                {
                    obj.set_string_member("@type", "checkDatabaseEncryptionKey");
                    obj.set_string_member("encryption_key", key);
                    node.set_object(obj);
                    string mess = Json.to_string(node, false);
                    Send(mess);
                }
            }
            else if (type == "error")
            {

            	warning("[TDLib]: %s", Json.to_string(data, true));

            }
        }
    }
}
