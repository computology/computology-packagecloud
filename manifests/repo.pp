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
  $server_address = "https://packagecloud.io",
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
    $base_url = $server_address
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

        #include puppetlabs-apt module
        include apt

        $component = 'main'
        $repo_url = "${base_url}/${repo_name}/${osname}"
        $distribution =  $::lsbdistcodename

        #Create the repository resource
        apt::source { "${normalized_name}":
          comment  => "${normalized_name}",
          ensure   => 'present',
          location => "${repo_url}",
          release  => "${distribution}",
          repos    => "${component}",
          include  => {
            'deb'    => true,
            'src'    => true,
          },
          key      => {
            'server'  => "${server_address}",
            'source'  => "${server_address}/gpg.key",
          },
        }          
        
        #Set apt update frequency
        class { 'apt':
          update => {
            frequency => 'daily',
          },
        }
      }

      default: {
        fail("Sorry, $::operatingsystem isn't supported for apt repos at this time. Email support@packagecloud.io")
      }
    }
  } elsif $type == 'rpm' {
    case $::operatingsystem {
      'RedHat', 'redhat', 'CentOS', 'centos', 'Amazon', 'Fedora', 'Scientific', 'OracleLinux', 'OEL': {

        $majrel = $::osreleasemaj
        if $::pygpgme_installed == 'false' {
          warning("The pygpgme package could not be installed. This means GPG verification is not possible for any RPM installed on your system. To fix this, add a repository with pygpgme. Usualy, the EPEL repository for your system will have this. More information: https://fedoraproject.org/wiki/EPEL#How_can_I_use_these_extra_packages.3F and https://github.com/stahnma/puppet-module-epel")
          $repo_gpgcheck = 0
        } else {
          $repo_gpgcheck = 1
        }

        if $read_token {
          if $majrel == '5' {
            $yum_repo_url = $::operatingsystem ? {
              /(RedHat|redhat|CentOS|centos)/ => "${server_address}/priv/${read_token}/${repo_name}/el/5/$::architecture/",
              /(OracleLinux|OEL)/ => "${server_address}/priv/${read_token}/${repo_name}/ol/5/$::architecture/",
              'Scientific' => "${server_address}/priv/${read_token}/${repo_name}/scientific/5/$::architecture/",
            }
          } else {
            $yum_repo_url = $::operatingsystem ? {
              /(RedHat|redhat|CentOS|centos)/ => "${base_url}/${repo_name}/el/${majrel}/$::architecture/",
              /(OracleLinux|OEL)/ => "${base_url}/${repo_name}/ol/${majrel}/$::architecture/",
              'Scientific' => "${base_url}/${repo_name}/scientific/${majrel}/$::architecture/",
            }
          }
        } else {
          $yum_repo_url = $::operatingsystem ? {
            /(RedHat|redhat|CentOS|centos)/ => "${base_url}/${repo_name}/el/${majrel}/$::architecture/",
            /(OracleLinux|OEL)/ => "${base_url}/${repo_name}/ol/${majrel}/$::architecture/",
            'Scientific' => "${base_url}/${repo_name}/scientific/${majrel}/$::architecture/",
          }
        }

        $description = $normalized_name
        $repo_url = $::operatingsystem ? {
          /(RedHat|redhat|CentOS|centos|Scientific|OracleLinux|OEL)/ => $yum_repo_url,
          'Fedora' => "${base_url}/${repo_name}/fedora/${majrel}/$::architecture/",
          'Amazon' => "${base_url}/${repo_name}/el/6/$::architecture",
        }

        $gpg_url = "${base_url}/gpg.key"
        $gpg_key_filename = get_gpg_key_filename($server_address)
        $gpg_file_path = "/etc/pki/rpm-gpg/RPM-GPG-KEY-${gpg_key_filename}"

        #create the repository resource
        yumrepo { "${normalized_name}":
          baseurl    => "${repo_url}", 
          descr      => "${description}",
          enabled    => 1,
          ensure     => 'present',
          gpgcheck   => 0,
          gpgkey     => "${gpg_url}",
          priority   => ${priority},
          repo_gpgcheck => ${repo_gpgcheck},
          sslcacert  => '/etc/pki/tls/certs/ca-bundle.crt',
          sslverify => 1,
        }
 
      }


      default: {
        fail("Sorry, $::operatingsystem isn't supported for yum repos at this time. Email support@packagecloud.io")
      }
    }
  }

}
