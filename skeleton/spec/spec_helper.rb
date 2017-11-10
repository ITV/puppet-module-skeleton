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
    :architecture => 'x86_64',
    :awsregion => 'eu-west-1',
    :concat_basedir => '/dne',
    :ecosystem => 'dev',
    :ec2_ami_id => 'ami-12345678',
    :ec2_instance_type => 't2.medium',
    :ec2_placement_availability_zone => 'eu-west-1a',
    :env => 'test',
    :ipaddress => '10.10.10.10',
    :ipaddress_eth0 => '10.0.0.2',
    :ipaddress_eth1 => '10.0.0.3',
    :ipaddress_lo => '127.0.0.1',
    :is_virtual => true,
    :kernel => 'Linux',
    :kernelrelease => '1.2.3',
    :kernelversion => '3.10.0',
    :location => 'local',
    :operatingsystem => 'CentOS',
    :operatingsystemmajrelease => '7.2',
    :operatingsystemrelease => '7.0',
    :osfamily => 'RedHat',
    :path => '/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin',
    :product => 'product',
    :puppetversion => '4.8.1',
    :selinux => false,
    :sensu_plugins_omnibus => '1.3.0',
    :staging_http_get => 'curl',
    :sudoversion => '1.8.6p7',
    :virtual => 'xenhvm',
  }}
end
