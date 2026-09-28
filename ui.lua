local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local userInput = game:GetService("UserInputService")

local theme = {
	background = Color3.fromRGB(17, 17, 23),
	sidebar = Color3.fromRGB(21, 21, 28),
	surface = Color3.fromRGB(28, 28, 37),
	hover = Color3.fromRGB(36, 36, 47),
	stroke = Color3.fromRGB(44, 44, 58),
	text = Color3.fromRGB(236, 236, 245),
	muted = Color3.fromRGB(135, 135, 156),
	accent = Color3.fromRGB(124, 92, 255),
	off = Color3.fromRGB(55, 55, 72),
}

local library = {}

local function make(class, props, parent)
	local inst = Instance.new(class)
	for key, value in pairs(props) do
		inst[key] = value
	end
	inst.Parent = parent
	return inst
end

local function corner(inst, radius)
	return make("UICorner", { CornerRadius = UDim.new(0, radius) }, inst)
end

local function outline(inst, color)
	return make("UIStroke", {
		Color = color or theme.stroke,
		Thickness = 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, inst)
end

local function animate(inst, props, time)
	tweenService:Create(inst, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function attach(gui)
	local ok = pcall(function()
		gui.Parent = gethui and gethui() or game:GetService("CoreGui")
	end)
	if not ok or not gui.Parent then
		gui.Parent = players.LocalPlayer:WaitForChild("PlayerGui")
	end
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

local tabMethods = {}
tabMethods.__index = tabMethods

function tabMethods:nextOrder()
	self.order = self.order + 1
	return self.order
end

function tabMethods:row(height)
	local row = make("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = theme.surface,
		BorderSizePixel = 0,
		LayoutOrder = self:nextOrder(),
	}, self.page)
	corner(row, 8)
	return row
end

function tabMethods:section(text)
	make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 22),
		BackgroundTransparency = 1,
		Text = string.upper(text),
		TextColor3 = theme.muted,
		Font = Enum.Font.GothamBold,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = self:nextOrder(),
	}, self.page)
end

function tabMethods:label(text)
	local row = self:row(34)
	local label = make("TextLabel", {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = theme.text,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	return {
		set = function(_, newText)
			label.Text = newText
		end,
	}
end

function tabMethods:toggle(options)
	local state = options.default == true
	local row = self:row(40)

	make("TextLabel", {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -74, 1, 0),
		BackgroundTransparency = 1,
		Text = options.name,
		TextColor3 = theme.text,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)

	local track = make("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(38, 20),
		BackgroundColor3 = state and theme.accent or theme.off,
		BorderSizePixel = 0,
	}, row)
	corner(track, 10)

	local knob = make("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	}, track)
	corner(knob, 8)

	local function apply(silent)
		animate(track, { BackgroundColor3 = state and theme.accent or theme.off })
		animate(knob, { Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
		if not silent and options.callback then
			task.spawn(options.callback, state)
		end
	end

	local hit = make("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
	}, row)
	hit.MouseEnter:Connect(function()
		animate(row, { BackgroundColor3 = theme.hover })
	end)
	hit.MouseLeave:Connect(function()
		animate(row, { BackgroundColor3 = theme.surface })
	end)
	hit.Activated:Connect(function()
		state = not state
		apply(false)
	end)

	return {
		set = function(_, value)
			state = value
			apply(true)
		end,
	}
end

function tabMethods:button(options)
	local row = self:row(38)
	local hit = make("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = options.name,
		TextColor3 = theme.text,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
	}, row)
	hit.MouseEnter:Connect(function()
		animate(row, { BackgroundColor3 = theme.hover })
	end)
	hit.MouseLeave:Connect(function()
		animate(row, { BackgroundColor3 = theme.surface })
	end)
	hit.Activated:Connect(function()
		if options.callback then
			task.spawn(options.callback)
		end
	end)
end

function tabMethods:slider(options)
	local min = options.min or 0
	local max = options.max or 100
	local value = math.clamp(options.default or min, min, max)
	local row = self:row(54)

	make("TextLabel", {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -80, 0, 30),
		BackgroundTransparency = 1,
		Text = options.name,
		TextColor3 = theme.text,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)

	local valueLabel = make("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		Size = UDim2.fromOffset(60, 30),
		BackgroundTransparency = 1,
		Text = tostring(value),
		TextColor3 = theme.accent,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, row)

	local bar = make("Frame", {
		Position = UDim2.fromOffset(12, 36),
		Size = UDim2.new(1, -24, 0, 6),
		BackgroundColor3 = theme.off,
		BorderSizePixel = 0,
	}, row)
	corner(bar, 3)

	local fill = make("Frame", {
		Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0),
		BackgroundColor3 = theme.accent,
		BorderSizePixel = 0,
	}, bar)
	corner(fill, 3)

	local hit = make("TextButton", {
		Position = UDim2.fromOffset(12, 26),
		Size = UDim2.new(1, -24, 0, 26),
		BackgroundTransparency = 1,
		Text = "",
	}, row)

	local dragging = false
	local function setFromX(x)
		local alpha = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		local newValue = math.floor(min + (max - min) * alpha + 0.5)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		valueLabel.Text = tostring(newValue)
		if newValue ~= value then
			value = newValue
			if options.callback then
				task.spawn(options.callback, value)
			end
		end
	end

	hit.InputBegan:Connect(function(input)
		if isPress(input) then
			dragging = true
			setFromX(input.Position.X)
		end
	end)
	userInput.InputChanged:Connect(function(input)
		if dragging and isMove(input) then
			setFromX(input.Position.X)
		end
	end)
	userInput.InputEnded:Connect(function(input)
		if isPress(input) then
			dragging = false
		end
	end)
end

local windowMethods = {}
windowMethods.__index = windowMethods

function windowMethods:selectTab(target)
	for _, tab in ipairs(self.tabs) do
		local active = tab == target
		tab.page.Visible = active
		animate(tab.button, {
			BackgroundTransparency = active and 0 or 1,
			TextColor3 = active and theme.text or theme.muted,
		})
		tab.indicator.Visible = active
	end
end

function windowMethods:addTab(name)
	local tab = setmetatable({ order = 0 }, tabMethods)

	tab.button = make("TextButton", {
		Size = UDim2.new(1, 0, 0, 34),
		BackgroundColor3 = theme.surface,
		BackgroundTransparency = 1,
		Text = "   " .. name,
		TextColor3 = theme.muted,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		LayoutOrder = #self.tabs + 1,
	}, self.sidebar)
	corner(tab.button, 8)

	tab.indicator = make("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(3, 16),
		BackgroundColor3 = theme.accent,
		BorderSizePixel = 0,
		Visible = false,
	}, tab.button)
	corner(tab.indicator, 2)

	tab.page = make("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.stroke,
		Visible = false,
	}, self.content)
	make("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, tab.page)
	make("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 14),
	}, tab.page)

	tab.button.Activated:Connect(function()
		self:selectTab(tab)
	end)

	table.insert(self.tabs, tab)
	if #self.tabs == 1 then
		self:selectTab(tab)
	end
	return tab
end

function windowMethods:notify(text, duration)
	local toast = make("Frame", {
		Size = UDim2.new(1, 0, 0, 40),
		BackgroundColor3 = theme.surface,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, self.toasts)
	corner(toast, 8)
	local toastStroke = outline(toast)
	toastStroke.Transparency = 1

	local label = make("TextLabel", {
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -24, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = theme.text,
		TextTransparency = 1,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, toast)

	animate(toast, { BackgroundTransparency = 0 }, 0.2)
	animate(toastStroke, { Transparency = 0 }, 0.2)
	animate(label, { TextTransparency = 0 }, 0.2)

	task.delay(duration or 3, function()
		animate(toast, { BackgroundTransparency = 1 }, 0.25)
		animate(toastStroke, { Transparency = 1 }, 0.25)
		animate(label, { TextTransparency = 1 }, 0.25)
		task.wait(0.3)
		toast:Destroy()
	end)
end

function windowMethods:setVisible(visible)
	self.main.Visible = visible
end

function windowMethods:destroy()
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end
	self.gui:Destroy()
end

function library.createWindow(options)
	local self = setmetatable({ tabs = {}, connections = {} }, windowMethods)

	self.gui = make("ScreenGui", {
		Name = options.name or "Window",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	attach(self.gui)

	self.main = make("Frame", {
		Size = UDim2.fromOffset(520, 340),
		Position = UDim2.new(0.5, -260, 0.5, -170),
		BackgroundColor3 = theme.background,
		BorderSizePixel = 0,
		Active = true,
		ClipsDescendants = true,
	}, self.gui)
	corner(self.main, 12)
	outline(self.main)

	local header = make("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
	}, self.main)

	make("TextLabel", {
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.new(0, 200, 1, 0),
		BackgroundTransparency = 1,
		Text = options.name or "Window",
		TextColor3 = theme.text,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, header)

	if options.version then
		local tag = make("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 132, 0.5, 0),
			Size = UDim2.fromOffset(46, 18),
			BackgroundColor3 = theme.surface,
			BorderSizePixel = 0,
		}, header)
		corner(tag, 9)
		make("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = options.version,
			TextColor3 = theme.muted,
			Font = Enum.Font.GothamMedium,
			TextSize = 10,
		}, tag)
	end

	local close = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.fromOffset(26, 26),
		BackgroundColor3 = theme.surface,
		Text = "x",
		TextColor3 = theme.muted,
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		AutoButtonColor = false,
	}, header)
	corner(close, 7)
	close.MouseEnter:Connect(function()
		animate(close, { BackgroundColor3 = Color3.fromRGB(190, 65, 75), TextColor3 = theme.text })
	end)
	close.MouseLeave:Connect(function()
		animate(close, { BackgroundColor3 = theme.surface, TextColor3 = theme.muted })
	end)
	close.Activated:Connect(function()
		self:setVisible(false)
	end)

	make("Frame", {
		Position = UDim2.fromOffset(0, 43),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = theme.stroke,
		BorderSizePixel = 0,
	}, self.main)

	self.sidebar = make("Frame", {
		Position = UDim2.fromOffset(0, 44),
		Size = UDim2.new(0, 130, 1, -44),
		BackgroundColor3 = theme.sidebar,
		BorderSizePixel = 0,
	}, self.main)
	make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, self.sidebar)
	make("UIPadding", {
		PaddingTop = UDim.new(0, 10),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	}, self.sidebar)

	self.content = make("Frame", {
		Position = UDim2.fromOffset(130, 44),
		Size = UDim2.new(1, -130, 1, -44),
		BackgroundTransparency = 1,
	}, self.main)

	self.toasts = make("Frame", {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -20, 1, -20),
		Size = UDim2.fromOffset(260, 300),
		BackgroundTransparency = 1,
	}, self.gui)
	make("UIListLayout", {
		Padding = UDim.new(0, 6),
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, self.toasts)

	local dragging = false
	local dragStart, startPosition
	header.InputBegan:Connect(function(input)
		if isPress(input) then
			dragging = true
			dragStart = input.Position
			startPosition = self.main.Position
		end
	end)
	table.insert(self.connections, userInput.InputChanged:Connect(function(input)
		if dragging and isMove(input) then
			local delta = input.Position - dragStart
			self.main.Position = UDim2.new(
				startPosition.X.Scale, startPosition.X.Offset + delta.X,
				startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
			)
		end
	end))
	table.insert(self.connections, userInput.InputEnded:Connect(function(input)
		if isPress(input) then
			dragging = false
		end
	end))

	if options.toggleKey then
		table.insert(self.connections, userInput.InputBegan:Connect(function(input, processed)
			if not processed and input.KeyCode == options.toggleKey then
				self:setVisible(not self.main.Visible)
			end
		end))
	end

	return self
end

return library
