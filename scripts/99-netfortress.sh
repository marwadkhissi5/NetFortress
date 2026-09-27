#!/bin/sh
echo "block in log quick on vtnet1_vlan10 to 10.30.30.1/24" >> /tmp/rules.debug
echo "pass in quick on vtnet1_vlan10" >> /tmp/rules.debug
pfctl -f /tmp/rules.debug
