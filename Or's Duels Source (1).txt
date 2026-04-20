if not fireproximityprompt then
    fireproximityprompt = (getgenv and getgenv().fireproximityprompt)
        or (genv and genv().fireproximityprompt)
        or function(prompt)

            pcall(function()
                prompt:InputHoldBegin()
                task.wait(0.05)
                prompt:InputHoldEnd()
            end);
        end
end

local UIS          = game:GetService("UserInputService")
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui      = game:GetService("CoreGui")
local Workspace    = game:GetService("Workspace")
local HttpService  = game:GetService("HttpService")
local Lighting     = game:GetService("Lighting")
local Stats        = game:GetService("Stats")
local Camera       = Workspace.CurrentCamera

local lp = Players.LocalPlayer

local GLOBAL_CONFIG_FILE = "ORsDuel_Config.json"
local _globalConfig = {}

local function _saveGlobalConfig()
    if writefile then
        pcall(writefile, GLOBAL_CONFIG_FILE, HttpService:JSONEncode(_globalConfig))
    end
end

local _DEFAULT_CONFIG = {
    statsPanelPos   = {px=376, py=17},
    speedHubConfig  = {speedActive=true, notStealSpeed=58, px=341, py=65, rtnSpeed=30.3},
    grabBarPos      = {px=313, py=234},
    hitTPPos        = {px=129, py=93},
    spinConfig      = {velocidade=100, px=129, py=179},
    menuPos         = {px=43,  py=13},
    meleeAimConfig  = {px=494, py=20},
    floatConfig     = {autoFloatEnabled=false, px=129, py=49, power=10},
    tauntConfig     = {px=43,  py=53},
    hbBtnPos        = {px=8,   py=54},
    autoPlayConfig  = {px=129, py=136},
    aimBotConfig    = {px=130, py=7,  speed=62.3},
    wpBtnPos        = {px=16,  py=9},
    infoBarPos      = {px=304, py=6},
    duelPositions   = {
        P1x=-472.6094970703125,  P1y=-6.811800003051758,  P1z=90.1884994506836,
        P2x=-472.7843933105469,  P2y=-6.811800003051758,  P2z=91.6488037109375,
        PEXx=-486.3769226074219, PEXy=-4.577744483947754, PEXz=95.26581573486328,
        R1x=-473.0520935058594,  R1y=-6.811800003051758,  R1z=30.290199279785158,
        R2x=-473.19378662109377, R2y=-6.811800003051758,  R2z=28.322099685668947,
        REXx=-485.9707336425781, REXy=-4.627743244171143, REXz=25.178876876831056,
    },
    togglesState    = {
        desyncNoReset=false, desyncReset=false,
        speedCustomizer=false, spin=true,    autoTP=false,  noAnim=false,
        lock=true,  autoDuel=true,  hitTP=true,   meleeAimbot=false,
        playerEsp=true,  xrayBase=true,  hitboxExp=true,   autoSteal=true,
        fov=false,  float=true,  infJump=true,  optimizer=true,  antiRagdoll=true,
    },
}

local function _loadGlobalConfig()
    local loaded = false
    if isfile and isfile(GLOBAL_CONFIG_FILE) then
        local ok, raw = pcall(readfile, GLOBAL_CONFIG_FILE)
        if ok and raw then
            local ok2, d = pcall(HttpService.JSONDecode, HttpService, raw)
            if ok2 and d then
                _globalConfig = d
                loaded = true
            end
        end
    end

    if not loaded then
        _globalConfig = _DEFAULT_CONFIG
        _saveGlobalConfig()
    end
end

local _savePending = false
local function _saveDebounced()
    if _savePending then return end
    _savePending = true
    task.delay(0.3, function()
        _savePending = false
        _saveGlobalConfig()
    end);
end

local function cfgGet(section)
    return _globalConfig[section]
end

local function cfgSet(section, data)
    _globalConfig[section] = data
    _saveDebounced()
end

local function cfgSetNow(section, data)
    _globalConfig[section] = data
    _saveGlobalConfig()
end

_loadGlobalConfig()

task.spawn(function()
    while true do
        task.wait(8)
        _saveGlobalConfig()
    end
end);

pcall(function()
    if CoreGui:FindFirstChild("ORsDuel_v4") then
        CoreGui:FindFirstChild("ORsDuel_v4"):Destroy()
    end
end);

local ControlModule = nil
pcall(function()
    ControlModule = require(lp.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
end);

local Screen = Instance.new("ScreenGui")
Screen.Name           = "ORsDuel_v4"
Screen.ResetOnSpawn   = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Screen.Parent         = CoreGui;

task.spawn(function()
    local introGui = Instance.new("ScreenGui", CoreGui)
    introGui.Name = "OrkszIntro"
    introGui.ResetOnSpawn = false
    introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    introGui.DisplayOrder = 999

    local function playKey()
        pcall(function()
            local s = Instance.new("Sound", workspace)
            s.SoundId = "rbxassetid://9119713951"
            s.Volume = 0.35
            s.PlaybackSpeed = 0.85 + math.random() * 0.3
            s:Play()
            game:GetService("Debris"):AddItem(s, 0.6)
        end);
    end

    local lbl = Instance.new("TextLabel", introGui)
    lbl.Size        = UDim2.new(1, 0, 0, 60)
    lbl.Position    = UDim2.new(0, 0, 0.28, 0)
    lbl.BackgroundTransparency = 1
    lbl.ZIndex      = 200
    lbl.Font        = Enum.Font.GothamBlack
    lbl.TextSize    = 28
    lbl.TextColor3  = Color3.fromRGB(255, 255, 255)
    lbl.TextTransparency = 0
    lbl.Text        = ""
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    lbl.Position = UDim2.new(0, 0, 0.12, 0)
    lbl.TextTransparency = 1
    TweenService:Create(lbl, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Position = UDim2.new(0, 0, 0.28, 0),
        TextTransparency = 0,
    }):Play()
    task.wait(0.35)

    local part1 = "Orksz Duels"
    local part2 = " > Nine Duels"
    local full   = part1 .. part2

    for i = 1, #full do
        local ch = full:sub(i, i)
        if ch ~= " " then playKey() end

        if i <= #part1 then
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            lbl.TextColor3 = Color3.fromRGB(140, 140, 140)
        end
        lbl.Text = full:sub(1, i)
        task.wait(0.065)
    end

    task.wait(0.15)
    TweenService:Create(lbl, TweenInfo.new(0.12), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
    task.wait(0.12)
    TweenService:Create(lbl, TweenInfo.new(0.25), {TextColor3 = Color3.fromRGB(200,200,200)}):Play()

    task.wait(1.3)

    TweenService:Create(lbl, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Position = UDim2.new(1.1, 0, 0.28, 0),
        TextTransparency = 1,
    }):Play()
    task.wait(0.45)
    introGui:Destroy()
end);

local C = {
    Black     = Color3.fromRGB(0,   0,   0),
    DarkRow   = Color3.fromRGB(18,  18,  18),
    DarkTab   = Color3.fromRGB(15,  15,  15),
    Gray      = Color3.fromRGB(160, 160, 160),
    LightGray = Color3.fromRGB(130, 130, 130),
    White     = Color3.fromRGB(230, 230, 230),
    Dim       = Color3.fromRGB(90,  90,  90),
    TogOff    = Color3.fromRGB(40,  40,  48),
}

local STROKE_ACTIVE = Color3.fromRGB(160, 30, 30)
local STROKE_IDLE   = Color3.fromRGB(0, 0, 0)
local DOT_ON  = Color3.fromRGB(255, 255, 255)
local DOT_OFF = Color3.fromRGB(100, 100, 100)

local function New(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props) do if k ~= "Parent" then o[k] = v end end
    o.Parent = props.Parent
    return o
end

local function addDefaultStroke(frame)
    local stroke = Instance.new("UIStroke", frame)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = 2
    stroke.Color = STROKE_IDLE
    stroke.Transparency = 1
    stroke.Enabled = true
    return stroke
end

local _hubRestoring = false
local tFrameGlobal = nil

local function storeHubSize(frame)
    frame:SetAttribute("origW", frame.Size.X.Offset)
    frame:SetAttribute("origH", frame.Size.Y.Offset)
end

local function hubOpen(frame, instant)
    frame.Visible = true
end

local function hubClose(frame, cb)
    frame.Visible = false
    if cb then cb() end
end

local function applyHubGradient(frame)

    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0
end

local function setHubActive(hub, dot, active)
    local stroke = hub:FindFirstChildOfClass("UIStroke")
    if not stroke then stroke = addDefaultStroke(hub) end
    if active then
        stroke.Color = STROKE_ACTIVE
        stroke.Transparency = 0
    else
        stroke.Color = STROKE_IDLE
        stroke.Transparency = 1
    end
    if dot then
        dot.Text = "◉"
        dot.TextColor3 = active and DOT_ON or DOT_OFF
        dot.BackgroundTransparency = 1
    end
end

local function Drag(mover, handle)
    handle = handle or mover
    local dragging, ds, sp, di
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            ds       = i.Position
            sp       = mover.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end);
        end
    end);
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then
            di = i
        end
    end);
    UIS.InputChanged:Connect(function(i)
        if i == di and dragging then
            local d = i.Position - ds
            mover.Position = UDim2.new(
                sp.X.Scale, sp.X.Offset + d.X,
                sp.Y.Scale, sp.Y.Offset + d.Y
            )
        end
    end);
end

local function linkSettingsToHub(mainFrame, settingsFrame, gapY)
    gapY = gapY or 8
    RunService.Heartbeat:Connect(function()
        if not settingsFrame.Visible then return end
        if not mainFrame or not mainFrame.Parent then return end
        local ap = mainFrame.AbsolutePosition
        local as = mainFrame.AbsoluteSize
        settingsFrame.Position = UDim2.new(0, ap.X, 0, ap.Y + as.Y + gapY)
    end);
end

local function makeInlineExpand(frame, collapsedH, expandedH)
    local expanded = false
    frame.ClipsDescendants = true
    local W = frame.Size.X.Offset
    if W <= 0 then W = 128 end
    local baseZ = frame.ZIndex
    return function()
        if _dragJustHappened then return end
        expanded = not expanded

        frame.ZIndex = expanded and 50 or baseZ
        for _, c in ipairs(frame:GetDescendants()) do
            pcall(function() c.ZIndex = c.ZIndex + (expanded and 45 or -45) end);
        end
        local tw = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        TweenService:Create(frame, tw, {
            Size = UDim2.new(0, W, 0, expanded and expandedH or collapsedH)
        }):Play()
    end
end

local _dragJustHappened = false

local function _absorbNextClick()
    _dragJustHappened = true
    local absorber = Instance.new("TextButton")
    absorber.Size = UDim2.new(1, 0, 1, 0)
    absorber.Position = UDim2.new(0, 0, 0, 0)
    absorber.BackgroundTransparency = 1
    absorber.Text = ""
    absorber.ZIndex = 9999
    absorber.Modal = false
    absorber.Parent = Screen

    local conn
    conn = absorber.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.Touch
        or inp.UserInputType == Enum.UserInputType.MouseButton1 then
            conn:Disconnect()
            absorber:Destroy()
            task.delay(0.05, function() _dragJustHappened = false end);
        end
    end);

    task.delay(0.6, function()
        if absorber and absorber.Parent then
            pcall(function() conn:Disconnect() end);
            absorber:Destroy()
        end
        _dragJustHappened = false
    end);
end

local function MakeDrag(frame, onDrop)
    local dragging    = false
    local didMove     = false
    local activeInput = nil
    local startPos    = Vector2.zero
    local frameStart  = Vector2.zero

    local TOUCH_THRESHOLD = 12
    local MOUSE_THRESHOLD = 4

    local function beginDrag(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if not frame.Visible then return end
        if dragging then return end
        dragging    = true
        didMove     = false
        activeInput = input
        startPos    = Vector2.new(input.Position.X, input.Position.Y)
        frameStart  = Vector2.new(frame.AbsolutePosition.X, frame.AbsolutePosition.Y)
    end

    local function hookObj(obj)
        if obj:IsA("ScrollingFrame") then return end
        if obj:IsA("GuiObject") and not obj:IsA("TextBox") then

            local p = obj.Parent
            while p do
                if p:IsA("ScrollingFrame") then return end
                p = p.Parent
            end
            obj.InputBegan:Connect(beginDrag)
        end
    end
    hookObj(frame)
    for _, d in ipairs(frame:GetDescendants()) do hookObj(d) end
    frame.DescendantAdded:Connect(hookObj)

    UIS.InputChanged:Connect(function(input)
        if not dragging then return end
        if input ~= activeInput and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

        local delta = Vector2.new(input.Position.X, input.Position.Y) - startPos
        local threshold = (activeInput and activeInput.UserInputType == Enum.UserInputType.Touch)
            and TOUCH_THRESHOLD or MOUSE_THRESHOLD

        if not didMove then
            if delta.Magnitude < threshold then return end
            didMove = true

            _dragJustHappened = true
        end

        local nx = frameStart.X + delta.X
        local ny = frameStart.Y + delta.Y
        frame.Position = UDim2.new(0, nx, 0, ny)
    end);

    UIS.InputEnded:Connect(function(input)
        if not dragging then return end
        if input ~= activeInput then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1
        and input.UserInputType ~= Enum.UserInputType.Touch then return end

        local wasMobile = (input.UserInputType == Enum.UserInputType.Touch)
        dragging    = false
        activeInput = nil

        if didMove then
            if onDrop then onDrop(frame) end
            if wasMobile then

                _absorbNextClick()
            else

                task.delay(0.12, function() _dragJustHappened = false end);
            end
        end
        didMove = false
    end);

    return function() return _dragJustHappened end
end

local ghostReg = {}
local ghostT   = 0

RunService.Heartbeat:Connect(function(dt)
    if #ghostReg == 0 then return end
    ghostT = ghostT + 1
    if ghostT < 2 then return end
    ghostT = 0
    local dt2 = dt * 2
    local i = 1
    while i <= #ghostReg do
        local g = ghostReg[i]
        if not g.f or not g.f.Parent then
            pcall(function() g.l:Destroy() end);
            table.remove(ghostReg, i)
        else
            g.wp = g.wp + g.ws
            g.y  = g.y  + g.sp * 60 * dt2
            g.l.Position = UDim2.new(g.x + math.sin(g.wp) * g.wa, 0, g.y, 0)
            if     g.y < 0.05 then g.l.TextTransparency = 1 - g.op*(g.y+0.15)/0.20
            elseif g.y > 0.75 then g.l.TextTransparency = 1 - g.op*(1-(g.y-0.75)/0.30)
            else                    g.l.TextTransparency = 1 - g.op end
            if g.y > 1.1 then
                g.y=-.15; g.x=math.random(0,90)/100
                g.sp=.0008+math.random()*.0012
                g.wa=.03+math.random()*.04
                g.op=.35+math.random()*.45
                local sz=math.random(10,18)
                g.l.TextSize=sz; g.l.Size=UDim2.new(0,sz+4,0,sz+4)
            end
            i = i + 1
        end
    end
end);

local function Ghost(frame, n)
    frame.ClipsDescendants = true
    for k = 1, (n or 5) do
        task.delay((k-1)*0.3, function()
            if not frame.Parent then return end
            local l = Instance.new("TextLabel", frame)
            l.BackgroundTransparency = 1
            l.Text = ""
            l.ZIndex = (frame.ZIndex or 5) + 1
            l.BorderSizePixel = 0
            local sz = math.random(10, 18)
            l.TextSize = sz
            l.Size = UDim2.new(0, sz+4, 0, sz+4)
            l.TextTransparency = 1
            local g = {
                f  = frame, l = l,
                x  = math.random(0,90)/100,
                y  = -.15 - math.random()*.5,
                sp = .0008 + math.random()*.0012,
                wa = .03   + math.random()*.04,
                ws = .04   + math.random()*.03,
                wp = math.random()*math.pi*2,
                op = .35   + math.random()*.45,
            }
            l.Position = UDim2.new(g.x, 0, g.y, 0)
            table.insert(ghostReg, g)
        end);
    end
end;

do
    local tpDownDados = { px = -1, py = -1 }
    do
        local d = cfgGet("tpDownConfig") or {px=43, py=93}
        if d then tpDownDados = d end
    end

    local tpDownFrame = Instance.new("Frame", Screen)
    tpDownFrame.Name = "TpDownFrame"
    tpDownFrame.Size = UDim2.new(0, 128, 0, 34)
    if tpDownDados.px and tpDownDados.px >= 0 then
        tpDownFrame.Position = UDim2.new(0, tpDownDados.px, 0, tpDownDados.py)
    else
        tpDownFrame.Position = UDim2.new(0.85, 0, 0.85, 0)
    end
    tpDownFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    tpDownFrame.Active = true; tpDownFrame.ZIndex = 5; tpDownFrame.Visible = true
    Instance.new("UICorner", tpDownFrame).CornerRadius = UDim.new(0, 10)
    local tpDownStroke = Instance.new("UIStroke", tpDownFrame)
    tpDownStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    tpDownStroke.Thickness = 2; tpDownStroke.Color = STROKE_IDLE
    tpDownStroke.Transparency = 1
    applyHubGradient(tpDownFrame)
    local tpDownDot = Instance.new("TextLabel", tpDownFrame)
    tpDownDot.BackgroundTransparency = 1
    tpDownDot.Size = UDim2.new(0, 14, 0, 14)
    tpDownDot.Position = UDim2.new(0, 3, 0.5, -7)
    tpDownDot.Text = "◉"; tpDownDot.ZIndex = 12
    tpDownDot.TextColor3 = DOT_OFF
    tpDownDot.Font = Enum.Font.GothamBold; tpDownDot.TextSize = 13

    MakeDrag(tpDownFrame, function()
        local ap = tpDownFrame.AbsolutePosition
        tpDownDados.px = ap.X; tpDownDados.py = ap.Y
        cfgSetNow("tpDownConfig", tpDownDados)
    end);

    local tpDownBtn = Instance.new("TextButton", tpDownFrame)
    tpDownBtn.Size = UDim2.new(1, -18, 1, -8); tpDownBtn.Position = UDim2.new(0, 16, 0, 4)
    tpDownBtn.BackgroundTransparency = 1; tpDownBtn.Text = "TP DOWN"
    tpDownBtn.TextColor3 = Color3.new(1,1,1); tpDownBtn.Font = Enum.Font.Bangers
    tpDownBtn.TextSize = 15; tpDownBtn.BorderSizePixel = 0; tpDownBtn.AutoButtonColor = false; tpDownBtn.ZIndex = 6
    Instance.new("UICorner", tpDownBtn).CornerRadius = UDim.new(0, 10)

    tpDownBtn.MouseButton1Click:Connect(function()
        if _dragJustHappened then return end

        tpDownStroke.Color = STROKE_ACTIVE
        TweenService:Create(tpDownStroke, TweenInfo.new(0.1), {Transparency = 0}):Play()
        task.delay(0.35, function()
            TweenService:Create(tpDownStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
        end);
        local char = lp.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                rayParams.FilterDescendantsInstances = {char}
                local raycastResult = workspace:Raycast(hrp.Position, Vector3.new(0, -1000, 0), rayParams)
                if raycastResult then
                    hrp.CFrame = CFrame.new(hrp.Position.X, raycastResult.Position.Y + hrp.Size.Y/2 + 0.1, hrp.Position.Z)
                else
                    hrp.CFrame = CFrame.new(hrp.Position.X, -50, hrp.Position.Z)
                end
            end
        end
    end);
end

local miniFrame = Instance.new("Frame", Screen)
miniFrame.Size             = UDim2.new(0, 72, 0, 30)
miniFrame.Position         = UDim2.new(0.05, 0, 0.20, 0)
miniFrame.BackgroundColor3 = C.Black
miniFrame.BorderSizePixel  = 0
miniFrame.Active           = true
miniFrame.ZIndex           = 10
Instance.new("UICorner", miniFrame).CornerRadius = UDim.new(0, 10)
local mStroke = Instance.new("UIStroke", miniFrame)
mStroke.Thickness = 2
mStroke.Color     = Color3.fromRGB(0, 0, 0)
mStroke.Transparency = 1
applyHubGradient(miniFrame)

local menuBtn = New("TextButton", {
    Size                    = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency  = 1,
    BorderSizePixel         = 0,
    Text                    = "MENU",
    TextColor3              = C.White,
    Font = Enum.Font.Bangers,
    TextSize                = 20,
    AutoButtonColor         = false,
    ZIndex                  = 11,
    Parent                  = miniFrame,
})
Instance.new("UICorner", menuBtn).CornerRadius = UDim.new(0, 10)

local ITEM_H   = 32
local ITEM_PAD = 2
local HEADER_H = 54

local MainFrame = Instance.new("Frame", Screen)
MainFrame.Name             = "HubMain"
MainFrame.Size             = UDim2.new(0, 198, 0, 240)
MainFrame.Position         = UDim2.new(0.5, -99, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0
MainFrame.Visible          = false
MainFrame.ZIndex           = 5
MainFrame.Active           = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local hStroke = Instance.new("UIStroke", MainFrame)
hStroke.Thickness = 2; hStroke.Color = Color3.fromRGB(0, 0, 0)
hStroke.Transparency = 1

do
    local mainPosDados = cfgGet("hubMainPos") or {px=309, py=67}
    do
        MainFrame.Position = UDim2.new(0, mainPosDados.px, 0, mainPosDados.py)
    end
    local pressing, pressStart, frameStart, dragInput, movedDist, activeInput = false, Vector2.zero, Vector2.zero, nil, 0, nil
    MainFrame.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end

        local relY = i.Position.Y - MainFrame.AbsolutePosition.Y
        if relY > HEADER_H then return end
        pressing = true; movedDist = 0
        pressStart = Vector2.new(i.Position.X, i.Position.Y)
        frameStart = Vector2.new(MainFrame.AbsolutePosition.X, MainFrame.AbsolutePosition.Y)
        activeInput = i; dragInput = nil
    end);
    MainFrame.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            dragInput = i
        end
    end);
    UIS.InputChanged:Connect(function(i)
        if not pressing or i ~= dragInput then return end
        local d = Vector2.new(i.Position.X, i.Position.Y) - pressStart
        movedDist = d.Magnitude
        MainFrame.Position = UDim2.new(0, frameStart.X + d.X, 0, frameStart.Y + d.Y)
    end);
    UIS.InputEnded:Connect(function(i)
        if not pressing or i ~= activeInput then return end
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
        pressing = false; activeInput = nil
        if movedDist >= 8 then
            local ap = MainFrame.AbsolutePosition
            mainPosDados.px = ap.X; mainPosDados.py = ap.Y
            cfgSetNow("hubMainPos", mainPosDados)
        end
        movedDist = 0
    end);
end

local hubTitleLbl = New("TextLabel", {
    Text = "ORKSZ DUELS", TextColor3 = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBlack, TextSize = 16,
    Size = UDim2.new(1, 0, 0, 36), Position = UDim2.new(0, 0, 0, 0),
    BackgroundTransparency = 1, TextXAlignment = "Center", ZIndex = 6, Parent = MainFrame,
})
do
    local t = 0; local dir = 1
    RunService.Heartbeat:Connect(function(dt)
        if not hubTitleLbl or not hubTitleLbl.Parent then return end
        t = t + dt * 0.7 * dir
        if t >= 1 then t = 1; dir = -1
        elseif t <= 0 then t = 0; dir = 1 end
        local v = math.floor(t * 255)
        hubTitleLbl.TextColor3 = Color3.fromRGB(v, v, v)
    end);
end

local TabContainer = New("Frame", {
    Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 34),
    BackgroundColor3 = C.DarkTab, ZIndex = 6, Parent = MainFrame,
})
New("UICorner",    {CornerRadius = UDim.new(0, 6), Parent = TabContainer})
New("UIListLayout",{FillDirection = "Horizontal", HorizontalAlignment = "Center", Parent = TabContainer})

local ContentArea = New("Frame", {
    Size = UDim2.new(1, 0, 0, 240 - HEADER_H),
    Position = UDim2.new(0, 0, 0, HEADER_H),
    BackgroundTransparency = 1, ClipsDescendants = true,
    ZIndex = 6, Parent = MainFrame,
})

local TABS     = {"Combat", "Protect", "Visual", "Desync", "Settings"}
local TAB_ROWS = {Combat={}, Protect={}, Visual={}, Desync={}, Settings={}}
local Pages    = {}
local TabBtns  = {}

local function rebuildPage(name)
    local sf = Pages[name]; if not sf then return end
    local n = #TAB_ROWS[name]
    sf.CanvasSize = UDim2.new(0, 0, 0, n*ITEM_H + math.max(0,n-1)*ITEM_PAD + 10)
end

local function MakePage(name)
    local sf = New("ScrollingFrame", {
        Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Visible = false,
        ScrollBarThickness = 3, ScrollBarImageColor3 = C.Gray,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 6, Parent = ContentArea,
    })
    New("UIListLayout", {HorizontalAlignment="Center", Padding=UDim.new(0,ITEM_PAD), Parent=sf})
    New("UIPadding",    {PaddingTop=UDim.new(0,6), Parent=sf})
    Pages[name] = sf

    local b = New("TextButton", {
        Size=UDim2.new(0.25,0,1,0), BackgroundTransparency=1,
        Text=name, TextColor3=C.Dim, Font = Enum.Font.GothamBold, TextSize=9,
        ZIndex=7, Parent=TabContainer,
    })
    b.MouseButton1Click:Connect(function()
        for _,p in pairs(Pages)   do p.Visible=false end
        for _,x in pairs(TabBtns) do x.TextColor3=C.Dim end
        sf.Visible=true; b.TextColor3=C.White
    end);
    TabBtns[name] = b
end

for _, t in ipairs(TABS) do MakePage(t) end
TabBtns["Combat"].TextColor3 = C.White
Pages["Combat"].Visible      = true

local function Toggle(page, label, default, cb)
    local on = default
    local row = New("Frame", {
        Size=UDim2.new(0.93,0,0,ITEM_H), BackgroundColor3=C.DarkRow,
        BackgroundTransparency=0.3, ZIndex=7, Parent=Pages[page],
    })
    New("UICorner", {CornerRadius=UDim.new(0,8), Parent=row})
    New("UIStroke", {Color=C.Gray, Thickness=1, Transparency=0.6, Parent=row})
    New("TextLabel", {
        Text=label, Size=UDim2.new(0.62,0,1,0), Position=UDim2.new(0.04,0,0,0),
        TextColor3=Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize=12,
        BackgroundTransparency=1, TextXAlignment="Left", ZIndex=8, Parent=row,
    })
    local bg = New("Frame", {
        Size=UDim2.new(0,38,0,18), Position=UDim2.new(1,-44,0.5,-9),
        BackgroundColor3=on and C.Gray or C.TogOff, ZIndex=8, Parent=row,
    })
    New("UICorner", {CornerRadius=UDim.new(1,0), Parent=bg})
    local dot = New("Frame", {
        Size=UDim2.new(0,14,0,14),
        Position=on and UDim2.new(0.55,0,0.1,0) or UDim2.new(0.08,0,0.1,0),
        BackgroundColor3=Color3.new(1,1,1), ZIndex=9, Parent=bg,
    })
    New("UICorner", {CornerRadius=UDim.new(1,0), Parent=dot})
    New("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=10, Parent=row,
    }).MouseButton1Click:Connect(function()
        on = not on
        TweenService:Create(bg,  TweenInfo.new(0.18), {BackgroundColor3=on and C.Gray or C.TogOff}):Play()
        TweenService:Create(dot, TweenInfo.new(0.18), {Position=on and UDim2.new(0.55,0,0.1,0) or UDim2.new(0.08,0,0.1,0)}):Play()
        cb(on)
    end);
    table.insert(TAB_ROWS[page], row)
    rebuildPage(page)
end

local startAimBot, stopAimBot
local LockFrame, aimRedDot
local aimEnabled = false
local stopDuelExterno
local forceLockToggle
local forceDuelToggle

local isStealing      = false
local stealStartTime  = 0
local STEAL_RADIUS    = 9
local STEAL_DURATION  = 0.2
local stealConn       = nil
local progressConn    = nil
local stealActive_    = false
local animalCache     = {}
local promptCache     = {}
local stealCache      = {}

local grabBarFill    = nil
local grabBarPercent = nil
local gbStroke       = nil
local radBox         = nil
local durBox         = nil

local infoBarDados = { px = -1, py = -1 }
local grabBarDados = { px = -1, py = -1 }

local function carregarInfoBarPos()
    local d = cfgGet("infoBarPos") or {px=304, py=6}
    if d then infoBarDados = d end
end
local function carregarGrabBarPos()
    local d = cfgGet("grabBarPos") or {px=245, py=198}
    if d then
        grabBarDados = d
        if d.radius   then STEAL_RADIUS   = d.radius   end
        if d.duration then STEAL_DURATION = d.duration end
    end
end
carregarInfoBarPos()
carregarGrabBarPos()

local infoBarGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
infoBarGui.Name = "InfoBarGui"
infoBarGui.ResetOnSpawn = false
infoBarGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local topFrame = Instance.new("Frame", infoBarGui)
topFrame.Size = UDim2.new(0, 190, 0, 34)
topFrame.Position = UDim2.new(0.5, -95, 0, -6)
topFrame.AnchorPoint = Vector2.new(0, 0)
topFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
topFrame.BorderSizePixel = 0
topFrame.Active = false
Instance.new("UICorner", topFrame).CornerRadius = UDim.new(0, 10)
applyHubGradient(topFrame)
local topStroke = Instance.new("UIStroke", topFrame)
topStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
topStroke.Thickness = 2
topStroke.Color = STROKE_IDLE
topStroke.Transparency = 1
do
    local title = Instance.new("TextLabel", topFrame)
    title.Size = UDim2.new(1, 0, 1, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "OR's DUEL"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.Bangers
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.TextYAlignment = Enum.TextYAlignment.Center

    local fpsLbl = Instance.new("TextLabel", topFrame)
    fpsLbl.Size = UDim2.new(0, 36, 0, 12)
    fpsLbl.Position = UDim2.new(0, 5, 1, -14)
    fpsLbl.BackgroundTransparency = 1
    fpsLbl.Text = "fps:--"
    fpsLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    fpsLbl.Font = Enum.Font.Bangers
    fpsLbl.TextSize = 11
    fpsLbl.TextXAlignment = Enum.TextXAlignment.Left

    local pingLbl = Instance.new("TextLabel", topFrame)
    pingLbl.Size = UDim2.new(0, 40, 0, 12)
    pingLbl.Position = UDim2.new(1, -45, 1, -14)
    pingLbl.BackgroundTransparency = 1
    pingLbl.Text = "--:ping"
    pingLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    pingLbl.Font = Enum.Font.Bangers
    pingLbl.TextSize = 11
    pingLbl.TextXAlignment = Enum.TextXAlignment.Right

    local fpsAcum = 0; local fpsFrames = 0; local fpsTimer = 0
    local pingTimer = 0
    RunService.RenderStepped:Connect(function(dt)
        if dt <= 0 then return end
        fpsAcum = fpsAcum + (1 / dt); fpsFrames = fpsFrames + 1; fpsTimer = fpsTimer + dt
        if fpsTimer >= 0.5 then
            local avg = math.floor(fpsAcum / fpsFrames)
            fpsLbl.Text = "FPS:" .. avg
            fpsAcum = 0; fpsFrames = 0; fpsTimer = 0
        end
    end);
    RunService.Heartbeat:Connect(function(dt)
        pingTimer = pingTimer + dt
        if pingTimer < 1 then return end
        pingTimer = 0
        local ok, ping = pcall(function()
            return math.floor(lp:GetNetworkPing() * 1000)
        end);
        pingLbl.Text = (ok and type(ping)=="number") and (ping .. ":PING") or "--:PING"
        pingLbl.TextColor3 = C.White
    end);
end

local botFrame = Instance.new("Frame", infoBarGui)
botFrame.Name = "GrabBarFrame"
botFrame.Size = UDim2.new(0, 240, 0, 28)
botFrame.AnchorPoint = Vector2.new(0, 0)
task.defer(function()
    local vp = workspace.CurrentCamera.ViewportSize
    if grabBarDados.px and grabBarDados.px >= 0
    and grabBarDados.px < vp.X - 50 and grabBarDados.py < vp.Y - 10 then
        botFrame.Position = UDim2.new(0, grabBarDados.px, 0, grabBarDados.py)
    else
        botFrame.Position = UDim2.new(0, math.floor(vp.X/2 - 120), 0, math.floor(vp.Y - 90))
        grabBarDados.px = botFrame.Position.X.Offset
        grabBarDados.py = botFrame.Position.Y.Offset
        cfgSet("grabBarPos", grabBarDados)
    end
end);
botFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
botFrame.BorderSizePixel = 0
botFrame.Active = true
Instance.new("UICorner", botFrame).CornerRadius = UDim.new(0, 10)
applyHubGradient(botFrame)
local botStroke = Instance.new("UIStroke", botFrame)
botStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
botStroke.Thickness = 2
botStroke.Color = STROKE_IDLE
botStroke.Transparency = 1
gbStroke = botStroke
do

    local readyLbl = Instance.new("TextLabel", botFrame)
    readyLbl.Size = UDim2.new(0, 90, 1, 0)
    readyLbl.Position = UDim2.new(0, 10, 0, 0)
    readyLbl.BackgroundTransparency = 1
    readyLbl.Text = "READY"
    readyLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    readyLbl.Font = Enum.Font.GothamBold
    readyLbl.TextSize = 11
    readyLbl.TextXAlignment = Enum.TextXAlignment.Left
    grabBarPercent = readyLbl

    radBox = Instance.new("TextBox", botFrame)
    radBox.Size = UDim2.new(0, 24, 0, 16)
    radBox.Position = UDim2.new(1, -56, 0.5, -8)
    radBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    radBox.BorderSizePixel = 0
    radBox.Text = tostring(STEAL_RADIUS)
    radBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    radBox.Font = Enum.Font.GothamBold; radBox.TextSize = 11
    radBox.ClearTextOnFocus = false
    Instance.new("UICorner", radBox).CornerRadius = UDim.new(0, 5)
    radBox.FocusLost:Connect(function()
        local val = tonumber(radBox.Text:match("[%d%.]+"))
        if val then
            STEAL_RADIUS = math.clamp(math.floor(val), 1, 200)
            if hitboxActive then hitboxExpand = STEAL_RADIUS; hitboxExpandAllPrompts(hitboxExpand) end
        end
        radBox.Text = tostring(STEAL_RADIUS)
        grabBarDados.radius = STEAL_RADIUS; cfgSet("grabBarPos", grabBarDados)
    end);

    durBox = Instance.new("TextBox", botFrame)
    durBox.Size = UDim2.new(0, 24, 0, 16)
    durBox.Position = UDim2.new(1, -28, 0.5, -8)
    durBox.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    durBox.BorderSizePixel = 0
    durBox.Text = tostring(STEAL_DURATION)
    durBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    durBox.Font = Enum.Font.GothamBold; durBox.TextSize = 11
    durBox.ClearTextOnFocus = false
    Instance.new("UICorner", durBox).CornerRadius = UDim.new(0, 5)
    durBox.FocusLost:Connect(function()
        local val = tonumber(durBox.Text:match("[%d%.]+"))
        if val then STEAL_DURATION = math.clamp(val, 0.05, 5) end
        durBox.Text = tostring(STEAL_DURATION)
        grabBarDados.duration = STEAL_DURATION; cfgSet("grabBarPos", grabBarDados)
    end);

    local barBg = Instance.new("Frame", botFrame)
    barBg.Size = UDim2.new(1, -6, 0, 6)
    barBg.Position = UDim2.new(0, 3, 1, -7)
    barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    barBg.BorderSizePixel = 0
    Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)
    grabBarFill = Instance.new("Frame", barBg)
    grabBarFill.Size = UDim2.fromScale(0, 1)
    grabBarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    grabBarFill.BorderSizePixel = 0
    Instance.new("UICorner", grabBarFill).CornerRadius = UDim.new(1, 0)
end

do
    local bobBaseX = workspace.CurrentCamera.ViewportSize.X * 0.5 - 105
    local bobBaseY = -6
    local bobT = 0
    RunService.Heartbeat:Connect(function(dt)
        bobT = bobT + dt
        local offsetY = math.sin(bobT * 4.5) * 5
        topFrame.Position = UDim2.new(0, bobBaseX, 0, bobBaseY + offsetY)
    end);
end

do
    local dragging, dragInput, dragStart, startAbsPos, activeBotInput
    botFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position
            startAbsPos = botFrame.AbsolutePosition
            activeBotInput = input
        end
    end);
    botFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end);
    UIS.InputEnded:Connect(function(input)
        if not dragging then return end
        if input ~= activeBotInput then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        dragging = false; activeBotInput = nil
        grabBarDados.px = botFrame.AbsolutePosition.X
        grabBarDados.py = botFrame.AbsolutePosition.Y
        cfgSet("grabBarPos", grabBarDados)
    end);
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            botFrame.Position = UDim2.new(0, startAbsPos.X + delta.X, 0, startAbsPos.Y + delta.Y)
        end
    end);
end

do
local spdBillboard    = nil
local spdLabelValue   = nil

local function criarSpdBillboard(char)

    if spdBillboard and spdBillboard.Parent then
        spdBillboard:Destroy()
    end
    spdBillboard  = nil
    spdLabelValue = nil

    local head = char:WaitForChild("Head", 5)
    if not head then return end

    local bb = Instance.new("BillboardGui")
    bb.Name           = "SpdBillboard"
    bb.Adornee        = head
    bb.Size           = UDim2.new(0, 60, 0, 20)
    bb.StudsOffset    = Vector3.new(0, 2.4, 0)
    bb.AlwaysOnTop    = true
    bb.ResetOnSpawn   = false
    bb.LightInfluence = 0
    bb.Parent         = char

    local lbl = Instance.new("TextLabel", bb)
    lbl.Size                   = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text                   = "0"
    lbl.TextColor3             = Color3.fromRGB(255, 255, 255)
    lbl.Font                   = Enum.Font.GothamBold
    lbl.TextSize               = 14
    lbl.TextXAlignment         = Enum.TextXAlignment.Center
    lbl.TextYAlignment         = Enum.TextYAlignment.Center

    local txtGrad = Instance.new("UIGradient", lbl)
    txtGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(180, 180, 180)),
    })
    txtGrad.Rotation = 90

    local txtStroke = Instance.new("UIStroke", lbl)
    txtStroke.Thickness    = 2
    txtStroke.Color        = Color3.fromRGB(0, 0, 0)
    txtStroke.Transparency = 0

    spdBillboard  = bb
    spdLabelValue = lbl
end

lp.CharacterAdded:Connect(function(char)
    task.wait(0.1)
    criarSpdBillboard(char)
end);
if lp.Character then
    task.spawn(criarSpdBillboard, lp.Character)
end

RunService.RenderStepped:Connect(function()
    if not spdLabelValue then return end
    local char = lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        spdLabelValue.Text = "0"
        return
    end
    local vel = hrp.AssemblyLinearVelocity
    local spd = math.floor(Vector3.new(vel.X, 0, vel.Z).Magnitude + 0.5)
    spdLabelValue.Text = tostring(spd)
end);
end

local duelBarCurPct     = 0
local function duelBarSetPhase(phase) end

do
    local ok, dbg = pcall(function() return debug end);
    if ok and dbg and dbg.info and hookfunction then
        local oldInfo
        oldInfo = hookfunction(dbg.info, function(...)
            local s = oldInfo(1, "s")

            if s and (s:find("Packages.Synchronizer") or s:find("Packages.Net")) then
                return nil
            end
            return oldInfo(...)
        end);
    end
end

local keyBindAim      = nil; local waitingKeyAim   = false
local keyBindAB       = nil; local waitingAB       = false
local keyBindFloat    = nil; local waitingKeyFloat = false
local dbKeyBind       = nil; local dbWaiting       = false
local autoKeyBind     = nil; local autoWaitingKey  = false
local keyBindAutoTP   = nil; local waitingAutoTP   = false
local keyBindHitTP    = nil; local waitingHitTP    = false

local _kbLabelAim   = nil
local _kbLabelAB    = nil
local _kbLabelFloat = nil
local _kbLabelDrop  = nil
local _kbLabelAuto  = nil

local mvSpeedOn    = false
local mvSpeedVal   = 40
local _bridgeDisableMv = nil
local _bridgeSetMvSpeed = nil
local autoPlayOn = false
local pararAutoPlayGlobal = nil

local duelReturnSpeed  = 28.8
local duelNotStealSpeed = 52

do
    local lastStealing = lp:GetAttribute("Stealing") == true

    lp:GetAttributeChangedSignal("Stealing"):Connect(function()
        local stealing = lp:GetAttribute("Stealing") == true
        if stealing and not lastStealing then
            lastStealing = true

            if _bridgeSetMvSpeed and (mvSpeedOn or autoPlayOn) then
                _bridgeSetMvSpeed(duelReturnSpeed)
            end
        elseif not stealing and lastStealing then
            lastStealing = false

            if _bridgeSetMvSpeed and (mvSpeedOn or autoPlayOn) then
                _bridgeSetMvSpeed(duelNotStealSpeed)
            end
        end
    end);

end
local speedWhileStealActive = false
local speedWhileStealConn   = nil
local stealingSpeedValue    = 29

local function startSpeedWhileStealing()
    if speedWhileStealConn then return end
    speedWhileStealConn = RunService.Heartbeat:Connect(function()
        if not speedWhileStealActive then return end
        if not lp:GetAttribute("Stealing") then return end
        local c = lp.Character; if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart"); if not h then return end
        local hum = c:FindFirstChildOfClass("Humanoid")
        local md = hum and hum.MoveDirection or Vector3.zero
        if md.Magnitude > 0.1 then
            h.AssemblyLinearVelocity = Vector3.new(md.X * stealingSpeedValue, h.AssemblyLinearVelocity.Y, md.Z * stealingSpeedValue)
        end
    end);
end

local function stopSpeedWhileStealing()
    if speedWhileStealConn then speedWhileStealConn:Disconnect(); speedWhileStealConn = nil end
end

local stopCebo
local startNoAnim, stopNoAnim

do
    local Cebo = {}
    stopCebo = function()
        if Cebo.Conn     then Cebo.Conn:Disconnect()     end
        if Cebo.GradConn then Cebo.GradConn:Disconnect() end
        if Cebo.Circle   then Cebo.Circle:Destroy()      end
        if Cebo.Align    then Cebo.Align:Destroy()       end
        if Cebo.Attach   then Cebo.Attach:Destroy()      end
        Cebo = {}
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.AutoRotate = true
        end
    end
end

do
    local noAnimConn = nil
    local noAnimStoppedTracks = {}
    local noAnimActive = false
    local LEG_PARTS = {"LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot","Left Leg","Right Leg"}
    local MOVE_ANIM_NAMES = {"walk","run","idle","fall","jump","climb","swim"}
    local function isLegMotor(motor)
        local p1 = motor.Part1; if not p1 then return false end
        for _, name in ipairs(LEG_PARTS) do if p1.Name == name then return true end end
        return false
    end
    local function isMovementTrack(track)
        local name = track.Name:lower()
        for _, n in ipairs(MOVE_ANIM_NAMES) do if name:find(n) then return true end end
        return false
    end
    startNoAnim = function()
        noAnimActive = true
        if noAnimConn then noAnimConn:Disconnect(); noAnimConn = nil end
        noAnimStoppedTracks = {}
        noAnimConn = RunService.Stepped:Connect(function()
            if not noAnimActive then return end
            local c = lp.Character; if not c then return end
            local hum = c:FindFirstChildOfClass("Humanoid")
            local animator = hum and hum:FindFirstChildOfClass("Animator")
            if animator then
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    if isMovementTrack(track) then track:Stop(0) end
                end
            end
            for _, desc in ipairs(c:GetDescendants()) do
                if desc:IsA("Motor6D") and isLegMotor(desc) and desc.Parent then
                    desc.Transform = CFrame.new()
                end
            end
        end);
    end
    stopNoAnim = function()
        noAnimActive = false
        if noAnimConn then noAnimConn:Disconnect(); noAnimConn = nil end
        noAnimStoppedTracks = {}
    end
end

local enableOptimizer, disableOptimizer
local enableXray, disableXray
local enableESP, disableESP
local espEnabled = false

do

    local function _enableOptimizer()
        if getgenv and getgenv().OPTIMIZER_ACTIVE then return end
        if getgenv then getgenv().OPTIMIZER_ACTIVE = true end
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            Lighting.GlobalShadows = false
            Lighting.Brightness = 3
            Lighting.FogEnd = 9e9
        end);
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do
                pcall(function()
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                        obj:Destroy()
                    elseif obj:IsA("BasePart") then
                        obj.CastShadow = false
                        obj.Material = Enum.Material.Plastic
                    end
                end);
            end
        end);
    end
    local function _disableOptimizer()
        if getgenv then getgenv().OPTIMIZER_ACTIVE = false end
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
            Lighting.GlobalShadows = true
            Lighting.Brightness = 2
            Lighting.FogEnd = 100000
        end);
    end
    enableOptimizer  = _enableOptimizer
    disableOptimizer = _disableOptimizer

    local xrayActive = false
    local xrayTransparencyCache = {}
    local xrayWatchConn = nil
    local function isBasePart(obj)
        if not obj:IsA("BasePart") then return false end
        local n = obj.Name:lower()
        local pn = (obj.Parent and obj.Parent.Name:lower()) or ""
        local gpn = (obj.Parent and obj.Parent.Parent and obj.Parent.Parent.Name:lower()) or ""
        return obj.Anchored and (
            n:find("base") or pn:find("base") or gpn:find("base") or
            n:find("plot") or pn:find("plot") or gpn:find("plot")
        )
    end
    local function applyXrayPart(obj)
        if not isBasePart(obj) then return end
        if xrayTransparencyCache[obj] ~= nil then return end
        xrayTransparencyCache[obj] = obj.LocalTransparencyModifier
        pcall(function() obj.LocalTransparencyModifier = 0.85 end);
    end
    local function _enableXray()
        if xrayActive then return end
        xrayActive = true
        pcall(function()
            for _, obj in ipairs(workspace:GetDescendants()) do applyXrayPart(obj) end
        end);
        xrayWatchConn = workspace.DescendantAdded:Connect(function(obj)
            if not xrayActive then return end
            task.defer(function() pcall(function() applyXrayPart(obj) end) end);
        end);
    end
    local function _disableXray()
        if not xrayActive then return end
        xrayActive = false
        if xrayWatchConn then xrayWatchConn:Disconnect(); xrayWatchConn = nil end
        for part, value in pairs(xrayTransparencyCache) do
            if part then pcall(function() part.LocalTransparencyModifier = value end) end
        end
        xrayTransparencyCache = {}
    end
    enableXray  = _enableXray
    disableXray = _disableXray

    local espConnections = {}
    local function createESP(plr)
        if plr == lp then return end
        if not plr.Character then return end
        if plr.Character:FindFirstChild("ESP_Hitbox") then return end
        local char = plr.Character
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local hitbox = Instance.new("BoxHandleAdornment")
        hitbox.Name = "ESP_Hitbox"; hitbox.Adornee = hrp
        hitbox.Size = Vector3.new(4, 6, 2); hitbox.Color3 = Color3.fromRGB(0,0,0)
        hitbox.Transparency = 0.6; hitbox.ZIndex = 10
        hitbox.AlwaysOnTop = true; hitbox.Parent = char
    end
    local function removeESP(plr)
        if not plr.Character then return end
        local h = plr.Character:FindFirstChild("ESP_Hitbox")
        if h then h:Destroy() end
    end
    local function _enableESP()
        espEnabled = true
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp then
                if plr.Character then createESP(plr) end
                local conn = plr.CharacterAdded:Connect(function()
                    task.wait(0.1); createESP(plr)
                end);
                table.insert(espConnections, conn)
            end
        end
        local paConn = Players.PlayerAdded:Connect(function(plr)
            if plr == lp then return end
            local caConn = plr.CharacterAdded:Connect(function()
                task.wait(0.1); createESP(plr)
            end);
            table.insert(espConnections, caConn)
        end);
        table.insert(espConnections, paConn)
    end
    local function _disableESP()
        espEnabled = false
        for _, plr in ipairs(Players:GetPlayers()) do removeESP(plr) end
        for _, conn in ipairs(espConnections) do
            if conn and conn.Connected then conn:Disconnect() end
        end
        espConnections = {}
    end
    enableESP  = _enableESP
    disableESP = _disableESP
end

lp.CharacterAdded:Connect(function()
    task.wait(0.1)
    if espEnabled then enableESP() end
    if togglesState and togglesState["fov"] then
        task.wait(0.3)
        TweenService:Create(Camera, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {FieldOfView = 100}):Play()
    end
end);

local spinGui = nil
local spinModule = nil

local function createSpinHub()
    if spinGui and spinGui.Parent then spinGui:Destroy() end

    local spinAtivo = false
    local spinForce = nil
    local spinDefault = function()
        local vp = workspace.CurrentCamera.ViewportSize
        return {velocidade = 100, px = math.floor(vp.X * 0.478), py = math.floor(vp.Y * 0.337)}
    end
    local dadosSalvos = spinDefault()

    local function carregarDados()
        local d = cfgGet("spinConfig") or {px=131, py=129}
        if d then

            if d.posicaoHub then
                local vp = workspace.CurrentCamera.ViewportSize
                d.px = math.floor((d.posicaoHub.X or 0.478) * vp.X)
                d.py = math.floor((d.posicaoHub.Y or 0.337) * vp.Y)
                d.posicaoHub = nil
            end
            dadosSalvos = d
        end
    end
    local function salvarDados()
        cfgSet("spinConfig", dadosSalvos)
    end
    carregarDados()

    spinGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
    spinGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    spinGui.ResetOnSpawn = false
    spinGui.Name = "SpinHubGui"
    spinGui.Enabled = false

    local function makeDraggableSpin(frame, salva)
        MakeDrag(frame, function()
            if salva then
                local ap = frame.AbsolutePosition
                dadosSalvos.px = ap.X; dadosSalvos.py = ap.Y
                salvarDados()
            end
        end);
    end

    local fMain = Instance.new("Frame", spinGui)
    fMain.BorderSizePixel = 0
    fMain.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    fMain.Size = UDim2.new(0, 128, 0, 34)
    fMain.Position = UDim2.new(0, dadosSalvos.px, 0, dadosSalvos.py)
    fMain.Active = true
    fMain.ClipsDescendants = true
    Instance.new("UICorner", fMain).CornerRadius = UDim.new(0, 10)
    makeDraggableSpin(fMain, true)
    applyHubGradient(fMain)

    addDefaultStroke(fMain)

    local btnSpinToggle = Instance.new("TextButton", fMain)
    btnSpinToggle.TextSize = 16
    btnSpinToggle.BackgroundTransparency = 1
    btnSpinToggle.Font = Enum.Font.Bangers
    btnSpinToggle.Size = UDim2.new(1, -10, 0, 32)
    btnSpinToggle.Text = "SPIN"
    btnSpinToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    btnSpinToggle.Position = UDim2.new(0, 5, 0, 1)
    btnSpinToggle.AutoButtonColor = false
    Instance.new("UICorner", btnSpinToggle).CornerRadius = UDim.new(0, 7)

    local btnSettings = Instance.new("TextButton", fMain)
    btnSettings.Text = "⚙"
    btnSettings.TextSize = 13
    btnSettings.Font = Enum.Font.Bangers
    btnSettings.TextColor3 = Color3.fromRGB(200, 200, 200)
    btnSettings.BackgroundTransparency = 1
    btnSettings.Size = UDim2.new(0, 22, 0, 22)
    btnSettings.Position = UDim2.new(1, -24, 0, 6)
    btnSettings.AutoButtonColor = false
    Instance.new("UICorner", btnSettings).CornerRadius = UDim.new(0, 6)

    local lblStatus = Instance.new("TextLabel", fMain)
    lblStatus.Text = "◉"
    lblStatus.TextColor3 = DOT_OFF
    lblStatus.BackgroundTransparency = 1
    lblStatus.Size = UDim2.new(0, 14, 0, 14)
    lblStatus.Position = UDim2.new(0, 2, 0, 10)
    lblStatus.Font = Enum.Font.GothamBold
    lblStatus.TextSize = 13

    local spinDivider = Instance.new("Frame", fMain)
    spinDivider.Size = UDim2.new(1, -12, 0, 1)
    spinDivider.Position = UDim2.new(0, 6, 0, 34)
    spinDivider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    spinDivider.BorderSizePixel = 0; spinDivider.ZIndex = 6

    local spinKbHint = Instance.new("TextLabel", fMain)
    spinKbHint.TextSize = 11; spinKbHint.BackgroundTransparency = 1
    spinKbHint.Font = Enum.Font.Bangers
    spinKbHint.TextColor3 = Color3.fromRGB(130, 130, 130)
    spinKbHint.Size = UDim2.new(1, -8, 0, 22)
    spinKbHint.Text = "Set keybind in Settings"
    spinKbHint.Position = UDim2.new(0, 6, 0, 38); spinKbHint.ZIndex = 6

    local function atualizarSpin()
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if spinAtivo then
            if not spinForce then
                spinForce = Instance.new("BodyAngularVelocity", hrp)
                spinForce.MaxTorque = Vector3.new(0, math.huge, 0)
            end
            spinForce.AngularVelocity = Vector3.new(0, dadosSalvos.velocidade, 0)
        elseif spinForce then
            spinForce:Destroy(); spinForce = nil
        end
    end

    local function toggleSpin()
        spinAtivo = not spinAtivo
        setHubActive(fMain, lblStatus, spinAtivo)
        atualizarSpin()
    end

    btnSpinToggle.MouseButton1Click:Connect(function() if _dragJustHappened then return end toggleSpin() end);
    local _spinToggleSettings = makeInlineExpand(fMain, 34, 66)
    btnSettings.MouseButton1Click:Connect(_spinToggleSettings)

    return { toggle = toggleSpin, isActive = function() return spinAtivo end }
end

local duelGui    = nil
dbFrame          = nil

local function isMyPlot(plotName)
    local plot = workspace.Plots and workspace.Plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign"); if not sign then return false end
    local yb = sign:FindFirstChild("YourBase")
    return yb and yb:IsA("BillboardGui") and yb.Enabled == true
end

local function scanPlot(plot)
    if not plot or not plot:IsA("Model") then return end
    if isMyPlot(plot.Name) then return end
    local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return end
    for _, pod in ipairs(podiums:GetChildren()) do
        if pod:IsA("Model") and pod:FindFirstChild("Base") then
            local uid = plot.Name .. "_" .. pod.Name

            for _, ex in ipairs(animalCache) do if ex.uid == uid then return end end
            table.insert(animalCache, {
                name = pod.Name, plot = plot.Name, slot = pod.Name,
                worldPosition = pod:GetPivot().Position,
                uid = uid,
            })
        end
    end
end

local function findPromptCached(ad)
    if not ad then return nil end
    local cp = promptCache[ad.uid]
    if cp and cp.Parent then return cp end
    local plots = workspace:FindFirstChild("Plots"); if not plots then return nil end
    local plot  = plots:FindFirstChild(ad.plot);    if not plot  then return nil end
    local pods  = plot:FindFirstChild("AnimalPodiums"); if not pods then return nil end
    local pod   = pods:FindFirstChild(ad.slot);     if not pod   then return nil end
    local base  = pod:FindFirstChild("Base");        if not base  then return nil end
    local sp    = base:FindFirstChild("Spawn");      if not sp    then return nil end

    local function searchPrompt(obj)
        for _, ch in ipairs(obj:GetDescendants()) do
            if ch:IsA("ProximityPrompt") then return ch end
        end
    end
    local att = sp:FindFirstChild("PromptAttachment")
    local prompt = nil
    if att then
        for _, p in ipairs(att:GetChildren()) do
            if p:IsA("ProximityPrompt") then prompt = p; break end
        end
    end
    if not prompt then prompt = searchPrompt(sp) end
    if prompt then promptCache[ad.uid] = prompt end
    return prompt
end

local function buildCallbacks(prompt)
    if stealCache[prompt] then return end
    local data = { holdCallbacks = {}, triggerCallbacks = {}, ready = true }
    local ok1, c1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(c1) == "table" then
        for _, conn in ipairs(c1) do
            if type(conn.Function) == "function" then
                table.insert(data.holdCallbacks, conn.Function)
            end
        end
    end
    local ok2, c2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(c2) == "table" then
        for _, conn in ipairs(c2) do
            if type(conn.Function) == "function" then
                table.insert(data.triggerCallbacks, conn.Function)
            end
        end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then
        stealCache[prompt] = data
    end
end

local function nearestAnimal()
    local char = lp.Character; if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
    if not hrp then return nil end
    local best, bestD = nil, math.huge
    for _, ad in ipairs(animalCache) do
        if not isMyPlot(ad.plot) and ad.worldPosition then
            local d = (hrp.Position - ad.worldPosition).Magnitude
            if d < bestD then bestD = d; best = ad end
        end
    end
    return best, bestD
end

local function findNearestTarget()
    local _, bestD = nearestAnimal()
    if not bestD then return nil end
    local char = lp.Character; if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local best, bd = nil, math.huge
    for _, ad in ipairs(animalCache) do
        if not isMyPlot(ad.plot) and ad.worldPosition then
            local d = (hrp.Position - ad.worldPosition).Magnitude
            if d < bd then bd = d; best = ad end
        end
    end
    if not best then return nil end

    local plots = workspace:FindFirstChild("Plots")
    if plots then
        local plot = plots:FindFirstChild(best.plot)
        local pods = plot and plot:FindFirstChild("AnimalPodiums")
        local pod  = pods and pods:FindFirstChild(best.slot)
        local base = pod and pod:FindFirstChild("Base")
        local sp   = base and base:FindFirstChild("Spawn")
        if sp and sp:IsA("BasePart") then return sp end
    end

    return { Position = best.worldPosition }
end

task.spawn(function()
    task.wait(2)
    local plots = workspace:WaitForChild("Plots", 10); if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") then scanPlot(plot) end
    end
    plots.ChildAdded:Connect(function(plot)
        if plot:IsA("Model") then task.wait(0.5); scanPlot(plot) end
    end);

    task.spawn(function()
        while task.wait(5) do
            animalCache = {}; promptCache = {}
            for _, plot in ipairs(plots:GetChildren()) do
                if plot:IsA("Model") then scanPlot(plot) end
            end
        end
    end);
end);

local function resetStealBar()
    if grabBarFill    then grabBarFill.Size = UDim2.fromScale(0, 1) end
    if grabBarPercent then grabBarPercent.Text = "READY" end
    if gbStroke then
        gbStroke.Color = STROKE_IDLE
        gbStroke.Transparency = 1
    end
end

local function getPromptAnchorPart(prompt)
    local p = prompt.Parent
    if p then
        if p:IsA("BasePart") then return p end
        if p.Parent and p.Parent:IsA("BasePart") then return p.Parent end
        local anc = p:FindFirstAncestorWhichIsA("BasePart")
        if anc then return anc end
    end
    return nil
end

local duelModule = nil
local autoTPHubFrame   = nil
local hitTPHubFrame    = nil
local meleeAimHubFrame = nil

local function createDuelHub()
    if duelGui and duelGui.Parent then duelGui:Destroy() end

    local dadosSalvosL = { ativo = false, posicaoHub = { X = 0.38188, Y = 0.31921 } }
    local SpeedValueLeft = 52; local savedSpeedLeft = 52; local AutoL = false

    local _pd = cfgGet("duelPositions") or {}
    local P1      = Vector3.new(_pd.P1x   or -472.6094970703125,  _pd.P1y   or -6.811800003051758,  _pd.P1z   or 90.1884994506836)
    local P2      = Vector3.new(_pd.P2x   or -472.7843933105469,  _pd.P2y   or -6.811800003051758,  _pd.P2z   or 91.6488037109375)
    local P_EXTRA = Vector3.new(_pd.PEXx  or -486.3769226074219,  _pd.PEXy  or -4.577744483947754,  _pd.PEXz  or 95.26581573486328)
    local dadosSalvosR = { ativo = false, posicaoHub = { X = 0.61812, Y = 0.31921 } }
    local SpeedValueRight = 52; local savedSpeedRight = 52; local AutoR = false
    local R1      = Vector3.new(_pd.R1x   or -473.0520935058594,  _pd.R1y   or -6.811800003051758,  _pd.R1z   or 30.290199279785158)
    local R2      = Vector3.new(_pd.R2x   or -473.19378662109377, _pd.R2y   or -6.811800003051758,  _pd.R2z   or 28.322099685668947)
    local R_EXTRA = Vector3.new(_pd.REXx  or -485.9707336425781,  _pd.REXy  or -4.627743244171143,  _pd.REXz  or 25.178876876831056)

    local function salvarDadosL() cfgSet("leftHubConfig", dadosSalvosL) end
    local function carregarDadosL()
        local d = cfgGet("leftHubConfig")
        if d then dadosSalvosL = d end
        AutoL = false; dadosSalvosL.ativo = false
    end
    local function salvarDadosR() cfgSet("rightHubConfig", dadosSalvosR) end
    local function carregarDadosR()
        local d = cfgGet("rightHubConfig")
        if d then dadosSalvosR = d end
        AutoR = false; dadosSalvosR.ativo = false
    end
    carregarDadosL(); carregarDadosR()

    duelGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
    duelGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    duelGui.ResetOnSpawn = false
    duelGui.Name = "HubCombinadoGui"
    duelGui.Enabled = false

    local dadosSalvosAuto = { px = -1, py = -1, keybind = nil }
    do
        local d = cfgGet("autoPlayConfig") or {px=577, py=-8}
        dadosSalvosAuto = d
    end
    local function salvarDadosAuto()
        cfgSet("autoPlayConfig", dadosSalvosAuto)
    end

    local AutoPlayAtivo = false
    local autoPlayWasActive = false
    local ladoEscolhido = nil

    local fAuto = Instance.new("Frame", duelGui)
    fAuto.Name = "AutoPlayFrame"
    fAuto.BorderSizePixel = 0
    fAuto.BackgroundColor3 = Color3.fromRGB(0,0,0)
    fAuto.Size = UDim2.new(0, 128, 0, 34)
    fAuto.Active = true
    fAuto.ZIndex = 10
    fAuto.ClipsDescendants = true

    if dadosSalvosAuto.px and dadosSalvosAuto.px >= 0 then
        fAuto.Position = UDim2.new(0, dadosSalvosAuto.px, 0, dadosSalvosAuto.py)
    else
        fAuto.Position = UDim2.new(0.5, -63, 0.32, 0)
    end

    Instance.new("UICorner", fAuto).CornerRadius = UDim.new(0, 10)
    applyHubGradient(fAuto)

    local autoStroke = Instance.new("UIStroke", fAuto)
    autoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    autoStroke.Thickness = 2
    autoStroke.Color = STROKE_IDLE
    autoStroke.Transparency = 1

    local lblAuto = Instance.new("TextLabel", fAuto)
    lblAuto.BackgroundTransparency = 1
    lblAuto.Size = UDim2.new(0,14,0,14)
    lblAuto.Position = UDim2.new(0,3,0,10)
    lblAuto.Text = "◉"; lblAuto.ZIndex = 12
    lblAuto.TextColor3 = DOT_OFF
    lblAuto.Font = Enum.Font.GothamBold
    lblAuto.TextSize = 13

    local btnAuto = Instance.new("TextButton", fAuto)
    btnAuto.BackgroundTransparency = 1
    btnAuto.BorderSizePixel = 0
    btnAuto.Font = Enum.Font.Bangers
    btnAuto.TextSize = 17
    btnAuto.Size = UDim2.new(1,-28,0,32)
    btnAuto.Position = UDim2.new(0,5,0,1)
    btnAuto.Text = "AUTO PLAY"
    btnAuto.TextXAlignment = Enum.TextXAlignment.Center
    btnAuto.AutoButtonColor = false
    btnAuto.ZIndex = 12

    local btnGear = Instance.new("TextButton", fAuto)
    btnGear.BackgroundTransparency = 1
    btnGear.BorderSizePixel = 0
    btnGear.Font = Enum.Font.GothamBold
    btnGear.TextSize = 12
    btnGear.TextColor3 = Color3.fromRGB(160,160,160)
    btnGear.Size = UDim2.new(0,22,0,22)
    btnGear.Position = UDim2.new(1,-24,0,6)
    btnGear.Text = "⚙"
    btnGear.AutoButtonColor = false
    btnGear.ZIndex = 13

    local function atualizarBtnAutoVisual()
        if not ladoEscolhido then
            btnAuto.TextColor3 = Color3.fromRGB(255,255,255)
            autoStroke.Color = STROKE_IDLE; autoStroke.Transparency = 1
            lblAuto.TextColor3 = DOT_OFF
        elseif AutoPlayAtivo then
            btnAuto.TextColor3 = Color3.fromRGB(255,255,255)
            autoStroke.Color = STROKE_ACTIVE; autoStroke.Transparency = 0
            lblAuto.TextColor3 = DOT_ON
        else
            btnAuto.TextColor3 = Color3.fromRGB(255,255,255)
            autoStroke.Color = STROKE_IDLE; autoStroke.Transparency = 1
            lblAuto.TextColor3 = DOT_OFF
        end
    end
    atualizarBtnAutoVisual()

    local autoDivider = Instance.new("Frame", fAuto)
    autoDivider.Size = UDim2.new(1, -12, 0, 1)
    autoDivider.Position = UDim2.new(0, 6, 0, 34)
    autoDivider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    autoDivider.BorderSizePixel = 0; autoDivider.ZIndex = 11

    local lblTitulo = Instance.new("TextLabel", fAuto)
    lblTitulo.BackgroundTransparency = 1
    lblTitulo.TextColor3 = Color3.fromRGB(255,255,255)
    lblTitulo.Size = UDim2.new(1,0,0,18)
    lblTitulo.Position = UDim2.new(0,0,0,37)
    lblTitulo.Text = "CHOOSE SIDE"
    lblTitulo.Font = Enum.Font.GothamBold
    lblTitulo.TextSize = 9
    lblTitulo.ZIndex = 31

    local btnPR = Instance.new("TextButton", fAuto)
    btnPR.BackgroundTransparency = 1
    btnPR.BorderSizePixel = 0
    btnPR.Font = Enum.Font.Bangers
    btnPR.TextSize = 15
    btnPR.TextColor3 = Color3.fromRGB(255,255,255)
    btnPR.Size = UDim2.new(0,52,0,24)
    btnPR.Position = UDim2.new(0,8,0,56)
    btnPR.Text = "RIGHT"
    btnPR.AutoButtonColor = false
    btnPR.ZIndex = 32
    Instance.new("UICorner", btnPR).CornerRadius = UDim.new(0,7)
    local sPR = Instance.new("UIStroke", btnPR)
    sPR.Thickness = 1.5; sPR.Color = STROKE_ACTIVE
    sPR.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    sPR.Enabled = false

    local btnPL = Instance.new("TextButton", fAuto)
    btnPL.BackgroundTransparency = 1
    btnPL.BorderSizePixel = 0
    btnPL.Font = Enum.Font.Bangers
    btnPL.TextSize = 15
    btnPL.TextColor3 = Color3.fromRGB(255,255,255)
    btnPL.Size = UDim2.new(0,52,0,24)
    btnPL.Position = UDim2.new(0,66,0,56)
    btnPL.Text = "LEFT"
    btnPL.AutoButtonColor = false
    btnPL.ZIndex = 32
    Instance.new("UICorner", btnPL).CornerRadius = UDim.new(0,7)
    local sPL = Instance.new("UIStroke", btnPL)
    sPL.Thickness = 1.5; sPL.Color = STROKE_ACTIVE
    sPL.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    sPL.Enabled = false

    local dotRow = Instance.new("Frame", fAuto)
    dotRow.BackgroundTransparency = 1
    dotRow.Size = UDim2.new(1,0,0,12)
    dotRow.Position = UDim2.new(0,0,0,84)
    dotRow.ZIndex = 31

    local dotR = Instance.new("Frame", dotRow)
    dotR.Size = UDim2.new(0,7,0,7)
    dotR.Position = UDim2.new(0.5,-10,0.5,-3)
    dotR.BackgroundColor3 = DOT_OFF
    dotR.BorderSizePixel = 0; dotR.ZIndex = 32
    Instance.new("UICorner", dotR).CornerRadius = UDim.new(1,0)

    local dotL = Instance.new("Frame", dotRow)
    dotL.Size = UDim2.new(0,7,0,7)
    dotL.Position = UDim2.new(0.5,3,0.5,-3)
    dotL.BackgroundColor3 = DOT_OFF
    dotL.BorderSizePixel = 0; dotL.ZIndex = 32
    Instance.new("UICorner", dotL).CornerRadius = UDim.new(1,0)

    if dadosSalvosAuto.keybind then
        local ok, kc = pcall(function() return Enum.KeyCode[dadosSalvosAuto.keybind] end);
        if ok and kc then autoKeyBind = kc end
    end

    local function atualizarPainelVisual()
        sPR.Enabled = (ladoEscolhido == "RIGHT")
        sPL.Enabled = (ladoEscolhido == "LEFT")
        dotR.BackgroundColor3 = (ladoEscolhido == "RIGHT") and DOT_ON or DOT_OFF
        dotL.BackgroundColor3 = (ladoEscolhido == "LEFT")  and DOT_ON or DOT_OFF
    end
    atualizarPainelVisual()

    local _autoToggleSettings = makeInlineExpand(fAuto, 34, 98)
    btnGear.MouseButton1Click:Connect(function() if _dragJustHappened then return end _autoToggleSettings() end);

    btnPR.MouseButton1Click:Connect(function()
        if _dragJustHappened then return end
        ladoEscolhido = "RIGHT"
        atualizarPainelVisual(); atualizarBtnAutoVisual()

        local tw = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(fAuto, tw, {Size = UDim2.new(0, fAuto.Size.X.Offset, 0, 34)}):Play()
    end);

    btnPL.MouseButton1Click:Connect(function()
        if _dragJustHappened then return end
        ladoEscolhido = "LEFT"
        atualizarPainelVisual(); atualizarBtnAutoVisual()

        local tw = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(fAuto, tw, {Size = UDim2.new(0, fAuto.Size.X.Offset, 0, 34)}):Play()
    end);

    MakeDrag(fAuto, function()
        dadosSalvosAuto.px = fAuto.AbsolutePosition.X
        dadosSalvosAuto.py = fAuto.AbsolutePosition.Y
        salvarDadosAuto()
    end);

    local waitingKeyL = false; local waitingKeyR = false
    local keyBindL = nil; local keyBindR = nil

    local function atualizarEstadoL(v)
        AutoL = v
        if not v and not AutoR then
            AutoPlayAtivo = false; autoPlayOn = false
            if mvSpeedOn and _bridgeSetMvSpeed and not lp:GetAttribute("Stealing") then _bridgeSetMvSpeed(duelNotStealSpeed) end
            atualizarBtnAutoVisual()
        end
    end
    local function atualizarEstadoR(v)
        AutoR = v
        if not v and not AutoL then
            AutoPlayAtivo = false; autoPlayOn = false
            if mvSpeedOn and _bridgeSetMvSpeed and not lp:GetAttribute("Stealing") then _bridgeSetMvSpeed(duelNotStealSpeed) end
            atualizarBtnAutoVisual()
        end
    end

    local heartbeatL = nil; local heartbeatR = nil
    local isReturning = false; local isGoingToSlot = false

    local function finalizarPercursoLeft()
        if heartbeatL then heartbeatL:Disconnect(); heartbeatL = nil end
        isReturning = false; SpeedValueLeft = savedSpeedLeft
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
        if hum then hum:Move(Vector3.zero) end
        atualizarEstadoL(false)
    end

    local function returnToBaseLeft()
        if heartbeatL then heartbeatL:Disconnect(); heartbeatL = nil end
        isReturning = true; isGoingToSlot = false
        local c0 = lp.Character
        local h0 = c0 and c0:FindFirstChild("HumanoidRootPart")
        local hum0 = c0 and c0:FindFirstChildOfClass("Humanoid")
        if h0 then h0.AssemblyLinearVelocity = Vector3.zero end
        if hum0 then hum0:Move(Vector3.zero) end
        SpeedValueLeft = duelReturnSpeed
        local waypoints = {R1, P1, P2}; local wp = 1; local duelBarTriggered = false
        heartbeatL = RunService.Heartbeat:Connect(function()
            if not AutoL then heartbeatL:Disconnect(); heartbeatL = nil; return end
            local char = lp.Character; if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            local target = waypoints[wp]
            local dist = (Vector3.new(target.X, hrp.Position.Y, target.Z) - hrp.Position).Magnitude
            if dist < 1.5 then
                if wp == 1 and not duelBarTriggered then duelBarTriggered = true; duelBarSetPhase(0) end
                if wp < #waypoints then wp = wp + 1 else finalizarPercursoLeft(); return end
            end
            local dir = (target - hrp.Position).Unit
            hum:Move(dir, false)
            local _sv = mvSpeedOn and mvSpeedVal or SpeedValueLeft
            hrp.AssemblyLinearVelocity = Vector3.new(dir.X * _sv, hrp.AssemblyLinearVelocity.Y, dir.Z * _sv)
        end);
    end

    local function runAutoLeft()
        if heartbeatL then heartbeatL:Disconnect(); heartbeatL = nil end
        isGoingToSlot = true; isReturning = false; duelBarSetPhase(1)
        local char = lp.Character; if not char then atualizarEstadoL(false); return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then atualizarEstadoL(false); return end
        SpeedValueLeft = duelNotStealSpeed; savedSpeedLeft = duelNotStealSpeed
        local phase = 1
        heartbeatL = RunService.Heartbeat:Connect(function()
            if not AutoL then heartbeatL:Disconnect(); heartbeatL = nil; return end
            char = lp.Character; if not char then return end
            hrp = char:FindFirstChild("HumanoidRootPart"); hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            local target = phase == 1 and R1 or (phase == 2 and R2 or R_EXTRA)
            local dist = (target - Vector3.new(hrp.Position.X, target.Y, hrp.Position.Z)).Magnitude
            if dist < 1.5 then
                if phase == 1 then
                    phase = 2; SpeedValueLeft = 58; duelBarSetPhase(2)
                elseif phase == 2 then
                    phase = 3; SpeedValueLeft = 55; duelBarSetPhase(3)
                else

                    if mvSpeedOn and _bridgeSetMvSpeed then _bridgeSetMvSpeed(duelReturnSpeed) end
                    heartbeatL:Disconnect(); heartbeatL = nil; returnToBaseLeft(); return
                end
            end
            local dir = (target - hrp.Position).Unit
            hum:Move(dir, false)
            local _sv = mvSpeedOn and mvSpeedVal or SpeedValueLeft
            hrp.AssemblyLinearVelocity = Vector3.new(dir.X * _sv, hrp.AssemblyLinearVelocity.Y, dir.Z * _sv)
        end);
    end

    local function finalizarPercursoRight()
        if heartbeatR then heartbeatR:Disconnect(); heartbeatR = nil end
        isReturning = false; SpeedValueRight = savedSpeedRight
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
        if hum then hum:Move(Vector3.zero) end
        atualizarEstadoR(false)
    end

    local function returnToBaseRight()
        if heartbeatR then heartbeatR:Disconnect(); heartbeatR = nil end
        isReturning = true; isGoingToSlot = false
        local c0 = lp.Character
        local h0 = c0 and c0:FindFirstChild("HumanoidRootPart")
        local hum0 = c0 and c0:FindFirstChildOfClass("Humanoid")
        if h0 then h0.AssemblyLinearVelocity = Vector3.zero end
        if hum0 then hum0:Move(Vector3.zero) end
        SpeedValueRight = duelReturnSpeed
        local waypoints = {P1, R1, R2}; local wp = 1; local duelBarTriggered = false
        heartbeatR = RunService.Heartbeat:Connect(function()
            if not AutoR then heartbeatR:Disconnect(); heartbeatR = nil; return end
            local char = lp.Character; if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            local target = waypoints[wp]
            local dist = (Vector3.new(target.X, hrp.Position.Y, target.Z) - hrp.Position).Magnitude
            if dist < 1.5 then
                if wp == 1 and not duelBarTriggered then duelBarTriggered = true; duelBarSetPhase(0) end
                if wp < #waypoints then wp = wp + 1 else finalizarPercursoRight(); return end
            end
            local dir = (target - hrp.Position).Unit
            hum:Move(dir, false)
            local _sv = mvSpeedOn and mvSpeedVal or SpeedValueRight
            hrp.AssemblyLinearVelocity = Vector3.new(dir.X * _sv, hrp.AssemblyLinearVelocity.Y, dir.Z * _sv)
        end);
    end

    local function runAutoRight()
        if heartbeatR then heartbeatR:Disconnect(); heartbeatR = nil end
        isGoingToSlot = true; isReturning = false; duelBarSetPhase(1)
        local char = lp.Character; if not char then atualizarEstadoR(false); return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then atualizarEstadoR(false); return end
        SpeedValueRight = duelNotStealSpeed; savedSpeedRight = duelNotStealSpeed
        local phase = 1
        heartbeatR = RunService.Heartbeat:Connect(function()
            if not AutoR then heartbeatR:Disconnect(); heartbeatR = nil; return end
            char = lp.Character; if not char then return end
            hrp = char:FindFirstChild("HumanoidRootPart"); hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            local target = phase == 1 and P1 or (phase == 2 and P2 or P_EXTRA)
            local dist = (target - Vector3.new(hrp.Position.X, target.Y, hrp.Position.Z)).Magnitude
            if dist < 1.5 then
                if phase == 1 then
                    phase = 2; SpeedValueRight = 58; duelBarSetPhase(2)
                elseif phase == 2 then
                    phase = 3; SpeedValueRight = 55; duelBarSetPhase(3)
                else

                    if mvSpeedOn and _bridgeSetMvSpeed then _bridgeSetMvSpeed(duelReturnSpeed) end
                    heartbeatR:Disconnect(); heartbeatR = nil; returnToBaseRight(); return
                end
            end
            local dir = (target - hrp.Position).Unit
            hum:Move(dir, false)
            local sv = mvSpeedOn and mvSpeedVal or SpeedValueRight
            hrp.AssemblyLinearVelocity = Vector3.new(dir.X * sv, hrp.AssemblyLinearVelocity.Y, dir.Z * sv)
        end);
    end

    local function executarLado(lado)
        AutoPlayAtivo = true; autoPlayOn = true

        if mvSpeedOn and _bridgeSetMvSpeed then _bridgeSetMvSpeed(duelNotStealSpeed) end
        atualizarBtnAutoVisual()
        if lado == "LEFT" then
            AutoR = false; AutoL = true
            if heartbeatR then heartbeatR:Disconnect(); heartbeatR = nil end
            runAutoLeft()
        else
            AutoL = false; AutoR = true
            if heartbeatL then heartbeatL:Disconnect(); heartbeatL = nil end
            runAutoRight()
        end
    end

    do
        local lookAlign  = nil
        local lookAttach = nil
        local wasActive  = false

        local function cleanLook()
            if lookAlign  and lookAlign.Parent  then lookAlign:Destroy()  end
            if lookAttach and lookAttach.Parent then lookAttach:Destroy() end
            lookAlign = nil; lookAttach = nil
        end

        local function setupLook(hrp)
            cleanLook()
            lookAttach = Instance.new("Attachment", hrp)
            lookAlign  = Instance.new("AlignOrientation", hrp)
            lookAlign.Attachment0     = lookAttach
            lookAlign.Mode            = Enum.OrientationAlignmentMode.OneAttachment
            lookAlign.RigidityEnabled = true
            lookAlign.Responsiveness  = 200
            lookAlign.Enabled         = false
        end

        RunService.Heartbeat:Connect(function(dt)
            local active = AutoPlayAtivo

            if active then
                local char = lp.Character
                local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then

                    if not lookAlign or not lookAlign.Parent then
                        setupLook(hrp)
                    end

                    local targetPart = findNearestTarget()
                    local targetPos  = targetPart and targetPart.Position

                    if targetPos then
                        local diff = targetPos - hrp.Position
                        local flat = Vector3.new(diff.X, 0, diff.Z)
                        if flat.Magnitude > 0.5 then
                            lookAlign.Enabled = true
                            lookAlign.CFrame  = CFrame.lookAt(Vector3.zero, flat)
                        end
                    else

                        if lookAlign then lookAlign.Enabled = false end
                    end

                    local vel = hrp.AssemblyLinearVelocity
                    if vel.Magnitude > 5 then
                        local t = tick()
                        local perp = Vector3.new(-vel.Z, 0, vel.X).Unit
                        local jitter = math.sin(t * 8.3) * 0.018
                        hrp.AssemblyLinearVelocity = vel + perp * (vel.Magnitude * jitter)
                    end
                else
                    cleanLook()
                end
                wasActive = true
            elseif wasActive then
                cleanLook()
                wasActive = false
            end
        end);
    end

    local function iniciarAutoPlay()
        if not ladoEscolhido then return end
        autoPlayWasActive = true
        if aimEnabled then
            aimEnabled = false; stopAimBot()
            setHubActive(LockFrame, aimRedDot, false)
        end
        if abEnabled and stopAbAim and abFrame and abRedDot then
            abEnabled = false; stopAbAim()
            setHubActive(abFrame, abRedDot, false)
        end

        if mvSpeedOn and _bridgeSetMvSpeed then
            if lp:GetAttribute("Stealing") then
                _bridgeSetMvSpeed(duelReturnSpeed)
            else
                _bridgeSetMvSpeed(duelNotStealSpeed)
            end
        end
        executarLado(ladoEscolhido)
    end

    local function hasBrainrotInHand()

        if lp:GetAttribute("Stealing") then return true end

        local c = lp.Character; if not c then return false end
        for _, obj in ipairs(c:GetChildren()) do
            if obj:IsA("Tool") and obj.Name:lower():find("brainrot") then return true end
        end
        return false
    end

    local function pararAutoPlay()
        autoPlayWasActive = false
        AutoPlayAtivo = false; autoPlayOn = false
        AutoL = false; AutoR = false
        if heartbeatL then heartbeatL:Disconnect(); heartbeatL = nil end
        if heartbeatR then heartbeatR:Disconnect(); heartbeatR = nil end

        if mvSpeedOn and _bridgeSetMvSpeed and not lp:GetAttribute("Stealing") then _bridgeSetMvSpeed(duelNotStealSpeed) end
        atualizarBtnAutoVisual()
        local char = lp.Character
        if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum:Move(Vector3.zero) end end
    end
    pararAutoPlayGlobal = pararAutoPlay

    btnAuto.MouseButton1Click:Connect(function()
        if _dragJustHappened then return end
        if not ladoEscolhido then return end

        if not speedWhileStealActive and not mvSpeedOn then
            showToast("Ative o Speed primeiro!")
            return
        end
        if AutoPlayAtivo then pararAutoPlay() else iniciarAutoPlay() end
    end);

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if autoKeyBind and not autoWaitingKey and input.KeyCode == autoKeyBind then
            if ladoEscolhido and (speedWhileStealActive or mvSpeedOn) then
                if AutoPlayAtivo then pararAutoPlay() else iniciarAutoPlay() end
            end
        end
    end);

    lp.CharacterAdded:Connect(function(char)
        char:WaitForChild("HumanoidRootPart")
        char:WaitForChildOfClass("Humanoid")
        if heartbeatL then heartbeatL:Disconnect(); heartbeatL = nil end
        if heartbeatR then heartbeatR:Disconnect(); heartbeatR = nil end
        AutoL = false; AutoR = false
        if autoPlayWasActive and ladoEscolhido then
            task.wait(1.2)
            if autoPlayWasActive and ladoEscolhido then
                AutoPlayAtivo = true; autoPlayOn = true
                executarLado(ladoEscolhido)
            end
        else
            atualizarBtnAutoVisual()
        end
    end);



    local function pararDuelCompleto()
        autoPlayWasActive = false
        if heartbeatL then heartbeatL:Disconnect(); heartbeatL = nil end
        if heartbeatR then heartbeatR:Disconnect(); heartbeatR = nil end
        AutoL = false; AutoR = false; AutoPlayAtivo = false; autoPlayOn = false

        if mvSpeedOn and _bridgeSetMvSpeed and not lp:GetAttribute("Stealing") then _bridgeSetMvSpeed(duelNotStealSpeed) end
        atualizarBtnAutoVisual()
        local char = lp.Character
        if char then local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum:Move(Vector3.zero) end end

    end
    stopDuelExterno = pararDuelCompleto

    local autoTPAtivo  = false
    local autoTPDados  = { px = -1, py = -1 }
    do local d = cfgGet("autoTPPos"); autoTPDados = d or {px=580, py=72} end

    local fAutoTP = Instance.new("Frame", Screen)
    fAutoTP.Name = "AutoTPFrame"
    fAutoTP.BorderSizePixel = 0
    fAutoTP.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    fAutoTP.Size = UDim2.new(0, 128, 0, 34)
    storeHubSize(fAutoTP)
    fAutoTP.Active = true; fAutoTP.ZIndex = 10; fAutoTP.Visible = false

    if autoTPDados.px and autoTPDados.px >= 0 then
        fAutoTP.Position = UDim2.new(0, autoTPDados.px, 0, autoTPDados.py)
    else
        fAutoTP.Position = UDim2.new(0.5, -64, 0.42, 0)
    end

    Instance.new("UICorner", fAutoTP).CornerRadius = UDim.new(0, 10)
    applyHubGradient(fAutoTP)

    local autoTPStroke = Instance.new("UIStroke", fAutoTP)
    autoTPStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    autoTPStroke.Thickness = 2; autoTPStroke.Color = STROKE_IDLE
    autoTPStroke.Transparency = 1

    local autoTPDot = Instance.new("TextLabel", fAutoTP)
    autoTPDot.BackgroundTransparency = 1
    autoTPDot.Size = UDim2.new(0, 14, 0, 14)
    autoTPDot.Position = UDim2.new(0, 3, 0.5, -7)
    autoTPDot.Text = "◉"; autoTPDot.ZIndex = 12
    autoTPDot.TextColor3 = DOT_OFF
    autoTPDot.Font = Enum.Font.GothamBold; autoTPDot.TextSize = 13

    local btnAutoTP = Instance.new("TextButton", fAutoTP)
    btnAutoTP.BackgroundTransparency = 1; btnAutoTP.BorderSizePixel = 0
    btnAutoTP.Font = Enum.Font.Bangers; btnAutoTP.TextSize = 15
    btnAutoTP.Size = UDim2.new(1, -18, 1, -8)
    btnAutoTP.Position = UDim2.new(0, 16, 0, 4)
    btnAutoTP.Text = "TP MANUAL"
    btnAutoTP.TextColor3 = Color3.fromRGB(90, 90, 90)
    btnAutoTP.TextXAlignment = Enum.TextXAlignment.Center
    btnAutoTP.AutoButtonColor = false; btnAutoTP.ZIndex = 12

    MakeDrag(fAutoTP, function()
        autoTPDados.px = fAutoTP.AbsolutePosition.X
        autoTPDados.py = fAutoTP.AbsolutePosition.Y
        cfgSet("autoTPPos", autoTPDados)
    end);

    local function setAutoTPVisual(on)
        autoTPAtivo = on
        autoTPStroke.Color = on and STROKE_ACTIVE or STROKE_IDLE
        TweenService:Create(autoTPStroke, TweenInfo.new(0.18),
            {Transparency = on and 0 or 1}):Play()
        autoTPDot.TextColor3 = on and DOT_ON or DOT_OFF
    end

    local function atualizarBloqueioTP()
        local bloqueado = (ladoEscolhido == nil)
        btnAutoTP.TextColor3 = bloqueado
            and Color3.fromRGB(90, 90, 90)
            or  Color3.fromRGB(255, 255, 255)
        autoTPDot.TextColor3 = bloqueado and Color3.fromRGB(60,60,60) or DOT_OFF
    end
    atualizarBloqueioTP()

    local _origPR = btnPR.MouseButton1Click
    local _origPL = btnPL.MouseButton1Click
    btnPR.MouseButton1Click:Connect(function() task.defer(atualizarBloqueioTP) end);
    btnPL.MouseButton1Click:Connect(function() task.defer(atualizarBloqueioTP) end);

    local function executarTP()
        if not ladoEscolhido then return end

        setAutoTPVisual(true)

        if heartbeatL then heartbeatL:Disconnect(); heartbeatL = nil end
        if heartbeatR then heartbeatR:Disconnect(); heartbeatR = nil end
        AutoL = false; AutoR = false

        local char = lp.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local startPos = (ladoEscolhido == "LEFT") and R1 or P1
            hrp.CFrame = CFrame.new(startPos.X, startPos.Y + 2, startPos.Z)
            hrp.AssemblyLinearVelocity  = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero

            if _bridgeSetMvSpeed then _bridgeSetMvSpeed(duelReturnSpeed) end
        end

        task.wait(0.15)

        AutoPlayAtivo = true; autoPlayOn = true
        autoPlayWasActive = true
        isGoingToSlot = true; isReturning = false
        atualizarBtnAutoVisual()
        duelBarSetPhase(2)

        if ladoEscolhido == "LEFT" then
            AutoL = true; AutoR = false
            SpeedValueLeft = 62; savedSpeedLeft = duelNotStealSpeed
            local phase = 2
            heartbeatL = RunService.Heartbeat:Connect(function()
                if not AutoL then heartbeatL:Disconnect(); heartbeatL = nil; return end
                local c = lp.Character; if not c then return end
                local h = c:FindFirstChild("HumanoidRootPart")
                local hu = c:FindFirstChildOfClass("Humanoid")
                if not h or not hu then return end
                local target = phase == 2 and R2 or R_EXTRA
                local dist = (target - Vector3.new(h.Position.X, target.Y, h.Position.Z)).Magnitude
                if dist < 1.5 then
                    if phase == 2 then phase = 3; SpeedValueLeft = 55; duelBarSetPhase(3)
                    else heartbeatL:Disconnect(); heartbeatL = nil; returnToBaseLeft(); return end
                end
                local dir2 = (target - h.Position).Unit
                hu:Move(dir2, false)
                local _sv = mvSpeedOn and mvSpeedVal or SpeedValueLeft
                h.AssemblyLinearVelocity = Vector3.new(dir2.X * _sv, h.AssemblyLinearVelocity.Y, dir2.Z * _sv)
            end);
        else
            AutoR = true; AutoL = false
            SpeedValueRight = 62; savedSpeedRight = duelNotStealSpeed
            local phase = 2
            heartbeatR = RunService.Heartbeat:Connect(function()
                if not AutoR then heartbeatR:Disconnect(); heartbeatR = nil; return end
                local c = lp.Character; if not c then return end
                local h = c:FindFirstChild("HumanoidRootPart")
                local hu = c:FindFirstChildOfClass("Humanoid")
                if not h or not hu then return end
                local target = phase == 2 and P2 or P_EXTRA
                local dist = (target - Vector3.new(h.Position.X, target.Y, h.Position.Z)).Magnitude
                if dist < 1.5 then
                    if phase == 2 then phase = 3; SpeedValueRight = 55; duelBarSetPhase(3)
                    else heartbeatR:Disconnect(); heartbeatR = nil; returnToBaseRight(); return end
                end
                local dir2 = (target - h.Position).Unit
                hu:Move(dir2, false)
                local _sv = mvSpeedOn and mvSpeedVal or SpeedValueRight
                h.AssemblyLinearVelocity = Vector3.new(dir2.X * _sv, h.AssemblyLinearVelocity.Y, dir2.Z * _sv)
            end);
        end
    end

    btnAutoTP.MouseButton1Click:Connect(function()
        if _dragJustHappened then return end
        if not ladoEscolhido then
            TweenService:Create(btnAutoTP, TweenInfo.new(0.1),
                {TextColor3 = Color3.fromRGB(180, 60, 60)}):Play()
            task.delay(0.35, function()
                TweenService:Create(btnAutoTP, TweenInfo.new(0.2),
                    {TextColor3 = Color3.fromRGB(90, 90, 90)}):Play()
            end);
            return
        end

        if autoTPAtivo then
            pararAutoPlay()
            setAutoTPVisual(false)
        else
            executarTP()
        end
    end);

    UIS.InputBegan:Connect(function(input, gp)
        if gp or waitingAutoTP then return end
        if keyBindAutoTP and input.KeyCode == keyBindAutoTP and fAutoTP.Visible then
            if not ladoEscolhido then return end
            if autoTPAtivo then pararAutoPlay(); setAutoTPVisual(false)
            else executarTP() end
        end
    end);

    do
        local saved = cfgGet("autoTPPos") or {}
        if saved.keybind then
            local ok, kc = pcall(function() return Enum.KeyCode[saved.keybind] end);
            if ok and kc then keyBindAutoTP = kc end
        end
    end

    do
        local hitTPAtivo   = false
        local hitTPCooldown = false
        local hadBrainrot  = false
        local hitTPConn    = nil

        local hitTPDados = { px = -1, py = -1 }
        do local d = cfgGet("hitTPPos"); hitTPDados = d or {px=579, py=32} end

        local fHitTP = Instance.new("Frame", Screen)
        fHitTP.Name = "HitTPFrame"
        fHitTP.BorderSizePixel = 0
        fHitTP.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        fHitTP.Size = UDim2.new(0, 128, 0, 34)
    storeHubSize(fHitTP)
        fHitTP.Active = true; fHitTP.ZIndex = 10; fHitTP.Visible = false

        if hitTPDados.px and hitTPDados.px >= 0 then
            fHitTP.Position = UDim2.new(0, hitTPDados.px, 0, hitTPDados.py)
        else
            fHitTP.Position = UDim2.new(0.5, -55, 0.50, 0)
        end

        Instance.new("UICorner", fHitTP).CornerRadius = UDim.new(0, 10)
        applyHubGradient(fHitTP)

        local hitTPStroke = Instance.new("UIStroke", fHitTP)
        hitTPStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        hitTPStroke.Thickness = 2; hitTPStroke.Color = STROKE_IDLE
        hitTPStroke.Transparency = 1

        local hitTPDot = Instance.new("TextLabel", fHitTP)
        hitTPDot.BackgroundTransparency = 1
        hitTPDot.Size = UDim2.new(0, 14, 0, 14)
        hitTPDot.Position = UDim2.new(0, 3, 0.5, -7)
        hitTPDot.Text = "◉"; hitTPDot.ZIndex = 12
        hitTPDot.TextColor3 = DOT_OFF
        hitTPDot.Font = Enum.Font.GothamBold; hitTPDot.TextSize = 13

        local btnHitTP = Instance.new("TextButton", fHitTP)
        btnHitTP.BackgroundTransparency = 1; btnHitTP.BorderSizePixel = 0
        btnHitTP.Font = Enum.Font.Bangers; btnHitTP.TextSize = 15
        btnHitTP.Size = UDim2.new(1, -18, 1, -8)
        btnHitTP.Position = UDim2.new(0, 16, 0, 4)
        btnHitTP.Text = "AUTO TP"
        btnHitTP.TextColor3 = Color3.fromRGB(90, 90, 90)
        btnHitTP.TextXAlignment = Enum.TextXAlignment.Center
        btnHitTP.AutoButtonColor = false; btnHitTP.ZIndex = 12

        MakeDrag(fHitTP, function()
            hitTPDados.px = fHitTP.AbsolutePosition.X
            hitTPDados.py = fHitTP.AbsolutePosition.Y
            cfgSet("hitTPPos", hitTPDados)
        end);

        local function setHitTPVisual(on)
            hitTPAtivo = on
            hitTPStroke.Color = on and STROKE_ACTIVE or STROKE_IDLE
            TweenService:Create(hitTPStroke, TweenInfo.new(0.18),
                {Transparency = on and 0 or 1}):Play()
            hitTPDot.TextColor3 = on and DOT_ON or DOT_OFF
        end

        local function atualizarBloqueioHitTP()
            local bloqueado = (ladoEscolhido == nil)
            btnHitTP.TextColor3 = bloqueado
                and Color3.fromRGB(90, 90, 90)
                or  Color3.fromRGB(255, 255, 255)
            hitTPDot.TextColor3 = bloqueado and Color3.fromRGB(60, 60, 60) or DOT_OFF
        end
        atualizarBloqueioHitTP()

        btnPR.MouseButton1Click:Connect(function() task.defer(atualizarBloqueioHitTP) end);
        btnPL.MouseButton1Click:Connect(function() task.defer(atualizarBloqueioHitTP) end);

        local stateConn  = nil
        local charConn   = nil

        local function conectarEstado(char)
            if stateConn then stateConn:Disconnect(); stateConn = nil end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            stateConn = hum.StateChanged:Connect(function(_, newState)
                if not hitTPAtivo then return end
                if not ladoEscolhido then return end
                if hitTPCooldown then return end

                if newState == Enum.HumanoidStateType.Physics
                or newState == Enum.HumanoidStateType.Ragdoll
                or newState == Enum.HumanoidStateType.FallingDown then
                    hitTPCooldown = true
                    task.spawn(function()
                        task.wait(0.01)

                        local bc = lp.Character
                        if bc then
                            local bh = bc:FindFirstChild("HumanoidRootPart")
                            local bm = bc:FindFirstChildOfClass("Humanoid")
                            if bm and bh then
                                bm:ChangeState(Enum.HumanoidStateType.Running)
                                pcall(function() if ControlModule then ControlModule:Enable() end end);
                                bh.AssemblyLinearVelocity  = Vector3.zero
                                bh.AssemblyAngularVelocity = Vector3.zero
                                for _, obj in ipairs(bc:GetDescendants()) do
                                    if obj:IsA("Motor6D") and obj.Enabled == false then
                                        obj.Enabled = true
                                    end
                                end
                            end
                        end

                        task.wait(0.03)

                        if hitTPAtivo and ladoEscolhido then
                            executarTP()
                        end
                        task.wait(2.5)
                        hitTPCooldown = false
                    end);
                end
            end);
        end

        local function iniciarHitTPLoop()
            if hitTPConn then hitTPConn:Disconnect(); hitTPConn = nil end
            if stateConn then stateConn:Disconnect(); stateConn = nil end
            if charConn  then charConn:Disconnect();  charConn  = nil end
            hitTPCooldown = false

            local char = lp.Character
            if char then conectarEstado(char) end

            charConn = lp.CharacterAdded:Connect(function(newChar)
                newChar:WaitForChild("Humanoid", 5)
                conectarEstado(newChar)
                hitTPCooldown = false
            end);
        end

        btnHitTP.MouseButton1Click:Connect(function()
            if _dragJustHappened then return end
            if not ladoEscolhido then
                TweenService:Create(btnHitTP, TweenInfo.new(0.1),
                    {TextColor3 = Color3.fromRGB(180, 60, 60)}):Play()
                task.delay(0.35, function()
                    TweenService:Create(btnHitTP, TweenInfo.new(0.2),
                        {TextColor3 = Color3.fromRGB(90, 90, 90)}):Play()
                end);
                return
            end
            hitTPAtivo = not hitTPAtivo
            setHitTPVisual(hitTPAtivo)
            if hitTPAtivo then
                iniciarHitTPLoop()
            else
                if hitTPConn  then hitTPConn:Disconnect();  hitTPConn  = nil end
                if stateConn  then stateConn:Disconnect();  stateConn  = nil end
                if charConn   then charConn:Disconnect();   charConn   = nil end
                hitTPCooldown = false
            end
        end);

        UIS.InputBegan:Connect(function(input, gp)
            if gp or waitingHitTP then return end
            if keyBindHitTP and input.KeyCode == keyBindHitTP and fHitTP.Visible then
                if not ladoEscolhido then return end
                hitTPAtivo = not hitTPAtivo
                setHitTPVisual(hitTPAtivo)
                if hitTPAtivo then iniciarHitTPLoop()
                else
                    if hitTPConn  then hitTPConn:Disconnect();  hitTPConn  = nil end
                    if stateConn  then stateConn:Disconnect();  stateConn  = nil end
                    if charConn   then charConn:Disconnect();   charConn   = nil end
                    hitTPCooldown = false
                end
            end
        end);

        do
            local saved = cfgGet("hitTPPos") or {}
            if saved.keybind then
                local ok, kc = pcall(function() return Enum.KeyCode[saved.keybind] end);
                if ok and kc then keyBindHitTP = kc end
            end
        end

        fHitTP.Visible = false
        hitTPHubFrame = fHitTP
    end

    RunService.Heartbeat:Connect(function()
        if autoTPAtivo and not AutoPlayAtivo then
            setAutoTPVisual(false)
        end
    end);

    autoTPHubFrame = fAutoTP

    return {
        toggle = function()
            if AutoPlayAtivo then pararDuelCompleto() else iniciarAutoPlay() end
        end,
        isActive = function() return AutoPlayAtivo end,
        setNotStealSpeed = function(v)
            SpeedValueLeft  = v; savedSpeedLeft  = v
            SpeedValueRight = v; savedSpeedRight = v
        end,
        getPositions = function()
            return {P1=P1, P2=P2, P_EXTRA=P_EXTRA, R1=R1, R2=R2, R_EXTRA=R_EXTRA}
        end,
        setPosition = function(name, v3)
            if     name == "P1"      then P1      = v3
            elseif name == "P2"      then P2      = v3
            elseif name == "P_EXTRA" then P_EXTRA = v3
            elseif name == "R1"      then R1      = v3
            elseif name == "R2"      then R2      = v3
            elseif name == "R_EXTRA" then R_EXTRA = v3
            end
        end,
    }
end;

(function()
    local posGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
    posGui.Name = "PosHubGui"
    posGui.ResetOnSpawn = false
    posGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    posGui.Enabled = false

    local KEYS   = {"P1","P2","P_EXTRA","R1","R2","R_EXTRA"}
    local LABELS = {"P1","P2","P END","R1","R2","R END"}
    local COLORS = {
        Color3.fromRGB(80,160,255),
        Color3.fromRGB(50,120,220),
        Color3.fromRGB(30,80,180),
        Color3.fromRGB(255,120,80),
        Color3.fromRGB(220,70,50),
        Color3.fromRGB(180,40,30),
    }

    local ROW_H   = 26
    local PAD     = 8
    local W       = 200
    local H_TITLE = 28
    local BTN_H   = 28
    local H_TOTAL = H_TITLE + #KEYS * ROW_H + PAD + BTN_H + 4

    local _posSaved = cfgGet("posHubPos") or {}
    local fPos = Instance.new("Frame", posGui)
    fPos.Name = "PosHub"
    fPos.Size = UDim2.new(0, W, 0, H_TOTAL)
    if _posSaved.px and _posSaved.px >= 0 then
        fPos.Position = UDim2.new(0, _posSaved.px, 0, _posSaved.py)
    else

        local vp = workspace.CurrentCamera.ViewportSize
        fPos.Position = UDim2.new(0, math.floor(vp.X/2 - W/2), 0, math.floor(vp.Y - H_TOTAL - 80))
    end
    fPos.BackgroundColor3 = Color3.fromRGB(0,0,0)
    fPos.Active = true
    fPos.BorderSizePixel = 0
    Instance.new("UICorner", fPos).CornerRadius = UDim.new(0, 10)
    applyHubGradient(fPos)
    addDefaultStroke(fPos)

    local title = Instance.new("TextLabel", fPos)
    title.Size = UDim2.new(1, -8, 0, H_TITLE)
    title.Position = UDim2.new(0, 8, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "SET POSITIONS"
    title.Font = Enum.Font.Bangers
    title.TextSize = 15
    title.TextColor3 = Color3.new(1,1,1)
    title.TextXAlignment = Enum.TextXAlignment.Left

    local btnClose = Instance.new("TextButton", fPos)
    btnClose.Size = UDim2.new(0, 22, 0, 22)
    btnClose.Position = UDim2.new(1, -26, 0, 3)
    btnClose.BackgroundTransparency = 1
    btnClose.Text = "✕"
    btnClose.Font = Enum.Font.GothamBold
    btnClose.TextSize = 12
    btnClose.TextColor3 = Color3.fromRGB(160,160,160)
    btnClose.AutoButtonColor = false
    btnClose.MouseButton1Click:Connect(function()
        posGui.Enabled = false
    end);

    local _drag = false; local _ds, _sap
    title.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            _drag = true; _ds = i.Position; _sap = fPos.AbsolutePosition
        end
    end);
    UIS.InputChanged:Connect(function(i)
        if _drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - _ds
            fPos.Position = UDim2.new(0, _sap.X+d.X, 0, _sap.Y+d.Y)
        end
    end);
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            if _drag then
                local ap = fPos.AbsolutePosition
                cfgSetNow("posHubPos", {px=ap.X, py=ap.Y})
            end
            _drag = false
        end
    end);

    for i, key in ipairs(KEYS) do
        local rowY = H_TITLE + (i-1)*ROW_H

        local lbl = Instance.new("TextLabel", fPos)
        lbl.Size = UDim2.new(0, 52, 0, ROW_H)
        lbl.Position = UDim2.new(0, PAD, 0, rowY)
        lbl.BackgroundTransparency = 1
        lbl.Text = LABELS[i]
        lbl.Font = Enum.Font.Bangers
        lbl.TextSize = 13
        lbl.TextColor3 = COLORS[i]
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local btnSet = Instance.new("TextButton", fPos)
        btnSet.Size = UDim2.new(0, 50, 0, 18)
        btnSet.Position = UDim2.new(0, 62, 0, rowY + 4)
        btnSet.BackgroundColor3 = Color3.fromRGB(25,25,25)
        btnSet.Font = Enum.Font.Bangers
        btnSet.TextSize = 12
        btnSet.TextColor3 = Color3.fromRGB(200,200,200)
        btnSet.Text = "SET"
        btnSet.AutoButtonColor = false
        btnSet.BorderSizePixel = 0
        Instance.new("UICorner", btnSet).CornerRadius = UDim.new(0,5)
        local btnStk = Instance.new("UIStroke", btnSet)
        btnStk.Color = COLORS[i]; btnStk.Thickness = 1

        local coordLbl = Instance.new("TextLabel", fPos)
        coordLbl.Size = UDim2.new(0, 76, 0, ROW_H)
        coordLbl.Position = UDim2.new(0, 116, 0, rowY)
        coordLbl.BackgroundTransparency = 1
        coordLbl.Font = Enum.Font.Code
        coordLbl.TextSize = 8
        coordLbl.TextColor3 = Color3.fromRGB(130,130,130)
        coordLbl.TextXAlignment = Enum.TextXAlignment.Left
        coordLbl.Text = "..."

        local function refreshCoord()
            if duelModule and duelModule.getPositions then
                local p = duelModule.getPositions()[key]
                if p then coordLbl.Text = string.format("%.0f\n%.0f %.0f", p.X, p.Y, p.Z) end
            end
        end
        task.defer(refreshCoord)

        btnSet.MouseButton1Click:Connect(function()
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if duelModule and duelModule.setPosition then
                duelModule.setPosition(key, hrp.Position)

                local pos = duelModule.getPositions()
                cfgSet("duelPositions", {
                    P1x=pos.P1.X,     P1y=pos.P1.Y,     P1z=pos.P1.Z,
                    P2x=pos.P2.X,     P2y=pos.P2.Y,     P2z=pos.P2.Z,
                    PEXx=pos.P_EXTRA.X, PEXy=pos.P_EXTRA.Y, PEXz=pos.P_EXTRA.Z,
                    R1x=pos.R1.X,     R1y=pos.R1.Y,     R1z=pos.R1.Z,
                    R2x=pos.R2.X,     R2y=pos.R2.Y,     R2z=pos.R2.Z,
                    REXx=pos.R_EXTRA.X, REXy=pos.R_EXTRA.Y, REXz=pos.R_EXTRA.Z,
                })
                refreshCoord()
                showToast(LABELS[i] .. " salvo!")

                TweenService:Create(btnSet, TweenInfo.new(0.1),
                    {BackgroundColor3=Color3.fromRGB(30,80,30)}):Play()
                task.delay(0.4, function()
                    TweenService:Create(btnSet, TweenInfo.new(0.2),
                        {BackgroundColor3=Color3.fromRGB(25,25,25)}):Play()
                end);
            end
        end);
    end

    local showPtsOn = false
    local wpParts = {}

    local function clearWpParts()
        for _, p in ipairs(wpParts) do pcall(function() p:Destroy() end) end
        wpParts = {}
    end

    local function showWaypoints()
        clearWpParts()
        if not duelModule or not duelModule.getPositions then return end
        local pos = duelModule.getPositions()
        local nameMap = {P1="P1",P2="P2",P_EXTRA="P End",R1="R1",R2="R2",R_EXTRA="R End"}
        local colorMap = {
            P1=Color3.fromRGB(80,160,255), P2=Color3.fromRGB(50,120,220), P_EXTRA=Color3.fromRGB(30,80,180),
            R1=Color3.fromRGB(255,120,80), R2=Color3.fromRGB(220,70,50),  R_EXTRA=Color3.fromRGB(180,40,30),
        }
        for key, v3 in pairs(pos) do
            local part = Instance.new("Part")
            part.Size = Vector3.new(1, 1, 1)
            part.CFrame = CFrame.new(v3.X, v3.Y + 0.5, v3.Z)
            part.Anchored = true
            part.CanCollide = false
            part.Transparency = 0.3
            part.Color = colorMap[key] or Color3.new(1,1,1)
            part.Material = Enum.Material.Neon
            part.Parent = Workspace
            local bb = Instance.new("BillboardGui", part)
            bb.Size = UDim2.new(0, 60, 0, 24)
            bb.StudsOffset = Vector3.new(0, 2, 0)
            bb.AlwaysOnTop = true
            local lbl = Instance.new("TextLabel", bb)
            lbl.Size = UDim2.new(1,0,1,0)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.Bangers
            lbl.TextSize = 16
            lbl.TextColor3 = colorMap[key] or Color3.new(1,1,1)
            lbl.Text = nameMap[key] or key
            lbl.TextStrokeTransparency = 0
            table.insert(wpParts, part)
        end
    end

    local showBtn = Instance.new("TextButton", fPos)
    showBtn.Size = UDim2.new(1, -16, 0, BTN_H - 4)
    showBtn.Position = UDim2.new(0, 8, 0, H_TITLE + #KEYS * ROW_H + PAD)
    showBtn.BackgroundColor3 = Color3.fromRGB(25,25,25)
    showBtn.Font = Enum.Font.Bangers
    showBtn.TextSize = 13
    showBtn.TextColor3 = Color3.fromRGB(200,200,200)
    showBtn.Text = "Show Points"
    showBtn.AutoButtonColor = false
    showBtn.BorderSizePixel = 0
    Instance.new("UICorner", showBtn).CornerRadius = UDim.new(0,6)
    local showBtnStroke = Instance.new("UIStroke", showBtn)
    showBtnStroke.Thickness = 1; showBtnStroke.Color = Color3.fromRGB(80,80,80)

    showBtn.MouseButton1Click:Connect(function()
        showPtsOn = not showPtsOn
        if showPtsOn then
            showWaypoints()
            showBtn.TextColor3 = Color3.fromRGB(255,220,80)
            showBtnStroke.Color = Color3.fromRGB(255,220,80)
        else
            clearWpParts()
            showBtn.TextColor3 = Color3.fromRGB(200,200,200)
            showBtnStroke.Color = Color3.fromRGB(80,80,80)
        end
    end);

    posGui:GetPropertyChangedSignal("Enabled"):Connect(function()
        if not posGui.Enabled and showPtsOn then
            showPtsOn = false
            clearWpParts()
            showBtn.TextColor3 = Color3.fromRGB(200,200,200)
            showBtnStroke.Color = Color3.fromRGB(80,80,80)
        end
    end);

    getgenv().__posHubGui = posGui
end)();

local AimSpeed = 55
local aimDadosSalvos = { speed = 55, px = -1, py = -1 }

local function salvarAimConfig()
    cfgSet("aimBotConfig", aimDadosSalvos)
end
local function carregarAimConfig()
    local dados = cfgGet("aimBotConfig") or {px=130, py=7, speed=58}
    do

        if dados.posicaoHub then
            local vp = workspace.CurrentCamera.ViewportSize
            dados.px = math.floor((dados.posicaoHub.X or 0.5) * vp.X)
            dados.py = math.floor((dados.posicaoHub.Y or 0.78) * vp.Y)
            dados.posicaoHub = nil; dados.posicaoSettings = nil
        end
        aimDadosSalvos = dados
        AimSpeed = math.clamp(aimDadosSalvos.speed or 55, 1, 200)
    end
end
carregarAimConfig()

local function findNearestEnemyAim(myHRP)
    local nearest, nearestDist, nearestTorso = nil, math.huge, nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character then
            local eh = p.Character:FindFirstChild("HumanoidRootPart")
            if not eh then continue end
            local torso = p.Character:FindFirstChild("UpperTorso") or p.Character:FindFirstChild("Torso")
            local d = (eh.Position - myHRP.Position).Magnitude
            if d < nearestDist then nearestDist = d; nearest = eh; nearestTorso = torso or eh end
        end
    end
    return nearest, nearestDist, nearestTorso
end

local SlapListAim = {"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap"}
local function findBatAim()
    local c = lp.Character; if not c then return nil end
    local bp = lp:FindFirstChildOfClass("Backpack")
    for _, ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end
    if bp then for _, ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    for _, name in ipairs(SlapListAim) do
        local t = c:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
        if t then return t end
    end
    return nil
end

local function activateAntiDie()
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    hum.BreakJointsOnDeath = false
    hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    hum:GetPropertyChangedSignal("Health"):Connect(function()
        if hum.Health <= 0 then hum.Health = hum.MaxHealth end
    end);
    hum.Died:Connect(function()
        task.wait()
        local newHum = Instance.new("Humanoid")
        newHum.Name = "ReplacedHumanoid"; newHum.Parent = char
        workspace.CurrentCamera.CameraSubject = newHum; hum:Destroy()
    end);
end

local aimConnections     = {}
local _aimCachedTarget, _aimCachedTorso = nil, nil
local _aimAlign  = nil
local _aimAttach = nil

local function cleanAimPhysics()
    if _aimAlign  then pcall(function() _aimAlign:Destroy()  end); _aimAlign  = nil end
    if _aimAttach then pcall(function() _aimAttach:Destroy() end); _aimAttach = nil end
end

local function setupAimAlign(hrp)
    cleanAimPhysics()
    _aimAttach = Instance.new("Attachment", hrp)
    _aimAlign  = Instance.new("AlignOrientation", hrp)
    _aimAlign.Attachment0     = _aimAttach
    _aimAlign.Mode            = Enum.OrientationAlignmentMode.OneAttachment
    _aimAlign.RigidityEnabled = true
    _aimAlign.Enabled         = false
end

startAimBot = function()
    if aimConnections.aimbot then return end
    activateAntiDie()
    if stopDuelExterno then stopDuelExterno() end
    if autoPlayOn and pararAutoPlayGlobal then pararAutoPlayGlobal() end

    local c0 = lp.Character
    if c0 then
        local hum0 = c0:FindFirstChildOfClass("Humanoid")
        if hum0 then
            local bat = findBatAim()
            if bat then
                task.spawn(function()
                    pcall(function() hum0:UnequipTools() end);
                    task.wait(0.05)
                    pcall(function() hum0:EquipTool(bat) end);
                end);
            end
        end
        local hrp0 = c0:FindFirstChild("HumanoidRootPart")
        if hrp0 then setupAimAlign(hrp0) end
    end

    aimConnections.aimbot = RunService.Heartbeat:Connect(function()
        if not aimEnabled then return end
        local c = lp.Character; if not c then return end
        local h   = c:FindFirstChild("HumanoidRootPart")
        local hum = c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end

        if not _aimAlign or not _aimAlign.Parent then setupAimAlign(h) end

        local target, dist, torso = findNearestEnemyAim(h)
        if not target or not target.Parent then
            _aimCachedTarget = nil; _aimCachedTorso = nil
            if _aimAlign then _aimAlign.Enabled = false end
            hum.AutoRotate = true
            return
        end
        _aimCachedTarget = target; _aimCachedTorso = torso

        local aimPos  = target.Position
        local diff    = aimPos - h.Position
        local flatDir = Vector3.new(diff.X, 0, diff.Z)

        if flatDir.Magnitude > 0.1 and _aimAlign then
            hum.AutoRotate = false
            _aimAlign.Enabled = true
            _aimAlign.CFrame  = CFrame.lookAt(Vector3.zero, Vector3.new(flatDir.X, 0, flatDir.Z))
        end

        local flatDist = flatDir.Magnitude
        local diffY    = diff.Y

        local velY = math.clamp(diffY * 18, -AimSpeed * 1.5, AimSpeed * 1.5)

        if flatDist > 1.5 then
            local moveDir = flatDir.Unit
            h.AssemblyLinearVelocity = Vector3.new(
                moveDir.X * AimSpeed, velY, moveDir.Z * AimSpeed)
        else
            local tv = target.AssemblyLinearVelocity
            h.AssemblyLinearVelocity = Vector3.new(tv.X, velY, tv.Z)
        end

    end);
end

stopAimBot = function()
    if aimConnections.aimbot then aimConnections.aimbot:Disconnect(); aimConnections.aimbot = nil end
    cleanAimPhysics()
    _aimCachedTarget = nil
    _aimCachedTorso  = nil
    local c = lp.Character
    if c then
        local hum = c:FindFirstChildOfClass("Humanoid")
        if hum then hum.AutoRotate = true end
    end
end

lp.CharacterAdded:Connect(function()
    task.wait(1)
    activateAntiDie()
    if aimEnabled then
        stopAimBot()
        task.wait(0.1)
        startAimBot()
    end
end);

(function()
    local tDados = { px = -1, py = -1 }
    do
        local d = cfgGet("tauntConfig") or {px=43, py=53}
        if d then

            if d.pos then
                local ok, vp = pcall(function() return workspace.CurrentCamera.ViewportSize end);
                if ok and vp and vp.X > 0 then
                    d.px = math.floor((d.pos.X or 0.85) * vp.X)
                    d.py = math.floor((d.pos.Y or 0.92) * vp.Y)
                end
                d.pos = nil
            end
            tDados = d
        end
    end

    local tFrame = Instance.new("Frame", Screen)
    tFrameGlobal = tFrame
    tFrame.Name = "TauntFrame"
    tFrame.Size = UDim2.new(0, 72, 0, 26)

    if tDados.px and tDados.px >= 0 then
        tFrame.Position = UDim2.new(0, tDados.px, 0, tDados.py)
    else
        tFrame.Position = UDim2.new(0.85, 0, 0.92, 0)
    end
    tFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    tFrame.Active = true; tFrame.ZIndex = 5; tFrame.Visible = true
    Instance.new("UICorner", tFrame).CornerRadius = UDim.new(0, 8)
    applyHubGradient(tFrame)
    local tStroke = addDefaultStroke(tFrame)

    MakeDrag(tFrame, function()
        local vp = workspace.CurrentCamera.ViewportSize
        local ap = tFrame.AbsolutePosition
        tDados.px = ap.X; tDados.py = ap.Y
        cfgSetNow("tauntConfig", tDados)
    end);

    local tBtn = Instance.new("TextButton", tFrame)
    tBtn.Size = UDim2.new(1, -4, 1, -4); tBtn.Position = UDim2.new(0, 2, 0, 2)
    tBtn.BackgroundTransparency = 1; tBtn.Text = "TAUNT"
    tBtn.TextColor3 = Color3.new(1,1,1); tBtn.Font = Enum.Font.Bangers
    tBtn.TextSize = 14; tBtn.BorderSizePixel = 0; tBtn.AutoButtonColor = false; tBtn.ZIndex = 6
    Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 6)

    tBtn.MouseButton1Click:Connect(function()
        if _dragJustHappened then return end

        tStroke.Color = STROKE_ACTIVE
        TweenService:Create(tStroke, TweenInfo.new(0.1), {Transparency = 0}):Play()
        task.delay(0.4, function()
            TweenService:Create(tStroke, TweenInfo.new(0.25), {Transparency = 1}):Play()
        end);
        local msg = "OR's on top!"

        local sent = false
        pcall(function()
            local tcs = game:GetService("TextChatService")
            local ch = tcs:FindFirstChild("TextChannels")
            local general = ch and (ch:FindFirstChild("RBXGeneral") or ch:GetChildren()[1])
            if general then general:SendAsync(msg); sent = true end
        end);

        if not sent then pcall(function()
            local ev = game:GetService("ReplicatedStorage")
                :FindFirstChild("DefaultChatSystemChatEvents")
            ev = ev and ev:FindFirstChild("SayMessageRequest")
            if ev then ev:FireServer(msg, "All"); sent = true end
        end) end

        if not sent then pcall(function()
            local rs = game:GetService("ReplicatedStorage")
            local remote = rs:FindFirstChild("SayMessage") or rs:FindFirstChild("ChatMessage")
                or rs:FindFirstChild("SendMessage")
            if remote then remote:FireServer(msg) end
        end) end
    end);
end)();

local floatEnabled = false
local floatHubConn = nil
local FloatFrame   = nil
local floatRedDot  = nil
local _floatPowerRef = nil

local function startFloat()

    if floatHubConn then floatHubConn:Disconnect(); floatHubConn = nil end
    floatHubConn = RunService.Heartbeat:Connect(function()
        if not floatEnabled then return end
        local char = lp.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
        local cv = root.AssemblyLinearVelocity
        local power = (_floatPowerRef and _floatPowerRef.power) or 14.7

        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local toExclude = {}
        for _, p in ipairs(game:GetService("Players"):GetPlayers()) do
            if p.Character then table.insert(toExclude, p.Character) end
        end
        rp.FilterDescendantsInstances = toExclude

        local hit = workspace:Raycast(root.Position, Vector3.new(0, -200, 0), rp)
        if not hit then return end

        if hit.Position.Y > root.Position.Y then return end

        local targetY = hit.Position.Y + power
        local yDiff   = targetY - root.Position.Y

        if math.abs(yDiff) > 0.25 then
            local yVel = yDiff > 0
                and math.clamp(yDiff * 12, 0, 40)
                or  math.clamp(yDiff * 5, -10, 0)
            root.AssemblyLinearVelocity = Vector3.new(cv.X, yVel, cv.Z)
        else
            root.AssemblyLinearVelocity = Vector3.new(cv.X, 0, cv.Z)
        end
    end);
end

local function stopFloat()
    if floatHubConn then floatHubConn:Disconnect(); floatHubConn = nil end
    local char = lp.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            root.AssemblyLinearVelocity = Vector3.new(
                root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
        end
    end
end

lp.CharacterAdded:Connect(function()
    task.wait(1)
    if floatEnabled then
        floatEnabled = false
        pcall(function() setHubActive(FloatFrame, floatRedDot, false) end);
        stopFloat()
    end
end);

(function()

LockFrame = Instance.new("Frame", Screen)
LockFrame.Name = "LockFrame"
LockFrame.Size = UDim2.new(0, 128, 0, 34)
storeHubSize(LockFrame)
LockFrame.Position = (aimDadosSalvos.px and aimDadosSalvos.px >= 0)
    and UDim2.new(0, aimDadosSalvos.px, 0, aimDadosSalvos.py)
    or  UDim2.new(0.5, -64, 0.78, 0)
LockFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
LockFrame.Active = true; LockFrame.ZIndex = 5; LockFrame.Visible = false
LockFrame.ClipsDescendants = true
Instance.new("UICorner", LockFrame).CornerRadius = UDim.new(0, 10)
applyHubGradient(LockFrame)
addDefaultStroke(LockFrame)

local function makeDraggableAim(frame)
    MakeDrag(frame, function()
        local vp = workspace.CurrentCamera.ViewportSize
        local ap = frame.AbsolutePosition
        aimDadosSalvos.px = ap.X; aimDadosSalvos.py = ap.Y
        salvarAimConfig()
    end);
end
makeDraggableAim(LockFrame)

aimRedDot = Instance.new("TextLabel", LockFrame)
aimRedDot.Text = "◉"; aimRedDot.TextColor3 = DOT_OFF
aimRedDot.BackgroundTransparency = 1
aimRedDot.Size = UDim2.new(0,14,0,14)
aimRedDot.Position = UDim2.new(0,3,0,10)
aimRedDot.Font = Enum.Font.GothamBold; aimRedDot.TextSize = 13

local lockBtn = Instance.new("TextButton", LockFrame)
lockBtn.Size = UDim2.new(1,-10,0,32); lockBtn.Position = UDim2.new(0,5,0,1)
lockBtn.BackgroundTransparency = 1
lockBtn.Text = "AIM"
lockBtn.TextColor3 = Color3.new(1,1,1); lockBtn.Font = Enum.Font.Bangers
lockBtn.TextSize = 16; lockBtn.BorderSizePixel = 0; lockBtn.AutoButtonColor = false
Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 7)

local aimGear = Instance.new("TextButton", LockFrame)
aimGear.Text = "⚙"
aimGear.BackgroundTransparency = 1
aimGear.TextColor3 = Color3.new(1,1,1); aimGear.Font = Enum.Font.Bangers; aimGear.TextSize = 13
aimGear.Size = UDim2.new(0,22,0,22); aimGear.Position = UDim2.new(1,-24,0,6)
aimGear.BorderSizePixel = 0; aimGear.AutoButtonColor = false
Instance.new("UICorner", aimGear).CornerRadius = UDim.new(0, 6)

local aimDivider = Instance.new("Frame", LockFrame)
aimDivider.Size = UDim2.new(1, -12, 0, 1)
aimDivider.Position = UDim2.new(0, 6, 0, 34)
aimDivider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
aimDivider.BorderSizePixel = 0; aimDivider.ZIndex = 6

local aimKbHintLbl = Instance.new("TextLabel", LockFrame)
aimKbHintLbl.TextSize = 11; aimKbHintLbl.BackgroundTransparency = 1
aimKbHintLbl.Font = Enum.Font.Bangers
aimKbHintLbl.TextColor3 = Color3.fromRGB(130, 130, 130)
aimKbHintLbl.Size = UDim2.new(1, -8, 0, 22)
aimKbHintLbl.Text = "Set keybind in Settings"
aimKbHintLbl.Position = UDim2.new(0, 6, 0, 38); aimKbHintLbl.ZIndex = 6

local aimValueBox = Instance.new("TextBox", LockFrame)
aimValueBox.Visible = false; aimValueBox.Size = UDim2.new(0,0,0,0)
aimValueBox.Parent = LockFrame

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if keyBindAim and not waitingKeyAim and input.KeyCode == keyBindAim then
        aimEnabled = not aimEnabled
        setHubActive(LockFrame, aimRedDot, aimEnabled)
        if aimEnabled then
            if stopDuelExterno then stopDuelExterno() end
            startAimBot()
        else
            stopAimBot()
        end
    end
end);

lockBtn.MouseButton1Click:Connect(function()
    if _dragJustHappened then return end
    aimEnabled = not aimEnabled
    setHubActive(LockFrame, aimRedDot, aimEnabled)
    if aimEnabled then
        if stopDuelExterno then stopDuelExterno() end
        startAimBot()
    else
        stopAimBot()
    end
end);

local _aimToggleSettings = makeInlineExpand(LockFrame, 34, 66)
aimGear.MouseButton1Click:Connect(_aimToggleSettings)
aimValueBox.FocusLost:Connect(function()
    local v = tonumber(aimValueBox.Text)
    if v then AimSpeed = math.clamp(v,1,200); aimDadosSalvos.speed = AimSpeed; salvarAimConfig() end
end);
end)();

local function execSteal(prompt, animalName)
    local data = stealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false; isStealing = true
    stealStartTime = tick()
    if grabBarPercent then grabBarPercent.Text = animalName or "STEAL..." end
    if gbStroke then
        gbStroke.Color = STROKE_ACTIVE
        gbStroke.Transparency = 0
    end
    if progressConn   then progressConn:Disconnect() end

    progressConn = RunService.Heartbeat:Connect(function()
        if not isStealing then progressConn:Disconnect(); return end
        local prog = math.clamp((tick() - stealStartTime) / STEAL_DURATION, 0, 1)
        if grabBarFill    then grabBarFill.Size = UDim2.fromScale(prog, 1) end
        if grabBarPercent then grabBarPercent.Text = math.floor(prog*100).."%" end
    end);
    task.spawn(function()

        for _, fn in ipairs(data.holdCallbacks) do task.spawn(fn) end

        local elapsed = 0
        while elapsed < STEAL_DURATION do elapsed = elapsed + task.wait() end

        for _, fn in ipairs(data.triggerCallbacks) do task.spawn(fn) end
        task.wait(0.01)
        if progressConn then progressConn:Disconnect(); progressConn = nil end
        resetStealBar()
        task.wait(0.01)
        data.ready = true; isStealing = false
    end);
    return true
end

local function startAutoSteal()
    if stealConn then return end
    stealConn = RunService.Heartbeat:Connect(function()
        if not stealActive_ or isStealing then return end
        local target, dist = nearestAnimal()
        if not target then return end
        local char = lp.Character
        local hrp  = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso"))
        if not hrp then return end
        if dist > STEAL_RADIUS then return end
        local prompt = promptCache[target.uid]
        if not prompt or not prompt.Parent then prompt = findPromptCached(target) end
        if prompt then buildCallbacks(prompt); execSteal(prompt, target.name) end
    end);
end

local function stopAutoSteal()
    if stealConn then stealConn:Disconnect(); stealConn = nil end
    isStealing = false
    resetStealBar()
end

do
    local function _maDef()
        local vp = workspace.CurrentCamera.ViewportSize
        return { px = math.floor(vp.X * 0.44), py = math.floor(vp.Y * 0.88) }
    end
    local maDados = _maDef()
    do
        local d = cfgGet("meleeAimConfig") or {px=134, py=168}
        if d then
            if d.posicaoHub then
                local vp = workspace.CurrentCamera.ViewportSize
                d.px = math.floor((d.posicaoHub.X or 0.44) * vp.X)
                d.py = math.floor((d.posicaoHub.Y or 0.88) * vp.Y)
                d.posicaoHub = nil
            end
            maDados = d
        end
    end
    local function salvarMAConfig() cfgSet("meleeAimConfig", maDados) end

    local maActive = false

    local function startCebo()
        if Cebo.Conn then return end
        local char = lp.Character; if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        stopCebo()
        Cebo.Attach = Instance.new("Attachment", hrp)
        Cebo.Align  = Instance.new("AlignOrientation", hrp)
        Cebo.Align.Attachment0     = Cebo.Attach
        Cebo.Align.Mode            = Enum.OrientationAlignmentMode.OneAttachment
        Cebo.Align.RigidityEnabled = true
        Cebo.Circle = New("Part", {
            Shape="Cylinder", Material="SmoothPlastic",
            Size=Vector3.new(0.05,14.5,14.5), Color=Color3.fromRGB(0,0,0),
            CanCollide=false, Massless=true, Transparency=0, Parent=Workspace,
        })
        New("Weld", {
            Part0=hrp, Part1=Cebo.Circle,
            C0=CFrame.new(0,-1,0)*CFrame.Angles(0,0,math.rad(90)),
            Parent=Cebo.Circle,
        })
        Cebo.Conn = RunService.RenderStepped:Connect(function()
            local tgt, dm = nil, 7.25
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local eh = p.Character:FindFirstChild("HumanoidRootPart")
                    if not eh then continue end
                    local d = (eh.Position - hrp.Position).Magnitude
                    if d <= dm then tgt, dm = eh, d end
                end
            end
            if tgt then
                char.Humanoid.AutoRotate = false
                Cebo.Align.Enabled = true
                Cebo.Align.CFrame  = CFrame.lookAt(hrp.Position,
                    Vector3.new(tgt.Position.X, hrp.Position.Y, tgt.Position.Z))
                local t = char:FindFirstChild("Bat") or char:FindFirstChild("Medusa")
                if t then t:Activate() end
            else
                Cebo.Align.Enabled       = false
                char.Humanoid.AutoRotate = true
            end
        end);
    end

    local maFrame = Instance.new("Frame", Screen)
    maFrame.Name = "MeleeAimFrame"
    maFrame.Size = UDim2.new(0, 128, 0, 34)
    storeHubSize(maFrame)
    maFrame.Position = UDim2.new(0, maDados.px, 0, maDados.py)
    maFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    maFrame.Active = true; maFrame.ZIndex = 5; maFrame.Visible = false
    Instance.new("UICorner", maFrame).CornerRadius = UDim.new(0, 10)
    applyHubGradient(maFrame); addDefaultStroke(maFrame)

    MakeDrag(maFrame, function()
        local vp = workspace.CurrentCamera.ViewportSize
        local ap = maFrame.AbsolutePosition
        maDados.px = ap.X; maDados.py = ap.Y
        salvarMAConfig()
    end);

    local maRedDot = Instance.new("TextLabel", maFrame)
    maRedDot.Text = "◉"; maRedDot.TextColor3 = DOT_OFF
    maRedDot.BackgroundTransparency = 1
    maRedDot.Size = UDim2.new(0,14,0,14)
    maRedDot.Position = UDim2.new(0,3,0.5,-7)
    maRedDot.Font = Enum.Font.GothamBold; maRedDot.TextSize = 13; maRedDot.ZIndex = 6

    local maBtn = Instance.new("TextButton", maFrame)
    maBtn.Size = UDim2.new(1,-20,1,-8); maBtn.Position = UDim2.new(0,14,0,4)
    maBtn.BackgroundTransparency = 1; maBtn.Text = "MELEE AIM"
    maBtn.TextColor3 = Color3.new(1,1,1); maBtn.Font = Enum.Font.Bangers
    maBtn.TextSize = 16; maBtn.BorderSizePixel = 0; maBtn.AutoButtonColor = false; maBtn.ZIndex = 6
    Instance.new("UICorner", maBtn).CornerRadius = UDim.new(0, 7)

    maBtn.MouseButton1Click:Connect(function()
        if _dragJustHappened then return end
        maActive = not maActive
        setHubActive(maFrame, maRedDot, maActive)
        if maActive then startCebo() else stopCebo() end
    end);

    lp.CharacterAdded:Connect(function()
        task.wait(1)
        if maActive then startCebo() end
    end);

    meleeAimHubFrame = maFrame
end

local autoBatHubFrame = nil
abEnabled  = false
abFrame    = nil
abRedDot   = nil
stopAbAim  = nil
startAbAim = nil
do
    local function _abDef()
        return { px = nil, py = nil, speed = nil, keybind = nil }
    end
    local abDados = _abDef()
    do
        local d = cfgGet("autoBatConfig") or {px=131, py=48}
        if d then abDados = d end
    end
    local function salvarAB() cfgSet("autoBatConfig", abDados) end

    abEnabled = false
    local abConnections = {}
    local _abAlign      = nil
    local _abAttach     = nil

    local function cleanAbPhysics()
        if _abAlign  then pcall(function() _abAlign:Destroy()  end); _abAlign  = nil end
        if _abAttach then pcall(function() _abAttach:Destroy() end); _abAttach = nil end
    end

    local function setupAbAlign(hrp)
        cleanAbPhysics()
        _abAttach = Instance.new("Attachment", hrp)
        _abAlign  = Instance.new("AlignOrientation", hrp)
        _abAlign.Attachment0     = _abAttach
        _abAlign.Mode            = Enum.OrientationAlignmentMode.OneAttachment
        _abAlign.RigidityEnabled = true
        _abAlign.Enabled         = false
    end

    stopAbAim = function()
        if abConnections.main then abConnections.main:Disconnect(); abConnections.main = nil end
        cleanAbPhysics()
        local c = lp.Character
        if c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then hum.AutoRotate = true end
        end
    end

    startAbAim = function()
        if abConnections.main then return end
        if autoPlayOn and pararAutoPlayGlobal then pararAutoPlayGlobal() end

        local c0 = lp.Character
        if c0 then
            local hum0 = c0:FindFirstChildOfClass("Humanoid")
            if hum0 then
                local bat = findBatAim()
                if bat then
                    task.spawn(function()
                        pcall(function() hum0:UnequipTools() end);
                        task.wait(0.05)
                        pcall(function() hum0:EquipTool(bat) end);
                    end);
                end
            end
            local hrp0 = c0:FindFirstChild("HumanoidRootPart")
            if hrp0 then setupAbAlign(hrp0) end
        end

        abConnections.main = RunService.Heartbeat:Connect(function()
            if not abEnabled then return end
            local c   = lp.Character; if not c then return end
            local h   = c:FindFirstChild("HumanoidRootPart"); if not h then return end
            local hum = c:FindFirstChildOfClass("Humanoid");  if not hum then return end

            if not _abAlign or not _abAlign.Parent then setupAbAlign(h) end

            local target, dist = findNearestEnemyAim(h)
            if not target or not target.Parent then
                if _abAlign then _abAlign.Enabled = false end
                hum.AutoRotate = true
                return
            end

            local aimPos  = target.Position
            local diff    = aimPos - h.Position
            local flatDir = Vector3.new(diff.X, 0, diff.Z)

            if flatDir.Magnitude > 0.1 and _abAlign then
                hum.AutoRotate = false
                _abAlign.Enabled = true
                _abAlign.CFrame  = CFrame.lookAt(Vector3.zero, Vector3.new(flatDir.X, 0, flatDir.Z))
            end

            local abSpeedVal = abDados.speed or AimSpeed
            local flatDist = flatDir.Magnitude
            local velY     = math.clamp(diff.Y * 18, -abSpeedVal * 1.5, abSpeedVal * 1.5)

            if flatDist > 1.5 then
                local moveDir = flatDir.Unit
                h.AssemblyLinearVelocity = Vector3.new(
                    moveDir.X * abSpeedVal, velY, moveDir.Z * abSpeedVal)
            else
                local tv = target.AssemblyLinearVelocity
                h.AssemblyLinearVelocity = Vector3.new(tv.X, velY, tv.Z)
            end

            local t = c:FindFirstChildOfClass("Tool")
            if t and t.Parent == c then
                pcall(function() t:Activate() end);
            end
        end);
    end

    abFrame = Instance.new("Frame", Screen)
    abFrame.Name = "AutoBatFrame"
    abFrame.Size = UDim2.new(0, 128, 0, 34)
    storeHubSize(abFrame)
    abFrame.Position = (abDados.px and abDados.py)
        and UDim2.new(0, abDados.px, 0, abDados.py)
        or  UDim2.new(0.5, -64, 0.5, -17)
    abFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    abFrame.Active = true; abFrame.ZIndex = 5; abFrame.Visible = false
    abFrame.ClipsDescendants = true
    Instance.new("UICorner", abFrame).CornerRadius = UDim.new(0, 10)
    applyHubGradient(abFrame); addDefaultStroke(abFrame)

    MakeDrag(abFrame, function()
        abDados.px = abFrame.AbsolutePosition.X
        abDados.py = abFrame.AbsolutePosition.Y
        salvarAB()
    end);

    abRedDot = Instance.new("TextLabel", abFrame)
    abRedDot.Text = "◉"; abRedDot.TextColor3 = DOT_OFF
    abRedDot.BackgroundTransparency = 1
    abRedDot.Size = UDim2.new(0,14,0,14); abRedDot.Position = UDim2.new(0,3,0,10)
    abRedDot.Font = Enum.Font.GothamBold; abRedDot.TextSize = 13

    local abBtn = Instance.new("TextButton", abFrame)
    abBtn.Size = UDim2.new(1,-10,0,32); abBtn.Position = UDim2.new(0,5,0,1)
    abBtn.BackgroundTransparency = 1; abBtn.Text = "AIM BAT"
    abBtn.TextColor3 = Color3.new(1,1,1); abBtn.Font = Enum.Font.Bangers
    abBtn.TextSize = 16; abBtn.BorderSizePixel = 0; abBtn.AutoButtonColor = false
    Instance.new("UICorner", abBtn).CornerRadius = UDim.new(0, 7)

    local abGear = Instance.new("TextButton", abFrame)
    abGear.Text = "⚙"; abGear.BackgroundTransparency = 1
    abGear.TextColor3 = Color3.new(1,1,1); abGear.Font = Enum.Font.Bangers; abGear.TextSize = 13
    abGear.Size = UDim2.new(0,22,0,22); abGear.Position = UDim2.new(1,-24,0,6)
    abGear.BorderSizePixel = 0; abGear.AutoButtonColor = false

    local abDivider = Instance.new("Frame", abFrame)
    abDivider.Size = UDim2.new(1,-12,0,1); abDivider.Position = UDim2.new(0,6,0,34)
    abDivider.BackgroundColor3 = Color3.fromRGB(80,80,80)
    abDivider.BorderSizePixel = 0; abDivider.ZIndex = 6

    local abKbHintLbl = Instance.new("TextLabel", abFrame)
    abKbHintLbl.TextSize = 11; abKbHintLbl.BackgroundTransparency = 1
    abKbHintLbl.Font = Enum.Font.Bangers
    abKbHintLbl.TextColor3 = Color3.fromRGB(130,130,130)
    abKbHintLbl.Size = UDim2.new(1,-8,0,22)
    abKbHintLbl.Text = "Set keybind in Settings"
    abKbHintLbl.Position = UDim2.new(0,6,0,38); abKbHintLbl.ZIndex = 6

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if keyBindAB and not waitingAB and input.KeyCode == keyBindAB then
            abEnabled = not abEnabled
            setHubActive(abFrame, abRedDot, abEnabled)
            if abEnabled then startAbAim() else stopAbAim() end
        end
    end);

    abBtn.MouseButton1Click:Connect(function()
        if _dragJustHappened then return end
        abEnabled = not abEnabled
        setHubActive(abFrame, abRedDot, abEnabled)
        if abEnabled then startAbAim() else stopAbAim() end
    end);

    local _abToggleSettings = makeInlineExpand(abFrame, 34, 66)
    abGear.MouseButton1Click:Connect(_abToggleSettings)

    lp.CharacterAdded:Connect(function()
        task.wait(1)
        if abEnabled then
            stopAbAim()
            task.wait(0.1)
            startAbAim()
        end
    end);

    autoBatHubFrame = abFrame
end;
(function()
    local function _floatDef()
        local vp = workspace.CurrentCamera.ViewportSize
        return { px = math.floor(vp.X * 0.50), py = math.floor(vp.Y * 0.88), power = 14.7 }
    end
    local floatDadosSalvos = _floatDef()
    do
        local d = cfgGet("floatConfig") or {px=131, py=88}
        if d then
            if d.posicaoHub then
                local vp = workspace.CurrentCamera.ViewportSize
                d.px = math.floor((d.posicaoHub.X or 0.50) * vp.X)
                d.py = math.floor((d.posicaoHub.Y or 0.88) * vp.Y)
                d.posicaoHub = nil; d.posicaoSettings = nil
            end
            if not d.power then d.power = 14.7 end
            floatDadosSalvos = d
        end
    end
    local function salvarFloatConfig() cfgSet("floatConfig", floatDadosSalvos) end
    _floatPowerRef = floatDadosSalvos

    FloatFrame = Instance.new("Frame", Screen)
    FloatFrame.Name    = "FloatFrame"
    FloatFrame.Size    = UDim2.new(0, 128, 0, 34)
    storeHubSize(FloatFrame)
    FloatFrame.Position = UDim2.new(0, floatDadosSalvos.px, 0, floatDadosSalvos.py)
    FloatFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    FloatFrame.Active  = true; FloatFrame.ZIndex = 5; FloatFrame.Visible = false
    FloatFrame.ClipsDescendants = true
    Instance.new("UICorner", FloatFrame).CornerRadius = UDim.new(0, 10)
    applyHubGradient(FloatFrame)
    addDefaultStroke(FloatFrame)

    MakeDrag(FloatFrame, function()
        local vp = workspace.CurrentCamera.ViewportSize
        local ap = FloatFrame.AbsolutePosition
        floatDadosSalvos.px = ap.X; floatDadosSalvos.py = ap.Y
        salvarFloatConfig()
    end);

    floatRedDot = Instance.new("TextLabel", FloatFrame)
    floatRedDot.Text = "◉"; floatRedDot.TextColor3 = DOT_OFF
    floatRedDot.BackgroundTransparency = 1
    floatRedDot.Size = UDim2.new(0, 14, 0, 14)
    floatRedDot.Position = UDim2.new(0, 3, 0, 10)
    floatRedDot.Font = Enum.Font.GothamBold; floatRedDot.TextSize = 13

    local floatMainBtn = Instance.new("TextButton", FloatFrame)
    floatMainBtn.Size = UDim2.new(1, -10, 0, 32); floatMainBtn.Position = UDim2.new(0, 5, 0, 1)
    floatMainBtn.BackgroundTransparency = 1
    floatMainBtn.Text = "FLOAT"
    floatMainBtn.TextColor3 = Color3.new(1, 1, 1); floatMainBtn.Font = Enum.Font.Bangers
    floatMainBtn.TextSize = 16; floatMainBtn.BorderSizePixel = 0; floatMainBtn.AutoButtonColor = false
    Instance.new("UICorner", floatMainBtn).CornerRadius = UDim.new(0, 7)

    local floatGear = Instance.new("TextButton", FloatFrame)
    floatGear.Text = "⚙"
    floatGear.BackgroundTransparency = 1
    floatGear.TextColor3 = Color3.new(1, 1, 1); floatGear.Font = Enum.Font.Bangers; floatGear.TextSize = 13
    floatGear.Size = UDim2.new(0, 22, 0, 22); floatGear.Position = UDim2.new(1, -24, 0, 6)
    floatGear.BorderSizePixel = 0; floatGear.AutoButtonColor = false
    Instance.new("UICorner", floatGear).CornerRadius = UDim.new(0, 6)

    local floatDivider = Instance.new("Frame", FloatFrame)
    floatDivider.Size = UDim2.new(1, -12, 0, 1)
    floatDivider.Position = UDim2.new(0, 6, 0, 34)
    floatDivider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    floatDivider.BorderSizePixel = 0; floatDivider.ZIndex = 6

    local floatSettingsFrame = Instance.new("Frame", FloatFrame)
    floatSettingsFrame.Name = "FloatSettings"
    floatSettingsFrame.BackgroundTransparency = 1
    floatSettingsFrame.BorderSizePixel = 0
    floatSettingsFrame.Size = UDim2.new(1, 0, 0, 80)
    floatSettingsFrame.Position = UDim2.new(0, 0, 0, 36)
    floatSettingsFrame.ZIndex = 6

    local floatPowerHint = Instance.new("TextLabel", floatSettingsFrame)
    floatPowerHint.TextSize = 11; floatPowerHint.BackgroundTransparency = 1
    floatPowerHint.Font = Enum.Font.Bangers
    floatPowerHint.TextColor3 = Color3.fromRGB(130, 130, 130)
    floatPowerHint.Size = UDim2.new(1, -8, 0, 20)
    floatPowerHint.Text = "Set power in Settings"
    floatPowerHint.Position = UDim2.new(0, 6, 0, 4); floatPowerHint.ZIndex = 6

    UIS.InputBegan:Connect(function(input, gp)
        if gp then return end
        if keyBindFloat and not waitingKeyFloat and input.KeyCode == keyBindFloat then
            floatEnabled = not floatEnabled
            setHubActive(FloatFrame, floatRedDot, floatEnabled)
            if floatEnabled then
                if not (_floatPowerRef and _floatPowerRef.autoFloatEnabled == true) then
                    startFloat()
                end
            else
                stopFloat()
            end
        end
    end);

    floatMainBtn.MouseButton1Click:Connect(function()
        if _dragJustHappened then return end
        floatEnabled = not floatEnabled
        setHubActive(FloatFrame, floatRedDot, floatEnabled)
        if floatEnabled then

            if not (_floatPowerRef and _floatPowerRef.autoFloatEnabled == true) then
                startFloat()
            end
        else
            stopFloat()
        end
    end);

    local _floatToggleSettings = makeInlineExpand(FloatFrame, 34, 100)
    floatGear.MouseButton1Click:Connect(_floatToggleSettings)
end)();

do
    local autoFloatEnabled = false
    local autoFloatConn = nil

    if _floatPowerRef then
        _floatPowerRef.autoFloatEnabled = false
    end

    local floatSF = FloatFrame and (FloatFrame:FindFirstChild("FloatSettings")
        or FloatFrame:FindFirstChild("FloatSettings", true))
    if not floatSF then
        floatSF = Screen:FindFirstChild("FloatSettings", true)
    end

    if floatSF then
        local autoFloatLbl = Instance.new("TextLabel", floatSF)
        autoFloatLbl.TextSize = 12; autoFloatLbl.BackgroundTransparency = 1
        autoFloatLbl.Font = Enum.Font.Bangers
        autoFloatLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        autoFloatLbl.Size = UDim2.new(0, 80, 0, 18)
        autoFloatLbl.Text = "AUTO FLOAT:"
        autoFloatLbl.Position = UDim2.new(0, 8, 0, 28)
        autoFloatLbl.TextXAlignment = Enum.TextXAlignment.Left; autoFloatLbl.ZIndex = 6

        local afTogBg = Instance.new("Frame", floatSF)
        afTogBg.Size = UDim2.new(0, 34, 0, 16)
        afTogBg.Position = UDim2.new(1, -40, 0, 29)
        afTogBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        afTogBg.ZIndex = 8
        Instance.new("UICorner", afTogBg).CornerRadius = UDim.new(1, 0)

        local afTogDot = Instance.new("Frame", afTogBg)
        afTogDot.Size = UDim2.new(0, 12, 0, 12)
        afTogDot.Position = UDim2.new(0, 2, 0.5, -6)
        afTogDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        afTogDot.ZIndex = 9
        Instance.new("UICorner", afTogDot).CornerRadius = UDim.new(1, 0)

        local afTogBtn = Instance.new("TextButton", floatSF)
        afTogBtn.Size = UDim2.new(1, 0, 0, 26)
        afTogBtn.Position = UDim2.new(0, 0, 0, 26)
        afTogBtn.BackgroundTransparency = 1
        afTogBtn.Text = ""; afTogBtn.ZIndex = 10

        local function setAFVisual(on)
            TweenService:Create(afTogBg, TweenInfo.new(0.18), {
                BackgroundColor3 = on and Color3.fromRGB(160, 160, 160) or Color3.fromRGB(40, 40, 48)
            }):Play()
            TweenService:Create(afTogDot, TweenInfo.new(0.18), {
                Position = on and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
            }):Play()
        end

        local function doAutoFloat()
            if autoFloatConn then autoFloatConn:Disconnect() end
            local afActivated = false

            _floatPowerRef.onGrabComplete = function()
                if floatHubConn then stopFloat() end
                if floatEnabled then
                    floatEnabled = false
                    afActivated  = false
                    setHubActive(FloatFrame, floatRedDot, false)
                end
            end

            autoFloatConn = RunService.Heartbeat:Connect(function()
                if not autoFloatEnabled then return end
                local myChar = lp.Character
                if not myChar then return end
                local myRoot = myChar:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end

                if grabIsStealing or grabHoldStarted or lp:GetAttribute("Stealing") then
                    if floatHubConn then
                        stopFloat()
                        if afActivated then
                            afActivated = false
                            floatEnabled = false
                            setHubActive(FloatFrame, floatRedDot, false)
                        end
                    end
                    return
                end

                local hasBrainrot = false
                for _, obj in ipairs(myChar:GetChildren()) do
                    if obj:IsA("Tool") and obj.Name:lower():find("brainrot") then
                        hasBrainrot = true; break
                    end
                end
                if hasBrainrot then
                    if floatHubConn then
                        stopFloat()
                        if afActivated then
                            afActivated = false
                            floatEnabled = false
                            setHubActive(FloatFrame, floatRedDot, false)
                        end
                    end
                    return
                end

                local close = false
                for _, plr in ipairs(game.Players:GetPlayers()) do
                    if plr ~= lp and plr.Character then
                        local r = plr.Character:FindFirstChild("HumanoidRootPart")
                        if r then
                            local d = (r.Position - myRoot.Position).Magnitude
                            if d < 8 then
                                close = true; break
                            end
                        end
                    end
                end
                if close then

                    if not floatHubConn then
                        if not floatEnabled then

                            afActivated = true
                            floatEnabled = true
                            setHubActive(FloatFrame, floatRedDot, true)
                        end
                        startFloat()
                    end
                else

                    if floatHubConn then
                        stopFloat()
                        if afActivated then

                            afActivated = false
                            floatEnabled = false
                            setHubActive(FloatFrame, floatRedDot, false)
                        end

                    else
                        afActivated = false
                    end
                end
            end);
        end

        afTogBtn.MouseButton1Click:Connect(function()
            autoFloatEnabled = not autoFloatEnabled
            _floatPowerRef.autoFloatEnabled = autoFloatEnabled
            setAFVisual(autoFloatEnabled)
            if autoFloatEnabled then

                if floatEnabled and floatHubConn then
                    stopFloat()
                end
                doAutoFloat()
            else

                if autoFloatConn then autoFloatConn:Disconnect(); autoFloatConn = nil end
                _floatPowerRef.onGrabComplete = nil

                if floatEnabled then
                    startFloat()
                end
            end
        end);
    end
end

local speedHubGui = nil

local function createSpeedHub()
    if speedHubGui and speedHubGui.Parent then speedHubGui:Destroy() end

    local function _speedDef()
        local vp = workspace.CurrentCamera.ViewportSize
        return { px = math.floor(vp.X * 0.24), py = math.floor(vp.Y * 0.45), rtnSpeed = 28.8, notStealSpeed = 52, speedActive = false }
    end
    local speedDados = _speedDef()

    local function salvarSpeed()
        cfgSet("speedHubConfig", speedDados)
    end
    local function carregarSpeed()
        local d = cfgGet("speedHubConfig") or {px=312, py=56}
        if d then
            if d.posicao then
                local vp = workspace.CurrentCamera.ViewportSize
                d.px = math.floor((d.posicao.X or 0.24) * vp.X)
                d.py = math.floor((d.posicao.Y or 0.45) * vp.Y)
                d.posicao = nil
            end
            speedDados = d
        end

        speedWhileStealActive = speedDados.speedActive == true
    end
    carregarSpeed()
    duelReturnSpeed   = speedDados.rtnSpeed     or 28.8
    duelNotStealSpeed = speedDados.notStealSpeed or 52

    local _notStealSpeed = speedDados.notStealSpeed or 52

    speedHubGui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
    speedHubGui.Name = "SpeedHubGui"; speedHubGui.ResetOnSpawn = false
    speedHubGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    speedHubGui.Enabled = false

    local fSpeed = Instance.new("Frame", speedHubGui)
    fSpeed.Size = UDim2.new(0, 148, 0, 96)
    fSpeed.Position = UDim2.new(0, speedDados.px, 0, speedDados.py)
    fSpeed.BackgroundColor3 = Color3.fromRGB(0,0,0); fSpeed.Active = true
    Instance.new("UICorner", fSpeed).CornerRadius = UDim.new(0, 10)
    applyHubGradient(fSpeed)
    addDefaultStroke(fSpeed)

    local function makeDragSpeed(frame)
        MakeDrag(frame, function()
            local vp = workspace.CurrentCamera.ViewportSize
            speedDados.px = frame.AbsolutePosition.X; speedDados.py = frame.AbsolutePosition.Y
            salvarSpeed()
        end);
    end
    makeDragSpeed(fSpeed)

    local titleLbl = Instance.new("TextLabel", fSpeed)
    titleLbl.Size = UDim2.new(1,0,0,16); titleLbl.Position = UDim2.new(0,0,0,2)
    titleLbl.BackgroundTransparency = 1; titleLbl.Font = Enum.Font.Bangers
    titleLbl.Text = "SPEED SETTINGS"; titleLbl.TextColor3 = Color3.new(1,1,1); titleLbl.TextSize = 12

    local speedTogFrame = Instance.new("Frame", fSpeed)
    speedTogFrame.Size = UDim2.new(0.9,0,0,22); speedTogFrame.Position = UDim2.new(0.05,0,0,18)
    speedTogFrame.BackgroundTransparency = 1

    local speedLbl = Instance.new("TextLabel", speedTogFrame)
    speedLbl.Size = UDim2.new(0,60,1,0); speedLbl.BackgroundTransparency = 1
    speedLbl.Font = Enum.Font.Bangers; speedLbl.Text = "SPEED/DUEL"
    speedLbl.TextColor3 = Color3.new(1,1,1); speedLbl.TextSize = 15
    speedLbl.TextXAlignment = Enum.TextXAlignment.Left

    local speedTogBtn = Instance.new("TextButton", speedTogFrame)
    speedTogBtn.Size = UDim2.new(0,42,0,22); speedTogBtn.Position = UDim2.new(0,64,0.5,-11)
    speedTogBtn.BackgroundColor3 = C.TogOff; speedTogBtn.Text = ""
    speedTogBtn.AutoButtonColor = false
    Instance.new("UICorner", speedTogBtn).CornerRadius = UDim.new(1, 0)

    local speedKnob = Instance.new("Frame", speedTogBtn)
    speedKnob.Size = UDim2.new(0,18,0,18); speedKnob.Position = UDim2.new(0,2,0.5,-9)
    speedKnob.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", speedKnob).CornerRadius = UDim.new(1, 0)

    local function atualizarVisualSpeed(v)
        TweenService:Create(speedKnob, TweenInfo.new(0.18), {
            Position = v and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
        }):Play()
        speedTogBtn.BackgroundColor3 = v and C.Gray or C.TogOff
    end
    atualizarVisualSpeed(speedWhileStealActive)

    speedTogBtn.MouseButton1Click:Connect(function()
        speedWhileStealActive = not speedWhileStealActive
        atualizarVisualSpeed(speedWhileStealActive)
        if speedWhileStealActive then startSpeedWhileStealing() else stopSpeedWhileStealing() end
        speedDados.speedActive = speedWhileStealActive; salvarSpeed()
    end);

    local divider = Instance.new("Frame", fSpeed)
    divider.Size = UDim2.new(0.88, 0, 0, 1)
    divider.Position = UDim2.new(0.06, 0, 0, 46)
    divider.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    divider.BorderSizePixel = 0

    local mvTitle = Instance.new("TextLabel", fSpeed)
    mvTitle.Size = UDim2.new(1, 0, 0, 14)
    mvTitle.Position = UDim2.new(0, 0, 0, 50)
    mvTitle.BackgroundTransparency = 1
    mvTitle.Font = Enum.Font.Bangers
    mvTitle.Text = "SPEED/MOVE"
    mvTitle.TextColor3 = Color3.new(1, 1, 1)
    mvTitle.TextSize = 11

    local mvOn = speedDados.mvActive == true
    mvSpeedOn = mvOn
    local mvSpeed      = speedDados.mvSpeed      or 40
    mvSpeedVal = mvSpeed
    local mvConn       = nil

    _bridgeSetMvSpeed = function(v)
        mvSpeed = v; mvSpeedVal = v
    end

    local mvStealing    = false
    local mvStealConn   = nil

    local function stopMvSpeed()
        mvSpeedOn = false; mvOn = false
        if mvConn then mvConn:Disconnect(); mvConn = nil end
        if mvStealConn then mvStealConn:Disconnect(); mvStealConn = nil end

        local char = lp.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
        end
        mvStealing = false
    end

    local function _doStartMvSpeed()
        if mvConn then mvConn:Disconnect(); mvConn = nil end
        if mvStealConn then mvStealConn:Disconnect(); mvStealConn = nil end
        mvStealing = lp:GetAttribute("Stealing") == true
        mvStealConn = lp:GetAttributeChangedSignal("Stealing"):Connect(function()
            if autoPlayOn then return end
            mvStealing = lp:GetAttribute("Stealing") == true
        end);
        mvConn = RunService.Heartbeat:Connect(function()
            if not mvOn then return end
            if autoPlayOn then return end
            local char = lp.Character; if not char then return end
            local h   = char:FindFirstChild("HumanoidRootPart"); if not h then return end
            local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
            local currentSpeed = mvSpeed
            local md = hum.MoveDirection
            if md.Magnitude > 0.1 then
                h.AssemblyLinearVelocity = Vector3.new(
                    md.X * currentSpeed,
                    h.AssemblyLinearVelocity.Y,
                    md.Z * currentSpeed
                )
            end
        end);
    end

    local function startMvSpeed()
        if mvConn then mvConn:Disconnect(); mvConn = nil end
        if mvStealConn then mvStealConn:Disconnect(); mvStealConn = nil end
        mvSpeedOn = true; mvOn = true
        _doStartMvSpeed()
    end

    lp.CharacterAdded:Connect(function()
        mvBV = nil
        if mvOn then task.wait(0.5); startMvSpeed() end
    end);

    local mvTogFrame = Instance.new("Frame", fSpeed)
    mvTogFrame.Size = UDim2.new(0.9, 0, 0, 22); mvTogFrame.Position = UDim2.new(0.05, 0, 0, 64)
    mvTogFrame.BackgroundTransparency = 1

    local mvLbl = Instance.new("TextLabel", mvTogFrame)
    mvLbl.Size = UDim2.new(0, 60, 1, 0); mvLbl.BackgroundTransparency = 1
    mvLbl.Font = Enum.Font.Bangers; mvLbl.Text = "SPEED/MOVE"
    mvLbl.TextColor3 = Color3.new(1,1,1); mvLbl.TextSize = 15
    mvLbl.TextXAlignment = Enum.TextXAlignment.Left

    local mvTogBtn = Instance.new("TextButton", mvTogFrame)
    mvTogBtn.Size = UDim2.new(0, 42, 0, 22); mvTogBtn.Position = UDim2.new(0, 64, 0.5, -11)
    mvTogBtn.BackgroundColor3 = mvOn and C.Gray or C.TogOff
    mvTogBtn.Text = ""; mvTogBtn.AutoButtonColor = false
    Instance.new("UICorner", mvTogBtn).CornerRadius = UDim.new(1, 0)
    local mvKnob = Instance.new("Frame", mvTogBtn)
    mvKnob.Size = UDim2.new(0, 18, 0, 18)
    mvKnob.Position = mvOn and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
    mvKnob.BackgroundColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", mvKnob).CornerRadius = UDim.new(1, 0)

    _bridgeDisableMv = function()
        stopMvSpeed()
        TweenService:Create(mvKnob, TweenInfo.new(0.18), {Position = UDim2.new(0,2,0.5,-9)}):Play()
        mvTogBtn.BackgroundColor3 = C.TogOff
        speedDados.mvActive = false; salvarSpeed()
    end

    mvTogBtn.MouseButton1Click:Connect(function()
        if mvSpeedOn then
            stopMvSpeed()
        else
            startMvSpeed()
        end
        TweenService:Create(mvKnob, TweenInfo.new(0.18), {
            Position = mvSpeedOn and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
        }):Play()
        mvTogBtn.BackgroundColor3 = mvSpeedOn and C.Gray or C.TogOff
        speedDados.mvActive = mvSpeedOn; salvarSpeed()
    end);
    if mvOn then startMvSpeed() end

    mvSpeed = _notStealSpeed
    mvSpeedVal = mvSpeed

    _bridgeSetMvSpeed = function(v)
        mvSpeed = v; mvSpeedVal = v
    end
end

local TOGGLES_CONFIG = "TogglesState.json"

local hitboxActive   = false
local hitboxExpand   = 12
local hitboxPartConn = nil
local hitboxPart     = nil

local hitboxExpandAllPrompts, hitboxStart, hitboxStop
do
    local function _expandAllPrompts(maxDist)
        local plots = workspace:FindFirstChild("Plots"); if not plots then return end
        for _, plot in ipairs(plots:GetDescendants()) do
            if plot:IsA("ProximityPrompt") then
                pcall(function() plot.MaxActivationDistance = maxDist; plot.RequiresLineOfSight = false end);
            end
        end
    end
    local function _createPart()
        local char = lp.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if hrp:FindFirstChild("HBExpandPart") then return end
        local p = Instance.new("Part")
        p.Name="HBExpandPart"; p.Size=Vector3.new(hitboxExpand*2,hitboxExpand*2,hitboxExpand*2)
        p.CFrame=hrp.CFrame; p.Anchored=false; p.CanCollide=false; p.CanTouch=false
        p.CanQuery=false; p.Transparency=1; p.Massless=true; p.Parent=hrp
        local weld=Instance.new("WeldConstraint"); weld.Part0=hrp; weld.Part1=p; weld.Parent=p
        hitboxPart = p
    end
    local function _destroyPart()
        if hitboxPart then pcall(function() hitboxPart:Destroy() end); hitboxPart = nil end
        local char = lp.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then local p=hrp:FindFirstChild("HBExpandPart"); if p then p:Destroy() end end
    end
    hitboxExpandAllPrompts = _expandAllPrompts
    hitboxStart = function()
        _expandAllPrompts(hitboxExpand); _createPart()
        if hitboxPartConn then hitboxPartConn:Disconnect() end
        hitboxPartConn = workspace.DescendantAdded:Connect(function(obj)
            if obj:IsA("ProximityPrompt") then
                pcall(function() obj.MaxActivationDistance=hitboxExpand; obj.RequiresLineOfSight=false end);
            end
        end);
        lp.CharacterAdded:Connect(function()
            task.wait(0.5); if hitboxActive then _createPart() end
        end);
    end
    hitboxStop = function()
        _expandAllPrompts(10); _destroyPart()
        if hitboxPartConn then hitboxPartConn:Disconnect(); hitboxPartConn = nil end
    end
end

local togglesState = {
        desyncNoReset=false, desyncReset=false,
    autoDuel        = false,
    lock            = false,
    aimBatHub       = false,
    dropBrainrot    = false,
    fov             = false,
    meleeAimbot     = false,
    spin            = false,
    infJump         = false,
    speedCustomizer = false,
    optimizer       = false,
    antiRagdoll     = false,
    antiFling       = false,
    xrayBase        = false,
    noAnim          = false,
    playerEsp       = false,
    float           = false,
    autoTP          = false,
    hitTP           = false,
    autoSteal       = false,
    hitboxExp       = false,
    autoBat         = false,
}
local function salvarToggles()
    cfgSet("togglesState", togglesState)
end
local function carregarToggles()
    local d = cfgGet("togglesState")
    if d then
        for k, v in pairs(d) do
            if togglesState[k] ~= nil then togglesState[k] = v end
        end
    elseif isfile and isfile(TOGGLES_CONFIG) then

        local ok, raw = pcall(readfile, TOGGLES_CONFIG)
        if ok and raw then
            local ok2, d2 = pcall(HttpService.JSONDecode, HttpService, raw)
            if ok2 and d2 then
                for k, v in pairs(d2) do
                    if togglesState[k] ~= nil then togglesState[k] = v end
                end
            end
        end
    end

end
carregarToggles()

local toggleForces = {}

local function ToggleSaved(page, label, stateKey, saveState, cb)
    local on = (saveState and togglesState[stateKey] == true) or false
    local row = New("Frame", {
        Size=UDim2.new(0.93,0,0,ITEM_H), BackgroundColor3=C.DarkRow,
        BackgroundTransparency=0.3, ZIndex=7, Parent=Pages[page],
    })
    New("UICorner", {CornerRadius=UDim.new(0,8), Parent=row})
    New("UIStroke", {Color=C.Gray, Thickness=1, Transparency=0.6, Parent=row})
    New("TextLabel", {
        Text=label, Size=UDim2.new(0.62,0,1,0), Position=UDim2.new(0.04,0,0,0),
        TextColor3=Color3.new(1,1,1), Font = Enum.Font.GothamBold, TextSize=12,
        BackgroundTransparency=1, TextXAlignment="Left", ZIndex=8, Parent=row,
    })
    local bg = New("Frame", {
        Size=UDim2.new(0,38,0,18), Position=UDim2.new(1,-44,0.5,-9),
        BackgroundColor3=on and C.Gray or C.TogOff, ZIndex=8, Parent=row,
    })
    New("UICorner", {CornerRadius=UDim.new(1,0), Parent=bg})
    local dot = New("Frame", {
        Size=UDim2.new(0,14,0,14),
        Position=on and UDim2.new(0.55,0,0.1,0) or UDim2.new(0.08,0,0.1,0),
        BackgroundColor3=Color3.new(1,1,1), ZIndex=9, Parent=bg,
    })
    New("UICorner", {CornerRadius=UDim.new(1,0), Parent=dot})

    local _busy = false
    local function forceState(newOn)
        if _busy then return end
        _busy = true
        on = newOn
        TweenService:Create(bg,  TweenInfo.new(0.18), {BackgroundColor3=on and C.Gray or C.TogOff}):Play()
        TweenService:Create(dot, TweenInfo.new(0.18), {Position=on and UDim2.new(0.55,0,0.1,0) or UDim2.new(0.08,0,0.1,0)}):Play()
        if saveState then togglesState[stateKey] = on; salvarToggles() end
        cb(on)
        _busy = false
    end

    New("TextButton", {
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=10, Parent=row,
    }).MouseButton1Click:Connect(function() forceState(not on) end);

    table.insert(TAB_ROWS[page], row)
    rebuildPage(page)
    toggleForces[stateKey] = forceState
    return forceState, row
end

forceDuelToggle = ToggleSaved("Combat", "Auto Duel", "autoDuel", true, function(v)
    if v then
        if not duelGui or not duelGui.Parent then duelModule = createDuelHub() end
        duelGui.Enabled = true
    else
        if duelGui then duelGui.Enabled = false end
        if stopDuelExterno then stopDuelExterno() end
    end
end);

ToggleSaved("Combat", "Auto Steal", "autoSteal", true, function(v)
    stealActive_ = v
    if v then startAutoSteal() else stopAutoSteal() end
end);

ToggleSaved("Combat", "Aim Bat", "aimBatHub", true, function(v)
    if abFrame then
        if v then hubOpen(abFrame) else hubClose(abFrame, function()
            if abEnabled then abEnabled = false; stopAbAim(); setHubActive(abFrame, abRedDot, false) end
        end) end
    end
end);

forceLockToggle = ToggleSaved("Combat", "Aim", "lock", true, function(v)
    if v then hubOpen(LockFrame) else hubClose(LockFrame) end
    if not v and aimEnabled then
        aimEnabled = false
        stopAimBot()
        setHubActive(LockFrame, aimRedDot, false)
    end

end);

ToggleSaved("Combat", "Melee Aimbot", "meleeAimbot", true, function(v)
    if meleeAimHubFrame then if v then hubOpen(meleeAimHubFrame) else hubClose(meleeAimHubFrame) end end
end);

ToggleSaved("Combat", "Auto TP", "hitTP",
        "desyncNoReset", "desyncReset", true, function(v)
    if hitTPHubFrame then if v then hubOpen(hitTPHubFrame) else hubClose(hitTPHubFrame) end end
end);

ToggleSaved("Combat", "TP Manual", "autoTP", true, function(v)
    if autoTPHubFrame then if v then hubOpen(autoTPHubFrame) else hubClose(autoTPHubFrame) end end
end);

local _doDropBrainrot = nil
local _dbRedDot = nil

do
    local dbDados = cfgGet("dropBrainrotConfig") or {px=599, py=111}
    local function salvarDB() cfgSet("dropBrainrotConfig", dbDados) end

    dbFrame = Instance.new("Frame", Screen)
    dbFrame.Name = "DropBrainrotFrame"
    dbFrame.Size = UDim2.new(0, 100, 0, 30)
    storeHubSize(dbFrame)
    if dbDados.px and dbDados.px >= 0 then
        dbFrame.Position = UDim2.new(0, dbDados.px, 0, dbDados.py)
    else
        local vp = workspace.CurrentCamera.ViewportSize
        dbFrame.Position = UDim2.new(0, math.floor(vp.X/2 - 50), 0, math.floor(vp.Y * 0.6))
    end
    dbFrame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    dbFrame.Active = true; dbFrame.ZIndex = 5; dbFrame.Visible = false
    dbFrame.ClipsDescendants = true
    Instance.new("UICorner", dbFrame).CornerRadius = UDim.new(0,10)
    applyHubGradient(dbFrame); addDefaultStroke(dbFrame)

    MakeDrag(dbFrame, function()
        local ap = dbFrame.AbsolutePosition
        dbDados.px = ap.X; dbDados.py = ap.Y; salvarDB()
    end);

    _dbRedDot = Instance.new("TextLabel", dbFrame)
    _dbRedDot.Size = UDim2.new(0,14,0,30); _dbRedDot.Position = UDim2.new(0,3,0,0)
    _dbRedDot.BackgroundTransparency = 1; _dbRedDot.Text = "◉"
    _dbRedDot.TextColor3 = DOT_OFF; _dbRedDot.Font = Enum.Font.GothamBold
    _dbRedDot.TextSize = 11; _dbRedDot.ZIndex = 6
    _dbRedDot.TextYAlignment = Enum.TextYAlignment.Center

    local dbBtn = Instance.new("TextButton", dbFrame)
    dbBtn.Size = UDim2.new(1, 0, 1, 0); dbBtn.Position = UDim2.new(0, 0, 0, 0)
    dbBtn.BackgroundTransparency = 1; dbBtn.Text = "DROP"
    dbBtn.TextColor3 = Color3.new(1,1,1); dbBtn.Font = Enum.Font.Bangers
    dbBtn.TextSize = 15; dbBtn.AutoButtonColor = false; dbBtn.ZIndex = 6
    Instance.new("UICorner", dbBtn).CornerRadius = UDim.new(0,10)

    dbBtn.MouseButton1Click:Connect(function()
        if _dragJustHappened then return end

        local dbStroke = dbFrame:FindFirstChildOfClass("UIStroke")
        if dbStroke then
            dbStroke.Color = STROKE_ACTIVE
            TweenService:Create(dbStroke, TweenInfo.new(0.1), {Transparency = 0}):Play()
            task.delay(0.4, function()
                TweenService:Create(dbStroke, TweenInfo.new(0.25), {Transparency = 1}):Play()
            end);
        end
        if _doDropBrainrot then _doDropBrainrot() end
    end);
end

do
    _doDropBrainrot = function()
        local c = lp.Character; if not c then return end
        local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if _dbRedDot then _dbRedDot.TextColor3 = Color3.fromRGB(255,80,80) end
        task.spawn(function()
            for run = 1, 2 do
                local movel = 0.1
                for _ = 1, 3 do
                    RunService.Heartbeat:Wait()
                    c = lp.Character
                    hrp = c and c:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local vel = hrp.Velocity
                        hrp.Velocity = vel * 3000 + Vector3.new(0, 3000, 0)
                        RunService.RenderStepped:Wait()
                        hrp.Velocity = vel
                        RunService.Stepped:Wait()
                        hrp.Velocity = vel + Vector3.new(0, movel, 0)
                        movel = -movel
                    end
                end
            end
            task.wait(0.1)
            if _dbRedDot then _dbRedDot.TextColor3 = DOT_OFF end
        end);
    end

    UIS.InputBegan:Connect(function(input, gp)
        if gp or dbWaiting then return end
        if dbKeyBind and input.KeyCode == dbKeyBind and dbFrame and dbFrame.Visible then
            _doDropBrainrot()
        end
    end);

    ToggleSaved("Combat", "Drop Brainrot", "dropBrainrot", true, function(v)
        if v then hubOpen(dbFrame) else hubClose(dbFrame) end
    end);
end

ToggleSaved("Combat", "Hitbox Expander ᵒᵖᵗⁱᵒⁿᵃˡ", "hitboxExp", true, function(v)
    hitboxActive = v
    if v then hitboxStart() else hitboxStop() end
end);

local infJumpActive = false
local jumpForce = 50
local clampFallSpeed = 80
RunService.Heartbeat:Connect(function()
    if not infJumpActive then return end
    local char = lp.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp and hrp.Velocity.Y < -clampFallSpeed then
        hrp.Velocity = Vector3.new(hrp.Velocity.X, -clampFallSpeed, hrp.Velocity.Z)
    end
end);
UIS.JumpRequest:Connect(function()
    if not infJumpActive then return end
    local char = lp.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Velocity = Vector3.new(hrp.Velocity.X, jumpForce, hrp.Velocity.Z) end
end);
ToggleSaved("Combat", "Inf Jump", "infJump", true, function(v)
    infJumpActive = v
end);

ToggleSaved("Combat", "Spin", "spin", true, function(v)
    if v then
        if not spinGui or not spinGui.Parent then spinModule = createSpinHub() end
        spinGui.Enabled = true
    else
        if spinGui then spinGui.Enabled = false end
        if spinModule and spinModule.isActive and spinModule.isActive() then
            if spinModule.toggle then spinModule.toggle() end
        end
    end
end);

ToggleSaved("Combat", "Speed Customizer", "speedCustomizer", true, function(v)
    if v then
        if not speedHubGui or not speedHubGui.Parent then createSpeedHub() end
        speedHubGui.Enabled = true
        local f = speedHubGui:FindFirstChildOfClass("Frame")
        if f then hubOpen(f) end
    else
        if speedHubGui then
            local f = speedHubGui:FindFirstChildOfClass("Frame")
            if f then hubClose(f, function() speedHubGui.Enabled = false end);
            else speedHubGui.Enabled = false end
        end
    end
end);

do
    local resetRow = New("TextButton", {
        Size = UDim2.new(0.93, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BackgroundTransparency = 0,
        Text = "Reset Positions",
        TextColor3 = C.White,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    Instance.new("UICorner", resetRow).CornerRadius = UDim.new(0, 8)
    addDefaultStroke(resetRow)
    resetRow.Parent = Pages["Combat"]
    table.insert(TAB_ROWS["Combat"], resetRow)
    rebuildPage("Combat")

    resetRow.MouseButton1Click:Connect(function()

        local rsStroke = resetRow:FindFirstChildOfClass("UIStroke")
        if rsStroke then
            rsStroke.Color = STROKE_ACTIVE
            TweenService:Create(rsStroke, TweenInfo.new(0.1), {Transparency = 0}):Play()
            task.delay(0.4, function()
                TweenService:Create(rsStroke, TweenInfo.new(0.25), {Transparency = 1}):Play()
            end);
        end

        local defaults = {
            hubMainPos         = {px=288,  py=24},
            menuPos            = {px=119,   py=7},
            tauntConfig        = {px=24,   py=14},
            grabBarPos         = {px=266,  py=221},
            autoPlayConfig     = {px=556,  py=-42},
            autoTPPos          = {px=447,  py=76},
            hitTPPos           = {px=549,  py=93},
            aimBotConfig       = {px=129,  py=128},
            autoBatConfig      = {px=131,  py=7},
            meleeAimConfig     = {px=450,  py=118},
            floatConfig        = {px=131,  py=48},
            dropBrainrotConfig = {px=599,  py=111},
            spinConfig         = {px=131,  py=89},
            speedHubConfig     = {px=570,  py=143},
        }
        for k, v in pairs(defaults) do
            local cur = cfgGet(k) or {}
            for kk, vv in pairs(v) do cur[kk] = vv end
            cfgSet(k, cur)
        end

        local function moveIfVisible(frame, px, py)
            if frame and frame.Visible then
                frame.Position = UDim2.new(0, px, 0, py)
            end
        end

        MainFrame.Position = UDim2.new(0, 288, 0, 24)

        if tFrameGlobal then tFrameGlobal.Position = UDim2.new(0, 24, 0, 14) end

        local function moveFrame(frame, px, py)
            if frame then frame.Position = UDim2.new(0, px, 0, py) end
        end

        moveFrame(LockFrame,        129, 128)
        moveFrame(abFrame,          131, 7)
        moveFrame(autoTPHubFrame,   447, 76)
        moveFrame(hitTPHubFrame,    549, 93)
        moveFrame(meleeAimHubFrame, 450, 118)
        moveFrame(FloatFrame,       131, 48)
        moveFrame(dbFrame,          599, 111)

        aimDadosSalvos.px = 129; aimDadosSalvos.py = 128; salvarAimConfig()

        local gb = infoBarGui and infoBarGui:FindFirstChild("GrabBarFrame")
        if gb then gb.Position = UDim2.new(0, 245, 0, 198) end

        if spinGui then
            local sf = spinGui:FindFirstChildOfClass("Frame")
            if sf then sf.Position = UDim2.new(0, 131, 0, 89) end
        end

        if duelGui then
            local df = duelGui:FindFirstChildOfClass("Frame")
            if df then df.Position = UDim2.new(0, 586, 0, 37) end
        end

        if speedHubGui then
            local sf = speedHubGui:FindFirstChildOfClass("Frame")
            if sf then sf.Position = UDim2.new(0, 570, 0, 143) end
        end

        showToast("Positions reset!")
    end);
end

do

    pcall(function()
        if hookfunction and debug and debug.info then
            local oldInfo
            oldInfo = hookfunction(debug.info, function(...)
                local ok, src = pcall(function() return oldInfo(1, "s") end);
                if ok and src and src:find("Packages.Synchronizer") then
                    return nil
                end
                return oldInfo(...)
            end);
        end
    end);

    local RELOAD_URL = (getgenv and getgenv().SCRIPT_RELOAD_URL) or ""

    if getgenv then
        if getgenv().ORS_AUTOLOAD == nil then
            getgenv().ORS_AUTOLOAD = false
        end
    end

    local autoLoadEnabled = (getgenv and getgenv().ORS_AUTOLOAD == true) or false
    local kickConn = nil

    if getgenv then
        if not getgenv().ORS_LAST_RELOAD then
            getgenv().ORS_LAST_RELOAD = 0
        end
    end

    local autoLoadRow = New("TextButton", {
        Size = UDim2.new(0.93, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BackgroundTransparency = 0,
        Text = "Auto Load for Kick  " .. (autoLoadEnabled and "ON" or "OFF"),
        TextColor3 = autoLoadEnabled and C.White or C.Gray,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
        BorderSizePixel = 0,
    })
    Instance.new("UICorner", autoLoadRow).CornerRadius = UDim.new(0, 8)
    local alStroke = addDefaultStroke(autoLoadRow)
    autoLoadRow.Parent = Pages["Combat"]
    table.insert(TAB_ROWS["Combat"], autoLoadRow)
    rebuildPage("Combat")

    local function doReload()

        local now = tick()
        if getgenv and (now - (getgenv().ORS_LAST_RELOAD or 0)) < 5 then return end
        if getgenv then getgenv().ORS_LAST_RELOAD = now end

        task.wait(0.8)
        local reloaded = false
        pcall(function()
            local url = (getgenv and getgenv().SCRIPT_RELOAD_URL) or RELOAD_URL
            if url and url ~= "" then
                loadstring(game:HttpGet(url, true))()
                reloaded = true
            end
        end);

        if not reloaded then
            task.wait(0.4)
            pcall(function()
                local url = (getgenv and getgenv().SCRIPT_RELOAD_URL) or RELOAD_URL
                if url and url ~= "" then
                    loadstring(game:HttpGet(url, true))()
                end
            end);
        end
    end

    local function setAutoLoad(v)
        autoLoadEnabled = v

        if getgenv then getgenv().ORS_AUTOLOAD = v end

        autoLoadRow.Text = "Auto Load for Kick  " .. (v and "ON" or "OFF")
        autoLoadRow.TextColor3 = v and C.White or C.Gray

        alStroke.Color = v and STROKE_ACTIVE or STROKE_IDLE
        alStroke.Transparency = v and 0 or 1

        if kickConn then kickConn:Disconnect(); kickConn = nil end
        if v then

            kickConn = Players.PlayerRemoving:Connect(function(player)
                if player ~= lp then return end

                doReload()
            end);
        end
    end

    if autoLoadEnabled then
        task.defer(function()
            setAutoLoad(true)
        end);
    end

    autoLoadRow.MouseButton1Click:Connect(function()
        if _dragJustHappened then return end
        setAutoLoad(not autoLoadEnabled)
    end);
end

do

    local function makeSettingsTitle(text)
        local lbl = New("TextLabel", {
            Size = UDim2.new(0.93, 0, 0, 22),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = C.Gray,
            Font = Enum.Font.Bangers,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
        })
        lbl.Parent = Pages["Settings"]
        table.insert(TAB_ROWS["Settings"], lbl)
        rebuildPage("Settings")
        return lbl
    end

    local function makeNumRow(labelText, getValue, setValue, minV, maxV, decimals)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(0.93, 0, 0, 30)
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        row.BackgroundTransparency = 0
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        addDefaultStroke(row)
        row.Parent = Pages["Settings"]
        table.insert(TAB_ROWS["Settings"], row)
        rebuildPage("Settings")

        local lbl = New("TextLabel", {
            Size = UDim2.new(0.58, 0, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = labelText,
            TextColor3 = C.White,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = row,
        })

        local box = New("TextBox", {
            Size = UDim2.new(0.34, 0, 0, 20),
            Position = UDim2.new(0.63, 0, 0.5, -10),
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            BackgroundTransparency = 0,
            TextColor3 = C.White,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            Text = "...",
            ClearTextOnFocus = false,
            ZIndex = 3,
            Parent = row,
        })
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)
        local bStroke = Instance.new("UIStroke", box)
        bStroke.Thickness = 1.5; bStroke.Color = Color3.fromRGB(80, 80, 80)

        task.defer(function()
            task.wait(0.6)
            if box and box.Parent then box.Text = tostring(getValue()) end
        end);

        box.Focused:Connect(function()
            box.Text = tostring(getValue())
        end);
        box.FocusLost:Connect(function()
            local val = tonumber(box.Text:match("[%d%.]+"))
            if val then
                val = math.clamp(val, minV, maxV)
                if not decimals then val = math.floor(val) end
                setValue(val)
            end
            box.Text = tostring(getValue())
        end);
        return row, box
    end

    makeSettingsTitle("▸ DUEL SPEEDS")

    makeNumRow("Duel Speed (not stealing)",
        function() return duelNotStealSpeed end,
        function(v)
            duelNotStealSpeed = v
            local cfg = cfgGet("speedHubConfig") or {}
            cfg.notStealSpeed = v; cfgSet("speedHubConfig", cfg)
            if duelModule and duelModule.setNotStealSpeed then duelModule.setNotStealSpeed(v) end
            if _bridgeSetMvSpeed then _bridgeSetMvSpeed(v) end
        end, 1, 500, true)

    makeNumRow("Return Speed (after steal)",
        function() return duelReturnSpeed end,
        function(v)
            duelReturnSpeed = v
            local cfg = cfgGet("speedHubConfig") or {}
            cfg.rtnSpeed = v; cfgSet("speedHubConfig", cfg)
        end, 1, 200, true)

    makeNumRow("Float Power",
        function()
            return (_floatPowerRef and _floatPowerRef.power) or 14.7
        end,
        function(v)
            if _floatPowerRef then
                _floatPowerRef.power = v
                local cfg = cfgGet("floatConfig") or {}
                cfg.power = v; cfgSet("floatConfig", cfg)
                if floatEnabled then stopFloat(); startFloat() end
            end
        end, 1, 100, true)

    makeSettingsTitle("▸ AIM SPEEDS")

    makeNumRow("Aim Speed",
        function() return AimSpeed end,
        function(v)
            AimSpeed = v
            aimDadosSalvos.speed = v; salvarAimConfig()
            if aimValueBox then aimValueBox.Text = tostring(v) end
        end, 1, 200, true)

    makeNumRow("Aim Bat Speed",
        function()
            local d = cfgGet("autoBatConfig") or {}
            return d.speed or AimSpeed
        end,
        function(v)
            local d = cfgGet("autoBatConfig") or {}
            d.speed = v; cfgSet("autoBatConfig", d)
        end, 1, 300, true)

    makeSettingsTitle("▸ GRAB / STEAL")

    makeNumRow("Steal Radius",
        function() return STEAL_RADIUS end,
        function(v)
            STEAL_RADIUS = v
            if hitboxActive then hitboxExpand = v; hitboxExpandAllPrompts(v) end
            grabBarDados.radius = v; cfgSet("grabBarPos", grabBarDados)
            if radBox then radBox.Text = tostring(v) end
        end, 1, 200, false)

    makeNumRow("Steal Duration (s)",
        function() return STEAL_DURATION end,
        function(v)
            STEAL_DURATION = v
            grabBarDados.duration = v; cfgSet("grabBarPos", grabBarDados)
            if durBox then durBox.Text = tostring(v) end
        end, 0.05, 5, true)

    makeSettingsTitle("▸ SPIN")

    makeNumRow("Spin Speed",
        function()
            local d = cfgGet("spinConfig") or {}
            return d.velocidade or 100
        end,
        function(v)
            local d = cfgGet("spinConfig") or {}
            d.velocidade = v; cfgSet("spinConfig", d)
        end, 1, 9999, false)

    makeSettingsTitle("▸ KEYBINDS")

    local function makeKbRow(labelText, getKey, onSet, getSaveKey, configSection, configKey)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(0.93, 0, 0, 30)
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        row.BackgroundTransparency = 0
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        addDefaultStroke(row)
        row.Parent = Pages["Settings"]
        table.insert(TAB_ROWS["Settings"], row)
        rebuildPage("Settings")

        local lbl = New("TextLabel", {
            Size = UDim2.new(0.55, 0, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = labelText,
            TextColor3 = C.White,
            Font = Enum.Font.GothamBold,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2,
            Parent = row,
        })

        local waiting = false
        local btn = New("TextButton", {
            Size = UDim2.new(0.38, 0, 0, 20),
            Position = UDim2.new(0.59, 0, 0.5, -10),
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            BackgroundTransparency = 0,
            TextColor3 = C.Gray,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            Text = "NONE",
            AutoButtonColor = false,
            ZIndex = 3,
            Parent = row,
        })
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
        local bStroke = Instance.new("UIStroke", btn)
        bStroke.Thickness = 1.5; bStroke.Color = Color3.fromRGB(80, 80, 80)

        local saved = cfgGet(configSection)
        if saved and saved[configKey] then
            local ok, kc = pcall(function() return Enum.KeyCode[saved[configKey]] end);
            if ok and kc then
                onSet(kc)
                btn.Text = saved[configKey]:sub(1,5):upper()
                btn.TextColor3 = C.White
            end
        end

        btn.MouseButton1Click:Connect(function()
            if _dragJustHappened or waiting then return end
            waiting = true
            btn.Text = "..."
            btn.TextColor3 = Color3.fromRGB(255, 220, 80)
            local conn; conn = UIS.InputBegan:Connect(function(input, gp)
                if gp then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    conn:Disconnect()
                    onSet(input.KeyCode)
                    btn.Text = input.KeyCode.Name:sub(1,5):upper()
                    btn.TextColor3 = C.White
                    waiting = false

                    local cfg = cfgGet(configSection) or {}
                    cfg[configKey] = input.KeyCode.Name
                    cfgSet(configSection, cfg)
                end
            end);
        end);

        return btn
    end

    makeKbRow("Auto Play",
        function() return autoKeyBind end,
        function(kc)
            autoKeyBind = kc
        end,
        nil, "autoPlayConfig", "keybind")

    makeKbRow("Aim (Lock)",
        function() return keyBindAim end,
        function(kc)
            keyBindAim = kc
            aimDadosSalvos.keybind = kc.Name; salvarAimConfig()
        end,
        nil, "aimBotConfig", "keybind")

    makeKbRow("Aim Bat",
        function() return keyBindAB end,
        function(kc)
            keyBindAB = kc
            local cfg = cfgGet("autoBatConfig") or {}
            cfg.keybind = kc.Name; cfgSet("autoBatConfig", cfg)
        end,
        nil, "autoBatConfig", "keybind")

    makeKbRow("Float",
        function() return keyBindFloat end,
        function(kc)
            keyBindFloat = kc
            local cfg = cfgGet("floatConfig") or {}
            cfg.keybind = kc.Name; cfgSet("floatConfig", cfg)
        end,
        nil, "floatConfig", "keybind")

    makeKbRow("Drop Brainrot",
        function() return dbKeyBind end,
        function(kc)
            dbKeyBind = kc
            local cfg = cfgGet("dropBrainrotConfig") or {}
            cfg.keybind = kc.Name; cfgSet("dropBrainrotConfig", cfg)
        end,
        nil, "dropBrainrotConfig", "keybind")

    makeKbRow("Auto TP (Manual)",
        function() return keyBindAutoTP end,
        function(kc)
            keyBindAutoTP = kc
            local cfg = cfgGet("autoTPPos") or {}
            cfg.keybind = kc.Name; cfgSet("autoTPPos", cfg)
        end,
        nil, "autoTPPos", "keybind")

    makeKbRow("Hit TP (Auto)",
        function() return keyBindHitTP end,
        function(kc)
            keyBindHitTP = kc
            local cfg = cfgGet("hitTPPos") or {}
            cfg.keybind = kc.Name; cfgSet("hitTPPos", cfg)
        end,
        nil, "hitTPPos", "keybind")
end

do
    local active = false
    local conn   = nil
    local function start()
        if conn then return end
        conn = RunService.Heartbeat:Connect(function()
            if not active then return end
            local char = lp.Character; if not char then return end
            local hrp  = char:FindFirstChild("HumanoidRootPart")
            local hum  = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            local state = hum:GetState()
            if state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                pcall(function() if ControlModule then ControlModule:Enable() end end);
                hrp.AssemblyLinearVelocity  = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") and obj.Enabled == false then obj.Enabled = true end
            end
        end);
    end
    local function stop()
        if conn then conn:Disconnect(); conn = nil end
    end
    lp.CharacterAdded:Connect(function()
        if active then task.wait(0.5); stop(); start() end
    end);
    ToggleSaved("Protect", "Anti-Ragdoll", "antiRagdoll", true, function(v)
        active = v; if v then start() else stop() end
    end);
    if togglesState["antiRagdoll"] == true then active = true; start() end
end

do
    local conn = nil
    local function start()
        if conn then conn:Disconnect() end
        conn = RunService.Stepped:Connect(function()
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= lp and player.Character then
                    for _, v in pairs(player.Character:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end
        end);
    end
    local function stop()
        if conn then conn:Disconnect(); conn = nil end
    end
    lp.CharacterAdded:Connect(function()
        if conn then stop(); task.wait(0.5); start() end
    end);
    ToggleSaved("Protect", "Anti Fling", "antiFling", true, function(v)
        if v then start() else stop() end
    end);
    if togglesState["antiFling"] == true then start() end
end

ToggleSaved("Protect", "Float", "float", true, function(v)
    if not FloatFrame then return end
    if v then
        hubOpen(FloatFrame)
    else
        hubClose(FloatFrame, function()
            if floatEnabled then
                floatEnabled = false
                setHubActive(FloatFrame, floatRedDot, false)
                stopFloat()
            end
        end);
    end
end);

ToggleSaved("Protect", "Optimizer", "optimizer", true, function(v)
    task.defer(function()
        task.wait(0.2)
        if v then enableOptimizer() else disableOptimizer() end
    end);
end);

ToggleSaved("Desync", "Desync No Reset", "desyncNoReset", true, function(v)

end);

ToggleSaved("Desync", "Desync Reset", "desyncReset", true, function(v)

end);

ToggleSaved("Visual", "Xray Base", "xrayBase", true, function(v)
    task.defer(function()
        task.wait(0.2)
        if v then enableXray() else disableXray() end
    end);
end);

ToggleSaved("Visual", "FOV", "fov", true, function(v)
    task.spawn(function()
        task.wait(0.3)
        local cam = workspace.CurrentCamera
        TweenService:Create(cam, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {FieldOfView = v and 100 or 70}):Play()
    end);
end);

ToggleSaved("Visual", "No Anim", "noAnim", true, function(v)
    if v then startNoAnim() else stopNoAnim() end
end);

ToggleSaved("Visual", "Player ESP", "playerEsp", true, function(v)
    espEnabled = v
    if v then enableESP() else disableESP() end
end);

local function showToast(message)
    local toast = Instance.new("Frame", Screen)
    toast.Size = UDim2.new(0, 260, 0, 38)
    toast.Position = UDim2.new(0.5, -130, 0, -50)
    toast.BackgroundColor3 = C.Black
    toast.BackgroundTransparency = 0.04
    toast.BorderSizePixel = 0
    toast.ZIndex = 50
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 12)
    local tStroke = Instance.new("UIStroke", toast)
    tStroke.Thickness = 2
    tStroke.Color = C.Gray

    local tGrad = Instance.new("UIGradient", toast)
    tGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,  0,  0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(12, 12, 12)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(30, 30, 30)),
    })
    tGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0,   0.02),
        NumberSequenceKeypoint.new(0.6, 0.05),
        NumberSequenceKeypoint.new(1,   0.12),
    })
    tGrad.Rotation = 135

    local lbl = Instance.new("TextLabel", toast)
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = message
    lbl.TextColor3 = C.White
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 51

    TweenService:Create(toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        {Position = UDim2.new(0.5, -130, 0, 14)}):Play()
    task.delay(2.5, function()
        TweenService:Create(toast, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, -130, 0, -50)}):Play()
        task.wait(0.3)
        toast:Destroy()
    end);
end;

(function()

    local menuPosDados = { px = -1, py = -1 }
    do
        local d = cfgGet("menuPos") or {px=43, py=13}
        if d then

            if d.X ~= nil and d.px == nil then
                local ok, vp = pcall(function() return workspace.CurrentCamera.ViewportSize end);
                if ok and vp and vp.X > 0 then
                    d.px = math.floor(d.X * vp.X) + (d.XO or 0)
                    d.py = math.floor(d.Y * vp.Y) + (d.YO or 0)
                end
                d.X = nil; d.Y = nil; d.XO = nil; d.YO = nil
            end
            menuPosDados = d
        end
    end

    if menuPosDados.px and menuPosDados.px >= 0 then
        miniFrame.Position = UDim2.new(0, menuPosDados.px, 0, menuPosDados.py)
    end

    local pressing    = false
    local pressStart  = Vector2.zero
    local frameStart  = Vector2.zero
    local dragInput   = nil
    local movedDist   = 0
    local activeMenuInput = nil

    menuBtn.InputBegan:Connect(function(i)
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
        pressing  = true
        movedDist = 0
        pressStart   = Vector2.new(i.Position.X, i.Position.Y)
        frameStart   = Vector2.new(miniFrame.AbsolutePosition.X, miniFrame.AbsolutePosition.Y)
        activeMenuInput = i
        dragInput = nil
    end);

    menuBtn.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then
            dragInput = i
        end
    end);

    UIS.InputChanged:Connect(function(i)
        if not pressing then return end
        if i ~= dragInput then return end
        local d = Vector2.new(i.Position.X, i.Position.Y) - pressStart
        movedDist = d.Magnitude
        miniFrame.Position = UDim2.new(0, frameStart.X + d.X, 0, frameStart.Y + d.Y)
    end);

    UIS.InputEnded:Connect(function(i)
        if not pressing then return end
        if i ~= activeMenuInput then return end
        if i.UserInputType ~= Enum.UserInputType.MouseButton1 and i.UserInputType ~= Enum.UserInputType.Touch then return end
        local wasDrag = movedDist >= 8
        pressing = false; movedDist = 0; activeMenuInput = nil
        if wasDrag then
            local ap = miniFrame.AbsolutePosition
            menuPosDados.px = ap.X; menuPosDados.py = ap.Y
            cfgSetNow("menuPos", menuPosDados)
            return
        end
        if MainFrame.Visible then

            local w = 198; local h = 240
            local ap = MainFrame.AbsolutePosition
            TweenService:Create(MainFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                {Size = UDim2.new(0, w * 0.75, 0, h * 0.75),
                 Position = UDim2.new(0, ap.X + w*0.125, 0, ap.Y + h*0.125),
                 BackgroundTransparency = 1}):Play()
            task.delay(0.19, function()
                MainFrame.Visible = false
                MainFrame.Size = UDim2.new(0, w, 0, h)
                MainFrame.Position = UDim2.new(0, ap.X, 0, ap.Y)
                MainFrame.BackgroundTransparency = 0
            end);
            TweenService:Create(mStroke, TweenInfo.new(0.2), {Transparency = 1}):Play()
        else

            local w = 198; local h = 240
            MainFrame.BackgroundTransparency = 1
            MainFrame.Size = UDim2.new(0, w * 0.75, 0, h * 0.75)

            local ap = MainFrame.AbsolutePosition
            MainFrame.Position = UDim2.new(0, ap.X + w*0.125, 0, ap.Y + h*0.125)
            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Size = UDim2.new(0, w, 0, h),
                 Position = UDim2.new(0, ap.X, 0, ap.Y),
                 BackgroundTransparency = 0}):Play()

            mStroke.Color = STROKE_ACTIVE
            TweenService:Create(mStroke, TweenInfo.new(0.2), {Transparency = 0}):Play()
        end
    end);
end)();

pcall(function() spinModule = createSpinHub() end);
pcall(function() duelModule = createDuelHub() end);
pcall(function() createSpeedHub() end);

task.defer(function()
    task.wait(0.4)

    local keys = {
        "lock", "autoDuel", "spin", "speedCustomizer",
        "meleeAimbot", "infJump", "antiRagdoll", "noAnim", "playerEsp",
        "float",
        "fov", "optimizer", "xrayBase",
        "autoTP",
        "hitTP",
        "desyncNoReset", "desyncReset",
        "autoSteal",
        "hitboxExp",
        "autoBat",
        "aimBatHub",
        "dropBrainrot",
    }

    _hubRestoring = true
    for _, k in ipairs(keys) do
        if togglesState[k] == true and toggleForces[k] then
            pcall(toggleForces[k], true)
        end
    end
    _hubRestoring = false
end);