#!/bin/sh
set -eu
die(){ ev=$1; shift; for msg in "$@"; do echo "${msg}"; done; exit "${ev}"; }
thispath=`perl -MCwd=realpath -le'print(realpath(\$ARGV[0]))' -- "${0}"`
thisdir=${thispath%/*}
cd "${thisdir}"
./update-conf.sh
exec nginx -t -p "${thisdir}/var/" -c "${thisdir}/nginx.conf"
