/* User.vala
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

    class User : Object
    {

        public int id { get; set; }
        public string? first_name { get; set; }
        public string? last_name { get; set; }
        public string? username { get; set; }

		public signal void update();
        
    }
    
    class Users : Object
    {

    	Gee.TreeMap<int, User> list;

    	public Users ()
    	{

			list = new Gee.TreeMap<int, User> ();
			
			TDI.send_request (null, new TDIRequest("user", null, receive_user, true));

    	}

    	public void user_add (User data)
    	{

    		if (!list.has_key (data.id))
    		{

    			list.@set(data.id, data);

    		}

    	}

    	public User user_get (int id)
    	{

			if (list.has_key (id))
			{

				var user = list.@get(id);

				debug("User [%s %s] returned.", user.first_name, user.last_name);

				return user;

			}
			else
			{

				var data = new User();
				data.id = id;
				list.@set(id, data);

				var node = new Json.Node(Json.NodeType.OBJECT);
				var obj = new Json.Object();
				obj.set_string_member("@type", "getUser");
				obj.set_int_member("user_id", id);
				node.set_object(obj);

				TDI.send_request (null, new TDIRequest(null, node, null, false));

				debug("User [%s] getting in TDLib.", data.id.to_string());

				return data;

			}

    	}

    	bool? receive_user (Json.Node data)
    	{

    		//var data_obj = data.get_object();

			User user = Json.gobject_deserialize (typeof(User), data) as User;
			
			debug ("Received user data ID=%s", user.id.to_string());

			if (list.has_key(user.id))
			{

				var old_user = list.@get(user.id);
				old_user.last_name = user.last_name;
				old_user.first_name = user.first_name;
				old_user.username = user.username;
				old_user.update();

			}

			debug("User [%s] updaed from TDLib.", user.id.to_string());

			return false;

    	}

    }

}
