local TimeModifier = 1 -- [CONTROL SPEED HERE] (1 = Normal, 0.5 = 2x Speed, 2 = Slow Motion)

print("Latest TAS Player built for V64.03 (Integrity Scan + Speed Mod)")

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
local Animate = getsenv(LP.Character.Animate)
local OriginalPlayAnim = Animate.playAnimation

local function toggleSlide(newValue)
    if not LP.Character then return end
    if newValue == true then
        LP.Character.HumanoidRootPart.Size = NewV(2, 1, 1)
        LP.Character.FE2_Hitbox.Size = NewV(2, 1, 1)
        LP.Character.Humanoid.HipHeight = -1.5
    else
        LP.Character.HumanoidRootPart.Size = NewV(2, 2, 1)
        LP.Character.FE2_Hitbox.Size = NewV(2, 2, 1)
        LP.Character.Humanoid.HipHeight = 0
    end
    if LP.Character:FindFirstChild("Animate") and LP.Character.Animate:FindFirstChild("Sliding") then
        LP.Character.Animate.Sliding:Fire(newValue)
    end
end

local function doSlide(delay)
    toggleSlide(true); task.wait(delay); toggleSlide(false)
end

-- // CLEANUP //
local CleanedUp = false
local function Cleanup(resetCharacter)
    if CleanedUp then return end
    CleanedUp = true
    print("Cleaning Up...")
    
    if getgenv().TASConnections then
        for _, connection in pairs(getgenv().TASConnections) do
            if connection then connection:Disconnect() end
        end
        getgenv().TASConnections = {}
    end

    if Animate and OriginalPlayAnim then Animate.playAnimation = OriginalPlayAnim end

    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.AutoRotate = true
    end

    if resetCharacter and LP.Character and LP.Character:FindFirstChild("Humanoid") then
        Alert("Error/Resetting...", Color3.new(1, 0, 0))
        LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        LP.Character.Humanoid.Health = 0
        task.spawn(function()
            LP.CharacterAdded:Wait()
            game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("AddedWaiting"):FireServer()
        end)
    end
end

AddConnection(LP.Character.Humanoid.Died:Connect(function() Cleanup(false) end))

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

-- // INTEGRITY CHECK //
-- This checks if the TAS file has missing values BEFORE we start, 
-- preventing random crashes later.
print("Scanning TAS for integrity...")
local BrokenFrames = 0
for i, Frame in ipairs(TAS) do
    if not Frame.CCFrame or #Frame.CCFrame < 6 then
        BrokenFrames = BrokenFrames + 1
        if BrokenFrames == 1 then
            warn("TAS DATA ERROR: Frame " .. i .. " is missing CCFrame data (Argument 3 nil)")
        end
    end
end

if BrokenFrames > 0 then
    Alert("TAS CORRUPT: " .. BrokenFrames .. " broken frames detected!", Color3.new(1, 0, 0))
    warn("TAS Playback Aborted due to corrupt data.")
    Cleanup(true)
    return
else
    print("TAS Integrity Check Passed.")
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
if not RootPart then Cleanup(true) return end

if RootPart.Anchored then
    RootPart:GetPropertyChangedSignal("Anchored"):Wait()
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
local function activateAnimation(AnimData)
    if not AnimData then Animate.playAnimation = OriginalPlayAnim; return end
    local n = AnimData[1]
    if LP.Character.Humanoid:GetState() == Enum.HumanoidStateType.Physics then n = "swing" end
    
    if n and (n == "swing" or n ~= LastPlayedAnim) then
        Animate.playAnimation = function() end
        OriginalPlayAnim(n, AnimData[2] or 0.1, LP.Character.Humanoid)
        if n == "walk" then Animate.setAnimationSpeed(.76) 
        elseif n == "slide" then task.spawn(doSlide, 0.25) end
        LastPlayedAnim = n
    end
end

local Offset = SpawnPoint.Position - NewV(0, 1000, 0)
local OldFrame = 3
local RenderedFrames = 0
local AnimErrors = 0 

AddConnection(LP.Character.Humanoid.Changed:Connect(function(C)
    if C == "Health" and LP.Character.Humanoid.Health <= 0 then Alert('Died.', Color3.new(1, 0, 0)); Cleanup(false) end
end))

-- // PHYSICS LOOP (Heartbeat) //
local MainLoop
MainLoop = RS.Heartbeat:Connect(function()
    if CleanedUp then 
        if MainLoop then MainLoop:Disconnect() end
        return 
    end
    
    RenderedFrames = RenderedFrames + 1
    local Elapsed = os.clock() - TimeStart
    LP.Character.Humanoid.Health = 99999
    
    while OldFrame < #TAS and TAS[OldFrame + 1].time <= Elapsed do 
        OldFrame = OldFrame + 1 
    end

    if OldFrame >= #TAS then
        Alert('Finished!', Color3.new(0, 1, 0))
        Alert(string.format("TAS: %d | Rendered: %d", OriginalFrameCount, RenderedFrames), Color3.new(1,1,1))
        
        if AnimErrors == 0 then
            Alert("Animation Errors: 0", Color3.new(0, 1, 0))
        else
            Alert("Animation Errors: " .. AnimErrors, Color3.new(1, 0.5, 0))
        end
        
        if Animate and OriginalPlayAnim and LP.Character and LP.Character.Humanoid then
             Animate.playAnimation = OriginalPlayAnim
             OriginalPlayAnim("idle", 0.1, LP.Character.Humanoid)
        end
        Cleanup(false) 
        return
    end

    local FA = TAS[OldFrame]
    local FB = TAS[OldFrame + 1] or FA

    local Dur = FB.time - FA.time
    local Alpha = (Dur > 0) and math.clamp((Elapsed - FA.time) / Dur, 0, 1) or 0

    -- [RAW DATA ACCESS] No 'or 0' here.
    local cfA = NewC(FA.CCFrame[1], FA.CCFrame[2], FA.CCFrame[3]) * AngC(FA.CCFrame[4], FA.CCFrame[5], FA.CCFrame[6])
    local cfB = NewC(FB.CCFrame[1], FB.CCFrame[2], FB.CCFrame[3]) * AngC(FB.CCFrame[4], FB.CCFrame[5], FB.CCFrame[6])
    local vA = NewV(FA.VVelocity[1], FA.VVelocity[2], FA.VVelocity[3])
    local vB = NewV(FB.VVelocity[1], FB.VVelocity[2], FB.VVelocity[3])

    -- Apply Physics
    LP.Character.Humanoid.Jump = true
    RootPart.CFrame = cfA:Lerp(cfB, Alpha) + Offset
    RootPart.Velocity = vA:Lerp(vB, Alpha)
    
    -- Capture Animation Errors
    local s, e = pcall(activateAnimation, FA.AAnimation)
    if not s then
        AnimErrors = AnimErrors + 1
    end
end)
AddConnection(MainLoop)
