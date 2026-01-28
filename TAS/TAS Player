local TimeModifier = 1 -- [CONTROL SPEED HERE] (1 = Normal, 0.5 = 2x Speed, 2 = Slow Motion)

print("Latest TAS Player built for V64.03 (Auto-Queue Fix)")

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

-- // ALERTS //
local CLMAIN = getsenv(LP.PlayerScripts.CL_MAIN_GameScript)
local Alert = CLMAIN.newAlert or print

Alert("TAS Player: Speed " .. TimeModifier .. "x", Color3.new(1, 1, 1))

if not getgenv().alreadystarted then
    Alert("TAS Player Started.", Color3.fromRGB(255, 149, 5))
    getgenv().alreadystarted = true
else
    Alert("TAS Player ready.", Color3.new(0,1,.5))
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
    warn("TAS Warning: Could not hook Animate script. Animations may rely on fallbacks.")
    Animate = { setAnimationSpeed = function() end, playAnimation = function() end }
    OriginalPlayAnim = function() end
end

local function toggleSlide(newValue)
    if not LP.Character then return end
    
    if newValue == true then
        if LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.Size = NewV(2, 1, 1)
        end
        if LP.Character:FindFirstChild("FE2_Hitbox") then
            LP.Character.FE2_Hitbox.Size = NewV(2, 1, 1)
        end
        if LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.HipHeight = -1.5
        end
    else
        if LP.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.Size = NewV(2, 2, 1)
        end
        if LP.Character:FindFirstChild("FE2_Hitbox") then
            LP.Character.FE2_Hitbox.Size = NewV(2, 2, 1)
        end
        if LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.HipHeight = 0
        end
    end

    if LP.Character and LP.Character:FindFirstChild("Animate") and LP.Character.Animate:FindFirstChild("Sliding") then
        LP.Character.Animate.Sliding:Fire(newValue)
    end
end

-- // SPOOFING VARIABLES //
getgenv().IsTASPlaying = true 
getgenv().TASCurrentMoveDir = Vector3.new(0,0,0) 

-- // HOOK METAMETHOD //
local oldIndex
oldIndex = hookmetamethod(game, "__index", function(self, key)
    if getgenv().IsTASPlaying and key == "MoveDirection" then
        if self:IsA("Humanoid") and self.Parent == LP.Character then
            return getgenv().TASCurrentMoveDir
        end
    end
    return oldIndex(self, key)
end)

-- // CLEANUP //
local CleanedUp = false
local function Cleanup(resetCharacter)
    if CleanedUp then return end
    CleanedUp = true
    getgenv().IsTASPlaying = false
    print("Cleaning Up...")
    
    if getgenv().TASConnections then
        for _, connection in pairs(getgenv().TASConnections) do
            if connection then connection:Disconnect() end
        end
        getgenv().TASConnections = {}
    end

    if Animate and OriginalPlayAnim then Animate.playAnimation = OriginalPlayAnim end

    if LP.Character then
        if LP.Character:FindFirstChild("Humanoid") then
            LP.Character.Humanoid.AutoRotate = true
        end
        toggleSlide(false)
    end

    if resetCharacter and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        Alert("Error/Resetting...", Color3.new(1, 0, 0))
        LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        LP.Character.Humanoid.Health = 0
        
        -- [AUTO-QUEUE FIX]
        task.spawn(function()
            local newChar = LP.CharacterAdded:Wait()
            local newRoot = newChar:WaitForChild("HumanoidRootPart", 10)
            local LiftPos = Vector3.new(-25, -144, 139)
            local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("AddedWaiting")
            
            -- Keep firing AddedWaiting until we are physically inside the lift
            while newChar and newChar.Parent and newRoot do
                local dist = (newRoot.Position - LiftPos).Magnitude
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
local LiftCheckPos = Vector3.new(-25, -144, 139)
local Map = nil

while not Map and not CleanedUp do
    local ConditionsMet = false
    Alert("Waiting for Player in Lift...", Color3.fromRGB(255, 255, 0))
    
    repeat
        task.wait(0.2)
        local Root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if Root then
            local Dist = (Root.Position - LiftCheckPos).Magnitude
            if Dist <= 30 or Dist > 800 then ConditionsMet = true end
        end
    until ConditionsMet or CleanedUp
    
    if CleanedUp then return end

    Alert("Ready! Waiting for NewMap...", Color3.fromRGB(0, 255, 255))
    
    while ConditionsMet and not CleanedUp do
        local Root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if Root then
            local Dist = (Root.Position - LiftCheckPos).Magnitude
            if Dist > 30 and Dist <= 800 then
                ConditionsMet = false
                Alert("Left Zone - Pausing...", Color3.fromRGB(255, 100, 0))
                break
            end
        end
        
        local FoundMap = Multi:FindFirstChild("NewMap")
        if FoundMap then Map = FoundMap; break end
        task.wait(0.1)
    end
end

if CleanedUp or not Map then return end

-- // TAS EXECUTION //
local realMapName = Map:WaitForChild('Settings'):GetAttribute("MapName")
local mapName = HttpService:UrlEncode(realMapName)
print("Map Detected:", realMapName)

local success, path
if isfolder("Flood-GUI") and isfolder("Flood-GUI/TAS FILES") then
    local TargetTASPath = "Flood-GUI/TAS FILES/" .. realMapName .. ".json"
    if isfile(TargetTASPath) then path = readfile(TargetTASPath); success = true end
end

if not path then
    success, path = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/main/TAS%20FILES/".. mapName .. ".json")
    end)
end

if not success or #path < 50 then
    print("TAS MISSING")
    Alert("TAS Missing/Download Failed!", Color3.new(1,0,0))
    Cleanup(true)
    return
end

local TAS
local DecodeSuccess, _ = pcall(function() TAS = HttpService:JSONDecode(path) end)

if not TAS or not DecodeSuccess then
    Alert("TAS file corrupt!", Color3.new(1,0,0))
    Cleanup(true)
    return
end

-- // SPEED MODIFIER //
if TimeModifier ~= 1 then
    for _, Frame in ipairs(TAS) do
        if Frame.time then Frame.time = Frame.time * TimeModifier end
    end
end

local OriginalFrameCount = #TAS
Alert("TAS Loaded: " .. OriginalFrameCount .. " Frames", Color3.new(0,1,1))
repeat task.wait() until Map.Name == "Map" or CleanedUp
if CleanedUp then return end

local Settings = Map:WaitForChild('Settings')
if Settings:GetAttribute("Highlight") or SkipMirroredMaps[realMapName] then
    Mirrored = false
else
    Mirrored = false 
end
Alert(Mirrored and "Mirrored Playback" or "Normal Playback", Color3.fromRGB(255, 149, 5))

local SpawnPoint = nil
for _,v in ipairs(Map:GetChildren()) do
    if v.Name == "Part" then
        local c; c = v:GetPropertyChangedSignal("Rotation"):Connect(function() c:Disconnect(); SpawnPoint = v end)
    end
end

local t = 0
repeat task.wait(0.1); t=t+0.1; if not SpawnPoint then SpawnPoint = Map:FindFirstChild("Spawn", true) end
until SpawnPoint or t > 10 or CleanedUp

if not SpawnPoint then 
    Alert("No Spawn Found!", Color3.new(1,0,0))
    Cleanup(true)
    return 
end

Alert("Starting TAS...", Color3.fromRGB(0, 255, 0))

local RootPart = LP.Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = LP.Character:WaitForChild("Humanoid", 10)

if not RootPart or not Humanoid then Cleanup(true) return end

while (RootPart.Anchored == true) or (Humanoid.WalkSpeed <= 0) do
    if CleanedUp then return end
    
    if RootPart.Anchored == true then
        RootPart:GetPropertyChangedSignal("Anchored"):Wait()
    elseif Humanoid.WalkSpeed <= 0 then
        Humanoid:GetPropertyChangedSignal("WalkSpeed"):Wait()
    end
end

local TimeStart = os.clock()

if CleanedUp then return end

if LP.Character and LP.Character:FindFirstChild("Humanoid") then
    LP.Character.Humanoid.AutoRotate = false
end

Animate.playAnimation = function() end

for _, v in next, Map:GetDescendants() do
    if v.Name == 'ButtonIcon' then
        local p = v.Parent.Parent:FindFirstChildOfClass('Part')
        if p then p.Size = NewV(7, 7, 7); p.Transparency = 1 end
    end
end

local LastPlayedAnim = nil
local IsSliding = false

local function activateAnimation(AnimData)
    if not AnimData then Animate.playAnimation = OriginalPlayAnim; return end
    
    if not LP.Character or not LP.Character.Parent or not LP.Character:FindFirstChild("Head") or not LP.Character:FindFirstChild("Humanoid") or not LP.Character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local n = AnimData[1]
    local animTime = AnimData[2] or 0.1

    -- [PRIORITY 1] Physics State = ALWAYS SWING
    if LP.Character.Humanoid:GetState() == Enum.HumanoidStateType.Physics then 
        n = "swing" 
    end
    
    -- [PRIORITY 2] Idle Logic
    if n == "idle" then
        local vel = LP.Character.HumanoidRootPart.Velocity
        if vel.Magnitude > 1 then
            if LP.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
                n = "walk"
                animTime = 0.1
            else
                n = "fall"
                animTime = 0.3
            end
        end
    end

    -- [PRIORITY 3] Fall + Still = Swing
    if n == "fall" and LP.Character.HumanoidRootPart.Velocity.Magnitude < 0.1 then
        n = "swing"
    end

    -- [LOGIC] Slide Toggle
    if n == "slide" then
        if not IsSliding then
            toggleSlide(true)
            IsSliding = true
        end
    else
        if IsSliding then
            toggleSlide(false)
            IsSliding = false
        end
    end

    -- [PLAYBACK] 
    if n and (n == "swing" or n == "zipline" or n ~= LastPlayedAnim) then
        Animate.playAnimation = function() end
        OriginalPlayAnim(n, animTime, LP.Character.Humanoid)
        
        if n == "walk" then
            Animate.setAnimationSpeed(.76) 
        end
        
        LastPlayedAnim = n
    end
end

local Offset = SpawnPoint.Position - NewV(0, 1000, 0)
local OldFrame = 3
local RenderedFrames = 0
local AnimErrors = 0 
local FinishedRun = false

-- // PHYSICS LOOP (Heartbeat) //
local MainLoop
MainLoop = RS.Heartbeat:Connect(function()
    -- Stability Check
    if not RootPart or not RootPart.Parent or not Humanoid or not Humanoid.Parent then
        Cleanup(false)
        return
    end

    if CleanedUp then 
        if MainLoop then MainLoop:Disconnect() end
        return 
    end
    
    RenderedFrames = RenderedFrames + 1
    local Elapsed = os.clock() - TimeStart
    
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.Health = 99999
    end
    
    while OldFrame < #TAS and TAS[OldFrame + 1].time <= Elapsed do 
        OldFrame = OldFrame + 1 
    end

    if OldFrame >= #TAS then
        if not FinishedRun then
            FinishedRun = true
            Alert('Finished!', Color3.new(0, 1, 0))
            Alert(string.format("TAS: %d | Rendered: %d", OriginalFrameCount, RenderedFrames), Color3.new(1,1,1))
            
            if AnimErrors > 0 then
                Alert("Animation Errors: " .. AnimErrors, Color3.new(1, 0.5, 0))
            end
            
            if Animate and OriginalPlayAnim and LP.Character and LP.Character:FindFirstChild("Humanoid") then
                 Animate.playAnimation = OriginalPlayAnim
                 OriginalPlayAnim("idle", 0.1, LP.Character.Humanoid)
            end
            Cleanup(false) 
        end
        return
    end

    local FA = TAS[OldFrame]
    local FB = TAS[OldFrame + 1] or FA

    local Dur = FB.time - FA.time
    local Alpha = (Dur > 0) and math.clamp((Elapsed - FA.time) / Dur, 0, 1) or 0

    local cfA = NewC(FA.CCFrame[1], FA.CCFrame[2], FA.CCFrame[3]) * AngC(FA.CCFrame[4], FA.CCFrame[5], FA.CCFrame[6])
    local cfB = NewC(FB.CCFrame[1], FB.CCFrame[2], FB.CCFrame[3]) * AngC(FB.CCFrame[4], FB.CCFrame[5], FB.CCFrame[6])
    local vA = NewV(FA.VVelocity[1], FA.VVelocity[2], FA.VVelocity[3])
    local vB = NewV(FB.VVelocity[1], FB.VVelocity[2], FB.VVelocity[3])

    local TargetVelocity = vA:Lerp(vB, Alpha)
    
    if TargetVelocity.Magnitude > 0 then
        getgenv().TASCurrentMoveDir = TargetVelocity.Unit
    else
        getgenv().TASCurrentMoveDir = Vector3.new(0,0,0)
    end

    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.Jump = true
        RootPart.CFrame = cfA:Lerp(cfB, Alpha) + Offset
        RootPart.Velocity = TargetVelocity
    end
    
    local s, e = pcall(activateAnimation, FA.AAnimation)
    if not s then
        AnimErrors = AnimErrors + 1
    end
end)
AddConnection(MainLoop)
