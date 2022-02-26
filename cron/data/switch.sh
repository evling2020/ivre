#!/bin/sh

is_done=/ivre-share/.done

if [ -f $is_done ];then
	rm -rf $is_done
	/usr/local/bin/docker exec -itd ivre_db_1 /bin/bash -c "if [ -f /tmp/mongodump-db ] ; then rm -rf /tmp/mongodump-db ; fi ; mongodump --archive='/tmp/mongodump-db' --db=ivre2 ; mongo ivre --eval 'db.dropDatabase()' ; mongorestore --archive='/tmp/mongodump-db' --nsFrom='ivre2.*' --nsTo='ivre.*' ; if [ -f /tmp/mongodump-db ] ; then rm -rf /tmp/mongodump-db ; fi ; mongo ivre2 --eval 'db.dropDatabase()'"
fi
