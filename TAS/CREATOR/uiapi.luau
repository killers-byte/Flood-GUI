--[[ 
    FE2 TAS UI Library (High Fidelity Restoration)
    Matches the original "TAS Creator built for FE2 v63.21" visual style.
]]

local TAS_UI = {}

function TAS_UI.Create()
    local CoreGui = game:GetService("CoreGui")
    
    -- // 1. Main ScreenGui //
    local HUD = Instance.new("ScreenGui")
    HUD.Name = "TAS_HUD_Original"
    HUD.Parent = CoreGui
    HUD.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    HUD.ResetOnSpawn = false

    -- // 2. Main Container //
    local HUDFrame = Instance.new("Frame")
    HUDFrame.Name = "HUD"
    HUDFrame.Parent = HUD
    HUDFrame.AnchorPoint = Vector2.new(0.5, 0)
    HUDFrame.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    HUDFrame.BackgroundTransparency = 1.000
    HUDFrame.Position = UDim2.new(0.5, 0, 0.89, 0)
    HUDFrame.Size = UDim2.new(1, 0, 0.0825, 0)
    HUDFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
    HUDFrame.ZIndex = 3

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = HUDFrame
    Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Main.BackgroundTransparency = 1.000
    Main.Size = UDim2.new(1, 0, 1, 0)

    -- // 3. GameStats (The dark box in bottom center) //
    local GameStats = Instance.new("Frame")
    GameStats.Name = "GameStats"
    GameStats.Parent = Main
    GameStats.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    GameStats.BackgroundTransparency = 0.500
    GameStats.BorderColor3 = Color3.fromRGB(27, 42, 53)
    GameStats.BorderSizePixel = 0
    GameStats.Position = UDim2.new(0.33, 0, 0.178, 0)
    GameStats.Size = UDim2.new(0, 348, 0, 73)
    
    -- Rounded Corners for Stats
    local StatsCorner = Instance.new("UICorner")
    StatsCorner.CornerRadius = UDim.new(0, 9)
    StatsCorner.Parent = GameStats

    -- // 4. Timer Display (The big numbers) //
    local TimeText = Instance.new("TextLabel")
    TimeText.Name = "TimeText"
    TimeText.Parent = GameStats
    TimeText.BackgroundTransparency = 1.000
    TimeText.Position = UDim2.new(0.017, 0, 0.162, 0)
    TimeText.Size = UDim2.new(0.5, 0, 0.7, 0)
    TimeText.Font = Enum.Font.Highway
    TimeText.Text = "0:00.000"
    TimeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimeText.TextScaled = true
    TimeText.TextWrapped = true
    
    -- Constraint to keep text nice
    local TimeConstraint = Instance.new("UITextSizeConstraint")
    TimeConstraint.MaxTextSize = 45
    TimeConstraint.Parent = TimeText

    -- // 5. Counters (Right side of box) //
    
    -- Savestates Counter
    local SavestatesCount = Instance.new("TextLabel")
    SavestatesCount.Name = "SavestatesCount"
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

    -- Frame Counter
    local FrameCount = Instance.new("TextLabel")
    FrameCount.Name = "FrameCount"
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

    -- Show Keybinds Button
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Name = "KeybindToggle"
    KeybindButton.Parent = GameStats
    KeybindButton.BackgroundTransparency = 1.000
    KeybindButton.Position = UDim2.new(0, 190, 0, 42)
    KeybindButton.Size = UDim2.new(0, 149, 0, 33)
    KeybindButton.Font = Enum.Font.Highway
    KeybindButton.Text = "Show Keybinds"
    KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeybindButton.TextSize = 20.000

    -- // 6. Shadow & Background Layers (Main2) //
    local Main2 = Instance.new("Frame")
    Main2.Name = "Main2"
    Main2.Parent = HUDFrame
    Main2.BackgroundTransparency = 1.000
    Main2.Size = UDim2.new(1, 0, 1, 0)
    Main2.ZIndex = -1

    local ShadowThingy = Instance.new("Frame")
    ShadowThingy.Name = "Dropshadowthingy"
    ShadowThingy.Parent = Main2
    ShadowThingy.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    ShadowThingy.BackgroundTransparency = 0.500
    ShadowThingy.Position = UDim2.new(0, 602, 0, -165)
    ShadowThingy.Size = UDim2.new(-0.022, 278, 3.415, 0)
    ShadowThingy.Visible = false
    ShadowThingy.ZIndex = -2
    
    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 9)
    ShadowCorner.Parent = ShadowThingy

    -- // 7. Keybinds List (The menu that pops up) //
    local KeyBindFrame = Instance.new("Frame")
    KeyBindFrame.Name = "KeyBindFrame"
    KeyBindFrame.Parent = Main
    KeyBindFrame.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    KeyBindFrame.BackgroundTransparency = 1.000
    KeyBindFrame.Position = UDim2.new(0.548, 0, -2.415, 0)
    KeyBindFrame.Size = UDim2.new(-0.022, 278, 3.515, 0)
    KeyBindFrame.Visible = false
    
    local KeyList = Instance.new("UIListLayout")
    KeyList.Parent = KeyBindFrame
    KeyList.SortOrder = Enum.SortOrder.LayoutOrder
    KeyList.Padding = UDim.new(0, -4)

    -- Helper for Keybind Labels
    local function CreateKeyLabel(text, color)
        local L = Instance.new("TextLabel")
        L.Parent = KeyBindFrame
        L.BackgroundTransparency = 1.000
        L.Size = UDim2.new(1, 0, 0.113, 0)
        L.Font = Enum.Font.Highway
        L.Text = text
        L.TextColor3 = color or Color3.fromRGB(255, 255, 255)
        L.TextScaled = true
        L.TextWrapped = true
        
        local C = Instance.new("UITextSizeConstraint")
        C.MaxTextSize = 18
        C.Parent = L
        return L
    end

    local CapLockStatus = CreateKeyLabel("CapsLock : Paused", Color3.fromRGB(255, 255, 0))
    CreateKeyLabel("One : Add a Savestate")
    CreateKeyLabel("Two : Remove a Savestate")
    CreateKeyLabel("Three : Go To Last SaveState")
    CreateKeyLabel("Four : Go Back a Frame")
    CreateKeyLabel("Five : Go a Frame Forward")
    CreateKeyLabel("Six : SaveRun")
    CreateKeyLabel("C : CanCollide Toggle")
    CreateKeyLabel("Delete: Stop Creating")
    CreateKeyLabel("Zero: View TAS")

    -- // 8. Map Info (Top of screen) //
    local MapEventInfo = Instance.new("TextLabel")
    MapEventInfo.Name = "MapEventInfo"
    MapEventInfo.Parent = HUDFrame
    MapEventInfo.AnchorPoint = Vector2.new(0.5, 1)
    MapEventInfo.BackgroundTransparency = 1.000
    MapEventInfo.Position = UDim2.new(0.5, 0, -0.1, 0)
    MapEventInfo.Size = UDim2.new(1.2, 0, 0, 0)
    MapEventInfo.Text = ""
    MapEventInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    MapEventInfo.TextScaled = true
    MapEventInfo.TextStrokeTransparency = 0.625
    MapEventInfo.Font = Enum.Font.Highway
    
    -- Map Event Gradient
    local MEIGradient = Instance.new("UIGradient")
    MEIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(184, 184, 184))
    }
    MEIGradient.Rotation = 90
    MEIGradient.Parent = MapEventInfo

    -- // 9. Internal Toggle Logic //
    KeybindButton.Activated:Connect(function()
        KeyBindFrame.Visible = not KeyBindFrame.Visible
        ShadowThingy.Visible = not ShadowThingy.Visible
        if KeyBindFrame.Visible then
            KeybindButton.Text = "Hide Keybinds"
        else
            KeybindButton.Text = "Show Keybinds"
        end
    end)

    -- // 10. Return Objects //
    return {
        ScreenGui = HUD,
        TimeText = TimeText,
        SavestatesCount = SavestatesCount,
        FrameCount = FrameCount,
        KeybindButton = KeybindButton,
        StatusText = CapLockStatus,
        MapEventInfo = MapEventInfo
    }
end

return TAS_UI
