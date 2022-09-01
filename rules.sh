# These are my rules that I use on my VPS servers.


# Drops spoofed and null packets 
iptables -A INPUT -s 127.0.0.0/8 -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

# Droping diferent types of attacks
iptables -A INPUT -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
iptables -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,PSH,URG -j DROP
iptables -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG -j DROP
iptables -A INPUT -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
iptables -A OUTPUT -p udp -j DROP
iptables -A INPUT -p tcp --dport 8080 -j DROP
iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,ACK FIN -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags PSH,ACK PSH -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags ACK,URG URG -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,RST FIN,RST -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,PSH,URG -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,PSH,URG -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,ACK,URG -j DROP
iptables -A INPUT -f -j DROP

# Drop ICMP packets, Blocks ICMP response and invalid packets with spoofed addresses
iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j DROP
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j DROP
sysctl -w net.ipv4.icmp_echo_ignore_all=1
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j DROP
iptables -A INPUT -p icmp -m icmp --icmp-type address-mask-request -j DROP
iptables -A INPUT -p icmp -m icmp --icmp-type timestamp-request -j DROP
iptables -A INPUT -p icmp -m limit --limit 2/second --limit-burst 2 -j ACCEPT
iptables -A INPUT -p icmp -j DROP

# Drops Reseted TCP Packets 
iptables -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT

# Drops SYN flooding
iptables -A INPUT -p tcp -m state --state NEW -m limit --limit 2/second --limit-burst 2 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -j DROP


# Protection against port scanning/NMAP and logs them  

iptables -A INPUT -m recent --name portscan --rcheck --seconds 86400 -j DROP
iptables -A FORWARD -m recent --name portscan --rcheck --seconds 86400 -j DROP
iptables -A INPUT -m recent --name portscan --remove
iptables -A FORWARD -m recent --name portscan --remove
iptables -A INPUT -m recent --name portscan --set -j LOG --log-prefix "Portscan:"
iptables -A INPUT -m recent --name portscan --set -j DROP
iptables -A FORWARD -m recent --name portscan --set -j LOG --log-prefix "Portscan:"
iptables -A FORWARD -m recent --name portscan --set -j DROP
iptables -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j DROP
iptables -A INPUT -p tcp --tcp-flags ACK,URG URG -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL SYN,FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL URG,PSH,FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL URG,PSH,SYN,FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s -j ACCEPT
iptables -A INPUT -p tcp --tcp-flags SYN,ACK SYN,ACK -m state --state NEW -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP

# Droping different attacks
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -p tcp -s [your_server_ip]--sport 80 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -I INPUT -s 109.51.48.210 -j DROP
iptables -A INPUT -p icmp --icmp-type echo-request -j REJECT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,ACK FIN -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags PSH,ACK PSH -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags ACK,URG URG -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,RST FIN,RST -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,PSH,ACK,URG -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,PSH,URG -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,PSH,URG -j DROP
iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG FIN,SYN,RST,ACK,URG -j DROP
iptables -A INPUT -f -j DROP
iptables -A INPUT -p udp -m udp --sport 19 -j DROP
iptables -A INPUT -p udp -m udp --sport 123 -j DROP
iptables -A INPUT -p udp -m udp --sport 161 -j DROP
iptables -A INPUT -p udp -m udp --sport 1433 -j DROP
iptables -A INPUT -p udp -m udp --sport 1900 -j DROP
iptables -A INPUT -p udp -m udp --sport 27015 -j DROP
iptables -A INPUT -p udp -m udp --sport 27950 -j DROP
iptables -A INPUT -p udp -m udp --sport 27952 -j DROP
iptables -A INPUT -p udp -m udp --sport 27960 -j DROP
iptables -A INPUT -p udp -m udp --sport 27965 -j DROP
iptables -A INPUT -p icmp -j DROP
iptables -A INPUT -p udp -m udp --sport 19329 -j DROP
iptables -A INPUT -p udp -m udp --sport 53 -j DROP
iptables -A INPUT -p tcp -m tcp --sport 53 -j DROP
iptables -A INPUT -p tcp -m tcp --sport 19329 -j DROP
iptables -A INPUT -p tcp -m tcp --sport 5353 -j DROP
iptables -A INPUT -p udp -m udp --sport 5353 -j DROP
iptables -A INPUT -p udp -m udp --sport 7143 -j DROP
iptables -A INPUT -p tcp -m tcp --sport 7143 -j DROP
iptables -A INPUT -p tcp -m tcp --sport 123 -j DROP
iptables -A INPUT -p udp -m udp --sport 123 -j DROP
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p icmp -j DROP
iptables -N syn-flood
iptables -A syn-flood -m limit --limit 10/sec --limit-burst 15 -j RETURN
iptables -A syn-flood -j LOG --log-prefix "SYN flooding: "
iptables -A syn-flood -j DROP
iptables -t mangle -A PREROUTING -p udp -m multiport --sports 3283,37810,7001,17185,3072,3702,32414,177,6881,5683,41794,2362 -j DROP 
iptables -t mangle -A PREROUTING -p udp -m multiport --sports 11211,53413,17,1900,10001,389,137,5351,502 -j DROP
iptables -t mangle -A PREROUTING -p udp --sport 37810 -j DROP
iptables -t mangle -A PREROUTING -p udp --sport 7001 -j DROP
iptables -I INPUT -p udp -m length --length 100:140 -m string --string "nAFS" --algo kmp -j DROP
iptables -t mangle -A PREROUTING -p udp --sport 17185 -j DROP
iptables -t mangle -A PREROUTING -p udp -m multiport --sports 3072,3702 -j DROP
iptables -t mangle -A PREROUTING -p tcp -m multiport --sports 3072,3702 -j DROP
iptables -t mangle -A PREROUTING -p udp --sport 3283 -m length --length 1048 -j DROP
iptables -t mangle -A PREROUTING -p udp --sport 32414 -j DROP
iptables -t mangle -A PREROUTING -p udp --sport 177 -j DROP
iptables -t mangle -A PREROUTING -p udp --sport 6881 -m length --length 320:330 -j DROP
iptables -t mangle -A PREROUTING -p udp -m length --length 280:300 --sport 32414 -j DROP
iptables --new-chain RATE-LIMIT
iptables --append INPUT --match conntrack --ctstate NEW --jump RATE-LIMIT
iptables --append RATE-LIMIT --match limit --limit 50/sec --limit-burst 20 --jump ACCEPT
iptables --append RATE-LIMIT --jump DROP
iptables-save