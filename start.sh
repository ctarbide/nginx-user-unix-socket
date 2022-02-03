#!/bin/sh

set -eux

die(){ ev=$1; shift; for msg in "$@"; do echo "${msg}"; done; exit "${ev}"; }

thispath=`perl -MCwd=realpath -le'print(realpath(\$ARGV[0]))' -- "${0}"`
thisdir=${thispath%/*}

cd "${thisdir}"

[ -d var/logs ] || mkdir -p var/logs

./update-conf.sh

nginx -p "${thisdir}/var/" -t -c "${thisdir}/nginx.conf" || die 111 "configuration error"

exec nginx -p "${thisdir}/var/" -c "${thisdir}/nginx.conf"

exit 111
