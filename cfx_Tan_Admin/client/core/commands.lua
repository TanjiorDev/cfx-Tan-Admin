RegisterCommand('menuadmin', function()
    TAN_Admin.CheckAccess(TAN_Admin.OpenMainMenu)
end, false)

RegisterKeyMapping('menuadmin', 'Ouvrir le menu administration', 'keyboard', Config.OpenKey)
