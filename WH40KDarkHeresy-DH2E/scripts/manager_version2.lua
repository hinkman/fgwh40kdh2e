-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local rsname = "DarkHeresy";
local rsmajorversion = 2;

function onInit()
	if User.isHost() or User.isLocal() then
		updateCampaign();
	end

	DB.onAuxCharLoad = onCharImport;
	DB.onImport = onImport;
	Module.onModuleLoad = onModuleLoad;
end

function onCharImport(nodePC)
	local _, _, aMajor, _ = DB.getImportRulesetVersion();
	updateChar(nodePC, aMajor[rsname]);
end

function onImport(node)
	local aPath = StringManager.split(node.getNodeName(), ".");
	if #aPath == 2 and aPath[1] == "charsheet" then
		local _, _, aMajor, _ = DB.getImportRulesetVersion();
		updateChar(node, aMajor[rsname]);
	end
end

function onModuleLoad(sModule)
	local _, _, aMajor, _ = DB.getRulesetVersion(sModule);
	updateModule(sModule, aMajor[rsname]);
end

function updateChar(nodePC, nVersion)
	if not nVersion then
		nVersion = 0;
	end
	
	if nVersion < rsmajorversion then
		if nVersion < 2 then
			migrateCharacter2(nodePC);
		end
	end
end

function updateCampaign()
	local _, _, aMajor, aMinor = DB.getRulesetVersion();
	local major = aMajor[rsname];
	if not major then
		return;
	end
	
	if major > 0 and major < rsmajorversion then
		print("Migrating campaign database to latest data version.");
		DB.backup();
		
		if major < 2 then
			convertCharacters2();
		end
	end
end

function updateModule(sModule, nVersion)
	if not nVersion then
		nVersion = 0;
	end
	
	if nVersion < rsmajorversion then
		local nodeRoot = DB.getRoot(sModule);
		
		-- If non-character data changes, add migration checks here
	end
end

function migrateCharacter2(nodeChar)
	local nodeSkills = nodeChar.createChild("skilllist");
	
	for _,vSkill in pairs(DB.getChildren(nodeChar, "skills.might")) do
		local nodeNewSkill = nodeSkills.createChild();
		DB.copyNode(vSkill, nodeNewSkill);
	end
	DB.deleteChild(nodeChar, "skills.might");
	
	for _,vSkill in pairs(DB.getChildren(nodeChar, "skills.speed")) do
		local nodeNewSkill = nodeSkills.createChild();
		DB.copyNode(vSkill, nodeNewSkill);
	end
	DB.deleteChild(nodeChar, "skills.speed");

	for _,vSkill in pairs(DB.getChildren(nodeChar, "skills.intellect")) do
		local nodeNewSkill = nodeSkills.createChild();
		DB.copyNode(vSkill, nodeNewSkill);
	end
	DB.deleteChild(nodeChar, "skills.intellect");
end

function convertCharacters2()
	for _,nodeChar in pairs(DB.getChildren("charsheet")) do
		migrateCharacter2(nodeChar);
	end
end
