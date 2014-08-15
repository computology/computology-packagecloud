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

define packagecloud::repo(
  $type = undef,
  $fq_name = undef,
  $master_token = undef,
  $gpg_url = "https://packagecloud.io/gpg.key",
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
    $read_token = get_read_token($repo_name, $master_token)
  }

  if $read_token {
    $base_url = "https://${read_token}:@packagecloud.io"
  } else {
    $base_url = "https://packagecloud.io"
  }

  if $type == 'gem' {
    exec { "install packagecloud ${repo_name} repo as gem source":
      command => "gem source --add ${base_url}/${repo_name}/",
      unless  => "gem source --list | grep ${base_url}/${repo_name}",
    }
  } elsif $type == 'deb' {
    $osname = downcase($::operatingsystem)
    case $osname {
      'debian', 'ubuntu': {

        include apt

        apt::source { "${normalized_name}":
          location         => "${base_url}/${repo_name}/$osname",
          repos            => 'main',
          key              => 'D59097AB',
          key_server       => 'pgp.mit.edu',
          include_src      => true,
        }
      }

      default: {
        fail("Sorry, $::operatingsystem isn't supported for apt repos at this time. Email support@packagecloud.io")
      }
    }
  } elsif $type == 'rpm' {
    case $::operatingsystem {
      'RedHat', 'redhat', 'CentOS', 'centos', 'Amazon', 'Fedora', 'Scientific': {

        if !$::pygpgme_installed {
          warning("The pygpgme package could not be installed. This means GPG verification is not possible for any RPM installed on your system. To fix this, add a repository with pygpgme. Usualy, the EPEL repository for your system will have this. More information: https://fedoraproject.org/wiki/EPEL#How_can_I_use_these_extra_packages.3F and https://github.com/stahnma/puppet-module-epel")
          $repo_gpgcheck = 0
        } else {
          $repo_gpgcheck = 1
        }

        yumrepo { "${normalized_name}":
          ensure => present,
          descr   => "${base_url}/${repo_name}",
          enabled => 1,
          baseurl => $::operatingsystem ? {
            /(RedHat|redhat|CentOS|centos)/ => "${base_url}/${repo_name}/el/$::operatingsystemmajrelease/$::architecture/",
            'Fedora' => "${base_url}/${repo_name}/fedora/$::operatingsystemmajrelease/$::architecture/",
            'Amazon' => "${base_url}/${repo_name}/el/6/$::architecture",
          },
          gpgcheck      => 0,
          gpgkey        => $gpg_url,
          sslverify     => 1,
          sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
          repo_gpgcheck => $repo_gpgcheck,
        }

        exec { "yum_make_cache_${repo_name}":
          command => "yum -q makecache -y --disablerepo='*' --enablerepo='${normalized_name}'",
          path => "/usr/bin",
          require => Yumrepo["${normalized_name}"],
        }
      }

      default: {
        fail("Sorry, $::operatingsystem isn't supported for yum repos at this time. Email support@packagecloud.io")
      }
    }
  }

}
