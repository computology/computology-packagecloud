Exec {
  path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin' ]
}

case $operatingsystem {
  'RedHat', 'CentOS': {
    package { 'rubygems':
        ensure => present,
        name   => 'rubygems',
    }

    case $::operatingsystemrelease {
      /^5.*/: {
        package { 'epel5':
          ensure => present,
          source => 'http://mirror.vcu.edu/pub/gnu_linux/epel/5/i386/epel-release-5-4.noarch.rpm',
        }
      }
      default: {}
    }

    packagecloud::repo { 'computology/packagecloud-cookbook-test-public':
      fq_name => 'computology/packagecloud-cookbook-test-public',
      type    => 'rpm',
    }

    packagecloud::repo { 'computology/packagecloud-cookbook-test-private':
      type         => 'rpm',
      master_token => '762748f7ae0bfdb086dd539575bdc8cffdca78c6a9af0db9',
    }

    package { 'jake-docs':
      ensure  => installed,
      require => Packagecloud::Repo['computology/packagecloud-cookbook-test-private'],
    }
  }
  /^(Debian|Ubuntu)$/:{
    case $lsbdistcodename {
      'trusty': {
        package { 'dpkg-dev':
          ensure => present,
          name   => 'dpkg-dev',
        }
        package { 'rubygems':
          ensure => present,
          name   => 'rubygems-integration',
        }
      }
      default: {
        package { 'rubygems':
          ensure => present,
          name   => 'rubygems',
        }
        package { 'libgemplugin-ruby':
          ensure => present,
        }
      }
    }

    packagecloud::repo { 'computology/packagecloud-cookbook-test-public':
      fq_name => 'computology/packagecloud-cookbook-test-public',
      type    => 'deb',
    }

    packagecloud::repo { 'computology/packagecloud-cookbook-test-private':
      type         => 'deb',
      master_token => '762748f7ae0bfdb086dd539575bdc8cffdca78c6a9af0db9',
    }

    package { 'jake-doc':
      ensure  => installed,
      require => Packagecloud::Repo['computology/packagecloud-cookbook-test-private'],
    }

    exec { 'jake_source':
      command => '/usr/bin/apt-get source jake',
      cwd     => '/home/vagrant',
      require => Packagecloud::Repo['computology/packagecloud-cookbook-test-public'],
    }
  }
}

package { 'jake binary':
  ensure  => installed,
  name    => 'jake',
  require => Packagecloud::Repo['computology/packagecloud-cookbook-test-public'],
}

packagecloud::repo { 'gem repository for blah':
  fq_name => 'computology/packagecloud-cookbook-test-public',
  type    => 'gem',
}

package { 'jake gem':
    ensure          => 'installed',
    name            => 'jakedotrb',
    provider        => 'gem',
    install_options => ['--bindir', '/usr/local/bin'],
    require         => Package['rubygems'],
}
