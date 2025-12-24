--[[ 
    FE2 TAS UI Library (Fixed Shadows & Alignment)
]]

local TAS_UI = {}

function TAS_UI.Create()
    local CoreGui = game:GetService("CoreGui")
    
    -- // 1. Main ScreenGui //
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "TAS_HUD"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

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

    -- Main Container Layer
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

    -- // 3. Game Stats Box (Bottom Center) //
    local GameStats = Instance.new("Frame")
    GameStats.Name = "GameStats"
    GameStats.Parent = MainContainer
    GameStats.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    GameStats.BackgroundTransparency = 0.500
    GameStats.BorderColor3 = Color3.fromRGB(27, 42, 53)
    GameStats.BorderSizePixel = 0
    GameStats.Position = UDim2.new(0.33, 0, 0.178, 0)
    GameStats.Size = UDim2.new(0, 348, 0, 73)

    local GSCorner = Instance.new("UICorner")
    GSCorner.CornerRadius = UDim.new(0, 9)
    GSCorner.Parent = GameStats

    -- // 4. Information Labels //
    
    -- Timer
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
    
    local TimeConstraint = Instance.new("UITextSizeConstraint")
    TimeConstraint.MaxTextSize = 45
    TimeConstraint.Parent = TimeText

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

    -- Toggle Button
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

    -- // 5. Keybinds Menu (Foreground) //
    -- Original scale coordinates from the TAS Creator source
    local KB_Position = UDim2.new(0.54838, 0, -2.4152, 0)
    local KB_Size = UDim2.new(-0.02195, 278, 3.5152, 0)

    local KeyBindFrame = Instance.new("Frame")
    KeyBindFrame.Name = "KeyBindFrame"
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

    -- // 6. Keybinds Shadow (Background) //
    -- FIX: Force the shadow frame to use the exact same Scale coordinates as the text frame
    -- The original used Offset which caused it to drift on different resolutions.
    local ShadowFrame = Instance.new("Frame")
    ShadowFrame.Name = "ShadowFrame"
    ShadowFrame.Parent = BackgroundLayer
    ShadowFrame.BackgroundColor3 = Color3.fromRGB(22, 31, 40)
    ShadowFrame.BackgroundTransparency = 0.500
    ShadowFrame.Position = KB_Position -- Matched
    ShadowFrame.Size = KB_Size         -- Matched
    ShadowFrame.Visible = false
    ShadowFrame.ZIndex = -2

    local ShadowCorner = Instance.new("UICorner")
    ShadowCorner.CornerRadius = UDim.new(0, 9)
    ShadowCorner.Parent = ShadowFrame

    -- Inner Shadow Image
    local ShadowHolder = Instance.new("Frame")
    ShadowHolder.BackgroundTransparency = 1.000
    ShadowHolder.Size = UDim2.new(1.008, 0, 1.083, 0)
    ShadowHolder.Position = UDim2.new(0, 0, -0.083, 0)
    ShadowHolder.Parent = ShadowFrame
    
    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Parent = ShadowHolder
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1.000
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1.2, 0, 1.08, 0)
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 0.500
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    
    local DSCorner = Instance.new("UICorner")
    DSCorner.CornerRadius = UDim.new(0, 9)
    DSCorner.Parent = DropShadow

    -- // 7. Labels Helper //
    local function CreateLabel(text, color)
        local L = Instance.new("TextLabel")
        L.Parent = KeyBindFrame
        L.BackgroundTransparency = 1.000
        L.Size = UDim2.new(1, 0, 0.113, 0)
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

    -- // 8. Map Event Info //
    local MapEventInfo = Instance.new("TextLabel")
    MapEventInfo.Parent = HUDFrame
    MapEventInfo.BackgroundTransparency = 1.000
    MapEventInfo.Position = UDim2.new(0.5, 0, -0.1, 0)
    MapEventInfo.Size = UDim2.new(1.2, 0, 0, 0)
    MapEventInfo.Font = Enum.Font.Highway
    MapEventInfo.Text = ""
    MapEventInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
    MapEventInfo.TextScaled = true
    
    local MEIGradient = Instance.new("UIGradient")
    MEIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(184, 184, 184))
    }
    MEIGradient.Rotation = 90
    MEIGradient.Parent = MapEventInfo

    -- // 9. Toggle Logic //
    KeybindButton.Activated:Connect(function()
        KeyBindFrame.Visible = not KeyBindFrame.Visible
        ShadowFrame.Visible = not ShadowFrame.Visible
        if KeyBindFrame.Visible then
            KeybindButton.Text = "Hide Keybinds"
        else
            KeybindButton.Text = "Show Keybinds"
        end
    end)

    return {
        ScreenGui = ScreenGui,
        TimeText = TimeText,
        SavestatesCount = SavestatesCount,
        FrameCount = FrameCount,
        KeybindButton = KeybindButton,
        StatusText = CapLockStatus,
        MapEventInfo = MapEventInfo
    }
end

return TAS_UI
