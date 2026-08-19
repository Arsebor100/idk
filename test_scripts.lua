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
handle.Size = Vector3.new(0.2, 0.2, 0.2)
handle.Transparency = 1
handle.CanCollide = false
handle.Parent = tool

tool.Parent = player:WaitForChild("Backpack")

local isActive = false
local connection

tool.Activated:Connect(function()
	local character = player.Character
	if not character then return end
	
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	if isActive then
		isActive = false
		if connection then
			connection:Disconnect()
			connection = nil
		end
		return
	end
	
	isActive = true
	
	connection = RunService.Heartbeat:Connect(function()
		if not isActive or not hrp or not hrp.Parent then
			if connection then connection:Disconnect() end
			return
		end
		
		local t = tick() * 11
		local offset = math.sin(t) * 0.4
		
		-- Движение вперёд-назад + наклон
		hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, offset * 0.18)
		hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(offset * 10), 0, 0)
	end)
end)

tool.Unequipped:Connect(function()
	isActive = false
	if connection then
		connection:Disconnect()
		connection = nil
	end
end)

print("Jerk tool добавлен в инвентарь")
