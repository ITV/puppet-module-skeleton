require 'puppetlabs_spec_helper/module_spec_helper'
require 'hiera-puppet-helper'
require 'yaml'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))

RSpec.configure do |c|
  c.formatter = :documentation
  # Enable colour in Jenkins
  c.color = true
  c.tty = true
  c.before do
    # avoid "Only root can execute commands as other users"
    Puppet.features.stubs(:root? => true)
  end
end

# use both rpsec and yaml backends .. see: https://github.com/bobtfish/hiera-puppet-helper#advanced
shared_context "hieradata" do
  let(:hiera_config) do
    { :backends => ['rspec', 'yaml'],
    :hierarchy => [
      '%{fqdn}/%{calling_module}',
      '%{calling_module}',
      'common'],
    :yaml => {
      :datadir => File.join(fixture_path, 'hieradata') },
    :rspec => respond_to?(:hiera_data) ? hiera_data : {} }
  end
end

shared_context "facter" do
  let(:default_facts) {{
    :kernel => 'Linux',
    :osfamily => 'RedHat',
    :concat_basedir => '/dne',
    :operatingsystem => 'CentOS',
    :cache_bust => Time.now,
  }}
end
