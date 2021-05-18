-- Copyright 2021 Tyler (@Mashend2468)
-- https://github.com/namatchi/mashend-ball

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local tool = script.Parent
local ballPart = tool:WaitForChild("Part")
local Ball = require(tool:WaitForChild("Ball"))
local rig

local SHOW_TRAIL_SPEED = 100

-- Rig to character for all players
function Equipped()
	local character = tool.Parent
	local player = Players:GetPlayerFromCharacter(character)

	-- only proceed if player exists
	if player ~= nil then
		rig = Ball.CreateRig(ballPart)
		rig:AddToCharacter(character)
		rig:SetNetworkOwner(player)
		rig:SetColor(character["Body Colors"].TorsoColor.Color)
	end
end

-- Remove rig if it was ever completed
function Unequipped()
	if rig ~= nil and rig.character ~= nil then
		rig:RemoveCharacter()
	end

	rig = nil
end

function Stepped()
	if rig ~= nil then
		rig:ShowTrail(rig.part.Velocity.magnitude > SHOW_TRAIL_SPEED)
	end
end

tool.Equipped:connect(Equipped)
tool.Unequipped:connect(Unequipped)
RunService.Stepped:connect(Stepped)