function TAN_Admin.OpenDeveloperMenu()
    lib.registerMenu({
        id = 'tan_admin_dev', title = 'Outils développeur', position = Config.MenuPosition,
        options = {
            {label = 'Copier Vector3', icon = 'copy'},
            {label = 'Copier Vector4', icon = 'copy'},
            {label = 'Copier le heading', icon = 'compass'},
            {label = TAN_Admin.State.coordinatesVisible and 'Masquer mes coordonnées' or 'Afficher mes coordonnées', icon = 'location-dot'},
        }
    }, function(selected)
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        if selected == 1 then
            lib.setClipboard(('vector3(%.2f, %.2f, %.2f)'):format(coords.x, coords.y, coords.z))
            TAN_Admin.Notify('Vector3 copié.', 'success')
        elseif selected == 2 then
            lib.setClipboard(('vector4(%.2f, %.2f, %.2f, %.2f)'):format(coords.x, coords.y, coords.z, heading))
            TAN_Admin.Notify('Vector4 copié.', 'success')
        elseif selected == 3 then
            lib.setClipboard(('%.2f'):format(heading))
            TAN_Admin.Notify('Heading copié.', 'success')
        elseif selected == 4 then
            TAN_Admin.ToggleCoordinatesDisplay()
            TAN_Admin.OpenDeveloperMenu()
        end
    end)
    lib.showMenu('tan_admin_dev')
end
