# smbusrauthd
# Samba User Authentication Daemon
# v0.1.0-prealpha
# By puluntu69

- A lightweight, secure, queue-based Samba user authentication daemon meant for clients to easily manage SMB accounts for themselves on your server with a user-friendly web frontend.

## WARNING:
- This is still prealpha software!
- While this is stable and secure enough for LAN environments, schools, internal infrastructure, etc, IT IS NOT STABLE AND SECURE ENOUGH FOR PRODUCTION OR TO BE EXPOSED ON THE INTERNET!

## Features:
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
6. If you use an SSD, add the following in /etc/fstab:
```
tmpfs /srv/www/server/data/queue tmpfs rw,nosuid,noexec,nouser,nodev,size=10m 0 0
```
7. If you use an SSD, mount /srv/www/server/data/queue as a tmpfs filesystem:
```bash
mount -t tmpfs -o rw,nosuid,noexec,nouser,nodev,size=10m tmpfs /srv/www/server/data/queue
```
8. Make sure the entire web server root (and everything under it recursively) is owned by apache (or nginx) and has the following permissions:
```
drwxr-x--x
```
9. Make sure your web server has the proper SELinux context if you use SELinux:
```bash
semanage fcontext -a -t httpd_sys_rw_content_t "/srv/www/server(/.*)?"
restorecon -Rv /srv/www/server
```
10. Create a cron job for the provision_smb_users.sh script. Add this in root's crontab:
```bash
* * * * * /srv/www/server/scripts/provision_smb_users.sh
```
11. Remove the comment in /srv/www/server/data/users.list after reading it
12. Edit index.html, register.php and provision_smb_users.sh according to your needs
13. Make sure your firewall allows communication via the port 80
14. Make sure the web server is running
15. Done! To connect, from a web browser, type in the address bar:
```
http://(your server's IP address):80/
```
