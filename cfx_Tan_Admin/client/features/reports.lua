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


