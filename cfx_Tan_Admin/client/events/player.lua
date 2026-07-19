RegisterNetEvent('TAN_Admin:setCoords', function(coords)
    SetPedCoordsKeepVehicle(PlayerPedId(), coords.x, coords.y, coords.z + 1.0)
end)

RegisterNetEvent('TAN_Admin:toggleFreeze', function()
    TAN_Admin.State.frozen = not TAN_Admin.State.frozen
    FreezeEntityPosition(PlayerPedId(), TAN_Admin.State.frozen)
    TAN_Admin.Notify(('Vous avez été %s par un administrateur.'):format(TAN_Admin.State.frozen and 'freeze' or 'unfreeze'), 'inform')
end)

RegisterNetEvent('TAN_Admin:heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
    TriggerEvent('esx_basicneeds:resetStatus')
end)

RegisterNetEvent('TAN_Admin:revive', function()
    TAN_Admin.RevivePed()
end)

RegisterNetEvent('TAN_Admin:spawnVehicle', function(modelName)
    local model = joaat(modelName)
    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then
        TAN_Admin.Notify('Ce modèle de véhicule est invalide.', 'error')
        return
    end

    lib.requestModel(model, 5000)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    SetPedIntoVehicle(ped, vehicle, -1)
    SetVehicleOnGroundProperly(vehicle)
    SetModelAsNoLongerNeeded(model)
    TAN_Admin.Notify(('Véhicule %s créé.'):format(modelName), 'success')
end)


