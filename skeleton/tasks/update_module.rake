
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
    'tasks/templates/puppetfile.erb',
    'tasks/update_module.rake',
  ]

  templates = [
    '.fixtures.yml.erb',
    'metadata.json.erb',
    'spec/classes/example_spec.rb.erb',
    'spec/spec_helper_acceptance.rb.erb',
    'README.markdown.erb',
  ]

  if safe_update
    protected_files = [
      '.fixtures.yml.erb',
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
    FileUtils.cp skeleton_file, File.join(Dir.getwd, f) if File.exists?(skeleton_file)
  end

  templates.each do |t|
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

desc 'Update module dependencies'
task :update_dependencies do |t,args|

  require 'erb'
  require 'yaml'
  require 'tempfile'

  templates = {
    'tasks/templates/fixtures.yml.erb' => '.fixtures.yml',
    'tasks/templates/puppetfile.erb' => 'Puppetfile',
  }

  metadata_file = File.join(Dir.getwd, "itv.yaml")

  metadata = {}

  File.open( metadata_file, "r" ) do |f|
    metadata = YAML.load( f )
  end

  profile_modules = metadata['dependencies']['puppet_modules']['profile_modules']
  repo_modules    = metadata['dependencies']['puppet_modules']['repo_modules']
  forge_modules   = metadata['dependencies']['puppet_modules']['forge_modules']
  local_modules   = metadata['dependencies']['puppet_modules']['local_modules']

  all_repo_modules = profile_modules.merge( repo_modules )

  templates.each_pair do |templ,target|
    template = ERB.new( File.read(File.join(Dir.getwd, templ)), 0, '-' )
    tmp_target = Tempfile.new(File.basename(templ))
    tmp_target.write template.result(binding)
    tmp_target.rewind
    FileUtils.cp tmp_target, target
  end

end

