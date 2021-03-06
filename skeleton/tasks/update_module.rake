
desc 'Update module from puppet-module-skeleton'
task :update_from_skeleton, :safe_update do |t,args|

  args.with_defaults(:safe_update => false)
  safe_update = args[:safe_update]

  require 'erb'
  require 'json'

  require 'ostruct'
  metadata = {}
  metadata = OpenStruct.new(metadata)

  static_files = [
    'Gemfile',
    'Rakefile',
    'jenkins.sh',
    '.gitignore',
    'spec/spec_helper.rb',
    'spec/acceptance/nodesets/default.yml',
    'spec/acceptance/nodesets/centos6.yml',
    'spec/acceptance/nodesets/centos7.yml',
    'spec/acceptance/nodesets/vagrant-centos6.yml',
    'spec/acceptance/nodesets/vagrant-centos7.yml',
    'tasks/templates/fixtures.yml.erb',
    'tasks/templates/test-puppetfile.erb',
    'tasks/templates/deps-puppetfile.erb',
    'tasks/templates/metadata.json.erb',
    'tasks/update_module.rake',
  ]

  templates = [
    'itv.yaml.erb',
    'metadata.json.erb',
    'spec/classes/example_spec.rb.erb',
    'spec/spec_helper_acceptance.rb.erb',
    'README.markdown.erb',
  ]

  if safe_update
    protected_files = [
      'metadata.json.erb',
      'spec/classes/example_spec.rb.erb',
      'README.markdown.erb',
    ]
    static_files = static_files - protected_files
    templates = templates - protected_files
  end

  skeleton_dir = File.join( File.expand_path('~'), '.puppet/var/puppet-module/skeleton')

  metadata_file = File.join(Dir.getwd, "metadata.json")

  metadata_hash = {}

  File.open( metadata_file, "r" ) do |f|
    metadata_hash = JSON.load( f )
  end

  repo_name = metadata_hash['name']

  if repo_name =~ /^(itv-|puppetmodule-)/
    repo_name.gsub!(/^itv-/, 'puppet-module-')
    repo_name.gsub!(/^puppetmodule-/, 'puppet-module-')
    File.open( metadata_file ,"w" ) do |f|
      metadata_hash['name'] = repo_name
      f.write(JSON.pretty_generate metadata_hash)
    end
  end

  metadata.name         = repo_name =~ /^(puppet-module)/ ? repo_name.split(/puppet-module-/)[1] : repo_name
  metadata.author       = 'itv'
  metadata.license      = 'Apache 2.0'
  metadata.version      = metadata_hash['version']
  metadata.source       = metadata_hash['source']
  metadata.author       = metadata_hash['author']
  metadata.summary      = metadata_hash['summary']
  metadata.issues_url   = metadata_hash['issues_url']
  metadata.description  = metadata_hash['description']
  metadata.project_page = metadata_hash['project_page']

  static_files.each do |f|
    skeleton_file =  File.join( skeleton_dir, f)
    FileUtils.mkdir_p ( File.dirname(f) )
    FileUtils.cp skeleton_file, File.join(Dir.getwd, f) if File.exists?(skeleton_file)
  end

  templates.each do |t|
    next unless File.exists? (File.join( skeleton_dir, t))
    template = ERB.new( File.read(File.join( skeleton_dir, t)), 0, '<>' )
    tmp_target = Tempfile.new(File.basename(t))
    tmp_target.write template.result(binding)
    tmp_target.rewind
    target_file = File.join(Dir.getwd, File.join(File.dirname(t),File.basename(t, '.erb')))
    FileUtils.cp tmp_target, target_file
  end

end


### This task manages the Puppetfile and .fixtures.yaml, to provide a consist mechanism
### for listing and updating dependencies for modules

task :spec => [:update_module, :update_dependencies]
task :acceptance => [:update_module, :update_dependencies]
task :beaker => [:update_module, :update_dependencies]
task :update_deps => [:update_module, :update_dependencies]

desc 'Update module config from itv.yaml'
task :update_module do |t,args|

  project_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  fixture_path = File.expand_path(File.join(project_root, 'spec', 'fixtures'))

  puts "\nUpdating module config from itv.yaml ..."

  require 'erb'
  require 'yaml'
  require 'tempfile'
  require 'bundler'

  templates = {
    'tasks/templates/fixtures.yml.erb' => '.fixtures.yml',
    'tasks/templates/deps-puppetfile.erb' => 'Puppetfile',
    'tasks/templates/test-puppetfile.erb' => "#{fixture_path}/Puppetfile",
    'tasks/templates/metadata.json.erb' => 'metadata.json',
  }

  metadata_file = File.join(Dir.getwd, "itv.yaml")

  metadata = {}

  File.open( metadata_file, "r" ) do |f|
    metadata = YAML.load( f )
  end

  profile_modules = metadata['dependencies']['puppet_modules']['profile_modules'] || nil
  repo_modules    = metadata['dependencies']['puppet_modules']['repo_modules'] || {}
  forge_modules   = metadata['dependencies']['puppet_modules']['forge_modules'] || {}
  local_modules   = metadata['dependencies']['puppet_modules']['local_modules']

  all_repo_modules = profile_modules.nil? ? repo_modules : profile_modules.merge( repo_modules )

  unless metadata['dependencies']['puppet_modules']['testing_modules'].nil?
    repo_testing_modules  = metadata['dependencies']['puppet_modules']['testing_modules']['repo_modules'] || {}
    forge_testing_modules = metadata['dependencies']['puppet_modules']['testing_modules']['forge_modules'] || {}
  else
    repo_testing_modules  = {}
    forge_testing_modules = {}
  end

  fixture_repo_modules  = all_repo_modules.merge( repo_testing_modules )
  fixture_forge_modules = forge_modules.merge( forge_testing_modules )

  templates.each_pair do |templ,target|
    template = ERB.new( File.read(File.join(Dir.getwd, templ)), 0, '-' )
    tmp_target = Tempfile.new(File.basename(templ))
    tmp_target.write template.result(binding)
    tmp_target.rewind
    FileUtils.cp tmp_target, target
  end

  puts "\n ... update complete! \n"

end

desc 'Update module dependencies'
task :update_dependencies do |t,args|

  project_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  fixture_path = File.expand_path(File.join(project_root, 'spec', 'fixtures'))

  puts "\n ... running librarian-puppet \n\n"

  Dir.chdir( fixture_path ) do
    Bundler.with_clean_env do
      if ENV['LIBRARIAN_clean'] == 'true'
        sh "bundle exec librarian-puppet clean --verbose" do |ok,res|
          unless ok
            raise "something went wrong during the Librarian clean operation! see output for details"
          end
        end
      end
      if File.exists?(File.join( fixture_path, 'Puppetfile.lock' ))
        puts "Found lockfile, and update is not overriden"
        FileUtils.rm_f (File.join( fixture_path, 'Puppetfile.lock' ))
      end unless ENV['LIBRARIAN_lock'] == 'true'
      sh "bundle exec librarian-puppet install --verbose" do |ok,res|
        unless ok
          raise "something went wrong during the Librarian install! see output for details"
        end
      end
    end
  end

end
