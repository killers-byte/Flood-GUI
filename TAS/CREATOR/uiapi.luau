--[[ 
    FE2 TAS UI Library (Pixel-Perfect Restoration)
    Extracted directly from TAS Creator v63.21 source.
]]

local TAS_UI = {}

function TAS_UI.Create()
    local CoreGui = game:GetService("CoreGui")
    
    -- 1. Main HUD Container
    local HUD = Instance.new("ScreenGui")
    HUD.Name = "HUD"
    HUD.Parent = CoreGui
    HUD.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    HUD.ResetOnSpawn = false

    local HUDFrame = Instance.new("Frame")
    HUDFrame.Name = "HUD"
    HUDFrame.Parent = HUD
    HUDFrame.AnchorPoint = Vector2.new(0.5, 0)
    HUDFrame.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    HUDFrame.BackgroundTransparency = 1.000
    HUDFrame.Position = UDim2.new(0.5, 0, 0.889999986, 0)
    HUDFrame.Size = UDim2.new(1, 0, 0.0825000033, 0)
    HUDFrame.SizeConstraint = Enum.SizeConstraint.RelativeYY
    HUDFrame.ZIndex = 3

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = HUDFrame
    Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Main.BackgroundTransparency = 1.000
    Main.Size = UDim2.new(1, 0, 1, 0)

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Main
    UIListLayout.FillDirection = Enum.FillDirection.Horizontal
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    UIListLayout.Padding = UDim.new(0.00999999978, 0)

    -- 2. GameStats (The main info box)
    local GameStats = Instance.new("Frame")
    GameStats.Name = "GameStats"
    GameStats.Parent = Main
    GameStats.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    GameStats.BackgroundTransparency = 0.500
    GameStats.BorderColor3 = Color3.fromRGB(27, 42, 53)
    GameStats.BorderSizePixel = 0
    GameStats.LayoutOrder = 3
    GameStats.Position = UDim2.new(0.330083579, 0, 0.178413421, 0)
    GameStats.Size = UDim2.new(0, 348, 0, 73)

    local GameStatsCorner = Instance.new("UICorner")
    GameStatsCorner.CornerRadius = UDim.new(0, 9)
    GameStatsCorner.Parent = GameStats

    -- 3. Time Text
    local TimeText = Instance.new("TextLabel")
    TimeText.Name = "TimeText"
    TimeText.Parent = GameStats
    TimeText.BackgroundTransparency = 1.000
    TimeText.Position = UDim2.new(0.017283421, 0, 0.162744388, 0)
    TimeText.Size = UDim2.new(0.5, 0, 0.699999988, 0)
    TimeText.Font = Enum.Font.Highway
    TimeText.Text = "0:00.000"
    -- Original script uses this huge value which clamps to white
    TimeText.TextColor3 = Color3.fromRGB(255, 255, 255) 
    TimeText.TextScaled = true
    TimeText.TextSize = 45.000
    TimeText.TextWrapped = true

    local TimeTextConstraint = Instance.new("UITextSizeConstraint")
    TimeTextConstraint.MaxTextSize = 45
    TimeTextConstraint.Parent = TimeText

    -- 4. Counts (Savestates/Frames)
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
    SavestatesCount.TextSize = 22.000
    SavestatesCount.TextWrapped = true
    local SCConstraint = Instance.new("UITextSizeConstraint")
    SCConstraint.MaxTextSize = 22
    SCConstraint.Parent = SavestatesCount

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
    FrameCount.TextSize = 22.000
    FrameCount.TextWrapped = true
    local FCConstraint = Instance.new("UITextSizeConstraint")
    FCConstraint.MaxTextSize = 22
    FCConstraint.Parent = FrameCount

    -- 5. Toggle Button
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Name = "ShowKeybinds"
    KeybindButton.Parent = GameStats
    KeybindButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    KeybindButton.BackgroundTransparency = 1.000
    KeybindButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
    KeybindButton.BorderSizePixel = 0
    KeybindButton.Position = UDim2.new(0, 190, 0, 42)
    KeybindButton.Size = UDim2.new(0, 149, 0, 33)
    KeybindButton.Font = Enum.Font.Highway
    KeybindButton.Text = "Show Keybinds"
    KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeybindButton.TextSize = 20.000

    -- 6. Main DropShadow
    local DropShadowHolder = Instance.new("Frame")
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = GameStats
    DropShadowHolder.BackgroundTransparency = 1.000
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
    DropShadowHolder.ZIndex = 0

    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1.000
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 47, 1, 47)
    DropShadow.ZIndex = 0
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.500
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

    -- 7. Keybind Frame (The menu)
    local KeyBindFrame = Instance.new("Frame")
    KeyBindFrame.Name = "KeyBindFrame"
    KeyBindFrame.Parent = Main
    KeyBindFrame.Active = true
    KeyBindFrame.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    KeyBindFrame.BackgroundTransparency = 1.000
    KeyBindFrame.BorderColor3 = Color3.fromRGB(27, 42, 53)
    KeyBindFrame.BorderSizePixel = 0
    KeyBindFrame.LayoutOrder = 3
    KeyBindFrame.Position = UDim2.new(0.548381984, 0, -2.41520619, 0)
    KeyBindFrame.Size = UDim2.new(-0.0219492037, 278, 3.51520572, 0)
    KeyBindFrame.Visible = false

    local KBList = Instance.new("UIListLayout")
    KBList.Parent = KeyBindFrame
    KBList.SortOrder = Enum.SortOrder.LayoutOrder
    KBList.Padding = UDim.new(0, -4)

    local function CreateLabel(text, color, name)
        local L = Instance.new("TextLabel")
        L.Name = name or "Info"
        L.Parent = KeyBindFrame
        L.BackgroundTransparency = 1.000
        L.Size = UDim2.new(1, 0, 0.112999998, 0)
        L.Font = Enum.Font.Highway
        L.Text = text
        L.TextColor3 = color or Color3.fromRGB(65025, 65025, 65025)
        L.TextScaled = true
        L.TextSize = 18.000
        L.TextWrapped = true
        local C = Instance.new("UITextSizeConstraint")
        C.MaxTextSize = 18
        C.Parent = L
        return L
    end

    local CapLockStatus = CreateLabel("CapsLock : Paused", Color3.fromRGB(255, 255, 0), "CapLockPause")
    CreateLabel("One : Add a Savestate", nil, "SaveStateInfo")
    CreateLabel("Two : Remove a Savestate", nil, "RemoveSaveStateInfo")
    CreateLabel("Three : Go To Last SaveState", nil, "GoBackSavestate")
    CreateLabel("Four : Go Back a Frame", nil, "GoFrameBack")
    CreateLabel("Five : Go a Frame Forward", nil, "GoFrameForward")
    CreateLabel("Six : SaveRun", nil, "SaveRun")
    CreateLabel("C : CanCollide Toggle", nil, "CanCollideToggle")
    CreateLabel("Delete: Stop Creating", nil, "Reset to normal")
    CreateLabel("Zero: View TAS", nil, "Viewtas")

    -- 8. Keybind Shadow (Separate hierarchy in original)
    local Main2 = Instance.new("Frame")
    Main2.Name = "Main2"
    Main2.Parent = HUD
    Main2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Main2.BackgroundTransparency = 1.000
    Main2.Size = UDim2.new(1, 0, 1, 0)
    Main2.ZIndex = -1

    local ShadowThingy = Instance.new("Frame")
    ShadowThingy.Name = "Dropshadowthingy"
    ShadowThingy.Parent = Main2
    ShadowThingy.Active = true
    ShadowThingy.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    ShadowThingy.BackgroundTransparency = 0.500
    ShadowThingy.BorderColor3 = Color3.fromRGB(27, 42, 53)
    ShadowThingy.BorderSizePixel = 0
    ShadowThingy.LayoutOrder = 3
    ShadowThingy.Position = UDim2.new(0, 602, 0, -165)
    ShadowThingy.Size = UDim2.new(-0.0219999999, 278, 3.41499996, 0)
    ShadowThingy.Visible = false
    ShadowThingy.ZIndex = -2

    local ShadowHolder2 = Instance.new("Frame")
    ShadowHolder2.Name = "DropShadowHolder"
    ShadowHolder2.Parent = ShadowThingy
    ShadowHolder2.BackgroundTransparency = 1.000
    ShadowHolder2.BorderSizePixel = 0
    ShadowHolder2.Position = UDim2.new(-4.49821499e-07, 0, -0.0830525681, 0)
    ShadowHolder2.Size = UDim2.new(1.00852144, 0, 1.08305275, 0)
    ShadowHolder2.ZIndex = 0

    local DropShadow2 = Instance.new("ImageLabel")
    DropShadow2.Name = "DropShadow"
    DropShadow2.Parent = ShadowHolder2
    DropShadow2.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow2.BackgroundTransparency = 1.000
    DropShadow2.BorderSizePixel = 0
    DropShadow2.Position = UDim2.new(0.497877091, 0, 0.535654724, 0)
    DropShadow2.Size = UDim2.new(1.19575405, 0, 1.08791792, 0)
    DropShadow2.ZIndex = 0
    DropShadow2.Image = "rbxassetid://6015897843"
    DropShadow2.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow2.ImageTransparency = 0.500
    DropShadow2.ScaleType = Enum.ScaleType.Slice
    DropShadow2.SliceCenter = Rect.new(49, 49, 450, 450)

    local SC1 = Instance.new("UICorner")
    SC1.CornerRadius = UDim.new(0, 9)
    SC1.Parent = DropShadow2

    local SC2 = Instance.new("UICorner")
    SC2.CornerRadius = UDim.new(0, 9)
    SC2.Parent = ShadowHolder2
    
    local SC3 = Instance.new("UICorner")
    SC3.CornerRadius = UDim.new(0, 9)
    SC3.Parent = ShadowThingy

    -- 9. Map Event Info
    local MapEventInfo = Instance.new("TextLabel")
    MapEventInfo.Name = "MapEventInfo"
    MapEventInfo.Parent = HUD
    MapEventInfo.AnchorPoint = Vector2.new(0.5, 1)
    MapEventInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MapEventInfo.BackgroundTransparency = 1.000
    MapEventInfo.Position = UDim2.new(0.5, 0, -0.100000001, 0)
    MapEventInfo.Size = UDim2.new(1.20000005, 0, 0, 0)
    MapEventInfo.Text = ""
    MapEventInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    MapEventInfo.TextScaled = true
    MapEventInfo.TextSize = 14.000
    MapEventInfo.TextStrokeTransparency = 0.625
    MapEventInfo.TextWrapped = true
    MapEventInfo.Font = Enum.Font.Highway

    local MEIGradient = Instance.new("UIGradient")
    MEIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(184, 184, 184))
    }
    MEIGradient.Rotation = 90
    MEIGradient.Parent = MapEventInfo

    -- 10. Toggle Logic
    KeybindButton.Activated:Connect(function()
        KeyBindFrame.Visible = not KeyBindFrame.Visible
        ShadowThingy.Visible = not ShadowThingy.Visible
        if KeyBindFrame.Visible then
            KeybindButton.Text = "Hide Keybinds"
        else
            KeybindButton.Text = "Show Keybinds"
        end
    end)

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
