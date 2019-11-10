#!/bin/bash
BUILD_DIR=build
PCAP_DIR=pcaps
LOG_DIR=logs

TEST_FILE=${LOG_DIR}/test.mn
TOPO=topology.json

RUN_SCRIPT=../../utils/run_exercise.py
NO_DEBUG_SCRIPT=../disable_debug.py

STATUS=0

enable_ipv6(){
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0	&&              
	sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
}

disable_ipv6(){
    sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1 &&
	sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
}

stop(){    
    echo "Stopping Mininet ..." &&
    sudo mn -c &&
	sudo killall -q -s KILL firefox wireshark telnet iperf 
    echo ''
}

clean(){ 
    echo 'clean()' 
    sudo rm -rf "$PCAP_DIR"/* "$LOG_DIR"/* "$BUILD_DIR"/*
}

dirs(){  
    echo 'dirs()' &&
    mkdir -p "$BUILD_DIR" "$PCAP_DIR" "$LOG_DIR"
}

build(){   
    for P4_SOURCE in *.p4 ; do
        P4_JSON=${BUILD_DIR}/$(basename -s .p4 "$P4_SOURCE").json
        make "$P4_JSON" || return $?        
    done    
}

no_debug(){
    echo -e '\nNO DEBUG MODE\n' &&
    "$NO_DEBUG_SCRIPT"
}

run(){        
	disable_ipv6 &&
    stop &&
    clean &&
    dirs &&
    build
    STATUS=$?
    for opt in $@; do
        shift
        if [ "$opt" == "-6" ]; then
            enable_ipv6            
        elif [ "$opt" == "-r" ]; then
            no_debug        
        elif [ "$opt" == "-s" ]; then
            NEXT_OPT='-s'
            break
        elif [ "$opt" == "--script" ]; then
            NEXT_OPT='--script'
            break
        else
            echo "ERROR: option '$opt' not recognized"
            exit 1
        fi
        STATUS=$(($STATUS + $?))
    done
    if [ "$NEXT_OPT" == '-s' ]; then
        echo "$@" > "$TEST_FILE"
        MININET_SCRIPT="-s $TEST_FILE"
    elif [ "$NEXT_OPT" == '--script' ]; then
        MININET_SCRIPT="-s $1"
    fi
    if [ $STATUS -eq 0 ]; then
        echo -e '\nStarting Mininet ...\n'    
        sudo python "$RUN_SCRIPT" -t "$TOPO" -b simple_switch_grpc $MININET_SCRIPT
    else
        echo "ERROR: unexpected error happened"
        exit $STATUS
    fi
}

# set -o xtrace
if [ -z "$1" ] || [ "${1:0:1}" == "-" ]; then         
    run $@
else
    CMD=$1
    shift
    "$CMD" $@
fi
