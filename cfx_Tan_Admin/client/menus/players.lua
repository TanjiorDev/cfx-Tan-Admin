function TAN_Admin.OpenPlayersMenu()
    TAN_Admin.ESX.TriggerServerCallback('TAN_Admin:getPlayers', function(players)
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

