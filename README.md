# smbusrauthd
# Samba User Authentication Daemon
# v0.1.1-prealpha
# By puluntu69

## WHAT'S NEW IN THIS RELEASE?
- tmpfs is actually fixed.
- Queue files in the tmpfs are actually securely erased

- A lightweight, secure, queue-based Samba user authentication daemon meant for clients to easily manage SMB accounts for themselves on your server with a user-friendly web frontend.

## WARNING:
- This is still pre-alpha software!
- While this is stable and secure enough for LAN environments, schools, internal infrastructure, etc, IT IS NOT STABLE AND SECURE ENOUGH FOR PRODUCTION OR TO BE EXPOSED ON THE INTERNET!

## Features (most likely broken on some setups):
- [x] User registration with a simple HTML frontend and a PHP registration form
- [x] Password strength enforcement
- [x] Secure registration queueing using shred -u and tmpfs
- [x] Cron-based auto-provisioning daemon for system SMB accounts via smbpasswd
- [x] SELinux-compatible and root-isolated for security
- [x] No databases or frameworks - just HTML, PHP, Bash and flat text files

## Planned features:
- [ ] User deletion via a web interface
- [ ] Change password via a web interface
- [ ] Change username via a web interface
- [ ] Logging and auditing
- [ ] HTTPS support

## Installation:
Since this is a more complex project, installation can be a little difficult.
1. Clone this repository
2. Make sure you have a web server installed
3. Place the contents inside a web server root (e.g. "/srv/www/server")
4. If you're deploying this in production, it's safe to delete README.md and LICENSE
5. Delete /srv/www/server/data/queue/README.txt after reading it
6. Make a group called smbusrauthd-services and add your service users (like apache or nginx) to it:
```bash
groupadd smbusrauthd-services
usermod -aG smbusrauthd-services apache # Change this to nginx or any other web service you use if you don't use Apache
```
7. Add the following in /etc/fstab:
```fstab
tmpfs /srv/www/server/data/queue tmpfs rw,nosuid,noexec,nodev,mode=0660,uid=0,gid=<GID of smbusrauthd-services>,size=10m 0 0
```
8. Mount /srv/www/server/data/queue as a tmpfs filesystem:
```bash
mount -t tmpfs -o rw,nosuid,noexec,nodev,mode=0660,uid=0,gid=<GID of smbusrauthd-services>,size=10m tmpfs /srv/www/server/data/queue
```
9. Make sure the entire web server root (and everything under it recursively) is owned by apache (or nginx) and has the following permissions:
```
drwxr-x--x
```
10. IMPORTANT EXCEPTION! Make sure /srv/www/server/data/queue is owned by the user root, the group smbusrauthd-services, AND has the following permissions:
```
drw-rw----
```
11. Make sure your web server has the proper SELinux context if you use SELinux:
```bash
semanage fcontext -a -t httpd_sys_rw_content_t "/srv/www/server(/.*)?"
restorecon -Rv /srv/www/server/
```
12. Create a cron job for the provision_smb_users.sh script. Add this in root's crontab:
```bash
* * * * * /srv/www/server/scripts/provision_smb_users.sh
```
13. Remove the comment in /srv/www/server/data/users.list after reading it
14. Edit index.html, register.php and provision_smb_users.sh according to your needs
15. Make sure your firewall allows communication via the port 80
16. Make sure the web server is running
17. Done! To connect, from a web browser, type in the address bar:
```
http://(your server's IP address):80/
```