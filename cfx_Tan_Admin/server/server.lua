local ESX = exports['es_extended']:getSharedObject()

local function notify(playerId, message, notificationType)
    TriggerClientEvent('ox_lib:notify', playerId, {
        title = 'Administration',
        description = message,
        type = notificationType or 'inform'
    })
end

local function isAllowed(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end

    return Config.AllowedGroups[xPlayer.getGroup()] == true
end

local function validTarget(target)
    target = tonumber(target)
    if not target or not GetPlayerName(target) then return nil end
    return target
end

ESX.RegisterServerCallback('TAN_Admin:getgroup', function(source, cb)
    cb(isAllowed(source))
end)

ESX.RegisterServerCallback('TAN_Admin:getPlayers', function(source, cb)
    if not isAllowed(source) then
        cb({})
        return
    end

    local players = {}
    for _, playerId in ipairs(GetPlayers()) do
        local id = tonumber(playerId)
        players[#players + 1] = {
            id = id,
            name = GetPlayerName(playerId) or ('Joueur %s'):format(playerId)
        }
    end

    table.sort(players, function(a, b) return a.id < b.id end)
    cb(players)
end)

RegisterNetEvent('TAN_Admin:gotoPlayer', function(target)
    local source = source
    if not isAllowed(source) then return end

    target = validTarget(target)
    if not target then
        notify(source, "Le joueur n'existe pas.", 'error')
        return
    end

    local targetPed = GetPlayerPed(target)
    local coords = GetEntityCoords(targetPed)
    TriggerClientEvent('TAN_Admin:setCoords', source, coords)
    notify(source, 'Téléportation effectuée.', 'success')
end)

RegisterNetEvent('TAN_Admin:bringPlayer', function(target)
    local source = source
    if not isAllowed(source) then return end

    target = validTarget(target)
    if not target then
        notify(source, "Le joueur n'existe pas.", 'error')
        return
    end

    local adminPed = GetPlayerPed(source)
    local coords = GetEntityCoords(adminPed)
    TriggerClientEvent('TAN_Admin:setCoords', target, coords)
    notify(source, 'Le joueur a été téléporté sur vous.', 'success')
end)

RegisterNetEvent('TAN_Admin:toggleFreeze', function(target)
    local source = source
    if not isAllowed(source) then return end

    target = validTarget(target)
    if not target then
        notify(source, "Le joueur n'existe pas.", 'error')
        return
    end

    TriggerClientEvent('TAN_Admin:toggleFreeze', target)
    notify(source, 'État de freeze modifié.', 'success')
end)

RegisterNetEvent('TAN_Admin:healPlayer', function(target)
    local source = source
    if not isAllowed(source) then return end

    target = validTarget(target)
    if not target then
        notify(source, "Le joueur n'existe pas.", 'error')
        return
    end

    TriggerClientEvent('TAN_Admin:heal', target)
    notify(source, 'Joueur soigné.', 'success')
end)

RegisterNetEvent('TAN_Admin:revivePlayer', function(target)
    local source = source
    if not isAllowed(source) then return end

    target = validTarget(target)
    if not target then
        notify(source, "Le joueur n'existe pas.", 'error')
        return
    end

    TriggerClientEvent('TAN_Admin:revive', target)
    notify(source, 'Joueur réanimé.', 'success')
end)

RegisterNetEvent('TAN_Admin:kickPlayer', function(target, reason)
    local source = source
    if not isAllowed(source) then return end

    target = validTarget(target)
    if not target then
        notify(source, "Le joueur n'existe pas.", 'error')
        return
    end

    reason = tostring(reason or 'Expulsé par un administrateur')
    DropPlayer(target, reason)
    notify(source, 'Joueur expulsé.', 'success')
end)

RegisterNetEvent('TAN_Admin:requestVehicleSpawn', function(model)
    local source = source
    if not isAllowed(source) then return end

    model = tostring(model or ''):lower():gsub('[^%w_]', '')
    if model == '' or #model > 40 then
        notify(source, 'Nom de véhicule invalide.', 'error')
        return
    end

    TriggerClientEvent('TAN_Admin:spawnVehicle', source, model)
end)

-- =========================
-- Système de reports
-- =========================
local reports = {}
local nextReportId = 1
local reportCooldowns = {}

local function getOpenReports()
    local list = {}
    for _, report in pairs(reports) do
        list[#list + 1] = report
    end
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

local function sendReportRefresh()
    for _, playerId in ipairs(GetPlayers()) do
        local id = tonumber(playerId)
        if isAllowed(id) then
            TriggerClientEvent('TAN_Admin:reportsUpdated', id)
        end
    end
end

ESX.RegisterServerCallback('TAN_Admin:getReports', function(source, cb)
    if not isAllowed(source) then
        cb({})
        return
    end
    cb(getOpenReports())
end)

RegisterNetEvent('TAN_Admin:createReport', function(message)
    local source = source
    local now = os.time()
    local maxLength = tonumber(Config.ReportMaxLength) or 300
    local cooldown = tonumber(Config.ReportCooldown) or 60

    message = tostring(message or ''):gsub('^%s+', ''):gsub('%s+$', '')
    if message == '' then
        notify(source, 'Votre report ne peut pas être vide.', 'error')
        return
    end
    if #message > maxLength then
        notify(source, ('Votre report est trop long (%s caractères maximum).'):format(maxLength), 'error')
        return
    end
    if reportCooldowns[source] and now - reportCooldowns[source] < cooldown then
        local remaining = cooldown - (now - reportCooldowns[source])
        notify(source, ('Veuillez patienter encore %s seconde(s).'):format(remaining), 'error')
        return
    end

    for _, report in pairs(reports) do
        if report.playerId == source then
            notify(source, 'Vous avez déjà un report ouvert.', 'error')
            return
        end
    end

    local reportId = nextReportId
    nextReportId = nextReportId + 1
    reportCooldowns[source] = now
    reports[reportId] = {
        id = reportId,
        playerId = source,
        playerName = GetPlayerName(source) or ('Joueur %s'):format(source),
        message = message,
        createdAt = os.date('%H:%M'),
        claimedBy = nil,
        claimedName = nil
    }

    notify(source, ('Votre report #%s a été envoyé au staff.'):format(reportId), 'success')
    for _, playerId in ipairs(GetPlayers()) do
        local id = tonumber(playerId)
        if isAllowed(id) then
            notify(id, ('Nouveau report #%s de [%s] %s.'):format(reportId, source, reports[reportId].playerName), 'inform')
        end
    end
    sendReportRefresh()
end)

RegisterNetEvent('TAN_Admin:claimReport', function(reportId)
    local source = source
    if not isAllowed(source) then return end
    reportId = tonumber(reportId)
    local report = reportId and reports[reportId]
    if not report then
        notify(source, "Ce report n'existe plus.", 'error')
        return
    end
    if report.claimedBy and report.claimedBy ~= source then
        notify(source, ('Ce report est déjà pris par %s.'):format(report.claimedName or 'un staff'), 'error')
        return
    end

    report.claimedBy = source
    report.claimedName = GetPlayerName(source) or ('Staff %s'):format(source)
    notify(source, ('Vous avez pris en charge le report #%s.'):format(reportId), 'success')
    if GetPlayerName(report.playerId) then
        notify(report.playerId, ('Votre report #%s est pris en charge par %s.'):format(reportId, report.claimedName), 'inform')
    end
    sendReportRefresh()
end)

RegisterNetEvent('TAN_Admin:replyReport', function(reportId, message)
    local source = source
    if not isAllowed(source) then return end
    reportId = tonumber(reportId)
    local report = reportId and reports[reportId]
    if not report then
        notify(source, "Ce report n'existe plus.", 'error')
        return
    end
    message = tostring(message or ''):gsub('^%s+', ''):gsub('%s+$', '')
    if message == '' then return end
    if not GetPlayerName(report.playerId) then
        notify(source, "Le joueur n'est plus connecté.", 'error')
        return
    end
    TriggerClientEvent('TAN_Admin:reportReply', report.playerId, reportId, GetPlayerName(source) or 'Staff', message)
    notify(source, 'Réponse envoyée au joueur.', 'success')
end)

RegisterNetEvent('TAN_Admin:gotoReportPlayer', function(reportId)
    local source = source
    if not isAllowed(source) then return end
    local report = reports[tonumber(reportId)]
    if not report or not GetPlayerName(report.playerId) then
        notify(source, "Le joueur n'est plus connecté.", 'error')
        return
    end
    local coords = GetEntityCoords(GetPlayerPed(report.playerId))
    TriggerClientEvent('TAN_Admin:setCoords', source, coords)
end)

RegisterNetEvent('TAN_Admin:bringReportPlayer', function(reportId)
    local source = source
    if not isAllowed(source) then return end
    local report = reports[tonumber(reportId)]
    if not report or not GetPlayerName(report.playerId) then
        notify(source, "Le joueur n'est plus connecté.", 'error')
        return
    end
    local coords = GetEntityCoords(GetPlayerPed(source))
    TriggerClientEvent('TAN_Admin:setCoords', report.playerId, coords)
end)

RegisterNetEvent('TAN_Admin:closeReport', function(reportId, reason)
    local source = source
    if not isAllowed(source) then return end
    reportId = tonumber(reportId)
    local report = reportId and reports[reportId]
    if not report then
        notify(source, "Ce report n'existe plus.", 'error')
        return
    end

    reason = tostring(reason or 'Report traité')
    if GetPlayerName(report.playerId) then
        notify(report.playerId, ('Votre report #%s a été fermé : %s'):format(reportId, reason), 'success')
    end
    reports[reportId] = nil
    notify(source, ('Report #%s fermé.'):format(reportId), 'success')
    sendReportRefresh()
end)

AddEventHandler('playerDropped', function()
    local source = source
    reportCooldowns[source] = nil
    local changed = false
    for id, report in pairs(reports) do
        if report.playerId == source then
            reports[id] = nil
            changed = true
        elseif report.claimedBy == source then
            report.claimedBy = nil
            report.claimedName = nil
            changed = true
        end
    end
    if changed then sendReportRefresh() end
end)
