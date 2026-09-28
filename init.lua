local baseUrl = "https://raw.githubusercontent.com/yourname/codebrainrot/main/"
local toggleKey = Enum.KeyCode.RightControl
local forcePlaceId = nil

local env = getgenv and getgenv() or _G
if env.codeBrainrotLoaded then
	warn("[CodeBrainrot] already loaded")
	return
end
env.codeBrainrotLoaded = true

local marketplace = game:GetService("MarketplaceService")

local function fetchModule(path)
	local okFetch, source = pcall(function()
		return game:HttpGet(baseUrl .. path)
	end)
	if not okFetch then
		return nil, source
	end

	local chunk, compileError = loadstring(source)
	if not chunk then
		return nil, compileError
	end

	local okRun, result = pcall(chunk)
	if not okRun then
		return nil, result
	end
	return result
end

local ui, uiError = fetchModule("ui.lua")
if not ui then
	env.codeBrainrotLoaded = nil
	warn("[CodeBrainrot] failed to load ui: " .. tostring(uiError))
	return
end

local placeId = forcePlaceId or game.PlaceId
local gameName = "Unknown game"
if placeId == 0 then
	gameName = "Studio place"
else
	pcall(function()
		gameName = marketplace:GetProductInfo(placeId).Name
	end)
end

local window = ui.createWindow({
	name = "CodeBrainrot",
	version = "v1.0.0",
	toggleKey = toggleKey,
})

local context = {
	notify = function(text)
		window:notify(text)
	end,
}

local gameScript = fetchModule("games/" .. tostring(placeId) .. ".lua")
local config = nil
if typeof(gameScript) == "function" then
	local ok, result = pcall(gameScript, context)
	if ok and typeof(result) == "table" then
		config = result
	else
		warn("[CodeBrainrot] game script errored: " .. tostring(result))
	end
end

local home = window:addTab("Home")
home:section("current game")
home:label(gameName)
home:label("place id  " .. tostring(placeId))
home:section("status")
if config then
	home:label("supported, open the scripts tab")
else
	home:label("no script for this game yet")
	home:label("add games/" .. tostring(placeId) .. ".lua to your repo")
end

if config then
	local scripts = window:addTab("Scripts")
	local features = config.features or {}

	if #features == 0 then
		scripts:label("no features in this script")
	end

	for _, feature in ipairs(features) do
		if feature.type == "toggle" then
			scripts:toggle(feature)
		elseif feature.type == "slider" then
			scripts:slider(feature)
		elseif feature.type == "button" then
			scripts:button(feature)
		elseif feature.type == "section" then
			scripts:section(feature.name)
		end
	end
end

window:notify("loaded, press " .. toggleKey.Name .. " to hide")
