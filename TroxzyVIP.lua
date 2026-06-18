-- ============================================
-- TROXZY VIP v20.7 ULTIMATE (SPECTATOR DETECTOR)
-- 🔥 FIXED: Panic Mode Error & WalkSpeed Conflict
-- ============================================

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(2)

print("TROXZY: Script started")

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
if not Player then warn("Player nil"); return end
if not Player.Character then Player.CharacterAdded:Wait() end
task.wait(1)

local Camera = Workspace.CurrentCamera
local IS_MOBILE = UIS.TouchEnabled

-- Global state
_G.TroxzyAutoFarm = false

-- Variabel Utama
local CurrentlyFarming = false
local mapCompleted = false
local Escaped = false
local Main, ToggleBtn, MapDetect = nil, nil, nil
local TimerHookActive = false
local TimerHookStart = 0

-- TAS State
local TAS_COROUTINE = nil
local TAS_RUNNING = false
local TAS_STATUS_LABEL = nil

-- Auto Queue State
local AUTO_QUEUE_ENABLED = false
local AutoQueueListener = nil

-- 60 FPS Movement
local liftTarget = nil
local moveToLift = false

-- Admin Detector Pro
local DetectedAdmins = {}
local lastAdminCount = 0

-- UI State
local isMinimized = false

-- Cleanup UI Lama
pcall(function()
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui.Name:find("TROXZY_VIP") then gui:Destroy() end
    end
    for _, gui in pairs(Player.PlayerGui:GetChildren()) do
        if gui.Name:find("TROXZY_VIP") then gui:Destroy() end
    end
end)

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

-- ==================== UTILITY & THEME ====================
local function addCorner(obj, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = obj
end

local function addStroke(obj, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(255,255,255)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.85
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = obj
    return s
end

local function Tween(obj, props, time)
    if not obj then return end
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
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

local SOUND_IDS = { success = 9120386436, alert = 9116456845, error = 9116456845 }
local function playSound(id)
    pcall(function()
        local s = Instance.new("Sound", Workspace)
        s.SoundId = "rbxassetid://" .. id
        s.Volume = 0.5
        s:Play()
        game.Debris:AddItem(s, 3)
    end)
end

local ThemeObjects = {}
local function RegisterThemeObject(obj, property, darkValue, lightValue)
    table.insert(ThemeObjects, { obj = obj, property = property, dark = darkValue, light = lightValue })
end

local currentTheme = "Dark"
local DARK_THEME = {
    MainBg = Color3.fromRGB(17, 17, 26), HeaderBg = Color3.fromRGB(24, 24, 36),
    Border = Color3.fromRGB(255, 255, 255), Accent = Color3.fromRGB(99, 102, 241),
    TabActive = Color3.fromRGB(45, 45, 65), TabInactive = Color3.fromRGB(24, 24, 36),
    TextBright = Color3.fromRGB(245, 245, 250), TextMedium = Color3.fromRGB(180, 180, 200),
    TextDim = Color3.fromRGB(120, 120, 140), StatsBg = Color3.fromRGB(24, 24, 36),
    StatsText = Color3.fromRGB(150, 180, 255), SectionText = Color3.fromRGB(150, 150, 170),
    ToggleBg = Color3.fromRGB(40, 40, 55), ToggleDot = Color3.fromRGB(120, 120, 140),
    InputBg = Color3.fromRGB(30, 30, 45), InfoBg = Color3.fromRGB(35, 35, 50),
    InfoText = Color3.fromRGB(200, 220, 255), ButtonRecord = Color3.fromRGB(180, 40, 40),
    ButtonPanic = Color3.fromRGB(255, 80, 80), ButtonForceLeave = Color3.fromRGB(180, 50, 50)
}
local LIGHT_THEME = {
    MainBg = Color3.fromRGB(245, 245, 250), HeaderBg = Color3.fromRGB(230, 230, 240),
    Border = Color3.fromRGB(0, 0, 0), Accent = Color3.fromRGB(79, 70, 229),
    TabActive = Color3.fromRGB(210, 210, 230), TabInactive = Color3.fromRGB(230, 230, 240),
    TextBright = Color3.fromRGB(20, 20, 30), TextMedium = Color3.fromRGB(60, 60, 80),
    TextDim = Color3.fromRGB(100, 100, 120), StatsBg = Color3.fromRGB(220, 220, 235),
    StatsText = Color3.fromRGB(30, 50, 100), SectionText = Color3.fromRGB(80, 80, 100),
    ToggleBg = Color3.fromRGB(200, 200, 220), ToggleDot = Color3.fromRGB(150, 150, 170),
    InputBg = Color3.fromRGB(220, 220, 235), InfoBg = Color3.fromRGB(210, 210, 230),
    InfoText = Color3.fromRGB(20, 40, 80), ButtonRecord = Color3.fromRGB(200, 50, 50),
    ButtonPanic = Color3.fromRGB(255, 90, 90), ButtonForceLeave = Color3.fromRGB(190, 60, 60)
}

local function applyTheme(theme)
    currentTheme = theme
    local t = (theme == "Dark") and DARK_THEME or LIGHT_THEME
    for _, entry in ipairs(ThemeObjects) do
        if entry.obj and entry.obj.Parent then
            Tween(entry.obj, { [entry.property] = (theme == "Dark") and entry.dark or entry.light })
        end
    end
    if _G.ToggleStates then
        for _, toggle in pairs(_G.ToggleStates) do toggle.SetState(toggle.state) end
    end
end

-- ==================== CONFIG & STATS ====================
local CONFIG = {
    TARGET_MAP = "Sandswept Ruins", TARGET_DIFFICULTY = "Crazy",
    TAS_MODE = "Play", TAS_AUTO_START = false,
    NOCLIP = false, GOD_MODE = false, SPEED = false, INF_JUMP = false, ESP = false, FULLBRIGHT = false, FOV = false,
    SPEED_VAL = 20, FOV_VAL = 90,
    BLACKLIST_ENABLED = true, AUTO_RECONNECT = true, STEALTH_MODE = true, ADMIN_DETECTOR = true, AUTO_LEAVE_ADMIN = true,
    RANDOM_DELAY = true, HIDE_SCRIPT = true, MAP_ROTATION = false, NIGHT_MODE = false, DASHBOARD = true, SMART_ALERTS = true,
    PANIC_MODE = false, COLLECT_ITEMS = true, AIR_SWIM = true, TIMER_HOOK = false, ANTI_REPORT = false, ANTI_ADMIN = false, AUTO_UPDATE = false,
    CUSTOM_FLOOD_COLORS = false, FLOOD_COLOR = "Blue"
}

local Stats = {
    mapsCompleted = 0, totalTime = 0, sessionStart = os.clock(),
    difficultyStats = { Easy = 0, Normal = 0, Hard = 0, Insane = 0, Crazy = 0, ["Crazy+"] = 0 },
    blacklistedSkipped = 0, adminDetected = 0, adminLeft = 0, currentMap = ""
}

local function loadStats()
    pcall(function()
        if isfile("Troxzy_Stats.json") then
            local d = HttpService:JSONDecode(readfile("Troxzy_Stats.json"))
            for k, v in pairs(d) do if Stats[k] ~= nil then Stats[k] = v end end
        end
    end)
    Stats.sessionStart = os.clock()
end

local function saveStats()
    pcall(function()
        Stats.totalTime = Stats.totalTime + (os.clock() - Stats.sessionStart)
        writefile("Troxzy_Stats.json", HttpService:JSONEncode(Stats))
        Stats.sessionStart = os.clock()
    end)
end

local function updateStats(d)
    Stats.mapsCompleted = Stats.mapsCompleted + 1
    if d and Stats.difficultyStats[d] then
        Stats.difficultyStats[d] = Stats.difficultyStats[d] + 1
    end
end

local function getStatsText()
    return string.format("Maps: %d  |  Adm: %d", Stats.mapsCompleted, Stats.adminLeft)
end

-- ==================== CORE FUNCTIONS ====================
local MapBlacklist = { "Blue Moon", "Poisonous Chasm", "Rustic Jungle", "Luminance" }
local function isMapBlacklisted(n)
    if not CONFIG.BLACKLIST_ENABLED then return false end
    for _, bl in ipairs(MapBlacklist) do if n:lower():find(bl:lower()) then return true end end
    return false
end

local MapRotation = { "Sandswept Ruins", "Axiom", "Castle Tides", "Lost Woods", "Nimble Valley", "Mayan Remnants", "Sulphureous Sea", "Lava Tower", "Dark Sci-Forest", "Sedimentary Temple", "Abandoned Facility", "Sinking Ship", "Familiar Ruins" }
local rotationIndex = 1
local function rotateMap()
    if not CONFIG.MAP_ROTATION then return end
    CONFIG.TARGET_MAP = MapRotation[rotationIndex]
    rotationIndex = rotationIndex + 1
    if rotationIndex > #MapRotation then rotationIndex = 1 end
end

local adminKeywords = { ["admin"] = true, ["mod"] = true, ["owner"] = true, ["dev"] = true, ["helper"] = true, ["staff"] = true }
local function isAdmin(p)
    if not CONFIG.ADMIN_DETECTOR then return false end
    local name = p.Name:lower(); local display = p.DisplayName:lower()
    for kw, _ in pairs(adminKeywords) do if name:find(kw) or display:find(kw) then return true end end
    return false
end

local function getAdminPlayers()
    local admins = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and isAdmin(p) then
            table.insert(admins, p)
        end
    end
    return admins
end

local function getSpectators()
    local specs = {}
    if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return specs end
    local myRoot = Player.Character.HumanoidRootPart
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character.Humanoid
            if hum.Health <= 0 then
                local theirRoot = p.Character.HumanoidRootPart
                local dist = (myRoot.Position - theirRoot.Position).Magnitude
                if dist < 50 then
                    table.insert(specs, p)
                end
            end
        end
    end
    return specs
end

local function detectAdmins()
    return #getAdminPlayers() > 0
end

local function blockAdminRemotes()
    local RemoteFolder = ReplicatedStorage:FindFirstChild("Remote")
    if not RemoteFolder then return end
    local dangerousKeywords = { "kick", "ban", "punish", "jail", "teleport", "freeze", "spectate", "kill", "crash" }
    for _, remote in ipairs(RemoteFolder:GetChildren()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local lowerName = remote.Name:lower()
            for _, kw in ipairs(dangerousKeywords) do
                if lowerName:find(kw) then remote.OnClientEvent:Connect(function() end); break end
            end
        end
    end
end

local lastAdminAlert = 0
local function handleAdminDetection()
    if not CONFIG.ADMIN_DETECTOR then return end
    local admins = getAdminPlayers()
    local count = #admins
    if count > lastAdminCount then
        local now = os.clock()
        if now - lastAdminAlert < 10 then return end
        lastAdminAlert = now
        Stats.adminDetected = Stats.adminDetected + (count - lastAdminCount)
        notify("Admin(s) detected! Protection active.", "Anti-Admin")
        if CONFIG.ANTI_ADMIN then blockAdminRemotes() end
        if CONFIG.SMART_ALERTS then playSound(SOUND_IDS.alert) end
    end
    lastAdminCount = count
end

if CONFIG.ANTI_REPORT then pcall(function() Players.ReportAbuse = function() end end) end

local floodColorMap = { Blue = Color3.fromRGB(0, 150, 255), Green = Color3.fromRGB(0, 255, 100), Red = Color3.fromRGB(255, 50, 50), Pink = Color3.fromRGB(255, 100, 200), Purple = Color3.fromRGB(150, 50, 255) }
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
    local now = os.clock()
    if now - lastFloodColorUpdate < 0.5 then return end
    lastFloodColorUpdate = now
    applyFloodColors()
end

local function stealthDelay() return CONFIG.STEALTH_MODE and math.random(10, 50) / 100 or 0.05 end
local function stealthOffset() return CONFIG.STEALTH_MODE and Vector3.new(math.random(-50,50)/100, math.random(-30,30)/100, math.random(-50,50)/100) or Vector3.new(math.random(), math.random(), math.random()) end

local buttonCount = 0
local function shouldTakeBreak()
    if not CONFIG.RANDOM_DELAY then return false end
    buttonCount = buttonCount + 1
    if buttonCount >= math.random(3,8) then buttonCount = 0; return true end
    return false
end

local function isPlayerNearby()
    if not CONFIG.HIDE_SCRIPT then return false end
    local char = Player.Character; if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return false end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if (root.Position - p.Character.HumanoidRootPart.Position).Magnitude < 20 then return true end
        end
    end
    return false
end

local function attemptReconnect()
    saveStats(); task.wait(3)
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end)
    task.wait(2); pcall(function() TeleportService:Teleport(game.PlaceId) end)
end

local function setupAutoReconnect()
    if not CONFIG.AUTO_RECONNECT then return end
    TrackConnection(Player:GetPropertyChangedSignal("Parent"):Connect(function() if not Player.Parent then attemptReconnect() end end))
    TrackConnection(TeleportService.TeleportInitFailed:Connect(attemptReconnect))
    TrackConnection(Player.OnTeleport:Connect(saveStats))
end

local function forceReconnect()
    saveStats(); task.wait(1)
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end)
    task.wait(2); pcall(function() TeleportService:Teleport(game.PlaceId) end)
end

local DIFFICULTY_RANKS = { ["Easy"] = 1, ["Normal"] = 2, ["Hard"] = 3, ["Insane"] = 4, ["Crazy"] = 5, ["Crazy+"] = 6 }
local function DisconnectMapDetection()
    if MapDetect then MapDetect:Disconnect(); MapDetect = nil end
end

-- ==================== TAS ENGINE ====================
local function ExecuteTAS()
    if not CONFIG.TAS_AUTO_START then notify("TAS Auto-Start is OFF. Enable it first.", "TAS"); return end
    if TAS_RUNNING then
        if TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE); TAS_COROUTINE = nil end
        TAS_RUNNING = false; task.wait(0.2)
    end

    _G.TroxzyAutoFarm = false
    CurrentlyFarming = false
    DisconnectMapDetection()

    local url = CONFIG.TAS_MODE == "Record"
        and "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TAS/CREATOR/creator.luau"
        or "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TAS/PLAYER/newtasplayer.luau"

    local success, scriptContent = pcall(function() return game:HttpGet(url) end)
    if not success then notify("Download failed.", "Error"); return end

    local func, compileErr = loadstring(scriptContent)
    if not func then notify("Compile error.", "Error"); return end

    TAS_COROUTINE = coroutine.create(function()
        TAS_RUNNING = true
        local execOk, execErr = pcall(func)
        TAS_RUNNING = false
        TAS_COROUTINE = nil

        if AUTO_QUEUE_ENABLED then
            mapCompleted = true
        end

        if not execOk then notify("TAS runtime error: " .. tostring(execErr), "Error") else notify("TAS finished!", "Success") end
        if TAS_STATUS_LABEL then TAS_STATUS_LABEL.Text = "Status: ▶ READY" end
    end)

    coroutine.resume(TAS_COROUTINE)
    if TAS_STATUS_LABEL then TAS_STATUS_LABEL.Text = "Status: ▶ RUNNING" end
end

local function Check(flag)
    local char = Player.Character; if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return false end
    if flag == "InLift" then return hrp.Position.X < 50 and hrp.Position.Z > 70
    elseif flag == "InGame" then return hrp.Position.X > 50 end
    return false
end

-- ==================== GAME DETECTION & REMOTE ====================
local Multiplayer = Workspace:WaitForChild("Multiplayer")
local RemoteFolder = ReplicatedStorage:WaitForChild("Remote")
local ReqPasskey = RemoteFolder:WaitForChild("ReqPasskey")
local NewMapVote = RemoteFolder:WaitForChild("NewMapVote")
local UpdMapVote = RemoteFolder:WaitForChild("UpdMapVote")
local AddedWaiting = RemoteFolder:WaitForChild("AddedWaiting")
local AlertRemote = RemoteFolder:WaitForChild("Alert")

TrackConnection(AlertRemote.OnClientEvent:Connect(function(msg) if type(msg) == "string" and msg:lower():match("escaped") then Escaped = true end end))
TrackConnection(Player.Idled:Connect(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end))

local function GetRandomPoint(part) local s = part.Size; return part.CFrame * CFrame.new((math.random()-0.5) * s.X * 0.9, (math.random()-0.5) * s.Y * 0.9, (math.random()-0.5) * s.Z * 0.9) end
local function GetDifficulty() local ok, res = pcall(function() local diffLabel = Workspace.Lobby.GameInfo.SurfaceGui.Frame.Difficulty.Difficulty; return string.gsub(string.split(diffLabel.Text, ":")[1], "^%s*(.-)%s*$", "%1") end); if ok and res then return DIFFICULTY_RANKS[res] or 0, res end; return 0, "Unknown" end
local function isRandStr(str) if #str == 0 then return false end; for i = 1, #str do if str:sub(i,i):lower() == str:sub(i,i) then return false end end; return true end

-- ==================== 60 FPS AUTO WALK TO LIFT ====================
local function findLiftPosition()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("lift") or name:find("elevator") or name:find("lobby") then
                return obj.Position
            end
        end
    end
    return Vector3.new(25, 10, 85)
end

TrackConnection(RunService.Heartbeat:Connect(function()
    if moveToLift and AUTO_QUEUE_ENABLED and not panicActive and not TAS_RUNNING then
        local char = Player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if char and hum and hrp and hum.Health > 0 then
            if not Check("InGame") and not Check("InLift") then
                if liftTarget then
                    local dir = (liftTarget - hrp.Position)
                    if dir.Magnitude > 2 then
                        hum:MoveTo(liftTarget)
                        -- HAPUS: hum.WalkSpeed = 20 agar tidak konflik dengan fitur Speed
                    else
                        pcall(function() AddedWaiting:FireServer() end)
                        moveToLift = false
                    end
                end
            elseif Check("InLift") then
                pcall(function() AddedWaiting:FireServer() end)
                moveToLift = false
            end
        end
    end
end))

-- ==================== EVENT-DRIVEN AUTO QUEUE ====================
local function StartAutoQueue()
    if AutoQueueListener then
        AutoQueueListener:Disconnect()
        AutoQueueListener = nil
    end

    moveToLift = false
    mapCompleted = false

    AutoQueueListener = Multiplayer.ChildAdded:Connect(function(newMap)
        if not AUTO_QUEUE_ENABLED or panicActive then return end
        repeat task.wait() until Check("InGame")
        mapCompleted = false
        if not TAS_RUNNING then
            _G.TroxzyAutoFarm = false
            CurrentlyFarming = false
            DisconnectMapDetection()
            task.spawn(ExecuteTAS)
        end
    end)
    TrackConnection(AutoQueueListener)
    notify("Auto Queue 60FPS Active + Walk to Lift", "Queue")
end

local function StopAutoQueue()
    if AutoQueueListener then
        AutoQueueListener:Disconnect()
        AutoQueueListener = nil
    end
    moveToLift = false
    if TAS_RUNNING and TAS_COROUTINE then
        pcall(coroutine.close, TAS_COROUTINE)
        TAS_COROUTINE = nil
        TAS_RUNNING = false
    end
    notify("Auto Queue dihentikan.", "Queue")
end

task.spawn(function()
    while task.wait(0.5) do
        if AUTO_QUEUE_ENABLED and not panicActive then
            local char = Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and not Check("InGame") and not Check("InLift") and not TAS_RUNNING then
                moveToLift = true
                liftTarget = findLiftPosition()
            else
                moveToLift = false
            end
        end
    end
end)

TrackConnection(Player.CharacterAdded:Connect(function()
    if not Player.Character then Player.CharacterAdded:Wait() end
    refreshNoclip()
    ncActive = false
    if not Check("InGame") then
        mapCompleted = false
    end
end))

-- ==================== NOCLIP, VISUALS, & DEATH FIX ====================
local ncCache, ncActive = {}, false
local function refreshNoclip() ncCache = {}; local char = Player.Character; if char then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then table.insert(ncCache, v) end end end end
local function applyNoclip(state) if state == ncActive then return end; ncActive = state; for _, v in ipairs(ncCache) do if v and v.Parent then v.CanCollide = not state end end end

refreshNoclip()

-- ==================== ESP FIXED ====================
local espCache = {}
local lastESPUpdate = 0
local function updateESP()
    if os.clock() - lastESPUpdate < 0.1 then return end
    lastESPUpdate = os.clock()

    if not CONFIG.ESP then
        for _, hl in pairs(espCache) do pcall(function() hl:Destroy() end) end
        espCache = {}
        return
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            if plr.Character and not espCache[plr] then
                local hl = Instance.new("Highlight")
                hl.FillColor = Color3.fromRGB(160, 180, 200)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.Parent = plr.Character
                espCache[plr] = hl
            elseif not plr.Character and espCache[plr] then
                pcall(function() espCache[plr]:Destroy() end)
                espCache[plr] = nil
            end
        end
    end

    for plr, hl in pairs(espCache) do
        if not plr.Parent or (plr.Character and hl.Parent ~= plr.Character) then
            pcall(function() hl:Destroy() end)
            espCache[plr] = nil
        end
    end
end

local function clearESPCache() for _, hl in pairs(espCache) do pcall(function() hl:Destroy() end) end; espCache = {} end

TrackConnection(Players.PlayerAdded:Connect(function(plr)
    if CONFIG.ESP and plr ~= Player then
        local chr = plr.Character or plr.CharacterAdded:Wait()
        if chr and not espCache[plr] then
            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(160, 180, 200)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Parent = chr
            espCache[plr] = hl
        end
    end
end))

TrackConnection(Players.PlayerRemoving:Connect(function(plr)
    if espCache[plr] then
        pcall(function() espCache[plr]:Destroy() end)
        espCache[plr] = nil
    end
end))

-- ==================== PRE-DEKLARASI UI FUNCTIONS & PANIC MODE ====================
local panicActive = false; _G.ToggleStates = {}
local minimizeUI, maximizeUI -- Pre-deklarasi agar bisa dipanggil oleh Panic Mode

local function activatePanicMode() 
    panicActive = true; _G.TroxzyAutoFarm = false; CurrentlyFarming = false; 
    DisconnectMapDetection(); StopAutoQueue(); applyNoclip(false); 
    pcall(function() Player.Character.Humanoid.WalkSpeed = 16 end); 
    minimizeUI(true); 
    clearESPCache(); notify("PANIC MODE ACTIVATED!", "Emergency"); 
    if _G.ToggleStates["PANIC_MODE"] then _G.ToggleStates["PANIC_MODE"].SetState(true) end 
end

local function deactivatePanicMode() 
    panicActive = false; _G.TroxzyAutoFarm = false; CurrentlyFarming = false; 
    pcall(function() Player.Character.Humanoid.WalkSpeed = 16 end); 
    applyNoclip(false); 
    maximizeUI(); 
    if _G.ToggleStates["PANIC_MODE"] then _G.ToggleStates["PANIC_MODE"].SetState(false) end 
end

local lastVisUpdate, lastFOV = 0, 70
local function updateVisuals() if os.clock() - lastVisUpdate < 0.5 then return end; lastVisUpdate = os.clock(); Lighting.Brightness = CONFIG.FULLBRIGHT and 2 or 1; Lighting.FogEnd = CONFIG.FULLBRIGHT and 99999 or 10000; if Camera then local tfov = CONFIG.FOV and CONFIG.FOV_VAL or 70; if tfov ~= lastFOV then Tween(Camera, {FieldOfView = tfov}); lastFOV = tfov end end; periodicFloodColorUpdate() end

-- ==================== MANUAL AUTO FARM LOGIC ====================
local function OnMapLoad(map)
    clearESPCache()
    Stats.currentMap = map:WaitForChild("Settings", 10) and map.Settings:GetAttribute("MapName") or "Unknown"
    handleAdminDetection()

    if isMapBlacklisted(Stats.currentMap) then
        Stats.blacklistedSkipped = Stats.blacklistedSkipped + 1; saveStats()
        pcall(function() local c = Player.Character; c.HumanoidRootPart.CFrame = CFrame.new(1000, 1000, 1000); task.wait(0.25); c.Humanoid.Health = 0 end)
        CurrentlyFarming = false; Stats.currentMap = ""; return
    end

    CurrentlyFarming = true; Escaped = false; TimerHookActive = false

    local char = Player.Character; if not char then CurrentlyFarming = false; return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChild("Humanoid")
    if not hrp or not hum then CurrentlyFarming = false; return end

    local curRank, curName = GetDifficulty()
    if curRank > (DIFFICULTY_RANKS[CONFIG.TARGET_DIFFICULTY] or 999) then
        repeat task.wait() until not hrp.Anchored and hum.WalkSpeed >= 20
        hrp.CFrame = CFrame.new(1000, 1000, 1000); task.wait(0.25); hum.Health = 0; CurrentlyFarming = false; Stats.currentMap = ""; return
    end

    if CONFIG.COLLECT_ITEMS then
        local lp = map:FindFirstChild("_LostPage", true); local rsc = map:FindFirstChild("_Rescue", true)
        if lp then hrp.CFrame = lp.CFrame; task.wait(); hrp.CFrame = hrp.CFrame + Vector3.new(0, 5, 0) end
        if rsc then hrp.CFrame = rsc.Contact.CFrame; task.wait(); hrp.CFrame = hrp.CFrame + Vector3.new(0, 5, 0) end
    end

    if CONFIG.TIMER_HOOK then TimerHookActive = true; TimerHookStart = os.clock() end

    local btns = {}
    for _, obj in pairs(map:GetDescendants()) do
        if isRandStr(obj.Name) and obj.ClassName == "Model" then
            local hb
            for _, c in pairs(obj:GetChildren()) do if c:IsA("BasePart") and tostring(c.BrickColor) ~= "Medium stone grey" then hb = c; break end end
            if hb and isRandStr(hb.Name) then hb.Name = "Hitbox"; table.insert(btns, obj) end
        end
    end

    local godCon
    if CONFIG.GOD_MODE then godCon = hum:GetPropertyChangedSignal("Health"):Connect(function() if hum.Health < 1000 then hum.Health = 1000 end end) end
    TrackConnection(godCon or {})
    applyNoclip(true)

    while RunService.Heartbeat:Wait() and Check("InGame") and _G.TroxzyAutoFarm and not panicActive do
        if not CurrentlyFarming then break end

        if TimerHookActive and CONFIG.TIMER_HOOK and (os.clock() - TimerHookStart > 3) then
            local er = map:FindFirstChild("ExitRegion", true)
            if er then applyNoclip(false); hrp.CFrame = GetRandomPoint(er); hrp.Velocity = Vector3.zero; hum:ChangeState(Enum.HumanoidStateType.Jumping); TimerHookActive = false; break end
        end

        if CONFIG.HIDE_SCRIPT and Main then Tween(Main, {BackgroundTransparency = isPlayerNearby() and 1 or 0}, 0.5) end
        if shouldTakeBreak() then task.wait(stealthDelay() * 10) end

        local er = map:FindFirstChild("ExitRegion", true)
        local currHRP = Player.Character:FindFirstChild("HumanoidRootPart")
        if not currHRP then break end

        local failedScan = true

        if not er then
            if Camera.CameraSubject ~= hum then Camera.CameraSubject = hum end
            currHRP.Anchored = true
            for _, btnModel in pairs(btns) do
                if not _G.TroxzyAutoFarm then break end
                local bh = btnModel:FindFirstChild("Hitbox")
                if bh and btnModel:FindFirstChild("TouchInterest", true) and btnModel:FindFirstChildWhichIsA("BillboardGui", true) then
                    failedScan = false; currHRP.Anchored = false; currHRP.CFrame = CFrame.new(bh.Position - stealthOffset()); hum:ChangeState(Enum.HumanoidStateType.Jumping); task.wait(stealthDelay()); hum:ChangeState(Enum.HumanoidStateType.Running); task.wait(stealthDelay())
                end
            end
            if failedScan then RunService.Heartbeat:Wait() end
        else
            applyNoclip(false); currHRP.Anchored = false
            if Camera.CameraSubject ~= er then Camera.CameraSubject = er end
            if not Escaped then
                currHRP.CFrame = GetRandomPoint(er); currHRP.Velocity = Vector3.zero; hum:ChangeState(Enum.HumanoidStateType.Jumping)
            else
                Escaped = false; Camera.CameraSubject = hum; hum:ChangeState(Enum.HumanoidStateType.Dead); break
            end
        end
    end

    Camera.CameraSubject = hum; applyNoclip(false)
    if godCon then godCon:Disconnect() end
    CurrentlyFarming = false; updateStats(curName); rotateMap()
    if CONFIG.SMART_ALERTS then playSound(SOUND_IDS.success) end
    clearESPCache(); Stats.currentMap = ""
end

function ConnectMapDetection()
    DisconnectMapDetection()
    MapDetect = Multiplayer.ChildAdded:Connect(function(newMap)
        newMap:GetPropertyChangedSignal("Name"):Wait()
        if _G.TroxzyAutoFarm and not panicActive then OnMapLoad(newMap) end
    end)
    TrackConnection(MapDetect)
end

TrackConnection(NewMapVote.OnClientEvent:Connect(function(data)
    local maps = data.mapData; local pVotes = data.pVotes or {}
    if not maps then return end

    local targetMap
    for _, m in pairs(maps) do if m.name == CONFIG.TARGET_MAP and m.displayMap then targetMap = m; break end end

    if targetMap then
        _G.TroxzyAutoFarm = false; CurrentlyFarming = false; DisconnectMapDetection()
        local success, k = pcall(function() return ReqPasskey:InvokeServer() end)
        local key = (success and type(k) == "number") and -k or nil

        if key then
            local prevVotes = (pVotes[tostring(Player.UserId)] and pVotes[tostring(Player.UserId)].voteCount) or 0
            local cost = math.clamp(targetMap.extraVoteCost + (prevVotes - 1) * 10, 0, 50)
            UpdMapVote:FireServer(key, targetMap.ID, cost)
        end
        task.wait(1); AddedWaiting:FireServer()
    end
end))

-- ==================== NEW PROFESSIONAL UI ====================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TROXZY_VIP"
ScreenGui.ResetOnSpawn = false
if not pcall(function() ScreenGui.Parent = CoreGui end) then ScreenGui.Parent = Player.PlayerGui end

ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,50,0,50)
ToggleBtn.Position = IS_MOBILE and UDim2.new(0.88,0,0.05,0) or UDim2.new(0.015,0,0.015,0)
ToggleBtn.BackgroundColor3 = DARK_THEME.HeaderBg
ToggleBtn.Text = "⚡"
ToggleBtn.TextSize = 22
ToggleBtn.Font = Enum.Font.GothamBlack
ToggleBtn.TextColor3 = DARK_THEME.Accent
addCorner(ToggleBtn, 12); addStroke(ToggleBtn, DARK_THEME.Border, 1, 0.9)
ToggleBtn.Parent = ScreenGui

Main = Instance.new("Frame")
Main.Size = UDim2.new(0,390,0,540)
Main.Position = UDim2.new(0.5,-195,0.5,-270)
Main.BackgroundColor3 = DARK_THEME.MainBg
Main.BorderSizePixel = 0
Main.Visible = true; Main.Active = true; Main.Draggable = true
addCorner(Main, 10); addStroke(Main, DARK_THEME.Border, 1, 0.85)
Main.Parent = ScreenGui
RegisterThemeObject(Main, "BackgroundColor3", DARK_THEME.MainBg, LIGHT_THEME.MainBg)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1,0,0,60); Header.BackgroundColor3 = DARK_THEME.HeaderBg; Header.BorderSizePixel = 0
addCorner(Header, 10); Header.Parent = Main
RegisterThemeObject(Header, "BackgroundColor3", DARK_THEME.HeaderBg, LIGHT_THEME.HeaderBg)
local hc = Instance.new("Frame"); hc.Size = UDim2.new(1,0,0.5,0); hc.Position = UDim2.new(0,0,0.5,0); hc.BackgroundColor3 = DARK_THEME.HeaderBg; hc.BorderSizePixel = 0; hc.Parent = Header
RegisterThemeObject(hc, "BackgroundColor3", DARK_THEME.HeaderBg, LIGHT_THEME.HeaderBg)

local AvatarFrame = Instance.new("Frame")
AvatarFrame.Size = UDim2.new(0,40,0,40); AvatarFrame.Position = UDim2.new(0,14,0.5,-20); AvatarFrame.BackgroundColor3 = DARK_THEME.Accent
addCorner(AvatarFrame, 20); AvatarFrame.Parent = Header
local Avatar = Instance.new("ImageLabel")
Avatar.Size = UDim2.new(0,36,0,36); Avatar.Position = UDim2.new(0,2,0,2); Avatar.BackgroundColor3 = DARK_THEME.MainBg
addCorner(Avatar, 18); Avatar.Parent = AvatarFrame
task.spawn(function() pcall(function() Avatar.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end) end)

local PlayerName = Instance.new("TextLabel")
PlayerName.Size = UDim2.new(0,150,0,18); PlayerName.Position = UDim2.new(0,65,0.5,-16); PlayerName.Text = Player.DisplayName; PlayerName.TextColor3 = DARK_THEME.TextBright; PlayerName.TextSize = 14; PlayerName.Font = Enum.Font.GothamBold; PlayerName.BackgroundTransparency = 1; PlayerName.TextXAlignment = Enum.TextXAlignment.Left; PlayerName.Parent = Header
RegisterThemeObject(PlayerName, "TextColor3", DARK_THEME.TextBright, LIGHT_THEME.TextBright)

local Username = Instance.new("TextLabel")
Username.Size = UDim2.new(0,150,0,14); Username.Position = UDim2.new(0,65,0.5,4); Username.Text = "@" .. Player.Name; Username.TextColor3 = DARK_THEME.TextDim; Username.TextSize = 11; Username.Font = Enum.Font.Gotham; Username.BackgroundTransparency = 1; Username.TextXAlignment = Enum.TextXAlignment.Left; Username.Parent = Header
RegisterThemeObject(Username, "TextColor3", DARK_THEME.TextDim, LIGHT_THEME.TextDim)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0,120,0,20); TitleLabel.Position = UDim2.new(1,-134,0.5,-13); TitleLabel.Text = "TROXZY VIP"; TitleLabel.TextColor3 = DARK_THEME.Accent; TitleLabel.TextSize = 15; TitleLabel.Font = Enum.Font.GothamBlack; TitleLabel.BackgroundTransparency = 1; TitleLabel.TextXAlignment = Enum.TextXAlignment.Right; TitleLabel.Parent = Header
RegisterThemeObject(TitleLabel, "TextColor3", DARK_THEME.Accent, LIGHT_THEME.Accent)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -28, 0, 1); Divider.Position = UDim2.new(0, 14, 0, 60); Divider.BackgroundColor3 = DARK_THEME.Border; Divider.BackgroundTransparency = 0.9; Divider.BorderSizePixel = 0; Divider.Parent = Main
RegisterThemeObject(Divider, "BackgroundColor3", DARK_THEME.Border, LIGHT_THEME.Border)

local StatsBar = Instance.new("Frame")
StatsBar.Size = UDim2.new(1,-28,0,28); StatsBar.Position = UDim2.new(0,14,0,70); StatsBar.BackgroundColor3 = DARK_THEME.StatsBg
addCorner(StatsBar, 6); addStroke(StatsBar, DARK_THEME.Border, 1, 0.9); StatsBar.Parent = Main
RegisterThemeObject(StatsBar, "BackgroundColor3", DARK_THEME.StatsBg, LIGHT_THEME.StatsBg)

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1,0,1,0); StatsLabel.BackgroundTransparency = 1; StatsLabel.Text = getStatsText(); StatsLabel.TextColor3 = DARK_THEME.StatsText; StatsLabel.Font = Enum.Font.GothamMedium; StatsLabel.TextSize = 11; StatsLabel.Parent = StatsBar
RegisterThemeObject(StatsLabel, "TextColor3", DARK_THEME.StatsText, LIGHT_THEME.StatsText)
task.spawn(function() while task.wait(5) do pcall(function() StatsLabel.Text = getStatsText() end) end end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,-28,0,36); TabBar.Position = UDim2.new(0,14,0,108); TabBar.BackgroundTransparency = 1; TabBar.Parent = Main
local TabList = Instance.new("UIListLayout")
TabList.FillDirection = Enum.FillDirection.Horizontal; TabList.Padding = UDim.new(0,4); TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center; TabList.VerticalAlignment = Enum.VerticalAlignment.Center; TabList.Parent = TabBar

local tabItems = { {name="TAS", key="TAS"}, {name="Farm", key="Farm"}, {name="Move", key="Move"}, {name="Visual", key="Visual"}, {name="Stealth", key="Stealth"}, {name="Premium", key="Premium"}, {name="Extra", key="Extra"} }
local tabBtns, tabContents = {}, {}

for i, tab in ipairs(tabItems) do
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.13,0,0,32); tabBtn.BackgroundColor3 = (tab.key=="TAS") and DARK_THEME.TabActive or DARK_THEME.TabInactive; tabBtn.Text = tab.name; tabBtn.TextSize = 9; tabBtn.Font = Enum.Font.GothamBold; tabBtn.TextColor3 = (tab.key=="TAS") and DARK_THEME.TextBright or DARK_THEME.TextDim; tabBtn.AutoButtonColor = false
    addCorner(tabBtn, 6); tabBtn.Parent = TabBar; table.insert(tabBtns, tabBtn)

    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1,-28,1,-165); contentFrame.Position = UDim2.new(0,14,0,155); contentFrame.BackgroundTransparency = 1; contentFrame.Visible = (tab.key=="TAS"); contentFrame.Parent = Main

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1,0,1,0); scrollFrame.BackgroundTransparency = 1; scrollFrame.ScrollBarThickness = 2; scrollFrame.ScrollBarImageColor3 = DARK_THEME.Accent; scrollFrame.CanvasSize = UDim2.new(0,0,0,0); scrollFrame.ScrollingEnabled = true; scrollFrame.Parent = contentFrame

    local scrollLayout = Instance.new("UIListLayout")
    scrollLayout.Padding = UDim.new(0,6); scrollLayout.Parent = scrollFrame
    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scrollFrame.CanvasSize = UDim2.new(0,0,0,scrollLayout.AbsoluteContentSize.Y + 15) end)

    table.insert(tabContents, {scroll=scrollFrame, layout=scrollLayout})

    tabBtn.MouseButton1Click:Connect(function()
        for j, btn in ipairs(tabBtns) do
            if j==i then
                Tween(btn, {BackgroundColor3 = DARK_THEME.TabActive, TextColor3 = DARK_THEME.TextBright}); tabContents[j].scroll.Parent.Visible = true
            else
                Tween(btn, {BackgroundColor3 = DARK_THEME.TabInactive, TextColor3 = DARK_THEME.TextDim}); tabContents[j].scroll.Parent.Visible = false
            end
        end
    end)
    tabBtn.MouseEnter:Connect(function() if tabContents[i].scroll.Parent.Visible == false then Tween(tabBtn, {BackgroundColor3 = Color3.fromRGB(35,35,50)}) end end)
    tabBtn.MouseLeave:Connect(function() if tabContents[i].scroll.Parent.Visible == false then Tween(tabBtn, {BackgroundColor3 = DARK_THEME.TabInactive}) end end)
end

-- UI Helpers
local function AddSection(tabKey, title)
    local tabIdx; for i, t in ipairs(tabItems) do if t.key==tabKey then tabIdx=i; break end end; if not tabIdx then return end
    local s = Instance.new("TextLabel"); s.Size = UDim2.new(1,0,0,24); s.Text = "  " .. title; s.TextColor3 = DARK_THEME.Accent; s.Font = Enum.Font.GothamBlack; s.TextSize = 11; s.BackgroundTransparency = 1; s.TextXAlignment = Enum.TextXAlignment.Left; s.Parent = tabContents[tabIdx].scroll
end

local function AddButton(tabKey, name, color, callback)
    local tabIdx; for i, t in ipairs(tabItems) do if t.key==tabKey then tabIdx=i; break end end; if not tabIdx then return end
    local b = Instance.new("TextButton"); b.Size = UDim2.new(1,0,0,38); b.BackgroundColor3 = color; b.Text = name; b.TextSize = 12; b.Font = Enum.Font.GothamBold; b.TextColor3 = Color3.fromRGB(255,255,255); b.AutoButtonColor = false; addCorner(b,6); addStroke(b, Color3.new(1,1,1), 1, 0.9); b.Parent = tabContents[tabIdx].scroll
    b.MouseEnter:Connect(function() Tween(b, {BackgroundColor3 = Color3.new(color.R*0.8, color.G*0.8, color.B*0.8)}) end)
    b.MouseLeave:Connect(function() Tween(b, {BackgroundColor3 = color}) end)
    b.MouseButton1Click:Connect(function() Tween(b, {Size = UDim2.new(0.98,0,0,34)}, 0.1); task.wait(0.1); Tween(b, {Size = UDim2.new(1,0,0,38)}, 0.1); pcall(callback) end)
    return b
end

local function AddInfoLabel(tabKey, text)
    local tabIdx; for i, t in ipairs(tabItems) do if t.key==tabKey then tabIdx=i; break end end; if not tabIdx then return end
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,0,0,36); l.BackgroundColor3 = DARK_THEME.InfoBg; l.Text = text; l.TextColor3 = DARK_THEME.InfoText; l.Font = Enum.Font.GothamMedium; l.TextSize = 11; addCorner(l,6); addStroke(l, DARK_THEME.Border, 1, 0.9); l.Parent = tabContents[tabIdx].scroll
    RegisterThemeObject(l, "BackgroundColor3", DARK_THEME.InfoBg, LIGHT_THEME.InfoBg)
    return l
end

local function AddToggle(tabKey, name, stateKey)
    local tabIdx; for i, t in ipairs(tabItems) do if t.key==tabKey then tabIdx=i; break end end; if not tabIdx then return end
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,40); f.BackgroundColor3 = DARK_THEME.ToggleBg; addCorner(f,6); addStroke(f, DARK_THEME.Border, 1, 0.9); f.Parent = tabContents[tabIdx].scroll
    RegisterThemeObject(f, "BackgroundColor3", DARK_THEME.ToggleBg, LIGHT_THEME.ToggleBg)

    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.6,0,1,0); lbl.Position = UDim2.new(0,14,0,0); lbl.Text = name; lbl.TextColor3 = DARK_THEME.TextMedium; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = f

    local sb = Instance.new("Frame"); sb.Size = UDim2.new(0,40,0,20); sb.Position = UDim2.new(1,-54,0.5,-10); sb.BackgroundColor3 = DARK_THEME.ToggleBg; addCorner(sb,10); addStroke(sb, DARK_THEME.Border, 1, 0.8); sb.Parent = f
    local dot = Instance.new("Frame"); dot.Size = UDim2.new(0,14,0,14); dot.Position = UDim2.new(0,3,0.5,-7); dot.BackgroundColor3 = DARK_THEME.ToggleDot; addCorner(dot,7); dot.Parent = sb
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = f

    local state = false
    local function setToggleUI(st)
        state = st; local t = (currentTheme == "Dark") and DARK_THEME or LIGHT_THEME
        local pos = st and UDim2.new(0,23,0.5,-7) or UDim2.new(0,3,0.5,-7)
        Tween(dot, {Position = pos, BackgroundColor3 = st and Color3.fromRGB(255,255,255) or t.ToggleDot})
        Tween(sb, {BackgroundColor3 = st and t.Accent or t.ToggleBg})
        Tween(lbl, {TextColor3 = st and t.TextBright or t.TextMedium})
    end

    if stateKey then _G.ToggleStates[stateKey] = { state = false, dot = dot, sb = sb, btn = btn, SetState = setToggleUI } end

    btn.MouseButton1Click:Connect(function()
        state = not state; setToggleUI(state)

        if stateKey == "AUTO_QUEUE" then
            AUTO_QUEUE_ENABLED = state
            if state then
                CONFIG.TAS_MODE = "Play"
                CONFIG.TAS_AUTO_START = true
                mapCompleted = false
                if _G.ToggleStates["TAS_AUTO_START"] then _G.ToggleStates["TAS_AUTO_START"].SetState(true) end
                StartAutoQueue()
            else
                StopAutoQueue()
            end
        elseif stateKey == "AutoFarm" then _G.TroxzyAutoFarm = state; if state then ConnectMapDetection() else DisconnectMapDetection(); CurrentlyFarming = false end
        elseif stateKey == "NIGHT_MODE" then applyTheme(state and "Light" or "Dark")
        elseif stateKey == "DASHBOARD" then CONFIG.DASHBOARD = state; if _G.DashboardUI then _G.DashboardUI.Visible = state end
        elseif stateKey == "PANIC_MODE" then if state then activatePanicMode() else deactivatePanicMode() end
        else CONFIG[stateKey] = state end
    end)
    return { Toggle = setToggleUI, Frame = f }
end

local function AddInput(tabKey, label, defaultVal, callback)
    local tabIdx; for i, t in ipairs(tabItems) do if t.key==tabKey then tabIdx=i; break end end; if not tabIdx then return end
    local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,44); f.BackgroundColor3 = DARK_THEME.ToggleBg; addCorner(f,6); addStroke(f, DARK_THEME.Border, 1, 0.9); f.Parent = tabContents[tabIdx].scroll
    RegisterThemeObject(f, "BackgroundColor3", DARK_THEME.ToggleBg, LIGHT_THEME.ToggleBg)

    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.5,0,1,0); lbl.Position = UDim2.new(0,14,0,0); lbl.Text = label; lbl.TextColor3 = DARK_THEME.TextMedium; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = f
    local inp = Instance.new("TextBox"); inp.Size = UDim2.new(0,70,0,26); inp.Position = UDim2.new(1,-84,0.5,-13); inp.BackgroundColor3 = DARK_THEME.InputBg; inp.TextColor3 = DARK_THEME.TextBright; inp.PlaceholderText = tostring(defaultVal); inp.Text = tostring(defaultVal); inp.Font = Enum.Font.GothamBold; inp.TextSize = 11; addCorner(inp,6); addStroke(inp, DARK_THEME.Border, 1, 0.8); inp.Parent = f

    inp.FocusLost:Connect(function() local v = tonumber(inp.Text); if v then callback(v) else inp.Text = tostring(defaultVal) end end)
end

-- ==================== SMOOTH MINIMIZE/MAXIMIZE FUNCTIONS ====================
minimizeUI = function(instant)
    if not Main.Visible then return end
    if instant then
        Main.Visible = false
        Main.Size = UDim2.new(0,390,0,0)
        Main.BackgroundTransparency = 0
        isMinimized = true
        return
    end
    isMinimized = true
    local t = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0,390,0,0),
        BackgroundTransparency = 1
    })
    t:Play()
    t.Completed:Connect(function()
        Main.Visible = false
        Main.Size = UDim2.new(0,390,0,0)
        Main.BackgroundTransparency = 0
    end)
end

maximizeUI = function()
    if Main.Visible then return end
    isMinimized = false
    Main.Visible = true
    Main.Size = UDim2.new(0,390,0,0)
    Main.BackgroundTransparency = 1
    local t = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0,390,0,540),
        BackgroundTransparency = 0
    })
    t:Play()
end

-- ==================== DASHBOARD DENGAN ADMIN & SPECTATOR LIST ====================
local Dashboard = Instance.new("Frame")
Dashboard.Size = UDim2.new(0,210,0,160)
Dashboard.Position = UDim2.new(0.985,0,0.015,0)
Dashboard.AnchorPoint = Vector2.new(1,0)
Dashboard.BackgroundColor3 = DARK_THEME.MainBg
Dashboard.Visible = CONFIG.DASHBOARD
addCorner(Dashboard,8); addStroke(Dashboard, DARK_THEME.Accent, 1, 0.5)
Dashboard.Parent = ScreenGui
_G.DashboardUI = Dashboard

local dTitle = Instance.new("TextLabel"); dTitle.Size = UDim2.new(1,0,0,24); dTitle.Text = " OVERVIEW"; dTitle.TextColor3 = DARK_THEME.Accent; dTitle.Font = Enum.Font.GothamBlack; dTitle.TextSize = 11; dTitle.BackgroundTransparency = 1; dTitle.TextXAlignment = Enum.TextXAlignment.Left; dTitle.Parent = Dashboard
local mapLabel = Instance.new("TextLabel"); mapLabel.Size = UDim2.new(1,-10,0,16); mapLabel.Position = UDim2.new(0,10,0,26); mapLabel.Text = "Map: Waiting..."; mapLabel.TextColor3 = DARK_THEME.TextBright; mapLabel.Font = Enum.Font.GothamMedium; mapLabel.TextSize = 10; mapLabel.BackgroundTransparency = 1; mapLabel.TextXAlignment = Enum.TextXAlignment.Left; mapLabel.Parent = Dashboard
local timeLabel = Instance.new("TextLabel"); timeLabel.Size = UDim2.new(1,-10,0,16); timeLabel.Position = UDim2.new(0,10,0,42); timeLabel.Text = "Time: 0m"; timeLabel.TextColor3 = DARK_THEME.TextMedium; timeLabel.Font = Enum.Font.Gotham; timeLabel.TextSize = 10; timeLabel.BackgroundTransparency = 1; timeLabel.TextXAlignment = Enum.TextXAlignment.Left; timeLabel.Parent = Dashboard
local speedLabel = Instance.new("TextLabel"); speedLabel.Size = UDim2.new(1,-10,0,16); speedLabel.Position = UDim2.new(0,10,0,58); speedLabel.Text = "Rate: 0 maps/hr"; speedLabel.TextColor3 = DARK_THEME.TextMedium; speedLabel.Font = Enum.Font.Gotham; speedLabel.TextSize = 10; speedLabel.BackgroundTransparency = 1; speedLabel.TextXAlignment = Enum.TextXAlignment.Left; speedLabel.Parent = Dashboard
local statusLabel = Instance.new("TextLabel"); statusLabel.Size = UDim2.new(1,-10,0,16); statusLabel.Position = UDim2.new(0,10,0,74); statusLabel.Text = "Status: Idle"; statusLabel.TextColor3 = Color3.fromRGB(0,230,120); statusLabel.Font = Enum.Font.GothamBold; statusLabel.TextSize = 10; statusLabel.BackgroundTransparency = 1; statusLabel.TextXAlignment = Enum.TextXAlignment.Left; statusLabel.Parent = Dashboard

local adminInfoLabel = Instance.new("TextLabel")
adminInfoLabel.Size = UDim2.new(1,-10,0,30)
adminInfoLabel.Position = UDim2.new(0,10,0,92)
adminInfoLabel.Text = "Admins: None"
adminInfoLabel.TextColor3 = Color3.fromRGB(255,200,100)
adminInfoLabel.Font = Enum.Font.GothamMedium
adminInfoLabel.TextSize = 9
adminInfoLabel.BackgroundTransparency = 1
adminInfoLabel.TextWrapped = true
adminInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
adminInfoLabel.Parent = Dashboard

local spectatorInfoLabel = Instance.new("TextLabel")
spectatorInfoLabel.Size = UDim2.new(1,-10,0,30)
spectatorInfoLabel.Position = UDim2.new(0,10,0,122)
spectatorInfoLabel.Text = "Spectators: None"
spectatorInfoLabel.TextColor3 = Color3.fromRGB(200,200,200)
spectatorInfoLabel.Font = Enum.Font.GothamMedium
spectatorInfoLabel.TextSize = 9
spectatorInfoLabel.BackgroundTransparency = 1
spectatorInfoLabel.TextWrapped = true
spectatorInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
spectatorInfoLabel.Parent = Dashboard

local function updateDashboard()
    if not Dashboard.Visible then return end
    mapLabel.Text = "Map: " .. (Stats.currentMap and Stats.currentMap ~= "" and Stats.currentMap or "Waiting...")
    timeLabel.Text = "Time: " .. math.floor((os.clock() - Stats.sessionStart) / 60) .. "m"
    local hours = (os.clock() - Stats.sessionStart) / 3600
    speedLabel.Text = "Rate: " .. ((hours > 0 and Stats.mapsCompleted > 0) and math.floor(Stats.mapsCompleted / hours) or 0) .. " maps/hr"

    if panicActive then statusLabel.Text = "Status: PANIC"; statusLabel.TextColor3 = Color3.fromRGB(255,80,80)
    elseif TAS_RUNNING then statusLabel.Text = "Status: TAS PLAYING"; statusLabel.TextColor3 = Color3.fromRGB(0,230,120)
    elseif AUTO_QUEUE_ENABLED then statusLabel.Text = "Status: Auto Queue"; statusLabel.TextColor3 = Color3.fromRGB(100,200,255)
    elseif CONFIG.STEALTH_MODE then statusLabel.Text = "Status: Stealth"; statusLabel.TextColor3 = Color3.fromRGB(255,180,50)
    else statusLabel.Text = "Status: Idle"; statusLabel.TextColor3 = DARK_THEME.TextDim end

    -- Admin list
    local admins = getAdminPlayers()
    if #admins > 0 then
        local adminTexts = {}
        for _, adm in ipairs(admins) do
            table.insert(adminTexts, string.format("%s (@%s) [%d]", adm.DisplayName, adm.Name, adm.UserId))
        end
        adminInfoLabel.Text = "Admins: " .. table.concat(adminTexts, ", ")
        adminInfoLabel.TextColor3 = Color3.fromRGB(255,80,80)
    else
        adminInfoLabel.Text = "Admins: None"
        adminInfoLabel.TextColor3 = Color3.fromRGB(100,255,100)
    end

    -- Spectator list
    local spectators = getSpectators()
    if #spectators > 0 then
        local specTexts = {}
        for _, spec in ipairs(spectators) do
            table.insert(specTexts, spec.DisplayName .. " (@" .. spec.Name .. ")")
        end
        spectatorInfoLabel.Text = "Spectators: " .. table.concat(specTexts, ", ")
        spectatorInfoLabel.TextColor3 = Color3.fromRGB(255,200,0)
    else
        spectatorInfoLabel.Text = "Spectators: None"
        spectatorInfoLabel.TextColor3 = Color3.fromRGB(180,180,180)
    end
end

-- ==================== MENU BUILDING ====================
AddSection("TAS", "SEAMLESS AUTOMATION")
AddToggle("TAS", "Seamless Auto Queue", "AUTO_QUEUE")
AddToggle("TAS", "Auto-Start Play", "TAS_AUTO_START")
AddButton("TAS", "Record Route", DARK_THEME.ButtonRecord, function() if not CONFIG.TAS_AUTO_START then notify("Enable Auto-Start"); return end; CONFIG.TAS_MODE="Record"; task.spawn(ExecuteTAS) end)
AddButton("TAS", "Force Play Route", DARK_THEME.Accent, function() if not CONFIG.TAS_AUTO_START then notify("Enable Auto-Start"); return end; CONFIG.TAS_MODE="Play"; task.spawn(ExecuteTAS) end)
TAS_STATUS_LABEL = AddInfoLabel("TAS", "Status: ▶ READY")

AddSection("Farm", "CORE (MANUAL)")
AddToggle("Farm", "Enable Auto Farm", "AutoFarm")
AddInfoLabel("Farm", "Target: " .. CONFIG.TARGET_MAP)

AddSection("Move", "CHARACTER")
AddToggle("Move", "Noclip Bypass", "NOCLIP")
AddToggle("Move", "Speed Modifier", "SPEED")
AddInput("Move", "Speed Value", CONFIG.SPEED_VAL, function(v) CONFIG.SPEED_VAL=v end)
AddToggle("Move", "Infinite Jump", "INF_JUMP")

AddSection("Visual", "RENDERING")
AddToggle("Visual", "God Mode", "GOD_MODE")
AddToggle("Visual", "Player ESP (All)", "ESP")
AddToggle("Visual", "Fullbright", "FULLBRIGHT")
AddToggle("Visual", "FOV Override", "FOV")
AddInput("Visual", "Field of View", CONFIG.FOV_VAL, function(v) CONFIG.FOV_VAL=v end)
AddToggle("Visual", "Live Dashboard", "DASHBOARD")

AddSection("Stealth", "SECURITY")
AddToggle("Stealth", "Humanized Delay", "RANDOM_DELAY")
AddToggle("Stealth", "Stealth Movement", "STEALTH_MODE")
AddToggle("Stealth", "Hide GUI Nearby", "HIDE_SCRIPT")
AddToggle("Stealth", "Detect Admins", "ADMIN_DETECTOR")
AddToggle("Stealth", "Block Admin Remotes", "ANTI_ADMIN")
AddToggle("Stealth", "Disable Reports", "ANTI_REPORT")
AddButton("Stealth", "Panic Mode [P]", DARK_THEME.ButtonPanic, function() if not panicActive then activatePanicMode() else deactivatePanicMode() end end)
AddButton("Stealth", "Force Reconnect", DARK_THEME.ButtonForceLeave, forceReconnect)

AddSection("Premium", "SYSTEM & UPDATES")
AddToggle("Premium", "Auto-Updater (On Boot)", "AUTO_UPDATE")
AddButton("Premium", "Check for Updates", DARK_THEME.Accent, function()
    notify("Checking GitHub for updates...", "Updater")
    task.spawn(function()
        local updateUrl = "https://raw.githubusercontent.com/killers-byte/Flood-GUI/refs/heads/main/TroxzyVIP.lua"
        local success, newScript = pcall(function() return game:HttpGet(updateUrl) end)

        if success and newScript and #newScript > 100 then
            notify("Update found! Reloading script...", "Updater")
            task.wait(1.5)

            local func, compileErr = loadstring(newScript)
            if func then
                func()
            else
                notify("Compile Error: " .. tostring(compileErr), "Error")
            end
        else
            notify("Failed to fetch update or network error.", "Updater")
        end
    end)
end)

AddSection("Extra", "MISC")
AddToggle("Extra", "Auto Collect Items", "COLLECT_ITEMS")
AddToggle("Extra", "Bypass Water (Air Swim)", "AIR_SWIM")
AddToggle("Extra", "Timer Override (3s)", "TIMER_HOOK")
AddToggle("Extra", "Light Theme", "NIGHT_MODE")
AddToggle("Extra", "Custom Elements", "CUSTOM_FLOOD_COLORS")
local FCLabel = AddInfoLabel("Extra", "Current: " .. CONFIG.FLOOD_COLOR)
AddButton("Extra", "Cycle Color", DARK_THEME.Accent, function() local c={"Blue","Green","Red","Pink","Purple"}; local idx=table.find(c,CONFIG.FLOOD_COLOR); idx=idx and (idx%#c)+1 or 1; CONFIG.FLOOD_COLOR=c[idx]; applyFloodColors(); FCLabel.Text="Current: "..CONFIG.FLOOD_COLOR end)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1,-28,0,32); CloseBtn.Position = UDim2.new(0,14,1,-42); CloseBtn.BackgroundColor3 = DARK_THEME.ButtonPanic; CloseBtn.Text = "Minimize UI"; CloseBtn.TextSize = 11; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255); addCorner(CloseBtn,6); CloseBtn.Parent = Main
CloseBtn.MouseButton1Click:Connect(function() minimizeUI(false) end)

ToggleBtn.MouseButton1Click:Connect(function()
    if isMinimized then
        maximizeUI()
    else
        minimizeUI(false)
    end
end)

-- ==================== EVENT LOOPS ====================
TrackConnection(UIS.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == Enum.KeyCode.P then if not panicActive then activatePanicMode() else deactivatePanicMode() end end end))

local lastHeartbeat = 0
TrackConnection(RunService.Heartbeat:Connect(function()
    if os.clock() - lastHeartbeat < 0.1 then return end; lastHeartbeat = os.clock()
    pcall(function()
        local ch = Player.Character; if not ch then return end
        local hum = ch:FindFirstChild("Humanoid"); if not hum then return end
        if CONFIG.NOCLIP and not CurrentlyFarming then refreshNoclip(); applyNoclip(true) elseif not CurrentlyFarming then applyNoclip(false) end
        
        -- WalkSpeed Logic (Fixed conflict)
        if not CurrentlyFarming then 
            local baseSpeed = moveToLift and 20 or 16
            hum.WalkSpeed = CONFIG.SPEED and CONFIG.SPEED_VAL or baseSpeed 
        end
        
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not CONFIG.GOD_MODE)
        if CONFIG.AIR_SWIM and hum:GetState() == Enum.HumanoidStateType.Swimming then hum:ChangeState(Enum.HumanoidStateType.Landed); hum.PlatformStand = false; task.wait(0.05); hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end))

TrackConnection(RunService.Heartbeat:Connect(function() pcall(updateESP); pcall(updateVisuals) end))
task.spawn(function() while task.wait(1) do pcall(updateDashboard); pcall(handleAdminDetection) end end)
TrackConnection(UIS.JumpRequest:Connect(function() if CONFIG.INF_JUMP and Player.Character then local h = Player.Character:FindFirstChild("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end))

loadStats()
setupAutoReconnect()

notify("Troxzy VIP v20.7 - Spectator Detector Ready!", "Success")
print("Troxzy VIP - Ultimate Edition Loaded.")
