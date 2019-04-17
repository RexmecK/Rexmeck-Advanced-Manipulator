widgetCallbacks = {}

function call(wid)
    if type(widgetCallbacks[wid]) == "function" then
        widgetCallbacks[wid]()
    end
end



ownerManipulatorInstance = {}
ownerManipulatorUuid = nil
ownerId = nil

-- -1 needs check
-- 0 not alive
-- 1 checking
ownerStatus = -1
ALIVERPC = nil

function init()
    ownerId = config.getParameter("ownerId")
    ownerManipulatorUuid = config.getParameter("ownerManipulatorUuid")
    ownerManipulatorInstance = config.getParameter("ownerManipulatorInstance")
    pcall(setUIColor, status.statusProperty("rex_ui_color", themeColor))
	shiftingEnabled = status.statusProperty("rex_ui_rainbow", false)
	
    updateInfo()
end

function update(dt)
	shiftUI(dt)
    checkMMStatus()
end

function uninit()

end

--

MMModes = {
    "Mining",
    "Painting",
    "Placing Blocks",
    "Filter Mining",
    "Eyedropper",
}

PaintColors = {
    "333f", --invisible
    "f00f", --red
    "00ff", --blue
    "0f0f", --green
    "ff0f", --yellow
    "f80f", --orange
    "d22dc1ff", --pink
    "000f", --black
    "ffff", --white
}

ModeButtons = {
	{"selectmine"          , "/rexManipulator/ui/main/image/mine.png"},
	{"selectpaint"        , "/rexManipulator/ui/main/image/paint.png"},
	{"selectplace"         , "/rexManipulator/ui/main/image/place.png"},
	{"selectfilter"        , "/rexManipulator/ui/main/image/filtermine.png"},
	{"selecteyedropper"    , "/rexManipulator/ui/main/image/eyedropper.png"},
}

function updateButtonMode(mode)
    for i,v in pairs(ModeButtons) do
        if i == mode then
            _buttons[v[1]] = v[2].."?replace;ff3c3c=333;343434="..themeColor
        else
            _buttons[v[1]] = v[2] 
        end
    end
    setUIColor("")
end

function updateInfo()
    widget.setText("h1", "^#343434;Mode: "..MMModes[ownerManipulatorInstance.mode])
    widget.setText("mine_size", tostring(ownerManipulatorInstance.size[1]))
    updateButtonMode(ownerManipulatorInstance.mode)
    widget.setImage("paintcolor", "/rexManipulator/ui/main/image/color.png?setcolor="..PaintColors[ownerManipulatorInstance.paint])
end

pendingInstanceChange = false
function checkMMStatus()
    if ownerStatus == 0 then
        pane.dismiss()
    elseif ownerStatus == -1 and ownerId and world.entityExists(ownerId) then
        ALIVERPC = world.sendEntityMessage(ownerId, "advMM.alive")
        ownerStatus = 1
    elseif ownerStatus == 1 then
        if ALIVERPC:finished() then
            local result = ALIVERPC:result()
            if result and result == ownerManipulatorUuid then -- is alive
                if pendingInstanceChange then
                    world.sendEntityMessage(ownerId, "advMM.setInstanceChanges", pendingInstanceChange)
                    pendingInstanceChange = false
                end
                ownerStatus = -1
                ALIVERPC = nil
            else
                ownerStatus = 0
                ALIVERPC = nil
            end
        end
    elseif not ownerId then
        pane.dismiss()
    end
end



function MMgetInstance(name)
    return ownerManipulatorInstance[name]
end

function MMsetInstance(name, b)
    ownerManipulatorInstance[name] = b
    if not pendingInstanceChange then
        pendingInstanceChange = {}
    end
    pendingInstanceChange[name] = b
    updateInfo()
end

--



require("/scripts/vec2.lua")
require("/scripts/util.lua")

widgetCallbacks["selectmine"] = function()
    MMsetInstance("mode", 1)
end

widgetCallbacks["selectpaint"] = function()
    MMsetInstance("mode", 2)
end

widgetCallbacks["selectplace"] = function()
    MMsetInstance("mode", 3)
end

widgetCallbacks["selectfilter"] = function()
    MMsetInstance("mode", 4)
end

widgetCallbacks["selecteyedropper"] = function()
    MMsetInstance("mode", 5)
end

function vec2.max(vector, max)
    return { math.max(vector[1], max[1]), math.max(vector[2],max[2]) }
end

function vec2.min(vector, min)
    return { math.min(vector[1], min[1]), math.min(vector[2],min[2]) }
end

widgetCallbacks["mine_size"] = function()
    local num = tonumber(widget.getText("mine_size"))
    if not num then return end
    MMsetInstance("size", {num,num} )
end

widgetCallbacks["mine+"] = function()
    MMsetInstance("size", vec2.min(vec2.add(ownerManipulatorInstance.size, {1,1}), {99,99}) )
end

widgetCallbacks["mine-"] = function()
    MMsetInstance("size", vec2.max(vec2.add(ownerManipulatorInstance.size, {-1,-1}), {1,1}) )
end

widgetCallbacks["paint+"] = function()
    MMsetInstance("paint", util.wrap(ownerManipulatorInstance.paint + 1, 1, #PaintColors) )
end

widgetCallbacks["paint-"] = function()
    MMsetInstance("paint", util.wrap(ownerManipulatorInstance.paint - 1, 1, #PaintColors) )
end


widgetCallbacks["placepick"] = function()
    local ui = root.assetJson("/rexManipulator/ui/blockpicker/pane.json")
    ui.ownerId = ownerId
    ui.ownerManipulatorUuid = ownerManipulatorUuid
    ui.ownerManipulatorInstance = ownerManipulatorInstance
    player.interact("ScriptPane", ui)
end


require("/rexManipulator/ui/color.lua")

themeColor = "72e372"

_buttons = {
	close = "/rexManipulator/ui/main/image/x.png",
	selectmine = "/rexManipulator/ui/main/image/mine.png",
	selectpaint = "/rexManipulator/ui/main/image/paint.png",
	selectplace = "/rexManipulator/ui/main/image/place.png",
	selectfilter = "/rexManipulator/ui/main/image/filtermine.png",
	selecteyedropper = "/rexManipulator/ui/main/image/eyedropper.png",
	["mine+"] = "/rexManipulator/ui/main/image/right.png",
	["mine-"] = "/rexManipulator/ui/main/image/left.png",
	["paint+"] = "/rexManipulator/ui/main/image/right.png",
	["paint-"] = "/rexManipulator/ui/main/image/left.png",
	["placepick"] = "/rexManipulator/ui/main/image/pickbutton.png",
}

_images = {
	background1 = "/rexManipulator/ui/main/image/bg.png",
	headerover = "/rexManipulator/ui/main/image/header.png"
}

_texts = {
	"mine_size"
}

function setUIColor(dr)

	if dr == "" then
		dr = themeColor
	end
	
	for i,v in pairs(_buttons) do
		widget.setButtonImages(i, {base = v.."?replace;ff3c3c="..dr, hover = v.."?replace;ff3c3c="..dr.."?brightness=60", pressed = v.."?replace;ff3c3c="..dr.."?brightness=60"})
		widget.setFontColor(i,"#"..dr)
	end
	
	for i,v in pairs(_images) do
		widget.setImage(i, v.."?replace;ff3c3c="..dr)
	end
	
	for i,v in pairs(_texts) do
		widget.setFontColor(v, "#"..dr)
	end
	
	for i,v in pairs(objlist or {}) do
		widget.setFontColor("objects.list."..v.name..".name", "#"..dr)
		
		
		if v.type == "number" then
			widget.setImage("objects.list."..v.name..".icon", "/itemeditork/type/int.png?replace;ff3c3c="..dr)
		elseif v.type == "string" then
			widget.setImage("objects.list."..v.name..".icon", "/itemeditork/type/string.png?replace;ff3c3c="..dr)
		elseif v.type == "boolean" then
			widget.setImage("objects.list."..v.name..".icon", "/itemeditork/type/boolean.png?replace;ff3c3c="..dr)
		elseif v.type == "object" then
			widget.setImage("objects.list."..v.name..".icon", "/itemeditork/type/obj.png?replace;ff3c3c="..dr)
		elseif v.type == "array" then
			widget.setImage("objects.list."..v.name..".icon", "/itemeditork/type/array.png?replace;ff3c3c="..dr)
		end
		
	end
	
	themeColor = dr

end

