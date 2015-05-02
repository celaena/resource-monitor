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
module.barHeight = barHeight;
module.buffer = buffer;
module.powerBarHeight = powerBarHeight;
module.blipBuffer = blipBuffer;

module.mainFrameHeights = {
	buffer + barHeight + buffer + barHeight + buffer,
	buffer + barHeight + buffer + barHeight + buffer + powerBarHeight + buffer,
	buffer + barHeight + buffer + barHeight + buffer + powerBarHeight + buffer + powerBarHeight + buffer
}

local function generateBarFrame(mainFrame, ind, name, color)
	local ResourceBar = CreateFrame("Frame", name, mainFrame);
	ResourceBar:SetSize(width, barHeight);
	ResourceBar:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", buffer, ((buffer + ((barHeight + buffer) * ind)) * -1));
	ResourceBar:EnableMouse(false);
	ResourceBar.bgTexture = ResourceBar:CreateTexture(name .. "Background", BACKGROUND);
	ResourceBar.bgTexture:SetTexture(0.25,0.25,0.25,1);
	ResourceBar.bgTexture:SetAllPoints();
	ResourceBar.olTexture = ResourceBar:CreateTexture(name .. "Overlay", OVERLAY);
	ResourceBar.olTexture:SetSize(width, barHeight);
	ResourceBar.olTexture:SetTexture(color.R,color.G,color.B,color.A);
	ResourceBar.olTexture:SetPoint("LEFT", ResourceBar, "LEFT", 0, 0);
	
	local ResourceBarTextFrame1 = CreateFrame("Frame", name .. "TextFrame1", ResourceBar);
	ResourceBarTextFrame1:SetSize(textBoxWidth, barHeight * 0.75);
	ResourceBarTextFrame1:SetPoint("LEFT", ResourceBar, "LEFT", buffer * 4, 0);
	ResourceBarTextFrame1:EnableMouse(false);
	ResourceBarTextFrame1.bgTexture = ResourceBarTextFrame1:CreateTexture(name .. "TextFrame1Bg", BACKGROUND);
	ResourceBarTextFrame1.bgTexture:SetTexture(0.1,0.1,0.1,1);
	ResourceBarTextFrame1.bgTexture:SetAllPoints();
	
	local ResourceBarTextPer = ResourceBarTextFrame1:CreateFontString(name .. "TextPer", OVERLAY, "GameFontNormal");
	ResourceBarTextPer:SetPoint("RIGHT", -1, 0);
	ResourceBarTextPer:SetTextColor(1,1,1,1);
	ResourceBarTextPer:SetText("?");
	
	local ResourceBarTextFrame2 = CreateFrame("Frame", name .. "TextFrame2", ResourceBar);
	ResourceBarTextFrame2:SetSize(textBoxWidth, barHeight * 0.75);
	ResourceBarTextFrame2:SetPoint("RIGHT", ResourceBar, "RIGHT", buffer * -4, 0);
	ResourceBarTextFrame2:EnableMouse(false);
	ResourceBarTextFrame2.bgTexture = ResourceBarTextFrame2:CreateTexture(name .. "TextFrame2Bg", BACKGROUND);
	ResourceBarTextFrame2.bgTexture:SetTexture(0.1,0.1,0.1,1);
	ResourceBarTextFrame2.bgTexture:SetAllPoints();
	
	local ResourceBarTextCount = ResourceBarTextFrame2:CreateFontString(name .. "TextCount", OVERLAY, "GameFontNormal");
	ResourceBarTextCount:SetPoint("RIGHT", -1, 0);
	ResourceBarTextCount:SetTextColor(1,1,1,1);
	ResourceBarTextCount:SetText("?");
	
	ResourceBar.percentText = ResourceBarTextPer;
	ResourceBar.countText = ResourceBarTextCount;
	
	return ResourceBar;
end

module.InitFrames = function(mainFrame)
	local length = width + (buffer * 2);
	mainFrame:SetPoint("BOTTOMLEFT", ResMonDB["x"] - (length/2), ResMonDB["y"] - (module.mainFrameHeights[3]/2));
	mainFrame:SetSize(length, module.mainFrameHeights[3]);
	mainFrame.bgTexture = mainFrame:CreateTexture("ResMonMainBackground", BACKGROUND);
	mainFrame.bgTexture:SetTexture(0,0,0,0.75);
	mainFrame.bgTexture:SetAllPoints();
	
	local HealthBar = generateBarFrame(mainFrame, 0, "ResMonHealthBar", defaultColor);
	local ResourceBar = generateBarFrame(mainFrame, 1, "ResMonResBar", defaultColor);
	
	local PowerFrame = CreateFrame("Frame", "ResMonPowerFrame", mainFrame);
	PowerFrame:SetPoint("TOPLEFT", ResourceBar, "BOTTOMLEFT", 0, (buffer * -1));
	PowerFrame:SetSize(width, powerBarHeight * 2);
	PowerFrame:EnableMouse(false);
	
	local blipBars = {
		["FIVE_BAR_1"] = {
			NAME = "ResMonFiveBlipBar1",
			NUM = 5,
			OFFSET = 0
		},
		["FIVE_BAR_2"] = {
			NAME = "ResMonFiveBlipBar2",
			NUM = 5,
			OFFSET = 1		
		},
		["THREE_BAR"] = {
			NAME = "ResMonThreeBlipBar",
			NUM = 3,
			OFFSET = 0		
		}
	}
	
	local blipHeight = powerBarHeight - (module.blipBuffer * 2);
	for k, conf in pairs(blipBars) do
		local bar = CreateFrame("Frame", conf.NAME, PowerFrame);
		bar:SetSize(width, powerBarHeight);
		bar:SetPoint("TOPLEFT", PowerFrame, "TOPLEFT", 0, powerBarHeight * (conf.OFFSET * -1));	
		bar:EnableMouse(false);		
		bar.bgTexture = bar:CreateTexture(conf.NAME .. "BG", BACKGROUND);
		bar.bgTexture:SetTexture(0.25,0.25,0.25,1);
		bar.bgTexture:SetAllPoints();
		
		bar.BLIPS = {};
		local blipWidth = ((width - (module.blipBuffer * (conf.NUM + 1))) / conf.NUM);
		for i = 1, conf.NUM do
			local blip = CreateFrame("Frame", "ResMon".. conf.NAME .. "PowerBlip" .. i, bar);
			blip:SetSize(blipWidth, blipHeight);
			blip:SetPoint("TOPLEFT", bar, "TOPLEFT", (blipWidth * (i - 1)) + (module.blipBuffer * i), (module.blipBuffer * -1))
			blip:EnableMouse(false);
			blip.bgTexture = blip:CreateTexture("ResMon".. conf.NAME .. "PowerBlip" .. i .."BG", OVERLAY);
			blip.bgTexture:SetTexture(0,0,0,1);
			blip.bgTexture:SetAllPoints();
			bar.BLIPS[i] = blip;
		end
		
		conf.FRAME = bar;
	end
	
	return HealthBar, ResourceBar, PowerFrame, blipBars;
end