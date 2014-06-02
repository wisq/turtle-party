os.loadAPI("apis/json")

function main()
  checkin()

  while true do
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

  local data_out = json.decode(response.readAll())
  local task = data_out['task']

  if task == 'standby' then
    local seconds = tonumber(data_out['seconds'])
    print("Standing by for " .. seconds .. " seconds.")
    sleep(seconds)
  end
end

function getDeviceType()
  if turtle then
    return "turtle"
  else
    return "computer"
  end
end
