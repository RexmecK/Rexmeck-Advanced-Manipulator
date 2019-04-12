manipulatorCore = {}
manipulatorCore.uuid = ""
manipulatorCore.anibeamed = false
manipulatorCore.InterfaceCooldown = 0 --prevents duped interface

function manipulatorCore:init()
    self.uuid = sb.makeUuid()
    self:setupMessages()
    self:loadConfig()
    self:loadInstanceConfig()
    self:initAim()
    self:receiveInstanceConfigChanges(self.instanceConfig)


    miner:setBeamPartProperty(self.config.beamStart)
    miner:setPrimaryColor(self.config.primaryColor)
    miner:setSecondaryColor(self.config.secondaryColor)
    miner:onModeUpdate()
    
    selfItem.rootDirectory = config.getParameter("thisDirectory", "/")

    if type(self.config.customScript) == "string" then
        manipulatorRequire(self.config.customScript)
        if type(manipulator) == "table" then
            manipulator.localDirectory = config.getParameter("thisDirectory", "/")
            if type(manipulator.init) == "function" then
                manipulator:init()
            end
        end
    end

end

function manipulatorCore:update(dt, fireMode, shift, moves)
    self:updateAim(dt, fireMode, shift, moves)


    self.InterfaceCooldown = math.max(self.InterfaceCooldown - dt, 0)

    if type(manipulator) == "table" and type(manipulator.update) == "function" then
        manipulator:update(dt, fireMode, shift, moves)
    end
    
    self.instanceConfig.placing = miner:getPlacing()
end

function manipulatorCore:uninit()
    if type(manipulator) == "table" and type(manipulator.uninit) == "function" then
        manipulator:uninit()
    end
    self:saveInstanceConfig()
end

function manipulatorCore:activate(fireMode, shift)
    if type(manipulator) == "table" and type(manipulator.activate) == "function" then
        manipulator:activate(fireMode, shift)
    end
    
    if shift then
        if fireMode == "primary" then
            self:openInterface()
        end
    end
end

--

manipulatorCore.config = {
    beamStart = {"head", "beamPoint"},
    primaryColor = {200,139,40,255},
    secondaryColor = {255,255,255,255}
}

manipulatorCore.instanceConfig = {
    size = {3,3},
    paint = 2,
    placing = {name = "dirt", type = "material"},
    mode = 1, --mine, color, tile
}

function manipulatorRequire(script) require(pD(script)) end

function manipulatorCore:loadConfig()
    local itemconfig = config.getParameter("manipulator")
    if not itemconfig then return end

    self.config.beamStart = itemconfig.beamStart

    self.config.primaryColor = itemconfig.primaryColor
    if not self.config.primaryColor[4] then self.config.primaryColor[4] = 255 end

    self.config.secondaryColor = itemconfig.secondaryColor
    if not self.config.secondaryColor[4] then self.config.secondaryColor[4] = 255 end

    self.config.customScript = itemconfig.customScript
end

function manipulatorCore:loadInstanceConfig()
    local conf = config.getParameter("manipulator_instance")
    if not conf then return end
    for i,v in pairs(conf) do
        if type(v) == type(self.instanceConfig[i]) then
            self.instanceConfig[i] = v
        end
    end
end

function manipulatorCore:saveInstanceConfig()
    activeItem.setInstanceValue("manipulator_instance", self.instanceConfig)
end

function manipulatorCore:receiveInstanceConfigChanges(config) --events
    for i,v in pairs(config) do
        self.instanceConfig[i] = v
        if i == "size" then miner:setSize(v) 
        elseif i == "paint" then miner:setPaint(v)
        elseif i == "placing" then miner:setPlacing(v)
        elseif i == "mode" then miner:setMode(v) end
    end
end

function manipulatorCore:setupMessages()
    message.setHandler("advMM.getInstance", function(_, loc, a) if not loc then return end return self.instanceConfig[a] end)
    message.setHandler("advMM.setInstance", function(_, loc, a, b) if not loc then return end self.instanceConfig[a] = b end)
    message.setHandler("advMM.setPlacing", function(_, loc, a) if not loc then return end self.instanceConfig["placing"] = a miner:setPlacing(a) end)
    message.setHandler("advMM.setInstanceChanges", function(_, loc, a) if not loc then return end self:receiveInstanceConfigChanges(a) end)
    message.setHandler("advMM.alive", function(_, loc, a, b) if not loc then return end self.InterfaceCooldown = 0.5 return self.uuid end)
end


function manipulatorCore:openInterface()
    if self.InterfaceCooldown == 0 then
        self.InterfaceCooldown = 2
		local ui = root.assetJson("/rexManipulator/ui/main/pane.json")
		ui.ownerId = activeItem.ownerEntityId()
		ui.ownerManipulatorUuid = self.uuid
		ui.ownerManipulatorInstance = self.instanceConfig
        player.interact("ScriptPane", ui)
    end
end

function manipulatorCore:initAim()
    local aimAngle, dir = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
    aim.current = math.deg(aimAngle)
    aim.direction = dir
    aim.anglesmooth = 8
end

function manipulatorCore:updateAim(dt)
    local aimAngle, dir = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
    aim.target = math.deg(aimAngle)
    aim.direction = dir
end



addClass("manipulatorCore")