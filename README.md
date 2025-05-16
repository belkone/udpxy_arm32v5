# udpxy for Mikrotik arm32v5 devices (EN7562CT CPU)

Docker container for running [udpxy](https://github.com/pcherenkov/udpxy) - a UDP-to-HTTP multicast traffic relay daemon. This container is specifically built for Mikrotik devices with EN7562CT CPU like the hEX Refresh, running on arm32v5 architecture.

## Overview

This project provides a lightweight Docker container that allows Mikrotik routers to relay multicast UDP streams (like IPTV) to HTTP clients on your network.

## Included Packages

The container includes the following utility packages to facilitate configuration and troubleshooting:

- `net-tools` - Basic network tools including ifconfig, netstat, etc.
- `iproute2` - Advanced IP routing utilities
- `iputils-ping` - Ping, tracepath and other network utilities
- `procps` - Process utilities like ps, top, etc.
- `curl` - Command line tool for transferring data with URL syntax
- `dnsutils` - DNS utilities including dig, nslookup, etc.

## Base Project

This container is based on the original udpxy project:
- [https://github.com/pcherenkov/udpxy](https://github.com/pcherenkov/udpxy)

## Documentation

For detailed documentation on udpxy and its configuration options, please refer to:
- [udpxy man page](https://man.archlinux.org/man/udpxy.1.en)

## Running on Mikrotik

### Prerequisites

- Mikrotik router with EN7562CT CPU (like hEX Refresh)
- RouterOS version that supports containers
- Container package must be enabled

### Step 1: Enable Containers on Mikrotik

Follow the official Mikrotik documentation to enable and configure containers:
[https://help.mikrotik.com/docs/spaces/ROS/pages/84901929/Container](https://help.mikrotik.com/docs/spaces/ROS/pages/84901929/Container)

### Step 2: Add the Container

Run the following command in your Mikrotik terminal:

```
/container add remote-image belkone/udpxy_arm32v5:latest interface=veth1 start-on-boot=yes logging=yes root-dir=usb1/containers/udpxy
```

**Note:** You may need to adjust the parameters according to your setup, particularly:
- The `interface` name
- The `root-dir` location depending on your storage configuration

### Step 3: Customizing udpxy Settings

You can modify the startup command for udpxy by editing the container settings in Mikrotik:

```
/container config set [find] cmd="udpxy -T -a eth0 -p 4022 -m eth0 -c 10 -B 2097152 -R 8"
```

Common parameters to customize:
- `-p PORT`: Change the listening port (default: 4022)
- `-c N`: Maximum number of clients allowed (default: 3)
- `-B SIZE`: Set buffer size in bytes (default: system-dependent)
- `-l FILE`: Enable logging to a file
- `-M SEC`: Source timeout in seconds

For a complete list of options, refer to the [udpxy documentation](https://man.archlinux.org/man/udpxy.1.en).

### Step 3: Network Configuration

1. Add the container's interface (e.g., `veth1`) to the bridge that includes:
   - The Ethernet port receiving multicast traffic
   - Any tunneling interface (if you need to forward unicast remotely)

2. Enable IGMP snooping on the bridge:
   ```
   /interface bridge set [find name=bridge1] igmp-snooping=yes
   ```

3. Optimizing for unicast traffic over L2 tunnels:
   
   If you're forwarding unicast traffic remotely via L2 tunnels (like EoIP, VxLAN and others) because your STB (Set-Top Box) requires it, it's recommended to block multicast packets from being forwarded through the tunnel. This prevents duplicate traffic (both multicast and unicast) and saves bandwidth.
   
   Add the following bridge filter rule:
   ```
   /interface bridge filter add action=drop chain=forward out-interface=<BRIDGE_NAME> packet-type=multicast
   ```
   
   Replace `<BRIDGE_NAME>` with the name of your bridge interface. This rule will prevent multicast packets from being forwarded through the bridge, allowing only the unicast HTTP traffic from udpxy.

## Accessing udpxy

Once running, you can access UDP streams via HTTP using:
```
http://[router-ip]:4022/udp/[multicast-ip]:[port]
```

Example:
```
http://192.168.1.1:4022/udp/239.0.0.1:1234
```

## Security Warning

⚠️ **IMPORTANT**: When adding the Docker container's network interface to a bridge that has connectivity to other networks or the internet, the udpxy service may become publicly accessible. This could potentially expose your IPTV streams to unauthorized users.

Consider implementing one or more of these security measures:
- Configure firewall rules on your Mikrotik to restrict access to the udpxy port (4022 by default)
- Use a dedicated bridge for the container that only includes necessary interfaces
- Change the default port to something non-standard
- If possible, implement authentication mechanisms in front of the service

Remember that multicast-to-HTTP conversion removes any encryption or access controls that might have been present in the original stream.

## License

This project is distributed under the same license as the original udpxy project.
