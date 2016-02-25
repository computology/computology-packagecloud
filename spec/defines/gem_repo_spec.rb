require 'spec_helper'

describe 'packagecloud::gem_repo' do
  let :pre_condition do
    "Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }"
  end

  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)

  context 'with sensible parameters' do
    let(:title) { 'username/publicrepo' }

    let(:params) do
      {
        :base_url => 'https://packagecloud.io',
        :repo_name => 'username/publicrepo',
      }
    end
    it do
      is_expected.to compile.with_all_deps
    end
    it do
      is_expected.to contain_exec('install packagecloud username/publicrepo repo as gem source').
             with({"command"=>"gem source --add https://packagecloud.io/username/publicrepo/",
                   "unless"=>"gem source --list | grep https://packagecloud.io/username/publicrepo"})
    end
    it do
      is_expected.to create_packagecloud__gem_repo('username/publicrepo')
    end
  end

end
