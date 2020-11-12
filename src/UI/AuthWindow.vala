/* AuthWindow.vala
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

    [GtkTemplate (ui="/com/syabrocraft/Telegraph/ui/AuthWindow.ui")]
	public class AuthWindow : Hdy.Window
	{
		// Элементы интерфейса
		[GtkChild]Entry Number_Entry;
		[GtkChild]Entry Code_Entry;
		[GtkChild]Entry Pass_Entry;

		[GtkChild]Button Next_Button;
		[GtkChild]Button Back_Button;

		[GtkChild]Gtk.Stack MainStack;

		[GtkChild]Gtk.Spinner Spinner;

		TDIRequest tdi_request;


		public AuthWindow (Gtk.Application app)
		{

			Object (application: app);

			show.connect(showed);
			tdi_request = new TDIRequest("updateAuthorizationState", null, update_auth_state, true);

			Next_Button.clicked.connect(next_clicked);
			Back_Button.clicked.connect(back_clicked);

		}

		void showed ()
		{

			Spinner.start();
			TDI.send_request(null, tdi_request);

		}

		void auth_request()
		{

			Spinner.stop();
			Next_Button.set_sensitive(true);
			Back_Button.set_sensitive(true);

		}

		void auth_response()
		{

			Spinner.start();
			Next_Button.set_sensitive(false);
			Back_Button.set_sensitive(false);

		}

		bool? update_auth_state (Json.Node data)
		{

			Json.Object data_obj = data.get_object();
			Json.Object auth_obj = data_obj.get_object_member("authorization_state");
			string data_type = auth_obj.get_string_member("@type");

			//debug("Received %s", data_type);

			switch (data_type){
			case "authorizationStateWaitPhoneNumber":

				MainStack.set_visible_child_name ("GetPhonePage");
				auth_request();

				break;
			case "authorizationStateWaitCode":

				MainStack.set_visible_child_name ("GetCodePage");
				auth_request();

				break;
			case "authorizationStateWaitPassword":

				MainStack.set_visible_child_name ("GetPassPage");
				auth_request();

				break;
			case "authorizationStateReady":

				//this.close();

				return true;

				break;
			}

			return false;

		}

		void next_clicked()
		{

			string? page_name = MainStack.get_visible_child_name();

			switch (page_name){
			case "GetNumberPage":

				var node = new Json.Node(Json.NodeType.OBJECT);
                var obj = new Json.Object();

                obj.set_string_member("@type", "setAuthenticationPhoneNumber");
                obj.set_string_member("phone_number", Number_Entry.get_text());
                var sett_obj = new Json.Object();
                sett_obj.set_boolean_member("is_current_phone_number", true);
                sett_obj.set_boolean_member("allow_flash_call", false);
                sett_obj.set_boolean_member("allow_sms_retriever_api", false);
                obj.set_object_member("settings", sett_obj);
                node.set_object(obj);

                TDI.send_request(null, new TDIRequest(null, node, null, false));

				break;
			case "GetCodePage":

				var node = new Json.Node(Json.NodeType.OBJECT);
                var obj = new Json.Object();

                obj.set_string_member("@type", "checkAuthenticationCode");
                obj.set_string_member("code", Code_Entry.get_text());
                node.set_object(obj);

                TDI.send_request(null, new TDIRequest(null, node, null, false));

				break;
			case "GetPassPage":

				var node = new Json.Node(Json.NodeType.OBJECT);
                var obj = new Json.Object();

                obj.set_string_member("@type", "checkAuthenticationPassword");
                obj.set_string_member("password", Pass_Entry.get_text());
                node.set_object(obj);

				//debug ("Sending %s", Json.to_string(node, true));

                TDI.send_request(null, new TDIRequest(null, node, null, false));

				break;
			}

			auth_response();

		}

		void back_clicked()
		{

		}

	}

}
