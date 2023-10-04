#!/bin/bash

# if you want output showing extra stuff `export VERBOSE=1` in your shell before running, or set it here.
# VERBOSE=1

# if you want to run in test-only/dry mode `export TEST_ONLY=1` in your shell before running, or set it here.
# TEST_ONLY=1

# SOURCE_INTERFACES will correspond to the switch and optionally switch sub-interfaces that you want to mirror from
# NOTE: on UDMSE Pro, switch0.1 is typically the "default" network VLAN #1 (untagged)
# NOTE: on UDMSE Pro, switch0.2 is typically the "guest" network VLAN #2 (tagged)
# NOTE: you will probably want to create an "IDS" specific network, e.g. VLAN#999 to which you will assign the IDS port that you're mirroring the traffic out to. This will avoid the switch duplicating traffic to that port, e.g. because the IDS VLAN#999 has nothing else in it there is no other traffic being generated in that VLAN, so the only traffic that will be seen on the IDS_PORT is the mirrored traffic. 
# NOTE: This can be a list of interfaces if you want to monitor multiple source VLAN's
SOURCE_INTERFACES="switch0.1 switch0.2"

# IDS_PORT is the physical wired port that your IDS sensor/inspection device is connected to and to which you will mirror traffic.
# NOTE: This port should be in an IDS specific VLAN that no other traffic is being generated on. e.g. management of the IDS sensor would be on another port in a different VLAN, or via wireless connectivity e.g. if you're using Corelight@Home on a Raspberry Pi.
IDS_PORT="eth6"

for INTERFACE in ${SOURCE_INTERFACES} ; do
  echo "Mirroring traffic from ${INTERFACE} to ${IDS_PORT}"
  # configure mirroring queue if not already configured
  # test for existance of existing queue for interface
  tc -s qdisc ls dev ${INTERFACE} 2>&1 | grep ingress 1>/dev/null 2>&1

  if [ ${?} -ne 0 ] ; then
    # the queue does not exist yet, create it.
    test "${VERBOSE}" = "1" && echo -n "Creating Traffic Control queue for ${INTERFACE}..."
    test "${TEST_ONLY}" != "1" && tc qdisc add dev ${INTERFACE} handle ffff: ingress && echo "OK" || echo "FAILURE"
    echo
  else
    test "${VERBOSE}" = "1" && echo "Traffic Control queue already exists for ${INTERFACE}..."
  fi

  test "${VERBOSE}" = "1" && echo "Current Traffic Control queue for ${INTERFACE}..." && echo
  test "${VERBOSE}" = "1" && tc -s qdisc ls dev ${INTERFACE} && echo

  # direct monitored traffic out the physical interface connected to the Corelight sensor
  # test for existance of existing filter for interface
  tc -s -p filter ls dev ${INTERFACE} parent ffff: 2>&1 | grep "to device ${IDS_PORT}" 1>/dev/null 2>&1

  if [ ${?} -ne 0 ] ; then
    # the filter does not exist yet, create it.
    test "${VERBOSE}" = "1" && echo -n "Creating Traffic Control filter for ${INTERFACE} mirroring to ${IDS_PORT}..."
    test "${TEST_ONLY}" != "1" && tc filter add dev ${INTERFACE} parent ffff: protocol all u32 match u32 0 0 action mirred egress mirror dev ${IDS_PORT} && echo "OK" || echo "FAILURE"
    echo
  else
    test "${VERBOSE}" = "1" && echo "Traffic Control filter already exists for ${INTERFACE}..."
  fi

  test "${VERBOSE}" = "1" && echo "Current Traffic Control filter for ${INTERFACE}..." && echo
  test "${VERBOSE}" = "1" && tc -s -p filter ls dev ${INTERFACE} parent ffff: && echo
done

# EOF