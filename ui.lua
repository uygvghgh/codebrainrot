local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local userInput = game:GetService("UserInputService")

local colors = {
	window = Color3.fromRGB(36, 36, 36),
	titlebar = Color3.fromRGB(26, 26, 26),
	row = Color3.fromRGB(48, 48, 48),
	rowHover = Color3.fromRGB(58, 58, 58),
	border = Color3.fromRGB(70, 70, 70),
	text = Color3.fromRGB(230, 230, 230),
	dim = Color3.fromRGB(150, 150, 150),
	blue = Color3.fromRGB(50, 120, 220),
	box = Color3.fromRGB(75, 75, 75),
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

local function round(inst, radius)
	return make("UICorner", { CornerRadius = UDim.new(0, radius or 4) }, inst)
end

local function tween(inst, props, time)
	tweenService:Create(inst, TweenInfo.new(time or 0.1), props):Play()
end

local function attach(gui)
	local ok = pcall(function()
		gui.Parent = gethui and gethui() or game:GetService("CoreGui")
	end)
	if not ok or not gui.Parent then
		gui.Parent = players.LocalPlayer:WaitForChild("PlayerGui")
	end
end

local function pressed(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function moved(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

local tabClass = {}
tabClass.__index = tabClass

function tabClass:nextOrder()
	self.order = self.order + 1
	return self.order
end

function tabClass:row(height)
	local row = make("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = colors.row,
		BorderSizePixel = 0,
		LayoutOrder = self:nextOrder(),
	}, self.page)
	round(row, 4)
	return row
end

function tabClass:section(text)
	make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = colors.dim,
		Font = Enum.Font.SourceSansSemibold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = self:nextOrder(),
	}, self.page)
end

function tabClass:label(text)
	local row = self:row(26)
	local label = make("TextLabel", {
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -16, 1, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = colors.text,
		Font = Enum.Font.SourceSans,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)
	return {
		set = function(_, newText)
			label.Text = newText
		end,
	}
end

function tabClass:toggle(options)
	local on = options.default == true
	local row = self:row(30)

	make("TextLabel", {
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -44, 1, 0),
		BackgroundTransparency = 1,
		Text = options.name,
		TextColor3 = colors.text,
		Font = Enum.Font.SourceSans,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, row)

	local box = make("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = on and colors.blue or colors.box,
		BorderSizePixel = 0,
	}, row)
	round(box, 3)

	local function refresh(silent)
		tween(box, { BackgroundColor3 = on and colors.blue or colors.box })
		if not silent and options.callback then
			task.spawn(options.callback, on)
		end
	end

	local btn = make("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
	}, row)
	btn.MouseEnter:Connect(function()
		tween(row, { BackgroundColor3 = colors.rowHover })
	end)
	btn.MouseLeave:Connect(function()
		tween(row, { BackgroundColor3 = colors.row })
	end)
	btn.Activated:Connect(function()
		on = not on
		refresh(false)
	end)

	return {
		set = function(_, value)
			on = value
			refresh(true)
		end,
	}
end

function tabClass:button(options)
	local row = self:row(30)
	local btn = make("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = options.name,
		TextColor3 = colors.text,
		Font = Enum.Font.SourceSans,
		TextSize = 16,
	}, row)
	btn.MouseEnter:Connect(function()
		tween(row, { BackgroundColor3 = colors.rowHover })
	end)
	btn.MouseLeave:Connect(function()
		tween(row, { BackgroundColor3 = colors.row })
	end)
	btn.Activated:Connect(function()
		if options.callback then
			task.spawn(options.callback)
		end
	end)
end

function tabClass:slider(options)
	local min = options.min or 0
	local max = options.max or 100
	local value = math.clamp(options.default or min, min, max)
	local row = self:row(46)

	make("TextLabel", {
		Position = UDim2.fromOffset(8, 2),
		Size = UDim2.new(1, -70, 0, 22),
		BackgroundTransparency = 1,
		Text = options.name,
		TextColor3 = colors.text,
		Font = Enum.Font.SourceSans,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, row)

	local valueLabel = make("TextLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 2),
		Size = UDim2.fromOffset(56, 22),
		BackgroundTransparency = 1,
		Text = tostring(value),
		TextColor3 = colors.dim,
		Font = Enum.Font.SourceSans,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Right,
	}, row)

	local bar = make("Frame", {
		Position = UDim2.fromOffset(8, 32),
		Size = UDim2.new(1, -16, 0, 5),
		BackgroundColor3 = colors.box,
		BorderSizePixel = 0,
	}, row)

	local fill = make("Frame", {
		Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0),
		BackgroundColor3 = colors.blue,
		BorderSizePixel = 0,
	}, bar)

	local hit = make("TextButton", {
		Position = UDim2.fromOffset(8, 24),
		Size = UDim2.new(1, -16, 0, 20),
		BackgroundTransparency = 1,
		Text = "",
	}, row)

	local dragging = false
	local function update(x)
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
		if pressed(input) then
			dragging = true
			update(input.Position.X)
		end
	end)
	userInput.InputChanged:Connect(function(input)
		if dragging and moved(input) then
			update(input.Position.X)
		end
	end)
	userInput.InputEnded:Connect(function(input)
		if pressed(input) then
			dragging = false
		end
	end)
end

local windowClass = {}
windowClass.__index = windowClass

function windowClass:selectTab(target)
	for _, tab in ipairs(self.tabs) do
		local active = tab == target
		tab.page.Visible = active
		tab.button.TextColor3 = active and colors.text or colors.dim
		tab.underline.Visible = active
	end
end

function windowClass:addTab(name)
	local tab = setmetatable({ order = 0 }, tabClass)

	tab.button = make("TextButton", {
		Size = UDim2.new(0, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Text = name,
		TextColor3 = colors.dim,
		Font = Enum.Font.SourceSansSemibold,
		TextSize = 16,
		LayoutOrder = #self.tabs + 1,
	}, self.tabBar)
	make("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }, tab.button)

	tab.underline = make("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 2),
		BackgroundColor3 = colors.blue,
		BorderSizePixel = 0,
		Visible = false,
	}, tab.button)

	tab.page = make("ScrollingFrame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = colors.border,
		Visible = false,
	}, self.content)
	make("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder }, tab.page)
	make("UIPadding", {
		PaddingTop = UDim.new(0, 8),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 10),
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

function windowClass:notify(text, duration)
	local toast = make("TextLabel", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundColor3 = colors.titlebar,
		BorderSizePixel = 0,
		Text = "  " .. text,
		TextColor3 = colors.text,
		Font = Enum.Font.SourceSans,
		TextSize = 16,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, self.toasts)
	round(toast, 4)

	task.delay(duration or 3, function()
		tween(toast, { BackgroundTransparency = 1, TextTransparency = 1 }, 0.3)
		task.wait(0.35)
		toast:Destroy()
	end)
end

function windowClass:setVisible(visible)
	self.main.Visible = visible
end

function windowClass:destroy()
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end
	self.gui:Destroy()
end

function library.createWindow(options)
	local self = setmetatable({ tabs = {}, connections = {} }, windowClass)

	self.gui = make("ScreenGui", {
		Name = options.name or "Window",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	attach(self.gui)

	self.main = make("Frame", {
		Size = UDim2.fromOffset(460, 310),
		Position = UDim2.new(0.5, -230, 0.5, -155),
		BackgroundColor3 = colors.window,
		BorderSizePixel = 0,
		Active = true,
		ClipsDescendants = true,
	}, self.gui)
	round(self.main, 6)
	make("UIStroke", { Color = colors.border, Thickness = 1 }, self.main)

	local titlebar = make("Frame", {
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundColor3 = colors.titlebar,
		BorderSizePixel = 0,
	}, self.main)

	local title = options.name or "Window"
	if options.version then
		title = title .. "  " .. options.version
	end
	make("TextLabel", {
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -50, 1, 0),
		BackgroundTransparency = 1,
		Text = title,
		TextColor3 = colors.text,
		Font = Enum.Font.SourceSansSemibold,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, titlebar)

	local close = make("TextButton", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.fromOffset(34, 30),
		BackgroundTransparency = 1,
		Text = "x",
		TextColor3 = colors.dim,
		Font = Enum.Font.SourceSansSemibold,
		TextSize = 18,
	}, titlebar)
	close.MouseEnter:Connect(function()
		close.TextColor3 = Color3.fromRGB(220, 80, 80)
	end)
	close.MouseLeave:Connect(function()
		close.TextColor3 = colors.dim
	end)
	close.Activated:Connect(function()
		self:setVisible(false)
	end)

	self.tabBar = make("Frame", {
		Position = UDim2.fromOffset(0, 30),
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundColor3 = colors.titlebar,
		BorderSizePixel = 0,
	}, self.main)
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, self.tabBar)

	self.content = make("Frame", {
		Position = UDim2.fromOffset(0, 62),
		Size = UDim2.new(1, 0, 1, -62),
		BackgroundTransparency = 1,
	}, self.main)

	self.toasts = make("Frame", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 16, 1, -16),
		Size = UDim2.fromOffset(240, 200),
		BackgroundTransparency = 1,
	}, self.gui)
	make("UIListLayout", {
		Padding = UDim.new(0, 4),
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, self.toasts)

	local dragging = false
	local dragStart, startPos
	titlebar.InputBegan:Connect(function(input)
		if pressed(input) then
			dragging = true
			dragStart = input.Position
			startPos = self.main.Position
		end
	end)
	table.insert(self.connections, userInput.InputChanged:Connect(function(input)
		if dragging and moved(input) then
			local delta = input.Position - dragStart
			self.main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end))
	table.insert(self.connections, userInput.InputEnded:Connect(function(input)
		if pressed(input) then
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
