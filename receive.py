#!/usr/bin/env python
import sys
import struct
import os

from scapy.all import *

def get_if():
    ifs=get_if_list()
    iface=None
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print "Cannot find eth0 interface"
        exit(1)
    return iface

def handle_pkt(pkt):
    if TCP in pkt or UDP in pkt:
        print "got a packet"
        pkt.show2()
    #    hexdump(pkt)
        print ' '
        print ' '
        print ' -----  PACOTE TESTE RECEBIDO  ----- '    
        print ' '
        sys.stdout.flush()


def main():
    ifaces = filter(lambda i: 'eth' in i, os.listdir('/sys/class/net/'))
    iface = ifaces[0]
    print "sniffing on %s" % iface
    sys.stdout.flush()
    sniff(iface = iface,
          prn = lambda x: handle_pkt(x))

if __name__ == '__main__':
    main()
