/* ChatListModel.vala
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

 	class ChatListModel : Object
 	{

 		//Gee.ArrayList<Telegraph.ChatData> chat_list;
		Gtk.ListBox chat_list;

 		public ChatListModel(Gtk.ListBox list_box)
 		{

			chat_list = list_box;

			chat_list.set_sort_func(ChatList_sort_func);

			Application.tdi.receive_message.connect (receive_td);

			var node = new Json.Node (Json.NodeType.OBJECT);
			var obj = new Json.Object ();
			obj.set_string_member ("@type", "getChats");
			obj.set_int_member ("offset_order", int64.MAX);
			obj.set_int_member ("offset_chat_id", 0);
			obj.set_int_member ("limit", 100);
			node.set_object (obj);

			//debug ("%s", "Geting 100 chats wich offset");
			Application.tdi.Send (Json.to_string (node, false));

 		}

 		public void receive_td (string type, Json.Node data)
 		{

			var data_obj = data.get_object ();
			switch (type){
			case "chats":

				debug("Received chats list.");

				var data_arr = data_obj.get_array_member ("chat_ids");
				data_arr.foreach_element(foreach_chats);

				break;
			case "chat":
			case "updateChatLastMessage":
			case "updateChatOrder":
				receive_chat_data (type, data);
				chat_list.invalidate_sort ();
				break;
			}

 		}

 		void foreach_chats (Json.Array arr, uint index, Json.Node node)
		{

			int64 id = node.get_int();
			var element = new ElementChatList(id);
			receive_chat_data.connect (element.update);

			chat_list.prepend(element);

			//chat_list.show_all();

		}

		int ChatList_sort_func(Gtk.ListBoxRow row1, Gtk.ListBoxRow row2)
		{

			var obj1 = row1 as ElementChatList;
			var obj2 = row2 as ElementChatList;

			if (obj1 != null && obj2 != null){

				uint64 order1 = obj1.order;
				uint64 order2 = obj2.order;

				if (order1 < order2) return 1;
				else if (order1 > order2) return -1;
				else return 0;

				//return (int)(order1 - order2);
			}

			return 0;

		}

		signal void receive_chat_data(string type, Json.Node data);

 	}

 }
