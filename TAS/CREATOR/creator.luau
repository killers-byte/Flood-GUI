--[[
    FE2 TAS Creator (Restored & Functional)
    - Fixed "Hold to Rewind" (restored original loops)
    - Fixed "View TAS" (restored data structure)
    - Fixed "Moving while Paused" (restored anchor logic)
    - Added Velocity Preservation (Pausing won't kill your momentum)
]]

-- CONFIGURATION
local UI_API_URL = "https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/main/TAS/CREATOR/uiapi.luau"

-- // BYPASSES //
local OldIndex
OldIndex = hookmetamethod(game, "__index", function(self, key)
    if key == "Archivable" and not checkcaller() then
        return false
    end
    return OldIndex(self, key)
end)

-- // SERVICES //
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character
local GameScript = LocalPlayer.PlayerScripts:WaitForChild("CL_MAIN_GameScript", 10)
local NewAlert = getsenv(GameScript).newAlert

-- // LOAD UI //
local TAS_UI = loadstring(game:HttpGet(UI_API_URL))()
local UI = TAS_UI.Create()

-- // VARIABLES //
local SaveStates = {}       -- (Originally 'q')
local CurrentFrames = {}    -- (Originally 'r')
local CurrentAnim = {}      -- (Originally 'p')
local RopeTable = {}

-- State Variables
local IsPaused = true       -- (Originally 't')
local TimeOffset = 0        -- (Originally 's')
local PauseStart = 0        -- (Originally 'u')
local RunStart = 0          -- (Originally 'x')

-- Map Variables
local MapOffsetX, MapOffsetY, MapOffsetZ
local MapOriginCFrame
local CurrentMapName

-- Loops & Connections
local HeartbeatConnection
local InputBeganConnection
local InputEndedConnection
local CharAddedConnection

-- Input Loop States (For holding keys)
local Rewinding = false     -- (Originally 'dH')
local FastForwarding = false -- (Originally 'dB')

-- Velocity Fix Variable
local SavedVelocity = Vector3.new(0, 0, 0)

-- // HELPER FUNCTIONS //

local function GetCharacterCFrame()
    local Root = LocalPlayer.Character.HumanoidRootPart
    local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Root.CFrame:GetComponents()
    -- Matches original math: y - MapOffsetY + 1000
    return CFrame.new(x - MapOffsetX, y - MapOffsetY + 1000, z - MapOffsetZ, R00, R01, R02, R10, R11, R12, R20, R21, R22)
end

local function CaptureFrame()
    local Root = LocalPlayer.Character.HumanoidRootPart
    return {
        CFrame = GetCharacterCFrame(),
        CameraCFrame = Workspace.CurrentCamera.CFrame,
        Velocity = Root.Velocity,
        Animation = CurrentAnim,
        Time = tick() - RunStart - TimeOffset
    }
end

local function UpdateTimeDisplay()
    local elapsed = tick() - RunStart - TimeOffset
    local m = math.floor(elapsed / 60)
    local s = math.floor(elapsed % 60)
    local ms = math.floor(elapsed * 1000 % 1000)
    UI.TimeText.Text = string.format("%d:%02d.%03d", m, s, ms)
end

local function UpdateCounters()
    UI.SavestatesCount.Text = "Savestates " .. tostring(#SaveStates)
    UI.FrameCount.Text = "Frames " .. tostring(#CurrentFrames)
end

-- // ANIMATION HOOK //
local OriginalPlayAnim
local AnimEnv
local function HookAnimations()
    repeat
        local Animate = LocalPlayer.Character:WaitForChild("Animate", 5)
        if Animate then AnimEnv = getsenv(Animate) end
        task.wait()
    until AnimEnv and AnimEnv.playAnimation ~= nil
    
    OriginalPlayAnim = AnimEnv.playAnimation
    
    AnimEnv.playAnimation = function(anim, speed)
        if not IsPaused then
            CurrentAnim = {anim, speed}
            OriginalPlayAnim(CurrentAnim[1], CurrentAnim[2], LocalPlayer.Character.Humanoid)
        end
    end
end

-- // CORE LOGIC //

local function TogglePause()
    IsPaused = not IsPaused
    local Root = LocalPlayer.Character.HumanoidRootPart
    
    if IsPaused then
        -- Pausing
        SavedVelocity = Root.Velocity -- Save velocity
        Root.Anchored = true
        UI.TimeText.TextColor3 = Color3.fromRGB(255, 255, 0)
        PauseStart = tick()
        UI.StatusText.Text = "CapsLock : Paused"
        UI.StatusText.TextColor3 = Color3.fromRGB(255, 255, 0)
    else
        -- Unpausing
        Root.Anchored = false
        Root.Velocity = SavedVelocity -- Restore velocity
        UI.TimeText.TextColor3 = Color3.fromRGB(255, 255, 255)
        TimeOffset = TimeOffset + (tick() - PauseStart)
        UI.StatusText.Text = "CapsLock : Unpaused"
        UI.StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

local function LoadState(frame)
    if not frame then return end
    
    CurrentFrames = {}
    IsPaused = true
    
    local Root = LocalPlayer.Character.HumanoidRootPart
    Root.Anchored = true
    UI.TimeText.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    -- Restore Physics
    Root.CFrame = frame.CFrame + Vector3.new(MapOffsetX, MapOffsetY - 1000, MapOffsetZ)
    Root.Velocity = frame.Velocity
    SavedVelocity = frame.Velocity -- Ensure unpause keeps this velocity
    Workspace.CurrentCamera.CFrame = frame.CameraCFrame
    
    -- Restore Time
    PauseStart = tick()
    RunStart = tick() - frame.Time
    TimeOffset = 0
    
    -- Restore Animation
    if frame.Animation and frame.Animation[1] then
        OriginalPlayAnim(frame.Animation[1], frame.Animation[2], LocalPlayer.Character.Humanoid)
        if frame.Animation[1] == "walk" and AnimEnv then
            AnimEnv.setAnimationSpeed(0.76)
        end
    end
    
    UpdateTimeDisplay()
end

local function LoadLastSavestate()
    if #SaveStates == 0 then return end
    local lastStateTable = SaveStates[#SaveStates]
    local lastFrame = lastStateTable[#lastStateTable]
    LoadState(lastFrame)
end

local function AddSavestate()
    if #CurrentFrames > 0 then
        NewAlert("Added Savestate", Color3.fromRGB(0, 255, 0), 1)
        table.insert(SaveStates, CurrentFrames)
        CurrentFrames = {}
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

-- // FRAME MANIPULATION (Restored Loops) //

local function StepBack()
    if LocalPlayer.Character then
        local targetFrame = CurrentFrames[#CurrentFrames - 1]
        
        -- If current buffer empty, try grabbing from last savestate
        if not targetFrame and #SaveStates > 0 then
            targetFrame = SaveStates[#SaveStates][#SaveStates[#SaveStates] - 1]
        end
        
        if targetFrame then
            if not IsPaused then TogglePause() end
            LoadState(targetFrame)
            -- Remove last frame from buffer
            CurrentFrames[#CurrentFrames] = nil
        end
    end
end

local function RewindLoop()
    Rewinding = true
    StepBack()
    while task.wait(0.05) and Rewinding do
        StepBack()
    end
end

local function StepForward()
    if IsPaused then
        TogglePause()
        RunService.Heartbeat:Wait()
        RunService.Heartbeat:Wait()
        TogglePause()
    end
end

local function FastForwardLoop()
    FastForwarding = true
    StepForward()
    while task.wait(0.1) and FastForwarding do
        StepForward()
    end
end

-- // VIEW TAS LOGIC (Restored) //
local PlayingBack = false
local function Playback(data)
    PlayingBack = true
    local Root = LocalPlayer.Character.HumanoidRootPart
    local Cam = Workspace.CurrentCamera
    
    local index = 3
    local start = tick()
    
    local playbackCon
    playbackCon = RunService.Heartbeat:Connect(function()
        Root.Anchored = false
        Root.Humanoid.Jump = true -- Keep jumping state active
        
        if not IsPaused then TogglePause() end
        
        -- Process frames up to current time
        while index <= #data do
            local frame = data[index]
            if tick() - start < frame.time then break end
            
            -- Apply Frame
            local cf = frame.CCFrame
            local camCf = frame.CCameraCFrame
            
            local cPos = Vector3.new(cf[1], cf[2], cf[3])
            local cRot = CFrame.fromEulerAnglesXYZ(unpack(cf[4]))
            Root.CFrame = (CFrame.new(cPos) * cRot) + Vector3.new(MapOffsetX, MapOffsetY - 1000, MapOffsetZ)
            
            local camPos = Vector3.new(camCf[1], camCf[2], camCf[3])
            local camRot = CFrame.fromEulerAnglesXYZ(unpack(camCf[4]))
            Cam.CFrame = (CFrame.new(camPos) * camRot) + Vector3.new(MapOffsetX, MapOffsetY - 1000, MapOffsetZ)
            
            -- Anim
            if frame.AAnimation then
                OriginalPlayAnim(frame.AAnimation[1], frame.AAnimation[2], LocalPlayer.Character.Humanoid)
            end
            
            index = index + 1
        end
        
        if index > #data then
            playbackCon:Disconnect()
            PlayingBack = false
            Root.Anchored = true
        end
    end)
end

local function ViewTAS()
    if not PlayingBack then
        AddSavestate() -- Auto save current progress
        
        -- Flatten Savestates into Playback Data
        local flatData = {}
        for _, stateGroup in ipairs(SaveStates) do
            for _, frame in ipairs(stateGroup) do
                local entry = {}
                
                -- Convert data to simple format
                entry.time = frame.Time
                
                if frame.Animation then
                    entry.AAnimation = {frame.Animation[1], frame.Animation[2]}
                else
                    entry.AAnimation = {"walk", 0.1}
                end
                
                local cf = frame.CFrame
                local rx, ry, rz = cf:ToEulerAnglesXYZ()
                entry.CCFrame = {cf.X, cf.Y, cf.Z, {rx, ry, rz}}
                
                local ccf = frame.CameraCFrame
                local crx, cry, crz = ccf:ToEulerAnglesXYZ()
                entry.CCameraCFrame = {ccf.X, ccf.Y, ccf.Z, {crx, cry, crz}}
                
                table.insert(flatData, entry)
            end
        end
        
        Playback(flatData)
    end
end

-- // SAVE TO FILE //
local function SaveToFile()
    -- Exactly matches ViewTAS flattening logic but wraps for JSON
    local exportData = {}
    for _, stateGroup in ipairs(SaveStates) do
        for _, frame in ipairs(stateGroup) do
            local entry = {}
            entry.time = frame.Time
            entry.AAnimation = frame.Animation or {"walk", 0.1}
            entry.AAnimationChanged = frame.Animation[2]
            entry.VVelocity = {frame.Velocity.X, frame.Velocity.Y, frame.Velocity.Z}
            
            local cf = frame.CFrame
            local rx, ry, rz = cf:ToEulerAnglesXYZ()
            entry.CCFrame = {cf.X, cf.Y, cf.Z, {rx, ry, rz}}
            
            local ccf = frame.CameraCFrame
            local crx, cry, crz = ccf:ToEulerAnglesXYZ()
            entry.CCameraCFrame = {ccf.X, ccf.Y, ccf.Z, {crx, cry, crz}}
            
            table.insert(exportData, entry)
        end
    end
    
    if not isfolder("TAS") then makefolder("TAS") end
    writefile("TAS/" .. CurrentMapName .. ".json", HttpService:JSONEncode(exportData))
    NewAlert("Saved to TAS/"..CurrentMapName..".json", Color3.fromRGB(0, 255, 0), 1)
end


-- // SETUP MAP //
local function SetupMap()
    local MP = Workspace.Multiplayer
    local Map = MP:WaitForChild("Map")
    
    -- Find Spawn
    local Spawn = Map:FindFirstChild("Spawn", true)
    if not Spawn then
        -- Lift logic
        local target, waiting = nil, true
        for _, p in pairs(Map:GetChildren()) do
            if p.Name == "Part" and p.Size.Y < 5 then
                p:GetPropertyChangedSignal("Rotation"):Connect(function() target = p end)
            end
        end
        repeat task.wait() until target
        Map.PrimaryPart = target
    else
        Map.PrimaryPart = Spawn
    end
    
    CurrentMapName = Map.Settings:GetAttribute("MapName")
    
    local ClonedMap = Map:Clone()
    for _, c in pairs(Workspace:GetChildren()) do if c.Name == "Map" then c:Destroy() end end
    ClonedMap.Parent = Workspace
    
    -- Set offsets
    local PrimPos = ClonedMap.PrimaryPart.Position
    MapOffsetX, MapOffsetY, MapOffsetZ = PrimPos.X, PrimPos.Y, PrimPos.Z
    MapOriginCFrame = CFrame.new(MapOffsetX, MapOffsetY, MapOffsetZ)
    
    -- Reset Char
    LocalPlayer.Character.Head:Destroy()
    LocalPlayer.CharacterAdded:Wait()
    
    local Char = LocalPlayer.Character
    local Root = Char:WaitForChild("HumanoidRootPart")
    local Hum = Char:WaitForChild("Humanoid")
    
    -- Rope
    local FE2Char = Char:WaitForChild("FE2_Character")
    local startZipline = getsenv(FE2Char).startZipline
    if #RopeTable > 0 then
        task.spawn(function()
            while Char and Hum.Health > 0 do
                setupvalue(startZipline, 2, RopeTable)
                task.wait()
            end
        end)
    end
    
    -- Teleport
    Hum.WalkSpeed = 0
    Hum.JumpPower = 0
    task.wait(0.5)
    Root.CFrame = CFrame.new(PrimPos) + Vector3.new(0, ClonedMap.PrimaryPart.Size.Y/2 + 3, 0)
    task.wait(0.5)
    Root.Anchored = true
    Hum.WalkSpeed = 20
    Hum.JumpPower = 50
    
    -- Initial Save
    table.insert(SaveStates, {{
        CFrame = CaptureFrame().CFrame,
        CameraCFrame = Workspace.CurrentCamera.CFrame * MapOriginCFrame,
        Velocity = Vector3.new(0,0,0),
        Animation = {"idle", 0},
        Time = 0
    }})
    
    PauseStart = tick()
    RunStart = tick()
    HookAnimations()
    CharAddedConnection = LocalPlayer.CharacterAdded:Connect(function(c)
        c:WaitForChild("Animate")
        HookAnimations()
    end)
    
    -- Reveal
    for _, v in pairs(ClonedMap:GetDescendants()) do
        if v:IsA("BasePart") then
            if v.Name ~= "Part" then pcall(function() v.Transparency = v.CanCollide and 0 or 0.8 end) end
            if v.Name:lower():match("button") or (v.Parent and v.Parent.Name:lower():match("button")) then
                local b = Instance.new("SelectionBox", v)
                b.Adornee = v
                b.Color3 = Color3.fromRGB(255, 140, 0)
            end
        end
    end
    
    if MP:FindFirstChild("Map") then MP.Map:Destroy() end
    NewAlert("TAS Ready", Color3.fromRGB(0, 255, 0), 1)
end


-- // ROPE LISTENER //
task.spawn(function()
    local FE2Char = LocalPlayer.Character:WaitForChild("FE2_Character")
    local code = getscriptbytecode(FE2Char)
    local eventName = string.match(code, "GetPropertyChangedSignal%s+(%a+)%s+OnClientEvent")
    local event = game:FindFirstChild(eventName, true)
    
    if event then
        event.OnClientEvent:Connect(function(val)
            if type(val) == "table" and #val > 0 then RopeTable = val end
        end)
    end
end)


-- // MAIN EXECUTION //
Workspace.Multiplayer:WaitForChild("NewMap", 9e99)
Workspace.Multiplayer:WaitForChild("Map", 9e99)

repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and not LocalPlayer.Character.HumanoidRootPart.Anchored

SetupMap()

-- // INPUT HANDLING //
InputBeganConnection = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local k = input.KeyCode.Name
    
    if k == "CapsLock" then TogglePause()
    elseif k == "One" then task.spawn(AddSavestate)
    elseif k == "Two" then task.spawn(RemoveSavestate)
    elseif k == "Three" then task.spawn(LoadLastSavestate)
    elseif k == "Four" then task.spawn(RewindLoop) -- Restored Loop
    elseif k == "Five" then task.spawn(FastForwardLoop) -- Restored Loop
    elseif k == "Six" then SaveToFile()
    elseif k == "Zero" then task.spawn(ViewTAS) -- Restored ViewTAS
    elseif k == "C" then
        local t = LocalPlayer:GetMouse().Target
        if t then t.CanCollide = not t.CanCollide; t.Transparency = t.CanCollide and 0 or 0.8 end
    elseif k == "Delete" then
        UI.ScreenGui:Destroy()
        LocalPlayer.Character.Humanoid.Health = 0
        script.Disabled = true
    end
end)

InputEndedConnection = UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    local k = input.KeyCode.Name
    if k == "Four" then Rewinding = false end
    if k == "Five" then FastForwarding = false end
end)

HeartbeatConnection = RunService.Heartbeat:Connect(function()
    if not IsPaused then
        UpdateTimeDisplay()
        table.insert(CurrentFrames, CaptureFrame())
    end
    UpdateCounters()
end)
