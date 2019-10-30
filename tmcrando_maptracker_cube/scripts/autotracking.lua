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

function updateSectionChestCountFromByteAndFlag(segment, locationRef, address, flag, callback)
    local location = Tracker:FindObjectForCode(locationRef)
    if location then
        -- Do not auto-track this the user has manually modified it
        if location.Owner.ModifiedByUser then
            return
        end

        local value = ReadU8(segment, address)

        if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
            print(locationRef, value)
        end

        if (value & flag) ~= 0 then
            location.AvailableChestCount = 0
            if callback then
                callback(true)
            end
        else
            location.AvailableChestCount = location.ChestCount
            if callback then
                callback(false)
            end
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
    BOW_VALUE = 2
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

  updateSectionChestCountFromByteAndFlag(segment, "@Eastern Shops/Simon's Simulations", 0x2002c9c, 0x02)
  updateSectionChestCountFromByteAndFlag(segment, "@Tingle/Tingle", 0x2002ca3, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Shrine Heart Piece/Shrine Heart Piece", 0x2002cc3, 0x10)
  updateSectionChestCountFromByteAndFlag(segment, "@Lady Next to Cafe/Lady Next to Cafe", 0x2002cd6, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Smith's House/Intro Items", 0x2002cde, 0x40)
  updateSectionChestCountFromByteAndFlag(segment, "@Minish Village/Barrel", 0x2002cf5, 0x04)
  updateSectionChestCountFromByteAndFlag(segment, "@Grimblade/Heart Piece", 0x2002d2c, 0x08)
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

  end

  if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    return true
  end
end

ScriptHost:AddMemoryWatch("TMC Item Data", 0x2002b30, 0x45, updateItemsFromMemorySegment)
ScriptHost:AddMemoryWatch("TMC Item Upgrades", 0x2002ae8, 0x08, updateGearFromMemory)
ScriptHost:AddMemoryWatch("TMC Locations and Bosses", 0x2002c81, 0x200, updateLocations)
ScriptHost:AddMemoryWatch("TMC Keys", 0x2002e9d, 0x22, updateKeys)
