local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

for _, v in pairs(character:GetDescendants()) do
	if v:IsA("Motor6D") then
		v:Destroy()
	end
end

-- Чтобы кусочки ещё и разлетелись
for _, part in pairs(character:GetChildren()) do
	if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
		part.Anchored = false
		part.CanCollide = true
		
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.Velocity = Vector3.new(
			math.random(-40, 40),
			math.random(20, 50),
			math.random(-40, 40)
		)
		bv.Parent = part
		
		game:GetService("Debris"):AddItem(bv, 0.3)
	end
end

print("Разобрало")
