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

require "y2network/interface"

module Y2Network
  module DBus
    # It wraps a `Y2Network::Interface` class adding methods to convert from/to
    # DBus data.
    #
    # @todo Forward methods to the wrapped connection
    class Interface
      attr_reader :interface

      # @param interface [Y2Network::Interface] Network interface
      def initialize(interface)
        @interface = interface
      end

      # Returns interface DBus data in a hash
      #
      # @return [Hash<String,Object>]
      def to_dbus
        data = {
          "Name"        => interface.name,
          "Description" => interface.description,
          "Type"        => interface.type.short_name, # it should use a number
        }

        hardware = interface.hardware
        additional =
          if hardware
            {
              "Mac"     => hardware.mac.to_s,
              "Driver"  => hardware.driver,
              "Virtual" => false
            }
          else
            { "Virtual" => true }
          end

        data.merge(additional)
      end
    end
  end
end
