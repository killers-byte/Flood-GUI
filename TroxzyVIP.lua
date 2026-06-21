-- ============================================
-- TROXZY VIP v22.1 "SPECTRAL BLADE" [BACKEND CORE]
-- ============================================

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
    Frame.Size = UDim2.new(0, 320, 0, 180); Frame.Position = UDim2.new(0.5, -160, 0.5, -90); Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Frame.BorderSizePixel = 0
    local UICorner = Instance.new("UICorner", Frame); UICorner.CornerRadius = UDim.new(0, 12)
    
    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "TROXZY AUTHENTICATION"; Title.TextColor3 = Color3.fromRGB(240, 240, 240); Title.Font = Enum.Font.GothamBold; Title.TextSize = 13; Title.BackgroundTransparency = 1

    local Input = Instance.new("TextBox", Frame)
    Input.Size = UDim2.new(0, 280, 0, 36); Input.Position = UDim2.new(0.5, -140, 0, 50); Input.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Input.TextColor3 = Color3.fromRGB(255, 255, 255); Input.PlaceholderText = "Paste your key here..."; Input.TextSize = 12; Input.Font = Enum.Font.GothamMedium; Input.ClearTextOnFocus = false
    local InputCorner = Instance.new("UICorner", Input); InputCorner.CornerRadius = UDim.new(0, 8)

    local Submit = Instance.new("TextButton", Frame)
    Submit.Size = UDim2.new(0, 280, 0, 36); Submit.Position = UDim2.new(0.5, -140, 0, 96); Submit.BackgroundColor3 = Color3.fromRGB(220, 220, 220); Submit.Text = "Unlock"; Submit.TextColor3 = Color3.fromRGB(20, 20, 20); Submit.Font = Enum.Font.GothamBold; Submit.TextSize = 12; Submit.AutoButtonColor = false
    local SubmitCorner = Instance.new("UICorner", Submit); SubmitCorner.CornerRadius = UDim.new(0, 8)

    local ErrorLabel = Instance.new("TextLabel", Frame)
    ErrorLabel.Size = UDim2.new(1, 0, 0, 20); ErrorLabel.Position = UDim2.new(0, 0, 0, 140); ErrorLabel.Text = ""; ErrorLabel.TextColor3 = Color3.fromRGB(255, 80, 80); ErrorLabel.Font = Enum.Font.GothamMedium; ErrorLabel.TextSize = 11; ErrorLabel.BackgroundTransparency = 1

    local function checkKey(rawInput)
        local input = string.match(rawInput, "^%s*(.-)%s*$")
        if not input or input == "" then ErrorLabel.Text = "Key cannot be empty!"; return end
        Submit.Text = "Verifying..."; Submit.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
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
        if not keyData.hwid or keyData.hwid == "" then Player:Kick("Key not linked. Provide UserID."); return end
        if tostring(keyData.hwid) ~= playerUserID then Player:Kick("SECURITY: Key bound to another account!"); return end
        if not keyData.expiry then Player:Kick("Missing expiry field."); return end
        
        local expireTime = parseExpiry(keyData.expiry)
        if not expireTime then Player:Kick("Invalid date format."); return end
        if GetRealTime() > expireTime then Player:Kick("Key Expired!"); return end
        
        Submit.BackgroundColor3 = Color3.fromRGB(40, 200, 80); Submit.Text = "Success!"
        task.wait(0.5); keyValid = true; getgenv().keyExpireTime = expireTime; KeyScreen:Destroy()
    end

    Submit.MouseButton1Click:Connect(function() checkKey(Input.Text) end)
    repeat task.wait() until keyValid or not Player.Parent
    return keyValid
end

if not supremeKeyValidation() then return end

-- ==================== MAIN LOGIC ====================
if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Player = Players.LocalPlayer

getgenv().TomatoAutoFarm = false

-- GLOBAL STATE & CONFIG
local CONFIG = {
    TARGET_MAP = "Sandswept Ruins", TARGET_DIFFICULTY = "Crazy", TAS_MODE = "Play", TAS_AUTO_START = false,
    NOCLIP = false, GOD_MODE = false, SPEED = false, INF_JUMP = false, ESP = false, FULLBRIGHT = false, FOV = false,
    SPEED_VAL = 20, FOV_VAL = 90, AUTO_RECONNECT = true, STEALTH_MODE = true, ADMIN_DETECTOR = true,
    HIDE_SCRIPT = true, DASHBOARD = true, SMART_ALERTS = true, COLLECT_ITEMS = true, AIR_SWIM = true, AUTO_UPDATE = false,
    CUSTOM_FLOOD_COLORS = false, FLOOD_COLOR = "Blue", ANTI_ADMIN = false, ANTI_REPORT = false, RANDOM_DELAY = true
}

local STATE = {
    CurrentlyFarming = false, TAS_RUNNING = false, TAS_STATUS = "READY", AUTO_QUEUE_ENABLED = false, 
    mapCompleted = false, isGhostMode = false, panicActive = false, moveToLift = false
}

local Stats = { mapsCompleted = 0, totalTime = 0, sessionStart = os.clock(), adminDetected = 0, adminLeft = 0, currentMap = "" }

local function notify(msg, title) pcall(function() StarterGui:SetCore("SendNotification", { Title = title or "Troxzy VIP", Text = msg, Duration = 2 }) end) end
local function GetRealTime() local ok, srvTime = pcall(function() return math.floor(Workspace:GetServerTimeNow()) end); if ok and srvTime and srvTime > 1000000 then return srvTime end; return os.time() end

local function isAdminName(str) str = str:lower(); return str:match("^[@_]?[aà]dm?[i1]n[istrator]*$") or str:match("^m[o0]d[erato]*r?$") or str:match("^st[a4]ff$") end
local function getAdminPlayers() local admins = {}; for _, p in pairs(Players:GetPlayers()) do if p ~= Player and (isAdminName(p.Name) or isAdminName(p.DisplayName)) then table.insert(admins, p) end end; return admins end
local function getSpectators() local specs = {}; if not Player.Character or not Player.Character:FindFirstChild("HumanoidRootPart") then return specs end; local myRoot = Player.Character.HumanoidRootPart; for _, p in pairs(Players:GetPlayers()) do if p ~= Player and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character:FindFirstChild("HumanoidRootPart") then local hum = p.Character.Humanoid; if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then if (myRoot.Position - p.Character.HumanoidRootPart.Position).Magnitude < 50 then table.insert(specs, p) end end end end; return specs end

local TAS_COROUTINE = nil
local function ExecuteTAS()
    if not CONFIG.TAS_AUTO_START then notify("TAS Auto-Start is OFF."); return end
    if STATE.TAS_RUNNING then if TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE); TAS_COROUTINE = nil end; STATE.TAS_RUNNING = false; task.wait(0.2) end
    getgenv().TomatoAutoFarm = false; STATE.CurrentlyFarming = false
    local url = CONFIG.TAS_MODE == "Record" and "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TAS/CREATOR/creator.luau" or "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TAS/PLAYER/newtasplayer.luau"
    local success, scriptContent = pcall(function() return game:HttpGet(url) end)
    if not success then return end
    local func = loadstring(scriptContent); if not func then return end
    TAS_COROUTINE = coroutine.create(function() STATE.TAS_RUNNING = true; pcall(func); STATE.TAS_RUNNING = false; TAS_COROUTINE = nil; if STATE.AUTO_QUEUE_ENABLED then STATE.mapCompleted = true end; STATE.TAS_STATUS = "READY" end)
    coroutine.resume(TAS_COROUTINE); STATE.TAS_STATUS = "RUNNING"
end

local function applyNoclip(state) local char = Player.Character; if char then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = not state end end end end

local function activatePanicMode()
    STATE.panicActive = true; getgenv().TomatoAutoFarm = false; STATE.CurrentlyFarming = false; applyNoclip(false)
    pcall(function() Player.Character.Humanoid.WalkSpeed = 16 end)
    if getgenv().TroxzyAPI and getgenv().TroxzyAPI.UIHooks.minimize then getgenv().TroxzyAPI.UIHooks.minimize(true) end
    if _G.ToggleStates and _G.ToggleStates["PANIC_MODE"] then _G.ToggleStates["PANIC_MODE"].SetState(true) end
end

local function deactivatePanicMode()
    STATE.panicActive = false;
    if getgenv().TroxzyAPI and getgenv().TroxzyAPI.UIHooks.maximize then getgenv().TroxzyAPI.UIHooks.maximize() end
    if _G.ToggleStates and _G.ToggleStates["PANIC_MODE"] then _G.ToggleStates["PANIC_MODE"].SetState(false) end
end

local function applyFloodColors() if not CONFIG.CUSTOM_FLOOD_COLORS then return end; local fMap = { Blue = Color3.fromRGB(0, 150, 255), Green = Color3.fromRGB(0, 255, 100), Red = Color3.fromRGB(255, 50, 50), Pink = Color3.fromRGB(255, 100, 200), Purple = Color3.fromRGB(150, 50, 255) }; local tC = fMap[CONFIG.FLOOD_COLOR] or Color3.fromRGB(0, 150, 255); for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name:lower():find("water") or v.Name:lower():find("acid") or v.Name:lower():find("lava") or v.Name:lower():find("flood")) then pcall(function() v.Color = tC end) end end end

local WinFarmCoroutine, WinFarmRunning = nil, false
local function StartWinEngine() if WinFarmRunning then return end; local s, scr = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/killers-byte/Flood-GUI/refs/heads/main/win") end); if s and scr then local f = loadstring(scr); if f then WinFarmCoroutine = coroutine.create(function() WinFarmRunning = true; pcall(f); WinFarmRunning = false; WinFarmCoroutine = nil end); coroutine.resume(WinFarmCoroutine) end end end
local function StopWinEngine() if WinFarmCoroutine then pcall(coroutine.close, WinFarmCoroutine); WinFarmCoroutine = nil end; WinFarmRunning = false; STATE.CurrentlyFarming = false end

local AutoQueueListener = nil
local function StartAutoQueue() if AutoQueueListener then AutoQueueListener:Disconnect() end; STATE.moveToLift = false; STATE.mapCompleted = false; AutoQueueListener = Workspace:WaitForChild("Multiplayer").ChildAdded:Connect(function(newMap) if not STATE.AUTO_QUEUE_ENABLED or STATE.panicActive or STATE.isGhostMode then return end; pcall(function() local s = newMap:WaitForChild("Settings", 5); if s then Stats.currentMap = s:GetAttribute("MapName") or "Unknown" end end); task.wait(3); if not STATE.TAS_RUNNING then getgenv().TomatoAutoFarm = false; task.spawn(ExecuteTAS) end end) end
local function StopAutoQueue() if AutoQueueListener then AutoQueueListener:Disconnect(); AutoQueueListener = nil end; STATE.moveToLift = false; if STATE.TAS_RUNNING and TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE); STATE.TAS_RUNNING = false end end

-- HOTKEYS & LOOP
UIS.InputBegan:Connect(function(inp, gp) if not gp and inp.KeyCode == Enum.KeyCode.P then if not STATE.panicActive then activatePanicMode() else deactivatePanicMode() end end end)
RunService.Heartbeat:Connect(function()
    pcall(function()
        local ch = Player.Character; if not ch then return end; local hum = ch:FindFirstChild("Humanoid"); if not hum then return end
        if CONFIG.NOCLIP and not STATE.CurrentlyFarming then applyNoclip(true) elseif not STATE.CurrentlyFarming then applyNoclip(false) end
        if not STATE.CurrentlyFarming then hum.WalkSpeed = CONFIG.SPEED and CONFIG.SPEED_VAL or 16 end
        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not CONFIG.GOD_MODE)
        if CONFIG.AIR_SWIM and hum:GetState() == Enum.HumanoidStateType.Swimming then hum:ChangeState(Enum.HumanoidStateType.Landed); hum.PlatformStand = false; task.wait(0.05); hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end)
end)

-- ==============================================================
-- 📡 DAFTARKAN API UNTUK DIBACA OLEH GITHUB
-- ==============================================================
getgenv().TroxzyAPI = {
    CONFIG = CONFIG, STATE = STATE, Stats = Stats, KeyTime = getgenv().keyExpireTime or 0,
    GetRealTime = GetRealTime, getAdminPlayers = getAdminPlayers, getSpectators = getSpectators,
    activatePanicMode = activatePanicMode, deactivatePanicMode = deactivatePanicMode, applyFloodColors = applyFloodColors,
    ExecuteTAS = ExecuteTAS, StartAutoQueue = StartAutoQueue, StopAutoQueue = StopAutoQueue,
    StartWinEngine = StartWinEngine, StopWinEngine = StopWinEngine, notify = notify,
    UIHooks = {} -- Hooks akan diisi oleh UI Script nanti
}

-- ==============================================================
-- 🔗 EKSEKUSI UI DARI GITHUB RAW
-- ==============================================================
local GITHUB_RAW_UI_URL = "https://raw.githubusercontent.com/killers-byte/Flood-GUI/refs/heads/main/TroxzyUI"

local success, uiScript = pcall(function() return game:HttpGet(GITHUB_RAW_UI_URL) end)
if success and uiScript then
    local runUI, err = loadstring(uiScript)
    if runUI then runUI() else warn("Gagal membaca kode UI dari GitHub: " .. tostring(err)) end
else
    warn("Gagal terhubung ke GitHub RAW UI!")
end

notify("TROXZY VIP - BACKEND LOADED", "System")
