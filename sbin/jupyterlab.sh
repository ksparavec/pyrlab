#!/usr/bin/env bash
set -eux

groupadd -g ${GID} ${USER}
useradd -u ${UID} -g ${GID} -p '' -M -d ${HOMEDIR} -s /bin/bash ${USER}
usermod -a -G sudo ${USER}
[[ -d /usr/local/lib/R ]] && chown -R ${USER}:${USER} /usr/local/lib/R

sudo -iu ${USER} <<EOF

[[ zzz${ENVVARS} != zzz && -r ${ENVVARS} ]] && set -a && . ${ENVVARS} && set +a || true

[[ zzz${RCS} != zzz && -x ${RCS} ]] && ./${RCS} || true

export PATH=${HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
[[ -d /usr/local/cuda/bin ]] && export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
[[ -d /usr/local/cuda/bin ]] && export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

cd /volumes/notebooks && SHELL=/bin/bash exec jupyter lab --port=${PORT} --no-browser --ip=0.0.0.0 --LabApp.token=''
EOF
