-- =====================================================
--  UNIVERSAL MEGA HUB
--  Красиво • Много функций • Почти везде
-- =====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ===================== СОСТОЯНИЯ =====================
local S = {
	speed = 16,
	jump = 50,
	noclip = false,
	fly = false,
	infJump = false,
	flingAura = false,
	jointAura = false,
	partAura = false,
	chaos = false,
	god = false,
	invis = false,
	fullbright = false,
	nofog = false,
}

local flyBV, flyBG
local connections = {}
local auraParts = {}

-- ===================== ХЕЛПЕРЫ =====================
local function HRP()
	local c = player.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function Hum()
	local c = player.Character
	return c and c:FindFirstChildOfClass("Humanoid")
end

local function notify(title, text)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = 4
		})
	end)
end

-- ===================== MOVEMENT =====================
local function applyStats()
	local h = Hum()
	if h then
		h.WalkSpeed = S.speed
		h.JumpPower = S.jump
		h.UseJumpPower = true
	end
end

local function setNoclip(state)
	S.noclip = state
	if connections.noclip then connections.noclip:Disconnect() end
	if state then
		connections.noclip = RunService.Stepped:Connect(function()
			local char = player.Character
			if char then
				for _, p in pairs(char:GetDescendants()) do
					if p:IsA("BasePart") then p.CanCollide = false end
				end
			end
		end)
	end
end

local function setFly(state)
	S.fly = state
	local hrp = HRP()
	if not hrp then return end

	if flyBV then flyBV:Destroy() flyBV = nil end
	if flyBG then flyBG:Destroy() flyBG = nil end
	if connections.fly then connections.fly:Disconnect() end

	if state then
		flyBV = Instance.new("BodyVelocity")
		flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
		flyBV.Velocity = Vector3.zero
		flyBV.Parent = hrp

		flyBG = Instance.new("BodyGyro")
		flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		flyBG.P = 3000
		flyBG.Parent = hrp

		connections.fly = RunService.RenderStepped:Connect(function()
			if not S.fly or not flyBV then return end
			local cam = workspace.CurrentCamera
			local move = Vector3.zero
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.yAxis end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.yAxis end

			flyBV.Velocity = move.Magnitude > 0 and move.Unit * 70 or Vector3.zero
			flyBG.CFrame = cam.CFrame
		end)
	end
end

UserInputService.JumpRequest:Connect(function()
	if S.infJump then
		local h = Hum()
		if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
	end
end)

-- ===================== TROLL =====================
local function doFling(targetHRP, power)
	if not targetHRP then return end
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	bv.Velocity = Vector3.new(math.random(-power, power), math.random(60, 140), math.random(-power, power))
	bv.Parent = targetHRP
	game:GetService("Debris"):AddItem(bv, 0.35)
end

-- Click Fling
mouse.Button1Down:Connect(function()
	local t = mouse.Target
	if t and t.Parent:FindFirstChildOfClass("Humanoid") then
		doFling(t.Parent:FindFirstChild("HumanoidRootPart"), 180)
	end
end)

-- ===================== AURAS & CHAOS =====================
local function updateAuras()
	local hrp = HRP()
	if not hrp then return end

	-- Fling Aura
	if S.flingAura then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local o = plr.Character:FindFirstChild("HumanoidRootPart")
				if o and (o.Position - hrp.Position).Magnitude < 30 then
					if math.random() < 0.2 then doFling(o, 130) end
				end
			end
		end
	end

	-- Joint Destroy Aura
	if S.jointAura then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and (plr.Character:GetPivot().Position - hrp.Position).Magnitude < 28 then
				if math.random() < 0.12 then
					for _, v in pairs(plr.Character:GetDescendants()) do
						if v:IsA("Motor6D") then v:Destroy() end
					end
				end
			end
		end
	end

	-- Part Aura (части карты)
	if S.partAura then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Parent ~= player.Character and obj.Size.Magnitude < 25 then
				if (obj.Position - hrp.Position).Magnitude < 40 and #auraParts < 22 then
					if not table.find(auraParts, obj) then
						obj.Anchored = false
						local bp = Instance.new("BodyPosition")
						bp.MaxForce = Vector3.new(8e4, 8e4, 8e4)
						bp.P = 5000
						bp.Parent = obj
						table.insert(auraParts, obj)
					end
				end
			end
		end
		for i = #auraParts, 1, -1 do
			local p = auraParts[i]
			if p and p.Parent then
				local bp = p:FindFirstChildOfClass("BodyPosition")
				if bp then
					local a = tick() * 2 + i
					bp.Position = hrp.Position + Vector3.new(math.cos(a)*9, math.sin(tick()+i)*3, math.sin(a)*9)
				end
			else
				table.remove(auraParts, i)
			end
		end
	end

	-- Chaos (разлёт карты)
	if S.chaos and math.random() < 0.08 then
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Parent ~= player.Character and (obj.Position - hrp.Position).Magnitude < 50 then
				if math.random() < 0.03 then
					obj.Anchored = false
					doFling(obj, 90)
				end
			end
		end
	end
end

-- ===================== PLAYER =====================
local function setGod(state)
	S.god = state
	local h = Hum()
	if h then
		if state then
			h.MaxHealth = math.huge
			h.Health = math.huge
		else
			h.MaxHealth = 100
			h.Health = 100
		end
	end
end

local function setInvis(state)
	S.invis = state
	local char = player.Character
	if not char then return end
	for _, p in pairs(char:GetDescendants()) do
		if p:IsA("BasePart") or p:IsA("Decal") then
			p.Transparency = state and 1 or 0
		end
	end
end

-- Anti AFK
player.Idled:Connect(function()
	local vu = game:GetService("VirtualUser")
	vu:CaptureController()
	vu:ClickButton2(Vector2.new())
end)

-- ===================== WORLD =====================
local function setFullbright(state)
	S.fullbright = state
	if state then
		Lighting.Brightness = 2
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
		Lighting.GlobalShadows = false
		Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
	else
		Lighting.Brightness = 1
		Lighting.GlobalShadows = true
	end
end

local function setNoFog(state)
	S.nofog = state
	Lighting.FogEnd = state and 100000 or 1000
end

-- Блоки
UserInputService.InputBegan:Connect(function(inp, gpe)
	if gpe then return end
	if inp.KeyCode == Enum.KeyCode.Q then
		local hrp = HRP()
		if hrp then
			local part = Instance.new("Part")
			part.Size = Vector3.new(4, 4, 4)
			part.Anchored = true
			part.Color = Color3.fromRGB(math.random(80,255), math.random(80,255), math.random(80,255))
			part.Position = hrp.Position + hrp.CFrame.LookVector * 9
			part.Name = "MyBlock"
			part.Parent = workspace
		end
	elseif inp.KeyCode == Enum.KeyCode.E then
		if mouse.Target and mouse.Target.Name == "MyBlock" then
			mouse.Target:Destroy()
		end
	end
end)

-- ===================== GUI =====================
local gui = Instance.new("ScreenGui")
gui.Name = "MegaHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 290, 0, 520)
main.Position = UDim2.new(0, 25, 0.5, -260)
main.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(60, 60, 75)
stroke.Thickness = 1.2

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
titleBar.BorderSizePixel = 0
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 14)
titleFix.Position = UDim2.new(0, 0, 1, -14)
titleFix.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -50, 1, 0)
title.Position = UDim2.new(0, 14, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MEGA HUB"
title.TextColor3 = Color3.fromRGB(240, 240, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 32, 0, 32)
close.Position = UDim2.new(1, -38, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(200, 50, 60)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255,255,255)
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.Parent = titleBar
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 7)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Scroll
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -16, 1, -55)
scroll.Position = UDim2.new(0, 8, 0, 48)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 130)
scroll.CanvasSize = UDim2.new(0, 0, 0, 1100)
scroll.Parent = main

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.Parent = scroll

local function section(text)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, 0, 0, 24)
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = Color3.fromRGB(140, 140, 170)
	l.Font = Enum.Font.GothamBold
	l.TextSize = 13
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = scroll
end

local function toggle(name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	btn.Text = "  " .. name .. "  —  OFF"
	btn.TextColor3 = Color3.fromRGB(230, 230, 240)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = scroll
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

	local on = false
	btn.MouseButton1Click:Connect(function()
		on = not on
		btn.Text = "  " .. name .. (on and "  —  ON" or "  —  OFF")
		btn.BackgroundColor3 = on and Color3.fromRGB(0, 130, 90) or Color3.fromRGB(35, 35, 45)
		callback(on)
	end)
end

local function button(name, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(240, 240, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 13
	btn.Parent = scroll
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
	btn.MouseButton1Click:Connect(callback)
end

-- ===== СОЗДАЁМ ИНТЕРФЕЙС =====
section("MOVEMENT")
toggle("Noclip", setNoclip)
toggle("Fly", setFly)
toggle("Infinite Jump", function(v) S.infJump = v end)
button("Speed 50", function() S.speed = 50 applyStats() end)
button("Speed 100", function() S.speed = 100 applyStats() end)
button("Speed 150", function() S.speed = 150 applyStats() end)
button("Speed Reset", function() S.speed = 16 applyStats() end)
button("Jump 120", function() S.jump = 120 applyStats() end)

section("TROLL / CHAOS")
toggle("Fling Aura", function(v) S.flingAura = v end)
toggle("Joint Destroy Aura", function(v) S.jointAura = v end)
toggle("Part Aura (карта)", function(v) S.partAura = v end)
toggle("Map Chaos", function(v) S.chaos = v end)
button("Fling All", function()
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			doFling(plr.Character:FindFirstChild("HumanoidRootPart"), 200)
		end
	end
	notify("Fling", "Всех кинуло")
end)

section("PLAYER")
toggle("God Mode", setGod)
toggle("Invisible", setInvis)
button("Reset Character", function()
	local h = Hum()
	if h then h.Health = 0 end
end)

section("WORLD")
toggle("Fullbright", setFullbright)
toggle("No Fog", setNoFog)
button("FPS Boost", function()
	for _, v in pairs(workspace:GetDescendants()) do
		if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") then
			v.Enabled = false
		end
	end
	notify("FPS", "Эффекты вырублены")
end)
button("Rejoin", function()
	TeleportService:Teleport(game.PlaceId, player)
end)

section("BINDS")
local bindInfo = Instance.new("TextLabel")
bindInfo.Size = UDim2.new(1, 0, 0, 50)
bindInfo.BackgroundTransparency = 1
bindInfo.Text = "Q — поставить блок\nE — удалить блок\nЛКМ — Click Fling"
bindInfo.TextColor3 = Color3.fromRGB(150, 150, 170)
bindInfo.Font = Enum.Font.Gotham
bindInfo.TextSize = 12
bindInfo.TextXAlignment = Enum.TextXAlignment.Left
bindInfo.Parent = scroll

-- Drag
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)
titleBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- Главный цикл
RunService.Heartbeat:Connect(function()
	updateAuras()
	if S.god then
		local h = Hum()
		if h and h.Health < h.MaxHealth then h.Health = h.MaxHealth end
	end
end)

-- Респавн
player.CharacterAdded:Connect(function()
	task.wait(0.6)
	applyStats()
	if S.noclip then setNoclip(true) end
	if S.fly then setFly(true) end
	if S.god then setGod(true) end
	if S.invis then setInvis(true) end
end)

notify("MEGA HUB", "Загружен успешно")
print("MEGA HUB загружен")
