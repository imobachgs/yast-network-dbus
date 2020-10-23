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
require "y2network/dbus/route"
require "y2network/dbus/connection_config"
require "y2network/dbus/interface"

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
        @network = network
      end

      dbus_interface "org.opensuse.YaST2.Network" do
        dbus_method :GetInterfaces, "out interfaces:aa{sv}" do
          response = network.interfaces.map do |iface|
            Y2Network::DBus::Interface.new(iface).to_dbus
          end
          log_method("GetInterfaces", response)
          [response]
        end

        dbus_method :GetConnections, "out connections:aa{sv}" do
          response = network.connections.map do |conn|
            Y2Network::DBus::ConnectionConfig.from_connection(conn).to_dbus
          end
          log_method("GetConnections", response)
          [response]
        end

        dbus_method :GetRoutes, "out routes:aa{sv}" do
          response = network.routing.routes.map do |route|
            Y2Network::DBus::Route.new(route).to_dbus
          end
          log_method("GetRoutes", response)
          [response]
        end

        dbus_method :UpdateRoutes, "in routes:aa{sv}, out routes:aa{sv}" do |routes|
          response = update_network_config([:routing]) do |config|
            routes = routes.map do |r|
              new_route = Y2Network::DBus::Route.from_dbus(r)
              # FIXME: the route does not have visibility of the list of interfaces
              interface = r["Interface"] ? config.interfaces.by_name(r["Interface"]) : nil
              new_route.interface = interface
              new_route
            end

            routing_table = Y2Network::RoutingTable.new(routes.map(&:route))
            config.routing.tables.clear
            config.routing.tables << routing_table
            routes.map(&:to_dbus)
          end

          log_method("UpdateRoutes", response)
          [response]
        end

        dbus_method :UpdateConnections, "in conns:aa{sv}, out updated_conns:aa{sv}" do |conns|
          response = update_network_config([:interfaces, :connections]) do |config|
            new_connections = conns.map do |data|
              conn = config.connections.find { |c| c.name == data["Name"] }
              Y2Network::DBus::ConnectionConfig.from_dbus(data, connection: conn)
            end

            new_connections.each do |c|
              config.add_or_update_connection_config(c.connection)
            end

            new_connections.map(&:to_dbus)
          end

          log_method("UpdateConnections", response)
          [response]
        end

      private

        def update_network_config(only, &block)
          new_network = network.copy
          response = block.call(new_network)
          new_network.write(original: network, only: only)
          @network = new_network
          response
        end

        def log_method(name, response)
          puts "#{name}: #{response.inspect}"
        end
      end
    end
  end
end
