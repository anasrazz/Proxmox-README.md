# Configuration de pfSense

Ce répertoire documente la mise en place du pare-feu pfSense au cœur de notre infrastructure de virtualisation. 

## 📝 Résumé des actions
- **Installation** : Déploiement de pfSense en tant que passerelle principale.
- **Réseau** : Configuration des interfaces WAN (em0) et LAN (em1).
- **Segmentations** : Mise en place des VLANs 10 (Étudiants), 20 (Corporate) et 30 (Management).
- **Services** : Configuration des serveurs DHCP par segment et des règles de filtrage (Firewall Rules) pour assurer l'isolation entre les réseaux.

📄 **Détails techniques** : Veuillez consulter le fichier [pfsense.pdf](./pfsense.pdf) pour la documentation complète avec captures d'écran.
