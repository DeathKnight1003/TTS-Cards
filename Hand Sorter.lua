function onLoad()
    ace = 15
    mode = true --true= number
    Color = nil
    offset = {6,1,0}
    self.createButton({
        label="Suits", click_function="StartSortS", function_owner=self,
        position={-1.5,0.19,0}, rotation={0,0,0}, width=600, height=450, font_size=200
    })
    
    self.createButton({
        label="Numbers", click_function="StartSortN", function_owner=self,
        position={0,0.19,0}, rotation={0,0,0}, width=800, height=450, font_size=200
    })
    
    self.createButton({
        label="Ace:H", click_function="Ace", function_owner=self,
        position={1.5,0.19,0}, rotation={0,0,0}, width=600, height=450, font_size=200
    })
end

function Ace()
    if ace == 1 then
        ace = 15
        self.editButton({index=2,label="Ace:H"})
    else
        ace = 1
        self.editButton({index=2,label="Ace:L"})
    end
end

function autoS(tbl)
    StartSortS(self,tbl[1])
end

function autoN(tbl)
    StartSortN(self,tbl[1])
end

function StartSortS(o,color) 
    Color = color
    mode = false
    startLuaCoroutine(self,"Sort")
end

function StartSortN(o,color) 
    Color = color
    mode = true
    startLuaCoroutine(self,"Sort")
end

function Sort()
    local color = Color
    local mode2 = mode
    local hand = {}
    local cards = Player[color].getHandObjects()
    local rot = Player[color].getHandTransform(1).rotation
    rot.y = rot.y + 180
    for i, card in ipairs(cards) do
        local Split = stringSplit(card.getDescription(), "%S+")
        if mode2 == false then -- mode suit
            if Split[1] == "A" then
                local num = ace + (tonumber(Split[2])*100)
                table.insert(hand,{num,card.guid})
            else
                local num = tonumber(Split[1]) + (tonumber(Split[2])*100)
                table.insert(hand,{num,card.guid})
            end
        else --mode number
            if Split[1] == "A" then
                local num = (ace*100) + tonumber(Split[2])
                table.insert(hand,{num,card.guid})
            else
                local num = (tonumber(Split[1])*100) + tonumber(Split[2])
                table.insert(hand,{num,card.guid})
            end
        end
    end
    local keys = {}
    for k in pairs(hand) do table.insert(keys, k) end
    table.sort(keys, function(a, b) return hand[a][1] > hand[b][1] end)
    local sorted = {}
    for _, k in ipairs(keys) do table.insert(sorted, {hand[k][2]}) end
    
    for i, id in ipairs(reverseTable(sorted)) do
        local obj = getObjectFromGUID(id[1])
        waitFrames(1)
        obj.setRotation(rot)
        obj.setPosition(rotateLocalCoordinates(offset,color))
    end
    return 1
end

function stringSplit(s, pattern)
    local t = {}
    for i in string.gmatch(s, pattern) do
        table.insert(t, i)
    end
    return t
end

function waitFrames(frames)
    while frames > 0 do
    coroutine.yield(0)
    frames = frames - 1
    end
end

function rotateLocalCoordinates(desiredPos,color)
    local objPos, objRot = Player[color].getHandTransform().position, Player[color].getHandTransform().rotation
    local angle = -math.rad(objRot.y)
	local x = desiredPos[1] * math.cos(angle) - desiredPos[3] * math.sin(angle)
	local z = desiredPos[1] * math.sin(angle) + desiredPos[3] * math.cos(angle)
	return {objPos.x+x, objPos.y+desiredPos[2], objPos.z+z}
end

function reverseTable(table)
	local length = #table
	local reverse = {}
	for i, v in ipairs(table) do
		reverse[length + 1 - i] = v
	end
	return reverse
end