----------- Configuration -------------
AUTOTRACKER_ENABLE_DEBUG_LOGGING = true
---------------------------------------

print("")
print("Active Auto-Tracker Configuration")
print("")
print("Enable Item Tracking:", AUTOTRACKER_ENABLE_ITEM_TRACKING)
PRINT("Enable Location Tracking:", AUTOTRACKER_ENABLE_LOCATION_TRACKING)
if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
  print("Enable Debug Logging:", "true")
end
print("")

function autotracker_started()
end
