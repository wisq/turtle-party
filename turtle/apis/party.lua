os.loadAPI("apis/json")

function main()
  checkin()

  while true do
    check_for_updates()
    do_task()
  end
end

function checkin()
  local data_in = {
    id    = os.getComputerID(),
    label = os.getComputerLabel(),
    dev_type = getDeviceType()
  }
  local response = http.post("http://localhost:3000/party/checkin", json.encode(data_in))

  if not response then
    error "Checkin failed!"
  end

  local data_out = json.decode(response.readAll())
  local new_label = data_out['label']
  if new_label and new_label ~= os.getComputerLabel() then
    os.setComputerLabel(new_label)
    print("Set label to '" .. new_label .. "'.")
  end
  print "Checked in."
end

function do_task()
  local data_in = {id = os.getComputerID()}
  local response = http.post("http://localhost:3000/party/next_task", json.encode(data_in))

  if not response then
    error "Failed to retrieve next task!"
  end

  local json_out = response.readAll()
  local data_out = json.decode(json_out)
  local task = data_out['task']

  if task == 'standby' then
    local seconds = tonumber(data_out['seconds'])
    print("Standing by for " .. seconds .. " seconds.")
    sleep(seconds)
  else
    error("Unknown task: " .. json_out)
  end
end

function check_for_updates()
  local response = http.get("http://localhost:3000/update/check/" .. getVersion())

  if not response then
    print("Update check failed.")
  elseif response.readAll() == "OKAY" then
    -- nothing to do
  else
    print("Update needed!  Rebooting in 3 seconds.")
    sleep(3)
    os.reboot()
  end
end

function getDeviceType()
  if turtle then
    return "turtle"
  else
    return "computer"
  end
end

function getVersion()
  local fh = fs.open(".version", "r")
  local version = fh.readAll()
  fh.close()
  return version
end
