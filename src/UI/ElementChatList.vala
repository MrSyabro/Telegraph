/* ElementChatList.vala
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

using Gtk;

namespace Telegraph {

    [GtkTemplate (ui="/com/syabrocraft/Telegraph/ui/ElementChatList.ui")]
    class ElementChatList : Gtk.ListBoxRow
    {
    	[GtkChild]public Label	Name_ChatListElement;
        [GtkChild]public Label	Mess_ChatListElement;

        public int64 id { get; private set; }
        public int64 order { get; private set; }


		public ElementChatList (int64 chat_id)
		{

			this.id = chat_id;

			var node = new Json.Node(Json.NodeType.OBJECT);
			var obj = new Json.Object();
			obj.set_string_member("@type", "getChat");
			obj.set_int_member("chat_id", chat_id);
			node.set_object(obj);

			TDI.send_request(null, new TDIRequest("chat", node, receive_chat, true));
			TDI.send_request(null, new TDIRequest("updateChatOrder", null, receive_order, true));
			TDI.send_request(null, new TDIRequest("updateChatLastMessage", null, receive_last_message, true));

		}

		void set_last_message(Json.Object data)
		{

			var content = data.get_object_member("content");
			switch (content.get_string_member("@type")){
			case "messageText":

				var text = content.get_object_member("text").get_string_member("text");
				Mess_ChatListElement.set_text(text);

				break;
			}

		}

		bool? receive_chat (Json.Node data)
		{

			//debug(Json.to_string(data, true));

			var data_obj = data.get_object();

			if (data_obj.get_int_member("id") == this.id)
	    	{

	    		Name_ChatListElement.set_text(data_obj.get_string_member("title"));
				var message = data_obj.get_object_member("last_message");
				set_last_message(message);
				this.order = data_obj.get_array_member("positions").get_object_element(0).get_string_member("order").to_int64();

	    	}

	    	return false;

		}

		bool? receive_order (Json.Node data)
		{

			var data_obj = data.get_object();

			if (data_obj.get_int_member("chat_id") == this.id)
			{

				//debug ("Getted updateChatOrder respnse: %s", Json.to_string(data, true));

				this.order = data_obj.get_array_member("positions").get_object_element(0).get_string_member("order").to_int64();

			}

			return false;

		}

		bool? receive_last_message (Json.Node data)
		{

			var data_obj = data.get_object();

			if (data_obj.get_int_member("chat_id") == this.id)
			{

				debug ("Getting LastMessage: ID = %s", data_obj.get_int_member("chat_id").to_string());
				var mess_obj = data_obj.get_object_member("last_message");
				set_last_message(mess_obj);
				this.order = data_obj.get_array_member("positions").get_object_element(0).get_string_member("order").to_int64();

			}

			return false;

		}

	}

}
