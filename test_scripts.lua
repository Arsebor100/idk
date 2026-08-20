local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- ======================
-- ВЫГРУЗКА ВСЕГО ЛИШНЕГО
-- ======================

-- Останавливаем известные скрипты
pcall(function() if getgenv().StopChaos then getgenv().StopChaos() end end)
pcall(function() if getgenv().StopAura then getgenv().StopAura() end end)

-- Удаляем инструменты Jerk и прочие
local function clearTools(container)
	if not container then return end
	for _, v in pairs(container:GetChildren()) do
		if v:IsA("Tool") and (v.Name:lower():find("jerk") or v.Name:lower():find("block")) then
			v:Destroy()
		end
	end
end

clearTools(player:FindFirstChild("Backpack"))
clearTools(player.Character)

-- Удаляем наши старые GUI
for _, gui in pairs(player:WaitForChild("PlayerGui"):GetChildren()) do
	if gui.Name == "ScriptUpdateNotify" or gui.Name == "ChaosGui" or gui.Name == "AuraGui" then
		gui:Destroy()
	end
end

-- Чистим getgenv от старых флагов (кроме вотчера)
local keep = {
	StopScriptWatcher = true,
	ScriptWatcherRunning = true
}

for k, v in pairs(getgenv()) do
	if not keep[k] and (typeof(v) == "function" or typeof(v) == "boolean") then
		if tostring(k):lower():find("chaos") or tostring(k):lower():find("aura") or tostring(k):lower():find("jerk") then
			getgenv()[k] = nil
		end
	end
end

print("[CLEAN] Всё лишнее выгружено. Обновлялка оставлена.")

-- ======================
-- ПРОСТОЙ БРАУЗЕР
-- ======================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SimpleBrowser"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 320, 0, 280)
main.Position = UDim2.new(0.5, -160, 0.5, -140)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
main.BorderSizePixel = 0
main.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "Browser + Cleaner"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = main

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	screenGui:Destroy()
end)

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -20, 0, 60)
info.Position = UDim2.new(0, 10, 0, 50)
info.BackgroundTransparency = 1
info.Text = "Все лишние скрипты выгружены.\nОбновлялка (Watcher) оставлена работать.\n\nМожешь закрыть это окно."
info.TextColor3 = Color3.fromRGB(200, 200, 200)
info.TextSize = 14
info.Font = Enum.Font.Gotham
info.TextWrapped = true
info.TextYAlignment = Enum.TextYAlignment.Top
info.Parent = main

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 30)
status.Position = UDim2.new(0, 10, 1, -40)
status.BackgroundTransparency = 1
status.Text = "Статус: Чисто"
status.TextColor3 = Color3.fromRGB(0, 255, 120)
status.TextSize = 14
status.Font = Enum.Font.GothamBold
status.Parent = main

print("[Browser] Окно открыто")
