function TAN_Admin.OpenReportActions(report)
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

function TAN_Admin.OpenReportsMenu()
    TAN_Admin.ESX.TriggerServerCallback('TAN_Admin:getReports', function(reports)
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
            if args and args.id then TAN_Admin.OpenReportActions(args) end
        end)
        lib.showMenu('tan_admin_reports')
    end)
end

