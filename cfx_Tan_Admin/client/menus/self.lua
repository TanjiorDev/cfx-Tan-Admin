function TAN_Admin.OpenSelfMenu()
    lib.registerMenu({
        id = 'tan_admin_self',
        title = 'Actions personnelles',
        position = Config.MenuPosition,

        options = {
            {
                label = 'Me soigner',
                icon = 'heart-pulse'
            },
            {
                label = 'Me réanimer',
                icon = 'user-plus'
            },
            {
                label = TAN_Admin.State.godMode
                    and 'Désactiver le GodMode'
                    or 'Activer le GodMode',
                icon = 'shield-halved'
            },
            {
                label = TAN_Admin.State.invisible
                    and 'Redevenir visible'
                    or 'Devenir invisible',
                icon = 'eye-slash'
            },
            {
                label = 'Téléportation au marqueur',
                icon = 'location-arrow'
            },
            {
                label = TAN_Admin.State.noclipActive
                    and 'Désactiver le noclip'
                    or 'Activer le noclip',
                icon = 'person-flying'
            }
        }
    }, function(selected, scrollIndex, args)
        local ped = PlayerPedId()

        if selected == 1 then
            SetEntityHealth(ped, GetEntityMaxHealth(ped))
            ClearPedBloodDamage(ped)

            TriggerEvent('esx_basicneeds:resetStatus')

            TAN_Admin.Notify(
                'Vous avez été soigné.',
                'success'
            )

        elseif selected == 2 then
            TAN_Admin.RevivePed()

            TAN_Admin.Notify(
                'Vous avez été réanimé.',
                'success'
            )

        elseif selected == 3 then
            TAN_Admin.State.godMode = not TAN_Admin.State.godMode

            SetEntityInvincible(
                ped,
                TAN_Admin.State.godMode
            )

            TAN_Admin.Notify(
                ('GodMode %s.'):format(
                    TAN_Admin.State.godMode
                        and 'activé'
                        or 'désactivé'
                ),
                TAN_Admin.State.godMode
                    and 'success'
                    or 'inform'
            )

            TAN_Admin.OpenSelfMenu()

        elseif selected == 4 then
            TAN_Admin.State.invisible = not TAN_Admin.State.invisible

            SetEntityVisible(
                ped,
                not TAN_Admin.State.invisible,
                false
            )

            TAN_Admin.Notify(
                ('Invisibilité %s.'):format(
                    TAN_Admin.State.invisible
                        and 'activée'
                        or 'désactivée'
                ),
                TAN_Admin.State.invisible
                    and 'success'
                    or 'inform'
            )

            TAN_Admin.OpenSelfMenu()

        elseif selected == 5 then
            local blip = GetFirstBlipInfoId(8)

            if not DoesBlipExist(blip) then
                TAN_Admin.Notify(
                    "Vous n'avez pas placé de marqueur.",
                    'error'
                )

                return
            end

            local coords = GetBlipInfoIdCoord(blip)
            local found = false
            local groundZ = 0.0

            SetPedCoordsKeepVehicle(
                ped,
                coords.x,
                coords.y,
                1000.0
            )

            for height = 1000, 0, -25 do
                SetPedCoordsKeepVehicle(
                    ped,
                    coords.x,
                    coords.y,
                    height + 0.0
                )

                RequestCollisionAtCoord(
                    coords.x,
                    coords.y,
                    height + 0.0
                )

                Wait(10)

                found, groundZ = GetGroundZFor_3dCoord(
                    coords.x,
                    coords.y,
                    height + 0.0,
                    false
                )

                if found then
                    break
                end
            end

            SetPedCoordsKeepVehicle(
                ped,
                coords.x,
                coords.y,
                found and groundZ + 1.0 or coords.z
            )

            TAN_Admin.Notify(
                'Téléportation effectuée.',
                'success'
            )

        elseif selected == 6 then
            ExecuteCommand('adminnoclip')

            Wait(50)

            TAN_Admin.OpenSelfMenu()
        end
    end)

    lib.showMenu('tan_admin_self')
end