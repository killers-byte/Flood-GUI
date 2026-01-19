-- ==============================================================================
-- [SINGLE INSTANCE / OVERRIDE LOGIC]
-- ==============================================================================
if getgenv().TomatoConnections then
    print("!!! OVERRIDING PREVIOUS SCRIPT INSTANCE !!!")
    for i, connection in pairs(getgenv().TomatoConnections) do
        if connection then
            pcall(function() connection:Disconnect() end)
        end
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
-- [CONFIGURATION] EDIT THIS SECTION
-- ==============================================================================

local MODE = "Record" 
local TARGET_MAP_NAME = "Central Mass Array" -- Exact Case-Sensitive Name
local TARGET_DIFFICULTY_NAME = "Crazy+" 

getgenv().TomatoAutoFarm = true

-- ==============================================================================
-- [LOGIC] MODE HANDLER
-- ==============================================================================

local function ExecuteSecondaryScript()
    if MODE == "Record" then
        print("!!! TARGET MAP FOUND - MODE: RECORD - EXECUTING CREATOR SCRIPT !!!")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/main/TAS/CREATOR/creator.luau"))()
    elseif MODE == "Play" then
        print("!!! TARGET MAP FOUND - MODE: PLAY - EXECUTING PLAYER SCRIPT !!!")
        loadstring(game:HttpGet("https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/main/TAS/PLAYER/newtasplayer.luau"))()
    else
        warn("INVALID MODE SELECTED! Please set MODE to 'Record' or 'Play'.")
    end
end

-- ==============================================================================
-- [INTERNAL] SETUP & UTILS
-- ==============================================================================

local ALERTS_ENABLED = true
local EXITREGION_MAX_ATTEMPTS = 1300
local CurrentlyFarming = false

local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = game:GetService("Players").LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Multiplayer = Workspace:WaitForChild("Multiplayer")

local DIFFICULTY_RANKS = {
    ["Easy"] = 1,
    ["Normal"] = 2,
    ["Hard"] = 3,
    ["Insane"] = 4,
    ["Crazy"] = 5,
    ["Crazy+"] = 6
}

-- Remotes
local RemoteFolder = ReplicatedStorage:WaitForChild("Remote")
local ReqPasskey = RemoteFolder:WaitForChild("ReqPasskey")
local NewMapVote = RemoteFolder:WaitForChild("NewMapVote")
local UpdMapVote = RemoteFolder:WaitForChild("UpdMapVote")
local AddedWaiting = RemoteFolder:WaitForChild("AddedWaiting")

-- Anti-AFK
TrackConnection(LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end))

-- Respawn & Rejoin Lift Handler (On Respawn)
TrackConnection(LocalPlayer.CharacterAdded:Connect(function(char)
    if getgenv().IsResettingForDifficulty then
        char:WaitForChild("HumanoidRootPart", 10)
        task.wait(0.5) 
        print("Respawned. Attempting to rejoin Lift...")
        AddedWaiting:FireServer()
        getgenv().IsResettingForDifficulty = false
    end
end))

-- Alert System
local CLMAIN = LocalPlayer.PlayerScripts:WaitForChild("CL_MAIN_GameScript")
local CLMAINenv = getsenv(CLMAIN)
local gameAlert = CLMAINenv.newAlert
local Alert

if CLMAINenv and gameAlert then
    Alert = function(...)
        if ALERTS_ENABLED then
            local Output = tostring(...)
            gameAlert(Output, nil, nil, "rainbow")
            print(Output)
        end
    end
else
    Alert = print
end

function isRandomString(str)
    if #str == 0 then return false end
    for i = 1, #str do
        local ltr = str:sub(i, i)
        if ltr:lower() == ltr then return false end
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
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    if Flag == "InLift" then
        if hrp.Position.X < 50 and hrp.Position.Z > 70 then return true end
    elseif Flag == "InGame" then
        if hrp.Position.X > 50 then return true end
    end
    return false
end

local function GetCurrentDifficultyRank()
    local success, result = pcall(function()
        local diffLabel = Workspace.Lobby.GameInfo.SurfaceGui.Frame.Difficulty.Difficulty
        local text = diffLabel.Text
        local splitText = string.split(text, ":")
        local word = splitText[1]
        word = string.gsub(word, "^%s*(.-)%s*$", "%1")
        return word
    end)

    if success and result then
        local rank = DIFFICULTY_RANKS[result]
        if rank then
            return rank, result
        else
            return 0, result
        end
    end
    return 0, "Unknown"
end

-- ==============================================================================
-- [MAIN LOGIC] MAP LOAD & FARM
-- ==============================================================================

local MapDetect
local ConnectMap

local function OnMapLoad(Map)
    CurrentlyFarming = true
    
    local HumanoidRootPart = GetChar():WaitForChild("HumanoidRootPart")
    local Humanoid = GetChar():WaitForChild("Humanoid")

    -- 1. DIFFICULTY CHECK LOGIC
    local currentRank, currentName = GetCurrentDifficultyRank()
    local targetRank = DIFFICULTY_RANKS[TARGET_DIFFICULTY_NAME] or 999
    
    print("-------------------------------------------------")
    print("DIFFICULTY CHECK:")
    print("Current: " .. currentName .. " ("..currentRank..")")
    print("Target:  " .. TARGET_DIFFICULTY_NAME .. " ("..targetRank..")")

    if currentRank > targetRank then
        Alert("Difficulty Too High ("..currentName.."). Resetting...")
        getgenv().IsResettingForDifficulty = true 
        Humanoid.Health = 0
        CurrentlyFarming = false
        return 
    elseif currentRank < targetRank then
        Alert("Difficulty Low ("..currentName.."). Farming to raise it.")
    else
        Alert("Difficulty Correct ("..currentName.."). Farming to cycle vote.")
    end
    print("-------------------------------------------------")

    -- 2. FARMING SETUP
    local Settings = Map:WaitForChild("Settings", 10)
    if Settings then
        local MapName = Settings:GetAttribute("MapName")
        if MapName then Alert("Map Loaded! " .. MapName) end
    end

    if Check("InGame") == false then
        Alert("Skipping due to InGame == false.")
    end

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

    Alert("Commencing Auto Farm")
    local CurrentButton = nil
    
    local GodMode = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        Humanoid.Health = 1000
    end)
    TrackConnection(GodMode)
    
    local Attempts = 0
    local DifferentScan = false
    
    Noclip(true)
    
    -- 3. FARM LOOP
    -- [UPDATE] Added check for getgenv().TomatoAutoFarm
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
                -- [UPDATE] Stop inner loop immediately if paused
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
    
    Alert("Waiting for next Map...")
    CurrentlyFarming = false
end

ConnectMap = function()
    MapDetect = Multiplayer.ChildAdded:Connect(function(NewMap)
        NewMap:GetPropertyChangedSignal("Name"):Wait()
        
        if getgenv().TomatoAutoFarm == true then
            OnMapLoad(NewMap)
            Alert("Connecting..")
        end
    end)
    TrackConnection(MapDetect)
end

-- ==============================================================================
-- [INTEGRATION] VOTE LOGIC
-- ==============================================================================

local function GetSessionKey()
    local success, key = pcall(function()
        return ReqPasskey:InvokeServer()
    end)
    if success and key then
        return -key -- Negate key
    end
    return nil
end

local function CalculateCost(mapData, myVoteData)
    local currentVoteCount = 0
    local votedMapID = 0
    if myVoteData then
        currentVoteCount = myVoteData.voteCount or 0
        votedMapID = myVoteData.mapID or 0
    end
    if votedMapID == mapData.ID then
        local rawCost = mapData.extraVoteCost + (currentVoteCount - 1) * 10
        return math.clamp(rawCost, 0, 50)
    end
    if mapData.locked == true then
        return mapData.unlockCost
    end
    return 0
end

local VoteListener = NewMapVote.OnClientEvent:Connect(function(dataPacket)
    local maps = dataPacket.mapData
    local pVotes = dataPacket.pVotes or {}
    
    if not maps then return end

    local foundTarget = nil

    -- Check if our target map is in the list AND VISIBLE
    for _, map in pairs(maps) do
        if map.name == TARGET_MAP_NAME and map.displayMap == true then
            foundTarget = map
            break
        end
    end

    if foundTarget then
        getgenv().TomatoAutoFarm = false
        CurrentlyFarming = false
        
        Alert("!!! TARGET MAP DETECTED: " .. TARGET_MAP_NAME .. " !!!")
        print("Stopping AutoFarm to vote for: " .. TARGET_MAP_NAME)

        local remoteKey = GetSessionKey()
        if not remoteKey then 
            Alert("Vote Failed: No Key")
            return 
        end

        local myUserId = tostring(LocalPlayer.UserId)
        local myVoteData = pVotes[myUserId]
        local cost = CalculateCost(foundTarget, myVoteData)

        UpdMapVote:FireServer(remoteKey, foundTarget.ID, cost)
        Alert("Vote Sent! Cost: " .. cost)

        task.spawn(ExecuteSecondaryScript)
    else
        print("Target map ("..TARGET_MAP_NAME..") not found or not displayed.")
    end
end)

TrackConnection(VoteListener)

-- ==============================================================================
-- [INTERNAL] MAIN LOOP
-- ==============================================================================

if _G.LoopCancel ~= nil then
    _G.LoopCancel = true
    task.wait(.1)
end
_G.LoopCancel = false
Alert("Ready! Starting Update Loop.")

-- Auto Lift Rejoin Logic (Watchdog)
task.spawn(function()
    while task.wait(1) do
        if _G.LoopCancel == true then break end
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local inLift = Check("InLift")
            local inGame = Check("InGame")

            -- Logic: If NOT in lift AND NOT in game -> Fire Remote
            -- [UPDATE] Only if AutoFarm is Enabled
            if not inLift and not inGame and getgenv().TomatoAutoFarm then
                AddedWaiting:FireServer()
            end
        end
    end
end)

-- Main Connection & Pause Alert Loop
task.spawn(function()
    while task.wait(0.5) do
        -- 1. Check for Script Kill
        if _G.LoopCancel == true then
            Alert("Script Overridden/Cancelled.")
            if MapDetect then MapDetect:Disconnect() end
            break
        end
        
        -- 2. Ensure Map Listener is active
        if not MapDetect then
            ConnectMap()
        end

        -- 3. Check for PAUSE (User toggled false)
        if getgenv().TomatoAutoFarm == false then
            Alert("Auto Farm Paused!")
            
            -- Wait here until User toggles TRUE or cancels script
            repeat 
                task.wait(0.5) 
            until getgenv().TomatoAutoFarm == true or _G.LoopCancel == true
            
            -- If we exited the loop because they turned it back ON (and not because script died)
            if _G.LoopCancel == false then
                Alert("Auto Farm Resumed!")
            end
        end
    end
end)
