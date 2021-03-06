/* MessageData.vala
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

    class MessageData : Object
    {

		public int64 message_id { get; set; }
		public string owner_name { get; set; }
		public User owner { get; set; }
		public Json.Object content { get; set; }
		public bool pending { get; set; default = false; }

		//public signal void update(MessageData data);

    }

}
