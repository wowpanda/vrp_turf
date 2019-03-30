MySQL = module("vrp_mysql", "MySQL")
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_turf_wars")

MySQL.createCommand("vRP/add_turf", "INSERT IGNORE INTO vrp_turfs(id, x, y, z, blipColor) VALUES(@id, @x, @y, @z, @blipColor)")
MySQL.createCommand("vRP/remove_turf", "DELETE FROM vrp_turfs WHERE id = @id")
MySQL.createCommand("vRP/get_turfs", "SELECT * FROM vrp_turfs")
MySQL.createCommand("vRP/make_owner_turf", "UPDATE vrp_turfs SET owner_id = @owner_id WHERE id = @id")
MySQL.createCommand("vRP/not_owner_turf", "UPDATE vrp_turfs SET owner_id = NULL WHERE id = @id")

local a = 0

RegisterServerEvent('spawnturf')
AddEventHandler('spawnturf',function()
	user_id = vRP.getUserId({source})
	player = vRP.getUserSource({user_id})
	name = vRP.getPlayerName({player})
	turfuri = 0
	MySQL.query("vRP/get_turfs", {}, function(turfs, affected)
		if #turfs > 0 then
			for i, v in ipairs(turfs) do
				turfuri = turfuri + 1
				id = v.id
				x = v.x
				y = v.y
				z = v.z 
				blipColor = v.blipColor
				if not vRP.hasGroup({user_id, "cop1"}) or not vRP.hasGroup({user_id,"cop"}) then
					if vRP.hasPermission({user_id, "mafie.turf"}) then
						TriggerClientEvent('createTurfZone:perm',player,id,x, y, z, blipColor,name)
					else
						TriggerClientEvent('createTurfZone:noperm',player,id,x, y, z, blipColor)
					end
				else
					TriggerClientEvent('createTurfZone:cop',player,id,x, y, z, blipColor)
				end
			end
		end
	end)
end)

RegisterServerEvent('vrp:givemoney')
AddEventHandler('vrp:givemoney',function(name,blipColor)
	user_id = vRP.getUserId({source})
	player = vRP.getUserSource({user_id})
	vRP.giveMoney({user_id, 1000000})
	TriggerClientEvent('vrp:notify_turfcontiuna',-1,name,blipColor)
end)

RegisterServerEvent('startwar')
AddEventHandler('startwar',function(id,name,x,y,z,blipColor)
	owner_id = vRP.getUserId({source})
	MySQL.execute("vRP/make_owner_turf",{owner_id = owner_id,id = id})
	TriggerClientEvent('vrp:notify_turfowner',-1,tostring(name),blipColor)
	TriggerClientEvent('vrp:create_blip',-1,id,name,x,y,z,blipColor)
	if blipColor == 49 then
		color = "^8^*Rosu"
	end
	if blipColor == 38 then
		color = "^4^*Albastru"
	end
	if blipColor == 70 then
		color = "^3^*Galben"
	end
	if blipColor == 69 then
		color = "^2^*Verde"
	end
	TriggerClientEvent('chatMessage',-1,'^0[^4TURF^0] ', {255, 0, 0}, "^0Turf-ul ^4" .. color .. "^r^0 este cucerit de ^9^*".. name .. "^r^0, du-te si doboara-l!")
end)

RegisterServerEvent('endwar')
AddEventHandler('endwar',function(id,name,blipColor)
	MySQL.execute("vRP/not_owner_turf",{id = id})
	TriggerClientEvent('vrp:notify_endwar',-1,tostring(name),blipColor)
end)

local ch_delTurf = {function(player,choice)
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		vRP.prompt({player,"ID Turf:","",function(player,turfID)
			MySQL.query("vRP/get_turfs", {}, function(turfs, affected)
				if #turfs > 0 then
					for i,v in pairs(turfs) do
						id = v.id
						if tonumber(turfID) > 0 and tonumber(turfID) == tonumber(id) then
							MySQL.query("vRP/remove_turf", {id = id})
							vRPclient.notify(player,{"~w~[TURF] ~g~Turf cu ID-ul ~r~#"..turfID.." ~g~a fost sters!"})
						end
					end
				end
			end)
		end})
	end
end, "Sterge zona turf"}

local ch_createTurf = {function(player,choice)
	local user_id = vRP.getUserId({player})
	if user_id ~= nil then
		vRP.prompt({player,"Culoare Turf:","",function(player,blipColor)
			blipColor = blipColor
			if blipColor ~= nil then
				vRPclient.getPosition(player,{},function(x,y,z)
					MySQL.query("vRP/get_turfs", {}, function(turfs, affected)
						if #turfs > 0 then
							for i, v in ipairs(turfs) do
								turfuri = turfuri + 1
								MySQL.query("vRP/add_turf", {id = turfuri, x = x, y = y, z = z, blipColor = blipColor})
								vRPclient.notify(player,{"~w~[TURF] ~g~Turf cu ID-ul ~r~#"..turfuri.." ~g~a fost creat!"})
							end
						end
						if #turfs == 0 then
							MySQL.query("vRP/add_turf", {id = 1, x = x, y = y, z = z, blipColor = blipColor})
							vRPclient.notify(player,{"~w~[TURF] ~g~Turf cu ID-ul ~r~#1 ~g~a fost creat!"})
						end
					end)
				end)
			end
		end})
	end
end, "Creaza zona turf pentru mafii"}

vRP.registerMenuBuilder({"admin", function(add, data)
	local user_id = vRP.getUserId({data.player})
	if user_id ~= nil then
		local choices = {}
	
		if vRP.hasGroup({user_id, "owner"}) then
			choices["Create Turf"] = ch_createTurf
			choices["Delete Turf"] = ch_delTurf
		end
		add(choices)
	end
end})
