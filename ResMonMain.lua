ResMon = {};

local module = {};
local moduleName = "Main";
ResMon[moduleName] = module;

local BACKGROUND = "BACKGROUND";
local OVERLAY = "OVERLAY";

local width = 400;
local textBoxWidth = 38;
local barHeight = 20;
local buffer = 1;
local powerBarHeight = 15;
local blipBuffer = 1;

local defaultColor = {
	R = 0.8,
	G = 0.8,
	B = 0.8,
	A = 1
};

module.HEALTH_BAR_COLORS = {
	GREEN = {
		R = 0,
		G = 0.8,
		B = 0,
		A = 1
	},
	YELLOW = {
		R = 1,
		G = 1,
		B = 0,
		A = 1
	},
	ORANGE = {
		R = 1,
		G = 0.5,
		B = 0,
		A = 1
	},
	RED = {
		R = 1,
		G = 0,
		B = 0,
		A = 1
	}
};
module.width = width;
module.mainFrameHeights = {
	(buffer * 3) + (barHeight * 2),
	(buffer * 4) + (barHeight * 2) + powerBarHeight,
	(buffer * 5) + (barHeight * 2) + (powerBarHeight * 2)
};

local function generateBackgroundTexture(frame, name, texture)
	frame.bgTexture = frame:CreateTexture(name, BACKGROUND);
	frame.bgTexture:SetColorTexture(texture[1],texture[2],texture[3],texture[4]);
	frame.bgTexture:SetAllPoints();
end

local function generateDefaultTextOverlay(frame, name)
	local textItem = frame:CreateFontString(name, OVERLAY, "GameFontNormal");
	textItem:SetPoint("RIGHT", -1, 0);
	textItem:SetTextColor(1,1,1,1);
	textItem:SetText("?");
	return textItem;
end

local function generateBarFrame(mainFrame, ind, name, color)
	local ResourceBar = CreateFrame("Frame", name, mainFrame);
	ResourceBar:SetSize(width, barHeight);
	ResourceBar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", buffer, ((buffer + ((barHeight + buffer) * ind)) * -1));
	ResourceBar:EnableMouse(false);
	generateBackgroundTexture(ResourceBar, name .. "Background", {0.25,0.25,0.25,1});	
	
	ResourceBar.olTexture = ResourceBar:CreateTexture(name .. "Overlay", OVERLAY);
	ResourceBar.olTexture:SetSize(width, barHeight);
	ResourceBar.olTexture:SetPoint("LEFT", ResourceBar, "LEFT", 0, 0);
	ResourceBar.olTexture:SetColorTexture(color.R,color.G,color.B,color.A);
	
	local ResourceBarTextFrame1 = CreateFrame("Frame", name .. "TextFrame1", ResourceBar);
	ResourceBarTextFrame1:SetSize(textBoxWidth, barHeight * 0.75);
	ResourceBarTextFrame1:SetPoint("LEFT", ResourceBar, "LEFT", buffer * 4, 0);
	ResourceBarTextFrame1:EnableMouse(false);
	generateBackgroundTexture(ResourceBarTextFrame1, name .. "TextFrame1Bg", {0.1,0.1,0.1,1});
	
	local ResourceBarTextFrame2 = CreateFrame("Frame", name .. "TextFrame2", ResourceBar);
	ResourceBarTextFrame2:SetSize(textBoxWidth, barHeight * 0.75);
	ResourceBarTextFrame2:SetPoint("RIGHT", ResourceBar, "RIGHT", buffer * -4, 0);
	ResourceBarTextFrame2:EnableMouse(false);
	generateBackgroundTexture(ResourceBarTextFrame2, name .. "TextFrame2Bg", {0.1,0.1,0.1,1});
	
	ResourceBar.percentText = generateDefaultTextOverlay(ResourceBarTextFrame1, name .. "TextPer");
	ResourceBar.countText = generateDefaultTextOverlay(ResourceBarTextFrame2, name .. "TextCount");
	
	return ResourceBar;
end

module.InitFrames = function(mainFrame)
	local length = width + (buffer * 2);
	mainFrame:SetPoint("BOTTOMLEFT", ResMonDB["x"] - (length/2), ResMonDB["y"] - (module.mainFrameHeights[3]/2));
	mainFrame:SetSize(length, module.mainFrameHeights[3]);
	generateBackgroundTexture(mainFrame, "ResMonMainBackground", {0,0,0,0.75});
	
	local HealthBar = generateBarFrame(mainFrame, 0, "ResMonHealthBar", defaultColor);
	local ResourceBar = generateBarFrame(mainFrame, 1, "ResMonResBar", defaultColor);
	
	local PowerFrame = CreateFrame("Frame", "ResMonPowerFrame", mainFrame);
	PowerFrame:SetPoint("TOPLEFT", ResourceBar, "BOTTOMLEFT", 0, (buffer * -1));
	PowerFrame:SetSize(width, powerBarHeight * 2);
	PowerFrame:EnableMouse(false);
	
	local blipBars = {};	
	local blipHeight = powerBarHeight - (blipBuffer * 2);
	for j = 3, 8 do 
		local barName = "ResMonBlipBar" .. j;
		local bar = CreateFrame("Frame", barName, PowerFrame);
		bar:SetSize(width, powerBarHeight);
		bar:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", 0, 0);	
		bar:EnableMouse(false);	
		generateBackgroundTexture(bar, barName .. "BG", {0.25,0.25,0.25,1});	
		
		bar.BLIPS = {};
		local blipWidth = ((width - (blipBuffer * (j + 1))) / j);
		for i = 1, j do
			local blip = CreateFrame("Frame", "ResMon".. barName .. "PowerBlip" .. i, bar);
			blip:SetSize(blipWidth, blipHeight);
			blip:SetPoint("TOPLEFT", bar, "TOPLEFT", (blipWidth * (i - 1)) + (blipBuffer * i), (blipBuffer * -1))
			blip:EnableMouse(false);
			blip.bgTexture = blip:CreateTexture("ResMon".. barName .. "PowerBlip" .. i .."BG", OVERLAY);
			blip.bgTexture:SetColorTexture(0,0,0,1);
			blip.bgTexture:SetAllPoints();
			bar.BLIPS[i] = blip;
		end
		
		blipBars[j] = bar;
	end
	
	return HealthBar, ResourceBar, PowerFrame, blipBars;
end