# 🛡️ Tan Admin

Un menu d'administration moderne développé pour **ESX Legacy**, utilisant **ox_lib** et **illenium-appearance**.

Le menu est pensé pour permettre aux membres du staff de gérer facilement les joueurs, les véhicules, les reports et les outils de développement depuis une seule interface.

---

# ✨ Fonctionnalités

## ✅ Prise de service Staff

Avant d'accéder aux outils d'administration, le staff doit activer son service.

Lors de la prise de service :

* Activation du mode Staff
* Application automatique de la tenue Staff (compatible illenium-appearance)
* Déverrouillage de tous les menus d'administration

En quittant le service :

* La tenue d'origine est automatiquement restaurée
* Les menus d'administration sont masqués

---

# 👤 Actions personnelles

Permet d'effectuer rapidement plusieurs actions sur son propre personnage.

## ❤️ Se soigner

* Restaure toute la vie
* Nettoie le sang
* Réinitialise les besoins ESX (si disponible)

---

## 🩺 Se réanimer

Réanime immédiatement le personnage.

---

## 🛡️ GodMode

Activation ou désactivation du mode invincible.

---

## 👻 Invisibilité

Permet de devenir invisible ou visible instantanément.

---

## 📍 Téléportation au marqueur

Téléporte automatiquement le joueur sur le point GPS placé sur la carte.

Le système recherche automatiquement le sol afin d'éviter de rester bloqué dans les airs.

---

## ✈️ Noclip

Activation du mode Noclip permettant de se déplacer librement dans la carte.

---

# 👥 Gestion des joueurs

Visualisation de tous les joueurs connectés.

Pour chaque joueur :

## 📌 Se téléporter sur lui

Téléporte le staff jusqu'au joueur sélectionné.

---

## 📌 Le téléporter sur moi

Téléporte le joueur jusqu'au staff.

---

## ❄️ Freeze / Unfreeze

Bloque ou débloque complètement les déplacements du joueur.

---

## ❤️ Soigner

Restaure complètement la santé du joueur.

---

## 🩺 Réanimer

Réanime immédiatement le joueur.

---

## 🚪 Expulser

Permet d'expulser un joueur du serveur avec une raison personnalisée.

---

# 🚗 Gestion des véhicules

Tous les outils nécessaires pour gérer rapidement un véhicule.

## 🚘 Faire apparaître un véhicule

Deux possibilités :

* Choisir un véhicule dans la liste configurée
* Entrer manuellement un nom de modèle GTA V

Exemple :

* adder
* police
* sultan
* buffalo
* baller

---

## 🔧 Réparer

Répare entièrement le véhicule.

---

## 🧼 Nettoyer

Supprime toute la saleté présente sur le véhicule.

---

## 🔄 Retourner

Replace automatiquement le véhicule sur ses roues.

---

## ⚡ Amélioration maximale

Applique automatiquement les meilleures améliorations disponibles :

* Performances moteur
* Transmission
* Freins
* Suspension
* Turbo
* Pneus renforcés

---

## 🗑️ Supprimer

Supprime proprement le véhicule sélectionné.

---

# 💻 Outils Développeur

Conçu spécialement pour les développeurs FiveM.

---

## 📋 Copier Vector3

Copie directement dans le presse-papiers :

```lua
vector3(x, y, z)
```

---

## 📋 Copier Vector4

Copie directement :

```lua
vector4(x, y, z, heading)
```

---

## 🧭 Copier le Heading

Copie uniquement la rotation du personnage.

Exemple :

```
180.00
```

---

## 📍 Afficher les coordonnées

Affiche en temps réel :

* Position X
* Position Y
* Position Z
* Heading

Très pratique pour :

* Mapping
* Création de zones
* ox_target
* PolyZone
* Spawn de PNJ
* Spawn de véhicules

---

# 📨 Gestion des Reports

Système complet de gestion des reports.

Le menu affiche :

* Numéro du report
* Heure
* Nom du joueur
* ID du joueur
* Message envoyé
* Statut du report

---

## ✋ Prendre en charge

Permet à un membre du staff de réserver le report afin d'éviter qu'il soit traité par plusieurs personnes.

---

## 💬 Répondre

Envoie une réponse directement au joueur.

---

## 📍 Aller au joueur

Téléporte automatiquement le staff vers le joueur ayant ouvert le report.

---

## 👥 Faire venir le joueur

Téléporte le joueur vers le staff.

---

## ✅ Fermer le report

Ferme définitivement le report avec une raison personnalisée.

---

# 🎯 Compatibilité

* ✅ ESX Legacy
* ✅ ox_lib
* ✅ illenium-appearance
* ✅ OneSync
* ✅ Lua 5.4

---

# 🚀 Points forts

* Interface moderne avec ox_lib
* Navigation rapide
* Menus organisés
* Notifications intégrées
* Optimisé pour les performances
* Compatible avec les serveurs RP
* Facile à configurer
* Structure claire pour les développeurs

---

# 📂 Structure

```
client/
├── core/
├── events/
├── features/
├── menus/
└── client.lua

server/
└── server.lua

config.lua
fxmanifest.lua
```

---

# 👨‍💻 Développé par

**Tanjiro Studio**
