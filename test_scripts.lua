local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Создаём инструмент
local tool = Instance.new("Tool")
tool.Name = "Jerk"
tool.RequiresHandle = false
tool.CanBeDropped = false

local handle = Instance.new("Part")
handle.Name = "Handle"
handle.Size = Vector3.new(0.1, 0.1, 0.1)
handle.Transparency = 1
handle.CanCollide = false
handle.Parent = tool

tool.Parent = player:WaitForChild("Backpack")

local isActive = false
local connection
local originalCFrames = {}

local function getParts(character)
	return {
		LowerTorso = character:FindFirstChild("LowerTorso"),
		UpperTorso = character:FindFirstChild("UpperTorso"),
		Head = character:FindFirstChild("Head"),
		LeftUpperLeg = character:FindFirstChild("LeftUpperLeg"),
		RightUpperLeg = character:FindFirstChild("RightUpperLeg"),
	}
end

tool.Activated:Connect(function()
	local character = player.Character
	if not character then return end
	
	local parts = getParts(character)
	if not parts.LowerTorso or not parts.UpperTorso then
		warn("Это не R15")
		return
	end
	
	if isActive then
		-- Выключаем и возвращаем части на место
		isActive = false
		if connection then
			connection:Disconnect()
			connection = nil
		end
		return
	end
	
	isActive = true
	
	-- Запоминаем исходные CFrame (относительно RootPart)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	
	connection = RunService.Heartbeat:Connect(function()
		if not isActive or not character or not character.Parent then
			if connection then connection:Disconnect() end
			return
		end
		
		local t = tick() * 10
		local thrust = math.sin(t) * 0.55          -- сила толчков
		local lean = math.sin(t) * 0.25             -- наклон торса
		local hip = math.sin(t + 0.3) * 0.35        -- движение таза
		
		-- Таз (главное движение)
		if parts.LowerTorso then
			parts.LowerTorso.CFrame = parts.LowerTorso.CFrame:Lerp(
				parts.LowerTorso.CFrame * CFrame.new(0, 0, hip) * CFrame.Angles(math.rad(thrust * 12), 0, 0),
				0.4
			)
		end
		
		-- Верхний торс (наклон вперёд)
		if parts.UpperTorso then
			parts.UpperTorso.CFrame = parts.UpperTorso.CFrame:Lerp(
				parts.UpperTorso.CFrame * CFrame.Angles(math.rad(lean * 18), 0, 0),
				0.35
			)
		end
		
		-- Голова чуть следует за торсом
		if parts.Head then
			parts.Head.CFrame = parts.Head.CFrame:Lerp(
				parts.Head.CFrame * CFrame.Angles(math.rad(lean * 8), 0, 0),
				0.3
			)
		end
		
		-- Ноги чуть разъезжаются/двигаются
		if parts.LeftUpperLeg then
			parts.LeftUpperLeg.CFrame = parts.LeftUpperLeg.CFrame:Lerp(
				parts.LeftUpperLeg.CFrame * CFrame.Angles(math.rad(-thrust * 6), 0, math.rad(4)),
				0.3
			)
		end
		if parts.RightUpperLeg then
			parts.RightUpperLeg.CFrame = parts.RightUpperLeg.CFrame:Lerp(
				parts.RightUpperLeg.CFrame * CFrame.Angles(math.rad(-thrust * 6), 0, math.rad(-4)),
				0.3
			)
		end
	end)
end)

tool.Unequipped:Connect(function()
	isActive = false
	if connection then
		connection:Disconnect()
		connection = nil
	end
end)

print("R15 Jerk tool добавлен")
