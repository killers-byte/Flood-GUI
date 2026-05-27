local TimeModifier = 1 -- [CONTROL SPEED HERE] (1 = Normal, 0.5 = 2x Speed, 2 = Slow Motion)
local SmoothnessFactor = 0.15 -- [ROTATION SMOOTHING] Lower = Smoother, Higher = Snappier (0.1-0.2 recommended)

print("Latest TAS Player built for V65 (Kinematic Smoothing & Pitch LERP + Auto-Queue)")

-- // GLOBAL CLEANUP //
if getgenv().TASConnections then
    for _, connection in pairs(getgenv().TASConnections) do
        if connection then connection:Disconnect() end
    end
end
getgenv().TASConnections = {}

local function AddConnection(conn)
    table.insert(getgenv().TASConnections, conn)
    return conn
end

-- // CONFIGURATION //
local SkipMirroredMaps = {
    ["Retro Coast"] = true, ["Zemblanity"] = true, ["Northern Mill"] = true,
    ["Mysterium"] = true, ["Decaying Silo"] = true, ["Active Volcanic Mines"] = true,
    ["Snowy Stronghold"] = true, ["Classic Canyon"] = true
}

if State and State().HighlightOnlyMaps then
    for _,v in ipairs(State().HighlightOnlyMaps) do SkipMirroredMaps[v] = true end
end

local Mirrored = false
local NewV = Vector3.new
local NewC = CFrame.new
local AngC = CFrame.fromEulerAnglesXYZ
local LP = game.Players.LocalPlayer
local Multi = workspace.Multiplayer
local RS = game:GetService('RunService')
local HttpService = game:GetService("HttpService")

-- // PROFESSIONAL ALERT SYSTEM //
local CLMAIN = getsenv(LP.PlayerScripts:WaitForChild("CL_MAIN_GameScript", 10))

local Theme = {
    System = Color3.fromRGB(150, 150, 255), 
    Info = Color3.fromRGB(220, 220, 220),   
    Success = Color3.fromRGB(80, 220, 120), 
    Warning = Color3.fromRGB(255, 170, 0),  
    Error = Color3.fromRGB(255, 60, 60),    
    Highlight = Color3.fromRGB(0, 200, 255) 
}

local function Log(msg, category)
    local color = Theme[category] or Theme.Info
    local text = "[TAS] " .. msg
    print(text)
    if CLMAIN and type(CLMAIN.newAlert) == "function" then
        CLMAIN.newAlert(text, color)
    end
end

if not getgenv().alreadystarted then
    Log("Engine initialized (v65)", "System")
    task.wait(0.1)
    Log("Smoothing Algorithm: Adaptive LERP enabled.", "System")
    task.wait(0.1)
    Log("Playback Speed: " .. TimeModifier .. "x", "Highlight")
    getgenv().alreadystarted = true
else
    Log("Engine re-hooked (v65)", "System")
    task.wait(0.15)
    Log("Playback Speed: " .. TimeModifier .. "x", "Highlight")
end

-- // FE2 WATER DETECTION SYSTEM //
local WaterParts = {}

local function CacheWaterParts(MapFolder)
    WaterParts = {}
    local attempts = 0
    repeat
        for _, v in pairs(MapFolder:GetDescendants()) do
            if v:IsA("BasePart") and (string.find(v.Name, "_Water") or v.Parent.Name == "Waters") then
                if not table.find(WaterParts, v) then
                    table.insert(WaterParts, v)
                end
            end
        end
        if #WaterParts == 0 then 
            attempts = attempts + 1
            task.wait(0.5) 
        end
    until #WaterParts > 0 or attempts > 10
    
    if #WaterParts > 0 then
        Log("Hydro-Volumes synchronized: " .. #WaterParts .. " detected.", "Success")
    else
        Log("Water detection failed.", "Error")
    end
end

local function IsInWater(Position)
    for _, water in pairs(WaterParts) do
        local halfSize = water.Size * 0.5
        local objSpace = water.CFrame:PointToObjectSpace(Position)
        if math.abs(objSpace.Y) <= halfSize.Y and math.abs(objSpace.X) <= halfSize.X and math.abs(objSpace.Z) <= halfSize.Z then
            local waterState = water:FindFirstChild("WaterState")
            if not waterState or waterState:GetAttribute("NoSwim") ~= true then
                return true
            end
        end
    end
    return false
end

-- // ANIMATION HELPERS //
if not LP.Character or not LP.Character:FindFirstChild("Animate") then
    LP.CharacterAdded:Wait()
    LP.Character:WaitForChild("Animate", 10)
end

local Animate, OriginalPlayAnim
local SuccessHook, Err = pcall(function()
    local AnimateScript = LP.Character.Animate
    Animate = getsenv(AnimateScript)
    OriginalPlayAnim = Animate.playAnimation
end)

if not SuccessHook or not Animate then
    Log("Animation hook failure.", "Warning")
    Animate = { setAnimationSpeed = function() end, playAnimation = function() end }
    OriginalPlayAnim = function() end
end

local function toggleSlide(newValue)
    if not LP.Character then return end
    if newValue == true then
        if LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.Size = NewV(2, 1, 1) end
        if LP.Character:FindFirstChild("FE2_Hitbox") then LP.Character.FE2_Hitbox.Size = NewV(2, 1, 1) end
        if LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.HipHeight = -1.5 end
    else
        if LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.Size = NewV(2, 2, 1) end
        if LP.Character:FindFirstChild("FE2_Hitbox") then LP.Character.FE2_Hitbox.Size = NewV(2, 2, 1) end
        if LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.HipHeight = 0 end
    end
    if LP.Character and LP.Character:FindFirstChild("Animate") and LP.Character.Animate:FindFirstChild("Sliding") then
        LP.Character.Animate.Sliding:Fire(newValue)
    end
end

getgenv().IsTASPlaying = true 
getgenv().TASCurrentMoveDir = Vector3.new(0,0,0) 

local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if getgenv().IsTASPlaying and key == "MoveDirection" then
        if self:IsA("Humanoid") and self.Parent == LP.Character then
            return getgenv().TASCurrentMoveDir
        end
    end
    return oldIndex(self, key)
end)

-- // CLEANUP & AUTO-QUEUE //
local LiftCheckPos = Vector3.new(-25, -144, 139)
local CleanedUp = false
local function Cleanup(resetCharacter)
    if CleanedUp then return end
    CleanedUp = true
    getgenv().IsTASPlaying = false
    
    if getgenv().TASConnections then
        for _, connection in pairs(getgenv().TASConnections) do
            if connection then connection:Disconnect() end
        end
        getgenv().TASConnections = {}
    end

    if Animate and OriginalPlayAnim then 
        if LP.Character and LP.Character:FindFirstChild("Humanoid") and LP.Character.Humanoid.Health > 0 then
            Animate.playAnimation = OriginalPlayAnim 
            if LP.Character.Animate:FindFirstChild("ToggleSwim") then
                LP.Character.Animate.ToggleSwim:Fire(false)
            end
        end
    end

    if LP.Character then
        if LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.AutoRotate = true end
        toggleSlide(false)
    end

    if resetCharacter and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        Log("Re-initializing session...", "Error")
        LP.Character.Humanoid.Health = 0
        
        -- [AUTO-QUEUE FIX INTEGRATION]
        task.spawn(function()
            local newChar = LP.CharacterAdded:Wait()
            local newRoot = newChar:WaitForChild("HumanoidRootPart", 10)
            local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("AddedWaiting")
            
            while newChar and newChar.Parent and newRoot do
                local dist = (newRoot.Position - LiftCheckPos).Magnitude
                if dist <= 30 then
                    print("TAS: Player entered lift. Stopping queue spam.")
                    break
                end
                
                Remote:FireServer()
                task.wait(0.5)
            end
        end)
    end
end

if LP.Character and LP.Character:FindFirstChild("Humanoid") then
    AddConnection(LP.Character.Humanoid.Died:Connect(function() Cleanup(false) end))
end

-- // SMART START LOGIC //
local Map = nil

while not Map and not CleanedUp do
    local ConditionsMet = false
    Log("Awaiting queue entry...", "Warning")
    repeat
        task.wait(0.2)
        local Root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if Root then
            local Dist = (Root.Position - LiftCheckPos).Magnitude
            if Dist <= 30 or Dist > 800 then ConditionsMet = true end
        end
    until ConditionsMet or CleanedUp
    
    if CleanedUp then return end
    Log("Queue confirmed. Awaiting map data...", "System")
    
    while ConditionsMet and not CleanedUp do
        local FoundMap = Multi:FindFirstChild("NewMap")
        if FoundMap then Map = FoundMap; break end
        task.wait(0.1)
    end
end

if CleanedUp or not Map then return end

-- // TAS EXECUTION //
local realMapName = Map:WaitForChild('Settings'):GetAttribute("MapName")
local mapName = HttpService:UrlEncode(realMapName)

local success, path
if isfolder("Flood-GUI") and isfolder("Flood-GUI/TAS FILES") then
    local TargetTASPath = "Flood-GUI/TAS FILES/" .. realMapName .. ".json"
    if isfile(TargetTASPath) then path = readfile(TargetTASPath); success = true end
end

if not path then
    success, path = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/testing/TAS%20FILES/".. mapName .. ".json")
    end)
end

if not success or #path < 50 then
    Log("Download failed: No data for '".. realMapName .."'.", "Error")
    Cleanup(true)
    return
end

local TAS
local DecodeSuccess, _ = pcall(function() TAS = HttpService:JSONDecode(path) end)
if not TAS or not DecodeSuccess then
    Log("Parse error: Corrupted JSON.", "Error")
    Cleanup(true)
    return
end

if TimeModifier ~= 1 then
    for _, Frame in ipairs(TAS) do
        if Frame.time then Frame.time = Frame.time * TimeModifier end
    end
end

local OriginalFrameCount = #TAS
Log(string.format("Data validated: %d Frames loaded.", OriginalFrameCount), "Info")
repeat task.wait() until Map.Name == "Map" or CleanedUp
if CleanedUp then return end

local SpawnPoint = nil
for _,v in ipairs(Map:GetChildren()) do
    if v.Name == "Part" then
        local c; c = v:GetPropertyChangedSignal("Rotation"):Connect(function() c:Disconnect(); SpawnPoint = v end)
    end
end

local t = 0
repeat task.wait(0.1); t=t+0.1; if not SpawnPoint then SpawnPoint = Map:FindFirstChild("Spawn", true) end
until SpawnPoint or t > 10 or CleanedUp

if not SpawnPoint then Log("Failed to resolve map spawn.", "Error") Cleanup(true) return end

-- // MAP PRE-PROCESSING //
CacheWaterParts(Map)

-- [HITBOX EXPANDER]
for _, v in next, Map:GetDescendants() do
    if v.Name == 'ButtonIcon' then
        pcall(function()
            local p = v.Parent.Parent:FindFirstChildOfClass('Part')
            if p then p.Size = NewV(7, 7, 7) p.Transparency = 1 end
        end)
    end
end
Log("Map volumes processed.", "Success")

task.wait(0.1)
Log("Executing playback...", "Success")

local RootPart = LP.Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = LP.Character:WaitForChild("Humanoid", 10)

while (RootPart.Anchored == true) or (Humanoid.WalkSpeed <= 0) do
    if CleanedUp then return end
    task.wait()
end

local TimeStart = os.clock()
if LP.Character and LP.Character:FindFirstChild("Humanoid") then
    LP.Character.Humanoid.AutoRotate = false
end

Animate.playAnimation = function() end

local LastPlayedAnim = nil
local IsSliding = false
local LastSlideTime = 0
local MinSlideTime = 0.3
local IsCurrentlySwimming = false

local function activateAnimation(AnimData, Elapsed)
    if not AnimData then return end
    local character = LP.Character
    if not character or not character.Parent then return end
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChild("Humanoid")
    if not head or not humanoid or not RootPart then return end

    local n = AnimData[1]
    local animTime = AnimData[2] or 0.1
    Elapsed = Elapsed or 0

    -- // WATER LOGIC //
    local checkSubmerged = IsInWater(RootPart.Position + Vector3.new(0, 1, 0))
    if checkSubmerged then
        IsCurrentlySwimming = true
        if RootPart.Velocity.Magnitude > 1.5 then n = "swim" else n = "swimidle" end
        if character.Animate:FindFirstChild("ToggleSwim") then
            pcall(function() character.Animate.ToggleSwim:Fire(true) end)
        end
    else
        IsCurrentlySwimming = false
        if character.Animate:FindFirstChild("ToggleSwim") then
            pcall(function() character.Animate.ToggleSwim:Fire(false) end)
        end
        if humanoid:GetState() == Enum.HumanoidStateType.Physics then n = "swing" end
        if n == "idle" then
            if RootPart.Velocity.Magnitude > 1 then
                if humanoid.FloorMaterial ~= Enum.Material.Air then n = "walk" else n = "fall" end
            end
        end
        if n == "fall" and RootPart.Velocity.Magnitude < 0.1 then n = "swing" end
        if n == "slide" then
            if not IsSliding then toggleSlide(true) IsSliding = true LastSlideTime = Elapsed end
        elseif IsSliding then
            if (Elapsed - LastSlideTime >= MinSlideTime) or n == "swing" or n == "fall" or n == "zipline" then
                toggleSlide(false) IsSliding = false
            else n = "slide" end
        end
    end

    if n and (n ~= LastPlayedAnim) then
        Animate.playAnimation = function() end
        pcall(function() OriginalPlayAnim(n, animTime, humanoid) end)
        if n == "walk" then pcall(function() Animate.setAnimationSpeed(.76) end) end
        LastPlayedAnim = n
    end
end

local Offset = SpawnPoint.Position - NewV(0, 1000, 0)
local OldFrame = 3
local RenderedFrames = 0
local FinishedRun = false

-- // PHYSICS LOOP //
local MainLoop
MainLoop = RS.Heartbeat:Connect(function()
    if not RootPart or not RootPart.Parent or not Humanoid or not Humanoid.Parent or CleanedUp then 
        if MainLoop then MainLoop:Disconnect() end
        return 
    end
    
    RenderedFrames = RenderedFrames + 1
    local Elapsed = os.clock() - TimeStart
    
    -- [WALLJUMP BLOCKER]
    local liveWeld = RootPart:FindFirstChild("WalljumpWeld_Live")
    if liveWeld then liveWeld:Destroy() end
    local serverWeld = RootPart:FindFirstChild("WalljumpWeld_Server")
    if serverWeld then serverWeld:Destroy() end

    Humanoid.Health = 99999
    
    while OldFrame < #TAS and TAS[OldFrame + 1].time <= Elapsed do OldFrame = OldFrame + 1 end
    if OldFrame >= #TAS then
        if not FinishedRun then
            FinishedRun = true
            Log("Playback successfully concluded.", "Success")
            if Animate and OriginalPlayAnim then
                 Animate.playAnimation = OriginalPlayAnim
                 pcall(function() OriginalPlayAnim("idle", 0.1, Humanoid) end)
            end
            Cleanup(false) 
        end
        return
    end

    local FA = TAS[OldFrame]
    local FB = TAS[OldFrame + 1] or FA
    
    -- // KINEMATIC INTERPOLATION //
    local Dur = FB.time - FA.time
    local Alpha = (Dur > 0) and math.clamp((Elapsed - FA.time) / Dur, 0, 1) or 0

    local cfA = NewC(FA.CCFrame[1], FA.CCFrame[2], FA.CCFrame[3]) * AngC(FA.CCFrame[4], FA.CCFrame[5], FA.CCFrame[6])
    local cfB = NewC(FB.CCFrame[1], FB.CCFrame[2], FB.CCFrame[3]) * AngC(FB.CCFrame[4], FB.CCFrame[5], FB.CCFrame[6])
    local vA = NewV(FA.VVelocity[1], FA.VVelocity[2], FA.VVelocity[3])
    local vB = NewV(FB.VVelocity[1], FB.VVelocity[2], FB.VVelocity[3])

    local TargetVelocity = vA:Lerp(vB, Alpha)
    getgenv().TASCurrentMoveDir = TargetVelocity.Magnitude > 0 and TargetVelocity.Unit or Vector3.zero

    -- // ADVANCED ROTATION LERP & PITCH //
    local TargetCFrame = cfA:Lerp(cfB, Alpha) + Offset
    
    if IsCurrentlySwimming and TargetVelocity.Magnitude > 0.5 then
        local LookAtCFrame = NewC(TargetCFrame.Position, TargetCFrame.Position + TargetVelocity.Unit)
        RootPart.CFrame = RootPart.CFrame:Lerp(LookAtCFrame, SmoothnessFactor)
    else
        RootPart.CFrame = TargetCFrame
    end
    
    RootPart.Velocity = TargetVelocity
    pcall(activateAnimation, FA.AAnimation, Elapsed)
end)
AddConnection(MainLoop)
