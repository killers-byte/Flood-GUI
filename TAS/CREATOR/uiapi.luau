--- START OF FILE uiapi.luau.txt ---

--[[ 
    FE2 TAS UI Library (Updated)
    - Includes GameGui toggling
    - New Keybinds added
    - Layout overlap fixes
]]

local TAS_UI = {}

function TAS_UI.Create()
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 5)

    -- // GameGui Toggle Logic //
    local GameGui = PlayerGui and PlayerGui:FindFirstChild("GameGui")
    if GameGui then 
        GameGui.Enabled = false 
    end

    -- // Clean up old UIs //
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "TAS_HUD" then v:Destroy() end
    end

    -- // 1. Main ScreenGui //
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TAS_HUD"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    -- Re-enable GameGui when this UI is destroyed (Clean Reset)
    ScreenGui.Destroying:Connect(function()
        if GameGui then 
            GameGui.Enabled = true 
        end
    end)

    -- // 2. Main HUD Frame //
    local HUDFrame = Instance.new("Frame")
    HUDFrame.Name = "HUD"
    HUDFrame.Parent = ScreenGui
    HUDFrame.AnchorPoint = Vector2.new(0.5, 0)
    HUDFrame.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    HUDFrame.BackgroundTransparency = 1.000
    HUDFrame.Position = UDim2.new(0.5, 0, 0.889999986, 0)
    HUDFrame.Size = UDim2.new(1, 0, 0.0825000033, 0)
    HUDFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
    HUDFrame.ZIndex = 3

    local MainContainer = Instance.new("Frame")
    MainContainer.Name = "Main"
    MainContainer.Parent = HUDFrame
    MainContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainContainer.BackgroundTransparency = 1.000
    MainContainer.Size = UDim2.new(1, 0, 1, 0)

    -- Background Layer (For Shadows)
    local BackgroundLayer = Instance.new("Frame")
    BackgroundLayer.Name = "BackgroundLayer"
    BackgroundLayer.Parent = HUDFrame
    BackgroundLayer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BackgroundLayer.BackgroundTransparency = 1.000
    BackgroundLayer.Size = UDim2.new(1, 0, 1, 0)
    BackgroundLayer.ZIndex = -1

    -- // 3. Game Stats Box //
    local GameStats = Instance.new("Frame")
    GameStats.Name = "GameStats"
    GameStats.Parent = MainContainer
    GameStats.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    GameStats.BackgroundTransparency = 0.500
    GameStats.BorderColor3 = Color3.fromRGB(27, 42, 53)
    GameStats.BorderSizePixel = 0
    -- Positioned slightly to the left to leave room for keybinds
    GameStats.Position = UDim2.new(0.30, 0, 0.178, 0) 
    GameStats.Size = UDim2.new(0, 348, 0, 73)

    local GSCorner = Instance.new("UICorner")
    GSCorner.CornerRadius = UDim.new(0, 9)
    GSCorner.Parent = GameStats

    -- // 4. Labels //
    local TimeText = Instance.new("TextLabel")
    TimeText.Parent = GameStats
    TimeText.BackgroundTransparency = 1.000
    TimeText.Position = UDim2.new(0.017, 0, 0.162, 0)
    TimeText.Size = UDim2.new(0.5, 0, 0.7, 0)
    TimeText.Font = Enum.Font.Highway
    TimeText.Text = "0:00.000"
    TimeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimeText.TextScaled = true
    TimeText.TextWrapped = true
    
    local TimeConstraint = Instance.new("UITextSizeConstraint")
    TimeConstraint.MaxTextSize = 45
    TimeConstraint.Parent = TimeText

    local SavestatesCount = Instance.new("TextLabel")
    SavestatesCount.Parent = GameStats
    SavestatesCount.BackgroundTransparency = 1.000
    SavestatesCount.Position = UDim2.new(0, 190, 0, 0)
    SavestatesCount.Size = UDim2.new(0, 149, 0, 33)
    SavestatesCount.Font = Enum.Font.Highway
    SavestatesCount.Text = "Savestates 0"
    SavestatesCount.TextColor3 = Color3.fromRGB(255, 255, 255)
    SavestatesCount.TextScaled = true
    
    local SSConstraint = Instance.new("UITextSizeConstraint")
    SSConstraint.MaxTextSize = 22
    SSConstraint.Parent = SavestatesCount

    local FrameCount = Instance.new("TextLabel")
    FrameCount.Parent = GameStats
    FrameCount.BackgroundTransparency = 1.000
    FrameCount.Position = UDim2.new(0, 190, 0, 20)
    FrameCount.Size = UDim2.new(0, 149, 0, 33)
    FrameCount.Font = Enum.Font.Highway
    FrameCount.Text = "Frames 0"
    FrameCount.TextColor3 = Color3.fromRGB(255, 255, 255)
    FrameCount.TextScaled = true
    
    local FCConstraint = Instance.new("UITextSizeConstraint")
    FCConstraint.MaxTextSize = 22
    FCConstraint.Parent = FrameCount

    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Parent = GameStats
    KeybindButton.BackgroundTransparency = 1.000
    KeybindButton.Position = UDim2.new(0, 190, 0, 42)
    KeybindButton.Size = UDim2.new(0, 149, 0, 33)
    KeybindButton.Font = Enum.Font.Highway
    KeybindButton.Text = "Show Keybinds"
    KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeybindButton.TextSize = 20.000

    -- // 5. Keybind Menu & Shadow //
    -- Moved X to 0.60 to ensure no overlap with stats
    -- Adjusted Y Position (-3.8) and Height (4.8) to fit new entries
    local KB_Position = UDim2.new(0.60, 0, -3.8, 0)
    local KB_Size = UDim2.new(-0.02195, 278, 4.8, 0)

    local KeyBindFrame = Instance.new("Frame")
    KeyBindFrame.Parent = MainContainer
    KeyBindFrame.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    KeyBindFrame.BackgroundTransparency = 1.000
    KeyBindFrame.Position = KB_Position
    KeyBindFrame.Size = KB_Size
    KeyBindFrame.Visible = false

    local KeyList = Instance.new("UIListLayout")
    KeyList.Parent = KeyBindFrame
    KeyList.SortOrder = Enum.SortOrder.LayoutOrder
    KeyList.Padding = UDim.new(0, -4)

    -- Fixed Shadow
    local ShadowFrame = Instance.new("Frame")
    ShadowFrame.Parent = BackgroundLayer
    ShadowFrame.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    ShadowFrame.BackgroundTransparency = 0.500
    ShadowFrame.Position = KB_Position
    ShadowFrame.Size = KB_Size
    ShadowFrame.Visible = false
    ShadowFrame.ZIndex = -2

    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 9)
    ShadowCorner.Parent = ShadowFrame

    -- Labels Helper
    local function CreateLabel(text, color)
        local L = Instance.new("TextLabel")
        L.Parent = KeyBindFrame
        L.BackgroundTransparency = 1.000
        -- Reduced height slightly to fit more items
        L.Size = UDim2.new(1, 0, 0.08, 0)
        L.Font = Enum.Font.Highway
        L.Text = text
        L.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        L.TextScaled = true
        local C = Instance.new("UITextSizeConstraint")
        C.MaxTextSize = 18
        C.Parent = L
        return L
    end

    local CapLockStatus = CreateLabel("CapsLock : Paused", Color3.fromRGB(255, 255, 0))
    CreateLabel("One : Add a Savestate")
    CreateLabel("Two : Remove a Savestate")
    CreateLabel("Three : Go To Last SaveState")
    CreateLabel("Four : Go Back a Frame")
    CreateLabel("Five : Go a Frame Forward")
    CreateLabel("Six : SaveRun")
    CreateLabel("C : CanCollide Toggle")
    CreateLabel("Delete: Stop Creating")
    CreateLabel("Zero: View TAS")
    -- New Keybinds
    CreateLabel("Up/Down : Visual Scrubbing")
    CreateLabel("F8 : Resync Visuals")
    CreateLabel("Equals : Toggle Env Updates")

    local MapEventInfo = Instance.new("TextLabel")
    MapEventInfo.Parent = HUDFrame
    MapEventInfo.BackgroundTransparency = 1.000
    MapEventInfo.Position = UDim2.new(0.5, 0, -0.1, 0)
    MapEventInfo.Size = UDim2.new(1.2, 0, 0, 0)
    MapEventInfo.Font = Enum.Font.Highway
    MapEventInfo.Text = ""
    MapEventInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    MapEventInfo.TextScaled = true
    
    KeybindButton.Activated:Connect(function()
        KeyBindFrame.Visible = not KeyBindFrame.Visible
        ShadowFrame.Visible = not ShadowFrame.Visible
        KeybindButton.Text = KeyBindFrame.Visible and "Hide Keybinds" or "Show Keybinds"
    end)

    return {
        ScreenGui = ScreenGui,
        TimeText = TimeText,
        SavestatesCount = SavestatesCount,
        FrameCount = FrameCount,
        StatusText = CapLockStatus,
        MapEventInfo = MapEventInfo
    }
end

return TAS_UI
