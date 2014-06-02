-- Note: Do not use fs.getSize() anywhere here.
-- I'm not sure if this is platform-dependent or what, but it seems
-- my (Linux) server and (Mac) CCLite emulator disagree on sizes.
-- Best to use "expected size" throughout.

os.loadAPI("apis/sha1")
os.loadAPI("apis/json")

function httpGet(what, url)
  local response = http.get("http://localhost:3000" .. url)
  local err = nil

  assert(response, "Failed to retrieve " .. what .. ": request failed")
  code = response.getResponseCode()
  assert(code == 200, "Failed to retrieve " .. what .. ": HTTP code " .. code)
  return response
end

function httpGetAll(what, url, expect_size)
  local response = httpGet(what, url)
  local data = response.readAll()
  response.close()

  if expect_size and string.len(data) == expect_size - 1 then -- readAll stripped EOL
    data = data .. "\n"
  end

  return data
end

function writeFile(file, content, size, hash)
  local tempfile = file .. ".new"
  local out_fh = fs.open(tempfile, "w")
  out_fh.write(content)
  out_fh.close()

  if hash then
    validate(readFile(tempfile, size), size, hash, "Written file " .. tempfile)
  end

  fs.delete(file)
  fs.move(tempfile, file)

  if size then
    print("Wrote " .. file .. " (" .. size .. " bytes)")
  end
end

function hashText(text)
  return sha1.SHA1(text)
end

function hashFile(file, size)
  local content = readFile(file, size)
  if content then
    return hashText(content)
  else
    return nil
  end
end

function readFile(file, expect_size)
  local fh = fs.open(file, "r")
  if not fh then
    return nil
  end

  local content = fh.readAll()
  fh.close()

  if expect_size and string.len(content) == expect_size - 1 then
    -- readAll stripped EOL
    content = content .. "\n"
  end
  return content
end

function validate(data, expect_size, expect_hash, err_prefix)
  local size = string.len(data)
  assert(size == expect_size, err_prefix .. " failed size check: got " .. size .. ", expected " .. expect_size)

  local hash = hashText(data)
  assert(hash == expect_hash, err_prefix .. " failed hash check: got " .. hash .. ", expected " .. expect_hash)
end

function touchFile(file)
  fs.open(file, "w").close()
end

print "Updating ..."
local update_data = json.decode(httpGetAll("manifest", "/update/manifest"))

for file, file_data in pairs(update_data['manifest']) do
  local size = file_data['size']
  local hash = file_data['hash']

  if hashFile(file, size) ~= hash then
    local content = httpGetAll(file, "/update/file?path=" .. file, size)
    validate(content, size, hash, "Download for " .. file)
    writeFile(file, content, size, hash)

    if file == "startup" or file == "update" then
      touchFile(".update-reboot")
    end
  end
end

local version = update_data['version']
writeFile(".version", version)

print "Update complete."
