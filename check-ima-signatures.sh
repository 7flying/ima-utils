#!/bin/bash
#
# Checks if all the files part of an RPM have IMA signatures
#

script=${0##*/}
path=$1

if [ $# -ne 1 -o ! -s "$path" ]; then
    echo "Usage: $script <path-to-file>" >&2
    exit 1
fi

tmpd=$(mktemp -d tmp-ima-check-XXXXXXXXXX)

cp $path $tmpd; cd $tmpd

rpm2cpio $path | cpio -idm
output=$(find . -type f)
no_ima=0

for fpath in $output; do
    if [[ ! $(getfattr -m security.ima $fpath) ]]; then
        echo "IMA signature not found for" $fpath
        no_ima=$((no_ima+1))
    fi
done


if [[ $no_ima > 0 ]]; then
    echo $no_ima "file/s without IMA signatures"
else
    echo "IMA signatures OK for" $path
fi

cd .. ; rm -rf $tmpd
