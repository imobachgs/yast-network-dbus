# Copyright (c) [2019] SUSE LLC
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

require "yast/rake"

Yast::Tasks.configuration do |conf|
  conf.skip_license_check << /doc\//
  conf.skip_license_check << /test\/data/
  conf.skip_license_check << /\.desktop$/
  conf.skip_license_check << /\.rnc$/
end

task :start do
  dirs = Dir["**/src"]
  dirs << ENV["Y2DIR"] if ENV["Y2DIR"] && !ENV["Y2DIR"].empty?
  ENV["Y2DIR"] = dirs.join(":")

  require "yast"
  require "y2network/dbus/server"
  Y2Network::DBus::Server.new.run
end
