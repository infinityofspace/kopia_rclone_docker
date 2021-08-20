#!/bin/bash

if [[ "$KOPIA_BUILD_TYPE" == "noui" ]]
then
  make install-noui KOPIA_BUILD_FLAGS="-ldflags '-linkmode external -extldflags -static'"
else
  make install KOPIA_BUILD_FLAGS="-ldflags '-linkmode external -extldflags -static'"
fi
