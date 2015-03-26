#!/bin/bash
## Purge existing files, to ensure we remove files as well
find $HOME/.puppet/var/puppet-module -type f -delete
## Primary checkout command:
find skeleton -type f | git checkout-index --stdin --force --prefix="$HOME/.puppet/var/puppet-module/" --
