local oldInit = init or function() end
local oldUpdate = update or function() end
local clearDrawables = function() end
local cleared = false

require "/scripts/vec2.lua"

function init()
	local result, ret = pcall(oldInit)
	clearDrawables = localAnimator.clearDrawables
	localAnimator.clearDrawables = function()
		cleared = true
		clearDrawables()
	end
	if not result then
		sb.logError(tostring(ret))
		oldInit = function() end
	end

end

function update(...)
	local lines = status.statusProperty("rexManipulatorLines", {})
	
	local result, ret = pcall(oldUpdate, ...)
	if not result then
		sb.logError(tostring(ret))
		oldUpdate = function() end
	end
	if not cleared then
		clearDrawables()
	end
	if lines and player.id() and world.entityExists(player.id()) then
		local playerPos = world.entityPosition(player.id()) 
		for i,v in pairs(lines) do
			localAnimator.addDrawable(
				{
					line = {vec2.sub(v.startPosition, playerPos), vec2.sub(v.endPosition, playerPos)},
					color = v.color or {255,255,255,255},
					fullbright = true,
					width = v.width or 1
				},
				"Overlay"
			)
		end
	end
	cleared = false
end