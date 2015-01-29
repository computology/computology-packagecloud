#
# Author: Joe Damato
# Module Name: packagecloud
#
# Copyright 2014, Computology, LLC
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'uri'

module Packagecloud
  class GPG
    def self.compute_filename(server_address)
      URI.parse(server_address).host.gsub!('.', '_')
    end
  end
end

module Puppet::Parser::Functions
  newfunction(:get_gpg_key_filename, :type => :rvalue) do |args|
    server_address = args[0]
    Packagecloud::GPG.compute_filename(server_address)
  end
end
