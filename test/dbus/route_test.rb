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

require_relative "../test_helper"
require "y2network/ip_address"
require "y2network/route"
require "y2network/virtual_interface"
require "y2network/dbus/route"

describe Y2Network::DBus::Route do
  subject { described_class.new(real_route) }

  let(:eth0) { Y2Network::VirtualInterface.new("eth0") }
  let(:real_route) do
    Y2Network::Route.new(
      to:      destination,
      gateway: gateway
    )
  end

  let(:destination) { IPAddr.new("192.168.1.0/24") }
  let(:gateway) { IPAddr.new("192.168.1.1") }

  describe "#to_dbus" do
    it "returns DBus data" do
      expect(subject.to_dbus).to eq(
        "Default"     => false,
        "Destination" => "192.168.1.0/24",
        "Gateway"     => "192.168.1.1",
        "Options"     => ""
      )
    end

    context "when it is the default route" do
      let(:destination) { :default }

      it "sets the 'Default' key to true" do
        expect(subject.to_dbus).to eq(
          "Default" => true,
          "Gateway" => "192.168.1.1",
          "Options" => ""
        )
      end
    end

    describe "#from_dbus" do
      let(:dbus_data) do
        {
          "Default" => false,
          "Gateway" => "192.168.2.1",
          "Destination" => "192.168.2.0/24"
        }
      end

      it "sets the configuration according to the DBus data" do
        subject.from_dbus(dbus_data)
        expect(subject.route.gateway).to eq(IPAddr.new("192.168.2.1"))
        expect(subject.route.to).to eq(IPAddr.new("192.168.2.0/24"))
      end

      context "when it is the default route" do
        let(:dbus_data) do
          {
            "Default" => true,
            "Gateway" => "192.168.2.1"
          }
        end
        it "sets the route as the default one" do
          subject.from_dbus(dbus_data)
          expect(subject.route).to be_default
          expect(subject.route.gateway).to eq(IPAddr.new("192.168.2.1"))
        end
      end
    end
  end
end
