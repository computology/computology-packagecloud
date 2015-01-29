#
# Author: Joe Damato
# Module Name: packagecloud
#
# Copyright 2014-2015, Computology, LLC
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

require "uri"

module Puppet::Parser::Functions
  newfunction(:build_base_url, :type => :rvalue) do |args|
    read_token = args[0]
    server_address = args[1]

    uri = URI(server_address)
    uri.user = read_token
    uri.password = ''

    uri.to_s
  end
end
