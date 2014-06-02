function get(file)
  local response = http.get("http://localhost:3000/update/file?path=" .. file)
  if response then
    local fh = fs.open(file, "w")
    fh.writeLine(response.readAll())
    fh.close()
  else
    print("Failed to retrieve " .. file)
  end
end

fs.makeDir("apis")
get("apis/sha1")
get("apis/json")
get("update")

if os.run({}, "update") then
  print "Bootstrap successful.  Rebooting in 5 seconds."
  sleep(5)
  os.reboot()
else
  print "Bootstrap failed!"
end
