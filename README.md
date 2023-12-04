# openwrt-plexmediaserver
Sets up an on-router plex media server instance

**REQUIREMENTS**: an ARMv7 or ARMv8 device with a beefy CPU (quad-core is probably preferable) and at least 120 MB of free RAM that can be dedicated to plex media server. 

**COMPATABLE DEVICES**: This **should** work on any sufficiently powerful armv7 or armv8 device, but has only been tested on a Netgear R9000 (ARMv7) and a dynalink dl-wrx36 (ARMv8).

**INSTALL INSTRUCTIONS**

An install script (install_plex.sh) is in the top level repo directory. This will setup and install plex media server (via an init.d service) and will add something to something to `/etc/rc.local` to start plex on boot can be found [HERE](https://github.com/jkool702/openwrt-plexmediaserver/blob/main/WRX36/install_plex.sh) 

Note: install script required `curl`

The easiest way to set everything up is probably to run the following on your Router:

    curl 'https://raw.githubusercontent.com/jkool702/openwrt-plexmediaserver/main/WRX36/install_plex.sh' >/tmp/install_plex.sh
    chmod +x /tmp/install_plex.sh

    /tmp/install_plex.sh <PLEX_DEV> <PLEX_MNT>

Replace `<PLEX_DEV>` and `<PLEX_MNT>` with the block device and mountpoint you will be using. e.g. it should look something like

    /tmp/install_plex.sh /dev/sda2 /mnt/plex

After install, you can access plex from a plex media player app or from a web browser by going to `${ROUTER_IP}:32400/web` (e.g., `192.168.1.1:32400/web`)

***

**HOW IT WORKS**

When you run `service plexmediaserver update`, it:

1. downloads an [ARMv7|ARMv8] NAS plexmediaserver package (specifically the ASUSTOR one)
2. unpacks it (in the `.plex/library/Application` directory on the external hard drive)
3. creates an xz-compressed squashfs image of the unpacked plexmediaserver package

this squashfs image will be stored on the external drive at `.plex/Library/Application/plexmediaserver.sqfs`

When you run `service plexmediaserver start`, it:

1. copies the `plexmediaserver.sqfs` image to `/tmp/plexmediaserver/plexmediaserver.sqfs`
2. mounts the squashfs image to `/tmp/plexmediaserver` (which hides it from the rest of the system under the squashfs mount)
3. sets up required environment variables and forks a process that runs the plexmediaserver binary in the background

***

**MEMORY USAGE**

using an in-memory squashfs-image keeps the server responsive (since its binaries/libraries are all on a ramdisk, not the external drive) without taking up too much memory (since it is all xz-compressed). Memory usage is around 100-120mb or so, which uses up, 10-12% of the WRX36's 1gb of RAM.

***

**PERFORMANCE**

It all works quite well, provided you turn off video transcoding in the plex settings. On my WRX36 I was streaming a HDR HEVC-encoded 4k movie to a plex app on a 4k apple TV with audio being transcoded (but not video) and had 0 dropped frames. If you need to transcode video the experience will be quite choppy on anything 720p or higher resolution....the a53 just doesnt have the processing power for realtime video transcoding.

note: turning off the "automatically adjust quality" option in plex seemed to improve quality and performance by a good amount.
