--[[
    FE2 TAS Creator (Fixed Crash Issue)
    UI Loaded via API
    Velocity Preserved | Savestates Fixed | Frame Rewind | Archivable Bypass Restored
]]

-- CONFIGURATION
local UI_API_URL = "https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/main/TAS/CREATOR/uiapi.luau"

print("Initializing TAS Creator for FE2...")

-- Keybind Configuration
local Keybinds = {
    AddSavestate = "One",
    RemoveSavestate = "Two",
    BackSavestate = "Three",
    GoFrameBack = "Four",
    GoFrameForward = "Five",
    SaveRun = "Six",
    UserPause = "CapsLock",
    CollisionToggler = "C",
    ResetToNormal = "Delete",
    ViewTAS = "Zero"
}

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local GameScriptEnv = getsenv(PlayerScripts:WaitForChild("CL_MAIN_GameScript"))
local NewAlert = GameScriptEnv.newAlert

-- // CRITICAL ANTI-CRASH BYPASS //
-- The game checks if parts are Archivable to detect cloning/stealing.
-- We must hook this to return false to the game, but true to our script.
local OldIndex
OldIndex = hookmetamethod(game, "__index", function(self, key)
    -- If the game asks "Is this Archivable?", we say "No" (false).
    -- We use checkcaller() to allow OUR script to see the truth.
    if key == "Archivable" and not checkcaller() then
        return false
    end
    return OldIndex(self, key)
end)
print("Archivable Bypass Hooked")

-- Load UI via API
local TAS_UI = loadstring(game:HttpGet(UI_API_URL))()
local UI_Elements = TAS_UI.Create()

-- Variables
local SaveStates = {}       
local CurrentRunFrames = {} 
local RopeTable = {}

local IsPaused = true
local TimeOffset = 0
local PauseStartTime = 0
local RunStartTime = 0
local SavedPauseVelocity = Vector3.new(0, 0, 0)

local MapOffsetX, MapOffsetY, MapOffsetZ
local MapOriginCFrame
local OriginalMapPosition

local CurrentMapName
local Connection_CharacterAdded
local Connection_Heartbeat
local Connection_InputBegan
local Connection_Rope

-- Helper Functions
local function GetAlertColor(r, g, b)
    return Color3.new(r or 1, g or 1, b or 1)
end

NewAlert("TAS Creator Initialized", GetAlertColor(0.7, 0, 1))

-- Hooking Logic
local function GetCharacterComponents()
    local Root = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("Torso") or LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
    if not Root then return CFrame.new() end
    
    local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Root.CFrame:GetComponents()
    return CFrame.new(x - MapOffsetX, y - MapOffsetY + 1000, z - MapOffsetZ, R00, R01, R02, R10, R11, R12, R20, R21, R22)
end

local CurrentAnimationData = {"idle", 0}
local OriginalPlayAnimation
local AnimationScriptEnv

local function HookAnimationScript()
    repeat
        local char = LocalPlayer.Character
        if not char then task.wait() continue end
        local animScript = char:WaitForChild("Animate", 5)
        if animScript then
            AnimationScriptEnv = getsenv(animScript)
        end
        task.wait()
    until AnimationScriptEnv and AnimationScriptEnv.playAnimation ~= nil

    OriginalPlayAnimation = AnimationScriptEnv.playAnimation
    
    AnimationScriptEnv.playAnimation = function(animName, speed)
        if not IsPaused then
            CurrentAnimationData = {animName, speed}
            OriginalPlayAnimation(CurrentAnimationData[1], CurrentAnimationData[2], LocalPlayer.Character.Humanoid)
        end
    end
    print("Animation Hook Updated")
end

local function CaptureFrame()
    local root = LocalPlayer.Character.HumanoidRootPart
    return {
        CFrame = GetCharacterComponents(),
        CameraCFrame = workspace.CurrentCamera.CFrame,
        Velocity = root.Velocity,
        Animation = CurrentAnimationData,
        Time = tick() - RunStartTime - TimeOffset
    }
end

-- Map Setup Logic
local function SetupMap()
    local Multiplayer = Workspace:WaitForChild("Multiplayer")
    local Map = Multiplayer:WaitForChild("Map")
    
    local Spawn = Map:FindFirstChild("Spawn", true)
    if Spawn then
        Map.PrimaryPart = Spawn
    else
        local targetPart = nil
        local connection
        local waiting = true
        for _, part in ipairs(Map:GetChildren()) do
            if part.Name == "Part" and part.Size.Y < 5 then
                connection = part:GetPropertyChangedSignal("Rotation"):Connect(function()
                    targetPart = part
                    waiting = false
                    connection:Disconnect()
                end)
            end
        end
        repeat task.wait() until not waiting or targetPart
        Map.PrimaryPart = targetPart
    end

    CurrentMapName = Map.Settings:GetAttribute("MapName")
    
    for _, desc in pairs(Map:GetDescendants()) do
        desc.Archivable = true
    end
    print("Map processed")

    local ClonedMap = Map:Clone()
    for _, child in pairs(Workspace:GetChildren()) do
        if child.Name == "Map" then child:Destroy() end
    end
    ClonedMap.Parent = Workspace
    
    OriginalMapPosition = ClonedMap.PrimaryPart.Position
    MapOffsetX, MapOffsetY, MapOffsetZ = OriginalMapPosition.X, OriginalMapPosition.Y, OriginalMapPosition.Z
    MapOriginCFrame = CFrame.new(MapOffsetX, MapOffsetY, MapOffsetZ)

    LocalPlayer.Character.Head:Destroy()
    LocalPlayer.CharacterAdded:Wait()
    local Char = LocalPlayer.Character
    local Hum = Char:WaitForChild("Humanoid")
    local Root = Char:WaitForChild("HumanoidRootPart")

    local FE2Char = Char:WaitForChild("FE2_Character")
    local FE2Env = getsenv(FE2Char)
    local startZipline = FE2Env.startZipline

    if #RopeTable >= 1 then
        print("Loading RopeTable! Size:", #RopeTable)
        task.spawn(function()
            while Char and Hum.Health >= 1 do
                setupvalue(startZipline, 2, RopeTable)
                task.wait()
            end
        end)
    end

    Hum.WalkSpeed = 0
    Hum.JumpPower = 0
    task.wait(0.5)
    Root.CFrame = CFrame.new(ClonedMap.PrimaryPart.Position) + Vector3.new(0, ClonedMap.PrimaryPart.Size.Y/2 + 3, 0)
    task.wait(0.5)
    Root.Anchored = true
    Hum.WalkSpeed = 20
    Hum.JumpPower = 50

    table.insert(SaveStates, {{
        CFrame = GetCharacterComponents(),
        CameraCFrame = workspace.CurrentCamera.CFrame * MapOriginCFrame,
        Velocity = Vector3.new(0,0,0),
        Animation = {"idle", 0},
        Time = 0
    }})

    PauseStartTime = tick()
    RunStartTime = tick()
    HookAnimationScript()

    Connection_CharacterAdded = LocalPlayer.CharacterAdded:Connect(function(newChar)
        local anim = newChar:WaitForChild("Animate")
        if anim.Enabled then HookAnimationScript() end
    end)

    task.wait(1)
    -- Reveal logic / Button detection
    for _, obj in pairs(ClonedMap:GetDescendants()) do
        if obj:IsA("BasePart") then
            if not string.match(obj.Name, "Part") then
                pcall(function() 
                    obj.Transparency = (obj.CanCollide and 0.5) or 0.8
                end)
            end
            if obj.Name:lower():match("button") or obj.Parent.Name:lower():match("button") then
                local box = Instance.new("SelectionBox", obj)
                box.Adornee = obj
                box.Color3 = Color3.fromRGB(255, 140, 0)
            end
        end
    end
    
    if Multiplayer:FindFirstChild("Map") then
        Multiplayer.Map:Destroy()
    end
    print("Finished setting up map")
end

-- Update UI
local function UpdateUI()
    UI_Elements.SavestatesCount.Text = "Savestates " .. tostring(#SaveStates)
    UI_Elements.FrameCount.Text = "Frames " .. tostring(#CurrentRunFrames)
    
    local elapsed = tick() - RunStartTime - TimeOffset
    local m = math.floor(elapsed / 60)
    local s = math.floor(elapsed % 60)
    local ms = math.floor(elapsed * 1000 % 1000)
    UI_Elements.TimeText.Text = string.format("%d:%02d.%03d", m, s, ms)
end

-- Core Functionality
local function RestoreStateFromFrame(frame)
    local Root = LocalPlayer.Character.HumanoidRootPart
    
    Root.CFrame = frame.CFrame + Vector3.new(MapOffsetX, MapOffsetY - 1000, MapOffsetZ)
    Root.Velocity = frame.Velocity
    SavedPauseVelocity = frame.Velocity
    
    workspace.CurrentCamera.CFrame = frame.CameraCFrame
    
    TimeOffset = 0
    RunStartTime = tick() - frame.Time
    PauseStartTime = tick()
    
    if OriginalPlayAnimation and frame.Animation then
        OriginalPlayAnimation(frame.Animation[1], frame.Animation[2], LocalPlayer.Character.Humanoid)
    end
    if frame.Animation[1] == "walk" and AnimationScriptEnv then
         AnimationScriptEnv.setAnimationSpeed(0.76)
    end
end

local function TogglePause()
    IsPaused = not IsPaused
    local Root = LocalPlayer.Character.HumanoidRootPart
    
    if IsPaused then
        SavedPauseVelocity = Root.Velocity 
        Root.Anchored = true
        
        UI_Elements.TimeText.TextColor3 = Color3.fromRGB(255, 255, 0)
        PauseStartTime = tick()
        UI_Elements.StatusText.Text = "CapsLock : Paused"
        UI_Elements.StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
    else
        Root.Anchored = false
        Root.Velocity = SavedPauseVelocity 
        
        UI_Elements.TimeText.TextColor3 = Color3.fromRGB(255, 255, 255)
        TimeOffset = TimeOffset + (tick() - PauseStartTime)
        UI_Elements.StatusText.Text = "CapsLock : Unpaused"
        UI_Elements.StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

local function LoadLastSavestate()
    if #SaveStates == 0 then return end
    
    local stateList = SaveStates[#SaveStates]
    local lastFrame = stateList[#stateList]
    
    if lastFrame then
        CurrentRunFrames = {}
        
        IsPaused = true
        LocalPlayer.Character.HumanoidRootPart.Anchored = true
        UI_Elements.TimeText.TextColor3 = Color3.fromRGB(255, 255, 0)
        UI_Elements.StatusText.Text = "CapsLock : Paused"
        
        RestoreStateFromFrame(lastFrame)
        UpdateUI()
    end
end

local function AddSavestate()
    if #CurrentRunFrames > 0 then
        NewAlert("Added Savestate", Color3.fromRGB(0, 255, 0), 1)
        table.insert(SaveStates, CurrentRunFrames)
        CurrentRunFrames = {}
        UpdateUI()
    else
        NewAlert("No frames to save", Color3.fromRGB(255, 0, 0), 1)
    end
end

local function RemoveSavestate()
    if #SaveStates > 1 then
        NewAlert("Removed Savestate", Color3.fromRGB(0, 255, 0), 1)
        table.remove(SaveStates)
        LoadLastSavestate()
    else
        NewAlert("No Savestate", Color3.fromRGB(255, 0, 0), 1)
    end
end

local function ToggleCollision()
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    if target then
        target.CanCollide = not target.CanCollide
        target.Transparency = target.CanCollide and 0 or 0.8
    end
end

local function FrameAdvance()
    if IsPaused then
        TogglePause()
        RunService.Heartbeat:Wait()
        RunService.Heartbeat:Wait()
        TogglePause()
    end
end

local function FrameRewind()
    if not IsPaused then TogglePause() end
    
    local targetFrame
    
    if #CurrentRunFrames > 0 then
        table.remove(CurrentRunFrames)
        if #CurrentRunFrames > 0 then
            targetFrame = CurrentRunFrames[#CurrentRunFrames]
        end
    end
    
    if not targetFrame and #CurrentRunFrames == 0 then
        if #SaveStates > 0 then
            local lastStateList = table.remove(SaveStates)
            CurrentRunFrames = lastStateList
            
            if #CurrentRunFrames > 0 then
                table.remove(CurrentRunFrames)
                if #CurrentRunFrames > 0 then
                    targetFrame = CurrentRunFrames[#CurrentRunFrames]
                end
            end
        end
    end
    
    if targetFrame then
        RestoreStateFromFrame(targetFrame)
        UpdateUI()
    end
end

local function SaveRunToJson()
    local exportData = {}
    
    for _, stateGroup in ipairs(SaveStates) do
        for _, frame in ipairs(stateGroup) do
            local cleanFrame = {
                AAnimation = frame.Animation or {"walk", 0.1},
                AAnimationChanged = frame.Animation[2],
                VVelocity = {frame.Velocity.X, frame.Velocity.Y, frame.Velocity.Z},
                CCameraCFrame = {frame.CameraCFrame:GetComponents()},
                CCFrame = {frame.CFrame:GetComponents()},
                time = frame.Time
            }
            local cf = frame.CFrame
            local rx, ry, rz = cf:ToEulerAnglesXYZ()
            cleanFrame.CCFrame = {cf.X, cf.Y, cf.Z, {rx, ry, rz}}
            
            local ccf = frame.CameraCFrame
            local crx, cry, crz = ccf:ToEulerAnglesXYZ()
            cleanFrame.CCameraCFrame = {ccf.X, ccf.Y, ccf.Z, {crx, cry, crz}}

            table.insert(exportData, cleanFrame)
        end
    end
    
    if not isfolder("Flood-GUI/TAS FILES") then
        makefolder("Flood-GUI")
        makefolder("Flood-GUI/TAS FILES")
    end
    
    local fileName = "Flood-GUI/TAS FILES/" .. (CurrentMapName or "Unknown") .. ".json"
    writefile(fileName, HttpService:JSONEncode(exportData))
    NewAlert("Run Saved to " .. fileName, Color3.fromRGB(0, 255, 0), 1)
end

local function ViewTAS()
    if #SaveStates > 0 then
        local playbackData = {}
        for _, group in ipairs(SaveStates) do
            for _, frame in ipairs(group) do
                table.insert(playbackData, {
                    AAnimation = frame.Animation,
                    CCFrame = {frame.CFrame:GetComponents()},
                    time = frame.Time
                })
            end
        end
        
        local idx = 1
        local start = tick()
        local con
        con = RunService.Heartbeat:Connect(function()
            if not playbackData[idx] then con:Disconnect() return end
            
            local frame = playbackData[idx]
            if tick() - start >= frame.time then
                LocalPlayer.Character.HumanoidRootPart.Anchored = false
                LocalPlayer.Character.HumanoidRootPart.CFrame = frame.CCFrame + Vector3.new(MapOffsetX, MapOffsetY-1000, MapOffsetZ)
                idx = idx + 1
            end
        end)
    end
end

-- Initialize Rope Listener
local RopeListenerEvent = (function()
    local bytecode = getscriptbytecode(LocalPlayer.Character.FE2_Character)
    local eventName = string.match(bytecode, "GetPropertyChangedSignal%s+(%a+)%s+OnClientEvent")
    return game:FindFirstChild(eventName, true)
end)()

if RopeListenerEvent then
    Connection_Rope = RopeListenerEvent.OnClientEvent:Connect(function(val)
        if type(val) == "table" and #val >= 1 then
            RopeTable = val
            print("Rope Table Captured")
            Connection_Rope:Disconnect()
        end
    end)
end

-- Main Loop
print("Waiting for Map...")
Workspace.Multiplayer:WaitForChild("NewMap", 9e99)
Workspace.Multiplayer:WaitForChild("Map", 9e99)

repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Anchored == false

print("Starting TAS Session")
task.wait(1)
SetupMap()

-- Input Handling
Connection_InputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    
    local key = input.KeyCode.Name
    if key == Keybinds.UserPause then TogglePause()
    elseif key == Keybinds.AddSavestate then task.spawn(AddSavestate)
    elseif key == Keybinds.RemoveSavestate then task.spawn(RemoveSavestate)
    elseif key == Keybinds.BackSavestate then task.spawn(LoadLastSavestate)
    elseif key == Keybinds.CollisionToggler then ToggleCollision()
    elseif key == Keybinds.SaveRun then SaveRunToJson()
    elseif key == Keybinds.GoFrameForward then task.spawn(FrameAdvance)
    elseif key == Keybinds.GoFrameBack then task.spawn(FrameRewind)
    elseif key == Keybinds.ViewTAS then task.spawn(ViewTAS)
    elseif key == Keybinds.ResetToNormal then 
        UI_Elements.ScreenGui:Destroy()
        LocalPlayer.Character.Humanoid.Health = 0
        script.Disabled = true
    end
end)

-- Heartbeat Loop
Connection_Heartbeat = RunService.Heartbeat:Connect(function()
    if not IsPaused then
        UpdateUI()
        table.insert(CurrentRunFrames, CaptureFrame())
    end
end)
