function runScript(script)
  if not os.run({}, script) then
    print("Script \"" .. script .. "\" failed!  Rebooting in 10 secs.")
    sleep(10)
    return os.reboot()
  end
end

function init()
  fs.delete(".update-reboot")
  runScript("update")
  if fs.exists(".update-reboot") then
    print("Startup scripts modified!  Rebooting in 3 secs.")
    sleep(3)
    return os.reboot()
  end
  runScript("cleanup")
end

function main()
  init()
  os.loadAPI("apis/party")
end

main()
