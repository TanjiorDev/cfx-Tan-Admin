
local function setNoclipEntityState(entity, enabled)
    if entity == 0 or not DoesEntityExist(entity) then return end

    SetEntityInvincible(entity, enabled or TAN_Admin.State.godMode)
    SetEntityCollision(entity, not enabled, not enabled)
    FreezeEntityPosition(entity, enabled)
    SetEntityVisible(entity, not enabled, false)
end

RegisterCommand('adminnoclip', function()
    TAN_Admin.CheckAccess(function()
        TAN_Admin.State.noclipActive = not TAN_Admin.State.noclipActive
        local ped = PlayerPedId()

        if TAN_Admin.State.noclipActive then
            TAN_Admin.State.noclipVehicle = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or 0
            local entity = TAN_Admin.State.noclipVehicle ~= 0 and TAN_Admin.State.noclipVehicle or ped

            setNoclipEntityState(entity, true)
            SetEntityVisible(ped, false, false)

            CreateThread(function()
                while TAN_Admin.State.noclipActive do
                    ped = PlayerPedId()
                    local currentVehicle = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or 0
                    entity = currentVehicle ~= 0 and currentVehicle or ped

                    if currentVehicle ~= 0 then
                        TAN_Admin.State.noclipVehicle = currentVehicle
                        SetEntityVisible(currentVehicle, false, false)
                        SetEntityCollision(currentVehicle, false, false)
                        FreezeEntityPosition(currentVehicle, true)
                        SetEntityInvincible(currentVehicle, true)
                    end
                    SetEntityVisible(ped, false, false)

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
                    if IsControlJustPressed(0, 241) then TAN_Admin.State.noclipSpeed = math.min(TAN_Admin.State.noclipSpeed + 0.5, Config.MaxVehicleSpeed) end
                    if IsControlJustPressed(0, 242) then TAN_Admin.State.noclipSpeed = math.max(TAN_Admin.State.noclipSpeed - 0.5, 0.5) end
                    SetEntityVelocity(entity, 0.0, 0.0, 0.0)
                    SetEntityCoordsNoOffset(entity, coords + (move * TAN_Admin.State.noclipSpeed), true, true, true)
                    SetEntityHeading(entity, rotation.z)
                    Wait(0)
                end
            end)
        else
            local currentVehicle = IsPedInAnyVehicle(ped, false) and GetVehiclePedIsIn(ped, false) or 0
            local vehicleToRestore = currentVehicle ~= 0 and currentVehicle or TAN_Admin.State.noclipVehicle

            if vehicleToRestore ~= 0 and DoesEntityExist(vehicleToRestore) then
                SetEntityCollision(vehicleToRestore, true, true)
                FreezeEntityPosition(vehicleToRestore, false)
                SetEntityInvincible(vehicleToRestore, false)
                SetEntityVisible(vehicleToRestore, true, false)
                SetVehicleOnGroundProperly(vehicleToRestore)
            end

            SetEntityCollision(ped, true, true)
            FreezeEntityPosition(ped, false)
            SetEntityInvincible(ped, TAN_Admin.State.godMode)
            SetEntityVisible(ped, not TAN_Admin.State.invisible, false)
            TAN_Admin.State.noclipVehicle = 0
        end

        TAN_Admin.Notify(('Noclip %s.'):format(TAN_Admin.State.noclipActive and 'activé' or 'désactivé'), TAN_Admin.State.noclipActive and 'success' or 'inform')
    end)
end, false)
RegisterKeyMapping('adminnoclip', 'Activer ou désactiver le noclip', 'keyboard', Config.NoclipKey)

