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
require "y2network/dbus/network"
require "y2network/config"

module Y2Network
  module DBus
    class Server
      # Runs the client
      #
      # Starts a DBus service.
      def run
        bus = ::DBus::session_bus
        service = bus.request_service("org.opensuse.YaST2.Network")
        network_config = Y2Network::Config.from(:sysconfig)

        exported_network = Y2Network::DBus::Network.new(
          "/org/opensuse/YaST2/Network", network_config
        )
        service.export(exported_network)

        main_loop = ::DBus::Main.new
        main_loop << bus
        main_loop.run
      end
    end
  end
end
