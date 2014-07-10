Exec {
  path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ]
}

package { 'rubygems':
    name => 'rubygems',
    ensure => present,
}

case $operatingsystem {
  'RedHat', 'CentOS': { 
    packagecloud::repo { "computology/packagecloud-cookbook-test-public":
      fq_name => "computology/packagecloud-cookbook-test-public",
      type => 'rpm',
    }

    packagecloud::repo { "computology/packagecloud-cookbook-test-private":
      type => 'rpm',
      master_token => '762748f7ae0bfdb086dd539575bdc8cffdca78c6a9af0db9',
    }

    package { 'jake-docs':
      ensure => installed,
      require => Packagecloud::Repo["computology/packagecloud-cookbook-test-private"],
    }
  }
  /^(Debian|Ubuntu)$/:{ 
    packagecloud::repo { "computology/packagecloud-cookbook-test-public":
      fq_name => "computology/packagecloud-cookbook-test-public",
      type => 'deb',
    }

    packagecloud::repo { "computology/packagecloud-cookbook-test-private":
      type => 'deb',
      master_token => '762748f7ae0bfdb086dd539575bdc8cffdca78c6a9af0db9',
    }

    package { 'jake-doc':
      ensure => installed,
      require => Packagecloud::Repo["computology/packagecloud-cookbook-test-private"],
    }

    exec { 'jake_source':
      command => '/usr/bin/apt-get source jake',
      cwd => '/home/vagrant',
      require => Packagecloud::Repo["computology/packagecloud-cookbook-test-public"],
    }

    package { 'libgemplugin-ruby':
      ensure => present,
    }
  }
}

package { 'jake binary':
  name   =>  'jake',
  ensure => installed,
  require => Packagecloud::Repo["computology/packagecloud-cookbook-test-public"],
}

packagecloud::repo { "gem repository for blah":
  fq_name => "computology/packagecloud-cookbook-test-public",
  type => 'gem',
}

package { 'jake gem':
    name     => 'jakedotrb',
    ensure   => 'installed',
    provider => 'gem',
    require  => Package['rubygems'],
}
