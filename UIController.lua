local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ParticleSystem = require(script.Parent.ParticleSystem)
ParticleSystem.init() 
local function createParticleButtons()
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Parent = player.PlayerGui

	local function createButton(name, position)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0, 100, 0, 50)
		button.Position = position
		button.Text = name
		button.Parent = ScreenGui

		if name == "Spawn Proton" then
			button.MouseButton1Click:Connect(function()
				ParticleSystem.spawnParticle("Proton")
			end)
		elseif name == "Spawn Electron" then
			button.MouseButton1Click:Connect(function()
				ParticleSystem.spawnParticle("Electron")
			end)
		elseif name == "Spawn Neutron" then
			button.MouseButton1Click:Connect(function()
				ParticleSystem.spawnParticle("Neutron")
			end)
		end

		return button
	end

	createButton("Spawn Proton", UDim2.new(0, 10, 0, 10))
	createButton("Spawn Electron", UDim2.new(0, 10, 0, 70))
	createButton("Spawn Neutron", UDim2.new(0, 10, 0, 130))
end

createParticleButtons()