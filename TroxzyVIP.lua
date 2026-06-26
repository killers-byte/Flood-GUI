-- ============================================
-- TROXZY VIP v24.18 "SPECTRAL BLADE" [BACKEND CORE - GOD MODE]
-- Badan Intelijen Negara - DASHBOARD INTEGRATED + STRICT ADMIN DETECT
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
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local NetworkClient = game:GetService("NetworkClient")
local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local PathfindingService = nil
pcall(function() PathfindingService = game:GetService("PathfindingService") end)

getgenv().TomatoAutoFarm = false; getgenv().TomatoConnections = getgenv().TomatoConnections or {}; _G.TroxzyAutoFarm = false

local TAS_COROUTINE = nil
local AutoQueueListener = nil
local liftTarget = nil
local lastAdminCount = 0
local lastAdminAlert = 0
local SoundPool = {}
local ESP_IDENTIFIER = "TX_ESP_" .. tostring(math.random(100000, 999999))

local EXECUTOR_CAPS = {
    CAN_HOOK = pcall(function() return hookfunction end),
    CAN_GETGC = pcall(function() return getgc end),
    CAN_DRAWING = pcall(function() return Drawing end),
    CAN_GETSENV = pcall(function() return getsenv end),
    IS_64BIT = pcall(function() return syn and syn.set_thread_identity end) or (identifyexecutor and identifyexecutor():lower():find("syn")),
}
local EXECUTOR_NAME = "Unknown"
pcall(function() EXECUTOR_NAME = identifyexecutor() or "Unknown" end)

local function getPooledSound() if #SoundPool > 0 then local s = table.remove(SoundPool); if s and s.Parent then return s end end; local s = Instance.new("Sound"); s.Volume = 0.5; return s end
local function returnSoundToPool(s) if s then s:Stop(); s.Parent = nil; table.insert(SoundPool, s) end end
local SOUND_IDS = { alert = 9116456845, warning = 9120388711 }
local function playSound(id) pcall(function() local s = getPooledSound(); s.SoundId = "rbxassetid://" .. id; s.Parent = Workspace; s:Play(); task.delay(3, function() returnSoundToPool(s) end) end) end

if _G.TroxzyConnections then for _, conn in pairs(_G.TroxzyConnections) do pcall(function() conn:Disconnect() end) end end
_G.TroxzyConnections = {}
local function TrackConnection(conn) table.insert(_G.TroxzyConnections, conn); return conn end
local function notify(msg, title) pcall(function() StarterGui:SetCore("SendNotification", { Title = title or "Troxzy VIP", Text = msg, Duration = 4 }) end) end

local CONFIG = {
    TARGET_MAP = "Sandswept Ruins", TARGET_DIFFICULTY = "Crazy", TAS_MODE = "Play", TAS_AUTO_START = false,
    NOCLIP = false, GOD_MODE = false, SPEED = false, INF_JUMP = false, ESP = false, FULLBRIGHT = false, FOV = false,
    SPEED_VAL = 20, FOV_VAL = 90, AUTO_RECONNECT = true, STEALTH_MODE = true, ADMIN_DETECTOR = true,
    HIDE_SCRIPT = true, DASHBOARD = true, SMART_ALERTS = true, AIR_SWIM = true, AUTO_UPDATE = false,
    CUSTOM_FLOOD_COLORS = false, FLOOD_COLOR = "Blue", ANTI_ADMIN = false, ANTI_REPORT = true,
    RANDOM_DELAY = true, AUTO_HOP_ADMIN = true, SPOOF_NAME = true, CLEAN_CHAR = true, ANTI_SS = true, ANTI_SPY = true,
    ADAPTIVE_ESP = true,
    MEMORY_CAMO = true,
    ANTI_TAMPER = true,
    NEURAL_PATH_CORRECT = true,
    SPECTATOR_TRAP = true,
    ADMIN_BEHAVIOR_ANALYTICS = true,
    PROFIT_EXP_PER_MAP = 40,
    PROFIT_COIN_PER_MAP = 20
}

local STATE = { 
    AUTO_QUEUE_ENABLED = false, TAS_RUNNING = false, panicActive = false, 
    isGhostMode = false, moveToLift = false, mapCompleted = false, CurrentlyFarming = false,
    CurrentAdmins = "None", CurrentSpectators = "None",
    HybridActive = false, CounterMeasureActive = false,
    RECORDING_TAS = false,
    RecordedWaypoints = {},
    RecordStartTime = 0
}

local Stats = { mapsCompleted = 0, totalTime = 0, sessionStart = os.clock(), adminDetected = 0, adminLeft = 0, currentMap = "", ServerPing = 0 }
local function loadStats() pcall(function() if isfile("Troxzy_Stats.json") then local d = HttpService:JSONDecode(readfile("Troxzy_Stats.json")); for k, v in pairs(d) do if Stats[k] ~= nil then Stats[k] = v end end end end); Stats.sessionStart = os.clock() end
local function saveStats() pcall(function() Stats.totalTime = Stats.totalTime + (os.clock() - Stats.sessionStart); writefile("Troxzy_Stats.json", HttpService:JSONEncode(Stats)); Stats.sessionStart = os.clock() end) end

-- [ Adaptive Tick Rate ]
local FastTick = 0.1
local SlowTickRate = 1.0
local LastSlowTick = 0
local LastFastTick = 0

-- [ Watermark (memory leak fixed) ]
local WatermarkGui = nil
local function applyWatermark()
    if not CONFIG.ANTI_SS then
        if WatermarkGui then WatermarkGui:Destroy(); WatermarkGui = nil end
        return
    end
    if WatermarkGui and WatermarkGui.Parent then return end
    local sg = Instance.new("ScreenGui", CoreGui)
    sg.Name = "TX_WATERMARK"
    sg.IgnoreGuiInset = true; sg.DisplayOrder = 99999
    local txt = Instance.new("TextLabel", sg)
    txt.Size = UDim2.new(1, 0, 1, 0); txt.BackgroundTransparency = 1
    txt.Text = "TROXZY VIP - CLASSIFIED OVERRIDE"
    txt.TextColor3 = Color3.fromRGB(255, 255, 255); txt.TextTransparency = 0.98
    txt.TextSize = 50; txt.Rotation = 35; txt.Font = Enum.Font.GothamBlack
    WatermarkGui = sg
end

-- [ Memory Camouflage ]
local function camouflageGUIs()
    if not CONFIG.MEMORY_CAMO then return end
    local mainGui = CoreGui:FindFirstChild("TROXZY_VIP")
    if mainGui then mainGui.Name = "GUI_" .. tostring(math.random(100000, 999999)) end
    if WatermarkGui and WatermarkGui.Parent then WatermarkGui.Name = "WM_" .. tostring(math.random(1000, 9999)) end
end

-- [ Anti-Tamper API Protection ]
local function protectAPI()
    if not CONFIG.ANTI_TAMPER then return end
    local api = getgenv().TroxzyAPI
    if not api then return end
    local mt = getrawmetatable(api) or {}
    local orig_index = mt.__index
    mt.__index = function(t, k)
        local caller = ""
        pcall(function() caller = debug.info(2, "s") end)
        if caller ~= "" and not caller:find("Troxzy") and not caller:find("BIN") then
            notify("⚠️ Unauthorized API access!", "SECURITY")
            if not STATE.panicActive then activatePanicMode() end
            return nil
        end
        if orig_index then return orig_index(t, k) end
        return nil
    end
    pcall(function() setreadonly(mt, true) end)
end

-- [ Neural Path Correction ]
local StuckDetection = { lastPos = Vector3.zero, lastCheck = 0, stuckThreshold = 5 }
local function checkStuckAndCorrect()
    if not CONFIG.NEURAL_PATH_CORRECT then return end
    if not PathfindingService then return end
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local now = os.clock()
    if now - StuckDetection.lastCheck > 2 then
        if (hrp.Position - StuckDetection.lastPos).Magnitude < 1 and (now - StuckDetection.lastCheck > StuckDetection.stuckThreshold) then
            local targetPos = Workspace:FindFirstChild("Lobby") and Workspace.Lobby:FindFirstChild("TeleportPart") and Workspace.Lobby.TeleportPart.Position or hrp.Position + Vector3.new(0, 10, 20)
            local path = PathfindingService:CreatePath()
            local success, err = pcall(function() path:ComputeAsync(hrp.Position, targetPos) end)
            if success and path.Status == Enum.PathStatus.Success then
                local waypoints = path:GetWaypoints()
                for _, wp in ipairs(waypoints) do
                    if wp.Action == Enum.PathWaypointAction.Walk then
                        char:FindFirstChild("Humanoid"):MoveTo(wp.Position)
                        break
                    end
                end
            end
        end
        StuckDetection.lastPos = hrp.Position
        StuckDetection.lastCheck = now
    end
end

-- [ TAS Recording ]
function StartRecordingTAS()
    STATE.RECORDING_TAS = true
    STATE.RecordedWaypoints = {}
    STATE.RecordStartTime = os.clock()
    notify("🔴 Recording TAS...", "TAS Recorder")
end
function StopRecordingTAS()
    if not STATE.RECORDING_TAS then return end
    STATE.RECORDING_TAS = false
    local data = HttpService:JSONEncode(STATE.RecordedWaypoints)
    local filename = "Troxzy_CustomTAS_" .. (Stats.currentMap or "Unknown") .. ".json"
    pcall(function() writefile(filename, data) end)
    notify("✅ TAS tersimpan", "TAS Recorder")
end
local lastRecordPos = nil
local function recordWaypoint()
    if not STATE.RECORDING_TAS then return end
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local pos = hrp.Position
    if lastRecordPos and (pos - lastRecordPos).Magnitude < 1 then return end
    table.insert(STATE.RecordedWaypoints, {t = os.clock() - STATE.RecordStartTime, x = pos.X, y = pos.Y, z = pos.Z})
    lastRecordPos = pos
end

-- [ Spectator Trap ]
local function activateSpectatorTrap()
    if not CONFIG.SPECTATOR_TRAP then return end
    local lobby = Workspace:FindFirstChild("Lobby")
    if lobby then
        local decoy = Instance.new("Part")
        decoy.Size = Vector3.new(2, 5, 1)
        decoy.Position = lobby:FindFirstChild("SpawnLocation") and lobby.SpawnLocation.Position + Vector3.new(math.random(-5,5), 0, math.random(-5,5)) or Vector3.new(25, 5, 85)
        decoy.Anchored = true; decoy.CanCollide = false; decoy.BrickColor = BrickColor.random()
        decoy.Parent = Workspace
        task.delay(5, function() pcall(function() decoy:Destroy() end) end)
    end
    local chatRemote = ReplicatedStorage:FindFirstChild("Remote"):FindFirstChild("ChatMessage") or ReplicatedStorage:FindFirstChild("Chat")
    if chatRemote and chatRemote:IsA("RemoteEvent") then
        pcall(function() chatRemote:FireServer("LAG PARAH, GW KICK") end)
    end
end

-- [ Admin Behavior Analytics ]
local PlayerAnalytics = {}
local function updatePlayerAnalytics()
    if not CONFIG.ADMIN_BEHAVIOR_ANALYTICS then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player then
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos = hrp.Position; local t = os.clock()
                if not PlayerAnalytics[p] then
                    PlayerAnalytics[p] = {positions = {}, lastPos = pos, lastTime = t, flaggedAdmin = false}
                end
                local ana = PlayerAnalytics[p]
                table.insert(ana.positions, {t = t, pos = pos})
                while #ana.positions > 0 and t - ana.positions[1].t > 30 do table.remove(ana.positions, 1) end
                if #ana.positions >= 2 then
                    local dist = (pos - ana.lastPos).Magnitude; local dt = t - ana.lastTime
                    if dt > 0.1 then
                        local speed = dist / dt
                        if speed > 100 or (speed < 1 and dt > 10) then ana.flaggedAdmin = true end
                    end
                end
                ana.lastPos = pos; ana.lastTime = t
            else
                PlayerAnalytics[p] = nil
            end
        end
    end
    for p, _ in pairs(PlayerAnalytics) do if not p.Parent then PlayerAnalytics[p] = nil end end
end

-- [ STRICT ADMIN DETECTION ]
local function isAdmin(p)
    if not p then return false end
    -- Owner game
    if p.UserId == game.CreatorId then return true end
    -- Roblox Admin group
    local success, isRobloxAdmin = pcall(function() return p:IsInGroup(1200769) end)
    if success and isRobloxAdmin then return true end
    -- GUI Admin di PlayerGui
    local pGui = p:FindFirstChild("PlayerGui")
    if pGui then
        if pGui:FindFirstChild("HDAdminGUIs") or pGui:FindFirstChild("Adonis_UI") or pGui:FindFirstChild("KohlsAdmin") or pGui:FindFirstChild("AdminUI") then return true end
    end
    -- Leaderstats admin/mod/owner
    local leaderstats = p:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in ipairs(leaderstats:GetChildren()) do
            local lowerName = stat.Name:lower()
            if lowerName == "admin" or lowerName == "mod" or lowerName == "rank" or lowerName == "role" or lowerName == "staff" then
                local val = tostring(stat.Value):lower()
                if val == "admin" or val == "mod" or val == "owner" or val == "dev" or val == "staff" or val == "creator" or val == "headadmin" then return true end
            end
        end
    end
    -- Behavior flagged
    if PlayerAnalytics[p] and PlayerAnalytics[p].flaggedAdmin then return true end
    return false
end

local function Check(flag) local char = Player.Character; if not char then return false end; local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return false end; if flag == "InLift" then return hrp.Position.X < 50 and hrp.Position.Z > 70 elseif flag == "InGame" then return hrp.Position.X > 50 end return false end
local function getAdminPlayers() local admins = {}; for _, p in pairs(Players:GetPlayers()) do if p ~= Player and isAdmin(p) then table.insert(admins, p) end end; return admins end
local function getAdminNames() local names = {}; for _, p in ipairs(getAdminPlayers()) do table.insert(names, p.Name) end; return names end

local function getPlayersInLobbyLift()
    local entries = {}
    local myChar = Player.Character
    if not myChar then return entries end
    local myHrp = myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp or myHrp.Position.X <= 50 then return entries end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player then
            local char = p.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local x = hrp.Position.X; local z = hrp.Position.Z
                    if x < 50 then
                        local loc = "LOBY"
                        if z > 70 then loc = "LIFT" end
                        table.insert(entries, {name = p.Name, location = loc})
                    end
                end
            end
        end
    end
    table.sort(entries, function(a, b) return a.name < b.name end)
    return entries
end

local function getSpectatorDisplayNames()
    local entries = getPlayersInLobbyLift()
    local displayNames = {}
    for _, entry in ipairs(entries) do table.insert(displayNames, entry.name .. " [ " .. entry.location .. " ]") end
    return displayNames
end

local function getSpectators()
    local specs = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= Player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.X < 50 then table.insert(specs, p) end
        end
    end
    return specs
end
local function getSpectatorNames() return getSpectatorDisplayNames() end

local function activateCounterMeasures() if STATE.CounterMeasureActive then return end; STATE.CounterMeasureActive = true end
local function deactivateCounterMeasures() if not STATE.CounterMeasureActive then return end; STATE.CounterMeasureActive = false end

local function blockAdminRemotes()
    local RemoteFolder = ReplicatedStorage:FindFirstChild("Remote")
    if not RemoteFolder then return end
    local dangerousKeywords = { "kick", "ban", "punish", "jail", "teleport", "freeze", "spectate", "kill", "crash" }
    for _, remote in ipairs(RemoteFolder:GetChildren()) do if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then local lowerName = remote.Name:lower(); for _, kw in ipairs(dangerousKeywords) do if lowerName:find(kw) then remote.OnClientEvent:Connect(function() end); break end end end end
end

local function activateGhostMode()
    if STATE.isGhostMode then return end
    STATE.isGhostMode = true
    getgenv().TomatoAutoFarm = false; STATE.CurrentlyFarming = false
    StopWinEngine()
    if TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE) end
    TAS_COROUTINE = nil; STATE.TAS_RUNNING = false
    if getgenv().TroxzyAPI and getgenv().TroxzyAPI.StopAutoQueue then getgenv().TroxzyAPI.StopAutoQueue() end
    pcall(function() Player.Character.Humanoid.WalkSpeed = 16 end)
    if getgenv().TroxzyAPI and getgenv().TroxzyAPI.UIHooks.hide then getgenv().TroxzyAPI.UIHooks.hide() end
    if CONFIG.SMART_ALERTS then playSound(SOUND_IDS.alert) end
end
local function deactivateGhostMode()
    if not STATE.isGhostMode then return end
    STATE.isGhostMode = false
    if getgenv().TroxzyAPI and getgenv().TroxzyAPI.UIHooks.show then getgenv().TroxzyAPI.UIHooks.show() end
end

local function updateSpectatorUI()
    local specNames = getSpectatorDisplayNames()
    STATE.CurrentSpectators = #specNames > 0 and table.concat(specNames, ", ") or "None"
    if #specNames > 0 then if not STATE.CounterMeasureActive then activateCounterMeasures() end else if STATE.CounterMeasureActive then deactivateCounterMeasures() end end
end

local function updateAdminDetection()
    if not CONFIG.ADMIN_DETECTOR then return end
    local adminCount = #getAdminPlayers()
    if adminCount > 0 then
        if adminCount > lastAdminCount and (os.clock() - lastAdminAlert >= 10) then
            lastAdminAlert = os.clock()
            Stats.adminDetected = Stats.adminDetected + (adminCount - lastAdminCount)
            if CONFIG.ANTI_ADMIN then blockAdminRemotes() end
            if CONFIG.AUTO_HOP_ADMIN then serverHop() else if not STATE.isGhostMode then activateGhostMode() end end
            if CONFIG.SPECTATOR_TRAP then activateSpectatorTrap() end
        end
    else
        if STATE.isGhostMode then deactivateGhostMode() end
        lastAdminCount = 0
    end
    lastAdminCount = adminCount
end

if CONFIG.ANTI_REPORT then pcall(function() Players.ReportAbuse = function() end end) end

local floodColorMap = { Blue = Color3.fromRGB(0, 150, 255), Green = Color3.fromRGB(0, 255, 100), Red = Color3.fromRGB(255, 50, 50), Pink = Color3.fromRGB(255, 100, 200), Purple = Color3.fromRGB(150, 50, 255) }
local function applyFloodColors() if not CONFIG.CUSTOM_FLOOD_COLORS then return end; local targetColor = floodColorMap[CONFIG.FLOOD_COLOR] or Color3.fromRGB(0, 150, 255); for _, v in pairs(Workspace:GetDescendants()) do if v:IsA("BasePart") and (v.Name:lower():find("water") or v.Name:lower():find("acid") or v.Name:lower():find("lava") or v.Name:lower():find("flood")) then pcall(function() v.Color = targetColor end) end end end
local lastFloodColorUpdate = 0
local function periodicFloodColorUpdate() if not CONFIG.CUSTOM_FLOOD_COLORS then return end; local now = os.clock(); if now - lastFloodColorUpdate < 0.5 then return end; lastFloodColorUpdate = now; applyFloodColors() end

local function serverHop()
    notify("⚠️ Bailing out! Admin Detected. Initiating Server Hop...", "STEALTH OPS")
    saveStats()
    local servers = {}
    local success, result = pcall(function()
        local req = request or http_request or (syn and syn.request)
        if req then
            local resp = req({Url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"})
            if resp and resp.StatusCode == 200 then return HttpService:JSONDecode(resp.Body) end
        end
    end)
    if success and result and result.data then
        for _, v in pairs(result.data) do
            if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < (v.maxPlayers - 1) and v.id ~= game.JobId then
                table.insert(servers, 1, v.id)
            end
        end
    end
    if #servers > 0 then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Player)
    else
        TeleportService:Teleport(game.PlaceId)
    end
end

local function forceReconnect() saveStats(); task.wait(1); pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end); task.wait(2); pcall(function() TeleportService:Teleport(game.PlaceId) end) end
local function attemptReconnect() saveStats(); task.wait(3); pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end) end
local function setupAutoReconnect() if not CONFIG.AUTO_RECONNECT then return end; TrackConnection(Player:GetPropertyChangedSignal("Parent"):Connect(function() if not Player.Parent then attemptReconnect() end end)); TrackConnection(TeleportService.TeleportInitFailed:Connect(attemptReconnect)) end

local function ExecuteTAS()
    if not CONFIG.TAS_AUTO_START then notify("TAS Auto-Start is OFF."); return end
    if STATE.TAS_RUNNING then 
        if TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE) end
        TAS_COROUTINE = nil; STATE.TAS_RUNNING = false; task.wait(0.2) 
    end
    getgenv().TomatoAutoFarm = false; STATE.CurrentlyFarming = false;
    local url = CONFIG.TAS_MODE == "Record" and "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TAS/CREATOR/creator.luau" or "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TAS/PLAYER/newtasplayer.luau"
    local success, scriptContent = pcall(function() return game:HttpGet(url) end)
    if not success then return end
    local func, compileErr = loadstring(scriptContent)
    if not func then return end
    TAS_COROUTINE = coroutine.create(function() STATE.TAS_RUNNING = true; pcall(func); STATE.TAS_RUNNING = false; TAS_COROUTINE = nil; if STATE.AUTO_QUEUE_ENABLED then STATE.mapCompleted = true end; if getgenv().TroxzyAPI and getgenv().TroxzyAPI.UIHooks.updateTASStatus then getgenv().TroxzyAPI.UIHooks.updateTASStatus("  Status: READY") end end)
    coroutine.resume(TAS_COROUTINE)
    if getgenv().TroxzyAPI and getgenv().TroxzyAPI.UIHooks.updateTASStatus then getgenv().TroxzyAPI.UIHooks.updateTASStatus("  Status: RUNNING") end
end
_G.ExecuteTAS = ExecuteTAS

local Multiplayer = Workspace:WaitForChild("Multiplayer")
local RemoteFolder = ReplicatedStorage:WaitForChild("Remote")
local AddedWaiting = RemoteFolder:WaitForChild("AddedWaiting")

-- NOCLIP
local ncCache = {}
local ncActive = false
local function refreshNoclip() ncCache = {}; local char = Player.Character; if char then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then table.insert(ncCache, v) end end end end
local function applyNoclip(state) if state == ncActive then return end; ncActive = state; for _, v in ipairs(ncCache) do if v and v.Parent then v.CanCollide = not state end end end
_G.applyNoclip = applyNoclip

-- ESP (Adaptive)
local espCache = {}
local lastESPUpdate = 0
local function updateESP()
    if not CONFIG.ESP then for _, hl in pairs(espCache) do pcall(function() hl:Destroy() end) end; espCache = {}; return end
    if CONFIG.ADAPTIVE_ESP then
        local anyNear = false
        local myHrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= Player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    if (myHrp.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 100 then anyNear = true; break end
                end
            end
        end
        if not anyNear then for _, hl in pairs(espCache) do pcall(function() hl:Destroy() end) end; espCache = {}; return end
    end
    if os.clock() - lastESPUpdate < 0.05 then return end; lastESPUpdate = os.clock()
    local allPlayers = Players:GetPlayers()
    for plr, hl in pairs(espCache) do if not plr.Parent or not plr.Character or hl.Parent ~= plr.Character then pcall(function() hl:Destroy() end); espCache[plr] = nil end end
    for _, plr in ipairs(allPlayers) do
        if plr ~= Player and plr.Character and not espCache[plr] then
            local hl = Instance.new("Highlight")
            hl.Name = ESP_IDENTIFIER; hl.FillTransparency = 0.3; hl.OutlineTransparency = 0.1; hl.Parent = plr.Character
            espCache[plr] = hl
        end
        if espCache[plr] then
            local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
            local otherRoot = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if root and otherRoot then
                local dist = (root.Position - otherRoot.Position).Magnitude
                if dist < 15 then espCache[plr].FillColor = Color3.fromRGB(255, 80, 80); espCache[plr].OutlineColor = Color3.fromRGB(255, 50, 50)
                elseif dist < 40 then espCache[plr].FillColor = Color3.fromRGB(255, 200, 50); espCache[plr].OutlineColor = Color3.fromRGB(255, 150, 50)
                else espCache[plr].FillColor = Color3.fromRGB(160, 180, 200); espCache[plr].OutlineColor = Color3.fromRGB(255, 255, 255) end
            end
        end
    end
end
local function clearESPCache() for _, hl in pairs(espCache) do pcall(function() hl:Destroy() end) end; espCache = {} end
_G.clearESPCache = clearESPCache

local function applyGodMode()
    if not CONFIG.GOD_MODE then return end
    local char = Player.Character
    if char and char:FindFirstChild("Humanoid") then
        local hum = char.Humanoid
        if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
    end
end

local function activatePanicMode() STATE.panicActive = true; getgenv().TomatoAutoFarm = false; STATE.CurrentlyFarming = false; applyNoclip(false); pcall(function() Player.Character.Humanoid.WalkSpeed = 16 end); if getgenv().TroxzyAPI and getgenv().TroxzyAPI.UIHooks.minimize then getgenv().TroxzyAPI.UIHooks.minimize(true) end; clearESPCache(); if _G.ToggleStates and _G.ToggleStates["PANIC_MODE"] then _G.ToggleStates["PANIC_MODE"].SetState(true) end end
local function deactivatePanicMode() STATE.panicActive = false; if getgenv().TroxzyAPI and getgenv().TroxzyAPI.UIHooks.maximize then getgenv().TroxzyAPI.UIHooks.maximize() end; if _G.ToggleStates and _G.ToggleStates["PANIC_MODE"] then _G.ToggleStates["PANIC_MODE"].SetState(false) end end

local lastVisUpdate = 0
local function updateVisuals() 
    if os.clock() - lastVisUpdate < 0.5 then return end; 
    lastVisUpdate = os.clock(); 
    Lighting.Brightness = CONFIG.FULLBRIGHT and 2 or 1; 
    Lighting.FogEnd = CONFIG.FULLBRIGHT and 99999 or 10000; 
    periodicFloodColorUpdate() 
end

local WIN_SCRIPT_URL = "https://raw.githubusercontent.com/killers-byte/Flood-GUI/refs/heads/main/win"
local WinFarmCoroutine, WinFarmRunning, WinDownloading = nil, false, false

local function SoftAntiResetGuard()
    if not STATE.CurrentlyFarming then return end
    local char = Player.Character; if not char then return end
    local hum = char:FindFirstChild("Humanoid"); if not hum then return end
    if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
    local blockedStates = { Enum.HumanoidStateType.Dead, Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Seated, Enum.HumanoidStateType.PlatformStand }
    for _, state in ipairs(blockedStates) do hum:SetStateEnabled(state, false) end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root.Position.Y < -200 then root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z); root.Velocity = Vector3.zero end
end

function StartWinEngine()
    if WinFarmRunning or WinDownloading then return end
    WinDownloading = true
    WinFarmCoroutine = nil
    local success, scriptContent = pcall(function() return game:HttpGet(WIN_SCRIPT_URL) end)
    if not success or not scriptContent then WinDownloading = false; getgenv().TomatoAutoFarm = false; STATE.CurrentlyFarming = false; return end
    local func, err = loadstring(scriptContent)
    if not func then WinDownloading = false; getgenv().TomatoAutoFarm = false; STATE.CurrentlyFarming = false; return end
    WinDownloading = false; WinFarmRunning = true; STATE.CurrentlyFarming = true; getgenv().TomatoAutoFarm = true
    WinFarmCoroutine = coroutine.create(function() local ok, result = pcall(func); if not ok then warn("[AutoFarm] Error:", result) end; WinFarmRunning = false; STATE.CurrentlyFarming = false; WinFarmCoroutine = nil end)
    coroutine.resume(WinFarmCoroutine)
end

function StopWinEngine()
    if WinFarmCoroutine then pcall(coroutine.close, WinFarmCoroutine) end
    WinFarmCoroutine = nil; WinFarmRunning = false; STATE.CurrentlyFarming = false; getgenv().TomatoAutoFarm = false
end

local function ToggleAutoFarm()
    if getgenv().TomatoAutoFarm or WinFarmRunning then StopWinEngine() else StartWinEngine() end
end

local findLiftPosition = function() for _, obj in pairs(Workspace.Lobby:GetDescendants()) do if obj:IsA("BasePart") and obj.Name:lower():find("lift") then return obj.Position + Vector3.new(0, 5, 0) end end; return Vector3.new(25, 7, 85) end
local SUPPORTED_TAS_MAPS = { "Abandoned Cemetery", "Abandoned Facility", "Abandoned Junkyard", "Active Volcanic Mines", "Antiquated Railways", "Aquatic Reservoir", "Archipelago", "Arctic Grotto", "Axiom", "Bathroom Leak", "Beep Block Station", "Beneath The Ruins", "Blue Moon", "Buried Oasis", "Cadaver Creek", "Calamity Kingdom", "Castle Tides", "Cave System", "Central Mass Array", "Chaoz Japan", "Classic Canyon", "Closing Hours", "Club Quarry", "Construction Thrill", "Crystal Caverns", "Cyberpunk District", "Dark Sci-Forest", "Decaying Silo", "Decrepit Seas", "Desolate Domain", "Despotic Ruins", "Distorted Ignis Dimension", "Dormant Vale", "Dreamscape Skylines", "Eerie Peaks", "Factory Center", "Fall Equinox", "Fallen (Classic)", "Fallen", "Familiar Ruins", "Flood Island", "Flooded Studio", "Footlight Lane", "Forgotten Tombs", "Forsaken Era", "Frostbite Coastline", "Gloomy Manor", "Golden Passage", "Graveyard Cliffside", "Grumbling Mineshafts", "Hovering Enclaves", "Icy Spires", "Ignis Peaks", "Infiltration", "Lava Tower", "Lost City of Gold", "Lost Desert", "Lost Woods", "Luminance", "Magmatic Mines", "Marigold Meadows", "Marred Dreams", "Mysterium", "Mystic Fortress", "Nimble Valley", "Northern Mill", "Oriental Grove", "Outlier of a Coppice Carcass", "Pascha Equinox", "Pitfall Temple", "Poisonous Chasm", "Poisonous Forest", "Poisonous Valley", "Relic Valley", "Retro Coast", "Rustic Jungle", "Sakura Falls", "Sandstorm Dunes", "Sandswept Ruins", "Sapphire Falls", "Satomi Springs", "Sedimentary Temple", "Shimmering Delta", "Sinking Ship", "Sky Sanctuary", "Snowscape Odyssey", "Snowy Peaks", "Snowy Stronghold", "Spider Dungeon", "Star Manor", "Starry Fields", "Submerging Coastland", "Sulphureous Sea", "Summit", "Sunken Citadel", "Sunlit Villas", "Toxic Woods", "Toybox Trouble", "Whirlwind Wasteland", "Whispering Nocturnal", "Wild Savannah", "Wildwood Waterways", "Windswept Valley", "Wintertide Haven", "Zemblanity" }
local isMapInTAS = function(mapName) for _, map in ipairs(SUPPORTED_TAS_MAPS) do if string.lower(map) == string.lower(mapName) then return true end end; return false end

-- [ AUTO UPDATER ]
local UPDATE_CONFIG = {
    ENABLED = true, 
    CURRENT_VERSION = "v24.18",
    VERSION_CHECK_URL = "https://raw.githubusercontent.com/killers-byte/Flood-GUI/refs/heads/main/version.txt",
    UPDATE_SCRIPT_URL = "https://raw.githubusercontent.com/killers-byte/Flood-GUI/refs/heads/main/TroxzyVIP.lua",
    FALLBACK_URLS = { "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TroxzyVIP.lua" }
}
local function fetchVersion(url) local success, data = pcall(function() return game:HttpGet(url) end); if success and data then return string.match(data, "%S+") end; return nil end
local function performUpdate()
    notify("🔄 Update ditemukan! Membersihkan script lama...", "Auto Updater")
    pcall(function() StopWinEngine() end); pcall(function() StopAutoQueue() end)
    if _G.TroxzyConnections then for _, conn in pairs(_G.TroxzyConnections) do pcall(function() conn:Disconnect() end) end; _G.TroxzyConnections = {} end
    pcall(function() if getgenv().TroxzyAPI and getgenv().TroxzyAPI.UIHooks and getgenv().TroxzyAPI.UIHooks.destroy then getgenv().TroxzyAPI.UIHooks.destroy() end end)
    local function purgeTroxzyGuis(container) for _, obj in ipairs(container:GetChildren()) do if obj:IsA("ScreenGui") and (string.find(obj.Name:lower(), "troxzy") or string.find(obj.Name:lower(), "tx_")) then pcall(function() obj:Destroy() end) end end end
    pcall(function() purgeTroxzyGuis(CoreGui) end); pcall(function() purgeTroxzyGuis(Player:WaitForChild("PlayerGui")) end)
    pcall(function() clearESPCache() end)
    local scriptData = nil
    local success, data = pcall(function() return game:HttpGet(UPDATE_CONFIG.UPDATE_SCRIPT_URL) end)
    if success and data and #data > 100 then scriptData = data else for _, url in ipairs(UPDATE_CONFIG.FALLBACK_URLS) do success, data = pcall(function() return game:HttpGet(url) end); if success and data and #data > 100 then scriptData = data; break end end end
    if scriptData then notify("⚡ Memasang & merestart script baru...", "Auto Updater"); task.wait(0.8); local func, err = loadstring(scriptData); if func then getgenv().TroxzyAPI = nil; func() else notify("❌ Gagal memuat compile: " .. tostring(err), "Auto Updater") end else notify("❌ Gagal mengunduh update.", "Auto Updater") end
end
local function checkForUpdates() local latestVersion = fetchVersion(UPDATE_CONFIG.VERSION_CHECK_URL); if latestVersion then if latestVersion ~= UPDATE_CONFIG.CURRENT_VERSION then notify("🆕 Update tersedia! " .. UPDATE_CONFIG.CURRENT_VERSION .. " → " .. latestVersion, "Auto Updater"); task.wait(0.5); performUpdate() else notify("✅ Versi terbaru digunakan (" .. UPDATE_CONFIG.CURRENT_VERSION .. ").", "Auto Updater") end else performUpdate() end end
if CONFIG.AUTO_UPDATE then task.spawn(function() task.wait(3); checkForUpdates() end) end

-- [ HYBRID AUTO-QUEUE ]
function StartAutoQueue()
    if AutoQueueListener then AutoQueueListener:Disconnect() end
    STATE.moveToLift = false; STATE.mapCompleted = false
    AutoQueueListener = Multiplayer.ChildAdded:Connect(function(newMap)
        if not STATE.AUTO_QUEUE_ENABLED or STATE.panicActive or STATE.isGhostMode then return end
        if STATE.HybridActive then return end
        STATE.HybridActive = true
        local s = newMap:WaitForChild("Settings", 8) 
        if not s then STATE.HybridActive = false; return end 
        local mapName = "NewMap"; local retryCount = 0
        while (mapName == "NewMap" or mapName == "Map" or mapName == "") and retryCount < 30 do
            local attrName = s:GetAttribute("MapName")
            if not attrName then local val = s:FindFirstChild("MapName"); if val and val:IsA("StringValue") then attrName = val.Value end end
            mapName = attrName or newMap.Name
            if mapName == "NewMap" or mapName == "Map" or mapName == "" then task.wait(0.2); retryCount = retryCount + 1 end
        end
        Stats.currentMap = mapName
        local timeout = os.clock() + 15 
        repeat task.wait(0.1) until Check("InGame") or not STATE.AUTO_QUEUE_ENABLED or os.clock() > timeout
        if not STATE.AUTO_QUEUE_ENABLED then STATE.HybridActive = false; return end
        STATE.mapCompleted = false
        if not Check("InGame") then
            notify("⚠️ Timeout 15s (" .. mapName .. "), gagal teleport. Fallback ke Auto Farm.", "Hybrid System")
            if STATE.TAS_RUNNING and TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE); TAS_COROUTINE = nil; STATE.TAS_RUNNING = false end
            getgenv().TomatoAutoFarm = true; STATE.CurrentlyFarming = true
            StopWinEngine(); StartWinEngine()
            STATE.HybridActive = false; return
        end
        task.wait(0.5)
        if isMapInTAS(mapName) then
            notify("🚀 TAS Support (" .. mapName .. ")! Eksekusi TAS...", "Hybrid System")
            getgenv().TomatoAutoFarm = false; STATE.CurrentlyFarming = false
            StopWinEngine(); task.spawn(ExecuteTAS)
        else
            notify("⚡ TAS Tidak Support (" .. mapName .. ")! Switch ke Auto Farm...", "Hybrid System")
            if STATE.TAS_RUNNING and TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE); TAS_COROUTINE = nil; STATE.TAS_RUNNING = false end
            getgenv().TomatoAutoFarm = true; STATE.CurrentlyFarming = true
            StopWinEngine(); StartWinEngine()
        end
        STATE.HybridActive = false
    end)
    STATE.AUTO_QUEUE_ENABLED = true
end

function StopAutoQueue() 
    if AutoQueueListener then AutoQueueListener:Disconnect(); AutoQueueListener = nil end
    STATE.moveToLift = false; STATE.AUTO_QUEUE_ENABLED = false; STATE.HybridActive = false
    if TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE) end
    TAS_COROUTINE = nil; STATE.TAS_RUNNING = false 
end

task.spawn(function() while task.wait(0.5) do if (STATE.AUTO_QUEUE_ENABLED or getgenv().TomatoAutoFarm) and not STATE.panicActive and not STATE.isGhostMode then local char = Player.Character; if char and char:FindFirstChild("HumanoidRootPart") and not Check("InGame") and not Check("InLift") and not STATE.TAS_RUNNING and not STATE.CurrentlyFarming then STATE.moveToLift = true; liftTarget = findLiftPosition() else STATE.moveToLift = false end else STATE.moveToLift = false end end end)
TrackConnection(RunService.Heartbeat:Connect(function() if STATE.moveToLift and (STATE.AUTO_QUEUE_ENABLED or getgenv().TomatoAutoFarm) and not STATE.panicActive and not STATE.TAS_RUNNING then local char = Player.Character; local hum = char and char:FindFirstChild("Humanoid"); local hrp = char and char:FindFirstChild("HumanoidRootPart"); if hum and hrp and hum.Health > 0 and not Check("InGame") and not Check("InLift") and liftTarget then if (liftTarget - hrp.Position).Magnitude > 3 then hum:MoveTo(liftTarget); hum.WalkSpeed = 25 else pcall(function() AddedWaiting:FireServer() end); STATE.moveToLift = false end end end end))
TrackConnection(Player.CharacterAdded:Connect(function() refreshNoclip(); ncActive = false; if not Check("InGame") then STATE.mapCompleted = false end end))

-- [ AUTO REBIRTH ]
local REBIRTH_CONFIG = { ENABLED = true, CHECK_INTERVAL = 3, AUTO_RESUME = true, MAX_RETRIES = 5, REBIRTH_DELAY_MIN = 2, REBIRTH_DELAY_MAX = 5, MAX_LEVEL = 100, LEADERSTAT_NAME = "Level", REMOTE_NAMES = { "rebirth", "reborn", "prestige", "ascend", "reset", "newlife", "dorebirth" }, BUTTON_NAMES = { "rebirth", "reborn", "prestige", "ascend", "reincarnate" }, LEVEL_ATTRIBUTE = "Level", REBIRTH_STAT_NAME = "Rebirth" }
local RebirthState = { isRebirthing = false, rebirthCount = 0, lastRebirthTime = 0, attemptCount = 0, foundRemote = nil, foundButton = nil }
local function findRebirthRemote()
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do 
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") or remote:IsA("BindableEvent") or remote:IsA("BindableFunction") then 
            local lowerName = remote.Name:lower(); for _, name in ipairs(REBIRTH_CONFIG.REMOTE_NAMES) do if lowerName:find(name) then return remote end end 
        end 
    end 
    return nil
end
local function findRebirthButton()
    for _, obj in pairs(Workspace:GetDescendants()) do 
        if obj:IsA("ClickDetector") or obj:IsA("ProximityPrompt") then 
            local lowerName = obj.Name:lower(); for _, name in ipairs(REBIRTH_CONFIG.BUTTON_NAMES) do if lowerName:find(name) then return obj end end 
        elseif obj:IsA("BasePart") then 
            local clickDetector = obj:FindFirstChild("ClickDetector"); if clickDetector then local lowerName = obj.Name:lower(); for _, name in ipairs(REBIRTH_CONFIG.BUTTON_NAMES) do if lowerName:find(name) then return clickDetector end end end 
        end 
    end 
    return nil
end
local function getCurrentLevel()
    local leaderstats = Player:FindFirstChild("leaderstats")
    if leaderstats then 
        local levelStat = leaderstats:FindFirstChild(REBIRTH_CONFIG.LEADERSTAT_NAME)
        if levelStat then
            if levelStat:IsA("IntValue") or levelStat:IsA("NumberValue") then return levelStat.Value 
            elseif levelStat:IsA("StringValue") then local cleanStr = string.gsub(levelStat.Value, "[,KMB]", ""); return tonumber(cleanStr) or 0 end
        end 
    end
    local char = Player.Character; if char then local levelAttr = char:GetAttribute(REBIRTH_CONFIG.LEVEL_ATTRIBUTE); if type(levelAttr) == "number" then return levelAttr end end
    local levelAttr2 = Player:GetAttribute(REBIRTH_CONFIG.LEVEL_ATTRIBUTE); if type(levelAttr2) == "number" then return levelAttr2 end; return 0
end
local function executeRebirth()
    if RebirthState.isRebirthing then return end; RebirthState.isRebirthing = true
    if not RebirthState.foundRemote then RebirthState.foundRemote = findRebirthRemote() end
    if RebirthState.foundRemote then 
        local success = pcall(function() 
            if RebirthState.foundRemote:IsA("RemoteEvent") or RebirthState.foundRemote:IsA("BindableEvent") then RebirthState.foundRemote:FireServer(); RebirthState.foundRemote:FireServer(1)
            elseif RebirthState.foundRemote:IsA("RemoteFunction") or RebirthState.foundRemote:IsA("BindableFunction") then RebirthState.foundRemote:InvokeServer(); RebirthState.foundRemote:InvokeServer(1) end 
        end)
        if success then RebirthState.rebirthCount = RebirthState.rebirthCount + 1; RebirthState.lastRebirthTime = os.clock(); notify("🔄 Rebirth Dieksekusi Secara Otomatis!", "Auto Rebirth"); task.wait(math.random(REBIRTH_CONFIG.REBIRTH_DELAY_MIN, REBIRTH_CONFIG.REBIRTH_DELAY_MAX)); RebirthState.isRebirthing = false; return true end 
    end
    if not RebirthState.foundButton then RebirthState.foundButton = findRebirthButton() end
    if RebirthState.foundButton then 
        local success = pcall(function() if RebirthState.foundButton:IsA("ClickDetector") then fireclickdetector(RebirthState.foundButton) elseif RebirthState.foundButton:IsA("ProximityPrompt") then fireproximityprompt(RebirthState.foundButton) end end)
        if success then RebirthState.rebirthCount = RebirthState.rebirthCount + 1; RebirthState.lastRebirthTime = os.clock(); notify("🔄 Rebirth via Tombol Dieksekusi!", "Auto Rebirth"); task.wait(math.random(REBIRTH_CONFIG.REBIRTH_DELAY_MIN, REBIRTH_CONFIG.REBIRTH_DELAY_MAX)); RebirthState.isRebirthing = false; return true end 
    end
    RebirthState.foundRemote = nil; RebirthState.foundButton = nil; RebirthState.attemptCount = RebirthState.attemptCount + 1
    if RebirthState.attemptCount >= REBIRTH_CONFIG.MAX_RETRIES then notify("⚠️ Gagal mencari trigger Rebirth di game ini.", "Auto Rebirth"); RebirthState.attemptCount = 0 end
    RebirthState.isRebirthing = false; return false
end
local AutoRebirthLoop = nil
function StartAutoRebirth()
    if AutoRebirthLoop then return end
    AutoRebirthLoop = true
    task.spawn(function()
        while REBIRTH_CONFIG.ENABLED and AutoRebirthLoop do
            task.wait(REBIRTH_CONFIG.CHECK_INTERVAL)
            if not REBIRTH_CONFIG.ENABLED or not AutoRebirthLoop then break end
            if not STATE.panicActive and not RebirthState.isRebirthing then
                local currentLevel = getCurrentLevel()
                if currentLevel >= REBIRTH_CONFIG.MAX_LEVEL and currentLevel > 0 then
                    notify("🌟 Target tercapai! Melakukan Auto Rebirth...", "Auto Rebirth")
                    local wasFarming = getgenv().TomatoAutoFarm; local wasTAS = STATE.TAS_RUNNING; local wasQueue = STATE.AUTO_QUEUE_ENABLED
                    if wasFarming then StopWinEngine() end
                    if wasTAS then if TAS_COROUTINE then pcall(coroutine.close, TAS_COROUTINE) end; TAS_COROUTINE = nil; STATE.TAS_RUNNING = false end
                    task.wait(0.5); local rebirthSuccess = executeRebirth()
                    if rebirthSuccess and REBIRTH_CONFIG.AUTO_RESUME then
                        task.wait(2)
                        if wasQueue then StartAutoQueue() elseif wasFarming then getgenv().TomatoAutoFarm = true; StartWinEngine() elseif wasTAS then task.spawn(ExecuteTAS) end
                    end
                end
            end
        end
    end)
end
function StopAutoRebirth() REBIRTH_CONFIG.ENABLED = false; AutoRebirthLoop = nil end

getgenv().TroxzyAPI_Rebirth = { CONFIG = REBIRTH_CONFIG, STATE = RebirthState, Start = StartAutoRebirth, Stop = StopAutoRebirth, Execute = executeRebirth, GetLevel = getCurrentLevel, FindRemote = findRebirthRemote, FindButton = findRebirthButton }

-- [ API FOR UI ]
local API = {
    CONFIG = CONFIG, STATE = STATE, Stats = Stats, KeyTime = keyExpireTime, GetRealTime = GetRealTime, 
    getAdminPlayers = getAdminPlayers, getSpectators = getSpectators,
    getAdminNames = getAdminNames, getSpectatorNames = getSpectatorNames,
    activatePanicMode = activatePanicMode, deactivatePanicMode = deactivatePanicMode, applyFloodColors = applyFloodColors,
    ExecuteTAS = ExecuteTAS, StartAutoQueue = StartAutoQueue, StopAutoQueue = StopAutoQueue,
    StartWinEngine = StartWinEngine, StopWinEngine = StopWinEngine, forceReconnect = forceReconnect,
    notify = notify, Rebirth = getgenv().TroxzyAPI_Rebirth, Updater = { CheckForUpdates = checkForUpdates, PerformUpdate = performUpdate }, UIHooks = {},
    QuickPanic = activatePanicMode,
    QuickHop = serverHop,
    ToggleAutoFarm = ToggleAutoFarm,
    getFPS = function() return FPS_COUNTER end,
    getPing = function() return Stats.ServerPing or 0 end,
    getMemory = function() return collectgarbage("count") end,
    getSessionProfit = function() return Stats.mapsCompleted * (CONFIG.PROFIT_EXP_PER_MAP or 40), Stats.mapsCompleted * (CONFIG.PROFIT_COIN_PER_MAP or 20) end,
    StartRecordingTAS = StartRecordingTAS,
    StopRecordingTAS = StopRecordingTAS,
    EXECUTOR_NAME = EXECUTOR_NAME,
    EXECUTOR_CAPS = EXECUTOR_CAPS,
}
getgenv().TroxzyAPI = API

protectAPI()

local GITHUB_RAW_UI_URL = "https://raw.githubusercontent.com/killers-byte/Flood-GUI/refs/heads/main/TroxzyUI" 
local success, uiScript = pcall(function() return game:HttpGet(GITHUB_RAW_UI_URL) end)
if success and uiScript then local runUI, err = loadstring(uiScript); if runUI then runUI() end end

-- [ FPS Monitor (Fixed) ]
local FPS_COUNTER = 60
local lastFPSTime = os.clock()
local fpsCount = 0
RunService.RenderStepped:Connect(function()
    fpsCount = fpsCount + 1
    if os.clock() - lastFPSTime >= 1 then FPS_COUNTER = fpsCount; fpsCount = 0; lastFPSTime = os.clock() end
end)

-- [ Heartbeat Loops ]
TrackConnection(RunService.Heartbeat:Connect(function()
    if os.clock() - LastFastTick < FastTick then return end; LastFastTick = os.clock()
    pcall(SoftAntiResetGuard)
    pcall(function()
        local ch = Player.Character; if not ch then return end; local hum = ch:FindFirstChild("Humanoid"); if not hum then return end
        if CONFIG.NOCLIP and not STATE.CurrentlyFarming then applyNoclip(true) elseif not STATE.CurrentlyFarming then applyNoclip(false) end
        if not STATE.CurrentlyFarming then hum.WalkSpeed = CONFIG.SPEED and CONFIG.SPEED_VAL or (STATE.moveToLift and 20 or 16) end
        if CONFIG.AIR_SWIM then hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false); if hum:GetState() == Enum.HumanoidStateType.Swimming then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end else hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true) end
        applyGodMode()
    end)
    updateSpectatorUI()
    stealthCharacterUpdate()
    applyWatermark()
    checkStuckAndCorrect()
    recordWaypoint()
end))

task.spawn(function()
    while true do
        local interval = SlowTickRate
        if #getAdminPlayers() == 0 then interval = 2 end
        task.wait(interval)
        updateAdminDetection()
        updatePlayerAnalytics()
        if CONFIG.SPECTATOR_TRAP and #getSpectators() > 0 then activateSpectatorTrap() end
        if CONFIG.MEMORY_CAMO and math.floor(os.clock()) % 10 < 1 then camouflageGUIs() end
        pcall(function() Stats.ServerPing = math.floor(NetworkClient:GetNetworkPing() * 1000) end)
        if API.UIHooks.updateDashboard then pcall(API.UIHooks.updateDashboard) end
    end
end)

TrackConnection(RunService.Heartbeat:Connect(function() pcall(updateESP); pcall(updateVisuals) end))
TrackConnection(RunService.RenderStepped:Connect(function() if CONFIG.FOV and Camera then Camera.FieldOfView = CONFIG.FOV_VAL end end))
TrackConnection(UIS.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == Enum.KeyCode.P then if not STATE.panicActive then activatePanicMode() else deactivatePanicMode() end end end))
TrackConnection(UIS.JumpRequest:Connect(function()
    if CONFIG.INF_JUMP and Player.Character then
        local h = Player.Character:FindFirstChild("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping); h.Jump = true end
    end
end))

-- [ Anti-Spy Loop ]
local function antiSpyLoop()
    if not CONFIG.ANTI_SPY then return end
    for _, v in pairs(CoreGui:GetChildren()) do
        local name = v.Name:lower()
        if name:find("dex") or name:find("spy") or name:find("turtle") or name:find("explorer") then
            Player:Kick("💀 BADAN INTELIJEN NEGARA: UNAUTHORIZED SPYWARE DETECTED.")
            return
        end
    end
end

local function stealthCharacterUpdate()
    local char = Player.Character; if not char then return end
    if CONFIG.SPOOF_NAME then
        local hum = char:FindFirstChild("Humanoid")
        if hum and hum.DisplayName ~= "Troxzy_Ghost" then hum.DisplayName = "Troxzy_Ghost" end
    end
    if CONFIG.CLEAN_CHAR then
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Accessory") or v:IsA("Shirt") or v:IsA("Pants") or v:IsA("ShirtGraphic") or v:IsA("CharacterMesh") then
                pcall(function() v:Destroy() end)
            end
        end
    end
end

loadStats(); setupAutoReconnect()
if REBIRTH_CONFIG.ENABLED then StartAutoRebirth() end

notify("TROXZY VIP - DASHBOARD INTEGRATED & ADMIN STRICT", "System")
