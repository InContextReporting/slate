#!/usr/bin/env bash
set -o errexit #abort if any command fails

bundle exec middleman build --clean
staticrypt build/index.html chatbotsinhealthcare -e -o build/index.html -f password_template.html

