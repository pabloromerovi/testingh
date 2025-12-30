if getgenv().UI_LOADED == true then return else getgenv().UI_LOADED = true end

local Services = setmetatable({}, {
	__index = function(self, name)
		local success, cache = pcall(function()
			return cloneref(game:GetService(name))
		end)
		if success then
			rawset(self, name, cache)
			return cache
		else
			warn("Invalid Service: " .. tostring(name))
		end
	end
})

function SafeGetService(name)
	return Services[name]
end

local RunService = SafeGetService("RunService")
local Players = SafeGetService("Players")
local Player = Players.LocalPlayer
local CollectionService = SafeGetService("CollectionService")
local TeleportService = SafeGetService("TeleportService")

local network = {}
local wait = task.wait
local spawn = task.spawn

local states = {
	server_bypass = false;
	mod_kick = false;
	mod_notifier = false;
	ddos_send_count = 20;
	fire_rate = 800;
	insta_kill_send_count = 20;
	avoid = false;
	tesla_spam = false;
	infinite_run = false;
}

-- SERVER BYPASS
local server_bypass = @native function(value: boolean)
	if value then
		if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return end
		local humanoid_root: Part = Player.Character:FindFirstChild("HumanoidRootPart")
		local hook; hook = hookmetamethod(game, "__namecall", newcclosure(function(...)
			if checkcaller() then return hook(...) end
			local args = {...}
			local method = string.lower(getnamecallmethod())
			local self = args[1]
			table.remove(args, 1)
			if typeof(self) == "Instance" and method == "findfirstchild" and args[1] == "HumanoidRootPart" and Player.Character and Player.Character:FindFirstChild("LowerTorso") and self == Player.Character then
				return Player.Character.LowerTorso
			end
			return hook(...)
		end))
		local hook; hook = hookmetamethod(game, "__index", newcclosure(function(...)
			if checkcaller() then return hook(...) end
			local self, index = ...
			if typeof(self) == "Instance" and index == "HumanoidRootPart" and self == Player.Character then
				return Player.Character:FindFirstChild("LowerTorso")
			end
			return hook(...)
		end))
		humanoid_root:Destroy()
	else
		if isfunctionhooked(getrawmetatable(game).__namecall) and isfunctionhooked(getrawmetatable(game).__index) then
			restorefunction(getrawmetatable(game).__namecall)
			restorefunction(getrawmetatable(game).__index)
		end
	end
end

-- INFINITE SPRINT
local toggle_run = function(active)
	for _,v in getgc(true) do
		if type(v) == "table" and rawget(v, "Sprint") and type(rawget(v, "Sprint")) == "number" then
			v.Sprint = active and math.huge or 21
		end
	end
end

-- NETWORK FUNCTIONS
for _,v in getgc(false) do
	if type(v) == "function" and islclosure(v) then
		if debug.info(v, "n") == "FireServer" then
			network.FireServer = v
		elseif debug.info(v, "n") == "InvokeServer" then
			network.InvokeServer = v
		end
	end
end

-- INFINITE AMMO
local toggle_infinite_ammo; toggle_infinite_ammo = @native function(enabled: boolean)
	local LUA_GC = getgc(true)
	local Network
	local newluaclosure = newlclosure
	for _,v in LUA_GC do
		if type(v) == "table" then
			if rawget(v, "InvokeServer") then
				Network = v
			elseif rawget(v, "_discharge") then
				if not enabled then
					restorefunction(rawget(v, "_discharge"))
					break
				end
				local hook; hook = hookfunction(rawget(v, "_discharge"), newluaclosure(function(gun_settings)
					Network:FireServer("setToolState", "Reload")
					Network:FireServer("setToolState", "Reloaded")
					gun_settings.Ammo = 999
					hook(gun_settings)
				end))
			end
		end
	end
end

-- UI LIBRARY
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()
local Window = Library:Window("Discord Library")
local Main = Window:Server("Main", "")
local Weapons = Window:Server("Weapons", "")
local Moderation = Window:Server("Moderation", "")
local DDoS = Window:Server("DDoS", "")
local Teleport = Window:Server("Teleportation", "")
local Doors = Window:Server("Doors", "")
local Misc = Window:Server("Utilities", "")

-- Estados de botones toggles
local statesToggle = {}

-- FUNCION GENERICA PARA BOTON TOGGLE
local function ButtonToggle(server, name, callback)
	statesToggle[name] = false
	server:Button(name, function()
		statesToggle[name] = not statesToggle[name]
		callback(statesToggle[name])
		Library:Notification("Notification", name .. (statesToggle[name] and " ACTIVADO" or " DESACTIVADO"), "Okay!")
	end)
end

-- MAIN TOGGLES
ButtonToggle(Main, "Fullbright", function(active)
	if active then
		local hook; hook = hookmetamethod(game, "__newindex", newcclosure(function(self, index, value)
			if not checkcaller() and self == game:GetService("Lighting") then return end
			hook(self, index, value)
		end))
	else
		restorefunction(getrawmetatable(game).__newindex)
	end
end)

Main:Button("Teleport to Testing Place", function()
	TeleportService:Teleport(4346713746, Player)
end)

ButtonToggle(Main, "Infinite Sprint", function(active)
	toggle_run(active)
end)

Main:Button("Remove Barriers", function()
	for _,v in workspace.Ignore:GetChildren() do
		if tostring(v) == "Block" or tostring(v) == "CI" then
			v:Destroy()
		end
	end
end)

ButtonToggle(Main, "Disable Blinking", function(active)
	for _,v in getgc(false) do
		if type(v) == "function" and islclosure(v) and (debug.info(v,"n") == "ToggleBlink" or debug.info(v,"n") == "UpdateBlink") then
			if active then
				hookfunction(v, function() end)
			else
				if isfunctionhooked(v) then restorefunction(v) end
			end
		end
	end
end)

-- WEAPONS
ButtonToggle(Weapons, "Infinite Ammo", function(active)
	toggle_infinite_ammo(active)
end)

ButtonToggle(Weapons, "Disable RPM", function(active)
	if active then
		local hook; hook = hookfunction(task.wait, newcclosure(function(time)
			if checkcaller() then return hook(time) end
			local caller = debug.info(3,"f")
			if caller and debug.info(caller,"n") == "_activateDischarge" then time = nil end
			return hook(time)
		end))
	else
		if isfunctionhooked(task.wait) then restorefunction(task.wait) end
	end
end)

-- TELEPORT
local TP = Teleport:Dropdown("Teleport to Player", {}, function() end)
TP:Button("TP to Player", function()
	-- lógica de teleport a jugador
end)
TP:Dropdown("Teleport to Place", {}, function() end)
TP:Button("TP to Place", function()
	-- lógica de teleport a lugar
end)

-- DOORS
Doors:Button("Open Keycard Door Nearest", function()
	for _,v in CollectionService:GetTagged("Door") do
		network.FireServer("interactWith","Door", v:GetAttribute("Id"), "Front")
		network.FireServer("interactWith","Door", v:GetAttribute("Id"), "Back")
	end
end)

Doors:Button("Open All Keycard Doors", function()
	if not Player.Character or not Player.Character:FindFirstChildWhichIsA("Tool") then return end
	local Card = Player.Character:FindFirstChildWhichIsA("Tool")
	for _,v in CollectionService:GetTagged("Door") do
		for _, part in v:GetDescendants() do
			if part:FindFirstChild("TouchInterest") then
				firetouchinterest(Card.Handle, part, 0)
				firetouchinterest(Card.Handle, part, 1)
			end
		end
	end
end)

ButtonToggle(Doors, "Spam Teslas", function(active)
	states.tesla_spam = active
end)

-- MODERATION
ButtonToggle(Moderation, "Server Bypass", function(active)
	states.server_bypass = active
	server_bypass(active)
end)

-- DDoS
DDoS:Button("Load Character Spam", function()
	for i = 1, 20 do
		network.FireServer("switchTeamMenu","Janitor")
	end
end)

-- AUTOMATICO AL REAPARECER
Player.CharacterAdded:Connect(function(char)
	if states.server_bypass then server_bypass(true) end
	if statesToggle["Infinite Sprint"] then toggle_run(true) end
end)

RunService.PreRender:Connect(function()
	if states.tesla_spam and Player and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
		local touchies = {} -- llenar con TouchTransmitters
		for _,v in touchies do
			firetouchinterest(Player.Character.HumanoidRootPart, v.Parent, 0)
			wait()
			firetouchinterest(Player.Character.HumanoidRootPart, v.Parent, 1)
		end
	end
end)
