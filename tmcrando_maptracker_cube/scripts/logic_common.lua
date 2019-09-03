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
