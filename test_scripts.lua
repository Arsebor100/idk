-- ============================================
-- UNIVERSAL CHAOS + UTILITY SCRIPT
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Состояния
local states = {
	speed = 16,
	jump = 50,
	noclip = false,
	fly = false,
	infJump = false,
	flingAura = false,
	god = false,
	antiAfk = true
}

local flyBody = nil
local connections = {}

-- ========== ФУНКЦИИ ==========

local function getHRP()
	local char = player.Character
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHum()
	local char = player.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

-- Speed / Jump
local function applyStats()
	local hum = getHum()
	if hum then
		hum.WalkSpeed = states.speed
		hum.JumpPower = states.jump
		hum.UseJumpPower = true
	end
end

-- Noclip
local function setNoclip(on)
	states.noclip = on
	if connections.noclip then connections.noclip:Disconnect() end
	if on then
		connections.noclip = RunService.Stepped:Connect(function()
			local char = player.Character
			if char then
				for _, part in pairs(char:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
	end
end

-- Fly
local function setFly(on)
	states.fly = on
	local hrp = getHRP()
	if not hrp then return end
	
	if flyBody then flyBody:Destroy() flyBody = nil end
	
	if on then
		flyBody = Instance.new("BodyVelocity")
		flyBody.MaxForce = Vector3.new(40000, 40000, 40000)
		flyBody.Velocity = Vector3.zero
		flyBody.Parent = hrp
		
		connections.fly = RunService.RenderStepped:Connect(function()
			if not states.fly or not flyBody then return end
			local cam = workspace.CurrentCamera
			local dir = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
			flyBody.Velocity = dir.Unit * 60
			if dir.Magnitude < 0.1 then flyBody.Velocity = Vector3.zero end
		end)
	else
		if connections.fly then connections.fly:Disconnect() end
	end
end

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
	if states.infJump then
		local hum = getHum()
		if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

-- Fling Aura
local function flingAuraLoop()
	if not states.flingAura then return end
	local hrp = getHRP()
	if not hrp then return end
	
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local other = plr.Character:FindFirstChild("HumanoidRootPart")
			if other and (other.Position - hrp.Position).Magnitude < 25 then
				local bv = Instance.new("BodyVelocity")
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Velocity = Vector3.new(math.random(-120,120), 90, math.random(-120,120))
				bv.Parent = other
				game:GetService("Debris"):AddItem(bv, 0.3)
			end
		end
	end
end

-- Click Fling
mouse.Button1Down:Connect(function()
	local target = mouse.Target
	if target and target.Parent:FindFirstChildOfClass("Humanoid") then
		local hrp = target.Parent:FindFirstChild("HumanoidRootPart")
		if hrp then
			local bv = Instance.new("BodyVelocity")
			bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
			bv.Velocity = Vector3.new(math.random(-200,200), 150, math.random(-200,200))
			bv.Parent = hrp
			game:GetService("Debris"):AddItem(bv, 0.4)
		end
	end
end)

-- God Mode
local function setGod(on)
	states.god = on
	local hum = getHum()
	if hum then
		if on then
			hum.MaxHealth = math.huge
			hum.Health = math.huge
		else
			hum.MaxHealth = 100
			hum.Health = 100
		end
	end
end

-- Anti AFK
if states.antiAfk then
	local vu = game:GetService("VirtualUser")
	player.Idled:Connect(function()
		vu:CaptureController()
		vu:ClickButton2(Vector2.new())
	end)
end

-- Блоки (Q поставить / E удалить)
local function placeBlock()
	local hrp = getHRP()
	if not hrp then return end
	local part = Instance.new("Part")
	part.Size = Vector3.new(4,4,4)
	part.Anchored = true
	part.CanCollide = true
	part.Color = Color3.fromRGB(math.random(100,255), math.random(100,255), math.random(100,255))
	part.Position = hrp.Position + hrp.CFrame.LookVector * 8
	part.Name = "MyBlock"
	part.Parent = workspace
end

local function deleteBlock()
	if mouse.Target and mouse.Target.Name == "MyBlock" then
		mouse.Target:Destroy()
	end
end

UserInputService.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.Q then placeBlock() end
	if input.KeyCode == Enum.KeyCode.E then deleteBlock() end
end)

-- Rejoin
local function rejoin()
	TeleportService:Teleport(game.PlaceId, player)
end

-- ========== ПРОСТОЕ GUI ==========
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UniversalHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 420)
frame.Position = UDim2.new(0, 20, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
title.Text = "Universal Hub"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 10)

local y = 45
local function addToggle(name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 28)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	btn.Text = name .. ": OFF"
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	
	local on = false
	btn.MouseButton1Click:Connect(function()
		on = not on
		btn.Text = name .. (on and ": ON" or ": OFF")
		btn.BackgroundColor3 = on and Color3.fromRGB(0, 140, 80) or Color3.fromRGB(40, 40, 50)
		callback(on)
	end)
	y = y + 32
end

local function addButton(name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -20, 0, 28)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.Parent = frame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseButton1Click:Connect(callback)
	y = y + 32
end

addToggle("Noclip", setNoclip)
addToggle("Fly", setFly)
addToggle("Infinite Jump", function(v) states.infJump = v end)
addToggle("Fling Aura", function(v) states.flingAura = v end)
addToggle("God Mode", setGod)

addButton("Speed 50", function() states.speed = 50 applyStats() end)
addButton("Speed 100", function() states.speed = 100 applyStats() end)
addButton("Speed Reset", function() states.speed = 16 applyStats() end)
addButton("Jump 100", function() states.jump = 100 applyStats() end)
addButton("Rejoin", rejoin)

-- Fling Aura цикл
RunService.Heartbeat:Connect(function()
	flingAuraLoop()
	if states.god then
		local hum = getHum()
		if hum and hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
	end
end)

-- При респавне
player.CharacterAdded:Connect(function()
	task.wait(0.5)
	applyStats()
	if states.noclip then setNoclip(true) end
	if states.fly then setFly(true) end
	if states.god then setGod(true) end
end)

print("Universal Hub загружен")
print("Q - поставить блок | E - удалить блок")
