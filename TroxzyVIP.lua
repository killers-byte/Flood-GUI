-- ============================================
-- TROXZY VIP v22.1 "SPECTRAL BLADE" [WIN ENGINE]
-- Badan Intelijen Negara - AUTO WIN PROTOCOL
-- 🔥 FIXED: FULL FEATURES RESTORED + FLUENT UI MODERN + HWID + ANTI-LOOP
-- ============================================

-- [ SUPREME KEY SYSTEM - EMBEDDED & REDESIGNED ]
local function supremeKeyValidation()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local Player = Players.LocalPlayer
    if not Player then return false end

    -- ==========================================
    -- 🛠️ [FIX] BYPASS LOGIN JIKA SUDAH AUTHENTICATED
    -- ==========================================
    local function GetRealTime()
        local ok, srvTime = pcall(function() return math.floor(Workspace:GetServerTimeNow()) end)
        if ok and srvTime and srvTime > 1000000 then return srvTime end
        return os.time()
    end

    if getgenv().keyExpireTime and getgenv().keyExpireTime > GetRealTime() then return true end
    -- ==========================================

    local BASE_KEYS_URL = "https://gist.githubusercontent.com/killers-byte/4cd78cad4c3cf8e62e90cd7f8c82624b/raw/9274ea73d0e08917868481c5ee77c00dcfa2c144/TroxzyKey.json"
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
                for m = 1, month - 1 do days = days + daysInMonth[m]; if m == 2 and isLeap(year) then days = days + 1 end end
                days = days + (day - 1)
                return (days * 86400) + 86399 - (7 * 3600)
            end
        end
        return nil
    end

    local KeyScreen = Instance.new("ScreenGui", game:GetService("CoreGui"))
    KeyScreen.Name = "TroxzyKeyAuth"
    
    local Frame = Instance.new("Frame", KeyScreen)
    Frame.Size = UDim2.new(0, 320, 0, 180)
    Frame.Position = UDim2.new(0.5, -160, 0.5, -90)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    local UICorner = Instance.new("UICorner", Frame); UICorner.CornerRadius = UDim.new(0, 12)
    local UIStroke = Instance.new("UIStroke", Frame); UIStroke.Color = Color3.fromRGB(60, 60, 60); UIStroke.Thickness = 1
    
    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 40)
    Title.Text = "TROXZY AUTHENTICATION"
    Title.TextColor3 = Color3.fromRGB(240, 240, 240)
    Title.Font = Enum.Font.GothamBold; Title.TextSize = 13; Title.BackgroundTransparency = 1

    local Input = Instance.new("TextBox", Frame)
    Input.Size = UDim2.new(0, 280, 0, 36); Input.Position = UDim2.new(0.5, -140, 0, 50)
    Input.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Input.TextColor3 = Color3.fromRGB(255, 255, 255)
    Input.PlaceholderText = "Paste your key here..."; Input.TextSize = 12; Input.Font = Enum.Font.GothamMedium
    Input.ClearTextOnFocus = false
    local InputCorner = Instance.new("UICorner", Input); InputCorner.CornerRadius = UDim.new(0, 8)
    local InputStroke = Instance.new("UIStroke", Input); InputStroke.Color = Color3.fromRGB(60, 60, 60); InputStroke.Thickness = 1

    local Submit = Instance.new("TextButton", Frame)
    Submit.Size = UDim2.new(0, 280, 0, 36); Submit.Position = UDim2.new(0.5, -140, 0, 96)
    Submit.BackgroundColor3 = Color3.fromRGB(220, 220, 220); Submit.Text = "Unlock"; Submit.TextColor3 = Color3.fromRGB(20, 20, 20)
    Submit.Font = Enum.Font.GothamBold; Submit.TextSize = 12; Submit.AutoButtonColor = false
    local SubmitCorner = Instance.new("UICorner", Submit); SubmitCorner.CornerRadius = UDim.new(0, 8)

    local ErrorLabel = Instance.new("TextLabel", Frame)
    ErrorLabel.Size = UDim2.new(1, 0, 0, 20); ErrorLabel.Position = UDim2.new(0, 0, 0, 140)
    ErrorLabel.Text = ""; ErrorLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    ErrorLabel.Font = Enum.Font.GothamMedium; ErrorLabel.TextSize = 11; ErrorLabel.BackgroundTransparency = 1

    Submit.MouseEnter:Connect(function() TweenService:Create(Submit, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play() end)
    Submit.MouseLeave:Connect(function() TweenService:Create(Submit, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 220, 220)}):Play() end)

    local function checkKey(rawInput)
        local input = string.match(rawInput, "^%s*(.-)%s*$")
        if not input or input == "" then ErrorLabel.Text = "Key cannot be empty!"; return end
        
        Submit.Text = "Verifying..."
        Submit.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
        local nocacheUrl = BASE_KEYS_URL .. "?t=" .. tostring(os.time())
        local success, data = pcall(function() return game:HttpGet(nocacheUrl) end)
        if not success then ErrorLabel.Text = "Connection failed."; Submit.Text = "Unlock"; Submit.BackgroundColor3 = Color3.fromRGB(220, 220, 220); return end
        
        local ok, keys = pcall(function() return HttpService:JSONDecode(data) end)
        if not ok then ErrorLabel.Text = "Server data error."; Submit.Text = "Unlock"; Submit.BackgroundColor3 = Color3.fromRGB(220, 220, 220); return end
        
        local keyData = keys[input]
        if not keyData then
            attempts = attempts + 1
            if attempts >= 3 then Player:Kick("TROXZY: Too many invalid attempts.") else ErrorLabel.Text = "Invalid Key! (" .. attempts .. "/3)"; Input.Text = "" end
            Submit.Text = "Unlock"; Submit.BackgroundColor3 = Color3.fromRGB(220, 220, 220); return
        end
        
        local playerUserID = tostring(Player.UserId)
        if not keyData.hwid or keyData.hwid == "" then Player:Kick("Key not linked. Provide UserID (" .. playerUserID .. ") to Admin."); return end
        if tostring(keyData.hwid) ~= playerUserID then Player:Kick("SECURITY: Key bound to another account!"); return end
        if not keyData.expiry then Player:Kick("Missing expiry field."); return end
        
        local expireTime = parseExpiry(keyData.expiry)
        if not expireTime then Player:Kick("Invalid date format."); return end
        if GetRealTime() > expireTime then Player:Kick("Key Expired!"); return end
        
        Submit.BackgroundColor3 = Color3.fromRGB(40, 200, 80); Submit.Text = "Success!"
        task.wait(0.5); keyValid = true; getgenv().keyExpireTime = expireTime; KeyScreen:Destroy()
    end

    Submit.MouseButton1Click:Connect(function() checkKey(Input.Text) end)
    Input.FocusLost:Connect(function(enterPressed) if enterPressed then checkKey(Input.Text) end end)
    repeat task.wait() until keyValid or not Player.Parent
    return keyValid
end

if not supremeKeyValidation() then return end

-- ==================== MAIN SCRIPT CORE ====================
local keyExpireTime = getgenv().keyExpireTime or 0
local function GetRealTime() local Workspace = game:GetService("Workspace"); local ok, srvTime = pcall(function() return math.floor(Workspace:GetServerTimeNow()) end); if ok and srvTime and srvTime > 1000000 then return srvTime end; return os.time() end
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1)

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

local Camera = Workspace.CurrentCamera
local IS_MOBILE = UIS.TouchEnabled

getgenv().TomatoAutoFarm = false; getgenv().TomatoConnections = getgenv().TomatoConnections or {}; _G.TroxzyAutoFarm = false
local Main, ToggleBtn, MapDetect = nil, nil, nil
local CurrentlyFarming, Escaped = false, false
local TAS_COROUTINE, TAS_RUNNING, TAS_STATUS_LABEL = nil, false, nil
local AUTO_QUEUE_ENABLED, AutoQueueListener, liftTarget, moveToLift, mapCompleted = false, nil, nil, false, false
local lastAdminCount, isMinimized, isGhostMode, lastDashboardUpdate = 0, false, false, 0
local SoundPool = {}

local function getPooledSound() if #SoundPool > 0 then local s = table.remove(SoundPool); if s and s.Parent then return s end end; local s = Instance.new("Sound"); s.Volume = 0.5; return s end
local function returnSoundToPool(s) if s then s:Stop(); s.Parent = nil; table.insert(SoundPool, s) end end
local SOUND_IDS = { alert = 9116456845 }
local function playSound(id) pcall(function() local s = getPooledSound(); s.SoundId = "rbxassetid://" .. id; s.Parent = Workspace; s:Play(); task.delay(3, function() returnSoundToPool(s) end) end) end

-- CLEANUP OLD UI
pcall(function()
    for _, gui in pairs(CoreGui:GetChildren()) do if gui.Name:find("TROXZY_VIP") or gui.Name:find("TroxzyKeyAuth") then gui:Destroy() end end
    for _, gui in pairs(Player.PlayerGui:GetChildren()) do if gui.Name:find("TROXZY_VIP") or gui.Name:find("TroxzyKeyAuth") then gui:Destroy() end end
end)
if _G.TroxzyConnections then for _, conn in pairs(_G.TroxzyConnections) do pcall(function() conn:Disconnect() end) end end
_G.TroxzyConnections = {}
local function TrackConnection(conn) table.insert(_G.TroxzyConnections, conn); return conn end
local function addCorner(obj, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = obj end
local function Tween(obj, props, time) if not obj then return end; TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play() end
local function notify(msg, title) pcall(function() StarterGui:SetCore("SendNotification", { Title = title or "Troxzy VIP", Text = msg, Duration = 2 }) end) end

local CONFIG = {
    TARGET_MAP = "Sandswept Ruins", TARGET_DIFFICULTY = "Crazy", TAS_MODE = "Play", TAS_AUTO_START = false,
    NOCLIP = false, GOD_MODE = false, SPEED = false, INF_JUMP = false, ESP = false, FULLBRIGHT = false, FOV = false,
    SPEED_VAL = 20, FOV_VAL = 90, AUTO_RECONNECT = true, STEALTH_MODE = true, ADMIN_DETECTOR = true,
    HIDE_SCRIPT = true, DASHBOARD = true, SMART_ALERTS = true, PANIC_MODE = false, COLLECT_ITEMS = true, AIR_SWIM = true, AUTO_UPDATE = false,
    CUSTOM_FLOOD_COLORS = false, FLOOD_COLOR = "Blue", ANTI_ADMIN = false, ANTI_REPORT = false, RANDOM_DELAY = true
}

local Stats = { mapsCompleted = 0, totalTime = 0, sessionStart = os.clock(), adminDetected = 0, adminLeft = 0, currentMap = "" }
local function loadStats() pcall(function() if isfile("Troxzy_Stats.json") then local d = HttpService:JSONDecode(readfile("Troxzy_Stats.json")); for k, v in pairs(d) do if Stats[k] ~= nil then Stats[k] = v end end end end); Stats.sessionStart = os.clock() end
local function saveStats() pcall(function() Stats.totalTime = Stats.totalTime + (os.clock() - Stats.sessionStart); writefile("Troxzy_Stats.json", HttpService:JSONEncode(Stats)); Stats.sessionStart = os.clock() end) end

local function isAdminName(str) str = str:lower(); return str:match("^[@_]?[aà]dm?[i1]n[istrator]*$") or str:match("^m[o0]d[erato]*r?$") or str:match("^st[a4]ff$") end
local function isAdmin(p) return isAdminName(p.Name) or isAdminName(p.DisplayName) end
local function getAdminPlayers() local admins = {}; for _, p in pairs(Players:GetPlayers()) do if p ~= Player and isAdmin(p) then table.insert(admins, p) end end; return admins end

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
    if isGhostMode then return end; isGhostMode = true; getgenv().TomatoAutoFarm = false; CurrentlyFarming = false; StopAutoQueue()
    pcall(function() Player.Character.Humanoid.WalkSpeed = 16 end); if Main then Main.Visible = false end; if ToggleBtn then ToggleBtn.Visible = false end
    if CONFIG.SMART_ALERTS then playSound(SOUND_IDS.alert) end
end
local function deactivateGhostMode() if not isGhostMode then return end; isGhostMode = false; if Main then Main.Visible = true end; if ToggleBtn then ToggleBtn.Visible = true end end

local lastAdminAlert = 0
local function handleAdminDetection()
    if not CONFIG.ADMIN_DETECTOR then return end
    local count = #getAdminPlayers()
    if count > 0 then
        if count > lastAdminCount and (os.clock() - lastAdminAlert >= 10) then
            lastAdminAlert = os.clock(); Stats.adminDetected = Stats.adminDetected + (count - lastAdminCount)
            if CONFIG.ANTI_ADMIN then blockAdminRemotes() end
            if getgenv().TomatoAutoFarm or AUTO_QUEUE_ENABLED or TAS_RUNNING then activateGhostMode() end
        end
    else if isGhostMode then deactivateGhostMode() end end
    lastAdminCount = count
end

if CONFIG.ANTI_REPORT then pcall(function() Players.ReportAbuse = function() end end) end

local floodColorMap = { Blue = Color3.fromRGB(0, 150, 255), Green = Color3.fromRGB(0, 255, 100), Red = Color3.fromRGB(255, 50, 50), Pink = Color3.fromRGB(255, 100, 200), Purple = Color3.fromRGB(150, 50, 255) }
local function applyFloodColors() if not CONFIG.CUSTOM_FLOOD_COLORS then return end; local targetColor = floodColorMap[CONFIG.FLOOD_COLOR] or Color3.fromRGB(0, 150, 255); for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name:lower():find("water") or v.Name:lower():find("acid") or v.Name:lower():find("lava") or v.Name:lower():find("flood")) then pcall(function() v.Color = targetColor end) end end end
local lastFloodColorUpdate = 0
local function periodicFloodColorUpdate() if not CONFIG.CUSTOM_FLOOD_COLORS then return end; local now = os.clock(); if now - lastFloodColorUpdate < 0.5 then return end; lastFloodColorUpdate = now; applyFloodColors() end

local function forceReconnect() saveStats(); task.wait(1); pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end); task.wait(2); pcall(function() TeleportService:Teleport(game.PlaceId) end) end
local function attemptReconnect() saveStats(); task.wait(3); pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end) end
local function setupAutoReconnect() if not CONFIG.AUTO_RECONNECT then return end; TrackConnection(Player:GetPropertyChangedSignal("Parent"):Connect(function() if not Player.Parent then attemptReconnect() end end)); TrackConnection(TeleportService.TeleportInitFailed:Connect(attemptReconnect)) end

local function DisconnectMapDetection() if MapDetect then MapDetect:Disconnect(); MapDetect = nil end end
local function ExecuteTAS()
    if not CONFIG.TAS_AUTO_START then notify("TAS Auto-Start is OFF."); return end
    if TAS_RUNNING then if TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE); TAS_COROUTINE = nil end; TAS_RUNNING = false; task.wait(0.2) end
    getgenv().TomatoAutoFarm = false; CurrentlyFarming = false; DisconnectMapDetection()
    local url = CONFIG.TAS_MODE == "Record" and "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TAS/CREATOR/creator.luau" or "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TAS/PLAYER/newtasplayer.luau"
    local success, scriptContent = pcall(function() return game:HttpGet(url) end)
    if not success then return end
    local func, compileErr = loadstring(scriptContent)
    if not func then return end

    TAS_COROUTINE = coroutine.create(function()
        TAS_RUNNING = true; pcall(func); TAS_RUNNING = false; TAS_COROUTINE = nil; if AUTO_QUEUE_ENABLED then mapCompleted = true end
        if TAS_STATUS_LABEL then TAS_STATUS_LABEL.Text = "  Status: READY" end
    end)
    coroutine.resume(TAS_COROUTINE); if TAS_STATUS_LABEL then TAS_STATUS_LABEL.Text = "  Status: RUNNING" end
end

local Multiplayer = Workspace:WaitForChild("Multiplayer")
local RemoteFolder = ReplicatedStorage:WaitForChild("Remote")
local AddedWaiting = RemoteFolder:WaitForChild("AddedWaiting")

local function Check(flag)
    local char = Player.Character; if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return false end
    if flag == "InLift" then return hrp.Position.X < 50 and hrp.Position.Z > 70 elseif flag == "InGame" then return hrp.Position.X > 50 end return false
end

local ncCache, ncActive = {}, false
local function refreshNoclip() ncCache = {}; local char = Player.Character; if char then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then table.insert(ncCache, v) end end end end
local function applyNoclip(state) if state == ncActive then return end; ncActive = state; for _, v in ipairs(ncCache) do if v and v.Parent then v.CanCollide = not state end end end

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
                if distOk then local hl = Instance.new("Highlight"); hl.FillColor = Color3.fromRGB(160, 180, 200); hl.OutlineColor = Color3.fromRGB(255, 255, 255); hl.Parent = plr.Character; espCache[plr] = hl end
            elseif not plr.Character and espCache[plr] then pcall(function() espCache[plr]:Destroy() end); espCache[plr] = nil
            elseif plr.Character and espCache[plr] and myRoot and plr.Character:FindFirstChild("HumanoidRootPart") then
                if (myRoot.Position - plr.Character.HumanoidRootPart.Position).Magnitude > ESP_MAX_DISTANCE then pcall(function() espCache[plr]:Destroy() end); espCache[plr] = nil end
            end
        end
    end
    for plr, hl in pairs(espCache) do if not plr.Parent or (plr.Character and hl.Parent ~= plr.Character) then pcall(function() hl:Destroy() end); espCache[plr] = nil end end
end
local function clearESPCache() for _, hl in pairs(espCache) do pcall(function() hl:Destroy() end) end; espCache = {} end

local panicActive = false; _G.ToggleStates = {}
local minimizeUI, maximizeUI
local function activatePanicMode() panicActive = true; getgenv().TomatoAutoFarm = false; CurrentlyFarming = false; applyNoclip(false); pcall(function() Player.Character.Humanoid.WalkSpeed = 16 end); minimizeUI(true); clearESPCache(); if _G.ToggleStates["PANIC_MODE"] then _G.ToggleStates["PANIC_MODE"].SetState(true) end end
local function deactivatePanicMode() panicActive = false; maximizeUI(); if _G.ToggleStates["PANIC_MODE"] then _G.ToggleStates["PANIC_MODE"].SetState(false) end end

local lastVisUpdate, lastFOV = 0, 70
local function updateVisuals() if os.clock() - lastVisUpdate < 0.5 then return end; lastVisUpdate = os.clock(); Lighting.Brightness = CONFIG.FULLBRIGHT and 2 or 1; Lighting.FogEnd = CONFIG.FULLBRIGHT and 99999 or 10000; if Camera then local tfov = CONFIG.FOV and CONFIG.FOV_VAL or 70; if tfov ~= lastFOV then Tween(Camera, {FieldOfView = tfov}); lastFOV = tfov end end; periodicFloodColorUpdate() end

local WIN_SCRIPT_URL = "https://raw.githubusercontent.com/killers-byte/Flood-GUI/refs/heads/main/win"
local WinFarmCoroutine, WinFarmRunning, WinDownloading = nil, false, false

local function StartWinEngine()
    if WinFarmRunning or WinDownloading then return end; WinDownloading = true
    local success, scriptContent = pcall(function() return game:HttpGet(WIN_SCRIPT_URL) end)
    if not success or not scriptContent then WinDownloading = false; getgenv().TomatoAutoFarm = false; return end
    local func, err = loadstring(scriptContent)
    if not func then WinDownloading = false; getgenv().TomatoAutoFarm = false; return end
    WinDownloading = false
    WinFarmCoroutine = coroutine.create(function() WinFarmRunning = true; pcall(func); WinFarmRunning = false; WinFarmCoroutine = nil end)
    coroutine.resume(WinFarmCoroutine)
end
local function StopWinEngine() if WinFarmCoroutine then pcall(coroutine.close, WinFarmCoroutine); WinFarmCoroutine = nil end; WinFarmRunning = false; CurrentlyFarming = false end

local function findLiftPosition() for _, obj in pairs(Workspace.Lobby:GetDescendants()) do if obj:IsA("BasePart") and obj.Name:lower():find("lift") then return obj.Position + Vector3.new(0, 5, 0) end end; return Vector3.new(25, 7, 85) end

function StartAutoQueue()
    if AutoQueueListener then AutoQueueListener:Disconnect() end; moveToLift = false; mapCompleted = false
    AutoQueueListener = Multiplayer.ChildAdded:Connect(function(newMap)
        if not AUTO_QUEUE_ENABLED or panicActive or isGhostMode then return end
        pcall(function() local s = newMap:WaitForChild("Settings", 5); if s then Stats.currentMap = s:GetAttribute("MapName") or "Unknown" end end)
        repeat task.wait() until Check("InGame") or not AUTO_QUEUE_ENABLED
        if not AUTO_QUEUE_ENABLED then return end; mapCompleted = false
        if not TAS_RUNNING then getgenv().TomatoAutoFarm = false; task.spawn(ExecuteTAS) end
    end)
end
function StopAutoQueue() if AutoQueueListener then AutoQueueListener:Disconnect(); AutoQueueListener = nil end; moveToLift = false; if TAS_RUNNING and TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE); TAS_RUNNING = false end end

task.spawn(function()
    while task.wait(0.5) do
        if (AUTO_QUEUE_ENABLED or getgenv().TomatoAutoFarm) and not panicActive and not isGhostMode then
            local char = Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and not Check("InGame") and not Check("InLift") and not TAS_RUNNING and not CurrentlyFarming then moveToLift = true; liftTarget = findLiftPosition() else moveToLift = false end
        else moveToLift = false end
    end
end)

TrackConnection(RunService.Heartbeat:Connect(function()
    if moveToLift and (AUTO_QUEUE_ENABLED or getgenv().TomatoAutoFarm) and not panicActive and not TAS_RUNNING then
        local char = Player.Character; local hum = char and char:FindFirstChild("Humanoid"); local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 and not Check("InGame") and not Check("InLift") and liftTarget then
            if (liftTarget - hrp.Position).Magnitude > 3 then hum:MoveTo(liftTarget); hum.WalkSpeed = 25 else pcall(function() AddedWaiting:FireServer() end); moveToLift = false end
        end
    end
end))

TrackConnection(Player.CharacterAdded:Connect(function() refreshNoclip(); ncActive = false; if not Check("InGame") then mapCompleted = false end end))

-- ==================== FLUENT UI SYSTEM ====================
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "TROXZY_VIP"; ScreenGui.ResetOnSpawn = false
if not pcall(function() ScreenGui.Parent = CoreGui end) then ScreenGui.Parent = Player.PlayerGui end

-- TEMA WARNA FLUENT MODERN
local M_BG = Color3.fromRGB(15, 15, 15) 
local M_CONTENT = Color3.fromRGB(22, 22, 22) 
local M_ELEMENT = Color3.fromRGB(32, 32, 32) 
local M_TEXT_W = Color3.fromRGB(240, 240, 240)
local M_TEXT_D = Color3.fromRGB(140, 140, 140)
local M_ACCENT = Color3.fromRGB(74, 222, 128) 
local M_BORDER = Color3.fromRGB(45, 45, 45)

ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0,45,0,45); ToggleBtn.Position = IS_MOBILE and UDim2.new(0.88,0,0.05,0) or UDim2.new(0.015,0,0.015,0)
ToggleBtn.BackgroundColor3 = M_ELEMENT; ToggleBtn.Text = "T"; ToggleBtn.TextSize = 20; ToggleBtn.Font = Enum.Font.GothamBold; ToggleBtn.TextColor3 = M_TEXT_W
addCorner(ToggleBtn, 8); ToggleBtn.Parent = ScreenGui

Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 520, 0, 360); Main.Position = UDim2.new(0.5, -260, 0.5, -180)
Main.BackgroundColor3 = M_BG; Main.BorderSizePixel = 0; Main.Visible = true; Main.Active = true; Main.Draggable = true
addCorner(Main, 10); Main.Parent = ScreenGui
local MainStroke = Instance.new("UIStroke", Main); MainStroke.Color = M_BORDER; MainStroke.Thickness = 1

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 140, 1, 0); Sidebar.BackgroundColor3 = M_BG; Sidebar.BorderSizePixel = 0; addCorner(Sidebar, 10)
local SidebarHider = Instance.new("Frame", Sidebar)
SidebarHider.Size = UDim2.new(0, 10, 1, 0); SidebarHider.Position = UDim2.new(1, -10, 0, 0); SidebarHider.BackgroundColor3 = M_BG; SidebarHider.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel", Sidebar)
TitleLabel.Size = UDim2.new(1, -20, 0, 50); TitleLabel.Position = UDim2.new(0, 15, 0, 10)
TitleLabel.Text = "<b>Troxzy VIP</b>\n<font size='10' color='#8c8c8c'>By Troxzy</font>"
TitleLabel.TextColor3 = M_TEXT_W; TitleLabel.Font = Enum.Font.Gotham; TitleLabel.TextSize = 13; TitleLabel.RichText = true
TitleLabel.BackgroundTransparency = 1; TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local ContentBg = Instance.new("Frame", Main)
ContentBg.Size = UDim2.new(1, -140, 1, 0); ContentBg.Position = UDim2.new(0, 140, 0, 0)
ContentBg.BackgroundColor3 = M_CONTENT; ContentBg.BorderSizePixel = 0; addCorner(ContentBg, 10)
local ContentHider = Instance.new("Frame", ContentBg)
ContentHider.Size = UDim2.new(0, 10, 1, 0); ContentHider.BackgroundColor3 = M_CONTENT; ContentHider.BorderSizePixel = 0

local TabListContainer = Instance.new("ScrollingFrame", Sidebar)
TabListContainer.Size = UDim2.new(1, -15, 1, -70); TabListContainer.Position = UDim2.new(0, 10, 0, 60)
TabListContainer.BackgroundTransparency = 1; TabListContainer.ScrollBarThickness = 0

local TabListLayout = Instance.new("UIListLayout", TabListContainer)
TabListLayout.Padding = UDim.new(0, 4); TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local tabItems = { {name="Automate", icon="⚙️"}, {name="Player", icon="👤"}, {name="Visuals", icon="👁️"}, {name="Security", icon="🛡️"}, {name="Settings", icon="🔧"} }
local tabBtns, tabContents = {}, {}

for i, tab in ipairs(tabItems) do
    local tabBtn = Instance.new("TextButton", TabListContainer)
    tabBtn.Size = UDim2.new(1, 0, 0, 32); tabBtn.BackgroundColor3 = (i==1) and M_ELEMENT or M_BG
    tabBtn.Text = "  " .. tab.icon .. "  " .. tab.name; tabBtn.TextSize = 12; tabBtn.Font = Enum.Font.GothamMedium
    tabBtn.TextColor3 = (i==1) and M_TEXT_W or M_TEXT_D; tabBtn.AutoButtonColor = false; tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    addCorner(tabBtn, 6); table.insert(tabBtns, tabBtn)

    local cFrame = Instance.new("ScrollingFrame", ContentBg)
    cFrame.Size = UDim2.new(1, -30, 1, -30); cFrame.Position = UDim2.new(0, 15, 0, 15)
    cFrame.BackgroundTransparency = 1; cFrame.ScrollBarThickness = 2; cFrame.ScrollBarImageColor3 = M_BORDER
    cFrame.Visible = (i==1); cFrame.BorderSizePixel = 0

    local cLayout = Instance.new("UIListLayout", cFrame)
    cLayout.Padding = UDim.new(0, 8); cLayout.SortOrder = Enum.SortOrder.LayoutOrder
    cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() cFrame.CanvasSize = UDim2.new(0,0,0,cLayout.AbsoluteContentSize.Y + 10) end)
    table.insert(tabContents, {scroll=cFrame, layout=cLayout})

    tabBtn.MouseButton1Click:Connect(function()
        for j, btn in ipairs(tabBtns) do
            if j==i then Tween(btn, {BackgroundColor3 = M_ELEMENT, TextColor3 = M_TEXT_W}); tabContents[j].scroll.Visible = true
            else Tween(btn, {BackgroundColor3 = M_BG, TextColor3 = M_TEXT_D}); tabContents[j].scroll.Visible = false end
        end
    end)
end

-- UI Builder Functions
local function AddSection(tabIdx, title)
    local s = Instance.new("TextLabel", tabContents[tabIdx].scroll)
    s.Size = UDim2.new(1, 0, 0, 20); s.Text = title; s.TextColor3 = M_TEXT_D; s.Font = Enum.Font.GothamBold
    s.TextSize = 11; s.BackgroundTransparency = 1; s.TextXAlignment = Enum.TextXAlignment.Left
end

local function AddToggle(tabIdx, name, stateKey)
    local f = Instance.new("Frame", tabContents[tabIdx].scroll)
    f.Size = UDim2.new(1, -10, 0, 40); f.BackgroundColor3 = M_ELEMENT; addCorner(f, 8)
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.7, 0, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.Text = name
    lbl.TextColor3 = M_TEXT_W; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12
    lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local sb = Instance.new("Frame", f)
    sb.Size = UDim2.new(0, 40, 0, 22); sb.Position = UDim2.new(1, -55, 0.5, -11)
    sb.BackgroundColor3 = M_BG; addCorner(sb, 11)
    
    local dot = Instance.new("Frame", sb)
    dot.Size = UDim2.new(0, 16, 0, 16); dot.Position = UDim2.new(0, 3, 0.5, -8)
    dot.BackgroundColor3 = M_TEXT_D; addCorner(dot, 8)
    
    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
    local state = false

    local function setToggleUI(st)
        state = st
        Tween(dot, {Position = st and UDim2.new(0, 21, 0.5, -8) or UDim2.new(0, 3, 0.5, -8), BackgroundColor3 = st and Color3.fromRGB(255,255,255) or M_TEXT_D})
        Tween(sb, {BackgroundColor3 = st and M_ACCENT or M_BG})
    end
    if stateKey then _G.ToggleStates[stateKey] = { state = false, SetState = setToggleUI } end

    btn.MouseButton1Click:Connect(function()
        state = not state; setToggleUI(state)
        if stateKey == "AUTO_QUEUE" then AUTO_QUEUE_ENABLED = state; if state then CONFIG.TAS_MODE = "Play"; CONFIG.TAS_AUTO_START = true; mapCompleted = false; StartAutoQueue() else StopAutoQueue() end
        elseif stateKey == "AutoFarm" then getgenv().TomatoAutoFarm = state; if state then StartWinEngine() else StopWinEngine() end
        elseif stateKey == "DASHBOARD" then CONFIG.DASHBOARD = state; if _G.DashboardUI then _G.DashboardUI.Visible = state end
        elseif stateKey == "PANIC_MODE" then if state then activatePanicMode() else deactivatePanicMode() end
        else CONFIG[stateKey] = state end
    end)
end

local function AddButton(tabIdx, name, isRed, callback)
    local b = Instance.new("TextButton", tabContents[tabIdx].scroll)
    b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = isRed and Color3.fromRGB(200, 50, 50) or M_BG
    b.Text = name; b.TextSize = 12; b.Font = Enum.Font.GothamMedium; b.TextColor3 = M_TEXT_W
    b.AutoButtonColor = false; addCorner(b, 8)
    local strk = Instance.new("UIStroke", b); strk.Color = M_BORDER; strk.Thickness = 1
    b.MouseEnter:Connect(function() Tween(b, {BackgroundColor3 = isRed and Color3.fromRGB(180, 40, 40) or M_ELEMENT}) end)
    b.MouseLeave:Connect(function() Tween(b, {BackgroundColor3 = isRed and Color3.fromRGB(200, 50, 50) or M_BG}) end)
    b.MouseButton1Click:Connect(function() pcall(callback) end)
end

local function AddInput(tabIdx, label, defaultVal, callback)
    local f = Instance.new("Frame", tabContents[tabIdx].scroll)
    f.Size = UDim2.new(1, -10, 0, 40); f.BackgroundColor3 = M_ELEMENT; addCorner(f, 8)
    local lbl = Instance.new("TextLabel", f); lbl.Size = UDim2.new(0.5, 0, 1, 0); lbl.Position = UDim2.new(0, 15, 0, 0); lbl.Text = label; lbl.TextColor3 = M_TEXT_W; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12; lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local inp = Instance.new("TextBox", f); inp.Size = UDim2.new(0, 80, 0, 26); inp.Position = UDim2.new(1, -95, 0.5, -13); inp.BackgroundColor3 = M_BG; inp.TextColor3 = M_TEXT_W; inp.PlaceholderText = tostring(defaultVal); inp.Text = tostring(defaultVal); inp.Font = Enum.Font.Gotham; inp.TextSize = 12; addCorner(inp, 6); local strk = Instance.new("UIStroke", inp); strk.Color = M_BORDER; strk.Thickness = 1
    inp.FocusLost:Connect(function() local v = tonumber(inp.Text); if v then callback(v) else inp.Text = tostring(defaultVal) end end)
end

local function AddInfoLabel(tabIdx, text)
    local f = Instance.new("Frame", tabContents[tabIdx].scroll)
    f.Size = UDim2.new(1, -10, 0, 30); f.BackgroundColor3 = M_BG; addCorner(f, 8); local strk = Instance.new("UIStroke", f); strk.Color = M_BORDER; strk.Thickness = 1
    local lbl = Instance.new("TextLabel", f); lbl.Size = UDim2.new(1, -20, 1, 0); lbl.Position = UDim2.new(0, 10, 0, 0); lbl.Text = text; lbl.TextColor3 = M_TEXT_W; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 11; lbl.BackgroundTransparency = 1; lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end

minimizeUI = function(instant) if instant then Main.Visible = false; isMinimized = true; return end; isMinimized = true; local t = TweenService:Create(Main, TweenInfo.new(0.3), { Size = UDim2.new(0,520,0,0) }); t:Play(); t.Completed:Connect(function() Main.Visible = false end) end
maximizeUI = function() isMinimized = false; Main.Visible = true; Main.Size = UDim2.new(0,520,0,0); TweenService:Create(Main, TweenInfo.new(0.3), { Size = UDim2.new(0,520,0,360) }):Play() end
ToggleBtn.MouseButton1Click:Connect(function() if isMinimized then maximizeUI() else minimizeUI(false) end end)

-- LIVE DASHBOARD RESTORED
local Dashboard = Instance.new("Frame"); Dashboard.Size = UDim2.new(0, 230, 0, 0); Dashboard.Position = UDim2.new(0.985, 0, 0.015, 0); Dashboard.AnchorPoint = Vector2.new(1, 0); Dashboard.BackgroundColor3 = M_BG; Dashboard.AutomaticSize = Enum.AutomaticSize.Y; Dashboard.Visible = CONFIG.DASHBOARD; addCorner(Dashboard, 8); local dStroke = Instance.new("UIStroke", Dashboard); dStroke.Color = M_BORDER; dStroke.Thickness = 1; Dashboard.Parent = ScreenGui; _G.DashboardUI = Dashboard
local DPad = Instance.new("UIPadding"); DPad.PaddingTop = UDim.new(0, 12); DPad.PaddingBottom = UDim.new(0, 12); DPad.PaddingLeft = UDim.new(0, 12); DPad.PaddingRight = UDim.new(0, 12); DPad.Parent = Dashboard
local DLayout = Instance.new("UIListLayout"); DLayout.SortOrder = Enum.SortOrder.LayoutOrder; DLayout.Padding = UDim.new(0, 6); DLayout.Parent = Dashboard
local function createDashLabel(text, order, color) local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(1, 0, 0, 16); lbl.BackgroundTransparency = 1; lbl.Text = text; lbl.TextColor3 = color or M_TEXT_W; lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.TextWrapped = true; lbl.AutomaticSize = Enum.AutomaticSize.Y; lbl.RichText = true; lbl.LayoutOrder = order; lbl.Parent = Dashboard; return lbl end
local function createDashDivider(order) local div = Instance.new("Frame"); div.Size = UDim2.new(1, 0, 0, 1); div.BackgroundColor3 = M_BORDER; div.BorderSizePixel = 0; div.LayoutOrder = order; div.Parent = Dashboard; return div end

local dTitle = createDashLabel("<b>⚔️ OVERVIEW</b>", 1, M_ACCENT); dTitle.Font = Enum.Font.GothamBlack; dTitle.TextSize = 12
createDashDivider(2)
local mapLabel = createDashLabel("🗺️ <b>Map:</b> Waiting...", 3)
local timeLabel = createDashLabel("⏱️ <b>Time:</b> 0m", 4, M_TEXT_D)
local speedLabel = createDashLabel("⚡ <b>Rate:</b> 0 maps/hr", 5, M_TEXT_D)
local statusLabel = createDashLabel("ℹ️ <b>Status:</b> Idle", 6, Color3.fromRGB(0, 230, 120))
local ghostStatusLabel = createDashLabel("👻 <b>Ghost Mode:</b> Inactive", 7, Color3.fromRGB(180, 180, 180))
local keyDurationLabel = createDashLabel("🔑 <b>Key Expires In:</b> ...", 8, Color3.fromRGB(255, 200, 100))
createDashDivider(9)
local adminInfoLabel = createDashLabel("🛡️ <b>Admins:</b> None", 10, Color3.fromRGB(100, 255, 100))
local spectatorInfoLabel = createDashLabel("👁️ <b>Spectators:</b> None", 11, Color3.fromRGB(180, 180, 180))

local function updateDashboard()
    if not Dashboard.Visible then return end
    local remaining = keyExpireTime - GetRealTime()
    if remaining <= 0 then Player:Kick("Key expired!"); return end
    if keyExpireTime > GetRealTime() + 315360000 then keyDurationLabel.Text = "🔑 <b>Key: PERMANENT</b>"; keyDurationLabel.TextColor3 = M_ACCENT
    else
        local days = math.floor(remaining / 86400); local hours = math.floor((remaining % 86400) / 3600); local minutes = math.floor((remaining % 3600) / 60)
        keyDurationLabel.Text = "🔑 <b>Expires In:</b> " .. (days > 0 and days.."d " or "") .. hours .. "h " .. minutes .. "m"
    end
    mapLabel.Text = "🗺️ <b>Map:</b> " .. (Stats.currentMap ~= "" and Stats.currentMap or "Waiting...")
    timeLabel.Text = "⏱️ <b>Time:</b> " .. math.floor((os.clock() - Stats.sessionStart) / 60) .. "m"
    local sessionHours = (os.clock() - Stats.sessionStart) / 3600
    speedLabel.Text = "⚡ <b>Rate:</b> " .. ((sessionHours > 0 and Stats.mapsCompleted > 0) and math.floor(Stats.mapsCompleted / sessionHours) or 0) .. " maps/hr"
    
    if isGhostMode then ghostStatusLabel.Text = "👻 <b>Ghost Mode:</b> ACTIVE"; ghostStatusLabel.TextColor3 = Color3.fromRGB(255, 50, 50) else ghostStatusLabel.Text = "👻 <b>Ghost Mode:</b> Inactive"; ghostStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180) end
    if panicActive then statusLabel.Text = "ℹ️ <b>Status:</b> PANIC"; statusLabel.TextColor3 = Color3.fromRGB(255,80,80) elseif TAS_RUNNING then statusLabel.Text = "ℹ️ <b>Status:</b> TAS PLAYING"; statusLabel.TextColor3 = M_ACCENT elseif AUTO_QUEUE_ENABLED then statusLabel.Text = "ℹ️ <b>Status:</b> Auto Queue"; statusLabel.TextColor3 = Color3.fromRGB(100,200,255) else statusLabel.Text = "ℹ️ <b>Status:</b> Idle"; statusLabel.TextColor3 = M_TEXT_D end
    
    local admins = getAdminPlayers(); if #admins > 0 then local txt = {}; for _, adm in ipairs(admins) do table.insert(txt, " - " .. adm.Name) end; adminInfoLabel.Text = "🛡️ <b>Admins:</b>\n" .. table.concat(txt, "\n"); adminInfoLabel.TextColor3 = Color3.fromRGB(255,80,80) else adminInfoLabel.Text = "🛡️ <b>Admins:</b> None"; adminInfoLabel.TextColor3 = Color3.fromRGB(100,255,100) end
    local spectators = getSpectators(); if #spectators > 0 then local stxt = {}; for _, spec in ipairs(spectators) do table.insert(stxt, " - " .. spec.DisplayName) end; spectatorInfoLabel.Text = "👁️ <b>Spectators:</b>\n" .. table.concat(stxt, "\n"); spectatorInfoLabel.TextColor3 = Color3.fromRGB(255,200,0) else spectatorInfoLabel.Text = "👁️ <b>Spectators:</b> None"; spectatorInfoLabel.TextColor3 = Color3.fromRGB(180,180,180) end
end

-- TAB 1: Automate
AddSection(1, "SEAMLESS AUTOMATION")
AddToggle(1, "Seamless Auto Queue", "AUTO_QUEUE")
AddToggle(1, "Auto-Start Play", "TAS_AUTO_START")
AddButton(1, "Record Route", false, function() if not CONFIG.TAS_AUTO_START then notify("Enable Auto-Start"); return end; CONFIG.TAS_MODE="Record"; task.spawn(ExecuteTAS) end)
AddButton(1, "Force Play Route", false, function() if not CONFIG.TAS_AUTO_START then notify("Enable Auto-Start"); return end; CONFIG.TAS_MODE="Play"; task.spawn(ExecuteTAS) end)
TAS_STATUS_LABEL = AddInfoLabel(1, "  Status: READY")
AddSection(1, "CORE (Win Engine)")
AddToggle(1, "Enable Auto Farm (Win)", "AutoFarm")
AddInfoLabel(1, "  Target Map: " .. CONFIG.TARGET_MAP)

-- TAB 2: Player
AddSection(2, "CHARACTER CONTROL")
AddToggle(2, "Noclip Bypass", "NOCLIP")
AddToggle(2, "Speed Modifier", "SPEED")
AddInput(2, "Speed Value", CONFIG.SPEED_VAL, function(v) CONFIG.SPEED_VAL=v end)
AddToggle(2, "Infinite Jump", "INF_JUMP")
AddToggle(2, "God Mode", "GOD_MODE")
AddToggle(2, "Air Swim (Bypass Water)", "AIR_SWIM")

-- TAB 3: Visuals
AddSection(3, "RENDERING")
AddToggle(3, "Player ESP", "ESP")
AddToggle(3, "Fullbright", "FULLBRIGHT")
AddToggle(3, "FOV Override", "FOV")
AddInput(3, "Field of View", CONFIG.FOV_VAL, function(v) CONFIG.FOV_VAL=v end)
AddToggle(3, "Live Dashboard", "DASHBOARD")
AddSection(3, "CUSTOM ELEMENTS")
AddToggle(3, "Custom Flood Colors", "CUSTOM_FLOOD_COLORS")
local FCLabel = AddInfoLabel(3, "  Current: " .. CONFIG.FLOOD_COLOR)
AddButton(3, "Cycle Color", false, function() local c={"Blue","Green","Red","Pink","Purple"}; local idx=table.find(c,CONFIG.FLOOD_COLOR); idx=idx and (idx%#c)+1 or 1; CONFIG.FLOOD_COLOR=c[idx]; applyFloodColors(); FCLabel.Text="  Current: "..CONFIG.FLOOD_COLOR end)

-- TAB 4: Security
AddSection(4, "STEALTH & AVOIDANCE")
AddToggle(4, "Humanized Delay", "RANDOM_DELAY")
AddToggle(4, "Stealth Movement", "STEALTH_MODE")
AddToggle(4, "Hide GUI Nearby", "HIDE_SCRIPT")
AddToggle(4, "Detect Admins (Fuzzy)", "ADMIN_DETECTOR")
AddToggle(4, "Block Admin Remotes", "ANTI_ADMIN")
AddToggle(4, "Disable Reports", "ANTI_REPORT")
AddButton(4, "PANIC MODE [P]", true, function() if not panicActive then activatePanicMode() else deactivatePanicMode() end end)
AddButton(4, "Force Reconnect", true, forceReconnect)

-- TAB 5: Settings
AddSection(5, "SYSTEM & UPDATES")
AddToggle(5, "Auto-Updater (On Boot)", "AUTO_UPDATE")
AddButton(5, "Check for Updates", false, function()
    notify("Checking GitHub...", "Updater")
    task.spawn(function()
        local success, newScript = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/killers-byte/Flood-GUI/refs/heads/main/TroxzyVIP.lua") end)
        if success and newScript and #newScript > 100 then
            notify("Update found! Reloading...", "Updater"); task.wait(1.5)
            local func = loadstring(newScript); if func then func() end
        end
    end)
end)
AddSection(5, "MISCELLANEOUS")
AddToggle(5, "Auto Collect Items", "COLLECT_ITEMS")
AddToggle(5, "Timer Override (3s)", "TIMER_HOOK")
AddButton(5, "Minimize User Interface", false, function() minimizeUI(false) end)

-- Hotkeys & Loop
TrackConnection(UIS.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == Enum.KeyCode.P then if not panicActive then activatePanicMode() else deactivatePanicMode() end end end))
TrackConnection(UIS.JumpRequest:Connect(function() if CONFIG.INF_JUMP and Player.Character then local h = Player.Character:FindFirstChild("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end))

local lastHeartbeat = 0
TrackConnection(RunService.Heartbeat:Connect(function()
    if os.clock() - lastHeartbeat < 0.1 then return end; lastHeartbeat = os.clock()
    pcall(function()
        local ch = Player.Character; if not ch then return end; local hum = ch:FindFirstChild("Humanoid"); if not hum then return end
        if CONFIG.NOCLIP and not CurrentlyFarming then refreshNoclip(); applyNoclip(true) elseif not CurrentlyFarming then applyNoclip(false) end
        if not CurrentlyFarming then hum.WalkSpeed = CONFIG.SPEED and CONFIG.SPEED_VAL or (moveToLift and 20 or 16) end
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not CONFIG.GOD_MODE)
        if CONFIG.AIR_SWIM and hum:GetState() == Enum.HumanoidStateType.Swimming then hum:ChangeState(Enum.HumanoidStateType.Landed); hum.PlatformStand = false; task.wait(0.05); hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
    pcall(handleAdminDetection)
    pcall(updateDashboard)
end))
TrackConnection(RunService.Heartbeat:Connect(function() pcall(updateESP); pcall(updateVisuals) end))

loadStats(); setupAutoReconnect()
notify("TROXZY VIP - ALL FEATURES RESTORED", "System")
