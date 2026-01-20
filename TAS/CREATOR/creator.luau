--[[
    FE2 TAS Creator (Build v64.03)
    - FIXED: UI nil index safety.
    - FIXED: Keybind 4 (Rewind) and Keybind 5 (Step-Forward) loops.
    - FIXED: Keybind execution safety (checks if Map is ready).
    - FIXED: View TAS now includes the current "active" frames.
    - SYNC: Animation and Physics logic synchronized with TAS Player.
]]

local UI_API_URL = "https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/main/TAS/CREATOR/uiapi.luau"

print("TAS Creator: Version v64.03 Initialized")

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

-- // SERVICES //
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- // STATE VARIABLES //
local CurrentAnim = {"idle", 0.1}
local Savestates = {}
local Frames = {}
local TimeOffset = 0
local IsPaused = true
local PauseStart = tick()
local OriginalPlayAnim
local AnimEnv
local RunStart = tick()
local SavedVelocity = Vector3.new(0, 0, 0)
local ButtonDebounce = false
local Connections = {} 
local IsRewinding = false
local IsFastForwarding = false
local MapReady = false

-- Recording Settings
local RecordAccumulator = 0
local TARGET_FPS = 60
local RECORD_INTERVAL = 1 / TARGET_FPS

-- Environment
getgenv().IsSwimming = false
local WaterParts = {}
local UI_Elements, TimeText, FrameCountLabel, StatusLabel
local MapOffset, MapPos, MapX, MapY, MapZ, ClonedMap, RopeTable

-- // ALERTS //
local NewAlert = nil
local function SetupAlerts()
    local GameScript = LocalPlayer.PlayerScripts:WaitForChild("CL_MAIN_GameScript", 5)
    if GameScript then
        local success, env = pcall(getsenv, GameScript)
        if success and env.newAlert then NewAlert = env.newAlert end
    end
end
SetupAlerts()

local function SendAlert(msg, color)
    if NewAlert then pcall(function() NewAlert(msg, color) end)
    else SetupAlerts() if NewAlert then pcall(function() NewAlert(msg, color) end) end end
end

-- // BYPASS //
local OldIndex
OldIndex = hookmetamethod(game, "__index", function(self, key)
    if not checkcaller() then
        if key == "Archivable" then return false end
        if getgenv().IsSwimming and key == "Position" and self.Name == "HumanoidRootPart" then
            return Vector3.new(-23, -153, 0)
        end
    end
    return OldIndex(self, key)
end)

local function Round(n) return math.floor(n * 1000 + 0.5) / 1000 end
local function AddConnection(con) table.insert(Connections, con) return con end

-- // CORE LOGIC //
local function GetPlayerCFrame()
    if not MapReady then return CFrame.new() end
    local Root = LocalPlayer.Character.HumanoidRootPart
    local x, y, z, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Root.CFrame:GetComponents()
    return CFrame.new(x - MapX, y - MapY + 1000, z - MapZ, R00, R01, R02, R10, R11, R12, R20, R21, R22)
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

local function UpdateTime()
    if not TimeText then return end
    local dp = tick() - RunStart - TimeOffset
    local m = math.floor(dp / 60)
    local s = math.floor(dp % 60)
    local ms = math.floor(dp * 1000 % 1000)
    TimeText.Text = string.format("%d:%02d.%03d", m, s, ms)
end

local function TogglePause()
    if not MapReady then return end
    IsPaused = not IsPaused
    local Root = LocalPlayer.Character.HumanoidRootPart
    if IsPaused then
        SavedVelocity = Root.Velocity
        Root.Anchored = true
        if TimeText then TimeText.TextColor3 = Color3.fromRGB(255, 255, 0) end
        PauseStart = tick()
        if StatusLabel then StatusLabel.Text = "CapsLock : Paused"; StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0) end
    else
        Root.Anchored = false
        Root.Velocity = SavedVelocity
        if TimeText then TimeText.TextColor3 = Color3.fromRGB(255, 255, 255) end
        TimeOffset = TimeOffset + (tick() - PauseStart)
        if StatusLabel then StatusLabel.Text = "CapsLock : Unpaused"; StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255) end
        RecordAccumulator = 0
    end
end

-- // KEY 4/5 LOGIC //
local function RewindFrame()
    if MapReady and IsPaused and #Frames > 1 then
        table.remove(Frames)
        local Frame = Frames[#Frames]
        local Root = LocalPlayer.Character.HumanoidRootPart
        Root.CFrame = Frame.CFrame + Vector3.new(MapX, MapY - 1000, MapZ)
        Root.Velocity = Frame.Velocity
        SavedVelocity = Frame.Velocity
        workspace.CurrentCamera.CFrame = Frame.CameraCFrame
        PauseStart = tick()
        RunStart = tick() - Frame.Time
        TimeOffset = 0
        UpdateTime()
    end
end

local function RewindLoop()
    while IsRewinding do RewindFrame(); task.wait(0.05) end
end

local function FastForwardLoop()
    while IsFastForwarding do
        if IsPaused then
            TogglePause()
            RunService.Heartbeat:Wait()
            TogglePause()
        end
        task.wait()
    end
end

-- // SAVESTATES //
local function LoadLastSavestate()
    if not MapReady then return end
    local LastState = Savestates[#Savestates]
    if LastState and #LastState > 0 then
        local Frame = LastState[#LastState]
        Frames = {}
        IsPaused = true
        local Root = LocalPlayer.Character.HumanoidRootPart
        Root.Anchored = true
        Root.CFrame = Frame.CFrame + Vector3.new(MapX, MapY - 1000, MapZ)
        Root.Velocity = Frame.Velocity
        SavedVelocity = Frame.Velocity
        workspace.CurrentCamera.CFrame = Frame.CameraCFrame
        PauseStart = tick()
        RunStart = tick() - Frame.Time
        TimeOffset = 0
        if OriginalPlayAnim then OriginalPlayAnim(Frame.Animation[1], Frame.Animation[2], LocalPlayer.Character.Humanoid) end
        UpdateTime()
    end
end

-- // PLAYBACK //
local IsViewingTAS = false
local function PlaybackTAS(Data)
    IsViewingTAS = true
    local Root = LocalPlayer.Character.HumanoidRootPart
    local Hum = LocalPlayer.Character.Humanoid
    local Offset = ClonedMap.PrimaryPart.Position - Vector3.new(0, 1000, 0)
    local idx = 1
    local PlayStart = tick()
    local LastPlayedAnim = ""
    
    local Con
    Con = RunService.Heartbeat:Connect(function()
        Root.Anchored = false
        if not IsPaused then TogglePause() end
        local Elapsed = tick() - PlayStart
        for i = idx, #Data do
            local F = Data[i]
            if Elapsed < F.time then break
            elseif i >= #Data then Con:Disconnect(); IsViewingTAS = false; Root.Anchored = true
            elseif Elapsed >= F.time then
                idx = i
                local cf = F.CCFrame
                local ccf = F.CCameraCFrame
                Root.CFrame = CFrame.new(cf[1], cf[2], cf[3]) * CFrame.fromEulerAnglesXYZ(cf[4], cf[5], cf[6]) + Offset
                workspace.CurrentCamera.CFrame = CFrame.new(ccf[1], ccf[2], ccf[3]) * CFrame.fromEulerAnglesXYZ(ccf[4], ccf[5], ccf[6]) + Offset
                Root.Velocity = Vector3.new(F.VVelocity[1], F.VVelocity[2], F.VVelocity[3])
                
                local animName = F.AAnimation[1]
                if Hum:GetState() == Enum.HumanoidStateType.Physics then animName = "swing" end
                if animName ~= LastPlayedAnim and OriginalPlayAnim then
                    OriginalPlayAnim(animName, F.AAnimation[2], Hum)
                    LastPlayedAnim = animName
                end
            end
        end
    end)
    AddConnection(Con)
end

-- // SAVE FUNCTION //
local function SaveRun()
    if not MapReady then return end
    local Export = {}
    -- Combine Savestates and current Frames
    local AllData = {}
    for _,chunk in ipairs(Savestates) do for _,f in ipairs(chunk) do table.insert(AllData, f) end end
    for _,f in ipairs(Frames) do table.insert(AllData, f) end

    for _,F in ipairs(AllData) do
        local rx, ry, rz = F.CFrame:ToEulerAnglesXYZ()
        local crx, cry, crz = F.CameraCFrame:ToEulerAnglesXYZ()
        table.insert(Export, {
            time = Round(F.Time),
            AAnimation = F.Animation or {"walk", 0.1},
            VVelocity = {Round(F.Velocity.X), Round(F.Velocity.Y), Round(F.Velocity.Z)},
            CCFrame = {Round(F.CFrame.X), Round(F.CFrame.Y), Round(F.CFrame.Z), Round(rx), Round(ry), Round(rz)},
            CCameraCFrame = {Round(F.CameraCFrame.X), Round(F.CameraCFrame.Y), Round(F.CameraCFrame.Z), Round(crx), Round(cry), Round(crz)}
        })
    end
    
    if not isfolder("Flood-GUI/TAS FILES") then makefolder("Flood-GUI/TAS FILES") end
    local Name = ClonedMap.Settings:GetAttribute("MapName") or "Unknown"
    writefile("Flood-GUI/TAS FILES/" .. Name .. ".json", game:GetService("HttpService"):JSONEncode(Export))
    SendAlert("Run Saved Successfully", Color3.new(0, 1, 0))
end

-- // INITIALIZATION //
local function HookAnimations()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local anim = char:WaitForChild("Animate")
    AnimEnv = getsenv(anim)
    OriginalPlayAnim = AnimEnv.playAnimation
    AnimEnv.playAnimation = function(anim, speed)
        if not IsPaused then CurrentAnim = {anim, speed}; OriginalPlayAnim(anim, speed, LocalPlayer.Character.Humanoid) end
    end
end

local function SetupMap()
    local Map = workspace.Multiplayer:WaitForChild("Map")
    ClonedMap = Map:Clone()
    ClonedMap.Parent = workspace
    MapPos = ClonedMap.PrimaryPart.Position
    MapX, MapY, MapZ = MapPos.X, MapPos.Y, MapPos.Z
    
    LocalPlayer.Character.Humanoid.Health = 0
    LocalPlayer.CharacterAdded:Wait()
    task.wait(1)
    
    HookAnimations()
    UI_Elements = TAS_UI.Create()
    TimeText, FrameCountLabel, StatusLabel = UI_Elements.TimeText, UI_Elements.FrameCount, UI_Elements.StatusText
    
    local Root = LocalPlayer.Character.HumanoidRootPart
    Root.CFrame = CFrame.new(MapPos) + Vector3.new(0, 5, 0)
    Root.Anchored = true
    
    MapReady = true
    table.insert(Savestates, {{CFrame = GetPlayerCFrame(), CameraCFrame = workspace.CurrentCamera.CFrame, Velocity = Vector3.new(0,0,0), Animation = {"idle", 0.1}, Time = 0}})
    workspace.Multiplayer.Map:Destroy()
    SendAlert("v64.03 Ready", Color3.new(0,1,0))
end

-- // LOOPS //
AddConnection(RunService.Heartbeat:Connect(function(dt)
    if not IsPaused and MapReady then
        UpdateTime()
        RecordAccumulator = RecordAccumulator + dt
        if RecordAccumulator >= RECORD_INTERVAL then
            RecordAccumulator = RecordAccumulator - RECORD_INTERVAL
            table.insert(Frames, CaptureFrameData())
        end
    end
    
    if UI_Elements then
        if UI_Elements.SavestatesCount then UI_Elements.SavestatesCount.Text = "Savestates " .. #Savestates end
        if FrameCountLabel then FrameCountLabel.Text = "Frames " .. #Frames end
    end
end))

AddConnection(UserInputService.InputBegan:Connect(function(i, g)
    if g or not MapReady then return end
    local k = i.KeyCode.Name
    if k == Keybinds.UserPause then TogglePause()
    elseif k == Keybinds.AddSavestate then SendAlert("Savestate Added", Color3.new(0,1,0)); table.insert(Savestates, Frames); Frames = {}
    elseif k == Keybinds.BackSavestate then task.spawn(LoadLastSavestate)
    elseif k == Keybinds.SaveRun then SaveRun()
    elseif k == Keybinds.GoFrameBack then IsRewinding = true; task.spawn(RewindLoop)
    elseif k == Keybinds.GoFrameForward then IsFastForwarding = true; task.spawn(FastForwardLoop)
    elseif k == Keybinds.ViewTAS and not IsViewingTAS then
        local Data = {}
        for _,chunk in ipairs(Savestates) do
            for _,f in ipairs(chunk) do
                local rx, ry, rz = f.CFrame:ToEulerAnglesXYZ()
                local crx, cry, crz = f.CameraCFrame:ToEulerAnglesXYZ()
                table.insert(Data, {time = Round(f.Time), AAnimation = f.Animation, VVelocity = {Round(f.Velocity.X), Round(f.Velocity.Y), Round(f.Velocity.Z)}, CCFrame = {Round(f.CFrame.X), Round(f.CFrame.Y), Round(f.CFrame.Z), Round(rx), Round(ry), Round(rz)}, CCameraCFrame = {Round(f.CameraCFrame.X), Round(f.CameraCFrame.Y), Round(f.CameraCFrame.Z), Round(crx), Round(cry), Round(crz)}})
            end
        end
        for _,f in ipairs(Frames) do
            local rx, ry, rz = f.CFrame:ToEulerAnglesXYZ()
            local crx, cry, crz = f.CameraCFrame:ToEulerAnglesXYZ()
            table.insert(Data, {time = Round(f.Time), AAnimation = f.Animation, VVelocity = {Round(f.Velocity.X), Round(f.Velocity.Y), Round(f.Velocity.Z)}, CCFrame = {Round(f.CFrame.X), Round(f.CFrame.Y), Round(f.CFrame.Z), Round(rx), Round(ry), Round(rz)}, CCameraCFrame = {Round(f.CameraCFrame.X), Round(f.CameraCFrame.Y), Round(f.CameraCFrame.Z), Round(crx), Round(cry), Round(crz)}})
        end
        PlaybackTAS(Data)
    end
end))

AddConnection(UserInputService.InputEnded:Connect(function(i, g)
    if i.KeyCode.Name == Keybinds.GoFrameBack then IsRewinding = false end
    if i.KeyCode.Name == Keybinds.GoFrameForward then IsFastForwarding = false end
end))

SetupMap()
