#!/bin/bash
set -euo pipefail

## IMPORTANT NOTE!
## This script is intended to automatically be run by the superuser every minute using a cron job.
## It checks the queue every minute for a user trying to register for an account and provisions an SMB user for them.
## Add:
## * * * * * /srv/www/server/scripts/provision_smb_users.sh
## to the superuser's crontab.


## IMPORTANT NOTE #2!
## Since the queue files contain plaintext passwords (which is required temporarily to make an SMB user with smbpasswd -a),
## it's recommended to mount /srv/www/server/data/queue as a tmpfs filesystem in RAM.
## This is because RAM is volatile (and gets cleared on every reboot).
## If you have an HDD, there's no need to do this, since shred -u works fine for securely erasing queue files.
## That is, UNLESS you use some specific filesystems, but more info on that in /srv/www/server/data/queue/README.txt. (PLEASE CHECK IT!!!)
## On SSDs, because of wear leveling, shred -u can't guarantee a full secure erase,
## which is why it's recommended to store the queue in RAM memory.

## WHAT SIZE SHOULD I MAKE THE TMPFS FILESYSTEM?
## The tmpfs filesystem doesn't need to be big. Just 10 MiB is enough for most use cases.
## Even 1 MiB could be enough for really small servers.
## Check /srv/www/server/data/queue/README.txt for more info. THIS IS NOT OPTIONAL!!!!!!!!!!


## IMPORTANT NOTE #3!
## Replace any instance of /srv/www/server with the real path on your server!


# All commands are invoked using variables that point to their absolute path
# This is because $PATH is undefined when running the script with cron
USERADD="/usr/sbin/useradd"
CHPASSWD="/usr/sbin/chpasswd"
MKDIR="/usr/bin/mkdir"
CHOWN="/usr/bin/chown"
CHMOD="/usr/bin/chmod"
SEMANAGE="/usr/sbin/semanage"
RESTORECON="/usr/sbin/restorecon"
SMBPASSWD="/usr/bin/smbpasswd"
GREP="/usr/bin/grep"
STAT="/usr/bin/stat"
DD="/usr/bin/dd"
RM="/usr/bin/rm"

QUEUE_DIR="/srv/www/server/data/queue"

echo "Starting SMB provisioning at $(date)"

for file in "$QUEUE_DIR"/*.rgs; do
	[ -e "$file" ] || continue

	echo "Processing $file"
	{ read -r _; read -r line; } < $file
	username="${line%%:*}"
	password="${line#*:}"

	# Feel free to update this section according to your threat model
	$USERADD -M -s /sbin/nologin "$username"
	echo "$username:$password" | $CHPASSWD

	## NOTE:
	# This assumes that you use the [homes] Samba share with /srv/smb/server as the home directory.
	# Feel free to change this according to your config.
	$MKDIR -p "/srv/smb/server/$username"
	$CHOWN -R "$username" "/srv/smb/server/$username"
	$CHMOD -R 700 "/srv/smb/server/$username"

	# If you don't use SELinux on your Linux system, comment the following two lines:
	$SEMANAGE fcontext -a -t samba_share_t "/srv/smb/server/${username}(/.*)?"
	$RESTORECON -R "/srv/smb/server/$username"

	{
		echo "$password"
		echo "$password"
	} | $SMBPASSWD -a "$username" >/dev/null

	# Securely erase the queue file
	filesize=$($STAT --format "%s" $file)
	$DD if=/dev/random of="$file" bs=1 count="$filesize" conv=notrunc
	$DD if=/dev/random of="$file" bs=1 count="$filesize" conv=notrunc
	$DD if=/dev/random of="$file" bs=1 count="$filesize" conv=notrunc
	$DD if=/dev/zero of="$file" bs=1 count="$filesize" conv=notrunc
	$RM "$file"

	echo "Provisioned user $username"
done

echo "Finished at $(date)"
