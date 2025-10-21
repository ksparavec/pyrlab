set -eux

export PYTHONDONTWRITEBYTECODE=1
PIPHOST=`echo ${PIPPROXY} | perl -MRegexp::Common -nE 'say $1 if /($RE{net}{IPv4})/'`
USEPROXY=""
[[ zzz${PIPPROXY} != zzz ]] && USEPROXY="--index-url ${PIPPROXY}/root/pypi/+simple --trusted-host ${PIPHOST}"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

pip_install()
{
  # If package string contains --index-url, don't use proxy index (custom index takes precedence)
  local proxy_args="${USEPROXY}"
  if [[ "$1" == *"--index-url"* ]]; then
    proxy_args=""
  fi

  uv pip install \
    --upgrade \
    --prefix="/usr/local" \
    --default-timeout=300 \
    --no-warn-script-location \
    --no-cache-dir \
    --compile-bytecode \
    --system \
    ${proxy_args} $1
}
