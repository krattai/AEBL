#!/bin/bash
#
# ownCloud
#
# Run JS tests
#
# @author Vincent Petry
# @copyright 2014 Vincent Petry <pvince81@owncloud.com>
#

# set -e

NPM="$(which npm 2>/dev/null)"
PREFIX="build"

if test -z "$NPM"
then
	echo 'Node JS >= 0.8 is required to run the JavaScript tests' >&2
	exit 1
fi

# update/install test packages
mkdir -p "$PREFIX" && $NPM install --link --prefix "$PREFIX" || exit 3

KARMA="$(which karma 2>/dev/null)"

# If not installed globally, try local version
if test -z "$KARMA"
then
	KARMA="$PREFIX/node_modules/karma/bin/karma"
fi

if test -z "$KARMA"
then
	echo 'Karma module executable not found' >&2
	exit 2
fi

NODE_PATH='build/node_modules' KARMA_TESTSUITE="$1" $KARMA start tests/karma.config.js --single-run

