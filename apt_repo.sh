#!/usr/bin/env bash
PACKAGES=$1
REPOSITORY=$2

set -eux
apt-get update
cd $REPOSITORY
for package in `cat $PACKAGES`;
do
    apt-cache depends --recurse --no-recommends --no-suggests --no-conflicts --no-breaks --no-replaces --no-enhances $package | grep "^\w" | sort -u
done | sort -u >packages.txt
apt-get download `cat packages.txt`
dpkg-scanpackages . | gzip -c > Packages.gz
rm -f *.txt
