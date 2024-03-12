set -eux

export PYTHONDONTWRITEBYTECODE=1
[[ zzz${PIPPROXY} != zzz ]] && USEPROXY="-i ${PIPPROXY}/root/pypi/+simple --trusted-host ${PIPHOST}"
PYTHONMAJOR=`echo ${PYTHONBASE} | cut -d- -f1`

pip_install()
{
  sudo pip install \
    -qq \
    --upgrade \
    --prefix="/usr/local" \
    --default-timeout=300 \
    --no-warn-script-location \
    --no-cache-dir \
    --no-compile \
    ${USEPROXY} $1
}
