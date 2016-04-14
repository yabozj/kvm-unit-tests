#!/bin/bash

verbose="no"

if [ ! -f config.mak ]; then
    echo "run ./configure && make first. See ./configure -h"
    exit 1
fi
source config.mak
source scripts/functions.bash

function usage()
{
cat <<EOF

Usage: $0 [-g group] [-a accel] [-o qemu_opts] [-t] [-h] [-v]

    -g: Only execute tests in the given group
    -a: Force acceleration mode (tcg/kvm)
    -o: additional options for QEMU command line
    -t: disable timeouts
    -h: Output this help text
    -v: Enables verbose mode

Set the environment variable QEMU=/path/to/qemu-system-ARCH to
specify the appropriate qemu binary for ARCH-run.

EOF
}

RUNTIME_arch_run="./$TEST_DIR/run"
source scripts/runtime.bash

while getopts "g:a:o:thv" opt; do
    case $opt in
        g)
            only_group=$OPTARG
            ;;
        a)
            force_accel=$OPTARG
            ;;
        o)
            extra_opts=$OPTARG
            ;;
        t)
            no_timeout="yes"
            ;;
        h)
            usage
            exit
            ;;
        v)
            verbose="yes"
            ;;
        *)
            exit 1
            ;;
    esac
done

if [ "$PRETTY_PRINT_STACKS" = "yes" ]; then
	log_redir="> >(./scripts/pretty_print_stacks.py \$kernel >> test.log)"
else
	log_redir=">> test.log"
fi

RUNTIME_arch_run="./$TEST_DIR/run $log_redir"
config=$TEST_DIR/unittests.cfg
rm -f test.log
printf "BUILD_HEAD=$(cat build-head)\n\n" > test.log
for_each_unittest $config run "$extra_opts"
