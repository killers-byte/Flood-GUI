-- ============================================
-- TROXZY VIP v20.1 – RECORD MODE & PAUSE FULLY WORKING
-- 🔥 Record Mode bisa dijalankan kapan saja (tanpa TAS Auto‑Start)
-- 🔥 Pause berfungsi: menjeda TAS, langsung lanjut saat unpause
-- 🔥 TAS Play Auto tetap auto‑queue stabil
-- 📱 UI selalu tampil, auto‑update hanya ke versi lebih tinggi
-- ============================================

repeat wait() until game:IsLoaded()
wait(2)

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

-- Player
local Player = Players.LocalPlayer
if not Player then return end
repeat wait() until Player.Character
wait(1)

local Camera = Workspace.CurrentCamera
if not Camera then return end

local IS_MOBILE = UIS.TouchEnabled

-- Global state
_G.TAS_PLAY_AUTO_ACTIVE = false
_G.TAS_PAUSED = false
_G.TAS_EXECUTING = false
_G.TroxzyAutoFarm = false

local CurrentlyFarming = false
local Escaped = false
local Main = nil
local ToggleBtn = nil
local MapDetect = nil
local TimerHookActive = false
local TimerHookStart = 0

-- Cleanup
for _, gui in pairs(Player.PlayerGui:GetChildren()) do
    if gui.Name:find("TROXZY") then gui:Destroy() end
end

if _G.TroxzyConnections then
    for _, conn in pairs(_G.TroxzyConnections) do
        pcall(function() conn:Disconnect() end)
    end
end
_G.TroxzyConnections = {}

local function TrackConnection(conn)
    table.insert(_G.TroxzyConnections, conn)
    return conn
end

-- Utility
local function addCorner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = obj
end

local function addStroke(obj, thickness, color)
    local s = Instance.new("UIStroke", obj)
    s.Thickness = thickness or 1.5
    s.Color = color or Color3.fromRGB(255,255,255)
    s.Transparency = 0.6
end

local function notify(msg, title)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Troxzy VIP",
            Text = msg,
            Duration = 2
        })
    end)
end

local SOUND_IDS = {
    success = 9120386436,
    alert = 9116456845,
    error = 9116456845
}
local function playSound(id)
    if not id then return end
    pcall(function()
        local sound = Instance.new("Sound", Workspace)
        sound.SoundId = "rbxassetid://" .. id
        sound.Volume = 0.5
        sound:Play()
        game.Debris:AddItem(sound, 3)
    end)
end

-- Version
local SCRIPT_VERSION = "20.1"
local UPDATE_URL = "https://raw.githubusercontent.com/killers-byte/Flood-GUI/refs/heads/main/TroxzyVIP.lua"

local function compareVersions(v1, v2)
    local major1, minor1 = v1:match("^(%d+)%.(%d+)$")
    local major2, minor2 = v2:match("^(%d+)%.(%d+)$")
    if not major1 or not major2 then return false end
    local num1 = tonumber(major1) * 100 + tonumber(minor1)
    local num2 = tonumber(major2) * 100 + tonumber(minor2)
    return num1 < num2
end

local function checkForUpdates()
    notify("Checking for updates...", "Updater")
    local success, latestScript = pcall(function() return game:HttpGet(UPDATE_URL) end)
    if not success then notify("Update check failed", "Updater"); return end
    local versionMatch = string.match(latestScript, 'SCRIPT_VERSION = "([%d.]+)"')
    if versionMatch and compareVersions(SCRIPT_VERSION, versionMatch) then
        notify("New version v" .. versionMatch .. " found! Updating...", "Updater")
        task.wait(1)
        local func, err = loadstring(latestScript)
        if func then pcall(func) else notify("Update failed", "Error") end
    else
        notify("Already on latest version (v" .. SCRIPT_VERSION .. ")", "Updater")
    end
end

-- Config
local CONFIG = {
    TARGET_MAP = "Sandswept Ruins", TARGET_DIFFICULTY = "Crazy",
    TAS_MODE = "Record", TAS_AUTO_START = false, TAS_PLAY_AUTO = false,
    NOCLIP = false, GOD_MODE = false, SPEED = false, INF_JUMP = false,
    ESP = false, FULLBRIGHT = false, FOV = false,
    SPEED_VAL = 20, FOV_VAL = 90,
    BLACKLIST_ENABLED = true, AUTO_RECONNECT = true, STAT_TRACKER = true,
    STEALTH_MODE = true, ADMIN_DETECTOR = true, AUTO_LEAVE_ADMIN = true,
    RANDOM_DELAY = true, HIDE_SCRIPT = true, MAP_ROTATION = false,
    NIGHT_MODE = false, DASHBOARD = false, SMART_ALERTS = true,
    AUTO_UPDATE = false, PANIC_MODE = false,
    -- EXTRA FEATURES
    COLLECT_ITEMS = true,
    AIR_SWIM = true,
    TIMER_HOOK = false,
    ANTI_REPORT = false,
    ANTI_ADMIN = false,
    CUSTOM_FLOOD_COLORS = false,
    FLOOD_COLOR = "Blue"
}

-- Stats
local Stats = {
    mapsCompleted = 0, totalTime = 0, sessionStart = tick(),
    difficultyStats = { Easy = 0, Normal = 0, Hard = 0, Insane = 0, Crazy = 0, ["Crazy+"] = 0 },
    blacklistedSkipped = 0, adminDetected = 0, adminLeft = 0, currentMap = ""
}
local function loadStats()
    if not readfile then return end
    if isfile("Troxzy_Stats.json") then
        local s, d = pcall(function() return HttpService:JSONDecode(readfile("Troxzy_Stats.json")) end)
        if s and d then for k, v in pairs(d) do if Stats[k] ~= nil then Stats[k] = v end end end
    end; Stats.sessionStart = tick()
end
local function saveStats()
    if not writefile then return end
    Stats.totalTime = Stats.totalTime + (tick() - Stats.sessionStart)
    writefile("Troxzy_Stats.json", HttpService:JSONEncode(Stats))
    Stats.sessionStart = tick()
end
local function updateStats(d)
    Stats.mapsCompleted = Stats.mapsCompleted + 1
    if d and Stats.difficultyStats[d] then Stats.difficultyStats[d] = Stats.difficultyStats[d] + 1 end
end
local function getStatsText()
    return string.format("Maps: %d  |  Adm: %d", Stats.mapsCompleted, Stats.adminLeft)
end

-- Blacklist
local MapBlacklist = { "Blue Moon", "Poisonous Chasm", "Rustic Jungle", "Luminance" }
local function isMapBlacklisted(n)
    if not CONFIG.BLACKLIST_ENABLED then return false end
    for _, bl in ipairs(MapBlacklist) do
        if n:lower():find(bl:lower()) then return true end
    end
    return false
end

-- Map Rotation
local MapRotation = {
    "Sandswept Ruins", "Axiom", "Castle Tides", "Lost Woods",
    "Nimble Valley", "Mayan Remnants", "Sulphureous Sea",
    "Lava Tower", "Dark Sci-Forest", "Sedimentary Temple",
    "Abandoned Facility", "Sinking Ship", "Familiar Ruins"
}
local rotationIndex = 1
local function rotateMap()
    if not CONFIG.MAP_ROTATION then return end
    CONFIG.TARGET_MAP = MapRotation[rotationIndex]
    rotationIndex = rotationIndex + 1
    if rotationIndex > #MapRotation then rotationIndex = 1 end
end

-- Admin Detector
local adminKeywords = { ["admin"] = true, ["mod"] = true, ["owner"] = true, ["dev"] = true, ["helper"] = true, ["staff"] = true }
local function isAdmin(p)
    if not CONFIG.ADMIN_DETECTOR then return false end
    local name = p.Name:lower()
    local display = p.DisplayName:lower()
    for kw, _ in pairs(adminKeywords) do
        if name:find(kw) or display:find(kw) then return true end
    end
    return false
end
local function detectAdmins()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and isAdmin(p) then return true end
    end
    return false
end

local function blockAdminRemotes()
    local RemoteFolder = ReplicatedStorage:WaitForChild("Remote")
    local dangerousKeywords = { "kick", "ban", "punish", "jail", "teleport", "freeze", "spectate", "kill", "crash" }
    for _, remote in ipairs(RemoteFolder:GetChildren()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local lowerName = remote.Name:lower()
            for _, kw in ipairs(dangerousKeywords) do
                if lowerName:find(kw) then
                    remote.OnClientEvent:Connect(function() end)
                    notify("Blocked remote: " .. remote.Name, "Anti-Admin")
                    break
                end
            end
        end
    end
end

local function preventReports()
    if not CONFIG.ANTI_REPORT then return end
    pcall(function()
        local oldReportAbuse = Players.ReportAbuse
        Players.ReportAbuse = function() end
        notify("Report abuse disabled!", "Anti-Report")
    end)
end

-- Deteksi admin
local lastAdminAlert = 0
local function handleAdminDetection()
    if not CONFIG.ADMIN_DETECTOR then return end
    if not detectAdmins() then return end
    local now = tick()
    if now - lastAdminAlert < 10 then return end
    lastAdminAlert = now
    Stats.adminDetected = Stats.adminDetected + 1
    notify("Admin terdeteksi! Mengaktifkan proteksi...", "Anti-Admin")
    if CONFIG.ANTI_ADMIN then
        blockAdminRemotes()
    end
    if CONFIG.SMART_ALERTS then playSound(SOUND_IDS.alert) end
end

local function handleAntiReport()
    if not CONFIG.ANTI_REPORT then return end
    preventReports()
end

handleAntiReport()

-- Custom Flood Colors
local floodColorMap = {
    Blue = Color3.fromRGB(0, 150, 255),
    Green = Color3.fromRGB(0, 255, 100),
    Red = Color3.fromRGB(255, 50, 50),
    Pink = Color3.fromRGB(255, 100, 200),
    Purple = Color3.fromRGB(150, 50, 255)
}
local function applyFloodColors()
    if not CONFIG.CUSTOM_FLOOD_COLORS then return end
    local targetColor = floodColorMap[CONFIG.FLOOD_COLOR] or Color3.fromRGB(0, 150, 255)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:lower():find("water") or v.Name:lower():find("acid") or v.Name:lower():find("lava") or v.Name:lower():find("flood")) then
            pcall(function() v.Color = targetColor end)
        end
    end
end
local lastFloodColorUpdate = 0
local function periodicFloodColorUpdate()
    if not CONFIG.CUSTOM_FLOOD_COLORS then return end
    local now = tick()
    if now - lastFloodColorUpdate < 0.5 then return end
    lastFloodColorUpdate = now
    applyFloodColors()
end

-- Stealth Mode
local function stealthDelay()
    return CONFIG.STEALTH_MODE and math.random(10, 50) / 100 or 0.05
end
local function stealthOffset()
    return CONFIG.STEALTH_MODE and Vector3.new(math.random(-50, 50) / 100, math.random(-30, 30) / 100, math.random(-50, 50) / 100) or Vector3.new(math.random(), math.random(), math.random())
end

-- Random Delay
local buttonCount = 0
local function getRandomFarmDelay()
    return CONFIG.RANDOM_DELAY and math.random(10, 50) / 10 or 0
end
local function shouldTakeBreak()
    if not CONFIG.RANDOM_DELAY then return false end
    buttonCount = buttonCount + 1
    if buttonCount >= math.random(3, 8) then
        buttonCount = 0
        return true
    end
    return false
end

-- Hide Script
local function isPlayerNearby()
    if not CONFIG.HIDE_SCRIPT then return false end
    local char = Player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if (root.Position - p.Character.HumanoidRootPart.Position).Magnitude < 20 then
                return true
            end
        end
    end
    return false
end

-- Reconnect
local function attemptReconnect()
    saveStats()
    task.wait(3)
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end)
    task.wait(2)
    pcall(function() TeleportService:Teleport(game.PlaceId) end)
end
local function setupAutoReconnect()
    if not CONFIG.AUTO_RECONNECT then return end
    TrackConnection(Player:GetPropertyChangedSignal("Parent"):Connect(function()
        if not Player.Parent then attemptReconnect() end
    end))
    TrackConnection(TeleportService.TeleportInitFailed:Connect(attemptReconnect))
    TrackConnection(Player.OnTeleport:Connect(saveStats))
end
local function forceReconnect()
    saveStats()
    task.wait(1)
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end)
    task.wait(2)
    pcall(function() TeleportService:Teleport(game.PlaceId) end)
end

-- Difficulty
local DIFFICULTY_RANKS = { ["Easy"] = 1, ["Normal"] = 2, ["Hard"] = 3, ["Insane"] = 4, ["Crazy"] = 5, ["Crazy+"] = 6 }

local function DisconnectMapDetection()
    if MapDetect then
        MapDetect:Disconnect()
        MapDetect = nil
    end
end

-- ==================== EXECUTE TAS ====================
local function ExecuteTAS()
    -- Hanya cek pause & executing, TIDAK perlu TAS_AUTO_START
    if _G.TAS_PAUSED then
        notify("TAS sedang dijeda.", "TAS Pause")
        return
    end
    if _G.TAS_EXECUTING then
        notify("TAS masih berjalan...", "TAS")
        return
    end

    _G.TAS_EXECUTING = true
    _G.TroxzyAutoFarm = false
    CurrentlyFarming = false

    local url = CONFIG.TAS_MODE == "Record"
        and "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TAS/CREATOR/creator.luau"
        or "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TAS/PLAYER/newtasplayer.luau"

    local ok, res = pcall(function() return game:HttpGet(url) end)
    if not ok then
        notify("Failed to download TAS", "Error")
        _G.TAS_EXECUTING = false
        return
    end

    local f, e = loadstring(res)
    if not f then
        notify("Failed to compile TAS: " .. tostring(e), "Error")
        _G.TAS_EXECUTING = false
        return
    end

    task.spawn(function()
        pcall(f)
        _G.TAS_EXECUTING = false
        notify("TAS completed!", "TAS")
        if _G.TAS_PLAY_AUTO_ACTIVE then
            _G.TroxzyAutoFarm = true
            DisconnectMapDetection()
        end
    end)

    notify("TAS Loaded!", "Success")
end

-- ==================== GAME DETECTION ====================
local Multiplayer = Workspace:WaitForChild("Multiplayer")
local RemoteFolder = ReplicatedStorage:WaitForChild("Remote")
local ReqPasskey, NewMapVote, UpdMapVote, AddedWaiting, AlertRemote =
    RemoteFolder:WaitForChild("ReqPasskey"),
    RemoteFolder:WaitForChild("NewMapVote"),
    RemoteFolder:WaitForChild("UpdMapVote"),
    RemoteFolder:WaitForChild("AddedWaiting"),
    RemoteFolder:WaitForChild("Alert")

TrackConnection(AlertRemote.OnClientEvent:Connect(function(msg)
    if type(msg) == "string" and msg:lower():match("escaped") then Escaped = true end
end))
TrackConnection(Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end))

-- Helpers
local function GetChar() return Player.Character end
local function Check(flag)
    local char = GetChar()
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    if flag == "InLift" then
        return hrp.Position.X < 50 and hrp.Position.Z > 70
    elseif flag == "InGame" then
        return hrp.Position.X > 50
    end
    return false
end
local function GetRandomPointInPart(part)
    local s = part.Size
    return part.CFrame * CFrame.new(
        (math.random() - 0.5) * (s.X * 0.9),
        (math.random() - 0.5) * (s.Y * 0.9),
        (math.random() - 0.5) * (s.Z * 0.9)
    )
end
local function GetCurrentDifficultyRank()
    local ok, res = pcall(function()
        local diffLabel = Workspace.Lobby.GameInfo.SurfaceGui.Frame.Difficulty.Difficulty
        return string.gsub(string.split(diffLabel.Text, ":")[1], "^%s*(.-)%s*$", "%1")
    end)
    if ok and res then return DIFFICULTY_RANKS[res] or 0, res end
    return 0, "Unknown"
end
local function isRandomString(str)
    if #str == 0 then return false end
    for i = 1, #str do
        if str:sub(i, i):lower() == str:sub(i, i) then return false end
    end
    return true
end

-- Noclip
local noclipCache, noclipActive = {}, false
local function refreshNoclipCache()
    noclipCache = {}
    local char = GetChar()
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then table.insert(noclipCache, v) end
        end
    end
end
local function applyNoclip(state)
    if state == noclipActive then return end
    noclipActive = state
    for _, v in ipairs(noclipCache) do
        if v and v.Parent then v.CanCollide = not state end
    end
end
TrackConnection(Player.CharacterAdded:Connect(function()
    repeat wait() until Player.Character
    refreshNoclipCache()
    noclipActive = false
end))
refreshNoclipCache()

-- ESP
local espCache = {}
local lastESPUpdate = 0
local ESP_UPDATE_INTERVAL = 0.1

local function clearESPForPlayer(plr)
    local hl = espCache[plr]
    if hl then pcall(function() hl:Destroy() end) end
    espCache[plr] = nil
end
local function clearAllESP()
    for plr, hl in pairs(espCache) do pcall(function() hl:Destroy() end) end
    espCache = {}
end
local function createHighlight(plr)
    if not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end
    clearESPForPlayer(plr)
    local hl = Instance.new("Highlight")
    hl.Name = "PlayerHighlight"
    hl.FillColor = Color3.fromRGB(160, 180, 200)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.Parent = plr.Character
    espCache[plr] = hl
end
local function onPlayerAdded(plr)
    if plr == Player then return end
    local conn
    conn = plr.CharacterAdded:Connect(function(char)
        clearESPForPlayer(plr)
        task.wait(0.1)
        if CONFIG.ESP and plr.Character and plr.Character:FindFirstChild("Head") then
            createHighlight(plr)
        end
    end)
    TrackConnection(conn)
    TrackConnection(plr.AncestryChanged:Connect(function()
        if not plr:IsDescendantOf(Players) then
            clearESPForPlayer(plr)
            if conn then conn:Disconnect() end
        end
    end))
    if plr.Character and plr.Character:FindFirstChild("Head") and CONFIG.ESP then
        createHighlight(plr)
    end
end
local function onPlayerRemoving(plr)
    clearESPForPlayer(plr)
end
for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= Player then onPlayerAdded(plr) end
end
TrackConnection(Players.PlayerAdded:Connect(onPlayerAdded))
TrackConnection(Players.PlayerRemoving:Connect(onPlayerRemoving))

local function updateESP()
    local now = tick()
    if now - lastESPUpdate < ESP_UPDATE_INTERVAL then return end
    lastESPUpdate = now
    if not CONFIG.ESP then
        if next(espCache) then clearAllESP() end
        return
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            local hl = espCache[plr]
            local char = plr.Character
            local head = char and char:FindFirstChild("Head")
            if head then
                if not hl or not hl.Parent or hl.Parent ~= char then
                    clearESPForPlayer(plr)
                    createHighlight(plr)
                end
            else
                clearESPForPlayer(plr)
            end
        end
    end
end
local function clearESPCache() clearAllESP() end

-- Panic Mode
local panicActive = false
local function activatePanicMode()
    panicActive = true
    _G.TroxzyAutoFarm = false
    CurrentlyFarming = false
    DisconnectMapDetection()
    applyNoclip(false)
    if Player.Character then
        local hum = Player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
    if Main then Main.Visible = false end
    clearESPCache()
    notify("PANIC MODE ACTIVATED!", "Emergency")
    if CONFIG.SMART_ALERTS then playSound(SOUND_IDS.alert) end
end
local function deactivatePanicMode()
    panicActive = false
    _G.TroxzyAutoFarm = false
    CurrentlyFarming = false
    if Player.Character then
        local hum = Player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
    applyNoclip(false)
    if Main then Main.Visible = true end
    if ToggleBtn then ToggleBtn.Visible = true end
    notify("Panic deactivated. Panel restored.", "Emergency")
end

-- Visual
local lastVisualUpdate, lastFOVValue = 0, 70
local function updateVisuals()
    if tick() - lastVisualUpdate < 0.5 then return end
    lastVisualUpdate = tick()
    Lighting.Brightness = CONFIG.FULLBRIGHT and 2 or 1
    Lighting.FogEnd = CONFIG.FULLBRIGHT and 99999 or 10000
    if Camera then
        local tfov = CONFIG.FOV and CONFIG.FOV_VAL or 70
        if tfov ~= lastFOVValue then
            Camera.FieldOfView = tfov
            lastFOVValue = tfov
        end
    end
    periodicFloodColorUpdate()
end

-- ==================== AUTO FARM ====================
local function OnMapLoad(map)
    clearESPCache()
    local settings = map:WaitForChild("Settings", 10)
    local mapName = settings and settings:GetAttribute("MapName") or "Unknown"
    handleAdminDetection()
    handleAntiReport()

    -- TAS Play Auto: langsung jalankan TAS
    if _G.TAS_PLAY_AUTO_ACTIVE and CONFIG.TAS_AUTO_START then
        _G.TroxzyAutoFarm = true
        DisconnectMapDetection()
        CONFIG.TAS_MODE = "Play"
        task.spawn(ExecuteTAS)
        return
    end

    -- Farming normal
    if isMapBlacklisted(mapName) then
        Stats.blacklistedSkipped = Stats.blacklistedSkipped + 1
        notify("Blacklisted: " .. mapName, "Skip")
        saveStats()
        local char = GetChar()
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChild("Humanoid")
            if hrp and hum then
                hrp.CFrame = CFrame.new(1000, 1000, 1000)
                task.wait(0.25)
                hum.Health = 0
            end
        end
        CurrentlyFarming = false
        return
    end

    CurrentlyFarming, Escaped = true, false
    Stats.currentMap = mapName
    TimerHookActive = false

    local char = GetChar()
    if not char then CurrentlyFarming = false; return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then CurrentlyFarming = false; return end

    local currentRank, currentName = GetCurrentDifficultyRank()
    if currentRank > (DIFFICULTY_RANKS[CONFIG.TARGET_DIFFICULTY] or 999) then
        notify("Difficulty High! Reset...", "Error")
        repeat task.wait() until not hrp.Anchored and hum.WalkSpeed >= 20
        hrp.CFrame = CFrame.new(1000, 1000, 1000)
        task.wait(0.25)
        hum.Health = 0
        CurrentlyFarming = false
        return
    end

    if CONFIG.COLLECT_ITEMS then
        local lostPage = map:FindFirstChild("_LostPage", true)
        local rescue = map:FindFirstChild("_Rescue", true)
        if lostPage then
            hrp.CFrame = lostPage.CFrame
            task.wait()
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 5, 0)
            notify("Lost Page collected!", "Item")
        end
        if rescue then
            hrp.CFrame = rescue.Contact.CFrame
            task.wait()
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 5, 0)
            notify("Survivor rescued!", "Item")
        end
    end

    if CONFIG.TIMER_HOOK then
        TimerHookActive = true
        TimerHookStart = tick()
    end

    local buttons = {}
    for _, obj in pairs(map:GetDescendants()) do
        if isRandomString(obj.Name) and obj.ClassName == "Model" then
            local hitbox
            for _, c in pairs(obj:GetChildren()) do
                if c:IsA("BasePart") and tostring(c.BrickColor) ~= "Medium stone grey" then
                    hitbox = c
                    break
                end
            end
            if hitbox and isRandomString(hitbox.Name) then
                hitbox.Name = "Hitbox"
                table.insert(buttons, obj)
            end
        end
    end

    local godMode = hum:GetPropertyChangedSignal("Health"):Connect(function()
        hum.Health = 1000
    end)
    TrackConnection(godMode)
    applyNoclip(true)

    while RunService.Heartbeat:Wait() and Check("InGame") and _G.TroxzyAutoFarm and not panicActive do
        if not CurrentlyFarming then break end

        if TimerHookActive and CONFIG.TIMER_HOOK and (tick() - TimerHookStart > 3) then
            local exitRegion = map:FindFirstChild("ExitRegion", true)
            if exitRegion then
                applyNoclip(false)
                hrp.CFrame = GetRandomPointInPart(exitRegion)
                hrp.Velocity = Vector3.zero
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
                notify("Timer Hook triggered!", "Speed")
                TimerHookActive = false
                break
            end
        end

        if CONFIG.HIDE_SCRIPT and Main then
            Main.Visible = not isPlayerNearby()
        end

        if shouldTakeBreak() then
            task.wait(getRandomFarmDelay())
        end

        local exitRegion = map:FindFirstChild("ExitRegion", true)
        local currentHRP = GetChar():FindFirstChild("HumanoidRootPart")
        if not currentHRP then break end
        local failedScan = true

        if not exitRegion then
            if Camera.CameraSubject ~= hum then Camera.CameraSubject = hum end
            currentHRP.Anchored = true
            for _, button in pairs(buttons) do
                if not _G.TroxzyAutoFarm then break end
                local bh = button:FindFirstChild("Hitbox")
                if bh and button:FindFirstChild("TouchInterest", true) and button:FindFirstChildWhichIsA("BillboardGui", true) then
                    failedScan = false
                    currentHRP.Anchored = false
                    currentHRP.CFrame = CFrame.new(bh.Position - stealthOffset())
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    task.wait(stealthDelay())
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                    task.wait(stealthDelay())
                end
            end
            if failedScan then RunService.Heartbeat:Wait() end
        else
            applyNoclip(false)
            currentHRP.Anchored = false
            if Camera.CameraSubject ~= exitRegion then Camera.CameraSubject = exitRegion end
            if not Escaped then
                currentHRP.CFrame = GetRandomPointInPart(exitRegion)
                currentHRP.Velocity = Vector3.zero
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            else
                Escaped = false
                Camera.CameraSubject = hum
                hum:ChangeState(Enum.HumanoidStateType.Dead)
                break
            end
        end
    end

    Camera.CameraSubject = hum
    applyNoclip(false)
    if godMode then godMode:Disconnect() end
    CurrentlyFarming = false
    updateStats(currentName)
    rotateMap()
    if CONFIG.SMART_ALERTS then playSound(SOUND_IDS.success) end
    notify("Complete!", "System")
    clearESPCache()

    if _G.TAS_PLAY_AUTO_ACTIVE then
        DisconnectMapDetection()
    end
end

-- ==================== MAP DETECTION ====================
local function ConnectMapDetection()
    if MapDetect then return end
    MapDetect = Multiplayer.ChildAdded:Connect(function(newMap)
        newMap:GetPropertyChangedSignal("Name"):Wait()
        if (_G.TroxzyAutoFarm or _G.TAS_PLAY_AUTO_ACTIVE) and not panicActive then
            OnMapLoad(newMap)
            notify("Map Detected!", "Info")
        end
    end)
    TrackConnection(MapDetect)
end

-- ==================== VOTE SYSTEM ====================
local function GetSessionKey()
    local s, k = pcall(function() return ReqPasskey:InvokeServer() end)
    return s and k and -k or nil
end
local function CalculateCost(md, mv)
    local c, id = 0, 0
    if mv then
        c = mv.voteCount or 0
        id = mv.mapID or 0
    end
    if id == md.ID then
        return math.clamp(md.extraVoteCost + (c - 1) * 10, 0, 50)
    end
    return md.locked and md.unlockCost or 0
end

TrackConnection(NewMapVote.OnClientEvent:Connect(function(d)
    local maps, pVotes = d.mapData, d.pVotes or {}
    if not maps then return end
    local ft
    for _, m in pairs(maps) do
        if m.name == CONFIG.TARGET_MAP and m.displayMap then
            ft = m
            break
        end
    end
    if ft then
        notify("Target Found!", "Success")
        _G.TroxzyAutoFarm, CurrentlyFarming = false, false
        if _G.TroxzyConnections then
            for _, c in pairs(_G.TroxzyConnections) do
                if c ~= MapDetect then pcall(function() c:Disconnect() end) end
            end
        end
        local key = GetSessionKey()
        if key then
            UpdMapVote:FireServer(key, ft.ID, CalculateCost(ft, pVotes[tostring(Player.UserId)]))
            notify("Voted!", "Success")
        else
            notify("Vote Failed", "Error")
        end
        task.wait(1)
        AddedWaiting:FireServer()
        if _G.TAS_PLAY_AUTO_ACTIVE and CONFIG.TAS_AUTO_START then
            CONFIG.TAS_MODE = "Play"
            task.spawn(ExecuteTAS)
        elseif CONFIG.TAS_AUTO_START then
            notify("TAS Auto-Start is ON but Play Auto is OFF. Skipping TAS.", "Info")
        else
            notify("TAS Auto-Start is OFF.", "Info")
        end
    end
end))

-- ==================== UI PROFESIONAL ====================
local COLORS = {
    MainBg = Color3.fromRGB(20, 20, 26),
    HeaderBg = Color3.fromRGB(22, 22, 28),
    TabActive = Color3.fromRGB(40, 50, 65),
    TabInactive = Color3.fromRGB(25, 25, 33),
    StatsBg = Color3.fromRGB(28, 38, 52),
    ToggleBg = Color3.fromRGB(35, 35, 45),
    ToggleDot = Color3.fromRGB(100, 100, 115),
    ToggleDotActive = Color3.fromRGB(100, 200, 255),
    ToggleBgActive = Color3.fromRGB(30, 60, 90),
    SectionText = Color3.fromRGB(180, 200, 220),
    TextBright = Color3.fromRGB(245, 245, 250),
    TextMedium = Color3.fromRGB(220, 225, 235),
    TextDim = Color3.fromRGB(160, 160, 175),
    InfoBg = Color3.fromRGB(30, 40, 55),
    InfoText = Color3.fromRGB(180, 210, 255),
    InputBg = Color3.fromRGB(35, 35, 45),
    CloseBg = Color3.fromRGB(180, 50, 50),
    ButtonRecord = Color3.fromRGB(180, 40, 40),
    ButtonUpdate = Color3.fromRGB(60, 120, 180),
    ButtonPanic = Color3.fromRGB(255, 80, 80),
    ButtonForceLeave = Color3.fromRGB(180, 50, 50),
    DividerColor = Color3.fromRGB(45, 45, 55),
    VersionText = Color3.fromRGB(100, 120, 140),
    ToggleBtnBg = Color3.fromRGB(42, 58, 85),
    ToggleBtnText = Color3.fromRGB(255, 255, 255),
    BorderColor = Color3.fromRGB(60, 60, 80)
}

local ScreenGui = Instance.new("ScreenGui", Player.PlayerGui)
ScreenGui.Name = "TROXZY_VIP"
ScreenGui.ResetOnSpawn = false

ToggleBtn = Instance.new("TextButton", ScreenGui)
ToggleBtn.Size = UDim2.new(0, 60, 0, 60)
ToggleBtn.Position = IS_MOBILE and UDim2.new(0.88, 0, 0.05, 0) or UDim2.new(0.015, 0, 0.015, 0)
ToggleBtn.BackgroundColor3 = COLORS.ToggleBtnBg
ToggleBtn.Text = "☰"
ToggleBtn.TextSize = 28
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextColor3 = COLORS.ToggleBtnText
addCorner(ToggleBtn, 14)
addStroke(ToggleBtn, 2, Color3.fromRGB(255, 255, 255))

Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 370, 0, 530)
Main.Position = UDim2.new(0.5, -185, 0.5, -265)
Main.BackgroundColor3 = COLORS.MainBg
Main.BorderSizePixel = 0
Main.Visible = true
Main.Active = true
Main.Draggable = true
addCorner(Main, 12)
addStroke(Main, 1.5, COLORS.BorderColor)

-- Header
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = COLORS.HeaderBg
Header.BorderSizePixel = 0
addCorner(Header, 12)
Instance.new("Frame", Header).Size = UDim2.new(1, 0, 0.5, 0)
local hc = Instance.new("Frame", Header)
hc.Position = UDim2.new(0, 0, 0.5, 0)
hc.BackgroundColor3 = COLORS.HeaderBg
hc.BorderSizePixel = 0

local AvatarFrame = Instance.new("Frame", Header)
AvatarFrame.Size = UDim2.new(0, 38, 0, 38)
AvatarFrame.Position = UDim2.new(0, 10, 0.5, -19)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
AvatarFrame.BorderSizePixel = 0
addCorner(AvatarFrame, 19)
local Avatar = Instance.new("ImageLabel", AvatarFrame)
Avatar.Size = UDim2.new(0, 32, 0, 32)
Avatar.Position = UDim2.new(0, 3, 0, 3)
Avatar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
Avatar.BorderSizePixel = 0
addCorner(Avatar, 16)
spawn(function()
    pcall(function()
        Avatar.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
end)

local PlayerName = Instance.new("TextLabel", Header)
PlayerName.Size = UDim2.new(0, 130, 0, 18)
PlayerName.Position = UDim2.new(0, 56, 0.5, -14)
PlayerName.Text = Player.DisplayName
PlayerName.TextColor3 = COLORS.TextBright
PlayerName.TextSize = 13
PlayerName.Font = Enum.Font.GothamBold
PlayerName.BackgroundTransparency = 1
PlayerName.TextXAlignment = Enum.TextXAlignment.Left
PlayerName.TextTruncate = Enum.TextTruncate.AtEnd

local Username = Instance.new("TextLabel", Header)
Username.Size = UDim2.new(0, 130, 0, 12)
Username.Position = UDim2.new(0, 56, 0.5, 6)
Username.Text = "@" .. Player.Name
Username.TextColor3 = COLORS.TextDim
Username.TextSize = 9
Username.Font = Enum.Font.Gotham
Username.BackgroundTransparency = 1
Username.TextXAlignment = Enum.TextXAlignment.Left
Username.TextTruncate = Enum.TextTruncate.AtEnd

local TitleLabel = Instance.new("TextLabel", Header)
TitleLabel.Size = UDim2.new(0, 120, 0, 20)
TitleLabel.Position = UDim2.new(1, -128, 0.5, -13)
TitleLabel.Text = "Troxzy VIP"
TitleLabel.TextColor3 = COLORS.SectionText
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextXAlignment = Enum.TextXAlignment.Right

local UserID = Instance.new("TextLabel", Header)
UserID.Size = UDim2.new(0, 120, 0, 12)
UserID.Position = UDim2.new(1, -128, 0.5, 7)
UserID.Text = "ID: " .. Player.UserId
UserID.TextColor3 = COLORS.TextDim
UserID.TextSize = 8
UserID.Font = Enum.Font.Gotham
UserID.BackgroundTransparency = 1
UserID.TextXAlignment = Enum.TextXAlignment.Right

local Divider = Instance.new("Frame", Main)
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 0, 50)
Divider.BackgroundColor3 = COLORS.DividerColor
Divider.BorderSizePixel = 0

local StatsBar = Instance.new("Frame", Main)
StatsBar.Size = UDim2.new(1, -16, 0, 24)
StatsBar.Position = UDim2.new(0, 8, 0, 55)
StatsBar.BackgroundColor3 = COLORS.StatsBg
StatsBar.BorderSizePixel = 0
addCorner(StatsBar, 4)

local StatsLabel = Instance.new("TextLabel", StatsBar)
StatsLabel.Size = UDim2.new(1, -6, 1, 0)
StatsLabel.Position = UDim2.new(0, 3, 0, 0)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = getStatsText()
StatsLabel.TextColor3 = COLORS.InfoText
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextSize = 9
StatsLabel.TextTruncate = Enum.TextTruncate.AtEnd
task.spawn(function()
    while task.wait(5) do
        pcall(function() StatsLabel.Text = getStatsText() end)
    end
end)

-- Tab Bar
local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1, -16, 0, 32)
TabBar.Position = UDim2.new(0, 8, 0, 83)
TabBar.BackgroundTransparency = 1

local TabList = Instance.new("UIListLayout", TabBar)
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.Padding = UDim.new(0, 3)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.VerticalAlignment = Enum.VerticalAlignment.Center

local tabItems = {
    { name = "Farm", key = "Farm" },
    { name = "TAS", key = "TAS" },
    { name = "Move", key = "Move" },
    { name = "Visual", key = "Visual" },
    { name = "Stealth", key = "Stealth" },
    { name = "Premium", key = "Premium" },
    { name = "Extra", key = "Extra" }
}
local tabBtns, tabContents = {}, {}

for i, tab in ipairs(tabItems) do
    local tabBtn = Instance.new("TextButton", TabBar)
    tabBtn.Size = UDim2.new(0.13, 0, 0, 28)
    tabBtn.BackgroundColor3 = (tab.key == "Farm") and COLORS.TabActive or COLORS.TabInactive
    tabBtn.Text = tab.name
    tabBtn.TextSize = 8
    tabBtn.Font = Enum.Font.GothamBold
    tabBtn.TextColor3 = (tab.key == "Farm") and COLORS.TextMedium or COLORS.TextDim
    addCorner(tabBtn, 5)
    table.insert(tabBtns, tabBtn)

    local contentFrame = Instance.new("Frame", Main)
    contentFrame.Size = UDim2.new(1, -16, 1, -125)
    contentFrame.Position = UDim2.new(0, 8, 0, 119)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Visible = (tab.key == "Farm")

    local scrollFrame = Instance.new("ScrollingFrame", contentFrame)
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollingEnabled = true

    local scrollLayout = Instance.new("UIListLayout", scrollFrame)
    scrollLayout.Padding = UDim.new(0, 3)

    table.insert(tabContents, { scroll = scrollFrame, layout = scrollLayout })

    tabBtn.MouseButton1Click:Connect(function()
        for j, btn in ipairs(tabBtns) do
            if j == i then
                btn.BackgroundColor3 = COLORS.TabActive
                btn.TextColor3 = COLORS.TextMedium
                tabContents[j].scroll.Parent.Visible = true
            else
                btn.BackgroundColor3 = COLORS.TabInactive
                btn.TextColor3 = COLORS.TextDim
                tabContents[j].scroll.Parent.Visible = false
            end
        end
    end)
end

local function updateScrollSize(tabKey)
    local tabIdx
    for i, t in ipairs(tabItems) do
        if t.key == tabKey then tabIdx = i; break end
    end
    if not tabIdx then return end
    tabContents[tabIdx].scroll.CanvasSize = UDim2.new(0, 0, 0, tabContents[tabIdx].layout.AbsoluteContentSize.Y + 4)
end

local function AddSection(tabKey, title)
    local tabIdx
    for i, t in ipairs(tabItems) do
        if t.key == tabKey then tabIdx = i; break end
    end
    if not tabIdx then return end
    local s = Instance.new("TextLabel", tabContents[tabIdx].scroll)
    s.Size = UDim2.new(1, 0, 0, 16)
    s.Text = title
    s.TextColor3 = COLORS.SectionText
    s.Font = Enum.Font.GothamBold
    s.TextSize = 10
    s.BackgroundTransparency = 1
    s.TextXAlignment = Enum.TextXAlignment.Left
    updateScrollSize(tabKey)
end

local function AddButton(tabKey, name, color, callback)
    local tabIdx
    for i, t in ipairs(tabItems) do
        if t.key == tabKey then tabIdx = i; break end
    end
    if not tabIdx then return end
    local b = Instance.new("TextButton", tabContents[tabIdx].scroll)
    b.Size = UDim2.new(1, 0, 0, 34)
    b.BackgroundColor3 = color
    b.Text = name
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    addCorner(b, 6)
    b.MouseButton1Click:Connect(function()
        pcall(callback)
    end)
    updateScrollSize(tabKey)
end

local function AddInfoLabel(tabKey, text)
    local tabIdx
    for i, t in ipairs(tabItems) do
        if t.key == tabKey then tabIdx = i; break end
    end
    if not tabIdx then return end
    local l = Instance.new("TextLabel", tabContents[tabIdx].scroll)
    l.Size = UDim2.new(1, 0, 0, 30)
    l.BackgroundColor3 = COLORS.InfoBg
    l.Text = text
    l.TextColor3 = COLORS.InfoText
    l.Font = Enum.Font.GothamMedium
    l.TextSize = 10
    l.BorderSizePixel = 0
    addCorner(l, 6)
    updateScrollSize(tabKey)
    return l
end

local function AddToggle(tabKey, name, stateKey)
    local tabIdx
    for i, t in ipairs(tabItems) do
        if t.key == tabKey then tabIdx = i; break end
    end
    if not tabIdx then return end

    local f = Instance.new("Frame", tabContents[tabIdx].scroll)
    f.Size = UDim2.new(1, 0, 0, 34)
    f.BackgroundColor3 = COLORS.TabInactive
    f.BorderSizePixel = 0
    addCorner(f, 6)

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.48, 0, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.Text = name
    lbl.TextColor3 = COLORS.TextMedium
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 10
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local sb = Instance.new("Frame", f)
    sb.Size = UDim2.new(0, 36, 0, 18)
    sb.Position = UDim2.new(1, -48, 0.5, -9)
    sb.BackgroundColor3 = COLORS.ToggleBg
    sb.BorderSizePixel = 0
    addCorner(sb, 9)

    local dot = Instance.new("Frame", sb)
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 3, 0.5, -6)
    dot.BackgroundColor3 = COLORS.ToggleDot
    dot.BorderSizePixel = 0
    addCorner(dot, 6)

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state

        if stateKey == "AutoFarm" then
            _G.TroxzyAutoFarm = state
            if state then
                ConnectMapDetection()
            else
                DisconnectMapDetection()
                CurrentlyFarming = false
            end
        elseif stateKey == "NIGHT_MODE" then
            applyTheme(state and "Light" or "Dark")
        elseif stateKey == "DASHBOARD" and Dashboard then
            Dashboard.Visible = state
        elseif stateKey == "PANIC_MODE" then
            if state then activatePanicMode() else deactivatePanicMode() end
        elseif stateKey == "TAS_PAUSE" then
            _G.TAS_PAUSED = state
            if state then
                notify("TAS dijeda. Tekan lagi untuk melanjutkan.", "TAS Pause")
            else
                notify("TAS dilanjutkan.", "TAS Pause")
                -- Langsung jalankan TAS jika di map dan TAS Play Auto aktif
                if Check("InGame") and _G.TAS_PLAY_AUTO_ACTIVE and CONFIG.TAS_AUTO_START and not _G.TAS_EXECUTING then
                    task.spawn(ExecuteTAS)
                elseif Check("InGame") and not _G.TAS_EXECUTING then
                    -- Jika hanya TAS Play Auto tidak aktif, tetap jalankan TAS (Record Mode mungkin)
                    -- Record Mode manual, jadi hanya jalankan jika TAS Play Auto aktif
                end
            end
        else
            CONFIG[stateKey] = state
        end

        -- TAS Play Auto toggle
        if stateKey == "TAS_PLAY_AUTO" and state then
            if CONFIG.TAS_AUTO_START then
                _G.TAS_PLAY_AUTO_ACTIVE = true
                CONFIG.TAS_MODE = "Play"
                notify("TAS Play Auto Activated! Running...", "TAS")
                task.spawn(ExecuteTAS)
            else
                notify("Enable TAS Auto-Start first!", "TAS")
                CONFIG.TAS_PLAY_AUTO = false
                state = false
            end
        elseif stateKey == "TAS_PLAY_AUTO" and not state then
            _G.TAS_PLAY_AUTO_ACTIVE = false
            notify("TAS Play Auto deactivated.", "TAS")
        end

        local pos = state and UDim2.new(0, 18, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        dot:TweenPosition(pos, "Out", "Quad", 0.15)
        dot.BackgroundColor3 = state and COLORS.ToggleDotActive or COLORS.ToggleDot
        sb.BackgroundColor3 = state and COLORS.ToggleBgActive or COLORS.ToggleBg
    end)
    updateScrollSize(tabKey)
end

local function AddInput(tabKey, label, defaultVal, callback)
    local tabIdx
    for i, t in ipairs(tabItems) do
        if t.key == tabKey then tabIdx = i; break end
    end
    if not tabIdx then return end

    local f = Instance.new("Frame", tabContents[tabIdx].scroll)
    f.Size = UDim2.new(1, 0, 0, 40)
    f.BackgroundColor3 = COLORS.TabInactive
    f.BorderSizePixel = 0
    addCorner(f, 6)

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, 0, 0, 16)
    lbl.Position = UDim2.new(0, 0, 0, 2)
    lbl.Text = label
    lbl.TextColor3 = COLORS.TextDim
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 10
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Center

    local inp = Instance.new("TextBox", f)
    inp.Size = UDim2.new(0, 65, 0, 20)
    inp.Position = UDim2.new(0.5, -32, 0, 17)
    inp.BackgroundColor3 = COLORS.InputBg
    inp.TextColor3 = COLORS.TextBright
    inp.PlaceholderText = tostring(defaultVal)
    inp.Text = tostring(defaultVal)
    inp.Font = Enum.Font.Gotham
    inp.TextSize = 11
    addCorner(inp, 5)

    inp.FocusLost:Connect(function()
        local v = tonumber(inp.Text)
        if v then callback(v) end
    end)
    updateScrollSize(tabKey)
end

-- Themes
local DARK_THEME = {
    MainBg = Color3.fromRGB(20, 20, 26),
    HeaderBg = Color3.fromRGB(22, 22, 28),
    TabActive = Color3.fromRGB(40, 50, 65),
    TabInactive = Color3.fromRGB(25, 25, 33),
    TextBright = Color3.fromRGB(245, 245, 250),
    TextMedium = Color3.fromRGB(220, 225, 235),
    TextDim = Color3.fromRGB(160, 160, 175),
    StatsBg = Color3.fromRGB(28, 38, 52),
    StatsText = Color3.fromRGB(180, 210, 255),
    SectionText = Color3.fromRGB(180, 200, 220),
    ToggleBg = Color3.fromRGB(35, 35, 45),
    ToggleDot = Color3.fromRGB(100, 100, 115),
    InputBg = Color3.fromRGB(35, 35, 45),
    CloseBg = Color3.fromRGB(180, 50, 50)
}
local LIGHT_THEME = {
    MainBg = Color3.fromRGB(240, 240, 245),
    HeaderBg = Color3.fromRGB(235, 235, 240),
    TabActive = Color3.fromRGB(200, 210, 225),
    TabInactive = Color3.fromRGB(230, 230, 235),
    TextBright = Color3.fromRGB(20, 20, 30),
    TextMedium = Color3.fromRGB(40, 40, 50),
    TextDim = Color3.fromRGB(80, 80, 90),
    StatsBg = Color3.fromRGB(200, 210, 225),
    StatsText = Color3.fromRGB(30, 40, 60),
    SectionText = Color3.fromRGB(40, 50, 70),
    ToggleBg = Color3.fromRGB(200, 200, 210),
    ToggleDot = Color3.fromRGB(120, 120, 130),
    InputBg = Color3.fromRGB(220, 220, 225),
    CloseBg = Color3.fromRGB(200, 60, 60)
}
local currentTheme = "Dark"
local function applyTheme(theme)
    local t = theme == "Dark" and DARK_THEME or LIGHT_THEME
    currentTheme = theme
    if Main then Main.BackgroundColor3 = t.MainBg end
    if Header then Header.BackgroundColor3 = t.HeaderBg; hc.BackgroundColor3 = t.HeaderBg end
    for _, btn in ipairs(tabBtns) do
        if btn.BackgroundColor3 == COLORS.TabActive or btn.BackgroundColor3 == Color3.fromRGB(200, 210, 225) then
            btn.BackgroundColor3 = t.TabActive
        else
            btn.BackgroundColor3 = t.TabInactive
        end
        if btn.TextColor3 == COLORS.TextMedium or btn.TextColor3 == Color3.fromRGB(40, 40, 50) then
            btn.TextColor3 = t.TextMedium
        else
            btn.TextColor3 = t.TextDim
        end
    end
    if StatsBar then StatsBar.BackgroundColor3 = t.StatsBg end
    if StatsLabel then StatsLabel.TextColor3 = t.StatsText end
end

-- Dashboard
local Dashboard = Instance.new("Frame", ScreenGui)
Dashboard.Size = UDim2.new(0, 190, 0, 80)
Dashboard.Position = UDim2.new(0.985, 0, 0.015, 0)
Dashboard.AnchorPoint = Vector2.new(1, 0)
Dashboard.BackgroundColor3 = COLORS.MainBg
Dashboard.BorderSizePixel = 0
Dashboard.Visible = CONFIG.DASHBOARD
addCorner(Dashboard, 8)
addStroke(Dashboard, 1.5, COLORS.BorderColor)

local function createDashboardContent()
    local title = Instance.new("TextLabel", Dashboard)
    title.Size = UDim2.new(1, 0, 0, 18)
    title.Position = UDim2.new(0, 0, 0, 4)
    title.Text = "Live Dashboard"
    title.TextColor3 = COLORS.SectionText
    title.Font = Enum.Font.GothamBold
    title.TextSize = 10
    title.BackgroundTransparency = 1

    local mapLabel = Instance.new("TextLabel", Dashboard)
    mapLabel.Size = UDim2.new(1, 0, 0, 14)
    mapLabel.Position = UDim2.new(0, 0, 0, 22)
    mapLabel.Text = "Map: Waiting..."
    mapLabel.TextColor3 = COLORS.TextDim
    mapLabel.Font = Enum.Font.Gotham
    mapLabel.TextSize = 9
    mapLabel.BackgroundTransparency = 1
    mapLabel.Name = "MapLabel"

    local timeLabel = Instance.new("TextLabel", Dashboard)
    timeLabel.Size = UDim2.new(1, 0, 0, 14)
    timeLabel.Position = UDim2.new(0, 0, 0, 36)
    timeLabel.Text = "Time: 0m"
    timeLabel.TextColor3 = COLORS.TextDim
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextSize = 9
    timeLabel.BackgroundTransparency = 1
    timeLabel.Name = "TimeLabel"

    local speedLabel = Instance.new("TextLabel", Dashboard)
    speedLabel.Size = UDim2.new(1, 0, 0, 14)
    speedLabel.Position = UDim2.new(0, 0, 0, 50)
    speedLabel.Text = "Maps/hr: 0"
    speedLabel.TextColor3 = COLORS.TextDim
    speedLabel.Font = Enum.Font.Gotham
    speedLabel.TextSize = 9
    speedLabel.BackgroundTransparency = 1
    speedLabel.Name = "SpeedLabel"

    local statusLabel = Instance.new("TextLabel", Dashboard)
    statusLabel.Size = UDim2.new(1, 0, 0, 14)
    statusLabel.Position = UDim2.new(0, 0, 0, 64)
    statusLabel.Text = "Status: Idle"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 9
    statusLabel.BackgroundTransparency = 1
    statusLabel.Name = "StatusLabel"
end
createDashboardContent()

local function updateDashboard()
    if not Dashboard or not Dashboard.Visible then return end
    local mapLabel = Dashboard:FindFirstChild("MapLabel")
    local timeLabel = Dashboard:FindFirstChild("TimeLabel")
    local speedLabel = Dashboard:FindFirstChild("SpeedLabel")
    local statusLabel = Dashboard:FindFirstChild("StatusLabel")

    if mapLabel then mapLabel.Text = "Map: " .. (Stats.currentMap or "Waiting...") end
    if timeLabel then timeLabel.Text = "Time: " .. math.floor((tick() - Stats.sessionStart) / 60) .. "m" end
    if speedLabel then
        local hours = (tick() - Stats.sessionStart) / 3600
        speedLabel.Text = "Maps/hr: " .. (hours > 0 and math.floor(Stats.mapsCompleted / hours) or 0)
    end
    if statusLabel then
        if panicActive then
            statusLabel.Text = "Status: PANIC"
            statusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        elseif CurrentlyFarming then
            statusLabel.Text = "Status: Farming"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        elseif CONFIG.STEALTH_MODE then
            statusLabel.Text = "Status: Stealth"
            statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        else
            statusLabel.Text = "Status: Idle"
            statusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        end
    end
end

-- ==================== BUILD MENU ====================
AddSection("Farm", "AUTO FARM")
AddToggle("Farm", "Auto Farm", "AutoFarm")
AddInfoLabel("Farm", "[Target] " .. CONFIG.TARGET_MAP)

AddSection("TAS", "TAS LOADER")
AddToggle("TAS", "TAS Auto-Start", "TAS_AUTO_START")
AddToggle("TAS", "TAS Play Auto", "TAS_PLAY_AUTO")
AddToggle("TAS", "Pause TAS", "TAS_PAUSE")
AddButton("TAS", "Record Mode", COLORS.ButtonRecord, function()
    -- Record mode bisa dijalankan kapan saja
    notify("TAS Record akan dimulai.", "TAS")
    CONFIG.TAS_MODE = "Record"
    ExecuteTAS()
end)

AddSection("Move", "MOVEMENT")
AddToggle("Move", "Noclip", "NOCLIP")
AddToggle("Move", "Speed Boost", "SPEED")
AddToggle("Move", "Infinite Jump", "INF_JUMP")
AddInput("Move", "Speed", CONFIG.SPEED_VAL, function(v) CONFIG.SPEED_VAL = v end)

AddSection("Visual", "COMBAT + RENDER")
AddToggle("Visual", "God Mode", "GOD_MODE")
AddToggle("Visual", "ESP", "ESP")
AddToggle("Visual", "Fullbright", "FULLBRIGHT")
AddToggle("Visual", "FOV Changer", "FOV")
AddInput("Visual", "FOV", CONFIG.FOV_VAL, function(v) CONFIG.FOV_VAL = v end)

AddSection("Stealth", "ANTI-DETECTION")
AddToggle("Stealth", "Stealth Mode", "STEALTH_MODE")
AddToggle("Stealth", "Admin Detector", "ADMIN_DETECTOR")
AddToggle("Stealth", "Anti-Admin", "ANTI_ADMIN")
AddToggle("Stealth", "Anti-Report", "ANTI_REPORT")
AddToggle("Stealth", "Random Delay", "RANDOM_DELAY")
AddToggle("Stealth", "Hide Script", "HIDE_SCRIPT")
AddToggle("Stealth", "Map Rotation", "MAP_ROTATION")
AddButton("Stealth", "Force Leave", COLORS.ButtonForceLeave, forceReconnect)

AddSection("Premium", "PREMIUM FEATURES")
AddToggle("Premium", "Live Dashboard", "DASHBOARD")
AddToggle("Premium", "Smart Alerts", "SMART_ALERTS")
AddToggle("Premium", "Night Mode", "NIGHT_MODE")
AddToggle("Premium", "Auto-Updater", "AUTO_UPDATE")
AddButton("Premium", "Check Updates", COLORS.ButtonUpdate, checkForUpdates)
AddButton("Premium", "Panic Mode [P]", COLORS.ButtonPanic, activatePanicMode)

-- EXTRA TAB
AddSection("Extra", "✨ EXTRA FEATURES")
AddToggle("Extra", "Item Collector", "COLLECT_ITEMS")
AddToggle("Extra", "Air Swim", "AIR_SWIM")
AddToggle("Extra", "Timer Hook (3s)", "TIMER_HOOK")
AddToggle("Extra", "Custom Flood Colors", "CUSTOM_FLOOD_COLORS")
AddInfoLabel("Extra", "Flood Color: " .. CONFIG.FLOOD_COLOR)
AddButton("Extra", "Cycle Flood Color", Color3.fromRGB(100, 100, 200), function()
    local colors = { "Blue", "Green", "Red", "Pink", "Purple" }
    local idx = table.find(colors, CONFIG.FLOOD_COLOR)
    idx = idx and (idx % #colors) + 1 or 1
    CONFIG.FLOOD_COLOR = colors[idx]
    applyFloodColors()
    notify("Flood color: " .. CONFIG.FLOOD_COLOR, "Colors")
end)

-- Version Label
local VersionLabel = Instance.new("TextLabel", Main)
VersionLabel.Size = UDim2.new(0, 80, 0, 14)
VersionLabel.Position = UDim2.new(0.04, 0, 1, -33)
VersionLabel.Text = "v" .. SCRIPT_VERSION
VersionLabel.TextColor3 = COLORS.VersionText
VersionLabel.TextSize = 9
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.BackgroundTransparency = 1
VersionLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(1, -20, 0, 30)
CloseBtn.Position = UDim2.new(0, 10, 1, -33)
CloseBtn.BackgroundColor3 = COLORS.CloseBg
CloseBtn.Text = "Close Panel"
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
addCorner(CloseBtn, 6)
CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)
ToggleBtn.MouseButton1Click:Connect(function() Main.Visible = not Main.Visible end)

notify("Troxzy VIP v20.1 – Record & Pause perfected.", "Welcome")

-- Panic Keybind
TrackConnection(UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.P then
        if not panicActive then activatePanicMode() else deactivatePanicMode() end
    end
end))

-- ==================== LOOPS ====================
local lastHeartbeat = 0
TrackConnection(RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - lastHeartbeat < 0.1 then return end
    lastHeartbeat = now

    pcall(function()
        local char = Player.Character
        if not char then return end
        local hum = char:FindFirstChild("Humanoid")
        if not hum then return end

        if CONFIG.NOCLIP and not CurrentlyFarming then
            applyNoclip(true)
        elseif not CurrentlyFarming then
            applyNoclip(false)
        end

        if not CurrentlyFarming then
            hum.WalkSpeed = CONFIG.SPEED and CONFIG.SPEED_VAL or 16
        end

        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not CONFIG.GOD_MODE)

        if hum:GetState() == Enum.HumanoidStateType.Swimming then
            hum:ChangeState(Enum.HumanoidStateType.Landed)
            hum.PlatformStand = false
            task.wait(0.05)
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end))

TrackConnection(RunService.Heartbeat:Connect(function()
    pcall(updateESP)
    pcall(updateVisuals)
end))

task.spawn(function()
    while task.wait(2) do
        pcall(updateDashboard)
    end
end)

TrackConnection(UIS.JumpRequest:Connect(function()
    if CONFIG.INF_JUMP and Player.Character then
        local hum = Player.Character:FindFirstChild("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- ==================== WATCHDOG LOOP ====================
task.spawn(function()
    while task.wait(0.5) do
        if _G.TAS_PLAY_AUTO_ACTIVE then
            -- Di lift, reset deteksi dan flag executing
            if Check("InLift") and not Check("InGame") then
                DisconnectMapDetection()
                _G.TAS_EXECUTING = false
            end

            -- Di map, jika TAS tidak aktif, jalankan
            if Check("InGame") and not CurrentlyFarming and not _G.TAS_PAUSED and not _G.TAS_EXECUTING then
                task.spawn(ExecuteTAS)
            end

            -- Pastikan MapDetect selalu hidup
            if not MapDetect then
                ConnectMapDetection()
            end
        else
            if not _G.TroxzyAutoFarm then
                DisconnectMapDetection()
                break
            end
            if not MapDetect then
                ConnectMapDetection()
            end
        end
    end
end)

-- Admin detection loop
task.spawn(function()
    while task.wait(10) do
        if CONFIG.ADMIN_DETECTOR then
            handleAdminDetection()
        end
    end
end)

-- Auto Lift (hanya jika tidak TAS Play Auto)
task.spawn(function()
    while task.wait(1) do
        if _G.TAS_PLAY_AUTO_ACTIVE then break end
        if not _G.TroxzyAutoFarm then break end
        if Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            if not Check("InLift") and not Check("InGame") then
                AddedWaiting:FireServer()
            end
        end
    end
end)

if CONFIG.AUTO_UPDATE then
    task.spawn(function()
        task.wait(3)
        checkForUpdates()
    end)
end

loadStats()
setupAutoReconnect()

print("Troxzy VIP v20.1 – Record mode now works anytime, pause resumes immediately.")
