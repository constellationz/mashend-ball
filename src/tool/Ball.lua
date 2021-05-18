-- Copyright 2021 Tyler (@Mashend2468)
-- https://github.com/namatchi/mashend-ball

local RunService = game:GetService("RunService")

-- default values
local defaultUp = Vector3.new(0, 1, 0)
local defaultPower = 1
local defaultJumpPower = 50 -- like Humanoid (N/kg)

-- constants
local ZERO = Vector3.new(0, 0, 0)
local TORQUE_COEFFICIENT = 8e2 -- Tuned for zippy movement (N*m/kg)
local DAMPEN_ROLLING_COEFFICIENT = 1e2 -- (N*m/kg/m/s)

local Ball = {}
Ball.__index = Ball

-- Create a Ball to work with.
function Ball.CreateRig(part)
	assert(part ~= nil, "Ball.Rig missing argument 1: Part")

	local rig = {
		-- Instances
		part = part,
		trail = part:WaitForChild("Trail"),
		torque = part:WaitForChild("Torque"),
		center = part:WaitForChild("Center"),

		-- character rig
		weld = nil,
		humanoid = nil,
		character = nil,
		humanoidRootPart = nil,
		humanoidAttachment = nil,

		-- Rolling values
		up = defaultUp,
		power = defaultPower,
		jumpPower = defaultJumpPower,

		-- internal values
		_mass = part:GetMass(),
		_characterMass = 0,
		_hasCameraSubject = true
	}
	setmetatable(rig, Ball)

	return rig
end

-- Show or hide the trail.
function Ball:ShowTrail(show)
	self.trail.Enabled = show and true or false
end

-- Move the ball.
function Ball:MoveTo(newCFrame)
	self.part.CFrame = newCFrame
end

-- Gets the total mass of the Ball assembly.
function Ball:GetMass()
	return self._mass + self._characterMass
end

-- Set upwards direction to roll relative to
function Ball:SetUpDirection(direction)
	self.up = direction or defaultUp
end

-- Set rolling power
function Ball:SetPower(power)
	self.power = power or defaultPower
end

-- Color the ball
function Ball:SetColor(color)
	assert(color ~= nil, "Ball:SetColor missing argument 1: color")
	self.part.Color = color
	self.trail.Color = ColorSequence.new(color, color)
end

function Ball:SetCameraSubject()
	self._hasCameraSubject = true
	game:GetService("Workspace").CurrentCamera.CameraSubject = self.part
end

function Ball:UnsetCameraSubject()
	self._hasCameraSubject = false
	game:GetService("Workspace").CurrentCamera.CameraSubject = self.humanoid
end

function Ball:CancelVelocity()
	self.part.Velocity = ZERO
	self.part.RotVelocity = ZERO
end

-- Rig a character to the ball.
function Ball:AddCharacter(character)
	assert(character ~= nil, "Ball.AddCharacter missing argument 1: character")

	-- add character properties
	self.character = character
	self.humanoid = character:WaitForChild("Humanoid")
	self.humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	-- r15 and r6 have different attachment names
	self.humanoidAttachment = 
		self.humanoidRootPart:FindFirstChild("RootRigAttachment")
		or self.humanoidRootPart:FindFirstChild("RootAttachment")

	-- cancel velocity
	self:CancelVelocity()

	-- weld pieces together
	self.weld = Instance.new("Weld")
	self.weld.Part0 = self.part
	self.weld.Part1 = self.humanoidRootPart
	self.weld.C0 = CFrame.new(self.center.Position)
	self.weld.C1 = CFrame.new(self.humanoidAttachment.Position)
	self.weld.Parent = self.part

	-- adjust humanoid
	self.humanoid.PlatformStand = true

	-- calculate character mass
	self._characterMass = 0
	for _, v in pairs (character:GetDescendants()) do
		if v:isA'BasePart' and v.Massless == false then
			self._characterMass += v:GetMass()
		end
	end
end

-- Adds to character and moves the ball to the character.
function Ball:AddToCharacter(character)
	assert(character ~= nil, "Ball.AddToCharacter missing argument 1: \
		character")

	-- add character and move
	local summonPosition = character.PrimaryPart.CFrame
	self:AddCharacter(character)
	self:MoveTo(summonPosition)
end

-- If a character is rigged, remove it.
function Ball:RemoveCharacter()
	assert(self.character ~= nil, "Ball.character not defined! Did you forget \
		to call Ball:AddCharacter()?")

	-- reset character
	self.humanoid.PlatformStand = false
	self.humanoidRootPart.CFrame = CFrame.new(self.part.Position) -- stand up

	-- unset instances
	self.character = nil
	self.humanoid = nil
	self.humanoidRootPart = nil
	self.humanoidRigAttachment = nil

	-- in case the ball wasn't made in time
	if self.weld ~= nil then
		self.weld:Destroy()
	end

	-- reset physics values
	self._characterMass = 0
end

-- Sets the network owner.
function Ball:SetNetworkOwner(Player)
	self.part:SetNetworkOwner(Player)
end

-- Calculate a torque directly.
function Ball:RawRoll(torque)
	assert(torque ~= nil, "Ball:RawRoll missing argument 1: torque")

	self.torque.Torque = torque
end

-- Apply a force to the ball.
function Ball:ApplyImpulse(force)
	self.part:ApplyImpulse(force)
end

function Ball:Jump()
	self:ApplyImpulse(self.up * self:GetMass() * self.jumpPower)
end

function Ball:IsInAir()
	-- ignore water, ball, and character (if applicable)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.IgnoreWater = false
	params.FilterDescendantsInstances = {
		self.character,
		self.part
	}

	-- look down
	local downRay = -self.up * (self.part.Size.x/2 + 3)

	-- get result
	local result = workspace:Raycast(self.part.Position, downRay, params)
	return result == nil
end

-- Roll in a direction.
function Ball:Roll(direction)
	assert(direction ~= nil, "Ball.Roll missing argument 1: direction")

	-- set up desired roll
	-- direction:cross(up) -> desired angular velocity
	local torque = self.up:Cross(direction) * self.power * self:GetMass()
		* TORQUE_COEFFICIENT
	self:RawRoll(torque)
end

-- Dampens the rolling force
function Ball:Brake()
	-- Calculate dampening torque
	local dampening = -self.part.RotVelocity * DAMPEN_ROLLING_COEFFICIENT * 
		self:GetMass()
	self:RawRoll(dampening)
end

function Ball:Coast()
	self:RawRoll(ZERO)
end

return Ball
