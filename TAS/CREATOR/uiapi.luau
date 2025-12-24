--[[ 
    FE2 TAS UI Library (Fixed Shadows)
    - Fixed Scale/Offset mismatch that caused the background 
      to drift away from the text on different resolutions.
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

    -- Main Layers
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = HUDFrame
    Main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Main.BackgroundTransparency = 1.000
    Main.Size = UDim2.new(1, 0, 1, 0)

    -- Background Layer (for shadows)
    local Main2 = Instance.new("Frame")
    Main2.Name = "Main2"
    Main2.Parent = HUDFrame
    Main2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Main2.BackgroundTransparency = 1.000
    Main2.Size = UDim2.new(1, 0, 1, 0)
    Main2.ZIndex = -1

    -- 2. GameStats Box
    local GameStats = Instance.new("Frame")
    GameStats.Name = "GameStats"
    GameStats.Parent = Main
    GameStats.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    GameStats.BackgroundTransparency = 0.500
    GameStats.BorderColor3 = Color3.fromRGB(27, 42, 53)
    GameStats.BorderSizePixel = 0
    GameStats.Position = UDim2.new(0.330083579, 0, 0.178413421, 0)
    GameStats.Size = UDim2.new(0, 348, 0, 73)

    local GSCorner = Instance.new("UICorner")
    GSCorner.CornerRadius = UDim.new(0, 9)
    GSCorner.Parent = GameStats

    -- 3. Info Text
    local TimeText = Instance.new("TextLabel")
    TimeText.Name = "TimeText"
    TimeText.Parent = GameStats
    TimeText.BackgroundTransparency = 1.000
    TimeText.Position = UDim2.new(0.017, 0, 0.162, 0)
    TimeText.Size = UDim2.new(0.5, 0, 0.699, 0)
    TimeText.Font = Enum.Font.Highway
    TimeText.Text = "0:00.000"
    TimeText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TimeText.TextScaled = true
    TimeText.TextWrapped = true

    local TConstraint = Instance.new("UITextSizeConstraint")
    TConstraint.MaxTextSize = 45
    TConstraint.Parent = TimeText

    -- Counters
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
    local FCConstraint = Instance.new("UITextSizeConstraint")
    FCConstraint.MaxTextSize = 22
    FCConstraint.Parent = FrameCount

    -- Toggle Button
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Name = "ShowKeybinds"
    KeybindButton.Parent = GameStats
    KeybindButton.BackgroundTransparency = 1.000
    KeybindButton.Position = UDim2.new(0, 190, 0, 42)
    KeybindButton.Size = UDim2.new(0, 149, 0, 33)
    KeybindButton.Font = Enum.Font.Highway
    KeybindButton.Text = "Show Keybinds"
    KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeybindButton.TextSize = 20.000

    -- GameStats Shadow
    local DSH = Instance.new("Frame")
    DSH.Name = "DropShadowHolder"
    DSH.Parent = GameStats
    DSH.BackgroundTransparency = 1.000
    DSH.Size = UDim2.new(1, 0, 1, 0)
    DSH.ZIndex = 0

    local DS = Instance.new("ImageLabel")
    DS.Parent = DSH
    DS.AnchorPoint = Vector2.new(0.5, 0.5)
    DS.BackgroundTransparency = 1.000
    DS.Position = UDim2.new(0.5, 0, 0.5, 0)
    DS.Size = UDim2.new(1, 47, 1, 47)
    DS.ZIndex = 0
    DS.Image = "rbxassetid://6015897843"
    DS.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DS.ImageTransparency = 0.500
    DS.ScaleType = Enum.ScaleType.Slice
    DS.SliceCenter = Rect.new(49, 49, 450, 450)

    -- 4. Keybind List (The Frame)
    -- Using the specific Scale coordinates from the source
    local TargetPosition = UDim2.new(0.548381984, 0, -2.41520619, 0)
    local TargetSize = UDim2.new(-0.0219492037, 278, 3.51520572, 0)

    local KeyBindFrame = Instance.new("Frame")
    KeyBindFrame.Name = "KeyBindFrame"
    KeyBindFrame.Parent = Main
    KeyBindFrame.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    KeyBindFrame.BackgroundTransparency = 1.000
    KeyBindFrame.Position = TargetPosition
    KeyBindFrame.Size = TargetSize
    KeyBindFrame.Visible = false

    local KBList = Instance.new("UIListLayout")
    KBList.Parent = KeyBindFrame
    KBList.SortOrder = Enum.SortOrder.LayoutOrder
    KBList.Padding = UDim.new(0, -4)

    local function CreateLabel(text, color)
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

    -- 5. Keybind Background Shadow
    local ShadowThingy = Instance.new("Frame")
    ShadowThingy.Name = "Dropshadowthingy"
    ShadowThingy.Parent = Main2
    ShadowThingy.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    ShadowThingy.BackgroundTransparency = 0.500
    -- FIXED: FORCE POSITION TO MATCH KEYBIND FRAME EXACTLY
    ShadowThingy.Position = TargetPosition 
    -- FIXED: SIZE MATCHING
    ShadowThingy.Size = TargetSize
    ShadowThingy.Visible = false
    ShadowThingy.ZIndex = -2

    local SC3 = Instance.new("UICorner")
    SC3.CornerRadius = UDim.new(0, 9)
    SC3.Parent = ShadowThingy

    -- Inner Shadow for the Keybind box
    local ShadowHolder2 = Instance.new("Frame")
    ShadowHolder2.Parent = ShadowThingy
    ShadowHolder2.BackgroundTransparency = 1.000
    ShadowHolder2.Size = UDim2.new(1.008, 0, 1.083, 0)
    ShadowHolder2.Position = UDim2.new(0, 0, -0.083, 0)
    ShadowHolder2.ZIndex = 0

    local DS2 = Instance.new("ImageLabel")
    DS2.Parent = ShadowHolder2
    DS2.AnchorPoint = Vector2.new(0.5, 0.5)
    DS2.BackgroundTransparency = 1.000
    DS2.Position = UDim2.new(0.5, 0, 0.5, 0)
    DS2.Size = UDim2.new(1.2, 0, 1.08, 0)
    DS2.ZIndex = 0
    DS2.Image = "rbxassetid://6015897843"
    DS2.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DS2.ImageTransparency = 0.500
    DS2.ScaleType = Enum.ScaleType.Slice
    DS2.SliceCenter = Rect.new(49, 49, 450, 450)

    local SC1 = Instance.new("UICorner")
    SC1.CornerRadius = UDim.new(0, 9)
    SC1.Parent = DS2

    -- 6. Map Event Info
    local MapEventInfo = Instance.new("TextLabel")
    MapEventInfo.Name = "MapEventInfo"
    MapEventInfo.Parent = HUD
    MapEventInfo.AnchorPoint = Vector2.new(0.5, 1)
    MapEventInfo.BackgroundTransparency = 1.000
    MapEventInfo.Position = UDim2.new(0.5, 0, -0.1, 0)
    MapEventInfo.Size = UDim2.new(1.2, 0, 0, 0)
    MapEventInfo.Text = ""
    MapEventInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    MapEventInfo.TextScaled = true
    MapEventInfo.Font = Enum.Font.Highway

    local MEIGradient = Instance.new("UIGradient")
    MEIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(184, 184, 184))
    }
    MEIGradient.Rotation = 90
    MEIGradient.Parent = MapEventInfo

    -- Toggle Logic
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
