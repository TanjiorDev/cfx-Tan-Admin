TAN_Admin = TAN_Admin or {}
TAN_Admin.ESX = exports['es_extended']:getSharedObject()
TAN_Admin.State = {
    noclipActive = false,
    noclipSpeed = 1.0,
    noclipVehicle = 0,
    godMode = false,
    invisible = false,
    frozen = false,
    coordinatesVisible = false,
    staffDuty = false,
    originalAppearance = nil,
}

function TAN_Admin.Notify(message, notificationType)
    lib.notify({
        title = 'Administration',
        description = message,
        type = notificationType or 'inform'
    })
end

function TAN_Admin.CheckAccess(callback)
    TAN_Admin.ESX.TriggerServerCallback('TAN_Admin:getgroup', function(access)
        if not access then
            TAN_Admin.Notify("Vous n'avez pas la permission.", 'error')
            return
        end
        callback()
    end)
end

function TAN_Admin.RevivePed()
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

function TAN_Admin.GetCurrentVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        vehicle = GetClosestVehicle(GetEntityCoords(ped), 5.0, 0, 71)
    end
    return vehicle
end

function TAN_Admin.DeleteVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        TAN_Admin.Notify('Aucun véhicule à proximité.', 'error')
        return
    end

    NetworkRequestControlOfEntity(vehicle)
    local timeout = GetGameTimer() + 1500
    while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < timeout do Wait(0) end
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
    if DoesEntityExist(vehicle) then DeleteEntity(vehicle) end
    TAN_Admin.Notify('Véhicule supprimé.', 'success')
end
