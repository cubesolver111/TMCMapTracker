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

function TwoElements()
  if Tracker:ProviderCountForCode("earth") > 0 and Tracker:ProviderCountForCode("fire") > 0
  or Tracker:ProviderCountForCode("earth") > 0 and Tracker:ProviderCountForCode("water") > 0
  or Tracker:ProviderCountForCode("earth") > 0 and Tracker:ProviderCountForCode("wind") > 0
  or Tracker:ProviderCountForCode("fire") > 0 and Tracker:ProviderCountForCode("water") > 0
  or Tracker:ProviderCountForCode("fire") > 0 and Tracker:ProviderCountForCode("wind") > 0
  or Tracker:ProviderCountForCode("water") > 0 and Tracker:ProviderCountForCode("wind") > 0
  then
    return 1
  end
end

function ThreeElements()
  if Tracker:ProviderCountForCode("earth") > 0 and Tracker:ProviderCountForCode("fire") > 0 and Tracker:ProviderCountForCode("water") > 0
  or Tracker:ProviderCountForCode("earth") > 0 and Tracker:ProviderCountForCode("fire") > 0 and Tracker:ProviderCountForCode("wind") > 0
  or Tracker:ProviderCountForCode("fire") > 0 and Tracker:ProviderCountForCode("water") > 0 and Tracker:ProviderCountForCode("wind") > 0
  then
    return 1
  end
end

function FourElements()
  if Tracker:ProviderCountForCode("earth") > 0 and Tracker:ProviderCountForCode("fire") > 0 and Tracker:ProviderCountForCode("water") > 0 and Tracker:ProviderCountForCode("wind") > 0
  then
    return 1
  end
end
