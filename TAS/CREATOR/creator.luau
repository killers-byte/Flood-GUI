--[[
    FE2 TAS Creator (UpdRopeData + Playback Fix)
    - Syncs "View TAS" animation logic with TAS Player (Zipline Swing Fix).
    - Added Velocity application to local playback.
    - Synchronized data precision (Rounding) between Preview and Save.
]]

local UI_API_URL = "https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/main/TAS/CREATOR/uiapi.luau"

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

-- // SERVICES //
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- // ALERT SYSTEM SETUP //
local NewAlert = nil
local function SetupAlerts()
    local GameScript = LocalPlayer.PlayerScripts:WaitForChild("CL_MAIN_GameScript", 5)
    if GameScript then
        local success, env = pcall(getsenv, GameScript)
        if success and env.newAlert then
            NewAlert = env.newAlert
        end
    end
end
SetupAlerts()

local function SendAlert(msg, color)
    if NewAlert then
        pcall(function() NewAlert(msg, color) end)
    else
        SetupAlerts()
        if NewAlert then pcall(function() NewAlert(msg, color) end) end
    end
end

SendAlert("TAS Creator Initialized", Color3.fromRGB(183, 0, 255))

-- // BYPASSES //
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

-- // HANDSHAKE //
pcall(function()
    ReplicatedStorage.Remote.ReqPasskey:InvokeServer()
end)

-- // VARIABLES //
local CurrentAnim = {"idle", 0.1}
local Savestates = {}
local Frames = {}
local TimeOffset = 0
local IsPaused = true
local PauseStart
local OriginalPlayAnim
local AnimEnv
local RunStart
local SavedVelocity = Vector3.new(0, 0, 0)
local ButtonDebounce = false
local Connections = {} 

-- Recording Cap Variables
local RecordAccumulator = 0
local TARGET_FPS = 60
local RECORD_INTERVAL = 1 / TARGET_FPS

-- Auto-Swim Global
getgenv().IsSwimming = false
local WaterParts = {}

-- UI Variables
local TAS_UI = loadstring(game:HttpGet(UI_API_URL))()
local UI_Elements, TimeText, FrameCountLabel, StatusLabel

-- Map Variables
local MapOffset, MapPos, MapX, MapY, MapZ, ClonedMap, RopeTable

-- // HELPER FUNCTIONS //

local function Round(n) return math.floor(n * 1000 + 0.5) / 1000 end

local function AddConnection(con)
    table.insert(Connections, con)
    return con
end

local function ToggleCollision()
    local mouse = LocalPlayer:GetMouse()
    if mouse and mouse.Target then
        local target = mouse.Target
        target.CanCollide = not target.CanCollide
        target.Transparency = target.CanCollide and 0 or 0.8
    end
end

local function IsPointInPart(part, point)
    local rel = part.CFrame:PointToObjectSpace(point)
    local halfSize = part.Size / 2
    return math.abs(rel.X) <= halfSize.X and 
           math.abs(rel.Y) <= halfSize.Y and 
           math.abs(rel.Z) <= halfSize.Z
end

local function GetPlayerCFrame()
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

local function LoadUI()
    UI_Elements = TAS_UI.Create()
    TimeText = UI_Elements.TimeText
    FrameCountLabel = UI_Elements.FrameCount
    StatusLabel = UI_Elements.StatusText
end

local function UpdateTime()
    local dp = tick() - RunStart - TimeOffset
    local m = math.floor(dp / 60)
    local s = math.floor(dp % 60)
    local ms = math.floor(dp * 1000 % 1000)
    TimeText.Text = string.format("%d:%02d.%03d", m, s, ms)
end

local function HookAnimations()
    repeat
        local script = LocalPlayer.Character:WaitForChild("Animate")
        AnimEnv = getsenv(script)
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

-- // CLEANUP FUNCTION //
local function ResetToNormal()
    for _, con in pairs(Connections) do con:Disconnect() end
    Connections = {}
    if ClonedMap then ClonedMap:Destroy() end
    if UI_Elements and UI_Elements.ScreenGui then UI_Elements.ScreenGui:Destroy() end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Anchored = false
    end
    SendAlert("TAS Creator Stopped", Color3.fromRGB(255, 0, 0))
end

-- // CORE LOGIC //
local function TogglePause()
    IsPaused = not IsPaused
    local Root = LocalPlayer.Character.HumanoidRootPart
    if IsPaused then
        SavedVelocity = Root.Velocity
        Root.Anchored = true
        TimeText.TextColor3 = Color3.fromRGB(255, 255, 0)
        PauseStart = tick()
        StatusLabel.Text = "CapsLock : Paused"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    else
        Root.Anchored = false
        Root.Velocity = SavedVelocity
        TimeText.TextColor3 = Color3.fromRGB(255, 255, 255)
        TimeOffset = TimeOffset + tick() - PauseStart
        StatusLabel.Text = "CapsLock : Unpaused"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        RecordAccumulator = 0
    end
end

local function LoadLastSavestate()
    local LastState = Savestates[#Savestates]
    if LastState then
        local Frame = LastState[#LastState]
        if not Frame then return end
        Frames = {}
        IsPaused = true
        local Root = LocalPlayer.Character.HumanoidRootPart
        Root.Anchored = true
        TimeText.TextColor3 = Color3.fromRGB(255, 255, 0)
        Root.CFrame = Frame.CFrame + Vector3.new(MapX, MapY - 1000, MapZ)
        Root.Velocity = Frame.Velocity
        SavedVelocity = Frame.Velocity
        workspace.CurrentCamera.CFrame = Frame.CameraCFrame
        PauseStart = tick()
        RunStart = tick() - Frame.Time
        TimeOffset = 0
        OriginalPlayAnim(Frame.Animation[1], Frame.Animation[2], LocalPlayer.Character.Humanoid)
        if Frame.Animation[1] == "walk" then AnimEnv.setAnimationSpeed(0.76) end
        task.spawn(UpdateTime)
    end
end

local function AddSavestate()
    SendAlert("Added Savestate", Color3.fromRGB(0, 255, 0))
    table.insert(Savestates, Frames)
    Frames = {}
end

local RemoveConfirm = false
local RemoveConfirmTime = 0
local function RemoveSavestate()
    if not RemoveConfirm or (tick() - RemoveConfirmTime > 2) then
        RemoveConfirm = true
        RemoveConfirmTime = tick()
        SendAlert("Press again to remove savestate", Color3.fromRGB(255, 170, 0))
        return
    end
    RemoveConfirm = false
    if #Savestates > 1 then
        SendAlert("Removed Savestate", Color3.fromRGB(255, 0, 0))
        table.remove(Savestates)
        task.spawn(LoadLastSavestate)
    else
        SendAlert("No Savestate to remove", Color3.fromRGB(255, 0, 0))
    end
end

local function SetupMap()
    local MP = game.Workspace.Multiplayer
    local Map = MP:WaitForChild("Map")
    local Spawn = Map:FindFirstChild("Spawn", true)
    if not Spawn then
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
    else
        Map.PrimaryPart = Spawn
    end

    for _, desc in pairs(Map:GetDescendants()) do desc.Archivable = true end
    ClonedMap = Map:Clone()
    if workspace:FindFirstChild("Map") then workspace.Map:Destroy() end
    ClonedMap.Parent = workspace
    
    MapPos = ClonedMap.PrimaryPart.Position
    MapX, MapY, MapZ = MapPos.X, MapPos.Y, MapPos.Z
    MapOffset = CFrame.new(MapX, MapY, MapZ)
    
    local Char = LocalPlayer.Character
    if Char and Char:FindFirstChild("Humanoid") then
        Char.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        Char.Humanoid.Health = 0
    end
    
    LocalPlayer.CharacterAdded:Wait()
    Char = LocalPlayer.Character
    task.wait(1)
    
    local FE2Env = getsenv(Char:WaitForChild("FE2_Character"))
    local startZipline = FE2Env.startZipline
    if RopeTable and #RopeTable >= 1 then
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
    Root.CFrame = CFrame.new(ClonedMap.PrimaryPart.Position) + Vector3.new(0, ClonedMap.PrimaryPart.Size.Y/2 + Root.Size.Y/2 + Char["Left Leg"].Size.Y, 0)
    task.wait(0.5)
    Root.Anchored = true
    Hum.WalkSpeed = 20
    Hum.JumpPower = 50
    
    table.insert(Savestates, {{
        CFrame = GetPlayerCFrame(),
        CameraCFrame = workspace.CurrentCamera.CFrame,
        Velocity = Vector3.new(0,0,0),
        Animation = {"idle", 0.1},
        Time = 0
    }})
    
    LoadUI()
    PauseStart = tick()
    RunStart = tick()
    HookAnimations()
    
    AddConnection(LocalPlayer.CharacterAdded:Connect(function(c)
        local anim = c:WaitForChild("Animate")
        if anim.Enabled then HookAnimations() end
    end))
    
    WaterParts = {}
    for _, obj in ipairs(ClonedMap:GetDescendants()) do
        if obj:IsA("BasePart") then
             if obj.Name:find("_Water") then table.insert(WaterParts, obj) end
             if not obj.CanCollide then obj.Transparency = 0.8 end
             if obj.Name:lower():match("button") or (obj.Parent and obj.Parent.Name:lower():match("button")) then
                 local sel = Instance.new("SelectionBox", obj)
                 sel.Adornee = obj
                 sel.Color3 = Color3.fromRGB(255, 140, 0)
                 AddConnection(obj.Touched:Connect(function()
                     if not ButtonDebounce then
                         SendAlert("Button Touched!", Color3.fromRGB(255, 140, 0))
                         ButtonDebounce = true
                         task.wait(1)
                         ButtonDebounce = false
                     end
                 end))
             end
        end
    end
    if MP:FindFirstChild("Map") then MP.Map:Destroy() end
    SendAlert("Map Ready", Color3.fromRGB(0, 255, 0))
end

-- // VIEW TAS //
local IsViewingTAS = false
local function PlaybackTAS(Data)
    IsViewingTAS = true
    local Root = LocalPlayer.Character.HumanoidRootPart
    local Hum = LocalPlayer.Character.Humanoid
    local Cam = workspace.CurrentCamera
    local LastPlayedAnim = ""
    local Offset = ClonedMap.PrimaryPart.Position - Vector3.new(0, 1000, 0)
    local idx = 1
    local PlayStart = tick()
    
    local function PlayAnim(anim)
        local animName = anim[1]
        -- [FIX] Sync with Player's zipline detection logic
        if Hum:GetState() == Enum.HumanoidStateType.Physics then
            animName = "swing"
        end

        if animName ~= LastPlayedAnim then
            OriginalPlayAnim(animName, anim[2], Hum)
            if animName == "walk" then AnimEnv.setAnimationSpeed(0.76) end
            LastPlayedAnim = animName
        end
    end

    local Con
    Con = RunService.Heartbeat:Connect(function()
        Root.Anchored = false
        Hum.Jump = true
        if not IsPaused then TogglePause() end
        
        local Elapsed = tick() - PlayStart
        for i = idx, #Data do
            local Frame = Data[i]
            if Elapsed < Frame.time then break
            elseif i >= #Data then
                Root.Anchored = true
                Con:Disconnect()
                IsViewingTAS = false
                SendAlert("Playback Finished", Color3.fromRGB(0, 255, 0))
            elseif Elapsed >= Frame.time then
                idx = i
                local cf = Frame.CCFrame
                local ccf = Frame.CCameraCFrame
                local vel = Frame.VVelocity
                
                -- Apply Position and Rotation
                Root.CFrame = CFrame.new(cf[1], cf[2], cf[3]) * CFrame.fromEulerAnglesXYZ(cf[4], cf[5], cf[6]) + Offset
                Cam.CFrame = CFrame.new(ccf[1], ccf[2], ccf[3]) * CFrame.fromEulerAnglesXYZ(ccf[4], ccf[5], ccf[6]) + Offset
                
                -- [FIX] Apply Velocity to local preview
                Root.Velocity = Vector3.new(vel[1], vel[2], vel[3])
                
                PlayAnim(Frame.AAnimation)
            end
        end
    end)
    AddConnection(Con)
end

-- // SAVE RUN //
local function SaveRun()
    local Export = {}
    for i = 1, #Savestates do
        for j = 1, #Savestates[i] do
            local F = Savestates[i][j]
            local rx, ry, rz = F.CFrame:ToEulerAnglesXYZ()
            local crx, cry, crz = F.CameraCFrame:ToEulerAnglesXYZ()
            table.insert(Export, {
                time = Round(F.Time),
                AAnimation = F.Animation or {"walk", 0.1},
                AAnimationChanged = F.Animation[2],
                VVelocity = {Round(F.Velocity.X), Round(F.Velocity.Y), Round(F.Velocity.Z)},
                CCFrame = {Round(F.CFrame.X), Round(F.CFrame.Y), Round(F.CFrame.Z), Round(rx), Round(ry), Round(rz)},
                CCameraCFrame = {Round(F.CameraCFrame.X), Round(F.CameraCFrame.Y), Round(F.CameraCFrame.Z), Round(crx), Round(cry), Round(crz)}
            })
        end
    end
    if not isfolder("Flood-GUI/TAS FILES") then makefolder("Flood-GUI/TAS FILES") end
    writefile("Flood-GUI/TAS FILES/" .. ClonedMap.Settings:GetAttribute("MapName") .. ".json", game:GetService("HttpService"):JSONEncode(Export))
    SendAlert("Saved to Workspace", Color3.fromRGB(0, 255, 0))
end

-- // MAIN EXECUTION //
task.spawn(function()
    local RopeEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("UpdRopeData")
    RopeEvent.OnClientEvent:Connect(function(val) if type(val) == "table" then RopeTable = val end end)
end)

workspace.Multiplayer:WaitForChild("Map", 9e99)
repeat task.wait() until LocalPlayer.Character.HumanoidRootPart.Anchored == false
SetupMap()

AddConnection(RunService.Heartbeat:Connect(function(dt)
    if not IsPaused then
        UpdateTime()
        RecordAccumulator = RecordAccumulator + dt
        if RecordAccumulator >= RECORD_INTERVAL then
            RecordAccumulator = RecordAccumulator - RECORD_INTERVAL
            table.insert(Frames, CaptureFrameData())
        end
    end
    
    local PlayerPos = LocalPlayer.Character.HumanoidRootPart.Position
    local InWater = false
    if not (CurrentAnim and CurrentAnim[1] == "slide") then
        for _, wp in ipairs(WaterParts) do if IsPointInPart(wp, PlayerPos) then InWater = true break end end
    end
    getgenv().IsSwimming = InWater
    
    UI_Elements.SavestatesCount.Text = "Savestates " .. #Savestates
    FrameCountLabel.Text = "Frames " .. #Frames
end))

AddConnection(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local k = input.KeyCode.Name
    if k == Keybinds.UserPause then TogglePause()
    elseif k == Keybinds.AddSavestate then AddSavestate()
    elseif k == Keybinds.RemoveSavestate then RemoveSavestate()
    elseif k == Keybinds.BackSavestate then task.spawn(LoadLastSavestate)
    elseif k == Keybinds.CollisionToggler then ToggleCollision()
    elseif k == Keybinds.SaveRun then SaveRun()
    elseif k == Keybinds.ResetToNormal then task.spawn(ResetToNormal)
    elseif k == Keybinds.ViewTAS and not IsViewingTAS then
        AddSavestate()
        local Data = {}
        for i = 1, #Savestates do
            for j = 1, #Savestates[i] do
                local F = Savestates[i][j]
                local rx, ry, rz = F.CFrame:ToEulerAnglesXYZ()
                local crx, cry, crz = F.CameraCFrame:ToEulerAnglesXYZ()
                -- [FIX] Map local preview data EXACTLY as the SaveRun structure (WYSIWYG)
                table.insert(Data, {
                    time = Round(F.Time),
                    AAnimation = F.Animation or {"walk", 0.1},
                    VVelocity = {Round(F.Velocity.X), Round(F.Velocity.Y), Round(F.Velocity.Z)},
                    CCFrame = {Round(F.CFrame.X), Round(F.CFrame.Y), Round(F.CFrame.Z), Round(rx), Round(ry), Round(rz)},
                    CCameraCFrame = {Round(F.CameraCFrame.X), Round(F.CameraCFrame.Y), Round(F.CameraCFrame.Z), Round(crx), Round(cry), Round(crz)}
                })
            end
        end
        PlaybackTAS(Data)
    end
end))

AddConnection(LocalPlayer.Character.Humanoid.Died:Connect(function()
    task.wait(0.1)
    if not IsPaused then TogglePause() end
    LocalPlayer.CharacterAdded:Wait()
    if ClonedMap and ClonedMap.Parent then LoadLastSavestate() end
end))

AddConnection(workspace.Multiplayer.ChildAdded:Connect(function(c) if ClonedMap and (c.Name == "Map" or c.Name == "NewMap") then task.wait() c:Destroy() end end))
