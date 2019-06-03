local oldInit = init or function() end
local oldUpdate = update or function() end


require "/scripts/vec2.lua"

function init()
	oldInit()
end

function update(...)
	local lines = status.statusProperty("rexManipulatorLines", {})
	oldUpdate(...)
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
end