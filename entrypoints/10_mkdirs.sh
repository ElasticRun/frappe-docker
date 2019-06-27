#!/bin/sh
export SITE=${SITE_NAME:-site1.docker}
mkdir -p ${BENCH_HOME}/sites_orig/assets
# Copy original sites data into sites_orig
export BASE=${BENCH_HOME}/sites
export NEW_BASE=${BENCH_HOME}/sites_orig
# Backup of contents of sites
for d in `ls ${BASE}`
do
    if [ "$d" != "assets" -a -L ${BASE}/$d ]
    then
        mv ${BASE}/$d ${NEW_BASE}/$d
    fi
done
# Backup of assets
for d in `ls ${BASE}/assets`
do
    # Ignore symlinks from earlier
    if [ ! -L ${BASE}/assets/$d ]
    then
        mv -f ${BASE}/assets/$d ${NEW_BASE}/assets/$d
    fi
done
# Remove original data from sites
rm -rf ${BENCH_HOME}/sites/*

# Install new data from sites-backup.
export BACKUP_BASE=/home/frappe/sites-backup
export NEW_BASE=${BENCH_HOME}/sites
mkdir -p ${NEW_BASE}/assets
for d in `ls ${BACKUP_BASE}`
do
    if [ "$d" != "assets" -a -L ${BACKUP_BASE}/$d ]
    then
        mv ${BACKUP_BASE}/$d ${NEW_BASE}/$d
    fi
done
# handle assets separately
for d in `ls ${BACKUP_BASE}/assets`
do
    if [ -L ${BACKUP_BASE}/assets/$d ]
    then
        # Handle sym link
        echo "${BACKUP_BASE}/assets/$d is symlink"
        target=`readlink -f ${BACKUP_BASE}/assets/$d`
        ln -s $target ${NEW_BASE}/assets/$d
    else
        mv -f ${BACKUP_BASE}/assets/$d ${NEW_BASE}/assets/$d
    fi
done

sudo rm -rf ${BACKUP_BASE}

sudo chown -R frappe:frappe ${BENCH_HOME}/sites ${BENCH_HOME}/logs
if [ ! -f ${BENCH_HOME}/sites/apps.txt ]
then
    echo -n 'frappe' > ${BENCH_HOME}/sites/apps.txt
fi
