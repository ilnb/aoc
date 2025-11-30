local f = io.open('input.txt', 'r')
if not f then
  io.write('issues with input file.')
  return
end

local num1 = {}
local num2 = {}
for l in f:lines() do
  local a, b = l:match('(%d+)%s+(%d+)')
  a, b = tonumber(a), tonumber(b)
  num1[#num1 + 1], num2[#num2 + 1] = a, b
end
local size = #num1

table.sort(num1)
table.sort(num2)

local dis = 0
for i = 1, size do dis = dis + math.abs(num1[i] - num2[i]) end

local sim = 0
for i = 1, size do
  local count = 0
  for j = 1, size do
    if num1[i] == num2[j] then
      count = count + 1
    end
  end
  sim = sim + num1[i] * count
end

io.write('Distance: ', dis, '\n')
io.write('Similarity score: ', sim, '\n')
