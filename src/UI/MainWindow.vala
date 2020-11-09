/* MainWindow.vala
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

    [GtkTemplate (ui="/com/syabrocraft/Telegraph/ui/MainWindow.ui")]
	public class MainWindow : Hdy.ApplicationWindow
	{

		// Елементы интерфеса
		[GtkChild]ListBox ChatList_ListBox;	// Спиок чатов

		// Элементы поля ввода сообщений
		[GtkChild]Entry Message_Entry;
		[GtkChild]Button Send_Button;

		[GtkChild]ListBox MessageList_ListBox; // Переписка

		int64? selected_chat;
		MessageData selected_message;

		Telegraph.ChatListModel chat_list;
		Telegraph.MessagesListModel messages_list;


		//GLib.ListStore chat_list_store = new GLib.ListStore (Type.OBJECT);

		public MainWindow(Gtk.Application app) throws Error {

			Object (application: app);
			show.connect(main_window_show);
			this.icon = IconTheme.get_default ().load_icon (Constants.PROJECT_NAME, 48, 0);

			Send_Button.clicked.connect (send_clicked);
			ChatList_ListBox.row_activated.connect(chat_selected);

			//ChatList_ListStore = new GLib.ListStore(typeof(ChatID));

		}

		public void main_window_show() {

			//ChatList_ListBox.bind_model(ChatList_ListStore, ElementChatList.new_element);



			chat_list = new Telegraph.ChatListModel(ChatList_ListBox);
			messages_list = new Telegraph.MessagesListModel();

			//ChatList_ListBox.bind_model(chat_list, ElementChatList.create);
			MessageList_ListBox.bind_model(messages_list, MessageElement.create);

			Application.tdi.receive_message.connect (receive_td);

			this.destroy.connect(Application.tdi.Disconnect);

			/*var node = new Json.Node (Json.NodeType.OBJECT);
			var obj = new Json.Object ();

			obj.set_string_member ("@type", "getMe");

			node.set_object(obj);

			debug("Sending: %s", Json.to_string(node, true));

			Application.tdi.Send(Json.to_string(node, false));*/

		}

		void chat_selected (ListBoxRow row)
		{

			if (selected_chat != null)
			{

				var node = new Json.Node(Json.NodeType.OBJECT);
				var obj = new Json.Object();
				obj.set_string_member("@type", "closeChat");
				obj.set_int_member("chat_id", selected_chat);
				node.set_object(obj);

				Application.tdi.Send(Json.to_string(node, false));
			}

			ElementChatList data = row as ElementChatList;

			selected_chat = data.id;

			var node = new Json.Node(Json.NodeType.OBJECT);
			var obj = new Json.Object();
			obj.set_string_member("@type", "openChat");
			obj.set_int_member("chat_id", selected_chat);
			node.set_object(obj);

			Application.tdi.Send(Json.to_string(node, false));

			messages_list.select_chat(selected_chat);



		}

		void send_clicked ()
		{

			var node = new Json.Node (Json.NodeType.OBJECT);
			var obj = new Json.Object ();
			var mess_obj = new Json.Object ();
			var text_obj = new Json.Object ();

			obj.set_string_member ("@type", "sendMessage");
			obj.set_int_member ("chat_id", selected_chat);
			obj.set_object_member("input_message_content", mess_obj);
			mess_obj.set_string_member ("@type", "inputMessageText");
			mess_obj.set_object_member ("text", text_obj);
			text_obj.set_string_member ("@type", "formattedText");
			text_obj.set_string_member ("text", Message_Entry.get_text());

			node.set_object(obj);

			debug("Sending: %s", Json.to_string(node, true));

			Application.tdi.Send(Json.to_string(node, false));

			Message_Entry.set_text("");

		}

		void receive_td(string type, Json.Node data)
		{

			var data_obj = data.get_object();
			switch (type){
			case "updateNewMessage":
				/*var not = new Notification("Test1");
				not.set_priority(NotificationPriority.HIGH);

				var mess_obj = data_obj.get_object_member ("message");
				var content_obj = mess_obj.get_object_member ("content");
				if (content_obj.get_string_member("@type") == "messageText")
				{

					not.set_body(content_obj.get_object_member("text").get_string_member("text"));

				}

				debug ("Sending notification ID = %s", Json.to_string(data, true));

				//application.send_notification(mess_obj.get_int_member("id").to_string(), not);*/
				break;
			case "user":


				break;
			}

		}

    }

}
