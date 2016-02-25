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

define packagecloud::repo(
  $type = undef,
  $fq_name = undef,
  $master_token = undef,
  $priority = undef,
  $server_address = 'https://packagecloud.io',
) {
  validate_string($type)
  validate_string($master_token)

  include packagecloud

  if $fq_name != undef {
    $repo_name = $fq_name
  } else {
    $repo_name = $name
  }

  $normalized_name = regsubst($repo_name, '\/', '_')

  if $master_token != undef {
    $read_token = get_read_token($repo_name, $master_token, $server_address)
    $base_url = build_base_url($read_token, $server_address)
  } else {
    $read_token = false
    $base_url = $server_address
  }

  case $type {
    'gem': {
      packagecloud::gem_repo {"Gem Repo ${repo_name}":
        base_url  => $base_url,
        repo_name => $repo_name,
      }
    }
    'deb': {
      $osname = downcase($::operatingsystem)
      case $osname {
        'debian', 'ubuntu': {

          $component = 'main'
          $repo_url = "${base_url}/${repo_name}/${osname}"
          $distribution =  $::lsbdistcodename

          file { $normalized_name:
            ensure  => file,
            path    => "/etc/apt/sources.list.d/${normalized_name}.list",
            mode    => '0644',
            content => template('packagecloud/apt.erb'),
          }

          exec { "apt_key_add_${normalized_name}":
            command => "wget --auth-no-challenge -qO - ${base_url}/${repo_name}/gpgkey | apt-key add -",
            path    => '/usr/bin/:/bin/',
            require => File[$normalized_name],
          }

          exec { "apt_get_update_${normalized_name}":
            command =>  "apt-get update -o Dir::Etc::sourcelist=\"sources.list.d/${normalized_name}.list\" -o Dir::Etc::sourceparts=\"-\" -o APT::Get::List-Cleanup=\"0\"",
            path    => '/usr/bin/:/bin/',
            require => Exec["apt_key_add_${normalized_name}"],
          }
        }
        default: {
          fail("Sorry, ${::operatingsystem} isn't supported for apt repos at this time. Email support@packagecloud.io")
        }
      }
    }
    'rpm': {
      case $::operatingsystem {
        'RedHat', 'redhat', 'CentOS', 'centos', 'Amazon', 'Fedora', 'Scientific', 'OracleLinux', 'OEL': {

          $majrel = $::osreleasemaj
          if $::pygpgme_installed == 'false' {
            warning('The pygpgme package could not be installed. This means GPG verification is not possible for any RPM installed on your system. To fix this, add a repository with pygpgme. Usualy, the EPEL repository for your system will have this. More information: https://fedoraproject.org/wiki/EPEL#How_can_I_use_these_extra_packages.3F and https://github.com/stahnma/puppet-module-epel')
            $repo_gpgcheck = 0
          } else {
            $repo_gpgcheck = 1
          }

          if $read_token {
            if $majrel == '5' {
              $yum_repo_url = $::operatingsystem ? {
                /(RedHat|redhat|CentOS|centos)/ => "${server_address}/priv/${read_token}/${repo_name}/el/5/${::architecture}/",
                /(OracleLinux|OEL)/ => "${server_address}/priv/${read_token}/${repo_name}/ol/5/${::architecture}/",
                'Scientific' => "${server_address}/priv/${read_token}/${repo_name}/scientific/5/${::architecture}/",
              }
              $gpg_url = "${server_address}/priv/${read_token}/${repo_name}/gpgkey"
            } else {
              $yum_repo_url = $::operatingsystem ? {
                /(RedHat|redhat|CentOS|centos)/ => "${base_url}/${repo_name}/el/${majrel}/${::architecture}/",
                /(OracleLinux|OEL)/ => "${base_url}/${repo_name}/ol/${majrel}/${::architecture}/",
                'Scientific' => "${base_url}/${repo_name}/scientific/${majrel}/${::architecture}/",
              }
              $gpg_url = "${base_url}/${repo_name}/gpgkey"
            }
          } else {
            $yum_repo_url = $::operatingsystem ? {
              /(RedHat|redhat|CentOS|centos)/ => "${base_url}/${repo_name}/el/${majrel}/${::architecture}/",
              /(OracleLinux|OEL)/ => "${base_url}/${repo_name}/ol/${majrel}/${::architecture}/",
              'Scientific' => "${base_url}/${repo_name}/scientific/${majrel}/${::architecture}/",
            }
            $gpg_url = "${base_url}/${repo_name}/gpgkey"
          }

          $description = $normalized_name
          $repo_url = $::operatingsystem ? {
            /(RedHat|redhat|CentOS|centos|Scientific|OracleLinux|OEL)/ => $yum_repo_url,
            'Fedora' => "${base_url}/${repo_name}/fedora/${majrel}/${::architecture}/",
            'Amazon' => "${base_url}/${repo_name}/el/6/${::architecture}",
          }

          file { $normalized_name:
            ensure  => file,
            path    => "/etc/yum.repos.d/${normalized_name}.repo",
            mode    => '0644',
            content => template('packagecloud/yum.erb'),
          }

          exec { "yum_make_cache_${repo_name}":
            command => "yum -q makecache -y --disablerepo='*' --enablerepo='${normalized_name}'",
            path    => '/usr/bin',
            require => File[$normalized_name],
          }
        }

        default: {
          fail("Sorry, ${::operatingsystem} isn't supported for yum repos at this time. Email support@packagecloud.io")
        }
      }
    }
    default: {
      fail("Sorry, ${type} isn't a supported repository type in this module right now. Email support@packagecloud.io")
    }
  }

}
