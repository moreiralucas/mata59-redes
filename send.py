#!/usr/bin/env python
import argparse
import sys
import socket
import random
import struct

from scapy.all import *

def get_if():
    ifs=get_if_list()
    iface=None # "h1-eth0"
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print "Cannot find eth0 interface"
        exit(1)
    return iface

def main():

    if len(sys.argv) < 5:
        print 'ERROR: pass 4 parameters \n\tUSAGE: ./send.py <IPv4 destination> <socket_type> <port> <message>'
        exit(1)

    addr_str = sys.argv[1]
    socket_type = sys.argv[2].upper()
    port = int(sys.argv[3])
    data = sys.argv[4]

    addr = socket.gethostbyname(addr_str)
    iface = get_if()

    switch = addr_str.split('.')
    host = int(switch[-1])
    switch = int(switch[-2])    

    print "sending on interface %s to %s" % (iface, str(addr))
    pkt =  Ether(src=get_if_hwaddr(iface), dst='00:00:00:00:%02x:%02x' % (switch, host) )
    pkt = pkt / IP(dst=addr) 
    if socket_type == 'TCP':
        pkt = pkt / TCP(dport=port, sport=65530) 
    else:
        pkt = pkt / UDP(dport=port, sport=65530) 
    pkt = pkt / data
    pkt.show2()
    print ' '
    print ' '
    print ' -----  PACOTE TESTE ENVIADO  ------ '
    print ' '
    sendp(pkt, iface=iface, verbose=False)


if __name__ == '__main__':
    main()
