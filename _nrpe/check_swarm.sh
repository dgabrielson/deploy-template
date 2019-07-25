#!/usr/bin/env bash

swarm_status="$(docker info 2>/dev/null | grep Swarm: | cut -f 2 -d : | tr -d ' ')"
# swarm status is either "active" or "inactive"
node_ls="docker node ls --format {{.Hostname}}\t{{.Status}}/{{.Availability}}"
# good nodes end with "Ready/Active"

if [[ $swarm_status != "active" ]]; then
    echo "CRITICAL - swarm status: $swarm_status"
    exit 2
fi

total_nodes=$($node_ls 2>/dev/null | wc -l)
if [[ $total_nodes == "" ]]; then
    echo "CRITICAL - not a swarm manager"
    exit 2
fi

good_nodes=$($node_ls | grep "Ready/Active$" | wc -l)

if [[ $total_nodes == $good_nodes ]]; then
    echo "OK - all ${total_nodes} nodes active/ready"
    exit 0
else
    echo "CRITICAL - $($node_ls | grep -v "Ready/Active$")"
    exit 2
fi
