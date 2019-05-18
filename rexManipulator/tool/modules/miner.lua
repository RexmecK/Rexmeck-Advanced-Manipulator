require "/scripts/vec2.lua"

miner = {}
miner.beaming = 0
miner.snap = {nil,nil}
miner.startSnap = nil
miner.aimpos = {0,0}
miner.snapSensitivity = 0.25
--extra api-----------------------------

function math.round(x)
    if x%2 ~= 0.5 then
      return math.floor(x+0.5)
    end
    return x-0.5
end

function vec2.round(vector)
    return { math.round(vector[1]), math.round(vector[2]) }
end

function vec2.max(vector, max)
    return { math.max(vector[1], max[1]), math.max(vector[2],max[2]) }
end


--------------------------------------

function miner:init() end

function miner:update(dt, fireMode, shift, moves)
    self.aimpos = activeItem.ownerAimPosition()
    if self.snap[1] then self.aimpos[1] = self.snap[1] end -- some refactorings could do maybe later
    if self.snap[2] then self.aimpos[2] = self.snap[2] end
    
    if not shift or self.activated then
        self.activated = true
        if shift then
            if not self.startSnap then self.startSnap = self.aimpos end

            if not self.snap[1] and not self.snap[2] then
                if  (self.startSnap[1] + self.snapSensitivity < self.aimpos[1]) or (self.startSnap[1] - self.snapSensitivity > self.aimpos[1]) then
                    self.snap[2] = self.startSnap[2]
                elseif  (self.startSnap[2] + self.snapSensitivity < self.aimpos[2]) or (self.startSnap[2] - self.snapSensitivity > self.aimpos[2]) then
                    self.snap[1] = self.startSnap[1]
                end
            end
        else
            if self.startSnap then self.startSnap = nil end
            if self.snap[1] then self.snap[1] = nil end
            if self.snap[2] then self.snap[2] = nil end
        end

        if fireMode == "primary" then
            miner:OnPress("foreground")
        elseif fireMode == "alt" then
            miner:OnPress("background")
        else
            self.activated = false
            self.beaming = lerp(self.beaming, 0, 4)
        end
    else
        self.activated = false
        if self.startSnap then self.startSnap = nil end
        if self.snap[1] then self.snap[1] = nil end
        if self.snap[2] then self.snap[2] = nil end
        self.beaming = lerp(self.beaming, 0, 4)
    end

end

function miner:OnPress(layer)
    local mode = self:getMode()
    if mode == 1 then
        self:mineAt(self.aimpos, true, layer)
        self.beaming = lerp(self.beaming, 1, 2)
    elseif mode == 2 then
        self:paintMaterial(self.aimpos, true, layer, self:getSBPaint())
        self.beaming = lerp(self.beaming, 1, 2)
    elseif mode == 3 then
        local placing = self:getPlacing()
        if placing.type == "material" then
            self:placeMaterial(self.aimpos, true, layer, placing.name)
        elseif placing.type == "mod" then
                self:tileMod(self.aimpos, true, layer, placing.name)
        elseif placing.type == "liquid" then
            local liquidid = root.liquidId(placing.name)
            if liquidid then
                self:placeLiquid(self.aimpos, true, liquidid)
            end
        end
        self.beaming = lerp(self.beaming, 1, 2)
    elseif mode == 4 then
        local placing = self:getPlacing()
        if placing.type == "material" then
            self:filterMine(self.aimpos, true, layer, placing.name)
            self.beaming = lerp(self.beaming, 1, 2)
        elseif placing.type == "mod" then
                self:filterMineMod(self.aimpos, true, layer, placing.name)
                self.beaming = lerp(self.beaming, 1, 2)
        elseif placing.type == "liquid" then
            self:filterLiquid(self.aimpos, true, placing.name)
            self.beaming = lerp(self.beaming, 1, 2)
        end
        
        self.beaming = lerp(self.beaming, 1, 2)
    elseif mode == 5 then
        local result = self:eyedrop(self.aimpos,layer)
        if not result then return end
        self.beaming = lerp(self.beaming, 1, 2)
    end
end

function miner:uninit() end

--preferred properties

miner.mode = 1
miner.modes = {"mine", "paint", "tile", "filter", "eyedropper"}

function miner:onModeUpdate()
    if self.mode == 1 then
        self:setColor(self:getPrimaryColor())
    elseif self.mode == 2 then
        self:setColor(self:getPaintColor())
    elseif self.mode == 3 then
        self:setColor(self:getPrimaryColor())
    elseif self.mode == 4 then
        self:setColor(self:getPrimaryColor())
    elseif self.mode == 5 then
        self:setColor({0,0,0,0})
    end
end

function miner:setMode(a)
    self.mode = math.max(math.min(a, #self.modes), 1)
    self:onModeUpdate()
end

function miner:getMode()
    return self.mode
end

function miner:getModeName()
    return self.modes[self.mode]
end

miner.paint = 1

miner.paintColors = {
    {33,33,33,128},--"333f", --invisible
    {255,0,0,255},--"f00f", --red
    {0,0,255,255},--"00ff", --blue
    {0,255,0,255},--"0f0f", --green
    {255,255,0,255},--"ff0f", --yellow
    {255,128,0,255},--"f80f", --orange
    {210, 45, 193, 255},--"d22dc1ff", --pink
    {0,0,0,255},--"000f", --black
    {255,255,255,255}--"ffff", --white
}

function miner:onPaintUpdate()
    if self:getModeName() == "paint" then
        self:onModeUpdate()
    end
end

function miner:setPaint(a)
    self.paint = math.max(math.min(a, #self.paintColors), 1)
    self:onPaintUpdate()
end

function miner:getPaint()
    return self.paint
end

function miner:getSBPaint() -- this is for starbound paint index
    return self.paint - 1
end

function miner:getPaintColor()
    return self.paintColors[self.paint]
end

function miner:getMode()
    return self.mode
end

miner.placing = {name = "dirt", type = "material"}

function miner:setPlacing(a)
    self.placing = a
end

function miner:getPlacing(a)
    return self.placing
end

function miner:getSnapAxis()
    if self.snap[1] then
        return 2
    elseif self.snap[2] then
        return 1
    end
    return false
end

miner.color = {255,255,255}

function miner:setColor(color)
    self.color = color
    if not self.color[4] then self.color[4] = 255 end
end

function miner:getColor()
    if not self.color[4] then self.color[4] = 255 end
    return self.color
end

miner.primaryColor = {255,255,255}

function miner:setPrimaryColor(color)
    self.primaryColor = color
    if not self.primaryColor[4] then self.primaryColor[4] = 255 end
end

function miner:getPrimaryColor()
    if not self.primaryColor[4] then self.primaryColor[4] = 255 end
    return self.primaryColor
end

miner.secondaryColor = {255,255,255}

function miner:setSecondaryColor(color)
    self.secondaryColor = color
    if not self.secondaryColor[4] then self.secondaryColor[4] = 255 end
end

function miner:getSecondaryColor()
    if not self.secondaryColor[4] then self.secondaryColor[4] = 255 end
    return self.secondaryColor
end

miner.beamStart = nil

function miner:setBeamPartProperty(a)
    self.beamStart = a
end
function miner:getBeamPartProperty()
    return self.beamStart
end


miner.size = {3,3}

function miner:setSize(size)
    self.size = vec2.max(vec2.round(size), {1,1})
end

function miner:getSize()
    return self.size
end

miner.itemDrops = 0

function miner:setItemDrops(a)
    self.itemDrops = a
end

function miner:getItemDrops()
    if self.itemDrops then
        return 1
    end
    return 0
end

--for block rounding
function miner:getMinePos(pos, centered)
    if centered then
        pos = vec2.sub(pos, vec2.div(self.size, 2))
    end
    return vec2.sub(vec2.round(pos), {0.5, 0.5})
end

--gets the regions display for mining
function miner:getPoly(pos, centered) --for display purposes
    pos = self:getMinePos(pos, centered)

    local ret = {}

    ret[1] = vec2.add(pos, {0.5,0.5}) --bottom left
    ret[2] = vec2.add(pos, {self.size[1]+0.5,0.5}) --bottom right
    ret[3] = vec2.add(pos, {self.size[1]+0.5,self.size[2]+0.5}) --top right 
    ret[4] = vec2.add(pos, {0.5,self.size[2]+0.5})  -- top left

    return ret
end


--actions (area size is set by miner:setSize(vec2))

function miner:eyedrop(aimpos,layer)
    local mat = world.material(aimpos, layer)
    local liquid = world.liquidAt(aimpos)
    if mat then
        self:setPlacing({type = "material", name = mat})
        return true
    elseif liquid and liquid[1] then
        local liquidname = root.liquidName(liquid[1])
        self:setPlacing({type = "liquid", name = liquidname})
        return true
    end
end

function miner:paintMaterial(pos, centered, layer, color)
    pos = self:getMinePos(pos, centered)

    for x = 1, self.size[1] do
        for y = 1, self.size[2] do
            world.setMaterialColor({pos[1] + x,pos[2] + y}, layer, color)
        end
    end
end

function miner:tileMod(pos, centered, layer, modName, hueShift, allowOverlap)
    pos = self:getMinePos(pos, centered)

    for x = 1, self.size[1] do
        for y = 1, self.size[2] do
            world.placeMod({pos[1] + x,pos[2] + y}, layer, modName, hueShift, allowOverlap)
        end
    end
end


function miner:placeMaterial(pos, centered, layer, material)
    pos = self:getMinePos(pos, centered)

    for x = 1, self.size[1] do
        for y = 1, self.size[2] do
            world.placeMaterial({pos[1] + x,pos[2] + y}, layer, material, 0, true)
        end
    end
end

function miner:placeLiquid(pos, centered, liquidid)
    pos = self:getMinePos(pos, centered)

    for x = 1, self.size[1] do
        for y = 1, self.size[2] do
            world.spawnLiquid({pos[1] + x,pos[2] + y}, liquidid, 1)
        end
    end
end

function miner:filterLiquid(pos, centered, liquidname)
    pos = self:getMinePos(pos, centered)

    for x = 1, self.size[1] do
        for y = 1, self.size[2] do
            local ll = world.liquidAt({pos[1] + x,pos[2] + y})
            if ll and ll[1] and root.liquidName(ll[1]) == liquidname then
                world.destroyLiquid({pos[1] + x,pos[2] + y})
            end
        end
    end
end


function miner:filterMine(pos, centered, layer, material)
    pos = self:getMinePos(pos, centered)

    local listpos = jarray()
    for x = 1, self.size[1] do
        for y = 1, self.size[2] do
            local mat = world.material({pos[1] + x,pos[2] + y}, layer)
            if tostring(mat) == material then table.insert(listpos, {pos[1] + x,pos[2] + y}) end
        end
    end
    
    self:mine(listpos, layer)
end

function miner:filterMineMod(pos, centered, layer, modname)
    pos = self:getMinePos(pos, centered)

    local listpos = jarray()
    for x = 1, self.size[1] do
        for y = 1, self.size[2] do
            local mod = world.mod({pos[1] + x,pos[2] + y}, layer)
            if tostring(mod) == modname then table.insert(listpos, {pos[1] + x,pos[2] + y}) end
        end
    end
    
    self:mine(listpos, layer)
end

function miner:mineAt(pos, centered, layer)
    pos = self:getMinePos(pos, centered)

    local listpos = jarray()
    for x = 1, self.size[1] do
        for y = 1, self.size[2] do
            local pos = {pos[1] + x,pos[2] + y}
            if world.material(pos, layer) then
                table.insert(listpos, pos)
            end
        end
    end
    self:mine(listpos, layer)
end

function miner:mine(listpos, layer, harvestlevel)
    world.damageTiles(listpos, layer, {0,0}, "explosive", 10000, self:getItemDrops())
end

addClass("miner")