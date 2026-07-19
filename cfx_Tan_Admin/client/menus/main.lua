local function getStaffDutyOption()
    return {
        label = 'Prise de service staff',
        description = TAN_Admin.State.staffDuty
            and "Vous êtes en service. Décochez pour reprendre votre tenue d'origine."
            or 'Cochez pour prendre votre service et mettre la tenue staff.',
        icon = 'user-shield',
        checked = TAN_Admin.State.staffDuty,
        close = false,
        args = { action = 'staffDuty' }
    }
end

local function getMainMenuOptions()
    local options = {
        getStaffDutyOption()
    }

    -- Les menus d'administration restent cachés tant que le staff
    -- n'a pas pris son service.
    if TAN_Admin.State.staffDuty then
        options[#options + 1] = {
            label = 'Actions personnelles',
            description = 'Heal, revive, godmode, invisibilité, noclip',
            icon = 'user-shield',
            args = { action = 'self' }
        }
        options[#options + 1] = {
            label = 'Gestion des joueurs',
            description = 'Téléportation, freeze, heal, revive et kick',
            icon = 'users-gear',
            args = { action = 'players' }
        }
        options[#options + 1] = {
            label = 'Gestion des véhicules',
            description = 'Spawn, réparation, nettoyage et suppression',
            icon = 'car',
            args = { action = 'vehicles' }
        }
        options[#options + 1] = {
            label = 'Outils développeur',
            description = 'Coordonnées Vector3, Vector4 et heading',
            icon = 'code',
            args = { action = 'developer' }
        }
        options[#options + 1] = {
            label = 'Gestion des reports',
            description = 'Voir, prendre en charge et fermer les demandes',
            icon = 'triangle-exclamation',
            args = { action = 'reports' }
        }
    end

    return options
end

local rebuildingMainMenu = false

local function rebuildMainMenu()
    if rebuildingMainMenu then return end
    rebuildingMainMenu = true

    -- setMenuOptions ne reconstruit pas toujours correctement un menu lorsque
    -- son nombre d'options change. On ferme donc le menu, puis on le recrée.
    lib.hideMenu(false)

    CreateThread(function()
        Wait(50)
        rebuildingMainMenu = false
        TAN_Admin.OpenMainMenu()
    end)
end

function TAN_Admin.OpenMainMenu()
    lib.registerMenu({
        id = 'tan_admin_main',
        title = 'Menu Administration',
        position = Config.MenuPosition,
        onCheck = function(_, checked, args)
            if not args or args.action ~= 'staffDuty' then return end

            TAN_Admin.ToggleStaffDuty(checked, function(success)
                if not success then
                    TAN_Admin.Notify("La prise de service n'a pas pu être modifiée.", 'error')
                end

                -- Reconstruit entièrement le menu afin que les boutons
                -- apparaissent en service et disparaissent hors service.
                rebuildMainMenu()
            end)
        end,
        options = getMainMenuOptions()
    }, function(_, _, args)
        if not args then return end

        if args.action == 'self' then
            TAN_Admin.OpenSelfMenu()
        elseif args.action == 'players' then
            TAN_Admin.OpenPlayersMenu()
        elseif args.action == 'vehicles' then
            TAN_Admin.OpenVehicleMenu()
        elseif args.action == 'developer' then
            TAN_Admin.OpenDeveloperMenu()
        elseif args.action == 'reports' then
            TAN_Admin.OpenReportsMenu()
        end
    end)

    lib.showMenu('tan_admin_main')
end
