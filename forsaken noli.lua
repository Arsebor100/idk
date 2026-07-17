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

-- [[ GUI PRINCIPAL ]] --
local gui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
gui.Name = "NoliGUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999 -- Щоб завжди було зверху

-- [[ КНОПКА ДЕАКТИВАЦІЇ (тепер точно буде) ]] --
local disableBtn = Instance.new("TextButton")
disableBtn.Name = "DisableBtn"
disableBtn.Parent = gui
disableBtn.Size = UDim2.new(0, 100, 0, 40)
disableBtn.Position = UDim2.new(0, 10, 0, 10)
disableBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
disableBtn.Text = "DISABLE"
disableBtn.TextColor3 = Color3.new(1, 1, 1)
disableBtn.Font = Enum.Font.GothamBold
disableBtn.TextScaled = true
disableBtn.ZIndex = 10
Instance.new("UICorner", disableBtn)

disableBtn.MouseButton1Click:Connect(function()
    hum.WalkSpeed = 16
    hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    gui:Destroy()
    script:Destroy()
end)

-- [[ CAMBIAR ANIMACIONES IDLE Y RUN ]] --
local function changeDefaultAnims()
    local animate = char:WaitForChild("Animate", 5)
    if animate then
        animate.idle.Animation1.AnimationId = "rbxassetid://112724398873969"
        animate.idle.Animation2.AnimationId = "rbxassetid://112724398873969"
        animate.run.RunAnim.AnimationId = "rbxassetid://90175656540190"
        animate.Disabled = true
        task.wait()
        animate.Disabled = false
    end
end

-- [[ CREAR ANIMACIONES ]] --
local punchAnim = Instance.new("Animation")
punchAnim.AnimationId = "rbxassetid://110361063508944"
local punchTrack = hum:LoadAnimation(punchAnim)

local voidAnim = Instance.new("Animation")
voidAnim.AnimationId = "rbxassetid://119380285634530"
local voidTrack = hum:LoadAnimation(voidAnim)

local novaAnim = Instance.new("Animation")
novaAnim.AnimationId = "rbxassetid://110979677723900"
local novaTrack = hum:LoadAnimation(novaAnim)

local observantAnim = Instance.new("Animation")
observantAnim.AnimationId = "rbxassetid://134878524179035"
local observantTrack = hum:LoadAnimation(observantAnim)

-- Функція створення кнопок (додаємо в gui)
local function createCircleButton(name, pos, color)
    local btn = Instance.new("TextButton", gui)
    btn.Name = name
    btn.Size = UDim2.new(0, 70, 0, 70)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBlack
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    return btn
end

local punchBtn = createCircleButton("PUNCH", UDim2.new(1, -90, 0.5, -120), Color3.fromRGB(130, 0, 200))
local voidBtn = createCircleButton("VOID", UDim2.new(1, -90, 0.5, -30), Color3.fromRGB(90, 0, 150))
local novaBtn = createCircleButton("NOVA", UDim2.new(1, -90, 0.5, 60), Color3.fromRGB(160, 50, 255))

-- [[ INICIALIZAR ]] --
hum.HealthChanged:Connect(function() 
    if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end 
end)

hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
changeDefaultAnims()
