repeat wait() until game:IsLoaded()
local GuiLibrary = shared.Future.GuiLibrary
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local WORKSPACE = game:GetService("Workspace")
local PLAYERS = game:GetService("Players")
local COREGUI = game:GetService("CoreGui")
local lplr = PLAYERS.LocalPlayer
local mouse = lplr:GetMouse()
local cam = WORKSPACE.CurrentCamera
local getcustomasset = --[[getsynasset or getcustomasset or]] GuiLibrary["getRobloxAsset"]
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
local getgenv = getgenv or function() 
    return _G
end

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
        repeat task.wait() until isfile(path)
        print("[Future] downloaded "..path.." asset successfully!")
	end
	return getcustomasset(path) 
end

local HeartbeatTable = {}
local RenderStepTable = {}
local SteppedTable = {}
local function isAlive(plr)
    local plr = plr or lplr
    if plr and plr.Character and ((plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0) and (plr.Character:FindFirstChild("HumanoidRootPart")) and (plr.Character:FindFirstChild("Head"))) then
        return true
    end
end

local function skipFrame() 
    return game:GetService("RunService").Heartbeat:Wait()
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
local function BindToRenderStepped(name, func)
	if RenderStepTable[name] == nil then
		RenderStepTable[name] = game:GetService("RunService").RenderStepped:connect(func)
	end
end
local function UnbindFromRenderStepped(name)
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

setreadonly(getgenv().table, false)
getgenv().table.combine = function(...) 
    local args = {...}
    local MasterTable = {}
    for i,v in next, args do 
        if type(v) == "table" then 
            for i2,v2 in next, v do 
                table.insert(MasterTable, v2)
            end
        else
            table.insert(MasterTable, v)
        end
    end

    return MasterTable
end

local function getCharacters() 
    local t = {}
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) then
            t[v.Name] = v.Character
        end
    end
    return t
end

local function getColorFromPlayer(v) 
    if v.Team ~= nil then return v.TeamColor.Color end
end

local function getPlrNearMouse(max)
    local max = max or 99999999999999
    local nearestval, nearestnum = nil,max
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            local pos, vis = WORKSPACE.CurrentCamera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position)
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


local function getPlrNear(max)
    local max = max or 99999999999999
    local nearestval, nearestnum = nil,max
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            local diff = (v.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
            if diff < nearestnum then 
                nearestnum = diff 
                nearestval = v
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

local function canBeTargeted(plr, doTeamCheck) 
    if isAlive(plr) and plr~=lplr and (doTeamCheck and plr.Team ~=lplr.Team or not doTeamCheck) then 
        return true
    end
    return false
end

local function colorToRichText(color) 
    return " rgb("..tostring(color.R*255)..", "..tostring(color.G*255)..", "..tostring(color.B*255)..")"
end

local convertHealthToColor = function(health, maxHealth) 
    local percent = (health/maxHealth) * 100
    if percent < 70 then 
        return Color3.fromRGB(255, 196, 0)
    elseif percent < 45 then
        return Color3.fromRGB(255, 71, 71)
    end
    return Color3.fromRGB(96, 253, 48)
end

local function getAllPlrsNear()
    if not isAlive() then return {} end
    local t = {}
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr and v.Name ~= "StopEveryTrans" and v.Name~="BanEqualsACName" then 
            if v.Character.HumanoidRootPart then table.insert(t, (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude, v) end
        end
    end
    return t
end

local mainscript = lplr.PlayerScripts.MainLocalScript
local dependencies = {
    ["MainLocalScript"] = getsenv(mainscript),
    ["CWorld"] = require(mainscript.CWorld),
}


do 
    local canAttack = true
    local aura = {["Enabled"] = false}
    local auradist = {["Value"] = 14 }
    aura = GuiLibrary["Objects"]["CombatWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Aura",
        ["Function"] = function(callback) 
            if callback then
                spawn(function()
                    repeat task.wait(0.1) 
                        for i,v in next, getAllPlrsNear() do 
                            if isAlive() and canBeTargeted(v, false) and (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude < auradist["Value"] then 
                                local attackArgs = {
                                    v.Character
                                }
                                print(canAttack)
                                if canAttack then
                                    spawn(function()
                                        canAttack = false
                                        local x = game:GetService("ReplicatedStorage").GameRemotes.Attack:InvokeServer(table.unpack(attackArgs))
                                        if x~=nil then print(x) end
                                        canAttack = true
                                    end)
                                end
                                GuiLibrary["TargetHUDAPI"].update(v, math.floor(v.Character.Humanoid.Health))
                            else
                                GuiLibrary["TargetHUDAPI"].clear()
                            end
                        end
                    until aura["Enabled"] == false
                end)
            end
        end,
    })
    auradist = aura.CreateSlider({
        ["Name"] = "Range",
        ["Function"] = function() end,
        ["Min"] = 1,
        ["Round"] = 0,
        ["Max"] = 15,
        ["Default"] = 15
    })
end

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
                    local aimpart = smoothaimpart["Value"] == "Root" and "HumanoidRootPart" or "Head" 
                    local plr = getPlrNear()
                    if plr and canBeTargeted(plr, false) and UIS:IsMouseButtonPressed(smoothaimheld["Value"] == "LMB" and 0 or 1) then 
                        aimAt(plr.Character[aimpart].Position, smoothaimsmoothness["Value"])
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

do 
    local Speedmine = {["Enabled"] = false} 
    Speedmine = GuiLibrary["Objects"]["WorldWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Speedmine",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function()
                    repeat task.wait()
                        game:GetService("ReplicatedStorage").GameRemotes.AcceptBreakBlock:InvokeServer()
                    until not Speedmine.Enabled
                end)
            end
        end
    })
end
