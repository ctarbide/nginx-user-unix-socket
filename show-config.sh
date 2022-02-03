#!/bin/sh
nginx -V 2>&1 | perl -l -040 -ne'next unless m{-|=}; print'
