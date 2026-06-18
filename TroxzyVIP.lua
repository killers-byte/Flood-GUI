-- ============================================
-- TROXZY VIP - MASTER SEAMLESS EDITION v20.5
-- 🔥 Auto Queue Seamless + Anti-Delay Watchdog
-- 🔄 Auto-Updater GitHub Connected
-- ============================================

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(2)

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

-- Global Vars
_G.TroxzyAutoFarm = false
local CurrentlyFarming = false
local Escaped = false
local Main, ToggleBtn, MapDetect = nil, nil, nil
local TAS_COROUTINE, TAS_RUNNING = nil, false
local AUTO_QUEUE_ENABLED = false
local panicActive = false
_G.ToggleStates = {}

-- Setup Connection Management
_G.TroxzyConnections = {}
local function TrackConnection(conn) table.insert(_G.TroxzyConnections, conn); return conn end

-- Utility Functions
local function notify(msg, title) pcall(function() StarterGui:SetCore("SendNotification", {Title = title or "Troxzy VIP", Text = msg, Duration = 2}) end) end
local function addCorner(obj, r) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = obj end
local function addStroke(obj, color, thickness, transparency) local s = Instance.new("UIStroke"); s.Color = color; s.Thickness = thickness; s.Transparency = transparency; s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = obj end
local function Tween(obj, props, time) if obj then TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play() end end

-- Config
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

-- [TAS ENGINE - ANTI DELAY]
local function ExecuteTAS()
    if TAS_RUNNING then return end
    _G.TroxzyAutoFarm = false; CurrentlyFarming = false
    local url = "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TAS/PLAYER/newtasplayer.luau"
    local success, scriptContent = pcall(function() return game:HttpGet(url) end)
    if success and scriptContent then
        local func = loadstring(scriptContent)
        if func then
            TAS_COROUTINE = coroutine.create(function()
                TAS_RUNNING = true
                pcall(func)
                TAS_RUNNING = false
            end)
            coroutine.resume(TAS_COROUTINE)
        end
    end
end

-- [SEAMLESS MASTER LOOP - WATCHDOG ANTI-DIAM]
local lastQueueAttempt = 0
TrackConnection(RunService.Heartbeat:Connect(function()
    if not AUTO_QUEUE_ENABLED or panicActive then return end
    local now = os.clock()
    if now - lastQueueAttempt < 1 then return end
    lastQueueAttempt = now

    local char = Player.Character; local hum = char and char:FindFirstChild("Humanoid"); local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if char and hum and hrp and hum.Health > 0 then
        -- In Game Check
        if (hrp.Position.X > 50) then
            if not TAS_RUNNING then task.spawn(ExecuteTAS) end
        -- In Lobby Check
        elseif not (hrp.Position.X < 50 and hrp.Position.Z > 70) then
            pcall(function() ReplicatedStorage.Remote.AddedWaiting:FireServer() end)
            -- Watchdog: Paksa gerak jika diam
            if hrp.Velocity.Magnitude < 0.5 then
                hum:MoveTo(hrp.Position + Vector3.new(math.random(-15, 15), 0, math.random(-15, 15)))
            end
        end
    end
end))

-- UI Setup (Shortened for space, keep full logic)
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "TROXZY_VIP"
local Main = Instance.new("Frame", ScreenGui); Main.Size = UDim2.new(0,390,0,540); Main.Position = UDim2.new(0.5,-195,0.5,-270); Main.BackgroundColor3 = Color3.fromRGB(17,17,26); addCorner(Main, 10); Main.Draggable = true

-- Helper UI Function (With Notification)
local function AddToggle(tabKey, name, stateKey)
    -- [Logika UI Toggle sama seperti sebelumnya]
    -- PENTING: Di dalam callback, tambahkan: notify(name .. " is now " .. (state and "ON" or "OFF"), "Status")
    -- (Logika UI penuh dipersingkat di sini agar muat, silakan gunakan fungsi AddToggle dari script sebelumnya)
end

-- [UPDATE ENGINE GITHUB]
local function CheckForUpdates()
    notify("Checking GitHub for updates...", "Updater")
    local updateUrl = "https://raw.githubusercontent.com/killers-byte/Flood-GUI/refs/heads/main/TroxzyVIP.lua"
    local success, newScript = pcall(function() return game:HttpGet(updateUrl) end)
    if success and newScript and #newScript > 100 then
        notify("Update found! Reloading...", "Updater")
        task.wait(1)
        loadstring(newScript)()
    else
        notify("Already up to date.", "Updater")
    end
end

-- [MAIN UI BUILDING - PANGGIL FUNGSI ADD TOGGLE DENGAN NOTIFIKASI]
-- Tambahkan baris ini di bagian callback toggle:
-- notify(name .. " is now " .. (state and "ON" or "OFF"), "Settings")

-- [EVENT RESPAWN FIX]
TrackConnection(Player.CharacterAdded:Connect(function()
    task.wait(1)
    if AUTO_QUEUE_ENABLED then
        TAS_RUNNING = false
        if TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE) end
        notify("Respawn detected. Re-syncing...", "System")
    end
end))

notify("Troxzy VIP Seamless Ready!", "Success")
