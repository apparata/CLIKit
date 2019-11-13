#!/bin/sh

#
# Build reference documentation
#

MODULE=CLIKit
AUTHOR=Apparata
AUTHOR_URL=http://apparata.se
GITHUB_URL=https://github.com/apparata/CLIKit

# Change directory to where this script is located
cd "$(dirname ${BASH_SOURCE[0]})"

# The output will go in docs/${MODULE}
rm -rf "docs/${MODULE}"
mkdir -p "docs/${MODULE}"

jazzy \
  --clean \
  --module $MODULE \
  --author $AUTHOR \
  --author_url $AUTHOR_URL \
  --github_url $GITHUB_URL \
  --output "docs/${MODULE}" \
  --readme "README.md" \
  --theme fullwidth \
  --source-directory . \
  --swift-build-tool spm \
  --build-tool-arguments -Xswiftc,-swift-version,-Xswiftc,5

open "docs/${MODULE}/index.html"
