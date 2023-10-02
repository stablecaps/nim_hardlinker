#!/bin/bash

set -e

mkdir -p bin bin_dev htmldocs src tests
touch bin/placeholder.txt bin_dev/placeholder.txt

cat <<EOF > nimHardlinker.nimble
# Package

version       = "0.9.0"
author        = "Giri"
description   = "Program Hardlink files in Linux"
license       = "MIT"
srcDir        = "src"
bin           = @["nimHardlinker"]


# Dependencies

requires "nim ^= 1.6.12"
requires "docopt ^= 0.6.7"
EOF