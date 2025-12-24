--[[
    FE2 TAS Creator (Original Logic Logic - Deobfuscated)
    - Original "Hold 4/5" loops preserved
    - Original "View TAS" flattening logic preserved
    - Velocity Fix Added (No more stopping when unpausing)
    - Anti-Crash Hooks Preserved
]]

local UI_API_URL = "https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/main/TAS/CREATOR/uiapi.luau" -- PUT YOUR RAW LINK HERE

print("Latest TAS Creator built for FE2 v63.21 by tomato.txt")

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
local LocalPlayer = Players.LocalPlayer
local NewAlert = getsenv(LocalPlayer.PlayerScripts.CL_MAIN_GameScript).newAlert

-- // BYPASSES (Critical) //
local OldIndex
OldIndex = hookmetamethod(game, "__index", function(self, key)
    if key == "Archivable" and not checkcaller() then
        return false
    end
    return OldIndex(self, key)
end)

-- // HANDSHAKE //
pcall(function()
    game.ReplicatedStorage.Remote.ReqPasskey:InvokeServer()
end)

-- // VARIABLES //
local CurrentAnim = {}
local Savestates = {}
local Frames = {}
local TimeOffset = 0
local IsPaused = true -- (Originally 't')
local PauseStart
local OriginalPlayAnim
local AnimEnv
local RunStart
local TimeText -- (UI)
local GameStats -- (UI)
local FrameCountLabel -- (UI)
local StatusLabel -- (UI)
local MapName
local CharConnection

-- Velocity Fix Variable
local SavedVelocity = Vector3.new(0, 0, 0) 

local MapOffset, MapPos, MapX, MapY, MapZ

-- // HELPER FUNCTIONS //

local function GetPlayerCFrame()
    local Root = LocalPlayer.Character.HumanoidRootPart
    local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Root.CFrame:GetComponents()
    -- Matches original math: y - MapY + 1000
    local NewCF = CFrame.new(x - MapX, y - MapY + 1000, z - MapZ, R00, R01, R02, R10, R11, R12, R20, R21, R22)
    return NewCF
end

local function CaptureFrameData()
    return {
        CFrame = GetPlayerCFrame(),
        CameraCFrame = workspace.CurrentCamera.CFrame,
        Velocity = LocalPlayer.Character.HumanoidRootPart.Velocity,
        Animation = CurrentAnim,
        Time = tick() - RunStart - TimeOffset
    }
end

local function ToggleObjectVisibility(obj)
    -- Simplified check from original 'V' function
    obj.CanCollide = not obj.CanCollide
    if obj.CanCollide == false then
        obj.Transparency = 0
    else
        obj.Transparency = 1
    end
end

-- // UI LOADER //
local TAS_UI = loadstring(game:HttpGet(UI_API_URL))()
local UI_Elements
local function LoadUI()
    UI_Elements = TAS_UI.Create()
    TimeText = UI_Elements.TimeText
    FrameCountLabel = UI_Elements.FrameCount
    StatusLabel = UI_Elements.StatusText
end

-- // ANIMATION HOOK //
local function HookAnimations()
    repeat
        AnimEnv = getsenv(LocalPlayer.Character:WaitForChild("Animate"))
        task.wait()
    until AnimEnv.playAnimation ~= nil
    
    OriginalPlayAnim = AnimEnv.playAnimation
    
    AnimEnv.playAnimation = function(anim, speed)
        if not IsPaused then
            CurrentAnim = {anim, speed}
            OriginalPlayAnim(CurrentAnim[1], CurrentAnim[2], LocalPlayer.Character.Humanoid)
        end
    end
end

-- // MAP SETUP //
local RopeTable = {}
local ClonedMap
local function SetupMap()
    -- Wait for map logic (original 'a0')
    local MP = game.Workspace.Multiplayer
    local Map = MP:WaitForChild("Map")
    local Spawn = Map:FindFirstChild("Spawn", true)
    
    if Spawn then
        Map.PrimaryPart = Spawn
    else
        local target = nil
        local connections = {}
        for _, child in ipairs(Map:GetChildren()) do
            if child.Name == "Part" and child.Size.Y < 5 then
                table.insert(connections, child:GetPropertyChangedSignal("Rotation"):Connect(function()
                    target = child
                    for _, con in ipairs(connections) do con:Disconnect() end
                end))
            end
        end
        repeat task.wait() until target
        Map.PrimaryPart = target
    end

    MapName = Map.Settings:GetAttribute("MapName")
    print(MapName)
    
    for _, desc in pairs(Map:GetDescendants()) do
        desc.Archivable = true
    end
    
    ClonedMap = Map:Clone()
    for _, child in pairs(workspace:GetChildren()) do
        if child.Name == "Map" then child:Destroy() end
    end
    ClonedMap.Parent = workspace
    
    MapPos = ClonedMap.PrimaryPart.Position
    MapX, MapY, MapZ = MapPos.X, MapPos.Y, MapPos.Z
    MapOffset = CFrame.new(MapX, MapY, MapZ)
    
    LocalPlayer.Character.Head:Destroy()
    LocalPlayer.CharacterAdded:Wait()
    local Char = LocalPlayer.Character
    local FE2Char = Char:WaitForChild("FE2_Character")
    task.wait(1)
    
    -- Rope Logic
    local FE2Env = getsenv(FE2Char)
    local startZipline = FE2Env.startZipline
    if #RopeTable >= 1 then
        task.spawn(function()
            while Char and Char.Humanoid.Health >= 1 do
                setupvalue(startZipline, 2, RopeTable)
                task.wait()
            end
        end)
    end
    
    local Hum = Char:WaitForChild("Humanoid")
    local Root = Char:WaitForChild("HumanoidRootPart")
    
    Hum.WalkSpeed = 0
    Hum.JumpPower = 0
    task.wait(0.5)
    Hum.WalkSpeed = 0
    Hum.JumpPower = 0
    Root.CFrame = CFrame.new(ClonedMap.PrimaryPart.Position) + Vector3.new(0, ClonedMap.PrimaryPart.Size.Y/2, 0) + Vector3.new(0, Root.Size.Y/2, 0) + Vector3.new(0, Char["Left Leg"].Size.Y, 0)
    task.wait(0.5)
    Root.Anchored = true
    Hum.WalkSpeed = 20
    Hum.JumpPower = 50
    
    table.insert(Savestates, {{
        CFrame = GetPlayerCFrame(),
        CameraCFrame = workspace.CurrentCamera.CFrame * MapOffset,
        Velocity = Vector3.new(0,0,0),
        Animation = {"idle", 0},
        Time = 0
    }})
    
    LoadUI()
    PauseStart = tick()
    RunStart = tick()
    HookAnimations()
    
    CharConnection = LocalPlayer.CharacterAdded:Connect(function(c)
        local anim = c:WaitForChild("Animate")
        if anim.Enabled then HookAnimations() end
    end)
    
    task.wait(2)
    -- Reveal Logic
    for _, obj in ipairs(ClonedMap:GetDescendants()) do
        if obj:IsA("BasePart") then
             -- (Simplifying obfuscated loop checks slightly while keeping logic)
             if obj.Name ~= "Part" then -- Heuristic from original
                 pcall(ToggleObjectVisibility, obj)
             end
             
             if obj.Name:lower():match("button") or (obj.Parent and obj.Parent.Name:lower():match("button")) then
                 local sel = Instance.new("SelectionBox", obj)
                 sel.Adornee = obj
                 sel.Color3 = Color3.fromRGB(255, 140, 0)
             end
        end
    end
    
    if MP:FindFirstChild("Map") then MP.Map:Destroy() end
    print("Finished setting up map")
end

local function UpdateSavestateCount()
    UI_Elements.SavestatesCount.Text = "Savestates " .. tostring(#Savestates)
end

local function UpdateTime()
    local dp = tick() - RunStart - TimeOffset
    local m = math.floor(dp / 60)
    local s = math.floor(dp % 60)
    local ms = math.floor(dp * 1000 % 1000)
    TimeText.Text = string.format("%d:%02d.%03d", m, s, ms)
end

-- // CORE TAS FUNCTIONS //

-- Toggle Pause (dt) - VELOCITY FIX ADDED
local function TogglePause()
    IsPaused = not IsPaused
    local Root = LocalPlayer.Character.HumanoidRootPart
    
    if IsPaused then
        SavedVelocity = Root.Velocity -- [FIX] Save speed
        Root.Anchored = true
        TimeText.TextColor3 = Color3.fromRGB(255, 255, 0)
        PauseStart = tick()
        StatusLabel.Text = "CapsLock : Paused"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    else
        Root.Anchored = false
        Root.Velocity = SavedVelocity -- [FIX] Apply speed
        TimeText.TextColor3 = Color3.fromRGB(255, 255, 255)
        TimeOffset = TimeOffset + tick() - PauseStart
        StatusLabel.Text = "CapsLock : Unpaused"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Load Savestate (du) - VELOCITY FIX ADDED
local function LoadLastSavestate()
    local LastState = Savestates[#Savestates]
    if LastState then
        local Frame = LastState[#LastState]
        
        Frames = {}
        IsPaused = true
        
        local Root = LocalPlayer.Character.HumanoidRootPart
        Root.Anchored = true
        TimeText.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        Root.CFrame = Frame.CFrame + Vector3.new(MapX, MapY - 1000, MapZ)
        Root.Velocity = Frame.Velocity
        SavedVelocity = Frame.Velocity -- [FIX] Update buffer
        
        workspace.CurrentCamera.CFrame = Frame.CameraCFrame
        PauseStart = tick()
        RunStart = tick() - Frame.Time
        TimeOffset = 0
        
        OriginalPlayAnim(Frame.Animation[1], Frame.Animation[2], LocalPlayer.Character.Humanoid)
        if Frame.Animation[1] == "walk" then AnimEnv.setAnimationSpeed(0.76) end
        
        UpdateTime()
    end
end

local function UpdateFrameCount()
    FrameCountLabel.Text = "Frames " .. tostring(#Frames)
end

local function AddSavestate() -- (dx)
    NewAlert("Added Savestate", Color3.fromRGB(0, 255, 0), 1)
    table.insert(Savestates, Frames)
    Frames = {}
end

local function RemoveSavestate() -- (dy)
    if #Savestates > 1 then
        NewAlert("Removed Savestate", Color3.fromRGB(0, 255, 0), 1)
        table.remove(Savestates)
        task.spawn(LoadLastSavestate)
    else
        NewAlert("No Savestate", Color3.fromRGB(255, 0, 0), 1)
    end
end

local function ToggleCollision() -- (dz)
    local target = LocalPlayer:GetMouse().Target
    target.CanCollide = not target.CanCollide
    target.Transparency = target.CanCollide and 0 or 0.8
end

-- Fast Forward Logic
local IsFastForwarding = false
local FFTask
local function StepForward() -- (dD)
    if IsPaused then
        TogglePause()
        -- Original loop did exactly 2 heartbeats
        for i = 1, 2 do RunService.Heartbeat:Wait() end
        TogglePause()
    end
end

local function FastForwardLoop() -- (dE)
    while IsFastForwarding do
        StepForward()
        task.wait(0.1)
    end
end

local function StartFastForward() -- (dF)
    if not IsFastForwarding then
        IsFastForwarding = true
        FFTask = task.spawn(FastForwardLoop)
    end
end

-- Rewind Logic
local IsRewinding = false
local function RewindFrame() -- (dJ) - VELOCITY FIX ADDED
    if LocalPlayer.Character then
        local Frame = Frames[#Frames - 1]
        
        if not Frame then
            -- Logic to grab from previous savestate buffer if current is empty
            if #Savestates > 0 then
                 -- This logic matches the original script's behavior implicitly
                 -- by checking Savestates table structure
                 Frame = Savestates[#Savestates][#Savestates[#Savestates] - 1]
            end
        end
        
        if Frame then
            if not IsPaused then TogglePause() end
            
            local Root = LocalPlayer.Character.HumanoidRootPart
            Root.CFrame = Frame.CFrame + Vector3.new(MapX, MapY - 1000, MapZ)
            Root.Velocity = Frame.Velocity
            SavedVelocity = Frame.Velocity -- [FIX] Update buffer
            
            workspace.CurrentCamera.CFrame = Frame.CameraCFrame
            PauseStart = tick()
            RunStart = tick() - Frame.Time
            TimeOffset = 0
            
            if Frame.Animation[1] and Frame.Animation[2] then
                OriginalPlayAnim(Frame.Animation[1], Frame.Animation[2], LocalPlayer.Character.Humanoid)
            end
            if Frame.Animation[1] == "walk" then AnimEnv.setAnimationSpeed(0.76) end
            
            task.spawn(UpdateTime)
            -- Remove last frame
            Frames[#Frames] = nil
        end
    end
end

local function StartRewind() -- (dK)
    IsRewinding = true
    RewindFrame()
    while task.wait(0.05) and IsRewinding do
        RewindFrame()
    end
end

-- View TAS Logic (Restored exact logic structure)
local IsViewingTAS = false
local function PlaybackTAS(Data) -- (dM)
    IsViewingTAS = true
    local Root = LocalPlayer.Character.HumanoidRootPart
    local Cam = workspace.CurrentCamera
    
    local function PlayAnim(anim)
        OriginalPlayAnim(anim[1], anim[2], LocalPlayer.Character.Humanoid)
        if anim[1] == "walk" then AnimEnv.setAnimationSpeed(0.76) end
    end
    
    -- Hitbox Logic from original
    local Hitbox = LocalPlayer.Character.FE2_Hitbox
    Hitbox.CanTouch = false
    
    local Offset = ClonedMap.PrimaryPart.Position - Vector3.new(0, 1000, 0)
    local idx = 3
    local PlayStart = tick()
    
    local Con
    Con = RunService.Heartbeat:Connect(function()
        Root.Anchored = false
        LocalPlayer.Character.Humanoid.Jump = true
        if not IsPaused then TogglePause() end
        
        -- Loop to skip frames if lagging
        for i = idx, #Data do
            local Frame = Data[i]
            if tick() - PlayStart < Frame.time then
                break
            elseif i >= #Data then
                Root.Anchored = true
                Con:Disconnect()
                IsViewingTAS = false
            elseif tick() - PlayStart >= Frame.time then
                idx = i
                local cf = Frame.CCFrame
                local ccf = Frame.CCameraCFrame
                
                Root.CFrame = CFrame.new(cf[1], cf[2], cf[3]) * CFrame.fromEulerAnglesXYZ(cf[4], cf[5], cf[6]) + Offset
                Cam.CFrame = CFrame.new(ccf[1], ccf[2], ccf[3]) * CFrame.fromEulerAnglesXYZ(ccf[4], ccf[5], ccf[6]) + Offset
                
                PlayAnim(Frame.AAnimation)
            end
        end
    end)
end

-- // SAVE RUN (cw) //
local function SaveRun()
    local Export = {}
    for i = 1, #Savestates do
        for j = 1, #Savestates[i] do
            local F = Savestates[i][j]
            local Entry = {}
            Entry.AAnimationChanged = F.Animation[2]
            Entry.VVelocity = {F.Velocity.X, F.Velocity.Y, F.Velocity.Z}
            
            -- Flatten CFrame
            Entry.CCameraCFrame = {F.CameraCFrame.X, F.CameraCFrame.Y, F.CameraCFrame.Z, F.CameraCFrame:ToEulerAnglesXYZ()}
            Entry.CCFrame = {F.CFrame.X, F.CFrame.Y, F.CFrame.Z, F.CFrame:ToEulerAnglesXYZ()}
            
            if F.Animation and F.Animation[1] then
                Entry.AAnimation = {F.Animation[1], F.Animation[2]}
            else
                Entry.AAnimation = {"walk", 0.1}
            end
            
            Entry.time = F.Time
            table.insert(Export, Entry)
        end
    end
    
    -- Rounding function (original 'es')
    local function Round(n) return math.floor(n * 1000 + 0.5) / 1000 end
    
    -- Apply rounding
    local FinalExport = {}
    for _, v in ipairs(Export) do
        local newV = {}
        for k, val in pairs(v) do
            if type(val) == "table" then
                local t = {}
                for _, n in ipairs(val) do
                    if type(n) == "number" then table.insert(t, Round(n)) else table.insert(t, n) end
                end
                newV[k] = t
            else
                newV[k] = Round(val)
            end
        end
        table.insert(FinalExport, newV)
    end
    
    if not isfolder("Flood-GUI/TAS FILES") then makefolder("Flood-GUI/TAS FILES") end
    writefile("Flood-GUI/TAS FILES/" .. MapName .. ".json", game:GetService("HttpService"):JSONEncode(FinalExport))
    NewAlert("Saved", Color3.fromRGB(0, 255, 0), 1)
end

-- // ROPE LISTENER //
task.spawn(function()
    local FE2Char = LocalPlayer.Character:WaitForChild("FE2_Character")
    local byte = getscriptbytecode(FE2Char)
    local evtName = string.match(byte, "GetPropertyChangedSignal%s+(%a+)%s+OnClientEvent")
    local evt = game:FindFirstChild(evtName, true)
    
    if evt then
        evt.OnClientEvent:Connect(function(val)
            if #val >= 1 then RopeTable = val end
        end)
    end
end)

-- // MAIN EXECUTION //
game.Workspace.Multiplayer:WaitForChild("NewMap", 9e99)
game.Workspace.Multiplayer:WaitForChild("Map", 9e99)

repeat task.wait() until LocalPlayer.Character.HumanoidRootPart.Anchored == false
SetupMap()

if not isfolder("TAS") then makefolder("TAS") end

local LastHeartbeat = tick()

-- Heartbeat Loop (eM)
RunService.Heartbeat:Connect(function()
    if not IsPaused then
        UpdateTime()
        table.insert(Frames, CaptureFrameData())
        if tick() - LastHeartbeat >= 2 then LastHeartbeat = tick() end
    else
        LastHeartbeat = tick()
    end
    task.spawn(UpdateSavestateCount)
    task.spawn(UpdateFrameCount)
end)

SaveRun() -- Initial save (from original)

-- Input Handling (eN)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe then
        local k = input.KeyCode.Name
        if k == Keybinds.UserPause then TogglePause()
        elseif k == Keybinds.AddSavestate then task.spawn(AddSavestate)
        elseif k == Keybinds.RemoveSavestate then task.spawn(RemoveSavestate)
        elseif k == Keybinds.BackSavestate then task.spawn(LoadLastSavestate)
        elseif k == Keybinds.CollisionToggler then ToggleCollision()
        elseif k == Keybinds.SaveRun then SaveRun()
        elseif k == Keybinds.GoFrameForward then task.spawn(StartFastForward)
        elseif k == Keybinds.GoFrameBack then task.spawn(StartRewind)
        elseif k == Keybinds.ResetToNormal then 
            -- Cleanup logic (original 'eO')
            CharConnection:Disconnect()
            ClonedMap:Destroy()
            UI_Elements.ScreenGui:Destroy()
            LocalPlayer.Character.Humanoid.Health = 0
        elseif k == Keybinds.ViewTAS then
            if not IsViewingTAS then
                AddSavestate()
                -- Flatten for viewing
                local Data = {}
                for i = 1, #Savestates do
                    for j = 1, #Savestates[i] do
                        local F = Savestates[i][j]
                        local Entry = {}
                        -- (Manual copying logic from original 'ViewTAS' block)
                        Entry.AAnimationChanged = F.Animation[2]
                        Entry.CCameraCFrame = {F.CameraCFrame.X, F.CameraCFrame.Y, F.CameraCFrame.Z, F.CameraCFrame:ToEulerAnglesXYZ()}
                        Entry.CCFrame = {F.CFrame.X, F.CFrame.Y, F.CFrame.Z, F.CFrame:ToEulerAnglesXYZ()}
                        Entry.AAnimation = F.Animation or {"walk", 0.1}
                        Entry.time = F.Time
                        table.insert(Data, Entry)
                    end
                end
                PlaybackTAS(Data)
            end
        end
    end
end)

-- Input Ended (for holding keys)
UserInputService.InputEnded:Connect(function(input, gpe)
    if not gpe then
        local k = input.KeyCode.Name
        if k == Keybinds.GoFrameBack then IsRewinding = false end
        if k == Keybinds.GoFrameForward then IsFastForwarding = false end
    end
end)

-- Death Handler (ee)
LocalPlayer.Character.Humanoid.Died:Connect(function()
    task.wait(0.1)
    if not IsPaused then TogglePause() end
    LocalPlayer.CharacterAdded:Wait()
    task.wait(0.1)
    LoadLastSavestate()
end)
