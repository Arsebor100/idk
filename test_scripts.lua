local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local sizes = {
	Vector3.new(2, 2, 2),
	Vector3.new(4, 4, 4),
	Vector3.new(6, 2, 6)
}
local materials = {
	Enum.Material.Plastic,
	Enum.Material.Neon,
	Enum.Material.Wood,
	Enum.Material.Grass
}

local currentSize = 1
local currentMaterial = 1
local placedBlocks = {}

local function getPlacePosition()
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	return hrp.CFrame.Position + hrp.CFrame.LookVector * 6 + Vector3.new(0, 1, 0)
end

local function placeBlock()
	local pos = getPlacePosition()
	if not pos then return end
	
	local part = Instance.new("Part")
	part.Size = sizes[currentSize]
	part.Material = materials[currentMaterial]
	part.Anchored = true
	part.CanCollide = true
	part.Color = Color3.fromRGB(math.random(80, 255), math.random(80, 255), math.random(80, 255))
	part.Position = pos
	part.Name = "MyBlock"
	part.Parent = workspace
	
	table.insert(placedBlocks, part)
	print("Блок поставлен")
end

local function removeBlock()
	local target = mouse.Target
	if target and target.Name == "MyBlock" and target:IsA("BasePart") then
		target:Destroy()
		print("Блок удалён")
	end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.Q then
		placeBlock()
	elseif input.KeyCode == Enum.KeyCode.E then
		removeBlock()
	elseif input.KeyCode == Enum.KeyCode.R then
		currentSize = currentSize % #sizes + 1
		print("Размер:", currentSize)
	elseif input.KeyCode == Enum.KeyCode.F then
		currentMaterial = currentMaterial % #materials + 1
		print("Материал:", materials[currentMaterial].Name)
	end
end)

print("Скрипт запущен")
print("Q — поставить блок")
print("E — удалить блок")
print("R — сменить размер")
print("F — сменить материал")
