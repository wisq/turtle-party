os.loadAPI("apis/json")

function checkin()
  local data = {
    id    = os.getComputerID(),
    label = os.getComputerLabel(),
    dev_type = getDeviceType()
  }
  local json = json.encode(data)

  if http.post("http://localhost:3000/party/checkin", json) then
    print "checked in"
  else
    print "checkin failed"
  end
end

function getDeviceType()
  if turtle then
    return "turtle"
  else
    return "computer"
  end
end
