-- Gestion du service et de la tenue staff avec illenium-appearance.
-- L'apparence complète du joueur est sauvegardée avant d'appliquer uniquement
-- les composants et accessoires de la tenue staff.

TAN_Admin.State.staffDuty = TAN_Admin.State.staffDuty or false
TAN_Admin.State.originalAppearance = TAN_Admin.State.originalAppearance or nil

local APPEARANCE_RESOURCE = 'illenium-appearance'
local MALE_MODEL = joaat('mp_m_freemode_01')
local FEMALE_MODEL = joaat('mp_f_freemode_01')

local function isAppearanceReady()
    return GetResourceState(APPEARANCE_RESOURCE) == 'started'
end

local function deepCopy(data)
    if type(data) ~= 'table' then return data end

    local copy = {}
    for key, value in pairs(data) do
        copy[deepCopy(key)] = deepCopy(value)
    end
    return copy
end

local function getStaffOutfit(ped)
    local model = GetEntityModel(ped)

    if model == MALE_MODEL then
        return Config.StaffOutfit.male
    elseif model == FEMALE_MODEL then
        return Config.StaffOutfit.female
    end

    return nil
end

local function restoreOriginalAppearance(showNotification)
    local appearance = TAN_Admin.State.originalAppearance
    if not appearance or not isAppearanceReady() then return false end

    exports[APPEARANCE_RESOURCE]:setPedAppearance(PlayerPedId(), deepCopy(appearance))

    if showNotification then
        TAN_Admin.Notify("Vous avez quitté le service. Votre apparence d'origine a été restaurée.", 'inform')
    end

    return true
end

function TAN_Admin.EnableStaffDuty(callback)
    if TAN_Admin.State.staffDuty then
        if callback then callback(true) end
        return
    end

    if not isAppearanceReady() then
        TAN_Admin.Notify("La ressource illenium-appearance n'est pas démarrée.", 'error')
        if callback then callback(false) end
        return
    end

    local ped = PlayerPedId()
    local outfit = getStaffOutfit(ped)

    if not outfit then
        TAN_Admin.Notify("La tenue staff fonctionne uniquement avec un personnage freemode homme ou femme.", 'error')
        if callback then callback(false) end
        return
    end

    local currentAppearance = exports[APPEARANCE_RESOURCE]:getPedAppearance(ped)
    if not currentAppearance then
        TAN_Admin.Notify("Impossible de récupérer votre apparence actuelle.", 'error')
        if callback then callback(false) end
        return
    end

    TAN_Admin.State.originalAppearance = deepCopy(currentAppearance)

    if outfit.components then
        exports[APPEARANCE_RESOURCE]:setPedComponents(ped, deepCopy(outfit.components))
    end

    if outfit.props then
        exports[APPEARANCE_RESOURCE]:setPedProps(ped, deepCopy(outfit.props))
    end

    TAN_Admin.State.staffDuty = true
    TAN_Admin.Notify('Vous êtes maintenant en service avec la tenue staff.', 'success')

    if callback then callback(true) end
end

function TAN_Admin.DisableStaffDuty(callback)
    if not TAN_Admin.State.staffDuty then
        if callback then callback(true) end
        return
    end

    if not isAppearanceReady() then
        TAN_Admin.Notify("La ressource illenium-appearance n'est pas démarrée.", 'error')
        if callback then callback(false) end
        return
    end

    local restored = restoreOriginalAppearance(true)
    if not restored then
        TAN_Admin.Notify("Impossible de restaurer votre apparence d'origine.", 'error')
        if callback then callback(false) end
        return
    end

    TAN_Admin.State.staffDuty = false
    TAN_Admin.State.originalAppearance = nil

    if callback then callback(true) end
end

function TAN_Admin.ToggleStaffDuty(enabled, callback)
    if enabled then
        TAN_Admin.EnableStaffDuty(callback)
    else
        TAN_Admin.DisableStaffDuty(callback)
    end
end

-- Restaure la tenue civile si la ressource admin est arrêtée pendant le service.
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    if TAN_Admin.State.staffDuty then
        restoreOriginalAppearance(false)
    end
end)
