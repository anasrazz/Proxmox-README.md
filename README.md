# 🖥️ Infrastructure de Virtualisation avec Proxmox VE
### Projet de Fin d'Études — HP1 | 2026

---

## 👥 Équipe Projet

|        Nom          |  Rôle  | Spécialité |
|---------------------|----------------|---------------|
| Abdelilah EL GOUACH | Chef de projet | Cloud         |
| Ahmed ZOUITANE      |     Membre     | Réseau        |
| Mariem EL MEJJADI   |     Membre     | Cybersécurité |
| Ghita EL BIHEL      |     Membre     | Réseau        |
|  Anas RAZZOUK       |     Membre     | Cybersécurité |
| Noureddine AGROU    |     Membre     | Cybersécurité |
--------------------------------------------------------

### 📋 Description du Projet

Ce projet consiste à concevoir et mettre en place 
une infrastructure de virtualisation complète basée 
sur Proxmox VE, offrant:

- 🛡️ Sécurité réseau via pfSense
- 💾 Stockage centralisé via Ubuntu Server
- 📊 Supervision via Prometheus + Grafana
- 🌐 Portail web de gestion des ressources
- 🤖 Automatisation via Python/Bash/Ansible

---

## 🏗️ Architecture
## 🏗️ Architecture

```
                    INTERNET
                       │
              ┌────────▼────────┐
              │    pfSense      │  NODE 1
              │  Firewall+VLANs │
              │   DHCP + VPN    │
              └────────┬────────┘
                       │
            vmbr1 (LAN - 192.168.100.0/24)
                       │
         ┌─────────────┼─────────────┐
         │             │             │
      VLAN 10       VLAN 20       VLAN 30
  192.168.10.x   192.168.20.x  192.168.30.x
         │             │             │
   ┌─────▼────┐  ┌─────▼────┐  ┌────▼─────┐
   │  Ubuntu  │  │ Windows  │  │Supervision│
   │  NODE 2  │  │  NODE 3  │  │  (LXC)   │
   │ Stockage │  │  Client  │  │  Grafana  │
   │  Samba   │  │  Tests   │  │Prometheus │
   └──────────┘  └──────────┘  └───────────┘
```

## 🛠️ Technologies Utilisées

|    Technologie   |         Rôle          |
|------------------|-----------------------|
| Proxmox VE       | Hyperviseur principal |
| pfSense          | Pare-feu + Réseau     |
| Ubuntu Server    | Stockage + Services   |  
| Windows          | Client + Tests        |
| Samba            | Partage fichiers      |
| Prometheus       | Collecte métriques    |
| Grafana          | Visualisation         |
| Python/Bash      | Automatisation        |
| API REST Proxmox | Intégration           |
| GitHub           | Versioning            |
--------------------------------------------

## 📁 Structure du Dépôt

```
pfe-proxmox/
│
├── scripts/
│   ├── python/
│   │   ├── gestion_vms.py
│   │   ├── monitoring.py
│   │   └── backup_api.py
│   ├── bash/
│   │   ├── backup_auto.sh
│   │   ├── setup_network.sh
│   │   └── install_samba.sh
│   └── ansible/
│       ├── deploy.yml
│       └── inventory.ini
│
├── configs/
│   ├── pfsense/
│   │   ├── firewall_rules.xml
│   │   └── vlans_config.xml
│   ├── samba/
│   │   └── smb.conf
│   └── prometheus/
│       └── prometheus.yml
│
├── portail-web/
│   ├── app.py
│   ├── requirements.txt
│   └── templates/
│       └── dashboard.html
│
├── docs/
│   ├── cahier_des_charges.pdf
│   ├── fiche_cadrage.pdf
│   ├── architecture.png
│   └── rapport_final.pdf
│
└── README.md
```

## 🌐 Plan Réseau
 
 ------------------------------------------------------------------
|  Node  |        VM       |    VLAN   |       IP      |    Rôle   |
|--------|-----------------|-----------|---------------|-----------|
| NODE 1 | pfSense         | WAN + LAN | 192.168.100.1 | Firewall  |
| NODE 2 | Ubuntu Server   | VLAN 10   | 192.168.10.10 | Stockage  |
| NODE 3 | Windows         | VLAN 20   | 192.168.20.10 |  Client   |
| NODE 4 | Supervision LXC | VLAN 30   | 192.168.30.10 | Monitoring|
 ------------------------------------------------------------------

 Ubuntu Server (192.168.10.10)
│
└── /srv/stockage/
├── data/ ← Fichiers utilisateurs
├── backups/ ← Backups VMs Proxmox
└── shared/ ← Fichiers partagés

Accès Windows : \192.168.10.10\Stockage-PFE
Accès Linux : smb://192.168.10.10/Stockage-PFE

## 🔒 Sécurité
✅ pfSense = Point d'entrée unique
✅ VLANs = Isolation inter-VMs
✅ Firewall = Règles strictes
✅ VPN = Accès distant sécurisé
✅ Backups = Copies automatiques


## 📊 Modules Fonctionnels

### ✅ Module 1 — Réseau et Sécurité (pfSense)
- WAN + LAN configurés
- VLANs 10, 20, 30 créés
- Règles Firewall (isolation inter-VMs)
- DHCP par VLAN
- VPN OpenVPN

### ✅ Module 2 — Stockage (Ubuntu)
- Samba installé et configuré
- Partages réseau créés
- Backup automatique Proxmox
- Snapshots configurés

### ✅ Module 3 — Supervision
- Prometheus (collecte métriques)
- Grafana (dashboards)
- Node Exporter sur VMs
- Alertes configurées

### ✅ Module 4 — Automatisation
- Scripts Python (API Proxmox)
- Scripts Bash (backup)
- Ansible (déploiement)
- Portail Web Flask
