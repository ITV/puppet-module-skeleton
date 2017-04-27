require 'puppetlabs_spec_helper/module_spec_helper'
require 'yaml'

def fixture_path
  File.expand_path(File.join(__FILE__, '..', 'fixtures'))
end

# Add fixture lib dirs to LOAD_PATH. Work-around for PUP-3336
if Puppet.version < "4.0.0"
  Dir["#{fixture_path}/modules/*/lib"].entries.each do |lib_dir|
    $LOAD_PATH << lib_dir
  end
end

RSpec.configure do |c|
  c.formatter = :documentation
  # Enable colour in Jenkins
  c.color = true
  c.tty = true
  c.strict_variables = true
  c.parser = 'future'
  c.template_dir = File.expand_path(File.join(__FILE__, '../fixtures/templates'))
  c.hiera_config = File.expand_path(File.join(__FILE__, '../fixtures/hiera.yaml'))
  c.before do
    # avoid "Only root can execute commands as other users"
    Puppet.features.stubs(:root? => true)

    if ENV['RSPEC_PUPPET_DEBUG']
      Puppet::Util::Log.level = :debug
      Puppet::Util::Log.newdestination(:console)
      Puppet.settings[:graph] = true
      Puppet.settings[:graphdir] = "#{project_root}"
    end

  end
end

shared_context "facter" do
  let(:default_facts) {{
    :kernel => 'Linux',
    :osfamily => 'RedHat',
    :concat_basedir => '/dne',
    :operatingsystem => 'CentOS',
    :operatingsystemrelease => '7.0',
    :operatingsystemmajrelease => '7.2',
    :architecture => 'x86_64',
    :kernelversion => '3.10.0',
    :puppetversion => '4.8.1',
    :location => 'local',
    :sudoversion => '1.8.6p7',
    :path => '/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin',
    :selinux => false,
    :is_virtual => true,
    :ipaddress => '10.10.10.10',
    :ipaddress_lo => '127.0.0.1',
    :product => 'product',
    :env => 'test',
  }}
end
