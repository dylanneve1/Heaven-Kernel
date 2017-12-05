#!/system/bin/sh

# Optimize Databases script
# Original by dorimanx for ExTweaks
# Modified by UpInTheAir for SkyHigh kernels & Synapse

# Busybox 
if [ -e /su/xbin/busybox ]; then
	BB=/su/xbin/busybox;
else if [ -e /sbin/busybox ]; then
	BB=/sbin/busybox;
else
	BB=/system/xbin/busybox;
fi;
fi;

SQLITE=$(cat /res/synapse/Super/cron/sqlite);

if [ "$($BB mount | grep rootfs | cut -c 26-27 | grep -c ro)" -eq "1" ]; then
	$BB mount -o remount,rw /;
fi;

if [ "$SQLITE" == 1 ]; then

	# wait till CPU is idle.
	while [ ! "$($BB cat /proc/loadavg | cut -c1-4)" -lt "3.50" ]; do
		echo "Waiting For CPU to cool down";
		sleep 30;
	done;

	for i in $(find /data -iname "*.db"); do
		/system/xbin/sqlite3 "$i" 'VACUUM;' 2> /dev/null;
		/system/xbin/sqlite3 "$i" 'REINDEX;' 2> /dev/null;
	done;

	for i in $(find /data/media/0 -iname "*.db"); do
		/system/xbin/sqlite3 "$i" 'VACUUM;' 2> /dev/null;
		/system/xbin/sqlite3 "$i" 'REINDEX;' 2> /dev/null;
	done;
	$BB sync;

	date +%R-%F > /data/crontab/cron-db-optimizing;
	echo " DB Optimized" >> /data/crontab/cron-db-optimizing;

elif [ "$SQLITE" == 0 ]; then

	date +%R-%F > /data/crontab/cron-db-optimizing;
	echo " DB Optimization is disabled" >> /data/crontab/cron-db-optimizing;
fi;
