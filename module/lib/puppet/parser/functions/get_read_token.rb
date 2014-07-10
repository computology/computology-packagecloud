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

require "uri"
require "net/https"

module Packagecloud
  class API
    BASE_URL = "https://packagecloud.io/install/repositories/"

    attr_reader :name

    def initialize(name, master_token, os, dist, hostname)
      @name         = name
      @master_token = master_token
      @os           = os
      @dist         = dist
      @hostname     = hostname

      @endpoint_params = {
        :os   => os,
        :dist => dist,
        :name => hostname
      }
    end

    def repo_name
      @name.gsub('/', '_')
    end

    def rpm_base_url
      @rpm_base_url ||= master_rpm_base_url.dup.tap do |uri|
        uri.user = read_token
      end
    end

    def master_rpm_base_url
      @master_rpm_base_url ||= URI(get(uri_for("rpm_base_url"), @endpoint_params).body.chomp)
    end

    def read_token
      @read_token ||= post(uri_for("tokens.text"), @endpoint_params).body.chomp
    end

    def uri_for(resource)
      URI(BASE_URL + "#{@name}/#{resource}").tap do |uri|
        uri.user = @master_token
      end
    end

    def get(uri, params)
      uri.query = URI.respond_to?(:encode_www_form) ? URI.encode_www_form(params) : params.to_param
      request   = Net::HTTP::Get.new(uri.request_uri)

      if uri.user
        request.basic_auth uri.user.to_s, uri.password.to_s
      end

      http(uri.host, uri.port, request)
    end

    def post(uri, params)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.form_data = params

      if uri.user
        request.basic_auth uri.user.to_s, uri.password.to_s
      end

      http(uri.host, uri.port, request)
    end

    def http(host, port, request)
      http = Net::HTTP.new(host, port)
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.use_ssl = true
      store = OpenSSL::X509::Store.new
      store.set_default_paths
      http.cert_store = store

      case res = http.start { |http| http.request(request) }
      when Net::HTTPSuccess, Net::HTTPRedirection
        res
      else
        res.error!
      end
    end
  end
end

module Puppet::Parser::Functions
  newfunction(:get_read_token, :type => :rvalue) do |args|
    repo = args[0]
    master_token = args[1]

    os = lookupvar('::operatingsystem').downcase
    dist = lookupvar('::operatingsystemrelease')
    hostname = lookupvar('::fqdn')

    Packagecloud::API.new(repo, master_token, os, dist, hostname).read_token
  end
end
