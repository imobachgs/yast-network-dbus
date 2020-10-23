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

require "y2network/dbus/connection_config/base"
require "y2network/dbus/connection_config/ethernet"
require "y2network/dbus/connection_config/bridge"

module Y2Network
  module DBus
    module ConnectionConfig
      CONFIG_CLASSES = {
        eth: Y2Network::DBus::ConnectionConfig::Ethernet,
        br: Y2Network::DBus::ConnectionConfig::Bridge,
      }.freeze

      # Creates an object from a DBus message and a connection
      #
      # @param connection [Y2Network::DBus::ConnectionConfig::Base,nil] the real
      #   connection. If it is nil, a new one will be created.
      # @param data [Hash<String,Object>] Data from D-Bus.
      # @return [Y2Network::DBus::ConnectionConfig::Base]#
      def self.from_dbus(data, connection: nil)
        klass = class_for_type(data["Type"])
        connection ||= klass.connection_class.new
        result = klass.new(connection)
        result.from_dbus(data)
        result
      end

      # Creates an object from a connection
      #
      # @return [Y2Network::DBus::ConnectionConfig::Base]
      def self.from_connection(connection)
        type = connection.type.short_name.to_sym
        klass = class_for_type(type)
        klass.new(connection)
      end

      # Determines the connection config class for a given type
      #
      # If a suitable class is not found, it returns
      # {Y2Network::DBus::ConnectionConfig::Ethernet}.
      #
      # @param type [String,Symbol,nil]
      # @return [Class]
      def self.class_for_type(type)
        CONFIG_CLASSES[type.to_sym] || Y2Network::DBus::ConnectionConfig::Ethernet
      end
    end
  end
end
