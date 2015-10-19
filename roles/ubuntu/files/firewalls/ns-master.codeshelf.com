#!/bin/bash

IPTABLES="/sbin/iptables"
IPT6="/sbin/ip6tables"

# IPv4 firewall rules:

# Clear current rules
$IPTABLES -F

# Set default rules
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P FORWARD DROP
$IPTABLES -P OUTPUT ACCEPT

# Let in any loopback traffic
$IPTABLES -A INPUT -i lo -j ACCEPT 

# Let in established traffic
$IPTABLES -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Let in any icmp traffic
$IPTABLES -A INPUT -p icmp -j ACCEPT 

# SSH
$IPTABLES -A INPUT -s 104.130.125.194 -p tcp --dport 22 -j ACCEPT # master.codeshelf.com
$IPTABLES -A INPUT -s 70.36.226.20 -p tcp --dport 22 -j ACCEPT # oak.codeshelf.com
$IPTABLES -A INPUT -s 104.236.151.15 -p tcp --dport 22 -j ACCEPT # sanfrancisco.tinkergeek.com

# DNS
$IPTABLES -A INPUT -s 173.244.206.26 -p tcp --dport 53 -j ACCEPT # BuddyNS
$IPTABLES -A INPUT -s 173.244.206.26 -p udp --dport 53 -j ACCEPT
$IPTABLES -A INPUT -s 88.198.106.11 -p tcp --dport 53 -j ACCEPT # BuddyNS
$IPTABLES -A INPUT -s 88.198.106.11 -p udp --dport 53 -j ACCEPT
$IPTABLES -A INPUT -s 107.181.178.180 -p tcp --dport 53 -j ACCEPT # BuddyNS
$IPTABLES -A INPUT -s 107.181.178.180 -p udp --dport 53 -j ACCEPT
$IPTABLES -A INPUT -s 173.244.206.25 -p tcp --dport 53 -j ACCEPT # BuddyNS
$IPTABLES -A INPUT -s 173.244.206.25 -p udp --dport 53 -j ACCEPT
$IPTABLES -A INPUT -s 107.191.99.111 -p tcp --dport 53 -j ACCEPT # BuddyNS
$IPTABLES -A INPUT -s 107.191.99.111 -p udp --dport 53 -j ACCEPT
$IPTABLES -A INPUT -s 198.61.170.212 -p tcp --dport 53 -j ACCEPT # ns.codeshelf.com
$IPTABLES -A INPUT -s 198.61.170.212 -p udp --dport 53 -j ACCEPT

# Default Reject
$IPTABLES -A INPUT -j REJECT --reject-with icmp-host-prohibited

# Start IPv6 rules:

# Clear current rules
$IPT6 -F
 
# DROP all traffic
$IPT6 -P INPUT ACCEPT
$IPT6 -P OUTPUT ACCEPT
$IPT6 -P FORWARD DROP
 
# Let in any lookback traffic
$IPT6 -A INPUT -i lo -j ACCEPT

# Allow full outgoing connection but no incomming stuff
$IPT6 -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
 
# Allow icmp traffic
$IPT6 -A INPUT -p ipv6-icmp -j ACCEPT

# SSH
$IPT6 -A INPUT -s 2001:4800:7818:104:be76:4eff:fe05:d495 -p tcp --dport 22 -j ACCEPT # master.codeshelf.com

# DNS
$IPT6 -A INPUT -s 2607:f0d0:1005:72::100 -p tcp --dport 53 -j ACCEPT # BuddyNS
$IPT6 -A INPUT -s 2607:f0d0:1005:72::100 -p udp --dport 53 -j ACCEPT
$IPT6 -A INPUT -s 2a01:4f8:d12:d01::10:100 -p tcp --dport 53 -j ACCEPT # BuddyNS
$IPT6 -A INPUT -s 2a01:4f8:d12:d01::10:100 -p udp --dport 53 -j ACCEPT
$IPT6 -A INPUT -s 2001:4801:7817:72:be76:4eff:fe10:db08 -p tcp --dport 53 -j ACCEPT # ns.codeshelf.com
$IPT6 -A INPUT -s 2001:4801:7817:72:be76:4eff:fe10:db08 -p udp --dport 53 -j ACCEPT

# Default Reject
$IPT6 -A INPUT -j REJECT --reject-with icmp-host-prohibited

exit 0
