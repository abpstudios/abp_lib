---@diagnostic disable: missing-parameter
local settings = abplib.requireFile('@abp_lib/config/noclip')

local noclipActive = false
local noclipEntity = nil
local config = {
    controls = settings.Controls,
    speeds = settings.Speeds,

    offsets = {
        y = 0.5, -- [[How much distance you move forward and backward while the respective button is pressed]]
        z = 0.2, -- [[How much distance you move upward and downward while the respective button is pressed]]
        h = 3, -- [[How much you rotate. ]]
    },

    -- [[Background colour of the buttons. (It may be the standard black on first opening, just re-opening.)]]
    bgR = 30, -- [[Red]]
    bgG = 210, -- [[Green]]
    bgB = 140, -- [[Blue]]
    bgA = 70, -- [[Alpha]]
}

local index = 1 -- [[Used to determine the index of the speeds table.]]
local lastVehicle = nil

local function isAdmin()
    local role = abplib.player.hasPermission(0x128)
    return role
end

local function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

local function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

local function setupScaleform(scaleform)

    local scaleform = RequestScaleformMovie(scaleform)

    while not HasScaleformMovieLoaded(scaleform) do
        Wait(1)
    end

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(5)
    ButtonMessage("Ojo de Saurón")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    Button(GetControlInstructionalButton(2, config.controls.goUp, true))
    ButtonMessage("Arriba")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(2, config.controls.goDown, true))
    ButtonMessage("Abajo")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(1, config.controls.turnRight, true))
    Button(GetControlInstructionalButton(1, config.controls.turnLeft, true))
    ButtonMessage("Derecha / Izquerda")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(1, config.controls.goBackward, true))
    Button(GetControlInstructionalButton(1, config.controls.goForward, true))
    ButtonMessage("Adelante / Atras")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, config.controls.changeSpeed, true))
    ButtonMessage("" .. config.speeds[index].label .. " ")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(config.bgR)
    PushScaleformMovieFunctionParameterInt(config.bgG)
    PushScaleformMovieFunctionParameterInt(config.bgB)
    PushScaleformMovieFunctionParameterInt(config.bgA)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

local buttons = setupScaleform("instructional_buttons")
local currentSpeed = config.speeds[index].speed
local firstLoad = false

abplib.addKeybind({
    name = 'noclip',
    description = 'Staff NoClip',
    defaultKey = 'PAGEDOWN',
    onPressed = function(self)
        abplib.noclip.toggle()
    end,
})

local function ResetPlayerNoClip()
    if not noclipEntity then return end
    SetEntityCollision(noclipEntity, not  noclipActive, not  noclipActive)
    FreezeEntityPosition(noclipEntity,  noclipActive)

    SetEntityVisible(noclipEntity, not  noclipActive, false)
    SetLocalPlayerVisibleLocally(not  noclipActive)
    ResetEntityAlpha(noclipEntity)
end
local function EnableNoClip()
    SetEntityInvincible(PlayerPedId(), not noclipActive)

    while noclipActive do
        local playerPed = PlayerPedId()

        if noclipActive then
            if IsPedInAnyVehicle(playerPed, false) then
                noclipEntity = GetVehiclePedIsIn(playerPed, false)
                SetVehicleRadioEnabled(noclipEntity, not noclipActive)
                lastVehicle = noclipEntity
            else
                if lastVehicle ~= nil then
                    SetEntityCollision(lastVehicle, true, true)
                    ResetEntityAlpha(lastVehicle);
                    SetEntityVisible(lastVehicle, true, false);
                    FreezeEntityPosition(lastVehicle, false)
                    lastVehicle = nil
                end
                noclipEntity = playerPed
            end

            if not firstLoad then
                buttons = setupScaleform("instructional_buttons")
                firstLoad = true
            end

            DrawScaleformMovieFullscreen(buttons)

            local yoff = 0.0
            local zoff = 0.0

            if IsControlJustPressed(1, config.controls.changeSpeed) then
                if index ~= #config.speeds then
                    index = index + 1
                    currentSpeed = config.speeds[index].speed
                else
                    currentSpeed = config.speeds[1].speed
                    index = 1
                end
                setupScaleform("instructional_buttons")
            end

            if IsControlPressed(0, config.controls.goForward) then
                yoff = config.offsets.y
            end

            if IsControlPressed(0, config.controls.goBackward) then
                yoff = -config.offsets.y
            end

            if IsControlPressed(0, config.controls.goUp) or IsDisabledControlPressed(0, config.controls.goUp) then
                zoff = config.offsets.z
            end

            if IsControlPressed(0, config.controls.goDown) then
                zoff = -config.offsets.z
            end

            local newPos = GetOffsetFromEntityInWorldCoords(noclipEntity, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))

            SetEntityVisible(noclipEntity, false, false);
            SetLocalPlayerVisibleLocally(true);
            SetEntityAlpha(noclipEntity, 51, false);

            SetEntityVelocity(noclipEntity, 0.0, 0.0, 0.0)
            SetEntityRotation(noclipEntity, 0.0, 0.0, 0.0, 0, false)
            SetEntityHeading(noclipEntity, GetGameplayCamRelativeHeading())
            SetEntityCoordsNoOffset(noclipEntity, newPos.x, newPos.y, newPos.z, noclipActive, noclipActive, noclipActive)
        end
        
        Wait(3)
    end
end

local function ClearNoClip()
    local playerPed = PlayerPedId()
    SetPedCanRagdollFromPlayerImpact(playerPed, false)
    FreezeEntityPosition(playerPed, false)
    CreateThread(function()
        Wait(2000)
        SetPedCanRagdollFromPlayerImpact(playerPed, true)
    end)

    return true
end


abplib.noclip = {}

---Toggle the noclip state
---@param state any
---@return boolean
abplib.noclip.toggle = function(state)
    local hasPermissions = isAdmin()

    noclipActive = state or not noclipActive

    if not hasPermissions then
        noclipActive = false
    end

    ResetPlayerNoClip()

    if noclipActive then
        EnableNoClip()
        return true
    end

    return ClearNoClip()
end

---Check if the noclip is active
---@return boolean
abplib.noclip.isActive = function()
    return noclipActive
end