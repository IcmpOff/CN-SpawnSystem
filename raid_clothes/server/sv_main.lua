ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback("clothing:purchase", function(source,cb,price)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getAccount('money').money >= tonumber(price) then
        xPlayer.removeMoney(tonumber(price))
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback("PriceWithTaxString", function(source,cb,pData,pType)
    local data = {
        total = pData,
        text = pData.." + "..pType
    }
    cb(data)
end)

ESX.RegisterServerCallback("skins:getSteamId", function(source,cb)
    local hexid = GetHexId(source)
    local steamid = HexIdToSteamId(hexid)
    cb(hexid)
end)

function GetHexId(src)
    for k,v in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, 5) == "steam" then
            return v
        end
    end
    
    return false
end

function HexIdToSteamId(hexid)
    local cid = HexIdToComId(hexid)
    local steam64 = math.floor(tonumber(string.sub( cid, 2)))
	local a = steam64 % 2 == 0 and 0 or 1
	local b = math.floor(math.abs(6561197960265728 - steam64 - a) / 2)
	local sid = "STEAM_0:"..a..":"..(a == 1 and b -1 or b)
    return sid
end

function HexIdToComId(hexid)
    return math.floor(tonumber(string.sub(hexid, 7), 16))
end

local function checkExistenceClothes(cid, cb)
    MySQL.Async.fetchAll("SELECT cid FROM users_current WHERE cid = @cid LIMIT 1;", {["cid"] = cid}, function(result)
        local exists = result and result[1] and true or false
        cb(exists)
    end)
end

local function checkExistenceFace(cid, cb)
    MySQL.Async.fetchAll("SELECT cid FROM users_face WHERE cid = @cid LIMIT 1;", {["cid"] = cid}, function(result)
        local exists = result and result[1] and true or false
        cb(exists)
    end)
end

RegisterServerEvent("raid_clothes:insert_character_current")
AddEventHandler("raid_clothes:insert_character_current",function(data)
    if not data then return end
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local characterId = xPlayer.getIdentifier()
    if not characterId then return end
    checkExistenceClothes(characterId, function(exists)
        local values = {
            ["cid"] = characterId,
            ["model"] = json.encode(data.model),
            ["drawables"] = json.encode(data.drawables),
            ["props"] = json.encode(data.props),
            ["drawtextures"] = json.encode(data.drawtextures),
            ["proptextures"] = json.encode(data.proptextures),
        }

        if not exists then
            local cols = "cid, model, drawables, props, drawtextures, proptextures"
            local vals = "@cid, @model, @drawables, @props, @drawtextures, @proptextures"

            MySQL.Async.execute("INSERT INTO users_current ("..cols..") VALUES ("..vals..")", values, function()
            end)
            MySQL.Async.fetchAll("SELECT * FROM users_tattoos WHERE cid = @identifier", {['identifier'] = characterId}, function(result)
                if(result[1] == nil) then
                    local tattooValue = "{}"
                    MySQL.Async.execute("INSERT INTO users_tattoos (cid, tattoos) VALUES (@identifier, @tattoo)", {['identifier'] = characterId, ['tattoo'] = tattooValue})
                end
            end)
            return
        end

        local set = "model = @model,drawables = @drawables,props = @props,drawtextures = @drawtextures,proptextures = @proptextures"
        MySQL.Async.execute("UPDATE users_current SET "..set.." WHERE cid = @cid", values)
    end)
end)

RegisterServerEvent("raid_clothes:insert_character_face")
AddEventHandler("raid_clothes:insert_character_face",function(data)
    if not data then return end
    local src = source

    local xPlayer = ESX.GetPlayerFromId(src)
    local characterId = xPlayer.getIdentifier()

    if not characterId then return end

    checkExistenceFace(characterId, function(exists)
        if data.headBlend == "null" or data.headBlend == nil then
            data.headBlend = '[]'
        else
            data.headBlend = json.encode(data.headBlend)
        end
        local values = {
            ["cid"] = characterId,
            ["hairColor"] = json.encode(data.hairColor),
            ["headBlend"] = data.headBlend,
            ["headOverlay"] = json.encode(data.headOverlay),
            ["headStructure"] = json.encode(data.headStructure),
        }

        if not exists then
            local cols = "cid, hairColor, headBlend, headOverlay, headStructure"
            local vals = "@cid, @hairColor, @headBlend, @headOverlay, @headStructure"

            MySQL.Async.execute("INSERT INTO users_face ("..cols..") VALUES ("..vals..")", values, function()
            end)
            
            
            return
        end

        local set = "hairColor = @hairColor,headBlend = @headBlend, headOverlay = @headOverlay,headStructure = @headStructure"
        MySQL.Async.execute("UPDATE users_face SET "..set.." WHERE cid = @cid", values )
    end)
end)

RegisterServerEvent("raid_clothes:get_character_face")
AddEventHandler("raid_clothes:get_character_face",function(pSrc)
    local src = (not pSrc and source or pSrc)
    local xPlayer = ESX.GetPlayerFromId(src)
    local characterId = xPlayer.getIdentifier()

    if not characterId then return end

    MySQL.Async.fetchAll("SELECT cc.model, cf.hairColor, cf.headBlend, cf.headOverlay, cf.headStructure FROM users_face cf INNER JOIN users_current cc on cc.cid = cf.cid WHERE cf.cid = @cid", {['cid'] = characterId}, function(result)
        if (result ~= nil and result[1] ~= nil) then
            local temp_data = {
                hairColor = json.decode(result[1].hairColor),
                headBlend = json.decode(result[1].headBlend),
                headOverlay = json.decode(result[1].headOverlay),
                headStructure = json.decode(result[1].headStructure),
            }
            local model = tonumber(result[1].model)
            if model == 1885233650 or model == -1667301416 then
                TriggerClientEvent("raid_clothes:setpedfeatures", src, temp_data)
            end
        else
            TriggerClientEvent("raid_clothes:setpedfeatures", src, false)
        end
	end)
end)

RegisterServerEvent("raid_clothes:get_character_current")
AddEventHandler("raid_clothes:get_character_current",function(pSrc)
    local src = (not pSrc and source or pSrc)
    local xPlayer = ESX.GetPlayerFromId(src)
    local characterId = xPlayer.getIdentifier()

    if not characterId then return end

    MySQL.Async.fetchAll("SELECT * FROM users_current WHERE cid = @cid", {['cid'] = characterId}, function(result)
        local temp_data = {
            model = result[1].model,
            drawables = json.decode(result[1].drawables),
            props = json.decode(result[1].props),
            drawtextures = json.decode(result[1].drawtextures),
            proptextures = json.decode(result[1].proptextures),
        }
        TriggerClientEvent("raid_clothes:setclothes", src, temp_data,0)
	end)
end)

RegisterServerEvent("raid_clothes:retrieve_tats")
AddEventHandler("raid_clothes:retrieve_tats", function(pSrc)
    local src = (not pSrc and source or pSrc)
	local xPlayer = ESX.GetPlayerFromId(src)
	MySQL.Async.fetchAll("SELECT * FROM users_tattoos WHERE cid = @identifier", {['identifier'] = xPlayer.getIdentifier()}, function(result)
        if(result[1] ~= nil) then
            print("have tatto")
			TriggerClientEvent("raid_clothes:settattoos", src, json.decode(result[1].tattoos))
		else
			local tattooValue = "{}"
			MySQL.Async.execute("INSERT INTO users_tattoos (cid, tattoos) VALUES (@identifier, @tattoo)", {['identifier'] = xPlayer.getIdentifier(), ['tattoo'] = tattooValue})
			TriggerClientEvent("raid_clothes:settattoos", src, {})
		end
	end)
end)

RegisterServerEvent("raid_clothes:set_tats")
AddEventHandler("raid_clothes:set_tats", function(tattoosList)
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	MySQL.Async.execute("UPDATE users_tattoos SET tattoos = @tattoos WHERE cid = @identifier", {['tattoos'] = json.encode(tattoosList), ['identifier'] = xPlayer.getIdentifier()})
end)


RegisterServerEvent("raid_clothes:get_outfit")
AddEventHandler("raid_clothes:get_outfit",function(slot)
    if not slot then return end
    local src = source

    local xPlayer = ESX.GetPlayerFromId(src)
    local characterId = xPlayer.getIdentifier()

    if not characterId then return end

    MySQL.Async.fetchAll("SELECT * FROM users_outfits WHERE cid = @cid and slot = @slot", {
        ['cid'] = characterId,
        ['slot'] = slot
    }, function(result)
        if result and result[1] then
            if result[1].model == nil then
                TriggerClientEvent("DoLongHudText", src, "Can not use.",2)
                return
            end

            local data = {
                model = result[1].model,
                drawables = json.decode(result[1].drawables),
                props = json.decode(result[1].props),
                drawtextures = json.decode(result[1].drawtextures),
                proptextures = json.decode(result[1].proptextures),
                hairColor = json.decode(result[1].hairColor)
            }

            TriggerClientEvent("raid_clothes:setclothes", src, data,0)

            local values = {
                ["cid"] = characterId,
                ["model"] = data.model,
                ["drawables"] = json.encode(data.drawables),
                ["props"] = json.encode(data.props),
                ["drawtextures"] = json.encode(data.drawtextures),
                ["proptextures"] = json.encode(data.proptextures),
            }

            local set = "model = @model, drawables = @drawables, props = @props,drawtextures = @drawtextures,proptextures = @proptextures"
            MySQL.Async.execute("UPDATE users_current SET "..set.." WHERE cid = @cid",values)
        else
            TriggerClientEvent("DoLongHudText", src, "No outfit on slot " .. slot,2)
            return
        end
	end)
end)

RegisterServerEvent("raid_clothes:set_outfit")
AddEventHandler("raid_clothes:set_outfit",function(slot, name, data)
    if not slot then return end
    local src = source

    local xPlayer = ESX.GetPlayerFromId(src)
    local characterId = xPlayer.getIdentifier()

    if not characterId then return end

    MySQL.Async.fetchAll("SELECT slot FROM users_outfits WHERE cid = @cid and slot = @slot", {
        ['cid'] = characterId,
        ['slot'] = slot
    }, function(result)
        if result and result[1] then
            local values = {
                ["cid"] = characterId,
                ["slot"] = slot,
                ["name"] = name,
                ["model"] = json.encode(data.model),
                ["drawables"] = json.encode(data.drawables),
                ["props"] = json.encode(data.props),
                ["drawtextures"] = json.encode(data.drawtextures),
                ["proptextures"] = json.encode(data.proptextures),
                ["hairColor"] = json.encode(data.hairColor),
            }

            local set = "model = @model,name = @name,drawables = @drawables,props = @props,drawtextures = @drawtextures,proptextures = @proptextures,hairColor = @hairColor"
            MySQL.Async.execute("UPDATE users_outfits SET "..set.." WHERE cid = @cid and slot = @slot",values)
        else
            local cols = "cid, model, name, slot, drawables, props, drawtextures, proptextures, hairColor"
            local vals = "@cid, @model, @name, @slot, @drawables, @props, @drawtextures, @proptextures, @hairColor"

            local values = {
                ["cid"] = characterId,
                ["name"] = name,
                ["slot"] = slot,
                ["model"] = data.model,
                ["drawables"] = json.encode(data.drawables),
                ["props"] = json.encode(data.props),
                ["drawtextures"] = json.encode(data.drawtextures),
                ["proptextures"] = json.encode(data.proptextures),
                ["hairColor"] = json.encode(data.hairColor)
            }

            MySQL.Async.execute("INSERT INTO users_outfits ("..cols..") VALUES ("..vals..")", values, function()
                TriggerClientEvent("DoLongHudText", src, name .. " stored in slot " .. slot,1)
            end)
        end
	end)
end)


RegisterServerEvent("raid_clothes:remove_outfit")
AddEventHandler("raid_clothes:remove_outfit",function(slot)

    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local cid = xPlayer.getIdentifier()
    local slot = slot

    if not cid then return end

    MySQL.Async.execute( "DELETE FROM users_outfits WHERE cid = @cid AND slot = @slot", { ['cid'] = cid,  ["slot"] = slot } )
    TriggerClientEvent("DoLongHudText", src,"Removed slot " .. slot .. ".",1)
end)

RegisterServerEvent("raid_clothes:list_outfits")
AddEventHandler("raid_clothes:list_outfits",function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local cid = xPlayer.getIdentifier()
    local slot = slot
    local name = name

    if not cid then return end

    MySQL.Async.fetchAll("SELECT slot, name FROM users_outfits WHERE cid = @cid", {['cid'] = cid}, function(skincheck)
    	TriggerClientEvent("hotel:listSKINSFORCYRTHESICKFUCK",src, skincheck)
	end)
end)


RegisterServerEvent("clothing:checkIfNew")
AddEventHandler("clothing:checkIfNew", function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local cid = xPlayer.getIdentifier()

    MySQL.Async.fetchScalar("SELECT count(model) FROM users_current WHERE cid = @cid LIMIT 1", {
        ['cid'] = cid
    }, function(result)
        local isService = false;
        if result == 0 then
            MySQL.Async.fetchAll("select count(cid) assExist from users_current where cid =  @cid", {['cid'] = cid}, function(clothingCheck)
                local existsClothing = clothingCheck[1].assExist
                TriggerClientEvent('raid_clothes:setclothes',src,{},existsClothing)
            end)
            return
        else
            TriggerEvent("raid_clothes:get_character_current", src)
        end
        TriggerClientEvent("raid_clothes:inService",src,isService)
    end)
end)