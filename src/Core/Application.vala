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

				tdi = new Telegraph.TDI();
				main_window = new MainWindow (this);
				auth_window = new AuthWindow (this);
				users = new Users();

				tdi.receive_message.connect(receive_td);

			    add_window(main_window);
			    add_window(auth_window);
			    auth_window.present();

				Td_log.verbosity_level(0);

			    tdi.Run();

			} catch (Error e) { error(@"[Telegraph]$(e.code): $(e.message)"); }

		}

		protected override void startup()
		{

			base.startup();

			Hdy.init();

		}

		void receive_td (string type, Json.Node data)
		{

			var data_obj = data.get_object();

			switch (type) {
			case "updateAuthorizationState":


				Json.Object auth_obj = data_obj.get_object_member("authorization_state");
				string data_type = auth_obj.get_string_member("@type");

				if (data_type == "authorizationStateReady")
				{

					main_window.present();

				}

				break;
			case "updateOption":

				if (data_obj.get_string_member("name") == "my_id")
					user_id = (int)data_obj.get_object_member("value").get_int_member("value");

				break;
			}

		}

    }

}
