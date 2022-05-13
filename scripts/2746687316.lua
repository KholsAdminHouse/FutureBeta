repeat wait() until game:IsLoaded()
local GuiLibrary = shared.Future.GuiLibrary
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local WORKSPACE = game:GetService("Workspace")
local PLAYERS = game:GetService("Players")
local lplr = PLAYERS.LocalPlayer
local mouse = lplr:GetMouse()
local cam = WORKSPACE.CurrentCamera
local getcustomasset = getsynasset or getcustomasset
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport

local function requesturl(url, bypass) 
    if isfile(url) and shared.FutureDeveloper then 
        return readfile(url)
    end
    local repourl = bypass and "https://raw.githubusercontent.com/KholsAdminHouse/" or "https://raw.githubusercontent.com/KholsAdminHouse/FutureBeta/main/"
    local url = url:gsub("Future/", "")
    local req = requestfunc({
        Url = repourl..url,
        Method = "GET"
    })
    if req.StatusCode == 404 then error("404 Not Found") end
    return req.Body
end 

local function getasset(path)
	if not isfile(path) then
		local req = requestfunc({
			Url = "https://raw.githubusercontent.com/KholsAdminHouse/FutureBeta/main/"..path:gsub("Future/assets", "assets"),
			Method = "GET"
		})
        print("[Future] downloading "..path.." asset.")
		writefile(path, req.Body)
        print("[Future] downloaded "..path.." asset successfully!")
	end
	return getcustomasset(path) 
end

local HeartbeatTable = {}
local RenderStepTable = {}
local SteppedTable = {}
local function isAlive(plr)
    local plr = plr or lplr
    if plr and plr.Character and (plr.Character:FindFirstChild("RootPart")) then
        return true
    end
end

local function BindToHeartbeat(name, func)
    if HeartbeatTable[name] == nil then
        HeartbeatTable[name] = game:GetService("RunService").Heartbeat:connect(func)
    end
end
local function UnbindFromHeartbeat(name)
    if HeartbeatTable[name] then
        HeartbeatTable[name]:Disconnect()
        HeartbeatTable[name] = nil
    end
end
local function BindToRenderStep(name, func)
	if RenderStepTable[name] == nil then
		RenderStepTable[name] = game:GetService("RunService").RenderStepped:connect(func)
	end
end
local function UnbindFromRenderStep(name)
	if RenderStepTable[name] then
		RenderStepTable[name]:Disconnect()
		RenderStepTable[name] = nil
	end
end
local function BindToStepped(name, func)
	if SteppedTable[name] == nil then
		SteppedTable[name] = game:GetService("RunService").Stepped:connect(func)
	end
end
local function UnbindFromStepped(name)
	if SteppedTable[name] then
		SteppedTable[name]:Disconnect()
		SteppedTable[name] = nil
	end
end

local function ferror(...)
    local args ={...}
    local str=""
    for i,v in next,args do 
        str=str.." "..tostring(v)
    end
    GuiLibrary["CreateNotification"]("<font color='rgb(255, 10, 10)'>[ERROR]"..str.."</font>")
    error("[Future]"..str)
end

local function fwarn(...)
    local args ={...}
    local str=""
    for i,v in next,args do 
        str=str.." "..tostring(v)
    end
    warn("[Future]"..str)
    GuiLibrary["CreateNotification"]("<font color='rgb(255, 255, 10)'>[WARNING] "..str.."</font>")
end

local function fprint(...)
    local args ={...}
    local str=""
    for i,v in next,args do 
        str=str.." "..tostring(v)
    end
    print("[Future]"..str)
    GuiLibrary["CreateNotification"]("<font color='rgb(200, 200, 200)'>"..str.."</font>")
end

local function getColorFromPlayer(v) 
    if v.Team ~= nil then return v.TeamColor.Color end
end

local function getPlrNearMouse(max)
    local max = max or 99999999999999
    local nearestval, nearestnum = nil,max
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            local pos, vis = WORKSPACE.CurrentCamera:WorldToScreenPoint(v.Character.RootPart.root.Position)
            if vis and pos then 
                local diff = (UIS:GetMouseLocation() - Vector2.new(pos.X, pos.Y)).Magnitude
                if diff < nearestnum then 
                    nearestnum = diff 
                    nearestval = v
                end
            end
        end
    end
    return nearestval
end

local function getAimAt(pos)
    return WORKSPACE.CurrentCamera:WorldToScreenPoint(pos)
end

local function aimAt(pos,smooth)
    local smooth = smooth +1
    local targetPos = WORKSPACE.CurrentCamera:WorldToScreenPoint(pos)
    local mousePos = WORKSPACE.CurrentCamera:WorldToScreenPoint(mouse.Hit.p)
    mousemoverel((targetPos.X-mousePos.X)/smooth,(targetPos.Y-mousePos.Y)/smooth)
end

-- Get character model from player instance 
local function getCharacterModel(v) 
    local v = (typeof(v) == "number" and v) or (v:IsA("Player") and v.UserId)
    if v then 
        return game.Workspace.Playermodels:FindFirstChild(v)
    end
end

-- Create hook

if not shared.GAMESUNITECHARACTERHOOK then
    shared.GAMESUNITECHARACTERHOOK = true
    local oldindex; oldindex = hookmetamethod(game, "__index", function(Self, Key, ...)
        if checkcaller() and Self:IsA("Player") and Key == "Character" then
            return getCharacterModel(Self)
        end

        return oldindex(Self, Key, ...)
    end)
end

GuiLibrary["RemoveObject"]("WallHackOptionsButton")
GuiLibrary["RemoveObject"]("SmoothAimOptionsButton")
do 
    local smoothaim = {["Enabled"] = false}
    local smoothaimfov = {["Value"] = 40 }
    local smoothaimsmoothness = {["Value"] = 0}
    local smoothaimpart = {["Value"] ="Root"}
    local smoothaimheld = {["Value"] = "LMB"}

    smoothaim = GuiLibrary["Objects"]["CombatWindow"]["API"].CreateOptionsButton({
        ["Name"] = "SmoothAim",
        ["Function"] = function(callback) 
            if callback then 
                BindToStepped("SmoothAim", function() 
                    local aimpart = smoothaimpart["Value"] == "Root" and "RootPart" or "Head"
                    local plr = getPlrNearMouse(smoothaimfov["Value"] * 10)
                    if plr and isAlive(plr) and UIS:IsMouseButtonPressed(smoothaimheld["Value"] == "LMB" and 0 or 1) then 
                        aimAt(plr.Character.RootPart.root.Position + (aimpart == "Head" and Vector3.new(0, 4, 0) or Vector3.new(0,2,0)), smoothaimsmoothness["Value"])
                    end
                end)
            else
                UnbindFromStepped("SmoothAim")
            end
        end
    })
    smoothaimpart = smoothaim.CreateSelector({
        ["Name"] = "Part",
        ["Function"] = function() end, 
        ["List"] = {"Root", "Head"}
    })
    smoothaimheld = smoothaim.CreateSelector({
        ["Name"] = "Held",
        ["Function"] = function() end, 
        ["List"] = {"LMB", "RMB"}
    })
    smoothaimsmoothness = smoothaim.CreateSlider({
        ["Name"] = "Smoothness",
        ["Function"] = function(value) end,
        ["Min"] = 1,
        ["Max"] = 50,
        ["Round"] = 0,
    })
    smoothaimfov = smoothaim.CreateSlider({
        ["Name"] = "FOV",
        ["Function"] = function() end,
        ["Min"] = 1,
        ["Max"] = 100,
        ["Round"] = 0,
    })
end

GuiLibrary["RemoveObject"]("FakeLagOptionsButton")
do
    local fakelagsend = {["Enabled"] = false}
    local fakelagreceive = {["Enabled"] = false}
    local fakelag = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "FakeLag",
        ["Function"] = function(callback) 
            if callback then
                if fakelagsend["Enabled"] then 
                    BindToHeartbeat("SendFakeLag", function() 
                        if isAlive() then
                            sethiddenproperty(lplr.Character.RootPart, "NetworkIsSleeping", true)
                        end
                    end)
                end
                if fakelagreceive["Enabled"] then 
                    settings().Network.IncomingReplicationLag = 99999999999999999
                end
            else
                settings().Network.IncomingReplicationLag = 0
                UnbindFromHeartbeat("SendFakeLag")
            end
        end,
    })
    fakelagsend = fakelag.CreateToggle({
        ["Name"] = "Sending",
        ["Function"] = function() end,
    })
    fakelagreceive = fakelag.CreateToggle({
        ["Name"] = "Recieving",
        ["Function"] = function() end,
    })
end

GuiLibrary["RemoveObject"]("ChamsOptionsButton")
do
    local chams = {["Enabled"] = false}
    local chamsoutline = {["Enabled"] = false}
    local chamswalls = {["Enabled"] = false}
    local chamsfolder = Instance.new("Folder", GuiLibrary["ScreenGui"]); chamsfolder.Name = "Chams"
    local chamstransparency = {["Value"] = 0}
    local chamsteamcheck = {["Enabled"] = true}
    local chamslplr = {["Enabled"] = false}

    local chamsplayeraddedconnection
    local chamsplayerremovingconnection
    local chamscharacteraddedconnections = {}

    local function addHighlight(plr)
        spawn(function()
            repeat wait() until isAlive(plr)
            if (chamsteamcheck["Enabled"] and plr.Team ~= lplr.Team or not chamsteamcheck["Enabled"]) and (not chamslplr["Enabled"] and plr ~= lplr or chamslplr["Enabled"]) then
                local highlight
                if not chamsfolder:FindFirstChild(plr.Name) then
                    highlight = Instance.new("Highlight", chamsfolder)
                else
                    highlight = chamsfolder:FindFirstChild(plr.Name)
                end
                highlight.Adornee = plr.Character
                highlight.Name = plr.Name
                highlight.FillColor = chamsteamcheck["Enabled"] and getColorFromPlayer(plr) or GuiLibrary["GetColor"]()
                GuiLibrary["Signals"]["UpdateColor"]:connect(function()
                    highlight.FillColor = chamsteamcheck["Enabled"] and getColorFromPlayer(plr) or GuiLibrary["GetColor"]()
                end)
                highlight.OutlineColor = Color3.new(1,1,1)
                highlight.OutlineTransparency = chamsoutline["Enabled"] and 0 or 1
                highlight.FillTransparency = chamstransparency["Value"]/100
                highlight.DepthMode = chamswalls["Enabled"] and 1 or 0
            end
        end)
    end

    local function removeHighlight(plr) 
        if chamsfolder:FindFirstChild(plr.Name) then 
            chamsfolder:FindFirstChild(plr.Name):Destroy()
        end
    end

    chams = GuiLibrary["Objects"]["RenderWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Chams",
        ["Function"] = function(callback) 
            if callback then
                for i,v in next, PLAYERS:GetPlayers() do 
                    addHighlight(v)
                    chamscharacteraddedconnections[v.Name] = v.CharacterAdded:connect(function(char) 
                        addHighlight(v)
                    end)
                end 
                chamsplayeraddedconnection = PLAYERS.PlayerAdded:connect(function(plr)
                    addHighlight(plr)
                    chamscharacteraddedconnections[plr.Name] = plr.CharacterAdded:connect(function(char) 
                        addHighlight(plr)
                    end)
                end)
                chamsplayerremovingconnection = PLAYERS.PlayerRemoving:connect(function(plr) 
                    removeHighlight(plr)
                end)
            else
                if chamsplayeraddedconnection then
                    chamsplayeraddedconnection:Disconnect()
                    chamsplayeraddedconnection = nil
                end
                if chamsplayerremovingconnection then
                    chamsplayerremovingconnection:Disconnect()
                    chamsplayerremovingconnection = nil
                end
                if #chamscharacteraddedconnections > 0 then 
                    for i,v in next, chamscharacteraddedconnections do 
                        v:Disconnect()
                        chamscharacteraddedconnections[i] = nil
                    end
                end
                chamscharacteraddedconnections = {}
                chamsfolder:ClearAllChildren()
            end
        end,
    })
    chamstransparency = chams.CreateSlider({
        ["Name"] = "Transparency",
        ["Function"] = function()
            for i,v in next, chamsfolder:GetChildren() do
                if v:IsA("Highlight") then
                    v.FillTransparency = chamstransparency["Value"]/100
                end
            end
        end,
        ["Min"] = 0,
        ["Max"] = 100,
        ["Default"] = 0,
        ["OnInputEnded"] = false
    })
    chamsoutline = chams.CreateToggle({
        ["Name"] = "Outline",
        ["Function"] = function(callback)
            for i,v in next, chamsfolder:GetChildren() do
                if v:IsA("Highlight") then
                    v.OutlineTransparency = callback and 0 or 1
                end
            end
        end
    }) 
    chamsteamcheck = chams.CreateToggle({
        ["Name"] = "TeamCheck",
        ["Function"] = function() end,
        ["Default"] = true
    })
    chamswalls = chams.CreateToggle({
        ["Name"] = "WallCheck",
        ["Function"] = function(callback) 
            for i,v in next, chamsfolder:GetChildren() do
                if v:IsA("Highlight") then
                    v.DepthMode = callback and 1 or 0
                end
            end
        end
    })
    chamslplr = chams.CreateToggle({
        ["Name"] = "Self",
        ["Function"] = function(callback)
            local func = callback and addHighlight or removeHighlight
            if chams.Enabled then
                func(lplr)
            end
        end,
    })
end
