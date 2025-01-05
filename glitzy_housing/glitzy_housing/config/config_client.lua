local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPserver = Tunnel.getInterface("vRP","glitzy_homes")

src = {}
Tunnel.bindInterface("glitzy_homes",src)
vSERVER = Tunnel.getInterface("glitzy_homes")
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PRINCIPAL
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config = {} -- No mover
sv_config = {} -- No mover

CreateThread(function()
    sv_config = vSERVER.ServerConfig()
end)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURACIONES
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config.limitZone = 30.0 -- Límite si el jugador se aleja demasiado o no carga la casa, teletransporta al punto de entrada.
config.imagemDir = "http://144.217.29.241/carros/" -- Directorio de imágenes de vehículos.

config.drawlable = function(id, coords, tipo, porta)
    if tipo == "apartamento" then -- Configurar el mensaje/blip que aparecerá en la propiedad
        DrawText3Ds(coords.x, coords.y, coords.z+0.5, "~w~[Propiedad: ~g~"..tonumber(id).."~w~]\n~w~[~g~E~w~] entrar/salir\n~w~[~g~F~w~] comprar")
		DrawMarker(21,coords.x, coords.y, coords.z-0.7,0,0,0,0,0,130.0,0.5,1.0,0.5, 0,255,0,180 ,1,0,0,1)
	elseif tipo == "casa" then -- Configurar el mensaje/blip que aparecerá en la propiedad
		if porta then
			DrawText3Ds(coords.x, coords.y, coords.z+0.5, "~w~[PROPIEDAD: ~g~"..tonumber(id).."~w~]\n~w~[~g~E~w~] entrar/salir\n~w~[~g~L~w~] desbloquear\n~w~Puerta: ~r~Cerrada ")
			DrawMarker(21,coords.x, coords.y, coords.z-0.7,0,0,0,0,0,130.0,0.5,1.0,0.5, 255,0,0,180 ,1,0,0,1)
		else
			DrawText3Ds(coords.x, coords.y, coords.z+0.5, "~w~[PROPIEDAD: ~g~"..tonumber(id).."~w~]\n~w~[~g~E~w~] entrar/salir\n~w~[~g~L~w~] bloquear\n~w~Puerta: ~g~Abierta ")
			DrawMarker(21,coords.x, coords.y, coords.z-0.7,0,0,0,0,0,130.0,0.5,1.0,0.5, 0,255,0,180 ,1,0,0,1)
		end
	elseif tipo == "garage" then
		DrawMarker(36,coords.x, coords.y, coords.z,0,0,0,0,0,130.0,0.5,1.0,0.5, 0,255,0,180 ,1,0,0,1)
	elseif tipo == "armario" then
		DrawMarker(0,coords.x, coords.y, coords.z,0,0,0,0,0,130.0, 0.5,0.5,0.5, 0,255,0,180 ,1,0,0,1)
	elseif tipo == "baul" then
		DrawMarker(30,coords.x, coords.y, coords.z-0.3,0,0,0,0,0,130.0, 0.5,1.0,0.5, 0,255,0,180 ,1,0,0,1)
    end
end

config.lang = {
	trancar = function() return TriggerEvent("Notify","importante","Tú <b>bloqueaste</b> la puerta.", 5) end, -- Notificación cuando la puerta se bloquea
	destrancar = function() return TriggerEvent("Notify","importante","Tú <b>desbloqueaste</b> la puerta.", 5) end, -- Notificación cuando la puerta está desbloqueada
	trancada = function() return TriggerEvent("Notify","importante","La puerta está <b>bloqueada</b>, desbloqueala para entrar.", 5) end, -- Notificación cuando la puerta está cerrada
	notownerGaragem = function() return TriggerEvent("Notify","importante","No tienes acceso a este garaje.", 5) end, -- Notificación cuando el jugador no tiene acceso al garaje.
	veiculoSpawnado = function() return TriggerEvent("Notify","importante","Este vehículo ya está fuera del garaje.", 5) end, -- Notificación cuando el vehículo ya está fuera del garaje.
	apGaragem = function() return TriggerEvent("Notify","importante","Los espacios de aparcamiento del apartamento son solo para el propietario.", 5) end, -- Notificación cuando el vehículo ya está fuera del garaje.
	notAccess = function() return TriggerEvent("Notify","importante","No tienes acceso a esto.", 5000) end -- Notificación cuando no tienes acceso.
}

config.animLock = function() -- Animación de bloqueo/desbloqueo de puerta
	vRP._playAnim(true,{{"veh@mower@base","start_engine"}},false) -- Animación
	Wait(2000) -- Tiempo de espera
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURACIONES DE LOS GARAGES
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
src.tuningVehicle = function(custom, veh) -- Su función para aplicar tuning.
	TriggerServerEvent("nation:syncApplyMods", custom,VehToNet(veh))
end

src.deleteVehicle = function(veh) -- Su función para eliminar vehículo.
    exports['bm_module']:deleteVehicle(source, veh)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGURACIONES DE LOS BLIPS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
src.allDispHouses = function() -- El comando /home disp parpadea
    houseOwner = GlobalState.houseOwner
    
    for k,v in pairs(propiedades) do
        if houseOwner[k] == nil or v.tipo == "apartamento" then
            local blip = AddBlipForCoord(v.coords.x,v.coords.y,v.coords.z)
            SetBlipSprite(blip,411)
            SetBlipAsShortRange(blip,true)
            SetBlipColour(blip,2)
            SetBlipScale(blip,0.4)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Propiedades disponibles")
            EndTextCommandSetBlipName(blip)
            
            SetTimeout(15000,function() if DoesBlipExist(blip) then RemoveBlip(blip) end end)
        end
    end
end

src.myHouseBlip = function(coords) -- Las propiedades del jugador aparecen
	local blip = AddBlipForCoord(coords.x,coords.y,coords.z)
	SetBlipSprite(blip,411)
	SetBlipAsShortRange(blip,true)
	SetBlipColour(blip,36)
	SetBlipScale(blip,0.4)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Mi propiedad")
	EndTextCommandSetBlipName(blip)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OPTIMIZACIÓN (NO TOCAR AQUÍ)
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local time = 1000
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        if in_interior then
            local distance = #(pedCoords - infoInterior.coords)
            if distance >= config.limitZone then
                SetEntityCoords(PlayerPedId(), infoInterior.coords[1],infoInterior.coords[2],infoInterior.coords[3])
            end

            local distance = #(pedCoords - infoInterior.coords)
            if distance <= 2.0 then
                time = 1
                config.drawlable(infoInterior.houseID, infoInterior.coords, infoInterior.tipo, propiedades[infoInterior.houseID].porta)

                if infoInterior.tipo == "casa" then
                    if IsControlJustReleased(1, 182) and segundos <= 0 then
                        segundos = 3

                        if vSERVER.checkEnterHouse(infoInterior.houseID) then
                            
                            if propiedades[infoInterior.houseID].porta then
                                config.animLock()
                                propiedades[infoInterior.houseID].porta = false
                                config.lang['destrancar']()
                            else
                                config.animLock()
                                propiedades[infoInterior.houseID].porta = true
                                config.lang['trancar']()
                            end

                            vSERVER.syncLock(infoInterior.houseID, propiedades[infoInterior.houseID].porta)
                        end
                    end

                    if IsControlJustReleased(1, 51) and segundos <= 0 then
                        segundos = 3

                        if not propiedades[infoInterior.houseID].porta then
                            vSERVER.sairPropriedade(infoInterior.houseID)
                        else
                            config.lang['trancada']()
                        end
                    end

                elseif infoInterior.tipo == "apartamento" then
                    if IsControlJustReleased(1, 51) and segundos <= 0 then
                        segundos = 3

                        vSERVER.sairPropriedade(infoInterior.houseID)
                    end
                end
            end
        else 
            if length(nearestHouse) > 0 then
                for k in pairs(nearestHouse) do 
                    local distance = #(pedCoords - vec3(nearestHouse[k].coords.x,nearestHouse[k].coords.y,nearestHouse[k].coords.z))
                    if distance <= 5.0 then
                        time = 5
                        config.drawlable(k, vec3(nearestHouse[k].coords.x,nearestHouse[k].coords.y,nearestHouse[k].coords.z), nearestHouse[k].tipo, nearestHouse[k].porta)
                        if distance <= 2.0 then
                            if nearestHouse[k].tipo == "casa" then
                                if IsControlJustReleased(1, 182) and segundos <= 0 then
                                    segundos = 3

                                    if vSERVER.checkEnterHouse(k) then
                                        
                                        if nearestHouse[k].porta then
                                            config.animLock()
                                            nearestHouse[k].porta = false
                                            config.lang['destrancar']()
                                        else
                                            config.animLock()
                                            nearestHouse[k].porta = true
                                            config.lang['trancar']()
                                        end

                                        vSERVER.syncLock(k, nearestHouse[k].porta)
                                    end
                                end

                                if IsControlJustReleased(1, 51) and segundos <= 0 then
                                    segundos = 3

                                    if not nearestHouse[k].porta then
                                        vSERVER.entrarPropriedade(k, nearestHouse[k].tipo)
                                    else
                                        if vSERVER.comprarPropriedade(k, tostring(nearestHouse[k].tipo)) then
                                            config.lang['trancada']()
                                        end
                                    end
                                end

                            elseif nearestHouse[k].tipo == "apartamento" then
                                if IsControlJustReleased(1, 51) and segundos <= 0 then
                                    segundos = 3
                                    vSERVER.interfone(k)
                                end

                                if IsControlJustReleased(1, 145) and segundos <= 0 then
                                    segundos = 3
                                    vSERVER.comprarPropriedade(k, tostring(nearestHouse[k].tipo))
                                end
                            end
                        end
                    end
                end
            end
        end

        Citizen.Wait(time)
    end
end)

Citizen.CreateThread(function()
    while true do 
        local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)
        if not in_interior then
            for k in pairs(propriedades) do
                local distance = #(pedCoords - vec3(propriedades[k].coords.x,propriedades[k].coords.y,propriedades[k].coords.z))
                if distance < 10 then
                    nearestHouse[k] = propriedades[k]
                elseif nearestHouse[k] then
                    nearestHouse[k] = nil
                end
            end
        end
        
        Citizen.Wait(1000)
    end
end)
