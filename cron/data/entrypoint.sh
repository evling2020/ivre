#!/bin/sh
/usr/local/bin/docker exec -itd ivre_client_1 /bin/bash -c "ls -ltr /usr/local/share/ivre/geoip | grep -q csv || ivre ipdata --download"
