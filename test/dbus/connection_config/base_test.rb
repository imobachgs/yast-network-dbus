# frozen_string_literal: true

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

require_relative "../../test_helper"
require "y2network/dbus/connection_config/base"
require "y2network/connection_config/ethernet"

describe Y2Network::DBus::ConnectionConfig::Base do
  subject { described_class.new(conn) }

  let(:conn) do
    Y2Network::ConnectionConfig::Ethernet.new.tap do |c|
      c.name = "eth0"
      c.ip = ip_config
      c.description = "Default connection"
    end
  end

  let(:ip_config) do
    Y2Network::ConnectionConfig::IPConfig.new(
      Y2Network::IPAddress.from_string("192.168.1.1/24"),
      label: "default",
    )
  end

  describe "#to_dbus" do
    it "returns DBus data" do
      expect(subject.to_dbus).to include(
        "BootProto"   => "static",
        "Description" => "Default connection",
        "IP"          => "192.168.1.1/24",
        "Id"          => conn.id,
        "Label"       => "default",
        "Name"        => "eth0",
        "StartMode"   => "manual",
        "Type"        => "eth",
        "Virtual"     => false
      )
    end
  end

  describe "#from_dbus" do
    let(:dbus_data) do
      {
        "Name" => "eth1",
        "BootProto" => "static",
        "StartMode" => "ifplugd"
      }
    end

    it "sets connection properties according to D-Bus data" do
      subject.from_dbus(dbus_data)
      updated_conn = subject.connection
      expect(updated_conn.name).to eq("eth1")
      expect(updated_conn.startmode).to eq(Y2Network::Startmode.create("ifplugd"))
      expect(updated_conn.bootproto).to eq(Y2Network::BootProtocol.from_name("static"))
    end
  end
end
