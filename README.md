# YaST2 Network DBus Interface

This repository contains a simple DBus interface to `yast2-network`. It is meant
to be a temporary project to help in the development of a Cockpit plug-in for
Wicked.

## Running the Service

For the time being, it uses the session bus. Just run the following command to start
the server:

```sh
rake start
```

There are plans to make it run as root (as YaST2 does) and connected to the
system bus so it actually can apply changes to the configuration.
