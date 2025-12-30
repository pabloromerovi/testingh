if getgenv().UI_LOADED then return else getgenv().UI_LOADED = true end

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local states = {
    fullbright = false,
    infiniteSprint = false,
    teslaSpam = false,
    serverBypass = false
}

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MobileGUI"
screenGui.Parent = Player:WaitForChild("PlayerGui")
screenGui.ResetOnSpawn = false  -- No se borra al morir

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 600)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true  -- Necesario para arrastrar
mainFrame.Parent = screenGui

-- UI Layout
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = mainFrame

-- Función para arrastrar la GUI (compatible con móvil)
do
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    mainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- Crear Botón Toggle
local function CreateToggleButton(text, key, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.Text = text .. ": OFF"
    btn.Parent = mainFrame

    btn.MouseButton1Click:Connect(function()
        states[key] = not states[key]
        btn.Text = text .. (states[key] and ": ON" or ": OFF")
        if callback then callback(states[key]) end
    end)
end

-- Crear Botón Simple
local function CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.Text = text
    btn.Parent = mainFrame
    btn.MouseButton1Click:Connect(callback)
end

-- FUNCIONES

-- Fullbright
CreateToggleButton("Fullbright", "fullbright", function(state)
    if state then
        game:GetService("Lighting").Ambient = Color3.new(1,1,1)
        game:GetService("Lighting").ClockTime = 14
    else
        game:GetService("Lighting").Ambient = Color3.new(0.5,0.5,0.5)
        game:GetService("Lighting").ClockTime = 12
    end
end)

-- Infinite Sprint
local function toggleRun(state)
    for _,v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Sprint") and type(rawget(v, "Sprint")) == "number" then
            v.Sprint = state and math.huge or 21
        end
    end
end
CreateToggleButton("Infinite Sprint", "infiniteSprint", toggleRun)

-- Remove barriers
CreateButton("Remove Barriers", function()
    for _,v in pairs(Workspace.Ignore:GetChildren()) do
        if v.Name == "Block" or v.Name == "CI" then
            v:Destroy()
        end
    end
end)

-- Tesla Spam
CreateToggleButton("Tesla Spam", "teslaSpam", function() end)

-- Server Bypass
CreateToggleButton("Bypass Server AC", "serverBypass", function(state)
    if state and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = Player.Character:FindFirstChild("HumanoidRootPart")
        hrp:Destroy()
    end
end)

-- Teleport
CreateButton("Teleport to Test Place", function()
    TeleportService:Teleport(4346713746, Player)
end)

-- Doors
CreateButton("Open nearest keycard door", function()
    for _,v in pairs(CollectionService:GetTagged("Door")) do
        network.FireServer("interactWith","Door", v:GetAttribute("Id"), "Front")
        network.FireServer("interactWith","Door", v:GetAttribute("Id"), "Back")
    end
end)

CreateButton("Open all keycard doors", function()
    if not Player.Character or not Player.Character:FindFirstChildWhichIsA("Tool") then return end
    local Card = Player.Character:FindFirstChildWhichIsA("Tool")
    for _, v in pairs(CollectionService:GetTagged("Door")) do
        for _, part in pairs(v:GetDescendants()) do
            if part:FindFirstChild("TouchInterest") then
                firetouchinterest(Card.Handle, part, 0)
                firetouchinterest(Card.Handle, part, 1)
            end
        end
    end
end)

-- PreRender loop for Tesla spam
RunService.PreRender:Connect(function()
    if states.teslaSpam and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
        for _,v in pairs(Workspace:GetDescendants()) do
            if v:IsA("TouchTransmitter") then
                firetouchinterest(Player.Character.HumanoidRootPart, v.Parent, 0)
                task.wait()
                firetouchinterest(Player.Character.HumanoidRootPart, v.Parent, 1)
            end
        end
    end
end)

