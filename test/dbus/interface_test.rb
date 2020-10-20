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
require "y2network/dbus/interface"
require "y2network/physical_interface"

describe Y2Network::DBus::Interface do
  subject { described_class.new(real_iface) }

  let(:real_iface) do
    Y2Network::PhysicalInterface.new("eth0").tap do |i|
      i.description = "Interface #1"
    end
  end

  describe "#to_dbus" do
    let(:hardware) do
      instance_double(Y2Network::Hwinfo, mac: "01:23:45:67:89", driver: "virtio_net")
    end

    before do
      allow(real_iface).to receive(:hardware).and_return(hardware)
    end

    it "returns generic interface data" do
      expect(subject.to_dbus).to include(
        "Name"        => "eth0",
        "Type"        => "eth",
        "Description" => "Interface #1"
      )
    end

    it "returns hardware data" do
      expect(subject.to_dbus).to include(
        "Mac"     => hardware.mac,
        "Driver"  => hardware.driver,
        "Virtual" => false
      )
    end

    context "when there is no hardware" do
      let(:hardware) { nil }

      it "returns the interface as virtual" do
        exported = subject.to_dbus
        expect(exported).to include(
          "Virtual" => true
        )
        expect(exported.keys).to_not include("Mac")
        expect(exported.keys).to_not include("Driver")
      end
    end
  end
end
