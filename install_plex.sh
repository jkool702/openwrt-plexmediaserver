#!/bin/sh

#  using `service plexmediaserver enable doesnt quite work to start up plexmediaserver on boot, 
# since it tends to get started before the drive with the plex  library on it gets mounted.
# instead, use /etc/rc.local to automatically run `service plexmediaserver start` on bootup 
# (after mounting the plex external drive)

install_plex() {
## sets up and installs a plexmediaserver instance that runs on your WRX36. (note: this setup function requires `curl`
#
# USAGE:     install_plex <plex_dev> <plex_mnt>
#
# EXAMPLE:   install_plex /dev/sda2 /mnt/plex

# make sure theres 2 inputs
[ $# = 2 ] || { printf '\n\nERROR! MUST HAVE 2 INPUTS. \nUSAGE: install_plex <plex_dev> <plex_mnt>\n\n' >&2 && return 1; }

plex_dev="${1%/}"
plex_mnt="${2%/}"

# download main init.d script
curl 'https://raw.githubusercontent.com/jkool702/openwrt-plexmediaserver/test/etc/init.d/plexmediaserver' > /etc/init.d/plexmediaserver
[ -f /etc/init.d/plexmediaserver ] || { echo "ERROR downloading plexmediaserver init.d scrip. ABORTING." >&2; return 1; }
chmod +x /etc/init.d/plexmediaserver

# use /etc/rc.local to set up automatically starting plex on boot
tr -d '\n' </etc/rc.local | grep -qF 'mkdir -p "${plex_mnt}"grep -qF "${plex_dev} ${plex_mnt}" </proc/mounts || { mount "${plex_dev}" "${plex_mnt}" 2>&1 | grep -qF "unknown filesystem type '"'"'ntfs'"'"'"; } && { grep -qF '"'"'ntfs3'"'"' </proc/filesystems; } && ntfs-3g "${plex_dev}" "${plex_mnt}"sleep 2/etc/init.d/plexmediaserver startsleep 2ps | grep -q '"'"'Plex Media Server'"'"' || /etc/init.d/plexmediaserver start' || {
cat<<EOF>>/etc/rc.local

mkdir -p "${plex_mnt}"
grep -qF "${plex_dev} ${plex_mnt}" </proc/mounts || { mount "${plex_dev}" "${plex_mnt}" 2>&1 | grep -qF "unknown filesystem type 'ntfs'"; } && { grep -qF 'ntfs3' </proc/filesystems; } && ntfs-3g "${plex_dev}" "${plex_mnt}"
sleep 2
/etc/init.d/plexmediaserver start
sleep 2
ps | grep -q 'Plex Media Server' || /etc/init.d/plexmediaserver start

EOF
}

# mount plex drive
mkdir -p "$2"
grep -qF "${plex_dev} ${plex_mnt}" </proc/mounts || { mount "${plex_dev}" "${plex_mnt}" 2>&1 | grep -qF "unknown filesystem type 'ntfs'"; } && { grep -qF 'ntfs3' </proc/filesystems; } && ntfs-3g "${plex_dev}" "${plex_mnt}"

# make plex Library root dir
mkdir -p "${2}/.plex/Library"

# setup UCI and build plex squashfs image 
service plexmediaserver start
sleep 5

# start plex
service plexmediaserver start

# print usage info
{
printf '\n\nplexmediaserver has been installed and setup to automatically start up when the router boots\n'
printf '\nTo manually start/stop plexmediaserver, use:      \t service plexmediaserver [start|stop]\n'
printf '\nTo update to a new plexmediaserver version, use: \t service plexmediaserver update \n'
printf '\nTo access Plex from a web browser, go to:       \t %s\n\n' "$(ip addr show br-lan | grep 'inet '| sed -E s/'^.*inet (.*)\/.*$'/'\1'/):32400/web" >&2
} >&2

}

[ $# = 2 ] && install_plex "$1" "$2"
