set -eux

export PYTHONDONTWRITEBYTECODE=1
PIPHOST=`echo ${PIPPROXY} | perl -MRegexp::Common -nE 'say $1 if /($RE{net}{IPv4})/'`
USEPROXY=""
[[ zzz${PIPPROXY} != zzz ]] && USEPROXY="-i ${PIPPROXY}/root/pypi/+simple --trusted-host ${PIPHOST}"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

pip_install()
{
  pip install \
    --upgrade \
    --prefix="/usr/local" \
    --default-timeout=300 \
    --no-warn-script-location \
    --root-user-action=ignore \
    --no-cache-dir \
    --no-compile \
    ${USEPROXY} $1
}
