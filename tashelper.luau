-- ==============================================================================
-- [FLOOD ESCAPE 2: TAS MANAGER + AUTO FARM (MERGED VERSION)]
-- ==============================================================================

-- [1] INSTANCE CLEARING & SETUP
if getgenv().TomatoConnections then
    print("!!! OVERRIDING PREVIOUS INSTANCE !!!")
    for _, connection in pairs(getgenv().TomatoConnections) do
        if connection then pcall(function() connection:Disconnect() end) end
    end
    _G.LoopCancel = true
    getgenv().TomatoAutoFarm = false
    task.wait(0.2)
end

getgenv().TomatoConnections = {}
getgenv().IsResettingForDifficulty = false 
getgenv().TasFileCache = {} 
getgenv().TomatoAutoFarm = true
_G.LoopCancel = false

local function TrackConnection(connection)
    table.insert(getgenv().TomatoConnections, connection)
    return connection
end

-- ==============================================================================
-- [CONFIGURATION]
-- ==============================================================================

local CONFIG = {
    MODE = "Farm",               -- "Farm" = Auto Farm default, "Play" = Play TAS if available
    TARGET_DIFFICULTY = "None",  -- "None", "Easy", "Normal", "Hard", "Insane", "Crazy", "Crazy+"
    LOG_FILE = "TomatoTAS_MapLog.json",
    GITHUB_BASE = "https://raw.githubusercontent.com/tomatotxt/Flood-GUI/main/TAS%20FILES/",
    TAS_CREATOR_URL = "https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/main/TAS/CREATOR/creator.luau",
    TAS_PLAYER_URL = "https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/main/TAS/PLAYER/newtasplayer.luau"
}

-- ==============================================================================
-- [SERVICES & UTILS]
-- ==============================================================================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

local Multiplayer = Workspace:WaitForChild("Multiplayer")
local RemoteFolder = ReplicatedStorage:WaitForChild("Remote")
local ReqPasskey = RemoteFolder:WaitForChild("ReqPasskey")
local NewMapVote = RemoteFolder:WaitForChild("NewMapVote")
local UpdMapVote = RemoteFolder:WaitForChild("UpdMapVote")
local AddedWaiting = RemoteFolder:WaitForChild("AddedWaiting")

local DIFFICULTY_RANKS = {
    ["None"] = 999, ["Easy"] = 1, ["Normal"] = 2, ["Hard"] = 3, ["Insane"] = 4, ["Crazy"] = 5, ["Crazy+"] = 6
}

-- [Alert System]
local function Alert(msg)
    print("[TOMATO]: " .. tostring(msg))
    pcall(function()
        local CLMAINenv = getsenv(LocalPlayer.PlayerScripts:WaitForChild("CL_MAIN_GameScript"))
        CLMAINenv.newAlert(tostring(msg), nil, nil, "rainbow")
    end)
end

-- [Helper: Random String Detection from win.txt]
local function isRandomString(str)
    if #str == 0 then return false end
    for i = 1, #str do
        local ltr = str:sub(i, i)
        if ltr:lower() == ltr then return false end
    end
    return true
end

-- [Helper: Clean Map Name]
local function CleanMapName(name)
    if not name then return "" end
    -- Remove non-breaking spaces (\160) and standard spaces from ends
    local clean = name:gsub("\160", " "):gsub("^%s*(.-)%s*$", "%1")
    return clean
end

local function UrlEncode(str)
    if not str then return "" end
    str = str:gsub("([^%w %-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return str:gsub(" ", "%%20")
end

-- [Helper: GitHub Checker]
local function CheckGithubForFile(rawName)
    local mapName = CleanMapName(rawName)
    
    if getgenv().TasFileCache[mapName] ~= nil then
        return getgenv().TasFileCache[mapName]
    end

    local encoded = UrlEncode(mapName)
    local url = CONFIG.GITHUB_BASE .. encoded .. ".json"
    
    local success, response = pcall(function() return game:HttpGet(url) end)
    
    local exists = false
    if success and #response > 200 and not response:find("404: Not Found") then
        exists = true
    end

    getgenv().TasFileCache[mapName] = exists
    return exists
end

-- [Helper: Character & Noclip]
local function GetChar()
    return LocalPlayer.Character or (LocalPlayer.CharacterAdded:wait() and LocalPlayer.Character)
end

local function Noclip(Toggle)
    local char = GetChar()
    if char then
        for i, v in pairs(char:GetChildren()) do
            if v.ClassName == "Part" then v.CanCollide = not Toggle end
        end
    end
end

local function Check(Flag)
    local char = GetChar()
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    if Flag == "InLift" then
        if hrp.Position.X < 50 and hrp.Position.Z > 70 then return true end
    elseif Flag == "InGame" then
        if hrp.Position.X > 50 then return true end
    end
    return false
end

-- ==============================================================================
-- [LOGIC 1: VOTING SYSTEM]
-- ==============================================================================

local function ExecuteTAS(scriptType)
    _G.LoopCancel = true
    getgenv().TomatoAutoFarm = false
    
    if scriptType == "Creator" then
        Alert("!!! NEW MAP - STARTING CREATOR !!!")
        loadstring(game:HttpGet(CONFIG.TAS_CREATOR_URL))()
    elseif scriptType == "Player" then
        Alert("!!! EXISTING MAP - STARTING PLAYER !!!")
        loadstring(game:HttpGet(CONFIG.TAS_PLAYER_URL))()
    end
end

TrackConnection(NewMapVote.OnClientEvent:Connect(function(dataPacket)
    local maps = dataPacket.mapData
    if not maps then return end

    local missingTarget = nil
    local playableTarget = nil
    local maxRank = DIFFICULTY_RANKS[CONFIG.TARGET_DIFFICULTY] or 999

    for _, map in pairs(maps) do
        if map.displayMap == true then
            local cleanName = CleanMapName(map.name)
            local hasFile = CheckGithubForFile(cleanName)
            local mapRank = DIFFICULTY_RANKS[map.difficulty] or 0
            
            -- Priority 1: Record Missing Maps
            if not hasFile then
                missingTarget = map
                break 
            -- Priority 2: Play Existing Maps (If Mode is Play)
            elseif CONFIG.MODE == "Play" and hasFile and mapRank <= maxRank then
                if not playableTarget or mapRank > (DIFFICULTY_RANKS[playableTarget.difficulty] or 0) then
                    playableTarget = map
                end
            end
        end
    end

    local key = ReqPasskey:InvokeServer()
    if not key then return end

    if missingTarget then
        Alert("VOTE: NEW -> " .. missingTarget.name)
        UpdMapVote:FireServer(-key, missingTarget.ID, missingTarget.unlockCost or 0)
        ExecuteTAS("Creator")
    elseif playableTarget then
        Alert("VOTE: PLAY -> " .. playableTarget.name)
        UpdMapVote:FireServer(-key, playableTarget.ID, playableTarget.unlockCost or 0)
        ExecuteTAS("Player")
    else
        print("No targets. Continuing Auto-Farm.")
    end
end))

-- ==============================================================================
-- [LOGIC 2: AUTO FARM (FROM WIN.TXT)]
-- ==============================================================================

local function StartAutoFarm(Map)
    local char = GetChar()
    local HRP = char:WaitForChild("HumanoidRootPart")
    local Humanoid = char:WaitForChild("Humanoid")

    -- 1. Identify Buttons (Using strict win.txt logic)
    local Buttons = {}
    for i, MapObject in pairs(Map:GetDescendants()) do
        if isRandomString(MapObject.Name) and MapObject.ClassName == "Model" then
            local Hitbox
            for i, Candidate in pairs(MapObject:GetChildren()) do
                if Candidate:IsA("BasePart") and tostring(Candidate.BrickColor) ~= "Medium stone grey" then
                    Hitbox = Candidate
                    break
                end
            end
            if Hitbox and isRandomString(Hitbox.Name) then
                Hitbox.Name = "Hitbox"
                table.insert(Buttons, MapObject)
            end
        end
    end

    -- 2. Collectables
    local LostPage = Map:FindFirstChild("_LostPage", true)
    local Rescue = Map:FindFirstChild("_Rescue", true)
    local OriginalCFrame = HRP.CFrame
    
    if LostPage then
        HRP.CFrame = LostPage.CFrame
        task.wait(LocalPlayer:GetNetworkPing())
        HRP.CFrame = OriginalCFrame
        Alert("Got Lost Page")
    end
    if Rescue then
        HRP.CFrame = Rescue.Contact.CFrame
        task.wait(LocalPlayer:GetNetworkPing())
        HRP.CFrame = OriginalCFrame
        print("Got Escapee")
    end

    -- 3. Farm Loop
    local GodMode = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        Humanoid.Health = 1000
    end)
    TrackConnection(GodMode)
    
    local Attempts = 0
    Noclip(true)
    
    while task.wait() and Check("InGame") and getgenv().TomatoAutoFarm and not _G.LoopCancel do
        local ExitRegion = Map:FindFirstChild("ExitRegion", true)
        
        Humanoid.Jump = true
        local FailedScan = true
        
        if not ExitRegion then
            HRP.Anchored = true
            for i, Button in pairs(Buttons) do
                if not getgenv().TomatoAutoFarm then break end
                
                local ButtonHitbox = Button:FindFirstChild("Hitbox")
                if ButtonHitbox then
                    local TouchFound = Button:FindFirstChild("TouchInterest", true)
                    local GuiFound = Button:FindFirstChildWhichIsA("BillboardGui", true)
                    
                    if (TouchFound and GuiFound) then
                        FailedScan = false
                        HRP.Anchored = false
                        HRP.Velocity = Vector3.zero
                        -- Exact CFrame logic from win.txt
                        HRP.CFrame = CFrame.new(ButtonHitbox.Position) * CFrame.Angles(0, math.random() * (math.pi * 2), 0)
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        task.wait(0.255/15)
                    end
                end
            end
            if FailedScan == true then task.wait() end
        elseif ExitRegion then
            HRP.Anchored = false
            if Attempts < 1300 then
                Attempts = Attempts + 1
                HRP.CFrame = CFrame.new(ExitRegion.Position)
                HRP.Velocity = Vector3.new(0, 100, 0)
                task.wait()
            else
                break
            end
        end
    end
    
    Noclip(false)
    if GodMode then GodMode:Disconnect() end
end

-- ==============================================================================
-- [LOGIC 3: MAP LOADING HANDLER]
-- ==============================================================================

TrackConnection(Multiplayer.ChildAdded:Connect(function(NewMap)
    if _G.LoopCancel or not getgenv().TomatoAutoFarm then return end

    -- Wait for Attributes to load properly
    local Settings = NewMap:WaitForChild("Settings", 10)
    local MapName = "Unknown"
    
    if Settings then
        MapName = Settings:GetAttribute("MapName") or NewMap.Name
    else
        MapName = NewMap.Name
    end

    -- 1. Check if Missing File
    local hasFile = CheckGithubForFile(MapName)
    if not hasFile then
        Alert("MISSING FILE: " .. MapName)
        ExecuteTAS("Creator")
        return
    end

    -- 2. Difficulty Check
    local diffText = Workspace.Lobby.GameInfo.SurfaceGui.Frame.Difficulty.Difficulty.Text
    local currentRankName = diffText:split(":")[1]:gsub("^%s*(.-)%s*$", "%1")
    local currentRank = DIFFICULTY_RANKS[currentRankName] or 0
    local targetRank = DIFFICULTY_RANKS[CONFIG.TARGET_DIFFICULTY] or 999

    if CONFIG.TARGET_DIFFICULTY ~= "None" and currentRank > targetRank then
        Alert("Skipping " .. currentRankName .. " (Too Hard)")
        getgenv().IsResettingForDifficulty = true
        LocalPlayer.Character.Humanoid.Health = 0
        return
    end

    -- 3. Start Farming
    Alert("Auto-Farming: " .. MapName)
    StartAutoFarm(NewMap)
end))

-- ==============================================================================
-- [LOGIC 4: WATCHDOGS]
-- ==============================================================================

task.spawn(function()
    while task.wait(2) do
        if _G.LoopCancel then break end
        if getgenv().TomatoAutoFarm then
            local inLift = Check("InLift")
            local inGame = Check("InGame")
            if not inLift and not inGame then
                AddedWaiting:FireServer()
            end
        end
    end
end)

TrackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    if getgenv().IsResettingForDifficulty then
        char:WaitForChild("HumanoidRootPart", 10)
        task.wait(0.5)
        AddedWaiting:FireServer()
        getgenv().IsResettingForDifficulty = false
    end
end))

TrackConnection(LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end))

Alert(string.format("Manager Active | Mode: %s | Target: %s", CONFIG.MODE, CONFIG.TARGET_DIFFICULTY))
