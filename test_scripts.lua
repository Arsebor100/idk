local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local ESP_Config = {
    Enabled = true,
    TeamCheck = false,
    
    Allies = {
        Color = Color3.fromRGB(0, 255, 127),
        OutlineColor = Color3.fromRGB(0, 50, 0),
        Box = true,
        Name = true,
        Distance = true,
        Tracer = false,
    },
    
    Enemies = {
        Color = Color3.fromRGB(255, 30, 30),
        OutlineColor = Color3.fromRGB(50, 0, 0),
        Box = true,
        Name = true,
        Distance = true,
        Tracer = true,
    },
    
    TextSize = 13,
    BoxThickness = 1,
    TracerOrigin = Vector2.new(Camera and Camera.ViewportSize.X / 2 or 0, Camera and Camera.ViewportSize.Y or 0)
}

local ESP_Folder = Instance.new("Folder")
ESP_Folder.Name = "Custom_ESP"
ESP_Folder.Parent = CoreGui

local Camera = workspace.CurrentCamera

local function IsFriend(player)
    if player == LocalPlayer then return false end
    local success, result = pcall(function()
        return LocalPlayer:IsFriendsWith(player.UserId)
    end)
    return success and result
end

local function CreateESP(player)
    if player == LocalPlayer then return end

    local BoxOutline = Drawing.new("Square")
    BoxOutline.Visible = false
    BoxOutline.Thickness = ESP_Config.BoxThickness + 2
    BoxOutline.Filled = false

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Thickness = ESP_Config.BoxThickness
    Box.Filled = false

    local NameTag = Drawing.new("Text")
    NameTag.Visible = false
    NameTag.Center = true
    NameTag.Outline = true
    NameTag.Size = ESP_Config.TextSize

    local DistanceTag = Drawing.new("Text")
    DistanceTag.Visible = false
    DistanceTag.Center = true
    DistanceTag.Outline = true
    DistanceTag.Size = ESP_Config.TextSize - 2

    local Tracer = Drawing.new("Line")
    Tracer.Visible = false
    Tracer.Thickness = 1

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not ESP_Config.Enabled or not player.Parent or not player.Character then
            Box.Visible = false
            BoxOutline.Visible = false
            NameTag.Visible = false
            DistanceTag.Visible = false
            Tracer.Visible = false
            if not player.Parent then
                Box:Remove()
                BoxOutline:Remove()
                NameTag:Remove()
                DistanceTag:Remove()
                Tracer:Remove()
                connection:Disconnect()
            end
            return
        end

        local character = player.Character
        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if hrp and humanoid and humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local isAlly = IsFriend(player)
                local settings = isAlly and ESP_Config.Allies or ESP_Config.Enemies

                local head = character:FindFirstChild("Head")
                local headPos = head and Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0)) or pos
                local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))

                local height = math.abs(headPos.Y - legPos.Y)
                local width = height / 2

                if settings.Box then
                    BoxOutline.Size = Vector2.new(width, height)
                    BoxOutline.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                    BoxOutline.Color = settings.OutlineColor
                    BoxOutline.Visible = true

                    Box.Size = Vector2.new(width, height)
                    Box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                    Box.Color = settings.Color
                    Box.Visible = true
                else
                    Box.Visible = false
                    BoxOutline.Visible = false
                end

                if settings.Name then
                    NameTag.Text = (isAlly and "[Friend] " or "") .. player.Name
                    NameTag.Position = Vector2.new(pos.X, (pos.Y - height / 2) - 16)
                    NameTag.Color = settings.Color
                    NameTag.Visible = true
                else
                    NameTag.Visible = false
                end

                if settings.Distance then
                    local dist = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0)
                    DistanceTag.Text = tostring(dist) .. "m"
                    DistanceTag.Position = Vector2.new(pos.X, (pos.Y + height / 2) + 2)
                    DistanceTag.Color = Color3.fromRGB(200, 200, 200)
                    DistanceTag.Visible = true
                else
                    DistanceTag.Visible = false
                end

                if settings.Tracer then
                    Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    Tracer.To = Vector2.new(pos.X, pos.Y + height / 2)
                    Tracer.Color = settings.Color
                    Tracer.Visible = true
                else
                    Tracer.Visible = false
                end
            else
                Box.Visible = false
                BoxOutline.Visible = false
                NameTag.Visible = false
                DistanceTag.Visible = false
                Tracer.Visible = false
            end
        else
            Box.Visible = false
            BoxOutline.Visible = false
            NameTag.Visible = false
            DistanceTag.Visible = false
            Tracer.Visible = false
        end
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end

Players.PlayerAdded:Connect(CreateESP)
