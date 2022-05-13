-- Prophunt for future!

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
    if plr and plr.Character and ((plr.Character:FindFirstChild("Humanoid")) or (plr.Character:FindFirstChild("HumanoidRootPart"))) then
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

local function playsound(id, volume) 
    local sound = Instance.new("Sound")
    sound.Parent = workspace
    sound.SoundId = id
    sound.PlayOnRemove = true 
    if volume then 
        sound.Volume = volume
    end
    sound:Destroy()
end
 
local function playanimation(id) 
    if isAlive() then 
        local animation = Instance.new("Animation")
        animation.AnimationId = id
        local animatior = lplr.Character.Humanoid.Animator
        animatior:LoadAnimation(animation):Play()
    end
end

do 
    local AutoQueue = {["Enabled"] = false}; AutoQueue = GuiLibrary["Objects"]["MiscellaneousWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AutoQueue",
        ["Function"] = function(callback) 
            spawn(function()
                repeat
                    if AutoQueue["Enabled"] == false then break end
                    game:GetService("ReplicatedStorage")["events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"].joinQueue:FireServer({["queueType"] = "vanilla"})
                    task.wait(20) 
                until AutoQueue["Enabled"] == false
            end)
        end
    })
end

do 
    local Lagger = {["Enabled"] = false}; Lagger = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Lagger",
        ["DisableOnLeave"] = true;
        ["Function"] = function(callback) 
            if callback then 
                GuiLibrary["CreateNotification"]("Lagger discovered by Fern#5747 // fern.wtf")
                spawn(function() 
                    repeat 
                        for i = 1, 20 do
                            local args = {
                                [1] = 1,
                                [2] = "grenade",
                                [3] = game.Players.LocalPlayer.Character.HumanoidRootPart.Position,
                                [4] = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector
                            }
                            
                            game:GetService("ReplicatedStorage"):FindFirstChild("functions-@easy-games/projectile:shared/projectile-networking@ProjectileNetFunctions"):FindFirstChild("s:fireProjectile"):FireServer(unpack(args))
                        end
                        task.wait()
                    until Lagger["Enabled"] == false
                end)
            end
        end
    })
end

