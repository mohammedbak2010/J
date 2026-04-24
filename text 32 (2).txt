repeat task.wait() until game:IsLoaded()
pcall(function() setfpscap(999) end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local VisualSetters = {}
local mobileButtonContainer
local apMain
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local NORMAL_SPEED = 60
local CARRY_SPEED = 30
local LAGGER_SPEED = 15
local FOV_VALUE = 70
local UI_SCALE = isMobile and 0.65 or 1.0
local function getMobileOptimized(pcValue, mobileValue)
    return isMobile and mobileValue or pcValue
end
local lastNoclipUpdate = 0
RunService.Stepped:Connect(function()
    local now = tick()
    if now - lastNoclipUpdate < 0.1 then return end
    lastNoclipUpdate = now
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end
end)
local speedToggled = false
local fastestStealEnabled = false
local laggerToggled = false
local autoBatToggled = false
local hittingCooldown = false
local fullAutoPlayEnabled = false
local fullAutoPlayConn = nil
local fullAutoPlayLeftEnabled = false
local fullAutoPlayRightEnabled = false
local fullAutoPlayLeftConn = nil
local fullAutoPlayRightConn = nil
local fullAutoLeftSetter = nil
local fullAutoRightSetter = nil
local brainrotReturnLeftEnabled = false
local brainrotReturnRightEnabled = false
local brainrotReturnCooldown = false
local lastKnownHealth = 100
local G_myPlotSide = nil
local G_myPlotName = nil
local G_tpAutoEnabled = false
local G_autoPlayAfterTP = false
local G_countdownActive = false
local ultraModeEnabled = false
local autoSwingEnabled = false
local noCamCollisionEnabled = false
local noCamCollisionConn = nil
local noCamParts = {}
local _antiLagDescConn = nil
local lastBatSwing = 0
local BAT_SWING_COOLDOWN = 0.12
local SPAWN_DETECT_RADIUS = 40
local COUNTDOWN_TARGET = 4.9
local SPAWN_Z_RIGHT_THRESHOLD = 60
local SPAWN_LEFT = Vector3.new(-466.429901, 0, 113.553757)
local SPAWN_RIGHT = Vector3.new(-466.42984, 0, 6.55357218)
local AP_Offsets = {{x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0}}
local APR_Offsets = {{x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0},{x=0,y=0,z=0}}
local BR_L2 = Vector3.new(-475.5, -3.75, 100.5)
local BR_L3 = Vector3.new(-486.5, -3.75, 100.5)
local BR_R2 = Vector3.new(-475.50, -3.95, 17.55)
local BR_R3 = Vector3.new(-486.76, -3.95, 17.55)
local Keybinds = {
    AutoBat = Enum.KeyCode.E,
    SpeedToggle = Enum.KeyCode.Q,
    LaggerToggle = Enum.KeyCode.R,
    InfiniteJump = Enum.KeyCode.M,
    UIToggle = Enum.KeyCode.U,
    DropBrainrot = Enum.KeyCode.X,
    FloatToggle = Enum.KeyCode.J,
    FullAutoLeft = Enum.KeyCode.G,
    FullAutoRight = Enum.KeyCode.H,
    TPDown = Enum.KeyCode.F,
}
local isStealing = false
local stealStartTime = nil
local StealData = {}
local lastStealTick = 0
local plotCache = {}
local plotCacheTime = {}
local cachedPrompts = {}
local promptCacheTime = 0
local Settings = {
    AutoStealEnabled = false,
    StealRadius = 20,
    StealDuration = 0.25,
}
local Values = {
    STEAL_RADIUS = 20,
    STEAL_DURATION = 0.2,
    STEAL_COOLDOWN = 0.1,
    PLOT_CACHE_DURATION = 2,
    PROMPT_CACHE_REFRESH = 0.15,
    DEFAULT_GRAVITY = 196.2,
    GalaxyGravityPercent = 70,
    HOP_POWER = 35,
    HOP_COOLDOWN = 0.08,
}
local function detectMyPlot()
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil, nil end
    local myName = LocalPlayer.DisplayName or LocalPlayer.Name
    for _, plot in ipairs(plots:GetChildren()) do
        local ok, result = pcall(function()
            local sign = plot:FindFirstChild("PlotSign"); if not sign then return nil end
            local sg = sign:FindFirstChild("SurfaceGui"); if not sg then return nil end
            local fr = sg:FindFirstChild("Frame"); if not fr then return nil end
            local tl = fr:FindFirstChild("TextLabel"); if not tl then return nil end
            if tl.Text:find(myName, 1, true) then
                local spawnObj = plot:FindFirstChild("Spawn")
                if spawnObj then
                    local z = spawnObj.CFrame.Position.Z
                    return z < SPAWN_Z_RIGHT_THRESHOLD and "left" or "right"
                end
            end
            return nil
        end)
        if ok and result then return result, plot.Name end
    end
    return nil, nil
end
local function refreshMyPlotSide()
    local side, plotName = detectMyPlot()
    G_myPlotSide = side; G_myPlotName = plotName
    return side
end
task.spawn(function()
    while true do
        task.wait(2)
        if G_tpAutoEnabled then refreshMyPlotSide() end
    end
end)
task.spawn(function()
    local plots = workspace:WaitForChild("Plots", 30); if not plots then return end
    local myName = LocalPlayer.DisplayName or LocalPlayer.Name
    local function watchPlot(plot)
        pcall(function()
            local tl = plot:WaitForChild("PlotSign",5):WaitForChild("SurfaceGui",5):WaitForChild("Frame",5):WaitForChild("TextLabel",5)
            if not tl then return end
            tl:GetPropertyChangedSignal("Text"):Connect(function() refreshMyPlotSide() end)
            if tl.Text:find(myName, 1, true) then refreshMyPlotSide() end
        end)
    end
    for _, plot in ipairs(plots:GetChildren()) do task.spawn(watchPlot, plot) end
    plots.ChildAdded:Connect(function(plot) task.spawn(watchPlot, plot) end)
end)
local function calculateFastestStealSpeed()
    local char = LocalPlayer.Character; if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    local targetPos = nil
    if fullAutoPlayLeftEnabled then
        local pts = {FAP_L1, FAP_L2, FAP_L3, FAP_L4, FAP_L5}
        local phase = FAP_LeftPhase
        if type(phase) ~= "number" or phase < 1 then phase = 1 end
        if phase > 5 then phase = 5 end
        targetPos = pts[phase]
    elseif fullAutoPlayRightEnabled then
        local pts = {FAP_R1, FAP_R2, FAP_R3, FAP_R4, FAP_R5}
        local phase = FAP_RightPhase
        if type(phase) ~= "number" or phase < 1 then phase = 1 end
        if phase > 5 then phase = 5 end
        targetPos = pts[phase]
    else
        return nil
    end
    if not targetPos then return end
    local dist = Vector3.new(targetPos.X - hrp.Position.X, 0, targetPos.Z - hrp.Position.Z).Magnitude
    if dist < 0.1 then return end
    local requiredSpeed = math.clamp(dist / 1.65, 1, 9999)
    return requiredSpeed
end
RunService.Heartbeat:Connect(function()
    if not fastestStealEnabled then return end
    if not (fullAutoPlayLeftEnabled or fullAutoPlayRightEnabled) then return end
    local char = LocalPlayer.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local md = hum.MoveDirection; if md.Magnitude == 0 then return end
    local spd = calculateFastestStealSpeed()
    if spd then
        hrp.AssemblyLinearVelocity = Vector3.new(md.X * spd, hrp.AssemblyLinearVelocity.Y, md.Z * spd)
    end
end)
local function syncStealSettings()
    Values.STEAL_RADIUS = Settings.StealRadius
    Values.STEAL_DURATION = Settings.StealDuration
    Settings.StealRadius = Values.STEAL_RADIUS
    Settings.StealDuration = Values.STEAL_DURATION
end
local STEAL_COOLDOWN = Values.STEAL_COOLDOWN
local PLOT_CACHE_DURATION = Values.PLOT_CACHE_DURATION
local PROMPT_CACHE_REFRESH = Values.PROMPT_CACHE_REFRESH
local Enabled = {
    AntiRagdoll = false,
    AutoSteal = false,
    InfiniteJump = false,
    ShinyGraphics = false,
    Optimizer = false,
    Unwalk = false,
    RemoveAccessories = false,
}
local Connections = {}
local originalTransparency = {}
local savedAnimations = {}
local xrayEnabled = false
local h, hrp, speedLbl
local progressConnection = nil
local gui, main
local speedSwBg, speedSwCircle
local laggerSwBg, laggerSwCircle
local batSwBg, batSwCircle
local waitingForKey = nil
local function getHRP()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart")
end
local function isMyPlotByName(plotName)
    local currentTime = tick()
    if plotCache[plotName] and (currentTime - (plotCacheTime[plotName] or 0)) < PLOT_CACHE_DURATION then
        return plotCache[plotName]
    end
    local plots = workspace:FindFirstChild("Plots")
    if not plots then plotCache[plotName]=false; plotCacheTime[plotName]=currentTime; return false end
    local plot = plots:FindFirstChild(plotName)
    if not plot then plotCache[plotName]=false; plotCacheTime[plotName]=currentTime; return false end
    local sign = plot:FindFirstChild("PlotSign")
    if sign then
        local yourBase = sign:FindFirstChild("YourBase")
        if yourBase and yourBase:IsA("BillboardGui") then
            local result = yourBase.Enabled == true
            plotCache[plotName]=result; plotCacheTime[plotName]=currentTime
            return result
        end
    end
    plotCache[plotName]=false; plotCacheTime[plotName]=currentTime
    return false
end
local function findNearestPrompt()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local currentTime = tick()
    if currentTime - promptCacheTime < PROMPT_CACHE_REFRESH and #cachedPrompts > 0 then
        local nearestPrompt, nearestDist, nearestName = nil, math.huge, nil
        for _, data in ipairs(cachedPrompts) do
            if data.spawn then
                local dist = (data.spawn.Position - root.Position).Magnitude
                if dist <= Settings.StealRadius and dist < nearestDist then
                    nearestPrompt = data.prompt; nearestDist = dist; nearestName = data.name
                end
            end
        end
        if nearestPrompt then return nearestPrompt, nearestDist, nearestName end
    end
    cachedPrompts = {}; promptCacheTime = currentTime
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end
    local nearestPrompt, nearestDist, nearestName = nil, math.huge, nil
    for _, plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then continue end
        for _, podium in ipairs(podiums:GetChildren()) do
            pcall(function()
                local base = podium:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist = (spawn.Position - root.Position).Magnitude
                    local att = spawn:FindFirstChild("PromptAttachment")
                    if att then
                        for _, ch in ipairs(att:GetChildren()) do
                            if ch:IsA("ProximityPrompt") then
                                table.insert(cachedPrompts, {prompt=ch, spawn=spawn, name=podium.Name})
                                if dist <= Settings.StealRadius and dist < nearestDist then
                                    nearestPrompt=ch; nearestDist=dist; nearestName=podium.Name
                                end
                                break
                            end
                        end
                    end
                end
            end)
        end
    end
    return nearestPrompt, nearestDist, nearestName
end
local ProgressLabel, ProgressPercentLabel, ProgressBarFill, RadiusInput, DurationInput
local function ResetProgressBar()
    if ProgressLabel then ProgressLabel.Text = "READY" end
    if ProgressPercentLabel then ProgressPercentLabel.Text = "" end
    if ProgressBarFill then ProgressBarFill.Size = UDim2.new(0,0,1,0) end
end
local function executeSteal(prompt, name)
    local currentTime = tick()
    if currentTime - lastStealTick < STEAL_COOLDOWN then return end
    if isStealing then return end
    if not StealData[prompt] then
        StealData[prompt] = {hold={}, trigger={}, ready=true}
        pcall(function()
            if getconnections then
                for _, c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(StealData[prompt].hold, c.Function) end
                end
                for _, c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(StealData[prompt].trigger, c.Function) end
                end
            else StealData[prompt].useFallback = true end
        end)
    end
    local data = StealData[prompt]
    if not data.ready then return end
    data.ready=false; isStealing=true; stealStartTime=currentTime; lastStealTick=currentTime
    if ProgressLabel then ProgressLabel.Text = name or "STEALING..." end
    if progressConnection then progressConnection:Disconnect() end
    progressConnection = RunService.Heartbeat:Connect(function()
        if not isStealing then progressConnection:Disconnect(); return end
        local prog = math.clamp((tick()-stealStartTime)/Settings.StealDuration, 0, 1)
        if ProgressBarFill then ProgressBarFill.Size = UDim2.new(prog,0,1,0) end
        if ProgressPercentLabel then ProgressPercentLabel.Text = math.floor(prog*100).."%" end
    end)
    task.spawn(function()
        local ok = false
        pcall(function()
            if not data.useFallback then
                for _, f in ipairs(data.hold) do task.spawn(f) end
                task.wait(Settings.StealDuration)
                for _, f in ipairs(data.trigger) do task.spawn(f) end
                ok=true
            end
        end)
        if not ok and fireproximityprompt then
            pcall(function() fireproximityprompt(prompt); ok=true end)
        end
        if not ok then
            pcall(function()
                prompt:InputHoldBegin(); task.wait(Settings.StealDuration); prompt:InputHoldEnd(); ok=true
            end)
        end
        task.wait(Settings.StealDuration * 0.3)
        if progressConnection then progressConnection:Disconnect() end
        ResetProgressBar()
        task.wait(0.05)
        data.ready=true; isStealing=false
    end)
end
local function startAutoSteal()
    if Connections.autoSteal then return end
    Connections.autoSteal = RunService.Heartbeat:Connect(function()
        if not Enabled.AutoSteal or isStealing then return end
        local p,_,n = findNearestPrompt()
        if p then
            local char = LocalPlayer.Character
            local hrpLocal = char and char:FindFirstChild("HumanoidRootPart")
            if hrpLocal then
                hrpLocal.AssemblyLinearVelocity = Vector3.new(0, hrpLocal.AssemblyLinearVelocity.Y, 0)
            end
            executeSteal(p,n)
        end
    end)
end
local function stopAutoSteal()
    if Connections.autoSteal then Connections.autoSteal:Disconnect(); Connections.autoSteal=nil end
    isStealing=false; lastStealTick=0
    plotCache={}; plotCacheTime={}; cachedPrompts={}
    ResetProgressBar()
end
local function startAntiRagdoll()
    if Connections.antiRagdoll then return end
    Connections.antiRagdoll = RunService.Heartbeat:Connect(function()
        if not Enabled.AntiRagdoll then return end
        local char = LocalPlayer.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local st = hum:GetState()
            if st==Enum.HumanoidStateType.Physics or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.FallingDown then
                hum:ChangeState(Enum.HumanoidStateType.Running)
                workspace.CurrentCamera.CameraSubject = hum
                pcall(function()
                    local pm = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
                    if pm then require(pm:FindFirstChild("ControlModule")):Enable() end
                end)
                if root then root.Velocity=Vector3.new(0,0,0); root.RotVelocity=Vector3.new(0,0,0) end
            end
        end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled=true end
        end
    end)
end
local function stopAntiRagdoll()
    if Connections.antiRagdoll then Connections.antiRagdoll:Disconnect(); Connections.antiRagdoll=nil end
end
local IJ_JumpConn = nil
local IJ_FallConn = nil
local function startInfiniteJump()
    if IJ_JumpConn then IJ_JumpConn:Disconnect() end
    if IJ_FallConn then IJ_FallConn:Disconnect() end
    IJ_JumpConn = UserInputService.JumpRequest:Connect(function()
        if not Enabled.InfiniteJump then return end
        local char = LocalPlayer.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then root.Velocity = Vector3.new(root.Velocity.X, 55, root.Velocity.Z) end
    end)
    IJ_FallConn = RunService.Heartbeat:Connect(function()
        if not Enabled.InfiniteJump then return end
        local char = LocalPlayer.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root and root.Velocity.Y < -120 then
            root.Velocity = Vector3.new(root.Velocity.X, -120, root.Velocity.Z)
        end
    end)
end
local function stopInfiniteJump()
    if IJ_JumpConn then IJ_JumpConn:Disconnect(); IJ_JumpConn = nil end
    if IJ_FallConn then IJ_FallConn:Disconnect(); IJ_FallConn = nil end
end
local function startUnwalk()
    local c = LocalPlayer.Character; if not c then return end
    local hum = c:FindFirstChildOfClass("Humanoid")
    if hum then for _,t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    local anim = c:FindFirstChild("Animate")
    if anim then savedAnimations.Animate=anim:Clone(); anim:Destroy() end
end
local function stopUnwalk()
    local c = LocalPlayer.Character
    if c and savedAnimations.Animate then savedAnimations.Animate:Clone().Parent=c; savedAnimations.Animate=nil end
end
local function applyAntiLag(ultra)
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    Lighting.Brightness = 1
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0
    for _, e in pairs(Lighting:GetChildren()) do
        if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect")
            or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = false end
    end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            if ultra then obj.CastShadow = false end
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            if ultra then obj:Destroy() else obj.Transparency = 1 end
        elseif ultra and (obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire")) then
            obj.Enabled = false
        end
    end
    if ultra then pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end) end
end
local function enableOptimizer()
    Enabled.Optimizer = true
    applyAntiLag(false)
    if _antiLagDescConn then _antiLagDescConn:Disconnect() end
    _antiLagDescConn = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("BasePart") then obj.Material = Enum.Material.Plastic; obj.Reflectance = 0
        elseif obj:IsA("Decal") or obj:IsA("Texture") then obj.Transparency = 1 end
    end)
end
local function disableOptimizer()
    Enabled.Optimizer = false
    if _antiLagDescConn then _antiLagDescConn:Disconnect(); _antiLagDescConn = nil end
end
local function enableUltraMode()
    ultraModeEnabled = true
    applyAntiLag(true)
end
local function disableUltraMode()
    ultraModeEnabled = false
end
local removedAccessories = {}
local function removeAccessories()
    if Enabled.RemoveAccessories then
        local char = LocalPlayer.Character
        if not char then return end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("Accessory") or obj:IsA("Hat") then
                if not removedAccessories[obj] then
                    removedAccessories[obj] = true
                    obj:Destroy()
                end
            end
        end
    end
end
local function startRemoveAccessories()
    Enabled.RemoveAccessories = true
    removeAccessories()
    if not Connections.removeAccessories then
        Connections.removeAccessories = LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Enabled.RemoveAccessories then removeAccessories() end
        end)
    end
end
local function stopRemoveAccessories()
    Enabled.RemoveAccessories = false
    if Connections.removeAccessories then
        Connections.removeAccessories:Disconnect()
        Connections.removeAccessories = nil
    end
    removedAccessories = {}
end
local dropBrainrotActive = false
local DROP_ASCEND_DURATION = 0.2
local DROP_ASCEND_SPEED = 150
local setDropBrainrotVisual = nil
local dropMobileSetter = nil
local function runDropBrainrot()
    if dropBrainrotActive then return end
    local char = LocalPlayer.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    dropBrainrotActive = true
    local t0 = tick()
    local dc
    dc = RunService.Heartbeat:Connect(function()
        local r = char and char:FindFirstChild("HumanoidRootPart")
        if not r then
            dc:Disconnect(); dropBrainrotActive = false
            if setDropBrainrotVisual then setDropBrainrotVisual(false) end
            if dropMobileSetter then dropMobileSetter(false) end
            return
        end
        if tick() - t0 >= DROP_ASCEND_DURATION then
            dc:Disconnect()
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {char}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local rr = workspace:Raycast(r.Position, Vector3.new(0,-2000,0), rp)
            if rr then
                local hum2 = char:FindFirstChildOfClass("Humanoid")
                local off = (hum2 and hum2.HipHeight or 2) + (r.Size.Y/2)
                r.CFrame = CFrame.new(r.Position.X, rr.Position.Y+off, r.Position.Z)
                r.AssemblyLinearVelocity = Vector3.new(0,0,0)
            end
            dropBrainrotActive = false
            if setDropBrainrotVisual then setDropBrainrotVisual(false) end
            if dropMobileSetter then dropMobileSetter(false) end
            return
        end
        r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, DROP_ASCEND_SPEED, r.AssemblyLinearVelocity.Z)
    end)
end
local floatEnabled = false
local floatHeight = 9.5
local function enableNoCameraCollision()
    noCamCollisionEnabled = true
    if noCamCollisionConn then noCamCollisionConn:Disconnect() end
    noCamCollisionConn = RunService.RenderStepped:Connect(function()
        if not noCamCollisionEnabled then return end
        local ch = LocalPlayer.Character; if not ch then return end
        local cam = workspace.CurrentCamera; if not cam then return end
        local hrpLocal = ch:FindFirstChild("HumanoidRootPart"); if not hrpLocal then return end
        local camPos = cam.CFrame.Position
        local charPos = hrpLocal.Position + Vector3.new(0, 1.5, 0)
        local toChar = charPos - camPos
        local dist = toChar.Magnitude
        if dist < 0.3 then return end
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {ch}
        params.IgnoreWater = true
        local hit = {}
        local origin = camPos
        local remaining = toChar
        for _ = 1, 12 do
            if remaining.Magnitude < 0.2 then break end
            local res = workspace:Raycast(origin, remaining, params)
            if not res then break end
            local p = res.Instance
            if p and p:IsA("BasePart") and not p:IsDescendantOf(ch) then
                hit[p] = true
                if noCamParts[p] == nil then noCamParts[p] = p.LocalTransparencyModifier end
                p.LocalTransparencyModifier = 1
            end
            origin = res.Position + remaining.Unit * 0.02
            remaining = charPos - origin
        end
        for p, orig in pairs(noCamParts) do
            if not hit[p] then
                pcall(function()
                    if p and p.Parent then p.LocalTransparencyModifier = orig end
                end)
                noCamParts[p] = nil
            end
        end
    end)
end
local function disableNoCameraCollision()
    noCamCollisionEnabled = false
    if noCamCollisionConn then noCamCollisionConn:Disconnect(); noCamCollisionConn = nil end
    for p, orig in pairs(noCamParts) do
        pcall(function() if p and p.Parent then p.LocalTransparencyModifier = orig end end)
    end
    noCamParts = {}
end
local function startFloat()
    if Connections.float then Connections.float:Disconnect() end
    Connections.float = RunService.Heartbeat:Connect(function()
        if not floatEnabled then return end
        local char = LocalPlayer.Character; if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {char}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local rr = workspace:Raycast(root.Position, Vector3.new(0,-200,0), rp)
        if rr then
            local diff = (rr.Position.Y + floatHeight) - root.Position.Y
            if math.abs(diff) > 0.3 then
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, diff*15, root.AssemblyLinearVelocity.Z)
            else
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
            end
        end
    end)
end
local function stopFloat()
    if Connections.float then Connections.float:Disconnect(); Connections.float = nil end
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z) end
    end
end
local animHeartbeatConn = nil
local originalAnims = nil
local harderHitAnimEnabled = false
local Anims = {
    idle1="rbxassetid://133806214992291",idle2="rbxassetid://94970088341563",
    walk="rbxassetid://707897309",run="rbxassetid://707861613",
    jump="rbxassetid://116936326516985",fall="rbxassetid://116936326516985",
    climb="rbxassetid://116936326516985",swim="rbxassetid://116936326516985",
    swimidle="rbxassetid://116936326516985",
}
local function saveOriginalAnims(char)
    local animate = char:FindFirstChild("Animate"); if not animate then return end
    local function g(obj) return obj and obj.AnimationId or nil end
    originalAnims = {
        idle1=g(animate.idle and animate.idle.Animation1),idle2=g(animate.idle and animate.idle.Animation2),
        walk=g(animate.walk and animate.walk.WalkAnim),run=g(animate.run and animate.run.RunAnim),
        jump=g(animate.jump and animate.jump.JumpAnim),fall=g(animate.fall and animate.fall.FallAnim),
        climb=g(animate.climb and animate.climb.ClimbAnim),swim=g(animate.swim and animate.swim.Swim),
        swimidle=g(animate.swimidle and animate.swimidle.SwimIdle),
    }
end
local function applyAnimPack(char)
    local animate = char:FindFirstChild("Animate"); if not animate then return end
    local function s(obj, id) if obj then obj.AnimationId = id end end
    s(animate.idle and animate.idle.Animation1, Anims.idle1)
    s(animate.idle and animate.idle.Animation2, Anims.idle2)
    s(animate.walk and animate.walk.WalkAnim, Anims.walk)
    s(animate.run and animate.run.RunAnim, Anims.run)
    s(animate.jump and animate.jump.JumpAnim, Anims.jump)
    s(animate.fall and animate.fall.FallAnim, Anims.fall)
    s(animate.climb and animate.climb.ClimbAnim, Anims.climb)
    s(animate.swim and animate.swim.Swim, Anims.swim)
    s(animate.swimidle and animate.swimidle.SwimIdle, Anims.swimidle)
end
local function restoreOriginalAnims(char)
    if not originalAnims then return end
    local animate = char:FindFirstChild("Animate"); if not animate then return end
    local function s(obj, id) if obj and id then obj.AnimationId = id end end
    s(animate.idle and animate.idle.Animation1, originalAnims.idle1)
    s(animate.idle and animate.idle.Animation2, originalAnims.idle2)
    s(animate.walk and animate.walk.WalkAnim, originalAnims.walk)
    s(animate.run and animate.run.RunAnim, originalAnims.run)
    s(animate.jump and animate.jump.JumpAnim, originalAnims.jump)
    s(animate.fall and animate.fall.FallAnim, originalAnims.fall)
    s(animate.climb and animate.climb.ClimbAnim, originalAnims.climb)
    s(animate.swim and animate.swim.Swim, originalAnims.swim)
    s(animate.swimidle and animate.swimidle.SwimIdle, originalAnims.swimidle)
    local hum2 = char:FindFirstChildOfClass("Humanoid")
    if hum2 then for _, t in ipairs(hum2:GetPlayingAnimationTracks()) do t:Stop(0) end end
end
local function startHarderHitAnim()
    if animHeartbeatConn then animHeartbeatConn:Disconnect(); animHeartbeatConn = nil end
    local char = LocalPlayer.Character
    if char then
        saveOriginalAnims(char); applyAnimPack(char)
        local hum2 = char:FindFirstChildOfClass("Humanoid")
        if hum2 then for _, t in ipairs(hum2:GetPlayingAnimationTracks()) do t:Stop(0) end end
    end
    animHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not harderHitAnimEnabled then return end
        local c = LocalPlayer.Character
        if c then applyAnimPack(c) end
    end)
end
local function stopHarderHitAnim()
    if animHeartbeatConn then animHeartbeatConn:Disconnect(); animHeartbeatConn = nil end
    local char = LocalPlayer.Character
    if char then restoreOriginalAnims(char) end
end
local MEDUSA_COOLDOWN = 25
local medusaLastUsed = 0
local medusaDebounce = false
local medusaCounterEnabled = false
local medusaAnchorConns = {}
local function findMedusa()
    local char = LocalPlayer.Character; if not char then return nil end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local tn = tool.Name:lower()
            if tn:find("medusa") or tn:find("head") or tn:find("stone") then return tool end
        end
    end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") then
                local tn = tool.Name:lower()
                if tn:find("medusa") or tn:find("head") or tn:find("stone") then return tool end
            end
        end
    end
    return nil
end
local function useMedusaCounter()
    if medusaDebounce then return end
    if tick() - medusaLastUsed < MEDUSA_COOLDOWN then return end
    local char = LocalPlayer.Character; if not char then return end
    medusaDebounce = true
    local med = findMedusa()
    if not med then medusaDebounce = false; return end
    if med.Parent ~= char then
        local hum2 = char:FindFirstChildOfClass("Humanoid")
        if hum2 then hum2:EquipTool(med) end
    end
    pcall(function() med:Activate() end)
    medusaLastUsed = tick(); medusaDebounce = false
end
local function stopMedusaCounter()
    for _, c in pairs(medusaAnchorConns) do pcall(function() c:Disconnect() end) end
    medusaAnchorConns = {}
end
local function setupMedusaCounter(char)
    stopMedusaCounter(); if not char then return end
    local function onAnchorChanged(part)
        return part:GetPropertyChangedSignal("Anchored"):Connect(function()
            if medusaCounterEnabled and part.Anchored and part.Transparency == 1 then
                useMedusaCounter()
            end
        end)
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then table.insert(medusaAnchorConns, onAnchorChanged(part)) end
    end
    table.insert(medusaAnchorConns, char.DescendantAdded:Connect(function(part)
        if part:IsA("BasePart") then table.insert(medusaAnchorConns, onAnchorChanged(part)) end
    end))
end
local function doReturnTeleport(side)
    if brainrotReturnCooldown then return end
    brainrotReturnCooldown = true
    task.spawn(function()
        pcall(function()
            local c = LocalPlayer.Character
            if not c then return end
            local root = c:FindFirstChild("HumanoidRootPart")
            local hum = c:FindFirstChildOfClass("Humanoid")
            if not root then return end
            local rotation = (side == "right") and math.rad(180) or 0
            local step2 = (side == "right") and BR_R2 or BR_L2
            local step3 = (side == "right") and BR_R3 or BR_L3
            local function tp(pos)
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) * CFrame.Angles(0, rotation, 0)
                if hum then hum:ChangeState(Enum.HumanoidStateType.Running); hum:Move(Vector3.zero, false) end
                for _, obj in ipairs(c:GetDescendants()) do
                    if obj:IsA("Motor6D") and not obj.Enabled then obj.Enabled = true end
                end
            end
            tp(step2); task.wait(0.1); tp(step3)
        end)
        local _c = LocalPlayer.Character
        local _hum = _c and _c:FindFirstChildOfClass("Humanoid")
        if _hum then lastKnownHealth = _hum.Health end
        brainrotReturnCooldown = false
        if G_autoPlayAfterTP and G_myPlotSide then
            task.wait(0.3)
            local side2 = G_myPlotSide
            if fullAutoPlayLeftEnabled then stopFullAutoLeft(); fullAutoPlayLeftEnabled = false; if fullAutoLeftSetter then fullAutoLeftSetter(false) end end
            if fullAutoPlayRightEnabled then stopFullAutoRight(); fullAutoPlayRightEnabled = false; if fullAutoRightSetter then fullAutoRightSetter(false) end end
            task.wait(0.1)
            if side2 == "left" then
                fullAutoPlayLeftEnabled = true
                if fullAutoLeftSetter then fullAutoLeftSetter(true) end
                startFullAutoLeft()
                if VisualSetters.FullAuto then VisualSetters.FullAuto(true) end
            elseif side2 == "right" then
                fullAutoPlayRightEnabled = true
                if fullAutoRightSetter then fullAutoRightSetter(true) end
                startFullAutoRight()
                if VisualSetters.FullAuto then VisualSetters.FullAuto(true) end
            end
        end
    end)
end
RunService.Heartbeat:Connect(function()
    if not G_tpAutoEnabled then return end
    if brainrotReturnCooldown then return end
    if G_countdownActive then return end
    local char = LocalPlayer.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return end
    local hrpLocal = char:FindFirstChild("HumanoidRootPart")
    if hrpLocal and hrpLocal.Anchored then lastKnownHealth = hum.Health; return end
    local hp = hum.Health
    local st = hum:GetState()
    local rag = st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown
    local wasHit = hp < lastKnownHealth - 1; lastKnownHealth = hp
    if not (wasHit or rag) then return end
    if fullAutoPlayLeftEnabled then stopFullAutoLeft(); fullAutoPlayLeftEnabled = false; if fullAutoLeftSetter then fullAutoLeftSetter(false) end end
    if fullAutoPlayRightEnabled then stopFullAutoRight(); fullAutoPlayRightEnabled = false; if fullAutoRightSetter then fullAutoRightSetter(false) end end
    local side = G_myPlotSide
    if side == "left" then doReturnTeleport("left")
    elseif side == "right" then doReturnTeleport("right") end
end)
local function monitorCountdown(snd)
    if snd.Name ~= "Countdown" or not snd:IsA("Sound") then return end
    local triggered, conn = false, nil
    G_countdownActive = true
    conn = RunService.Heartbeat:Connect(function()
        if not snd or not snd.Parent or not snd.Playing then
            G_countdownActive = false
            if conn then conn:Disconnect(); conn = nil end; return
        end
        local ct = snd.TimePosition
        if ct >= COUNTDOWN_TARGET and not triggered then
            triggered = true; G_countdownActive = false
            if conn then conn:Disconnect(); conn = nil end
            if not G_tpAutoEnabled then return end
            local side = G_myPlotSide
            if not side then return end
            if fullAutoPlayLeftEnabled then stopFullAutoLeft(); fullAutoPlayLeftEnabled = false; if fullAutoLeftSetter then fullAutoLeftSetter(false) end end
            if fullAutoPlayRightEnabled then stopFullAutoRight(); fullAutoPlayRightEnabled = false; if fullAutoRightSetter then fullAutoRightSetter(false) end end
            task.wait(0.1)
            if side == "left" then
                fullAutoPlayRightEnabled = true
                if fullAutoRightSetter then fullAutoRightSetter(true) end
                startFullAutoRight()
                if VisualSetters.FullAuto then VisualSetters.FullAuto(true) end
            elseif side == "right" then
                fullAutoPlayLeftEnabled = true
                if fullAutoLeftSetter then fullAutoLeftSetter(true) end
                startFullAutoLeft()
                if VisualSetters.FullAuto then VisualSetters.FullAuto(true) end
            end
        end
        if ct > COUNTDOWN_TARGET + 2 then G_countdownActive = false; if conn then conn:Disconnect(); conn = nil end end
    end)
end
workspace.ChildAdded:Connect(function(child)
    if child.Name == "Countdown" and child:IsA("Sound") then monitorCountdown(child) end
end)
do local ex = workspace:FindFirstChild("Countdown"); if ex and ex:IsA("Sound") then monitorCountdown(ex) end end
local FAP_L1 = Vector3.new(-476.48, -6.28, 92.73)
local FAP_L2 = Vector3.new(-482.85, -5.03, 93.13)
local FAP_L3 = Vector3.new(-475.68, -6.89, 92.76)
local FAP_L4 = Vector3.new(-476.50, -6.46, 27.58)
local FAP_L5 = Vector3.new(-482.42, -5.03, 27.84)
local FAP_R1 = Vector3.new(-476.16, -6.52, 25.62)
local FAP_R2 = Vector3.new(-483.06, -5.03, 27.51)
local FAP_R3 = Vector3.new(-476.21, -6.63, 27.46)
local FAP_R4 = Vector3.new(-476.66, -6.39, 92.44)
local FAP_R5 = Vector3.new(-481.94, -5.03, 92.42)
local FACE_FAP_L = Vector3.new(-482.25, -4.96, 92.09)
local FACE_FAP_R = Vector3.new(-482.06, -6.93, 35.47)
local FAP_LeftPhase = 1
local FAP_RightPhase = 1
local function makeFullAutoPlay(getEnabled, setEnabled, getPhase, setPhase, getConn, setConn, getVisual, getMobSetter, p1, p2, p3, p4, p5, faceTgt)
    local pts = {p1, p2, p3, p4, p5}
    local function stop()
        local c = getConn(); if c then c:Disconnect(); setConn(nil) end
        setPhase(1)
        local char = LocalPlayer.Character
        if char then local hum2 = char:FindFirstChildOfClass("Humanoid"); if hum2 then hum2:Move(Vector3.zero, false) end end
    end
    local function start()
        stop(); setPhase(1)
        setConn(RunService.Heartbeat:Connect(function()
            if not getEnabled() then return end
            local char = LocalPlayer.Character; if not char then return end
            local rp = char:FindFirstChild("HumanoidRootPart")
            local hum2 = char:FindFirstChildOfClass("Humanoid")
            if not rp or not hum2 then return end
            local ph = getPhase()
            local tgt = pts[ph]
            local spd
            if fastestStealEnabled and ph >= 4 then
                local dist = Vector3.new(tgt.X - rp.Position.X, 0, tgt.Z - rp.Position.Z).Magnitude
                if dist > 0.1 then
                    spd = math.clamp(dist / 1.653, 28, 29)
                else
                    spd = CARRY_SPEED
                end
            else
                spd = ph >= 3 and CARRY_SPEED or NORMAL_SPEED
            end
            if (Vector3.new(tgt.X, rp.Position.Y, tgt.Z) - rp.Position).Magnitude < 1 then
                if ph == 5 then
                    hum2:Move(Vector3.zero, false); rp.AssemblyLinearVelocity = Vector3.zero
                    setEnabled(false); stop()
                    local v = getVisual(); if v then v(false) end
                    local mv2 = getMobSetter(); if mv2 then mv2(false) end
                    if faceTgt then
                        local dir = Vector3.new(faceTgt.X, rp.Position.Y, faceTgt.Z) - rp.Position
                        if dir.Magnitude > 0.01 then rp.CFrame = CFrame.new(rp.Position, rp.Position + dir.Unit) end
                    end
                    return
                elseif ph == 2 then
                    hum2:Move(Vector3.zero, false); rp.AssemblyLinearVelocity = Vector3.zero
                    task.wait(0.05); setPhase(3); return
                else
                    setPhase(ph + 1); return
                end
            end
            local d = tgt - rp.Position
            local mv3 = Vector3.new(d.X, 0, d.Z).Unit
            hum2:Move(mv3, false); rp.AssemblyLinearVelocity = Vector3.new(mv3.X * spd, rp.AssemblyLinearVelocity.Y, mv3.Z * spd)
        end))
    end
    return start, stop
end
local startFullAutoLeft, stopFullAutoLeft = makeFullAutoPlay(
    function() return fullAutoPlayLeftEnabled end,
    function(v) fullAutoPlayLeftEnabled = v end,
    function() return FAP_LeftPhase end,
    function(v) FAP_LeftPhase = v end,
    function() return fullAutoPlayLeftConn end,
    function(v) fullAutoPlayLeftConn = v end,
    function() return fullAutoLeftSetter end,
    function() return nil end,
    FAP_L1, FAP_L2, FAP_L3, FAP_L4, FAP_L5, FACE_FAP_L
)
local startFullAutoRight, stopFullAutoRight = makeFullAutoPlay(
    function() return fullAutoPlayRightEnabled end,
    function(v) fullAutoPlayRightEnabled = v end,
    function() return FAP_RightPhase end,
    function(v) FAP_RightPhase = v end,
    function() return fullAutoPlayRightConn end,
    function(v) fullAutoPlayRightConn = v end,
    function() return fullAutoRightSetter end,
    function() return nil end,
    FAP_R1, FAP_R2, FAP_R3, FAP_R4, FAP_R5, FACE_FAP_R
)
local function startFullAutoPlay() end
local function stopFullAutoPlay() end
local function findBat()
    local c = LocalPlayer.Character; if not c then return nil end
    local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
    local SlapList = {"Bat","Slap","Iron Slap","Gold Slap","Diamond Slap","Emerald Slap","Ruby Slap","Dark Matter Slap","Flame Slap","Nuclear Slap","Galaxy Slap","Glitched Slap"}
    for _, name in ipairs(SlapList) do
        local t = c:FindFirstChild(name) or (bp and bp:FindFirstChild(name))
        if t then return t end
    end
    for _, ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end
    if bp then for _, ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    return nil
end
local function getClosestPlayer()
    local c = LocalPlayer.Character; if not c then return nil end
    local hrpLocal = c:FindFirstChild("HumanoidRootPart"); if not hrpLocal then return nil end
    local cp, cd = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local d = (hrpLocal.Position - tr.Position).Magnitude
                if d < cd then cd = d; cp = p end
            end
        end
    end
    return cp
end
local _batT = 0
RunService.Heartbeat:Connect(function()
    local now = tick()
    if autoBatToggled and now - _batT >= 1/30 then
        _batT = now
        local c = LocalPlayer.Character; if c then
            local hrpLocal = c:FindFirstChild("HumanoidRootPart"); if hrpLocal then
                local target = getClosestPlayer()
                if target and target.Character then
                    local tr = target.Character:FindFirstChild("HumanoidRootPart")
                    if tr then
                        local fp = tr.Position + tr.CFrame.LookVector * 1.5
                        local dir = (fp - hrpLocal.Position).Unit
                        hrpLocal.AssemblyLinearVelocity = Vector3.new(dir.X*56.5, dir.Y*56.5, dir.Z*56.5)
                    end
                end
            end
        end
    end
    if autoBatToggled then
        local c = LocalPlayer.Character; if c then
            local bat = findBat(); if bat then
                if bat.Parent ~= c then local hum2 = c:FindFirstChildOfClass("Humanoid"); if hum2 then hum2:EquipTool(bat) end end
                if now - lastBatSwing >= BAT_SWING_COOLDOWN then
                    lastBatSwing = now; pcall(function() bat:Activate() end)
                end
            end
        end
    end
end)
local function runTPDown()
    local wasFloating = floatEnabled
    if wasFloating then stopFloat() end
    task.spawn(function()
        pcall(function()
            local c = LocalPlayer.Character; if not c then return end
            local hrpLocal = c:FindFirstChild("HumanoidRootPart"); if not hrpLocal then return end
            local hum = c:FindFirstChildOfClass("Humanoid"); if not hum then return end
            local rp = RaycastParams.new(); rp.FilterDescendantsInstances = {c}; rp.FilterType = Enum.RaycastFilterType.Exclude
            local hit = workspace:Raycast(hrpLocal.Position, Vector3.new(0,-500,0), rp)
            if hit then
                hrpLocal.AssemblyLinearVelocity = Vector3.zero
                hrpLocal.AssemblyAngularVelocity = Vector3.zero
                local hh = hum.HipHeight or 2
                local hy = hrpLocal.Size.Y / 2
                hrpLocal.CFrame = CFrame.new(hit.Position.X, hit.Position.Y + hh + hy + 0.1, hit.Position.Z)
                hrpLocal.AssemblyLinearVelocity = Vector3.zero
            end
        end)
        task.wait(0.1)
        if wasFloating then startFloat() end
        if VisualSetters and VisualSetters.TPDownReset then VisualSetters.TPDownReset() end
    end)
end

-- ============================================================
-- MAIN GUI (111 DUEL - Interface simplifiée)
-- ============================================================
;(function()
local C_BG     = Color3.fromRGB(12, 12, 18)
local C_CARD   = Color3.fromRGB(20, 20, 30)
local C_ACCENT = Color3.fromRGB(130, 90, 220)
local C_RED    = Color3.fromRGB(210, 50, 75)
local C_DIM    = Color3.fromRGB(120, 120, 135)
local C_SW_OFF = Color3.fromRGB(35, 35, 48)
local C_WHITE  = Color3.fromRGB(255, 255, 255)
local C_GREEN  = Color3.fromRGB(50, 200, 100)

local sideSetters = {}

gui = Instance.new("ScreenGui")
gui.Name = "DuelHubGUI"; gui.ResetOnSpawn = false; gui.DisplayOrder = 10
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- PROGRESS BAR (steal indicator)
local progressBar = Instance.new("Frame", gui)
progressBar.Size = UDim2.new(0, 320, 0, 48)
progressBar.Position = UDim2.new(0.5, -160, 1, -65)
progressBar.BackgroundColor3 = C_BG; progressBar.BorderSizePixel = 0; progressBar.Active = true; progressBar.ZIndex = 50
Instance.new("UICorner", progressBar).CornerRadius = UDim.new(0, 8)
local pbStroke = Instance.new("UIStroke", progressBar)
pbStroke.Color = C_ACCENT; pbStroke.Thickness = 1.5
do
    local drag, ds, sp = false
    progressBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = inp.Position; sp = progressBar.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - ds
            progressBar.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
end
ProgressLabel = Instance.new("TextLabel", progressBar)
ProgressLabel.Size = UDim2.new(0.45, 0, 0, 16); ProgressLabel.Position = UDim2.new(0, 8, 0, 6)
ProgressLabel.BackgroundTransparency = 1; ProgressLabel.Text = "READY"; ProgressLabel.TextColor3 = C_ACCENT
ProgressLabel.Font = Enum.Font.GothamBlack; ProgressLabel.TextSize = 11; ProgressLabel.TextXAlignment = Enum.TextXAlignment.Left; ProgressLabel.ZIndex = 51
ProgressPercentLabel = Instance.new("TextLabel", progressBar)
ProgressPercentLabel.Size = UDim2.new(1, -8, 0, 16); ProgressPercentLabel.Position = UDim2.new(0, 0, 0, 6)
ProgressPercentLabel.BackgroundTransparency = 1; ProgressPercentLabel.Text = ""; ProgressPercentLabel.TextColor3 = C_WHITE
ProgressPercentLabel.Font = Enum.Font.GothamBlack; ProgressPercentLabel.TextSize = 12; ProgressPercentLabel.TextXAlignment = Enum.TextXAlignment.Right; ProgressPercentLabel.ZIndex = 51
local pTrack = Instance.new("Frame", progressBar)
pTrack.Size = UDim2.new(1, -16, 0, 14); pTrack.Position = UDim2.new(0, 8, 0, 26)
pTrack.BackgroundColor3 = C_SW_OFF; pTrack.BorderSizePixel = 0; pTrack.ZIndex = 50
Instance.new("UICorner", pTrack).CornerRadius = UDim.new(0, 4)
ProgressBarFill = Instance.new("Frame", pTrack)
ProgressBarFill.Size = UDim2.new(0, 0, 1, 0); ProgressBarFill.BackgroundColor3 = C_ACCENT
ProgressBarFill.BorderSizePixel = 0; ProgressBarFill.ZIndex = 51
Instance.new("UICorner", ProgressBarFill).CornerRadius = UDim.new(0, 4)

-- MAIN FRAME
main = Instance.new("Frame")
main.Name = "Main"
main.Size = getMobileOptimized(UDim2.new(0, 340, 0, 520), UDim2.new(0, 290, 0, 460))
main.Position = getMobileOptimized(UDim2.new(0, 10, 0, 60), UDim2.new(0.5, -145, 0, 50))
main.BackgroundColor3 = C_BG; main.BorderSizePixel = 0; main.Active = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = C_ACCENT; mainStroke.Thickness = 1.5

-- Draggable
do
    local drag, ds, sp = false
    main.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = inp.Position; sp = main.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - ds
            main.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
end

-- HEADER
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 50); header.BackgroundColor3 = C_CARD; header.BorderSizePixel = 0; header.ZIndex = 3
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)
local headerFix = Instance.new("Frame", header)
headerFix.Size = UDim2.new(1, 0, 0, 14); headerFix.Position = UDim2.new(0, 0, 1, -14)
headerFix.BackgroundColor3 = C_CARD; headerFix.BorderSizePixel = 0; headerFix.ZIndex = 2

local titleLbl = Instance.new("TextLabel", header)
titleLbl.Size = UDim2.new(1, -90, 1, 0); titleLbl.Position = UDim2.new(0, 14, 0, 0)
titleLbl.BackgroundTransparency = 1; titleLbl.Text = "111 DUEL"
titleLbl.TextColor3 = C_WHITE; titleLbl.Font = Enum.Font.GothamBlack
titleLbl.TextSize = getMobileOptimized(20, 16); titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.ZIndex = 4

local fpsLbl = Instance.new("TextLabel", header)
fpsLbl.Size = UDim2.new(0, 60, 1, 0); fpsLbl.Position = UDim2.new(1, -120, 0, 0)
fpsLbl.BackgroundTransparency = 1; fpsLbl.Text = "60 FPS"
fpsLbl.TextColor3 = C_ACCENT; fpsLbl.Font = Enum.Font.GothamBold
fpsLbl.TextSize = getMobileOptimized(11, 9); fpsLbl.TextXAlignment = Enum.TextXAlignment.Right; fpsLbl.ZIndex = 4

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0, 32, 0, 32); closeBtn.Position = UDim2.new(1, -40, 0.5, -16)
closeBtn.BackgroundColor3 = C_RED; closeBtn.BorderSizePixel = 0
closeBtn.Text = "×"; closeBtn.TextColor3 = C_WHITE
closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 22; closeBtn.ZIndex = 8
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local reopenBtn = Instance.new("TextButton", gui)
reopenBtn.Size = UDim2.new(0, 44, 0, 44); reopenBtn.Position = UDim2.new(0, 10, 0, 60)
reopenBtn.BackgroundColor3 = C_ACCENT; reopenBtn.BorderSizePixel = 0
reopenBtn.Text = "111"; reopenBtn.TextColor3 = C_WHITE
reopenBtn.Font = Enum.Font.GothamBlack; reopenBtn.TextSize = 13; reopenBtn.ZIndex = 20; reopenBtn.Visible = false
Instance.new("UICorner", reopenBtn).CornerRadius = UDim.new(0, 10)

closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false; reopenBtn.Visible = true
end)
reopenBtn.MouseButton1Click:Connect(function()
    reopenBtn.Visible = false; main.Visible = true
end)
closeBtn.MouseEnter:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3=Color3.fromRGB(255,70,90)}):Play() end)
closeBtn.MouseLeave:Connect(function() TweenService:Create(closeBtn, TweenInfo.new(0.15), {BackgroundColor3=C_RED}):Play() end)

-- FPS update
local lastFrameT = tick()
RunService.RenderStepped:Connect(function()
    local now = tick()
    local fps = 1 / math.max(now - lastFrameT, 0.001)
    lastFrameT = now
    fpsLbl.Text = string.format("%d FPS", fps)
    fpsLbl.TextColor3 = fps >= 50 and C_GREEN or fps >= 30 and Color3.fromRGB(255,180,80) or C_RED
end)

-- SCROLL
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(1, -16, 1, -58); scroll.Position = UDim2.new(0, 8, 0, 54)
scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = C_ACCENT; scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new(0,0,0,0); scroll.ZIndex = 2
local vstack = Instance.new("Frame", scroll)
vstack.Size = UDim2.new(1, 0, 0, 0); vstack.AutomaticSize = Enum.AutomaticSize.Y
vstack.BackgroundTransparency = 1
local vLayout = Instance.new("UIListLayout", vstack)
vLayout.Padding = UDim.new(0, 6); vLayout.SortOrder = Enum.SortOrder.LayoutOrder

local orderN = 0
local function O() orderN = orderN + 1; return orderN end

-- Section label helper
local function mkSection(txt)
    local f = Instance.new("Frame", vstack)
    f.Size = UDim2.new(1, 0, 0, 24); f.BackgroundTransparency = 1; f.LayoutOrder = O()
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
    l.Text = "▸ " .. txt:upper(); l.TextColor3 = C_ACCENT
    l.Font = Enum.Font.GothamBold; l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left
    local line = Instance.new("Frame", f)
    line.Size = UDim2.new(1, 0, 0, 1); line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = C_ACCENT; line.BackgroundTransparency = 0.7; line.BorderSizePixel = 0
end

-- Toggle row helper
local function mkToggle(label, defaultOn, order, onToggle, enabledKey)
    local row = Instance.new("Frame", vstack)
    row.Size = UDim2.new(1, 0, 0, 40); row.BackgroundColor3 = C_CARD
    row.BorderSizePixel = 0; row.LayoutOrder = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", row)
    stroke.Color = C_ACCENT; stroke.Thickness = 1; stroke.Transparency = 0.75

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -70, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextColor3 = C_WHITE
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 4

    local swBg = Instance.new("Frame", row)
    swBg.Size = UDim2.new(0, 44, 0, 22); swBg.Position = UDim2.new(1, -54, 0.5, -11)
    swBg.BackgroundColor3 = defaultOn and C_ACCENT or C_SW_OFF; swBg.BorderSizePixel = 0; swBg.ZIndex = 4
    Instance.new("UICorner", swBg).CornerRadius = UDim.new(1, 0)
    local swCircle = Instance.new("Frame", swBg)
    swCircle.Size = UDim2.new(0, 18, 0, 18)
    swCircle.Position = defaultOn and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    swCircle.BackgroundColor3 = C_WHITE; swCircle.BorderSizePixel = 0; swCircle.ZIndex = 5
    Instance.new("UICorner", swCircle).CornerRadius = UDim.new(1, 0)

    local isOn = defaultOn
    local function setVisual(state)
        isOn = state
        TweenService:Create(swBg, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {BackgroundColor3 = isOn and C_ACCENT or C_SW_OFF}):Play()
        TweenService:Create(swCircle, TweenInfo.new(0.18, Enum.EasingStyle.Back), {Position = isOn and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)}):Play()
    end
    if enabledKey then VisualSetters[enabledKey] = setVisual end

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.ZIndex = 6
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn; setVisual(isOn)
        if enabledKey then Enabled[enabledKey] = isOn end
        if onToggle then onToggle(isOn) end
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.12), {Transparency=0.3}):Play()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3=Color3.fromRGB(26,26,40)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(stroke, TweenInfo.new(0.12), {Transparency=0.75}):Play()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundColor3=C_CARD}):Play()
    end)
    return setVisual, swBg, swCircle
end

-- Input row helper
local function mkInput(label, default, order, onChange)
    local row = Instance.new("Frame", vstack)
    row.Size = UDim2.new(1, 0, 0, 40); row.BackgroundColor3 = C_CARD
    row.BorderSizePixel = 0; row.LayoutOrder = order
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", row)
    stroke.Color = C_ACCENT; stroke.Thickness = 1; stroke.Transparency = 0.75
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.55, 0, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextColor3 = C_WHITE
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 4
    local box = Instance.new("TextBox", row)
    box.Size = UDim2.new(0, 70, 0, 26); box.Position = UDim2.new(1, -80, 0.5, -13)
    box.BackgroundColor3 = C_BG; box.BorderSizePixel = 0
    box.Text = tostring(default); box.TextColor3 = C_WHITE
    box.Font = Enum.Font.GothamBold; box.TextSize = 11; box.ZIndex = 4
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
    local bs = Instance.new("UIStroke", box); bs.Color = C_ACCENT; bs.Thickness = 1; bs.Transparency = 0.5
    box.FocusLost:Connect(function()
        if onChange then onChange(box.Text, box) end
    end)
    return box
end

-- ─── COMBAT ───
mkSection("Combat")
local setARVisual, _, _ = mkToggle("Anti Ragdoll", Enabled.AntiRagdoll, O(), function(s)
    if s then startAntiRagdoll() else stopAntiRagdoll() end
end, "AntiRagdoll")

local brSwBgL, brSwCircleL, brSwBgR, brSwCircleR
local brLV, _bbl, _bbcl = mkToggle("Brainrot Return L", false, O(), function(on)
    if on and brainrotReturnRightEnabled then
        brainrotReturnRightEnabled = false
        if brSwBgR and brSwCircleR then
            TweenService:Create(brSwBgR, TweenInfo.new(0.18), {BackgroundColor3=C_SW_OFF}):Play()
            TweenService:Create(brSwCircleR, TweenInfo.new(0.18), {Position=UDim2.new(0,2,0.5,-9)}):Play()
        end
    end
    brainrotReturnLeftEnabled = on
end)
brSwBgL = _bbl; brSwCircleL = _bbcl

local brRV, _bbr, _bbcr = mkToggle("Brainrot Return R", false, O(), function(on)
    if on and brainrotReturnLeftEnabled then
        brainrotReturnLeftEnabled = false
        if brSwBgL and brSwCircleL then
            TweenService:Create(brSwBgL, TweenInfo.new(0.18), {BackgroundColor3=C_SW_OFF}):Play()
            TweenService:Create(brSwCircleL, TweenInfo.new(0.18), {Position=UDim2.new(0,2,0.5,-9)}):Play()
        end
    end
    brainrotReturnRightEnabled = on
end)
brSwBgR = _bbr; brSwCircleR = _bbcr

local setCarryVisual, _csb, _csc = mkToggle("Carry Mode [Q]", speedToggled, O(), function(on)
    if on and laggerToggled then
        laggerToggled = false
        if laggerSwBg and laggerSwCircle then
            TweenService:Create(laggerSwBg, TweenInfo.new(0.18), {BackgroundColor3=C_SW_OFF}):Play()
            TweenService:Create(laggerSwCircle, TweenInfo.new(0.18), {Position=UDim2.new(0,2,0.5,-9)}):Play()
        end
        if sideSetters.laggerSetter then sideSetters.laggerSetter(false) end
    end
    speedToggled = on
    if sideSetters.carrySetter then sideSetters.carrySetter(on) end
end)
speedSwBg = _csb; speedSwCircle = _csc

local setLaggerVisual, _lsb, _lsc = mkToggle("Lagger Mode [R]", laggerToggled, O(), function(on)
    if on and speedToggled then
        speedToggled = false
        if speedSwBg and speedSwCircle then
            TweenService:Create(speedSwBg, TweenInfo.new(0.18), {BackgroundColor3=C_SW_OFF}):Play()
            TweenService:Create(speedSwCircle, TweenInfo.new(0.18), {Position=UDim2.new(0,2,0.5,-9)}):Play()
        end
        if sideSetters.carrySetter then sideSetters.carrySetter(false) end
    end
    laggerToggled = on
    if sideSetters.laggerSetter then sideSetters.laggerSetter(on) end
end)
laggerSwBg = _lsb; laggerSwCircle = _lsc

local setBatVisual, _bsb, _bsc = mkToggle("Auto Bat [E]", autoBatToggled, O(), function(on)
    autoBatToggled = on; autoSwingEnabled = on
    if sideSetters.batSetter then sideSetters.batSetter(on) end
end)
batSwBg = _bsb; batSwCircle = _bsc

local setHHAVisual, _, _ = mkToggle("Harder Hit Anim", false, O(), function(on)
    harderHitAnimEnabled = on
    if on then startHarderHitAnim() else stopHarderHitAnim() end
end)
VisualSetters.HarderHitAnim = setHHAVisual

local setMedVisual, _, _ = mkToggle("Medusa Counter", false, O(), function(on)
    medusaCounterEnabled = on
    if on then setupMedusaCounter(LocalPlayer.Character) else stopMedusaCounter() end
end)
VisualSetters.MedusaCounter = setMedVisual

local setFSVisual, _, _ = mkToggle("Fastest Steal", false, O(), function(on)
    fastestStealEnabled = on
end)
VisualSetters.FastestSteal = setFSVisual

-- ─── AUTO STEAL ───
mkSection("Auto Steal")
local setASVisual, _asb, _asc = mkToggle("Auto Steal", Enabled.AutoSteal, O(), function(on)
    Enabled.AutoSteal = on; Settings.AutoStealEnabled = on
    if on then startAutoSteal() else stopAutoSteal() end
end)

mkInput("Radius", Settings.StealRadius, O(), function(v, box)
    local n = tonumber(v)
    if n then
        Settings.StealRadius = math.clamp(math.floor(n), 1, 500)
        Values.STEAL_RADIUS = Settings.StealRadius
        box.Text = tostring(Settings.StealRadius)
        cachedPrompts = {}; promptCacheTime = 0
    else box.Text = tostring(Settings.StealRadius) end
end)

mkInput("Duration", Settings.StealDuration, O(), function(v, box)
    local n = tonumber(v)
    if n then
        Settings.StealDuration = math.clamp(n, 0.05, 5)
        Values.STEAL_DURATION = Settings.StealDuration
        box.Text = string.format("%.2f", Settings.StealDuration)
    else box.Text = string.format("%.2f", Settings.StealDuration) end
end)

-- ─── AUTO FEATURES ───
mkSection("Auto")
local setTPAutoVisual, _, _ = mkToggle("Auto TP", false, O(), function(on)
    G_tpAutoEnabled = on
    if on then task.spawn(refreshMyPlotSide) end
end)
VisualSetters.AutoTP = setTPAutoVisual

local setAPAfterTPVisual, _, _ = mkToggle("Auto Play After TP", false, O(), function(on)
    G_autoPlayAfterTP = on
end)
VisualSetters.APAfterTP = setAPAfterTPVisual

local setFALVisual, _, _ = mkToggle("Full Auto Left [G]", false, O(), function(on)
    fullAutoPlayLeftEnabled = on
    if fullAutoLeftSetter then fullAutoLeftSetter(on) end
    if on then startFullAutoLeft() else stopFullAutoLeft() end
end)
VisualSetters.FullAutoLeft = setFALVisual

local setFARVisual, _, _ = mkToggle("Full Auto Right [H]", false, O(), function(on)
    fullAutoPlayRightEnabled = on
    if fullAutoRightSetter then fullAutoRightSetter(on) end
    if on then startFullAutoRight() else stopFullAutoRight() end
end)
VisualSetters.FullAutoRight = setFARVisual

-- ─── MOVEMENT ───
mkSection("Movement")
local setIJVisual, _, _ = mkToggle("Infinite Jump [M]", Enabled.InfiniteJump, O(), function(s)
    if s then startInfiniteJump() else stopInfiniteJump() end
end, "InfiniteJump")

local setFloatVisual2, _, _ = mkToggle("Float [J]", false, O(), function(on)
    floatEnabled = on
    if on then startFloat() else stopFloat() end
end)

local _dropVis, _, _ = mkToggle("Drop Brainrot [X]", false, O(), function(on)
    if on then task.spawn(runDropBrainrot) end
end)
setDropBrainrotVisual = _dropVis

local setTPDVisual, tpdSwBg, tpdSwCircle = mkToggle("TP Down [F]", false, O(), function(on)
    if on then runTPDown() end
end)
VisualSetters.TPDown = setTPDVisual
VisualSetters.TPDownReset = function()
    TweenService:Create(tpdSwBg, TweenInfo.new(0.18), {BackgroundColor3=C_SW_OFF}):Play()
    TweenService:Create(tpdSwCircle, TweenInfo.new(0.18), {Position=UDim2.new(0,2,0.5,-9)}):Play()
    setTPDVisual(false)
end

local setNCCVisual, _, _ = mkToggle("No Cam Collision", false, O(), function(on)
    noCamCollisionEnabled = on
    if on then enableNoCameraCollision() else disableNoCameraCollision() end
end)
VisualSetters.NoCam = setNCCVisual

mkInput("Float Height", floatHeight, O(), function(v, box)
    local n = tonumber(v)
    if n then floatHeight = math.clamp(n, 1, 100); box.Text = tostring(floatHeight)
    else box.Text = tostring(floatHeight) end
end)
mkInput("Normal Speed", NORMAL_SPEED, O(), function(v, box)
    local n = tonumber(v)
    if n then NORMAL_SPEED = math.clamp(n, 1, 9999); box.Text = tostring(NORMAL_SPEED)
    else box.Text = tostring(NORMAL_SPEED) end
end)
mkInput("Carry Speed", CARRY_SPEED, O(), function(v, box)
    local n = tonumber(v)
    if n then CARRY_SPEED = math.clamp(n, 1, 9999); box.Text = tostring(CARRY_SPEED)
    else box.Text = tostring(CARRY_SPEED) end
end)
mkInput("Lagger Speed", LAGGER_SPEED, O(), function(v, box)
    local n = tonumber(v)
    if n then LAGGER_SPEED = math.clamp(n, 1, 9999); box.Text = tostring(LAGGER_SPEED)
    else box.Text = tostring(LAGGER_SPEED) end
end)

-- ─── VISUAL ───
mkSection("Visual")
local setOptVisual, _, _ = mkToggle("Anti Lag", Enabled.Optimizer, O(), function(s)
    if s then enableOptimizer() else disableOptimizer() end
end, "Optimizer")

local setUMVisual, _, _ = mkToggle("Ultra Mode", false, O(), function(s)
    ultraModeEnabled = s
    if s then enableUltraMode() else disableUltraMode() end
end)
VisualSetters.UltraMode = setUMVisual

local setRAVisual, _, _ = mkToggle("Remove Accessories", Enabled.RemoveAccessories, O(), function(s)
    if s then startRemoveAccessories() else stopRemoveAccessories() end
end, "RemoveAccessories")

-- ─── KEYBIND HANDLER ───
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local kc = input.KeyCode
    if kc == Keybinds.UIToggle then
        main.Visible = not main.Visible
        if reopenBtn then reopenBtn.Visible = not main.Visible end
    end
    if kc == Keybinds.SpeedToggle then
        speedToggled = not speedToggled
        if speedToggled and laggerToggled then
            laggerToggled = false
            setLaggerVisual(false)
            if sideSetters.laggerSetter then sideSetters.laggerSetter(false) end
        end
        setCarryVisual(speedToggled)
        if sideSetters.carrySetter then sideSetters.carrySetter(speedToggled) end
    end
    if kc == Keybinds.LaggerToggle then
        laggerToggled = not laggerToggled
        if laggerToggled and speedToggled then
            speedToggled = false
            setCarryVisual(false)
            if sideSetters.carrySetter then sideSetters.carrySetter(false) end
        end
        setLaggerVisual(laggerToggled)
        if sideSetters.laggerSetter then sideSetters.laggerSetter(laggerToggled) end
    end
    if kc == Keybinds.AutoBat then
        autoBatToggled = not autoBatToggled
        setBatVisual(autoBatToggled)
    end
    if kc == Keybinds.InfiniteJump then
        Enabled.InfiniteJump = not Enabled.InfiniteJump
        setIJVisual(Enabled.InfiniteJump)
        if Enabled.InfiniteJump then startInfiniteJump() else stopInfiniteJump() end
    end
    if kc == Keybinds.DropBrainrot then
        if setDropBrainrotVisual then setDropBrainrotVisual(true) end
        task.spawn(runDropBrainrot)
    end
    if kc == Keybinds.FloatToggle then
        floatEnabled = not floatEnabled
        setFloatVisual2(floatEnabled)
        if floatEnabled then startFloat() else stopFloat() end
    end
    if kc == Keybinds.FullAutoLeft then
        fullAutoPlayLeftEnabled = not fullAutoPlayLeftEnabled
        if fullAutoLeftSetter then fullAutoLeftSetter(fullAutoPlayLeftEnabled) end
        setFALVisual(fullAutoPlayLeftEnabled)
        if fullAutoPlayLeftEnabled then startFullAutoLeft() else stopFullAutoLeft() end
    end
    if kc == Keybinds.FullAutoRight then
        fullAutoPlayRightEnabled = not fullAutoPlayRightEnabled
        if fullAutoRightSetter then fullAutoRightSetter(fullAutoPlayRightEnabled) end
        setFARVisual(fullAutoPlayRightEnabled)
        if fullAutoPlayRightEnabled then startFullAutoRight() else stopFullAutoRight() end
    end
    if kc == Keybinds.TPDown then
        runTPDown()
    end
end)

-- Speed loop
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character; if not char then return end
    local localH = char:FindFirstChildOfClass("Humanoid")
    local localHRP = char:FindFirstChild("HumanoidRootPart")
    if not localH or not localHRP then return end
    h = localH; hrp = localHRP
    local md = localH.MoveDirection
    local spd = laggerToggled and LAGGER_SPEED or (speedToggled and CARRY_SPEED or NORMAL_SPEED)
    if md.Magnitude > 0 then
        localHRP.AssemblyLinearVelocity = Vector3.new(md.X*spd, localHRP.AssemblyLinearVelocity.Y, md.Z*spd)
    end
    if speedLbl then
        speedLbl.Text = string.format("%.0f", Vector3.new(localHRP.AssemblyLinearVelocity.X, 0, localHRP.AssemblyLinearVelocity.Z).Magnitude)
    end
end)

-- Mobile side buttons
mobileButtonContainer = Instance.new("Frame", gui)
mobileButtonContainer.Size = UDim2.new(0, 165, 0, 230)
mobileButtonContainer.Position = UDim2.new(1, -175, 0.5, -115)
mobileButtonContainer.BackgroundColor3 = C_BG; mobileButtonContainer.BackgroundTransparency = 0.25
mobileButtonContainer.BorderSizePixel = 0; mobileButtonContainer.Active = true; mobileButtonContainer.ZIndex = 100
Instance.new("UICorner", mobileButtonContainer).CornerRadius = UDim.new(0, 12)
local mbStroke = Instance.new("UIStroke", mobileButtonContainer)
mbStroke.Color = C_ACCENT; mbStroke.Thickness = 2; mbStroke.Transparency = 0.5
do
    local drag, ds, sp = false
    mobileButtonContainer.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = inp.Position; sp = mobileButtonContainer.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - ds
            mobileButtonContainer.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
end

local function mkMobileBtn(text, row, col, cb)
    local btn = Instance.new("TextButton", mobileButtonContainer)
    btn.Size = UDim2.new(0, 72, 0, 50)
    btn.Position = UDim2.new(0, (col-1)*83+5, 0, (row-1)*58+5)
    btn.BackgroundColor3 = C_CARD; btn.BorderSizePixel = 0; btn.Text = ""; btn.ZIndex = 101
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local bs = Instance.new("UIStroke", btn); bs.Color = C_ACCENT; bs.Thickness = 2; bs.Transparency = 0.5
    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, 0, 1, 0); lbl.BackgroundTransparency = 1
    lbl.Text = text; lbl.TextColor3 = C_WHITE
    lbl.Font = Enum.Font.GothamBlack; lbl.TextSize = 11; lbl.ZIndex = 102
    local dot = Instance.new("Frame", btn)
    dot.Size = UDim2.new(0, 8, 0, 8); dot.Position = UDim2.new(1, -12, 0, 4)
    dot.BackgroundColor3 = C_SW_OFF; dot.BorderSizePixel = 0; dot.ZIndex = 103
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local isOn = false
    local function setV(state)
        isOn = state
        TweenService:Create(dot, TweenInfo.new(0.15), {BackgroundColor3 = isOn and C_GREEN or C_SW_OFF}):Play()
        TweenService:Create(bs, TweenInfo.new(0.15), {Transparency = isOn and 0 or 0.5}):Play()
    end
    btn.MouseButton1Click:Connect(function()
        isOn = not isOn; setV(isOn)
        if cb then cb(isOn) end
    end)
    return setV
end

local batSetter = mkMobileBtn("BAT", 1, 1, function(on)
    autoBatToggled = on; setBatVisual(on)
end)
local carrySetter = mkMobileBtn("CARRY", 1, 2, function(on)
    if on and laggerToggled then
        laggerToggled = false; setLaggerVisual(false)
        if sideSetters.laggerSetter then sideSetters.laggerSetter(false) end
    end
    speedToggled = on; setCarryVisual(on)
end)
local laggerSetter = mkMobileBtn("LAG", 2, 1, function(on)
    if on and speedToggled then
        speedToggled = false; setCarryVisual(false)
        if sideSetters.carrySetter then sideSetters.carrySetter(false) end
    end
    laggerToggled = on; setLaggerVisual(on)
end)
local floatMSetter = mkMobileBtn("FLOAT", 2, 2, function(on)
    floatEnabled = on; setFloatVisual2(on)
    if on then startFloat() else stopFloat() end
end)
fullAutoLeftSetter = mkMobileBtn("AL", 3, 1, function(on)
    fullAutoPlayLeftEnabled = on; setFALVisual(on)
    if on then startFullAutoLeft() else stopFullAutoLeft() end
end)
fullAutoRightSetter = mkMobileBtn("AR", 3, 2, function(on)
    fullAutoPlayRightEnabled = on; setFARVisual(on)
    if on then startFullAutoRight() else stopFullAutoRight() end
end)
dropMobileSetter = mkMobileBtn("DROP", 4, 1, function(on)
    if on then
        if setDropBrainrotVisual then setDropBrainrotVisual(true) end
        task.spawn(runDropBrainrot)
    end
end)

sideSetters = {batSetter=batSetter, carrySetter=carrySetter, laggerSetter=laggerSetter}

-- Init on character
local function setupChar(char)
    h = char:WaitForChild("Humanoid")
    hrp = char:WaitForChild("HumanoidRootPart")
    lastKnownHealth = h and h.Health or 100
    if medusaCounterEnabled then setupMedusaCounter(char) end
    if harderHitAnimEnabled then task.wait(0.3); saveOriginalAnims(char); applyAnimPack(char) end
    local head = char:FindFirstChild("Head")
    if head then
        local bb = Instance.new("BillboardGui", head)
        bb.Size = UDim2.new(0, 80, 0, 20); bb.StudsOffset = Vector3.new(0, 3, 0); bb.AlwaysOnTop = true
        speedLbl = Instance.new("TextLabel", bb)
        speedLbl.Size = UDim2.new(1, 0, 1, 0); speedLbl.BackgroundTransparency = 1
        speedLbl.TextColor3 = C_ACCENT; speedLbl.Font = Enum.Font.GothamBold; speedLbl.TextScaled = true
    end
end
LocalPlayer.CharacterAdded:Connect(setupChar)
if LocalPlayer.Character then setupChar(LocalPlayer.Character) end

task.spawn(function()
    task.wait(2)
    if Enabled.AutoSteal then startAutoSteal() end
    if Enabled.AntiRagdoll then startAntiRagdoll() end
    if Enabled.InfiniteJump then setIJVisual(true); startInfiniteJump() end
    if Enabled.Optimizer then enableOptimizer() end
    if ultraModeEnabled then enableUltraMode() end
    if Enabled.RemoveAccessories then startRemoveAccessories() end
    workspace.CurrentCamera.FieldOfView = FOV_VALUE
end)

-- Auto Play sub-panel
apMain = Instance.new("Frame", gui)
apMain.Name = "APMain"
apMain.Size = getMobileOptimized(UDim2.new(0, 220, 0, 220), UDim2.new(0, 200, 0, 200))
apMain.Position = getMobileOptimized(UDim2.new(0.5, -110, 0.5, -110), UDim2.new(0.5, -100, 0.5, -100))
apMain.BackgroundColor3 = C_BG; apMain.BorderSizePixel = 0; apMain.Active = true
Instance.new("UICorner", apMain).CornerRadius = UDim.new(0, 12)
local apStroke2 = Instance.new("UIStroke", apMain); apStroke2.Color = C_ACCENT; apStroke2.Thickness = 1.5
do
    local drag, ds, sp = false
    apMain.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            drag = true; ds = inp.Position; sp = apMain.Position
            inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then drag = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if drag and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - ds
            apMain.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
end
local apHdr = Instance.new("Frame", apMain)
apHdr.Size = UDim2.new(1, 0, 0, 36); apHdr.BackgroundColor3 = C_CARD; apHdr.BorderSizePixel = 0; apHdr.ZIndex = 3
Instance.new("UICorner", apHdr).CornerRadius = UDim.new(0, 12)
local apHFix2 = Instance.new("Frame", apHdr)
apHFix2.Size = UDim2.new(1, 0, 0, 10); apHFix2.Position = UDim2.new(0, 0, 1, -10)
apHFix2.BackgroundColor3 = C_CARD; apHFix2.BorderSizePixel = 0; apHFix2.ZIndex = 2
local apTitleLbl = Instance.new("TextLabel", apHdr)
apTitleLbl.Size = UDim2.new(1, -40, 1, 0); apTitleLbl.Position = UDim2.new(0, 10, 0, 0)
apTitleLbl.BackgroundTransparency = 1; apTitleLbl.Text = "AUTO PLAY"
apTitleLbl.TextColor3 = C_WHITE; apTitleLbl.Font = Enum.Font.GothamBlack
apTitleLbl.TextSize = 13; apTitleLbl.TextXAlignment = Enum.TextXAlignment.Left; apTitleLbl.ZIndex = 4
local apCloseBtn = Instance.new("TextButton", apHdr)
apCloseBtn.Size = UDim2.new(0, 28, 0, 28); apCloseBtn.Position = UDim2.new(1, -33, 0.5, -14)
apCloseBtn.BackgroundColor3 = C_RED; apCloseBtn.BorderSizePixel = 0
apCloseBtn.Text = "×"; apCloseBtn.TextColor3 = C_WHITE; apCloseBtn.Font = Enum.Font.GothamBold; apCloseBtn.TextSize = 18; apCloseBtn.ZIndex = 6
Instance.new("UICorner", apCloseBtn).CornerRadius = UDim.new(0, 7)

local apReopen = Instance.new("TextButton", gui)
apReopen.Size = UDim2.new(0, 40, 0, 40)
apReopen.Position = getMobileOptimized(UDim2.new(0.5, -20, 0.5, -20), UDim2.new(0.5, -20, 0.5, -20))
apReopen.BackgroundColor3 = C_ACCENT; apReopen.BorderSizePixel = 0
apReopen.Text = "AP"; apReopen.TextColor3 = C_WHITE
apReopen.Font = Enum.Font.GothamBlack; apReopen.TextSize = 12; apReopen.ZIndex = 20; apReopen.Visible = false
Instance.new("UICorner", apReopen).CornerRadius = UDim.new(0, 10)
apCloseBtn.MouseButton1Click:Connect(function() apMain.Visible = false; apReopen.Visible = true end)
apReopen.MouseButton1Click:Connect(function() apMain.Visible = true; apReopen.Visible = false end)

local apBody = Instance.new("Frame", apMain)
apBody.Size = UDim2.new(1, -16, 1, -44); apBody.Position = UDim2.new(0, 8, 0, 40)
apBody.BackgroundTransparency = 1
local apBL = Instance.new("UIListLayout", apBody); apBL.Padding = UDim.new(0, 6); apBL.SortOrder = Enum.SortOrder.LayoutOrder

local AP_LeftOn = false
local AP_RightOn = false
local AP_LeftConn = nil
local AP_RightConn = nil
local AP_LeftPhase2 = 1
local AP_RightPhase2 = 1
local AP_L1 = Vector3.new(-476.48,-6.28,92.73)
local AP_L2 = Vector3.new(-483.12,-4.95,94.80)
local AP_R1 = Vector3.new(-476.16,-6.52,25.62)
local AP_R2 = Vector3.new(-483.06,-5.03,25.48)
local AP_SPEED = 60

local AP_SetLeftV = nil
local AP_SetRightV = nil

local function mkAPToggle(label, order2, onToggle2)
    local row2 = Instance.new("Frame", apBody)
    row2.Size = UDim2.new(1, 0, 0, 38); row2.BackgroundColor3 = C_CARD
    row2.BorderSizePixel = 0; row2.LayoutOrder = order2
    Instance.new("UICorner", row2).CornerRadius = UDim.new(0, 8)
    local stroke2 = Instance.new("UIStroke", row2); stroke2.Color = C_ACCENT; stroke2.Thickness = 1; stroke2.Transparency = 0.75
    local lbl2 = Instance.new("TextLabel", row2)
    lbl2.Size = UDim2.new(1, -60, 1, 0); lbl2.Position = UDim2.new(0, 10, 0, 0)
    lbl2.BackgroundTransparency = 1; lbl2.Text = label; lbl2.TextColor3 = C_WHITE
    lbl2.Font = Enum.Font.GothamBold; lbl2.TextSize = 12; lbl2.TextXAlignment = Enum.TextXAlignment.Left; lbl2.ZIndex = 4
    local swBg2 = Instance.new("Frame", row2)
    swBg2.Size = UDim2.new(0, 40, 0, 20); swBg2.Position = UDim2.new(1, -48, 0.5, -10)
    swBg2.BackgroundColor3 = C_SW_OFF; swBg2.BorderSizePixel = 0; swBg2.ZIndex = 4
    Instance.new("UICorner", swBg2).CornerRadius = UDim.new(1, 0)
    local swC2 = Instance.new("Frame", swBg2)
    swC2.Size = UDim2.new(0, 16, 0, 16); swC2.Position = UDim2.new(0, 2, 0.5, -8)
    swC2.BackgroundColor3 = C_WHITE; swC2.BorderSizePixel = 0; swC2.ZIndex = 5
    Instance.new("UICorner", swC2).CornerRadius = UDim.new(1, 0)
    local isOn2 = false
    local function sv2(state)
        isOn2 = state
        TweenService:Create(swBg2, TweenInfo.new(0.18), {BackgroundColor3 = isOn2 and C_ACCENT or C_SW_OFF}):Play()
        TweenService:Create(swC2, TweenInfo.new(0.18), {Position = isOn2 and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)}):Play()
    end
    local btn2 = Instance.new("TextButton", row2)
    btn2.Size = UDim2.new(1, 0, 1, 0); btn2.BackgroundTransparency = 1; btn2.Text = ""; btn2.ZIndex = 6
    btn2.MouseButton1Click:Connect(function()
        isOn2 = not isOn2; sv2(isOn2)
        if onToggle2 then onToggle2(isOn2) end
    end)
    return sv2
end

local apALOrder = 0
local function APO() apALOrder = apALOrder + 1; return apALOrder end

AP_SetLeftV = mkAPToggle("Auto Left [Z]", APO(), function(on)
    AP_LeftOn = on
    if on then
        if AP_LeftConn then AP_LeftConn:Disconnect() end
        AP_LeftPhase2 = 1
        AP_LeftConn = RunService.Heartbeat:Connect(function()
            if not AP_LeftOn then return end
            local c = LocalPlayer.Character; if not c then return end
            local rp2 = c:FindFirstChild("HumanoidRootPart")
            local hum3 = c:FindFirstChildOfClass("Humanoid")
            if not rp2 or not hum3 then return end
            local tgt2 = AP_LeftPhase2 == 1 and AP_L1 or AP_L2
            if (Vector3.new(tgt2.X, rp2.Position.Y, tgt2.Z) - rp2.Position).Magnitude < 1 then
                if AP_LeftPhase2 == 2 then
                    hum3:Move(Vector3.zero, false); rp2.AssemblyLinearVelocity = Vector3.zero
                    AP_LeftOn = false; if AP_LeftConn then AP_LeftConn:Disconnect(); AP_LeftConn = nil end
                    AP_LeftPhase2 = 1; if AP_SetLeftV then AP_SetLeftV(false) end; return
                else AP_LeftPhase2 = 2 end
            end
            local d2 = tgt2 - rp2.Position; local mv4 = Vector3.new(d2.X, 0, d2.Z).Unit
            hum3:Move(mv4, false); rp2.AssemblyLinearVelocity = Vector3.new(mv4.X*AP_SPEED, rp2.AssemblyLinearVelocity.Y, mv4.Z*AP_SPEED)
        end)
    else
        if AP_LeftConn then AP_LeftConn:Disconnect(); AP_LeftConn = nil end
        AP_LeftPhase2 = 1
    end
end)

AP_SetRightV = mkAPToggle("Auto Right [C]", APO(), function(on)
    AP_RightOn = on
    if on then
        if AP_RightConn then AP_RightConn:Disconnect() end
        AP_RightPhase2 = 1
        AP_RightConn = RunService.Heartbeat:Connect(function()
            if not AP_RightOn then return end
            local c = LocalPlayer.Character; if not c then return end
            local rp2 = c:FindFirstChild("HumanoidRootPart")
            local hum3 = c:FindFirstChildOfClass("Humanoid")
            if not rp2 or not hum3 then return end
            local tgt2 = AP_RightPhase2 == 1 and AP_R1 or AP_R2
            if (Vector3.new(tgt2.X, rp2.Position.Y, tgt2.Z) - rp2.Position).Magnitude < 1 then
                if AP_RightPhase2 == 2 then
                    hum3:Move(Vector3.zero, false); rp2.AssemblyLinearVelocity = Vector3.zero
                    AP_RightOn = false; if AP_RightConn then AP_RightConn:Disconnect(); AP_RightConn = nil end
                    AP_RightPhase2 = 1; if AP_SetRightV then AP_SetRightV(false) end; return
                else AP_RightPhase2 = 2 end
            end
            local d2 = tgt2 - rp2.Position; local mv4 = Vector3.new(d2.X, 0, d2.Z).Unit
            hum3:Move(mv4, false); rp2.AssemblyLinearVelocity = Vector3.new(mv4.X*AP_SPEED, rp2.AssemblyLinearVelocity.Y, mv4.Z*AP_SPEED)
        end)
    else
        if AP_RightConn then AP_RightConn:Disconnect(); AP_RightConn = nil end
        AP_RightPhase2 = 1
    end
end)

mkAPToggle("Full Auto L [G]", APO(), function(on)
    fullAutoPlayLeftEnabled = on; setFALVisual(on)
    if fullAutoLeftSetter then fullAutoLeftSetter(on) end
    if on then startFullAutoLeft() else stopFullAutoLeft() end
end)

mkAPToggle("Full Auto R [H]", APO(), function(on)
    fullAutoPlayRightEnabled = on; setFARVisual(on)
    if fullAutoRightSetter then fullAutoRightSetter(on) end
    if on then startFullAutoRight() else stopFullAutoRight() end
end)

-- AP speed input
local apSpeedRow = Instance.new("Frame", apBody)
apSpeedRow.Size = UDim2.new(1, 0, 0, 38); apSpeedRow.BackgroundColor3 = C_CARD
apSpeedRow.BorderSizePixel = 0; apSpeedRow.LayoutOrder = APO()
Instance.new("UICorner", apSpeedRow).CornerRadius = UDim.new(0, 8)
local apSL = Instance.new("TextLabel", apSpeedRow)
apSL.Size = UDim2.new(0.55, 0, 1, 0); apSL.Position = UDim2.new(0, 10, 0, 0)
apSL.BackgroundTransparency = 1; apSL.Text = "AP Speed"; apSL.TextColor3 = C_WHITE
apSL.Font = Enum.Font.GothamBold; apSL.TextSize = 12; apSL.TextXAlignment = Enum.TextXAlignment.Left; apSL.ZIndex = 4
local apSBox = Instance.new("TextBox", apSpeedRow)
apSBox.Size = UDim2.new(0, 65, 0, 24); apSBox.Position = UDim2.new(1, -73, 0.5, -12)
apSBox.BackgroundColor3 = C_BG; apSBox.BorderSizePixel = 0
apSBox.Text = tostring(AP_SPEED); apSBox.TextColor3 = C_WHITE
apSBox.Font = Enum.Font.GothamBold; apSBox.TextSize = 11; apSBox.ZIndex = 4
Instance.new("UICorner", apSBox).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", apSBox).Color = C_ACCENT
apSBox.FocusLost:Connect(function()
    local n = tonumber(apSBox.Text)
    if n then AP_SPEED = math.clamp(n, 1, 9999); apSBox.Text = tostring(AP_SPEED)
    else apSBox.Text = tostring(AP_SPEED) end
end)

-- AP keybind
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local kc = input.KeyCode
    if kc == Enum.KeyCode.Z then
        AP_LeftOn = not AP_LeftOn; if AP_SetLeftV then AP_SetLeftV(AP_LeftOn) end
    end
    if kc == Enum.KeyCode.C then
        AP_RightOn = not AP_RightOn; if AP_SetRightV then AP_SetRightV(AP_RightOn) end
    end
    if kc == Enum.KeyCode.P then
        apMain.Visible = not apMain.Visible; apReopen.Visible = not apMain.Visible
    end
end)

print("✓ 111 DUEL loaded")
end)()
