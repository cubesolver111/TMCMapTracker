-- Configuration ----------------------
TMC_AUTOTRACKER_DEBUG = true
---------------------------------------

print("")
print("Active Auto-Tracker Configuration")
print("")
if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
  print("Enable Debug Logging:", "true")
end
print("")

function checkReset(segment)
  print("reloading everything...")
end

ScriptHost:AddMemoryWatch("Full reset check",          0xC600, 0x500, checkReset)
