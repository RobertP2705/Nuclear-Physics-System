local RunService = game:GetService("RunService")
local PhysicsSystem = {}


local particles = setmetatable({}, {__mode = "k"})
local COULOMB_CONSTANT = 2000  
local STRONG_FORCE_CONSTANT = 2000
local STRONG_FORCE_RANGE = 100
local MIN_DISTANCE = 0.3
local DAMPING = 0.99  

local function calculateForceDirection(particle1, particle2)
	local direction = (particle1.Position - particle2.Position)
	local distance = direction.Magnitude
	return direction.Unit, math.max(distance, MIN_DISTANCE)
end

local function calculateElectricForce(particle1, particle2)
	local direction, distance = calculateForceDirection(particle1, particle2)

	local charge1 = particle1:GetAttribute("Charge")
	local charge2 = particle2:GetAttribute("Charge")

	local scaleFactor = 1
	if particle1.Name == "Electron" or particle2.Name == "Electron" then
		scaleFactor = 0.4
	end

	local forceMagnitude = COULOMB_CONSTANT * (charge1 * charge2) / (distance * distance) * scaleFactor

	return direction * forceMagnitude
end

local function calculateStrongForce(particle1, particle2)
	local direction, distance = calculateForceDirection(particle1, particle2)

	local type1 = particle1.Name
	local type2 = particle2.Name
	if (type1 ~= "Proton" and type1 ~= "Neutron") or
		(type2 ~= "Proton" and type2 ~= "Neutron") then
		return Vector3.new(0, 0, 0)
	end

	if distance > STRONG_FORCE_RANGE then
		return Vector3.new(0, 0, 0)
	end

	local attraction = STRONG_FORCE_CONSTANT * math.exp(-distance/2) / (distance * distance)
	local repulsion = STRONG_FORCE_CONSTANT * 2 * math.exp(-distance*2) / (distance * distance)
	local forceMagnitude = attraction - repulsion

	return direction * -forceMagnitude 
end

local function updateParticle(particle, deltaTime)
	local totalForce = Vector3.new(0, 0, 0)

	for otherParticle in pairs(particles) do
		if otherParticle ~= particle then
			local electricForce = calculateElectricForce(particle, otherParticle)
			local strongForce = calculateStrongForce(particle, otherParticle)
			totalForce = totalForce + electricForce + strongForce 
		end
	end

	local mass = particle:GetAttribute("Mass")
	local acceleration = totalForce / mass

	local bodyVelocity = particle:FindFirstChild("BodyVelocity")
	if bodyVelocity then
		local prevVelocity = bodyVelocity.Velocity
		local newVelocity = (prevVelocity + acceleration * deltaTime) * DAMPING
		if(particle.Name == "Electron" and newVelocity.Magnitude > 10)then
			bodyVelocity.Velocity = prevVelocity
		else
			bodyVelocity.Velocity = newVelocity
			particle.Position = particle.Position + newVelocity * deltaTime
		end
	end
end

function PhysicsSystem.registerParticle(particle)
	particles[particle] = true
	particle.AncestryChanged:Connect(function(_, parent)
		if not parent then
			particles[particle] = nil
		end
	end)
end
function PhysicsSystem.cleanupAllParticles()
	for particle in pairs(particles) do
		particles[particle] = nil
		particle:Destroy()
	end
end

local function cleanupParticle(particle)
	local character = workspace:FindFirstChild("ParticleCharacter")
	if character and (particle.Position - character.Position).Magnitude > 1000 then
		particles[particle] = nil
		particle:Destroy()
	end
end

function PhysicsSystem.init()
	RunService.Heartbeat:Connect(function(deltaTime)
		deltaTime = deltaTime * 0.1 
		for particle in pairs(particles) do
			updateParticle(particle, deltaTime)
			cleanupParticle(particle)
		end
	end)
end

return PhysicsSystem