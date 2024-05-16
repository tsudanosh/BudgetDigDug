-- Init
local twilightHighlandsPort = 94752;
local playerGUID = UnitGUID("player")
local frame = CreateFrame("FRAME","budgetDigDug")
local throttleMessageRate = 0.25;
local throttleMessageTimer = 0;
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("COMBAT_LOG_EVENT")
frame:RegisterEvent("RESEARCH_ARTIFACT_COMPLETE")
frame:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

--frame:RegisterEvent("PLAYER_STARTED_MOVING")

local epicsToAnnounce = {
	[3] = {
--		[90581]="\124cff9d9d9d\124Hitem:64375::::::::85:::::\124h[Drakkari Sacrificial Knife]\124h\124r";
		[90608]="\124cffa335ee\124Hitem:64377::::::::85:::::\124h[Zin'rokh, Destroyer of Worlds]\124h\124r"
	},
	[7] = {
		[91757]="\124cffa335ee\124Hitem:64645::::::::85:::::\124h[Tyrande's Favorite Doll]\124h\124r"
	},
	[8] = {
		[98533]="\124cffa335ee\124Hitem:69764::::::::85:::::\124h[Extinct Turtle Shell]\124h\124r" 
	},
	[10] = {
		[91227]="\124cffa335ee\124Hitem:64489::::::::85:::::\124h[Staff of Sorcerer-Thane Thaurissan]\124h\124r"
	}
}

local function CheckAnnounceEpicArtifact(raceId)
	local debugTest = 90581;
	local zinrokhRaceId = 3;
	local zinrokhSpellId = 90608;
	local zinrokhItemLink = "\124cffa335ee\124Hitem:64377::::::::85:::::\124h[Zin'rokh, Destroyer of Worlds]\124h\124r";

	local newResearchArtifact, _, _, _, _, _, _, spellId = GetActiveArtifactByRace(raceId);

	--spellId = debugTest;
	if epicsToAnnounce[raceId] ~= nil then 
		if epicsToAnnounce[raceId][spellId] ~= nil then
			SendChatMessage("GASP! Now discovering {star} "..epicsToAnnounce[raceId][spellId].." {star}","GUILD");
			SendChatMessage("gasps as they begin discovering "..epicsToAnnounce[raceId][spellId].."!","EMOTE");
		end
	end
end

local function FindRaceByArtifactName(artifactName)
	local numArchRaces = GetNumArchaeologyRaces();

	for x=1,numArchRaces do
		local raceDiscoveredArtifacts=GetNumArtifactsByRace(x);
		for y=1,raceDiscoveredArtifacts do 
			local currArtifact = select(1,GetArtifactInfoByRace(x,y));
			if currArtifact == artifactName then
				return x;
			end
		end
	end
end

frame:SetScript("OnEvent",function(self, event, ...)
	local tempThrottleMessageNextTimer = 0;
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()
		if subevent == "SPELL_AURA_APPLIED" and destGUID == playerGUID and spellId == twilightHighlandsPort then 
			tempThrottleMessageNextTimer = GetTime() + throttleMessageRate;
			if throttleMessageTimer < tempThrottleMessageNextTimer then
				throttleMessageTimer = tempThrottleMessageNextTimer;			
				SendChatMessage("~.~ Twilight Highlands teleport strikes again!","GUILD");
				return;
			end
		end	
	elseif event == "RESEARCH_ARTIFACT_COMPLETE" then
		local artifactName = ...;
		--local artifactName = "Tooth with Gold Filling";
		local raceId = FindRaceByArtifactName(artifactName);
		if raceId then
			CheckAnnounceEpicArtifact(raceId);
			return;
		end
	elseif event == "MOUNT_JOURNAL_USABILITY_CHANGED" then
		if IsFlying() then
			local mapId = C_Map.GetBestMapForUnit("player");
			local subZoneText = GetSubZoneText();
			if subZoneText then 
				if subZoneText == "Temple of Bethekk" then
					tempThrottleMessageNextTimer = GetTime() + throttleMessageRate;
					if throttleMessageTimer < tempThrottleMessageNextTimer then
						throttleMessageTimer = tempThrottleMessageNextTimer;
						SendChatMessage("{skull} Found the Zul'Gurub Dismount! Wish me luck! {skull}","GUILD");
						return;
					end
				end
			end
		end
	end
end)



-- Define valid channels to send slash command output, too. Also supports global/custom channels
local validChannels = {"SAY", "EMOTE", "YELL", "PARTY", "RAID", "INSTANCE_CHAT", "GUILD", "OFFICER", "AFK", "DND"}

local function isValidChannel(msg)
    for index = 1, #validChannels do
        if validChannels[index] == string.upper(msg) then
            return true
        end
    end
end
-- Setup Slash Commands
SLASH_BUDGETDIGDUG1, SLASH_BDD1 = '/budgetdigdug', '/bdd'

-- Execute slash commands
function SlashCmdList.BDD(msg, editBox)
	SlashCmdList.BUDGETDIGDUG(msg, Editbox)
end
function SlashCmdList.BUDGETDIGDUG(msg, editBox)
	local v,t,a,c,r=0 s={};
	for x=1,10 do 
	   c=GetNumArtifactsByRace(x);
	   a=0;
	   for y=1,c do 
		  t=select(10,GetArtifactInfoByRace(x,y));
		  a=a+t;
	   end r=GetArchaeologyRaceInfo(x);
	   if(c>1) then 
		  tinsert(s,r..": "..a);
		  v=a+v;
	   end 
	end 
	
	local index = GetChannelName(msg);
	if (index ~= 0) then
		SendChatMessage(table.concat(s,", ")..", TOTAL: "..v,"CHANNEL", nil, index)	
	elseif isValidChannel(msg) then 	
		SendChatMessage(table.concat(s,", ")..", TOTAL: "..v,msg)
	else
		print("BudgetDigDug Syntax: /budgetdigdug or /bdd followed by "..table.concat(validChannels,", ")..", or global channel name.");
	end
end