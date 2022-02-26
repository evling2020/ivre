#!/bin/bash
set -eu 

touch /var/log/ivre.log && tail -f /var/log/ivre.log

exec "$@"
