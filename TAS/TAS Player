print("Latest TAS Player built for V64.03 (Optimized Playback)")
local SkipMirroredMaps = {
    ["Retro Coast"] = true,
    ["Zemblanity"] = true,
    ["Northern Mill"] = true,
    ["Mysterium"] = true,
    ["Decaying Silo"] = true,
    ["Active Volcanic Mines"] = true,
    ["Snowy Stronghold"] = true,
    ["Classic Canyon"] = true
}
if State and State().HighlightOnlyMaps then
    for _,v in ipairs(State().HighlightOnlyMaps) do
        SkipMirroredMaps[v] = true
    end
end
local Mirrored = false
local NewV = Vector3.new
local NewC = CFrame.new
local AngC = CFrame.fromEulerAnglesXYZ
local LP = game.Players.LocalPlayer
local CurrentCamera = workspace.CurrentCamera

-- // ANIMATION HELPERS //
local function toggleSlide(newValue)
    if newValue == true then
        LP.Character.HumanoidRootPart.Size = Vector3.new(2, 1, 1)
        LP.Character.FE2_Hitbox.Size = Vector3.new(2, 1, 1)
        LP.Character.Humanoid.HipHeight = -1.5
    else
        LP.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
        LP.Character.FE2_Hitbox.Size = Vector3.new(2, 2, 1)
        LP.Character.Humanoid.HipHeight = 0
    end
    -- Safe check for Sliding event
    if LP.Character and LP.Character:FindFirstChild("Animate") and LP.Character.Animate:FindFirstChild("Sliding") then
        LP.Character.Animate.Sliding:Fire(newValue)
    end
end

local function doSlide(delay)
    toggleSlide(true)
    task.wait(delay)
    toggleSlide(false)
end

-- // ALERTS //
local CLMAIN = getsenv(LP.PlayerScripts.CL_MAIN_GameScript) -- {newAlert = print}
local Alert = CLMAIN.newAlert
if Alert == nil then
    warn("Your executor is so bad that it couldnt handle Alerts :(")
    Alert = print
end
Alert("Latest TAS Player built for V64.03 (Optimized)", Color3.new(1, 1, 1))
local Multi = workspace.Multiplayer
local RS = game:GetService('RunService')

if not getgenv().alreadystarted then
    Alert("TAS Player Started.", Color3.fromRGB(255, 149, 5))
    getgenv().alreadystarted = true
else
    Alert("TAS Player ready for next map.", Color3.new(0,1,.5))
end

-- // CLEANUP //
local DeathConnect
local function Cleanup()
    if DeathConnect then DeathConnect:Disconnect() end
    print("Cleaning Up..")
    Alert("Resetting..", Color3.new(0, 1, 1))
    if LP.Character and LP.Character:FindFirstChild("Head") then
        LP.Character.Head:Destroy()
    end
    LP.CharacterAdded:wait()
    task.wait(1)
    local RootPart = LP.Character:WaitForChild("HumanoidRootPart")
    for i = 1, 200 do
        RootPart.Velocity = Vector3.new(0, 1, 1000)
        task.wait()
    end
end
DeathConnect = LP.Character.Humanoid.Died:Connect(Cleanup)

-- // ANIMATION BYPASS //
local Animate = getsenv(LP.Character.Animate)
local Map = Multi:WaitForChild('NewMap', 9e6)
local realMapName = Map:WaitForChild('Settings'):GetAttribute("MapName")
local mapName = game:GetService("HttpService"):UrlEncode(realMapName)
print(realMapName)

-- // CHECK FOR LOCAL TAS //
local success, path
if isfolder("Flood-GUI") == true and isfolder("Flood-GUI/TAS FILES") == true then
    local TargetTASPath = "Flood-GUI/TAS FILES/" .. realMapName .. ".json"
    if isfile(TargetTASPath) == true then
        print("Found Local")
        path = readfile(TargetTASPath)
        success = true
    end
end

-- // DOWNLOAD TAS //
if path == nil then
    print("Getting Online!")
    success, path = 
        pcall(function()
            return game:HttpGet("https://raw.githubusercontent.com/tomatotxt/Flood-GUI/refs/heads/main/TAS%20FILES/".. mapName .. ".json")
        end)
end

if success and #path > 50 then
    print("TAS FILE IS REAL")
else
    print("TAS FILE BROKEN")
    Cleanup()
end

local TAS
local Success, Error = pcall(function(...)
    TAS = game:GetService("HttpService"):JSONDecode(path)
end)

-- Sanity Check
if not TAS or Success == false or #TAS < 60 then
    if Success == false then
        warn("JSON DECODE ERROR:", Error)
    end
    Alert("TAS file for "..mapName.." does not exist!", Color3.new(1,0,0))
    Cleanup()
else
    print("Total Frames:", #TAS)
    Alert("TAS Loaded!")
    repeat task.wait() until Map.Name == "Map"

    -- // MIRROR LOGIC //
    local HighlightPath = game:GetService("Workspace").Multiplayer.Map.Settings:GetAttribute("Highlight")

    if HighlightPath then
        Alert("Map cannot be mirrored.", Color3.fromRGB(255, 100, 0))
        Mirrored = false
    else
        if Map:WaitForChild('Settings'):FindFirstChild("_MirrorMap") then
            Mirrored = false
        else
            Mirrored = false
        end
        if Mirrored == true and SkipMirroredMaps[realMapName] then
            Alert('Map cannot be mirrored.', Color3.fromRGB(255, 100, 0))
            Mirrored = false
        end
        if Mirrored == true then
            Alert('Map is mirrored, TAS will be played mirrored!', Color3.fromRGB(255, 149, 5))
        else
            Alert('Map is not mirrored.', Color3.fromRGB(255, 149, 5))
        end
    end

    -- // SPAWN FINDER //
    local Spawn = (function()
        local Spawn = nil
        local connections = {}
        for _,v in ipairs(Map:GetChildren()) do
            if v.Name == "Part" then
                table.insert(connections, v:GetPropertyChangedSignal("Rotation"):Connect(function()
                    for _,v in ipairs(connections) do
                        v:Disconnect()
                    end
                    Spawn = v
                end))
            end
        end
        repeat task.wait() until Spawn or Map:FindFirstChild("Spawn", true)
        Alert("Spawn found!", Color3.fromRGB(0, 255, 0))
        return ((Spawn ~= nil) and Spawn) or Map:FindFirstChild("Spawn", true)
    end)()

    repeat task.wait() until LP.Character.HumanoidRootPart.Anchored == false
    local TimeStart = tick()
    Alert('TAS Running..', Color3.fromRGB(255, 149, 5))
    
    -- // HOOK PLAYANIMATION //
    PlayAnim = Animate.playAnimation
    Animate.playAnimation = function()end

    -- // VISUALS //
    for _, v in next, Map:GetDescendants() do
        if v.Name == 'ButtonIcon' then
            local buttonPart = v.Parent.Parent:FindFirstChildOfClass('Part')
            if buttonPart ~= nil then
                buttonPart.Size = Vector3.new(7, 7, 7)
                buttonPart.Transparency = 1
            end
        end
    end

    function isRandomString(str)
        for i = 1, #str do
            local ltr = str:sub(i, i)
            if ltr:lower() == ltr then
                return false
            end     
        end
        return true
    end

    -- // ANIMATION HANDLER (OPTIMIZED) //
    local LastPlayedAnim = nil
    
    local function activateAnimation(CurrentAnimation)
        if LP.Character.Humanoid:GetState() == Enum.HumanoidStateType.Physics then
            CurrentAnimation[1] = "swing"
        end
        
        if CurrentAnimation and CurrentAnimation[1] then
            -- [FIX] Only play if animation changed to prevent stutter/spam
            if CurrentAnimation[1] ~= LastPlayedAnim then
                Animate.playAnimation = function()end
                PlayAnim(CurrentAnimation[1], CurrentAnimation[2] or 0.1, LP.Character.Humanoid)
                
                if CurrentAnimation[1] == "walk" then
                    Animate.setAnimationSpeed(.76) 
                elseif CurrentAnimation[1] == "slide" then
                    task.spawn(doSlide, 0.25)
                end
                
                LastPlayedAnim = CurrentAnimation[1]
            end
        elseif CurrentAnimation == nil then
            Animate.playAnimation = PlayAnim
        end
    end

    local Offset = Spawn.Position - NewV(0, 1000, 0)
    local OldFrame = 3

    local Loop
    local Death

    Death = LP.Character.Humanoid.Changed:Connect(function(Change)
        if Change == "Health" and LP.Character.Humanoid.Health == 0 then
            Death:Disconnect()
            Loop:Disconnect()
            Alert('Player Died.', Color3.new(1, 0, 0))
        end
    end)

    local RootPart = LP.Character.HumanoidRootPart

    -- // MAIN PLAYBACK LOOP //
    Loop = RS.Heartbeat:Connect(function()
        local Elapsed = tick() - TimeStart
        LP.Character.Humanoid.Health = 99999
        
        -- Advance index based on current time
        while OldFrame < #TAS and TAS[OldFrame + 1].time <= Elapsed do
            OldFrame = OldFrame + 1
        end

        -- Check for end of run
        if OldFrame >= #TAS then
            Alert('TAS Run Finished!', Color3.new(0, 1, 0))
            Alert('TAS Player By Tomato & Moz', Color3.new(0, 1, 0))
            Death:Disconnect()
            Loop:Disconnect()
            DeathConnect:Disconnect()
            Animate.playAnimation = PlayAnim
            if LP.Character and LP.Character.Humanoid then
                Animate.playAnimation("idle", 0.1, LP.Character.Humanoid)
            end
            return
        end

        -- Frame Interpolation Logic
        local FrameA = TAS[OldFrame]
        local FrameB = TAS[OldFrame + 1] or FrameA
        
        local Duration = FrameB.time - FrameA.time
        local Alpha = (Duration > 0) and math.clamp((Elapsed - FrameA.time) / Duration, 0, 1) or 0

        -- Construct CFrames and Vectors for Lerping
        local cfA = NewC(FrameA.CCFrame[1], FrameA.CCFrame[2], FrameA.CCFrame[3]) * AngC(FrameA.CCFrame[4], FrameA.CCFrame[5], FrameA.CCFrame[6])
        local cfB = NewC(FrameB.CCFrame[1], FrameB.CCFrame[2], FrameB.CCFrame[3]) * AngC(FrameB.CCFrame[4], FrameB.CCFrame[5], FrameB.CCFrame[6])
        local vA = NewV(FrameA.VVelocity[1], FrameA.VVelocity[2], FrameA.VVelocity[3])
        local vB = NewV(FrameB.VVelocity[1], FrameB.VVelocity[2], FrameB.VVelocity[3])

        -- Apply Physics
        LP.Character.Humanoid.Jump = true
        RootPart.CFrame = cfA:Lerp(cfB, Alpha) + Offset
        RootPart.Velocity = vA:Lerp(vB, Alpha)
        
        -- Apply Animation
        local s, r = pcall(activateAnimation, FrameA.AAnimation)
        if s == false then warn(r) end
    end)
end
