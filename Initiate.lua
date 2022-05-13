-- // credits to anyones code i used/looked at.
getgenv()._FUTUREVERSION = "1.1.1c | "..(shared.FutureDeveloper and "dev" or shared.FutureTester and  "test" or "release").." build" -- // This is a cool thing yes
getgenv()._FUTUREMOTD = "futureclient.xyz 🔥"
print("[Future] Loading!")
repeat wait() until game:IsLoaded()
if shared.Future~=nil then print("[Future] Detected future already executed, not executing!") return end
getgenv().futureStartTime = game:GetService("Workspace"):GetServerTimeNow()
local startTime = game:GetService("Workspace"):GetServerTimeNow()
shared.Future = {}
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local HTTPSERVICE = game:GetService("HttpService")
local PLAYERS = game:GetService("Players")
local lplr = PLAYERS.LocalPlayer
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport

local function requesturl(url, bypass) 
    if isfile(url) then 
        return readfile(url)
    end
    local repourl = bypass and "https://raw.githubusercontent.com/KholsAdminHouse/" or "https://raw.githubusercontent.com/KholsAdminHouse/FutureBeta/main/"
    local url = url:gsub("FutureBeta/", "")
    local req = requestfunc({
        Url = repourl..url,
        Method = "GET"
    })
    if req.StatusCode ~= 200 then return req.StatusCode end
    return req.Body
end 

local GuiLibrary = loadstring(requesturl("FutureBeta/GuiLibrary.lua"))()
shared.Future.GuiLibrary = GuiLibrary
local getcustomasset = --[[getsynasset or getcustomasset or]] GuiLibrary["getRobloxAsset"]
GuiLibrary["LoadOnlyGuiConfig"]()


local HeartbeatTable = {}
local RenderStepTable = {}
local SteppedTable = {}
local function isAlive(plr)
    local plr = plr or lplr
    if plr and plr.Character and ((plr.Character:FindFirstChild("Humanoid")) and (plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0) and (plr.Character:FindFirstChild("HumanoidRootPart"))) then
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

local function skipFrame() 
    return game:GetService("RunService").Heartbeat:Wait()
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
    GuiLibrary["CreateNotification"]("<font color='rgb(170, 170, 170)'>"..str.."</font>")
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

local function getscript(id) 
    local id = id or shared.FuturePlaceId or game.PlaceId
    id = tostring(id)
    local req = requesturl("FutureBeta/scripts/"..id..".lua")
    if type(req) == "string" then
        return loadstring(req)()
    else
        --fwarn("[Future] invalid script (error "..tostring(req)..")") -- game is not supported
    end
end

local function getplusscript(id) -- future plus moment
    local id = id or shared.FuturePlaceId or game.PlaceId
    id = tostring(id)
    local req = requesturl("Future/plus/"..id..".fp")
    if type(req) == "string" then
        return loadstring(req)()
    else
        --fwarn("[Future] invalid script (error "..tostring(req)..")") -- game is not supported
    end
end

GuiLibrary["LoadOnlyGuiConfig"]()

local CombatWindow = GuiLibrary.CreateWindow({["Name"] = "Combat"})
local ExploitsWindow = GuiLibrary.CreateWindow({["Name"] = "Exploits"})
local MiscellaneousWindow = GuiLibrary.CreateWindow({["Name"] = "Miscellaneous"})
local MovementWindow = GuiLibrary.CreateWindow({["Name"] = "Movement"})
local RenderWindow = GuiLibrary.CreateWindow({["Name"] = "Render"})
local WorldWindow = GuiLibrary.CreateWindow({["Name"] = "World"})
local OtherWindow = GuiLibrary.CreateWindow({["Name"] = "Other"})

local configButton; configButton = OtherWindow.CreateOptionsButton({
    ["Name"] = "Config",
    ["Function"] = function(callback)
    end,
    ["NoKeybind"] = true,
})
local configBox; configBox = configButton.CreateTextbox({
    ["Name"] = "ConfigName",
    ["Function"] = function(value)
        spawn(function()
            GuiLibrary["SaveConfig"](GuiLibrary["CurrentConfig"])
            if isfile("Future/configs/"..tostring((shared.Future and shared.Future.PlaceId) or game.PlaceId).."/"..value..".json") then
                GuiLibrary["LoadConfig"](value)
            end
            GuiLibrary["CurrentConfig"] = value
        end)
    end,
    ["Default"] = "default"
})
local clickGuiButton = OtherWindow.CreateOptionsButton({
    ["Name"] = "ClickGui",
    ["Function"] = function(callback) 
        GuiLibrary.ClickGUI.Visible = callback
    end,
    ["DefaultKeybind"] = GuiLibrary.GuiKeybind,
    ["OnKeybound"] = function(key) 
        if key then GuiLibrary.GuiKeybind = key end
    end
})
local clickSoundToggle = clickGuiButton.CreateToggle({
    ["Name"] = "ClickSounds",
    ["Function"] = function(callback)
        GuiLibrary["ClickSounds"] = callback
    end,
    ["Default"] = true
})

local HUDButton = OtherWindow.CreateOptionsButton({
    ["Name"] = "HUD",
    ["Function"] = function(callback) 
        GuiLibrary["HUDEnabled"] = callback
    end,
    ["Default"] = true
})
local NotificationsToggle = HUDButton.CreateToggle({
    ["Name"] = "Notifications",
    ["Function"] = function(callback) 
        GuiLibrary["AllowNotifications"] = callback
    end,
    ["Default"] = true
})
local TargetHUDToggle = HUDButton.CreateToggle({
    ["Name"] = "TargetHUD",
    ["Function"] = function(callback) 
        GuiLibrary["TargetHUDEnabled"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local ArrayListToggle = HUDButton.CreateToggle({
    ["Name"] = "ArrayList",
    ["Function"] = function(callback) 
        GuiLibrary["ScreenGui"].ArrayList.Visible = callback
        GuiLibrary["ArrayList"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local ArrayList2Toggle = HUDButton.CreateToggle({
    ["Name"] = "ListBackground",
    ["Function"] = function(callback) 
        GuiLibrary["ListBackground"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local ArrayList3Toggle = HUDButton.CreateToggle({
    ["Name"] = "ListLines",
    ["Function"] = function(callback) 
        GuiLibrary["ListLines"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local WatermarkToggle = HUDButton.CreateToggle({
    ["Name"] = "Watermark",
    ["Function"] = function(callback) 
        GuiLibrary["DrawWatermark"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local WatermarkToggle2 = HUDButton.CreateToggle({
    ["Name"] = "WMBackground",
    ["Function"] = function(callback) 
        GuiLibrary["WatermarkBackground"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local WatermarkToggle3 = HUDButton.CreateToggle({
    ["Name"] = "WMLine",
    ["Function"] = function(callback) 
        GuiLibrary["WatermarkLine"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local RenderingToggle = HUDButton.CreateSelector({
    ["Name"] = "Rendering",
    ["Function"] = function(value) 
        GuiLibrary["Rendering"] = value
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = "Up",
    ["List"] = {"Up", "Down"}
})
local CoordsToggle = HUDButton.CreateToggle({
    ["Name"] = "Coords",
    ["Function"] = function(callback) 
        GuiLibrary["DrawCoords"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local SpeedToggle = HUDButton.CreateToggle({
    ["Name"] = "Speed",
    ["Function"] = function(callback) 
        GuiLibrary["DrawSpeed"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local FPSToggle = HUDButton.CreateToggle({
    ["Name"] = "FPS",
    ["Function"] = function(callback) 
        GuiLibrary["DrawFPS"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})
local PingToggle = HUDButton.CreateToggle({
    ["Name"] = "Ping",
    ["Function"] = function(callback) 
        GuiLibrary["DrawPing"] = callback
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
    end,
    ["Default"] = false
})

local colorButton; colorButton = OtherWindow.CreateOptionsButton({
    ["Name"] = "Colors",
    ["Function"] = function(callback) 
        if not callback then 
            colorButton.Toggle(true, true)
        end
    end,
    ["Default"] = true,
    ["NoKeybind"] = true,
})
local hueSlider = colorButton.CreateSlider({
    ["Name"] = "Hue",
    ["Function"] = function(value) 
        if not GuiLibrary["Rainbow"] then
            local value = value * 0.002777777777777 -- 360 * 0.002777777777777 = 1.000
            GuiLibrary["ColorTheme"].H = value
            GuiLibrary["Signals"]["UpdateColor"]:Fire(GuiLibrary["ColorTheme"])
        end
    end,
    ["Min"] = 0,
    ["Max"] = 360,
})
local saturationSlider = colorButton.CreateSlider({
    ["Name"] = "Saturation",
    ["Function"] = function(value) 
        GuiLibrary["ColorTheme"].S = value / 100
        GuiLibrary["Signals"]["UpdateColor"]:Fire(GuiLibrary["ColorTheme"])
    end,
    ["Min"] = 0,
    ["Max"] = 100,
})
local valueSlider = colorButton.CreateSlider({
    ["Name"] = "Lightness",
    ["Function"] = function(value) 
        GuiLibrary["ColorTheme"].V = value / 100
        GuiLibrary["Signals"]["UpdateColor"]:Fire(GuiLibrary["ColorTheme"])
    end,
    ["Min"] = 0,
    ["Max"] = 100,
})
local rainbowToggle = colorButton.CreateToggle({
    ["Name"] = "Rainbow",
    ["Function"] = function(callback) 
        GuiLibrary["Rainbow"] = callback
    end,
})
local rainbowSlider = colorButton.CreateSlider({
    ["Name"] = "RBSpeed",
    ["Function"] = function(value) 
        GuiLibrary["RainbowSpeed"] = value
    end,
    ["Min"] = 1,
    ["Max"] = 50,
    ["Default"] = 10,
})

local discordButton = {["Toggle"] = function(...) end} discordButton = OtherWindow.CreateOptionsButton({
    ["Name"] = "Discord",
    ["Function"] = function(callback)
        if callback then
            pcall(function() setclipboard("https://discord.com/invite/bdjT5UmmDJ") end)
            spawn(function()
				for i = 1, 14 do
					spawn(function()
						local reqbody = {
							["nonce"] = game:GetService("HttpService"):GenerateGUID(false), -- What, there is a nonce in my script?
							["args"] = {
								["invite"] = {["code"] = "bdjT5UmmDJ"},
								["code"] = "bdjT5UmmDJ",
							},
							["cmd"] = "INVITE_BROWSER"
						}
						local newreq = game:GetService("HttpService"):JSONEncode(reqbody)
						requestfunc({
							Headers = {
								["Content-Type"] = "application/json",
								["Origin"] = "https://discord.com"
							},
							Url = "http://127.0.0.1:64"..(53 + i).."/rpc?v=1",
							Method = "POST",
							Body = newreq
						})
					end)
				end
			end)
            discordButton["Toggle"](false, true) 
        end
    end
})

local destructButton; destructButton = OtherWindow.CreateOptionsButton({
    ["Name"] = "Destruct",
    ["Function"] = function(callback)
        if callback then
            spawn(function()
                GuiLibrary["SaveConfig"](GuiLibrary["CurrentConfig"])
                GuiLibrary.Signals.onDestroy:Fire()
            end)
        end
    end
})

local restartButton; restartButton = OtherWindow.CreateOptionsButton({
    ["Name"] = "Restart",
    ["Function"] = function(callback) 
        if callback then 
            spawn(function() 
                restartButton.Toggle(nil, true, true)
                GuiLibrary["SaveConfig"](GuiLibrary["CurrentConfig"])
                GuiLibrary.Signals.onDestroy:Fire()
                task.wait(0.5)
                if shared.FutureDeveloper then 
                    loadfile("Future/Initiate.lua")()
                else
                    loadstring(game:HttpGet('https://raw.githubusercontent.com/KholsAdminHouse/FutureBeta/main/loadstring.lua', true))()
                end
            end)
        end
    end
})

GuiLibrary["LoadOnlyGuiConfig"]()

-- Calculate Speed, FPS and Coords
local Coords, Speed, FPS = Vector3.new(), 0, 0
local Tick = tick()
local CurrentCharacterPositionConnection
spawn(function()
    local lastPos = Vector3.new()
    repeat task.wait(1)

        if isAlive() then 
            lastPos = lastPos or lplr.Character.PrimaryPart.Position
            local distance = (lastPos - lplr.Character.PrimaryPart.Position).Magnitude
            local meters = distance / (25 / 7) --//there is 25 / 7 studs in a meter
            Speed = meters * 3.6
            lastPos = lplr.Character.PrimaryPart.Position
        else
            Speed = 0
        end

    until shared.Future == nil
end)

BindToRenderStep("stats", function(dt) 
    if Tick <= tick() then
        FPS = math.round(1/dt)
        if isAlive() then 
            Coords = lplr.Character.PrimaryPart.Position
        end
        local ping = tonumber(game:GetService("Stats"):FindFirstChild("PerformanceStats").Ping:GetValue())
        GuiLibrary["Signals"]["statsUpdate"]:Fire(Coords, math.round(Speed*100)/100, FPS, ping)
        Tick = tick() + 0.2
    end
end)

local ontp = game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
		local stringtp = [[
        repeat wait() until game:IsLoaded()
        if isfile("Future/Initiate.lua") then 
            loadfile("Future/Initiate.lua")() 
        else 
            loadstring(game:HttpGet("https://raw.githubusercontent.com/KholsAdminHouse/FutureBeta/main/Initiate.lua", true))() 
        end
        ]]
		queueteleport(stringtp)
        GuiLibrary["Signals"]["onDestroy"]:Fire()
    end
end)

local bedwarsidtable = {
    6872274481,
    8444591321,
    8560631822
}
if table.find(bedwarsidtable, game.PlaceId) then 
    shared.FuturePlaceId = 6872274481
end
local minerscaveidtable = {
    7910558502,
    6604417568,
}
if table.find(minerscaveidtable, game.PlaceId) then 
    shared.FuturePlaceId = 6604417568
end

local success, _error = pcall(getscript, "Universal")
local success2, _error2 = pcall(getscript)
getplusscript()
if success then 
    print("[Future] Successfully retrieved Universal script!")
else
    fwarn("Unsuccessful attempt at retrieving Universal script!\n report this in the discord.\n (".._error..")")
end
if success2 then 
    print("[Future] Successfully retrieved Game script!")
else
    fwarn("Unsuccessful attempt at retrieving Game script!\n report this in the discord.\n (".._error2..")")
end
--[[
if success3 then 
    print("[Future] Successfully retrieved FuturePlus Game script!")
else
    fwarn("Unsuccessful attempt at retrieving FuturePlus Game script!\n report this in the discord.\n (".._error3..")")
end]]
GuiLibrary["LoadConfig"](GuiLibrary["CurrentConfig"])


local leaving = PLAYERS.PlayerRemoving:connect(function(player)
    if player == lplr then
        GuiLibrary["SaveConfig"](GuiLibrary["CurrentConfig"])
    end
end)

GuiLibrary.Signals.onDestroy:connect(function()
    UnbindFromRenderStep("stats")
    for i,v in next, GuiLibrary.Objects do 
        if v.Type == "OptionsButton" and i ~= "DestructOptionsButton" and v.API.Enabled then 
            v.API.Toggle(false, true)
        end
    end
    if ontp then ontp:Disconnect() end
    if leaving then leaving:Disconnect() end
    shared.Future = nil
end)

spawn(function()
    if GuiLibrary["AllowNotifications"] then
        local textlabel = Instance.new("TextLabel")
        textlabel.Size = UDim2.new(1, 0, 0, 36)
        textlabel.RichText = true
        textlabel.Text = [[<stroke thickness="2">Please join the Future discord server for updates and to leave feedback. discord.gg/bdjT5UmmDJ</stroke>]]
        textlabel.BackgroundTransparency = 1
        textlabel.TextStrokeTransparency = 0
        textlabel.TextSize = 25
        textlabel.Font = Enum.Font.SourceSans
        textlabel.TextColor3 = Color3.new(1, 1, 1)
        textlabel.Position = UDim2.new(0, 0, 0, -40)
        textlabel.Parent = GuiLibrary["ScreenGui"]
        local textlabel2 = Instance.new("TextLabel")
        textlabel2.Size = UDim2.new(1, 0, 0, 36)
        textlabel2.RichText = true
        textlabel2.Text = [[<stroke thickness="2">Always use alts when exploiting.</stroke>]]
        textlabel2.BackgroundTransparency = 1
        textlabel2.TextStrokeTransparency = 0
        textlabel2.TextSize = 25
        textlabel2.Font = Enum.Font.SourceSans
        textlabel2.TextColor3 = Color3.new(1, 1, 1)
        textlabel2.Position = UDim2.new(0, 0, 0, -20)
        textlabel2.Parent = GuiLibrary["ScreenGui"]
        task.wait(7.5)
        textlabel:Destroy()
        textlabel2:Destroy()
    end
end)

spawn(function()
    repeat
        if not shared.Future then 
            break
        end
        GuiLibrary["SaveConfig"](GuiLibrary["CurrentConfig"], true)
        for i = 1, 100 do 
            task.wait(0.02)
            if not shared.Future then 
                break
            end
        end
    until not shared.Future
end)
fprint("Finished loading in "..tostring(math.floor((game:GetService("Workspace"):GetServerTimeNow() - startTime) * 1000) / 1000).."s\nPress "..GuiLibrary["GuiKeybind"].." to open the Gui.\nPlease join the discord for changelogs and to report bugs. \ndiscord.gg/bdjT5UmmDJ\nEnjoy using Future v".._FUTUREVERSION.."")
shared._FUTURECACHED = true
