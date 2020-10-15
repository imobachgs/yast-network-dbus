# Copyright (c) [2020] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.

require "dbus"

module Y2Network
  module DBus
    # Network configuration DBus object.
    class Network < ::DBus::Object
      # @attr_reader network [Y2Network::Config] Network configuration
      attr_reader :network

      # Constructor
      #
      # @param path    [String] DBus object path
      # @param network [Y2Network::Config] Network configuration
      def initialize(path, network)
        super(path)
        @network = network
      end

      dbus_interface "org.opensuse.YaST2.Network" do
        dbus_method :GetInterfaces, "out interfaces:aa{sv}" do
          ifaces = network.interfaces.map do |iface|
            {
              "Name"        => iface.name,
              "Description" => iface.description,
              "Type"        => iface.type.short_name # it should use a number
            }
          end
          [ifaces]
        end

        dbus_method :GetConnections, "out connections:aa{sv}" do
          conns = network.connections.map do |conn|
            {
              "Id"          => conn.id,
              "Name"        => conn.name,
	      "Description" => conn.description.to_s
            }
          end
          [conns]
        end
      end
    end
  end
end
