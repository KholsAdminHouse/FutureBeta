repeat task.wait() until game:IsLoaded()
local GuiLibrary = shared.Future.GuiLibrary
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local WORKSPACE = game:GetService("Workspace")
local PLAYERS = game:GetService("Players")
local HTTPSERVICE = game:GetService("HttpService")
local lplr = PLAYERS.LocalPlayer
local mouse = lplr:GetMouse()
local cam = WORKSPACE.CurrentCamera
local getcustomasset = --[[getsynasset or getcustomasset or]] GuiLibrary["getRobloxAsset"]
local requestfunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or getgenv().request or request
local queueteleport = syn and syn.queue_on_teleport or queue_on_teleport or fluxus and fluxus.queue_on_teleport
local bedwars = {} 
local Reach = {["Enabled"] = false}
local speedsettings = {
    factor = 5.37,  
    velocitydivfactor = 2.9,
    wsvalue = 22.5
}

local function requesturl(url, bypass) 
    if isfile(url) and shared.FutureDeveloper then 
        return readfile(url)
    end
    local repourl = bypass and "https://raw.githubusercontent.com/joeengo/" or "https://raw.githubusercontent.com/joeengo/Future/main/"
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
			Url = "https://raw.githubusercontent.com/joeengo/Future/main/"..path:gsub("Future/assets", "assets"),
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
    if plr and plr.Character and ((plr.Character:FindFirstChild("Humanoid")) and (plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Humanoid").Health > 0) and (plr.Character:FindFirstChild("HumanoidRootPart")) and (plr.Character:FindFirstChild("Head"))) then
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
    GuiLibrary["CreateNotification"]("<font color='rgb(200, 200, 200)'>"..str.."</font>")
end

local function getColorFromPlayer(v) 
    if v.Team ~= nil then return v.TeamColor.Color end
end

local function getremote(t)
    for i,v in next, t do 
        if v == "Client" then 
            return t[i+1]
        end
    end
end

local function getPlrNear(max)
    local returning, nearestnum = nil,max
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            local diff = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude
            if diff < nearestnum then 
                nearestnum = diff 
                nearestval = v
            end
        end
    end
    return returning
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

local function getAllPlrsNear()
    if not isAlive() then return {} end
    local t = {}
    for i,v in next, PLAYERS:GetPlayers() do 
        if isAlive(v) and v~=lplr then 
            if v.Character.HumanoidRootPart then table.insert(t, (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude, v) end
        end
    end
    return t
end

local function canBeTargeted(plr, doTeamCheck) 
    if isAlive(plr) and plr~=lplr and (doTeamCheck and plr.Team ~=lplr.Team or not doTeamCheck) then 
        return true
    end
    return false
end

local function getMoveDirection(plr) 
    if not isAlive(plr) then return Vector3.new() end
    local velocity = part:GetVelocityAtPosition(part.Position)
    local velocityDirection = velocity.Magnitude > 0 and velocity.Unit or Vector3.new()
    return velocityDirection
end

local function getwool()
	for i5, v5 in pairs(bedwars["getInventory"](lplr)["items"]) do
		if v5["itemType"]:match("wool") or v5["itemType"]:match("grass") then
			return v5["itemType"], v5["amount"]
		end
	end	
	return nil
end

local function getItem(itemName)
	for i5, v5 in pairs(bedwars["getInventory"](lplr)["items"]) do
		if v5["itemType"] == itemName then
			return v5, i5
		end
	end
	return nil
end

local function hashvector(vec)
	return {
		["value"] = vec
	}
end

-- Huge thanks to 7granddad for this code, i dont see a point in writing this all my self when I know exactly what it does, it would just be alot of labour and work lel.

local Flamework = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
repeat task.wait() until Flamework.isInitialized
local KnitClient = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"].knit.src).KnitClient
local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
local InventoryUtil = require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil
local OldClientGet = getmetatable(Client).Get
local OldClientWaitFor = getmetatable(Client).WaitFor
getmetatable(Client).Get = function(Self, remotename)
    if remotename == bedwars["AttackRemote"] then
        local res = OldClientGet(Self, remotename)
        return {
            ["instance"] = res["instance"],
            ["CallServer"] = function(Self, tab)
                if Reach["Enabled"] then
                    local mag = (tab.validate.selfPosition.value - tab.validate.targetPosition.value).magnitude
                    local newres = hashvector(tab.validate.selfPosition.value + (mag > 14.4 and (CFrame.lookAt(tab.validate.selfPosition.value, tab.validate.targetPosition.value).lookVector * 4) or Vector3.new(0, 0, 0)))
                    tab.validate.selfPosition = newres
                end
                return res:CallServer(tab)
            end
        }
    end
    return OldClientGet(Self, remotename)
end

bedwars = {
    ["AnimationUtil"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].util["animation-util"]).AnimationUtil,
    ["AngelUtil"] = require(game:GetService("ReplicatedStorage").TS.games.bedwars.kit.kits.angel["angel-kit"]),
    ["AppController"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]).AppController,
    ["BalloonController"] = KnitClient.Controllers.BalloonController,
    ["BlockController"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
    ["BlockController2"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]).BlockPlacer,
    ["BlockTryController"] = getrenv()._G[game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client.placement["block-placer"]],
    ["BlockEngine"] = require(lplr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine,
    ["BlockEngineClientEvents"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.client["block-engine-client-events"]).BlockEngineClientEvents,
    ["BlockPlacementController"] = KnitClient.Controllers.BlockPlacementController,
    ["BedwarsKits"] = require(game:GetService("ReplicatedStorage").TS.games.bedwars.kit["bedwars-kit-shop"]).BedwarsKitShop,
    ["BlockBreaker"] = KnitClient.Controllers.BlockBreakController.blockBreaker,
    ["BowTable"] = KnitClient.Controllers.ProjectileController,
    ["ChestController"] = KnitClient.Controllers.ChestController,
    ["ClickHold"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.ui.lib.util["click-hold"]).ClickHold,
    ["ClientHandler"] = Client,
    ["ClientHandlerDamageBlock"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out.remotes).BlockEngineRemotes.Client,
    ["ClientStoreHandler"] = require(game.Players.LocalPlayer.PlayerScripts.TS.ui.store).ClientStore,
    ["ClientHandlerSyncEvents"] = require(lplr.PlayerScripts.TS["client-sync-events"]).ClientSyncEvents,
    ["CombatConstant"] = require(game:GetService("ReplicatedStorage").TS.combat["combat-constant"]).CombatConstant,
    ["CombatController"] = KnitClient.Controllers.CombatController,
    ["ConsumeSoulRemote"] = getremote(debug.getconstants(KnitClient.Controllers.GrimReaperController.consumeSoul)),
    ["ConstantManager"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].constant["constant-manager"]).ConstantManager,
    ["CooldownController"] = KnitClient.Controllers.CooldownController,
    ["damageTable"] = KnitClient.Controllers.DamageController,
    ["DaoRemote"] = getremote(debug.getconstants(debug.getprotos(KnitClient.Controllers.KatanaController.onEnable)[4])),
    ["DetonateRavenRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.RavenController).detonateRaven)),
    ["DropItem"] = getmetatable(KnitClient.Controllers.ItemDropController).dropItemInHand,
    ["DropItemRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.ItemDropController).dropItemInHand)),
    ["EatRemote"] = getremote(debug.getconstants(debug.getproto(getmetatable(KnitClient.Controllers.ConsumeController).onEnable, 1))),
    ["EquipItemRemote"] = getremote(debug.getconstants(debug.getprotos(shared.oldequipitem or require(game:GetService("ReplicatedStorage").TS.entity.entities["inventory-entity"]).InventoryEntity.equipItem)[3])),
    ["FishermanTable"] = KnitClient.Controllers.FishermanController,
    ["GameAnimationUtil"] = require(game:GetService("ReplicatedStorage").TS.animation["animation-util"]).GameAnimationUtil,
    ["GamePlayerUtil"] = require(game:GetService("ReplicatedStorage").TS.player["player-util"]).GamePlayerUtil,
    ["getEntityTable"] = require(game:GetService("ReplicatedStorage").TS.entity["entity-util"]).EntityUtil,
    ["getIcon"] = function(item, showinv)
        local itemmeta = bedwars["getItemMetadata"](item["itemType"])
        if itemmeta and showinv then
            return itemmeta.image
        end
        return ""
    end,
    ["getInventory"] = function(plr)
        local plr = plr or lplr
        local suc, result = pcall(function() return InventoryUtil.getInventory(plr) end)
        return (suc and result or {
            ["items"] = {},
            ["armor"] = {},
            ["hand"] = nil
        })
    end,
    ["getItemMetadata"] = require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta,
    ["GrimReaperController"] = KnitClient.Controllers.GrimReaperController,
    ["GuitarHealRemote"] = getremote(debug.getconstants(KnitClient.Controllers.GuitarController.performHeal)),
    ["HighlightController"] = KnitClient.Controllers.EntityHighlightController,
    ["ItemTable"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta, 1),
    ["JuggernautRemote"] = getremote(debug.getconstants(debug.getprotos(debug.getprotos(KnitClient.Controllers.JuggernautController.KnitStart)[1])[4])),
    ["KatanaController"] = KnitClient.Controllers.KatanaController,
    ["KatanaRemote"] = getremote(debug.getconstants(debug.getproto(KnitClient.Controllers.KatanaController.onEnable, 4))),
    ["KnockbackTable"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil.calculateKnockbackVelocity, 1),
    ["KnockbackTable2"] = require(game:GetService("ReplicatedStorage").TS.damage["knockback-util"]).KnockbackUtil,
    ["LobbyClientEvents"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"].lobby.out.client.events).LobbyClientEvents,
    ["MissileController"] = KnitClient.Controllers.GuidedProjectileController,
    ["MinerRemote"] = getremote(debug.getconstants(debug.getprotos(debug.getproto(getmetatable(KnitClient.Controllers.MinerController).onKitEnabled, 1))[2])),
    ["MinerController"] = KnitClient.Controllers.MinerController,
    ["PickupRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.ItemDropController).checkForPickup)),
    ["PlayerUtil"] = require(game:GetService("ReplicatedStorage").TS.player["player-util"]).GamePlayerUtil,
    ["ProjectileMeta"] = require(game:GetService("ReplicatedStorage").TS.projectile["projectile-meta"]).ProjectileMeta,
    ["QueueMeta"] = require(game:GetService("ReplicatedStorage").TS.game["queue-meta"]).QueueMeta,
    ["QueryUtil"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).GameQueryUtil,
    ["prepareHashing"] = require(game:GetService("ReplicatedStorage").TS["remote-hash"]["remote-hash-util"]).RemoteHashUtil.prepareHashVector3,
    ["ProjectileRemote"] = getremote(debug.getconstants(debug.getupvalues(getmetatable(KnitClient.Controllers.ProjectileController)["launchProjectileWithValues"])[2])),
    ["RavenTable"] = KnitClient.Controllers.RavenController,
    ["RespawnController"] = KnitClient.Controllers.BedwarsRespawnController,
    ["RespawnTimer"] = require(lplr.PlayerScripts.TS.controllers.games.bedwars.respawn.ui["respawn-timer"]).RespawnTimerWrapper,
    ["ResetRemote"] = getremote(debug.getconstants(debug.getproto(KnitClient.Controllers.ResetController.createBindable, 1))),
    ["Roact"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["roact"].src),
    ["RuntimeLib"] = require(game:GetService("ReplicatedStorage")["rbxts_include"].RuntimeLib),
    ["Shop"] = require(game:GetService("ReplicatedStorage").TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop,
    ["ShopItems"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.games.bedwars.shop["bedwars-shop"]).BedwarsShop.getShopItem, 2),
    ["ShopRight"] = require(lplr.PlayerScripts.TS.controllers.games.bedwars.shop.ui["item-shop"]["shop-left"]["shop-left"]).BedwarsItemShopLeft,
    ["SpawnRavenRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.RavenController).spawnRaven)),
    ["SoundManager"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).SoundManager,
    ["SoundList"] = require(game:GetService("ReplicatedStorage").TS.sound["game-sound"]).GameSound,
    ["sprintTable"] = KnitClient.Controllers.SprintController,
    ["StopwatchController"] = KnitClient.Controllers.StopwatchController,
    ["SwingSword"] = getmetatable(KnitClient.Controllers.SwordController).swingSwordAtMouse,
    ["SwingSwordRegion"] = getmetatable(KnitClient.Controllers.SwordController).swingSwordInRegion,
    ["SwordController"] = KnitClient.Controllers.SwordController,
    ["TreeRemote"] = getremote(debug.getconstants(debug.getprotos(debug.getprotos(KnitClient.Controllers.BigmanController.KnitStart)[2])[1])),
    ["TrinityRemote"] = getremote(debug.getconstants(debug.getproto(getmetatable(KnitClient.Controllers.AngelController).onKitEnabled, 1))),
    ["VictoryScreen"] = require(lplr.PlayerScripts.TS.controllers["game"].match.ui["victory-section"]).VictorySection,
    ["ViewmodelController"] = KnitClient.Controllers.ViewmodelController,
    ["WeldTable"] = require(game:GetService("ReplicatedStorage").TS.util["weld-util"]).WeldUtil,
    ["AttackRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.SwordController)["attackEntity"])),
    ["VelocityUtil"]  = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out["shared"].util["velocity-util"]).VelocityUtil, 
}

local function getblock(pos)
	return bedwars["BlockController"]:getStore():getBlockAt(bedwars["BlockController"]:getBlockPosition(pos)), bedwars["BlockController"]:getBlockPosition(pos)
end

for i,v in pairs(debug.getupvalues(getmetatable(KnitClient.Controllers.SwordController)["attackEntity"])) do
    if tostring(v) == "AC" then
        bedwars["AttackHashTable"] = v
        for i2,v2 in pairs(v) do
            if i2:find("constructor") == nil and i2:find("__index") == nil and i2:find("new") == nil then
                bedwars["AttackHashFunction"] = v2
                bedwars["AttachHashText"] = i2
            end
        end
    end
end
local blocktable = bedwars["BlockController2"].new(bedwars["BlockEngine"], getwool())
bedwars["placeBlock"] = function(newpos, customblock)
    local placeblocktype = (customblock or getwool())
    blocktable.blockType = placeblocktype
    if bedwars["BlockController"]:isAllowedPlacement(lplr, placeblocktype, Vector3.new(newpos.X/3, newpos.Y/3, newpos.Z/3)) and getItem(placeblocktype) then
        return blocktable:placeBlock(Vector3.new(newpos.X/3, newpos.Y/3, newpos.Z/3))
    end
end

local function getItem(itemName)
	for i5, v5 in pairs(bedwars["getInventory"](lplr)["items"]) do
		if v5["itemType"] == itemName then
			return v5, i5
		end
	end
	return nil
end

local function getHotbarSlot(itemName)
	for i5, v5 in pairs(bedwars["ClientStoreHandler"]:getState().Inventory.observedInventory.hotbar) do
		if v5["item"] and v5["item"]["itemType"] == itemName then
			return i5 - 1
		end
	end
	return nil
end

local function switchItem(tool, legit)
	if legit then
		bedwars["ClientStoreHandler"]:dispatch({
			type = "InventorySelectHotbarSlot", 
			slot = getHotbarSlot(tool.Name)
		})
	end
	pcall(function()
		lplr.Character.HandInvItem.Value = tool
	end)
	bedwars["ClientHandler"]:Get(bedwars["EquipItemRemote"]):CallServerAsync({
		hand = tool
	})
end

local function getBestTool(block)
    local tool = nil
	local toolnum = 0
	local blockmeta = bedwars["getItemMetadata"](block)
	local blockType = ""
	if blockmeta["block"] and blockmeta["block"]["breakType"] then
		blockType = blockmeta["block"]["breakType"]
	end
	for i,v in pairs(bedwars["getInventory"](lplr)["items"]) do
		local meta = bedwars["getItemMetadata"](v["itemType"])
		if meta["breakBlock"] and meta["breakBlock"][blockType] then
			tool = v
			break
		end
	end
    return tool
end

local function switchToAndUseTool(block, legit)
	local tool = getBestTool(block.Name)
	if tool and (isAlive() and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value ~= tool["tool"]) then
		if legit then
			if getHotbarSlot(tool["itemType"]) then
				bedwars["ClientStoreHandler"]:dispatch({
					type = "InventorySelectHotbarSlot", 
					slot = getHotbarSlot(tool["itemType"])
				})
				task.wait(0.1)
				updateitem:Fire(inputobj)
				return true
			else
				return false
			end
		end
		switchItem(tool["tool"])
		task.wait(0.1)
	end
end

local function getBeds() 
    local t = {}
    for i,v in next, WORKSPACE:WaitForChild("Map"):WaitForChild("Blocks"):GetChildren() do 
        if v.Name == "bed" then
            t[#t+1] = v
        end
    end
    return t
end

local function getotherbed(pos)
	local normalsides = {"Top", "Left", "Right", "Front", "Back"}
	for i,v in pairs(normalsides) do
		local bedobj = getblock(pos + (Vector3.FromNormalId(Enum.NormalId[v]) * 3))
		if bedobj and bedobj.Name == "bed" then
			return (pos + (Vector3.FromNormalId(Enum.NormalId[v]) * 3))
		end
	end
	return nil
end

local function isBlockCovered(pos)
    local normalsides = {"Top", "Left", "Right", "Front", "Back"}
	local coveredsides = 0
	for i, v in pairs(normalsides) do
		local blockpos = (pos + (Vector3.FromNormalId(Enum.NormalId[v]) * 3))
		local block = getblock(blockpos)
		if block then
			coveredsides = coveredsides + 1
		end
	end
	return coveredsides == #normalsides
end

local function getallblocks(pos, normal)
	local blocks = {}
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getblock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock and extrablock.Parent ~= nil and (covered or covered == false and lastblock == nil) then
			if bedwars["BlockController"]:isBlockBreakable({["blockPosition"] = blockpos}, lplr) then
				table.insert(blocks, extrablock.Name)
			else
				table.insert(blocks, "unbreakable")
				break
			end
			lastfound = extrablock
			if covered == false then
				break
			end
		else
			break
		end
	end
	return blocks
end

local function getlastblock(pos, normal)
	local lastfound = nil
	for i = 1, 20 do
		local blockpos = (pos + (Vector3.FromNormalId(normal) * (i * 3)))
		local extrablock = getblock(blockpos)
		local covered = isBlockCovered(blockpos)
		if extrablock and extrablock.Parent ~= nil and (covered or covered == false and lastblock == nil) then
			lastfound = extrablock
			if covered == false then
				break
			end
		else
			break
		end
	end
	return lastfound
end

local function getbestside(pos)
	local softest = 1000000
	local softestside = Enum.NormalId.Top
	local normalsides = {"Top", "Left", "Right", "Front", "Back"}
	for i,v in pairs(normalsides) do
		local sidehardness = 0
		for i2,v2 in pairs(getallblocks(pos, v)) do	
			sidehardness = sidehardness + (((v2 == "unbreakable" or v2 == "bed") and 99999999 or bedwars["ItemTable"][v2]["block"] and bedwars["ItemTable"][v2]["block"]["health"]) or 10)
            if bedwars["ItemTable"][v2]["block"] and v2 ~= "unbreakable" and v2 ~= "bed" and v2 ~= "ceramic" then
                local tool = getBestTool(v2)
                if tool then
                    sidehardness = sidehardness - bedwars["ItemTable"][tool["itemType"]]["breakBlock"][bedwars["ItemTable"][v2]["block"]["breakType"]]
                end
            end
		end
		if sidehardness <= softest then
			softest = sidehardness
			softestside = v
		end
	end
	return softestside, softest
end

local healthbarblocktable = {
	["blockHealth"] = -1,
	["breakingBlockPosition"] = Vector3.new(0, 0, 0)
}
bedwars["breakBlock"] = function(pos, effects, normal, bypass)
    if lplr:GetAttribute("DenyBlockBreak") == true then
		return nil
	end
	local block = ((bypass == nil and getlastblock(pos, Enum.NormalId[normal])) or getblock(pos))
	local notmainblock = not ((bypass == nil and getlastblock(pos, Enum.NormalId[normal])))
    if block and bedwars["BlockController"]:isBlockBreakable({blockPosition = bedwars["BlockController"]:getBlockPosition((notmainblock and pos or block.Position))}, lplr) then
        if bedwars["BlockEngineClientEvents"].DamageBlock:fire(block.Name, bedwars["BlockController"]:getBlockPosition((notmainblock and pos or block.Position)), block):isCancelled() then
            return nil
        end
        local olditem = nil
		pcall(function()
			olditem = lplr.Character.HandInvItem.Value
		end)
        local blockhealthbarpos = {blockPosition = Vector3.new(0, 0, 0)}
        local blockdmg = 0
        if block and block.Parent ~= nil then
            switchToAndUseTool(block)
            blockhealthbarpos = {
                blockPosition = bedwars["BlockController"]:getBlockPosition((notmainblock and pos or block.Position))
            }
            if healthbarblocktable.blockHealth == -1 or blockhealthbarpos.blockPosition ~= healthbarblocktable.breakingBlockPosition then
				local blockdata = bedwars["BlockController"]:getStore():getBlockData(blockhealthbarpos.blockPosition)
				if not blockdata then
					return nil
				end
				local blockhealth = blockdata:GetAttribute(lplr.Name .. "_Health")
				if blockhealth == nil then
					blockhealth = block:GetAttribute("Health");
				end
				healthbarblocktable.blockHealth = blockhealth
				healthbarblocktable.breakingBlockPosition = blockhealthbarpos.blockPosition
			end
            blockdmg = bedwars["BlockController"]:calculateBlockDamage(lplr, blockhealthbarpos)
            healthbarblocktable.blockHealth = healthbarblocktable.blockHealth - blockdmg
            if healthbarblocktable.blockHealth < 0 then
                healthbarblocktable.blockHealth = 0
            end
            bedwars["ClientHandlerDamageBlock"]:Get("DamageBlock"):CallServerAsync({
                blockRef = blockhealthbarpos, 
                hitPosition = (notmainblock and pos or block.Position), 
                hitNormal = Vector3.FromNormalId(Enum.NormalId[normal])
            }):andThen(function(p9)
				if p9 == "failed" then
					healthbarblocktable.blockHealth = healthbarblocktable.blockHealth + blockdmg
				end
			end)
            if effects then
				bedwars["BlockBreaker"]:updateHealthbar(blockhealthbarpos, healthbarblocktable.blockHealth, block:GetAttribute("MaxHealth"), blockdmg)
                if healthbarblocktable.blockHealth <= 0 then
                    bedwars["BlockBreaker"].breakEffect:playBreak(block.Name, blockhealthbarpos.blockPosition, lplr)
                    bedwars["BlockBreaker"].healthbarMaid:DoCleaning()
                else
                    bedwars["BlockBreaker"].breakEffect:playHit(block.Name, blockhealthbarpos.blockPosition, lplr)
                end
            end
        end
    end
end

local function isPointInMapOccupied(p)
    local region = Region3.new(p - Vector3.new(1, 1, 1), p + Vector3.new(1, 1, 1))
    local x = workspace:FindPartsInRegion3WithWhiteList(region, game:GetService("CollectionService"):GetTagged("block"))
    return (#x == 0)
end

local function get3Vector(p) 
    local x,y,z = p.X, p.Y,p.Z 
    x = math.floor((x) + 0.5)
    y = math.floor((y) + 0.5)
    z = math.floor((z) + 0.5)
    return Vector3.new(x,y,z)
end

local function getBestSword()
	local data, slot, bestdmg
    local items = bedwars.getInventory().items
	for i, v in next, items do
		if v.itemType:lower():find("sword") or v.itemType:lower():find("blade") then
			if bestdmg == nil or bedwars.ItemTable[v.itemType].sword.damage > bestdmg then
                data = v
				bestdmg = bedwars.ItemTable[v.itemType].sword.damage
				slot = i
			end
		end
	end
	return data, slot
end

local function state() 
    return bedwars["ClientStoreHandler"]:getState().Game.matchState
end
local states = {
    PRE = 0,
    RUNNING = 1,
    POST = 2
}

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

local function getBedNear(max)
    local returning, nearestnum = nil, max
    for i,v in next, getBeds() do 
        if isAlive() and v.Covers.BrickColor ~= lplr.TeamColor then
            local mag = (v.Position - lplr.Character.HumanoidRootPart.Position).Magnitude
            if mag < nearestnum then 
                nearestnum = mag
                returning = v
            end
        end
    end
    return returning
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

-- // combat window
do 
    local stopTween = false
    local origC0
    local aura = {["Enabled"] = false}
    local auradist = {["Value"] = 14 }
    local auraanim = {["Value"] = "Slow"}
    local hitremote = bedwars["ClientHandler"]:Get(bedwars["AttackRemote"])["instance"]
    aura = GuiLibrary["Objects"]["CombatWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Aura",
        ["Function"] = function(callback) 
            if callback then
                origC0 = origC0 or cam.Viewmodel.RightHand.RightWrist.C0
                spawn(function()
                    repeat wait() 
                        for i,v in next, getAllPlrsNear() do 
                            if isAlive(v) then
                                if state() ~= states.PRE and isAlive() and canBeTargeted(v, true) and (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).Magnitude < auradist["Value"] then 
                                    local weapon, slot = getBestSword()
                                    local selfpos = lplr.Character.HumanoidRootPart.Position + (auradist["Value"] > 14 and (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude > 14 and (CFrame.lookAt(lplr.Character.HumanoidRootPart.Position, v.Character.HumanoidRootPart.Position).lookVector * 4) or Vector3.new(0, 0, 0))
                                    local attackArgs = {
                                        ["weapon"] = weapon~=nil and weapon.tool,
                                        ["entityInstance"] = v.Character,
                                        ["validate"] = {
                                            ["raycast"] = {
                                                ["cameraPosition"] = hashvector(cam.CFrame.p), 
                                                ["cursorDirection"] = hashvector(Ray.new(cam.CFrame.p, v.Character.HumanoidRootPart.Position).Unit.Direction)
                                            },
                                            ["targetPosition"] = hashvector(v.Character.HumanoidRootPart.Position),
                                            ["selfPosition"] = hashvector(selfpos),
                                        }, 
                                        ["chargedAttack"] = {["chargeRatio"] = 1},
                                    }
                                    hitremote:InvokeServer(attackArgs)

                                    GuiLibrary["TargetHUDAPI"].update(v, math.floor(v.Character:GetAttribute("Health")))

                                    playanimation("rbxassetid://4947108314")

                                    -- animation stuff (thx 7grand once again)
                                    
                                    if not stopTween then
                                        local Tween
                                        if auraanim["Value"] == "Slow" then 
                                            Tween = TS:Create(cam.Viewmodel.RightHand.RightWrist,
                                            TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0), 
                                            {C0 = origC0 * CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(-math.rad(65), math.rad(55), -math.rad(70))})
                                        elseif auraanim["Value"] == "Medium" then 
                                            Tween = TS:Create(cam.Viewmodel.RightHand.RightWrist,
                                            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0), 
                                            {C0 = origC0 * CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(-math.rad(65), math.rad(55), -math.rad(70))})
                                        elseif auraanim["Value"] == "Fast" then 
                                            Tween = TS:Create(cam.Viewmodel.RightHand.RightWrist,
                                            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true, 0), 
                                            {C0 = origC0 * CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(-math.rad(65), math.rad(55), -math.rad(70))})
                                        elseif auraanim["Value"] == "Dev" then 
                                            Tween = TS:Create(cam.Viewmodel.RightHand.RightWrist,
                                            TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, true, 0), 
                                            {C0 = origC0 * CFrame.new(0.7, -0.7, 0.6) * CFrame.Angles(-math.rad(-90), math.rad(0), -math.rad(90))})
                                        end

                                        spawn(function()
                                            stopTween = true
                                            Tween:Play()
                                            Tween.Completed:Wait()
                                            stopTween = false
                                        end)
                                    end
                                end
                            else
                                GuiLibrary["TargetHUDAPI"].clear()
                            end
                        end
                    until aura["Enabled"] == false
                end)
            else
                cam.Viewmodel.RightHand.RightWrist.C0 = origC0
            end
        end,
    })
    auradist = aura.CreateSlider({
        ["Name"] = "Range",
        ["Function"] = function() end,
        ["Min"] = 1,
        ["Round"] = 0,
        ["Max"] = 18,
        ["Default"] = 18
    })
    auraanim = aura.CreateSelector({
        ["Name"] = "Anim",
        ["Function"] = function() end,
        ["List"] = {"Slow", "Medium", "Fast", "Dev", "None"},
        ["Default"] = "Slow",
    })

end

do 
    local veloh, velov = {["Value"] = 0},{["Value"] = 0}
    local velocity = {["Enabled"] = false}
    local oldveloh, oldvelov, oldvelofunc = bedwars["KnockbackTable"]["kbDirectionStrength"], bedwars["KnockbackTable"]["kbUpwardStrength"], bedwars["VelocityUtil"].applyVelocity
    velocity = GuiLibrary["Objects"]["CombatWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Velocity",
        ["Function"] = function(callback) 
            if callback then 
                bedwars["KnockbackTable"]["kbDirectionStrength"] = oldveloh * (veloh["Value"] / 100)
                bedwars["KnockbackTable"]["kbUpwardStrength"] = oldvelov * (velov["Value"] / 100)
                if veloh["Value"] == 0 and velov["Value"] == 0 then
                    bedwars["VelocityUtil"].applyVelocity = function(...) end
                else
                    bedwars["VelocityUtil"].applyVelocity = oldvelofunc
                end
            else
                bedwars["VelocityUtil"].applyVelocity = oldvelofunc
                bedwars["KnockbackTable"]["kbDirectionStrength"] = oldveloh
                bedwars["KnockbackTable"]["kbUpwardStrength"] = oldvelov
            end
        end,
    })
    veloh = velocity.CreateSlider({
        ["Name"] = "Horizontal",
        ["Function"] = function(value)
            if velocity["Enabled"] then 
                velocity.Toggle(nil, true, true)
                velocity.Toggle(nil, true, true)
            end
        end,
        ["Min"] = 0,
        ["Max"] = 100,
        ["Default"] = 0,
        ["Round"] = 1
    })
    velov = velocity.CreateSlider({
        ["Name"] = "Vertical",
        ["Function"] = function(value)
            if velocity["Enabled"] then 
                velocity.Toggle(nil, true, true)
                velocity.Toggle(nil, true, true)
            end
        end,
        ["Min"] = 0,
        ["Max"] = 100,
        ["Default"] = 0,
        ["Round"] = 1
    })
end

do 
    local old = getmetatable(bedwars["SwordController"]).isClickingTooFast
    local NoClickDelay = {["Enabled"] = false}
    NoClickDelay = GuiLibrary["Objects"]["CombatWindow"]["API"].CreateOptionsButton({
        ["Name"] = "NoClickDelay",
        ["Function"] = function(callback) 
            if callback then 
                getmetatable(bedwars["SwordController"]).isClickingTooFast = function(...) 
                    return false
                end
            else
                getmetatable(bedwars["SwordController"]).isClickingTooFast = old
            end
        end
    })
end
-- // exploits window 

do 
    local old, old2 = debug.getconstant(bedwars["SwingSwordRegion"], 10),debug.getconstant(bedwars["SwingSwordRegion"], 15)
    local ReachValue = {["Value"] = 0.1}
    Reach = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Reach",
        ["Function"] = function(callback) 
            if callback then 
                debug.setconstant(bedwars["SwingSwordRegion"], 10, old*(ReachValue["Value"]+1))
                debug.setconstant(bedwars["SwingSwordRegion"], 15, old2*(ReachValue["Value"]+1))
            else
                debug.setconstant(bedwars["SwingSwordRegion"], 10, old)
                debug.setconstant(bedwars["SwingSwordRegion"], 15, old2)
            end
        end,
    })
    ReachValue = Reach.CreateSlider({
        ["Name"] = "HitboxAdd",
        ["Function"] = function(value) 
            if Reach["Enabled"] then 
                debug.setconstant(bedwars["SwingSwordRegion"], 10, old*(value+1))
                debug.setconstant(bedwars["SwingSwordRegion"], 15, old2*(value+1))
            end
        end,
        ["Min"] = 0,
        ["Max"] = 2,
        ["Round"] = 1,
        ["Default"] = 2
    })
end


do 
    local shopbypass = {["Enabled"] = false}
    local old = bedwars["ShopItems"]
    shopbypass = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "ShopDisplayAll",
        ["Function"] = function(callback) 
            if callback then 
                for i,v in next, bedwars["ShopItems"] do 
                    v.nextTier = nil
                    v.tiered = nil
                end
            else
                bedwars["ShopItems"] = old
            end
        end,
    })
end


do 
    local Invisible = {["Enabled"] = false}
    Invisible = GuiLibrary["Objects"]["ExploitsWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Invisiblity",
        ["Function"] = function(callback) 
            if callback then 
				print(callback)
            else
                print(callback)
            end
        end,
    })
end



--// misc window



-- // movement window 
local stopSpeed = false
GuiLibrary["RemoveObject"]("LongJumpOptionsButton")
do 
    local longjumptick = tick()
    local speedval, timeval = {["Value"] = 0},{["Value"] = 0}
    local LongJump = {["Enabled"] = false}; LongJump = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
        ["Name"] = "LongJump",
        ["Function"] = function(callback) 
            if callback then
                spawn(function() 
                    task.wait(timeval["Value"])
                    if LongJump.Enabled then
                        LongJump.Toggle(false, true)
                    end
                end)
                spawn(function()
                    local i = 0
                    repeat 
                        local bt = WORKSPACE:GetServerTimeNow()
                        skipFrame()
                        local dt = WORKSPACE:GetServerTimeNow() - bt
                        if isAlive() then
                            stopSpeed = true
                            local params = RaycastParams.new()
                            params.FilterDescendantsInstances = {lplr.Character}
                            params.FilterType = Enum.RaycastFilterType.Blacklist
                            local ray = WORKSPACE:Raycast(lplr.Character.HumanoidRootPart.Position, Vector3.new(0, -7, 0), params)
                            if ray and ray.Instance then 
                                if LongJump.Enabled then
                                    LongJump.Toggle(false, true)
                                    stopSpeed = false
                                end
                                break
                            end

                            lplr.Character.Humanoid.WalkSpeed = speedsettings.wsvalue
                            local velo = lplr.Character.Humanoid.MoveDirection * (speedval["Value"]*(isnetworkowner(lplr.Character.HumanoidRootPart) and speedsettings.factor or 0)) * dt
                            velo = Vector3.new(velo.x / 10, 0, velo.z / 10)
                            lplr.Character:TranslateBy(velo)
                            local velo2 = (lplr.Character.Humanoid.MoveDirection * speedval["Value"]) / speedsettings.velocitydivfactor
                            lplr.Character.HumanoidRootPart.Velocity = Vector3.new(velo2.X, --[[math.random(-50, 50)]] 1, velo2.Z)
                        end
                    until not LongJump["Enabled"]
                    stopSpeed = false
                end)
            else
                stopSpeed = false
            end
        end,
    })
    speedval = LongJump.CreateSlider({
        ["Name"] = "Speed",
        ["Default"] = 50, 
        ["Min"] = 10,
        ["Round"] = 0,
        ["Max"] = 90,
        ["Function"] = function(value) end,
    })
    timeval = LongJump.CreateSlider({
        ["Name"] = "Duration",
        ["Default"] = 9, 
        ["Min"] = 2,
        ["Round"] = 0,
        ["Max"] = 9,
        ["Function"] = function(value) end,
    })
end

GuiLibrary["RemoveObject"]("SpeedOptionsButton")
do
    local isnetworkowner = isnetworkowner or function() return true end
    local speedval = {["Value"] = 40}
    local speedmode = {["Enabled"] = false}
    local speed = {["Enabled"] = false}
    speed = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Speed",
        ["ArrayText"] = function() return speedval["Value"] end,
        ["Function"] = function(callback)
            if callback then
                BindToStepped("Speed", function(time, dt)
                    if isAlive() and not stopSpeed then
                        lplr.Character.Humanoid.WalkSpeed = speedsettings.wsvalue
                        local velo = lplr.Character.Humanoid.MoveDirection * (speedval["Value"]*((isnetworkowner and isnetworkowner(lplr.Character.HumanoidRootPart)) and speedsettings.factor or 0)) * dt
                        velo = Vector3.new(velo.x / 10, 0, velo.z / 10)
                        lplr.Character:TranslateBy(velo)

                        local velo2 = (lplr.Character.Humanoid.MoveDirection * speedval["Value"]) / speedsettings.velocitydivfactor
                        lplr.Character.HumanoidRootPart.Velocity = Vector3.new(velo2.X, lplr.Character.HumanoidRootPart.Velocity.Y, velo2.Z)
                    end
                end)
            else
                lplr.Character.Humanoid.WalkSpeed = 16
                UnbindFromStepped("Speed")
            end
        end
    })
    speedval = speed.CreateSlider({
        ["Name"] = "Speed",
        ["Min"] = 1,
        ["Max"] = 44,
        ["Default"] = 44,
        ["Round"] = 0,
        ["Function"] = function() end
    })
end

GuiLibrary["RemoveObject"]("SpiderOptionsButton")
do 
    local xzdiv = {["Value"] = 1}
    local spiderval = {["Value"] = 40}
    local spider = {["Enabled"] = false}
    spider = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Spider",
        ["ArrayText"] = function() return spiderval["Value"] end,
        ["Function"] = function(callback)
            if callback then
                BindToStepped("Spider", function(time, dt)
                    if isAlive() then
                        local param = RaycastParams.new()
                        param.FilterDescendantsInstances = {game:GetService("CollectionService"):GetTagged("block")}
                        param.FilterType = Enum.RaycastFilterType.Whitelist
                        local ray = WORKSPACE:Raycast(lplr.Character.Head.Position-Vector3.new(0, 4, 0), lplr.Character.Humanoid.MoveDirection*3, param)
                        local ray2 = WORKSPACE:Raycast(lplr.Character.Head.Position, lplr.Character.Humanoid.MoveDirection*3, param)
                        if (ray and ray.Instance~=nil) or (ray2 and ray2.Instance~=nil) then
                            local velo = Vector3.new(0, spiderval["Value"] / 100, 0)
                            lplr.Character:TranslateBy(velo)
                            local old = lplr.Character.HumanoidRootPart.Velocity
                            lplr.Character.HumanoidRootPart.Velocity = Vector3.new(old.X / xzdiv["Value"], 0, old.Z / xzdiv["Value"])
                        end
                    end
                end)
            else
                UnbindFromStepped("Spider")
            end
        end
    })
    spiderval = spider.CreateSlider({
        ["Name"] = "Speed",
        ["Min"] = 1,
        ["Max"] = 40,
        ["Default"] = 30,
        ["Round"] = 0,
        ["Function"] = function() end
    })
    xzdiv = spider.CreateSlider({
        ["Name"] = "XZDivision",
        ["Min"] = 1,
        ["Max"] = 10,
        ["Default"] = 5,
        ["Round"] = 0,
        ["Function"] = function() end
    })
end

do 
    local nofall = {["Enabled"] = false}
    nofall = GuiLibrary["Objects"]["MovementWindow"]["API"].CreateOptionsButton({
        ["Name"] = "NoFall",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function()
                    repeat wait() 
                        if WORKSPACE:FindFirstChild("Map") and isAlive() then
                            game:GetService("ReplicatedStorage").rbxts_include.node_modules.net.out._NetManaged.GroundHit:FireServer(WORKSPACE.Map.Blocks,999999999999999.00069)
                        end
                    until nofall.Enabled == false
                end)
            end
        end
    })
end

-- // render window 
if isnetworkowner~=nil then do 
    local textlabel
    local LagBackNotify = {["Enabled"] = false}
    local notifyfunc
    notifyfunc = function() 
        if not isAlive() then repeat task.wait() until isAlive() end
        repeat task.wait() until not isnetworkowner(lplr.Character.HumanoidRootPart) or not isAlive()
        if isAlive() and LagBackNotify["Enabled"] then 
            textlabel = textlabel or Instance.new("TextLabel")
            textlabel.Size = UDim2.new(1, 0, 0, 36)
            textlabel.RichText = true
            textlabel.Text = "Lagback detected!"
            textlabel.BackgroundTransparency = 1
            textlabel.TextStrokeTransparency = 0.5
            textlabel.TextSize = 25
            textlabel.Font = Enum.Font.GothamSemibold
            textlabel.TextColor3 = Color3.fromRGB(255, 174, 0)
            textlabel.Position = UDim2.new(0, 0, 0, -70)
            textlabel.Parent = GuiLibrary["ScreenGui"]
            local Tween = TS:Create(textlabel, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0), {Position = UDim2.new(0, 0, 0, 0)})
            Tween:Play()
            repeat task.wait() until isnetworkowner(lplr.Character.HumanoidRootPart) or not isAlive()
            if textlabel then
                local Tween = TS:Create(textlabel, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, false, 0), {Position = UDim2.new(0, 0, 0, -70)})
                Tween:Play()
            end
        end
        notifyfunc()
    end
    LagBackNotify = GuiLibrary["Objects"]["RenderWindow"]["API"].CreateOptionsButton({
        ["Name"] = "LagbackNotifier",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function() 
                    notifyfunc()
                end)
            else
                if textlabel then
                    textlabel:Destroy()
                    textlabel = nil
                end
            end
        end,
    })
end end

do
    local BedESPFolder = Instance.new("Folder", GuiLibrary["ScreenGui"]) 
    BedESPFolder.Name = "BedESP"
    local function refresh(boolean) 
        if boolean then
            BedESPFolder:ClearAllChildren()
        end
        for i,v in next, getBeds() do 
            for i2,v2 in next, v:GetChildren() do
                local bhd = Instance.new("BoxHandleAdornment", BedESPFolder)
                bhd.Size = v2.Size + Vector3.new(0.01, 0.01, 0.01)
                bhd.CFrame = CFrame.new()
                bhd.Color3 = v2.Color
                bhd.Visible = true
                bhd.Adornee = v2
                bhd.ZIndex = 10
                bhd.Transparency = 0
                bhd.AlwaysOnTop = true
            end
        end
    end
    local connection, connection2
    local BedESP = {["Enabled"] = false}
    BedESP = GuiLibrary["Objects"]["RenderWindow"]["API"].CreateOptionsButton({
        ["Name"] = "BedESP",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function()
                    local connection2 = WORKSPACE:WaitForChild("Map"):WaitForChild("Blocks").ChildRemoved:Connect(function(v) 
                        if v.Name ~= "bed" then 
                            return nil
                        end
                        refresh(true)
                    end)
                    for i,v in next, getBeds() do 
                        for i2,v2 in next, v:GetChildren() do
                            refresh(false)   
                        end
                    end
                    bedwars["ClientHandler"]:WaitFor("BedwarsBedBreak"):andThen(function(p13)
                        connection = p13:Connect(function(p14) 
                            refresh(true)
                        end)
                    end)
                end)
            else
                if connection then 
                    connection:Disconnect()
                    connection = nil
                end
                if connection2 then 
                    connection2:Disconnect()
                    connection2 = nil
                end
                BedESPFolder:ClearAllChildren()
            end
        end 
    })
end

GuiLibrary["RemoveObject"]("ESPOptionsButton")
do 
    local esp = {["Enabled"] = false}
    local espfolder = GuiLibrary["ScreenGui"]:FindFirstChild("ESP") or Instance.new("Folder", GuiLibrary["ScreenGui"])
    espfolder.Name = "ESP"
    local espnames= {["Enabled"] = false}
    local espdisplaynames= {["Enabled"] = false}
    esp = GuiLibrary["Objects"]["RenderWindow"]["API"].CreateOptionsButton({
        ["Name"] = "ESP",
        ["Function"] = function(callback) 
            if callback then 
                BindToStepped("ESP", function() 
                    for i,v in next, PLAYERS:GetPlayers() do 
                        if v~=lplr and isAlive(v) then
                            local plrespframe
                            if espfolder:FindFirstChild(v.Name) then 
                                plrespframe = espfolder:FindFirstChild(v.Name)
                                plrespframe.line2.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe.line1.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe.line3.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe.line4.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe:FindFirstChild("name").TextColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                plrespframe:FindFirstChild("name").Visible = espnames["Enabled"]
                                local text = espdisplaynames["Enabled"] and v.DisplayName or v.Name
                                plrespframe:FindFirstChild("name").Text = "<stroke color='#000000' thickness='1'>"..text..(esphealth["Enabled"] and (" [<font color='#"..(convertHealthToColor(v.Character:GetAttribute("Health"),  v.Character:GetAttribute("MaxHealth")):ToHex()).."'>"..tostring(math.round(v.Character:GetAttribute("Health"))).."</font>]") or "").."</stroke>"
                            else
                                plrespframe = Instance.new("Frame", espfolder)
                                plrespframe.BackgroundTransparency = 1
                                plrespframe.Visible = false
                                plrespframe.Name = v.Name
                                plrespframe.BorderSizePixel = 0
                                local line1 = Instance.new("Frame", plrespframe)
                                line1.BorderSizePixel = 0
                                line1.Name = "line1"
                                line1.ZIndex = 99
                                line1.Size = UDim2.new(1, -2, 0, 1)
                                line1.Position = UDim2.new(0, 1, 0, 1)
                                line1.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                line1.Parent = plrespframe
                                local line2 = Instance.new("Frame", plrespframe)
                                line2.BorderSizePixel = 0
                                line2.Name = "line2"
                                line2.ZIndex = 99
                                line2.Size = UDim2.new(1, -2, 0, 1)
                                line2.Position = UDim2.new(0, 1, 1, -2)
                                line2.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                line2.Parent = plrespframe
                                local line3 = Instance.new("Frame", plrespframe)
                                line3.BorderSizePixel = 0
                                line3.Name = "line3"
                                line3.ZIndex = 99
                                line3.Size = UDim2.new(0, 1, 1, -2)
                                line3.Position = UDim2.new(0, 1, 0, 1)
                                line3.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                line3.Parent = plrespframe
                                local line4 = Instance.new("Frame", plrespframe)
                                line4.BorderSizePixel = 0
                                line4.Name = "line4"
                                line4.ZIndex = 99
                                line4.Size = UDim2.new(0, 1, 1, -2)
                                line4.Position = UDim2.new(1, -2, 0, 1)
                                line4.BackgroundColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                line4.Parent = plrespframe
                                local name = Instance.new("TextLabel", plrespframe)
                                local text = espdisplaynames["Enabled"] and v.DisplayName or v.Name
                                name.TextColor3 = getColorFromPlayer(v) or GuiLibrary["GetColor"]()
                                name.BackgroundTransparency = 1
                                name.Size = UDim2.new(0, 1, 1, 2)
                                name.Position = UDim2.new(0.5, 0, -0.95, 0)
                                name.AnchorPoint = Vector2.new(0.5, 0)
                                name.RichText = true
                                name.Text = "<stroke color='#000000' thickness='1'>"..text..(esphealth["Enabled"] and (" [<font color='#"..(convertHealthToColor(v.Character:GetAttribute("Health"),  v.Character:GetAttribute("MaxHealth")):ToHex()).."'>"..tostring(v.Character:GetAttribute("Health")).."</font>]") or "").."</stroke>"
                                name.Visible = espnames["Enabled"]
                                name.Name = "name"
                                name.TextSize = 15
                                name.Font = Enum.Font.Code
                            end

                            local rootPos, rootVis = WORKSPACE.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
							local rootSize = (v.Character.HumanoidRootPart.Size.X * 1200) * (WORKSPACE.CurrentCamera.ViewportSize.X / 1920)
							local headPos, headVis = WORKSPACE.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position + Vector3.new(0, 1 + v.Character.Humanoid.HipHeight, 0))
							local legPos, legVis = WORKSPACE.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position - Vector3.new(0, 1 + v.Character.Humanoid.HipHeight, 0))
                            plrespframe.Visible = rootVis
                            plrespframe.name.Visible = espnames["Enabled"]
                            if rootVis then
                                local rootSize = rootSize * 0.75
                                plrespframe.Size = UDim2.new(0, rootSize / rootPos.Z, 0, (headPos.Y - legPos.Y))
                                plrespframe.Position = UDim2.new(0, rootPos.X - plrespframe.Size.X.Offset / 2, 0, (rootPos.Y - plrespframe.Size.Y.Offset / 2) - 36)
                            end
                        end
                    end
                    for i,v in next, espfolder:GetChildren() do 
                        if not PLAYERS:FindFirstChild(v.Name) or not isAlive(PLAYERS:FindFirstChild(v.Name)) then
                            v:Destroy()
                        end
                    end
                end)
            else
                UnbindFromStepped("ESP")
                espfolder:ClearAllChildren()
            end
        end
    })

    espnames = esp.CreateToggle({
        ["Name"] = "Names",
        ["Function"] = function() end,
    })

    espdisplaynames = esp.CreateToggle({
        ["Name"] = "UseDisplayNames",
        ["Function"] = function() end,
    })
    esphealth = esp.CreateToggle({
        ["Name"] = "Health",
        ["Function"] = function() end,
    })
end

-- world window

do 
    local ChestStealer = {["Enabled"] = false}
	local ChestStealerDistance = {["Value"] = 1}
	local ChestStealDelay = tick()
	ChestStealer = GuiLibrary["Objects"]["WorldWindow"]["API"].CreateOptionsButton({
		["Name"] = "ChestStealer",
		["Function"] = function(callback)
			if callback then
				BindToRenderStep("ChestStealer", function()
					if ChestStealDelay <= tick() and isAlive() then
						ChestStealDelay = tick() + 0.2
						local rootpart = lplr.Character and lplr.Character:FindFirstChild("HumanoidRootPart")
						for i,v in pairs(game:GetService("CollectionService"):GetTagged("chest")) do
							if rootpart and (rootpart.Position - v.Position).magnitude <= ChestStealerDistance["Value"] and v:FindFirstChild("ChestFolderValue") then
								local chest = v.ChestFolderValue.Value
								local chestitems = chest and chest:GetChildren() or {}
								if #chestitems > 0 then
									bedwars["ClientHandler"]:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(chest)
									for i3,v3 in pairs(chestitems) do
										if v3:IsA("Accessory") then
											bedwars["ClientHandler"]:GetNamespace("Inventory"):Get("ChestGetItem"):CallServer(v.ChestFolderValue.Value, v3)
										end
									end
									bedwars["ClientHandler"]:GetNamespace("Inventory"):Get("SetObservedChest"):SendToServer(nil)
								end
							end
						end
					end
				end)
			else
				UnbindFromRenderStep("ChestStealer")
			end
		end,
		["HoverText"] = "Grabs items from near chests."
	})
	ChestStealerDistance = ChestStealer.CreateSlider({
		["Name"] = "Distance",
		["Min"] = 0,
		["Max"] = 18,
		["Function"] = function() end,
		["Default"] = 18
	})
end

do 
    local bedaura = {["Enabled"] = false}; bedaura = GuiLibrary["Objects"]["WorldWindow"]["API"].CreateOptionsButton({
        ["Name"] = "BedAura",
        ["Function"] = function(callback) 
            if callback then 
                spawn(function() 
                    repeat task.wait(0.2) 
                        local bed = getBedNear(20)
                        if bed then 
                            local bestSide = getbestside(bed.Position)
                            if bestSide then
                                bedwars["breakBlock"](bed.Position, true, bestSide)
                            end
                        end
                    until bedaura["Enabled"] == false
                end)
            end
        end
    })
end

do 
    local controls = require(game:GetService("Players").LocalPlayer.PlayerScripts.PlayerModule):GetControls()
    local AntiVoid = {["Enabled"] = false}; 
    AntiVoid = GuiLibrary["Objects"]["WorldWindow"]["API"].CreateOptionsButton({
        ["Name"] = "AntiVoid",
        ["Function"] = function(callback)
            if callback then 
                spawn(function()
                    local lastValid 
                    repeat task.wait(0.05)
                        if isAlive() then 
                            if lplr.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then 
                                lastValid = lplr.Character.HumanoidRootPart.CFrame
                            else
                                local params = RaycastParams.new()
                                params.FilterDescendantsInstances = {game:GetService("CollectionService"):GetTagged("block")}
                                params.FilterType = Enum.RaycastFilterType.Whitelist
                                local ray = WORKSPACE:Raycast(lplr.Character.HumanoidRootPart.Position, Vector3.new(0, -999999999999, 0), params)
                                if ray and not ray.Instance or not ray then 
                                    local mag = (lplr.Character.HumanoidRootPart.Position - lastValid.p).magnitude
                                    local magY = (lplr.Character.HumanoidRootPart.Position.Y - lastValid.p.Y)
                                    if magY <= -10 then 
                                        spawn(function()
                                            controls:Disable()
                                            lplr.Character.HumanoidRootPart.CFrame = lastValid:lerp(lplr.Character.HumanoidRootPart.CFrame, 0.5)
                                            task.wait(0.2)
                                            lplr.Character.HumanoidRootPart.CFrame = lastValid
                                            controls:Enable()
                                        end)
                                    end
                                end
                            end
                        end
                    until not AntiVoid["Enabled"] 
                end)
            end
        end,
    })
end


do
    local scaffold = {["Enabled"] = false}
    scaffold = GuiLibrary["Objects"]["WorldWindow"]["API"].CreateOptionsButton({
        ["Name"] = "Scaffold",
        ["Function"] = function(callback) 
            if callback then 
                BindToStepped("Scaffold", function()
                    if isAlive() and lplr.Character:FindFirstChild("Humanoid") ~= nil then
                        local block = getwool()
                        local newpos = lplr.Character.HumanoidRootPart.Position
                        newpos = get3Vector( Vector3.new(newpos.X, lplr.Character.HumanoidRootPart.Position.Y - 4, newpos.Z) )
                        local movedir = lplr.Character:FindFirstChild("Humanoid").MoveDirection
                        if movedir.X==0 and movedir.Z==0 and lplr.Character:FindFirstChild("Humanoid").Jump==true  then 
                            local velo = lplr.Character.HumanoidRootPart.Velocity
                            lplr.Character.HumanoidRootPart.Velocity = Vector3.new(0, 25, 0)
                        end
                        if not isPointInMapOccupied(newpos) then
                            bedwars["placeBlock"](newpos)
                        end

                        local expandpos = lplr.Character.HumanoidRootPart.Position + ((lplr.Character.Humanoid.MoveDirection.Unit))
                        expandpos = get3Vector( Vector3.new(expandpos.X, lplr.Character.HumanoidRootPart.Position.Y-4, expandpos.Z) )
                        if not isPointInMapOccupied(expandpos) then
                            bedwars["placeBlock"](expandpos)
                        end

                        local expandpos2 = lplr.Character.HumanoidRootPart.Position + ((lplr.Character.Humanoid.MoveDirection.Unit*2))
                        expandpos2 = get3Vector( Vector3.new(expandpos2.X, lplr.Character.HumanoidRootPart.Position.Y-4, expandpos2.Z) )
                        if not isPointInMapOccupied(expandpos2) then
                            bedwars["placeBlock"](expandpos2)
                        end
                    end
                end)
            else
                UnbindFromStepped("Scaffold")
            end
        end
    })
end


-- other window 

local function PrepareSessionInfo() 
    local api = {}

    local posTable = {
        ["X"] = {
            ["Scale"] = 0.790697575, 
            ["Offset"] = 0,
        },
        ["Y"] = {
            ["Scale"] = 0.539999962,
            ["Offset"] = 0
        }
    }
    if isfile("Future/configs/SessionInfo.json") then 
        local suc, value = pcall(function() 
            return HTTPSERVICE:JSONDecode(readfile("Future/configs/SessionInfo.json"))
        end)
        if suc then 
            posTable = value
        end
    end

    local SessionInfo = Instance.new("Frame")
    local Topbar = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local MainContainer = Instance.new("Frame")
    local Playtime = Instance.new("TextLabel")
    local UIGridLayout = Instance.new("UIGridLayout")
    local Lagbacks = Instance.new("TextLabel")
    local Kills = Instance.new("TextLabel")
    local Wins = Instance.new("TextLabel")
    local PlaytimeValue = Instance.new("TextLabel")
    local LagbacksValue = Instance.new("TextLabel")
    local KillsValue = Instance.new("TextLabel")
    local WinsValue = Instance.new("TextLabel")

    local p = posTable
    SessionInfo.Name = "SessionInfo"
    SessionInfo.Parent = GuiLibrary["ScreenGui"]
    SessionInfo.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    SessionInfo.BackgroundTransparency = 0.250
    SessionInfo.BorderSizePixel = 0
    SessionInfo.Position = UDim2.new(p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset)
    SessionInfo.Size = UDim2.new(0, 204, 0, 98)

    Topbar.Name = "Topbar"
    Topbar.Parent = SessionInfo
    Topbar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    Topbar.BackgroundTransparency = 0.600
    Topbar.BorderSizePixel = 0
    Topbar.Size = UDim2.new(0, 204, 0, 23)

    Title.Name = "Title"
    Title.Parent = Topbar
    Title.AnchorPoint = Vector2.new(0.5, 0.5)
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1.000
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0.0500000007, 0, 0.5, 0)
    Title.Size = UDim2.new(0, 10, 0, 23)
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = "Session Info"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14.000
    Title.TextXAlignment = Enum.TextXAlignment.Left

    MainContainer.Name = "MainContainer"
    MainContainer.Parent = SessionInfo
    MainContainer.AnchorPoint = Vector2.new(0.5, 0)
    MainContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainContainer.BackgroundTransparency = 1.000
    MainContainer.BorderSizePixel = 0
    MainContainer.Position = UDim2.new(0.5, 0, 0.244681045, 0)
    MainContainer.Size = UDim2.new(0, 192, 0, 72)

    Playtime.Name = "Playtime"
    Playtime.Parent = MainContainer
    Playtime.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Playtime.BackgroundTransparency = 1.000
    Playtime.Position = UDim2.new(0.0343137085, 0, -0.0584415607, 0)
    Playtime.Size = UDim2.new(0, 10, 0, 23)
    Playtime.Font = Enum.Font.Gotham
    Playtime.Text = "Playtime"
    Playtime.TextColor3 = Color3.fromRGB(255, 255, 255)
    Playtime.TextSize = 14.000
    Playtime.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    Playtime.TextXAlignment = Enum.TextXAlignment.Left

    UIGridLayout.Parent = MainContainer
    UIGridLayout.FillDirection = Enum.FillDirection.Vertical
    UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIGridLayout.CellPadding = UDim2.new(0, 0, 0, 0)
    UIGridLayout.CellSize = UDim2.new(0, 98, 0, 18)
    UIGridLayout.FillDirectionMaxCells = 5

    Lagbacks.Name = "Lagbacks"
    Lagbacks.Parent = MainContainer
    Lagbacks.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Lagbacks.BackgroundTransparency = 1.000
    Lagbacks.Position = UDim2.new(0.0343137085, 0, -0.0584415607, 0)
    Lagbacks.Size = UDim2.new(0, 10, 0, 23)
    Lagbacks.Font = Enum.Font.Gotham
    Lagbacks.Text = "Lagbacks"
    Lagbacks.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lagbacks.TextSize = 14.000
    Lagbacks.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    Lagbacks.TextXAlignment = Enum.TextXAlignment.Left

    Kills.Name = "Kills"
    Kills.Parent = MainContainer
    Kills.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Kills.BackgroundTransparency = 1.000
    Kills.Position = UDim2.new(0.0343137085, 0, -0.0584415607, 0)
    Kills.Size = UDim2.new(0, 10, 0, 23)
    Kills.Font = Enum.Font.Gotham
    Kills.Text = "Kills"
    Kills.TextColor3 = Color3.fromRGB(255, 255, 255)
    Kills.TextSize = 14.000
    Kills.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    Kills.TextXAlignment = Enum.TextXAlignment.Left

    Wins.Name = "Wins"
    Wins.Parent = MainContainer
    Wins.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Wins.BackgroundTransparency = 1.000
    Wins.Position = UDim2.new(0.0343137085, 0, -0.0584415607, 0)
    Wins.Size = UDim2.new(0, 10, 0, 23)
    Wins.Font = Enum.Font.Gotham
    Wins.Text = "Wins"
    Wins.TextColor3 = Color3.fromRGB(255, 255, 255)
    Wins.TextSize = 14.000
    Wins.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    Wins.TextXAlignment = Enum.TextXAlignment.Left

    PlaytimeValue.Name = "PlaytimeValue"
    PlaytimeValue.Parent = MainContainer
    PlaytimeValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    PlaytimeValue.BackgroundTransparency = 1.000
    PlaytimeValue.Position = UDim2.new(0.53125, 0, 0, 0)
    PlaytimeValue.Size = UDim2.new(0, 96, 0, 18)
    PlaytimeValue.Font = Enum.Font.Gotham
    PlaytimeValue.Text = "0d 0h 0m 0s"
    PlaytimeValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlaytimeValue.TextSize = 14.000
    PlaytimeValue.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    PlaytimeValue.TextXAlignment = Enum.TextXAlignment.Right

    LagbacksValue.Name = "LagbacksValue"
    LagbacksValue.Parent = MainContainer
    LagbacksValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    LagbacksValue.BackgroundTransparency = 1.000
    LagbacksValue.Position = UDim2.new(0.53125, 0, 0, 0)
    LagbacksValue.Size = UDim2.new(0, 96, 0, 18)
    LagbacksValue.Font = Enum.Font.Gotham
    LagbacksValue.Text = shared.FutureSavedSessionInfo and shared.FutureSavedSessionInfo.lagbacks or "0"
    LagbacksValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    LagbacksValue.TextSize = 14.000
    LagbacksValue.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    LagbacksValue.TextXAlignment = Enum.TextXAlignment.Right

    KillsValue.Name = "KillsValue"
    KillsValue.Parent = MainContainer
    KillsValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    KillsValue.BackgroundTransparency = 1.000
    KillsValue.Position = UDim2.new(0.53125, 0, 0, 0)
    KillsValue.Size = UDim2.new(0, 96, 0, 18)
    KillsValue.Font = Enum.Font.Gotham
    KillsValue.Text = shared.FutureSavedSessionInfo and shared.FutureSavedSessionInfo.kills or "0"
    KillsValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    KillsValue.TextSize = 14.000
    KillsValue.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    KillsValue.TextXAlignment = Enum.TextXAlignment.Right

    WinsValue.Name = "WinsValue"
    WinsValue.Parent = MainContainer
    WinsValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    WinsValue.BackgroundTransparency = 1.000
    WinsValue.Position = UDim2.new(0.53125, 0, 0, 0)
    WinsValue.Size = UDim2.new(0, 96, 0, 18)
    WinsValue.Font = Enum.Font.Gotham
    WinsValue.Text = shared.FutureSavedSessionInfo and shared.FutureSavedSessionInfo.wins or "0"
    WinsValue.TextColor3 = Color3.fromRGB(255, 255, 255)
    WinsValue.TextSize = 14.000
    WinsValue.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
    WinsValue.TextXAlignment = Enum.TextXAlignment.Right

    local _i_i = GuiLibrary["Signals"]["UpdateColor"]:connect(function(color) 
        Topbar.BackgroundColor3 = GuiLibrary["GetColor"]()
    end)

    table.insert(GuiLibrary["Connections"], _i_i)

    GuiLibrary["DragGUI"](SessionInfo, Topbar)

    function api.draw() 
        SessionInfo.Visible = true
    end

    function api.undraw() 
        SessionInfo.Visible = false
    end

    api.kills = KillsValue
    api.wins = WinsValue
    api.lagbacks = LagbacksValue
    api.playtime = PlaytimeValue
    api.Instance = SessionInfo

    return api
end

local SessionInfoAPI = PrepareSessionInfo()
local SessionInfoToggle = GuiLibrary["Objects"]["HUDOptionsButton"]["API"].CreateToggle({
    ["Name"] = "SessionInfo",
    ["Function"] = function(callback)
        GuiLibrary["Signals"]["HUDUpdate"]:Fire()
        if callback then 
            SessionInfoAPI.draw() 
        else
            SessionInfoAPI.undraw() 
        end
    end,
})

local detectLagback
detectLagback = function() 
    spawn(function() 
        if state() == 0 then repeat task.wait() until state() ~= states.PRE end
        if not isAlive() then repeat task.wait() until isAlive() end 
        repeat task.wait() until not isAlive() or not isnetworkowner(lplr.Character.HumanoidRootPart)
        if isAlive() then 
            SessionInfoAPI.lagbacks.Text = tostring(tonumber(SessionInfoAPI.lagbacks.Text) + 1)
        end
        repeat task.wait() until not isAlive() or isnetworkowner(lplr.Character.HumanoidRootPart)
        detectLagback()
    end)
end
detectLagback()

local ontp = game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        local api = SessionInfoAPI
		local stringtp = "shared.FutureSavedSessionInfo = {startTime ="..tostring(futureStartTime)..", kills = "..api.kills.Text..", wins = "..api.wins.Text..", lagbacks = "..api.lagbacks.Text.."}"
		queueteleport(stringtp)
        GuiLibrary["SaveConfig"](GuiLibrary["CurrentConfig"])
    end
end)

bedwars["ClientHandler"]:WaitFor("EntityDeathEvent"):andThen(function(p6)
    toDisconnect = p6:Connect(function(p7)
        if p7.fromEntity and p7.fromEntity.Name == lplr.Name then 
            SessionInfoAPI.kills.Text = tostring(tonumber(SessionInfoAPI.kills.Text) + 1)
        end
    end) 
    table.insert(GuiLibrary["Connections"], toDisconnect)
end)

spawn(function() 
    repeat task.wait() until state() == states.POST
    if state() == states.POST and isAlive() then 
        SessionInfoAPI.wins.Text = tostring(tonumber(SessionInfoAPI.wins.Text) + 1)
    end
end)

spawn(function()
    repeat task.wait(0.5) 

        local t = math.round(WORKSPACE:GetServerTimeNow()) - math.round((shared.FutureSavedSessionInfo and tonumber(shared.FutureSavedSessionInfo.startTime)) or futureStartTime)
        local seconds = tostring(t % 60)
        local minutes = tostring(math.floor(t / 60) % 60)
        local hours = tostring(math.floor(t / 3600) % 24)
        local days = tostring(math.floor(t / 86400))
        seconds = tostring(seconds)
        minutes = tostring(minutes)
        hours = tostring(hours)
        days = tostring(days)
        
        local formattedPlaytime = ("%sd %sh %sm %ss"):format(days, hours, minutes, seconds)

        SessionInfoAPI.playtime.Text = formattedPlaytime
    until not shared.Future
end)

GuiLibrary["Signals"]["HUDUpdate"]:connect(function() 
    if GuiLibrary["HUDEnabled"] then 
        if SessionInfoToggle["Enabled"] then 
            SessionInfoAPI.draw() 
        else
            SessionInfoAPI.undraw()
        end
    else
        SessionInfoAPI.undraw()
    end
end)

GuiLibrary.Signals.onDestroy:connect(function()
    local api = SessionInfoAPI
    shared.FutureSavedSessionInfo = {startTime = tostring(futureStartTime), kills = api.kills.Text, wins = api.wins.Text, lagbacks = api.lagbacks.Text}
    local si = SessionInfoAPI.Instance.Position

    local posTable = {
        ["X"] = {
            ["Scale"] = si.X.Scale, 
            ["Offset"] = si.X.Offset,
        },
        ["Y"] = {
            ["Scale"] = si.Y.Scale,
            ["Offset"] = si.Y.Offset
        }
    }

    local suc, value = pcall(function()
        return HTTPSERVICE:JSONEncode(posTable)
    end)
    if suc then 
        if isfile("Future/configs/SessionInfo.json") then 
            delfile("Future/configs/SessionInfo.json")
        end
        writefile("Future/configs/SessionInfo.json", value)
    else
        error(value)
    end
end)
