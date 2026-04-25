-- ═══════════════════════════════════════════════
--   H2N Desync + SPEED CONTROL  —  Standalone Script
--   Discord: discord.gg/7xzsux4kzx
-- ═══════════════════════════════════════════════

repeat task.wait() until game:IsLoaded()
if not game.PlaceId then repeat task.wait(1) until game.PlaceId end

local Players    = game:GetService("Players")
local UIS        = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LP         = Players.LocalPlayer

local Char, HRP, Hum
local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled

local function Setup(c)
    Char = c
    HRP  = c:WaitForChild("HumanoidRootPart")
    Hum  = c:WaitForChild("Humanoid")
    pcall(function() HRP:SetNetworkOwner(LP) end)
end
if LP.Character then Setup(LP.Character) end
LP.CharacterAdded:Connect(function(c) task.wait(0.1); Setup(c) end)

-- ══════════════════════════════════════
--  THEME — Royal Gold × Obsidian
-- ══════════════════════════════════════
local T = {
    A   = Color3.fromRGB(255, 215, 100),
    B   = Color3.fromRGB(230, 185, 60),
    C   = Color3.fromRGB(200, 155, 30),
    D   = Color3.fromRGB(255, 240, 180),
    Bg0 = Color3.fromRGB(4,   4,   8),
    Bg1 = Color3.fromRGB(8,   8,   14),
    Bg2 = Color3.fromRGB(13,  12,  22),
    Bg3 = Color3.fromRGB(18,  17,  30),
    Bg4 = Color3.fromRGB(26,  24,  42),
    Tx  = Color3.fromRGB(255, 240, 195),
    TxS = Color3.fromRGB(210, 185, 120),
    TxD = Color3.fromRGB(150, 125, 70),
    ON  = Color3.fromRGB(220, 175, 30),
    OFF = Color3.fromRGB(20,  18,  35),
    Suc = Color3.fromRGB(80,  230, 120),
    Err = Color3.fromRGB(255, 70,  70),
    Br  = Color3.fromRGB(255, 210, 60),
    BrS = Color3.fromRGB(180, 140, 30),
    BrD = Color3.fromRGB(80,  65,  15),
}

-- ══════════════════════════════════════
--  GOLD GRADIENT / SHIMMER HELPERS
-- ══════════════════════════════════════
local function makeGoldGradient()
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(8,   6,   0)),
        ColorSequenceKeypoint.new(0.15, Color3.fromRGB(60,  45,  5)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(180, 135, 20)),
        ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(255, 225, 80)),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(180, 135, 20)),
        ColorSequenceKeypoint.new(0.85, Color3.fromRGB(60,  45,  5)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(8,   6,   0)),
    })
end

local GOLD_CYCLE = {
    Color3.fromRGB(255,215,100), Color3.fromRGB(255,245,180),
    Color3.fromRGB(220,165, 30), Color3.fromRGB(255,200, 60),
    Color3.fromRGB(255,255,220),
}

local function applySpinningGoldStroke(parent, thickness, speed)
    thickness = thickness or 2; speed = speed or 1.4
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = thickness
    stroke.Parent = parent
    local grad = Instance.new("UIGradient", stroke)
    grad.Color = makeGoldGradient()
    grad.Rotation = math.random(0, 360)
    task.spawn(function()
        local t = math.random() * 10
        while parent and parent.Parent do
            t = t + 0.12
            grad.Rotation = (grad.Rotation + speed) % 360
            local i = math.floor(t * 1.5) % #GOLD_CYCLE + 1
            stroke.Color     = GOLD_CYCLE[i]:Lerp(GOLD_CYCLE[i % #GOLD_CYCLE + 1], (t*1.5)%1)
            stroke.Thickness = thickness + math.abs(math.sin(t * 2)) * 1.0
            task.wait(0.12)
        end
    end)
    return stroke
end

local function addBgShimmer(parent, speed, alpha)
    local ov = Instance.new("Frame", parent)
    ov.Size = UDim2.new(1,0,1,0)
    ov.BackgroundColor3 = Color3.fromRGB(200,150,20)
    ov.BackgroundTransparency = alpha or 0.82
    ov.BorderSizePixel = 0
    ov.ZIndex = (parent.ZIndex or 1) + 1
    ov.Active = false; ov.Selectable = false
    local c = parent:FindFirstChildOfClass("UICorner")
    if c then Instance.new("UICorner", ov).CornerRadius = c.CornerRadius end
    local g = Instance.new("UIGradient", ov)
    g.Color    = makeGoldGradient()
    g.Rotation = math.random(0, 360)
    task.spawn(function()
        while ov and ov.Parent do
            g.Rotation = (g.Rotation + (speed or 1.4)) % 360
            task.wait(0.12)
        end
    end)
    return ov
end

-- ══════════════════════════════════════
--  NOTIFICATION
-- ══════════════════════════════════════
local gui = Instance.new("ScreenGui")
gui.Name = "H2N_GUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.Parent = LP:WaitForChild("PlayerGui")

local function Notify(txt)
    local f = Instance.new("Frame", gui)
    f.Size = UDim2.new(0, 210, 0, 32)
    f.Position = UDim2.new(1, 10, 1, -80)
    f.BackgroundColor3 = T.Bg2
    f.BackgroundTransparency = 0.05
    f.ZIndex = 200
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    applySpinningGoldStroke(f, 1.5, 1.8)
    addBgShimmer(f, 1.6, 0.88)
    local accent = Instance.new("Frame", f)
    accent.Size = UDim2.new(0, 3, 1, -6)
    accent.Position = UDim2.new(0, 4, 0, 3)
    accent.BackgroundColor3 = T.Br
    accent.BorderSizePixel = 0
    accent.ZIndex = 202
    Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -14, 1, 0)
    lbl.Position = UDim2.new(0, 13, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = txt
    lbl.TextColor3 = T.Tx
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.ZIndex = 203
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        { Position = UDim2.new(1, -225, 1, -80) }):Play()
    task.spawn(function()
        task.wait(3)
        TweenService:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            { Position = UDim2.new(1, 10, 1, -80), BackgroundTransparency = 1 }):Play()
        task.wait(0.26); f:Destroy()
    end)
end

-- ══════════════════════════════════════
--  SPEED STATE
-- ══════════════════════════════════════
local CFG_FILE = "H2N_Config.json"
local HttpService = game:GetService("HttpService")

local SpeedSettings = {
    NormalSpeed   = 43,
    BrainrotSpeed = 17,
}

local function SaveConfig()
    pcall(function()
        if writefile then
            writefile(CFG_FILE, HttpService:JSONEncode({
                NormalSpeed   = SpeedSettings.NormalSpeed,
                BrainrotSpeed = SpeedSettings.BrainrotSpeed,
            }))
        end
    end)
end

local function LoadConfig()
    pcall(function()
        if readfile then
            local raw = readfile(CFG_FILE)
            if raw and raw ~= "" then
                local ok, d = pcall(function() return HttpService:JSONDecode(raw) end)
                if ok and type(d) == "table" then
                    if type(d.NormalSpeed)   == "number" then SpeedSettings.NormalSpeed   = math.clamp(d.NormalSpeed,   1, 300) end
                    if type(d.BrainrotSpeed) == "number" then SpeedSettings.BrainrotSpeed = math.clamp(d.BrainrotSpeed, 1, 300) end
                end
            end
        end
    end)
end

LoadConfig()

local isSpeedBoostEnabled = false
local speedConn = nil

local function isHoldingBrainrot()
    local char = LP.Character
    if not char then return false end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") and (child.Name:lower():find("brainrot") or child.Name:lower():find("brain")) then
            return true
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed < 27 then return true end
    return false
end

local function startSpeedBoost()
    if isSpeedBoostEnabled then return end
    isSpeedBoostEnabled = true
    if speedConn then speedConn:Disconnect() end
    speedConn = RunService.Heartbeat:Connect(function()
        if not isSpeedBoostEnabled then return end
        local char = LP.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0.1 then
            local targetSpeed = isHoldingBrainrot() and SpeedSettings.BrainrotSpeed or SpeedSettings.NormalSpeed
            local targetX = moveDir.X * targetSpeed
            local targetZ = moveDir.Z * targetSpeed
            local curVel = hrp.AssemblyLinearVelocity
            local diffX = targetX - curVel.X
            local diffZ = targetZ - curVel.Z
            if math.abs(diffX) > targetSpeed * 0.5 or math.abs(diffZ) > targetSpeed * 0.5 then
                hrp.AssemblyLinearVelocity = Vector3.new(targetX, curVel.Y, targetZ)
            else
                local smooth = 0.7
                hrp.AssemblyLinearVelocity = Vector3.new(
                    curVel.X + diffX * smooth, curVel.Y, curVel.Z + diffZ * smooth)
            end
        else
            local curVel = hrp.AssemblyLinearVelocity
            if math.abs(curVel.X) > 1 or math.abs(curVel.Z) > 1 then
                hrp.AssemblyLinearVelocity = Vector3.new(curVel.X * 0.7, curVel.Y, curVel.Z * 0.7)
            end
        end
    end)
    if Hum then Hum.UseJumpPower = true; Hum.JumpPower = 45 end
end

local function stopSpeedBoost()
    if not isSpeedBoostEnabled then return end
    isSpeedBoostEnabled = false
    if speedConn then speedConn:Disconnect(); speedConn = nil end
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0) end
    end
end

-- ══════════════════════════════════════
--  DESYNC STATE
-- ══════════════════════════════════════
local DesyncState = { enabled = false }

local function startDesync()
    if DesyncState.enabled then return end
    DesyncState.enabled = true
    pcall(function() raknet.desync(true) end)
    pcall(function()
        local char = LP.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.Health = 0
        end
    end)
    -- تشغيل السرعة تلقائياً مع الـ desync
    startSpeedBoost()
    Notify("DESYNC ON")
end

local function stopDesync()
    if not DesyncState.enabled then return end
    DesyncState.enabled = false
    pcall(function() raknet.desync(false) end)
    -- إيقاف السرعة مع الـ desync
    stopSpeedBoost()
    Notify("DESYNC OFF")
end

-- ══════════════════════════════════════
--  DISCORD LABEL ABOVE PLAYER
-- ══════════════════════════════════════
task.spawn(function()
    repeat task.wait() until Char and Char:FindFirstChild("HumanoidRootPart")
    local bb = Instance.new("BillboardGui")
    bb.Name = "DSX_DiscordBB"
    bb.Size = UDim2.new(0, 160, 0, 22)
    bb.StudsOffset = Vector3.new(0, 3.8, 0)
    bb.AlwaysOnTop = true
    bb.ResetOnSpawn = false
    bb.LightInfluence = 0
    bb.Adornee = Char:FindFirstChild("HumanoidRootPart")
    bb.Parent = gui

    local lbl = Instance.new("TextLabel", bb)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.Text = "discord.gg/7xzsux4kzx"
    lbl.TextStrokeTransparency = 0.3
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    local tg = Instance.new("UIGradient", lbl)
    tg.Color    = makeGoldGradient()
    tg.Rotation = 0

    RunService.RenderStepped:Connect(function()
        if not Char or not Char:FindFirstChild("HumanoidRootPart") then
            bb.Adornee = nil; return
        end
        bb.Adornee = Char:FindFirstChild("HumanoidRootPart")
        tg.Rotation = (tg.Rotation + 2) % 360
        local t2 = tick()
        local i = math.floor(t2 * 1.5) % #GOLD_CYCLE + 1
        lbl.TextColor3 = GOLD_CYCLE[i]:Lerp(GOLD_CYCLE[i%#GOLD_CYCLE+1], (t2*1.5)%1)
    end)

    LP.CharacterAdded:Connect(function(c)
        task.wait(0.5); Char = c
        local hrp = c:WaitForChild("HumanoidRootPart", 5)
        if hrp then bb.Adornee = hrp end
    end)
end)

-- ══════════════════════════════════════
--  INFO BAR  (discord link top-center)
-- ══════════════════════════════════════
do
    local infoSG = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
    infoSG.Name = "DSX_InfoBar"
    infoSG.ResetOnSpawn = false
    infoSG.ZIndexBehavior = Enum.ZIndexBehavior.Global
    infoSG.DisplayOrder = 998

    local bar = Instance.new("Frame", infoSG)
    bar.Size = UDim2.new(0, 240, 0, 32)
    bar.Position = UDim2.new(0.5, -120, 0, -4)
    bar.BackgroundColor3 = T.Bg1
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 10)
    local barStroke = applySpinningGoldStroke(bar, 1.8, 1.2)

    local titleLbl = Instance.new("TextLabel", bar)
    titleLbl.Size = UDim2.new(0.4, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 8, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "H2N DESYNC"
    titleLbl.TextColor3 = T.A
    titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.TextSize = 15
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 2

    local discLbl = Instance.new("TextLabel", bar)
    discLbl.Size = UDim2.new(0.58, 0, 0, 12)
    discLbl.Position = UDim2.new(0.4, 0, 1, -14)
    discLbl.BackgroundTransparency = 1
    discLbl.Text = "discord.gg/7xzsux4kzx"
    discLbl.TextColor3 = T.TxD
    discLbl.Font = Enum.Font.GothamBold
    discLbl.TextSize = 9
    discLbl.TextXAlignment = Enum.TextXAlignment.Right
    discLbl.ZIndex = 2

    task.spawn(function()
        local t = 0
        while bar and bar.Parent do
            t = t + 0.05
            local g = 0.5 + 0.5 * math.sin(t * 2)
            barStroke.Color = Color3.fromRGB(
                math.floor(220 + g*35), math.floor(165 + g*70), math.floor(20 + g*40))
            task.wait(0.12)
        end
    end)
end

-- ══════════════════════════════════════════════════════════
--  MAIN MENU  (draggable, with collapsible speed panel)
-- ══════════════════════════════════════════════════════════
local menuW, menuH = 260, 130
local speedPanelH  = 144  -- panel that slides down

local menu = Instance.new("Frame", gui)
menu.Name = "DSX_Menu"
menu.Size = UDim2.new(0, menuW, 0, menuH)
menu.Position = UDim2.new(0.5, -menuW/2, 0.5, -menuH/2)
menu.BackgroundColor3 = T.Bg1
menu.BackgroundTransparency = 0
menu.Active = true
menu.ZIndex = 55
menu.ClipsDescendants = true
Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 14)
applySpinningGoldStroke(menu, 2.2, 1.6)
addBgShimmer(menu, 1.1, 0.83)

-- HEADER
local header = Instance.new("Frame", menu)
header.Size = UDim2.new(1, 0, 0, 46)
header.BackgroundColor3 = T.ON
header.BackgroundTransparency = 0
header.BorderSizePixel = 0
header.ZIndex = 56
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
local hFix = Instance.new("Frame", header)
hFix.Size = UDim2.new(1, 0, 0.5, 0)
hFix.Position = UDim2.new(0, 0, 0.5, 0)
hFix.BackgroundColor3 = T.ON
hFix.BorderSizePixel = 0
hFix.ZIndex = 56
addBgShimmer(header, 2.0, 0.62)

local titleLabel = Instance.new("TextLabel", header)
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "H2N DESYNC"
titleLabel.TextColor3 = Color3.fromRGB(255, 240, 195)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.ZIndex = 57

local accentLine = Instance.new("Frame", menu)
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 0, 42)
accentLine.BackgroundColor3 = T.Br
accentLine.BorderSizePixel = 0
accentLine.ZIndex = 57
task.spawn(function()
    local t = 0
    while true do
        t = t + 0.05
        local g = 0.5 + 0.5 * math.sin(t * 3)
        accentLine.BackgroundColor3 = Color3.fromRGB(
            math.floor(230 + g * 25), math.floor(168 + g * 72), math.floor(10 + g * 50))
        accentLine.Size = UDim2.new(1, 0, 0, math.floor(2 + g * 1.5))
        task.wait(0.05)
    end
end)

-- DRAG HEADER
do
    local dragging, dragStart, startPos, activeInput = false, nil, nil, nil
    header.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if (t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch) and not dragging then
            dragging = true; activeInput = input
            dragStart = input.Position; startPos = menu.Position
        end
    end)
    header.InputChanged:Connect(function(input)
        if not dragging or input ~= activeInput then return end
        local t = input.UserInputType
        if t ~= Enum.UserInputType.MouseMovement and t ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - dragStart
        menu.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end)
    header.InputEnded:Connect(function(input)
        local t = input.UserInputType
        if (t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch) then return end
        if input ~= activeInput then return end
        dragging = false; activeInput = nil
    end)
end

-- ══════════════════════════════════════
--  DESYNC TOGGLE ROW
-- ══════════════════════════════════════
local toggleRow = Instance.new("Frame", menu)
toggleRow.Size = UDim2.new(1, -16, 0, 44)
toggleRow.Position = UDim2.new(0, 8, 0, 50)
toggleRow.BackgroundColor3 = T.Bg3
toggleRow.BackgroundTransparency = 0
toggleRow.ZIndex = 58
Instance.new("UICorner", toggleRow).CornerRadius = UDim.new(0, 8)
applySpinningGoldStroke(toggleRow, 1.2, 1.1)
addBgShimmer(toggleRow, 1.0, 0.91)

local togLbl = Instance.new("TextLabel", toggleRow)
togLbl.Size = UDim2.new(0.55, 0, 1, 0)
togLbl.Position = UDim2.new(0, 10, 0, 0)
togLbl.BackgroundTransparency = 1
togLbl.Text = "H2N DESYNC"
togLbl.TextColor3 = T.Tx
togLbl.Font = Enum.Font.GothamBold
togLbl.TextSize = 14
togLbl.TextXAlignment = Enum.TextXAlignment.Left
togLbl.ZIndex = 59

local togBtn = Instance.new("TextButton", toggleRow)
togBtn.Size = UDim2.new(0, 76, 0, 28)
togBtn.Position = UDim2.new(1, -84, 0.5, -14)
togBtn.BackgroundColor3 = T.OFF
togBtn.Text = "OFF"
togBtn.TextColor3 = T.TxD
togBtn.Font = Enum.Font.GothamBold
togBtn.TextSize = 13
togBtn.AutoButtonColor = false
Instance.new("UICorner", togBtn).CornerRadius = UDim.new(0, 7)
local togBtnStk = applySpinningGoldStroke(togBtn, 1.2, 1.3)
addBgShimmer(togBtn, 1.3, 0.87)

local function RefreshToggleBtn()
    if DesyncState.enabled then
        togBtn.Text = "ON"
        togBtn.BackgroundColor3 = T.ON
        togBtn.TextColor3 = T.Bg0
        togBtnStk.Thickness = 2
    else
        togBtn.Text = "OFF"
        togBtn.BackgroundColor3 = T.OFF
        togBtn.TextColor3 = T.TxD
        togBtnStk.Thickness = 1.2
    end
end

togBtn.MouseButton1Click:Connect(function()
    if DesyncState.enabled then stopDesync() else startDesync() end
    RefreshToggleBtn()
end)

-- ══════════════════════════════════════════════════════════════
--  ARROW BUTTON  (bottom-right corner of menu) — toggles speed panel
-- ══════════════════════════════════════════════════════════════
local speedPanelOpen = false
local isAnimating    = false

-- The arrow sits at the bottom-right corner of the base menu
local arrowBtn = Instance.new("TextButton", menu)
arrowBtn.Size = UDim2.new(0, 28, 0, 22)
arrowBtn.Position = UDim2.new(1, -34, 1, -menuH + 4)   -- bottom edge of base area
arrowBtn.AnchorPoint = Vector2.new(0, 0)
arrowBtn.BackgroundColor3 = T.Bg4
arrowBtn.Text = "▼"
arrowBtn.TextColor3 = T.A
arrowBtn.Font = Enum.Font.GothamBold
arrowBtn.TextSize = 12
arrowBtn.AutoButtonColor = false
arrowBtn.ZIndex = 65
Instance.new("UICorner", arrowBtn).CornerRadius = UDim.new(0, 6)
applySpinningGoldStroke(arrowBtn, 1, 1.8)

-- Position the arrow at the bottom of the static area
local function repositionArrow()
    arrowBtn.Position = UDim2.new(1, -34, 0, menuH - 26)
end
repositionArrow()

-- ══════════════════════════════════════
--  SPEED PANEL  (lives below the base rows, clipped until open)
-- ══════════════════════════════════════
local speedPanel = Instance.new("Frame", menu)
speedPanel.Name = "SpeedPanel"
speedPanel.Size = UDim2.new(1, -16, 0, speedPanelH)
speedPanel.Position = UDim2.new(0, 8, 0, menuH)   -- starts hidden below clip
speedPanel.BackgroundColor3 = T.Bg2
speedPanel.BackgroundTransparency = 0
speedPanel.ZIndex = 58
speedPanel.ClipsDescendants = false
Instance.new("UICorner", speedPanel).CornerRadius = UDim.new(0, 10)
applySpinningGoldStroke(speedPanel, 1.5, 1.2)
addBgShimmer(speedPanel, 1.0, 0.85)

-- Speed panel title
local spTitle = Instance.new("TextLabel", speedPanel)
spTitle.Size = UDim2.new(1, 0, 0, 22)
spTitle.Position = UDim2.new(0, 10, 0, 4)
spTitle.BackgroundTransparency = 1
spTitle.Text = "SPEED CONTROL"
spTitle.TextColor3 = T.A
spTitle.Font = Enum.Font.GothamBlack
spTitle.TextSize = 11
spTitle.TextXAlignment = Enum.TextXAlignment.Left
spTitle.ZIndex = 59

-- helper: make a number box row inside the speed panel
local function MakeSpeedRow(parent, labelText, yOffset, defaultVal, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -10, 0, 34)
    row.Position = UDim2.new(0, 5, 0, yOffset)
    row.BackgroundColor3 = T.Bg3
    row.BackgroundTransparency = 0
    row.ZIndex = 60
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
    applySpinningGoldStroke(row, 1, 1.2)
    addBgShimmer(row, 1.0, 0.92)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = T.Tx
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 61

    local box = Instance.new("TextBox", row)
    box.Size = UDim2.new(0, 66, 0, 24)
    box.Position = UDim2.new(1, -72, 0.5, -12)
    box.BackgroundColor3 = T.Bg4
    box.Text = tostring(defaultVal)
    box.TextColor3 = T.Tx
    box.Font = Enum.Font.GothamBold
    box.TextSize = 14
    box.ZIndex = 61
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    applySpinningGoldStroke(box, 1, 1.4)
    addBgShimmer(box, 1.4, 0.87)

    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then
            n = math.clamp(n, 1, 300)
            callback(n)
            box.Text = tostring(n)
        else
            box.Text = tostring(defaultVal)
        end
    end)
    return box
end

local normalBox = MakeSpeedRow(speedPanel, "Normal Speed",  28,
    SpeedSettings.NormalSpeed, function(v)
        SpeedSettings.NormalSpeed = v
    end)

local brainrotBox = MakeSpeedRow(speedPanel, "Brainrot Speed", 66,
    SpeedSettings.BrainrotSpeed, function(v)
        SpeedSettings.BrainrotSpeed = v
    end)

-- SAVE BUTTON
local saveBtn = Instance.new("TextButton", speedPanel)
saveBtn.Size = UDim2.new(1, -10, 0, 26)
saveBtn.Position = UDim2.new(0, 5, 0, speedPanelH - 32)
saveBtn.BackgroundColor3 = T.Bg4
saveBtn.AutoButtonColor = false
saveBtn.Text = "💾  SAVE"
saveBtn.TextColor3 = T.A
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 12
saveBtn.ZIndex = 61
Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 7)
local saveBtnStk = applySpinningGoldStroke(saveBtn, 1.2, 1.5)
addBgShimmer(saveBtn, 1.5, 0.88)

local saveBusy = false
saveBtn.MouseButton1Click:Connect(function()
    if saveBusy then return end
    saveBusy = true
    SaveConfig()
    saveBtn.Text = "✓  SAVED"
    saveBtn.TextColor3 = T.Suc
    saveBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 30)
    saveBtnStk.Color = T.Suc
    task.wait(1.2)
    saveBtn.Text = "💾  SAVE"
    saveBtn.TextColor3 = T.A
    saveBtn.BackgroundColor3 = T.Bg4
    saveBtnStk.Color = T.Br
    saveBusy = false
end)

-- ══════════════════════════════════════
--  ARROW CLICK  — slide panel
-- ══════════════════════════════════════
arrowBtn.MouseButton1Click:Connect(function()
    if isAnimating then return end
    isAnimating = true
    speedPanelOpen = not speedPanelOpen

    local targetMenuH = speedPanelOpen and (menuH + speedPanelH + 8) or menuH
    arrowBtn.Text = speedPanelOpen and "▲" or "▼"

    TweenService:Create(menu,
        TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Size = UDim2.new(0, menuW, 0, targetMenuH) }
    ):Play()

    local panelTargetY = speedPanelOpen and (menuH + 4) or menuH
    TweenService:Create(speedPanel,
        TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        { Position = UDim2.new(0, 8, 0, panelTargetY) }
    ):Play()

    task.wait(0.36)
    isAnimating = false
    -- reposition arrow at bottom of base area always
    repositionArrow()
end)

-- ══════════════════════════════════════
--  KEEP REFRESHING DESYNC BTN
-- ══════════════════════════════════════
RunService.RenderStepped:Connect(RefreshToggleBtn)

-- ══════════════════════════════════════
--  LAUNCH NOTIFICATION
-- ══════════════════════════════════════
task.wait(0.5)
Notify("H2N Desync Loaded")
-- sync boxes with loaded config
if normalBox then normalBox.Text = tostring(SpeedSettings.NormalSpeed) end
if brainrotBox then brainrotBox.Text = tostring(SpeedSettings.BrainrotSpeed) end
print("=========================")
print("H2N Desync Standalone  —  discord.gg/7xzsux4kzx")
print("=========================")
