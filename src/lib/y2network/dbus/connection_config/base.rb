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

require "y2network/connection_config/base"

module Y2Network
  module DBus
    module ConnectionConfig
      # It wraps a `Y2Network::DBus::ConnectionConfig::Base` interface adding
      # methods to convert from/to DBus data.
      #
      # @todo Forward methods to the wrapped connection
      class Base
        attr_reader :connection

        # @param connection [Y2Network::DBus::ConnectionConfig::Base] Original connection
        def initialize(connection)
          @connection = connection
        end

        def to_dbus
          data = {
            "Id"          => connection.id,
            "Name"        => connection.name,
            "Description" => connection.description.to_s,
            "BootProto"   => connection.bootproto.name,
            "StartMode"   => connection.startmode.name,
            "Virtual"     => connection.virtual?,
            "Type"        => connection.type.short_name,
          }

          data.merge!(ip_config_data(connection.ip)) if connection.ip
          data.merge(connection_data_by_type)
        end

        private

        # @todo Implement using subclasses
        def connection_data_by_type
          type_method = "#{connection.type.short_name}_connection_data".to_sym
          return {} unless respond_to?(type_method, true)
          send(type_method)
        end

        def bond_connection_data
          { "Interfaces" => [ connection.slaves ] }
        end

        # @param [Y2Network::IPConfig]
        def ip_config_data(ip_config)
          {
            "IP"    => ip_config.address.to_s,
            "Label" => ip_config.label.to_s
          }
        end
      end
    end
  end
end
