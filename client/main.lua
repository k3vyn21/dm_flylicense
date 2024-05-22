-- Vars
QBCore = nil
Fly = {}
Fly.CurrentCheckpoint = 0

-- Threads
CreateThread(function()
    while QBCore == nil do
        TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
        Wait(0)
    end
    blip = AddBlipForCoord(-1155.20, -2714.97, 18.887)
    SetBlipSprite(blip, 582)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.7)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Escuela de vuelo")
    EndTextCommandSetBlipName(blip)
    Fly.SpawnNPC(Config.FlyLicense.FlyNpc.model, Config.FlyLicense.FlyNpc.coords)
end)

-- Events
RegisterNetEvent('dm_flylicense:client:startTest', function()
    QBCore.Functions.TriggerCallback('dm_flylicense:checkAttemptsMoney', function(has_money, attempts)
        if has_money and attempts then
            TriggerServerEvent('dm_flylicense:server:checkBucket')
        else
            QBCore.Functions.Notify("No tienes suficiente dinero o no tienes más intentos")
        end
    end)
end)

RegisterNetEvent('dm_flylicense:auth', function()
    Fly.SetCam()
    Fly.MissionText('Bienvenido a la ~b~Escuela de vuelo~w~, tendrás que pasar unas ~y~pruebas.', 4500)
    PlaySoundFrontend(-1, "BASE_JUMP_PASSED", "HUD_AWARDS", 1)
    Wait(4500)
    Fly.MissionText('Una vez ~y~completes~w~ todas las pruebas sin ~r~fallo~w~, podrás comprar la ~g~licencia de vuelo.', 4500)
    PlaySoundFrontend(-1, 'Highlight_Cancel','DLC_HEIST_PLANNING_BOARD_SOUNDS', 1)
    Wait(4500)
    Fly.MissionText('¡Buena ~g~suerte~w~!', 2500)
    PlaySoundFrontend(-1, 'Highlight_Cancel','DLC_HEIST_PLANNING_BOARD_SOUNDS', 1)
    Fly.CloseCam()
    Fly.StartTest()
end)

-- Functions

Fly.SpawnNPC = function(modelo, x,y,z,h)
    hash = GetHashKey(modelo)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(1)
    end
    crearNPC = CreatePed(5, hash, x,y,z,h, false, true)
    FreezeEntityPosition(crearNPC, true)
    SetEntityInvincible(crearNPC, true)
    SetBlockingOfNonTemporaryEvents(crearNPC, true)
end

Fly.MissionText = function(text, time)
    ClearPrints()
    SetTextEntry_2("STRING")
    AddTextComponentString(text)
    DrawSubtitleTimed(time, 1)
end

Fly.StartTest = function()
    local Player = PlayerPedId()
    RequestModel(Config.FlyLicense.Vehicle.model)
    while not HasModelLoaded(Config.FlyLicense.Vehicle.model) do
        Wait(0)
    end
    Fly.Plane = CreateVehicle(GetHashKey(Config.FlyLicense.Vehicle.model), Config.FlyLicense.Vehicle.spawn, false, true)
    TaskWarpPedIntoVehicle(Player, Fly.Plane, -1)
    exports['LegacyFuel']:SetFuel(Fly.Plane, 100)
    CreateThread(function()
        while true do
            local Player = PlayerPedId()
            local pCoords = GetEntityCoords(Player)    
            if Fly.CurrentCheckpoint == 0 then
                Fly.CurrentCheckpoint = 1
                CCID = CreateCheckpoint(37, Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint].x, Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint].y, Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint].z, Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint+1].x, Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint+1].y, Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint+1].z, 25.0, 251, 186, 35, 100, false)
                Fly.Blip = AddBlipForCoord(Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint].xyz)
                SetBlipRoute(Fly.Blip, true)
                SendNUIMessage({
                    isReady = true,
                    text = "Checkpoint: 1/23<br>Pulsa E para tomar el checkpoint"
                })
            end
            if #(pCoords - vector3(Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint].xyz)) < 25 then
                if IsControlJustPressed(0, 38) then
                    RemoveBlip(Fly.Blip)
                    Fly.CurrentCheckpoint = Fly.CurrentCheckpoint + 1
                    DeleteCheckpoint(CCID)
                    if Fly.CurrentCheckpoint == 23 then
                        Fly.CurrentCheckpoint = 0
                        DeleteVehicle(Fly.Plane)
                        DeleteCheckpoint(nextCheckpoint)
                        SetEntityCoords(Player, vector3(-1154.72, -2717.10, 19.887))
                        SendNUIMessage({
                            isReady = false
                        })
                        TriggerServerEvent('dm_flylicense:server:returnto0')
                        break
                    end
                    if nextCheckpoint ~= nil then
                        DeleteCheckpoint(nextCheckpoint)
                    end
                    SendNUIMessage({
                        isReady = true,
                        text = "Checkpoint: "..Fly.CurrentCheckpoint.."/23<br>Pulsa E para tomar el checkpoint"
                    })
                    nextCheckpoint = CreateCheckpoint(37, Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint].x, Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint].y, Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint].z, Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint+1].x, Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint+1].y, Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint+1].z, 25.0, 251, 186, 35, 100, false)
                    Fly.Blip = AddBlipForCoord(Config.FlyLicense.Checkpoints[Fly.CurrentCheckpoint].xyz)
                    SetBlipRoute(Fly.Blip, true)
                end
            end
            if IsEntityDead(PlayerPedId()) then
                QBCore.Functions.Notify('Has muerto por lo tanto no recibiras tu licencia de vuelo y tendrás que comprar el test de nuevo.')
                Fly.CurrentCheckpoint = 0
                DeleteVehicle(Fly.Plane)
                DeleteCheckpoint(nextCheckpoint)
                SetEntityCoords(Player, vector3(-1154.72, -2717.10, 19.887))
                SendNUIMessage({
                    isReady = false
                })
                RemoveBlip(Fly.Blip)
                TriggerServerEvent('dm_flylicense:server:returnto0')
                TriggerServerEvent('dm_flylicense:removeFlyLicense')
                break
            end
            Wait(0)
        end
    end)
end

Fly.SetCam = function()
    ClearFocus()
    local Player = PlayerPedId()
    cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', -1152.03, -2714.03, 47.738, 0, 0, 0, 90)
    camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", -1152.03, -2714.03, 47.738, 116.45, 0, 0, 75.00, false, 0)
    PointCamAtCoord(camera, -1173.38, -2727.86, 46.794)
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 500, true, true)
end

Fly.CloseCam = function()
    ClearFocus()
    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cam, false)
    cam = nil
end