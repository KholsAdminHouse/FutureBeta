-- Prophunt for future!

repeat wait() until game:IsLoaded()
local GuiLibrary = shared.Future.GuiLibrary
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local WORKSPACE = game:GetService("Workspace")
local PLAYERS = game:GetService("Players")
local CAS = game:GetService("ContextActionService")
local COREGUI = game:GetService("CoreGui")
local lplr = PLAYERS.LocalPlayer
local mouse = lplr:GetMouse()
local cam = WORKSPACE.CurrentCamera
local getcustomasset = getsynasset or getcustomasset
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
local isnetworkowner = isnetworkowner or function() return true end
local state = function() return workspace.MatchDocument:GetAttribute("matchState") end

local UnixTime = os.time()
local UpdateTime = math.huge
if UnixTime >= UpdateTime then 
    print(" game has updated. ")
    if not shared.FutureDeveloper then 
        local textlabel = Instance.new("TextLabel")
        textlabel.Size = UDim2.new(1, 0, 0, 36)
        textlabel.RichText = true
        textlabel.Text = '<stroke thickness="2">Future is down due to the prophunt update. Expect it to be back up in a few minutes. \n join the Future discord server for updates, discord.gg/bdjT5UmmDJ</stroke>'
        textlabel.BackgroundTransparency = 1
        textlabel.TextStrokeTransparency = 0
        textlabel.TextSize = 40
        textlabel.Font = Enum.Font.SourceSans
        textlabel.TextColor3 = Color3.new(1, 1, 1)
        textlabel.Position = UDim2.new(0.5, 0, 0.5, 0)
        textlabel.AnchorPoint = Vector2.new(0.5, 0.5)
        textlabel.Parent = COREGUI.RobloxGui
        GuiLibrary["SaveConfig"](GuiLibrary["CurrentConfig"])
        GuiLibrary.Signals.onDestroy:Fire()
        task.wait(30)
        textlabel:Destroy()
        return
    end
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
        print("[Future] downloaded "..path.." asset successfully!")
	end
	return getcustomasset(path) 
end

local HeartbeatTable = {}
local RenderStepTable = {}
local SteppedTable = {}
local function isAlive(plr)
    local plr = plr or lplr
    if plr and plr.Character and (plr.Character:FindFirstChild("HumanoidRootPart")) then
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


local Flamework = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
repeat task.wait() until Flamework.isInitialized
local PS = lplr.PlayerScripts
local RS = game:GetService("ReplicatedStorage")
local RD = Flamework.resolveDependency
local dependencies = {
    -- normal dependencys:
    ClientHandler = require(RS.TS.networking),
    ItemMeta = require(RS.TS.item["item-meta"]).ProphuntItemMeta,
    GunController = require(PS.TS.controllers.game.items.gun["gun-controller"]),
    VelocityUtil = require(RS.rbxts_include["node_modules"]["@easy-games"]["game-core"].out.shared.util["velocity-util"]).VelocityUtil,
    ClientSyncEvents = require(PS.TS["client-sync-events"]).ClientSyncEvents,
    HighlightController = require(PS.TS.controllers.global.highlight["highlight-controller"]).HighlightController,
    WorldIndicatorController = require(RS.rbxts_include["node_modules"]["@easy-games"]["game-core"].out.client.controllers.indicators["world-indicator-controller"]).WorldIndicatorController,
    DamageIndicatorController = require(PS.TS.controllers.game.combat["damage-indicator-controller"]).DamageIndicatorController,
    ActiveItemController = require(PS.TS.controllers.game["active-item"]["active-item-controller"]).ActiveItemController,
    SprintController = require(PS.TS.controllers.global.movement["sprint-controller"]).SprintController,
    GunUtil = require(RS.TS.gun["gun-util"]).GunUtil,
    GameQueryUtil = require(RS.rbxts_include["node_modules"]["@easy-games"]["game-core"].out.shared["game-world-query"]["game-query-util"]).GameQueryUtil,

    -- flamework dependencys:
    SprintControllerF = RD("client/controllers/global/movement/sprint-controller@SprintController"),
    InventoryHandlerF = RD("client/controllers/game/active-item/active-item-manager-controller@ActiveItemManagerController"),
    GunControllerF = RD("client/controllers/game/items/gun/gun-controller@GunController"),
    ShiftLockControllerF = RD("client/controllers/global/camera/shift-lock-controller@ShiftLockController"),
    ProjectileControllerF = RD("@easy-games/projectile:client/controllers/projectile-controller@ProjectileController"),
    CombatControllerF = RD("client/controllers/game/combat/combat-controller@CombatController"),
    SwordControllerF = RD("client/controllers/game/items/sword/sword-controller@SwordController"),
    AmmoControllerF = RD("client/controllers/game/ammo/ammo-controller@AmmoController"),
    

}

local function getColorFromPlayer(v) 
    if v.Team ~= nil then return v.TeamColor.Color end
end
 
local function getHiders() 
    local p = {}
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and (v.Character:FindFirstChild("Head") == nil or (v.Team ~= nil and v.Team.Name == "Hider")) then 
            p[v.Name] = v
        end
    end
    return p
end

local function isHider(plr) 
    local plr = plr or lplr
    return plr.Team ~= nil and plr.Team.Name == "Hider"
end

local function isSeeker(plr) 
    return not isHider(plr)
end

local function getMap() 
    if WORKSPACE.Map.Build:FindFirstChild("PropTownSign") then
        return "MALL"
    end
    return "CUBA"
end

local function getMapAutowinPosition() 
    if getMap() == "CUBA" then
        return CFrame.new(-160.108078, 40.878952, -150.817886, -0.000178738439, 0, -1, 0, 1, 0, 1, 0, -0.000178738439)
    end
    return CFrame.new(-94.5189819, 14.1403761, 113.373901, -0.110669941, 0, -0.993857205, 0, 1, 0, 0.993857205, 0, -0.110669941)
end

local function canBeTargeted(plr, doTeamCheck) 
    if isAlive(plr) and plr~=lplr and (doTeamCheck and plr.Team ~=lplr.Team or not doTeamCheck) then 
        return true
    end
    return false
end

local function vischeck(char, part, ignorelist)
	local rayparams = RaycastParams.new()
	rayparams.FilterDescendantsInstances = {lplr.Character, char, cam, table.unpack(ignorelist or {})}
	local ray = workspace.Raycast(workspace, cam.CFrame.p, CFrame.lookAt(cam.CFrame.p, char[part].Position).lookVector.Unit * (cam.CFrame.p - char[part].Position).Magnitude, rayparams)
	return not ray
end

local function requestSelfDamage(health) 
    GuiLibrary["Debug"](("Requesting self damage for %s health"):format(tostring(health)))
    local requestSelfDamage = game:GetService("ReplicatedStorage")["events-@easy-games/damage:shared/damage-networking@DamageNetEvents"].requestSelfDamage
    requestSelfDamage:FireServer(health)
end

local function getInventory() 
    return dependencies.InventoryHandlerF.inventoryController:getPlayerInventory()~=nil 
    and dependencies.InventoryHandlerF.inventoryController:getPlayerInventory():getAllItems() 
    or {}
end

local function getAllPlrsNear()
    if not isAlive() then return {} end
    local t = {}
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            if v.Character:FindFirstChild("HumanoidRootPart") ~= nil then
                pcall(function()
                    table.insert(t, (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude, v) 
                end)
            end
        end
    end
    return t
end

local function getSword()
    local items = getInventory()
    for i,v in pairs(items) do 
		if v.item:find("sword") or v.item:find("pan") or v.item:find("bat") then 
			return v
		end
	end
end

local function getPistol()
    local items = getInventory()
    for i,v in next, items do 
        if v.item:find("pistol") then 
            return v
        end
    end
end


local function killall() 
    for i,v in next, getHiders() do
        pcall(function()
            local args = {
                lplr.Character.HumanoidRootPart.Position,
                CFrame.lookAt(lplr.Character.HumanoidRootPart.CFrame.p, v.Character.HumanoidRootPart.CFrame.p).lookVector * (v.Character.HumanoidRootPart.CFrame.p - lplr.Character.HumanoidRootPart.CFrame.p).magnitude,
                {
                    ["instance"] = v.Character.HumanoidRootPart,
                    ["normal"] = Vector3.new(1, 0, 0),
                    ["position"] = v.Character.HumanoidRootPart.Position
                },
                math.random(),
                false
            }
            if vischeck(v.Character, "HumanoidRootPart") then
                game:GetService("ReplicatedStorage")["events-shared/networking@NetEvents"].shoot:FireServer(unpack(args))  
            end
        end)    
    end
end

do 
    local Sprint = {["Enabled"] = false}; Sprint = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Sprint",
        ["Function"] = function(callback) 
            if callback then 
                dependencies.SprintControllerF:toggleSprint({sprinting = false})
                CAS:UnbindAction("sprint")
            else
                CAS:BindAction("sprint", function(_, inputstate, _)
                    if inputstate == Enum.UserInputState.Begin then
                        dependencies.SprintControllerF:startSprinting()
                        return
                    end
                    if inputstate == Enum.UserInputState.End then
                        dependencies.SprintControllerF:stopSprinting()
                    end;
                end, false, Enum.KeyCode.LeftShift);
            end
        end
    })
end

do 
    local aura = {["Enabled"] = false}
    local auraswing = {["Enabled"] = false}
    local auraswingsound = {["Enabled"] = false}    
    local soundtick = tick()
    local auradist = {["Value"] = 14 }
    aura = GuiLibrary["Objects"]["CombatWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Aura",
        ["Function"] = function(callback) 
            spawn(function()
                repeat wait() 
                    for i,v in next, getAllPlrsNear() do 
                        if isAlive() and canBeTargeted(v) and (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude < auradist["Value"] then 
                            local weapon = getSword()
                            if weapon ~= nil then
                                GuiLibrary["Debug"]("Attacking "..v.Name.." with magnitude of "..tostring((lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude))
                                dependencies.ClientHandler.NetFunctions.client.swordHit:invoke(weapon.item, v.Character, {isRaycast = true}, 0)
                                if auraswingsound["Enabled"] then 
                                    if soundtick < tick()+0.1 then
                                        playsound("rbxassetid://6760544639")
                                        soundtick = tick()
                                    end
                                end
                            end
                        end
                    end
                until aura["Enabled"] == false
            end)
        end,
    })
    auraswingsound = aura.CreateToggle({
        ["Name"] = "SwingSound",
        ["Function"] = function() end,
    })
    auradist = aura.CreateSlider({
        ["Name"] = "Range",
        ["Function"] = function() end,
        ["Min"] = 1,
        ["Max"] = 14,
        ["Default"] = 14
    })

end

do 
    local old = dependencies.VelocityUtil.applyVelocity
    local Velocity = {["Enabled"] = false}; Velocity = GuiLibrary["Objects"]["CombatWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Velocity",
        ["Function"] = function(callback) 
            if callback then
                dependencies.VelocityUtil.applyVelocity = function(...) end
            else
                dependencies.VelocityUtil.applyVelocity = old
            end 
        end
    })
end



do 
    local PropKill = {["Enabled"] = false}; PropKill = GuiLibrary["Objects"]["CombatWindow"]["API"].CreateOptionsButton({
        ["Name"] = "GunAura",
        ["Function"] = function(callback) 
            if callback then
                spawn(function()
                    repeat task.wait(0.05) 
                    killall()
                    until PropKill["Enabled"] == false
                end)
            end
        end
    })
end
--[[
do
    local AutoAdvertise = {["Enabled"] = false}
    local PropKill = {["Enabled"] = false}; PropKill = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AutoWin",
        ["Function"] = function(callback) 
            spawn(function()
                repeat task.wait(0.1)
                    if PropKill["Enabled"] == false then break end 

                    if isAlive() and lplr.Team ~= nil and state() ~= 0 then
                        if lplr.Team.Name == "Hider" then
                            requestSelfDamage(math.huge)
                            return
                        end

                        if state() == 2 or lplr.Team.Name == "Seeker" then 
                             game:GetService("ReplicatedStorage")["events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"].joinQueue:FireServer({["queueType"] = "vanilla"})
                            break
                        end

                    end
                until PropKill["Enabled"] == false
            end)
        end
    })
end]]

--[[
do
    local timeStart = nil
    local AutoAdvertise = {["Enabled"] = false}
    local PropKill = {["Enabled"] = false}; PropKill = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AutoWin",
        ["Function"] = function(callback) 
            timeStart = timeStart or WORKSPACE:GetServerTimeNow()
            spawn(function()
                repeat task.wait()
                    if PropKill["Enabled"] == false then break end 
                    if isAlive() and lplr.Team ~= nil then
                        if getPistol() then 
                            killnear()
                            task.wait(0.05)
                            if (state() == 2) then 
                                if (AutoAdvertise["Enabled"]) then
                                    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("Future AutoWin is simply the best, search engoalt.github.io today!","All")
                                end
                                game:GetService("ReplicatedStorage")["events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"].joinQueue:FireServer({["queueType"] = "vanilla"})
                                GuiLibrary["CreateNotification"]("AutoWin completed in ".. tostring(WORKSPACE:GetServerTimeNow() - timeStart) .. "s")
                                break
                            end
                        elseif lplr.Team ~= nil then
                            requestSelfDamage(math.huge)
                        end
                    end
                until PropKill["Enabled"] == false
            end)
        end
    })
end]]

do 
    local AutoSwapProp = {["Enabled"] = false}; AutoSwapProp = GuiLibrary["Objects"]["WorldWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AutoProp",
        ["Function"] = function(callback) 
            if callback and lplr.Team ~= nil then 
                spawn(function()
                    repeat task.wait() 
                            for i,v in pairs(WORKSPACE.Map.Props:children()) do --//credits to my friend liam lol
                                if isAlive() then
                                    task.wait(1)
                                    local oldhrp = lplr.Character.HumanoidRootPart.CFrame
                                    local old = cam.CFrame
                                    game:GetService("ReplicatedStorage")["events-shared/networking@NetEvents"].disguiseProp:FireServer(v.Name, v)
                                    cam.CFrame = old
                                    lplr.Character.HumanoidRootPart.CFrame = oldhrp
                                    if AutoSwapProp["Enabled"] == false then break end
                                end
                            end
                    until AutoSwapProp["Enabled"] == false
                end)
            end
        end
    })
end

do 
    local God = {["Enabled"] = false}; God = GuiLibrary["Objects"]["MiscellaneousWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Godmode",
        ["Function"] = function(callback) 
            spawn(function()
                if callback then
                    repeat task.wait(0.5) 
                        requestSelfDamage(-10000)
                    until not God.Enabled
                end
            end)
        end
    })
end

do 
    local GunMod = {["Enabled"] = false}; GunMod = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "GunMod",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function()
                    repeat task.wait(0.5) 
                        if not GunMod.Enabled then break end
                        dependencies.GunControllerF.ammo = math.huge
                        dependencies.ItemMeta.pistol.gun.fireRate = 0
                        dependencies.ItemMeta.pistol.gun.aimcone.bulletSpread = 0
                    until not GunMod["Enabled"]
                end)
            else
                dependencies.GunControllerF.ammo = math.huge
                dependencies.ItemMeta.pistol.gun.fireRate = 0.14
                dependencies.ItemMeta.pistol.gun.aimcone.bulletSpread = 0.015
            end          
        end
    })
end

do 
    local Invis = {["Enabled"] = false}
    Invis = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Invis",
        ["Function"] = function(callback) 
            if callback then 
                game:GetService("ReplicatedStorage"):FindFirstChild("events-shared/networking@NetEvents").setLocked:FireServer(true)
                for i,v in next, game.Players.LocalPlayer.Character:GetChildren() do
                    if v:IsA("MeshPart") then
                        v:destroy()
                    end
                end
            end
        end
    })
end


do 
    local AutoLeave = {["Enabled"] = false}; AutoLeave = GuiLibrary["Objects"]["MiscellaneousWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AutoRequeue",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function() 
                    repeat task.wait() until state() == 2
                    if AutoLeave.Enabled then 
                        game:GetService("ReplicatedStorage")["events-@easy-games/lobby:shared/event/lobby-events@getEvents.Events"].joinQueue:FireServer({["queueType"] = "vanilla"})
                    end
                end)
            end
        end
    })
end

do 
    local CoinGrab = {["Enabled"] = false}; CoinGrab = GuiLibrary["Objects"]["WorldWindow"]["API"].CreateOptionsButton({
        ["Name"] = "CoinGrab",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function() 
                    repeat task.wait(0.25)
                        for i,v in next, WORKSPACE.GroundItems:GetChildren() do 
                            if isnetworkowner(v) and isAlive() and isHider() then 
                                v.CFrame = lplr.Character.HumanoidRootPart.CFrame
                            end
                        end
                    until CoinGrab["Enabled"] == false
                end)
            end
        end,
    })
end

do
    local cached
    local FastCrate = {["Enabled"] = false}; FastCrate = GuiLibrary["Objects"]["WorldWindow"]["API"].CreateOptionsButton({
        ["Name"] = "FastCrate",
        ["Function"] = function(callback) 
            for i,v in next, WORKSPACE:WaitForChild("Map"):WaitForChild("Configuration"):WaitForChild("Crates"):GetChildren() do 
                local proxPrompt = v:WaitForChild("PromptLocation").OpenCrate
                cached = cached or proxPrompt.HoldDuration
                proxPrompt.HoldDuration = callback and 0 or cached
            end
        end,
    })
end

do 
    local Lagger = {["Enabled"] = false}; Lagger = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "FPSLagger",
        ["Function"] = function(callback) 
            if callback then
                spawn(function() 
                    repeat task.wait(0.05)
                        spawn(function() 
                            repeat task.wait()
                                requestSelfDamage(0)
                            until Lagger["Enabled"] == false
                        end)
                    until Lagger["Enabled"] == false
                end)
            end
        end,
    })
end

do 
    local old, old2, old3 = dependencies.HighlightController.highlight, dependencies.DamageIndicatorController.spawnDamageIndicator, dependencies.WorldIndicatorController.addIndicator
    local Lagger = {["Enabled"] = false}; Lagger = GuiLibrary["Objects"]["MiscellaneousWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AntiFPSLag",
        ["Function"] = function(callback) 
            if callback then 
                dependencies.HighlightController.highlight = function(...) end
                dependencies.WorldIndicatorController.addIndicator = function(...) end
                dependencies.DamageIndicatorController.spawnDamageIndicator = function(...) end
            else
                dependencies.HighlightController.highlight = old
                dependencies.WorldIndicatorController.addIndicator = old2
                dependencies.DamageIndicatorController.spawnDamageIndicator = old3
            end
        end,
    })
end
