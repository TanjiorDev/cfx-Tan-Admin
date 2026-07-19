local function getCoordinatesDisplayPosition()
    local position = Config.CoordinatesPosition or 'top-center'

    if position == 'top-left' then
        return 0.16, 0.028
    elseif position == 'top-right' then
        return 0.84, 0.028
    elseif position == 'bottom-center' then
        return 0.50, 0.94
    elseif position == 'bottom-left' then
        return 0.16, 0.94
    elseif position == 'bottom-right' then
        return 0.84, 0.94
    end

    return 0.50, 0.028
end

local function drawCoordinatesText(text)
    local x, y = getCoordinatesDisplayPosition()

    DrawRect(x, y, 0.215, 0.042, 20, 20, 24, 220)

    SetTextFont(4)
    SetTextScale(0.0, 0.36)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y - 0.012)
end

CreateThread(function()
    while true do
        if TAN_Admin.State.coordinatesVisible then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)

            drawCoordinatesText(
                ('X: %.2f | Y: %.2f | Z: %.2f | H: %.2f'):format(
                    coords.x,
                    coords.y,
                    coords.z,
                    heading
                )
            )

            Wait(0)
        else
            Wait(500)
        end
    end
end)

function TAN_Admin.ToggleCoordinatesDisplay()
    TAN_Admin.State.coordinatesVisible = not TAN_Admin.State.coordinatesVisible

    if TAN_Admin.State.coordinatesVisible then
        TAN_Admin.Notify('Affichage des coordonnées activé.', 'success')
    else
        TAN_Admin.Notify('Affichage des coordonnées désactivé.', 'inform')
    end
end

