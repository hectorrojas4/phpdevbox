#!/bin/bash
mutagen create \
       --sync-mode=two-way-resolved \
       --default-owner-beta=phpdevbox \
       --default-group-beta=phpdevbox \
       --default-file-mode=0644 \
       --default-directory-mode=0755 \
       --ignore=/.idea \
       --ignore=/.github \
       --ignore-vcs \
       --symlink-mode=posix-raw \
       ./webroot docker://$(docker ps | grep web | awk "{print \$1}")/var/www/phpdevbox

