#!/bin/sh

set -eu

die(){ ev=$1; shift; for msg in "$@"; do echo "${msg}"; done; exit "${ev}"; }

thispath=`perl -MCwd=realpath -le'print(realpath(\$ARGV[0]))' -- "${0}"`
thisdir=${thispath%/*}

cd "${thisdir}"

current_dir=
if [ -f CURRENT_DIR ]; then
    . ./CURRENT_DIR
fi

LISTEN=unix:/tmp/nginx-`id -u`.socket

if [ \
        -z "${current_dir}" \
        -o "${current_dir}" != "${thisdir}" \
        -o ! -f cache-update-conf.m4 -o cache-update-conf.m4 -ot update-conf.sh \
        -o ! -f nginx.conf -o nginx.conf -ot nginx.conf.m4 \
    ]; then
    echo 'current_dir="'"${thisdir}"'"' > CURRENT_DIR
    cat <<EOF>cache-update-conf.m4
m4_define(\`USER',\`${USER}')m4_dnl
m4_define(\`HOME',\`${HOME}')m4_dnl
m4_define(\`PWD',\`${thisdir}')m4_dnl
m4_define(\`LISTEN',\`${LISTEN}')m4_dnl
EOF
    m4 -P cache-update-conf.m4 nginx.conf.m4 > nginx.conf.tmp
    mv -f nginx.conf.tmp nginx.conf
    chmod a-w nginx.conf
fi