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

require_relative "../test_helper"
require "y2network/dbus/network_config"
require "y2network/connection_config/ethernet"

describe Y2Network::DBus::NetworkConfig do
  subject { described_class.new(config) }

  let(:config) do
    Y2Network::Config.new(source: :sysconfig, connections: conns, interfaces: interfaces)
  end
  let(:eth_conn) { Y2Network::ConnectionConfig::Ethernet.new }
  let(:conns) { Y2Network::ConnectionConfigsCollection.new([eth_conn]) }

  let(:eth0) { Y2Network::PhysicalInterface.new("eth0") }
  let(:interfaces) { Y2Network::InterfacesCollection.new([eth0]) }

  describe "#interfaces" do
    it "returns a list of wrapped interface objects" do
      ifaces = subject.interfaces.to_a
      expect(ifaces.size).to eq(1)
      iface = ifaces.first
      expect(iface).to be_a(Y2Network::DBus::Interface)
      expect(iface.interface).to eq(eth0)
    end
  end

  describe "#connections" do
    it "returns a list of wrapped connection config objects" do
      conns = subject.connections.to_a
      expect(conns.size).to eq(1)
      conn = conns.first
      expect(conn).to be_a(Y2Network::DBus::ConnectionConfig::Base)
      expect(conn.connection).to eq(eth_conn)
    end
  end

  describe "#write" do
    let(:original_config) do
      Y2Network::Config.new(source: :sysconfig)
    end

    let(:original) { described_class.new(original_config) }

    it "writes the configuration to the system" do
      expect(config).to receive(:write).with(original: original_config, only: [:connections])
      subject.write(original: original, only: [:connections])
    end
  end

  describe "#copy"
end
