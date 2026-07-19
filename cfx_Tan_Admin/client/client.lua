local ESX = exports['es_extended']:getSharedObject()

local noclipActive = false
local noclipSpeed = 1.0
local godMode = false
local invisible = false
local frozen = false

local function notify(message, notificationType)
    lib.notify({
        title = 'Administration',
        description = message,
        type = notificationType or 'inform'
    })
end

local function checkAccess(callback)
    ESX.TriggerServerCallback('TAN_Admin:getgroup', function(access)
        if not access then
            notify("Vous n'avez pas la permission.", 'error')
            return
        end
        callback()
    end)
end

local function revivePed()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedTasksImmediately(ped)
    ClearPedBloodDamage(ped)
    ResetPedVisibleDamage(ped)
    TriggerEvent('esx_basicneeds:resetStatus')
    TriggerEvent('esx:onPlayerSpawn')
end

local function getCurrentVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        vehicle = GetClosestVehicle(GetEntityCoords(ped), 5.0, 0, 71)
    end
    return vehicle
end

local function deleteVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        notify('Aucun véhicule à proximité.', 'error')
        return
    end

    NetworkRequestControlOfEntity(vehicle)
    local timeout = GetGameTimer() + 1500
    while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < timeout do Wait(0) end
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
    if DoesEntityExist(vehicle) then DeleteEntity(vehicle) end
    notify('Véhicule supprimé.', 'success')
end

local function requestPlayerId(title)
    local input = lib.inputDialog(title, {
        {type = 'number', label = 'ID du joueur', required = true, min = 1}
    })
    return input and tonumber(input[1]) or nil
end

local function openSelfMenu()
    lib.registerMenu({
        id = 'tan_admin_self',
        title = 'Actions personnelles',
        position = Config.MenuPosition,
        options = {
            {label = 'Me soigner', icon = 'heart-pulse'},
            {label = 'Me réanimer', icon = 'user-plus'},
            {label = godMode and 'Désactiver le GodMode' or 'Activer le GodMode', icon = 'shield-halved'},
            {label = invisible and 'Redevenir visible' or 'Devenir invisible', icon = 'eye-slash'},
            {label = 'Téléportation au marqueur', icon = 'location-arrow'},
            {label = noclipActive and 'Désactiver le noclip' or 'Activer le noclip', icon = 'person-flying'},
        }
    }, function(selected)
        local ped = PlayerPedId()
        if selected == 1 then
            SetEntityHealth(ped, GetEntityMaxHealth(ped))
            ClearPedBloodDamage(ped)
            TriggerEvent('esx_basicneeds:resetStatus')
            notify('Vous avez été soigné.', 'success')
        elseif selected == 2 then
            revivePed()
            notify('Vous avez été réanimé.', 'success')
        elseif selected == 3 then
            godMode = not godMode
            SetEntityInvincible(ped, godMode)
            notify(('GodMode %s.'):format(godMode and 'activé' or 'désactivé'), godMode and 'success' or 'inform')
            openSelfMenu()
        elseif selected == 4 then
            invisible = not invisible
            SetEntityVisible(ped, not invisible, false)
            notify(('Invisibilité %s.'):format(invisible and 'activée' or 'désactivée'), invisible and 'success' or 'inform')
            openSelfMenu()
        elseif selected == 5 then
            local blip = GetFirstBlipInfoId(8)
            if not DoesBlipExist(blip) then
                notify("Vous n'avez pas placé de marqueur.", 'error')
                return
            end
            local coords = GetBlipInfoIdCoord(blip)
            SetPedCoordsKeepVehicle(ped, coords.x, coords.y, 1000.0)
            local found, groundZ = false, 0.0
            for height = 1000, 0, -25 do
                SetPedCoordsKeepVehicle(ped, coords.x, coords.y, height + 0.0)
                RequestCollisionAtCoord(coords.x, coords.y, height + 0.0)
                Wait(10)
                found, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, height + 0.0, false)
                if found then break end
            end
            SetPedCoordsKeepVehicle(ped, coords.x, coords.y, found and groundZ + 1.0 or coords.z)
            notify('Téléportation effectuée.', 'success')
        elseif selected == 6 then
            ExecuteCommand('adminnoclip')
            openSelfMenu()
        end
    end)
    lib.showMenu('tan_admin_self')
end

local function openPlayersMenu()
    ESX.TriggerServerCallback('TAN_Admin:getPlayers', function(players)
        local options = {}
        for _, player in ipairs(players) do
            options[#options + 1] = {
                label = ('[%s] %s'):format(player.id, player.name),
                args = {id = player.id, name = player.name},
                icon = 'user'
            }
        end
        if #options == 0 then options[1] = {label = 'Aucun joueur connecté', icon = 'users-slash'} end

        lib.registerMenu({id = 'tan_admin_players', title = 'Gestion des joueurs', position = Config.MenuPosition, options = options}, function(_, _, args)
            if not args or not args.id then return end
            local target = args.id
            lib.registerMenu({
                id = 'tan_admin_player_actions',
                title = ('[%s] %s'):format(target, args.name),
                position = Config.MenuPosition,
                options = {
                    {label = 'Se téléporter sur lui', icon = 'person-walking-arrow-right'},
                    {label = 'Le téléporter sur moi', icon = 'people-arrows'},
                    {label = 'Freeze / Unfreeze', icon = 'snowflake'},
                    {label = 'Soigner', icon = 'heart-pulse'},
                    {label = 'Ré animer', icon = 'user-plus'},
                    {label = 'Expulser', icon = 'user-xmark'},
                }
            }, function(selected)
                if selected == 1 then TriggerServerEvent('TAN_Admin:gotoPlayer', target)
                elseif selected == 2 then TriggerServerEvent('TAN_Admin:bringPlayer', target)
                elseif selected == 3 then TriggerServerEvent('TAN_Admin:toggleFreeze', target)
                elseif selected == 4 then TriggerServerEvent('TAN_Admin:healPlayer', target)
                elseif selected == 5 then TriggerServerEvent('TAN_Admin:revivePlayer', target)
                elseif selected == 6 then
                    local input = lib.inputDialog('Expulser le joueur', {{type = 'input', label = 'Raison', required = true}})
                    if input then TriggerServerEvent('TAN_Admin:kickPlayer', target, input[1]) end
                end
            end)
            lib.showMenu('tan_admin_player_actions')
        end)
        lib.showMenu('tan_admin_players')
    end)
end

local function openVehicleMenu()
    lib.registerMenu({
        id = 'tan_admin_vehicle', title = 'Gestion des véhicules', position = Config.MenuPosition,
        options = {
            {label = 'Faire apparaître un véhicule', icon = 'car-side'},
            {label = 'Réparer le véhicule', icon = 'screwdriver-wrench'},
            {label = 'Nettoyer le véhicule', icon = 'spray-can-sparkles'},
            {label = 'Retourner le véhicule', icon = 'rotate'},
            {label = 'Amélioration maximale', icon = 'gauge-high'},
            {label = 'Supprimer le véhicule', icon = 'trash'},
        }
    }, function(selected)
        local vehicle = getCurrentVehicle()
        if selected == 1 then
            local input = lib.inputDialog('Faire apparaître un véhicule', {{type = 'input', label = 'Nom du modèle', default = Config.DefaultVehicle, required = true}})
            if input then TriggerServerEvent('TAN_Admin:requestVehicleSpawn', input[1]) end
        elseif vehicle == 0 or not DoesEntityExist(vehicle) then
            notify('Aucun véhicule à proximité.', 'error')
        elseif selected == 2 then
            SetVehicleFixed(vehicle)
            SetVehicleEngineHealth(vehicle, 1000.0)
            SetVehicleBodyHealth(vehicle, 1000.0)
            notify('Véhicule réparé.', 'success')
        elseif selected == 3 then
            SetVehicleDirtLevel(vehicle, 0.0)
            notify('Véhicule nettoyé.', 'success')
        elseif selected == 4 then
            SetEntityRotation(vehicle, 0.0, 0.0, GetEntityHeading(vehicle), 2, true)
            SetVehicleOnGroundProperly(vehicle)
            notify('Véhicule retourné.', 'success')
        elseif selected == 5 then
            SetVehicleModKit(vehicle, 0)
            for modType = 0, 49 do
                local count = GetNumVehicleMods(vehicle, modType)
                if count > 0 then SetVehicleMod(vehicle, modType, count - 1, false) end
            end
            ToggleVehicleMod(vehicle, 18, true)
            SetVehicleTyresCanBurst(vehicle, false)
            notify('Véhicule amélioré.', 'success')
        elseif selected == 6 then
            deleteVehicle(vehicle)
        end
    end)
    lib.showMenu('tan_admin_vehicle')
end

local function openDeveloperMenu()
    lib.registerMenu({
        id = 'tan_admin_dev', title = 'Outils développeur', position = Config.MenuPosition,
        options = {
            {label = 'Copier Vector3', icon = 'copy'},
            {label = 'Copier Vector4', icon = 'copy'},
            {label = 'Copier le heading', icon = 'compass'},
            {label = 'Afficher mes coordonnées', icon = 'location-dot'},
        }
    }, function(selected)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        if selected == 1 then
            lib.setClipboard(('vector3(%.2f, %.2f, %.2f)'):format(coords.x, coords.y, coords.z))
            notify('Vector3 copié.', 'success')
        elseif selected == 2 then
            lib.setClipboard(('vector4(%.2f, %.2f, %.2f, %.2f)'):format(coords.x, coords.y, coords.z, heading))
            notify('Vector4 copié.', 'success')
        elseif selected == 3 then
            lib.setClipboard(('%.2f'):format(heading))
            notify('Heading copié.', 'success')
        elseif selected == 4 then
            notify(('X %.2f | Y %.2f | Z %.2f | H %.2f'):format(coords.x, coords.y, coords.z, heading), 'inform')
        end
    end)
    lib.showMenu('tan_admin_dev')
end


local function openReportActions(report)
    local status = report.claimedBy and ("Pris par " .. (report.claimedName or 'un staff')) or 'En attente'
    lib.registerMenu({
        id = 'tan_admin_report_actions',
        title = ('Report #%s - [%s] %s'):format(report.id, report.playerId, report.playerName),
        position = Config.MenuPosition,
        options = {
            {label = 'Message', description = report.message, icon = 'message'},
            {label = 'Statut', description = status, icon = 'circle-info'},
            {label = 'Prendre en charge', icon = 'hand'},
            {label = 'Répondre au joueur', icon = 'reply'},
            {label = 'Se téléporter sur le joueur', icon = 'location-arrow'},
            {label = 'Téléporter le joueur sur moi', icon = 'people-arrows'},
            {label = 'Fermer le report', icon = 'check'},
        }
    }, function(selected)
        if selected == 3 then
            TriggerServerEvent('TAN_Admin:claimReport', report.id)
        elseif selected == 4 then
            local input = lib.inputDialog(('Répondre au report #%s'):format(report.id), {
                {type = 'textarea', label = 'Message au joueur', required = true, min = 2, max = Config.ReportMaxLength}
            })
            if input then TriggerServerEvent('TAN_Admin:replyReport', report.id, input[1]) end
        elseif selected == 5 then
            TriggerServerEvent('TAN_Admin:gotoReportPlayer', report.id)
        elseif selected == 6 then
            TriggerServerEvent('TAN_Admin:bringReportPlayer', report.id)
        elseif selected == 7 then
            local input = lib.inputDialog(('Fermer le report #%s'):format(report.id), {
                {type = 'input', label = 'Raison de fermeture', default = 'Report traité', required = true, max = 100}
            })
            if input then TriggerServerEvent('TAN_Admin:closeReport', report.id, input[1]) end
        end
    end)
    lib.showMenu('tan_admin_report_actions')
end

local function openReportsMenu()
    ESX.TriggerServerCallback('TAN_Admin:getReports', function(reports)
        local options = {}
        for _, report in ipairs(reports) do
            local status = report.claimedBy and ('Pris par %s'):format(report.claimedName or 'un staff') or 'En attente'
            options[#options + 1] = {
                label = ('#%s | [%s] %s'):format(report.id, report.playerId, report.playerName),
                description = ('%s | %s | %s'):format(report.createdAt or '--:--', status, report.message),
                icon = report.claimedBy and 'user-check' or 'triangle-exclamation',
                args = report
            }
        end
        if #options == 0 then
            options[1] = {label = 'Aucun report ouvert', description = 'Tous les reports ont été traités.', icon = 'check'}
        end

        lib.registerMenu({
            id = 'tan_admin_reports',
            title = ('Reports ouverts : %s'):format(#reports),
            position = Config.MenuPosition,
            options = options
        }, function(_, _, args)
            if args and args.id then openReportActions(args) end
        end)
        lib.showMenu('tan_admin_reports')
    end)
end

local function openMainMenu()
    lib.registerMenu({
        id = 'tan_admin_main', title = 'Menu Administration', position = Config.MenuPosition,
        options = {
            {label = 'Actions personnelles', description = 'Heal, revive, godmode, invisibilité, noclip', icon = 'user-shield'},
            {label = 'Gestion des joueurs', description = 'Téléportation, freeze, heal, revive et kick', icon = 'users-gear'},
            {label = 'Gestion des véhicules', description = 'Spawn, réparation, nettoyage et suppression', icon = 'car'},
            {label = 'Outils développeur', description = 'Coordonnées Vector3, Vector4 et heading', icon = 'code'},
            {label = 'Gestion des reports', description = 'Voir, prendre en charge et fermer les demandes', icon = 'triangle-exclamation'},
        }
    }, function(selected)
        if selected == 1 then openSelfMenu()
        elseif selected == 2 then openPlayersMenu()
        elseif selected == 3 then openVehicleMenu()
        elseif selected == 4 then openDeveloperMenu()
        elseif selected == 5 then openReportsMenu() end
    end)
    lib.showMenu('tan_admin_main')
end

RegisterCommand('menuadmin', function()
    checkAccess(openMainMenu)
end, false)
RegisterKeyMapping('menuadmin', 'Ouvrir le menu administration', 'keyboard', Config.OpenKey)

RegisterCommand('adminnoclip', function()
    checkAccess(function()
        noclipActive = not noclipActive
        local ped = PlayerPedId()
        local entity = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or ped
        SetEntityInvincible(entity, noclipActive or godMode)
        SetEntityCollision(entity, not noclipActive, not noclipActive)
        FreezeEntityPosition(entity, noclipActive)
        SetEntityVisible(ped, not noclipActive and not invisible, false)
        notify(('Noclip %s.'):format(noclipActive and 'activé' or 'désactivé'), noclipActive and 'success' or 'inform')

        if noclipActive then
            CreateThread(function()
                while noclipActive do
                    ped = PlayerPedId()
                    entity = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or ped
                    local coords = GetEntityCoords(entity)
                    local rotation = GetGameplayCamRot(2)
                    local pitch, yaw = math.rad(rotation.x), math.rad(rotation.z)
                    local direction = vector3(-math.sin(yaw) * math.cos(pitch), math.cos(yaw) * math.cos(pitch), math.sin(pitch))
                    local right = vector3(math.cos(yaw), math.sin(yaw), 0.0)
                    local move = vector3(0.0, 0.0, 0.0)
                    if IsControlPressed(0, 32) then move = move + direction end
                    if IsControlPressed(0, 33) then move = move - direction end
                    if IsControlPressed(0, 34) then move = move - right end
                    if IsControlPressed(0, 35) then move = move + right end
                    if IsControlPressed(0, 22) then move = move + vector3(0.0, 0.0, 1.0) end
                    if IsControlPressed(0, 36) then move = move - vector3(0.0, 0.0, 1.0) end
                    if IsControlJustPressed(0, 241) then noclipSpeed = math.min(noclipSpeed + 0.5, Config.MaxVehicleSpeed) end
                    if IsControlJustPressed(0, 242) then noclipSpeed = math.max(noclipSpeed - 0.5, 0.5) end
                    SetEntityVelocity(entity, 0.0, 0.0, 0.0)
                    SetEntityCoordsNoOffset(entity, coords + (move * noclipSpeed), true, true, true)
                    SetEntityHeading(entity, rotation.z)
                    Wait(0)
                end
            end)
        end
    end)
end, false)
RegisterKeyMapping('adminnoclip', 'Activer ou désactiver le noclip', 'keyboard', Config.NoclipKey)

RegisterNetEvent('TAN_Admin:setCoords', function(coords)
    SetPedCoordsKeepVehicle(PlayerPedId(), coords.x, coords.y, coords.z + 1.0)
end)

RegisterNetEvent('TAN_Admin:toggleFreeze', function()
    frozen = not frozen
    FreezeEntityPosition(PlayerPedId(), frozen)
    notify(('Vous avez été %s par un administrateur.'):format(frozen and 'freeze' or 'unfreeze'), 'inform')
end)

RegisterNetEvent('TAN_Admin:heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
    TriggerEvent('esx_basicneeds:resetStatus')
end)

RegisterNetEvent('TAN_Admin:revive', function()
    revivePed()
end)

RegisterNetEvent('TAN_Admin:spawnVehicle', function(modelName)
    local model = joaat(modelName)
    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
        notify('Ce modèle de véhicule est invalide.', 'error')
        return
    end

    lib.requestModel(model, 5000)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    SetPedIntoVehicle(ped, vehicle, -1)
    SetVehicleOnGroundProperly(vehicle)
    SetModelAsNoLongerNeeded(model)
    notify(('Véhicule %s créé.'):format(modelName), 'success')
end)


RegisterCommand(Config.ReportCommand, function()
    local input = lib.inputDialog('Contacter le staff', {
        {
            type = 'textarea',
            label = 'Expliquez votre problème',
            description = 'Donnez suffisamment de détails pour que le staff puisse vous aider.',
            required = true,
            min = 5,
            max = Config.ReportMaxLength
        }
    })
    if input then
        TriggerServerEvent('TAN_Admin:createReport', input[1])
    end
end, false)

RegisterNetEvent('TAN_Admin:reportReply', function(reportId, staffName, message)
    lib.alertDialog({
        header = ('Réponse au report #%s'):format(reportId),
        content = ('**%s :**\n\n%s'):format(staffName, message),
        centered = true,
        cancel = false
    })
end)

RegisterNetEvent('TAN_Admin:reportsUpdated', function()
    -- Le menu est rafraîchi à sa prochaine ouverture afin de ne pas interrompre une action en cours.
end)
