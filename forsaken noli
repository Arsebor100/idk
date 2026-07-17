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

-- НОВАЯ КНОПКА ДЕАКТИВАЦИИ
local deactivateBtn = createCircleButton("DEACTIVATE", UDim2.new(1, -90, 0.5, 150), Color3.fromRGB(200, 0, 0))
deactivateBtn.Size = UDim2.new(0, 80, 0, 80)  -- чуть больше

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

-- ... (весь остальной код меню остаётся без изменений) ...

-- [[ ФУНКЦИЯ ПОЛНОЙ ДЕАКТИВАЦИИ ]] --
local function deactivateScript()
    print("NoliGUI деактивирован")
    
    -- Останавливаем все анимации
    if punchTrack then punchTrack:Stop() end
    if voidTrack then voidTrack:Stop() end
    if novaTrack then novaTrack:Stop() end
    if observantTrack then observantTrack:Stop() end
    
    -- Удаляем GUI
    if gui then gui:Destroy() end
    
    -- Возвращаем нормальную скорость и прыжки
    if hum then
        hum.WalkSpeed = 16
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
    end
    
    -- Удаляем aura если есть
    if char then
        local aura = char:FindFirstChild("NoliTPAura")
        if aura then aura:Destroy() end
    end
end

-- Подключение кнопки
deactivateBtn.MouseButton1Click:Connect(deactivateScript)

-- [[ ОСТАЛЬНОЙ КОД (без изменений) ]] --
-- (весь код от runBtn.MouseButton1Click и ниже остаётся таким же, как ты прислал)

-- В конец скрипта добавь это:
plr.CharacterAdded:Connect(function(newChar)
    char = newChar
    hum = newChar:WaitForChild("Humanoid")
    hrp = newChar:WaitForChild("HumanoidRootPart")
    -- ... твой код ...
end)

print("NoliGUI загружен | Кнопка DEACTIVATE добавлена")
