# adds a virtual netwprking inside host / node
# these steps should be run on all nodes
#     - control-plane
#     - worker
ip link add v-net-0 type bridge
ip link set dev v-net-0 up
ip addr add 10.244.1.1/24 dev v-net-0
ip addr add 10.244.2.1/24 dev v-net-0