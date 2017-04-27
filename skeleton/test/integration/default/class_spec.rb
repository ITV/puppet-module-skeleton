control 'packages' do

  impact 1.0
  title 'Ensure all required packages are installed'
  desc 'These packages and repos must be installed/configured during base profile configuration'

  required_yum_repos = [
  ]

  required_yum_repos.each do |repo|
    describe yum.repo(repo) do
      it { should exist }
      it { should be_enabled }
    end
  end

  required_rpms = [
  ]

  required_rpms.each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end

end

control 'services' do

  impact 1.0
  title 'Ensure all required serviced are running'
  desc 'These services must be running after base profile configuration'

  required_services = [
  ]

  required_services.each do |svc|
    describe service(svc) do
      it { should be_enabled }
      it { should be_running }
    end
  end

end

control 'files' do

  impact 1.0
  title 'Ensure all required files are present'
  desc 'These files must be present after base profile configuration'

  files = [
  ]

  files.each do |script|
    describe file(script) do
      it { should be_executable }
    end
  end

end
