-- ==============================================================================
-- [FLOOD ESCAPE 2: TAS MANAGER + EXACT WIN.TXT FARM (ANCHOR FIXED)]
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
    MODE = "Farm",               
    TARGET_DIFFICULTY = "None",  
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

local function Alert(msg)
    print("[TOMATO]: " .. tostring(msg))
    pcall(function()
        local CLMAINenv = getsenv(LocalPlayer.PlayerScripts:WaitForChild("CL_MAIN_GameScript"))
        CLMAINenv.newAlert(tostring(msg), nil, nil, "rainbow")
    end)
end

-- [EXACT HELPERS FROM WIN.TXT]
function isRandomString(str)
    if #str == 0 then return false end
    for i = 1, #str do
        local ltr = str:sub(i, i)
        if ltr:lower() == ltr then
            return false
        end
    end
    return true
end

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
    local HumanoidRootPart = char:FindFirstChild("HumanoidRootPart")
    if not HumanoidRootPart then return false end

    if Flag == "InLift" then
        if HumanoidRootPart.Position.X < 50 and HumanoidRootPart.Position.Z > 70 then
            return true
        end
    elseif Flag == "InGame" then
        if HumanoidRootPart.Position.X > 50 then
            return true
        end
    end
    return false
end

-- [TAS MANAGER HELPERS]
local function CleanMapName(name)
    if not name then return "" end
    local clean = name:gsub("\160", " "):gsub("^%s*(.-)%s*$", "%1")
    return clean
end

local function UrlEncode(str)
    if not str then return "" end
    str = str:gsub("([^%w %-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return str:gsub(" ", "%%20")
end

local function CheckGithubForFile(rawName)
    local mapName = CleanMapName(rawName)
    if getgenv().TasFileCache[mapName] ~= nil then return getgenv().TasFileCache[mapName] end
    
    local encoded = UrlEncode(mapName)
    local url = CONFIG.GITHUB_BASE .. encoded .. ".json"
    local success, response = pcall(function() return game:HttpGet(url) end)
    local exists = (success and #response > 200 and not response:find("404: Not Found"))
    
    getgenv().TasFileCache[mapName] = exists
    return exists
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
            
            if not hasFile then
                missingTarget = map
                break 
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
-- [LOGIC 2: EXACT AUTO FARM FROM WIN.TXT]
-- ==============================================================================

local function StartAutoFarm(Map)
    -- PHASE 1: Wait for Teleport (Position Check)
    Alert("Waiting for Teleport...")
    local t = 0
    repeat 
        task.wait(0.2)
        t = t + 0.2
        if t > 60 then return end -- Timeout
    until Check("InGame") and getgenv().TomatoAutoFarm

    if not getgenv().TomatoAutoFarm then return end

    -- PHASE 2: Wait for Round Start (Anchor Check)
    Alert("Waiting for Unanchor...")
    local char = GetChar()
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    repeat 
        task.wait(0.1)
    until (hrp and hrp.Anchored == false) or not getgenv().TomatoAutoFarm

    if not getgenv().TomatoAutoFarm then return end
    Alert("Round Started! Farming...")

    -- === BELOW IS THE EXACT LOGIC FROM WIN.TXT ===
    
    local CurrentlyFarming = true
    local EXITREGION_MAX_ATTEMPTS = 1300
    
    if Check("InGame") == false then
        Alert("Skipping due to InGame == false.")
    end

    local Buttons = {}
    -- Single Scan of Map to reduce lag.
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
                -- Confirmed Buttonness
                Hitbox.Name = "Hitbox"
                table.insert(Buttons, MapObject)
            end
        end
    end

    local HumanoidRootPart = GetChar():WaitForChild("HumanoidRootPart")
    -- Grab Lost Page and Escapee
    local LostPage = Map:FindFirstChild("_LostPage", true)
    local Rescue = Map:FindFirstChild("_Rescue", true)
    local OriginalCFrame = HumanoidRootPart.CFrame
    
    if LostPage then
        HumanoidRootPart.CFrame = LostPage.CFrame
        task.wait(LocalPlayer:GetNetworkPing())
        HumanoidRootPart.CFrame = OriginalCFrame
        Alert("Got Lost Page.")
    end
    if Rescue then
        HumanoidRootPart.CFrame = Rescue.Contact.CFrame
        task.wait(LocalPlayer:GetNetworkPing())
        HumanoidRootPart.CFrame = OriginalCFrame
        print("Got Escapee.")
    end

    -- Auto Farm Loop
    Alert("Commencing Auto Farm")
    local CurrentButton = nil
    local Humanoid = GetChar():WaitForChild("Humanoid")
    
    local GodMode = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        Humanoid.Health = 1000
    end)
    TrackConnection(GodMode)
    
    local Attempts = 0 
    local DifferentScan = false
    
    Noclip(true)
    
    while task.wait() and Check("InGame") and getgenv().TomatoAutoFarm do
        if not CurrentlyFarming then break end

        local ExitRegion = Map:FindFirstChild("ExitRegion", true)
        local HRP = GetChar():FindFirstChild("HumanoidRootPart")
        if not HRP then break end
        
        Humanoid.Jump = true
        local FailedScan = true
        
        if not ExitRegion then
            HRP.Anchored = true
            for i, Button in pairs(Buttons) do
                -- Stop immediately if paused
                if not getgenv().TomatoAutoFarm then break end 

                local ButtonHitbox = Button:FindFirstChild("Hitbox")
                if ButtonHitbox then
                    CurrentButton = Button
                    local TouchFound = Button:FindFirstChild("TouchInterest", true)
                    local GuiFound = Button:FindFirstChildWhichIsA("BillboardGui", true)
                    
                    if (TouchFound and GuiFound) then
                        FailedScan = false
                        HRP.Anchored = false
                        HRP.Velocity = Vector3.zero
                        HRP.CFrame = CFrame.new(ButtonHitbox.Position) * CFrame.Angles(0, math.random() * (math.pi * 2), 0)
                        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        task.wait(0.255/15)
                    end
                end
            end
            if FailedScan == true then
                DifferentScan = true
                task.wait()
            end
        elseif ExitRegion then
            HRP.Anchored = false
            if Attempts < EXITREGION_MAX_ATTEMPTS then
                Attempts = Attempts + 1
                HRP.CFrame = CFrame.new(ExitRegion.Position)
                HRP.Velocity = Vector3.new(0, 100, 0)
                task.wait()
                if (HRP.Position - ExitRegion.Position).Magnitude <= 5 then
                    Attempts = Attempts + 1
                end
            else
                Alert("Teleported to ExitRegion.")
                break
            end
        end
    end
    
    Noclip(false)
    Alert("Complete.")
    if GodMode then GodMode:Disconnect() end
    CurrentlyFarming = false
end

-- ==============================================================================
-- [LOGIC 3: MAP LOADING HANDLER]
-- ==============================================================================

TrackConnection(Multiplayer.ChildAdded:Connect(function(NewMap)
    if _G.LoopCancel or not getgenv().TomatoAutoFarm then return end

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
