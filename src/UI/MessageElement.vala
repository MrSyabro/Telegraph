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

		MessageData mess_data;

		public MessageElement (MessageData data)
		{

			mess_data = data;
			this.OwnerName_Message.label = mess_data.owner_name;
			if (mess_data.owner.id == Application.user_id)
					this.set_halign(Align.END);

			create_content(mess_data.content);

			//mess_data.update.connect(this.update);
			mess_data.owner.update.connect(this.update_user);

		}

		void create_content (Json.Object content)
		{

			switch (content.get_string_member("@type")){
			case "messageText":

				var text = new Label("Test");
				text.set_line_wrap(true);
				//text.get_style_context().add_class("quote");
				text.set_text(content.get_object_member("text").get_string_member("text"));
				this.MessageChild.pack_start(text, false, false, 0);

				text.show();

				break;
			}

		}

		public static MessageElement create(Object data)
		{

			var element = new MessageElement(data as MessageData);

			return element;

		}

		void update_user()
		{

			OwnerName_Message.set_text(mess_data.owner.first_name);

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
