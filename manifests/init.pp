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

class packagecloud() {
    case $::operatingsystem {
      'debian', 'ubuntu': {
        package { 'apt-transport-https':
          ensure => latest,
        }
      }
      'RedHat', 'redhat', 'CentOS', 'centos', 'Amazon', 'Fedora', 'Scientific', 'OracleLinux', 'OEL': {
        package { 'pygpgme':
          ensure => latest,
        }
      }
      default: {
        fail("Sorry, $::operatingsystem isn't supported. Email support@packagecloud.io for help.")
      }
    }
}
