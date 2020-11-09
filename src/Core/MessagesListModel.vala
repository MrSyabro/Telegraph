/* MessageListModel.vala
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

 	class MessagesListModel : ListModel, Object
 	{

 		Gee.ArrayList<Telegraph.MessageData> messages_list;
 		int64 chat_id;

		public MessagesListModel ()
		{

			messages_list = new Gee.ArrayList<Telegraph.MessageData>();

			Application.tdi.receive_message.connect (receive_td);

		}

		public void select_chat (int64 id)
		{

			this.chat_id = id;

			items_changed(0, messages_list.size, 0);
			messages_list.clear();

			var node = new Json.Node (Json.NodeType.OBJECT);
			var obj = new Json.Object ();
			obj.set_string_member ("@type", "getChatHistory");
			obj.set_int_member ("chat_id", chat_id);
			obj.set_int_member ("from_message_id", 0);
			obj.set_int_member ("offset", -50);
			obj.set_int_member ("limit", 100);
			node.set_object (obj);

			Application.tdi.Send (Json.to_string (node, false));

			debug("Chat selected: %ld", (long)chat_id);

		}

		public void receive_td (string type, Json.Node data)
		{

			var data_obj = data.get_object();
			switch (type){
			case "messages":

				//debug("App received messages:\n%s", Json.to_string(data, true));
				var mess_arr = data_obj.get_array_member("messages");
				int len = (int)data_obj.get_int_member("total_count");

				debug("Getting %d messages..", len);

				mess_arr.foreach_element(foreach_mess);
				items_changed(0, 0, len);

				break;
			case "updateNewMessage":

				var mess_obj = data_obj.get_object_member ("message");
				if (mess_obj.get_int_member("chat_id") == chat_id)
				{

					//debug ("Adding message: %s", Json.to_string(mess_obj.get_member("content"), true));
					add_message(mess_obj);
					items_changed(messages_list.size - 1, 0, 1);

				}

				break;
			case "updateDeleteMessages":

				//debug(Json.to_string(data, true));

				if (data_obj.get_int_member("chat_id") == this.chat_id)
				{

					if (!data_obj.get_boolean_member("from_cache"))
					{
						var array = data_obj.get_array_member("message_ids");
						//debug ("deleting %d messages in %s chat_id", (int)array.get_length(), data_obj.get_int_member("chat_id").to_string());
						array.foreach_element(delete_message_ffunc);
					}

				}

				break;
			case "updateMessageSendSucceeded":

				int i = find_message(data_obj.get_int_member("old_message_id"));

				var mess_data = messages_list.@get(i);
				mess_data.message_id = data_obj.get_object_member("message").get_int_member("id");

				break;
			}

		}

		void delete_message_ffunc (Json.Array arr, uint index, Json.Node data)
		{

			int64 id = data.get_int();
			//debug("Find %s on %d elements.", id.to_string(), messages_list.size);

			int i = find_message(data.get_int());

			if (i > -1)
			{

				messages_list.remove_at(i);
				items_changed(i, 1, 0);

			}

		}

		int find_message(int64 id)
		{

			for (int i = messages_list.size - 1; i >= 0; i--)
			{

				var mess_data = messages_list.@get(i);
				if (mess_data.message_id == id)
				{

					return i;

				}

			}

			return -1;

		}

		public void add_message (Json.Object mess_obj)
		{

			var content = mess_obj.get_object_member("content");
			var element = new MessageData();
			element.content = content;

			element.message_id = mess_obj.get_int_member("id");
			element.owner_id = (int)mess_obj.get_int_member("sender_user_id");
			//element.owner_name = "Test";

			var user = Application.users.user_get(element.owner_id);
			element.owner_name = user.first_name;

			messages_list.add(element);

		}

		void foreach_mess (Json.Array arr, uint index, Json.Node node)
		{

			var mess_obj = arr.get_object_element(arr.get_length() - index - 1);
			add_message(mess_obj);

		}

		public Object? get_item (uint pos)
		{

			return messages_list.@get((int)pos);

		}

		public Type get_item_type ()
		{

			return typeof (MessageData);

		}

		public uint get_n_items()
		{

			return messages_list.size;

		}

 	}

}
