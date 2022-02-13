#!/bin/sh

set -eu #x

die(){ ev=$1; shift; for msg in "$@"; do echo "${msg}"; done; exit "${ev}"; }

thispath=`perl -MCwd=realpath -le'print(realpath(\$ARGV[0]))' -- "${0}"`
thisdir=${thispath%/*}

cd "${thisdir}"

[ -d var/logs ] || mkdir -p var/logs

./update-conf.sh

. ./vars.inc.sh

nginx -p "${thisdir}/var/" -t -c "${thisdir}/nginx.conf" || die 111 "configuration error"

# if nginx does not exit gracefully, it does not remove the socket file, nginx
# also does not remove it before starting, thus we must remove it ourselves
# before starting nginx, otherwise 'Address in use' error will ensue

rm -f "${SOCKET_FILE}"

sh -eu -c '
socket=$1; shift;
seq 30 | while read i; do
    test ! -r "${socket}" || break;
    sleep 1;
done;
test -r "${socket}";
chgrp nginx "${socket}";
chmod o-rwx "${socket}";
' -- "${SOCKET_FILE}" &

exec nginx -p "${thisdir}/var/" -c "${thisdir}/nginx.conf"

exit 111
