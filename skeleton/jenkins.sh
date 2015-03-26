#!/bin/bash

set -e

TEST_MODE=$1
export BEAKER_set="$2"

[ -f Gemfile.lock ] && rm Gemfile.lock
bundle install
bundle exec rake spec_clean syntax lint
bundle exec rake ${TEST_MODE}
