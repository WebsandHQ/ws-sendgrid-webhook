#!/bin/bash

NODEMON=`which nodemon`
TARGET='src/server.coffee'
DIRECTORY='src'

make browser_install
BASIC_USER=admin BASIC_PASSWORD=password DEVELOPMENT=1 $NODEMON --exitcrash -w "$DIRECTORY" "$TARGET"
