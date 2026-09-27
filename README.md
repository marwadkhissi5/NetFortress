# NetFortress — Enterprise Perimeter Defense & Segmented Network Lab

Laboratoire d'ingénierie réseau et cybersécurité déployé sur environnement virtuel bare-metal sous architecture **Apple Silicon (ARM64)** avec **OPNsense** et **Alpine Linux**.

---

## Architecture Réseau & Topologie

Le réseau repose sur un pare-feu périmétrique gérant un trunk 802.1Q découpé en zones de sécurité étanches :

| Zone | Identifiant / Tag | Sous-réseau | Rôle & Description |
| :--- | :--- | :--- | :--- |
| **WAN** | Physique (`vtnet0`) | DHCP / NAT hôte | Sortie Internet, inspection IPS en ligne et accès mandataire public |
| **LAN / Users** | VLAN 10 (`OPT1`) | `10.10.10.0/24` | Poste client / sonde Alpine (`10.10.10.50`) et serveurs locaux |
| **DMZ** | VLAN 20 (`OPT2`) | `10.20.20.0/24` | Zone tampon isolée |
| **Honeypot** | VLAN 30 (`OPT3`) | `10.30.30.0/24` | Segment d'interception et de leurre réseau (`10.30.30.50`) |

---

## Matrice de Sécurité & Politiques de Filtrage

* **Isolation Inter-VLAN stricte :** Le trafic émis depuis le VLAN 10 vers le VLAN 30 est systématiquement bloqué et consigné via Packet Filter (`block in log quick`).
* **Source NAT (Outbound NAT) :** Masquage dynamique permettant la sortie Internet sécurisée des sous-réseaux internes via l'interface WAN.
* **DNSBL (Unbound DNS) :** Neutralisation de la résolution des domaines malveillants à l'aide des flux Steven Black.
* **Réputation IP WAN :** Alias dynamique alimenté par Spamhaus DROP bloquant tout flux entrant d'adresses réputées hostiles.
* **Suricata IPS (Mode Inline) :** Inspection protocolaire en temps réel sur le moteur Netmap avec signatures *Emerging Threats*.
* **HAProxy :** Terminaison TLS, forçage HSTS, OCSP stapling et Rate Limiting par adresse source adossé à une Stick-table IPv4.
* **Sonde Honeypot :** Capture d'intrusion et journalisation des TTPs sur le port TCP `2222` au sein de la zone isolée VLAN 30.

---

## Structure du Dépôt

* `docs/` : Dossiers de validation technique, preuves d'interception et rapports complets de jalons.
* `configs/` : Fichiers de configuration réels d'OPNsense (XML assaini) et des interfaces réseau Alpine.
* `scripts/` : Scripts de persistance noyau FreeBSD (`99-netfortress.sh`) et déploiement de la sonde Honeypot.
* `tests/` : Commandes et scénarios de simulation d'attaques et de vérification d'isolation L3/L4.

---

## Validation Technique & Preuves d'Interception

1. **Isolation L3/L4 (VLAN 10 vers VLAN 30) :**
   * ICMP : 100% de perte de paquets.
   * TCP/3306 : `Operation timed out` (rejet silencieux).
   * Logs `pflog0` : trace formelle `rule 96/0(match): block in on vtnet1_vlan10`.
2. **Suricata Inline IPS :**
   * Déclenchement de l'alerte `ET ATTACK_RESPONSE id check returned root` lors du test applicatif.
3. **Capture Honeypot :**
   * Enregistrement horodaté de la charge utile de l'attaquant (`ATTACK: root 123456`) dans les journaux d'audit.
