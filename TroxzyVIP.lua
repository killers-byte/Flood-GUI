-- ============================================
-- TROXZY VIP - STABLE BUILD v20.8 (FIXED UI)
-- ============================================

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- Hapus UI lama
for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "TROXZY_VIP" then v:Destroy() end end

-- Buat GUI Utama
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "TROXZY_VIP"

local Main = Instance.new("Frame", ScreenGui)
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 300, 0, 400)
Main.Position = UDim2.new(0.5, -150, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "TROXZY VIP v20.8"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 8)

local Scrolling = Instance.new("ScrollingFrame", Main)
Scrolling.Size = UDim2.new(1, -10, 1, -50)
Scrolling.Position = UDim2.new(0, 5, 0, 45)
Scrolling.BackgroundTransparency = 1
Scrolling.ScrollBarThickness = 2
Instance.new("UIListLayout", Scrolling).Padding = UDim.new(0, 5)

-- Fungsi Toggle dengan Notifikasi
local function AddToggle(name, callback)
    local btn = Instance.new("TextButton", Scrolling)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(80, 80, 150) or Color3.fromRGB(60, 60, 80)
        game:GetService("StarterGui"):SetCore("SendNotification", {Title = "Troxzy", Text = name .. " is " .. (state and "ON" or "OFF")})
        callback(state)
    end)
end

-- Tambahkan Fitur
AddToggle("Auto Queue", function(s) _G.AutoQueue = s end)
AddToggle("Noclip", function(s) _G.Noclip = s end)
AddToggle("God Mode", function(s) _G.God = s end)

-- [ENGINE - DILATAR BELAKANG]
task.spawn(function()
    while task.wait(1) do
        -- Logic Noclip
        if _G.Noclip and Player.Character then
            for _, v in pairs(Player.Character:GetDescendants()) do 
                if v:IsA("BasePart") then v.CanCollide = false end 
            end
        end
        
        -- Logic Auto Queue
        if _G.AutoQueue and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = Player.Character.HumanoidRootPart
            if hrp.Position.X > 50 then
                -- Kamu berada di Map
            elseif not (hrp.Position.X < 50 and hrp.Position.Z > 70) then
                -- Kamu di Lobby, jalankan logika lift
                pcall(function() game:GetService("ReplicatedStorage").Remote.AddedWaiting:FireServer() end)
            end
        end
    end
end)

-- Tombol Update
local UpdateBtn = Instance.new("TextButton", Main)
UpdateBtn.Size = UDim2.new(1, 0, 0, 40)
UpdateBtn.Position = UDim2.new(0, 0, 1, -40)
UpdateBtn.Text = "CHECK FOR UPDATES"
UpdateBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
UpdateBtn.MouseButton1Click:Connect(function()
    local url = "https://raw.githubusercontent.com/killers-byte/Flood-GUI/refs/heads/main/TroxzyVIP.lua"
    local s, c = pcall(function() return game:HttpGet(url) end)
    if s then loadstring(c)() end
end)
