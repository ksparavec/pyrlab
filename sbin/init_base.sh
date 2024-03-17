set -eux

apt_https()
{
  if [ "zzz$APTHTTPS" == "zzzyes" ]; then
    echo $1 | sed -e 's$^https:$http://HTTPS/$'
  else
    echo $1
  fi
}
