-- delete all dat files

for k, v in pairs(file.list()) do
  if string.match(k, "dat$") then
    print(k)
    file.remove(k)
  end
end