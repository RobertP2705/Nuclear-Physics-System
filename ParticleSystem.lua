local ParticleSystem = {}
local PhysicsSystem = require(script.Parent.PhysicsSystem)

local function createBaseParticle(particleType)
	local particle = Instance.new("Part")
	particle.Shape = Enum.PartType.Ball
	particle.CanCollide = false
	particle.Anchored = false
	particle.Name = particleType
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bodyVelocity.Velocity = Vector3.new(0, 0, 0)
	bodyVelocity.Parent = particle
	if particleType == "Proton" then
		particle.Size = Vector3.new(2, 2, 2)
		particle.Color = Color3.new(1, 0, 0)
		particle:SetAttribute("Charge", 1)
		particle:SetAttribute("Mass", 1.67)
	elseif particleType == "Electron" then
		particle.Size = Vector3.new(1, 1, 1)
		particle.Color = Color3.new(0, 0, 1)
		particle:SetAttribute("Charge", -1)
		particle:SetAttribute("Mass", 9.1e-4)
	elseif particleType == "Neutron" then
		particle.Size = Vector3.new(2, 2, 2)
		particle.Color = Color3.new(0.5, 0.5, 0.5)
		particle:SetAttribute("Charge", 0)
		particle:SetAttribute("Mass", 1.67)
	end

	local attachment0 = Instance.new("Attachment")
	attachment0.Position = Vector3.new(-0.5, 0, 0)
	attachment0.Parent = particle

	local attachment1 = Instance.new("Attachment")
	attachment1.Position = Vector3.new(0.5, 0, 0)
	attachment1.Parent = particle

	local trail = Instance.new("Trail")
	trail.Color = ColorSequence.new(particle.Color)
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.Lifetime = 0.5
	trail.MinLength = 0.1
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1
	trail.Parent = particle

	return particle
end

function ParticleSystem.init()
	print("ParticleSystem init starting")
	PhysicsSystem.init()
	print("ParticleSystem init complete")
end

function ParticleSystem.spawnParticle(particleType)
	local particle = createBaseParticle(particleType)
	local character = workspace:FindFirstChild("ParticleCharacter")

	local camera = workspace.CurrentCamera
	if camera then
		particle.CFrame = CFrame.new(camera.CFrame.Position + (camera.CFrame.LookVector * 20))
	end 
	particle.Parent = workspace
	PhysicsSystem.registerParticle(particle)
	return particle
end

return ParticleSystem