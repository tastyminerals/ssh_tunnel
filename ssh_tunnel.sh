#!/bin/bash
# Copy ~/.ssh from your remote machine1 to your $HOME dir 

# config
username="pavels"
# sudo mkdir /mnt/tunnel && sudo chown $USER /mnt/tunnel
# sudo chown yourusername /mnt/tunnel
mountpath="/mnt/tunnel/"  # set your path, do not create dirs in $HOME!
#mountpath="/home/$USER/tunnel/"  # works on chromebooks
tail="@login.coli.uni-saarland.de:/home/CE/$username"

# set some constants
ssh_machine1=$username$tail
KILLFS=0
KILLALL=0
HOP=0

# in case of locked mount dirs
fusermount -u $mountpath -q

# unmount all mounted dirs
umountall() {
    mount -l -t fuse.sshfs | awk -F " " '{print "fusermount -u " $3}' | bash
    pkill ssh
    exit 0
}

# unmount given mountpoint
umountfs() {
    fusermount -u $mountpoint
    exit 0
}

usage() {
    tput sgr0
    echo -e "
\"ssh_tunnel\" allows you to mount remote file systems locally given mountpoint path.

 Usage: ssh_tunnel [OPTION] HOSTNAME
        ssh_tunnel HOSTNAME

 OPTIONS: 
   -h, show this help
   -e, mount remote machine2 which is behind another ssh machine, ssh machine1 --> ssh machine2 
   -u, unmount remote file system dirs
   -f | --off, unmount all mounted dirs and close all ssh processes!

 Examples:
    ssh_tunnel username -- mount remote username machine using random port on given mountpoint
    ssh_tunnel froggy -- also possible, mountpoint name will be /home/user/tunnel/froggy
    ssh_tunnel -u /home/user/tunnel/username -- unmount /home/user/tunnel/username dir
    ssh_tunnel -f -- unmount all mounted dirs
    ssh_tunnel -e falken-1 -- mount falken-1 fs on /home/user/tunnel/falken-1
"
}

# main
while getopts :ekuhof opt; do
    case $opt in
    e)
        if [ -n "$2" ]; then
            HOP=1
            ssh_machine2=$2
        else
            printf 'ERROR: "-e" requires machine hostname.\n' >&2
            exit 1
        fi
        if [ -n "$3" ]; then
            port=$3
        else
            port=$((RANDOM%65000+2000))
        fi
        ;;
    u)
        if [ -n "$2" ]; then
            KILLFS=1
            mountpoint=$2
        else
            printf 'ERROR: "-u" requires mountpoint path.\n' >&2
            exit 1
        fi
        ;;
    f | --off )
        KILLALL=1
        ;;
    h|-\?|--help)
        usage
        exit 0
        ;;
    esac
done
shift $((OPTIND-1))

if [ $KILLFS = 1 ]; then
    umountfs
    exit 0
fi

if [ $KILLALL = 1 ]; then
    umountall
    exit 0
fi

# user didn't use any option params
if [ $OPTIND = 1 ] && [ -n "$1" ]; then
    mountpoint=$mountpath$1
    if [ ! -d "$mountpoint" ]; then
        mkdir -p $mountpoint  # create mountpoint dirs
    fi
    sshfs $ssh_machine1 $mountpoint -C -o follow_symlinks #-p $port
    [ "$(ls -A $mountpoint)" ] && echo "--> mounted on $mountpoint" || echo "--X mount failed" 
    exit 0
fi

if [ $HOP = 1 ]; then
    mountpoint=$mountpath$ssh_machine2
    if [ ! -d "$mountpoint" ]; then
        mkdir -p $mountpoint  # create mountpoint dirs
    fi
    # -C use compression if your connection is slow, remove otherwise
    ssh -f ${ssh_machine1%:*} -L $port:$ssh_machine2:22 -N -C
    sshfs -p $port $username@localhost:/local/$username $mountpoint -C -o reconnect,ServerAliveInterval=15,ServerAliveCountMax=3
    [ "$(ls -A $mountpoint)" ] && echo "--> mounted on $mountpoint" || echo "--X mount failed" 
fi
