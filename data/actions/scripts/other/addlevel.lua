function onUse(cid, item, fromPosition, itemEx, toPosition)
    local exp = (math.random(10, 15))
    doPlayerAddExperience(cid, (((getExperienceForLevel((getPlayerLevel(cid))+1))-(getExperienceForLevel(getPlayerLevel(cid))))*(exp/100)))
	doCreatureSay(cid, ' Dodano ' .. exp .. ' procent experience. ', TALKTYPE_ORANGE_1)
	doSendMagicEffect(getCreaturePosition(cid), CONST_ME_BATS)
	doRemoveItem(item.uid, 1)
	return true
end