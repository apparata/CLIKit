#!/bin/sh

#
# Build reference documentation
#

# Requires sourcekitten at https://github.com/jpsim/SourceKitten.git

# Change directory to where this script is located
cd "$(dirname ${BASH_SOURCE[0]})"

# SourceKitten needs .build/debug.yaml, so let's build the package.
rm -rf .build
swift build

# The output will go in refdocs/
# Make sure /refdocs is in .gitignore
rm -rf docs/CLIKit
mkdir -p "docs/CLIKit"

sourcekitten doc --spm-module CLIKit > CLIKitDocs.json

jazzy \
  --clean \
  --swift-version 5.1.0 \
  --sourcekitten-sourcefile CLIKitDocs.json \
  --author Apparata \
  --author_url http://apparata.se \
  --github_url https://github.com/apparata/CLIKit \
  --output "docs/CLIKit" \
  --readme "README.md" \
  --source-directory .

rm CLIKitDocs.json

open "docs/CLIKit/index.html"
