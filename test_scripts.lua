local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Чтобы не умереть и стоять в воздухе
humanoid.PlatformStand = true
hrp.Anchored = true

-- Поднимаем чуть вверх
hrp.CFrame = hrp.CFrame + Vector3.new(0, 4, 0)

local parts = {}
for _, v in pairs(character:GetDescendants()) do
	if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
		table.insert(parts, v)
	end
end

-- Уничтожаем все суставы
for _, v in pairs(character:GetDescendants()) do
	if v:IsA("Motor6D") then
		v:Destroy()
	end
end

-- Раздвигаем части в разные стороны (как чертёж)
for i, part in ipairs(parts) do
	part.Anchored = true
	part.CanCollide = false
	
	local angle = (i / #parts) * math.pi * 2
	local distance = 3.5
	
	local offset = Vector3.new(
		math.cos(angle) * distance,
		math.sin(angle * 1.5) * 1.8,
		math.sin(angle) * distance
	)
	
	part.CFrame = hrp.CFrame * CFrame.new(offset)
end

print("Разобрало в воздухе")
