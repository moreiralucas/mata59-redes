/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;
const bit<8>  TYPE_TCP  = 0x6;
const bit<8>  TYPE_UDP  = 0x11;

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    typeOfService;
    bit<16>   totalLength;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragmentOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   checksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header tcp_t{
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNumber;
    bit<32> ackNumber;
    bit<4>  dataOffset;
    bit<6>  reserved;
    bit<6>  controlBits;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPointer;
}

header udp_t{
    bit<16> srcPort;   
    bit<16> dstPort;
    bit<16> totalLength;
    bit<16> checksum;
}

struct metadata {
    /* empty */
}

// headers do pacote
struct headers {
    ethernet_t   ethernet;
    ipv4_t       ipv4;
    tcp_t        tcp;
    udp_t        udp;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        // extrai header ethernet do pacote
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

     state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol){
            TYPE_TCP: parse_tcp;
            TYPE_UDP: parse_udp;
            default: accept;
        }
    }

    state parse_tcp {
       packet.extract(hdr.tcp);
       transition accept;
    }

    state parse_udp {
       packet.extract(hdr.udp);
       transition accept;
    }

}

/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {   
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    // descarta pacote 
    action drop() {
        mark_to_drop();
    }
    
    // faz o encaminhamento do pacote
    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
    }

    // faz o broadcast do pacote para todas as portas do roteador
    action ipv4_broadcast() {
        standard_metadata.mcast_grp = 1;
    }

    action mac_broadcast() {
        standard_metadata.mcast_grp = 1;
    }

    action mac_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
    }
    
    // tabela match-action que verifica qual acao executar sobre o pacote
    table mac_lpm {
        key = {
            hdr.ethernet.dstAddr: lpm;
        }
        actions = {
            mac_forward;
            mac_broadcast;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            ipv4_broadcast;
            drop;
            NoAction;
        }
        size = 1024;
        default_action = drop();
    }

    table tcp_firewall {
        key = {
            hdr.tcp.dstPort: range;
        }
        actions = {            
            drop;
            NoAction;
        }
        size = 1024;
        default_action = NoAction();
    }

    table udp_firewall {
        key = {
            hdr.udp.dstPort: range;
        }
        actions = {            
            drop;
            NoAction;
        }
        size = 1024;
        default_action = NoAction();
    }
    
    apply {
        if (hdr.ethernet.isValid()) {
            mac_lpm.apply();        
        }
        if (hdr.ipv4.isValid()) {
            ipv4_lpm.apply();        
        }
        if (hdr.tcp.isValid()) {
            tcp_firewall.apply();        
        }
        if (hdr.udp.isValid()) {
            udp_firewall.apply();        
        }
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply {  }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
    apply { }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr);        
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;