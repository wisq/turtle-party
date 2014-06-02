os.loadAPI("apis/json")

function checkin()
  local data_in = {
    id    = os.getComputerID(),
    label = os.getComputerLabel(),
    dev_type = getDeviceType()
  }
  local response = http.post("http://localhost:3000/party/checkin", json.encode(data_in))

  if response then
    local data_out = json.decode(response.readAll())

    local new_label = data_out['label']
    if new_label and new_label ~= os.getComputerLabel() then
      os.setComputerLabel(new_label)
      print("Set label to '" .. new_label .. "'.")
    end
    print "Checked in."
  else
    error "Checkin failed!"
  end
end

function getDeviceType()
  if turtle then
    return "turtle"
  else
    return "computer"
  end
end
