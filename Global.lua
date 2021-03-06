function onLoad(save)
    objectLockdown = {
        "f73eb4","140320","f476b8","17f289","c9a1ab","7fd288","802616","eb7c74",
        "21b5d2","a4df4c","1cffbc","e13ffd","de075e","4e5bd5","677d99","d8141f",
        "ed19b2","2adab0","b29774","5dff41","327c73","077736","6ee035","c382c1",
        "f4e4fc","7b997f","4c68cc","223061","42edd3","5b13c1","26b7c8","b8f2bb",
        "7bb674","8722e0","4ef0c4","257fd3","e08dc1","df996a","b17957","bc494b",
        "29677c","2612c0","7c63f0","e71bd6","c12205","54a40d","11974a","1f8690",

        "084f05","c3da13","7c14e7","ff9b4f",

        "9fdea2",

		"0dc414","ded49d","dc3aff","c42232","a506f9","423aeb",
    }
	Order = {
		{color="White",Obj=getObjectFromGUID("0dc414")},
		{color="Red",Obj=getObjectFromGUID("ded49d")},
		{color="Yellow",Obj=getObjectFromGUID("dc3aff")},
		{color="Green",Obj=getObjectFromGUID("c42232")},
		{color="Blue",Obj=getObjectFromGUID("a506f9")},
		{color="Pink",Obj=getObjectFromGUID("423aeb")},
	}
	if save ~= "" then
		local tbl = JSON.decode(save)
		Index = tbl[1]
		Turn = tbl[2]
	else
		Index = 0
		Turn = "Off"
	end
    lockObjects()
	UpdateDesplay()
	Mods = {}
   normaldeckbagguids = {"7882de"}
   normaldeckbags = {}
   for i,v in pairs(normaldeckbagguids) do
      table.insert(normaldeckbags,getObjectFromGUID(v))
   end
   Rzone = getObjectFromGUID("11b50e")
   Wzone = getObjectFromGUID("d72560")
   Gzone = getObjectFromGUID("c28f42")
   RzoneCards = {}
   WzoneCards = {}
   GzoneCards = {}
   timerTick = 0
end

function onPlayerChangedColor(col) --TEMPFUNCTION
   if col == "Grey" then
      return
   end
   local id = tostring(Player[col].steam_id)
   if id == "76561198041312957" or id == "76561198040185465" then
      broadcastToAll("Player " .. Player[col].steam_name .. " has been promoted\nbecause he/she is a developer.",{1,0,0})
      Player[col].promote()
   end
end

function onSave()
	local tbl = {Index,Turn}
	return JSON.encode(tbl)
end

function lockObjects()
	for i, list in ipairs(objectLockdown) do
		getObjectFromGUID(list).interactable = false
	end
end

function Reset()
	Index = 0
	Turn = "Off"
	UpdateDesplay()
	if #Mods > 0 then
		for i,Obj in ipairs(Mods) do
		Obj.call("Reset",{})
		end
	end
end

function RegisterMod(tbl)
	table.insert(Mods,getObjectFromGUID(tbl[1]))
	print("Registerd: " .. getObjectFromGUID(tbl[1]).getName())
end

function onObjectEnterScriptingZone(Zone, Object)
    if Zone == Rzone then
        if #RzoneCards == 0 then
            delayedCallback("SendCards",{"Rzone"}, 0.5)
        end
        table.insert(RzoneCards,Object)
    elseif Zone == Wzone then
        if #WzoneCards == 0 then
            delayedCallback("SendCards",{"Wzone"}, 0.5)
        end
        table.insert(WzoneCards,Object)
    elseif Zone == Gzone then
        if #GzoneCards == 0 then
            delayedCallback("SendCards",{"Gzone"}, 0.5)
        end
        table.insert(GzoneCards,Object)
    end
end

function SendCards(tbl)
    if tbl[1] == "Rzone" then
        for i, Obj in ipairs(Mods) do
            Obj.call("onObjectEnterRedZone",RzoneCards)
        end
        RzoneCards = {}
    elseif tbl[1] == "Wzone" then
        for i, Obj in ipairs(Mods) do
            Obj.call("onObjectEnterWhiteZone",WzoneCards)
        end
        WzoneCards = {}
    elseif tbl[1] == "Gzone" then
        for i, Obj in ipairs(Mods) do
            Obj.call("onObjectEnterGreyZone",GzoneCards)
        end
        GzoneCards = {}
    end
end

function SetTurn(tbl) -- tbl[1] = color
	for i,set in ipairs(Order) do
		if set.color == tbl[1] then
			Index = i
			Turn = set.color
			UpdateDesplay()
		end
	end
end

function NextPlayer(tbl) --tbl[1] = true/false
	if tbl[1] == true then
		Index = Index -1
		if Index <= 0 then
			Index = #Order
		end
		Turn = Order[Index].color
		if Player[Turn].seated == false then
			NextPlayer(tbl)
			return
		end
		UpdateDesplay()
	else
		Index = Index +1
		if Index > #Order then
			Index = 1
		end
		Turn = Order[Index].color
		if Player[Turn].seated == false then
			NextPlayer(tbl)
			return
		end
		UpdateDesplay()
	end
	broadcastToAll("It's " .. Player[Turn].steam_name .. " turn.",stringColorToRGB(Turn))
end

function UpdateDesplay()
	for i,set in ipairs(Order) do
		if Index == i then
			set.Obj.setColorTint(stringColorToRGB(set.color))
		else
			set.Obj.setColorTint({0,0,0})
		end
	end
end

function delayedCallback(fname,params,delay)
    timerTick = timerTick + 1
    params.id = ('timer_global' .. timerTick)
    Timer.create({identifier=params.id,function_owner=self, function_name=fname, parameters=params, delay=delay})
    return params.id
end
