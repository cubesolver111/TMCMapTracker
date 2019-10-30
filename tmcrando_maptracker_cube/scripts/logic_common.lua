function canDamage()
  if Tracker:ProviderCountForCode("sword") > 0 then
    return 1
  elseif Tracker:ProviderCountForCode("bow") > 0 then
    return 1
  elseif Tracker:ProviderCountForCode("lights") > 0 then
    return 1
  else
    return Tracker:ProviderCountForCode("bombs")
  end
end

function hasNoGust()
  if Tracker:ProviderCountForCode("gust") > 0 then
    return 0
  else
    return 1
  end
end

function OneElement()
  if Tracker:ProviderCountForCode("earth") > 0
  or Tracker:ProviderCountForCode("fire") > 0
  or Tracker:ProviderCountForCode("water") > 0
  or Tracker:ProviderCountForCode("wind") > 0
  then
    return 1
  else
    return 0
  end
end

function TwoElements()
  if Tracker:ProviderCountForCode("earth") > 0 and Tracker:ProviderCountForCode("fire") > 0
  or Tracker:ProviderCountForCode("earth") > 0 and Tracker:ProviderCountForCode("water") > 0
  or Tracker:ProviderCountForCode("earth") > 0 and Tracker:ProviderCountForCode("wind") > 0
  or Tracker:ProviderCountForCode("fire") > 0 and Tracker:ProviderCountForCode("water") > 0
  or Tracker:ProviderCountForCode("fire") > 0 and Tracker:ProviderCountForCode("wind") > 0
  or Tracker:ProviderCountForCode("water") > 0 and Tracker:ProviderCountForCode("wind") > 0
  then
    return 1
  else
    return 0
  end
end

function ThreeElements()
  if Tracker:ProviderCountForCode("earth") > 0 and Tracker:ProviderCountForCode("fire") > 0 and Tracker:ProviderCountForCode("water") > 0
  or Tracker:ProviderCountForCode("earth") > 0 and Tracker:ProviderCountForCode("fire") > 0 and Tracker:ProviderCountForCode("wind") > 0
  or Tracker:ProviderCountForCode("earth") > 0 and Tracker:ProviderCountForCode("water") > 0 and Tracker:ProviderCountForCode("wind") > 0
  or Tracker:ProviderCountForCode("fire") > 0 and Tracker:ProviderCountForCode("water") > 0 and Tracker:ProviderCountForCode("wind") > 0
  then
    return 1
  else
    return 0
  end
end

function FourElements()
  if Tracker:ProviderCountForCode("earth") > 0 and Tracker:ProviderCountForCode("fire") > 0 and Tracker:ProviderCountForCode("water") > 0 and Tracker:ProviderCountForCode("wind") > 0
  then
    return 1
  else
    return 0
  end
end

function has(item, amount)
  local count = Tracker:ProviderCountForCode(item)
  amount = tonumber(amount)
  if not amount then
    return count > 0
  else
    return count == amount
  end
end

function neededSwords()
  if Tracker:ProviderCountForCode("sword") >= 0 and has("sword0needed") then
    return 1
  elseif has("sword") and has("sword1needed") then
    return 1
  elseif has("sword2") and has("sword2needed") then
    return 1
  elseif has("sword3") and has("sword3needed") then
    return 1
  elseif has("sword4") and has("sword4needed") then
    return 1
  elseif has("sword5") and has("sword5needed") then
    return 1
  else
    return 0
  end
end

function neededElements()
  if has("element0Needed") then
    return 1
  elseif has("element1Needed") and OneElement()==1 then
    return 1
  elseif has("element2Needed") and TwoElements()==1 then
    return 1
  elseif has("element3Needed") and ThreeElements()==1 then
    return 1
  elseif has("element4Needed") and FourElements()==1 then
    return 1
  else
    return 0
  end
end

function noElementsOrSwords()
  if has("element0Needed") and has("sword0needed") and FourElements() == 1 and has("sword5") then
    return 1
  elseif has("element0Needed") and has("sword1needed") then
    return 1
  elseif has("element0Needed") and has("sword2needed") then
    return 1
  elseif has("element0Needed") and has("sword3needed") then
    return 1
  elseif has("element0Needed") and has("sword4needed") then
    return 1
  elseif has("element0Needed") and has("sword5needed") then
    return 1
  elseif has("element1Needed") and has("sword1needed") then
    return 1
  elseif has("element1Needed") and has("sword2needed") then
    return 1
  elseif has("element1Needed") and has("sword3needed") then
    return 1
  elseif has("element1Needed") and has("sword4needed") then
    return 1
  elseif has("element1Needed") and has("sword5needed") then
    return 1
  elseif has("element2Needed") and has("sword1needed") then
    return 1
  elseif has("element2Needed") and has("sword2needed") then
    return 1
  elseif has("element2Needed") and has("sword3needed") then
    return 1
  elseif has("element2Needed") and has("sword4needed") then
    return 1
  elseif has("element2Needed") and has("sword5needed") then
    return 1
  elseif has("element3Needed") and has("sword1needed") then
    return 1
  elseif has("element3Needed") and has("sword2needed") then
    return 1
  elseif has("element3Needed") and has("sword3needed") then
    return 1
  elseif has("element3Needed") and has("sword4needed") then
    return 1
  elseif has("element3Needed") and has("sword5needed") then
    return 1
  elseif has("element4Needed") and has("sword1needed") then
    return 1
  elseif has("element4Needed") and has("sword2needed") then
    return 1
  elseif has("element4Needed") and has("sword3needed") then
    return 1
  elseif has("element4Needed") and has("sword4needed") then
    return 1
  elseif has("element4Needed") and has("sword5needed") then
    return 1

  elseif has("sword0needed") and has("element1Needed") then
    return 1
  elseif has("sword0needed") and has("element2Needed") then
    return 1
  elseif has("sword0needed") and has("element3Needed") then
    return 1
  elseif has("sword0needed") and has("element4Needed") then
    return 1
  elseif has("sword1needed") and has("element1Needed") then
    return 1
  elseif has("sword1needed") and has("element2Needed") then
    return 1
  elseif has("sword1needed") and has("element3Needed") then
    return 1
  elseif has("sword1needed") and has("element4Needed") then
    return 1
  elseif has("sword2needed") and has("element1Needed") then
    return 1
  elseif has("sword2needed") and has("element2Needed") then
    return 1
  elseif has("sword2needed") and has("element3Needed") then
    return 1
  elseif has("sword2needed") and has("element4Needed") then
    return 1
  elseif has("sword3needed") and has("element1Needed") then
    return 1
  elseif has("sword3needed") and has("element2Needed") then
    return 1
  elseif has("sword3needed") and has("element3Needed") then
    return 1
  elseif has("sword3needed") and has("element4Needed") then
    return 1
  elseif has("sword4needed") and has("element1Needed") then
    return 1
  elseif has("sword4needed") and has("element2Needed") then
    return 1
  elseif has("sword4needed") and has("element3Needed") then
    return 1
  elseif has("sword4needed") and has("element4Needed") then
    return 1
  elseif has("sword5needed") and has("element1Needed") then
    return 1
  elseif has("sword5needed") and has("element2Needed") then
    return 1
  elseif has("sword5needed") and has("element3Needed") then
    return 1
  elseif has("sword5needed") and has("element4Needed") then
    return 1
  else
    return 0
  end
end
