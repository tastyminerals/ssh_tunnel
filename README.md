# ssh_tunnel
Simple script that allows you to mount remote directories over ssh, even those that are behind another ssh.

### Setup
Open the script file. In "config" section set your `username`, `mountpath` and `tail` parameters.

### Usage
```
 ssh_tunnel [OPTION] HOSTNAME
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
```
