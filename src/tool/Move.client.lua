-- Copyright 2021 Tyler (@Mashend2468)
-- https://github.com/namatchi/mashend-ball

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- tool
local tool = script.Parent
local ballPart = tool:WaitForChild("Part")
local Ball = require(tool:WaitForChild("Ball"))
local rig
local isBraking = true
local AIR_POWER = 50

-- mode modal UI as some sort of object
function ModeModal()
	local TweenService = game:GetService("TweenService")

	-- ui
	local container = tool:WaitForChild("ModeModal")
	local background = container:WaitForChild("ImageLabel")
	local textLabel = background:WaitForChild("TextLabel")

	-- make mode modal tweens
	-- 0.5 playtime, 0.5 delay time
	local _fade = TweenInfo.new(0.5, Enum.EasingStyle.Linear, 
		Enum.EasingDirection.In, 0, false, 0.5)
	local _fade1, _fade2, _fade3 = 
		TweenService:Create(container, _fade, {Enabled = false}),
		TweenService:Create(background, _fade, {ImageTransparency = 1}),
		TweenService:Create(textLabel, _fade, {TextTransparency = 1})

	-- exposed functions
	local modal = {}

	-- modal functionality
	function modal:Show(text)
		-- enable modal
		container.Enabled = true
		background.ImageTransparency = 0
		textLabel.TextTransparency = 0
		textLabel.Text = text

		-- fade modal
		modal:Fade()
	end

	-- fade this modal
	function modal:Fade()
		-- cancel fades
		_fade1:Cancel()
		_fade2:Cancel()
		_fade3:Cancel()

		-- play fades
		_fade1:Play()
		_fade2:Play()
		_fade3:Play()
	end

	function modal:SetParent(parent)
		container.Parent = parent
	end
	
	function modal:SetAdornee(adornee)
		container.Adornee = adornee
	end

	return modal
end
local modeModal = ModeModal() -- create object

function Equipped()
	-- make the rig and add our character
	rig = Ball.CreateRig(ballPart)
	rig:AddToCharacter(LocalPlayer.Character)
	rig:SetCameraSubject()

	-- set modal parent
	modeModal:SetAdornee(rig.part)
	modeModal:SetParent(LocalPlayer.PlayerGui)
end

function Unequipped()
	-- prevents a nil camera bug
	if rig.humanoid ~= nil then
		rig:UnsetCameraSubject()
	end

	-- remove character after camera operations
	rig:RemoveCharacter()
	rig = nil

	-- unset modal properties
	modeModal:SetAdornee(nil)
	modeModal:SetParent(tool)
end

function RenderStepped(delta)
	if rig ~= nil and rig.humanoid ~= nil and rig.humanoid.Health > 0 then
		if rig.humanoid.MoveDirection.magnitude > 0.1 then
			-- roll ball
			rig:Roll(rig.humanoid.MoveDirection)

			-- strafe (in air)
			if rig:IsInAir() == true then
				rig:ApplyImpulse(rig.humanoid.MoveDirection * rig:GetMass() 
					* AIR_POWER * delta)
			end
		elseif isBraking == true then
			rig:Brake()
		else
			rig:Coast()
		end
	end
end

-- Listen for inputs to toggle braking modes
function InputBegan(inputObject, didGameProcess)
	if didGameProcess == false 
		and inputObject.KeyCode == Enum.KeyCode.LeftControl then

		-- change braking mode
		isBraking = not isBraking
		modeModal:Show(isBraking and "Braking" or "Coasting")
	end
end

-- listen for jumps
function Jump()
	if rig ~= nil and rig:IsInAir() == false then
		rig:Jump()
	end
end

tool.Equipped:connect(Equipped)
tool.Unequipped:connect(Unequipped)
RunService.RenderStepped:connect(RenderStepped)
UserInputService.InputBegan:connect(InputBegan)
UserInputService.JumpRequest:connect(Jump)