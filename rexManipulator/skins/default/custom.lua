manipulator = {}
manipulator.anibeamed = true

manipulatorRequire("sprites.lua")
--

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


if not mat4 then mat4 = {} end
function mat4.mult(a,b)
	return {
		a[1] * b[1],
		a[2] * b[2],
		a[3] * b[3],
		a[4] * b[4]
	}
end
function mat4.round(a)
	return {
		math.round(a[1]),
		math.round(a[2]),
		math.round(a[3]),
		math.round(a[4])
	}
end

function mat4.min(a, b)
	if type(b) == "number" then b = {b,b,b,b} end
	return {
		math.min(a[1], b[1]),
		math.min(a[2], b[2]),
		math.min(a[3], b[3]),
		math.min(a[4], b[4])
	}
end


--probably for fx purposes

function manipulator:init()
	self.config = config.getParameter("manipulator", {})
	animation:addKeyFrames(self.config["keyFrames"] or {})
end

function manipulator:update(dt)
	self:updateFX(dt)
	self:updateBeamingAnimation()
end

function manipulator:uninit()

end


--

function manipulator:updateFX(dt)
	local aimpos = miner.aimpos
	local polys = miner:getPoly(aimpos, true)
	local lines = {}
	local beamcolor = miner:getColor()
	local beamSecondaryColor = miner:getSecondaryColor()
	local beamStartPart = miner:getBeamPartProperty()
	local beamStartPos = nil
	local mineSize = miner:getSize()
	if not beamStartPart then beamStartPos = {0,0} end

	-- lightning beam
	if math.floor(miner.beaming * 10) / 10 > 0 then
		table.insert(
			lines, 
			{
				color                  = mat4.min( mat4.round(mat4.mult(beamSecondaryColor, {1,1,1,0.5 * miner.beaming})), 255),
				forks                  = 0,
				minDisplacement        = 0.25,
				displacement           = 1,
				width                  = 1,
				forkAngleRange         = 0,
				partStartPosition      = beamStartPart,
				itemStartPosition      = beamStartPos,
				worldEndPosition       = aimpos,
			}
		)
	end

	activeItem.setScriptedAnimationParameter("lightning", lines)
end


function manipulator:updateBeamingAnimation()
	if math.floor(miner.beaming * 10) / 10 > 0.5 then
		if not self.anibeamed then
			animation:play("beaming")
			self.anibeamed = true
		end
		aim.current = aim.current + (math.random(0,10000) - 5000) / 1000
	elseif self.anibeamed and not animation:isPlaying("beaming") then
		self.anibeamed = false
		animation:play("unbeaming")
	end
end
