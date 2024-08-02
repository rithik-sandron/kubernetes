# Linux Networking 101
> https://www.redhat.com/sysadmin/sysadmin-essentials-networking-basics
    
# TOC
    1. Network namespace 
    2. Creating a network
    3. Creating a network for namespaces
    4. DNS / CoreDNS
        It's important to note that while DNS servers (like CoreDNS) handle name resolution and service discovery, CNI plugins are responsible for the actual network setup and IP address management for pods. These two components work together to enable effective networking and communication within a Kubernetes cluster.
   
    5. Networking in kubernetes
       1. 7 steps for networking
       2. Networking through CNI
       3. Add Weave CNI to kubernetes wihch takes care of networking
       4. for Pods networking - CNI
       5. for Service networking - kube-proxy
       6. kube-proxy
          1. modes
             1. userspace
             2. ipvs
             3. iptables
       7. ingress (NGINX)
          1. ssl
          2. load balancer

- Network [collection of two or more computers that can communicate]
- TCP [protocol to send packets to machines]
- IP [protocol to identify machines]

Each computer considers itself as the localhost node, with an internal-only IP address of `127.0.0.1`. The localhost designation is defined in the `/etc/hosts` file.
```bash
ping -c 1 localhost
```


# 1. Network namespace
> sutable for only two hosts.
network namespaces are small room inside a mahcine that has its own routing table, ARP table and routing information. this room cannot access networking information outside the namespace. hoat machine can see all the processes and network info tho.

To create a namespace
```bash
ip netns add <ns-name>
ip netns                            # to display the ns
ip netns exec <ns-name> ip link     # to display interfaces inside a namepace
```

To create a networking interface between namespaces,
```bash
ip link add <veth-ns1> type veth peer name <veth-ns2>
ip link set <veth-ns1> netns <ns-name>
ip link set <veth-ns2> netns <ns-name2>
```

To assign IP for the network interface,
```bash
ip -n <ns-name> addr add 169.254.0.1 dev <veth-ns1>
ip -n <ns-name2> addr add 169.254.0.2 dev <veth-ns2>
```

To bring up the connection
```bash
ip -n <ns-name> link set <veth-ns1> up
ip -n <ns-name2> link set <veth-ns2> up
```

Ping,
```bash
ip netns exec <ns-name> ping 69.254.0.2     # ns1 pings to 2
ip netns exec <ns-name2> ping 69.254.0.1    # ns2 pings to 1
```


# 2. Creating a network
> sutable for many hosts
### Creating and assigning IP to machines
To create a network, you need network interfaces. The Ethernet port is usually designated with the term eth plus a number starting with 0, but some devices get reported with different terms. 

To display network interfaces,
```bash
ip address show
ip link
```

To assign an IP address to a computer,
```bash
sudo ip address add 169.254.0.1 dev eth0    # on machine 1
sudo ip address add 169.254.0.2 dev eth0    # on machine 2
```

### Creating a route 
> we can create a route via another route to reate a IP
Below command adds a route to an address range starting from `169.254.0.0` and ending at `169.254.0.255` over the eth0 interface. It sets the routing protocol to static to indicate that the route was created by you, the administrator, as an intentional override for any dynamic routing.

To create a route
```bash
sudo ip route \
add 169.254.0.0/24 \
dev eth0 \
proto static
```

To verify your routing table,
```bash
route   # or `ip route`
```


# 3. Creating a network for namespaces
> sutable for many hosts within many namespaces

To create a network interface for the namespaces to utilize,
```bash
ip link add v-net-0 type bridge                             # to create
ip link set dev v-net-0 up                                  # to bring it up
ip link                                                     # to view
sudo ip addr add 192.168.15.5/24 dev v-net-0                # add IP to the interface. 
                                                                # We can use this ip to ping from host machine

# To set connection
ip link add <veth-ns1> type veth peer name <veth-ns-br>
ip link add <veth-ns2> type veth peer name <veth-ns-br>
ip link set <veth-ns1> netns <ns-name>
ip link set <veth-ns2> netns <ns-name2>
ip link set <veth-ns-br> master v-net-0

# To assign IP for the network interface,
ip -n <ns-name> addr add 169.254.0.1 dev <veth-ns1>
ip -n <ns-name2> addr add 169.254.0.2 dev <veth-ns2>

# To bring up the connection
ip -n <ns-name> link set <veth-ns1> up
ip -n <ns-name2> link set <veth-ns2> up

# Ping,
ip netns exec <ns-name> ping 69.254.0.2                     # ns1 pings to 2
ip netns exec <ns-name2> ping 69.254.0.1                    # ns2 pings to 1
```


# 4. DNS / CoreDNS
for a machine with an IP to identify another machine,
```bash
cat >> /etc/hosts
10.244.1.1  machine2        # add this in hosts file to identify the machine
```

For more machines editing all host files is complex.  so we maintain a DNS server and all the machine name and IP are added to the server and machines contact the DNS server to fetch the details of the other machines. To contact the DNS server,
```bash
cat >> etc/resolv.conf      # Add this to add machines in network
namesserver 10.96.1.1       # nameserver is the IP of the DNS server
```

Kubernetes creates similar DNS server to store the services and pods IP addess in the cluster using CoreDNS
```bash
host <service-name>     # to fetch full service url with its IP
```

# 5. Networking in kubernetes
Kubernetes creates a DNS server using CoreDNS, but it does not create any netowkr namespaces for the services or pods. It ask the CNI plugin to take that responsibility.

CNI plugin takes care of setting up the network we discussed earlier.
Available CNI plugins: (Accoding to perplex ai)
  - Calico: Known for its performance, flexibility, and advanced network policy features.
  - Flannel: One of the most mature and easy-to-use CNI plugins, often recommended for beginners.
  - Weave Net: Offers a simple setup and good performance.
  - Cilium: Provides advanced networking and security features using eBPF.
  - Canal: A combination of Flannel and Calico, offering simplicity and advanced network policy features.
  