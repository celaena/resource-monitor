SLASH_RESMON1 = "/resmon";
SlashCmdList["RESMON"] = function(message)
	print("Resource Monitor: "..message);
	if message == "lock" then
		ResMonDB["isLocked"] = true
	elseif message == "unlock" then
		ResMonDB["isLocked"] = false
	else
		print("\tOptions: lock, unlock")
	end
end

local mainModule = ResMon.Main;
local confModule = ResMon.ClassConfig;

local mainFrame;
local HealthBar;
local ResourceBar;
local PowerFrame;

local blipBars;

local maxPower;

local POWER_IND;

function ResMon.OnLoad(self)
	if (type(ResMonDB) ~= "table") then
		ResMonDB = {}
		ResMonDB["isLocked"] = false
		ResMonDB["x"] = 1000
		ResMonDB["y"] = 1000
	end
	
	HealthBar, ResourceBar, PowerFrame, blipBars = mainModule.InitFrames(self);

	self:RegisterForDrag("LeftButton");
	self:SetScript("OnDragStart",ResMon.OnDragStart);
	self:SetScript("OnDragStop",ResMon.OnDragStop);
	
	HealthBar:RegisterEvent("UNIT_HEALTH_FREQUENT", "player");
	HealthBar:SetScript("OnEvent", ResMon.healthBarOnEvent);
	
	ResourceBar:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player");
	ResourceBar:RegisterUnitEvent("UNIT_MAXPOWER", "player");
	ResourceBar:RegisterUnitEvent("UNIT_DISPLAYPOWER", "player");
	ResourceBar:SetScript("OnEvent", ResMon.resourceBarOnEvent);
	
	for k,barConf in pairs(blipBars) do
		barConf.FRAME.bgTexture:Hide();
		for i,blip in ipairs(barConf.FRAME.BLIPS) do
			blip.bgTexture:Hide();
		end
	end
end

function ResMon.OnEnterWorld(self)	
	local barSettings, powerInd = confModule.GetBarConfig();
	POWER_IND = powerInd;
	local powerBarCount = 0;
	blipBars.FIVE_BAR_2.FRAME.bgTexture:Hide();	
	for j,barSetting in pairs(barSettings) do
		powerBarCount = powerBarCount + 1;
		blipBars[j].FRAME.bgTexture:Show();	
		ResMon.setBlipConfig(blipBars[j].FRAME.BLIPS, barSetting.BLIP_COLORS);
		if (j == "FIVE_BAR_2") then
			blipBars.FIVE_BAR_2.FRAME:RegisterUnitEvent("UNIT_AURA", "player");
			blipBars.FIVE_BAR_2.FRAME:SetScript("OnEvent", ResMon.powerOnAuraEvent);
			blipBars.FIVE_BAR_2.FRAME.bgTexture:Show();
		else 			
			blipBars[j].FRAME:RegisterUnitEvent("UNIT_POWER", "player");
			blipBars[j].FRAME:SetScript("OnEvent", ResMon.powerOnPowerEvent);
		end
	end
	self:SetHeight(mainModule.mainFrameHeights[powerBarCount + 1]);
	
	ResMon.updateHealth();
	ResMon.updateResource();
end

-- UNIT_POWER(unit, type)
-- UNIT_POWER_FREQUENT(unit, type)
-- UNIT_MAXPOWER
-- UNIT_DISPLAYPOWER(unit)
-- UNIT_COMBO_POINTS
-- CP = ID 4

local powerType;


-- HEALTH BAR CONTROLLER --
function ResMon.healthBarOnEvent(self, event, unit, ...)
	if (event == "UNIT_HEALTH_FREQUENT") then
		ResMon.updateHealth();
	end
end

function ResMon.updateHealth()
	local curHp = UnitHealth("player");
	local maxHp = UnitHealthMax("player");
	local percentage = curHp / maxHp;
	HealthBar.olTexture:SetWidth(percentage * mainModule.width);
	HealthBar.percentText:SetText((math.floor(percentage * 100)) .. "%");
	local countStr = curHp .. "/" .. maxHp;
	HealthBar.countText:SetText(countStr);
	HealthBar.countText:GetParent():SetWidth(math.floor(string.len(countStr) * 8.5));
	
	local color;
	if (percentage > 0.8) then
		color = mainModule.HEALTH_BAR_COLORS.GREEN;
	elseif (percentage > 0.5) then
		color = mainModule.HEALTH_BAR_COLORS.YELLOW;
	elseif (percentage > 0.3) then
		color = mainModule.HEALTH_BAR_COLORS.ORANGE;
	else
		color = mainModule.HEALTH_BAR_COLORS.RED;
	end
	HealthBar.olTexture:SetTexture(color.R,color.G,color.B,color.A);
end

function ResMon.resourceBarOnEvent(self, event, unit, ...)
	if (event == "UNIT_POWER_FREQUENT") then
		if _G["SPELL_POWER_"..select(1, ...)] == powerType then
			ResMon.updateResourceBar();
		end
	elseif (event == "UNIT_DISPLAYPOWER" or event == "UNIT_MAXPOWER") then
		ResMon.updateResource();
	end
end


-- RESOURCE BAR CONTROLLER --
function ResMon.updateResource()
	local pt, typeName = UnitPowerType("player");
	powerType = pt;
	local barColor = PowerBarColor[pt];
	-- print("Update resource to " .. typeName .. "(Colors: " .. barColor.r .. ","..barColor.g..","..barColor.b..")");
	ResourceBar.olTexture:SetTexture(barColor.r,barColor.g,barColor.b,1);
	maxPower = UnitPowerMax("player", powerType);
	ResMon.updateResourceBar();
end

function ResMon.updateResourceBar()
	local curPower = UnitPower("player", powerType);
	local percentage = curPower / maxPower;
	ResourceBar.olTexture:SetWidth(percentage * mainModule.width);
	ResourceBar.percentText:SetText((math.floor(percentage * 100)) .. "%");
	local countStr = curPower .. "/" .. maxPower;
	ResourceBar.countText:SetText(countStr);
	ResourceBar.countText:GetParent():SetWidth(math.floor(string.len(countStr) * 8.5));
end


-- POWER BAR CONTROLLER --
function ResMon.powerOnPowerEvent(self, event, unit, powType)
	local thisPwrInd;
	if (powType == "COMBO_POINTS") then
		thisPwrInd = 4;
	else
		thisPwrInd = _G["SPELL_POWER_"..powType];
	end
	if (event == "UNIT_POWER" and thisPwrInd == POWER_IND) then		
		ResMon.setBlips(self.BLIPS, UnitPower("player", POWER_IND));
	end
end

function ResMon.powerOnAuraEvent(self, event, ...)
	ResMon.setBlips(blipBars.FIVE_BAR_2.FRAME.BLIPS, select(4, UnitAura("player", "Anticipation", nil, "PLAYER|HELPFUL")) or 0);
end

function ResMon.setBlipConfig(blips, blipColors, blipSounds)
	for i = 1, #blips do
		blips[i].bgTexture:SetTexture(blipColors[i][1],blipColors[i][2],blipColors[i][3],1);
		-- set sound?
	end
end

function ResMon.setBlips(blips, numSet)
	for i = 1, numSet do 
		blips[i].bgTexture:Show();
	end
	for i = numSet + 1, #blips do
		blips[i].bgTexture:Hide();
	end
end


-- GENERAL CONTROLLER --
function ResMon.OnEvent(self, event, ...)
	if (event == "ADDON_LOADED" and select(1, ...) == "ResourceMonitor") then
		ResMon.OnLoad(self);	
	elseif (event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TALENT_UPDATE") then
		ResMon.OnEnterWorld(self);
	end
end

function ResMon.OnDragStart()
	if not ResMonDB["isLocked"] then
		mainFrame:StartMoving();
	end
end

function ResMon.OnDragStop()
	mainFrame:StopMovingOrSizing();
	ResMonDB["x"], ResMonDB["y"] = mainFrame:GetCenter();
end

mainFrame = CreateFrame("Frame", "ResMonMainFrame", UIParent);
mainFrame:EnableMouse(true);
mainFrame:SetMovable(true);
mainFrame:RegisterEvent("ADDON_LOADED");
mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
mainFrame:RegisterEvent("PLAYER_TALENT_UPDATE");
mainFrame:SetScript("OnEvent", ResMon.OnEvent);