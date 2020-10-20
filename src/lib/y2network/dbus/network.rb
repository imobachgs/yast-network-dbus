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
require "yast"
require "y2network/dbus/network_config"

Yast.import "Lan"

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
        @network = Y2Network::DBus::NetworkConfig.new(network)
      end

      dbus_interface "org.opensuse.YaST2.Network" do
        dbus_method :GetInterfaces, "out interfaces:aa{sv}" do
          ifaces = network.interfaces.map(&:to_dbus)
          log_method("GetInterfaces", ifaces)
          [ifaces]
        end

        dbus_method :GetConnections, "out connections:aa{sv}" do
          conns = network.connections.map(&:to_dbus)
          log_method("GetConnections", [conns])
          [conns]
        end

        dbus_method :UpdateConnection, "in name:s, in conn:a{sv}" do |name, data|
          new_network = network.copy
          conn = new_network.connections.find { |c| c.name == name }
          conn.from_dbus(data)
          new_network.write(original: network, only: [:connections])
        end

        dbus_method :UpdateConnections, "in conns:a{sv}" do |conns|
          new_network = network.copy
          conns.each do |name, data|
            conn = new_network.connections.find { |c| c.name == name }
            conn.from_dbus(data)
          end
          new_network.write(original: network, only: [:connections])
        end

        private

        def log_method(name, response)
          puts "#{name}: #{response.inspect}"
        end
      end
    end
  end
end
