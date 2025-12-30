if getgenv().UI_LOADED then return else getgenv().UI_LOADED = true end

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local TeleportService = game:GetService("TeleportService")
local Workspace = game:GetService("Workspace")

local states = {
    fullbright = false,
    infiniteSprint = false,
    teslaSpam = false,
    serverBypass = false
}

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CustomUI"
screenGui.Parent = Player:WaitForChild("PlayerGui")

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 600)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- UI Layout
local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = mainFrame

-- Botón Toggle
local function CreateToggleButton(text, key, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
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

-- Botón simple
local function CreateButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.Text = text
    btn.Parent = mainFrame
    btn.MouseButton1Click:Connect(callback)
end

-- FUNCIONES PRINCIPALES

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
    if state then
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid_root = Player.Character:FindFirstChild("HumanoidRootPart")
            humanoid_root:Destroy()
        end
    end
end)

-- Teleport buttons
CreateButton("Teleport to Test Place", function()
    TeleportService:Teleport(4346713746, Player)
end)

-- Weapons
CreateButton("Infinite Ammo", function()
    for _,v in pairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "_discharge") and rawget(v, "InvokeServer") then
            local Network = v
            local hook; hook = hookfunction(rawget(v, "_discharge"), newcclosure(function(gun)
                Network:FireServer("setToolState", "Reload")
                Network:FireServer("setToolState", "Reloaded")
                gun.Ammo = 999
                hook(gun)
            end))
        end
    end
end)

CreateButton("Disable RPM", function()
    local hook; hook = hookfunction(task.wait, newcclosure(function(...: number?)
        if checkcaller() then return hook(...) end
        local t = ...
        local caller = debug.info(3, "f")
        if caller and debug.info(caller, "n") == "_activateDischarge" then t = nil end
        return hook(t)
    end))
end)

-- Doors
CreateButton("Open nearest keycard door", function()
    for _,v in pairs(CollectionService:GetTagged("Door")) do
        network.FireServer("interactWith","Door", v:GetAttribute("Id"), "Front")
        network.FireServer("interactWith", "Door", v:GetAttribute("Id"), "Back")
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
