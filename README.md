ITV puppet module skeleton, heavily derived from Gareth Rushgrove's
work at [https://github.com/garethr/puppet-module-skeleton] which 
is released under an Apache software license.

Puppet modules often take on the same file system structure. The
built-in puppet-module tool makes starting modules easy, but the build
in skeleton module is very simple. This skeleton is very opinionated.
It's going to assume you're going to start out with tests (both unit and
system), that you care about the puppet style guide, test using Travis,
keep track of releases and structure your modules according to strong
conventions.

## Installation

As a feature, puppet module tool will use `~/.puppet/var/puppet-module/skeleton`
as template for its `generate` command. The files provided here are
meant to be better templates for use with the puppet module tool.

As we don't want to have our .git files and this README in our skeleton, we export it like this:

    git clone https://github.com/ITV/puppet-module-skeleton 
    cd puppet-module-skeleton
    find skeleton -type f | git checkout-index --stdin --force --prefix="$HOME/.puppet/var/puppet-module/" --

## Usage

Then just generate your new module structure like so:

    puppet module generate user-module

Once you have your module then install the development dependencies:

    cd user-module
    bundle install

Now you should have a bunch of rake commands to help with your module
development:

    bundle exec rake -T
    rake acceptance        # Run acceptance tests
    rake build             # Build puppet module package
    rake clean             # Clean a built module package
    rake contributors      # Populate CONTRIBUTORS file
    rake coverage          # Generate code coverage information
    rake help              # Display the list of available rake tasks
    rake lint              # Check puppet manifests with puppet-lint / Run puppet-lint
    rake spec              # Run spec tests in a clean fixtures directory
    rake spec_clean        # Clean up the fixtures directory
    rake spec_prep         # Create the fixtures directory
    rake spec_standalone   # Run spec tests on an existing fixtures directory
    rake syntax            # Syntax check Puppet manifests and templates
    rake syntax:manifests  # Syntax check Puppet manifests
    rake syntax:templates  # Syntax check Puppet templates

Of particular interst should be:

* `rake spec` - run unit tests
* `rake lint` - checks against the puppet style guide
* `rake syntax` - to check your have valid puppet and erb syntax

## Thanks

The trick used in the installation above, and a few other bits came from
another excellent module skeleton from [spiette](https://github.com/spiette/puppet-module-skeleton).

---
# Divergence from upstream:

This module started out life as a duplication of garethr's [puppet-module-skeleton](https://github.com/garethr/puppet-module-skeleton),
the following is a list of changes that have been implemented:

- Gemfile:
  - add `puppet-lint-indent-check`, to allow indentation depth to be selected
  - add bobtfish's fork of `hiera-puppet-helper`, to facilitate hiera lookups
  - pin `docker-api` to 1.14, to ensure we don't have a version mismatch on centos7
- README.md:
  - add description of testing
- Rakefile:
  - Add PuppetLint overrides, with warning comment
  - Add PuppetLint chars_pre_indent, configurable by environment variable
  - Add `update_from_skeleton` task, to update current module to latest skeleton module
- metadata.json
  - Change name to ensure we follow the convention of `puppet-module-#{module_name}`
  - Add concat to list of included dependencies
- spec/spec_helper_acceptance.rb
  - Conditionaly include specific options based on the naming of modules
  - Several helper methods added, to facilitate testing for modules:
    - `upload_ssh_config` - explicitly set agent forwarding, and handle host keys
    - `upload_hiera_config`
      - create basic hiera config file for testing profile modules
        OR
      - upload an existing hiera config
    - `upload_hiera_yaml` - upload given hiera_data content, or file path, to nodeset
    - `upload_fixtures_file` - push any required files to modules_path, useful for adhoc config
    - `upload_fixtures_templates` - push any required templates to modules_path, useful for adhoc config
    - `upload_puppetfile`
      - uploads existing Puppetfile
        OR
      - creates a Puppetfile from a Puppetfile template, using the .fixtures.yml
    - `set_facts` - set facts on nodeset to values set in the nodeset yaml
    - `hieradata_common` - shared context, to upload the base common.yaml, with required hiera values
- spec/acceptance/class_spec.rb
  - add `hieradata_common` shared context
  - add `apply opts` to allow running puppet in debug mode by setting `BEAKER_puppet_debug`
  - add conditional to create specific test structure for profile modules
- spec/spec_helper.rb
  - Add shared context for hieradata, to assist with setting default hiera config, using rspec
    as a backend, to allow both setting hieradata in standard yaml, or within the specs themselves
  - Add shared context for facter, to set default facts, allowing us to make code more DRY
  - Add RSpec config, to set various options:
    - avoid "Only root can execute commands as other users"
    - set coloured output and tty in order for tests in Jenkins to be colourized
- spec/classes/example_spec.rb
  - allow target operating system to be configured based on BEAKER_set
  - add facter and hieradata shared contexts
  - ensure we conditionally create example_spec.rb based on module naming, to handle profile modules
- spec/acceptance/nodesets
  - Set default nodeset to use docker as the provider
  - Add nodesets for vagrant, for both centos6 and centos7
  - Add centos6 and centos7 specific nodesets for docker
