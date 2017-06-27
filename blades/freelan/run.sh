#!/bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

export LD_LIBRARY_PATH="${SCRIPTPATH}/install/lib"
export DYLD_LIBRARY_PATH="${SCRIPTPATH}/install/lib"

${SCRIPTPATH}/install/bin/freelan $@
#valgrind ${SCRIPTPATH}/install/bin/freelan $@
#gdb --args ${SCRIPTPATH}/install/bin/freelan $@
#lldb -- ${SCRIPTPATH}/install/bin/freelan $@
