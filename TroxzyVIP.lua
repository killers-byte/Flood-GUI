-- ============================================
-- TROXZY VIP v22.1 "SPECTRAL BLADE" [BACKEND CORE]
-- Badan Intelijen Negara - AUTO WIN PROTOCOL
-- 🔥 FITUR LENGKAP TERMASUK AUTO REBIRTH
-- ============================================

-- [ SUPREME KEY SYSTEM ]
local function supremeKeyValidation()
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local Player = Players.LocalPlayer
    if not Player then return false end

    local function GetRealTime()
        local ok, srvTime = pcall(function() return math.floor(Workspace:GetServerTimeNow()) end)
        if ok and srvTime and srvTime > 1000000 then return srvTime end
        return os.time()
    end

    if getgenv().keyExpireTime and getgenv().keyExpireTime > GetRealTime() then return true end

    local BASE_KEYS_URL = "https://gist.githubusercontent.com/killers-byte/4cd78cad4c3cf8e62e90cd7f8c82624b/raw/TroxzyKey.json"
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

local STATE = {
    AUTO_QUEUE_ENABLED = false,
    TAS_RUNNING = false,
    panicActive = false,
    isGhostMode = false,
    moveToLift = false,
    mapCompleted = false
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
        TAS_RUNNING = true; STATE.TAS_RUNNING = true
        pcall(func)
        TAS_RUNNING = false; STATE.TAS_RUNNING = false
        TAS_COROUTINE = nil
        if AUTO_QUEUE_ENABLED then mapCompleted = true; STATE.mapCompleted = true end
        if getgenv().TroxzyAPI and getgenv().TroxzyAPI.UIHooks.updateTASStatus then
            getgenv().TroxzyAPI.UIHooks.updateTASStatus("  Status: READY")
        end
    end)
    coroutine.resume(TAS_COROUTINE)
    if getgenv().TroxzyAPI and getgenv().TroxzyAPI.UIHooks.updateTASStatus then
        getgenv().TroxzyAPI.UIHooks.updateTASStatus("  Status: RUNNING")
    end
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

local panicActive = false
local function activatePanicMode() panicActive = true; STATE.panicActive = true; getgenv().TomatoAutoFarm = false; CurrentlyFarming = false; applyNoclip(false); pcall(function() Player.Character.Humanoid.WalkSpeed = 16 end); if getgenv().TroxzyAPI and getgenv().TroxzyAPI.UIHooks.minimize then getgenv().TroxzyAPI.UIHooks.minimize(true) end; clearESPCache(); if _G.ToggleStates and _G.ToggleStates["PANIC_MODE"] then _G.ToggleStates["PANIC_MODE"].SetState(true) end end
local function deactivatePanicMode() panicActive = false; STATE.panicActive = false; if getgenv().TroxzyAPI and getgenv().TroxzyAPI.UIHooks.maximize then getgenv().TroxzyAPI.UIHooks.maximize() end; if _G.ToggleStates and _G.ToggleStates["PANIC_MODE"] then _G.ToggleStates["PANIC_MODE"].SetState(false) end end

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
    if AutoQueueListener then AutoQueueListener:Disconnect() end; moveToLift = false; STATE.moveToLift = false; mapCompleted = false; STATE.mapCompleted = false
    AutoQueueListener = Multiplayer.ChildAdded:Connect(function(newMap)
        if not AUTO_QUEUE_ENABLED or panicActive or isGhostMode then return end
        pcall(function() local s = newMap:WaitForChild("Settings", 5); if s then Stats.currentMap = s:GetAttribute("MapName") or "Unknown" end end)
        repeat task.wait() until Check("InGame") or not AUTO_QUEUE_ENABLED
        if not AUTO_QUEUE_ENABLED then return end; mapCompleted = false; STATE.mapCompleted = false
        if not TAS_RUNNING then getgenv().TomatoAutoFarm = false; task.spawn(ExecuteTAS) end
    end)
    AUTO_QUEUE_ENABLED = true; STATE.AUTO_QUEUE_ENABLED = true
end
function StopAutoQueue() if AutoQueueListener then AutoQueueListener:Disconnect(); AutoQueueListener = nil end; moveToLift = false; STATE.moveToLift = false; AUTO_QUEUE_ENABLED = false; STATE.AUTO_QUEUE_ENABLED = false; if TAS_RUNNING and TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE); TAS_RUNNING = false; STATE.TAS_RUNNING = false end end

task.spawn(function()
    while task.wait(0.5) do
        if (AUTO_QUEUE_ENABLED or getgenv().TomatoAutoFarm) and not panicActive and not isGhostMode then
            local char = Player.Character
            if char and char:FindFirstChild("HumanoidRootPart") and not Check("InGame") and not Check("InLift") and not TAS_RUNNING and not CurrentlyFarming then moveToLift = true; STATE.moveToLift = true; liftTarget = findLiftPosition() else moveToLift = false; STATE.moveToLift = false end
        else moveToLift = false; STATE.moveToLift = false end
    end
end)

TrackConnection(RunService.Heartbeat:Connect(function()
    if moveToLift and (AUTO_QUEUE_ENABLED or getgenv().TomatoAutoFarm) and not panicActive and not TAS_RUNNING then
        local char = Player.Character; local hum = char and char:FindFirstChild("Humanoid"); local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hrp and hum.Health > 0 and not Check("InGame") and not Check("InLift") and liftTarget then
            if (liftTarget - hrp.Position).Magnitude > 3 then hum:MoveTo(liftTarget); hum.WalkSpeed = 25 else pcall(function() AddedWaiting:FireServer() end); moveToLift = false; STATE.moveToLift = false end
        end
    end
end))

TrackConnection(Player.CharacterAdded:Connect(function() refreshNoclip(); ncActive = false; if not Check("InGame") then mapCompleted = false; STATE.mapCompleted = false end end))

-- =============================================
-- 🔥 AUTO REBIRTH SYSTEM v1.0 (FULLY INTEGRATED)
-- =============================================
local REBIRTH_CONFIG = {
    ENABLED = false,
    CHECK_INTERVAL = 5,
    AUTO_RESUME = true,
    MAX_RETRIES = 10,
    REBIRTH_DELAY_MIN = 2,
    REBIRTH_DELAY_MAX = 5,
    USE_REMOTE = true,
    REMOTE_NAMES = { "Rebirth", "Reborn", "Prestige", "Ascend", "Reset", "NewLife" },
    BUTTON_NAMES = { "Rebirth", "Reborn", "Prestige", "Ascend", "Reincarnate", "Reset" },
    LEVEL_ATTRIBUTE = "Level",
    MAX_LEVEL = 100,
    LEADERSTAT_NAME = "Level",
    REBIRTH_STAT_NAME = "Rebirth"
}

local RebirthState = {
    isRebirthing = false,
    rebirthCount = 0,
    lastRebirthTime = 0,
    attemptCount = 0,
    foundRemote = nil,
    foundButton = nil
}

local function findRebirthRemote()
    local paths = { ReplicatedStorage:FindFirstChild("Remote"), ReplicatedStorage:FindFirstChild("Remotes") }
    for _, folder in ipairs(paths) do
        if folder then
            for _, remote in pairs(folder:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") or remote:IsA("BindableEvent") or remote:IsA("BindableFunction") then
                    local lowerName = remote.Name:lower()
                    for _, name in ipairs(REBIRTH_CONFIG.REMOTE_NAMES) do
                        if lowerName:find(name:lower()) then return remote end
                    end
                end
            end
        end
    end
    -- Cari di path literal
    local commonPaths = { "Remote.Rebirth", "Remotes.Rebirth", "Events.Rebirth" }
    for _, path in ipairs(commonPaths) do
        local success, obj = pcall(function()
            local parts = string.split(path, ".")
            local current = ReplicatedStorage
            for _, part in ipairs(parts) do
                current = current:FindFirstChild(part)
                if not current then return nil end
            end
            return current
        end)
        if success and obj then return obj end
    end
    return nil
end

local function findRebirthButton()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ClickDetector") then
            local lowerName = obj.Name:lower()
            for _, name in ipairs(REBIRTH_CONFIG.BUTTON_NAMES) do
                if lowerName:find(name:lower()) then return obj end
            end
        elseif obj:IsA("BasePart") then
            local clickDetector = obj:FindFirstChild("ClickDetector")
            if clickDetector then
                local lowerName = obj.Name:lower()
                for _, name in ipairs(REBIRTH_CONFIG.BUTTON_NAMES) do
                    if lowerName:find(name:lower()) then return clickDetector end
                end
            end
        elseif obj:IsA("ProximityPrompt") then
            local lowerName = obj.Name:lower()
            for _, name in ipairs(REBIRTH_CONFIG.BUTTON_NAMES) do
                if lowerName:find(name:lower()) then return obj end
            end
        end
    end
    return nil
end

local function getCurrentLevel()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then
        local levelStat = leaderstats:FindFirstChild(REBIRTH_CONFIG.LEADERSTAT_NAME)
        if levelStat and (levelStat:IsA("IntValue") or levelStat:IsA("NumberValue")) then return levelStat.Value end
    end
    local char = Player.Character
    if char then
        local levelAttr = char:GetAttribute(REBIRTH_CONFIG.LEVEL_ATTRIBUTE)
        if levelAttr and type(levelAttr) == "number" then return levelAttr end
    end
    local levelAttr2 = Player:GetAttribute(REBIRTH_CONFIG.LEVEL_ATTRIBUTE)
    if levelAttr2 and type(levelAttr2) == "number" then return levelAttr2 end
    return 0
end

local function executeRebirth()
    if RebirthState.isRebirthing then return end
    RebirthState.isRebirthing = true

    if REBIRTH_CONFIG.USE_REMOTE then
        if not RebirthState.foundRemote then RebirthState.foundRemote = findRebirthRemote() end
        if RebirthState.foundRemote then
            local success = pcall(function()
                if RebirthState.foundRemote:IsA("RemoteEvent") or RebirthState.foundRemote:IsA("BindableEvent") then
                    RebirthState.foundRemote:FireServer()
                elseif RebirthState.foundRemote:IsA("RemoteFunction") or RebirthState.foundRemote:IsA("BindableFunction") then
                    RebirthState.foundRemote:InvokeServer()
                end
            end)
            if success then
                RebirthState.rebirthCount = RebirthState.rebirthCount + 1
                RebirthState.lastRebirthTime = os.clock()
                notify("🔄 Rebirth executed via Remote!", "Rebirth System")
                task.wait(math.random(REBIRTH_CONFIG.REBIRTH_DELAY_MIN, REBIRTH_CONFIG.REBIRTH_DELAY_MAX))
                RebirthState.isRebirthing = false
                return true
            end
        end
    end

    if not RebirthState.foundButton then RebirthState.foundButton = findRebirthButton() end
    if RebirthState.foundButton then
        local success = pcall(function()
            if RebirthState.foundButton:IsA("ClickDetector") then
                fireclickdetector(RebirthState.foundButton)
            elseif RebirthState.foundButton:IsA("ProximityPrompt") then
                fireproximityprompt(RebirthState.foundButton)
            end
        end)
        if success then
            RebirthState.rebirthCount = RebirthState.rebirthCount + 1
            RebirthState.lastRebirthTime = os.clock()
            notify("🔄 Rebirth executed via Button!", "Rebirth System")
            task.wait(math.random(REBIRTH_CONFIG.REBIRTH_DELAY_MIN, REBIRTH_CONFIG.REBIRTH_DELAY_MAX))
            RebirthState.isRebirthing = false
            return true
        end
    end

    RebirthState.foundRemote = nil
    RebirthState.foundButton = nil
    RebirthState.attemptCount = RebirthState.attemptCount + 1
    if RebirthState.attemptCount >= REBIRTH_CONFIG.MAX_RETRIES then
        notify("⚠️ Failed to find rebirth after " .. REBIRTH_CONFIG.MAX_RETRIES .. " attempts.", "Rebirth System")
        RebirthState.attemptCount = 0
    end
    RebirthState.isRebirthing = false
    return false
end

local AutoRebirthLoop = nil
local function StartAutoRebirth()
    if AutoRebirthLoop then return end
    AutoRebirthLoop = task.spawn(function()
        while REBIRTH_CONFIG.ENABLED do
            task.wait(REBIRTH_CONFIG.CHECK_INTERVAL)
            if not REBIRTH_CONFIG.ENABLED then break end
            if panicActive then continue end
            if RebirthState.isRebirthing then continue end

            local currentLevel = getCurrentLevel()
            if currentLevel >= REBIRTH_CONFIG.MAX_LEVEL then
                notify("🌟 Level " .. currentLevel .. " reached! Executing rebirth...", "Rebirth System")

                local wasFarming = getgenv().TomatoAutoFarm
                local wasTAS = TAS_RUNNING
                local wasQueue = AUTO_QUEUE_ENABLED

                if wasFarming then StopWinEngine() end
                if wasTAS and TAS_COROUTINE then
                    pcall(coroutine.close, TAS_COROUTINE)
                    TAS_COROUTINE = nil
                    TAS_RUNNING = false
                end

                task.wait(0.5)
                local rebirthSuccess = executeRebirth()

                if rebirthSuccess and REBIRTH_CONFIG.AUTO_RESUME then
                    task.wait(2)
                    if wasQueue then StartAutoQueue()
                    elseif wasFarming then getgenv().TomatoAutoFarm = true; StartWinEngine()
                    elseif wasTAS then task.spawn(ExecuteTAS) end
                end
            end
        end
    end)
end

local function StopAutoRebirth()
    REBIRTH_CONFIG.ENABLED = false
    AutoRebirthLoop = nil
end

getgenv().TroxzyAPI_Rebirth = {
    CONFIG = REBIRTH_CONFIG,
    STATE = RebirthState,
    Start = StartAutoRebirth,
    Stop = StopAutoRebirth,
    Execute = executeRebirth,
    GetLevel = getCurrentLevel,
    FindRemote = findRebirthRemote,
    FindButton = findRebirthButton
}

-- =============================================
-- BANGUN API UNTUK UI
-- =============================================
local API = {
    CONFIG = CONFIG,
    STATE = STATE,
    Stats = Stats,
    KeyTime = keyExpireTime,
    GetRealTime = GetRealTime,
    getAdminPlayers = getAdminPlayers,
    getSpectators = getSpectators,
    activatePanicMode = activatePanicMode,
    deactivatePanicMode = deactivatePanicMode,
    applyFloodColors = applyFloodColors,
    ExecuteTAS = ExecuteTAS,
    StartAutoQueue = StartAutoQueue,
    StopAutoQueue = StopAutoQueue,
    StartWinEngine = StartWinEngine,
    StopWinEngine = StopWinEngine,
    forceReconnect = forceReconnect,
    notify = notify,
    Rebirth = getgenv().TroxzyAPI_Rebirth,
    UIHooks = {}
}
getgenv().TroxzyAPI = API

-- ==================== LOAD UI DARI GITHUB ====================
local GITHUB_RAW_UI_URL = "MASUKAN_LINK_RAW_GITHUB_DISINI"
local success, uiScript = pcall(function() return game:HttpGet(GITHUB_RAW_UI_URL) end)
if success and uiScript then
    local runUI, err = loadstring(uiScript)
    if runUI then runUI() else warn("Gagal membaca kode UI dari GitHub: " .. tostring(err)) end
else
    warn("Gagal terhubung ke GitHub RAW UI!")
end

-- ==================== LOOP UTAMA ====================
local lastHeartbeat = 0
TrackConnection(RunService.Heartbeat:Connect(function()
    if os.clock() - lastHeartbeat < 0.1 then return end; lastHeartbeat = os.clock()
    pcall(function()
        local ch = Player.Character; if not ch then return end; local hum = ch:FindFirstChild("Humanoid"); if not hum then return end
        if CONFIG.NOCLIP and not CurrentlyFarming then refreshNoclip(); applyNoclip(true) elseif not CurrentlyFarming then applyNoclip(false) end
        if not CurrentlyFarming then hum.WalkSpeed = CONFIG.SPEED and CONFIG.SPEED_VAL or (moveToLift and 20 or 16) end
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not CONFIG.GOD_MODE)
        if CONFIG.AIR_SWIM then hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false) else hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true) end
    end)
    pcall(handleAdminDetection)
    if API.UIHooks.updateDashboard then pcall(API.UIHooks.updateDashboard) end
end))
TrackConnection(RunService.Heartbeat:Connect(function() pcall(updateESP); pcall(updateVisuals) end))

-- Hotkeys
TrackConnection(UIS.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == Enum.KeyCode.P then if not panicActive then activatePanicMode() else deactivatePanicMode() end end end))
TrackConnection(UIS.JumpRequest:Connect(function() if CONFIG.INF_JUMP and Player.Character then local h = Player.Character:FindFirstChild("Humanoid"); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end))

loadStats(); setupAutoReconnect()
notify("TROXZY VIP - ALL FEATURES + AUTO REBIRTH LOADED", "System")
