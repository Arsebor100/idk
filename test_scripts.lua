local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local RAW_URL = "https://raw.githubusercontent.com/Arsebor100/idk/main/test_scripts.lua"
local CHECK_INTERVAL = 1 -- каждую секунду

local lastContent = nil
local isRunning = true

-- Функция загрузки новой версии
local function loadNewVersion(content)
	local success, err = pcall(function()
		loadstring(content)()
	end)
	if success then
		print("[Watcher] Новая версия успешно загружена")
	else
		warn("[Watcher] Ошибка при загрузке:", err)
	end
end

-- Уведомление + кнопка
local function notifyUpdate(newContent)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = "Скрипт обновился!",
			Text = "Нажми кнопку ниже чтобы загрузить",
			Duration = 12
		})
	end)

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ScriptUpdateNotify"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 280, 0, 90)
	frame.Position = UDim2.new(0.5, -140, 0.15, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 30)
	title.Position = UDim2.new(0, 10, 0, 8)
	title.BackgroundTransparency = 1
	title.Text = "Скрипт обновился!"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 18
	title.Font = Enum.Font.GothamBold
	title.Parent = frame

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, -20, 0, 36)
	button.Position = UDim2.new(0, 10, 0, 44)
	button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
	button.Text = "Загрузить новую версию"
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 16
	button.Font = Enum.Font.Gotham
	button.Parent = frame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = button

	button.MouseButton1Click:Connect(function()
		loadNewVersion(newContent)
		screenGui:Destroy()
	end)

	task.delay(20, function()
		if screenGui and screenGui.Parent then
			screenGui:Destroy()
		end
	end)
end

-- Основной цикл проверки
task.spawn(function()
	print("[Watcher] Запущен. Проверка каждую секунду...")

	while isRunning do
		local success, content = pcall(function()
			return game:HttpGet(RAW_URL .. "?t=" .. tick())
		end)

		if success and content and content ~= "" then
			if lastContent == nil then
				lastContent = content
				print("[Watcher] Первая версия сохранена")
			elseif content ~= lastContent then
				print("[Watcher] Обнаружено обновление!")
				lastContent = content
				notifyUpdate(content)
			end
		else
			warn("[Watcher] Не удалось получить файл")
		end

		task.wait(CHECK_INTERVAL)
	end
end)

getgenv().StopScriptWatcher = function()
	isRunning = false
	print("[Watcher] Остановлен")
end

print("[Watcher] Готов. Чтобы остановить: StopScriptWatcher()")
