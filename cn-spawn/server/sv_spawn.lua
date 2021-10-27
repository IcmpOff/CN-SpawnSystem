ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function Login.decode(tablestring)
    if tablestring == nil or tablestring == "" then
        return {}
    else
        return json.decode(tablestring)
    end
end

RegisterServerEvent("login:getCharModels")
AddEventHandler("login:getCharModels", function(charlist,isReset)
    local src = source
    local char

    local list = ""
    for i=1,#charlist do
        if i == #charlist then
            list = list..charlist[i]
        else
            list = list..charlist[i]..","
        end
    end

    if charlist == nil or json.encode(charlist) == "[]" then
        TriggerClientEvent("login:CreatePlayerCharacterPeds", src, nil, isReset)
        return
    end

    MySQL.Async.fetchAll("SELECT cc.*, cf.*, ct.* FROM users_face cf LEFT JOIN users_current cc on cc.cid = cf.cid LEFT JOIN users_tattoos ct on ct.cid = cf.cid WHERE cf.cid IN ("..list..")",{},function(result)
        if result then
            local temp_data = {}

            for k,v in pairs(result) do
                temp_data[v.cid] = {
                    model = v.model,
                    drawables = Login.decode(v.drawables),
                    props = Login.decode(v.props),
                    drawtextures = Login.decode(v.drawtextures),
                    proptextures = Login.decode(v.proptextures),
                    hairColor = Login.decode(v.hairColor),
                    headBlend = Login.decode(v.headBlend),
                    headOverlay = Login.decode(v.headOverlay),
                    headStructure = Login.decode(v.headStructure),
                    tattoos = Login.decode(v.tattoos),
                }
            end

            for i=1,#charlist do
                if temp_data[charlist[i]] == nil then
                    temp_data[charlist[i]] = nil
                end
            end

            TriggerClientEvent("login:CreatePlayerCharacterPeds",src,temp_data,isReset)
        end
    end)
end)

RegisterServerEvent("esx:playerSessionStarted")
AddEventHandler("esx:playerSessionStarted", function()
    local src = source
    Citizen.CreateThread(function()
        Citizen.Wait(600000 * 3)
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer or xPlayer == nil then
            DropPlayer(src, "You timed out while choosing a character")
            return
        end
    end)
end)

ESX.RegisterServerCallback("cn-spawn:createCharacter", function(source,cb,args)
    local src = source
    local identifier = GetHexId(src)
    local startingaccount = {
        bank = 50000
    }
    MySQL.Async.execute("INSERT INTO users (identifier,firstname,lastname,dateofbirth,sex,story,accounts) VALUES (@identifier,@firstname,@lastname,@dateofbirth,@sex,@story,@accounts)",{
        ["@identifier"] = identifier,
        ["@firstname"] = args.firstname,
        ["@lastname"] = args.lastname,
        ["@dateofbirth"] = args.dateofbirth,
        ["@sex"] = args.sex,
        ["@story"] = args.story,
        ["@accounts"] = json.encode(startingaccount)
    },function(result)
        cb(true)
    end)
end)

ESX.RegisterServerCallback("cn-spawn:deleteCharacter", function(source,cb,args)
    MySQL.Async.execute("DELETE FROM users WHERE id = @id",{["@id"] = args})
    cb(true)
end)

ESX.RegisterServerCallback("cn-spawn:fetchPlayerCharacters", function(source,cb,args)
    local src = source
    local identifier = GetHexId(src)
    local retval = nil
    print("Hex",identifier)
    MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier",{
        ["@identifier"] = identifier
    },function(result)
        cb(result)
    end)
end)

ESX.RegisterServerCallback("cn-spawn:loginPlayer", function(source,cb,args)
    local src = source
    local identifier = GetHexId(src)
    MySQL.Async.fetchAll("SELECT * FROM users_bans WHERE identifier = @identifier",{
        ["@identifier"] = identifier
    },function(result)
        if result == nil then
            cb(false)
        else
            cb(true)
        end
    end)
end)

ESX.RegisterServerCallback("cn-spawn:selectCharacter", function(source,cb,args)
    local src = source
    local identifier = GetHexId(src)
    MySQL.Async.fetchAll("SELECT * FROM users WHERE identifier = @identifier and id = @id",{
        ["@identifier"] = identifier,
        ["@id"] = args
    },function(result)
        local data ={
            loggedin = true,
            chardata = result[1],
            selectcharacter = args
        }
        print(json.encode(result[1]))
        TriggerEvent("esx:onPlayerJoined",result[1].id,src)
        cb(data)
    end)
end)

function GetHexId( src)
    for k,v in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, 5) == "steam" then
            return v
        end
    end
    
    return false
end