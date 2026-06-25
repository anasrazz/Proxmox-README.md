# 🖥️ Infrastructure de Virtualisation avec Proxmox VE
**Projet de Fin d'Études — Groupe HP1 | 2026**

---

## 👥 Équipe Projet

| Nom | Rôle | Spécialité |
|-----|------|------------|
| Abdelilah EL GOUACH | Chef de projet | Cloud |
| Ahmed ZOUITANE | Membre | Réseau |
| Mariem EL MEJJADI | Membre | Cybersécurité |
| Ghita EL BIHEL | Membre | Réseau |
| Anas RAZZOUKI | Membre | Cybersécurité |
| Noureddine AGROU | Membre | Cybersécurité |

---

## 📋 Description du Projet

Ce projet consiste à concevoir et mettre en place une infrastructure de virtualisation complète basée sur **Proxmox VE**, offrant :

- 🛡️ Sécurité réseau via **pfSense** (Firewall + VLANs + VPN)
- 💾 Stockage centralisé via **Ubuntu Server** (Samba)
- 📊 Supervision via **Prometheus + Grafana**
- 🌐 **Portail web** de gestion des ressources
- 🤖 Automatisation via **Python / Bash / Ansible**

---

## 🏗️ Architecture Globale

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
   ┌─────▼────┐  ┌─────▼────┐  ┌────▼──────┐
   │  Ubuntu  │  │ Windows  │  │Supervision│
   │  NODE 2  │  │  NODE 3  │  │  (LXC)    │
   │ Stockage │  │  Client  │  │  Grafana  │
   │  Samba   │  │  Tests   │  │Prometheus │
   └──────────┘  └──────────┘  └───────────┘
```
## 💻 Développements Spécifiques (Back-End & Front-End)
Le portail de gestion de notre infrastructure est divisé en deux parties pour une meilleure scalabilité :

* **Back-End (Platform Cloud)** : Géré par Ahmed ZOUITANE, il traite les requêtes API vers Proxmox et automatise les tâches complexes.
    * 🔗 [Lien vers le dépôt Back-End](https://github.com/azouitane/platform_cloud.git)
* **Front-End (Virtacore UI)** : Interface utilisateur moderne pour la supervision et le contrôle des VMs.
    * 🔗 [Lien vers le dépôt Front-End](https://github.com/azouitane/virtacore-ui.git)
---

## 🛠️ Technologies Utilisées

| Technologie | Rôle |
|-------------|------|
| Proxmox VE | Hyperviseur principal |
| KVM | Virtualisation |
| LXC | Conteneurisation |
| pfSense | Pare-feu + Réseau |
| Ubuntu Server | Stockage + Services |
| Windows | Client + Tests |
| Samba | Partage fichiers réseau |
| Prometheus | Collecte métriques |
| Grafana | Visualisation dashboards |
| Python / Bash | Scripts automatisation |
| Ansible | Déploiement automatisé |
| API REST Proxmox | Intégration et backup |
| GitHub | Versioning du code |

---
## 🌐 Plan Réseau

| Node | VM | VLAN | IP | Rôle |
|------|-----|------|----|------|
| NODE 1 | pfSense | WAN + LAN | 192.168.100.1 | Firewall |
| NODE 2 | Ubuntu Server | VLAN 10 | 192.168.10.10 | Stockage |
| NODE 3 | Windows | VLAN 20 | 192.168.20.10 | Client |
| NODE 4 | Supervision LXC | VLAN 30 | 192.168.30.10 | Monitoring |

---

## 💾 Stockage

```
Ubuntu Server (192.168.10.10)
│
└── /srv/stockage/
    ├── data/        ← Fichiers utilisateurs
    ├── backups/     ← Backups VMs Proxmox
    └── shared/      ← Fichiers partagés

Accès Windows : \\192.168.10.10\Stockage-PFE
Accès Linux   : smb://192.168.10.10/Stockage-PFE
```

---

## 🔒 Sécurité

```
✅ pfSense  = Point d'entrée unique
✅ VLANs    = Isolation inter-VMs
✅ Firewall = Règles strictes
✅ VPN      = Accès distant sécurisé
✅ Backups  = Copies automatiques daily
✅ Password = Forts et sécurisés
```

---

## 📊 Modules Fonctionnels

### ✅ Module 1 — Réseau et Sécurité (pfSense)
- WAN + LAN configurés
- VLANs 10, 20, 30 créés et assignés
- Règles Firewall (isolation inter-VMs)
- DHCP par VLAN
- VPN OpenVPN configuré

### ✅ Module 2 — Stockage (Ubuntu Server)
- Samba installé et configuré
- Partages réseau créés
- Backup automatique Proxmox vers Ubuntu
- Snapshots configurés

### ⏳ Module 3 — Supervision
- Prometheus (collecte métriques)
- Grafana (dashboards temps réel)
- Node Exporter sur toutes les VMs
- Alertes configurées

### ⏳ Module 4 — Automatisation
- Scripts Python via API Proxmox
- Scripts Bash (backup automatique)
- Ansible (déploiement automatisé)
- Portail Web Flask
---

## 📅 Planning Prévisionnel (Mise à jour)

| Phase | Titre | Dates | Status |
| :--- | :--- | :--- | :--- |
| Phase 1 | Analyse + Conception | 01 - 10 Juin | ✅ Terminé |
| Phase 2 | Installation + Config | 11 - 25 Juin | ✅ Terminé |
| Phase 3 | Déploiement Services | 26 Juin - 10 Juil | ✅ Terminé |
| Phase 4 | Tests + Validation | 11 - 20 Juil | ✅ Terminé |
| Phase 5 | Documentation + Soutenance | 21 Juil+ | ✅ Terminé |
---

## 📝 Livrables

```
✅ Fiche de cadrage
✅ Cahier des charges
✅ Dépôt GitHub configuré
✅ Infrastructure Proxmox (en cours)
✅ pfSense configuré (en cours)
✅ Ubuntu Stockage
✅ Supervision Grafana
✅ Scripts automatisation
✅ Portail Web
✅ Documentation technique
✅ Rapport final PFE
⏳ Présentation soutenance
```

---

## 🚀 Démarrage Rapide

```bash
# Cloner le dépôt
git clone https://github.com/USERNAME/pfe-proxmox.git
cd pfe-proxmox

# Installer les dépendances Python
pip install proxmoxer requests flask

# Lancer le gestionnaire de VMs
python3 scripts/python/gestion_vms.py

# Lancer le portail web
python3 portail-web/app.py
```

---

> **Encadrant : M. SALAMA ADIB | Groupe HP1 | 2026**
