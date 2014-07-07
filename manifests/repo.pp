define packagecloud::repo(
  $type = undef,
  $master_token = undef,
)
{
  validate_string($type)
  validate_string($master_token)

  include apt
  include packagecloud

  $normalized_name = regsubst($name, '\/', '_')

  if $master_token != undef {
    $read_token = get_read_token($name, $master_token)
  }

  if $read_token {
    $base_url = "https://${read_token}:@packagecloud.io"
  } else {
    $base_url = "https://packagecloud.io"
  }

  if $type == 'gem' {
    exec { "install packagecloud ${name} repo as gem source":
      command => "gem source --add ${base_url}/${name}",
      unless  => "gem source --list | grep ${base_url}/${name}"
    }
  } elsif $type == 'deb' {
    $osname = downcase($::operatingsystem)
    case $osname {
      'debian', 'ubuntu': {

        apt::source { "${normalized_name}":
          location         => "${base_url}/${name}/$osname",
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
      'RedHat', 'redhat', 'CentOS', 'centos', 'Amazon', 'Fedora': {

        package { 'pygpgme':
          ensure => latest,
        }

        yumrepo { "${normalized_name}":
          descr   => "packagecloud.io repo for ${name}",
          enabled => 1,
          baseurl => $::operatingsystem ? {
            /(RedHat|redhat|CentOS|centos)/ => "${base_url}/${name}/el/$::operatingsystemrelease/$::architecture/",
            'Fedora' => "${base_url}/${name}/fedora/$::operatingsystemrelease/$::architecture/",
            'Amazon' => "${base_url}/${name}/el/6/$::architecture",
          },
          gpgcheck      => 0,
          gpgkey        => 'https://packagecloud.io/gpg.key',
          repo_gpgcheck => 1,
        }
      }

      default: {
        fail("Sorry, $::operatingsystem isn't supported for yum repos at this time. Email support@packagecloud.io")
      }
    }
  }

}
