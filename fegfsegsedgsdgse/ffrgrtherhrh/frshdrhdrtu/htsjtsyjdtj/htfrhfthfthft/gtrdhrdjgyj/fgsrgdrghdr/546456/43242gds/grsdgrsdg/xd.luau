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
local network = {}
local wait = task.wait
local spawn = task.spawn
local TeleportService = SafeGetService("TeleportService")

local states = {
	server_bypass = false;
	mod_kick = false;
	mod_notifer = false;
	ddos_send_count = 20;
	fire_rate = 800;
	insta_kill_send_count = 20;	
	avoid = false;
	tesla_spam = false;
	infinite_run = false;
};

local server_bypass = @native function(value: boolean)
	if value then
		if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then
			return;
		end;
		local humanoid_root: Part = Player.Character:FindFirstChild("HumanoidRootPart");
		local hook; hook = hookmetamethod(game, "__namecall", newcclosure(function(...)
			if checkcaller() then return hook(...); end;
			local args = {...};
			local method = string.lower(getnamecallmethod());
			local self = args[1];
			table.remove(args, 1);
			if typeof(self) == "Instance" and method == "findfirstchild" and args[1] and type(args[1]) == "string" and args[1] == "HumanoidRootPart" and Player.Character and Player.Character.FindFirstChild(Player.Character, "LowerTorso") and self == Player.Character then
				return Player.Character.LowerTorso;
			end;
			return hook(...);
		end));
		local hook; hook = hookmetamethod(game, "__index", newcclosure(function(...)
			if checkcaller() then  return hook(...); end;
			local self, index = ...;
			if typeof(self) == "Instance" and typeof(index) == "string" and index == "HumanoidRootPart" and self ==  char then
				return char.FindFirstChild(char, "LowerTorso");
			end;
			return hook(...);
		end));	
		humanoid_root:Destroy();
	else
		if isfunctionhooked(getrawmetatable(game).__namecall) and isfunctionhooked(getrawmetatable(game).__index) then
			restorefunction(getrawmetatable(game).__namecall);
			restorefunction(getrawmetatable(game).__index);			
		end;
	end;
	return;
end;

local toggle_run = function(): ()
	for _,v in getgc(true) do
		if type(v) == "table" and rawget(v, "Sprint") and type(rawget(v, "Sprint")) == "number" then
			v.Sprint = math.huge;
		end;
	end;
	return;
end;

for _,v in getgc(false) do
	if type(v) == "function" and islclosure(v) then
		if debug.info(v, "n") == "FireServer" then
			network.FireServer = v;
		elseif debug.info(v, "n") == "InvokeServer" then
			network.InvokeServer = v;
		end;
	end;
end;

local decode_args;  decode_args = @native function(encoded: string, key: {number}, extra: number): string
	local decoded: string = "";
	local cut_off: number = #encoded;
	if not extra then
		cut_off = #encoded - key[5] ;
	end;
	for i = 1, cut_off do
		for mod = 0, 3 do
			if i % 4 == mod then
				local char: string = string.sub(encoded, i, i);
				local off_set: number = key[mod + 1];
				local code: number = string.byte(char) - 32;
				if extra then
					off_set = -off_set;
				end;
				local original: number = (code - off_set) % 95 + 32;
				decoded = decoded .. string.char(original);
				break;
			end;
		end;
	end;
	return decoded;
end;

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/UI-Libs/main/discord%20lib.txt"))()

local Window = Library:Window("Discord Library")
local Main = Window:Server("Main", "")
local Weapons = Window:Server("Weapons", "")
local Moderation = Window:Server("Moderation", "")
local DDoS = Window:Server("DDoS", "")
local Teleport = Window:Server("Teleportation", "")
local Doors = Window:Server("Doors", "")
local Misc = Window:Server("Utilities", "")

-- TODOS LOS TOGGLE SE CONVIERTEN EN BUTTONS

--[[Main:Button("Fullbright", function()
	local hook; hook = hookmetamethod(game, "__newindex", newcclosure(function(...)
		local self, index, value = ...
		if not checkcaller() and self and typeof(self) == "Instance" and self == game:GetService("Lighting") then
			return
		end
		hook(...)
	end))
	Library:Notification("Notification", "Now run IY full bright", "Okay!")
end)]]

Main:Button("Teleport to testing place", function()
	TeleportService:Teleport(4346713746, Player)
end)

Main:Button("Minimap spy", function()
end)

Main:Button("Trigger autofarm", function()
	local send_count: number = 999999;
	for _,v in getgc(false) do
		if type(v) == "function" and debug.info(v, "n") == "_createBlood" then
			local hook; hook = hookfunction(v, newlclosure(function(...)
				for i = 1, send_count do
					wait();
					hook(...);
				end;
				return hook(...)
			end));
		end;
	end;
end)

Main:Button("Get tool", function()
end)

Main:Button("Infinite sprint", function()
	toggle_run();
end)

Main:Button("Remove barriers", function()
	for _,v in workspace.Ignore:GetChildren() do
		if tostring(v) == "Block" or tostring(v) == "CI" then
			v:Destroy()
		end
	end
end)

Main:Button("Disable blinking", function()
	for _,v in getgc(false) do
		if type(v) == "function" and islclosure(v) and (debug.info(v, "n") == "ToggleBlink" or debug.info(v, "n") == "UpdateBlink") then
			hookfunction(v, function() end)
		end
	end
end)

-- Weapons

Weapons:Label("Firerate")
Weapons:Button("Make guns automatic", function()
end)

Weapons:Button("Infinite ammo", function()
	toggle_infinite_ammo(true);
end)

Weapons:Button("Disable rpm", function()
	local hook; hook = hookfunction(task.wait, newcclosure(function(...: number?): ()
		if checkcaller() then return hook(...); end;
		local time: number? = ...
		local caller = debug.info(3, "f");
		if caller and debug.info(caller, "n") == "_activateDischarge" then time = nil :: never; end;
		return hook(time);
	end));
end)

Weapons:Label("Spread")
Weapons:Button("No spread", function()
end)

Weapons:Label("Instant kill")
Weapons:Button("Toogle instant kill", function()
end)

-- Moderation

Moderation:Label("Moderation options")
Moderation:Button("Randomize apperance", function()
end)
Moderation:Button("Moderator scan", function()
end)
Moderation:Button("Kick when moderator arrives", function()
end)
Moderation:Button("Notifier", function()
end)
Moderation:Button("Avoid moderator", function()
end)

Moderation:Label("Anti cheat options")
Moderation:Button("Bypass server ac", function()
	states.server_bypass = true;
	server_bypass(true)
end)
Moderation:Button("Bypass client ac", function()
end)

-- DDoS

DDoS:Label("Methods")
DDoS:Button("Load character spam", function()
	for i = 1, 20 do
		network:FireServer("switchTeamMenu", "Janitor");	
		network:FireServer("switchTeamMenu", "Janitor");
		network:FireServer("switchTeamMenu", "Janitor");
	end;
end)

--[[ Teleport

local TP = Teleport:Dropdown("Teleport to player",{}, function(bool)
	Teleport:Add()
end)
TP:Button("tp to player", function()
	TP:Add("Option")
end)
TP:Dropdown("Teleport to place",{}, function(bool)
	TP:Add()
end)
TP:Button("tp to place", function()
	TP:Add("Option")
end)]]

-- Doors

Doors:Label("Main")
Doors:Button("Open keycard door nearest to you", function()
	for _,v in CollectionService:GetTagged("Door") do
		network:FireServer("interactWith","Door", v:GetAttribute("Id"), "Front")
		network:FireServer("interactWith", "Door", v:GetAttribute("Id"), "Back")
	end
end)

Doors:Button("Open all keycard door", function()
	if not Player.Character or not Player.Character:FindFirstChildWhichIsA("Tool") then
		return
	end
	local Card = Player.Character:FindFirstChildWhichIsA("Tool")
	for _, v in CollectionService:GetTagged("Door") do
		for _, part in v:GetDescendants() do
			if part:FindFirstChild("TouchInterest") then
				firetouchinterest(Card.Handle, part, 0)
				firetouchinterest(Card.Handle, part, 1)
			end
		end
	end
end)

Doors:Button("Spam teslas", function()
	states.tesla_spam = true
end)

-- Misc

Misc:Label("Section 1")
Misc:Label("Section 2")

-- Character added

Player.CharacterAdded:Connect(function(charec: Model): ()
	local char = charec;
	if states.server_bypass then
		server_bypass()
	end
	if states.infinite_run then 
		toggle_run()
	end
end)

-- PreRender

RunService.PreRender:Connect(function(deltaTimeRender: number) 
	if states.tesla_spam and Player and Player.Character:FindFirstChild("HumanoidRootPart") then
		for _,v: TouchTransmitter in touchies do
			firetouchinterest(Player.Character.HumanoidRootPart, v.Parent, 0);
			wait();
			firetouchinterest(Player.Character.HumanoidRootPart, v.Parent, 1);
		end;
	end;
	return;
end);
