#!/usr/bin/env bash
set -eux

cd && rm -rf .ssh .ipython .gitconfig
find /volumes/docker -mindepth 1 -maxdepth 1 -exec ln -s {} . \;

[[ -x ${RCS} ]] && ./${RCS} || true

[[ -d /usr/local/cuda/bin ]] && export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
[[ -d /usr/local/cuda/bin ]] && export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

cd /volumes/notebooks && SHELL=/bin/bash exec jupyter lab --port=${PORT} --no-browser --ip=0.0.0.0 --LabApp.token=''

