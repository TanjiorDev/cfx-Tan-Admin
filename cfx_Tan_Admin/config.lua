Config = {}

Config.MenuPosition = 'top-left'
Config.OpenKey = 'F10'
Config.NoclipKey = 'F9'

Config.AllowedGroups = {
    admin = true,
    owner = true,
    superadmin = true,
}

Config.MaxVehicleSpeed = 10.0

-- Véhicules disponibles dans la liste déroulante du menu admin.
-- Le label est le nom affiché et model correspond au nom de spawn FiveM.
Config.VehicleList = {
    {label = 'Sultan', model = 'sultan'},
    {label = 'Sultan RS', model = 'sultanrs'},
    {label = 'Adder', model = 'adder'},
    {label = 'Banshee', model = 'banshee'},
    {label = 'Buffalo', model = 'buffalo'},
    {label = 'Comet', model = 'comet2'},
    {label = 'Kuruma', model = 'kuruma'},
    {label = 'Rebla GTS', model = 'rebla'},
    {label = 'Schafter V12', model = 'schafter3'},
    {label = 'Zentorno', model = 'zentorno'},
    {label = 'Police Cruiser', model = 'police'},
    {label = 'Police Buffalo', model = 'police2'},
    {label = 'Ambulance', model = 'ambulance'},
    {label = 'Dépanneuse', model = 'towtruck'},
}

-- Système de reports
Config.ReportCommand = 'report'
Config.ReportMaxLength = 300
Config.ReportCooldown = 60 -- secondes entre deux reports par joueur


-- Affichage permanent des coordonnées
Config.CoordinatesPosition = 'top-center'
Config.CoordinatesRefreshRate = 100 -- millisecondes


-- Tenue utilisée lorsque la case « Service staff » est activée.
-- Format illenium-appearance :
-- component_id : 3 bras, 4 pantalon, 5 sac, 6 chaussures, 7 accessoires,
-- 8 sous-vêtement, 9 gilet, 10 decals, 11 haut.
-- prop_id : 0 chapeau/casque, 1 lunettes. Une valeur drawable = -1 retire le prop.
Config.StaffOutfit = {
    male = {
        components = {
            {component_id = 3, drawable = 3, texture = 0},
            {component_id = 4, drawable = 114, texture = 2},
            {component_id = 5, drawable = 0, texture = 0},
            {component_id = 6, drawable = 78, texture = 2},
            {component_id = 7, drawable = 0, texture = 0},
            {component_id = 8, drawable = 15, texture = 0},
            {component_id = 9, drawable = 0, texture = 0},
            {component_id = 10, drawable = 0, texture = 0},
            {component_id = 11, drawable = 287, texture = 2},
        },
        props = {
            {prop_id = 0, drawable = -1, texture = 0},
            {prop_id = 1, drawable = -1, texture = 0},
        }
    },
    female = {
        components = {
            {component_id = 3, drawable = 9, texture = 0},
            {component_id = 4, drawable = 121, texture = 2},
            {component_id = 5, drawable = 0, texture = 0},
            {component_id = 6, drawable = 82, texture = 2},
            {component_id = 7, drawable = 0, texture = 0},
            {component_id = 8, drawable = 14, texture = 0},
            {component_id = 9, drawable = 0, texture = 0},
            {component_id = 10, drawable = 0, texture = 0},
            {component_id = 11, drawable = 300, texture = 2},
        },
        props = {
            {prop_id = 0, drawable = -1, texture = 0},
            {prop_id = 1, drawable = -1, texture = 0},
        }
    }
}
