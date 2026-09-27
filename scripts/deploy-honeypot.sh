#!/bin/sh
# Configuration de la patte VLAN 30 et écouteur d'interception
ip link add link eth0 name eth0.30 type vlan id 30
ip link set dev eth0.30 up
ip addr add 10.30.30.50/24 dev eth0.30

# Lancement de l'écouteur en tâche de fond sur le port 2222
nc -l -p 2222 > /root/honeypot.log &
