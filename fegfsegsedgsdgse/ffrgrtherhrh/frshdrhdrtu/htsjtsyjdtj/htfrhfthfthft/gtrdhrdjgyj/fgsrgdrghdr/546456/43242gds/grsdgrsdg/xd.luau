local plr = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

-- RootPart reference
local root = plr.Character and plr.Character:WaitForChild("HumanoidRootPart")
plr.CharacterAdded:Connect(function(character)
    root = character:WaitForChild("HumanoidRootPart")
end)

-- Vent TP setup
local ventCFrame = CFrame.new(538.300049, 34, -190.999969, -1.1920929e-07, 0, 1.00000012, 0, 1, 0, -1.00000012, 0, -1.1920929e-07) * CFrame.Angles(0, math.rad(90), 0)
local targetPos = Vector3.new(538.300049, 34, -190.999969)
local distance = 1
local tpConnection

local function safeTeleport(destination)
    if not root or not root.Parent then return end
    if tpConnection then
        tpConnection:Disconnect()
        tpConnection = nil
    end

    tpConnection = RunService.Heartbeat:Connect(function()
        local currentPos = root.Position
        root:PivotTo(ventCFrame)
        if (currentPos - targetPos).Magnitude <= distance then
            root:PivotTo(destination)
            tpConnection:Disconnect()
            tpConnection = nil
        end
    end)
end

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Teleport GUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = plr:WaitForChild("PlayerGui")

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 100, 0, 40)
toggleButton.Position = UDim2.new(0.02, 0, 0.1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.Text = "open gui"
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextScaled = true
toggleButton.Parent = screenGui
toggleButton.Active = true
toggleButton.Draggable = true

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 400)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Navigation Buttons
local mainBtn = Instance.new("TextButton")
mainBtn.Size = UDim2.new(0.25, 0, 0, 40)
mainBtn.Position = UDim2.new(0, 0, 0, 0)
mainBtn.Text = "Main"
mainBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
mainBtn.TextColor3 = Color3.new(1, 1, 1)
mainBtn.Parent = mainFrame

local lockersBtn = Instance.new("TextButton")
lockersBtn.Size = UDim2.new(0.25, 0, 0, 40)
lockersBtn.Position = UDim2.new(0.25, 0, 0, 0)
lockersBtn.Text = "Lockers"
lockersBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
lockersBtn.TextColor3 = Color3.new(1, 1, 1)
lockersBtn.Parent = mainFrame

local playersBtn = Instance.new("TextButton")
playersBtn.Size = UDim2.new(0.25, 0, 0, 40)
playersBtn.Position = UDim2.new(0.5, 0, 0, 0)
playersBtn.Text = "Players"
playersBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
playersBtn.TextColor3 = Color3.new(1, 1, 1)
playersBtn.Parent = mainFrame

local locationsBtn = Instance.new("TextButton")
locationsBtn.Size = UDim2.new(0.25, 0, 0, 40)
locationsBtn.Position = UDim2.new(0.75, 0, 0, 0)
locationsBtn.Text = "Locations"
locationsBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
locationsBtn.TextColor3 = Color3.new(1, 1, 1)
locationsBtn.Parent = mainFrame

-- Pages
local mainPage = Instance.new("Frame")
mainPage.Size = UDim2.new(1, 0, 1, -40)
mainPage.Position = UDim2.new(0, 0, 0, 40)
mainPage.BackgroundTransparency = 1
mainPage.Visible = true
mainPage.Parent = mainFrame

local lockersPage = Instance.new("ScrollingFrame")
lockersPage.Size = UDim2.new(1, 0, 1, -40)
lockersPage.Position = UDim2.new(0, 0, 0, 40)
lockersPage.BackgroundTransparency = 1
lockersPage.Visible = false
lockersPage.CanvasSize = UDim2.new(0,0,0,0)
lockersPage.Parent = mainFrame

local playersPage = Instance.new("ScrollingFrame")
playersPage.Size = UDim2.new(1, 0, 1, -40)
playersPage.Position = UDim2.new(0, 0, 0, 40)
playersPage.BackgroundTransparency = 1
playersPage.Visible = false
playersPage.CanvasSize = UDim2.new(0,0,0,0)
playersPage.Parent = mainFrame

local locationsPage = Instance.new("ScrollingFrame")
locationsPage.Size = UDim2.new(1, 0, 1, -40)
locationsPage.Position = UDim2.new(0, 0, 0, 40)
locationsPage.BackgroundTransparency = 1
locationsPage.Visible = false
locationsPage.CanvasSize = UDim2.new(0,0,0,0)
locationsPage.Parent = mainFrame

-- Main page button
local instantBtn = Instance.new("TextButton")
instantBtn.Size = UDim2.new(1, -20, 0, 40)
instantBtn.Position = UDim2.new(0, 10, 0, 20)
instantBtn.BackgroundColor3 = Color3.fromRGB(45,45,45)
instantBtn.TextColor3 = Color3.new(1,1,1)
instantBtn.Text = "Instant Prompts"
instantBtn.Parent = mainPage
instantBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            v.HoldDuration = 0
        end
    end
end)

-- Lockers
local lockers = {
    {Name="LCZ Lockers", Pos=CFrame.new(559,8,-139)},
    {Name="EZ Lockers", Pos=CFrame.new(466,9,164)},
    {Name="Get Key", Pos=CFrame.new(713,8,-98)},
    {Name="NU-7", Pos=CFrame.new(869,489,414)}
}

local yPos = 10
for _, data in ipairs(lockers) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,40)
    btn.Position = UDim2.new(0,10,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = data.Name
    btn.Parent = lockersPage

    btn.MouseButton1Click:Connect(function()
        safeTeleport(data.Pos)
    end)
    yPos = yPos + 45
end
lockersPage.CanvasSize = UDim2.new(0,0,0,yPos)

-- Locations
local locations = {
    ["Tower"]=CFrame.new(548,557,848),
    ["CI Base"]=CFrame.new(830,500,875),
    ["106 CC"]=CFrame.new(655.999939,-5.89998817,-374.19989),
    ["Medical bay"]=CFrame.new(830,8.99999809,182.000061),
    ["Cafe"]=CFrame.new(583,3.50000334,210.000031),
    ["SD bay"]=CFrame.new(431.999969,9.5,82.0000458),
    ["MTF spawn"]=CFrame.new(763.000183,489.698029,429.000183),
    ["MTF armory"]=CFrame.new(830.321289,489.5,419.206696),
    ["CDC"]=CFrame.new(1008,16.5,-171),
    ["Control room"]=CFrame.new(375.999908,24.4999962,191.000031),
    ["Gate A"]=CFrame.new(383.5,7.5,292.000031),
    ["Gate B"]=CFrame.new(718,8.5,248.000031),
    ["Shelter 1"]=CFrame.new(529,8.50000095,78.1768188),
    ["Warhead"]=CFrame.new(623.999939,-17.4999905,-297.999847),
    ["Court room"]=CFrame.new(911.927917,8.5,150.66571),
    ["173 CC"]=CFrame.new(1016,24.5,-66.9999847),
    ["SCD spawn"]=CFrame.new(871.999939,8.5,199.999985),
    ["079 CC"]=CFrame.new(828.999939,0.5,-254.499969),
    ["008 CC"]=CFrame.new(356.257416,8.50000763,-335.106445),
    ["EZ lockers"]=CFrame.new(465,10,166),
    ["LCZ lockers"]=CFrame.new(560,8,-144),
    ["Normal armory"]=CFrame.new(591,7,-153),
    ["049 CC"]=CFrame.new(528,-40,-271),
    ["914 CC"]=CFrame.new(768,8,-146),
    ["Gate A outside"]=CFrame.new(426,537,783),
    ["Gate B outside"]=CFrame.new(849,527,593),
    ["Gate B tower"]=CFrame.new(871,499,461)
}

yPos = 10
for name, cf in pairs(locations) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,-20,0,40)
    btn.Position = UDim2.new(0,10,0,yPos)
    btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Text = name
    btn.Parent = locationsPage

    btn.MouseButton1Click:Connect(function()
        safeTeleport(cf)
    end)
    yPos = yPos + 45
end
locationsPage.CanvasSize = UDim2.new(0,0,0,yPos)

-- Players
local function updatePlayers()
    playersPage:ClearAllChildren()
    local yPos = 10
    for _, plrObj in ipairs(game.Players:GetPlayers()) do
        if plrObj ~= plr then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,-20,0,40)
            btn.Position = UDim2.new(0,10,0,yPos)
            btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Text = plrObj.Name
            btn.Parent = playersPage

            btn.MouseButton1Click:Connect(function()
                if plrObj.Character and plrObj.Character:FindFirstChild("HumanoidRootPart") then
                    safeTeleport(plrObj.Character.HumanoidRootPart.CFrame)
                end
            end)
            yPos = yPos + 45
        end
    end
    playersPage.CanvasSize = UDim2.new(0,0,0,yPos)
end

game.Players.PlayerAdded:Connect(updatePlayers)
game.Players.PlayerRemoving:Connect(updatePlayers)
updatePlayers()

-- Page Switching
mainBtn.MouseButton1Click:Connect(function()
    mainPage.Visible = true
    lockersPage.Visible = false
    playersPage.Visible = false
    locationsPage.Visible = false
end)
lockersBtn.MouseButton1Click:Connect(function()
    mainPage.Visible = false
    lockersPage.Visible = true
    playersPage.Visible = false
    locationsPage.Visible = false
end)
playersBtn.MouseButton1Click:Connect(function()
    mainPage.Visible = false
    lockersPage.Visible = false
    playersPage.Visible = true
    locationsPage.Visible = false
end)
locationsBtn.MouseButton1Click:Connect(function()
    mainPage.Visible = false
    lockersPage.Visible = false
    playersPage.Visible = false
    locationsPage.Visible = true
end)

-- Toggle GUI
toggleButton.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    toggleButton.Text = mainFrame.Visible and "close gui" or "open gui"
end)
