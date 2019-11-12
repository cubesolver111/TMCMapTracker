-- Configuration ----------------------
TMC_AUTOTRACKER_DEBUG = true
---------------------------------------

print("")
print("Active Auto-Tracker Configuration")
print("")
print("Enable Item Tracking:       ", AUTOTRACKER_ENABLE_ITEM_TRACKING)
print("Enable Location Tracking:   ", AUTOTRACKER_ENABLE_LOCATION_TRACKING)
if TMC_AUTOTRACKER_DEBUG then
  print("Enable Debug Logging:       ", TMC_AUTOTRACKER_DEBUG)
end
print("")

function autotracker_started()
  print("Started Tracking")
end

BOW_VALUE = 0
GOLD_FALLS_COUNT = 0
GOLD_WILDS_COUNT = 0
GOLD_CLOUDS_COUNT = 0
GOLD_WILDS_PREV_VALUE = 0
GOLD_CLOUDS_PREV_VALUE = 0

DWS_KEY_COUNT = 0
DWS_KEY_PREV_VALUE = 0
COF_KEY_COUNT = 0
COF_KEY_PREV_VALUE = 0
FOW_KEY_COUNT = 0
FOW_KEY_PREV_VALUE = 0
TOD_KEY_COUNT = 0
TOD_KEY_PREV_VALUE = 0
POW_KEY_COUNT = 0
POW_KEY_PREV_VALUE = 0
DHC_KEY_COUNT = 0
DHC_KEY_PREV_VALUE = 0
RC_KEY_COUNT = 0
RC_KEY_PREV_VALUE = 0

U8_READ_CACHE = 0
U8_READ_CACHE_ADDRESS = 0

function InvalidateReadCaches()
    U8_READ_CACHE_ADDRESS = 0
end

function ReadU8(segment, address)
    if U8_READ_CACHE_ADDRESS ~= address then
        U8_READ_CACHE = segment:ReadUInt8(address)
        U8_READ_CACHE_ADDRESS = address
    end
    return U8_READ_CACHE
end

function isInGame()
  return AutoTracker:ReadU8(0x2002b32) > 0x00
end

function testFlag(segment, address, flag)
  local value = ReadU8(segment, address)
  local flagTest = value & flag

  if flagTest ~= 0 then
    return true
  else
    return false
  end
end

function updateToggleItemFromByteAndFlag(segment, code, address, flag)
    local item = Tracker:FindObjectForCode(code)
    if item then
        local value = ReadU8(segment, address)
        if TMC_AUTOTRACKER_DEBUG then
            print(item.Name, code, flag)
        end

        local flagTest = value & flag

        if flagTest ~= 0 then
            item.Active = true
        else
            item.Active = false
        end
    end
end

function updateSectionChestCountFromByteAndFlag(segment, locationRef, address, flag)
    local location = Tracker:FindObjectForCode(locationRef)
    if location then
        --Don't undo what user has done
        if location.Owner.ModifiedByUser then
            return
        end

        local value = ReadU8(segment, address)

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(locationRef, value)
        end

        if (value & flag) ~= 0 then
            location.AvailableChestCount = 0
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print("Couldn't find location", locationRef)
    end
end

function updateDogFood(segment, code, address, flag)
  local item = Tracker:FindObjectForCode(code)
  if item then
    local value = ReadU8(segment, address)
    if TMC_AUTOTRACKER_DEBUG then
      print(item.Name, code, flag)
    end

    local flagTest = value or flag

    if flagTest >= 0x10 and flagTest < 0x30
    or flagTest >= 0x50 and flagTest < 0x70
    or flagTest >= 0x90 and flagTest < 0xB0
    or flagTest >= 0xd0 and flagTest < 0xf0 then
      item.Active = true
    else
      item.Active = false
    end
  end
end

function updateLLRKey(segment, code, address, flag)
  local item = Tracker:FindObjectForCode(code)
  if item then
    local value = ReadU8(segment, address)
    if TMC_AUTOTRACKER_DEBUG then
      print(item.Name, code, flag)
    end

    local flagTest = value or flag

    if flagTest >= 0x40 then
      item.Active = true
    else
      item.Active = false
    end
  end
end

function updateMush(segment, code, address, flag)
  local item = Tracker:FindObjectForCode(code)
  if item then
    local value = ReadU8(segment, address)
    if TMC_AUTOTRACKER_DEBUG then
      print(item.Name, code, flag)
    end

    local flagTest = value or flag

    if flagTest == 0x01 or flagTest == 0x02 or
       flagTest == 0x05 or flagTest == 0x06 or
       flagTest == 0x09 or flagTest == 0x0A or
       flagTest == 0x11 or flagTest == 0x12 or
       flagTest == 0x15 or flagTest == 0x16 or
       flagTest == 0x19 or flagTest == 0x1A or
       flagTest == 0x21 or flagTest == 0x22 or
       flagTest == 0x29 or flagTest == 0x2A or
       flagTest == 0x41 or flagTest == 0x42 or
       flagTest == 0x45 or flagTest == 0x46 or
       flagTest == 0x49 or flagTest == 0x4A or
       flagTest == 0x51 or flagTest == 0x52 or
       flagTest == 0x55 or flagTest == 0x56 or
       flagTest == 0x81 or flagTest == 0x82 or
       flagTest == 0x85 or flagTest == 0x86 or
       flagTest == 0x89 or flagTest == 0x8A or
       flagTest == 0xA1 or flagTest == 0xA2 or
       flagTest == 0xA5 or flagTest == 0xA6 or
       flagTest == 0xA9 or flagTest == 0xAA then
      item.Active = true
    else
      item.Active = false
    end
  end
end

function updateGraveKey(segment, code, address, flag)
  local item = Tracker:FindObjectForCode(code)
  if item then
    local value = ReadU8(segment, address)
    if TMC_AUTOTRACKER_DEBUG then
      print(item.Name, code, flag)
    end

    local flagTest = value or flag

    if flagTest == 0x01 or flagTest == 0x02 or
       flagTest == 0x05 or flagTest == 0x06 or
       flagTest == 0x11 or flagTest == 0x12 or
       flagTest == 0x15 or flagTest == 0x16 or
       flagTest == 0x41 or flagTest == 0x42 or
       flagTest == 0x45 or flagTest == 0x46 or
       flagTest == 0x51 or flagTest == 0x52 or
       flagTest == 0x55 or flagTest == 0x56 then
        item.Active = true
    else
      item.Active = false
    end
  end
end

function updateBooks(segment, code, address)
  local item = Tracker:FindObjectForCode(code)
  if item then
    local value = ReadU8(segment, address)
    if testFlag(segment, address, 0x04) or testFlag(segment, address, 0x08) or
       testFlag(segment, address, 0x10) or testFlag(segment, address, 0x20) or
       testFlag(segment, address, 0x40) or testFlag(segment, address, 0x80) then
          item.AcquiredCount = 1
    end
    if testFlag(segment, address, 0x04) and testFlag(segment, address, 0x10) or
       testFlag(segment, address, 0x04) and testFlag(segment, address, 0x20) or
       testFlag(segment, address, 0x04) and testFlag(segment, address, 0x40) or
       testFlag(segment, address, 0x04) and testFlag(segment, address, 0x80) or
       testFlag(segment, address, 0x08) and testFlag(segment, address, 0x10) or
       testFlag(segment, address, 0x08) and testFlag(segment, address, 0x20) or
       testFlag(segment, address, 0x08) and testFlag(segment, address, 0x40) or
       testFlag(segment, address, 0x08) and testFlag(segment, address, 0x80) or
       testFlag(segment, address, 0x10) and testFlag(segment, address, 0x04) or
       testFlag(segment, address, 0x10) and testFlag(segment, address, 0x08) or
       testFlag(segment, address, 0x10) and testFlag(segment, address, 0x40) or
       testFlag(segment, address, 0x10) and testFlag(segment, address, 0x80) or
       testFlag(segment, address, 0x20) and testFlag(segment, address, 0x04) or
       testFlag(segment, address, 0x20) and testFlag(segment, address, 0x08) or
       testFlag(segment, address, 0x20) and testFlag(segment, address, 0x40) or
       testFlag(segment, address, 0x20) and testFlag(segment, address, 0x80) or
       testFlag(segment, address, 0x40) and testFlag(segment, address, 0x04) or
       testFlag(segment, address, 0x40) and testFlag(segment, address, 0x08) or
       testFlag(segment, address, 0x40) and testFlag(segment, address, 0x10) or
       testFlag(segment, address, 0x40) and testFlag(segment, address, 0x20) then
          item.AcquiredCount = 2
    end
    if testFlag(segment, address, 0x04) and testFlag(segment, address, 0x10) and testFlag(segment, address, 0x40) or
       testFlag(segment, address, 0x04) and testFlag(segment, address, 0x10) and testFlag(segment, address, 0x80) or
       testFlag(segment, address, 0x04) and testFlag(segment, address, 0x20) and testFlag(segment, address, 0x40) or
       testFlag(segment, address, 0x04) and testFlag(segment, address, 0x20) and testFlag(segment, address, 0x80) or
       testFlag(segment, address, 0x08) and testFlag(segment, address, 0x20) and testFlag(segment, address, 0x80) or
       testFlag(segment, address, 0x08) and testFlag(segment, address, 0x20) and testFlag(segment, address, 0x40) or
       testFlag(segment, address, 0x08) and testFlag(segment, address, 0x10) and testFlag(segment, address, 0x80) or
       testFlag(segment, address, 0x08) and testFlag(segment, address, 0x10) and testFlag(segment, address, 0x40) then
          item.AcquiredCount = 3
    end
    if not testFlag(segment, address, 0x04) and not testFlag(segment, address, 0x08) and
       not testFlag(segment, address, 0x10) and not testFlag(segment, address, 0x20) and
       not testFlag(segment, address, 0x40) and not testFlag(segment, address, 0x80) then
          item.AcquiredCount = 0
    end
  end
end

function updateSwords(segment)
  local item = Tracker:FindObjectForCode("sword")
  if ReadU8(segment, 0x2002b33) == 0x01 or ReadU8(segment, 0x2002b33) == 0x41 or ReadU8(segment, 0x2002b33) == 0x81 then
    item.CurrentStage = 4
  elseif ReadU8(segment, 0x2002b33) == 0x11 or ReadU8(segment, 0x2002b33) == 0x51 or ReadU8(segment, 0x2002b33) == 0x91 then
    item.CurrentStage = 5
  elseif ReadU8(segment, 0x2002b32) == 0x05 then
    item.CurrentStage = 1
  elseif ReadU8(segment, 0x2002b32) == 0x15 then
    item.CurrentStage = 2
  elseif ReadU8 (segment, 0x2002b32) == 0x55 then
    item.CurrentStage = 3
  else
    item.CurrentStage = 0
  end
end

function updateBow(segment)
  local item = Tracker:FindObjectForCode("bow")
  if testFlag(segment, 0x2002b34, 0x04) then
    item.CurrentStage = 1
    BOW_VALUE = 1
  end
  if testFlag(segment, 0x2002b34, 0x10) then
    item.CurrentStage = 2
  end
  if not testFlag(segment, 0x2002b34, 0x04) and not testFlag(segment, 0x2002b34, 0x10) then
    item.CurrentStage = 0
    BOW_VALUE = 0
  end
end

function updateBoomerang(segment)
  local item = Tracker:FindObjectForCode("boomerang")
  if testFlag(segment, 0x2002b34, 0x40) then
    item.CurrentStage = 1
  end
  if testFlag(segment, 0x2002b35, 0x01) then
    item.CurrentStage = 2
  end
  if not testFlag(segment, 0x2002b34, 0x40) and not testFlag (segment, 0x2002b35, 0x01) then
    item.CurrentStage = 0
  end
end

function updateShield(segment)
  local item = Tracker:FindObjectForCode("shield")
  if testFlag(segment, 0x2002b35, 0x04) then
    item.CurrentStage = 1
  end
  if testFlag(segment, 0x2002b35, 0x10) then
    item.CurrentStage = 2
  end
  if not testFlag(segment, 0x2002b35, 0x10) and not testFlag(segment, 0x2002b35, 0x04) then
    item.CurrentStage = 0
  end
end

function updateLamp(segment)
  local item = Tracker:FindObjectForCode("lamp")
  if testFlag(segment, 0x2002b35, 0x40) then
    item.CurrentStage = 1
  else
    item.CurrentStage = 0
  end
end

function updateBottles(segment)
  local item = Tracker:FindObjectForCode("bottle")
  local value = ReadU8(segment, 0x2002b39)
  if value == 0x01 then
    item.CurrentStage = 1
  elseif value == 0x05 then
    item.CurrentStage = 2
  elseif value == 0x15 then
    item.CurrentStage = 3
  elseif value == 0x55 then
    item.CurrentStage = 4
  else
    item.CurrentStage = 0
  end
end

function updateBeams(segment)
  local item = Tracker:FindObjectForCode("beam")

  if testFlag(segment, 0x2002b45, 0x01) then
    item.Active = true
  elseif testFlag(segment, 0x2002b45, 0x40) then
    item.Active = true
  else
    item.Active = false
  end
end

function updateBombs(segment)
  local item = Tracker:FindObjectForCode("bombs")
  if item then
    item.CurrentStage = ReadU8(segment, 0x2002aee)
  end
  if ReadU8(segment, 0x2002aee) == 0x00 then
    item.CurrentStage = 0
  end
end

function updateQuiver(segment)
  local item = Tracker:FindObjectForCode("quiver")
  if item then
    if BOW_VALUE ~=0 then
      item.CurrentStage = ReadU8(segment, 0x2002aef) - 1
    else
      item.CurrentStage = ReadU8(segment, 0x2002aef)
    end
  end
  if ReadU8(segment,0x2002aef) == 0x00 then
    item.CurrentStage = 0
  end
end

function updateWallet(segment)
  local item = Tracker:FindObjectForCode("wallet")
  if item then
    item.CurrentStage = ReadU8(segment, 0x2002ae8)
  end
  if ReadU8(segment, 0x2002ae8) == 0x00 then
    item.CurrentStage = 0
  end
end

function updateScrolls(segment)
  local item = Tracker:FindObjectForCode("sevenscrolls")
  local count = 0
  if testFlag(segment, 0x2002b44, 0x01) then
    count = count + 1
  end
  if testFlag(segment, 0x2002b44, 0x04) then
    count = count + 1
  end
  if testFlag(segment, 0x2002b44, 0x10) then
    count = count + 1
  end
  if testFlag(segment, 0x2002b44, 0x40) then
    count = count + 1
  end
  if testFlag(segment, 0x2002b45, 0x01) then
    count = count + 1
  end
  if testFlag(segment, 0x2002b45, 0x04) then
    count = count + 1
  end
  if testFlag(segment, 0x2002b45, 0x10) then
    count = count + 1
  end
  if testFlag(segment, 0x2002b45, 0x40) then
    count = count + 1
  end
  if testFlag(segment, 0x2002b4e, 0x40) then
    count = count + 1
  end
  if testFlag(segment, 0x2002b4f, 0x01) then
    count = count + 1
  end
  if testFlag(segment, 0x2002b4f, 0x04) then
    count = count + 1
  end
  item.AcquiredCount = count
end

function updateGoldFalls(segment)
  local item = Tracker:FindObjectForCode("falls")
  if ReadU8(segment, 0x2002b58) == 0x6d then
    item.Active = true
    GOLD_FALLS_COUNT = 1
  elseif ReadU8(segment, 0x2002b59) == 0x6d then
    item.Active = true
    GOLD_FALLS_COUNT = 1
  elseif ReadU8(segment, 0x2002b5a) == 0x6d then
    item.Active = true
    GOLD_FALLS_COUNT = 1
  elseif ReadU8(segment, 0x2002b5b) == 0x6d then
    item.Active = true
    GOLD_FALLS_COUNT = 1
  elseif ReadU8(segment, 0x2002b5c) == 0x6d then
    item.Active = true
    GOLD_FALLS_COUNT = 1
  elseif ReadU8(segment, 0x2002b5d) == 0x6d then
    item.Active = true
    GOLD_FALLS_COUNT = 1
  elseif ReadU8(segment, 0x2002b5e) == 0x6d then
    item.Active = true
    GOLD_FALLS_COUNT = 1
  elseif ReadU8(segment, 0x2002b5f) == 0x6d then
    item.Active = true
    GOLD_FALLS_COUNT = 1
  elseif ReadU8(segment, 0x2002b60) == 0x6d then
    item.Active = true
    GOLD_FALLS_COUNT = 1
  elseif ReadU8(segment, 0x2002b61) == 0x6d then
    item.Active = true
    GOLD_FALLS_COUNT = 1
  elseif ReadU8(segment, 0x2002b62) == 0x6d then
    item.Active = true
    GOLD_FALLS_COUNT = 1
  elseif GOLD_FALLS_COUNT == 0 then
    item.Active = false
  end
end

function updateWilds(segment, code, flag)
  local item = Tracker:FindObjectForCode(code)
  if ReadU8(segment, 0x2002b58) == flag then
    if ReadU8(segment, 0x2002b6b) > GOLD_WILDS_PREV_VALUE then
      GOLD_WILDS_COUNT = GOLD_WILDS_COUNT + 1
      item.AcquiredCount = GOLD_WILDS_COUNT
    end
    GOLD_WILDS_PREV_VALUE = ReadU8(segment, 0x2002b6b)
  elseif ReadU8(segment, 0x2002b59) == flag then
    if ReadU8(segment, 0x2002b6c) > GOLD_WILDS_PREV_VALUE then
      GOLD_WILDS_COUNT = GOLD_WILDS_COUNT + 1
      item.AcquiredCount = GOLD_WILDS_COUNT
    end
    GOLD_WILDS_PREV_VALUE = ReadU8(segment, 0x2002b6c)
  elseif ReadU8(segment, 0x2002b5a) == flag then
    if ReadU8(segment, 0x2002b6d) > GOLD_WILDS_PREV_VALUE then
      GOLD_WILDS_COUNT = GOLD_WILDS_COUNT + 1
      item.AcquiredCount = GOLD_WILDS_COUNT
    end
    GOLD_WILDS_PREV_VALUE = ReadU8(segment, 0x2002b6d)
  elseif ReadU8(segment, 0x2002b5b) == flag then
    if ReadU8(segment, 0x2002b6e) > GOLD_WILDS_PREV_VALUE then
      GOLD_WILDS_COUNT = GOLD_WILDS_COUNT + 1
      item.AcquiredCount = GOLD_WILDS_COUNT
    end
    GOLD_WILDS_PREV_VALUE = ReadU8(segment, 0x2002b6e)
  elseif ReadU8(segment, 0x2002b5c) == flag then
    if ReadU8(segment, 0x2002b6f) > GOLD_WILDS_PREV_VALUE then
      GOLD_WILDS_COUNT = GOLD_WILDS_COUNT + 1
      item.AcquiredCount = GOLD_WILDS_COUNT
    end
    GOLD_WILDS_PREV_VALUE = ReadU8(segment, 0x2002b6f)
  elseif ReadU8(segment, 0x2002b5d) == flag then
    if ReadU8(segment, 0x2002b70) > GOLD_WILDS_PREV_VALUE then
      GOLD_WILDS_COUNT = GOLD_WILDS_COUNT + 1
      item.AcquiredCount = GOLD_WILDS_COUNT
    end
    GOLD_WILDS_PREV_VALUE = ReadU8(segment, 0x2002b70)
  elseif ReadU8(segment, 0x2002b5e) == flag then
    if ReadU8(segment, 0x2002b71) > GOLD_WILDS_PREV_VALUE then
      GOLD_WILDS_COUNT = GOLD_WILDS_COUNT + 1
      item.AcquiredCount = GOLD_WILDS_COUNT
    end
    GOLD_WILDS_PREV_VALUE = ReadU8(segment, 0x2002b71)
  elseif ReadU8(segment, 0x2002b5f) == flag then
    if ReadU8(segment, 0x2002b72) > GOLD_WILDS_PREV_VALUE then
      GOLD_WILDS_COUNT = GOLD_WILDS_COUNT + 1
      item.AcquiredCount = GOLD_WILDS_COUNT
    end
    GOLD_WILDS_PREV_VALUE = ReadU8(segment, 0x2002b72)
  elseif ReadU8(segment, 0x2002b60) == flag then
    if ReadU8(segment, 0x2002b73) > GOLD_WILDS_PREV_VALUE then
      GOLD_WILDS_COUNT = GOLD_WILDS_COUNT + 1
      item.AcquiredCount = GOLD_WILDS_COUNT
    end
    GOLD_WILDS_PREV_VALUE = ReadU8(segment, 0x2002b73)
  elseif ReadU8(segment, 0x2002b61) == flag then
    if ReadU8(segment, 0x2002b74) > GOLD_WILDS_PREV_VALUE then
      GOLD_WILDS_COUNT = GOLD_WILDS_COUNT + 1
      item.AcquiredCount = GOLD_WILDS_COUNT
    end
    GOLD_WILDS_PREV_VALUE = ReadU8(segment, 0x2002b74)
  elseif ReadU8(segment, 0x2002b62) == flag then
    if ReadU8(segment, 0x2002b75) > GOLD_WILDS_PREV_VALUE then
      GOLD_WILDS_COUNT = GOLD_WILDS_COUNT + 1
      item.AcquiredCount = GOLD_WILDS_COUNT
    end
    GOLD_WILDS_PREV_VALUE = ReadU8(segment, 0x2002b75)
  elseif GOLD_WILDS_COUNT == 0 then
    item.AcquiredCount = 0
  end
end

function updateClouds(segment, code, flag)
  local item = Tracker:FindObjectForCode(code)
  if ReadU8(segment, 0x2002b58) == flag then
    if ReadU8(segment, 0x2002b6b) > GOLD_CLOUDS_PREV_VALUE then
      GOLD_CLOUDS_COUNT = GOLD_CLOUDS_COUNT + 1
      item.AcquiredCount = GOLD_CLOUDS_COUNT
    end
    GOLD_CLOUDS_PREV_VALUE = ReadU8(segment, 0x2002b6b)
  elseif ReadU8(segment, 0x2002b59) == flag then
    if ReadU8(segment, 0x2002b6c) > GOLD_CLOUDS_PREV_VALUE then
      GOLD_CLOUDS_COUNT = GOLD_CLOUDS_COUNT + 1
      item.AcquiredCount = GOLD_CLOUDS_COUNT
    end
    GOLD_CLOUDS_PREV_VALUE = ReadU8(segment, 0x2002b6c)
  elseif ReadU8(segment, 0x2002b5a) == flag then
    if ReadU8(segment, 0x2002b6d) > GOLD_CLOUDS_PREV_VALUE then
      GOLD_CLOUDS_COUNT = GOLD_CLOUDS_COUNT + 1
      item.AcquiredCount = GOLD_CLOUDS_COUNT
    end
    GOLD_CLOUDS_PREV_VALUE = ReadU8(segment, 0x2002b6d)
  elseif ReadU8(segment, 0x2002b5b) == flag then
    if ReadU8(segment, 0x2002b6e) > GOLD_CLOUDS_PREV_VALUE then
      GOLD_CLOUDS_COUNT = GOLD_CLOUDS_COUNT + 1
      item.AcquiredCount = GOLD_CLOUDS_COUNT
    end
    GOLD_CLOUDS_PREV_VALUE = ReadU8(segment, 0x2002b6e)
  elseif ReadU8(segment, 0x2002b5c) == flag then
    if ReadU8(segment, 0x2002b6f) > GOLD_CLOUDS_PREV_VALUE then
      GOLD_CLOUDS_COUNT = GOLD_CLOUDS_COUNT + 1
      item.AcquiredCount = GOLD_CLOUDS_COUNT
    end
    GOLD_CLOUDS_PREV_VALUE = ReadU8(segment, 0x2002b6f)
  elseif ReadU8(segment, 0x2002b5d) == flag then
    if ReadU8(segment, 0x2002b70) > GOLD_CLOUDS_PREV_VALUE then
      GOLD_CLOUDS_COUNT = GOLD_CLOUDS_COUNT + 1
      item.AcquiredCount = GOLD_CLOUDS_COUNT
    end
    GOLD_CLOUDS_PREV_VALUE = ReadU8(segment, 0x2002b70)
  elseif ReadU8(segment, 0x2002b5e) == flag then
    if ReadU8(segment, 0x2002b71) > GOLD_CLOUDS_PREV_VALUE then
      GOLD_CLOUDS_COUNT = GOLD_CLOUDS_COUNT + 1
      item.AcquiredCount = GOLD_CLOUDS_COUNT
    end
    GOLD_CLOUDS_PREV_VALUE = ReadU8(segment, 0x2002b71)
  elseif ReadU8(segment, 0x2002b5f) == flag then
    if ReadU8(segment, 0x2002b72) > GOLD_CLOUDS_PREV_VALUE then
      GOLD_CLOUDS_COUNT = GOLD_CLOUDS_COUNT + 1
      item.AcquiredCount = GOLD_CLOUDS_COUNT
    end
    GOLD_CLOUDS_PREV_VALUE = ReadU8(segment, 0x2002b72)
  elseif ReadU8(segment, 0x2002b60) == flag then
    if ReadU8(segment, 0x2002b73) > GOLD_CLOUDS_PREV_VALUE then
      GOLD_CLOUDS_COUNT = GOLD_CLOUDS_COUNT + 1
      item.AcquiredCount = GOLD_CLOUDS_COUNT
    end
    GOLD_CLOUDS_PREV_VALUE = ReadU8(segment, 0x2002b73)
  elseif ReadU8(segment, 0x2002b61) == flag then
    if ReadU8(segment, 0x2002b74) > GOLD_CLOUDS_PREV_VALUE then
      GOLD_CLOUDS_COUNT = GOLD_CLOUDS_COUNT + 1
      item.AcquiredCount = GOLD_CLOUDS_COUNT
    end
    GOLD_CLOUDS_PREV_VALUE = ReadU8(segment, 0x2002b74)
  elseif ReadU8(segment, 0x2002b62) == flag then
    if ReadU8(segment, 0x2002b75) > GOLD_CLOUDS_PREV_VALUE then
      GOLD_CLOUDS_COUNT = GOLD_CLOUDS_COUNT + 1
      item.AcquiredCount = GOLD_CLOUDS_COUNT
    end
    GOLD_CLOUDS_PREV_VALUE = ReadU8(segment, 0x2002b75)
  elseif GOLD_CLOUDS_COUNT == 0 then
    item.AcquiredCount = 0
  end
end

function updateHearts(segment, address)
  local item = Tracker:FindObjectForCode("hearts")
  if item then
    item.CurrentStage = ReadU8(segment, address)/8 - 3
  end
  if ReadU8(segment,address)/8 == 0x08 then
    item.CurrentStage = 0
  end
end

function updateSmallKeys(segment, code, address)
  local item = Tracker:FindObjectForCode(code)
  if code == "dws_smallkey" then
    if ReadU8(segment, address) > DWS_KEY_PREV_VALUE then
      DWS_KEY_COUNT = DWS_KEY_COUNT + 1
      item.AcquiredCount = DWS_KEY_COUNT
    end
    DWS_KEY_PREV_VALUE = ReadU8(segment, address)
  elseif code == "cof_smallkey" then
    if ReadU8(segment, address) > COF_KEY_PREV_VALUE then
      COF_KEY_COUNT = COF_KEY_COUNT + 1
      item.AcquiredCount = COF_KEY_COUNT
    end
    COF_KEY_PREV_VALUE = ReadU8(segment, address)
  elseif code == "fow_smallkey" then
    if ReadU8(segment, address) > FOW_KEY_PREV_VALUE then
      FOW_KEY_COUNT = FOW_KEY_COUNT + 1
      item.AcquiredCount = FOW_KEY_COUNT
    end
    FOW_KEY_PREV_VALUE = ReadU8(segment, address)
  elseif code == "tod_smallkey" then
    if ReadU8(segment, address) > TOD_KEY_PREV_VALUE then
      TOD_KEY_COUNT = TOD_KEY_COUNT + 1
      item.AcquiredCount = TOD_KEY_COUNT
    end
    TOD_KEY_PREV_VALUE = ReadU8(segment, address)
  elseif code == "pow_smallkey" then
    if ReadU8(segment, address) > POW_KEY_PREV_VALUE then
      POW_KEY_COUNT = POW_KEY_COUNT + 1
      item.AcquiredCount = POW_KEY_COUNT
    end
    POW_KEY_PREV_VALUE = ReadU8(segment, address)
  elseif code == "explicit_dhc_smallkey" then
    if ReadU8(segment, address) > DHC_KEY_PREV_VALUE then
      DHC_KEY_COUNT = DHC_KEY_COUNT + 1
      item.AcquiredCount = DHC_KEY_COUNT
    end
    DHC_KEY_PREV_VALUE = ReadU8(segment, address)
  elseif code == "cryptkey" then
    if ReadU8(segment, address) > RC_KEY_PREV_VALUE then
      RC_KEY_COUNT = RC_KEY_COUNT + 1
      item.AcquiredCount = RC_KEY_COUNT
    end
    RC_KEY_PREV_VALUE = ReadU8(segment, address)
  else
    item.AcquiredCount = 0
  end
end

function updateItemsFromMemorySegment(segment)
  if not isInGame() then
    return false
  end
  InvalidateReadCaches()

  if AUTOTRACKER_ENABLE_ITEM_TRACKING then

    updateToggleItemFromByteAndFlag(segment, "remote", 0x2002b34, 0x01)
    updateToggleItemFromByteAndFlag(segment, "gust", 0x2002b36, 0x04)
    updateToggleItemFromByteAndFlag(segment, "cane", 0x2002b36, 0x10)
    updateToggleItemFromByteAndFlag(segment, "mitts", 0x2002b36, 0x40)
    updateToggleItemFromByteAndFlag(segment, "cape", 0x2002b37, 0x01)
    updateToggleItemFromByteAndFlag(segment, "boots", 0x2002b37, 0x04)
    updateToggleItemFromByteAndFlag(segment, "ocarina", 0x2002b37, 0x40)
    updateToggleItemFromByteAndFlag(segment, "trophy", 0x2002b41, 0x04)
    updateToggleItemFromByteAndFlag(segment, "carlov", 0x2002b41, 0x10)
    updateToggleItemFromByteAndFlag(segment, "grip", 0x2002b43, 0x01)
    updateToggleItemFromByteAndFlag(segment, "bracelets", 0x2002b43, 0x04)
    updateToggleItemFromByteAndFlag(segment, "flippers", 0x2002b43, 0x10)
    updateToggleItemFromByteAndFlag(segment, "spinattack", 0x2002b44, 0x01)
    updateToggleItemFromByteAndFlag(segment, "jabber", 0x2002b48, 0x40)
    updateToggleItemFromByteAndFlag(segment, "bowandfly", 0x2002b4e, 0x01)
    updateToggleItemFromByteAndFlag(segment, "mittsButterfly", 0x2002b4e, 0x04)
    updateToggleItemFromByteAndFlag(segment, "flippersButterfly", 0x2002b4e, 0x10)

    updateLLRKey(segment, "llrkey", 0x2002b3f, 0x40)
    updateDogFood(segment, "dogbottle", 0x2002b3f, 0x10)
    updateMush(segment, "mushroom", 0x2002b40, 0x01)
    updateBooks(segment, "books", 0x2002b40)
    updateGraveKey(segment, "gravekey", 0x2002b41, 0x01)

    updateSwords(segment)
    updateBow(segment)
    updateBoomerang(segment)
    updateShield(segment)
    updateLamp(segment)
    updateBottles(segment)
    updateBeams(segment)
    updateScrolls(segment)
    updateGoldFalls(segment)
    updateWilds(segment, "wilds", 0x6a)
    updateClouds(segment, "clouds", 0x65)

    updateSectionChestCountFromByteAndFlag(segment, "@Fifi/Fifi", 0x2002b3f, 0x20)

  end

  if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    return true
  end
end

function updateGearFromMemory(segment)
  if not isInGame() then
    return false
  end

  InvalidateReadCaches()

  if AUTOTRACKER_ENABLE_ITEM_TRACKING then
    updateBombs(segment)
    updateQuiver(segment)
    updateWallet(segment)
    updateHearts(segment, 0x2002aeb)
  end

  if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    return true
  end
end

function updateNorthDigging(segment)
  if testFlag(segment, 0x2002cce, 0xf8) and testFlag(segment, 0x2002ccf, 0x01) then
    local location = Tracker:FindObjectForCode("@North Digging Spots/Buried Treasure")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateMelariDigging(segment)
  if testFlag(segment, 0x2002cf3, 0xfe) and testFlag(segment, 0x2002cf4, 0x01) then
    local location = Tracker:FindObjectForCode("@Mines/Digging Spots (Melari's Mines Tab)")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateMelariDiggingObs(segment)
  if testFlag(segment, 0x2002cf3, 0xfe) and testFlag(segment, 0x2002cf4, 0x01) then
    local location = Tracker:FindObjectForCode("@Mines Obs/Digging Spots (Melari's Mines Tab)")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateNorthHyliaCapeCave(segment)
  if testFlag(segment,0x2002d02, 0x80) and testFlag(segment, 0x2002d03, 0x7e) then
    local location = Tracker:FindObjectForCode("@North Hylia Cape Cave/North Hylia Cape Cave")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateTreasureCave(segment)
  if testFlag(segment,0x2002d02, 0x80) and testFlag(segment, 0x2002d03, 0x7e) then
    local location = Tracker:FindObjectForCode("@Treasure Cave/Treasure Cave")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateDigCave(segment)
  if testFlag(segment, 0x2002d04, 0x80) and testFlag(segment, 0x2002d05, 0x02) then
    local location = Tracker:FindObjectForCode("@Trilby Highlands Mitts Cave/Trilby Cave")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateFOWLeftMitts(segment)
  if testFlag(segment, 0x2002d06, 0x01) and testFlag(segment, 0x2002d07, 0x20) then
    local location = Tracker:FindObjectForCode("@FOW/Left Side Mitts Chests")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateFOWLeftMittsRupees(segment)
  if testFlag(segment, 0x2002d06, 0x01) and testFlag(segment, 0x2002d07, 0x20) then
    local location = Tracker:FindObjectForCode("@FOW Rupees/Left Side Mitts Chests")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateFOWLeftMittsObscure(segment)
  if testFlag(segment, 0x2002d06, 0x01) and testFlag(segment, 0x2002d07, 0x20) then
    local location = Tracker:FindObjectForCode("@FOW Obscure/Left Side Mitts Chests")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateFOWLeftMittsRupObs(segment)
  if testFlag(segment, 0x2002d06, 0x01) and testFlag(segment, 0x2002d07, 0x20) then
    local location = Tracker:FindObjectForCode("@FOW RupObs/Left Side Mitts Chests")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateFOWRightMitts(segment)
  if testFlag(segment, 0x2002d06, 0x04) and testFlag(segment, 0x2002d07, 0x40) then
    local location = Tracker:FindObjectForCode("@FOW/Right Side Mitts Chests")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateFOWRightMittsRupees(segment)
  if testFlag(segment, 0x2002d06, 0x04) and testFlag(segment, 0x2002d07, 0x40) then
    local location = Tracker:FindObjectForCode("@FOW Rupees/Right Side Mitts Chests")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateFOWRightMittsObscure(segment)
  if testFlag(segment, 0x2002d06, 0x04) and testFlag(segment, 0x2002d07, 0x40) then
    local location = Tracker:FindObjectForCode("@FOW Obscure/Right Side Mitts Chests")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateFOWRightMittsRupObs(segment)
  if testFlag(segment, 0x2002d06, 0x04) and testFlag(segment, 0x2002d07, 0x40) then
    local location = Tracker:FindObjectForCode("@FOW RupObs/Right Side Mitts Chests")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateFOWRupees(segment)
  if testFlag(segment, 0x2002d06, 0xe0) and testFlag(segment, 0x2002d07, 0x0f) then
    local location = Tracker:FindObjectForCode("@FOW Rupees/Left Side Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateFOWRupeesObs(segment)
  if testFlag(segment, 0x2002d06, 0xe0) and testFlag(segment, 0x2002d07, 0x0f) then
    local location = Tracker:FindObjectForCode("@FOW RupObs/Left Side Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateSchoolyard(segment)
  if testFlag(segment, 0x2002d0b, 0x80) and testFlag(segment, 0x2002d0c, 0x03) then
    local location = Tracker:FindObjectForCode("@School Gardens/Garden Chests")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateSchoolyardOpen(segment)
  if testFlag(segment, 0x2002d0b, 0x80) and testFlag(segment, 0x2002d0c, 0x03) then
    local location = Tracker:FindObjectForCode("@School Gardens Open/Garden Chests")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateWestWoodsRupees(segment)
  if testFlag(segment, 0x2002d0d, 0xf0) and testFlag(segment, 0x2002d0e, 0x0f) and testFlag(segment, 0x2002d0f, 0xc0) and testFlag(segment, 0x2002d10, 0x3f) then
    local location = Tracker:FindObjectForCode("@Western Woods Beanstalk Rupee/Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateCrenelRupees(segment)
  if testFlag(segment, 0x2002d0e, 0xc0) and testFlag(segment, 0x2002d0f, 0x3f) then
    local location = Tracker:FindObjectForCode("@Mt. Crenel Beanstalk Rupees/Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateSouthRupees(segment)
  if testFlag(segment, 0x2002d1e, 0xe0) and testFlag(segment, 0x2002d1f, 0xff) and testFlag(segment, 0x2002d20, 0x0f) then
    local location = Tracker:FindObjectForCode("@Fusion Rupee Cave/Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateTrilbyRupees(segment)
  if testFlag(segment, 0x2002d20, 0xf0) and testFlag(segment, 0x2002d21, 0xff) and testFlag(segment, 0x2002d22, 0x07) then
    local location = Tracker:FindObjectForCode("@Trilby Highlands Rupee Cave/Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateUpperCaveRupees(segment)
  if testFlag(segment, 0x2002d25, 0xe0) and testFlag(segment, 0x2002d26, 0x3f) then
    local location = Tracker:FindObjectForCode("@Veil Falls Upper Cave Rupees/Downstairs Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateUpperCaveDivingRupees(segment)
  if testFlag(segment, 0x2002d26, 0xc0) and testFlag(segment, 0x2002d27, 0x0f) then
    local location = Tracker:FindObjectForCode("@Veil Falls Upper Cave Rupees/Underwater Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateCOFChests(segment)
  if testFlag(segment, 0x2002d5a, 0x80) and testFlag(segment, 0x2002d5b, 0x01) then
    local location = Tracker:FindObjectForCode("@COF/Lava Basement (Left,Right)")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateCOFChestsRupees(segment)
  if testFlag(segment, 0x2002d5a, 0x80) and testFlag(segment, 0x2002d5b, 0x01) then
    local location = Tracker:FindObjectForCode("@COF Rupees/Lava Basement (Left,Right)")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateCOFRupees(segment)
  if testFlag(segment, 0x2002d5b, 0xc0) and testFlag(segment, 0x2002d5c, 0x07) then
    local location = Tracker:FindObjectForCode("@COF Rupees/Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateTODOverhangRupees(segment)
  if testFlag(segment, 0x2002d94, 0xe0) and testFlag(segment, 0x2002d95, 0x03) then
    local location = Tracker:FindObjectForCode("@TOD Rupees/Left Path Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateTODOverhangRupeesObs(segment)
  if testFlag(segment, 0x2002d94, 0xe0) and testFlag(segment, 0x2002d95, 0x03) then
    local location = Tracker:FindObjectForCode("@TOD RupObs/Left Path Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateTODLowerRupees(segment)
  if testFlag(segment, 0x2002d95, 0x80) and testFlag(segment, 0x2002d96, 0x1f) then
    local location = Tracker:FindObjectForCode("@TOD Rupees/Lower Water Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateTODLowerRupeesObs(segment)
  if testFlag(segment, 0x2002d95, 0x80) and testFlag(segment, 0x2002d96, 0x1f) then
    local location = Tracker:FindObjectForCode("@TOD RupObs/Lower Water Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateTODUpperRupees(segment)
  if testFlag(segment, 0x2002d96, 0xe0) and testFlag(segment, 0x2002d97, 0x07) then
    local location = Tracker:FindObjectForCode("@TOD Rupees/Upper Water Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateTODUpperRupeesObs(segment)
  if testFlag(segment, 0x2002d96, 0xe0) and testFlag(segment, 0x2002d97, 0x07) then
    local location = Tracker:FindObjectForCode("@TOD RupObs/Upper Water Rupees")
    if location then
      if location.Owner.ModifiedByUser then
        return
      end

      location.AvailableChestCount = 0
    end
  end
end

function updateLocations(segment)
  if not isInGame() then
    return false
  end

  InvalidateReadCaches()

  if AUTOTRACKER_ENABLE_ITEM_TRACKING then
    updateToggleItemFromByteAndFlag(segment, "dws", 0x2002c9c, 0x04)
    updateToggleItemFromByteAndFlag(segment, "cof", 0x2002c9c, 0x08)
    updateToggleItemFromByteAndFlag(segment, "fow", 0x2002c9c, 0x10)
    updateToggleItemFromByteAndFlag(segment, "tod", 0x2002c9c, 0x20)
    updateToggleItemFromByteAndFlag(segment, "pow", 0x2002c9c, 0x40)
    updateToggleItemFromByteAndFlag(segment, "rc", 0x2002d02, 0x04)
  end

  if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    return true
  end

  --FUSIONS
  updateSectionChestCountFromByteAndFlag(segment, "@Top Right Fusion/Top Right Fusion", 0x2002c81, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@Bottom Left Fusion/Bottom Left Fusion", 0x2002c81, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Top Left Fusion/Top Left Fusion", 0x2002c81, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Central Fusion/Central Fusion", 0x2002c81, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Bottom Right Fusion/Bottom Right Fusion", 0x2002c81, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Castor Wilds Fusions/Left", 0x2002c81, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Castor Wilds Fusions/Middle", 0x2002c81, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Castor Wilds Fusions/Right", 0x2002c82, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Source of the Flow Cave/Fusion", 0x2002c82, 0x02)

  --CRENEL
  updateSectionChestCountFromByteAndFlag(segment, "@Crenel Climbing Wall Chest/Wall Chest", 0x2002cd4, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Crenel Wall Fairy/Crenel Fairy", 0x2002cf0, 0x01)
  updateMelariDigging(segment)
  updateMelariDiggingObs(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@Crenel Climbing Wall Cave/Crenel Climbing Wall Cave", 0x2002d04, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Mt. Crenel Beanstalk/Beanstalk", 0x2002d0c, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Mt. Crenel Beanstalk Rupees/Beanstalk", 0x2002d0c, 0x08)
  updateCrenelRupees(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@Rainy Minish Path Chest/Rainy Chest", 0x2002d10, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Mines/Minish Path Chest", 0x2002d11, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Melari Open/Minish Path Chest", 0x2002d11, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Grayblade/Chests", 0x2002d1c, 0x06)
  updateSectionChestCountFromByteAndFlag(segment, "@Crenel Mines Cave/Crenel Mines Cave", 0x2002d23, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Bridge Cave/Bridge Cave", 0x2002d23, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Fairy Cave Heart Piece/Fairy Cave", 0x2002d2b, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Grayblade/Heart Piece", 0x2002d2c, 0x01)

  --CRENEL BASE
  updateSectionChestCountFromByteAndFlag(segment, "@Vine Rupee/Rupee", 0x2002cc5, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@Crenel Base Chest/Crenel Base Chest", 0x2002cd4, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@Crenel Minish Crack/Minish Crack", 0x2002cde, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@Spring Water Path Chest/Spring Water Path", 0x2002d10, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Crenel Heart Piece Cave/Heart Piece", 0x2002d24, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Crenel Heart Piece Cave/Chests", 0x2002d24, 0x06)
  updateSectionChestCountFromByteAndFlag(segment, "@Fairy + Rupee Cave/Rupees", 0x2002d24, 0x38)
  updateSectionChestCountFromByteAndFlag(segment, "@Crenel Minish Hole/Minish Hole", 0x2002d28, 0x01)

  --CASTOR WILDS
  updateSectionChestCountFromByteAndFlag(segment, "@Platform Chest/Platform Chest", 0x2002cbd, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Wilds Diving Spots/Top", 0x2002cc0, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Wilds Diving Spots/Middle", 0x2002cc0, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Wilds Diving Spots/Bottom", 0x2002cc0, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Mulldozers/Bow Chest", 0x2002cde, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Mulldozers Open/Bow Chest", 0x2002cde, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Wilds Northern Minish Crack/Minish Crack", 0x2002cde, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Wilds Western Minish Crack/Minish Crack", 0x2002cde, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Wilds Vine Minish Crack/Minish Crack", 0x2002cde, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Mulldozers Open/Left Crack", 0x2002cf0, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Castor Wilds Mitts Cave/Castor Wilds Mitts Cave", 0x2002d04, 0x03)
  updateSectionChestCountFromByteAndFlag(segment, "@South Lake Cave/South Lake Cave", 0x2002d22, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@North Cave/North Cave", 0x2002d22, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Northeast Lake Cave/Northeast Lake Cave", 0x2002d23, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Darknut/Darknut", 0x2002d23, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Swiftblade the First/Heart Piece", 0x2002d2b, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Wilds Water Minish Hole/Hiking is Healthy", 0x2002d2c, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Wilds Water Minish Hole/Hiking Trip", 0x2002d2c, 0x20)

  --WIND RUINS
  updateSectionChestCountFromByteAndFlag(segment, "@Armos Kill/Armos", 0x2002cc2, 0x18)
  updateSectionChestCountFromByteAndFlag(segment, "@Pre FOW Chest/Pre FOW Chest", 0x2002cd2, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@4 Pillars Chest/4 Pillars Chest", 0x2002cd4, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Hole/Minish Hole", 0x2002cde, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Crack/Chest", 0x2002cf0, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Wind Ruins Beanstalk/Beanstalk", 0x2002d0c, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Bombable Wall/Bombable Wall", 0x2002d22, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Wall Hole/Minish Wall Hole Heart Piece", 0x2002d2b, 0x40)

  --VALLEY
  updateSectionChestCountFromByteAndFlag(segment, "@Lost Woods Secret Chest/Left Left Left Up Up Up", 0x2002cc7, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Northwest Grave Area/Nearby Chest", 0x2002cd3, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Northeast Grave Area/Nearby Chest", 0x2002cd3, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Dampe/Dampe", 0x2002ce9, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@Great Fairy/Great Fairy", 0x2002cef, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Royal Crypt/King Gustaf", 0x2002d02, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Royal Crypt/Left Path", 0x2002d12, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Royal Crypt/Right Path", 0x2002d12, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Royal Crypt/Gibdos", 0x2002d14, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Royal Crypt/Other Gibdos", 0x2002d14, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Northwest Grave Area/Northwest Grave", 0x2002d27, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Northwest Grave/Northwest Grave", 0x2002d27, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Northeast Grave Area/Northeast Grave", 0x2002d27, 0x40)

  --TRILBY
  updateSectionChestCountFromByteAndFlag(segment, "@Trilby Business Scrub/Trilby Business Scrub", 0x2002ca7, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Northern Chest/Chest", 0x2002cd2, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Rocks Chest/Rocks Chest", 0x2002cd3, 0x10)
  updateDigCave(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@Trilby Highlands Fusion Cave/Fusion Digging Cave", 0x2002d05, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Trilby Highlands Bomb Wall/Trilby Highlands Bomb Wall", 0x2002d1d, 0x20)
  updateTrilbyRupees(segment)

  --WESTERN WOOD
  updateNorthDigging(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@South Digging Spots/More Buried Treasure", 0x2002ccf, 0x06)
  updateSectionChestCountFromByteAndFlag(segment, "@Western Wood Chest/Freestanding Chest",0x2002ccf, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Percy's House/Percy Reward", 0x2002ce3, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Percy's House/Moblin Reward", 0x2002ce4, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Western Woods Tree/Heart Piece", 0x2002cef, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Western Woods Beanstalk/Beanstalk", 0x2002d0d, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Western Woods Beanstalk Rupee/Beanstalk", 0x2002d0d, 0x08)
  updateWestWoodsRupees(segment)

  --GARDENS
  updateSectionChestCountFromByteAndFlag(segment, "@Moat/Moat", 0x2002cbe, 0x0c)
  updateSectionChestCountFromByteAndFlag(segment, "@Grimblade/Heart Piece", 0x2002d2c, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Gardens Right Fountain/Dry Fountain", 0x2002d0e, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Gardens Right Fountain/Minish Hole", 0x2002d28, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Gardens Left Fountain/Minish Hole", 0x2002d28, 0x20)

  --NORTH FIELD
  updateSectionChestCountFromByteAndFlag(segment, "@North Field Digging Spot/North Field Digging Spot", 0x2002ccd, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Pre Royal Valley Chest/Chest", 0x2002cd3, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Top Left Tree/Top Left Tree", 0x2002d1c, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Top Right Tree/Top Right Tree", 0x2002d1c, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Bottom Left Tree/Bottom Left Tree", 0x2002d1c, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Bottom Right Tree/Bottom Right Tree", 0x2002d1c, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@4 Trees Done/Center Ladder", 0x2002d1d, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@North Field Cave Heart Piece/North Field Cave Heart Piece", 0x2002d2b, 0x08)

  --HYRULE TOWN
  updateSectionChestCountFromByteAndFlag(segment, "@Eastern Shops/Simon's Simulations", 0x2002c9c, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@Anju/Heart Piece", 0x2002ca5, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Hearth Ledge/Hearth Ledge", 0x2002cd5, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@School/Roof Chest", 0x2002cd5, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@Bell/Bell", 0x2002cd5, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Lady Next to Cafe/Lady Next to Cafe", 0x2002cd6, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Hearth/Hearth Right Pot", 0x2002ce0, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Stockwell's Shop/Dog Food Bottle Spot", 0x2002ce6, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Stockwell's Shop/Wallet Spot (80 Rupees)", 0x2002ce6, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Stockwell's Shop/Quiver Spot (600 Rupees)", 0x2002ce6, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Library/Yellow Library Minish", 0x2002ceb, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Eastern Shops/Figurine House Heart Piece", 0x2002cf2, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Eastern Shops/Figurine House", 0x2002cf2, 0xe0)
  updateSectionChestCountFromByteAndFlag(segment, "@Hearth/Hearth Back Door Heart Piece", 0x2002cf3, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Hearth Back Door Heart Piece/Hearth Back Door Heart Piece", 0x2002cf3, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@School/Pull the Statue", 0x2002cfc, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Town Digging Cave/Town Basement Left", 0x2002cfc, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Mayor's House Basement/Mayor's House Basement", 0x2002cfd, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Hyrule Well/Hyrule Well Bottom Chest", 0x2002cfd, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@Hyrule Well/Hyrule Well Center Chest", 0x2002cfd, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Fountain/Mulldozers", 0x2002cfd, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Fountain/Small Chest", 0x2002cfe, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Flippers Cave Rupees/Under the Waterfall", 0x2002cfe, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Flippers Cave/Scissor Beetles", 0x2002cfe, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Flippers Cave Rupees/Scissor Beetles", 0x2002cfe, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Flippers Cave/Frozen Chest", 0x2002cfe, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Flippers Cave Rupees/Frozen Chest", 0x2002cfe, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Town Digging Cave/Cave Chests", 0x2002d04, 0x1c)
  updateSectionChestCountFromByteAndFlag(segment, "@Stockwell's Shop/Attic Chest", 0x2002d0a, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@School Gardens/Heart Piece", 0x2002d0b, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@School Gardens Open/Heart Piece", 0x2002d0b, 0x40)
  updateSchoolyard(segment)
  updateSchoolyardOpen(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@School Gardens Open/Minish Path Chest", 0x2002d11, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Bakery Attic Chest/Bakery Attic Chest", 0x2002d13, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Fountain/Heart Piece", 0x2002d14, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Town Waterfall/Waterfall", 0x2002d1d, 0x40)

  --SOUTH FIELD
  updateSectionChestCountFromByteAndFlag(segment, "@Tingle/Tingle", 0x2002ca3, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Near Link's House Chest/Chest", 0x2002cd3, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@Smith's House/Intro Items", 0x2002cde, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Tree Heart Piece/Tree Heart Piece", 0x2002cee, 0x80)
  updateSouthRupees(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Flippers Hole/Minish Flippers Hole", 0x2002d2c, 0x02)

  --VEIL FALLS
  updateSectionChestCountFromByteAndFlag(segment, "@Upper Veil Falls Heart Piece/Upper Heart Piece", 0x2002cd0, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Source of the Flow Cave/Bombable Wall Second Chest", 0x2002cd0, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@South Veil Falls Rupees/Rupees", 0x2002cd0, 0x1c)
  updateSectionChestCountFromByteAndFlag(segment, "@Upper Veil Falls Rocks/Left Digging Spot", 0x2002cd0, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Lower Veil Falls Heart Piece/Lower Heart Piece", 0x2002cd1, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@Upper Veil Falls Rocks/Right Chest", 0x2002cd3, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Veil Falls Rock Chest/Veil Falls Chest", 0x2002cd3, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Veil Falls South Digging Spot/South Digging Spot", 0x2002cda, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Fusion Digging Cave/Chest", 0x2002d05, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Veil Falls South Mitts Cave/Veil Falls South Mitts Cave", 0x2002d05, 0x18)
  updateSectionChestCountFromByteAndFlag(segment, "@Fusion Digging Cave/Heart Piece", 0x2002d05, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Veil Falls Upper Cave/Freestanding Chest", 0x2002d25, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Veil Falls Upper Cave Rupees/Freestanding Chest", 0x2002d25, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Veil Falls Upper Cave/Bomb Wall Chest", 0x2002d25, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Veil Falls Upper Cave Rupees/Bomb Wall Chest", 0x2002d25, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Source of the Flow Cave/Bombable Wall First Chest", 0x2002d25, 0x10)
  updateUpperCaveRupees(segment)
  updateUpperCaveDivingRupees(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@Veil Falls Upper Waterfall/Waterfall Heart Piece", 0x2002d27, 0x10)

  --LON LON RANCH
  updateSectionChestCountFromByteAndFlag(segment, "@Lon Lon North Heart Piece/Lon Lon North Heart Piece", 0x2002ccb, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Lon Lon Ranch Digging Spot/Digging Spot Above Tree", 0x2002ccb, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@North Ranch Chest/Chest", 0x2002cd3, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Malon's Pot/Malon's Pot", 0x2002ce5, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Lon Lon Minish Crack/Lon Lon Minish Crack", 0x2002cf2, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Bonk the Tree Open/Minish Path Chest", 0x2002d11, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@Bonk the Tree Open/Minish Path Heart Piece", 0x2002d13, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Bonk the Tree/Minish Path Heart Piece", 0x2002d13, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Lon Lon Cave/Lon Lon Cave", 0x2002d1d, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Lon Lon Cave/Hidden Bomb Wall", 0x2002d1e, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Lon Lon Dried Up Pond/Lon Lon Pond", 0x2002d1e, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Goron Quest/Big Chest", 0x2002d2a, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Goron Quest/Small Chest", 0x2002d2a, 0x80)

  --EASTERN HILLS
  updateSectionChestCountFromByteAndFlag(segment, "@Farm Chest/Farm Chest", 0x2002cd2, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Farm Rupee/Farm Rupee", 0x2002d04, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Eastern Hills Beanstalk/Beanstalk Heart Piece", 0x2002d0d, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Eastern Hills Beanstalk/Beanstalk Chests", 0x2002d0d, 0x06)
  updateSectionChestCountFromByteAndFlag(segment, "@Eastern Hills Bombable Wall/Eastern Hills Bomb Wall", 0x2002d22, 0x08)

  --LAKE HYLIA
  updateSectionChestCountFromByteAndFlag(segment, "@Hylia Cape Heart Piece/Cape Heart Piece", 0x2002cbd, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Pond Heart Piece/Diving for Love", 0x2002cbd, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@Hylia Southern Heart Piece/Hylia Southern Heart Piece", 0x2002cbd, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Librari/Librari", 0x2002cf2, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Middle of the Lake/Digging Cave", 0x2002d02, 0x40)
  updateNorthHyliaCapeCave(segment)
  updateTreasureCave(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@Treasure Cave/Beanstalk Heart Piece", 0x2002d0c, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Treasure Cave/Beanstalk", 0x2002d0c, 0x60)
  updateSectionChestCountFromByteAndFlag(segment, "@Lake Cabin Open/Chest", 0x2002d11, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@North Minish Hole/North Minish Hole", 0x2002d2a, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Waveblade/Heart Piece", 0x2002d2c, 0x04)

  --MINISH WOODS
  updateSectionChestCountFromByteAndFlag(segment, "@Northern Heart Piece/Northern Heart Piece", 0x2002cc3, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Shrine Heart Piece/Shrine Heart Piece", 0x2002cc3, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Cross the Pond/Chest", 0x2002cd2, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Woods Pre Stump Chest/Chest", 0x2002cd2, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Pre Shrine Chest/Pre Shrine Chest", 0x2002cd2, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Woods Entrance Chest/Chest", 0x2002cd3, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Post Minish Village Chest/Wind Crest Chest", 0x2002cdb, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Woods Great Fairy/Minish Woods Great Fairy", 0x2002cef, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Pre Minish Village Minish Hole/Minish Hole", 0x2002cf0, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Belari Open/Belari 2nd Item", 0x2002cf2, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Village/Dock Heart Piece", 0x2002cf4, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Village Open/Dock Heart Piece", 0x2002cf4, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Village/Barrel", 0x2002cf5, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Village Open/Barrel", 0x2002cf5, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Woods North Digging Cave/Minish Woods North Digging Cave", 0x2002d02, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Like Like Cave/Like Like Cave", 0x2002d02, 0x30)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Village Open/Minish Path Chest", 0x2002d11, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Woods North Minish Hole/Minish Woods North Minish Hole", 0x2002d28, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Flippers Cave/Middle", 0x2002d2a, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Flippers Cave/Right", 0x2002d2a, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Flippers Cave/Left", 0x2002d2a, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Flippers Cave/Left Heart Piece", 0x2002d2b, 0x04)

  --CLOUD TOPS
  updateSectionChestCountFromByteAndFlag(segment, "@Right Chest/Right Chest", 0x2002cd7, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Center Left/Center Left", 0x2002cd7, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Top Left South Chest/Top Left South Chest", 0x2002cd7, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Top Left North Chests/Top Left North Chests", 0x2002cd7, 0xc0)
  updateSectionChestCountFromByteAndFlag(segment, "@Top Left North Chests Obscure/Top Left North Chests", 0x2002cd7, 0xc0)
  updateSectionChestCountFromByteAndFlag(segment, "@Bottom Left Chest/Bottom Left Chest", 0x2002cd8, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Center Right/Center Right", 0x2002cd8, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@Top Left North Chests Obscure/Digging Spot on the Left", 0x2002cd8, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Top Right Digging Spot/Digging Spot", 0x2002cd8, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@Center Digging Spot/Digging Spot", 0x2002cd8, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Southeast North Digging Spot/Digging Spot", 0x2002cd8, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Bottom Left Digging Spot/Digging Spot", 0x2002cd8, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@South Digging Spot/Digging Spot", 0x2002cd8, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@Southeast South Digging Spot/Digging Spot", 0x2002cd9, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Kill Piranhas (North)/Kill Piranhas", 0x2002cda, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@Kill Piranhas (South)/Kill Piranhas", 0x2002cda, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Wind Tribe House Open/Early House Chests", 0x2002cdc, 0xe0)
  updateSectionChestCountFromByteAndFlag(segment, "@Wind Tribe House Open/Later House Chests", 0x2002cdd, 0xc7)
  updateSectionChestCountFromByteAndFlag(segment, "@Wind Tribe House Open/Save Gregal", 0x2002ce8, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Wind Tribe House Open/Gregal's Gift", 0x2002ce8, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Wind Tribe House/Save Gregal", 0x2002ce8, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@Wind Tribe House/Gregal's Gift", 0x2002ce8, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Wind Tribe House/House Chests", 0x2002cdd, 0xc7)

  --DWS
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/Madderpillar Chest", 0x2002d3f, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/Puffstool Room", 0x2002d40, 0x0c)
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/Two Lamp Chest", 0x2002d40, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/Two Statue Room", 0x2002d40, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/West Side Big Chest", 0x2002d41, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/Barrel Room Northwest", 0x2002d41, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/Mulldozer Key", 0x2002d42, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/Slug Room", 0x2002d43, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/Basement Big Chest", 0x2002d43, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/Basement Switch Chest", 0x2002d44, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/Basement Switch Room Big Chest", 0x2002d44, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/Green Chu", 0x2002d44, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/Upstairs Chest", 0x2002d45, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/Blue Warp Heart Piece", 0x2002d45, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@DWS/Madderpillar Heart Piece", 0x2002d46, 0x04)

  --COF
  updateSectionChestCountFromByteAndFlag(segment, "@COF/Spiny Chu Pillar Chest", 0x2002d57, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@COF/Spiny Chu Fight", 0x2002d57, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@COF/First Rollobite Room", 0x2002d58, 0xc0)
  updateSectionChestCountFromByteAndFlag(segment, "@COF/Pre Lava Basement Room", 0x2002d59, 0x30)
  updateSectionChestCountFromByteAndFlag(segment, "@COF/Big Chest Room", 0x2002d59, 0x06)
  updateSectionChestCountFromByteAndFlag(segment, "@COF/Blade Chest", 0x2002d5a, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@COF/Spiny Beetle Fight", 0x2002d5a, 0x04)
  updateCOFChests(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@COF/Lava Basement Big Chest", 0x2002d5b, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@COF/Gleerok", 0x2002d5b, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@COF/Bombable Wall Heart Piece", 0x2002d5b, 0x10)

  updateSectionChestCountFromByteAndFlag(segment, "@COF Rupees/Spiny Chu Pillar Chest", 0x2002d57, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@COF Rupees/Spiny Chu Fight", 0x2002d57, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@COF Rupees/First Rollobite Room", 0x2002d58, 0xc0)
  updateSectionChestCountFromByteAndFlag(segment, "@COF Rupees/Pre Lava Basement Room", 0x2002d59, 0x30)
  updateSectionChestCountFromByteAndFlag(segment, "@COF Rupees/Big Chest Room", 0x2002d59, 0x06)
  updateSectionChestCountFromByteAndFlag(segment, "@COF Rupees/Blade Chest", 0x2002d5a, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@COF Rupees/Spiny Beetle Fight", 0x2002d5a, 0x04)
  updateCOFChestsRupees(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@COF Rupees/Lava Basement Big Chest", 0x2002d5b, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@COF Rupees/Gleerok", 0x2002d5b, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@COF Rupees/Bombable Wall Heart Piece", 0x2002d5b, 0x10)
  updateCOFRupees(segment)

  --FOW
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Entrance Far Left", 0x2002d05, 0x80)
  updateFOWLeftMitts(segment)
  updateFOWRightMitts(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Center Path Switch", 0x2002d06, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Bombable Wall Big Chest", 0x2002d08, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Bombable Wall Small Chest", 0x2002d08, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Minish Dirt Room Key Drop", 0x2002d08, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Eyegores", 0x2002d6f, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Clone Puzzle Key Drop", 0x2002d71, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Mazaal", 0x2002d72, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Pedestal Chest", 0x2002d73, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Skull Room Chest", 0x2002d73, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Right Side Two Lever Room", 0x2002d73, 0x60)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Left Side Key Drop", 0x2002d73, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Right Side Key Drop", 0x2002d74, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Wizzrobe Fight", 0x2002d74, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/FOW Reward", 0x2002d74, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW/Right Side Heart Piece", 0x2002d74, 0x80)

  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Entrance Big Rupee", 0x2002d05, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Entrance Far Left", 0x2002d05, 0x80)
  updateFOWLeftMittsRupees(segment)
  updateFOWRightMittsRupees(segment)
  updateFOWRupees(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Center Path Switch", 0x2002d06, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Bombable Wall Big Chest", 0x2002d08, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Bombable Wall Small Chest", 0x2002d08, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Minish Dirt Room Key Drop", 0x2002d08, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Eyegores", 0x2002d6f, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Clone Puzzle Key Drop", 0x2002d71, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Mazaal", 0x2002d72, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Pedestal Chest", 0x2002d73, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Skull Room Chest", 0x2002d73, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Right Side Two Lever Room", 0x2002d73, 0x60)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Left Side Key Drop", 0x2002d73, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Right Side Key Drop", 0x2002d74, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Wizzrobe Fight", 0x2002d74, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/FOW Reward", 0x2002d74, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Rupees/Right Side Heart Piece", 0x2002d74, 0x80)

  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Entrance Far Left", 0x2002d05, 0x80)
  updateFOWLeftMittsObscure(segment)
  updateFOWRightMittsObscure(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Center Path Switch", 0x2002d06, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Right Side Moldorm Pots", 0x2002d06, 0x18)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Bombable Wall Big Chest", 0x2002d08, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Bombable Wall Small Chest", 0x2002d08, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Minish Dirt Room Key Drop", 0x2002d08, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Eyegores", 0x2002d6f, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Clone Puzzle Key Drop", 0x2002d71, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Mazaal", 0x2002d72, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Pedestal Chest", 0x2002d73, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Skull Room Chest", 0x2002d73, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Right Side Two Lever Room", 0x2002d73, 0x60)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Left Side Key Drop", 0x2002d73, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Right Side Key Drop", 0x2002d74, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Wizzrobe Fight", 0x2002d74, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/FOW Reward", 0x2002d74, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW Obscure/Right Side Heart Piece", 0x2002d74, 0x80)

  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Entrance Large Rupee", 0x2002d05, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Entrance Far Left", 0x2002d05, 0x80)
  updateFOWLeftMittsRupObs(segment)
  updateFOWRightMittsRupObs(segment)
  updateFOWRupeesObs(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Center Path Switch", 0x2002d06, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Right Side Moldorm Pots", 0x2002d06, 0x18)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Bombable Wall Big Chest", 0x2002d08, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Bombable Wall Small Chest", 0x2002d08, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Minish Dirt Room Key Drop", 0x2002d08, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Eyegores", 0x2002d6f, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Clone Puzzle Key Drop", 0x2002d71, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Mazaal", 0x2002d72, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Pedestal Chest", 0x2002d73, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Skull Room Chest", 0x2002d73, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Right Side Two Lever Room", 0x2002d73, 0x60)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Left Side Key Drop", 0x2002d73, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Right Side Key Drop", 0x2002d74, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Wizzrobe Fight", 0x2002d74, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/FOW Reward", 0x2002d74, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@FOW RupObs/Right Side Heart Piece", 0x2002d74, 0x80)

  --TOD
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/Right Path Ice Walkway Chests", 0x2002d8b, 0x05)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/Overhang Chest", 0x2002d8b, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/Octo", 0x2002d8c, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/Blue Chu", 0x2002d8c, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/Basement Frozen Chest", 0x2002d8d, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/Small Key Locked Ice Block", 0x2002d8d, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/First Ice Block", 0x2002d8e, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/Ice Puzzle Frozen Chest", 0x2002d8f, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/Ice Puzzle Free Chest", 0x2002d8f, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/Dark Maze", 0x2002d8f, 0xe0)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/Dark Maze Bomb Wall", 0x2002d91, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/Post Blue Chu Frozen Chest", 0x2002d92, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/Post Madderpillar Chest", 0x2002d92, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/Underwater Pot", 0x2002d93, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD/Post Ice Puzzle Frozen Chest", 0x2002d93, 0x40)

  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Right Path Ice Walkway Chests", 0x2002d8b, 0x05)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Overhang Chest", 0x2002d8b, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Octo", 0x2002d8c, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Blue Chu", 0x2002d8c, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Basement Frozen Chest", 0x2002d8d, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Small Key Locked Ice Block", 0x2002d8d, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/First Ice Block", 0x2002d8e, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Ice Puzzle Frozen Chest", 0x2002d8f, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Ice Puzzle Free Chest", 0x2002d8f, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Dark Maze", 0x2002d8f, 0xe0)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Dark Maze Bomb Wall", 0x2002d91, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Post Blue Chu Frozen Chest", 0x2002d92, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Post Madderpillar Chest", 0x2002d92, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Underwater Pot", 0x2002d93, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Post Ice Puzzle Frozen Chest", 0x2002d93, 0x40)
  updateTODOverhangRupees(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Rupees/Right Path Rupees", 0x2002d95, 0x7c)
  updateTODLowerRupees(segment)
  updateTODUpperRupees(segment)

  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Right Path Ice Walkway Chests", 0x2002d8b, 0x05)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Right Path Ice Walkway Pot", 0x2002d8b, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Overhang Chest", 0x2002d8b, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Octo", 0x2002d8c, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Blue Chu", 0x2002d8c, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Basement Frozen Chest", 0x2002d8d, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Small Key Locked Ice Block", 0x2002d8d, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/First Ice Block", 0x2002d8e, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Ice Puzzle Frozen Chest", 0x2002d8f, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Ice Puzzle Free Chest", 0x2002d8f, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Dark Maze", 0x2002d8f, 0xe0)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Dark Maze Bomb Wall", 0x2002d91, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Post Blue Chu Frozen Chest", 0x2002d92, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Post Madderpillar Chest", 0x2002d92, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Underwater Pot", 0x2002d93, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD Obscure/Post Ice Puzzle Frozen Chest", 0x2002d93, 0x40)

  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Right Path Ice Walkway Chests", 0x2002d8b, 0x05)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Right Path Ice Walkway Pot", 0x2002d8b, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Overhang Chest", 0x2002d8b, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Octo", 0x2002d8c, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Blue Chu", 0x2002d8c, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Basement Frozen Chest", 0x2002d8d, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Small Key Locked Ice Block", 0x2002d8d, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/First Ice Block", 0x2002d8e, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Ice Puzzle Frozen Chest", 0x2002d8f, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Ice Puzzle Free Chest", 0x2002d8f, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Dark Maze", 0x2002d8f, 0xe0)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Dark Maze Bomb Wall", 0x2002d91, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Post Blue Chu Frozen Chest", 0x2002d92, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Post Madderpillar Chest", 0x2002d92, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Underwater Pot", 0x2002d93, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Post Ice Puzzle Frozen Chest", 0x2002d93, 0x40)
  updateTODOverhangRupeesObs(segment)
  updateSectionChestCountFromByteAndFlag(segment, "@TOD RupObs/Right Path Rupees", 0x2002d95, 0x7c)
  updateTODLowerRupeesObs(segment)
  updateTODUpperRupeesObs(segment)

  --POW
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Pre Big Key Door Big Chest", 0x2002da2, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Bombarossa Maze", 0x2002da2, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Block Maze Detour", 0x2002da2, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Spark Chest", 0x2002da3, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Flail Soldiers", 0x2002da4, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Moblin Archer Chest", 0x2002da4, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Block Maze Room", 0x2002da5, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Switch Chest", 0x2002da5, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Fire Wizzrobe Fight", 0x2002da6, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Pot Puzzle Key", 0x2002da7, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Twin Wizzrobe Fight", 0x2002da9, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Roller Chest", 0x2002da9, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Wizzrobe Platform Fight", 0x2002daa, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Firebar Grate", 0x2002daa, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Dark Room Big", 0x2002dab, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Dark Room Small", 0x2002dab, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Gyorg", 0x2002dab, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@POW/Heart Piece", 0x2002dac, 0x01)

  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Pre Big Key Door Big Chest", 0x2002da2, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Bombarossa Maze", 0x2002da2, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Block Maze Detour", 0x2002da2, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Spark Chest", 0x2002da3, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Flail Soldiers", 0x2002da4, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Moblin Archer Chest", 0x2002da4, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Block Maze Room", 0x2002da5, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Switch Chest", 0x2002da5, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Fire Wizzrobe Fight", 0x2002da6, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Pot Puzzle Key", 0x2002da7, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Rupees", 0x2002da7, 0x7c)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Twin Wizzrobe Fight", 0x2002da9, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Roller Chest", 0x2002da9, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Wizzrobe Platform Fight", 0x2002daa, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Firebar Grate", 0x2002daa, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Dark Room Big", 0x2002dab, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Dark Room Small", 0x2002dab, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Gyorg", 0x2002dab, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@POW Rupees/Heart Piece", 0x2002dac, 0x01)

  --DHC
  updateSectionChestCountFromByteAndFlag(segment, "@DHC/Vaati", 0x2002ca6, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC/Northwest Tower", 0x2002dbb, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC/Northeast Tower", 0x2002dbb, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC/Southwest Tower", 0x2002dbc, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC/Southeast Tower", 0x2002dbc, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC/Big Block Chest", 0x2002dbc, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC/Post Throne Big Chest", 0x2002dbf, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC/Blade Chest", 0x2002dc0, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC/Platform Chest", 0x2002dc1, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC/Stone King", 0x2002cd2, 0x02)

  updateSectionChestCountFromByteAndFlag(segment, "@DHC Open/Vaati", 0x2002ca6, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Open/Northwest Tower", 0x2002dbb, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Open/Northeast Tower", 0x2002dbb, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Open/Southwest Tower", 0x2002dbc, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Open/Southeast Tower", 0x2002dbc, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Open/Big Block Chest", 0x2002dbc, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Open/Post Throne Big Chest", 0x2002dbf, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Open/Blade Chest", 0x2002dc0, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Open/Platform Chest", 0x2002dc1, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Open/Stone King", 0x2002cd2, 0x02)

  updateSectionChestCountFromByteAndFlag(segment, "@DHC Ped/Vaati", 0x2002ca6, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Ped/Northwest Tower", 0x2002dbb, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Ped/Northeast Tower", 0x2002dbb, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Ped/Southwest Tower", 0x2002dbc, 0x01)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Ped/Southeast Tower", 0x2002dbc, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Ped/Big Block Chest", 0x2002dbc, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Ped/Post Throne Big Chest", 0x2002dbf, 0x80)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Ped/Blade Chest", 0x2002dc0, 0x20)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Ped/Platform Chest", 0x2002dc1, 0x08)
  updateSectionChestCountFromByteAndFlag(segment, "@DHC Ped/Stone King", 0x2002cd2, 0x02)

  updateSectionChestCountFromByteAndFlag(segment, "@Dark Hyrule Castle/Win", 0x2002ca6, 0x20)
end

function updateKeys(segment)
  if not isInGame() then
    return false
  end

  InvalidateReadCaches()

  if AUTOTRACKER_ENABLE_ITEM_TRACKING then
    updateToggleItemFromByteAndFlag(segment, "dws_bigkey", 0x2002ead, 0x04)
    updateToggleItemFromByteAndFlag(segment, "cof_bigkey", 0x2002eae, 0x04)
    updateToggleItemFromByteAndFlag(segment, "fow_bigkey", 0x2002eaf, 0x04)
    updateToggleItemFromByteAndFlag(segment, "tod_bigkey", 0x2002eb0, 0x04)
    updateToggleItemFromByteAndFlag(segment, "pow_bigkey", 0x2002eb1, 0x04)
    updateToggleItemFromByteAndFlag(segment, "explicit_dhc_bigkey", 0x2002eb2, 0x04)

    updateSmallKeys(segment, "dws_smallkey", 0x2002e9d)
    updateSmallKeys(segment, "cof_smallkey", 0x2002e9e)
    updateSmallKeys(segment, "fow_smallkey", 0x2002e9f)
    updateSmallKeys(segment, "tod_smallkey", 0x2002ea0)
    updateSmallKeys(segment, "pow_smallkey", 0x2002ea1)
    updateSmallKeys(segment, "explicit_dhc_smallkey", 0x2002ea2)
    updateSmallKeys(segment, "cryptkey", 0x2002ea3)

    updateSectionChestCountFromByteAndFlag(segment, "@Syrup's Hut/Witch's Item (60 Rupees)", 0x2002ea4, 0x04)
    updateSectionChestCountFromByteAndFlag(segment, "@Eastern Shops/Rem", 0x2002ea4, 0x08)
    updateSectionChestCountFromByteAndFlag(segment, "@Julietta's House/Bookshelf", 0x2002ea4, 0x10)
    updateSectionChestCountFromByteAndFlag(segment, "@Dr. Left's House/Dr. Left's House", 0x2002ea4, 0x20)
    updateSectionChestCountFromByteAndFlag(segment, "@Lake Cabin/Lake Cabin", 0x2002ea4, 0x40)
    updateSectionChestCountFromByteAndFlag(segment, "@Lake Cabin Open/Lake Cabin", 0x2002ea4, 0x40)
    updateSectionChestCountFromByteAndFlag(segment, "@Melari/Melari", 0x2002ea4, 0x80)
    updateSectionChestCountFromByteAndFlag(segment, "@Mines Obs/Melari", 0x2002ea4, 0x80)
    updateSectionChestCountFromByteAndFlag(segment, "@Melari Open/Melari", 0x2002ea4, 0x80)
    updateSectionChestCountFromByteAndFlag(segment, "@Mines/Melari", 0x2002ea4, 0x80)
    updateSectionChestCountFromByteAndFlag(segment, "@Belari/Belari", 0x2002ea5, 0x01)
    updateSectionChestCountFromByteAndFlag(segment, "@Belari Open/Belari", 0x2002ea5, 0x01)
    updateSectionChestCountFromByteAndFlag(segment, "@Carlov/Carlov", 0x2002ea5, 0x02)
    updateSectionChestCountFromByteAndFlag(segment, "@Crenel Business Scrub/Crenel Business Scrub", 0x2002ea5, 0x04)
    updateSectionChestCountFromByteAndFlag(segment, "@Swiftblade's Dojo/Spin Attack", 0x2002ea5, 0x10)
    updateSectionChestCountFromByteAndFlag(segment, "@Swiftblade's Dojo/Rock Breaker", 0x2002ea5, 0x20)
    updateSectionChestCountFromByteAndFlag(segment, "@Swiftblade's Dojo/Dash Attack", 0x2002ea5, 0x40)
    updateSectionChestCountFromByteAndFlag(segment, "@Swiftblade's Dojo/Down Thrust", 0x2002ea5, 0x80)
    updateSectionChestCountFromByteAndFlag(segment, "@Grayblade/Grayblade", 0x2002ea6, 0x01)
    updateSectionChestCountFromByteAndFlag(segment, "@Grimblade/Grimblade", 0x2002ea6, 0x02)
    updateSectionChestCountFromByteAndFlag(segment, "@Waveblade/Waveblade", 0x2002ea6, 0x04)
    updateSectionChestCountFromByteAndFlag(segment, "@Swiftblade the First/Swiftblade the First", 0x2002ea6, 0x08)
    updateSectionChestCountFromByteAndFlag(segment, "@Waterfall/Scarblade", 0x2002ea6, 0x10)
    updateSectionChestCountFromByteAndFlag(segment, "@Lower Veil Falls Waterfall/Splitblade", 0x2002ea6, 0x20)
    updateSectionChestCountFromByteAndFlag(segment, "@North Field Waterfall/Greatblade", 0x2002ea6, 0x40)
    updateSectionChestCountFromByteAndFlag(segment, "@Stockwell's Shop/Wallet Spot (80 Rupees)", 0x2002ea7, 0x01)
    updateSectionChestCountFromByteAndFlag(segment, "@Stockwell's Shop/Boomerang Spot (300 Rupees)", 0x2002ea7, 0x02)
    updateSectionChestCountFromByteAndFlag(segment, "@Stockwell's Shop/Quiver Spot (600 Rupees)", 0x2002ea7, 0x04)
    updateSectionChestCountFromByteAndFlag(segment, "@Wind Ruins Joy Butterfly/Joy Butterfly", 0x2002ea7, 0x08)
    updateSectionChestCountFromByteAndFlag(segment, "@Castor Wilds Joy Butterfly/Joy Butterfly", 0x2002ea7, 0x10)
    updateSectionChestCountFromByteAndFlag(segment, "@Royal Valley Joy Butterfly/Joy Butterfly", 0x2002ea7, 0x20)
    updateSectionChestCountFromByteAndFlag(segment, "@DHC Ped/Pedestal Two Elements", 0x2002ea7, 0x80)
    updateSectionChestCountFromByteAndFlag(segment, "@DHC Ped/Pedestal Three Elements", 0x2002ea8, 0x01)
    updateSectionChestCountFromByteAndFlag(segment, "@DHC Ped/Pedestal Four Elements", 0x2002ea8, 0x02)

  end

  if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    return true
  end
end

ScriptHost:AddMemoryWatch("TMC Item Data", 0x2002b30, 0x45, updateItemsFromMemorySegment)
ScriptHost:AddMemoryWatch("TMC Item Upgrades", 0x2002ae4, 0x0c, updateGearFromMemory)
ScriptHost:AddMemoryWatch("TMC Locations and Bosses", 0x2002c81, 0x200, updateLocations)
ScriptHost:AddMemoryWatch("TMC Keys", 0x2002e9d, 0x16, updateKeys)
