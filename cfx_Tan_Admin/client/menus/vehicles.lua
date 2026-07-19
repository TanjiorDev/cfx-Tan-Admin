function TAN_Admin.OpenVehicleMenu()
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
        local vehicle = TAN_Admin.GetCurrentVehicle()
        if selected == 1 then
            local vehicleOptions = {
                {value = '__manual__', label = 'Saisir un modèle manuellement'}
            }

            for _, vehicleData in ipairs(Config.VehicleList or {}) do
                vehicleOptions[#vehicleOptions + 1] = {
                    value = vehicleData.model,
                    label = vehicleData.label or vehicleData.model
                }
            end

            local input = lib.inputDialog('Faire apparaître un véhicule', {
                {
                    type = 'select',
                    label = 'Choisir un véhicule',
                    description = 'Sélectionnez un véhicule dans la liste.',
                    options = vehicleOptions,
                    default = Config.DefaultVehicle,
                    searchable = true,
                    required = true
                }
            })

            if not input then return end

            local modelName = input[1]
            if modelName == '__manual__' then
                local manualInput = lib.inputDialog('Modèle personnalisé', {
                    {
                        type = 'input',
                        label = 'Nom du modèle',
                        description = 'Exemple : sultan, adder, police',
                        default = Config.DefaultVehicle,
                        required = true
                    }
                })

                if not manualInput then return end
                modelName = manualInput[1]
            end

            TriggerServerEvent('TAN_Admin:requestVehicleSpawn', modelName)
        elseif vehicle == 0 or not DoesEntityExist(vehicle) then
            TAN_Admin.Notify('Aucun véhicule à proximité.', 'error')
        elseif selected == 2 then
            SetVehicleFixed(vehicle)
            SetVehicleEngineHealth(vehicle, 1000.0)
            SetVehicleBodyHealth(vehicle, 1000.0)
            TAN_Admin.Notify('Véhicule réparé.', 'success')
        elseif selected == 3 then
            SetVehicleDirtLevel(vehicle, 0.0)
            TAN_Admin.Notify('Véhicule nettoyé.', 'success')
        elseif selected == 4 then
            SetEntityRotation(vehicle, 0.0, 0.0, GetEntityHeading(vehicle), 2, true)
            SetVehicleOnGroundProperly(vehicle)
            TAN_Admin.Notify('Véhicule retourné.', 'success')
        elseif selected == 5 then
            SetVehicleModKit(vehicle, 0)
            for modType = 0, 49 do
                local count = GetNumVehicleMods(vehicle, modType)
                if count > 0 then SetVehicleMod(vehicle, modType, count - 1, false) end
            end
            ToggleVehicleMod(vehicle, 18, true)
            SetVehicleTyresCanBurst(vehicle, false)
            TAN_Admin.Notify('Véhicule amélioré.', 'success')
        elseif selected == 6 then
            TAN_Admin.DeleteVehicle(vehicle)
        end
    end)
    lib.showMenu('tan_admin_vehicle')
end
