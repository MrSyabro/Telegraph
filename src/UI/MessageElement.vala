/* MessageElement.vala
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

    [GtkTemplate (ui="/com/syabrocraft/Telegraph/ui/MessageElement.ui")]
	class MessageElement : Gtk.Box
	{

		[GtkChild]public Label OwnerName_Message;
		[GtkChild]public Gtk.Box MessageChild;


		public static MessageElement create(Object data)
		{

			var mess_data = data as MessageData;
			var element = new MessageElement();
			element.OwnerName_Message.label = mess_data.owner_name;
			if (mess_data.owner_id == Application.user_id)
					element.set_halign(Align.END);

			//debug ("New message: %s", mess_data.content.get_object_member("text").get_string_member("text"));

			switch (mess_data.content.get_string_member("@type")){
			case "messageText":

				var text = new Label("Test");
				text.set_line_wrap(true);
				text.set_text(mess_data.content.get_object_member("text").get_string_member("text"));
				element.MessageChild.pack_start(text, false, false, 0);

				text.show();

				break;
			}

			return element;

		}

		void update(MessageData mess_data)
		{

			OwnerName_Message.set_text(mess_data.owner_name);

			/*switch (mess_data.content.get_string_member("@type")){
			case "messageText":

				var text = new Label("Test");
				text.set_line_wrap(true);
				text.set_text(mess_data.content.get_object_member("text").get_string_member("text"));
				MessageChild.pack_start(text, false, false, 0);

				text.show();

				break;
			}*/

		}

	}

}
