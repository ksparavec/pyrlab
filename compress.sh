#!/bin/bash
cd $HOME
tar -I "xz -T0 -9e" -cpf local.tar.xz .local
rm -rf .local
cd /usr/local/lib/R
tar -I "xz -T0 -e" -cpf site-library.tar.xz site-library
rm -rf site-library
exit 0
