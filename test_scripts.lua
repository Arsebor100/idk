--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local plr = Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")
local cam = workspace.CurrentCamera
local mouse = plr:GetMouse()

-- [[ CAMBIAR ANIMACIONES IDLE Y RUN ]] --
local function changeDefaultAnims()
	local animate = char:WaitForChild("Animate")
	animate.idle.Animation1.AnimationId = "rbxassetid://112724398873969"
	animate.idle.Animation2.AnimationId = "rbxassetid://112724398873969"
	animate.run.RunAnim.AnimationId = "rbxassetid://90175656540190"
	
	animate.Disabled = true
	task.wait()
	animate.Disabled = false
end

-- [[ QUITAR BOTÓN DE SALTO ]] --
local function disableJump()
	hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
	local touchJump = plr.PlayerScripts:WaitForChild("PlayerModule"):WaitForChild("ControlModule"):FindFirstChild("TouchJumpController")
	if touchJump then touchJump:Destroy() end
end

-- [[ CREAR ANIMACIONES ]] --
local punchAnim = Instance.new("Animation")
punchAnim.AnimationId = "rbxassetid://110361063508944"
local punchTrack = hum:LoadAnimation(punchAnim)
punchTrack.Looped = false

local voidAnim = Instance.new("Animation")
voidAnim.AnimationId = "rbxassetid://119380285634530"
local voidTrack = hum:LoadAnimation(voidAnim)
voidTrack.Looped = true

local novaAnim = Instance.new("Animation")
novaAnim.AnimationId = "rbxassetid://110979677723900"
local novaTrack = hum:LoadAnimation(novaAnim)
novaTrack.Looped = false

local observantAnim = Instance.new("Animation")
observantAnim.AnimationId = "rbxassetid://134878524179035"
local observantTrack = hum:LoadAnimation(observantAnim)
observantTrack.Looped = true

-- [[ GUI PRINCIPAL ]] --
local gui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
gui.Name = "NoliGUI"
gui.ResetOnSpawn = false

local function createCircleButton(name, pos, color, textColor)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Parent = gui
	btn.Size = UDim2.new(0, 70, 0, 70)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.Text = name
	btn.TextColor3 = textColor or Color3.new(1,1,1)
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBlack
	btn.BorderSizePixel = 0
	
	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(1, 0)
	
	local stroke = Instance.new("UIStroke", btn)
	stroke.Color = Color3.fromRGB(220, 180, 255)
	stroke.Thickness = 2
	stroke.Transparency = 0.2
	
	return btn
end

local punchBtn = createCircleButton("PUNCH", UDim2.new(1, -90, 0.5, -120), Color3.fromRGB(130, 0, 200))
local voidBtn = createCircleButton("VOID", UDim2.new(1, -90, 0.5, -30), Color3.fromRGB(90, 0, 150))
local novaBtn = createCircleButton("NOVA", UDim2.new(1, -90, 0.5, 60), Color3.fromRGB(160, 50, 255))
local observantBtn = createCircleButton("OBSERVANT", UDim2.new(1, -180, 0.5, -30), Color3.fromRGB(140, 0, 210))
local runBtn = createCircleButton("RUN", UDim2.new(1, -180, 0.5, 60), Color3.fromRGB(255, 255, 255), Color3.new(0,0,0))

-- [[ VARIABLES ]] --
local voidDebounce = false
local punchDebounce = false
local novaDebounce = false
local observantDebounce = false
local isRunning = false
local isVoidRushing = false
local isObserving = false
local waitingForClickTP = false
local oldSpeedBeforeObservant = 16

-- [[ FUNCION NUEVA: AURA MORADA ]] --
local function createTeleportAura()
	local aura = Instance.new("Highlight")
	aura.Name = "NoliTPAura"
	aura.Parent = char
	aura.FillColor = Color3.fromRGB(170, 0, 255)
	aura.OutlineColor = Color3.fromRGB(220, 180, 255)
	aura.FillTransparency = 0.4
	aura.OutlineTransparency = 0
	
	-- Efecto de pulso
	local pulseTween = TweenService:Create(aura, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
		FillTransparency = 0.1,
		OutlineTransparency = 0.5
	})
	pulseTween:Play()
	
	return aura, pulseTween
end

-- [[ OBSERVANT MENU PRINCIPAL ]] --
local observantMenu = Instance.new("Frame")
observantMenu.Name = "ObservantMenu"
observantMenu.Parent = gui
observantMenu.Size = UDim2.new(0, 400, 0, 300)
observantMenu.Position = UDim2.new(0.5, -200, 0.5, -150)
observantMenu.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
observantMenu.BorderSizePixel = 0
observantMenu.Visible = false

local menuCorner = Instance.new("UICorner", observantMenu)
menuCorner.CornerRadius = UDim.new(0, 12)

local menuStroke = Instance.new("UIStroke", observantMenu)
menuStroke.Color = Color3.fromRGB(170, 0, 255)
menuStroke.Thickness = 3

local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = observantMenu
titleLabel.Size = UDim2.new(1, 0, 0, 60)
titleLabel.Position = UDim2.new(0, 0, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "What action will you take, Noli?"
titleLabel.TextColor3 = Color3.fromRGB(220, 180, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold

local clickTPBtn = Instance.new("TextButton")
clickTPBtn.Parent = observantMenu
clickTPBtn.Size = UDim2.new(0.8, 0, 0, 50)
clickTPBtn.Position = UDim2.new(0.1, 0, 0, 80)
clickTPBtn.BackgroundColor3 = Color3.fromRGB(130, 0, 200)
clickTPBtn.Text = "Teleport with a click"
clickTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
clickTPBtn.TextScaled = true
clickTPBtn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", clickTPBtn).CornerRadius = UDim.new(0, 8)

local spawnTPBtn = Instance.new("TextButton")
spawnTPBtn.Parent = observantMenu
spawnTPBtn.Size = UDim2.new(0.8, 0, 0, 50)
spawnTPBtn.Position = UDim2.new(0.1, 0, 0, 140)
spawnTPBtn.BackgroundColor3 = Color3.fromRGB(90, 0, 150)
spawnTPBtn.Text = "Teleport to the nearest Spawn"
spawnTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
spawnTPBtn.TextScaled = true
spawnTPBtn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", spawnTPBtn).CornerRadius = UDim.new(0, 8)

local playerTPBtn = Instance.new("TextButton")
playerTPBtn.Parent = observantMenu
playerTPBtn.Size = UDim2.new(0.8, 0, 0, 50)
playerTPBtn.Position = UDim2.new(0.1, 0, 0, 200)
playerTPBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 220)
playerTPBtn.Text = "TP to Player"
playerTPBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playerTPBtn.TextScaled = true
playerTPBtn.Font = Enum.Font.GothamBlack
Instance.new("UICorner", playerTPBtn).CornerRadius = UDim.new(0, 8)

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = observantMenu
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextScaled = true
closeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- [[ PLAYER LIST MENU ]] --
local playerListMenu = Instance.new("Frame")
playerListMenu.Name = "PlayerListMenu"
playerListMenu.Parent = gui
playerListMenu.Size = UDim2.new(0, 400, 0, 350)
playerListMenu.Position = UDim2.new(0.5, -200, 0.5, -175)
playerListMenu.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
playerListMenu.BorderSizePixel = 0
playerListMenu.Visible = false

local playerMenuCorner = Instance.new("UICorner", playerListMenu)
playerMenuCorner.CornerRadius = UDim.new(0, 12)

local playerMenuStroke = Instance.new("UIStroke", playerListMenu)
playerMenuStroke.Color = Color3.fromRGB(170, 0, 255)
playerMenuStroke.Thickness = 3

local playerListTitle = Instance.new("TextLabel")
playerListTitle.Parent = playerListMenu
playerListTitle.Size = UDim2.new(1, 0, 0, 50)
playerListTitle.Position = UDim2.new(0, 0, 0, 10)
playerListTitle.BackgroundTransparency = 1
playerListTitle.Text = "Select a Player"
playerListTitle.TextColor3 = Color3.fromRGB(220, 180, 255)
playerListTitle.TextScaled = true
playerListTitle.Font = Enum.Font.GothamBold

local playerCloseBtn = Instance.new("TextButton")
playerCloseBtn.Parent = playerListMenu
playerCloseBtn.Size = UDim2.new(0, 30, 0, 30)
playerCloseBtn.Position = UDim2.new(1, -40, 0, 10)
playerCloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
playerCloseBtn.Text = "X"
playerCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playerCloseBtn.TextScaled = true
playerCloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", playerCloseBtn).CornerRadius = UDim.new(1, 0)

local playerScrollFrame = Instance.new("ScrollingFrame")
playerScrollFrame.Parent = playerListMenu
playerScrollFrame.Size = UDim2.new(1, -20, 1, -70)
playerScrollFrame.Position = UDim2.new(0, 10, 0, 60)
playerScrollFrame.BackgroundTransparency = 1
playerScrollFrame.BorderSizePixel = 0
playerScrollFrame.ScrollBarThickness = 8
playerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local playerListLayout = Instance.new("UIListLayout")
playerListLayout.Parent = playerScrollFrame
playerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
playerListLayout.Padding = UDim.new(0, 5)

-- [[ FUNCIONES DE BOTONES ]] --
runBtn.MouseButton1Click:Connect(function()
	if isVoidRushing or isObserving then return end
	isRunning = not isRunning
	if isRunning then
		hum.WalkSpeed = 30
		runBtn.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	else
		hum.WalkSpeed = 16
		runBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end
end)

punchBtn.MouseButton1Click:Connect(function()
	if punchDebounce or isVoidRushing then return end
	punchDebounce = true
	punchTrack:Play()
	punchTrack.Stopped:Wait()
	punchDebounce = false
end)

local function endVoidRush(bv, connection)
	if connection then connection:Disconnect() end
	if bv then bv:Destroy() end
	voidTrack:Stop()
	isVoidRushing = false
	
	hum.WalkSpeed = isRunning and 30 or 16
	hum.AutoRotate = true
	changeDefaultAnims()
	voidDebounce = false
end

voidBtn.MouseButton1Click:Connect(function()
	if voidDebounce or isObserving then return end
	voidDebounce = true
	isVoidRushing = true
	voidTrack:Play()
	
	local oldAutoRotate = hum.AutoRotate
	hum.WalkSpeed = 50
	hum.AutoRotate = false
	
	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(100000, 0, 100000)
	bv.Parent = hrp
	
	local hitConnection
	local heartbeatConnection
	local startTime = tick()
	
	hitConnection = hrp.Touched:Connect(function(hit)
		if not isVoidRushing then return end
		local hitHum = hit.Parent:FindFirstChild("Humanoid")
		if hitHum and hitHum ~= hum then
			hitConnection:Disconnect()
			endVoidRush(bv, heartbeatConnection)
			task.wait(0.1)
			punchTrack:Play()
			punchTrack.Stopped:Wait()
		end
	end)
	
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if not isVoidRushing then return end
		if tick() - startTime >= 5 then
			hitConnection:Disconnect()
			endVoidRush(bv, heartbeatConnection)
			return
		end
		
		if bv and bv.Parent then
			local camDir = cam.CFrame.LookVector
			bv.Velocity = Vector3.new(camDir.X, 0, camDir.Z).Unit * 50
			hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + Vector3.new(camDir.X, 0, camDir.Z))
		end
	end)
end)

novaBtn.MouseButton1Click:Connect(function()
	if novaDebounce or isVoidRushing or isObserving then return end
	novaDebounce = true
	
	local oldSpeed = hum.WalkSpeed
	hum.WalkSpeed = 5
	
	novaTrack:Play()
	novaTrack:AdjustSpeed(6)
	novaTrack.Stopped:Wait()
	
	hum.WalkSpeed = isRunning and 30 or oldSpeed
	novaDebounce = false
end)

-- [[ OBSERVANT REWORK ]] --
local function closeAllMenus()
	observantMenu.Visible = false
	playerListMenu.Visible = false
	isObserving = false
	waitingForClickTP = false
	observantTrack:Stop()
	observantBtn.BackgroundColor3 = Color3.fromRGB(140, 0, 210)
	observantBtn.Text = "OBSERVANT"
	hum.WalkSpeed = isRunning and 30 or oldSpeedBeforeObservant
end

local function getNearestSpawn()
	local closestSpawn = nil
	local shortestDistance = math.huge
	
	for _, spawn in pairs(workspace:GetDescendants()) do
		if spawn:IsA("SpawnLocation") then
			local distance = (hrp.Position - spawn.Position).Magnitude
			if distance < shortestDistance then
				shortestDistance = distance
				closestSpawn = spawn
			end
		end
	end
	
	return closestSpawn
end

observantBtn.MouseButton1Click:Connect(function()
	if observantDebounce or isVoidRushing or waitingForClickTP then return end
	observantDebounce = true
	
	if observantMenu.Visible or playerListMenu.Visible then
		closeAllMenus()
	else
		isObserving = true
		oldSpeedBeforeObservant = hum.WalkSpeed
		hum.WalkSpeed = 5
		observantTrack:Play()
		observantBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 255)
		observantMenu.Visible = true
	end
	
	task.wait(0.5)
	observantDebounce = false
end)

clickTPBtn.MouseButton1Click:Connect(function()
	observantMenu.Visible = false
	waitingForClickTP = true
	observantBtn.Text = "CLICK TO TP"
	observantBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
end)

mouse.Button1Down:Connect(function()
	if not waitingForClickTP then return end
	if not mouse.Target then return end
	
	waitingForClickTP = false
	local targetPos = mouse.Hit.Position
	closeAllMenus()
	hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
end)

task.spawn(function()
	while true do
		task.wait(1)
		if waitingForClickTP then
			task.wait(9)
			if waitingForClickTP then
				closeAllMenus()
			end
		end
	end
end)

spawnTPBtn.MouseButton1Click:Connect(function()
	closeAllMenus()
	punchTrack:Play()
	punchTrack.Stopped:Wait()
	
	local nearestSpawn = getNearestSpawn()
	if nearestSpawn then
		hrp.CFrame = nearestSpawn.CFrame + Vector3.new(0, 3, 0)
	end
end)

-- TP TO PLAYER CON AURA - ACTUALIZADO
local function createPlayerButton(targetPlayer)
	if targetPlayer == plr then return end
	
	local playerBtn = Instance.new("TextButton")
	playerBtn.Parent = playerScrollFrame
	playerBtn.Size = UDim2.new(1, -10, 0, 50)
	playerBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 80)
	playerBtn.BorderSizePixel = 0
	playerBtn.Text = ""
	
	Instance.new("UICorner", playerBtn).CornerRadius = UDim.new(0, 8)
	
	local avatar = Instance.new("ImageLabel")
	avatar.Parent = playerBtn
	avatar.Size = UDim2.new(0, 40, 0, 40)
	avatar.Position = UDim2.new(0, 5, 0.5, -20)
	avatar.BackgroundTransparency = 1
	avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..targetPlayer.UserId.."&width=420&height=420&format=png"
	Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
	
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Parent = playerBtn
	nameLabel.Size = UDim2.new(1, -55, 1, 0)
	nameLabel.Position = UDim2.new(0, 50, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = targetPlayer.DisplayName.." (@"..targetPlayer.Name..")"
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	
	playerBtn.MouseButton1Click:Connect(function()
		if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
			closeAllMenus()
			
			-- CREAR AURA MORADA ✨
			local aura, pulseTween = createTeleportAura()
			
			punchTrack:Play()
			punchTrack.Stopped:Wait()
			
			-- TELEPORT
			hrp.CFrame = targetPlayer.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
			
			-- QUITAR AURA
			task.wait(0.2)
			if pulseTween then pulseTween:Cancel() end
			if aura then aura:Destroy() end
		end
	end)
	
	return playerBtn
end

local function refreshPlayerList()
	for _, child in pairs(playerScrollFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	
	local playerCount = 0
	for _, targetPlayer in pairs(Players:GetPlayers()) do
		if targetPlayer ~= plr then
			createPlayerButton(targetPlayer)
			playerCount = playerCount + 1
		end
	end
	
	playerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, playerCount * 55)
end

playerTPBtn.MouseButton1Click:Connect(function()
	observantMenu.Visible = false
	playerListMenu.Visible = true
	refreshPlayerList()
end)

playerCloseBtn.MouseButton1Click:Connect(function()
	closeAllMenus()
end)

closeBtn.MouseButton1Click:Connect(function()
	closeAllMenus()
end)

-- [[ INMORTALIDAD ]] --
hum.HealthChanged:Connect(function()
	if hum.Health < hum.MaxHealth then
		hum.Health = hum.MaxHealth
	end
end)

-- [[ INICIALIZAR ]] --
char:WaitForChild("Animate")
task.wait(1)
changeDefaultAnims()
disableJump()
hum.WalkSpeed = 16

plr.CharacterAdded:Connect(function(newChar)
	char = newChar
	hum = newChar:WaitForChild("Humanoid")
	hrp = newChar:WaitForChild("HumanoidRootPart")
	isVoidRushing = false
	isRunning = false
	closeAllMenus()
	task.wait(2)
	changeDefaultAnims()
	disableJump()
	hum.WalkSpeed = 16
	
	punchTrack = hum:LoadAnimation(punchAnim)
	punchTrack.Looped = false
	voidTrack = hum:LoadAnimation(voidAnim)
	voidTrack.Looped = true
	novaTrack = hum:LoadAnimation(novaAnim)
	novaTrack.Looped = false
	observantTrack = hum:LoadAnimation(observantAnim)
	observantTrack.Looped = true
end)
