-- SASUKE NDS TROLL HUB v1.0
-- Natural Disaster Survival | Luau / mobile / Delta
-- Tudo roda localmente, sem HTTP, key ou codigo externo.
-- O chute tenta aplicar um impulso fisico proximo. O servidor pode ignorar.
-- Emote Dropkick: animacao de referencia publica 133566007754001.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local env = (type(getgenv) == "function" and getgenv()) or _G
if env.SasukeNDS and type(env.SasukeNDS.Close) == "function" then
    pcall(env.SasukeNDS.Close)
end

local C = {
    bg = Color3.fromRGB(18, 14, 26),
    panel = Color3.fromRGB(33, 25, 45),
    row = Color3.fromRGB(43, 34, 57),
    purple = Color3.fromRGB(163, 83, 250),
    red = Color3.fromRGB(213, 59, 86),
    white = Color3.fromRGB(248, 240, 255),
    dim = Color3.fromRGB(185, 163, 210),
    off = Color3.fromRGB(81, 72, 101)
}
local opts = {
    kick = false,
    kickForce = 90,
    fastEmote = false,
    emoteSpeed = 2,
    spin = false,
    rainbow = false,
    bigHead = false,
    ghost = false,
    noclip = false,
    walkSpeed = 16,
    jump = 50
}
local alive = true
local busy = false
local connections = {}
local touchedTracks = setmetatable({}, {__mode = "k"})
local savedColors = setmetatable({}, {__mode = "k"})
local savedAlpha = setmetatable({}, {__mode = "k"})
local savedCollision = setmetatable({}, {__mode = "k"})
local savedHead = setmetatable({}, {__mode = "k"})
local selectedPlayer
local dropkickTrack, dropkickAnimation
local fx = Instance.new("Folder")
fx.Name = "SasukeNDS_ClientFX"
fx.Parent = workspace

local function connect(sig, fn)
    local connection = sig:Connect(fn)
    connections[#connections + 1] = connection
    return connection
end
local function make(class, parent, props)
    local obj = Instance.new(class)
    for property, value in pairs(props or {}) do obj[property] = value end
    obj.Parent = parent
    return obj
end
local function corner(parent, radius)
    return make("UICorner", parent, {CornerRadius = UDim.new(0, radius or 9)})
end
local function getChar(p)
    p = p or player
    local char = p.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then return nil end
    return char, root, hum
end

local gui = make("ScreenGui", nil, {
    Name = "SasukeNDSTrollHub", ResetOnSpawn = false,
    IgnoreGuiInset = true, ZIndexBehavior = Enum.ZIndexBehavior.Sibling
})
local okParent = pcall(function()
    if type(gethui) == "function" then
        gui.Parent = gethui()
    else
        gui.Parent = CoreGui
    end
end)
if not okParent then gui.Parent = player:WaitForChild("PlayerGui") end

local main = make("Frame", gui, {
    Size = UDim2.fromOffset(335, 444),
    Position = UDim2.new(0.5, -167, 0.45, -210),
    BackgroundColor3 = C.bg, BorderSizePixel = 0, Active = true,
    ClipsDescendants = true
})
corner(main, 15)
make("UIStroke", main, {Color = C.purple, Thickness = 1.5, Transparency = 0.18})
local header = make("Frame", main, {
    Size = UDim2.new(1, 0, 0, 49), BackgroundColor3 = C.panel,
    BorderSizePixel = 0, Active = true
})
corner(header, 14)
make("Frame", header, {Position = UDim2.new(0, 0, 1, -12),
    Size = UDim2.new(1, 0, 0, 12), BackgroundColor3 = C.panel,
    BorderSizePixel = 0})
make("TextLabel", header, {
    Size = UDim2.fromOffset(38, 43), Position = UDim2.fromOffset(9, 1),
    BackgroundTransparency = 1, Text = "◉", Font = Enum.Font.GothamBold,
    TextColor3 = C.red, TextSize = 30
})
make("TextLabel", header, {
    Size = UDim2.fromOffset(217, 25), Position = UDim2.fromOffset(43, 3),
    BackgroundTransparency = 1, Text = "SASUKE  /  NDS", TextColor3 = C.white,
    Font = Enum.Font.GothamBold, TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Left
})
make("TextLabel", header, {
    Size = UDim2.fromOffset(220, 15), Position = UDim2.fromOffset(43, 27),
    BackgroundTransparency = 1, Text = "TROLL HUB  •  v1.0", TextColor3 = C.dim,
    Font = Enum.Font.Gotham, TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left
})
local function headerBtn(label, x)
    local b = make("TextButton", header, {
        Size = UDim2.fromOffset(26, 27), Position = UDim2.fromOffset(x, 10),
        BackgroundColor3 = C.off, TextColor3 = C.white,
        Text = label, Font = Enum.Font.GothamBold, TextSize = 15,
        AutoButtonColor = true
    })
    corner(b, 7)
    return b
end
local minBtn = headerBtn("−", 273)
local closeBtn = headerBtn("×", 303)

local tabs = make("Frame", main, {
    Size = UDim2.new(1, -16, 0, 41), Position = UDim2.fromOffset(8, 53),
    BackgroundTransparency = 1
})
local pages = make("Frame", main, {
    Size = UDim2.new(1, -18, 1, -143), Position = UDim2.fromOffset(9, 100),
    BackgroundTransparency = 1, ClipsDescendants = true
})
local info = make("TextLabel", main, {
    Size = UDim2.new(1, -18, 0, 34), Position = UDim2.new(0, 9, 1, -39),
    BackgroundColor3 = C.panel, TextColor3 = C.dim,
    Text = "PRONTO PARA TROLLAR", Font = Enum.Font.GothamMedium,
    TextSize = 11, TextWrapped = true, BorderSizePixel = 0
})
corner(info, 7)
local function status(txt)
    if not alive then return end
    info.Text = tostring(txt)
end

local pageMap, tabMap = {}, {}
local function page(name)
    local view = make("ScrollingFrame", pages, {
        Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 2, ScrollBarImageColor3 = C.purple,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false
    })
    make("UIPadding", view, {PaddingTop = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 4)})
    make("UIListLayout", view, {Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder})
    pageMap[name] = view
    return view
end
local kickPage = page("CHUTE")
local emotePage = page("EMOTES")
local trollPage = page("TROLL")
local movePage = page("MOVE")
local tabNames = {"CHUTE", "EMOTES", "TROLL", "MOVE"}
local function selectTab(chosen)
    for name, view in pairs(pageMap) do
        view.Visible = name == chosen
    end
    for name, btn in pairs(tabMap) do
        btn.BackgroundColor3 = name == chosen and C.purple or C.panel
    end
end
for i, name in ipairs(tabNames) do
    local b = make("TextButton", tabs, {
        Size = UDim2.new(0.25, -4, 0, 34),
        Position = UDim2.new((i - 1) * 0.25, 2, 0, 3),
        BackgroundColor3 = C.panel, BorderSizePixel = 0,
        Text = name, TextColor3 = C.white,
        Font = Enum.Font.GothamBold, TextSize = 11
    })
    corner(b, 7)
    tabMap[name] = b
    connect(b.MouseButton1Click, function() selectTab(name) end)
end
selectTab("CHUTE")

local function rowFrame(parent, height)
    local row = make("Frame", parent, {
        Size = UDim2.new(1, -2, 0, height or 63),
        BackgroundColor3 = C.row, BorderSizePixel = 0
    })
    corner(row, 10)
    return row
end
local function labelText(parent, txt, y, w, sz, tint)
    return make("TextLabel", parent, {
        Position = UDim2.fromOffset(11, y),
        Size = UDim2.new(0, w or 210, 0, sz == 10 and 16 or 25),
        BackgroundTransparency = 1, Text = txt,
        TextColor3 = tint or C.white, TextSize = sz or 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = sz == 10 and Enum.Font.Gotham or Enum.Font.GothamMedium,
        TextTruncate = Enum.TextTruncate.AtEnd
    })
end
local function toggle(parent, title, description, initial, callback)
    local row = rowFrame(parent, 61)
    labelText(row, title, 6, 215, 12)
    labelText(row, description, 32, 216, 10, C.dim)
    local button = make("TextButton", row, {
        Size = UDim2.fromOffset(67, 30), Position = UDim2.new(1, -79, 0, 15),
        TextColor3 = C.white, Font = Enum.Font.GothamBold, TextSize = 11,
        AutoButtonColor = true, BorderSizePixel = 0
    })
    corner(button, 7)
    local current = initial
    local function refresh()
        button.BackgroundColor3 = current and C.purple or C.off
        button.Text = current and "ON" or "OFF"
    end
    refresh()
    connect(button.MouseButton1Click, function()
        current = not current
        refresh()
        callback(current)
    end)
    return function(v)
        current = not not v
        refresh()
    end
end
local function action(parent, title, description, buttonText, callback)
    local row = rowFrame(parent, 62)
    labelText(row, title, 5, 201, 12)
    labelText(row, description, 31, 202, 10, C.dim)
    local button = make("TextButton", row, {
        Size = UDim2.fromOffset(78, 31), Position = UDim2.new(1, -90, 0, 15),
        BackgroundColor3 = C.red, BorderSizePixel = 0,
        Text = buttonText, TextColor3 = C.white,
        Font = Enum.Font.GothamBold, TextSize = 11
    })
    corner(button, 7)
    connect(button.MouseButton1Click, callback)
    return button
end
local function valueRow(parent, title, description, value, minimum, maximum, step, onChange, formatter)
    local row = rowFrame(parent, 75)
    labelText(row, title, 5, 275, 12)
    labelText(row, description, 31, 168, 10, C.dim)
    local valueLabel = labelText(row, "", 49, 115, 12, C.purple)
    local function btn(txt, x)
        local b = make("TextButton", row, {
            Size = UDim2.fromOffset(39, 30),
            Position = UDim2.new(1, x, 0, 34),
            Text = txt, Font = Enum.Font.GothamBold,
            TextSize = 17, TextColor3 = C.white,
            BackgroundColor3 = C.off, BorderSizePixel = 0
        })
        corner(b, 7)
        return b
    end
    local minus, plus = btn("−", -95), btn("+", -49)
    local function refresh()
        valueLabel.Text = formatter and formatter(value) or tostring(value)
    end
    refresh()
    connect(minus.MouseButton1Click, function()
        value = math.max(minimum, value - step)
        refresh()
        onChange(value)
    end)
    connect(plus.MouseButton1Click, function()
        value = math.min(maximum, value + step)
        refresh()
        onChange(value)
    end)
end

-- Botao flutuante: aparece somente ao ativar CHUTE TROLL.
local kickButton = make("TextButton", gui, {
    Name = "KickNow", Size = UDim2.fromOffset(127, 56),
    Position = UDim2.new(1, -142, 0.68, 0),
    Text = "🦵  CHUTAR", BackgroundColor3 = C.red,
    TextColor3 = C.white, TextSize = 16,
    Font = Enum.Font.GothamBold, BorderSizePixel = 0,
    Visible = false, Active = true
})
corner(kickButton, 14)
make("UIStroke", kickButton, {Color = C.purple, Thickness = 2, Transparency = 0.15})

local function nearestPlayer()
    local _, root = getChar()
    if not root then return nil end
    local best, distance = nil, math.huge
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local _, otherRoot = getChar(other)
            if otherRoot then
                local d = (otherRoot.Position - root.Position).Magnitude
                if d < distance then best, distance = other, d end
            end
        end
    end
    return best, distance
end
local function target()
    if selectedPlayer and selectedPlayer.Parent == Players then
        if getChar(selectedPlayer) then return selectedPlayer end
    end
    return nearestPlayer()
end
local function listOtherPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and getChar(p) then list[#list + 1] = p end
    end
    table.sort(list, function(a, b) return a.Name:lower() < b.Name:lower() end)
    return list
end
local function nextTarget()
    local list = listOtherPlayers()
    if #list == 0 then
        selectedPlayer = nil
        status("SEM OUTROS JOGADORES DISPONIVEIS")
        return
    end
    local idx = 0
    for i, p in ipairs(list) do
        if p == selectedPlayer then
            idx = i
            break
        end
    end
    selectedPlayer = list[idx % #list + 1]
    status("ALVO: " .. selectedPlayer.DisplayName)
end

local function shockwave(position)
    if not alive then return end
    local part = make("Part", fx, {
        Name = "ChuteFX", Shape = Enum.PartType.Ball,
        Anchored = true, CanCollide = false, CanTouch = false,
        CanQuery = false, CastShadow = false,
        Material = Enum.Material.Neon,
        Color = C.purple, Transparency = 0.35,
        Size = Vector3.new(1, 1, 1), CFrame = CFrame.new(position)
    })
    TweenService:Create(part, TweenInfo.new(0.32), {
        Size = Vector3.new(12, 12, 12), Transparency = 1
    }):Play()
    Debris:AddItem(part, 0.42)
end

local function runDropkickAnimation(hum)
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return false end
    if dropkickTrack then
        pcall(function() dropkickTrack:Stop(0.06) end)
        dropkickTrack = nil
    end
    if not dropkickAnimation then
        dropkickAnimation = Instance.new("Animation")
        dropkickAnimation.Name = "SasukeDropkick"
        dropkickAnimation.AnimationId = "rbxassetid://133566007754001"
    end
    local ok, track = pcall(function()
        return animator:LoadAnimation(dropkickAnimation)
    end)
    if not ok or not track then return false end
    dropkickTrack = track
    local played = pcall(function()
        track.Priority = Enum.AnimationPriority.Action
        track:Play(0.08, 1, opts.emoteSpeed)
    end)
    task.delay(1.5, function()
        if track then
            pcall(function() track:Stop(0.06) end)
            pcall(function() track:Destroy() end)
        end
        if dropkickTrack == track then dropkickTrack = nil end
    end)
    return played
end

local function attemptFling(other, myRoot, otherRoot)
    if not otherRoot or not otherRoot.Parent then return false end
    if (otherRoot.Position - myRoot.Position).Magnitude > 7.5 then return false end
    local delta = otherRoot.Position - myRoot.Position
    local flat = Vector3.new(delta.X, 0, delta.Z)
    local direction = flat.Magnitude > 0.1 and flat.Unit or myRoot.CFrame.LookVector
    local amount = math.clamp(opts.kickForce, 40, 140)
    local impulse = direction * amount + Vector3.new(0, amount * 0.65, 0)
    -- Somente tentativa. O servidor pode ignorar alteracoes de outros personagens.
    local applied = pcall(function()
        otherRoot:ApplyImpulse(impulse * otherRoot.AssemblyMass)
        otherRoot.AssemblyLinearVelocity = impulse
    end)
    -- Empurrao fisico moderado com o proprio personagem: funciona somente
    -- se houver contato e o servidor aceitar a simulacao. Sem velocidades absurdas.
    local contact = pcall(function()
        myRoot:ApplyImpulse(direction * myRoot.AssemblyMass * 28)
    end)
    return applied or contact
end

local function kickNow()
    if not alive or not opts.kick or busy then return end
    busy = true
    kickButton.Text = "EM ACAO..."
    task.spawn(function()
        local success, reason = pcall(function()
            local who = target()
            if not who then status("SEM JOGADOR PARA CHUTAR") return end
            local _, myRoot, hum = getChar()
            local _, otherRoot = getChar(who)
            if not myRoot or not otherRoot then status("ALVO NAO DISPONIVEL") return end
            local maxApproach = 95
            if (myRoot.Position - otherRoot.Position).Magnitude > maxApproach then
                status("ALVO LONGE DEMAIS (ATE 95 STUDS)")
                return
            end
            status("INDO ATE: " .. who.DisplayName)
            local started = os.clock()
            while alive and opts.kick and (myRoot.Position - otherRoot.Position).Magnitude > 5.1 do
                if os.clock() - started > 5 then
                    status("NAO CONSEGUI CHEGAR PERTO DO ALVO")
                    return
                end
                local _, mRoot, mHum = getChar()
                local _, tRoot = getChar(who)
                if not mRoot or not tRoot then status("ALVO PERDIDO") return end
                myRoot, hum, otherRoot = mRoot, mHum, tRoot
                hum:MoveTo(otherRoot.Position)
                task.wait(0.15)
            end
            if not alive or not opts.kick then return end
            if not myRoot.Parent or not otherRoot.Parent then return end
            local flat = otherRoot.Position - myRoot.Position
            if Vector3.new(flat.X, 0, flat.Z).Magnitude > 0.1 then
                myRoot.CFrame = CFrame.lookAt(myRoot.Position,
                    Vector3.new(otherRoot.Position.X, myRoot.Position.Y, otherRoot.Position.Z))
            end
            local animated = runDropkickAnimation(hum)
            task.wait(0.23)
            if not alive or not opts.kick then return end
            local attempt = attemptFling(who, myRoot, otherRoot)
            shockwave(otherRoot.Position)
            if not animated then
                status("CHUTE VISUAL INDISPONIVEL; IMPULSO TENTADO")
            elseif attempt then
                status("CHUTE EM " .. who.DisplayName .. "! (FLING NAO GARANTIDO)")
            else
                status("EMOTE FEITO; SERVIDOR PODE BLOQUEAR FLING")
            end
        end)
        if not success then status("ERRO NO CHUTE: " .. tostring(reason):sub(1, 55)) end
        task.wait(0.35)
        busy = false
        if kickButton and kickButton.Parent then kickButton.Text = "🦵  CHUTAR" end
    end)
end

-- EMOTES: mudar somente tracks de emote/acoes, sem acelerar caminhada.
local function isEmote(track)
    local name = string.lower(track.Name or "")
    if name:find("walk", 1, true) or name:find("run", 1, true)
       or name:find("fall", 1, true) or name:find("jump", 1, true)
       or name:find("swim", 1, true) or name:find("climb", 1, true) then
        return false
    end
    if name:find("dance", 1, true) or name:find("emote", 1, true)
       or name:find("kick", 1, true) or name:find("pose", 1, true) then
        return true
    end
    return track.Priority == Enum.AnimationPriority.Action
        or track.Priority == Enum.AnimationPriority.Action2
        or track.Priority == Enum.AnimationPriority.Action3
        or track.Priority == Enum.AnimationPriority.Action4
end
local function boostEmotes(forceAny)
    local _, _, hum = getChar()
    local animator = hum and hum:FindFirstChildOfClass("Animator")
    if not animator then return 0 end
    local count = 0
    local ok, tracks = pcall(function() return animator:GetPlayingAnimationTracks() end)
    if not ok or not tracks then return 0 end
    for _, track in ipairs(tracks) do
        if track.IsPlaying and (isEmote(track) or (forceAny and track.Priority ~= Enum.AnimationPriority.Core)) then
            if touchedTracks[track] == nil then
                touchedTracks[track] = track.Speed
            end
            local speed = opts.emoteSpeed
            if pcall(function() track:AdjustSpeed(speed) end) then count = count + 1 end
        end
    end
    return count
end
local function resetEmotes()
    for track, oldSpeed in pairs(touchedTracks) do
        pcall(function()
            if track.IsPlaying then track:AdjustSpeed(oldSpeed) end
        end)
        touchedTracks[track] = nil
    end
end

local function restoreColors()
    for part, old in pairs(savedColors) do
        pcall(function() part.Color = old end)
        savedColors[part] = nil
    end
end
local function restoreTransparency()
    for part, old in pairs(savedAlpha) do
        pcall(function() part.Transparency = old end)
        savedAlpha[part] = nil
    end
end
local function restoreCollisions()
    for part, old in pairs(savedCollision) do
        pcall(function() part.CanCollide = old end)
        savedCollision[part] = nil
    end
end
local function restoreHeads()
    for h, size in pairs(savedHead) do
        pcall(function() h.Size = size end)
        savedHead[h] = nil
    end
end
local function rainbowTick(t)
    local character = player.Character
    if not character then return end
    for _, item in ipairs(character:GetDescendants()) do
        if item:IsA("BasePart") and item.Name ~= "HumanoidRootPart" then
            if savedColors[item] == nil then savedColors[item] = item.Color end
            item.Color = Color3.fromHSV((t * 0.14) % 1, 0.9, 1)
        end
    end
end
local function ghostTick()
    local character = player.Character
    if not character then return end
    for _, item in ipairs(character:GetDescendants()) do
        if item:IsA("BasePart") and item.Name ~= "HumanoidRootPart" then
            if savedAlpha[item] == nil then savedAlpha[item] = item.Transparency end
            item.Transparency = 0.75
        end
    end
end
local function noclipTick()
    local character = player.Character
    if not character then return end
    for _, item in ipairs(character:GetDescendants()) do
        if item:IsA("BasePart") and item.CanCollide then
            if savedCollision[item] == nil then savedCollision[item] = true end
            item.CanCollide = false
        end
    end
end
local function headTick()
    local character = player.Character
    local head = character and character:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        if savedHead[head] == nil then savedHead[head] = head.Size end
        head.Size = Vector3.new(4, 4, 4) -- Apenas visual local.
    end
end
local function fakeMeteor()
    local _, root = getChar()
    if not root then return end
    status("CHUVA DE METEOROS FALSA: SO VOCE VE")
    for i = 1, 8 do
        local a = math.random() * math.pi * 2
        local radius = math.random(6, 28)
        local start = root.Position + Vector3.new(
            math.cos(a) * radius, 42 + math.random(2, 14), math.sin(a) * radius)
        local ball = make("Part", fx, {
            Name = "FakeMeteor", Shape = Enum.PartType.Ball,
            Anchored = true, CanCollide = false, CanTouch = false,
            CanQuery = false, CastShadow = false,
            Size = Vector3.new(2.3, 2.3, 2.3),
            Color = C.red, Material = Enum.Material.Neon,
            Position = start
        })
        TweenService:Create(ball, TweenInfo.new(0.8 + i * 0.055,
            Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = start - Vector3.new(0, 43, 0), Transparency = 0.6
        }):Play()
        Debris:AddItem(ball, 1.55)
    end
end

-- Controles: CHUTE
local setKick = toggle(kickPage, "CHUTE TROLL", "Mostra um botao flutuante de chute", false, function(v)
    opts.kick = v
    kickButton.Visible = v
    status(v and "CHUTE ATIVO: TOQUE EM CHUTAR" or "CHUTE DESLIGADO")
end)
action(kickPage, "ESCOLHER ALVO", "Alternar jogadores ou usar mais proximo", "PROXIMO", nextTarget)
action(kickPage, "ALVO MAIS PROXIMO", "Desmarca o alvo selecionado", "AUTO", function()
    selectedPlayer = nil
    local p = nearestPlayer()
    status(p and ("ALVO AUTOMATICO: " .. p.DisplayName) or "SEM ALVOS")
end)
valueRow(kickPage, "FORCA DO IMPULSO", "Tentativa, depende do servidor", opts.kickForce,
    40, 140, 10, function(v) opts.kickForce = v end,
    function(v) return tostring(v) end)
action(kickPage, "CHUTAR AGORA", "Aproxima e executa o emote", "CHUTAR", kickNow)

-- Controles: EMOTES
local setTurbo = toggle(emotePage, "TURBO EMOTE", "Acelera os emotes que estiverem tocando", false, function(v)
    opts.fastEmote = v
    if v then
        status("TURBO EMOTE ATIVADO")
        boostEmotes(false)
    else
        resetEmotes()
        status("VELOCIDADE NORMAL RESTAURADA")
    end
end)
valueRow(emotePage, "VELOCIDADE DO EMOTE", "De 0.5x a 4.0x", opts.emoteSpeed,
    0.5, 4, 0.5, function(v)
        opts.emoteSpeed = v
        if opts.fastEmote then boostEmotes(false) end
    end, function(v) return string.format("%.1fx", v) end)
action(emotePage, "ACELERAR AGORA", "Aplica velocidade a animacao atual", "APLICAR", function()
    local n = boostEmotes(true)
    status(n > 0 and ("VELOCIDADE APLICADA: " .. n .. " ANIMACOES")
        or "NENHUM EMOTE ATIVO ENCONTRADO")
end)
action(emotePage, "RESTAURAR EMOTES", "Volta as animacoes alteradas ao normal", "RESET", function()
    opts.fastEmote = false
    setTurbo(false)
    resetEmotes()
    status("EMOTES RESTAURADOS")
end)

-- Controles: TROLL
local setSpin = toggle(trollPage, "MODO TORNADO", "Giro do proprio personagem", false, function(v)
    opts.spin = v
    local _, _, hum = getChar()
    if hum then hum.AutoRotate = not v end
    status(v and "GIRO ATIVO" or "GIRO DESATIVADO")
end)
toggle(trollPage, "RAINBOW", "Cor do seu personagem muda localmente", false, function(v)
    opts.rainbow = v
    if not v then restoreColors() end
end)
toggle(trollPage, "CABECONA", "Aumenta sua cabeca (efeito local)", false, function(v)
    opts.bigHead = v
    if not v then restoreHeads() end
end)
toggle(trollPage, "FANTASMA", "Transparencia do seu avatar, so cliente", false, function(v)
    opts.ghost = v
    if not v then restoreTransparency() end
end)
action(trollPage, "EXPLOSAO FALSA", "Efeito neon perto do seu personagem", "BOOM", function()
    local _, root = getChar()
    if root then shockwave(root.Position) end
    status("EXPLOSAO VISUAL • SO VOCE VE")
end)
action(trollPage, "METEOROS FALSOS", "Chuva de meteoros visual local", "CHUVA", fakeMeteor)

-- Controles: MOVE
valueRow(movePage, "VELOCIDADE DO PERSONAGEM", "Andar de 16 a 40", opts.walkSpeed,
    16, 40, 4, function(v)
        opts.walkSpeed = v
        local _, _, hum = getChar()
        if hum then hum.WalkSpeed = v end
    end)
valueRow(movePage, "PODER DE PULO", "Pulo de 50 a 110", opts.jump,
    50, 110, 10, function(v)
        opts.jump = v
        local _, _, hum = getChar()
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = v
        end
    end)
local setNoclip = toggle(movePage, "NOCLIP", "Passar por partes localmente", false, function(v)
    opts.noclip = v
    if not v then restoreCollisions() end
end)
action(movePage, "RESTAURAR MOVIMENTO", "Voltar caminhada/pulo padroes", "RESET", function()
    opts.walkSpeed = 16
    opts.jump = 50
    opts.noclip = false
    opts.spin = false
    setNoclip(false)
    setSpin(false)
    restoreCollisions()
    local _, root, hum = getChar()
    if hum then
        hum.WalkSpeed = 16
        hum.UseJumpPower = true
        hum.JumpPower = 50
        hum.AutoRotate = true
    end
    if root then root.AssemblyAngularVelocity = Vector3.zero end
    status("MOVIMENTO RESTAURADO")
end)

connect(kickButton.MouseButton1Click, kickNow)

-- Arrastar somente pela barra superior.
local dragging, pointer, origin, startPos = false, nil, nil, nil
connect(header.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        pointer = input
        origin = input.Position
        startPos = main.Position
    end
end)
connect(UIS.InputChanged, function(input)
    if dragging and origin and startPos and
       (input == pointer or (pointer and pointer.UserInputType == Enum.UserInputType.MouseButton1
       and input.UserInputType == Enum.UserInputType.MouseMovement)) then
        local diff = input.Position - origin
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + diff.X,
            startPos.Y.Scale, startPos.Y.Offset + diff.Y)
    end
end)
connect(UIS.InputEnded, function(input)
    if input == pointer or
       (pointer and pointer.UserInputType == Enum.UserInputType.MouseButton1
        and input.UserInputType == Enum.UserInputType.MouseButton1) then
        dragging, pointer = false, nil
    end
end)
local minimized = false
connect(minBtn.MouseButton1Click, function()
    minimized = not minimized
    tabs.Visible = not minimized
    pages.Visible = not minimized
    info.Visible = not minimized
    main.Size = UDim2.fromOffset(335, minimized and 49 or 444)
    minBtn.Text = minimized and "+" or "−"
end)

-- Um unico loop leve, para evitar varios Heartbeats concorrentes.
local accumulated = 0
connect(RunService.Heartbeat, function(dt)
    if not alive then return end
    accumulated = accumulated + dt
    if accumulated < 0.14 then return end
    accumulated = 0
    local character, root, hum = getChar()
    if not character then return end
    if opts.fastEmote then pcall(boostEmotes, false) end
    if opts.spin and root then
        hum.AutoRotate = false
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(22), 0)
    end
    if opts.bigHead then pcall(headTick) end
    if opts.rainbow then pcall(rainbowTick, os.clock()) end
    if opts.ghost then pcall(ghostTick) end
    if opts.noclip then pcall(noclipTick) end
end)

local function close()
    if not alive then return end
    alive = false
    opts.kick, opts.spin, opts.noclip, opts.fastEmote = false, false, false, false
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    local _, root, hum = getChar()
    if hum then
        hum.AutoRotate = true
        hum.WalkSpeed = 16
        hum.UseJumpPower = true
        hum.JumpPower = 50
    end
    if root then pcall(function() root.AssemblyAngularVelocity = Vector3.zero end) end
    resetEmotes()
    restoreColors()
    restoreTransparency()
    restoreCollisions()
    restoreHeads()
    if dropkickTrack then pcall(function() dropkickTrack:Stop(0) end) end
    if dropkickAnimation then dropkickAnimation:Destroy() end
    if fx then fx:Destroy() end
    if gui then gui:Destroy() end
    if env.SasukeNDS and env.SasukeNDS.Close == close then env.SasukeNDS = nil end
end
connect(closeBtn.MouseButton1Click, close)
env.SasukeNDS = {Close = close, Version = "1.0"}
status("PRONTO • ATIVE CHUTE TROLL PARA MOSTRAR BOTAO")