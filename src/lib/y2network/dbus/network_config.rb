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

require "y2network/config"
require "y2network/connection_configs_collection"
require "y2network/interfaces_collection"
require "y2network/dbus/connection_config/base"
require "y2network/dbus/interface"

module Y2Network
  module DBus
    # This class wraps a `Y2Network::Config` object and extends its API
    # to convert data to/from DBus.
    class NetworkConfig
      attr_reader :config

      # @param config [Y2Network::Config] Network configuration
      def initialize(config)
        @config = config
      end

      # Returns a collection of wrapped connection objects
      #
      # @return [Y2Network::ConnectionsConfigCollection] Collection of connection objects
      def connections
        return @connections if @connections

        conns = config.connections.map do |conn|
          Y2Network::DBus::ConnectionConfig::Base.new(conn)
        end

        @connections = Y2Network::ConnectionConfigsCollection.new(conns)
      end

      # Returns a collection of wrapped interface objects
      def interfaces
        return @interfaces if @interfaces

        ifaces = config.interfaces.map do |iface|
          Y2Network::DBus::Interface.new(iface)
        end

        @interfaces = Y2Network::InterfacesCollection.new(ifaces)
      end
    end
  end
end
