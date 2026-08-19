local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local CHAOS_RADIUS = 80
local FLING_POWER = 180
local isRunning = true

local function flingPart(part)
	if not part or not part.Parent then return end
	if part:IsA("BasePart") then
		part.Anchored = false
		part.CanCollide = true
		
		local bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bv.Velocity = Vector3.new(
			math.random(-FLING_POWER, FLING_POWER),
			math.random(40, 120),
			math.random(-FLING_POWER, FLING_POWER)
		)
		bv.Parent = part
		game:GetService("Debris"):AddItem(bv, 0.4)
	end
end

local function destroyJoints(character)
	if not character then return end
	for _, v in pairs(character:GetDescendants()) do
		if v:IsA("Motor6D") or v:IsA("Weld") or v:IsA("WeldConstraint") then
			v:Destroy()
		end
	end
end

local function chaosLoop()
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- Хаос по частям карты
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and obj.Parent ~= character then
			local dist = (obj.Position - hrp.Position).Magnitude
			if dist < CHAOS_RADIUS and math.random() < 0.15 then
				flingPart(obj)
			end
		end
	end

	-- Хаос по игрокам
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local otherHRP = plr.Character:FindFirstChild("HumanoidRootPart")
			if otherHRP then
				local dist = (otherHRP.Position - hrp.Position).Magnitude
				if dist < CHAOS_RADIUS then
					-- Разбираем на части
					if math.random() < 0.25 then
						destroyJoints(plr.Character)
					end
					-- Флингуем
					if math.random() < 0.3 then
						flingPart(otherHRP)
					end
				end
			end
		end
	end

	-- Себе тоже немного хаоса (чтобы было весело)
	if math.random() < 0.08 then
		flingPart(hrp)
	end
end

-- Запуск
local connection = RunService.Heartbeat:Connect(function()
	if isRunning then
		chaosLoop()
	end
end)

-- Остановка
getgenv().StopChaos = function()
	isRunning = false
	if connection then
		connection:Disconnect()
	end
	print("Хаос выключен")
end

print("ПОЛНЫЙ ХАОС ЗАПУЩЕН")
print("Чтобы выключить: StopChaos()")
