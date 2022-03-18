#!/bin/bash
cd $HOME && [ -f local.tar.xz ] && tar Jxpf local.tar.xz
cd /usr/local/lib/R && [ -f site-library.tar.xz ] && tar Jxpf site-library.tar.xz
exit 0
