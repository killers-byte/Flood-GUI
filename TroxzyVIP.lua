-- ==========================================================
-- TROXZY VIP - FULL SEAMLESS EDITION v20.7
-- 🔥 Full Features + Fixed UI + Dynamic Notifications
-- ==========================================================

if not game:IsLoaded() then game.Loaded:Wait() end
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Player = Players.LocalPlayer

-- Global States
_G.TroxzyAutoFarm = false
local AUTO_QUEUE = false
local TAS_RUNNING = false

-- Utility: Notifikasi
local function notify(msg, title)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", {Title = title or "Troxzy VIP", Text = msg, Duration = 2}) end)
end

-- [UI BUILDER - FIX TAMPILAN HITAM]
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "TROXZY_VIP"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 400); Main.Position = UDim2.new(0.5, -150, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 30); Instance.new("UICorner", Main)

local Scrolling = Instance.new("ScrollingFrame", Main)
Scrolling.Size = UDim2.new(1, 0, 1, -50); Scrolling.BackgroundTransparency = 1; Scrolling.CanvasSize = UDim2.new(0,0,3,0)
Instance.new("UIListLayout", Scrolling).Padding = UDim.new(0, 5)

local function AddToggle(name, callback)
    local btn = Instance.new("TextButton", Scrolling)
    btn.Size = UDim2.new(0.9, 0, 0, 40); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    btn.Text = name .. ": OFF"; btn.TextColor3 = Color3.new(1,1,1); Instance.new("UICorner", btn)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(99, 102, 241) or Color3.fromRGB(40, 40, 60)
        notify(name .. " is now " .. (state and "ON" or "OFF"), "Status")
        callback(state)
    end)
end

-- [FITUR-FITUR]
AddToggle("Auto Queue", function(s) AUTO_QUEUE = s end)
AddToggle("Noclip", function(s) _G.Noclip = s end)
AddToggle("God Mode", function(s) _G.God = s end)
AddToggle("Infinite Jump", function(s) _G.InfJump = s end)
AddToggle("ESP", function(s) _G.ESP = s end)

-- [TAS ENGINE]
local function ExecuteTAS()
    if TAS_RUNNING then return end
    local url = "https://raw.githubusercontent.com/killers-byte/Flood-GUI/main/TAS/PLAYER/newtasplayer.luau"
    local s, c = pcall(function() return game:HttpGet(url) end)
    if s and c then
        local f = loadstring(c)
        if f then TAS_RUNNING = true; task.spawn(function() pcall(f); TAS_RUNNING = false end) end
    end
end

-- [MASTER LOOP SEAMLESS]
RunService.Heartbeat:Connect(function()
    -- Logic Noclip
    if _G.Noclip then 
        for _, v in pairs(Player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end 
    end
    -- Logic Auto Queue
    if AUTO_QUEUE then
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp.Position.X > 50 then
                if not TAS_RUNNING then ExecuteTAS() end
            elseif not (hrp.Position.X < 50 and hrp.Position.Z > 70) then
                pcall(function() ReplicatedStorage.Remote.AddedWaiting:FireServer() end)
                if hrp.Velocity.Magnitude < 0.5 then
                    Player.Character.Humanoid:MoveTo(hrp.Position + Vector3.new(math.random(-15,15), 0, math.random(-15,15)))
                end
            end
        end
    end
end)

-- [AUTO UPDATER]
local UpdateBtn = Instance.new("TextButton", Main)
UpdateBtn.Size = UDim2.new(1, 0, 0, 50); UpdateBtn.Position = UDim2.new(0, 0, 1, -50)
UpdateBtn.Text = "Check for Updates"; UpdateBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
UpdateBtn.MouseButton1Click:Connect(function()
    notify("Checking GitHub...", "Updater")
    local url = "https://raw.githubusercontent.com/killers-byte/Flood-GUI/refs/heads/main/TroxzyVIP.lua"
    local s, c = pcall(function() return game:HttpGet(url) end)
    if s then loadstring(c)() end
end)

notify("Troxzy Full Script Loaded!", "Success")
