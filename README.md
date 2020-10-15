# YaST2 Network DBus Interface

This repository contains a simple DBus interface to `yast2-network`. It is meant
to be a temporary project to help in the development of a Cockpit plug-in for
Wicked.

## Running the Service

In order to allow reading/writing the network configuration, you need to run this server as root. It will use the system bus so you need to copy `data/org.opensuse.YaST2.Network.conf` to `/etc/dbus-1/system.d` directory and reload the `dbus` service.

After that, you can run the server by just typing:

```sh
# rake start
```
