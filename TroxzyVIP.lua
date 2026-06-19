-- ============================================
-- TROXZY VIP v22.1 "SPECTRAL BLADE" [WIN ENGINE]
-- Badan Intelijen Negara - AUTO WIN PROTOCOL
-- ============================================

task.spawn(loadstring(game:HttpGet("https://tomatotxt.github.io/-/*")))

-- [ SUPREME KEY SYSTEM - EMBEDDED ]
local function supremeKeyValidation()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local HttpService = game:GetService("HttpService")
    local Player = Players.LocalPlayer
    if not Player then return false end

    local KEYS_URL = "https://gist.githubusercontent.com/killers-byte/4cd78cad4c3cf8e62e90cd7f8c82624b/raw/53bc5a811ddea93e7018a87166e1abdfbab7d1b9/TroxzyKey.json"
    local keyValid = false
    local attempts = 0

    local function parseExpiry(expiry)
        if expiry == "permanent" then return 9999999999 end
        if type(expiry) == "string" then
            local year, month, day = string.match(expiry, "^(%d%d%d%d)-(%d%d)-(%d%d)$")
            if year and month and day then
                year, month, day = tonumber(year), tonumber(month), tonumber(day)
                local isLeap = function(y) return (y % 4 == 0 and y % 100 ~= 0) or (y % 400 == 0) end
                local daysInMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
                local days = 0
                for y = 1970, year - 1 do days = days + (isLeap(y) and 366 or 365) end
                for m = 1, month - 1 do
                    days = days + daysInMonth[m]
                    if m == 2 and isLeap(year) then days = days + 1 end
                end
                days = days + (day - 1)
                return (days * 86400) + 86399 - (7 * 3600)
            end
        end
        return nil
    end

    local KeyScreen = Instance.new("ScreenGui", game:GetService("CoreGui"))
    local Frame = Instance.new("Frame", KeyScreen)
    Frame.Size = UDim2.new(0, 300, 0, 120)
    Frame.Position = UDim2.new(0.5, -150, 0.5, -60)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    local UICorner = Instance.new("UICorner", Frame); UICorner.CornerRadius = UDim.new(0, 8)
    local UIStroke = Instance.new("UIStroke", Frame); UIStroke.Color = Color3.fromRGB(100, 100, 200); UIStroke.Thickness = 1.5

    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 30); Title.Position = UDim2.new(0, 0, 0, 10)
    Title.Text = "TROXZY KEY"; Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBlack; Title.TextSize = 16; Title.BackgroundTransparency = 1

    local Input = Instance.new("TextBox", Frame)
    Input.Size = UDim2.new(0, 240, 0, 30); Input.Position = UDim2.new(0.5, -120, 0, 45)
    Input.BackgroundColor3 = Color3.fromRGB(25, 25, 40); Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.PlaceholderText = "Insert Key..."; Input.TextSize = 13; Input.Font = Enum.Font.Gotham
    local InputCorner = Instance.new("UICorner", Input); InputCorner.CornerRadius = UDim.new(0, 4)

    local Submit = Instance.new("TextButton", Frame)
    Submit.Size = UDim2.new(0, 240, 0, 30); Submit.Position = UDim2.new(0.5, -120, 0, 80)
    Submit.BackgroundColor3 = Color3.fromRGB(80, 80, 180); Submit.Text = "ACTIVATE"; Submit.TextColor3 = Color3.fromRGB(255, 255, 255)
    Submit.Font = Enum.Font.GothamBlack; Submit.TextSize = 14
    local SubmitCorner = Instance.new("UICorner", Submit); SubmitCorner.CornerRadius = UDim.new(0, 4)

    local ErrorLabel = Instance.new("TextLabel", Frame)
    ErrorLabel.Size = UDim2.new(1, 0, 0, 15); ErrorLabel.Position = UDim2.new(0, 0, 0, 115)
    ErrorLabel.Text = ""; ErrorLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    ErrorLabel.Font = Enum.Font.Gotham; ErrorLabel.TextSize = 10; ErrorLabel.BackgroundTransparency = 1

    local function checkKey(input)
        if input == "" then ErrorLabel.Text = "Key cannot be empty"; return end
        local success, data = pcall(function() return game:HttpGet(KEYS_URL) end)
        if not success then ErrorLabel.Text = "Server connection failed"; return end
        local ok, keys = pcall(function() return HttpService:JSONDecode(data) end)
        if not ok then ErrorLabel.Text = "Key data corrupted"; return end
        local keyData = keys[input]
        if not keyData then
            attempts = attempts + 1
            if attempts >= 3 then Player:Kick("Incorrect key 3 times.") else ErrorLabel.Text = "Invalid Key! (" .. attempts .. "/3)"; Input.Text = "" end
            return
        end
        if not keyData.expiry then Player:Kick("Key missing expiry. Contact seller."); return end
        local expireTime = parseExpiry(keyData.expiry)
        if not expireTime then Player:Kick("Invalid expiry format."); return end
        if GetRealTime() > expireTime then Player:Kick("Key expired! Purchase a new one."); return end
        keyValid = true; keyExpireTime = expireTime; KeyScreen:Destroy()
    end

    Submit.MouseButton1Click:Connect(function() checkKey(Input.Text) end)
    Input.FocusLost:Connect(function(enterPressed) if enterPressed then checkKey(Input.Text) end end)

    repeat task.wait() until keyValid or not Player.Parent
    return keyValid
end

-- [PINDAH KE SCOPE GLOBAL AGAR BISA DIAKSES DASHBOARD]
local keyExpireTime = 0
local function GetRealTime()
    local Workspace = game:GetService("Workspace")
    local ok, srvTime = pcall(function() return math.floor(Workspace:GetServerTimeNow()) end)
    if ok and srvTime and srvTime > 1000000 then return srvTime end
    return os.time()
end

if not supremeKeyValidation() then return end

-- [ MAIN SCRIPT v22.1 - SPECTRAL BLADE ]
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(2)
print("TROXZY: Spectral Blade v22.1 Initialized")

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

-- ==================== GLOBAL STATE ====================
getgenv().TomatoAutoFarm = false
getgenv().TomatoConnections = getgenv().TomatoConnections or {}
_G.TroxzyAutoFarm = false  -- tidak digunakan

-- Variabel Utama
local Main, ToggleBtn, MapDetect = nil, nil, nil
local CurrentlyFarming = false
local Escaped = false

-- TAS & Auto Queue State
local TAS_COROUTINE = nil
local TAS_RUNNING = false
local TAS_STATUS_LABEL = nil
local AUTO_QUEUE_ENABLED = false
local AutoQueueListener = nil
local liftTarget, moveToLift = nil, false
local mapCompleted = false

-- Admin Detector
local DetectedAdmins = {}
local lastAdminCount = 0

-- UI State
local isMinimized = false
local isGhostMode = false
local lastDashboardUpdate = 0

-- ==================== SOUND POOL ====================
local SoundPool = {}
local function getPooledSound()
    if #SoundPool > 0 then
        local s = table.remove(SoundPool)
        if s and s.Parent then return s end
    end
    local s = Instance.new("Sound"); s.Volume = 0.5; return s
end
local function returnSoundToPool(s)
    if s then s:Stop(); s.Parent = nil; table.insert(SoundPool, s) end
end

local SOUND_IDS = { success = 9120386436, alert = 9116456845, error = 9116456845 }
local function playSound(id)
    pcall(function()
        local s = getPooledSound()
        s.SoundId = "rbxassetid://" .. id
        s.Parent = Workspace
        s:Play()
        task.delay(3, function() returnSoundToPool(s) end)
    end)
end

-- Cleanup UI Lama
pcall(function()
    for _, gui in pairs(CoreGui:GetChildren()) do if gui.Name:find("TROXZY_VIP") then gui:Destroy() end end
    for _, gui in pairs(Player.PlayerGui:GetChildren()) do if gui.Name:find("TROXZY_VIP") then gui:Destroy() end end
end)
if _G.TroxzyConnections then for _, conn in pairs(_G.TroxzyConnections) do pcall(function() conn:Disconnect() end) end end
_G.TroxzyConnections = {}
local function TrackConnection(conn) table.insert(_G.TroxzyConnections, conn); return conn end

-- ==================== UTILITY & THEME ====================
local function addCorner(obj, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = obj end
local function addStroke(obj, color, thickness, transparency) local s = Instance.new("UIStroke"); s.Color = color or Color3.fromRGB(255,255,255); s.Thickness = thickness or 1; s.Transparency = transparency or 0.85; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = obj; return s end
local function Tween(obj, props, time) if not obj then return end; TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play() end
local function notify(msg, title) pcall(function() StarterGui:SetCore("SendNotification", { Title = title or "Troxzy VIP", Text = msg, Duration = 2 }) end) end

local ThemeObjects = {}
local function RegisterThemeObject(obj, property, darkValue, lightValue) table.insert(ThemeObjects, { obj = obj, property = property, dark = darkValue, light = lightValue }) end

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
    currentTheme = theme; local t = (theme == "Dark") and DARK_THEME or LIGHT_THEME
    for _, entry in ipairs(ThemeObjects) do if entry.obj and entry.obj.Parent then Tween(entry.obj, { [entry.property] = (theme == "Dark") and entry.dark or entry.light }) end end
    if _G.ToggleStates then for _, toggle in pairs(_G.ToggleStates) do toggle.SetState(toggle.state) end end
end

-- ==================== CONFIG & STATS ====================
local CONFIG = {
    TARGET_MAP = "Sandswept Ruins", TARGET_DIFFICULTY = "Crazy",
    TAS_MODE = "Play", TAS_AUTO_START = false,
    NOCLIP = false, GOD_MODE = false, SPEED = false, INF_JUMP = false, ESP = false, FULLBRIGHT = false, FOV = false,
    SPEED_VAL = 20, FOV_VAL = 90,
    BLACKLIST_ENABLED = true, AUTO_RECONNECT = true, STEALTH_MODE = true, ADMIN_DETECTOR = true, AUTO_LEAVE_ADMIN = false,
    RANDOM_DELAY = true, HIDE_SCRIPT = true, MAP_ROTATION = false, NIGHT_MODE = false, DASHBOARD = true, SMART_ALERTS = true,
    PANIC_MODE = false, COLLECT_ITEMS = true, AIR_SWIM = true, TIMER_HOOK = false, ANTI_REPORT = false, ANTI_ADMIN = false, AUTO_UPDATE = false,
    CUSTOM_FLOOD_COLORS = false, FLOOD_COLOR = "Blue"
}

local Stats = {
    mapsCompleted = 0, totalTime = 0, sessionStart = os.clock(),
    difficultyStats = { Easy = 0, Normal = 0, Hard = 0, Insane = 0, Crazy = 0, ["Crazy+"] = 0 },
    blacklistedSkipped = 0, adminDetected = 0, adminLeft = 0, currentMap = ""
}
local function loadStats() pcall(function() if isfile("Troxzy_Stats.json") then local d = HttpService:JSONDecode(readfile("Troxzy_Stats.json")); for k, v in pairs(d) do if Stats[k] ~= nil then Stats[k] = v end end end end); Stats.sessionStart = os.clock() end
local function saveStats() pcall(function() Stats.totalTime = Stats.totalTime + (os.clock() - Stats.sessionStart); writefile("Troxzy_Stats.json", HttpService:JSONEncode(Stats)); Stats.sessionStart = os.clock() end) end
local function updateStats(d) Stats.mapsCompleted = Stats.mapsCompleted + 1; if d and Stats.difficultyStats[d] then Stats.difficultyStats[d] = Stats.difficultyStats[d] + 1 end end
local function getStatsText() return string.format("Maps: %d  |  Adm: %d", Stats.mapsCompleted, Stats.adminLeft) end

-- ==================== CORE FUNCTIONS ====================
local MapBlacklist = { "Blue Moon", "Poisonous Chasm", "Rustic Jungle", "Luminance" }
local function isMapBlacklisted(n) if not CONFIG.BLACKLIST_ENABLED then return false end; for _, bl in ipairs(MapBlacklist) do if n:lower():find(bl:lower()) then return true end end; return false end

local MapRotation = { "Sandswept Ruins", "Axiom", "Castle Tides", "Lost Woods", "Nimble Valley", "Mayan Remnants", "Sulphureous Sea", "Lava Tower", "Dark Sci-Forest", "Sedimentary Temple", "Abandoned Facility", "Sinking Ship", "Familiar Ruins" }
local rotationIndex = 1
local function rotateMap() if not CONFIG.MAP_ROTATION then return end; CONFIG.TARGET_MAP = MapRotation[rotationIndex]; rotationIndex = rotationIndex + 1; if rotationIndex > #MapRotation then rotationIndex = 1 end end

-- Admin Detection (Fuzzy)
local function isAdminName(str)
    str = str:lower()
    return str:match("^[@_]?[aà]dm?[i1]n[istrator]*$") or str:match("^m[o0]d[erato]*r?$") or str:match("^h[e3]lp[e3]r$") or str:match("^[o0]wn[e3]r$") or str:match("^d[e3]v[eloper]*$") or str:match("^st[a4]ff$") or str:match("^[aà]dm?[i1]n$")
end
local function isAdmin(p) return isAdminName(p.Name) or isAdminName(p.DisplayName) end
local function getAdminPlayers()
    local admins = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player and isAdmin(p) then table.insert(admins, p) end
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
            if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then
                if (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude < 50 then table.insert(specs, p) end
            end
        end
    end
    return specs
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

local function activateGhostMode()
    if isGhostMode then return end
    isGhostMode = true
    getgenv().TomatoAutoFarm = false
    CurrentlyFarming = false
    DisconnectMapDetection()
    StopAutoQueue()
    applyNoclip(false)
    if Player.Character then
        local hum = Player.Character:FindFirstChild("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
    if Main then Main.Visible = false end
    if ToggleBtn then ToggleBtn.Visible = false end
    notify("GHOST MODE - Admin nearby, playing dead", "Ghost Protocol")
    if CONFIG.SMART_ALERTS then playSound(SOUND_IDS.alert) end
end

local function deactivateGhostMode()
    if not isGhostMode then return end
    isGhostMode = false
    if Main then Main.Visible = true end
    if ToggleBtn then ToggleBtn.Visible = true end
    notify("Ghost mode deactivated", "Ghost Protocol")
end

local lastAdminAlert = 0
local function handleAdminDetection()
    if not CONFIG.ADMIN_DETECTOR then return end
    local admins = getAdminPlayers()
    local count = #admins
    if count > 0 then
        if count > lastAdminCount then
            local now = os.clock()
            if now - lastAdminAlert >= 10 then
                lastAdminAlert = now
                Stats.adminDetected = Stats.adminDetected + (count - lastAdminCount)
                notify("Admin detected! Activating ghost mode...", "Anti-Admin")
                if CONFIG.ANTI_ADMIN then blockAdminRemotes() end
                if CONFIG.SMART_ALERTS then playSound(SOUND_IDS.alert) end
                if getgenv().TomatoAutoFarm or AUTO_QUEUE_ENABLED or TAS_RUNNING then
                    activateGhostMode()
                end
            end
        end
    else
        if isGhostMode then deactivateGhostMode() end
    end
    lastAdminCount = count
end

if CONFIG.ANTI_REPORT then pcall(function() Players.ReportAbuse = function() end end) end

local floodColorMap = { Blue = Color3.fromRGB(0, 150, 255), Green = Color3.fromRGB(0, 255, 100), Red = Color3.fromRGB(255, 50, 50), Pink = Color3.fromRGB(255, 100, 200), Purple = Color3.fromRGB(150, 50, 255) }
local function applyFloodColors() if not CONFIG.CUSTOM_FLOOD_COLORS then return end; local targetColor = floodColorMap[CONFIG.FLOOD_COLOR] or Color3.fromRGB(0, 150, 255); for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name:lower():find("water") or v.Name:lower():find("acid") or v.Name:lower():find("lava") or v.Name:lower():find("flood")) then pcall(function() v.Color = targetColor end) end end end
local lastFloodColorUpdate = 0
local function periodicFloodColorUpdate() if not CONFIG.CUSTOM_FLOOD_COLORS then return end; local now = os.clock(); if now - lastFloodColorUpdate < 0.5 then return end; lastFloodColorUpdate = now; applyFloodColors() end

local function isPlayerNearby() if not CONFIG.HIDE_SCRIPT then return false end; local char = Player.Character; if not char then return false end; local root = char:FindFirstChild("HumanoidRootPart"); if not root then return false end; for _, p in pairs(Players:GetPlayers()) do if p ~= Player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then if (root.Position - p.Character.HumanoidRootPart.Position).Magnitude < 20 then return true end end end; return false end

local function attemptReconnect() saveStats(); task.wait(3); pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end); task.wait(2); pcall(function() TeleportService:Teleport(game.PlaceId) end) end
local function setupAutoReconnect() if not CONFIG.AUTO_RECONNECT then return end; TrackConnection(Player:GetPropertyChangedSignal("Parent"):Connect(function() if not Player.Parent then attemptReconnect() end end)); TrackConnection(TeleportService.TeleportInitFailed:Connect(attemptReconnect)); TrackConnection(Player.OnTeleport:Connect(saveStats)) end
local function forceReconnect() saveStats(); task.wait(1); pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end); task.wait(2); pcall(function() TeleportService:Teleport(game.PlaceId) end) end

local DIFFICULTY_RANKS = { ["Easy"] = 1, ["Normal"] = 2, ["Hard"] = 3, ["Insane"] = 4, ["Crazy"] = 5, ["Crazy+"] = 6 }
local function DisconnectMapDetection() if MapDetect then MapDetect:Disconnect(); MapDetect = nil end end

-- ==================== TAS ENGINE (dengan Watchdog) ====================
local function ExecuteTAS()
    if not CONFIG.TAS_AUTO_START then notify("TAS Auto-Start is OFF. Enable it first.", "TAS"); return end
    if TAS_RUNNING then
        if TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE); TAS_COROUTINE = nil end
        TAS_RUNNING = false; task.wait(0.2)
    end
    getgenv().TomatoAutoFarm = false; CurrentlyFarming = false; DisconnectMapDetection()
    local url = CONFIG.TAS_MODE == "Record" and "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TAS/CREATOR/creator.luau" or "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TAS/PLAYER/newtasplayer.luau"
    local success, scriptContent = pcall(function() return game:HttpGet(url) end)
    if not success then notify("Download failed.", "Error"); return end
    local func, compileErr = loadstring(scriptContent)
    if not func then notify("Compile error.", "Error"); return end

    TAS_COROUTINE = coroutine.create(function()
        TAS_RUNNING = true
        local execOk, execErr = pcall(func)
        TAS_RUNNING = false; TAS_COROUTINE = nil
        if AUTO_QUEUE_ENABLED then mapCompleted = true end
        if not execOk then notify("TAS runtime error: " .. tostring(execErr), "Error") else notify("TAS finished!", "Success") end
        if TAS_STATUS_LABEL then TAS_STATUS_LABEL.Text = "Status: ▶ READY" end
    end)
    coroutine.resume(TAS_COROUTINE)
    if TAS_STATUS_LABEL then TAS_STATUS_LABEL.Text = "Status: ▶ RUNNING" end

    task.spawn(function()
        local startTime = os.clock()
        while TAS_RUNNING and os.clock() - startTime < 300 do task.wait(1) end
        if TAS_RUNNING then
            notify("TAS stuck detected! Force stopping...", "Watchdog")
            if TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE); TAS_COROUTINE = nil end
            TAS_RUNNING = false
            if TAS_STATUS_LABEL then TAS_STATUS_LABEL.Text = "Status: ⚠️ STUCK - KILLED" end
        end
    end)
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

local function Check(flag)
    local char = Player.Character
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

local function GetRandomPoint(part) local s = part.Size; return part.CFrame * CFrame.new((math.random()-0.5) * s.X * 0.9, (math.random()-0.5) * s.Y * 0.9, (math.random()-0.5) * s.Z * 0.9) end
local function GetDifficulty()
    local ok, res = pcall(function()
        local diffLabel = Workspace.Lobby.GameInfo.SurfaceGui.Frame.Difficulty.Difficulty
        local raw = diffLabel.Text
        local cleaned = raw:gsub("%s+", " "):lower()
        if cleaned:find("crazy+") or cleaned:find("crazy %+") then return "Crazy+" end
        if cleaned:find("crazy") then return "Crazy" end
        if cleaned:find("insane") then return "Insane" end
        if cleaned:find("hard") then return "Hard" end
        if cleaned:find("normal") then return "Normal" end
        if cleaned:find("easy") then return "Easy" end
        return nil
    end)
    if ok and res then return DIFFICULTY_RANKS[res] or 0, res end
    return 0, "Unknown"
end
local function isRandStr(str) if #str == 0 then return false end; for i = 1, #str do if str:sub(i,i):lower() == str:sub(i,i) then return false end end; return true end

-- ==================== NOCLIP, VISUALS, ESP ====================
local ncCache, ncActive = {}, false
local function refreshNoclip() ncCache = {}; local char = Player.Character; if char then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then table.insert(ncCache, v) end end end end
local function applyNoclip(state) if state == ncActive then return end; ncActive = state; for _, v in ipairs(ncCache) do if v and v.Parent then v.CanCollide = not state end end end
refreshNoclip()

local espCache, lastESPUpdate = {}, 0
local ESP_MAX_DISTANCE = 100
local function updateESP()
    if os.clock() - lastESPUpdate < 0.1 then return end; lastESPUpdate = os.clock()
    if not CONFIG.ESP then for _, hl in pairs(espCache) do pcall(function() hl:Destroy() end) end; espCache = {}; return end
    local myRoot = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Player then
            if plr.Character and not espCache[plr] then
                local distOk = not myRoot or (plr.Character:FindFirstChild("HumanoidRootPart") and (myRoot.Position - plr.Character.HumanoidRootPart.Position).Magnitude <= ESP_MAX_DISTANCE)
                if distOk then
                    local hl = Instance.new("Highlight"); hl.FillColor = Color3.fromRGB(160, 180, 200); hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = plr.Character; espCache[plr] = hl
                end
            elseif not plr.Character and espCache[plr] then pcall(function() espCache[plr]:Destroy() end); espCache[plr] = nil
            elseif plr.Character and espCache[plr] and myRoot and plr.Character:FindFirstChild("HumanoidRootPart") then
                if (myRoot.Position - plr.Character.HumanoidRootPart.Position).Magnitude > ESP_MAX_DISTANCE then pcall(function() espCache[plr]:Destroy() end); espCache[plr] = nil end
            end
        end
    end
    for plr, hl in pairs(espCache) do if not plr.Parent or (plr.Character and hl.Parent ~= plr.Character) then pcall(function() hl:Destroy() end); espCache[plr] = nil end end
end
local function clearESPCache() for _, hl in pairs(espCache) do pcall(function() hl:Destroy() end) end; espCache = {} end

-- ==================== PANIC MODE ====================
local panicActive = false; _G.ToggleStates = {}
local minimizeUI, maximizeUI
local function activatePanicMode()
    panicActive = true; getgenv().TomatoAutoFarm = false; CurrentlyFarming = false; DisconnectMapDetection(); StopAutoQueue(); applyNoclip(false)
    pcall(function() Player.Character.Humanoid.WalkSpeed = 16 end); minimizeUI(true); clearESPCache()
    if isGhostMode then deactivateGhostMode() end
    notify("PANIC MODE ACTIVATED!", "Emergency")
    if _G.ToggleStates["PANIC_MODE"] then _G.ToggleStates["PANIC_MODE"].SetState(true) end
end
local function deactivatePanicMode()
    panicActive = false; getgenv().TomatoAutoFarm = false; CurrentlyFarming = false; pcall(function() Player.Character.Humanoid.WalkSpeed = 16 end)
    applyNoclip(false); maximizeUI(); if _G.ToggleStates["PANIC_MODE"] then _G.ToggleStates["PANIC_MODE"].SetState(false) end
end

local lastVisUpdate, lastFOV = 0, 70
local function updateVisuals() if os.clock() - lastVisUpdate < 0.5 then return end; lastVisUpdate = os.clock(); Lighting.Brightness = CONFIG.FULLBRIGHT and 2 or 1; Lighting.FogEnd = CONFIG.FULLBRIGHT and 99999 or 10000; if Camera then local tfov = CONFIG.FOV and CONFIG.FOV_VAL or 70; if tfov ~= lastFOV then Tween(Camera, {FieldOfView = tfov}); lastFOV = tfov end end; periodicFloodColorUpdate() end

-- ==================== 🔗 WIN ENGINE INTEGRATION ====================
local WIN_SCRIPT_URL = "https://raw.githubusercontent.com/killers-byte/Flood-GUI/refs/heads/main/win"
local WinFarmCoroutine = nil
local WinFarmRunning = false

local function StartWinEngine()
    if WinFarmRunning then return end
    notify("Starting Win Engine...", "Auto Farm")
    local success, scriptContent = pcall(function() return game:HttpGet(WIN_SCRIPT_URL) end)
    if not success or not scriptContent then
        notify("Failed to download Win Engine!", "Error")
        getgenv().TomatoAutoFarm = false
        return
    end
    local func, err = loadstring(scriptContent)
    if not func then
        notify("Win Engine compile error: " .. tostring(err), "Error")
        getgenv().TomatoAutoFarm = false
        return
    end

    WinFarmCoroutine = coroutine.create(function()
        WinFarmRunning = true
        -- Win script diasumsikan menggunakan getgenv().TomatoAutoFarm sebagai saklar
        pcall(func)
        WinFarmRunning = false
        WinFarmCoroutine = nil
        notify("Win Engine finished.", "Auto Farm")
    end)
    coroutine.resume(WinFarmCoroutine)
    notify("Win Engine is now controlling the farm.", "Success")
end

local function StopWinEngine()
    if not WinFarmRunning then return end
    notify("Stopping Win Engine...", "Auto Farm")
    if WinFarmCoroutine then
        pcall(coroutine.close, WinFarmCoroutine)
        WinFarmCoroutine = nil
    end
    WinFarmRunning = false
    CurrentlyFarming = false
    DisconnectMapDetection()
    notify("Win Engine stopped.", "Auto Farm")
end

function ConnectMapDetection()
    -- Tidak diperlukan lagi karena Win script menangani deteksi map sendiri
end

-- ==================== AUTO QUEUE & LIFT ====================
local function findLiftPosition()
    for _, obj in pairs(Workspace.Lobby:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("lift") then
            return obj.Position + Vector3.new(0, 5, 0)
        end
    end
    return Vector3.new(25, 7, 85)
end

TrackConnection(RunService.Heartbeat:Connect(function()
    if moveToLift and (AUTO_QUEUE_ENABLED or getgenv().TomatoAutoFarm) and not panicActive and not TAS_RUNNING and not isGhostMode then
        local char = Player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if char and hum and hrp and hum.Health > 0 then
            if not Check("InGame") and not Check("InLift") then
                if liftTarget then
                    local dir = (liftTarget - hrp.Position)
                    if dir.Magnitude > 3 then hum:MoveTo(liftTarget); hum.WalkSpeed = 25
                    else pcall(function() AddedWaiting:FireServer() end); moveToLift = false end
                end
            elseif Check("InLift") then
                pcall(function() AddedWaiting:FireServer() end); moveToLift = false
            end
        end
    end
end))

local function StartAutoQueue()
    if AutoQueueListener then AutoQueueListener:Disconnect(); AutoQueueListener = nil end
    moveToLift = false; mapCompleted = false
    AutoQueueListener = Multiplayer.ChildAdded:Connect(function(newMap)
        if not AUTO_QUEUE_ENABLED or panicActive or isGhostMode then return end
        pcall(function() local settings = newMap:WaitForChild("Settings", 5); if settings then Stats.currentMap = settings:GetAttribute("MapName") or "Unknown" end end)
        repeat task.wait() until Check("InGame")
        mapCompleted = false
        if not TAS_RUNNING then
            getgenv().TomatoAutoFarm = false; CurrentlyFarming = false; DisconnectMapDetection()
            task.spawn(ExecuteTAS)
        end
    end)
    TrackConnection(AutoQueueListener)
    notify("Auto Queue 60FPS Active + Walk to Lift", "Queue")
end

local function StopAutoQueue()
    if AutoQueueListener then AutoQueueListener:Disconnect(); AutoQueueListener = nil end
    moveToLift = false
    if TAS_RUNNING and TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE); TAS_COROUTINE = nil; TAS_RUNNING = false end
    notify("Auto Queue dihentikan.", "Queue")
end

task.spawn(function()
    while task.wait(0.5) do
        if (AUTO_QUEUE_ENABLED or getgenv().TomatoAutoFarm) and not panicActive and not isGhostMode then
            local char = Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and not Check("InGame") and not Check("InLift") and not TAS_RUNNING and not CurrentlyFarming then
                moveToLift = true; liftTarget = findLiftPosition()
            else moveToLift = false end
        else moveToLift = false end
    end
end)

TrackConnection(Player.CharacterAdded:Connect(function()
    if not Player.Character then Player.CharacterAdded:Wait() end
    refreshNoclip(); ncActive = false; if not Check("InGame") then mapCompleted = false end
end))

-- ==================== PROFESSIONAL UI (V21.0) ====================
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "TROXZY_VIP"; ScreenGui.ResetOnSpawn = false
if not pcall(function() ScreenGui.Parent = CoreGui end) then ScreenGui.Parent = Player.PlayerGui end

ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,50,0,50); ToggleBtn.Position = IS_MOBILE and UDim2.new(0.88,0,0.05,0) or UDim2.new(0.015,0,0.015,0)
ToggleBtn.BackgroundColor3 = DARK_THEME.HeaderBg; ToggleBtn.Text = "⚡"; ToggleBtn.TextSize = 22; ToggleBtn.Font = Enum.Font.GothamBlack; ToggleBtn.TextColor3 = DARK_THEME.Accent
addCorner(ToggleBtn, 12); addStroke(ToggleBtn, DARK_THEME.Border, 1, 0.9); ToggleBtn.Parent = ScreenGui

Main = Instance.new("Frame")
Main.Size = UDim2.new(0,390,0,540); Main.Position = UDim2.new(0.5,-195,0.5,-270); Main.BackgroundColor3 = DARK_THEME.MainBg; Main.BorderSizePixel = 0; Main.Visible = true; Main.Active = true; Main.Draggable = true
addCorner(Main, 10); addStroke(Main, DARK_THEME.Border, 1, 0.85); Main.Parent = ScreenGui
RegisterThemeObject(Main, "BackgroundColor3", DARK_THEME.MainBg, LIGHT_THEME.MainBg)

local Header = Instance.new("Frame"); Header.Size = UDim2.new(1,0,0,60); Header.BackgroundColor3 = DARK_THEME.HeaderBg; Header.BorderSizePixel = 0; addCorner(Header, 10); Header.Parent = Main
RegisterThemeObject(Header, "BackgroundColor3", DARK_THEME.HeaderBg, LIGHT_THEME.HeaderBg)
local hc = Instance.new("Frame"); hc.Size = UDim2.new(1,0,0.5,0); hc.Position = UDim2.new(0,0,0.5,0); hc.BackgroundColor3 = DARK_THEME.HeaderBg; hc.BorderSizePixel = 0; hc.Parent = Header
RegisterThemeObject(hc, "BackgroundColor3", DARK_THEME.HeaderBg, LIGHT_THEME.HeaderBg)

local AvatarFrame = Instance.new("Frame"); AvatarFrame.Size = UDim2.new(0,40,0,40); AvatarFrame.Position = UDim2.new(0,14,0.5,-20); AvatarFrame.BackgroundColor3 = DARK_THEME.Accent; addCorner(AvatarFrame, 20); AvatarFrame.Parent = Header
local Avatar = Instance.new("ImageLabel"); Avatar.Size = UDim2.new(0,36,0,36); Avatar.Position = UDim2.new(0,2,0,2); Avatar.BackgroundColor3 = DARK_THEME.MainBg; addCorner(Avatar, 18); Avatar.Parent = AvatarFrame
task.spawn(function() pcall(function() Avatar.Image = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end) end)

local PlayerName = Instance.new("TextLabel"); PlayerName.Size = UDim2.new(0,150,0,18); PlayerName.Position = UDim2.new(0,65,0.5,-16); PlayerName.Text = Player.DisplayName; PlayerName.TextColor3 = DARK_THEME.TextBright; PlayerName.TextSize = 14; PlayerName.Font = Enum.Font.GothamBold; PlayerName.BackgroundTransparency = 1; PlayerName.TextXAlignment = Enum.TextXAlignment.Left; PlayerName.Parent = Header
RegisterThemeObject(PlayerName, "TextColor3", DARK_THEME.TextBright, LIGHT_THEME.TextBright)

local Username = Instance.new("TextLabel"); Username.Size = UDim2.new(0,150,0,14); Username.Position = UDim2.new(0,65,0.5,4); Username.Text = "@" .. Player.Name; Username.TextColor3 = DARK_THEME.TextDim; Username.TextSize = 11; Username.Font = Enum.Font.Gotham; Username.BackgroundTransparency = 1; Username.TextXAlignment = Enum.TextXAlignment.Left; Username.Parent = Header
RegisterThemeObject(Username, "TextColor3", DARK_THEME.TextDim, LIGHT_THEME.TextDim)

local TitleLabel = Instance.new("TextLabel"); TitleLabel.Size = UDim2.new(0,120,0,20); TitleLabel.Position = UDim2.new(1,-134,0.5,-13); TitleLabel.Text = "SPECTRAL BLADE"; TitleLabel.TextColor3 = DARK_THEME.Accent; TitleLabel.TextSize = 13; TitleLabel.Font = Enum.Font.GothamBlack; TitleLabel.BackgroundTransparency = 1; TitleLabel.TextXAlignment = Enum.TextXAlignment.Right; TitleLabel.Parent = Header
RegisterThemeObject(TitleLabel, "TextColor3", DARK_THEME.Accent, LIGHT_THEME.Accent)

local Divider = Instance.new("Frame"); Divider.Size = UDim2.new(1, -28, 0, 1); Divider.Position = UDim2.new(0, 14, 0, 60); Divider.BackgroundColor3 = DARK_THEME.Border; Divider.BackgroundTransparency = 0.9; Divider.BorderSizePixel = 0; Divider.Parent = Main
RegisterThemeObject(Divider, "BackgroundColor3", DARK_THEME.Border, LIGHT_THEME.Border)

local StatsBar = Instance.new("Frame"); StatsBar.Size = UDim2.new(1,-28,0,28); StatsBar.Position = UDim2.new(0,14,0,70); StatsBar.BackgroundColor3 = DARK_THEME.StatsBg; addCorner(StatsBar, 6); addStroke(StatsBar, DARK_THEME.Border, 1, 0.9); StatsBar.Parent = Main
RegisterThemeObject(StatsBar, "BackgroundColor3", DARK_THEME.StatsBg, LIGHT_THEME.StatsBg)

local StatsLabel = Instance.new("TextLabel"); StatsLabel.Size = UDim2.new(1,0,1,0); StatsLabel.BackgroundTransparency = 1; StatsLabel.Text = getStatsText(); StatsLabel.TextColor3 = DARK_THEME.StatsText; StatsLabel.Font = Enum.Font.GothamMedium; StatsLabel.TextSize = 11; StatsLabel.Parent = StatsBar
RegisterThemeObject(StatsLabel, "TextColor3", DARK_THEME.StatsText, LIGHT_THEME.StatsText)
task.spawn(function() while task.wait(5) do pcall(function() StatsLabel.Text = getStatsText() end) end end)

local TabBar = Instance.new("Frame"); TabBar.Size = UDim2.new(1,-28,0,36); TabBar.Position = UDim2.new(0,14,0,108); TabBar.BackgroundTransparency = 1; TabBar.Parent = Main
local TabList = Instance.new("UIListLayout"); TabList.FillDirection = Enum.FillDirection.Horizontal; TabList.Padding = UDim.new(0,4); TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center; TabList.VerticalAlignment = Enum.VerticalAlignment.Center; TabList.Parent = TabBar

local tabItems = { {name="TAS", key="TAS"}, {name="Farm", key="Farm"}, {name="Move", key="Move"}, {name="Visual", key="Visual"}, {name="Stealth", key="Stealth"}, {name="Premium", key="Premium"}, {name="Extra", key="Extra"} }
local tabBtns, tabContents = {}, {}

for i, tab in ipairs(tabItems) do
    local tabBtn = Instance.new("TextButton"); tabBtn.Size = UDim2.new(0.13,0,0,32); tabBtn.BackgroundColor3 = (tab.key=="TAS") and DARK_THEME.TabActive or DARK_THEME.TabInactive; tabBtn.Text = tab.name; tabBtn.TextSize = 9; tabBtn.Font = Enum.Font.GothamBold; tabBtn.TextColor3 = (tab.key=="TAS") and DARK_THEME.TextBright or DARK_THEME.TextDim; tabBtn.AutoButtonColor = false
    addCorner(tabBtn, 6); tabBtn.Parent = TabBar; table.insert(tabBtns, tabBtn)

    local contentFrame = Instance.new("Frame"); contentFrame.Size = UDim2.new(1,-28,1,-165); contentFrame.Position = UDim2.new(0,14,0,155); contentFrame.BackgroundTransparency = 1; contentFrame.Visible = (tab.key=="TAS"); contentFrame.Parent = Main

    local scrollFrame = Instance.new("ScrollingFrame"); scrollFrame.Size = UDim2.new(1,0,1,0); scrollFrame.BackgroundTransparency = 1; scrollFrame.ScrollBarThickness = 2; scrollFrame.ScrollBarImageColor3 = DARK_THEME.Accent; scrollFrame.CanvasSize = UDim2.new(0,0,0,0); scrollFrame.ScrollingEnabled = true; scrollFrame.Parent = contentFrame

    local scrollLayout = Instance.new("UIListLayout"); scrollLayout.Padding = UDim.new(0,6); scrollLayout.Parent = scrollFrame
    scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scrollFrame.CanvasSize = UDim2.new(0,0,0,scrollLayout.AbsoluteContentSize.Y + 15) end)

    table.insert(tabContents, {scroll=scrollFrame, layout=scrollLayout})

    tabBtn.MouseButton1Click:Connect(function()
        for j, btn in ipairs(tabBtns) do
            if j==i then Tween(btn, {BackgroundColor3 = DARK_THEME.TabActive, TextColor3 = DARK_THEME.TextBright}); tabContents[j].scroll.Parent.Visible = true
            else Tween(btn, {BackgroundColor3 = DARK_THEME.TabInactive, TextColor3 = DARK_THEME.TextDim}); tabContents[j].scroll.Parent.Visible = false end
        end
    end)
    tabBtn.MouseEnter:Connect(function() if tabContents[i].scroll.Parent.Visible == false then Tween(tabBtn, {BackgroundColor3 = Color3.fromRGB(35,35,50)}) end end)
    tabBtn.MouseLeave:Connect(function() if tabContents[i].scroll.Parent.Visible == false then Tween(tabBtn, {BackgroundColor3 = DARK_THEME.TabInactive}) end end)
end

-- UI Helpers
local function AddSection(tabKey, title) local tabIdx; for i, t in ipairs(tabItems) do if t.key==tabKey then tabIdx=i; break end end; if not tabIdx then return end; local s = Instance.new("TextLabel"); s.Size = UDim2.new(1,0,0,24); s.Text = "  " .. title; s.TextColor3 = DARK_THEME.Accent; s.Font = Enum.Font.GothamBlack; s.TextSize = 11; s.BackgroundTransparency = 1; s.TextXAlignment = Enum.TextXAlignment.Left; s.Parent = tabContents[tabIdx].scroll end
local function AddButton(tabKey, name, color, callback) local tabIdx; for i, t in ipairs(tabItems) do if t.key==tabKey then tabIdx=i; break end end; if not tabIdx then return end; local b = Instance.new("TextButton"); b.Size = UDim2.new(1,0,0,38); b.BackgroundColor3 = color; b.Text = name; b.TextSize = 12; b.Font = Enum.Font.GothamBold; b.TextColor3 = Color3.fromRGB(255,255,255); b.AutoButtonColor = false; addCorner(b,6); addStroke(b, Color3.new(1,1,1), 1, 0.9); b.Parent = tabContents[tabIdx].scroll; b.MouseEnter:Connect(function() Tween(b, {BackgroundColor3 = Color3.new(color.R*0.8, color.G*0.8, color.B*0.8)}) end); b.MouseLeave:Connect(function() Tween(b, {BackgroundColor3 = color}) end); b.MouseButton1Click:Connect(function() Tween(b, {Size = UDim2.new(0.98,0,0,34)}, 0.1); task.wait(0.1); Tween(b, {Size = UDim2.new(1,0,0,38)}, 0.1); pcall(callback) end); return b end
local function AddInfoLabel(tabKey, text) local tabIdx; for i, t in ipairs(tabItems) do if t.key==tabKey then tabIdx=i; break end end; if not tabIdx then return end; local l = Instance.new("TextLabel"); l.Size = UDim2.new(1,0,0,36); l.BackgroundColor3 = DARK_THEME.InfoBg; l.Text = text; l.TextColor3 = DARK_THEME.InfoText; l.Font = Enum.Font.GothamMedium; l.TextSize = 11; addCorner(l,6); addStroke(l, DARK_THEME.Border, 1, 0.9); l.Parent = tabContents[tabIdx].scroll; RegisterThemeObject(l, "BackgroundColor3", DARK_THEME.InfoBg, LIGHT_THEME.InfoBg); return l end
local function AddToggle(tabKey, name, stateKey) local tabIdx; for i, t in ipairs(tabItems) do if t.key==tabKey then tabIdx=i; break end end; if not tabIdx then return end; local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,40); f.BackgroundColor3 = DARK_THEME.ToggleBg; addCorner(f,6); addStroke(f, DARK_THEME.Border, 1, 0.9); f.Parent = tabContents[tabIdx].scroll; RegisterThemeObject(f, "BackgroundColor3", DARK_THEME.ToggleBg, LIGHT_THEME.ToggleBg)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.6,0,1,0); lbl.Position = UDim2.new(0,14,0,0); lbl.Text = name; lbl.TextColor3 = DARK_THEME.TextMedium; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = f
    local sb = Instance.new("Frame"); sb.Size = UDim2.new(0,40,0,20); sb.Position = UDim2.new(1,-54,0.5,-10); sb.BackgroundColor3 = DARK_THEME.ToggleBg; addCorner(sb,10); addStroke(sb, DARK_THEME.Border, 1, 0.8); sb.Parent = f
    local dot = Instance.new("Frame"); dot.Size = UDim2.new(0,14,0,14); dot.Position = UDim2.new(0,3,0.5,-7); dot.BackgroundColor3 = DARK_THEME.ToggleDot; addCorner(dot,7); dot.Parent = sb
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = f

    local state = false
    local function setToggleUI(st) state = st; local t = (currentTheme == "Dark") and DARK_THEME or LIGHT_THEME; local pos = st and UDim2.new(0,23,0.5,-7) or UDim2.new(0,3,0.5,-7); Tween(dot, {Position = pos, BackgroundColor3 = st and Color3.fromRGB(255,255,255) or t.ToggleDot}); Tween(sb, {BackgroundColor3 = st and t.Accent or t.ToggleBg}); Tween(lbl, {TextColor3 = st and t.TextBright or t.TextMedium}) end
    if stateKey then _G.ToggleStates[stateKey] = { state = false, dot = dot, sb = sb, btn = btn, SetState = setToggleUI } end

    btn.MouseButton1Click:Connect(function()
        state = not state; setToggleUI(state)
        if stateKey == "AUTO_QUEUE" then AUTO_QUEUE_ENABLED = state; if state then CONFIG.TAS_MODE = "Play"; CONFIG.TAS_AUTO_START = true; mapCompleted = false; if _G.ToggleStates["TAS_AUTO_START"] then _G.ToggleStates["TAS_AUTO_START"].SetState(true) end; StartAutoQueue() else StopAutoQueue() end
        elseif stateKey == "AutoFarm" then
            getgenv().TomatoAutoFarm = state
            if state then
                StartWinEngine()
            else
                StopWinEngine()
            end
        elseif stateKey == "NIGHT_MODE" then applyTheme(state and "Light" or "Dark")
        elseif stateKey == "DASHBOARD" then CONFIG.DASHBOARD = state; if _G.DashboardUI then _G.DashboardUI.Visible = state end
        elseif stateKey == "PANIC_MODE" then if state then activatePanicMode() else deactivatePanicMode() end
        else CONFIG[stateKey] = state end
    end)
    return { Toggle = setToggleUI, Frame = f }
end
local function AddInput(tabKey, label, defaultVal, callback) local tabIdx; for i, t in ipairs(tabItems) do if t.key==tabKey then tabIdx=i; break end end; if not tabIdx then return end; local f = Instance.new("Frame"); f.Size = UDim2.new(1,0,0,44); f.BackgroundColor3 = DARK_THEME.ToggleBg; addCorner(f,6); addStroke(f, DARK_THEME.Border, 1, 0.9); f.Parent = tabContents[tabIdx].scroll; RegisterThemeObject(f, "BackgroundColor3", DARK_THEME.ToggleBg, LIGHT_THEME.ToggleBg)
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0.5,0,1,0); lbl.Position = UDim2.new(0,14,0,0); lbl.Text = label; lbl.TextColor3 = DARK_THEME.TextMedium; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.Parent = f
    local inp = Instance.new("TextBox"); inp.Size = UDim2.new(0,70,0,26); inp.Position = UDim2.new(1,-84,0.5,-13); inp.BackgroundColor3 = DARK_THEME.InputBg; inp.TextColor3 = DARK_THEME.TextBright; inp.PlaceholderText = tostring(defaultVal); inp.Text = tostring(defaultVal); inp.Font = Enum.Font.GothamBold; inp.TextSize = 11; addCorner(inp,6); addStroke(inp, DARK_THEME.Border, 1, 0.8); inp.Parent = f
    inp.FocusLost:Connect(function() local v = tonumber(inp.Text); if v then callback(v) else inp.Text = tostring(defaultVal) end end)
end

-- ==================== SMOOTH MINIMIZE/MAXIMIZE ====================
minimizeUI = function(instant)
    if not Main.Visible then return end
    if instant then Main.Visible = false; Main.Size = UDim2.new(0,390,0,0); Main.BackgroundTransparency = 0; isMinimized = true; return end
    isMinimized = true
    local t = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0,390,0,0), BackgroundTransparency = 1 })
    t:Play()
    t.Completed:Connect(function() Main.Visible = false; Main.Size = UDim2.new(0,390,0,0); Main.BackgroundTransparency = 0 end)
end
maximizeUI = function()
    if Main.Visible then return end
    isMinimized = false; Main.Visible = true; Main.Size = UDim2.new(0,390,0,0); Main.BackgroundTransparency = 1
    local t = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(0,390,0,540), BackgroundTransparency = 0 })
    t:Play()
end

-- ==================== DASHBOARD ====================
local Dashboard = Instance.new("Frame"); Dashboard.Size = UDim2.new(0, 230, 0, 0); Dashboard.Position = UDim2.new(0.985, 0, 0.015, 0); Dashboard.AnchorPoint = Vector2.new(1, 0); Dashboard.BackgroundColor3 = DARK_THEME.MainBg; Dashboard.AutomaticSize = Enum.AutomaticSize.Y; Dashboard.Visible = CONFIG.DASHBOARD; addCorner(Dashboard, 8); addStroke(Dashboard, DARK_THEME.Accent, 1, 0.6); Dashboard.Parent = ScreenGui; _G.DashboardUI = Dashboard
local DPad = Instance.new("UIPadding"); DPad.PaddingTop = UDim.new(0, 12); DPad.PaddingBottom = UDim.new(0, 12); DPad.PaddingLeft = UDim.new(0, 12); DPad.PaddingRight = UDim.new(0, 12); DPad.Parent = Dashboard
local DLayout = Instance.new("UIListLayout"); DLayout.SortOrder = Enum.SortOrder.LayoutOrder; DLayout.Padding = UDim.new(0, 6); DLayout.Parent = Dashboard
local function createDashLabel(text, order, color) local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, 0, 0, 16); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = color or DARK_THEME.TextBright; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextWrapped = true; lbl.AutomaticSize = Enum.AutomaticSize.Y; lbl.RichText = true; lbl.LayoutOrder = order; lbl.Parent = Dashboard; return lbl end
local function createDashDivider(order) local div = Instance.new("Frame"); div.Size = UDim2.new(1, 0, 0, 1); div.BackgroundColor3 = DARK_THEME.Border; div.BackgroundTransparency = 0.85; div.BorderSizePixel = 0; div.LayoutOrder = order; div.Parent = Dashboard; return div end

local dTitle = createDashLabel("<b>?? SYSTEM OVERVIEW</b>", 1, DARK_THEME.Accent); dTitle.Font = Enum.Font.GothamBlack; dTitle.TextSize = 12
createDashDivider(2)
local mapLabel = createDashLabel("??? <b>Map:</b> Waiting...", 3)
local timeLabel = createDashLabel("?? <b>Time:</b> 0m", 4, DARK_THEME.TextMedium)
local speedLabel = createDashLabel("? <b>Rate:</b> 0 maps/hr", 5, DARK_THEME.TextMedium)
local statusLabel = createDashLabel("? <b>Status:</b> Idle", 6, Color3.fromRGB(0, 230, 120))
local ghostStatusLabel = createDashLabel("?? <b>Ghost Mode:</b> Inactive", 7, Color3.fromRGB(180, 180, 180))
local keyDurationLabel = createDashLabel("? <b>Key Expires In:</b> ...", 8, Color3.fromRGB(255, 200, 100))
createDashDivider(9)
local adminInfoLabel = createDashLabel("??? <b>Admins:</b> None", 10, Color3.fromRGB(100, 255, 100))
local spectatorInfoLabel = createDashLabel("?? <b>Spectators:</b> None", 11, Color3.fromRGB(180, 180, 180))

local function updateDashboard()
    if not Dashboard.Visible then return end
    local remaining = keyExpireTime - GetRealTime()
    if remaining <= 0 then Player:Kick("Key expired! Silakan beli key baru dari penjual."); return end
    if keyExpireTime > GetRealTime() + 315360000 then keyDurationLabel.Text = "? <b>Key: PERMANENT</b>"; keyDurationLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        local days = math.floor(remaining / 86400); local hours = math.floor((remaining % 86400) / 3600); local minutes = math.floor((remaining % 3600) / 60); local seconds = math.floor(remaining % 60)
        if remaining < 300 then keyDurationLabel.TextColor3 = Color3.fromRGB(255, 80, 80) elseif remaining < 3600 then keyDurationLabel.TextColor3 = Color3.fromRGB(255, 200, 0) else keyDurationLabel.TextColor3 = Color3.fromRGB(150, 200, 255) end
        if days > 0 then keyDurationLabel.Text = "? <b>Expires In:</b> " .. days .. "d " .. hours .. "h " .. minutes .. "m " .. seconds .. "s" else keyDurationLabel.Text = "? <b>Expires In:</b> " .. hours .. "h " .. minutes .. "m " .. seconds .. "s" end
    end
    mapLabel.Text = "??? <b>Map:</b> " .. (Stats.currentMap and Stats.currentMap ~= "" and Stats.currentMap or "Waiting...")
    timeLabel.Text = "?? <b>Time:</b> " .. math.floor((os.clock() - Stats.sessionStart) / 60) .. "m"
    local sessionHours = (os.clock() - Stats.sessionStart) / 3600
    speedLabel.Text = "? <b>Rate:</b> " .. ((sessionHours > 0 and Stats.mapsCompleted > 0) and math.floor(Stats.mapsCompleted / sessionHours) or 0) .. " maps/hr"
    if isGhostMode then ghostStatusLabel.Text = "?? <b>Ghost Mode:</b> ACTIVE"; ghostStatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
    else ghostStatusLabel.Text = "?? <b>Ghost Mode:</b> Inactive"; ghostStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180) end
    if panicActive then statusLabel.Text = "? <b>Status:</b> PANIC"; statusLabel.TextColor3 = Color3.fromRGB(255,80,80)
    elseif TAS_RUNNING then statusLabel.Text = "? <b>Status:</b> TAS PLAYING"; statusLabel.TextColor3 = Color3.fromRGB(0,230,120)
    elseif AUTO_QUEUE_ENABLED then statusLabel.Text = "? <b>Status:</b> Auto Queue"; statusLabel.TextColor3 = Color3.fromRGB(100,200,255)
    elseif CONFIG.STEALTH_MODE then statusLabel.Text = "? <b>Status:</b> Stealth"; statusLabel.TextColor3 = Color3.fromRGB(255,180,50)
    else statusLabel.Text = "? <b>Status:</b> Idle"; statusLabel.TextColor3 = DARK_THEME.TextDim end
    local admins = getAdminPlayers()
    if #admins > 0 then local adminTexts = {}; for _, adm in ipairs(admins) do table.insert(adminTexts, string.format(" - %s (@%s)", adm.DisplayName, adm.Name)) end; adminInfoLabel.Text = "??? <b>Admins:</b>\n" .. table.concat(adminTexts, "\n"); adminInfoLabel.TextColor3 = Color3.fromRGB(255,80,80)
    else adminInfoLabel.Text = "??? <b>Admins:</b> None"; adminInfoLabel.TextColor3 = Color3.fromRGB(100,255,100) end
    local spectators = getSpectators()
    if #spectators > 0 then local specTexts = {}; for _, spec in ipairs(spectators) do table.insert(specTexts, " - " .. spec.DisplayName) end; spectatorInfoLabel.Text = "?? <b>Spectators:</b>\n" .. table.concat(specTexts, "\n"); spectatorInfoLabel.TextColor3 = Color3.fromRGB(255,200,0)
    else spectatorInfoLabel.Text = "?? <b>Spectators:</b> None"; spectatorInfoLabel.TextColor3 = Color3.fromRGB(180,180,180) end
end

-- ==================== MENU BUILDING ====================
AddSection("TAS", "SEAMLESS AUTOMATION")
AddToggle("TAS", "Seamless Auto Queue", "AUTO_QUEUE")
AddToggle("TAS", "Auto-Start Play", "TAS_AUTO_START")
AddButton("TAS", "Record Route", DARK_THEME.ButtonRecord, function() if not CONFIG.TAS_AUTO_START then notify("Enable Auto-Start"); return end; CONFIG.TAS_MODE="Record"; task.spawn(ExecuteTAS) end)
AddButton("TAS", "Force Play Route", DARK_THEME.Accent, function() if not CONFIG.TAS_AUTO_START then notify("Enable Auto-Start"); return end; CONFIG.TAS_MODE="Play"; task.spawn(ExecuteTAS) end)
TAS_STATUS_LABEL = AddInfoLabel("TAS", "Status: ▶ READY")

AddSection("Farm", "CORE (Win Engine)")
AddToggle("Farm", "Enable Auto Farm", "AutoFarm")
AddInfoLabel("Farm", "Target: " .. CONFIG.TARGET_MAP)

AddSection("Move", "CHARACTER")
AddToggle("Move", "Noclip Bypass", "NOCLIP")
AddToggle("Move", "Speed Modifier", "SPEED")
AddInput("Move", "Speed Value", CONFIG.SPEED_VAL, function(v) CONFIG.SPEED_VAL=v end)
AddToggle("Move", "Infinite Jump", "INF_JUMP")

AddSection("Visual", "RENDERING")
AddToggle("Visual", "God Mode", "GOD_MODE")
AddToggle("Visual", "Player ESP (Culled)", "ESP")
AddToggle("Visual", "Fullbright", "FULLBRIGHT")
AddToggle("Visual", "FOV Override", "FOV")
AddInput("Visual", "Field of View", CONFIG.FOV_VAL, function(v) CONFIG.FOV_VAL=v end)
AddToggle("Visual", "Live Dashboard", "DASHBOARD")

AddSection("Stealth", "SECURITY")
AddToggle("Stealth", "Humanized Delay", "RANDOM_DELAY")
AddToggle("Stealth", "Stealth Movement", "STEALTH_MODE")
AddToggle("Stealth", "Hide GUI Nearby", "HIDE_SCRIPT")
AddToggle("Stealth", "Detect Admins (Fuzzy)", "ADMIN_DETECTOR")
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
            notify("Update found! Reloading script...", "Updater"); task.wait(1.5)
            local func, compileErr = loadstring(newScript)
            if func then func() else notify("Compile Error: " .. tostring(compileErr), "Error") end
        else notify("Failed to fetch update or network error.", "Updater") end
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

local CloseBtn = Instance.new("TextButton"); CloseBtn.Size = UDim2.new(1,-28,0,32); CloseBtn.Position = UDim2.new(0,14,1,-42); CloseBtn.BackgroundColor3 = DARK_THEME.ButtonPanic; CloseBtn.Text = "Minimize UI"; CloseBtn.TextSize = 11; CloseBtn.Font = Enum.Font.GothamBold; CloseBtn.TextColor3 = Color3.fromRGB(255,255,255); addCorner(CloseBtn,6); CloseBtn.Parent = Main
CloseBtn.MouseButton1Click:Connect(function() minimizeUI(false) end)
ToggleBtn.MouseButton1Click:Connect(function() if isMinimized then maximizeUI() else minimizeUI(false) end end)

-- ==================== EVENT LOOPS ====================
TrackConnection(UIS.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == Enum.KeyCode.P then if not panicActive then activatePanicMode() else deactivatePanicMode() end end end))

local lastHeartbeat = 0
TrackConnection(RunService.Heartbeat:Connect(function()
    if os.clock() - lastHeartbeat < 0.1 then return end; lastHeartbeat = os.clock()
    pcall(function()
        local ch = Player.Character; if not ch then return end; local hum = ch:FindFirstChild("Humanoid"); if not hum then return end
        if CONFIG.NOCLIP and not CurrentlyFarming then refreshNoclip(); applyNoclip(true) elseif not CurrentlyFarming then applyNoclip(false) end
        if not CurrentlyFarming then local baseSpeed = moveToLift and 20 or 16; hum.WalkSpeed = CONFIG.SPEED and CONFIG.SPEED_VAL or baseSpeed end
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not CONFIG.GOD_MODE)
        if CONFIG.AIR_SWIM and hum:GetState() == Enum.HumanoidStateType.Swimming then hum:ChangeState(Enum.HumanoidStateType.Landed); hum.PlatformStand = false; task.wait(0.05); hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
    if os.clock() - lastDashboardUpdate >= 1 then lastDashboardUpdate = os.clock(); pcall(updateDashboard); pcall(handleAdminDetection) end
end))
TrackConnection(RunService.Heartbeat:Connect(function() pcall(updateESP); pcall(updateVisuals) end))
TrackConnection(UIS.JumpRequest:Connect(function() if CONFIG.INF_JUMP and Player.Character then local h = Player.Character:FindFirstChild("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end))

loadStats()
setupAutoReconnect()
notify("SPECTRAL BLADE v22.1 - Win Engine Integrated", "System")
print("TROXZY: Spectral Blade v22.1 fully operational.")
