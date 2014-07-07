# packagecloud

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with packagecloud](#setup)
    * [What packagecloud affects](#what-packagecloud-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with packagecloud](#beginning-with-packagecloud)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This is the packagecloud.io puppet module which allows you to easily get public and private
packagecloud.io repositories installed on your infrastructure.

## Module Description

This is the packagecloud.io puppet module which allows you to easily get public and private
packagecloud.io repositories installed on your infrastructure.

## Setup

### What packagecloud affects

* The packagecloud module will:
  * install apt-transport-https or pygpgme as appropriate for the underlying system
  * add the packagecloud.io gpg key for verifying repository metadata
  * add apt or yum repos to the system by creating the necessary files under /etc/apt/sources.list.d/ and /etc/yum.repos.d/, respectively

### Beginning with packagecloud

Simply install the packagecloud puppet module and you will be able to use the packagecloud::repo resource in your manifests:

```
packagecloud::repo { "username/publicrepo":
  type => 'rpm',
}

packagecloud::repo { "username/privaterepo":
  type => 'deb',
  master_token => 'eae123bca276162f376b9614ba134fa7993624a8de0bb3a2',
}
```

## Usage

As in the examples show in the above section, you should specify at least `type` (which can be either deb, rpm, or gem) and optionally `master_token`
if the repository is private.

## Limitations

Currently supports:
  * Redhat Enterprise Linux 5 and 6
  * CentOS 5 and 6
  * Fedora 14 - 20
  * AWS Linux
  * Ubuntu 4.10 - 14.04
  * Debian 4.0 - 8.0

## Development

Pull requests are welcome!

## Release Notes/Contributors/Etc 

Special thanks to Eric Lindvall for help with puppet.

