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

require "y2network/route"

module Y2Network
  module DBus
    class Route
      extend Forwardable

      attr_reader :route

      def_delegators :@route, :interface, :interface=

      class << self
        def from_dbus(data)
          route = new(Y2Network::Route.new)
          route.from_dbus(data)
          route
        end
      end
      # @param route [Y2Network::Route] Network route
      def initialize(route)
        @route = route
      end

      # Returns a hash containing the route DBus data
      #
      # @return [Hash<String,Object>]
      def to_dbus
        data = {
          "Default" => route.default?,
          "Options" => route.options
        }
        data["Destination"] = "#{route.to}/#{route.to.prefix}" unless route.default?
        data["Interface"] = route.interface.name if route.interface
        data["Gateway"] = route.gateway.to_s if route.gateway
        data
      end

      # @param data [Hash] D-Bus data
      def from_dbus(data)
        if data["Default"]
          route.to = :default
        else
          route.to = IPAddr.new(data["Destination"]) if data["Destination"]
        end
        route.gateway = IPAddr.new(data["Gateway"]) if data["Gateway"]
        route.options = data["Options"] if data["Options"]
      end
    end
  end
end
