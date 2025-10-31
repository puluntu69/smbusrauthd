## IF YOU ARE USING AN SSD, PLEASE MOUNT /srv/www/server/data/queue AS A TMPFS FILESYSTEM IN RAM!
## It doesn't need to be big. 10 MiB works fine for most use cases. Even 1 MiB could work for small servers.
## This is because this directory stores usernames along with PASSWORDS IN PLAINTEXT
## Which is temporarily required for making SMB users with smbpasswd!
## Due to wear-leveling on SSDs, it's not 100% guaranteed that shred -u will securely erase this sensitive info!
## You can safely ignore this message if you're using an HDD.
## To do this, add:
# tmpfs /srv/www/server/data/queue tmpfs rw,nosuid,noexec,nouser,nodev,size=10m 0 0
## to /etc/fstab.
## Also, make sure the owner of this directory is the user and group apache (or nginx, depending on your setup),
## And that the owner has read, write and execute permissions on this entire directory.