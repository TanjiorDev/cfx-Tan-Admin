# Organisation du client

- `core/` : initialisation, état partagé, fonctions communes et commandes.
- `menus/` : chaque menu est rangé dans son propre fichier.
- `features/` : fonctionnalités indépendantes (noclip, coordonnées, reports).
- `events/` : événements réseau reçus côté client.

L'ordre de chargement est défini dans `fxmanifest.lua`.
