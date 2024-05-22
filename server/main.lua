-- Vars
QBCore = nil
Fly = {}
Fly.Dimension = 0

-- Events
TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)
RegisterServerEvent('dm_flylicense:server:checkBucket', function()
    local pid = source
    local Player = QBCore.Functions.GetPlayer(pid)
    if GetPlayerRoutingBucket(pid) == 0 then
        Fly.Dimension = Fly.Dimension+1
        SetPlayerRoutingBucket(pid, tonumber(Fly.Dimension))
        TriggerClientEvent('dm_flylicense:auth', pid)
        exports['ghmattimysql']:execute('UPDATE players SET fly_attempt = @fa WHERE citizenid = @id', {['@id'] = Player.PlayerData.citizenid, ['@fa'] = 1})
    else
        Player.showNotification("Ya estás haciendo una prueba o estás en otra dimensión diferente a la 0", 5000)
    end
end)

RegisterServerEvent('dm_flylicense:server:returnto0', function()
    local pid = source
    SetPlayerRoutingBucket(pid, tonumber(0))
end)

RegisterServerEvent('dm_flylicense:removeFlyLicense', function()
    local pid = source
    local Player = QBCore.Functions.GetPlayer(pid)
    exports['ghmattimysql']:execute('UPDATE players SET fly_attempt = @fa WHERE citizenid = @id', {['@id'] = Player.PlayerData.citizenid, ['@fa'] = 0})
end)

-- Callbacks
QBCore.Functions.CreateCallback('dm_flylicense:checkAttemptsMoney', function(pid, cb)
    local Player = QBCore.Functions.GetPlayer(pid)
    local Player_money = Player.PlayerData.money.bank
    if Player_money >= 1000 then
        exports['ghmattimysql']:execute('SELECT * FROM players WHERE citizenid = @id', {['@id'] = Player.PlayerData.citizenid}, function(result)
            if result[1].fly_attempt == 1 then
                cb(true, false)
            else
                Player.Functions.RemoveMoney('bank',1000)
                cb(true, true)
            end
        end)
    else
        cb(false)
    end
end)

-- Command
RegisterCommand('getbucket', function(pid)
    print("Estás en la dimensión: "..GetPlayerRoutingBucket(pid))
end)

RegisterCommand('setbucket', function(pid)
    SetPlayerRoutingBucket(pid, tonumber(0))
end)