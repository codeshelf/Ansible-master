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
$IPTABLES -A INPUT -p tcp --dport 53 -j ACCEPT
$IPTABLES -A INPUT -p udp --dport 53 -j ACCEPT

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
$IPT6 -A INPUT -p tcp --dport 53 -j ACCEPT
$IPT6 -A INPUT -p udp --dport 53 -j ACCEPT

# Default Reject
$IPT6 -A INPUT -j REJECT --reject-with icmp-host-prohibited

exit 0
