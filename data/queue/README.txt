## IF YOU ARE USING AN SSD, OR AN HDD WITH THE FOLLOWING FILESYSTEMS:
## ext3, ext4, Btrfs, ZFS, XFS, NTFS 
## THEN PLEASE MOUNT /srv/www/server/data/queue AS A TMPFS FILESYSTEM IN RAM!
## It doesn't need to be big. 10 MiB works fine for most use cases. Even 1 MiB could work for small servers.
## This is because this directory stores usernames along with PASSWORDS IN PLAINTEXT
## Which is temporarily required for making SMB users with smbpasswd!
## Due to wear-leveling on SSDs, it's not 100% guaranteed that shred -u will securely erase this sensitive info!
## You can safely ignore this message if you're using an HDD.
## To do this, add:
# tmpfs /srv/www/server/data/queue tmpfs rw,nosuid,noexec,nodev,mode=0770,uid=0,gid=<GID of smbusrauthd-services>,size=10m 0 0
## to /etc/fstab.
## This assumes apache or whatever other web service you use can write to this tmpfs filesystem. THEY MUST BE IN THE smbusrauthd-services GROUP!
