
function onExtendedOpcode(player, opcode, buffer)
-- Create a sample JSON object
	if opcode == 105 then
		-- Attempt to decode JSON data using pcall to catch potential errors
		local json_status, json_data = pcall(
			function()
				return json.decode(buffer)  -- Attempt to decode JSON from 'buffer'
			end
		)

		-- Check if JSON decoding was successful or not
		if not json_status then
			-- If there's an error, log the error message and return
			g_logger.error("[My Module] JSON error: " .. json_data)
			return
		end	
		--funkcja print_r printuje tabelki do konsoli
		function print_r ( t ) 
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    sub_print_r(t,"  ")
end
		--Dekodujemy json
		local jsonData = json.decode(buffer)
		--odebranej tabelce z danymi  musimy nazwać dane bo funkcja tego wymaga by  nazwać zmienne x y z
		local jsonNewData = {
			x = jsonData[1],
			y = jsonData[2],
			z = jsonData[3],
			[4] = jsonData[4]
		}
		--wyciągamy Thing z X Y Z i slotpos z gracza
		local Thing = player:internalGetThing(jsonNewData)
		--Pobieramy realuid z thing
		local myRealId = Thing.getRealUID(Thing)
		--zbieramy informację o przedmiocie po RealUid
		local myItem = Game.getItemByRUID(myRealId)
----------------------------------------------------------------------------------	
		--Cała reszta to wyciąganie statystyk z myItem i wsadzanie ich do tabelki wysyłanej json opcodem do clienta
		
		local description = myItem.getDescription(myItem)
		--to ma spacje bo sie chujowo czytało po pijaku
		local id =        myItem:getId()
		local clientid =  ItemType(id):getClientId(myItem)
		local nazwa =     myItem:getName(myItem)
		local szansa =    myItem:getHitChance(myItem)
		local zasieg =    myItem:getShootRange(myItem)
		local zasieg2 = nil
		local typo =      ItemType(id):hasSubType(myItem)
		local waga =      myItem:getWeight(myItem)
		local typ =       myItem.getType(myItem) -- nie wiem kurwa
		local atak =      myItem:getAttack(myItem)
		local zbroja =    myItem:getArmor(myItem)
		local defens =    myItem:getDefense(myItem)
		local liczba =    myItem:getCount(myItem)
		local sloc = ItemType(id):usesSlot(CONST_SLOT_FEET)
		local tekst = myItem:getText(myItem)
		local podtyp = ItemType(id):hasSubType(myItem)
		local voca = ItemType(id):getVocationString(myItem)
		--print(sloc)
		
		
		--Pierwsze sortowanie najprostsze bo  po slocie do jakiego się mieści item
		local slot1 = ItemType(id):usesSlot(CONST_SLOT_NECKLACE)
		local slot2 = ItemType(id):usesSlot(CONST_SLOT_HEAD)
		local slot3 = ItemType(id):usesSlot(CONST_SLOT_ARMOR)
		local slot4 = ItemType(id):usesSlot(CONST_SLOT_FEET)
		local slot5 = ItemType(id):usesSlot(CONST_SLOT_RING)
		local slot6 = ItemType(id):usesSlot(CONST_SLOT_AMMO)
		local slot7 = ItemType(id):usesSlot(CONST_SLOT_LEGS)


local typItemu
--tu sprawdza najprostsze czyli w jaki slot wchodzi item
if slot1 then
    typItemu = "Necklace"
elseif slot2 then
    typItemu = "Helmet"
elseif slot3 then
    typItemu = "Armor"
elseif slot4 then
    typItemu = "Boots"
elseif slot5 then
    typItemu = "Ring"
elseif slot6 then
    typItemu = "Ammunition"
elseif slot7 then
	typItemu = "Legs"
end
--ile kurwa rąk potrzeba, tutaj ostrzegam zwraca różne wartości i jest zjebana ta lua lekko
local ileReczna = ItemType(id):getWieldInfo(myItem)
--jeśli nie jest zbroją to sprawdza możliwość bycia bronią
if not typItemu then
	local typBroni = ItemType(id):getWeaponType(myItem)
	if typBroni == 5 then --luk/kusza
		defense = nil
		armor = nil
		zbroja = nil
		zasieg2 = zasieg
		typItemu = "Distance"
	elseif typBroni == 3 then --axe
		if ileReczna == 1 then
			szansa = nil
			zbroja = nil
			typItemu = "Axe"
		else
			szansa = nil
			zbroja = nil
			typItemu = "Two-Handed Axe"
		end
	elseif typBroni == 2 then --mace
		if ileReczna == 1 then
			szansa = nil
			zbroja = nil
			typItemu = "Club"
		else
			szansa = nil
			zbroja = nil
			typItemu = "Two-Handed Club"
		end
	elseif typBroni == 1 then --miecz
		if ileReczna == 5 then
			szansa = nil
			zbroja = nil
			typItemu = "Two-Handed Sword"
		else
			szansa = nil
			typItemu = "Sword"
			zbroja = nil
		end
	elseif typBroni == 6 then --wand/rod
		
	end
	--print(typBroni)
end
--jak nie jest niczym innym to jest tarczą
if zbroja == 0 and atak == 0 and defens ~= 0 then
	typItemu = "Shield"
	zbroja = nil
	atak = nil
	szansa = nil
	hitChance = nil
end
--local opis = myItem:getText(id) --nie dziala gowno jebane

local atri = ItemType(id):hasShowAttributes(myItem) --ma atrybuty znaczy że jest butem albo naszyjnikiem np
--ale jakoś nie ma sensu tego już sortować bo w sumie to  wszedzie da sie  wjebać te staty defensywne

--print(atri)
--print(atri2)
--local abso = atri2.absorbPercent
--print(abso)


-- skoro wiemy już czym jest sprawdzany przedmiot to sprawdzamy jego statystyki:
--oenowe rarity--
local rar = myItem:getRarity()
local rari = rar.name
local jakosc = nil
if rari == "common" then
	jakosc = 1
elseif rari == "rare" then
	jakosc = 2
elseif rari == "epic" then
	jakosc = 3
elseif rari == "legendary" then
	jakosc  = 4
else
	jakosc = nil
end

--oenowy  itemLevel
local ilvl = myItem:getItemLevel()
--oenowy mirroring
local mirek = myItem:isMirrored()
--oenowe unidentified
local oen = myItem:isUnidentified()
--local atri2 = myItem:getBonusAttributes(myItem)
--print(atri2)
--local atat = myItem:getMaxAttributes()
--print(atat)


--print(atri2.absorbPercent[1]) -- physical
--print(atri2.absorbPercent[2]) --energy
--print(atri2.absorbPercent[3]) --earth
--print(atri2.absorbPercent[4]) --fire

--print(atri2.absorbPercent[6]) --protection lifedrain
--print(atri2.absorbPercent[7]) --protection manadrain

--print(atri2.absorbPercent[9])  --drown
--print(atri2.absorbPercent[10])  --ice
--print(atri2.absorbPercent[11]) --holy
--print(atri2.absorbPercent[12]) -- death


-- dodatkowy element dmg local atri2 = ItemType(id):getElementDamage(id)
--print(opis)
--print(defens)
--print(typItemu)
--print(ileReczna)
--print(atak)
--print(zbroja)

local atri2 = ItemType(id):getAbilities(myItem)


--print_r(atri2)
--local test = atri2.stats[4] --magic level
--local test2 = atri2.skills[5] --distance
--local test3 = atri2.skills[6] --shielding
----------------------------------------------------------------------------------

--tutaj robimy tabelke imp ktora dodaje sie do tabelki data jesli ma jakiekolwiek wartosci
local imp = {}  -- Create an empty table

-- Set all possible implicits to nil
imp.a_all = 0          -- Protection All
imp.maxhp = 0          -- Health
imp["one-handed"] = 0  -- One-Handed Fighting
imp.fist = 0           -- Fist Fighting
imp["two-handed"] = 0  -- Two-Handed Fighting
imp.maxhp_p = 0        -- Health
imp.fish = 0           -- Fishing
imp.as = 0             -- Attack Speed
imp.maxmp = 0          -- Mana
imp.a_heal = 0         -- Healing Protection
imp.mpgain = 0        -- Mana Regeneration
imp.maxmp_p = 0        -- Mana
imp.hpgain = 0         -- Health Regeneration
imp.speed = atri2.speed          -- Movement Speed
imp.mc = atri2.specialSkills[5]             -- Mana Leech Chance
imp.lc = atri2.specialSkills[3]             -- Life Leech Chance
imp.ma = atri2.specialSkills[6]             -- Mana Leech
imp.shield = atri2.skills[6]         -- Shielding
imp.la = atri2.specialSkills[4]             -- Life Leech
imp.cc = atri2.specialSkills[1]             -- Critical Chance
imp.ca = atri2.specialSkills[2]             -- Critical Damage
imp.mag = atri2.stats[4]            -- Magic Level
imp.dist = atri2.skills[5]           -- Distance Fighting
imp.a_phys = atri2.absorbPercent[1]         -- Physical Protection
imp.a_ene = atri2.absorbPercent[2]          -- Energy Protection
imp.a_earth = atri2.absorbPercent[3]        -- Earth Protection
imp.a_fire = atri2.absorbPercent[4]         -- Fire Protection
imp.a_ldrain = atri2.absorbPercent[6]       -- Lifedrain Protection
imp.a_mdrain = atri2.absorbPercent[7]       -- Manadrain Protection
imp.a_drown = atri2.absorbPercent[9]        -- Drown Protection
imp.a_ice = atri2.absorbPercent[10]          -- Ice Protection
imp.a_holy = atri2.absorbPercent[11]         -- Holy Protection
imp.a_death = atri2.absorbPercent[12]        -- Death Protection

----------------------------------------------------------------------------
for attr, value in pairs(imp) do
    if value == nil or value == 0 then
        imp[attr] = nil -- Remove attributes with nil or 0 values
    end
end
----------------------------------------------------------------------------
--Do tabelki json_data w tabelce data dodawana jest tabelka imp ^ ta wyżej, jesli jakiś mod
--zwraca wartość zero to jest wyjebywany z tabelki
----------------------------------------------------------------------------------
		local json_data =	{
  action = "new",
  data = {
    uid = myRealId,
    itemName = nazwa,
    desc = voca,
    clientId = clientid,
    itemLevel = ilvl,   --mody oena
    unidentified = oen, --mody oena
    mirrored = mirek,   --mody oena
    rarityId = jakosc,  --mody oena
    maxAttr = 0,        --mody oena
    attr = {"Attribute 1", "Attribute 2", "Attribute 3"}, --mody oena
    weight = waga,
    itemType = typItemu,
    armor = zbroja,
    attack = atak,
    hitChance = szansa,
    defense = defens,
    shootRange = zasieg2,
    st = liczba, --to jest ilosc przedmiotow
  }
}

--i tu dodajemy tabelke imp do tabelki data ale giga kozaczek
if next(imp) then
    json_data.data.imp = imp
end

--shootrange musi wpisywac tylko jesli jest distance weapon bo inaczej rozpierdoli skrypt
-- zbroja tak  samo musi byc wyzerowana dla broni dwurecznych
-- oen blokuje niektore wartosci tak ze  one nie wystepują  po prostu, a  skrypty czasem
--zwracają zero zamiast nil i sie wtedy rozpierdala to. dlatego jest tyle 
--pierdolenia sie z nilowaniem  niektorych wartosci  po to  aby nie występowały
--bo jak wystąpią to przestaje działać... gówno XD


		-- szmata to tabelka
		local szmata = json.encode(json_data)
		--jsonencode
		player:sendExtendedOpcode(105, json.encode(json_data))
		
	end
end
