vRP = Proxy.getInterface("vRP")

local inceput = true

local secondsRemaining = 5*60

function turf_drawTxt(x,y ,width,height,scale, text, r,g,b,a, outline)
    SetTextFont(0)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    if(outline)then
	    SetTextOutline()
	end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

Citizen.CreateThread(function()
	TriggerServerEvent('spawnturf')
end)

RegisterNetEvent('timer')
AddEventHandler('timer', function(name,blipColor)
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1000)
			if not inceput then
				secondsRemaining = secondsRemaining - 1
				if secondsRemaining == 0 then
					TriggerServerEvent('vrp:givemoney',name,blipColor)
					TriggerEvent('vrp:notify_turfaltau',1000000,blipColor)
					Citizen.Wait(30*60*1000)
					inceput = true
				end
				if secondsRemaining < 0 then
					secondsRemaining = 5*60
					break
				end
			else
				secondsRemaining = 5*60
				break
			end
		end
	end)
end)

AddEventHandler('timer', function()
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(0)
			if not inceput then
				if secondsRemaining < 300 and secondsRemaining > 0 then
					turf_drawTxt(0.66, 1.44, 1.0,1.0,0.4, "Castigi turful in: ~b~" .. secondsRemaining .. "~w~ secunde!", 255, 255, 255, 255)
				end
			end
		end
	end)
end)

RegisterNetEvent('createTurfZone:perm')
AddEventHandler('createTurfZone:perm',function(id, x, y, z, blipColor,name)	
	Citizen.CreateThread(function()
		local blip = AddBlipForCoord(x,y,z)
		SetBlipSprite(blip, 161)
		SetBlipScale(blip, 0.8)
		SetBlipColour(blip, blipColor)
		SetBlipAsShortRange(blip, true)
		vRP_createBlip(x,y,z,name,blipColor)
		while true do
			Citizen.Wait(0)
			if inceput then
				if Vdist(x,y,z,GetEntityCoords(GetPlayerPed(-1))) < 5 then
					info("Apasa ~INPUT_CONTEXT~ pentru a incepe ~b~WAR~w~!")
					if IsControlJustPressed(1, 51) then

						TriggerServerEvent('startwar', id,name,x, y, z,blipColor)

						notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~b~Ai cucerit zona~w~!", "~r~Ai grija, vei fi atacat~w~! ~b~#turf")
						
						TriggerEvent('timer',name,blipColor)

						inceput = false
					end
				end
			else
				if Vdist(x,y,z,GetEntityCoords(GetPlayerPed(-1))) < 5 then
					info("A fost inceput deja acest ~b~WAR~w~!")
				end
			end
		end
	end)
end)

RegisterNetEvent('createTurfZone:noperm')
AddEventHandler('createTurfZone:noperm',function(id, x, y, z, blipColor)	
	Citizen.CreateThread(function()
		blip = AddBlipForCoord(x,y,z)
		SetBlipSprite(blip, 161)
		SetBlipScale(blip, 0.8)
		SetBlipColour(blip, blipColor)
		SetBlipAsShortRange(blip, true)
		
		vRP_createBlip(x,y,z,name,blipColor)

		while true do
			Citizen.Wait(0)
			if Vdist(x,y,z,GetEntityCoords(GetPlayerPed(-1))) < 5 then
				info("Nu ai permisiunea de a incepe un ~b~WAR~w~!")
			end
		end
	end)
end)

RegisterNetEvent('createTurfZone:cop')
AddEventHandler('createTurfZone:cop',function(id, x, y, z, blipColor)	
	Citizen.CreateThread(function()
		blip = AddBlipForCoord(x,y,z)
		SetBlipSprite(blip, 161)
		SetBlipScale(blip, 0.8)
		SetBlipColour(blip, blipColor)
		SetBlipAsShortRange(blip, true)
		
		vRP_createBlip(x,y,z,name,blipColor)

		while true do
			Citizen.Wait(0)
			if Vdist(x,y,z,GetEntityCoords(GetPlayerPed(-1))) < 5 then
				info("Esti politist, nu poti incepe un ~b~WAR~w~!")
			end
		end
	end)
end)

function vRP_createBlip(x,y,z,name,blipColor)
	Citizen.CreateThread(function()
		local blip = AddBlipForCoord(x, y, z)
		SetBlipSprite(blip, 1)
		SetBlipScale(blip, 1.0)
		SetBlipColour(blip, blipColor)
		SetBlipAsShortRange(blip, true)
		if blipColor == 49 then
			color = "Rosu"
		end
		if blipColor == 38 then
			color = "Albastru"
		end
		if blipColor == 70 then
			color = "Galben"
		end
		if blipColor == 69 then
			color = "Verde"
		end
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("P: Turf "..color)
		EndTextCommandSetBlipName(blip)
	end)
end

RegisterNetEvent('vrp:create_blip')
AddEventHandler('vrp:create_blip',function(id,name,x,y,z,blipColor)
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(1000)
			if not inceput then
				if Vdist(x,y,z,GetEntityCoords(GetPlayerPed(-1))) > 50 then
					TriggerServerEvent('endwar',id,name,blipColor)
					inceput = true
					Citizen.Wait(3*1000)
					permite = true
					break
				end
				if vRP.isInComa() then
					TriggerServerEvent('endwar',id,name,blipColor)
					inceput = true
					Citizen.Wait(3*1000)
					permite = true
					break
				end
			end
		end
	end)
end)

RegisterNetEvent('vrp:chat_info')
AddEventHandler('vrp:chat_info',function(id,name,blipColor)
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(30000)
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
			if not inceput then
				TriggerEvent('chatMessage', '^0[^4TURF^0] ', {255, 0, 0}, "^0Turf-ul ^4" .. color .. "^r^0 este cucerit de ^9^*".. name .. "^r^0, du-te si doboara-l!")
			end
		end
	end)
end)

function info(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function notifyPicture(icon, type, sender, title, text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    SetNotificationMessage(icon, icon, true, type, sender, title, text)
    DrawNotification(false, true)
end

RegisterNetEvent('vrp:notify_endwar')
AddEventHandler('vrp:notify_endwar',function(name,blipColor)
	if blipColor == 49 then
		color = "~r~Rosu~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." a fost doborat~w~!", "~b~"..name.."~w~ a fost doborat sau a parasit turf-ul~w~! ~b~#turf")
	end
	if blipColor == 38 then
		color = "~b~Albastru~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." a fost doborat~w~!", "~b~"..name.."~w~ a fost doborat sau a parasit turf-ul~w~! ~b~#turf")
	end
	if blipColor == 70 then
		color = "~y~Galben~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." a fost doborat~w~!", "~b~"..name.."~w~ a fost doborat sau a parasit turf-ul~w~! ~b~#turf")
	end
	if blipColor == 69 then
		color = "~g~Verde~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." a fost doborat~w~!", "~b~"..name.."~w~ a fost doborat sau a parasit turf-ul~w~! ~b~#turf")
	end
end)

RegisterNetEvent('vrp:notify_turfowner')
AddEventHandler('vrp:notify_turfowner',function(name,blipColor)
	if blipColor == 49 then
		color = "~r~Rosu~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." a fost cucerit~w~!", "~w~Du-te si cucereste turf-ul lui ~b~"..name.."~w~! ~b~#turf")
	end
	if blipColor == 38 then
		color = "~b~Albastru~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." a fost cucerit~w~!", "~w~Du-te si cucereste turf-ul lui ~b~"..name.."~w~! ~b~#turf")
	end
	if blipColor == 70 then
		color = "~y~Galben~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." a fost cucerit~w~!", "~w~Du-te si cucereste turf-ul lui ~b~"..name.."~w~! ~b~#turf")
	end
	if blipColor == 69 then
		color = "~g~Verde~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." a fost cucerit~w~!", "~w~Du-te si cucereste turf-ul lui ~b~"..name.."~w~! ~b~#turf")
	end
end)

RegisterNetEvent('vrp:notify_turfcontiuna')
AddEventHandler('vrp:notify_turfcontiuna',function(name,blipColor)
	if blipColor == 49 then
		color = "~r~Rosu~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." este in posesia cuiva~w~!", "~w~Du-te si cucereste turf-ul lui ~b~"..name.."~w~! ~b~#turf")
	end
	if blipColor == 38 then
		color = "~b~Albastru~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." este in posesia cuiva~w~!", "~w~Du-te si cucereste turf-ul lui ~b~"..name.."~w~! ~b~#turf")
	end
	if blipColor == 70 then
		color = "~y~Galben~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." este in posesia cuiva~w~!", "~w~Du-te si cucereste turf-ul lui ~b~"..name.."~w~! ~b~#turf")
	end
	if blipColor == 69 then
		color = "~g~Verde~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." este in posesia cuiva~w~!", "~w~Du-te si cucereste turf-ul lui ~b~"..name.."~w~! ~b~#turf")
	end
end)
RegisterNetEvent('vrp:notify_turfaltau')
AddEventHandler('vrp:notify_turfaltau',function(money,blipColor)
	if blipColor == 49 then
		color = "~r~Rosu~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." este in posesia ta~w~!", "~w~Ai primit ~g~"..money.." $ ~w~pentru ca ai rezistat 5 minute~w~! ~b~#turf")
	end
	if blipColor == 38 then
		color = "~b~Albastru~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." este in posesia ta~w~!", "~w~Ai primit ~g~"..money.." $ ~w~pentru ca ai rezistat 5 minute~w~! ~b~#turf")
	end
	if blipColor == 70 then
		color = "~y~Galben~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." este in posesia ta~w~!", "~w~Ai primit ~g~"..money.." $ ~w~pentru ca ai rezistat 5 minute~w~! ~b~#turf")
	end
	if blipColor == 69 then
		color = "~g~Verde~w~"
		notifyPicture("CHAR_AMMUNATION", 2, "~r~Turfs ~g~| Notificare", "~w~Turf-ul "..color.." este in posesia ta~w~!", "~w~Ai primit ~g~"..money.." $ ~w~pentru ca ai rezistat 5 minute~w~! ~b~#turf")
	end
end)
