local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local FLIGHT_SPEED = 50
local ACCELERATION = 2
local DECELERATION = 0.95

local function createParticle()
	local particle = Instance.new("Part")
	particle.Shape = Enum.PartType.Ball
	particle.Size = Vector3.new(1, 1, 1)
	particle.Color = Color3.new(1, 1, 1)
	particle.Material = Enum.Material.Neon
	particle.CanCollide = false

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = particle

	local attachment0 = Instance.new("Attachment")
	attachment0.Position = Vector3.new(-0.5, 0, 0)
	attachment0.Parent = particle

	local attachment1 = Instance.new("Attachment")
	attachment1.Position = Vector3.new(0.5, 0, 0)
	attachment1.Parent = particle

	local trail = Instance.new("Trail")
	trail.Color = ColorSequence.new(Color3.new(1, 1, 1))
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.Lifetime = 0.5
	trail.MinLength = 0.1
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1
	trail.Parent = particle

	return particle, bodyVelocity
end

local function enableParticleFlight(character)
	character.Archivable = false
	character:Destroy()

	local particle, bodyVelocity = createParticle()
	particle.Name = "ParticleCharacter"  -- Add this line
	particle.CFrame = CFrame.new(camera.CFrame.Position - camera.CFrame.LookVector * 10)
	particle.Parent = workspace

	local currentVelocity = Vector3.new(0, 0, 0)
	local targetVelocity = Vector3.new(0, 0, 0)

	camera.CameraSubject = particle

	local function updateVelocity()
		local cameraLook = camera.CFrame.LookVector
		local cameraRight = camera.CFrame.RightVector
		local inputVelocity = Vector3.new()

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			inputVelocity = inputVelocity + cameraLook
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			inputVelocity = inputVelocity - cameraLook
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			inputVelocity = inputVelocity - cameraRight
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			inputVelocity = inputVelocity + cameraRight
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
			inputVelocity = inputVelocity + Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			inputVelocity = inputVelocity - Vector3.new(0, 1, 0)
		end

		if inputVelocity.Magnitude > 0 then
			targetVelocity = inputVelocity.Unit * FLIGHT_SPEED
		else
			targetVelocity = Vector3.new(0, 0, 0)
		end

		currentVelocity = currentVelocity:Lerp(targetVelocity, ACCELERATION * RunService.RenderStepped:Wait())

		if targetVelocity.Magnitude == 0 then
			currentVelocity = currentVelocity * DECELERATION
		end

		bodyVelocity.Velocity = currentVelocity
	end

	RunService.RenderStepped:Connect(updateVelocity)
end

player.CharacterAdded:Connect(enableParticleFlight)
if player.Character then
	enableParticleFlight(player.Character)
end