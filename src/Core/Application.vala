/* Application.vala
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

namespace Telegraph {

	class Application : Gtk.Application {

		public static Telegraph.TDI tdi;
		public static MainWindow main_window;
		public static AuthWindow auth_window;
		public static int? user_id;
		public static Users users;

		public Application () {

			Object(application_id: Constants.PROJECT_NAME,
				flags: ApplicationFlags.HANDLES_OPEN);

		}

		protected override void activate () {

			try {

				var client = TDI.create_client(1);
				main_window = new MainWindow (this);
				auth_window = new AuthWindow (this);
				users = new Users();

				client.requests_pending.connect(main_window.request_pending_cb);

				TDI.send_request(null, new TDIRequest("updateAuthorizationState", null, auth_ready, true));
				TDI.send_request(null, new TDIRequest("updateOption", null, update_myid_opt, true));

			    add_window(main_window);
			    add_window(auth_window);

			    Gtk.CssProvider css_provider = new Gtk.CssProvider ();
				css_provider.load_from_resource ("/com/syabrocraft/Telegraph/app.css");
				Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_USER);

			    auth_window.present();

				Td_log.verbosity_level(0);

			    TDI.client_run(null);

			} catch (Error e) { error(@"$(e.code): $(e.message)"); }

		}

		protected override void startup()
		{

			base.startup();

			Hdy.init();

		}

		bool? auth_ready (Json.Node data)
		{

			var data_obj = data.get_object();
			Json.Object auth_obj = data_obj.get_object_member("authorization_state");
			string data_type = auth_obj.get_string_member("@type");

			//debug ("Received %s", data_type);

			if (data_type == "authorizationStateReady")
			{

				auth_window.close();
				main_window.present();
				return true;

			}

			return false;

		}

		bool? update_myid_opt (Json.Node data)
		{

			var data_obj = data.get_object();

			if (data_obj.get_string_member("name") == "my_id")
			{

				user_id = (int)data_obj.get_object_member("value").get_int_member("value");
				return true;

			}

			return false;

		}

    }

}
