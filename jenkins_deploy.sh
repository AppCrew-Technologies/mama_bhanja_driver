#!/bin/bash

set -euo pipefail

# Extend PATH for Homebrew and CLI tools
export PATH="/opt/homebrew/opt/node@22/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

# Set UTF-8 encoding to avoid CocoaPods and Ruby errors
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Activate rbenv (for correct Ruby, Bundler, Fastlane, etc.)
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

sh ./deploy_apps.sh