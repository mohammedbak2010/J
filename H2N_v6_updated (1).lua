-- H2N v6.1 - ULTIMATE DESYNC FIX (PC + Mobile)
-- تحسين الديسنك ليكون أقوى بدون سجادة
-- دعم كامل للجوال والبي سي

repeat task.wait() until game:IsLoaded()
if not game.PlaceId then repeat task.wait(1) until game.PlaceId end

-- INTRO
task.spawn(function()
    local introGui = Instance.new("ScreenGui")
    introGui.Name = "H2NIntro"
    introGui.ResetOnSpawn = false
    introGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    introGui.DisplayOrder = 9999
    local ok = pcall(function() introGui.Parent = game:GetService("CoreGui") end)
    if not ok then introGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    local bg = Instance.new("Frame", introGui)
    bg.Size = UDim2.new(1, 0, 0, 120)
    bg.Position = UDim2.new(0, 0, 0.3, 0)
    bg.BackgroundTransparency = 1
    bg.ZIndex = 199

    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1, 0, 0, 50)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.ZIndex = 200
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextSize = 28
    lbl.TextColor3 = Color3.fromRGB(255, 215, 100)
    lbl.TextTransparency = 0
    lbl.Text = "best duels script"
    lbl.TextXAlignment = Enum.TextXAlignment.Center
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    local lbl2 = Instance.new("TextLabel", bg)
    lbl2.Size = UDim2.new(1, 0, 0, 30)
    lbl2.Position = UDim2.new(0, 0, 0, 52)
    lbl2.BackgroundTransparency = 1
    lbl2.ZIndex = 200
    lbl2.Font = Enum.Font.GothamBold
    lbl2.TextSize = 20
    lbl2.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl2.TextTransparency = 0
    lbl2.Text = ""
    lbl2.TextXAlignment = Enum.TextXAlignment.Center
    lbl2.TextStrokeTransparency = 0
    lbl2.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    local lbl3 = Instance.new("TextLabel", bg)
    lbl3.Size = UDim2.new(1, 0, 0, 30)
    lbl3.Position = UDim2.new(0, 0, 0, 85)
    lbl3.BackgroundTransparency = 1
    lbl3.ZIndex = 200
    lbl3.Font = Enum.Font.GothamBold
    lbl3.TextSize = 18
    lbl3.TextColor3 = Color3.fromRGB(255, 240, 150)
    lbl3.TextTransparency = 0
    lbl3.Text = ""
    lbl3.TextXAlignment = Enum.TextXAlignment.Center
    lbl3.TextStrokeTransparency = 0
    lbl3.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

    task.wait(5)
    introGui:Destroy()
end)

pcall(function()
    for _, v in ipairs(workspace:GetDescendants()) do
        if v.Name and (v.Name:find("H2N_WP_") or v.Name:find("H2N_Duel_")) then
            v:Destroy()
        end
    end
end)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer
local Char, HRP, Hum
local isMobile = UIS.TouchEnabled and not UIS.MouseEnabled

-- ANTI LAG GLOBAL FLAG
AntiLagEnabled = false

local fireproximityprompt = fireproximityprompt or function(prompt)
    if not prompt then return end
    pcall(function()
        if prompt.InputHoldBegin then
            prompt.InputHoldBegin()
            task.wait(0.05)
            prompt.InputHoldEnd()
        end
    end)
end

local function SafeWriteFile(name, data)
    pcall(function() if writefile then writefile(name, data) end end)
end

local function SafeReadFile(name)
    local success, result = pcall(function() if readfile then return readfile(name) end end)
    if success and result then return result end
    return nil
end

-- H2N Theme: Royal Gold × Obsidian
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
local Colors = {
    White = T.Bg1, LightGray = T.Bg2,
    MediumGray = T.A, DarkGray = T.C,
    VeryDark = T.Bg0, AlmostBlack = T.Bg0,
    Border = T.Br, Text = T.Tx,
    SubText = T.TxS, Success = T.Suc,
    Error = T.Err, DotOff = T.BrD,
    DotOn = T.A, DiscordBlue = T.B,
}

-- ============================================================
-- SHIMMER: UIGradient دوار
-- ============================================================
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

local function applySpinningGoldStroke(parent, thickness, speed)
    thickness = thickness or 2
    speed = speed or 1.4
    local stroke = Instance.new("UIStroke")
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness = thickness
    stroke.Parent = parent
    local grad = Instance.new("UIGradient", stroke)
    grad.Color = makeGoldGradient()
    grad.Rotation = math.random(0, 360)
    local GC = {
        Color3.fromRGB(255,215,100), Color3.fromRGB(255,245,180),
        Color3.fromRGB(220,165, 30), Color3.fromRGB(255,200, 60),
        Color3.fromRGB(255,255,220),
    }
    task.spawn(function()
        local t = math.random()*10
        local waitTime = 0.12
        while parent and parent.Parent do
            t = t + waitTime
            if not AntiLagEnabled then
                grad.Rotation = (grad.Rotation + speed) % 360
                local i = math.floor(t*1.5) % #GC + 1
                stroke.Color     = GC[i]:Lerp(GC[i%#GC+1], (t*1.5)%1)
                stroke.Thickness = thickness + math.abs(math.sin(t*2)) * 1.0
            end
            task.wait(waitTime)
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
    ov.Active = false
    ov.Selectable = false
    local c = parent:FindFirstChildOfClass("UICorner")
    if c then
        Instance.new("UICorner", ov).CornerRadius = c.CornerRadius
    end
    local g = Instance.new("UIGradient", ov)
    g.Color    = makeGoldGradient()
    g.Rotation = math.random(0, 360)
    task.spawn(function()
        while ov and ov.Parent do
            if not AntiLagEnabled then
                g.Rotation = (g.Rotation + (speed or 1.4)) % 360
            end
            task.wait(0.12)
        end
    end)
    return ov
end

local _notifyQueue = {}
local gui = nil

local function Notify(txt)
    if gui then
        local f = Instance.new("Frame", gui)
        f.Size = UDim2.new(0, 203, 0, 32)
        f.Position = UDim2.new(1, -218, 1, -80)
        f.AnchorPoint = Vector2.new(0, 1)
        f.BackgroundColor3 = T.Bg2
        f.BackgroundTransparency = 0.05
        f.ZIndex = 70
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

        local ns = applySpinningGoldStroke(f, 1.5, 1.8)
        addBgShimmer(f, 1.6, 0.88)

        local notifAccent = Instance.new("Frame", f)
        notifAccent.Size = UDim2.new(0, 3, 1, -6)
        notifAccent.Position = UDim2.new(0, 4, 0, 3)
        notifAccent.BackgroundColor3 = T.Br
        notifAccent.BorderSizePixel = 0
        notifAccent.ZIndex = 72
        Instance.new("UICorner", notifAccent).CornerRadius = UDim.new(1, 0)

        if not AntiLagEnabled then
            task.spawn(function()
                local t = 0
                local GC = {
                    Color3.fromRGB(255,215,100), Color3.fromRGB(255,245,180),
                    Color3.fromRGB(220,165, 30), Color3.fromRGB(255,200, 60),
                    Color3.fromRGB(255,255,220),
                }
                while notifAccent and notifAccent.Parent do
                    t = t + 0.12
                    local i = math.floor(t*1.5) % #GC + 1
                    notifAccent.BackgroundColor3 = GC[i]:Lerp(GC[i%#GC+1], (t*1.5)%1)
                    task.wait(0.12)
                end
            end)
        end

        local fl = Instance.new("TextLabel", f)
        fl.Size = UDim2.new(1, -14, 1, 0)
        fl.Position = UDim2.new(0, 13, 0, 0)
        fl.BackgroundTransparency = 1
        fl.Text = txt
        fl.TextColor3 = T.Tx
        fl.Font = Enum.Font.GothamBold
        fl.TextSize = 11
        fl.ZIndex = 73
        fl.TextXAlignment = Enum.TextXAlignment.Left
        fl.TextTruncate = Enum.TextTruncate.AtEnd

        if not AntiLagEnabled then
            task.spawn(function()
                local t = 0
                local GC = {
                    Color3.fromRGB(255,215,100), Color3.fromRGB(255,245,180),
                    Color3.fromRGB(220,165, 30), Color3.fromRGB(255,200, 60),
                    Color3.fromRGB(255,255,220),
                }
                while fl and fl.Parent do
                    t = t + 0.12
                    local i = math.floor(t*1.5) % #GC + 1
                    fl.TextColor3 = GC[i]:Lerp(GC[i%#GC+1], (t*1.5)%1)
                    task.wait(0.12)
                end
            end)
        end

        f.Position = UDim2.new(1, 10, 1, -80)
        game:GetService("TweenService"):Create(f,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Position = UDim2.new(1, -218, 1, -80) }
        ):Play()

        task.spawn(function()
            task.wait(AntiLagEnabled and 1.5 or 3)
            game:GetService("TweenService"):Create(f,
                TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                { Position = UDim2.new(1, 10, 1, -80), BackgroundTransparency = 1 }
            ):Play()
            task.wait(0.26)
            f:Destroy()
        end)
    else
        table.insert(_notifyQueue, txt)
    end
end

local function Setup(c)
    Char = c
    HRP = c:WaitForChild("HumanoidRootPart")
    Hum = c:WaitForChild("Humanoid")
    pcall(function() HRP:SetNetworkOwner(LP) end)
end

if LP.Character then Setup(LP.Character) end
LP.CharacterAdded:Connect(function(c)
    task.wait(0.1)
    Setup(c)
    pcall(function()
        _grabCallbackCache = {}
    end)
end)

local _switchingModes = false
local StopAutoPlayLeft, StopAutoPlayRight

local State = {
    AutoPlayLeft = false, AutoPlayRight = false,
    AntiRagdoll = false, InfiniteJump = false, XrayBase = false,
    ESP = false, AntiSentry = false, SpinBody = false, FloatEnabled = false,
    SpeedBoostEnabled = false, AutoGrab = false, Optimizer = false,
    HitCircle = false, SpamBat = false,
}

-- ============================================
-- DESYNC ULTRA (بدون سجادة - أقوى نسخة)
-- ============================================
local DesyncState = { enabled = false, savedCFrame = nil, savedHealth = nil }

local function startDesync()
    if DesyncState.enabled then return end
    DesyncState.enabled = true
    
    -- 1. تشغيل raknet
    pcall(function() raknet.desync(true) end)
    
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if hrp then
            -- حفظ موقعك
            DesyncState.savedCFrame = hrp.CFrame
            if hum and hum.Health then
                DesyncState.savedHealth = hum.Health
            end
            
            -- الطريقة 1: قفزة مفاجئة عالية
            hrp.CFrame = CFrame.new(hrp.Position.X + math.random(80,150), hrp.Position.Y - 40, hrp.Position.Z + math.random(80,150))
            task.wait(0.02)
            
            -- الطريقة 2: إرجاع سريع مع فيلوسيتي عالي (يخلي السيرفر يضيع)
            hrp.CFrame = DesyncState.savedCFrame
            hrp.AssemblyLinearVelocity = Vector3.new(math.random(-999,999), math.random(500,1500), math.random(-999,999))
            task.wait(0.03)
            
            -- الطريقة 3: هزة أرضية (تكسر الـ sync)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 15, 0)
            task.wait(0.02)
            hrp.CFrame = DesyncState.savedCFrame
            
            -- الطريقة 4: للموبايل فقط - قفل مؤقت للإدخال
            if isMobile then
                pcall(function()
                    UIS.TouchEnabled = false
                    task.wait(0.1)
                    UIS.TouchEnabled = true
                end)
            end
        end
        
        if hum then
            -- إيقاف كل الأنيميشنات (يمنع الرجوع)
            for _, track in pairs(hum:GetPlayingAnimationTracks()) do
                track:Stop()
            end
            -- تجميد الحركة مؤقتاً
            hum.AutoRotate = false
            hum.WalkSpeed = 0
        end
    end
    
    -- 5. تفعيل الـ Desync Loop (يضمن الاستمرارية)
    DesyncState.loopConn = RunService.Heartbeat:Connect(function()
        if not DesyncState.enabled then
            if DesyncState.loopConn then DesyncState.loopConn:Disconnect() end
            return
        end
        -- كل فريم نضرب raknet عشان نضمن القوة
        pcall(function() raknet.desync(true) end)
        -- نمنع أي محاولة لإصلاح الموقع
        local c2 = LP.Character
        if c2 and c2:FindFirstChild("Humanoid") then
            c2.Humanoid.AutoRotate = false
        end
    end)
    
    Notify("DESYNC ULTRA ON")
end

local function stopDesync()
    if not DesyncState.enabled then return end
    DesyncState.enabled = false
    
    -- إيقاف raknet
    pcall(function() raknet.desync(false) end)
    
    -- إيقاف اللوب
    if DesyncState.loopConn then
        DesyncState.loopConn:Disconnect()
        DesyncState.loopConn = nil
    end
    
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        -- إعادة ضبط الإعدادات
        if hum then
            hum.AutoRotate = true
            hum.WalkSpeed = 16
            -- إعادة الصحة إذا كانت تغيرت
            if DesyncState.savedHealth and hum.Health < DesyncState.savedHealth then
                hum.Health = DesyncState.savedHealth
            end
        end
        
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            -- إعادة الموقع المحفوظ
            if DesyncState.savedCFrame then
                hrp.CFrame = DesyncState.savedCFrame
            end
        end
    end
    
    Notify("DESYNC ULTRA OFF")
end

function ToggleDesync()
    if DesyncState.enabled then
        stopDesync()
    else
        startDesync()
    end
end

-- ============================================
-- باقي المتغيرات والدوال (نفس الأصل)
-- ============================================
local SpeedSettings = { NormalSpeed = 59, StealSpeed = 30 }
local isSpeedBoostEnabled = false
local speedConn = nil
local speedBoostWasOnBeforeAutoPlay = false

local _sbFrameSkip = 0
local _sbCurrentSpeed = 0
local _sbIsStealing = false
local _sbTransitionTime = 0
local _sbTransitionDuration = 0.35
local _sbLastStealState = false

local function getHRP()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function isHoldingBrainrot()
    local char = LP.Character
    if not char then return false end
    if LP:GetAttribute("Stealing") then return true end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") and (child.Name:lower():find("brainrot") or child.Name:lower():find("brain")) then
            return true
        end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.WalkSpeed < 27 then return true end
    return false
end

local function _naturalJitter(baseSpeed)
    return baseSpeed
end

local function startSpeedBoost()
    if isSpeedBoostEnabled then return end
    isSpeedBoostEnabled = true
    _sbCurrentSpeed = 0
    _sbFrameSkip = 0
    _sbIsStealing = isHoldingBrainrot()
    _sbLastStealState = _sbIsStealing
    _sbCurrentSpeed = _sbIsStealing and SpeedSettings.StealSpeed or SpeedSettings.NormalSpeed
    if speedConn then speedConn:Disconnect() end

    speedConn = RunService.Heartbeat:Connect(function(dt)
        if not isSpeedBoostEnabled then return end

        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end

        local nowStealing = isHoldingBrainrot()
        if nowStealing ~= _sbLastStealState then
            _sbLastStealState = nowStealing
            _sbTransitionTime = tick()
        end

        local targetSpeed = nowStealing and SpeedSettings.StealSpeed or SpeedSettings.NormalSpeed

        local moveDir = hum.MoveDirection
        local curVel = hrp.AssemblyLinearVelocity

        if moveDir.Magnitude > 0.1 then
            hrp.AssemblyLinearVelocity = Vector3.new(
                moveDir.X * targetSpeed,
                curVel.Y,
                moveDir.Z * targetSpeed
            )
        else
            if math.abs(curVel.X) > 0.5 or math.abs(curVel.Z) > 0.5 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, curVel.Y, 0)
            end
        end
    end)

    if Hum then Hum.UseJumpPower = true; Hum.JumpPower = 45 end
    Notify("SPEED BOOST ON")
end

local function stopSpeedBoost()
    if not isSpeedBoostEnabled then return end
    isSpeedBoostEnabled = false
    if speedConn then speedConn:Disconnect(); speedConn = nil end
    _sbCurrentSpeed = 0
    _sbFrameSkip = 0
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.new(
                hrp.AssemblyLinearVelocity.X * 0.1,
                hrp.AssemblyLinearVelocity.Y,
                hrp.AssemblyLinearVelocity.Z * 0.1
            )
        end
    end
    Notify("SPEED BOOST OFF")
end

-- FLOAT
local FloatConn = nil
local FLOAT_TARGET_HEIGHT = 10
local FLOAT_RISE_HEIGHT = 10

local function startFloat()
    if State.FloatEnabled then return end
    local char = LP.Character if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart") if not hrp then return end
    local floatOriginY = hrp.Position.Y + FLOAT_RISE_HEIGHT
    State.FloatEnabled = true
    if FloatConn then FloatConn:Disconnect(); FloatConn = nil end
    FloatConn = RunService.Heartbeat:Connect(function()
        if not State.FloatEnabled then return end
        local c2 = LP.Character if not c2 then return end
        local h = c2:FindFirstChild("HumanoidRootPart") if not h then return end
        local hum2 = c2:FindFirstChildOfClass("Humanoid")
        local moveDir = hum2 and hum2.MoveDirection or Vector3.zero
        local diff = floatOriginY - h.Position.Y
        local vertVel
        if diff > 0.3 then vertVel = math.clamp(diff * 8, 5, 50)
        elseif diff < -0.3 then vertVel = math.clamp(diff * 8, -50, -5)
        else vertVel = 0 end
        h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, vertVel, h.AssemblyLinearVelocity.Z)
    end)
    Notify("FLOAT ON")
end

local function stopFloat()
    if not State.FloatEnabled then return end
    State.FloatEnabled = false
    if FloatConn then FloatConn:Disconnect(); FloatConn = nil end
    local char = LP.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.AssemblyLinearVelocity = Vector3.zero end
    end
    Notify("FLOAT OFF")
end

-- AUTO GRAB
local EnhancedGrab = { Enabled = false, Radius = 8, LoopConnection = nil }
-- AUTO GRAB (PC) - نسخة PC مع سرعة قابلة للضبط
local PCGrab = { Enabled = false, Radius = 10, Speed = 0.25, LoopConnection = nil }
local grabBarRef = {}
local sbFill = nil
local stealBarFrame = nil
local _grabStealCache = {}
local _grabIsStealing = false
local _pcGrabStealCache = {}
local _pcGrabIsStealing = false

local function _isMyPlot(plotName)
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    if not sign then return false end
    local yb = sign:FindFirstChild("YourBase")
    if yb and yb:IsA("BillboardGui") then return yb.Enabled end
    return false
end

local function _findNearestPodiumPrompt()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local bestPrompt, bestDist, bestName = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if not _isMyPlot(plot.Name) then
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, pod in ipairs(podiums:GetChildren()) do
                    pcall(function()
                        local base = pod:FindFirstChild("Base")
                        local spawnPart = base and base:FindFirstChild("Spawn")
                        if spawnPart then
                            local spXZ = Vector2.new(spawnPart.Position.X, spawnPart.Position.Z)
                            local hrXZ = Vector2.new(hrp.Position.X, hrp.Position.Z)
                            local dist = (spXZ - hrXZ).Magnitude
                            if dist < bestDist and dist <= EnhancedGrab.Radius then
                                for _, child in ipairs(spawnPart:GetDescendants()) do
                                    if child:IsA("ProximityPrompt") and child.Enabled then
                                        bestPrompt = child
                                        bestDist = dist
                                        bestName = pod.Name
                                        break
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
    return bestPrompt, bestName
end

local function _buildGrabCallbacks(prompt)
    if _grabStealCache[prompt] then return end
    local data = { holdCBs = {}, triggerCBs = {}, ready = true }
    local ok1, c1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(c1) == "table" then
        for _, conn in ipairs(c1) do
            if type(conn.Function) == "function" then table.insert(data.holdCBs, conn.Function) end
        end
    end
    local ok2, c2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(c2) == "table" then
        for _, conn in ipairs(c2) do
            if type(conn.Function) == "function" then table.insert(data.triggerCBs, conn.Function) end
        end
    end
    if #data.holdCBs > 0 or #data.triggerCBs > 0 then _grabStealCache[prompt] = data end
end

local function _execGrabSteal(prompt, name)
    local data = _grabStealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    _grabIsStealing = true
    if grabBarRef.fill then grabBarRef.fill.Size = UDim2.new(1, 0, 1, 0) end
    if grabBarRef.pct then grabBarRef.pct.Text = "100%" end
    task.spawn(function()
        for _, fn in ipairs(data.holdCBs) do task.spawn(fn) end
        task.wait(0.2)
        for _, fn in ipairs(data.triggerCBs) do task.spawn(fn) end
        task.wait(0.05)
        data.ready = true
        _grabIsStealing = false
        _grabStealCache[prompt] = nil
        if grabBarRef.fill then grabBarRef.fill.Size = UDim2.new(0, 0, 1, 0) end
        if grabBarRef.pct then grabBarRef.pct.Text = "0%" end
    end)
    return true
end

local function UpdateEnhancedGrabBar(percent)
    if grabBarRef and grabBarRef.fill then
        grabBarRef.fill.Size = UDim2.new(math.clamp(percent/100,0,1),0,1,0)
    end
    if grabBarRef and grabBarRef.pct then
        grabBarRef.pct.Text = math.floor(percent).."%"
    end
    if grabBarRef and grabBarRef.radiusLbl then
        grabBarRef.radiusLbl.Text = EnhancedGrab.Radius.."st"
    end
    if grabBarRef and grabBarRef.rateLbl then
        grabBarRef.rateLbl.Text = ""
    end
end

local function StartEnhancedGrab()
    if EnhancedGrab.Enabled then return end
    -- mutual exclusion: إذا PC grab شغال، أوقفه أول
    if PCGrab.Enabled then
        PCGrab.Enabled = false
        _pcGrabIsStealing = false
        _pcGrabStealCache = {}
        if PCGrab.LoopConnection then PCGrab.LoopConnection:Disconnect(); PCGrab.LoopConnection = nil end
        if toggleUpdaters and toggleUpdaters["PCGrab"] then toggleUpdaters["PCGrab"](false) end
        Notify("AUTO GRAB (PC) OFF")
    end
    EnhancedGrab.Enabled = true
    _grabStealCache = {}
    _grabIsStealing = false
    if EnhancedGrab.LoopConnection then EnhancedGrab.LoopConnection:Disconnect() end
    EnhancedGrab.LoopConnection = RunService.Heartbeat:Connect(function()
        if not EnhancedGrab.Enabled or _grabIsStealing then return end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            local s = hum:GetState()
            if s == Enum.HumanoidStateType.Ragdoll
            or s == Enum.HumanoidStateType.FallingDown
            or s == Enum.HumanoidStateType.Physics then return end
        end
        local prompt, animalName = _findNearestPodiumPrompt()
        if prompt then
            _buildGrabCallbacks(prompt)
            _execGrabSteal(prompt, animalName)
        else
            UpdateEnhancedGrabBar(0)
        end
    end)
    UpdateEnhancedGrabBar(0)
    Notify("AUTO GRAB ON | Range: "..EnhancedGrab.Radius)
end

local function StopEnhancedGrab()
    if not EnhancedGrab.Enabled then return end
    EnhancedGrab.Enabled = false
    _grabIsStealing = false
    _grabStealCache = {}
    UpdateEnhancedGrabBar(0)
    if EnhancedGrab.LoopConnection then
        EnhancedGrab.LoopConnection:Disconnect()
        EnhancedGrab.LoopConnection = nil
    end
    Notify("AUTO GRAB OFF")
end

-- ============================================
-- AUTO GRAB (PC) - نسخة PC من blood hub
-- سرعة قابلة للتحكم، مدى قابل للتحكم
-- mutual exclusive مع AUTO GRAB العادي
-- يشارك نفس بار السرقة
-- ============================================
local function _findNearestPodiumPromptPC()
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local bestPrompt, bestDist, bestName = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if not _isMyPlot(plot.Name) then
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if podiums then
                for _, pod in ipairs(podiums:GetChildren()) do
                    pcall(function()
                        local base = pod:FindFirstChild("Base")
                        local spawnPart = base and base:FindFirstChild("Spawn")
                        if spawnPart then
                            local dist = (Vector2.new(spawnPart.Position.X, spawnPart.Position.Z)
                                        - Vector2.new(hrp.Position.X, hrp.Position.Z)).Magnitude
                            if dist < bestDist and dist <= PCGrab.Radius then
                                for _, child in ipairs(spawnPart:GetDescendants()) do
                                    if child:IsA("ProximityPrompt") and child.Enabled then
                                        bestPrompt = child
                                        bestDist = dist
                                        bestName = pod.Name
                                        break
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end
    end
    return bestPrompt, bestName
end

local function _buildPCGrabCallbacks(prompt)
    if _pcGrabStealCache[prompt] then return end
    local data = { holdCBs = {}, triggerCBs = {}, ready = true }
    local ok1, c1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 and type(c1) == "table" then
        for _, conn in ipairs(c1) do
            if type(conn.Function) == "function" then table.insert(data.holdCBs, conn.Function) end
        end
    end
    local ok2, c2 = pcall(getconnections, prompt.Triggered)
    if ok2 and type(c2) == "table" then
        for _, conn in ipairs(c2) do
            if type(conn.Function) == "function" then table.insert(data.triggerCBs, conn.Function) end
        end
    end
    if #data.holdCBs > 0 or #data.triggerCBs > 0 then _pcGrabStealCache[prompt] = data end
end

local function _execPCGrabSteal(prompt)
    local data = _pcGrabStealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    _pcGrabIsStealing = true
    -- تحديث البار المشترك
    if grabBarRef.fill then grabBarRef.fill.Size = UDim2.new(0, 0, 1, 0) end
    if grabBarRef.pct then grabBarRef.pct.Text = "0%" end
    task.spawn(function()
        -- تقدم تدريجي بناء على Speed
        local startT = tick()
        local dur = PCGrab.Speed
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not _pcGrabIsStealing then conn:Disconnect(); return end
            local prog = math.clamp((tick() - startT) / dur, 0, 1)
            if grabBarRef.fill then grabBarRef.fill.Size = UDim2.new(prog, 0, 1, 0) end
            if grabBarRef.pct then grabBarRef.pct.Text = math.floor(prog * 100).."%" end
        end)
        for _, fn in ipairs(data.holdCBs) do task.spawn(fn) end
        task.wait(dur)
        conn:Disconnect()
        for _, fn in ipairs(data.triggerCBs) do task.spawn(fn) end
        task.wait(0.05)
        data.ready = true
        _pcGrabIsStealing = false
        _pcGrabStealCache[prompt] = nil
        if grabBarRef.fill then grabBarRef.fill.Size = UDim2.new(0, 0, 1, 0) end
        if grabBarRef.pct then grabBarRef.pct.Text = "0%" end
        if grabBarRef.radiusLbl then grabBarRef.radiusLbl.Text = PCGrab.Radius.."st" end
    end)
    return true
end

local function StartPCGrab()
    if PCGrab.Enabled then return end
    -- mutual exclusion: إذا mobile grab شغال، أوقفه
    if EnhancedGrab.Enabled then
        StopEnhancedGrab()
        if toggleUpdaters and toggleUpdaters["AutoGrab"] then toggleUpdaters["AutoGrab"](false) end
    end
    PCGrab.Enabled = true
    _pcGrabStealCache = {}
    _pcGrabIsStealing = false
    if PCGrab.LoopConnection then PCGrab.LoopConnection:Disconnect() end
    PCGrab.LoopConnection = RunService.Heartbeat:Connect(function()
        if not PCGrab.Enabled or _pcGrabIsStealing then return end
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            local s = hum:GetState()
            if s == Enum.HumanoidStateType.Ragdoll
            or s == Enum.HumanoidStateType.FallingDown
            or s == Enum.HumanoidStateType.Physics then return end
        end
        local prompt = _findNearestPodiumPromptPC()
        if prompt then
            _buildPCGrabCallbacks(prompt)
            _execPCGrabSteal(prompt)
        else
            if grabBarRef.fill then grabBarRef.fill.Size = UDim2.new(0,0,1,0) end
            if grabBarRef.pct then grabBarRef.pct.Text = "0%" end
            if grabBarRef.radiusLbl then grabBarRef.radiusLbl.Text = PCGrab.Radius.."st" end
        end
    end)
    if grabBarRef.radiusLbl then grabBarRef.radiusLbl.Text = PCGrab.Radius.."st" end
    Notify("AUTO GRAB (PC) ON | Range: "..PCGrab.Radius)
end

local function StopPCGrab()
    if not PCGrab.Enabled then return end
    PCGrab.Enabled = false
    _pcGrabIsStealing = false
    _pcGrabStealCache = {}
    if grabBarRef.fill then grabBarRef.fill.Size = UDim2.new(0,0,1,0) end
    if grabBarRef.pct then grabBarRef.pct.Text = "0%" end
    if PCGrab.LoopConnection then
        PCGrab.LoopConnection:Disconnect()
        PCGrab.LoopConnection = nil
    end
    Notify("AUTO GRAB (PC) OFF")
end

-- DROP
local DropState = { active = false, lastTime = 0, COOLDOWN = 1.0 }
local _dropBlockAutoPlay = false
local _wfConns = {}
local _wfActive = false

local function startWalkFling()
    _wfActive = true
    table.insert(_wfConns, RunService.Stepped:Connect(function()
        if not _wfActive then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                for _, part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end))
    local co = coroutine.create(function()
        while _wfActive do
            RunService.Heartbeat:Wait()
            local char = LP.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local vel = root.Velocity
                root.Velocity = vel * 10000 + Vector3.new(0, 10000, 0)
                RunService.RenderStepped:Wait()
                if root and root.Parent then root.Velocity = vel end
                RunService.Stepped:Wait()
                if root and root.Parent then root.Velocity = vel + Vector3.new(0, 0.1, 0) end
            else
                RunService.Heartbeat:Wait()
            end
        end
    end)
    coroutine.resume(co)
    table.insert(_wfConns, co)
end

local function stopWalkFling()
    _wfActive = false
    for _, c in ipairs(_wfConns) do
        if typeof(c) == "RBXScriptConnection" then c:Disconnect()
        elseif typeof(c) == "thread" then pcall(task.cancel, c) end
    end
    _wfConns = {}
end

local function executeDrop()
    local now = tick()
    if DropState.active then return end
    DropState.lastTime = now
    DropState.active = true
    _dropBlockAutoPlay = true
    task.spawn(function()
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local savedHealth
        if hum then
            savedHealth = hum.Health
            pcall(function() hum.Health = hum.MaxHealth end)
        end
        startWalkFling()
        task.wait(0.4)
        stopWalkFling()
        if hum and hum.Parent then
            pcall(function()
                if hum.Health < savedHealth then
                    hum.Health = math.max(savedHealth * 0.5, 1)
                end
            end)
        end
        DropState.active = false
        task.wait(1.0)
        _dropBlockAutoPlay = false
        Notify("DROP!")
    end)
end

-- ============================================
-- AUTO TP DOWN
-- ============================================
local TPSettings = {
    Enabled = true, TPHeight = 12.5, LastTPTime = 0, TP_COOLDOWN = 0.15,
    SavedLandingX = nil, SavedLandingZ = nil, WasAboveThreshold = false, MonitorConnection = nil,
}
local function getHRPTP()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function findEmptySpot(hrp)
    if not hrp then return nil end
    local startX = hrp.Position.X
    local startZ = hrp.Position.Z
    local startY = hrp.Position.Y
    for y = -50, startY + 5, 2 do
        local checkPos = Vector3.new(startX, y, startZ)
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {LP.Character}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(checkPos, Vector3.new(0, 0.5, 0), rayParams)
        if not result then
            local radiusCheck = workspace:Raycast(checkPos, Vector3.new(0.5, 0, 0), rayParams)
            if not radiusCheck then
                return checkPos.Y
            end
        end
    end
    return hrp.Position.Y - 10
end

local function getGroundPositionTP(hrp)
    if not hrp then return nil end
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LP.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(hrp.Position, Vector3.new(0, -200, 0), rayParams)
    if result then
        return result.Position.Y
    end
    return hrp.Position.Y - 10
end

local function TeleportToGround()
    local hrp = getHRPTP()
    if not hrp then return false end
    local now = tick()
    if now - TPSettings.LastTPTime < TPSettings.TP_COOLDOWN then return false end
    if TPSettings.SavedLandingX == nil or TPSettings.SavedLandingZ == nil then
        TPSettings.SavedLandingX = hrp.Position.X
        TPSettings.SavedLandingZ = hrp.Position.Z
    end
    local safeY = findEmptySpot(hrp)
    if not safeY then safeY = getGroundPositionTP(hrp) end
    if not safeY then return false end
    local targetPos = Vector3.new(TPSettings.SavedLandingX, safeY + 1.5, TPSettings.SavedLandingZ)
    TPSettings.LastTPTime = now
    local flash = Instance.new("Part")
    flash.Shape = Enum.PartType.Ball
    flash.Size = Vector3.new(1,1,1)
    flash.Position = hrp.Position
    flash.Anchored = true
    flash.CanCollide = false
    flash.Material = Enum.Material.Neon
    flash.Color = T.A
    flash.Transparency = 0.3
    flash.Parent = workspace
    TweenService:Create(flash, TweenInfo.new(0.15), {Size = Vector3.new(2,2,2), Transparency = 1}):Play()
    task.delay(0.2, function() pcall(function() flash:Destroy() end) end)
    pcall(function() hrp.CFrame = CFrame.new(targetPos) end)
    return true
end

local function StartTPMonitoring()
    if TPSettings.MonitorConnection then return end
    TPSettings.MonitorConnection = RunService.Heartbeat:Connect(function()
        if not TPSettings.Enabled then return end
        local hrp = getHRPTP()
        if not hrp then
            TPSettings.WasAboveThreshold = false
            return
        end
        local currentHeight = hrp.Position.Y
        local isAbove = currentHeight >= TPSettings.TPHeight
        if isAbove and not TPSettings.WasAboveThreshold then
            TPSettings.SavedLandingX = hrp.Position.X
            TPSettings.SavedLandingZ = hrp.Position.Z
            TPSettings.WasAboveThreshold = true
        end
        if isAbove then
            TeleportToGround()
        end
        if not isAbove and TPSettings.WasAboveThreshold then
            TPSettings.WasAboveThreshold = false
        end
    end)
end

local function StopTPMonitoring()
    if TPSettings.MonitorConnection then
        TPSettings.MonitorConnection:Disconnect()
        TPSettings.MonitorConnection = nil
    end
    TPSettings.WasAboveThreshold = false
end

function ToggleAutoTPDown()
    if TPSettings.Enabled then
        TPSettings.Enabled = false
        StopTPMonitoring()
        Notify("AUTO TP DOWN OFF")
        if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoTPDown then sideButtonRefreshOnly.AutoTPDown() end
    else
        TPSettings.Enabled = true
        StartTPMonitoring()
        Notify("AUTO TP DOWN ON")
        if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoTPDown then sideButtonRefreshOnly.AutoTPDown() end
    end
end

-- TP DOWN
local function ExecuteTPDown()
    task.spawn(function()
        pcall(function()
            local char = LP.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end

            local rayParams = RaycastParams.new()
            rayParams.FilterDescendantsInstances = {char}
            rayParams.FilterType = Enum.RaycastFilterType.Exclude

            local hit = workspace:Raycast(hrp.Position, Vector3.new(0, -600, 0), rayParams)
            if hit then
                local hipH = hum.HipHeight or 2
                local hrpHalfY = hrp.Size.Y / 2
                local finalY = hit.Position.Y + hipH + hrpHalfY + 0.1

                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                hrp.CFrame = CFrame.new(hit.Position.X, finalY, hit.Position.Z)
                hrp.AssemblyLinearVelocity = Vector3.zero
            end
        end)
    end)
    Notify("TP DOWN!")
end

-- ============================================
-- AUTO PLAY LEFT/RIGHT
-- ============================================
local AP_L1     = Vector3.new(-476,    -7,      93)
local AP_LEND   = Vector3.new(-485,    -4,      95)
local AP_LFINAL = Vector3.new(-475,    -7,      16)
local AP_R1     = Vector3.new(-476,    -7,      27)
local AP_REND   = Vector3.new(-485,    -4,      25)
local AP_RFINAL = Vector3.new(-476,    -7,      105)

AP_ROUTES = {
    SHORT_L1   = Vector3.new(-476, -6, 93),
    SHORT_LEND = Vector3.new(-485, -4, 95),
    SHORT_R1   = Vector3.new(-476, -6, 28),
    SHORT_REND = Vector3.new(-485, -4, 25),
    ShortEnabled = false,
}

local AP_RSPD = 30.46
local AP_ESPD = 30.46
local function getAPFSPD() return SpeedSettings.NormalSpeed end

local WP_PARTS = {}
local WP_META = { BLUE = Color3.fromRGB(255, 215, 60) }

local function createWPPart(name, pos, color)
    local old = workspace:FindFirstChild("H2N_WP_"..name)
    if old then old:Destroy() end
    local part = Instance.new("Part")
    part.Name = "H2N_WP_"..name
    part.Size = Vector3.new(0.8,0.8,0.8)
    part.Shape = Enum.PartType.Ball
    part.Position = pos
    part.Anchored = true
    part.CanCollide = false
    part.CanQuery = false
    part.CastShadow = false
    part.Material = Enum.Material.Neon
    part.Color = color
    part.Transparency = 0.15
    local light = Instance.new("PointLight", part)
    light.Color = color
    light.Range = 5
    light.Brightness = 2
    local bg = Instance.new("BillboardGui", part)
    bg.Size = UDim2.new(0,50,0,20)
    bg.StudsOffset = Vector3.new(0,1.2,0)
    bg.AlwaysOnTop = true
    bg.LightInfluence = 0
    local lbl = Instance.new("TextLabel", bg)
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundColor3 = Colors.AlmostBlack
    lbl.BackgroundTransparency = 0.4
    lbl.Text = name
    lbl.TextColor3 = Colors.DiscordBlue
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0,6)
    part.Parent = workspace
    WP_PARTS[name] = part
end

local function initWPParts()
    createWPPart("L1",    AP_L1,     WP_META.BLUE)
    createWPPart("LEND",  AP_LEND,   WP_META.BLUE)
    createWPPart("LFIN",  AP_LFINAL, WP_META.BLUE)
    createWPPart("R1",    AP_R1,     WP_META.BLUE)
    createWPPart("REND",  AP_REND,   WP_META.BLUE)
    createWPPart("RFIN",  AP_RFINAL, WP_META.BLUE)
end

local aplConn, aprConn = nil, nil
local aplPhase, aprPhase = 1, 1

local function getHRP2()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHum2()
    local char = LP.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function apMoveToward(h, hum, targetPos, speed)
    local d = Vector3.new(targetPos.X - h.Position.X, 0, targetPos.Z - h.Position.Z)
    if d.Magnitude < 1 then return true end
    local md = d.Unit
    if hum then hum:Move(md, false) end
    h.AssemblyLinearVelocity = Vector3.new(md.X * speed, h.AssemblyLinearVelocity.Y, md.Z * speed)
    return false
end

local function updateAutoPlayLeft()
    if not State.AutoPlayLeft then
        if aplConn then aplConn:Disconnect(); aplConn = nil end
        return
    end
    local h, hum = getHRP2(), getHum2()
    if not h then return end
    if AP_ROUTES.ShortEnabled then
        if aplPhase == 1 then
            if apMoveToward(h, hum, AP_ROUTES.SHORT_L1, getAPFSPD()) then aplPhase = 2 end
        elseif aplPhase == 2 then
            if apMoveToward(h, hum, AP_ROUTES.SHORT_LEND, getAPFSPD()) then
                State.AutoPlayLeft = false
                if aplConn then aplConn:Disconnect(); aplConn = nil end
                aplPhase = 1
                local h2 = getHRP2(); local hum2 = getHum2()
                if h2 then h2.AssemblyLinearVelocity = Vector3.new(0, h2.AssemblyLinearVelocity.Y, 0) end
                if hum2 then hum2:Move(Vector3.zero, false); hum2.AutoRotate = true end
                if Hum then Hum.AutoRotate = true end
                if speedBoostWasOnBeforeAutoPlay then speedBoostWasOnBeforeAutoPlay = false; startSpeedBoost() end
                Notify("AUTO PLAY LEFT OFF")
                if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoPlayLeft then sideButtonRefreshOnly.AutoPlayLeft() end
            end
        end
    else
        if aplPhase == 1 then
            if apMoveToward(h, hum, AP_L1, getAPFSPD()) then aplPhase = 2 end
        elseif aplPhase == 2 then
            if apMoveToward(h, hum, AP_LEND, getAPFSPD()) then aplPhase = 3 end
        elseif aplPhase == 3 then
            if apMoveToward(h, hum, AP_L1, AP_ESPD) then aplPhase = 4 end
        elseif aplPhase == 4 then
            if apMoveToward(h, hum, AP_LFINAL, AP_RSPD) then
                State.AutoPlayLeft = false
                if aplConn then aplConn:Disconnect(); aplConn = nil end
                aplPhase = 1
                local h2 = getHRP2(); local hum2 = getHum2()
                if h2 then h2.AssemblyLinearVelocity = Vector3.new(0, h2.AssemblyLinearVelocity.Y, 0) end
                if hum2 then hum2:Move(Vector3.zero, false); hum2.AutoRotate = true end
                if Hum then Hum.AutoRotate = true end
                if speedBoostWasOnBeforeAutoPlay then speedBoostWasOnBeforeAutoPlay = false; startSpeedBoost() end
                Notify("AUTO PLAY LEFT OFF")
                if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoPlayLeft then sideButtonRefreshOnly.AutoPlayLeft() end
            end
        end
    end
end

local function updateAutoPlayRight()
    if not State.AutoPlayRight then
        if aprConn then aprConn:Disconnect(); aprConn = nil end
        return
    end
    local h, hum = getHRP2(), getHum2()
    if not h then return end
    if AP_ROUTES.ShortEnabled then
        if aprPhase == 1 then
            if apMoveToward(h, hum, AP_ROUTES.SHORT_R1, getAPFSPD()) then aprPhase = 2 end
        elseif aprPhase == 2 then
            if apMoveToward(h, hum, AP_ROUTES.SHORT_REND, getAPFSPD()) then
                State.AutoPlayRight = false
                if aprConn then aprConn:Disconnect(); aprConn = nil end
                aprPhase = 1
                local h2 = getHRP2(); local hum2 = getHum2()
                if h2 then h2.AssemblyLinearVelocity = Vector3.new(0, h2.AssemblyLinearVelocity.Y, 0) end
                if hum2 then hum2:Move(Vector3.zero, false); hum2.AutoRotate = true end
                if Hum then Hum.AutoRotate = true end
                if speedBoostWasOnBeforeAutoPlay then speedBoostWasOnBeforeAutoPlay = false; startSpeedBoost() end
                Notify("AUTO PLAY RIGHT OFF")
                if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoPlayRight then sideButtonRefreshOnly.AutoPlayRight() end
            end
        end
    else
        if aprPhase == 1 then
            if apMoveToward(h, hum, AP_R1, getAPFSPD()) then aprPhase = 2 end
        elseif aprPhase == 2 then
            if apMoveToward(h, hum, AP_REND, getAPFSPD()) then aprPhase = 3 end
        elseif aprPhase == 3 then
            if apMoveToward(h, hum, AP_R1, AP_ESPD) then aprPhase = 4 end
        elseif aprPhase == 4 then
            if apMoveToward(h, hum, AP_RFINAL, AP_RSPD) then
                State.AutoPlayRight = false
                if aprConn then aprConn:Disconnect(); aprConn = nil end
                aprPhase = 1
                local h2 = getHRP2(); local hum2 = getHum2()
                if h2 then h2.AssemblyLinearVelocity = Vector3.new(0, h2.AssemblyLinearVelocity.Y, 0) end
                if hum2 then hum2:Move(Vector3.zero, false); hum2.AutoRotate = true end
                if Hum then Hum.AutoRotate = true end
                if speedBoostWasOnBeforeAutoPlay then speedBoostWasOnBeforeAutoPlay = false; startSpeedBoost() end
                Notify("AUTO PLAY RIGHT OFF")
                if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoPlayRight then sideButtonRefreshOnly.AutoPlayRight() end
            end
        end
    end
end

StopAutoPlayLeft = function()
    if not State.AutoPlayLeft then return end
    State.AutoPlayLeft = false
    if aplConn then aplConn:Disconnect(); aplConn = nil end
    aplPhase = 1
    local h = getHRP2(); local hum = getHum2()
    if h then h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0) end
    if hum then hum:Move(Vector3.zero, false); hum.AutoRotate = true end
    if Hum then Hum.AutoRotate = true end
    if not _switchingModes then
        if speedBoostWasOnBeforeAutoPlay then speedBoostWasOnBeforeAutoPlay = false; startSpeedBoost() end
    end
    Notify("AUTO PLAY LEFT OFF")
    if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoPlayLeft then sideButtonRefreshOnly.AutoPlayLeft() end
end

local function StartAutoPlayLeft()
    if State.AutoPlayLeft then return end
    if _dropBlockAutoPlay then Notify("AutoPlay blocked - DROP cooldown active"); return end
    if State.AutoPlayRight then
        StopAutoPlayRight()
        if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoPlayRight then sideButtonRefreshOnly.AutoPlayRight() end
    end
    speedBoostWasOnBeforeAutoPlay = isSpeedBoostEnabled
    if isSpeedBoostEnabled then stopSpeedBoost() end
    State.AutoPlayLeft = true
    aplPhase = 1
    if Hum then Hum.AutoRotate = false end
    if aplConn then aplConn:Disconnect() end
    aplConn = RunService.Heartbeat:Connect(updateAutoPlayLeft)
    Notify("AUTO PLAY LEFT ON")
    if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoPlayLeft then sideButtonRefreshOnly.AutoPlayLeft() end
end

StopAutoPlayRight = function()
    if not State.AutoPlayRight then return end
    State.AutoPlayRight = false
    if aprConn then aprConn:Disconnect(); aprConn = nil end
    aprPhase = 1
    local h = getHRP2(); local hum = getHum2()
    if h then h.AssemblyLinearVelocity = Vector3.new(0, h.AssemblyLinearVelocity.Y, 0) end
    if hum then hum:Move(Vector3.zero, false); hum.AutoRotate = true end
    if Hum then Hum.AutoRotate = true end
    if not _switchingModes then
        if speedBoostWasOnBeforeAutoPlay then speedBoostWasOnBeforeAutoPlay = false; startSpeedBoost() end
    end
    Notify("AUTO PLAY RIGHT OFF")
    if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoPlayRight then sideButtonRefreshOnly.AutoPlayRight() end
end

local function StartAutoPlayRight()
    if State.AutoPlayRight then return end
    if _dropBlockAutoPlay then Notify("AutoPlay blocked - DROP cooldown active"); return end
    if State.AutoPlayLeft then
        StopAutoPlayLeft()
        if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoPlayLeft then sideButtonRefreshOnly.AutoPlayLeft() end
    end
    speedBoostWasOnBeforeAutoPlay = isSpeedBoostEnabled
    if isSpeedBoostEnabled then stopSpeedBoost() end
    State.AutoPlayRight = true
    aprPhase = 1
    if Hum then Hum.AutoRotate = false end
    if aprConn then aprConn:Disconnect() end
    aprConn = RunService.Heartbeat:Connect(updateAutoPlayRight)
    Notify("AUTO PLAY RIGHT ON")
    if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoPlayRight then sideButtonRefreshOnly.AutoPlayRight() end
end

local function ToggleSpeedBoost()
    if isSpeedBoostEnabled then
        stopSpeedBoost()
        if sideButtonRefreshOnly and sideButtonRefreshOnly.SpeedBoost then sideButtonRefreshOnly.SpeedBoost() end
    else
        isSpeedBoostEnabled = false
        if speedConn then speedConn:Disconnect(); speedConn = nil end
        startSpeedBoost()
        if sideButtonRefreshOnly and sideButtonRefreshOnly.SpeedBoost then sideButtonRefreshOnly.SpeedBoost() end
    end
end

local function ToggleFloat()
    if State.FloatEnabled then
        stopFloat()
        if sideButtonRefreshOnly and sideButtonRefreshOnly.FloatEnabled then sideButtonRefreshOnly.FloatEnabled() end
    else
        startFloat()
        if sideButtonRefreshOnly and sideButtonRefreshOnly.FloatEnabled then sideButtonRefreshOnly.FloatEnabled() end
    end
end

-- ============================================
-- HIT CIRCLE
-- ============================================
local HitCircleState = { Enabled = false }
local _hitCircleData = { Conn = nil, Circle = nil, Align = nil, Attach = nil }

local function StartHitCircle()
    if HitCircleState.Enabled then return end
    HitCircleState.Enabled = true
    local char = LP.Character or LP.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    if _hitCircleData.Attach then pcall(function() _hitCircleData.Attach:Destroy() end) end
    if _hitCircleData.Align then pcall(function() _hitCircleData.Align:Destroy() end) end
    if _hitCircleData.Circle then pcall(function() _hitCircleData.Circle:Destroy() end) end
    _hitCircleData.Attach = Instance.new("Attachment", hrp)
    _hitCircleData.Align = Instance.new("AlignOrientation", hrp)
    _hitCircleData.Align.Attachment0 = _hitCircleData.Attach
    _hitCircleData.Align.Mode = Enum.OrientationAlignmentMode.OneAttachment
    _hitCircleData.Align.RigidityEnabled = true
    local circle = Instance.new("Part")
    circle.Shape = Enum.PartType.Cylinder
    circle.Material = Enum.Material.Neon
    circle.Size = Vector3.new(0.05, 14.5, 14.5)
    circle.Color = T.A
    circle.CanCollide = false
    circle.Massless = true
    circle.Parent = workspace
    local weld = Instance.new("Weld")
    weld.Part0 = hrp; weld.Part1 = circle
    weld.C0 = CFrame.new(0, -1, 0) * CFrame.Angles(0, 0, math.rad(90))
    weld.Parent = circle
    _hitCircleData.Circle = circle
    if _hitCircleData.Conn then _hitCircleData.Conn:Disconnect() end
    _hitCircleData.Conn = RunService.RenderStepped:Connect(function()
        if not HitCircleState.Enabled then return end
        local c = LP.Character if not c then return end
        local h = c:FindFirstChild("HumanoidRootPart") if not h then return end
        local target, dmin = nil, 7.25
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - h.Position).Magnitude
                if d <= dmin then target = p.Character.HumanoidRootPart; dmin = d end
            end
        end
        if target then
            c.Humanoid.AutoRotate = false
            _hitCircleData.Align.Enabled = true
            _hitCircleData.Align.CFrame = CFrame.lookAt(h.Position, Vector3.new(target.Position.X, h.Position.Y, target.Position.Z))
            local bat = c:FindFirstChild("Bat") or c:FindFirstChild("Medusa")
            if bat then pcall(function() bat:Activate() end) end
        else
            _hitCircleData.Align.Enabled = false
            if c.Humanoid then c.Humanoid.AutoRotate = true end
        end
    end)
    Notify("HIT CIRCLE ON")
end

local function StopHitCircle()
    if not HitCircleState.Enabled then return end
    HitCircleState.Enabled = false
    if _hitCircleData.Conn then _hitCircleData.Conn:Disconnect(); _hitCircleData.Conn = nil end
    if _hitCircleData.Circle then pcall(function() _hitCircleData.Circle:Destroy() end); _hitCircleData.Circle = nil end
    if _hitCircleData.Align then pcall(function() _hitCircleData.Align:Destroy() end); _hitCircleData.Align = nil end
    if _hitCircleData.Attach then pcall(function() _hitCircleData.Attach:Destroy() end); _hitCircleData.Attach = nil end
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.AutoRotate = true end
    Notify("HIT CIRCLE OFF")
end

function ToggleHitCircle()
    if HitCircleState.Enabled then
        StopHitCircle()
    else
        StartHitCircle()
    end
end

local SlapList = {
    "Bat", "Slap", "Iron Slap", "Gold Slap", "Diamond Slap", "Emerald Slap",
    "Ruby Slap", "Dark Matter Slap", "Flame Slap", "Nuclear Slap", "Galaxy Slap", "Glitched Slap",
    "y", "z", "x"
}

-- ============================================
-- SPAM BAT
-- ============================================
local SpamBatState = { conn = nil, lastSwing = 0, COOLDOWN = 0.12, enabled = false }

local function _findBat()
    local c = LP.Character if not c then return nil end
    local bp = LP:FindFirstChildOfClass("Backpack")
    for _, ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end
    if bp then for _, ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    for _, name in ipairs(SlapList) do
        local t = c:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
        if t then return t end
    end
    return nil
end
local _findBatForSpam = _findBat

local function StartSpamBat()
    if SpamBatState.enabled then return end
    SpamBatState.enabled = true
    if SpamBatState.conn then SpamBatState.conn:Disconnect() end
    SpamBatState.conn = RunService.Heartbeat:Connect(function()
        if not SpamBatState.enabled then return end
        local c = LP.Character if not c then return end
        local bat = _findBatForSpam() if not bat then return end
        if bat.Parent ~= c then
            local hum = c:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum:EquipTool(bat) end) end
        end
        local now = tick()
        if now - SpamBatState.lastSwing < SpamBatState.COOLDOWN then return end
        SpamBatState.lastSwing = now
        pcall(function() bat:Activate() end)
    end)
    Notify("SPAM BAT ON")
end

local function StopSpamBat()
    if not SpamBatState.enabled then return end
    SpamBatState.enabled = false
    if SpamBatState.conn then SpamBatState.conn:Disconnect(); SpamBatState.conn = nil end
    Notify("SPAM BAT OFF")
end

function ToggleSpamBat()
    if SpamBatState.enabled then
        StopSpamBat()
    else
        StartSpamBat()
    end
end

-- ============================================
-- BAT AIMBOT
-- ============================================
local BatAimbotState = {
    conn = nil,
    enabled = false,
    lockedTarget = nil,
}
local BAT_AIMBOT_SPEED   = 60
local BAT_MELEE_OFFSET   = 3
local BAT_MAX_DISTANCE   = math.huge

local batAimbotHighlight = Instance.new("Highlight")
batAimbotHighlight.Name = "H2NBatAimbotESP"
batAimbotHighlight.FillColor = T.A
batAimbotHighlight.OutlineColor = T.D
batAimbotHighlight.FillTransparency = 0.5
batAimbotHighlight.OutlineTransparency = 0
local _hlOk = pcall(function() batAimbotHighlight.Parent = game:GetService("CoreGui") end)
if not _hlOk then batAimbotHighlight.Parent = LP:WaitForChild("PlayerGui") end

local function _isBatTargetValid(tc)
    if not tc then return false end
    local hum = tc:FindFirstChildOfClass("Humanoid")
    local hrp = tc:FindFirstChild("HumanoidRootPart")
    local ff  = tc:FindFirstChildOfClass("ForceField")
    return hum and hrp and hum.Health > 0 and not ff
end

local function _getBatTarget(myHRP)
    if BatAimbotState.lockedTarget and _isBatTargetValid(BatAimbotState.lockedTarget) then
        return BatAimbotState.lockedTarget:FindFirstChild("HumanoidRootPart"), BatAimbotState.lockedTarget
    end
    local best, bestHRP, bestDist = nil, nil, BAT_MAX_DISTANCE
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and _isBatTargetValid(p.Character) then
            local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
            local dist = (tHRP.Position - myHRP.Position).Magnitude
            if dist < bestDist then bestDist = dist; bestHRP = tHRP; best = p.Character end
        end
    end
    BatAimbotState.lockedTarget = best
    return bestHRP, best
end

local function StartBatAimbot()
    if BatAimbotState.conn then return end
    BatAimbotState.enabled = true
    local c = LP.Character if not c then return end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.AutoRotate = false
    local att = hrp:FindFirstChild("H2NAimbotAtt") or Instance.new("Attachment", hrp)
    att.Name = "H2NAimbotAtt"
    local align = hrp:FindFirstChild("H2NAimbotAlign") or Instance.new("AlignOrientation", hrp)
    align.Name = "H2NAimbotAlign"
    align.Mode = Enum.OrientationAlignmentMode.OneAttachment
    align.Attachment0 = att
    align.MaxTorque = math.huge
    align.Responsiveness = 200
    BatAimbotState.conn = RunService.Heartbeat:Connect(function()
        if not BatAimbotState.enabled then return end
        local char = LP.Character if not char then return end
        local curHRP = char:FindFirstChild("HumanoidRootPart") if not curHRP then return end
        local curHum = char:FindFirstChildOfClass("Humanoid") if not curHum then return end
        local bat = _findBat()
        if bat and bat.Parent ~= char then pcall(function() curHum:EquipTool(bat) end) end
        local tHRP, tChar = _getBatTarget(curHRP)
        if tHRP and tChar then
            batAimbotHighlight.Adornee = tChar
            local tVel = tHRP.AssemblyLinearVelocity
            local speed = tVel.Magnitude
            local predTime = math.clamp(speed / 150, 0.05, 0.2)
            local predPos = tHRP.Position + (tVel * predTime)
            local dir = (predPos - curHRP.Position)
            local dist3D = dir.Magnitude
            local standPos = predPos
            if dist3D > 0 then standPos = predPos - (dir.Unit * BAT_MELEE_OFFSET) end
            align.CFrame = CFrame.lookAt(curHRP.Position, predPos)
            local moveDir = (standPos - curHRP.Position)
            if moveDir.Magnitude > 1 then
                curHRP.AssemblyLinearVelocity = moveDir.Unit * BAT_AIMBOT_SPEED
            else
                curHRP.AssemblyLinearVelocity = tVel
            end
            pcall(function() if bat and bat.Parent == char then bat:Activate() end end)
        else
            BatAimbotState.lockedTarget = nil
            curHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            batAimbotHighlight.Adornee = nil
        end
    end)
    Notify("AUTO BAT ON")
end

local function StopBatAimbot()
    if not BatAimbotState.enabled then return end
    BatAimbotState.enabled = false
    if BatAimbotState.conn then BatAimbotState.conn:Disconnect(); BatAimbotState.conn = nil end
    local c = LP.Character
    local h = c and c:FindFirstChild("HumanoidRootPart")
    local hum = c and c:FindFirstChildOfClass("Humanoid")
    if h then
        local att = h:FindFirstChild("H2NAimbotAtt") if att then att:Destroy() end
        local al  = h:FindFirstChild("H2NAimbotAlign") if al then al:Destroy() end
        h.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    end
    if hum then hum.AutoRotate = true end
    BatAimbotState.lockedTarget = nil
    batAimbotHighlight.Adornee = nil
    Notify("AUTO BAT OFF")
end

LP.CharacterAdded:Connect(function()
    if BatAimbotState.enabled then
        if BatAimbotState.conn then BatAimbotState.conn:Disconnect(); BatAimbotState.conn = nil end
        task.wait(0.5)
        StartBatAimbot()
    end
end)

-- ============================================
-- OPTIMIZER
-- ============================================
local function startOptimizer()
    if State.Optimizer then return end
    State.Optimizer = true
    AntiLagEnabled = true
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").Brightness = 3
    end)
    pcall(function()
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                    obj:Destroy()
                elseif obj:IsA("BasePart") then
                    obj.CastShadow = false
                    obj.Material = Enum.Material.Plastic
                end
            end)
        end
    end)
    pcall(function()
        for _, sg in ipairs({game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()}) do
            if sg:IsA("UIStroke") then
                sg.Color = Color3.fromRGB(255, 215, 100)
                sg.Thickness = 1.5
                local grad = sg:FindFirstChildOfClass("UIGradient")
                if grad then grad.Rotation = 45 end
            end
        end
    end)
    Notify("ANTI LAG ON")
end

local function stopOptimizer()
    if not State.Optimizer then return end
    State.Optimizer = false
    AntiLagEnabled = false
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level08
        game:GetService("Lighting").GlobalShadows = true
        game:GetService("Lighting").Brightness = 2
    end)
    Notify("ANTI LAG OFF")
end

function ToggleOptimizer()
    if State.Optimizer then
        stopOptimizer()
    else
        startOptimizer()
    end
end

-- ============================================
-- XRAY BASE
-- ============================================
local baseOT = {}; local plotConns = {}; local xrayCon = nil
local XRAY_TRANSPARENCY = 0.68

local function applyXray(plot)
    if baseOT[plot] then return end; baseOT[plot] = {}
    for _, p in ipairs(plot:GetDescendants()) do
        if p:IsA("BasePart") and p.Transparency < 0.6 then baseOT[plot][p] = p.Transparency; p.Transparency = XRAY_TRANSPARENCY end
    end
    plotConns[plot] = plot.DescendantAdded:Connect(function(d)
        if d:IsA("BasePart") and d.Transparency < 0.6 then baseOT[plot][d] = d.Transparency; d.Transparency = XRAY_TRANSPARENCY end
    end)
end

local function StartXrayBase()
    if State.XrayBase then return end
    State.XrayBase = true
    local plots = workspace:FindFirstChild("Plots"); if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do applyXray(plot) end
    xrayCon = plots.ChildAdded:Connect(function(p) task.wait(0.2); applyXray(p) end)
    Notify("XRAY BASE ON")
end

local function StopXrayBase()
    if not State.XrayBase then return end
    State.XrayBase = false
    for _, conn in pairs(plotConns) do conn:Disconnect() end; plotConns = {}
    if xrayCon then xrayCon:Disconnect(); xrayCon = nil end
    for _, parts in pairs(baseOT) do
        for part, orig in pairs(parts) do if part and part.Parent then part.Transparency = orig end end
    end
    baseOT = {}
    Notify("XRAY BASE OFF")
end

function ToggleXrayBase()
    if State.XrayBase then
        StopXrayBase()
    else
        StartXrayBase()
    end
end

-- ============================================
-- ESP
-- ============================================
ESPState = { hl = {} }
local function ClearESP() for _, h in pairs(ESPState.hl) do if h and h.Parent then h:Destroy() end end; ESPState.hl = {} end
local function StartESP()
    if State.ESP then return end
    State.ESP = true; Notify("ESP ON")
end
local function StopESP()
    if not State.ESP then return end
    State.ESP = false; ClearESP(); Notify("ESP OFF")
end
local function updateESP()
    if not State.ESP then return end
    for player, h in pairs(ESPState.hl) do
        if not player or not player.Character then if h and h.Parent then h:Destroy() end; ESPState.hl[player] = nil end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and (not ESPState.hl[p] or not ESPState.hl[p].Parent) then
            local h = Instance.new("Highlight")
            h.FillColor = Colors.DarkGray; h.OutlineColor = Colors.White
            h.FillTransparency = 0.5; h.OutlineTransparency = 0; h.Adornee = p.Character; h.Parent = p.Character
            ESPState.hl[p] = h
        end
    end
end

function ToggleESP()
    if State.ESP then
        StopESP()
    else
        StartESP()
    end
end

-- ============================================
-- ANTI SENTRY
-- ============================================
SentryState = { target = nil, DETECT_DIST = 60, PULL_DIST = -5 }
local function findSentryTarget()
    local char = LP.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local rootPos = char.HumanoidRootPart.Position
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:find("Sentry") and not obj.Name:lower():find("bullet") then
            local part = (obj:IsA("BasePart") and obj) or (obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")))
            if part and (rootPos - part.Position).Magnitude <= SentryState.DETECT_DIST then return obj end
        end
    end
end
local function moveSentry(obj)
    local char = LP.Character; if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    for _, p in pairs(obj:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
    local root = char.HumanoidRootPart; local cf = root.CFrame * CFrame.new(0,0,SentryState.PULL_DIST)
    if obj:IsA("BasePart") then obj.CFrame = cf
    elseif obj:IsA("Model") then local m = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart"); if m then m.CFrame = cf end end
end
local function getWeapon() return LP.Backpack:FindFirstChild("Bat") or (LP.Character and LP.Character:FindFirstChild("Bat")) end
local function attackSentry()
    local char = LP.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local weapon = getWeapon(); if not weapon then return end
    if weapon.Parent == LP.Backpack then hum:EquipTool(weapon); task.wait(0.1) end
    pcall(function() weapon:Activate() end)
    for _, r in pairs(weapon:GetDescendants()) do if r:IsA("RemoteEvent") then pcall(function() r:FireServer() end) end end
end
local function StartAntiSentry() if State.AntiSentry then return end; State.AntiSentry = true; Notify("ANTI SENTRY ON") end
local function StopAntiSentry() if not State.AntiSentry then return end; State.AntiSentry = false; SentryState.target = nil; Notify("ANTI SENTRY OFF") end
local function updateAntiSentry() if not State.AntiSentry then return end; if SentryState.target and SentryState.target.Parent == workspace then moveSentry(SentryState.target); attackSentry() else SentryState.target = findSentryTarget() end end

function ToggleAntiSentry()
    if State.AntiSentry then
        StopAntiSentry()
    else
        StartAntiSentry()
    end
end

-- ============================================
-- SPIN BODY
-- ============================================
SpinState = { force = nil, SPEED = 25 }
local function StartSpinBody()
    if State.SpinBody then return end
    State.SpinBody = true
    local char = LP.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root or SpinState.force then return end
    SpinState.force = Instance.new("BodyAngularVelocity")
    SpinState.force.Name = "SpinForce"; SpinState.force.AngularVelocity = Vector3.new(0,SpinState.SPEED,0)
    SpinState.force.MaxTorque = Vector3.new(0,math.huge,0); SpinState.force.P = 1250; SpinState.force.Parent = root
    Notify("SPIN BODY ON")
end
local function StopSpinBody()
    if not State.SpinBody then return end
    State.SpinBody = false; if SpinState.force then SpinState.force:Destroy(); SpinState.force = nil end
    Notify("SPIN BODY OFF")
end

function ToggleSpinBody()
    if State.SpinBody then
        StopSpinBody()
    else
        StartSpinBody()
    end
end

-- ============================================
-- ANTI RAGDOLL
-- ============================================
ARState = { conn = nil, recoveryActive = false, recoveryTimer = nil }

local function forceRecoverFromRagdoll(hum, root)
    if not hum or not root then return end
    if ARState.recoveryTimer then task.cancel(ARState.recoveryTimer) end
    ARState.recoveryActive = true
    local char = hum.Parent
    if char then
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and obj.Enabled == false then obj.Enabled = true end
        end
    end
    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.Running)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end)
    if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = hum end
    pcall(function()
        local PlayerModule = LP.PlayerScripts:FindFirstChild("PlayerModule")
        if PlayerModule then
            local Controls = require(PlayerModule:FindFirstChild("ControlModule"))
            Controls:Enable()
        end
    end)
    ARState.recoveryTimer = task.delay(0.3, function() ARState.recoveryActive = false end)
end

local function StartAntiRagdoll()
    if State.AntiRagdoll then return end
    State.AntiRagdoll = true
    if ARState.conn then ARState.conn:Disconnect() end
    ARState.conn = RunService.Heartbeat:Connect(function()
        if not State.AntiRagdoll then return end
        local char = LP.Character if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end
        if hum.Health <= 0 then return end
        if ARState.recoveryActive then return end
        local state = hum:GetState()
        local isRagdolled = (state == Enum.HumanoidStateType.Physics or state == Enum.HumanoidStateType.Ragdoll or state == Enum.HumanoidStateType.FallingDown or state == Enum.HumanoidStateType.GettingUp or state == Enum.HumanoidStateType.Stunned)
        local hasBrokenJoints = false
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and obj.Enabled == false then hasBrokenJoints = true; break end
        end
        local angularVel = root.AssemblyAngularVelocity
        local isSpinning = math.abs(angularVel.Y) > 15
        if isRagdolled or hasBrokenJoints or isSpinning then forceRecoverFromRagdoll(hum, root) end
    end)
    Notify("ANTI RAGDOLL ON")
end

local function StopAntiRagdoll()
    if not State.AntiRagdoll then return end
    State.AntiRagdoll = false
    if ARState.conn then ARState.conn:Disconnect(); ARState.conn = nil end
    ARState.recoveryActive = false
    if ARState.recoveryTimer then task.cancel(ARState.recoveryTimer) end
    Notify("ANTI RAGDOLL OFF")
end

function ToggleAntiRagdoll()
    if State.AntiRagdoll then
        StopAntiRagdoll()
    else
        StartAntiRagdoll()
    end
end

-- ============================================
-- INFINITE JUMP
-- ============================================
JumpState = { conn = nil, fallConn = nil }
local INF_JUMP_FORCE = 54
local CLAMP_FALL = 80

local function StartInfiniteJump()
    if State.InfiniteJump then return end
    State.InfiniteJump = true
    if JumpState.conn then JumpState.conn:Disconnect(); JumpState.conn = nil end
    if JumpState.fallConn then JumpState.fallConn:Disconnect(); JumpState.fallConn = nil end
    JumpState.conn = UIS.JumpRequest:Connect(function()
        if not State.InfiniteJump then return end
        local h = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not h then return end
        h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, INF_JUMP_FORCE, h.AssemblyLinearVelocity.Z)
    end)
    JumpState.fallConn = RunService.Heartbeat:Connect(function()
        if not State.InfiniteJump then return end
        local h = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not h then return end
        if h.AssemblyLinearVelocity.Y < -CLAMP_FALL then
            h.AssemblyLinearVelocity = Vector3.new(h.AssemblyLinearVelocity.X, -CLAMP_FALL, h.AssemblyLinearVelocity.Z)
        end
    end)
    Notify("INFINITE JUMP ON")
end

local function StopInfiniteJump()
    State.InfiniteJump = false
    if JumpState.conn then JumpState.conn:Disconnect(); JumpState.conn = nil end
    if JumpState.fallConn then JumpState.fallConn:Disconnect(); JumpState.fallConn = nil end
    Notify("INFINITE JUMP OFF")
end

function ToggleInfiniteJump()
    if State.InfiniteJump then
        StopInfiniteJump()
    else
        StartInfiniteJump()
    end
end

-- ============================================
-- ANTI DIE
-- ============================================
AntiDieState = { conn = nil }
local function startPermanentAntiDie()
    if AntiDieState.conn then AntiDieState.conn:Disconnect() end
    AntiDieState.conn = RunService.Heartbeat:Connect(function()
        if not Hum or not Hum.Parent then return end
        if Hum.Health <= 0 then pcall(function() Hum.Health = Hum.MaxHealth * 0.9 end) end
        pcall(function() Hum.RequiresNeck = false end)
        if HRP and HRP.Position.Y < -10 then HRP.CFrame = CFrame.new(HRP.Position.X, -4, HRP.Position.Z) end
    end)
end
task.spawn(function() task.wait(0.5); startPermanentAntiDie() end)

-- ============================================
-- UNWALK
-- ============================================
UnwalkState = { active = false, animConn = nil }

local function stopAnimationsOnly(model)
    if not model then return end
    local humanoid = model:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        local animator = humanoid:FindFirstChild("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop() end
        end
    end
    for _, descendant in pairs(model:GetDescendants()) do
        if descendant:IsA("AnimationTrack") then descendant:Stop() end
    end
end

local function startUnwalk()
    if UnwalkState.active then return end
    if UnwalkState.animConn then UnwalkState.animConn:Disconnect() end
    UnwalkState.animConn = RunService.RenderStepped:Connect(function()
        if not UnwalkState.active then return end
        local char = LP.Character
        if char then
            stopAnimationsOnly(char)
            for _, tool in pairs(char:GetChildren()) do if tool:IsA("Tool") then stopAnimationsOnly(tool) end end
        end
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LP and player.Character then stopAnimationsOnly(player.Character) end
        end
    end)
    UnwalkState.active = true
    Notify("UNWALK ON")
end

local function stopUnwalk()
    if not UnwalkState.active then return end
    if UnwalkState.animConn then UnwalkState.animConn:Disconnect(); UnwalkState.animConn = nil end
    UnwalkState.active = false
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            local animateScript = player.Character:FindFirstChild("Animate")
            if animateScript and animateScript:IsA("LocalScript") then
                animateScript.Disabled = true
                task.wait(0.1)
                animateScript.Disabled = false
            end
        end
    end
    Notify("UNWALK OFF")
end

function ToggleUnwalk()
    if UnwalkState.active then
        stopUnwalk()
    else
        startUnwalk()
    end
end

-- ============================================
-- DAMAGE TRACKING
-- ============================================
DmgState = { conn = nil, cooldown = false, lastHealth = nil, cooldownTimer = nil, COOLDOWN = 2.8 }

local function stopFeaturesOnDamage()
    if DmgState.cooldown then return end
    DmgState.cooldown = true
    _switchingModes = true
    if State.AutoPlayLeft then StopAutoPlayLeft() end
    if State.AutoPlayRight then StopAutoPlayRight() end
    _switchingModes = false
    if State.FloatEnabled then stopFloat() end
    if DmgState.cooldownTimer then pcall(function() task.cancel(DmgState.cooldownTimer) end) end
    DmgState.cooldownTimer = task.delay(DmgState.COOLDOWN, function() DmgState.cooldown = false end)
end

local function setupDamageTracking()
    if DmgState.conn then DmgState.conn:Disconnect(); DmgState.conn = nil end
    local char = LP.Character if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid") if not hum then return end
    DmgState.lastHealth = hum.Health
    DmgState.conn = RunService.Heartbeat:Connect(function()
        if not LP.Character or not hum or hum.Parent ~= LP.Character then
            if DmgState.conn then DmgState.conn:Disconnect(); DmgState.conn = nil end
            return
        end
        local currentHealth = hum.Health
        if DmgState.lastHealth and currentHealth < DmgState.lastHealth - 0.5 and hum.Health > 0 then
            if not DmgState.cooldown then stopFeaturesOnDamage() end
        end
        local currentState = hum:GetState()
        if currentState == Enum.HumanoidStateType.Physics or currentState == Enum.HumanoidStateType.Ragdoll or currentState == Enum.HumanoidStateType.FallingDown then
            if not DmgState.cooldown then stopFeaturesOnDamage() end
        end
        if currentHealth > 0 then DmgState.lastHealth = currentHealth end
    end)
end

LP.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    DmgState.cooldown = false
    DmgState.lastHealth = nil
    if DmgState.cooldownTimer then pcall(function() task.cancel(DmgState.cooldownTimer) end) end
    setupDamageTracking()
    if UnwalkState.active then stopAnimationsOnly(char) end
    if HitCircleState.Enabled then HitCircleState.Enabled = false; task.wait(0.5); StartHitCircle() end
end)

-- ============================================
-- KEYBINDS
-- ============================================
Keys = {
    TPDown = Enum.KeyCode.J, AutoPlayLeft = Enum.KeyCode.G, AutoPlayRight = Enum.KeyCode.H,
    AntiRagdoll = Enum.KeyCode.K, Float = Enum.KeyCode.F, SpeedBoost = Enum.KeyCode.B,
    Unwalk = Enum.KeyCode.U, AutoTPDown = Enum.KeyCode.T, Desync = Enum.KeyCode.L,
}
KeyEnabled = {
    TPDown = true, AutoPlayLeft = true, AutoPlayRight = true, AntiRagdoll = true,
    Float = true, SpeedBoost = true, Unwalk = true, AutoTPDown = true, Desync = true,
}

UIS.InputBegan:Connect(function(input, gpe)
    if gpe or input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    local k = input.KeyCode
    if KeyEnabled.TPDown and k == Keys.TPDown then
        ExecuteTPDown()
    elseif KeyEnabled.AutoPlayLeft and k == Keys.AutoPlayLeft then
        if State.AutoPlayLeft then StopAutoPlayLeft() else StartAutoPlayLeft() end
    elseif KeyEnabled.AutoPlayRight and k == Keys.AutoPlayRight then
        if State.AutoPlayRight then StopAutoPlayRight() else StartAutoPlayRight() end
    elseif KeyEnabled.AntiRagdoll and k == Keys.AntiRagdoll then
        ToggleAntiRagdoll()
    elseif KeyEnabled.Float and k == Keys.Float then
        ToggleFloat()
    elseif KeyEnabled.SpeedBoost and k == Keys.SpeedBoost then
        ToggleSpeedBoost()
    elseif KeyEnabled.AutoTPDown and k == Keys.AutoTPDown then
        ToggleAutoTPDown()
    elseif KeyEnabled.Unwalk and k == Keys.Unwalk then
        ToggleUnwalk()
    elseif KeyEnabled.Desync and k == Keys.Desync then
        ToggleDesync()
    end
end)

discordLink = "discord.gg/wsUuRQYVB"

-- ============================================
-- GUI (نفس الأصل مع إضافة زر DESYNC)
-- ============================================
gui = Instance.new("ScreenGui")
gui.Name = "H2N"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.Parent = LP:WaitForChild("PlayerGui")

-- INFO BAR
do
    local infoSG = Instance.new("ScreenGui", LP:WaitForChild("PlayerGui"))
    infoSG.Name = "H2N_InfoBar"
    infoSG.ResetOnSpawn = false
    infoSG.ZIndexBehavior = Enum.ZIndexBehavior.Global
    infoSG.DisplayOrder = 998

    local bar = Instance.new("Frame", infoSG)
    bar.Size = UDim2.new(0, 220, 0, 32)
    bar.Position = UDim2.new(0.5, -110, 0, -4)
    bar.BackgroundColor3 = T.Bg1
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 10)

    local barStroke = applySpinningGoldStroke(bar, 1.8, 1.2)
    local titleLbl = Instance.new("TextLabel", bar)
    titleLbl.Size = UDim2.new(1, 0, 1, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "H2N"
    titleLbl.TextColor3 = T.Tx
    titleLbl.Font = Enum.Font.GothamBlack
    titleLbl.TextSize = 16
    titleLbl.TextXAlignment = Enum.TextXAlignment.Center
    titleLbl.TextYAlignment = Enum.TextYAlignment.Center
    titleLbl.ZIndex = 2

    local fpsLbl = Instance.new("TextLabel", bar)
    fpsLbl.Size = UDim2.new(0, 46, 0, 12)
    fpsLbl.Position = UDim2.new(0, 6, 1, -14)
    fpsLbl.BackgroundTransparency = 1
    fpsLbl.Text = "FPS:--"
    fpsLbl.TextColor3 = T.TxS
    fpsLbl.Font = Enum.Font.GothamBold
    fpsLbl.TextSize = 10
    fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
    fpsLbl.ZIndex = 2

    local discLbl = Instance.new("TextLabel", bar)
    discLbl.Size = UDim2.new(0, 108, 0, 12)
    discLbl.Position = UDim2.new(1, -113, 1, -14)
    discLbl.BackgroundTransparency = 1
    discLbl.Text = "discord.gg/wsUuRQYVB"
    discLbl.TextColor3 = T.TxD
    discLbl.Font = Enum.Font.GothamBold
    discLbl.TextSize = 9
    discLbl.TextXAlignment = Enum.TextXAlignment.Right
    discLbl.ZIndex = 2

    local fpsAcum, fpsFrames, fpsTimer = 0, 0, 0
    RunService.RenderStepped:Connect(function(dt)
        if dt <= 0 then return end
        fpsAcum = fpsAcum + (1/dt)
        fpsFrames = fpsFrames + 1
        fpsTimer = fpsTimer + dt
        if fpsTimer >= 0.5 then
            fpsLbl.Text = "FPS:" .. math.floor(fpsAcum / fpsFrames)
            fpsAcum = 0; fpsFrames = 0; fpsTimer = 0
        end
    end)

    task.spawn(function()
        local t = 0
        while bar and bar.Parent do
            t = t + 0.05
            if not AntiLagEnabled then
                local g = 0.5 + 0.5 * math.sin(t * 2)
                barStroke.Color = Color3.fromRGB(math.floor(220 + g*35), math.floor(165 + g*70), math.floor(20 + g*40))
            end
            task.wait(0.12)
        end
    end)
end

task.spawn(function()
    task.wait(0.1)
    for _, msg in ipairs(_notifyQueue) do
        Notify(msg)
        task.wait(0.3)
    end
    _notifyQueue = {}
end)

local SideButtonSize = 32
local SideButtonWidth = 120
local SideButtonShape = "rect"
local menuW, menuH = 350, 350
local StealBarVisible = true
local ButtonPositions = {}
local sideHiddenMap = {}
local menu = nil
local numberBoxReferences = {}
local toggleUpdaters = {}
local sideButtonRefs = {}
local sideButtonVisibility = {}
local sideButtonRefreshOnly = {}

local CFG = "H2N_Config.json"

local function Save()
    local menuPos = {X=0.5, XO=0, Y=0.52, YO=0}
    if menu then
        menuPos = {
            X = menu.Position.X.Scale, XO = menu.Position.X.Offset,
            Y = menu.Position.Y.Scale, YO = menu.Position.Y.Offset,
        }
    end
    local stealBarPos = {X=0.5, XO=-170, Y=1, YO=-55}
    if stealBarFrame and stealBarFrame.Parent then
        stealBarPos = {
            X = stealBarFrame.Position.X.Scale, XO = stealBarFrame.Position.X.Offset,
            Y = stealBarFrame.Position.Y.Scale, YO = stealBarFrame.Position.Y.Offset,
        }
    end
    local data = {
        SideButtonSize = SideButtonSize, SideButtonWidth = SideButtonWidth, SideButtonShape = SideButtonShape, menuW = menuW, menuH = menuH,
        menuPos = menuPos, stealBarPos = stealBarPos,
        NormalSpeed = SpeedSettings.NormalSpeed, StealSpeed = SpeedSettings.StealSpeed,
        EnhancedGrab = { Radius = EnhancedGrab.Radius, Enabled = EnhancedGrab.Enabled },
        PCGrab = { Radius = PCGrab.Radius, Speed = PCGrab.Speed, Enabled = PCGrab.Enabled },
        Keys = {
            TPDown = Keys.TPDown.Name, AutoPlayLeft = Keys.AutoPlayLeft.Name,
            AutoPlayRight = Keys.AutoPlayRight.Name, AntiRagdoll = Keys.AntiRagdoll.Name,
            Float = Keys.Float.Name, SpeedBoost = Keys.SpeedBoost.Name,
            Unwalk = Keys.Unwalk.Name, AutoTPDown = Keys.AutoTPDown.Name,
            Desync = Keys.Desync.Name,
        },
        KeyEnabled = {
            TPDown = KeyEnabled.TPDown, AutoPlayLeft = KeyEnabled.AutoPlayLeft,
            AutoPlayRight = KeyEnabled.AutoPlayRight, AntiRagdoll = KeyEnabled.AntiRagdoll,
            Float = KeyEnabled.Float, SpeedBoost = KeyEnabled.SpeedBoost,
            Unwalk = KeyEnabled.Unwalk, AutoTPDown = KeyEnabled.AutoTPDown,
            Desync = KeyEnabled.Desync,
        },
        ST_AntiSentry = State.AntiSentry, ST_SpinBody = State.SpinBody,
        ST_AntiRagdoll = State.AntiRagdoll, ST_InfiniteJump = State.InfiniteJump,
        ST_FloatEnabled = State.FloatEnabled, ST_XrayBase = State.XrayBase,
        ST_ESP = State.ESP, ST_SpeedBoost = isSpeedBoostEnabled,
        ST_Optimizer = State.Optimizer,
        ST_Unwalk = UnwalkState.active,
        ST_HitCircle = HitCircleState.Enabled,
        ST_SpamBat = SpamBatState.enabled,
        ST_BatAimbot = BatAimbotState.enabled,
        ST_BatAimbotSpeed = BAT_AIMBOT_SPEED,
        StealBarVisible = StealBarVisible, sideHiddenMap = sideHiddenMap,
        sideButtonVisibility = sideButtonVisibility,
        ButtonPositions = ButtonPositions,
        TPSettings = { Enabled = TPSettings.Enabled, TPHeight = TPSettings.TPHeight },
        FloatRiseHeight = FLOAT_RISE_HEIGHT,
        ShortRouteEnabled = AP_ROUTES.ShortEnabled,
        DesyncEnabled = DesyncState.enabled,
    }
    SafeWriteFile(CFG, HttpService:JSONEncode(data))
end

local function Load()
    local raw = SafeReadFile(CFG)
    if not raw or raw == "" then return end
    local ok2, d = pcall(function() return HttpService:JSONDecode(raw) end)
    if not ok2 or type(d) ~= "table" then return end
    if d.SideButtonSize then SideButtonSize = d.SideButtonSize end
    if d.SideButtonWidth then SideButtonWidth = d.SideButtonWidth end
    if d.SideButtonShape then SideButtonShape = d.SideButtonShape end
    if d.menuW then menuW = d.menuW end
    if d.menuH then menuH = d.menuH end
    if d.NormalSpeed then SpeedSettings.NormalSpeed = d.NormalSpeed end
    if d.StealSpeed then SpeedSettings.StealSpeed = d.StealSpeed end
    if d.EnhancedGrab then
        if d.EnhancedGrab.Radius then EnhancedGrab.Radius = math.clamp(d.EnhancedGrab.Radius, 1, 100) end
        if d.EnhancedGrab.Enabled ~= nil then EnhancedGrab.Enabled = d.EnhancedGrab.Enabled end
    end
    if d.PCGrab then
        if d.PCGrab.Radius then PCGrab.Radius = math.clamp(d.PCGrab.Radius, 1, 100) end
        if d.PCGrab.Speed then PCGrab.Speed = math.clamp(d.PCGrab.Speed, 0.05, 5) end
        if d.PCGrab.Enabled ~= nil then PCGrab.Enabled = d.PCGrab.Enabled end
    end
    if type(d.Keys) == "table" then
        for k, v in pairs(d.Keys) do
            local e = Enum.KeyCode[v]
            if e and Keys[k] ~= nil then Keys[k] = e end
        end
    end
    if type(d.KeyEnabled) == "table" then
        for k, v in pairs(d.KeyEnabled) do
            if KeyEnabled[k] ~= nil then KeyEnabled[k] = v end
        end
    end
    if d.ST_AntiSentry ~= nil then State.AntiSentry = d.ST_AntiSentry end
    if d.ST_SpinBody ~= nil then State.SpinBody = d.ST_SpinBody end
    if d.ST_AntiRagdoll ~= nil then State.AntiRagdoll = d.ST_AntiRagdoll end
    if d.ST_InfiniteJump ~= nil then State.InfiniteJump = d.ST_InfiniteJump end
    if d.ST_FloatEnabled ~= nil then State.FloatEnabled = d.ST_FloatEnabled end
    if d.ST_XrayBase ~= nil then State.XrayBase = d.ST_XrayBase end
    if d.ST_ESP ~= nil then State.ESP = d.ST_ESP end
    if d.ST_SpeedBoost ~= nil then isSpeedBoostEnabled = d.ST_SpeedBoost end
    if d.ST_Optimizer ~= nil then State.Optimizer = d.ST_Optimizer end
    if d.ST_Unwalk ~= nil then UnwalkState.active = d.ST_Unwalk end
    if d.ST_HitCircle ~= nil then HitCircleState.Enabled = d.ST_HitCircle end
    if d.ST_SpamBat ~= nil then SpamBatState.enabled = d.ST_SpamBat end
    if d.ST_BatAimbot ~= nil then BatAimbotState.enabled = d.ST_BatAimbot; if d.ST_BatAimbot then task.defer(StartBatAimbot) end end
    if d.ST_BatAimbotSpeed ~= nil then BAT_AIMBOT_SPEED = d.ST_BatAimbotSpeed end
    if d.StealBarVisible ~= nil then StealBarVisible = d.StealBarVisible end
    if type(d.sideHiddenMap) == "table" then sideHiddenMap = d.sideHiddenMap end
    if type(d.sideButtonVisibility) == "table" then
        for k, v in pairs(d.sideButtonVisibility) do
            sideButtonVisibility[k] = v
        end
    end
    if type(d.ButtonPositions) == "table" then ButtonPositions = d.ButtonPositions end
    if d.TPSettings then
        if d.TPSettings.Enabled ~= nil then TPSettings.Enabled = d.TPSettings.Enabled end
        if d.TPSettings.TPHeight then TPSettings.TPHeight = d.TPSettings.TPHeight end
    end
    if d.FloatRiseHeight then FLOAT_RISE_HEIGHT = math.clamp(d.FloatRiseHeight, 1, 200) end
    if d.ShortRouteEnabled ~= nil then AP_ROUTES.ShortEnabled = d.ShortRouteEnabled end
    if d.DesyncEnabled ~= nil and d.DesyncEnabled then
        task.defer(function() startDesync() end)
    end
    if type(d.menuPos) == "table" then
        task.defer(function()
            if menu then
                menu.Position = UDim2.new(d.menuPos.X, d.menuPos.XO, d.menuPos.Y, d.menuPos.YO)
            end
        end)
    end
    if type(d.stealBarPos) == "table" then
        task.defer(function()
            if stealBarFrame then
                stealBarFrame.Position = UDim2.new(d.stealBarPos.X, d.stealBarPos.XO, d.stealBarPos.Y, d.stealBarPos.YO)
            end
        end)
    end
    task.defer(function()
        for id, boxRef in pairs(numberBoxReferences) do
            if boxRef and boxRef.TextBox then
                if id == "GrabRadius" then boxRef.TextBox.Text = tostring(EnhancedGrab.Radius)
                elseif id == "NormalSpeed" then boxRef.TextBox.Text = tostring(SpeedSettings.NormalSpeed)
                elseif id == "StealSpeed" then boxRef.TextBox.Text = tostring(SpeedSettings.StealSpeed)
                elseif id == "SideBtnSize" then boxRef.TextBox.Text = tostring(SideButtonSize)
                elseif id == "MenuWidth" then boxRef.TextBox.Text = tostring(menuW)
                elseif id == "MenuHeight" then boxRef.TextBox.Text = tostring(menuH)
                elseif id == "BatAimbotSpeed" then boxRef.TextBox.Text = tostring(BAT_AIMBOT_SPEED)
                elseif id == "TPHeight" then boxRef.TextBox.Text = tostring(TPSettings.TPHeight)
                elseif id == "FloatHeight" then boxRef.TextBox.Text = tostring(FLOAT_RISE_HEIGHT)
                end
            end
        end
        if grabBarRef.radiusLbl then grabBarRef.radiusLbl.Text = EnhancedGrab.Radius.."st" end
    end)
end

-- STEAL BAR
stealBarFrame = Instance.new("Frame", gui)
stealBarFrame.Name = "StealBar"
stealBarFrame.Size = UDim2.new(0,280,0,28)
stealBarFrame.Position = UDim2.new(0.5,-140,1,-45)
stealBarFrame.BackgroundColor3 = Colors.White
stealBarFrame.BackgroundTransparency = 0.15
stealBarFrame.ZIndex = 50
stealBarFrame.Visible = StealBarVisible
stealBarFrame.Active = true
Instance.new("UICorner", stealBarFrame).CornerRadius = UDim.new(0,10)
applySpinningGoldStroke(stealBarFrame, 1.8, 1.3)

do
    local sbDrag, sbDS, sbPS, sbActiveInput = false, nil, nil, nil
    stealBarFrame.InputBegan:Connect(function(inp)
        local t = inp.UserInputType
        if (t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch) and not sbDrag then
            sbDrag = true
            sbActiveInput = inp
            sbDS = inp.Position
            sbPS = stealBarFrame.Position
        end
    end)
    stealBarFrame.InputChanged:Connect(function(inp)
        if not sbDrag or inp ~= sbActiveInput then return end
        local t = inp.UserInputType
        if t ~= Enum.UserInputType.MouseMovement and t ~= Enum.UserInputType.Touch then return end
        local d = inp.Position - sbDS
        stealBarFrame.Position = UDim2.new(sbPS.X.Scale, sbPS.X.Offset + d.X, sbPS.Y.Scale, sbPS.Y.Offset + d.Y)
    end)
    stealBarFrame.InputEnded:Connect(function(inp)
        local t = inp.UserInputType
        if (t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch) and inp == sbActiveInput then
            sbDrag = false
            sbActiveInput = nil
        end
    end)
end

sbLabel = Instance.new("TextLabel", stealBarFrame)
sbLabel.Size = UDim2.new(0,36,1,0)
sbLabel.BackgroundTransparency = 1
sbLabel.Text = "GRAB"
sbLabel.TextColor3 = Colors.DarkGray
sbLabel.Font = Enum.Font.GothamBold
sbLabel.TextSize = 10
sbLabel.ZIndex = 51

sbBG = Instance.new("Frame", stealBarFrame)
sbBG.Size = UDim2.new(1,-120,0,12)
sbBG.Position = UDim2.new(0,38,0.5,-6)
sbBG.BackgroundColor3 = T.Bg0
sbBG.ZIndex = 51
Instance.new("UICorner", sbBG).CornerRadius = UDim.new(0,6)

sbFill = Instance.new("Frame", sbBG)
sbFill.Size = UDim2.new(0,0,1,0)
sbFill.BackgroundColor3 = T.Br
sbFill.ZIndex = 52
Instance.new("UICorner", sbFill).CornerRadius = UDim.new(0,6)

sbPct = Instance.new("TextLabel", stealBarFrame)
sbPct.Size = UDim2.new(0,28,1,0)
sbPct.Position = UDim2.new(1,-74,0,0)
sbPct.BackgroundTransparency = 1
sbPct.Text = "0%"
sbPct.TextColor3 = Colors.Text
sbPct.Font = Enum.Font.GothamBold
sbPct.TextSize = 10
sbPct.ZIndex = 51

sbRadius = Instance.new("TextLabel", stealBarFrame)
sbRadius.Size = UDim2.new(0,32,1,0)
sbRadius.Position = UDim2.new(1,-46,0,0)
sbRadius.BackgroundTransparency = 1
sbRadius.Text = EnhancedGrab.Radius.."st"
sbRadius.TextColor3 = Colors.MediumGray
sbRadius.Font = Enum.Font.GothamBold
sbRadius.TextSize = 10
sbRadius.ZIndex = 51

sbRate = Instance.new("TextLabel", stealBarFrame)
sbRate.Size = UDim2.new(0,0,1,0)
sbRate.Position = UDim2.new(1,0,0,0)
sbRate.BackgroundTransparency = 1
sbRate.Text = ""
sbRate.TextColor3 = Colors.MediumGray
sbRate.Font = Enum.Font.GothamBold
sbRate.TextSize = 9
sbRate.ZIndex = 51

grabBarRef = { fill = sbFill, pct = sbPct, radiusLbl = sbRadius, rateLbl = sbRate }

-- MENU BUTTON
local menuBtn = Instance.new("Frame", gui)
menuBtn.Size = UDim2.new(0,110,0,44)
menuBtn.Position = UDim2.new(0.5,-55,0.07,0)
menuBtn.BackgroundColor3 = T.Bg3
menuBtn.BackgroundTransparency = 0
menuBtn.Active = true
menuBtn.ZIndex = 60
Instance.new("UICorner", menuBtn).CornerRadius = UDim.new(0,12)
mbStroke = applySpinningGoldStroke(menuBtn, 2, 1.8)

menuBtnLabel = Instance.new("TextLabel", menuBtn)
menuBtnLabel.Size = UDim2.new(1,0,1,0)
menuBtnLabel.BackgroundTransparency = 1
menuBtnLabel.Text = "H2N"
menuBtnLabel.TextColor3 = T.A
menuBtnLabel.Font = Enum.Font.GothamBlack
menuBtnLabel.TextSize = 19
menuBtnLabel.ZIndex = 61

local menuGlowOverlay = Instance.new("Frame", menuBtn)
menuGlowOverlay.Size = UDim2.new(1,0,1,0)
menuGlowOverlay.BackgroundColor3 = T.D
menuGlowOverlay.BackgroundTransparency = 1
menuGlowOverlay.ZIndex = 60
menuGlowOverlay.BorderSizePixel = 0
Instance.new("UICorner", menuGlowOverlay).CornerRadius = UDim.new(0,12)

task.spawn(function()
    local t = 0
    local purpleColors = {
        Color3.fromRGB(255, 215, 100),
        Color3.fromRGB(255, 245, 180),
        Color3.fromRGB(220, 165, 30),
        Color3.fromRGB(255, 200, 60),
        Color3.fromRGB(255, 255, 220),
    }
    local shakeAmp = 1.2
    while true do
        t = t + 0.04
        local ci = math.floor(t * 1.5) % #purpleColors + 1
        local cn = ci % #purpleColors + 1
        local f = (t * 1.5) % 1
        local col = purpleColors[ci]:Lerp(purpleColors[cn], f)
        menuBtnLabel.TextColor3 = col
        mbStroke.Color = col
        local shimmer = math.abs(math.sin(t * 2.5))
        menuGlowOverlay.BackgroundTransparency = 1 - (shimmer * 0.13)
        local shakeX = math.sin(t * 5) * shakeAmp
        local shakeY = math.cos(t * 7) * (shakeAmp * 0.5)
        menuBtnLabel.Position = UDim2.new(0, shakeX, 0, shakeY)
        menuBtnLabel.Size = UDim2.new(1, 0, 1, 0)
        task.wait(0.04)
    end
end)

do
    local mbDragging = false
    local mbMoved = false
    local mbDragStart = nil
    local mbStartPos = nil
    local mbActiveInput = nil
    menuBtn.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if (t == Enum.UserInputType.Touch or t == Enum.UserInputType.MouseButton1) and not mbDragging then
            mbDragging = true
            mbMoved = false
            mbActiveInput = input
            mbDragStart = input.Position
            mbStartPos = menuBtn.Position
        end
    end)
    menuBtn.InputChanged:Connect(function(input)
        if not mbDragging or input ~= mbActiveInput then return end
        local t = input.UserInputType
        if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseMovement then return end
        local delta = input.Position - mbDragStart
        if delta.Magnitude > 6 then
            mbMoved = true
            menuBtn.Position = UDim2.new(mbStartPos.X.Scale, mbStartPos.X.Offset + delta.X, mbStartPos.Y.Scale, mbStartPos.Y.Offset + delta.Y)
        end
    end)
    menuBtn.InputEnded:Connect(function(input)
        local t = input.UserInputType
        if (t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1) then return end
        if input ~= mbActiveInput then return end
        local didMove = mbMoved
        mbDragging = false
        mbMoved = false
        mbActiveInput = nil
        if not didMove then
            if menu.Visible then
                menu.Visible = false
            else
                menu.Size = UDim2.new(0, menuW, 0, menuH)
                menu.BackgroundTransparency = 0
                menu.Visible = true
            end
        else
            Save()
        end
    end)
end

-- SPEED COUNTER
task.spawn(function()
    local RunService = game:GetService("RunService")

    repeat task.wait() until Char and Char:FindFirstChild("HumanoidRootPart")

    local bb = Instance.new("BillboardGui")
    bb.Name          = "H2N_SpeedCounter"
    bb.Size          = UDim2.new(0, 80, 0, 28)
    bb.StudsOffset   = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop   = true
    bb.ResetOnSpawn  = false
    bb.LightInfluence = 0
    bb.Adornee       = Char:FindFirstChild("HumanoidRootPart")
    bb.Parent        = gui

    local lbl = Instance.new("TextLabel", bb)
    lbl.Size                   = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font                   = Enum.Font.GothamBlack
    lbl.TextSize               = 15
    lbl.TextColor3             = Color3.fromRGB(255, 220, 80)
    lbl.TextStrokeTransparency = 0.4
    lbl.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)

    local tg = Instance.new("UIGradient", lbl)
    tg.Color    = makeGoldGradient()
    tg.Rotation = 0

    local GC = {
        Color3.fromRGB(255,215,100), Color3.fromRGB(255,245,180),
        Color3.fromRGB(220,165, 30), Color3.fromRGB(255,200, 60),
        Color3.fromRGB(255,255,220),
    }

    RunService.RenderStepped:Connect(function()
        if not Char or not Char:FindFirstChild("HumanoidRootPart") then
            bb.Adornee = nil
            return
        end
        bb.Adornee = Char:FindFirstChild("HumanoidRootPart")

        local hrp = Char:FindFirstChild("HumanoidRootPart")
        local speed = 0
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            speed = math.floor(Vector3.new(vel.X, 0, vel.Z).Magnitude)
        end
        lbl.Text = tostring(speed)

        local t2 = tick()
        tg.Rotation = (tg.Rotation + 2) % 360
        local i = math.floor(t2 * 1.5) % #GC + 1
        lbl.TextColor3 = GC[i]:Lerp(GC[i%#GC+1], (t2*1.5)%1)
    end)

    LP.CharacterAdded:Connect(function(c)
        task.wait(0.5)
        Char = c
        local hrp = c:WaitForChild("HumanoidRootPart", 5)
        if hrp then bb.Adornee = hrp end
    end)
end)

-- MAIN MENU
menu = Instance.new("Frame", gui)
menu.Size = UDim2.new(0, menuW, 0, menuH)
menu.Position = UDim2.new(0.5, -menuW/2, 0.5, -menuH/2)
menu.BackgroundColor3 = T.Bg1
menu.BackgroundTransparency = 0
menu.Visible = false
menu.Active = true
menu.ZIndex = 55
Instance.new("UICorner", menu).CornerRadius = UDim.new(0,14)
menuStroke = applySpinningGoldStroke(menu, 2.2, 1.6)
addBgShimmer(menu, 1.1, 0.83)

local header = Instance.new("Frame", menu)
header.Size = UDim2.new(1,0,0,46)
header.BackgroundColor3 = T.ON
header.BackgroundTransparency = 0
header.BorderSizePixel = 0
header.ZIndex = 56
hCorner = Instance.new("UICorner", header)
hCorner.CornerRadius = UDim.new(0,14)
hFix = Instance.new("Frame", header)
hFix.Size = UDim2.new(1,0,0.5,0)
hFix.Position = UDim2.new(0,0,0.5,0)
hFix.BackgroundColor3 = T.ON
hFix.BorderSizePixel = 0
hFix.ZIndex = 56
addBgShimmer(header, 2.0, 0.62)

accentLine = Instance.new("Frame", menu)
accentLine.Size = UDim2.new(1,0,0,2)
accentLine.Position = UDim2.new(0,0,0,42)
accentLine.BackgroundColor3 = T.Br
accentLine.BorderSizePixel = 0
accentLine.ZIndex = 57

task.spawn(function()
    local t = 0
    while true do
        t = t + 0.05
        local g = 0.5 + 0.5 * math.sin(t * 3)
        accentLine.BackgroundColor3 = Color3.fromRGB(
            math.floor(230 + g * 25),
            math.floor(168 + g * 72),
            math.floor(10 + g * 50)
        )
        accentLine.Size = UDim2.new(1,0,0, math.floor(2 + g * 1.5))
        task.wait(0.05)
    end
end)

tl = Instance.new("TextLabel", header)
tl.Size = UDim2.new(1,-20,1,0)
tl.Position = UDim2.new(0,14,0,0)
tl.BackgroundTransparency = 1
tl.Text = "H2N v6.1"
tl.TextColor3 = Color3.fromRGB(255, 240, 195)
tl.Font = Enum.Font.GothamBlack
tl.TextSize = 17
tl.TextXAlignment = Enum.TextXAlignment.Left
tl.ZIndex = 57

local verLbl = Instance.new("TextLabel", header)
verLbl.Size = UDim2.new(0,60,1,0)
verLbl.Position = UDim2.new(1,-70,0,0)
verLbl.BackgroundTransparency = 1
verLbl.Text = "ULTRA"
verLbl.TextColor3 = T.A
verLbl.Font = Enum.Font.GothamBold
verLbl.TextSize = 12
verLbl.TextXAlignment = Enum.TextXAlignment.Right
verLbl.ZIndex = 57

do
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local activeInput = nil
    header.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if (t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch) and not dragging then
            dragging = true
            activeInput = input
            dragStart = input.Position
            startPos = menu.Position
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
        dragging = false
        activeInput = nil
        Save()
    end)
end

local tabBar = Instance.new("Frame", menu)
tabBar.Size = UDim2.new(0,108,1,-48)
tabBar.Position = UDim2.new(0,6,0,48)
tabBar.BackgroundColor3 = T.Bg2
tabBar.BackgroundTransparency = 0
tabBar.ZIndex = 56
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0,10)
tbStroke = applySpinningGoldStroke(tabBar, 1.5, 0.9)

local tabNames = {"Combat", "Protect", "Visual", "Settings"}
local tabFrames = {}
local tabBtns = {}

for i, name in ipairs(tabNames) do
    local tb = Instance.new("TextButton", tabBar)
    tb.Size = UDim2.new(1,-12,0,38)
    tb.Position = UDim2.new(0,6,0,(i-1)*44+8)
    tb.BackgroundColor3 = T.Bg3
    tb.Text = name
    tb.TextColor3 = T.TxD
    tb.Font = Enum.Font.GothamBold
    tb.TextSize = 13
    tb.ZIndex = 57
    tb.TextXAlignment = Enum.TextXAlignment.Left
    tb.AutoButtonColor = false
    local tbCorner = Instance.new("UICorner", tb)
    tbCorner.CornerRadius = UDim.new(0,8)
    applySpinningGoldStroke(tb, 1.2, 1.0)
    local pad = Instance.new("UIPadding", tb)
    pad.PaddingLeft = UDim.new(0,8)
    tabBtns[name] = tb
    local sf = Instance.new("ScrollingFrame", menu)
    sf.Size = UDim2.new(1,-124,1,-50)
    sf.Position = UDim2.new(0,118,0,48)
    sf.BackgroundTransparency = 1
    sf.Visible = (i==1)
    sf.ScrollBarThickness = 3
    sf.ScrollBarImageColor3 = T.Br
    sf.CanvasSize = UDim2.new(0,0,0,0)
    sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sf.ZIndex = 57
    tabFrames[name] = sf
    tb.MouseButton1Click:Connect(function()
        for _, f in pairs(tabFrames) do f.Visible = false end
        for _, b in pairs(tabBtns) do
            b.BackgroundColor3 = T.Bg3
            b.TextColor3 = T.TxD
        end
        sf.Visible = true
        tb.BackgroundColor3 = T.ON
        tb.TextColor3 = T.A
    end)
end
tabBtns["Combat"].BackgroundColor3 = T.ON
tabBtns["Combat"].TextColor3 = T.A

local function MakeToggle(parent, text, order, cb, getState, featureName)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1,-10,0,40)
    row.Position = UDim2.new(0,5,0,order*44+4)
    row.BackgroundColor3 = T.Bg3
    row.BackgroundTransparency = 0
    row.ZIndex = 58
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)
    local rowStroke = applySpinningGoldStroke(row, 1.2, 1.1)
    addBgShimmer(row, 1.0, 0.91)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.58,0,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = T.Tx
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0,70,0,26)
    btn.Position = UDim2.new(1,-78,0.5,-13)
    btn.BackgroundColor3 = T.OFF
    btn.BackgroundTransparency = 0
    btn.Text = "OFF"
    btn.TextColor3 = T.TxD
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)
    local btnStk = applySpinningGoldStroke(btn, 1.2, 1.3)
    addBgShimmer(btn, 1.3, 0.87)
    local function UpdateButton()
        if getState() then
            btn.Text = "ON"
            btn.BackgroundColor3 = T.ON
            btn.TextColor3 = T.Bg0
            btnStk.Thickness = 2
        else
            btn.Text = "OFF"
            btn.BackgroundColor3 = T.OFF
            btn.TextColor3 = T.TxD
            btnStk.Thickness = 1.2
        end
    end
    UpdateButton()
    btn.MouseButton1Click:Connect(function()
        cb(not getState())
        UpdateButton()
        Save()
    end)
    RunService.RenderStepped:Connect(UpdateButton)
    if featureName then
        toggleUpdaters[featureName] = function(state) cb(state); UpdateButton() end
    end
    return btn
end

local function MakeNumberBox(parent, text, default, order, cb, minVal, maxVal, id)
    minVal = minVal or 1
    maxVal = maxVal or 200
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1,-10,0,40)
    row.Position = UDim2.new(0,5,0,order*44+4)
    row.BackgroundColor3 = T.Bg3
    row.BackgroundTransparency = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)
    applySpinningGoldStroke(row, 1.2, 1.1)
    addBgShimmer(row, 1.0, 0.91)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.55,0,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = T.Tx
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local box = Instance.new("TextBox", row)
    box.Size = UDim2.new(0,70,0,26)
    box.Position = UDim2.new(1,-78,0.5,-13)
    box.BackgroundColor3 = T.Bg4
    box.BackgroundTransparency = 0
    box.Text = tostring(default)
    box.TextColor3 = T.Tx
    box.Font = Enum.Font.GothamBold
    box.TextSize = 15
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,7)
    applySpinningGoldStroke(box, 1.2, 1.4)
    addBgShimmer(box, 1.4, 0.87)
    if id then
        numberBoxReferences[id] = { TextBox = box, cb = cb, minVal = minVal, maxVal = maxVal }
    end
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then
            n = math.clamp(n, minVal, maxVal)
            cb(n)
            box.Text = tostring(n)
        else
            box.Text = tostring(default)
        end
        Save()
    end)
    return box
end

local function MakeKeybind(parent, labelText, keyName, order)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1,-10,0,40)
    row.Position = UDim2.new(0,5,0,order*44+4)
    row.BackgroundColor3 = T.Bg3
    row.BackgroundTransparency = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)
    applySpinningGoldStroke(row, 1.2, 1.0)
    addBgShimmer(row, 1.0, 0.91)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.46,0,1,0)
    lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = labelText
    lbl.TextColor3 = T.Tx
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    local keyBtn = Instance.new("TextButton", row)
    keyBtn.Size = UDim2.new(0,52,0,26)
    keyBtn.Position = UDim2.new(0.47,0,0.5,-13)
    keyBtn.BackgroundColor3 = T.Bg4
    keyBtn.BackgroundTransparency = 0
    keyBtn.Text = Keys[keyName] and Keys[keyName].Name or "?"
    keyBtn.TextColor3 = T.Tx
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 11
    keyBtn.AutoButtonColor = false
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0,7)
    applySpinningGoldStroke(keyBtn, 1.2, 1.5)
    addBgShimmer(keyBtn, 1.5, 0.87)
    local enableBtn = Instance.new("TextButton", row)
    enableBtn.Size = UDim2.new(0,52,0,26)
    enableBtn.Position = UDim2.new(1,-60,0.5,-13)
    enableBtn.BackgroundColor3 = KeyEnabled[keyName] and T.ON or T.Err
    enableBtn.Text = KeyEnabled[keyName] and "ON" or "OFF"
    enableBtn.TextColor3 = T.Tx
    enableBtn.Font = Enum.Font.GothamBold
    enableBtn.TextSize = 11
    enableBtn.AutoButtonColor = false
    Instance.new("UICorner", enableBtn).CornerRadius = UDim.new(0,7)
    applySpinningGoldStroke(enableBtn, 1.2, 1.7)
    addBgShimmer(enableBtn, 1.7, 0.87)
    local listening = false
    local listenConn
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        keyBtn.BackgroundColor3 = T.Bg4
        if listenConn then listenConn:Disconnect() end
        listenConn = UIS.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Keys[keyName] = input.KeyCode
                keyBtn.Text = input.KeyCode.Name
                keyBtn.BackgroundColor3 = T.Bg4
                listening = false
                listenConn:Disconnect()
                Notify("Key "..labelText.." = "..input.KeyCode.Name)
                Save()
            end
        end)
    end)
    enableBtn.MouseButton1Click:Connect(function()
        KeyEnabled[keyName] = not KeyEnabled[keyName]
        enableBtn.Text = KeyEnabled[keyName] and "ON" or "OFF"
        enableBtn.BackgroundColor3 = KeyEnabled[keyName] and T.ON or T.Err
        Save()
    end)
end

-- COMBAT TAB
local ci = 0
local combat = tabFrames["Combat"]
MakeToggle(combat, "AUTO GRAB", ci, function(s) if s then StartEnhancedGrab() else StopEnhancedGrab() end end, function() return EnhancedGrab.Enabled end, "AutoGrab")
ci = ci + 1
MakeNumberBox(combat, "Grab Radius", EnhancedGrab.Radius, ci, function(v)
    EnhancedGrab.Radius = math.clamp(v, 1, 100)
    if grabBarRef.radiusLbl then grabBarRef.radiusLbl.Text = EnhancedGrab.Radius.."st" end
    Notify("Grab Radius = "..EnhancedGrab.Radius)
end, 1, 100, "GrabRadius")
ci = ci + 1
MakeToggle(combat, "AUTO PLAY LEFT", ci, function(s) if sideButtonRefs["AutoPlayLeft"] then sideButtonRefs["AutoPlayLeft"](s, true) end end, function() return sideButtonVisibility["AutoPlayLeft"] == true end, "AutoPlayLeft")
ci = ci + 1
MakeToggle(combat, "AUTO PLAY RIGHT", ci, function(s) if sideButtonRefs["AutoPlayRight"] then sideButtonRefs["AutoPlayRight"](s, true) end end, function() return sideButtonVisibility["AutoPlayRight"] == true end, "AutoPlayRight")
ci = ci + 1
MakeToggle(combat, "ANTI SENTRY", ci, function(s) if s then StartAntiSentry() else StopAntiSentry() end end, function() return State.AntiSentry end, "AntiSentry")
ci = ci + 1
MakeToggle(combat, "SPIN BODY", ci, function(s) if s then StartSpinBody() else StopSpinBody() end end, function() return State.SpinBody end, "SpinBody")
ci = ci + 1
MakeToggle(combat, "SPEED BOOST", ci, function(s) if sideButtonRefs["SpeedBoost"] then sideButtonRefs["SpeedBoost"](s, true) end end, function() return sideButtonVisibility["SpeedBoost"] == true end, "SpeedBoost")
ci = ci + 1
MakeNumberBox(combat, "Normal Speed", SpeedSettings.NormalSpeed, ci, function(v) SpeedSettings.NormalSpeed = math.clamp(v,1,200); Notify("Normal Speed = "..SpeedSettings.NormalSpeed) end, 1, 200, "NormalSpeed")
ci = ci + 1
MakeNumberBox(combat, "Steal Speed", SpeedSettings.StealSpeed, ci, function(v) SpeedSettings.StealSpeed = math.clamp(v,1,200); Notify("Steal Speed = "..SpeedSettings.StealSpeed) end, 1, 200, "StealSpeed")
ci = ci + 1
MakeToggle(combat, "DROP", ci, function(s) if sideButtonRefs["DROP"] then sideButtonRefs["DROP"](s, true) end end, function() return sideButtonVisibility["DROP"] == true end, "DROP")
ci = ci + 1
MakeToggle(combat, "HIT CIRCLE", ci, function(s) if s then StartHitCircle() else StopHitCircle() end end, function() return HitCircleState.Enabled end, "HitCircle")
ci = ci + 1
MakeToggle(combat, "SPAM BAT", ci, function(s) if s then StartSpamBat() else StopSpamBat() end end, function() return SpamBatState.enabled end, "SpamBat")
ci = ci + 1
MakeToggle(combat, "AUTO BAT", ci, function(s) if sideButtonRefs["AutoBat"] then sideButtonRefs["AutoBat"](s, true) end end, function() return sideButtonVisibility["AutoBat"] == true end, "AutoBat")
ci = ci + 1
MakeNumberBox(combat, "Bat Speed", BAT_AIMBOT_SPEED, ci, function(v) BAT_AIMBOT_SPEED = math.clamp(v, 10, 300); Notify("Bat Speed = " .. BAT_AIMBOT_SPEED) end, 10, 300, "BatAimbotSpeed")
ci = ci + 1
MakeToggle(combat, "ANTI LAG", ci, function(s) if s then startOptimizer() else stopOptimizer() end end, function() return State.Optimizer end, "Optimizer")
ci = ci + 1

-- PROTECT TAB
local pi = 0
local protect = tabFrames["Protect"]
MakeToggle(protect, "ANTI RAGDOLL", pi, function(s) if s then StartAntiRagdoll() else StopAntiRagdoll() end end, function() return State.AntiRagdoll end, "AntiRagdoll")
pi = pi + 1
MakeToggle(protect, "INFINITE JUMP", pi, function(s) if s then StartInfiniteJump() else StopInfiniteJump() end end, function() return State.InfiniteJump end, "InfiniteJump")
pi = pi + 1
MakeToggle(protect, "FLOAT", pi, function(s) if sideButtonRefs["FloatEnabled"] then sideButtonRefs["FloatEnabled"](s, true) end end, function() return sideButtonVisibility["FloatEnabled"] == true end, "FloatEnabled")
pi = pi + 1
MakeNumberBox(protect, "Float Height", FLOAT_RISE_HEIGHT, pi, function(v)
    FLOAT_RISE_HEIGHT = math.clamp(v, 1, 200)
    Notify("Float Height = "..FLOAT_RISE_HEIGHT)
end, 1, 200, "FloatHeight")
pi = pi + 1
MakeToggle(protect, "AUTO TP DOWN", pi, function(s) if sideButtonRefs["AutoTPDown"] then sideButtonRefs["AutoTPDown"](s, true) end end, function() return sideButtonVisibility["AutoTPDown"] == true end, "AutoTPDown")
pi = pi + 1
MakeNumberBox(protect, "TP Down Height", TPSettings.TPHeight, pi, function(v)
    TPSettings.TPHeight = math.clamp(v, 1, 500)
    Notify("TP Down Height = "..TPSettings.TPHeight)
end, 1, 500, "TPHeight")
pi = pi + 1
MakeToggle(protect, "TP DOWN", pi, function(s) if sideButtonRefs["TPDown"] then sideButtonRefs["TPDown"](s, true) end end, function() return sideButtonVisibility["TPDown"] == true end, "TPDown")
pi = pi + 1
MakeToggle(protect, "DESYNC", pi, function(s) if sideButtonRefs["Desync"] then sideButtonRefs["Desync"](s, true) end end, function() return sideButtonVisibility["Desync"] == true end, "DesyncUltra")
pi = pi + 1
MakeToggle(protect, "UNWALK", pi, function(s) if s then startUnwalk() else stopUnwalk() end end, function() return UnwalkState.active end, "Unwalk")
pi = pi + 1
MakeToggle(protect, "AUTO GRAB (PC)", pi, function(s)
    if s then
        StartPCGrab()
    else
        StopPCGrab()
    end
    if toggleUpdaters and toggleUpdaters["PCGrab"] then toggleUpdaters["PCGrab"](PCGrab.Enabled) end
end, function() return PCGrab.Enabled end, "PCGrab")
pi = pi + 1
MakeNumberBox(protect, "PC Grab Radius", PCGrab.Radius, pi, function(v)
    PCGrab.Radius = math.clamp(v, 1, 100)
    if grabBarRef.radiusLbl then grabBarRef.radiusLbl.Text = PCGrab.Radius.."st" end
    Notify("PC Grab Radius = "..PCGrab.Radius)
    Save()
end, 1, 100, "PCGrabRadius")
pi = pi + 1
MakeNumberBox(protect, "PC Grab Speed (s)", math.floor(PCGrab.Speed * 100) / 100, pi, function(v)
    PCGrab.Speed = math.clamp(v, 0.05, 5)
    Notify("PC Grab Speed = "..PCGrab.Speed.."s")
    Save()
end, 0.05, 5, "PCGrabSpeed")
pi = pi + 1

-- VISUAL TAB
local vi = 0
local visual = tabFrames["Visual"]

local function GetCornerForShape(shape)
    if shape == "circle" then return UDim.new(1, 0)
    elseif shape == "rect" then return UDim.new(0, 18)
    else return UDim.new(0, 14) end
end

local _allSideButtonCorners = {}

local function ApplyShapeToAllSideButtons(shape)
    SideButtonShape = shape
    for _, data in ipairs(_allSideButtonCorners) do
        data.corner.CornerRadius = GetCornerForShape(shape)
        if shape == "rect" then
            data.btn.Size = UDim2.new(0, SideButtonWidth, 0, SideButtonSize)
        else
            data.btn.Size = UDim2.new(0, SideButtonSize, 0, SideButtonSize)
        end
    end
    Save()
end

MakeToggle(visual, "ESP", vi, function(s) if s then ToggleESP() else ToggleESP() end end, function() return State.ESP end, "ESP")
vi = vi + 1
MakeToggle(visual, "XRAY BASE", vi, function(s) if s then ToggleXrayBase() else ToggleXrayBase() end end, function() return State.XrayBase end, "XrayBase")
vi = vi + 1
MakeToggle(visual, "Show Steal Bar", vi, function(s) StealBarVisible = s; stealBarFrame.Visible = s; Save() end, function() return StealBarVisible end)
vi = vi + 1
MakeNumberBox(visual, "Side Button Size", SideButtonSize, vi, function(val)
    SideButtonSize = val
    if SideButtonShape == "rect" then
        SideButtonWidth = math.floor(SideButtonSize * 3.75)
    end
    for _, b in pairs(gui:GetChildren()) do
        if b:IsA("Frame") and b.Name == "SideButton" then
            local btnW = (SideButtonShape == "rect") and SideButtonWidth or SideButtonSize
            b.Size = UDim2.new(0, btnW, 0, SideButtonSize)
        end
    end
end, 40, 150, "SideBtnSize")
vi = vi + 1
MakeNumberBox(visual, "Menu Width", menuW, vi, function(v) menuW = math.clamp(v,200,750); menu.Size = UDim2.new(0,menuW,0,menuH) end, 200, 750, "MenuWidth")
vi = vi + 1
MakeNumberBox(visual, "Menu Height", menuH, vi, function(v) menuH = math.clamp(v,200,750); menu.Size = UDim2.new(0,menuW,0,menuH) end, 200, 750, "MenuHeight")
vi = vi + 1

-- Button Shape Picker
do
    local shapeRow = Instance.new("Frame", visual)
    shapeRow.Size = UDim2.new(1,-10,0,40)
    shapeRow.Position = UDim2.new(0,5,0,vi*44+4)
    shapeRow.BackgroundColor3 = T.Bg3
    shapeRow.BackgroundTransparency = 0
    shapeRow.ZIndex = 58
    Instance.new("UICorner", shapeRow).CornerRadius = UDim.new(0,8)
    local shapeStk = Instance.new("UIStroke", shapeRow)
    shapeStk.Color = T.BrD
    shapeStk.Thickness = 1
    local shapeLbl = Instance.new("TextLabel", shapeRow)
    shapeLbl.Size = UDim2.new(0.42,0,1,0)
    shapeLbl.Position = UDim2.new(0,10,0,0)
    shapeLbl.BackgroundTransparency = 1
    shapeLbl.Text = "Btn Shape"
    shapeLbl.TextColor3 = T.Tx
    shapeLbl.Font = Enum.Font.GothamBold
    shapeLbl.TextSize = 13
    shapeLbl.TextXAlignment = Enum.TextXAlignment.Left
    shapeLbl.ZIndex = 59

    local shapes = {
        {id="square", label="SQ", tip="Square"},
        {id="circle", label="CI", tip="Circle"},
        {id="rect",   label="RE", tip="Rect"},
    }
    local shapeBtns = {}

    local function refreshShapeBtns()
        for _, sb in ipairs(shapeBtns) do
            if sb.id == SideButtonShape then
                sb.btn.BackgroundColor3 = T.ON
                sb.btn.TextColor3 = T.Tx
                sb.stroke.Color = T.Br
            else
                sb.btn.BackgroundColor3 = T.Bg4
                sb.btn.TextColor3 = T.TxD
                sb.stroke.Color = T.BrS
            end
        end
    end

    for i, sh in ipairs(shapes) do
        local sb = Instance.new("TextButton", shapeRow)
        sb.Size = UDim2.new(0, 38, 0, 26)
        sb.Position = UDim2.new(1, -14 - (4 - i) * 44, 0.5, -13)
        sb.BackgroundColor3 = T.Bg4
        sb.Text = sh.label
        sb.TextColor3 = T.TxD
        sb.Font = Enum.Font.GothamBold
        sb.TextSize = 16
        sb.AutoButtonColor = false
        sb.ZIndex = 59
        Instance.new("UICorner", sb).CornerRadius = UDim.new(0,7)
        local sbStroke = Instance.new("UIStroke", sb)
        sbStroke.Color = T.BrS
        sbStroke.Thickness = 1
        table.insert(shapeBtns, { id = sh.id, btn = sb, stroke = sbStroke })
        local shId = sh.id
        sb.MouseButton1Click:Connect(function()
            ApplyShapeToAllSideButtons(shId)
            refreshShapeBtns()
        end)
    end
    refreshShapeBtns()
    vi = vi + 1
end

-- SETTINGS TAB
local si = 0
local sTab = tabFrames["Settings"]
copyBtn = Instance.new("TextButton", sTab)
copyBtn.Size = UDim2.new(1,-10,0,40)
copyBtn.Position = UDim2.new(0,5,0,si*44+4)
copyBtn.BackgroundColor3 = T.ON
copyBtn.AutoButtonColor = false
copyBtn.Text = "COPY DISCORD LINK"
copyBtn.TextColor3 = T.Tx
copyBtn.Font = Enum.Font.GothamBold
copyBtn.TextSize = 13
Instance.new("UICorner", copyBtn).CornerRadius = UDim.new(0,8)
copyBtn.MouseButton1Click:Connect(function()
    setclipboard("discord.gg/wsUuRQYVB")
    copyBtn.BackgroundColor3 = T.ON
    task.wait(0.8)
    copyBtn.BackgroundColor3 = T.ON
    Notify("Discord link copied!")
end)
si = si + 1
sep = Instance.new("Frame", sTab)
sep.Size = UDim2.new(1,-10,0,28)
sep.Position = UDim2.new(0,5,0,si*44+4)
sep.BackgroundColor3 = T.Bg3
sep.BackgroundTransparency = 0
Instance.new("UICorner", sep).CornerRadius = UDim.new(0,6)
sepLbl = Instance.new("TextLabel", sep)
sepLbl.Size = UDim2.new(1,0,1,0)
sepLbl.BackgroundTransparency = 1
sepLbl.Text = "KEYBINDS"
sepLbl.TextColor3 = T.A
sepLbl.Font = Enum.Font.GothamBold
sepLbl.TextSize = 13
si = si + 1
MakeKeybind(sTab, "TP Down (J)", "TPDown", si); si = si + 1
MakeKeybind(sTab, "Auto Left (G)", "AutoPlayLeft", si); si = si + 1
MakeKeybind(sTab, "Auto Right (H)", "AutoPlayRight", si); si = si + 1
MakeKeybind(sTab, "Anti Ragdoll (K)", "AntiRagdoll", si); si = si + 1
MakeKeybind(sTab, "Float (F)", "Float", si); si = si + 1
MakeKeybind(sTab, "Speed Boost (B)", "SpeedBoost", si); si = si + 1
MakeKeybind(sTab, "Unwalk (U)", "Unwalk", si); si = si + 1
MakeKeybind(sTab, "Auto TP Down (T)", "AutoTPDown", si); si = si + 1
MakeKeybind(sTab, "Desync (L)", "Desync", si); si = si + 1

-- CHANGE ROUTE
do
    local sepRoute = Instance.new("Frame", sTab)
    sepRoute.Size = UDim2.new(1,-10,0,28)
    sepRoute.Position = UDim2.new(0,5,0,si*44+4)
    sepRoute.BackgroundColor3 = T.Bg3
    sepRoute.BackgroundTransparency = 0
    Instance.new("UICorner", sepRoute).CornerRadius = UDim.new(0,6)
    local sepRouteLbl = Instance.new("TextLabel", sepRoute)
    sepRouteLbl.Size = UDim2.new(1,0,1,0)
    sepRouteLbl.BackgroundTransparency = 1
    sepRouteLbl.Text = "AUTO PLAY ROUTE"
    sepRouteLbl.TextColor3 = T.A
    sepRouteLbl.Font = Enum.Font.GothamBold
    sepRouteLbl.TextSize = 13
    si = si + 1

    local routeRow = Instance.new("Frame", sTab)
    routeRow.Size = UDim2.new(1,-10,0,50)
    routeRow.Position = UDim2.new(0,5,0,si*44+4)
    routeRow.BackgroundColor3 = T.Bg3
    routeRow.BackgroundTransparency = 0
    routeRow.ZIndex = 58
    Instance.new("UICorner", routeRow).CornerRadius = UDim.new(0,8)
    local routeRowStk = Instance.new("UIStroke", routeRow)
    routeRowStk.Color = T.BrD
    routeRowStk.Thickness = 1

    local routeNameLbl = Instance.new("TextLabel", routeRow)
    routeNameLbl.Size = UDim2.new(0.55,0,0,22)
    routeNameLbl.Position = UDim2.new(0,10,0,4)
    routeNameLbl.BackgroundTransparency = 1
    routeNameLbl.Text = "Change Route"
    routeNameLbl.TextColor3 = T.Tx
    routeNameLbl.Font = Enum.Font.GothamBold
    routeNameLbl.TextSize = 13
    routeNameLbl.TextXAlignment = Enum.TextXAlignment.Left

    local routeDescLbl = Instance.new("TextLabel", routeRow)
    routeDescLbl.Size = UDim2.new(1,-10,0,18)
    routeDescLbl.Position = UDim2.new(0,10,0,26)
    routeDescLbl.BackgroundTransparency = 1
    routeDescLbl.Text = "FULL: 5pts  |  SHORT: L1-Lend only then stop"
    routeDescLbl.TextColor3 = T.TxD
    routeDescLbl.Font = Enum.Font.Gotham
    routeDescLbl.TextSize = 10
    routeDescLbl.TextXAlignment = Enum.TextXAlignment.Left
    routeDescLbl.TextTruncate = Enum.TextTruncate.AtEnd

    local routeBtn = Instance.new("TextButton", routeRow)
    routeBtn.Size = UDim2.new(0,80,0,28)
    routeBtn.Position = UDim2.new(1,-88,0.5,-14)
    routeBtn.BackgroundColor3 = T.OFF
    routeBtn.Text = "FULL"
    routeBtn.TextColor3 = T.TxD
    routeBtn.Font = Enum.Font.GothamBold
    routeBtn.TextSize = 12
    routeBtn.AutoButtonColor = false
    Instance.new("UICorner", routeBtn).CornerRadius = UDim.new(0,7)
    local routeBtnStk = Instance.new("UIStroke", routeBtn)
    routeBtnStk.Color = T.BrD
    routeBtnStk.Thickness = 1

    local function refreshRouteBtn()
        if AP_ROUTES.ShortEnabled then
            routeBtn.Text = "SHORT"
            routeBtn.BackgroundColor3 = T.ON
            routeBtn.TextColor3 = T.Tx
            routeBtnStk.Color = T.Br
            routeRowStk.Color = T.C
        else
            routeBtn.Text = "FULL"
            routeBtn.BackgroundColor3 = T.OFF
            routeBtn.TextColor3 = T.TxD
            routeBtnStk.Color = T.BrD
            routeRowStk.Color = T.BrD
        end
    end
    refreshRouteBtn()

    routeBtn.MouseButton1Click:Connect(function()
        AP_ROUTES.ShortEnabled = not AP_ROUTES.ShortEnabled
        if State.AutoPlayLeft then StopAutoPlayLeft() end
        if State.AutoPlayRight then StopAutoPlayRight() end
        refreshRouteBtn()
        Notify(AP_ROUTES.ShortEnabled and "Route: SHORT" or "Route: FULL (5 points)")
        Save()
    end)
    si = si + 1
end

local function CreateSideButton(text, side, index, getState, startFn, stopFn, stateKey)
    local btnW = (SideButtonShape == "rect") and SideButtonWidth or SideButtonSize
    local btn = Instance.new("Frame", gui)
    btn.Name = "SideButton"
    btn:SetAttribute("ID", text)
    btn.Size = UDim2.new(0, btnW, 0, SideButtonSize)
    btn.BackgroundColor3 = T.Bg1
    btn.BackgroundTransparency = 0
    btn.Active = true
    btn.ZIndex = 100
    btn.Visible = false
    
    local saved = ButtonPositions[text]
    if saved then
        btn.Position = UDim2.new(saved.X, saved.XO, saved.Y, saved.YO)
    else
        local row = index
        local col = (side == "left") and 0 or 1
        btn.Position = UDim2.new(
            0.35 + col * 0.12, 0,
            0.30 + row * 0.09, 0
        )
    end
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = GetCornerForShape(SideButtonShape)
    table.insert(_allSideButtonCorners, { corner = corner, btn = btn })
    local stroke = applySpinningGoldStroke(btn, 2, 1.6)
    addBgShimmer(btn, 1.6, 0.85)
    
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1,-6,1,-6)
    lbl.Position = UDim2.new(0,3,0,3)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = T.TxS
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextWrapped = true
    
    local function RefreshVisual()
        local isActive = getState()
        btn.BackgroundColor3 = isActive and T.ON or T.Bg1
        lbl.TextColor3 = isActive and Color3.fromRGB(255,255,255) or T.TxS
    end
    
    local pressing = false
    local hasMoved = false
    local dragStart = nil
    local btnStart = nil
    local activeInputId = nil
    
    local function resetState()
        pressing = false
        hasMoved = false
        dragStart = nil
        btnStart = nil
        activeInputId = nil
        local bW = (SideButtonShape == "rect") and SideButtonWidth or SideButtonSize
        btn.Size = UDim2.new(0, bW, 0, SideButtonSize)
    end
    
    btn.InputBegan:Connect(function(input)
        local t = input.UserInputType
        if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
        if pressing then return end
        pressing = true
        hasMoved = false
        activeInputId = input
        dragStart = input.Position
        btnStart = btn.Position
    end)
    
    btn.InputChanged:Connect(function(input)
        if not pressing or input ~= activeInputId then return end
        local t = input.UserInputType
        if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseMovement then return end
        if not dragStart or not btnStart then return end
        local delta = input.Position - dragStart
        if delta.Magnitude > 8 then
            hasMoved = true
            btn.Position = UDim2.new(btnStart.X.Scale, btnStart.X.Offset + delta.X, btnStart.Y.Scale, btnStart.Y.Offset + delta.Y)
        end
    end)
    
    local function handleRelease()
        if not pressing then return end
        local didMove = hasMoved
        local savedPos = btn.Position
        resetState()
        if not didMove then
            local ok, err
            if getState() then
                if stopFn then ok, err = pcall(stopFn) end
            else
                if startFn then ok, err = pcall(startFn) end
            end
            if not ok and err then
                warn("[H2N SideBtn] "..tostring(text)..": "..tostring(err))
                Notify("ERR: "..tostring(text))
            end
            local isActive = getState()
            btn.BackgroundColor3 = isActive and T.ON or T.Bg1
            lbl.TextColor3 = isActive and Color3.fromRGB(255,255,255) or T.TxS
            if stateKey and sideButtonVisibility[stateKey] == true then
                btn.Visible = true
            end
        else
            ButtonPositions[text] = {X = savedPos.X.Scale, XO = savedPos.X.Offset, Y = savedPos.Y.Scale, YO = savedPos.Y.Offset}
            Save()
        end
    end
    
    btn.InputEnded:Connect(function(input)
        local t = input.UserInputType
        if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
        if input ~= activeInputId then return end
        handleRelease()
    end)
    
    UIS.InputEnded:Connect(function(input)
        if not pressing or input ~= activeInputId then return end
        local t = input.UserInputType
        if t ~= Enum.UserInputType.Touch and t ~= Enum.UserInputType.MouseButton1 then return end
        handleRelease()
    end)

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            task.delay(0.35, function()
                if pressing and not hasMoved then
                    handleRelease()
                end
            end)
        end
    end)
    
    RunService.RenderStepped:Connect(RefreshVisual)
    
    if stateKey then
        sideButtonRefs[stateKey] = function(state, fromMenu)
            sideButtonVisibility[stateKey] = state
            btn.Visible = state
            if not state and fromMenu then
                if stateKey == "AutoPlayLeft" and State.AutoPlayLeft then StopAutoPlayLeft()
                elseif stateKey == "AutoPlayRight" and State.AutoPlayRight then StopAutoPlayRight()
                elseif stateKey == "SpeedBoost" and isSpeedBoostEnabled then stopSpeedBoost()
                elseif stateKey == "FloatEnabled" and State.FloatEnabled then stopFloat()
                elseif stateKey == "AutoTPDown" and TPSettings.Enabled then ToggleAutoTPDown()
                elseif stateKey == "DesyncUltra" and DesyncState.enabled then stopDesync()
                end
            end
            RefreshVisual()
        end
        sideButtonRefreshOnly[stateKey] = function()
            RefreshVisual()
        end
    end
end

-- Create all side buttons
CreateSideButton("AUTO PLAY LEFT", "left", 0, function() return State.AutoPlayLeft end,
    function()
        if BatAimbotState.enabled then StopBatAimbot(); if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoBat then sideButtonRefreshOnly.AutoBat() end end
        StartAutoPlayLeft()
    end,
    StopAutoPlayLeft, "AutoPlayLeft")
    
CreateSideButton("AUTO PLAY RIGHT", "left", 1, function() return State.AutoPlayRight end,
    function()
        if BatAimbotState.enabled then StopBatAimbot(); if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoBat then sideButtonRefreshOnly.AutoBat() end end
        StartAutoPlayRight()
    end,
    StopAutoPlayRight, "AutoPlayRight")
    
CreateSideButton("DESYNC", "left", 2,
    function() return DesyncState.enabled end,
    function() startDesync() end,
    function() stopDesync() end,
    "DesyncUltra")
    
CreateSideButton("AUTO BAT", "right", 0,
    function() return BatAimbotState.enabled end,
    function()
        if State.AutoPlayLeft then StopAutoPlayLeft(); if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoPlayLeft then sideButtonRefreshOnly.AutoPlayLeft() end end
        if State.AutoPlayRight then StopAutoPlayRight(); if sideButtonRefreshOnly and sideButtonRefreshOnly.AutoPlayRight then sideButtonRefreshOnly.AutoPlayRight() end end
        StartBatAimbot()
    end,
    function() StopBatAimbot() end,
    "AutoBat")
    
CreateSideButton("SPEED BOOST", "right", 1, function() return isSpeedBoostEnabled end, ToggleSpeedBoost, ToggleSpeedBoost, "SpeedBoost")
CreateSideButton("AUTO TP DOWN", "right", 2, function() return TPSettings.Enabled end, ToggleAutoTPDown, ToggleAutoTPDown, "AutoTPDown")
CreateSideButton("FLOAT", "right", 3, function() return State.FloatEnabled end, ToggleFloat, ToggleFloat, "FloatEnabled")
CreateSideButton("DROP", "right", 4, function() return DropState.active end,
    function()
        _switchingModes = true
        if State.AutoPlayLeft then StopAutoPlayLeft() end
        if State.AutoPlayRight then StopAutoPlayRight() end
        _switchingModes = false
        if State.FloatEnabled then stopFloat() end
        executeDrop()
    end,
    function() end,
    "DROP")
    
CreateSideButton("TP DOWN", "right", 5,
    function() return false end,
    function() ExecuteTPDown() end,
    function() end,
    "TPDown")

-- INITIALIZATION
RunService.Heartbeat:Connect(function(dt)
    if State.AntiSentry then updateAntiSentry() end
    if State.ESP then updateESP() end
end)

Load()
initWPParts()
stealBarFrame.Visible = StealBarVisible
menu.Size = UDim2.new(0, menuW, 0, menuH)

ApplyShapeToAllSideButtons("rect")

for _, b in pairs(gui:GetChildren()) do
    if b:IsA("Frame") and b.Name == "SideButton" then
        local btnW = (SideButtonShape == "rect") and SideButtonWidth or SideButtonSize
        b.Size = UDim2.new(0, btnW, 0, SideButtonSize)
        local id = b:GetAttribute("ID")
        local sp = ButtonPositions[id]
        if sp then b.Position = UDim2.new(sp.X, sp.XO, sp.Y, sp.YO) end
        local corner = b:FindFirstChildOfClass("UICorner")
        if corner then corner.CornerRadius = GetCornerForShape(SideButtonShape) end
        local keyMap = {
            ["AUTO PLAY LEFT"]  = "AutoPlayLeft",
            ["AUTO PLAY RIGHT"] = "AutoPlayRight",
            ["SPEED BOOST"]     = "SpeedBoost",
            ["AUTO TP DOWN"]    = "AutoTPDown",
            ["FLOAT"]           = "FloatEnabled",
            ["DROP"]            = "DROP",
            ["DESYNC"]          = "DesyncUltra",
            ["AUTO BAT"]        = "AutoBat",
            ["TP DOWN"]         = "TPDown",
        }
        local key = keyMap[id]
        if key and sideButtonVisibility[key] == true then
            b.Visible = true
        else
            b.Visible = false
        end
    end
end

task.spawn(function()
    task.wait(1)
    setupDamageTracking()
end)

task.spawn(function()
    while not (LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and LP.Character:FindFirstChildOfClass("Humanoid")) do
        task.wait(0.2)
    end
    task.wait(0.5)
    
    local savedSentry = State.AntiSentry
    local savedSpin = State.SpinBody
    local savedRagdoll = State.AntiRagdoll
    local savedJump = State.InfiniteJump
    local savedFloat = State.FloatEnabled
    local savedXray = State.XrayBase
    local savedESP = State.ESP
    local savedSpeed = isSpeedBoostEnabled
    local savedAutoLeft = State.AutoPlayLeft
    local savedAutoRight = State.AutoPlayRight
    local savedGrab = EnhancedGrab.Enabled
    local savedPCGrab = PCGrab.Enabled
    local savedUnwalk = UnwalkState.active
    local savedTP = TPSettings.Enabled
    local savedOptimizer = State.Optimizer
    local savedHitCircle = HitCircleState.Enabled
    local savedSpamBat = SpamBatState.enabled
    local savedBatAimbot = BatAimbotState.enabled
    local savedDesync = DesyncState.enabled
    
    State.AntiSentry = false
    State.SpinBody = false
    State.InfiniteJump = false
    State.FloatEnabled = false
    State.XrayBase = false
    State.ESP = false
    State.AntiRagdoll = false
    State.AutoPlayLeft = false
    State.AutoPlayRight = false
    State.Optimizer = false
    isSpeedBoostEnabled = false
    EnhancedGrab.Enabled = false
    PCGrab.Enabled = false
    TPSettings.Enabled = false
    HitCircleState.Enabled = false
    SpamBatState.enabled = false
    if BatAimbotState.enabled then StopBatAimbot() end
    if UnwalkState.active then stopUnwalk() end
    if DesyncState.enabled then stopDesync() end
    StopTPMonitoring()
    
    local function safeStart(fn, name)
        task.spawn(function() pcall(function() fn(); print("Auto-activated: "..name) end) end)
        task.wait(0.05)
    end
    
    if savedSentry then safeStart(StartAntiSentry, "Anti Sentry") end
    if savedSpin then safeStart(StartSpinBody, "Spin Body") end
    if savedRagdoll then safeStart(StartAntiRagdoll, "Anti Ragdoll") end
    if savedJump then safeStart(StartInfiniteJump, "Infinite Jump") end
    if savedFloat then safeStart(startFloat, "Float") end
    if savedXray then safeStart(StartXrayBase, "Xray Base") end
    if savedESP then safeStart(StartESP, "ESP") end
    if savedSpeed then safeStart(startSpeedBoost, "Speed Boost") end
    if savedOptimizer then safeStart(startOptimizer, "Anti Lag")
    elseif isMobile and not savedOptimizer then safeStart(startOptimizer, "Anti Lag (Auto Mobile)") end
    if savedHitCircle then safeStart(StartHitCircle, "Hit Circle") end
    if savedSpamBat then safeStart(StartSpamBat, "Spam Bat") end
    if savedBatAimbot then safeStart(StartBatAimbot, "Auto Bat") end
    if savedDesync then safeStart(startDesync, "Desync Ultra") end
    
    _switchingModes = true
    if savedAutoLeft then safeStart(StartAutoPlayLeft, "Auto Play Left") end
    if savedAutoRight then safeStart(StartAutoPlayRight, "Auto Play Right") end
    if savedGrab then safeStart(StartEnhancedGrab, "Auto Grab") end
    if savedPCGrab then safeStart(StartPCGrab, "Auto Grab PC") end
    _switchingModes = false
    
    if savedUnwalk then safeStart(startUnwalk, "Unwalk") end
    if savedTP then
        TPSettings.Enabled = true
        StartTPMonitoring()
    end
    
    task.wait(0.3)
    local _idToKey = {
        ["AUTO PLAY LEFT"] = "AutoPlayLeft",
        ["AUTO PLAY RIGHT"] = "AutoPlayRight",
        ["FLOAT"] = "FloatEnabled",
        ["SPEED BOOST"] = "SpeedBoost",
        ["AUTO TP DOWN"] = "AutoTPDown",
        ["DESYNC"] = "DesyncUltra",
        ["AUTO BAT"] = "AutoBat",
        ["TP DOWN"] = "TPDown",
    }
    for _, b in pairs(gui:GetChildren()) do
        if b:IsA("Frame") and b.Name == "SideButton" then
            local id = b:GetAttribute("ID")
            local key = _idToKey[id]
            if key then
                local isOn = false
                if id == "AUTO PLAY LEFT" then isOn = State.AutoPlayLeft
                elseif id == "AUTO PLAY RIGHT" then isOn = State.AutoPlayRight
                elseif id == "FLOAT" then isOn = State.FloatEnabled
                elseif id == "SPEED BOOST" then isOn = isSpeedBoostEnabled
                elseif id == "AUTO TP DOWN" then isOn = TPSettings.Enabled
                elseif id == "DESYNC" then isOn = DesyncState.enabled
                elseif id == "AUTO BAT" then isOn = BatAimbotState.enabled
                end
                b.BackgroundColor3 = isOn and T.ON or T.Bg1
                b.Visible = sideButtonVisibility[key] == true
            end
        end
    end
    
    task.wait(0.2)
    if toggleUpdaters["AntiRagdoll"] then toggleUpdaters["AntiRagdoll"](State.AntiRagdoll) end
    if toggleUpdaters["InfiniteJump"] then toggleUpdaters["InfiniteJump"](State.InfiniteJump) end
    if toggleUpdaters["AutoGrab"] then toggleUpdaters["AutoGrab"](EnhancedGrab.Enabled) end
    if toggleUpdaters["AntiSentry"] then toggleUpdaters["AntiSentry"](State.AntiSentry) end
    if toggleUpdaters["SpinBody"] then toggleUpdaters["SpinBody"](State.SpinBody) end
    if toggleUpdaters["XrayBase"] then toggleUpdaters["XrayBase"](State.XrayBase) end
    if toggleUpdaters["ESP"] then toggleUpdaters["ESP"](State.ESP) end
    if toggleUpdaters["Unwalk"] then toggleUpdaters["Unwalk"](UnwalkState.active) end
    if toggleUpdaters["Optimizer"] then toggleUpdaters["Optimizer"](State.Optimizer) end
    if toggleUpdaters["HitCircle"] then toggleUpdaters["HitCircle"](HitCircleState.Enabled) end
    if toggleUpdaters["SpamBat"] then toggleUpdaters["SpamBat"](SpamBatState.enabled) end
    if toggleUpdaters["AutoBat"] then toggleUpdaters["AutoBat"](sideButtonVisibility["AutoBat"] == true) end
    if toggleUpdaters["DesyncUltra"] then toggleUpdaters["DesyncUltra"](sideButtonVisibility["DesyncUltra"] == true) end
    
    local _sideKeys = {"AutoPlayLeft","AutoPlayRight","SpeedBoost","FloatEnabled","AutoTPDown","DROP","DesyncUltra","AutoBat","TPDown"}
    for _, key in ipairs(_sideKeys) do
        if toggleUpdaters[key] then
            toggleUpdaters[key](sideButtonVisibility[key] == true)
        end
    end
end)

Notify("H2N v6.1 DESYNC ULTRA LOADED")
print("===============================================================")
print("H2N v6.1 - DESYNC ULTRA (PC + Mobile) - No Carpet Needed")
print("===============================================================")