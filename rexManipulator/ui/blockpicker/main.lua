widgetCallbacks = {}

function widgetCallbacks.search()
    local text = widget.getText("search")
    querySearch(text)
end

function widgetCallbacks.pick()
    local sel = objects:getSelected()
    if not sel then return end
    world.sendEntityMessage(ownerId, "advMM.setPlacing", tileList[sel])
    pane.dismiss()
end

function call(wid)
    if type(widgetCallbacks[wid]) == "function" then
        widgetCallbacks[wid]()
    end
end

objects = {}

function split(inputstr, sep) 
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
return t
end

function getDirectoryOnly(path)
    local s = split(path, "/")
    local str = ""
    for i=1,#s do
        if #s <= i then str = str.."/" break end
        str = str.."/"..s[i]
    end
    return str
end


function vDir(str, dir)
	if string.sub(str,1,1) == "/" then
		return str
	end
	return dir..str
end

tileList = {}
function loadTileList()
    for i,v in pairs( root.assetJson("/rexManipulator/tiles.json" , {}) ) do
        if v.name and v.type then
            local c = false

            if v.type == "material" then 
                local e, matconfig = pcall(root.materialConfig, v.name)
                if e and matconfig then
                    if matconfig.config.itemDrop then
                        local conf2 = root.itemConfig({name = matconfig.config.itemDrop, count = 1}) 
                        if type(conf2.config.inventoryIcon) ~= "string" then conf2.config.inventoryIcon = "/assetmissing.png"  end
                        c = {shortdescription = conf2.config.shortdescription or v.name, image = vDir(conf2.config.inventoryIcon, conf2.directory)}
                    else
                        c = {shortdescription = matconfig.config.shortdescription or v.name, image = "/assetmissing.png"}
                    end
                else
                    sb.logError("Could not fetch material config %s!", v.name)
                end
            elseif v.type == "liquid" then 
                local  e, liquidConfig = pcall(root.liquidConfig, v.name)
                if e and liquidConfig then
                    if liquidConfig.config.itemDrop then
                        local conf2 = root.itemConfig({name = liquidConfig.config.itemDrop, count = 1}) 
                        if type(conf2.config.inventoryIcon) ~= "string" then conf2.config.inventoryIcon = liquidConfig.config.texture  end
                        c = {shortdescription = conf2.config.shortdescription or v.name, image = vDir(conf2.config.inventoryIcon, conf2.directory)}
                    else
                        c = {shortdescription = v.name, image = vDir(liquidConfig.config.texture, getDirectoryOnly(liquidConfig.path))}
                    end
                else
                    sb.logError("Could not fetch matmod config %s!", v.name)
                end
            elseif v.type == "mod" then 
                local  e, modConfig= pcall( root.modConfig, v.name)
                
                if e and modConfig then
                    if modConfig.config.itemDrop then
                        local conf2 = root.itemConfig({name = modConfig.config.itemDrop, count = 1}) 
                        if type(conf2.config.inventoryIcon) ~= "string" then conf2.config.inventoryIcon = "/assetmissing.png" end
                        c = {shortdescription = conf2.config.shortdescription or v.name, image = vDir(conf2.config.inventoryIcon, conf2.directory)}
                    else
                        c = {shortdescription = v.name, image = "/assetmissing.png"}
                    end
                else
                    sb.logError("Could not fetch liquid config %s!", v.name)
                end
            else
                sb.logError("Unknown Type: %s!", v.type)
            end

            if type(c) == "table" then
                tileList[v.name] = {name = v.name, shortdescription = c.shortdescription or v.name,image = c.image, type = v.type}
            end
        end
    end
end

-- -1 needs check
-- 0 not alive
-- 1 checking
ownerStatus = -1
ALIVERPC = nil

function init()
    objects = newlist("objects")
    ownerId = config.getParameter("ownerId")
    loadTileList()
    ownerManipulatorUuid = config.getParameter("ownerManipulatorUuid")
    ownerManipulatorInstance = config.getParameter("ownerManipulatorInstance")
    pcall(setUIColor, status.statusProperty("rex_ui_color", themeColor))
	shiftingEnabled = status.statusProperty("rex_ui_rainbow", false)
    querySearch("")
end

function update(dt)
	shiftUI(dt)
    checkMMStatus()
end

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


function queryTable(tab, func)
    local q = {}
    for i,v in pairs(tab) do
        if func(v) then
            table.insert(q, v)
        end
    end
    return q
end

function removePatterns(s)
    s = s:gsub("%%", "%%")
    for i,v in pairs({
        "%.",
        "%(",
        "%)",
        "%+",
        "%-",
        "%*",
        "%?",
        "%[",
        "%]",
        "%^",
        "%$",
    }) do
        s = s:gsub(v,"%"..v)
    end

    return s
end

function querySearch(matches)
    objects:clear()
    matches = removePatterns(matches)
    local listQuery = queryTable(tileList, 
        function(v) 
            if not v.shortdescription or type(v.shortdescription) ~= "string" then return end   
            return v.shortdescription:upper():match(matches:upper()) 
        end
    )
    for i,v in pairs(listQuery) do
        local id = objects:add(v.name)
        widget.setText("objects.list."..id..".name", v.shortdescription)
        widget.setImage("objects.list."..id..".icon", v.image)
    end
end


function newlist(path)
    widget.clearListItems(path)
    local n = {
        path = path,
        _list = {},
        _indexIds = {}
    }

    function n:clear()
        self._list = {}
        self._indexIds = {}
        widget.clearListItems(self.path..".list")
    end

    function n:getSelected()
        local sel = widget.getListSelected(self.path..".list")
        if not sel then return false end
        return self._list[sel]
    end

    function n:indexId(name)
        for i,v in pairs(self._list) do
            if v == name then return i end
        end
    end

    function n:add(name)
        local id = widget.addListItem(self.path..".list")
        widget.setFontColor("objects.list."..id..".name","#"..themeColor)
        self._list[id] = name
        table.insert(self._indexIds, id)
        return id
    end
    return n
end



require("/rexManipulator/ui/color.lua")

themeColor = "72e372"

_buttons = {
	close = "/rexManipulator/ui/blockpicker/image/x.png",
	pick = "/rexManipulator/ui/blockpicker/image/buttonpick.png",
}

_images = {
	bg2 = "/rexManipulator/ui/blockpicker/image/bg.png",
	headerover = "/rexManipulator/ui/blockpicker/image/header.png"
}

_texts = {
    "search"
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
	
	for i,v in pairs(objects._list or {}) do
		widget.setFontColor("objects.list."..i..".name", "#"..dr)
	end
	
	themeColor = dr

end




