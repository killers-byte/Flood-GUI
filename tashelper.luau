-- ==============================================================================
-- [SINGLE INSTANCE / OVERRIDE LOGIC]
-- ==============================================================================
if getgenv().TomatoConnections then
    for i, connection in pairs(getgenv().TomatoConnections) do
        if connection then pcall(function() connection:Disconnect() end) end
    end
    _G.LoopCancel = true
    getgenv().TomatoAutoFarm = false
    task.wait(0.2)
end

getgenv().TomatoConnections = {}
getgenv().IsResettingForDifficulty = false 

local function TrackConnection(connection)
    table.insert(getgenv().TomatoConnections, connection)
    return connection
end

-- ==============================================================================
-- [CONFIGURATION]
-- ==============================================================================
local DEFAULT_MODE = "Farm"            -- "Farm" or "Play"
local TARGET_DIFFICULTY_NAME = "None"  -- Default set to "None" (ignore difficulty)
local LOG_FILE_NAME = "TomatoTAS_MapLog.json"

getgenv().TomatoAutoFarm = true

-- ==============================================================================
-- [LOGGING & FILE SYSTEM]
-- ==============================================================================
local HttpService = game:GetService("HttpService")
local MapLog = {}

local function LoadLog()
    if isfile(LOG_FILE_NAME) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(LOG_FILE_NAME)) end)
        if success then MapLog = data end
    end
end

local function SaveLog()
    writefile(LOG_FILE_NAME, HttpService:JSONEncode(MapLog))
end

local function UpdateMapStatus(mapName, difficulty, hasFile)
    MapLog[mapName] = {
        Difficulty = difficulty,
        HasFile = hasFile,
        LastSeen = os.date("%Y-%m-%d %H:%M:%S")
    }
    SaveLog()
end

-- ==============================================================================
-- [UTILS]
-- ==============================================================================
local DIFFICULTY_RANKS = {
    ["None"] = 999, ["Easy"] = 1, ["Normal"] = 2, ["Hard"] = 3, ["Insane"] = 4, ["Crazy"] = 5, ["Crazy+"] = 6
}

local function UrlEncode(str)
    if not str then return "" end
    str = str:gsub("([^%w %-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return str:gsub(" ", "%%20")
end

local function CheckGithubForFile(mapName)
    local encoded = UrlEncode(mapName)
    local url = "https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/main/TAS%20FILES/" .. encoded .. ".json"
    local success, response = pcall(function() return game:HttpGet(url) end)
    local exists = (success and #response > 50)
    return exists
end

local function Alert(msg)
    print("[TOMATO]: " .. tostring(msg))
    pcall(function()
        local CLMAINenv = getsenv(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CL_MAIN_GameScript"))
        CLMAINenv.newAlert(tostring(msg), nil, nil, "rainbow")
    end)
end

-- ==============================================================================
-- [VOTING & INSTANT EXECUTION]
-- ==============================================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFolder = ReplicatedStorage:WaitForChild("Remote")
local ReqPasskey = RemoteFolder:WaitForChild("ReqPasskey")
local NewMapVote = RemoteFolder:WaitForChild("NewMapVote")
local UpdMapVote = RemoteFolder:WaitForChild("UpdMapVote")

local function ExecuteTAS(mode)
    _G.LoopCancel = true 
    getgenv().TomatoAutoFarm = false 
    if mode == "Creator" then
        Alert("LOADING TAS CREATOR...")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/main/TAS/CREATOR/creator.luau"))()
    elseif mode == "Player" then
        Alert("LOADING TAS PLAYER...")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/main/TAS/PLAYER/newtasplayer.luau"))()
    end
end

TrackConnection(NewMapVote.OnClientEvent:Connect(function(dataPacket)
    local maps = dataPacket.mapData
    if not maps then return end

    local missingTarget = nil
    local playableTarget = nil
    local targetRank = DIFFICULTY_RANKS[TARGET_DIFFICULTY_NAME] or 999

    for _, map in pairs(maps) do
        if map.displayMap == true then
            -- Check/Update Log and GitHub
            local hasFile = CheckGithubForFile(map.name)
            UpdateMapStatus(map.name, map.difficulty, hasFile)

            local mapRank = DIFFICULTY_RANKS[map.difficulty] or 0
            
            if not hasFile then
                missingTarget = map
                break
            elseif DEFAULT_MODE == "Play" and mapRank <= targetRank then
                -- Target hardest available map that is within our difficulty range
                if not playableTarget or mapRank > (DIFFICULTY_RANKS[playableTarget.difficulty] or 0) then
                    playableTarget = map
                end
            end
        end
    end

    local key = ReqPasskey:InvokeServer()
    if not key then return end

    if missingTarget then
        Alert("VOTE: NEW MAP -> " .. missingTarget.name)
        UpdMapVote:FireServer(-key, missingTarget.ID, missingTarget.unlockCost or 0)
        ExecuteTAS("Creator") 
    elseif playableTarget then
        Alert("VOTE: TAS PLAY -> " .. playableTarget.name)
        UpdMapVote:FireServer(-key, playableTarget.ID, playableTarget.unlockCost or 0)
        ExecuteTAS("Player")
    end
end))

-- ==============================================================================
-- [MAP HANDLER / AUTO-FARM]
-- ==============================================================================
local Workspace = game:GetService("Workspace")
local Multiplayer = Workspace:WaitForChild("Multiplayer")
local LocalPlayer = game:GetService("Players").LocalPlayer

local function GetChar() return LocalPlayer.Character or (LocalPlayer.CharacterAdded:wait() and LocalPlayer.Character) end

TrackConnection(Multiplayer.ChildAdded:Connect(function(NewMap)
    NewMap:GetPropertyChangedSignal("Name"):Wait()
    if not getgenv().TomatoAutoFarm or _G.LoopCancel then return end
    
    local diffText = Workspace.Lobby.GameInfo.SurfaceGui.Frame.Difficulty.Difficulty.Text
    local currentName = string.gsub(string.split(diffText, ":")[1], "^%s*(.-)%s*$", "%1")
    local currentRank = DIFFICULTY_RANKS[currentName] or 0
    local targetRank = DIFFICULTY_RANKS[TARGET_DIFFICULTY_NAME] or 999

    -- Map Guard: If a map starts and it's missing a file, record it
    local hasFile = CheckGithubForFile(NewMap.Name)
    if not hasFile then
        ExecuteTAS("Creator")
        return
    end

    -- Difficulty Skip: Reset if file exists but difficulty is too high
    if TARGET_DIFFICULTY_NAME ~= "None" and currentRank > targetRank then
        Alert("Difficulty Skip: " .. currentName)
        getgenv().IsResettingForDifficulty = true
        local Hum = GetChar():FindFirstChild("Humanoid")
        if Hum then Hum.Health = 0 end
        return
    end

    Alert("Farming: " .. NewMap.Name)
end))

-- ==============================================================================
-- [SYSTEM LOOPS]
-- ==============================================================================

-- Rejoin & Anti-AFK
task.spawn(function()
    while task.wait(2) do
        if _G.LoopCancel then break end
        local hrp = GetChar():FindFirstChild("HumanoidRootPart")
        if hrp and hrp.Position.X < 50 and hrp.Position.Z < 70 and getgenv().TomatoAutoFarm then
            RemoteFolder.AddedWaiting:FireServer()
        end
    end
end)

TrackConnection(LocalPlayer.Idled:Connect(function()
    game:GetService("VirtualUser"):CaptureController()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new())
end))

TrackConnection(LocalPlayer.CharacterAdded:Connect(function()
    if getgenv().IsResettingForDifficulty then
        task.wait(1)
        RemoteFolder.AddedWaiting:FireServer()
        getgenv().IsResettingForDifficulty = false
    end
end))

-- Startup
LoadLog()
local InitMsg = string.format("Manager Ready! | Mode: %s | Target: %s | Log: %s", 
    DEFAULT_MODE, TARGET_DIFFICULTY_NAME, LOG_FILE_NAME)
Alert(InitMsg)
