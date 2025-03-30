tape = {}
for i=1,30000 do
	tape[i] = 0
end

if arg[2] == "--dump" or arg[2] == "-d" then
	dftmode = true
	print("Dump Final Tape mode is enabled. When the program is finished, the final tape will be dumped to stdout.")
end

if arg[1] == nil then
	print("LuaBF cannot execute nothing. Please provide a file that contains your code.")
	os.exit()
end

BFfile, err = io.open(arg[1], 'r')
if BFfile == nil then
	print(err)
	print("LuaBF cannot see this file. Are you sure it exists and that you have read permissions?")
	os.exit()
end

code = BFfile:read("a*")
pointer = 1
char = 1
loop = {}
nest = 0
skip = false

repeat
	if code:sub(char,char) == "<" then
		if skip == false then
			pointer = pointer - 1
			if pointer < 1 then pointer = 30000 end
		end
	elseif code:sub(char,char) == ">" then
		if skip == false then
			pointer = pointer + 1
			if pointer > 30000 then pointer = 1 end
		end
	elseif code:sub(char,char) == "+" then
		if skip == false then
			tape[pointer] = tape[pointer] + 1
			if tape[pointer] > 255 then tape[pointer] = 1 end
		end
	elseif code:sub(char,char) == "-" then
		if skip == false then
			tape[pointer] = tape[pointer] - 1
			if tape[pointer] < 0 then tape[pointer] = 255 end
		end
	elseif code:sub(char,char) == "." then
		if skip == false then io.write(string.char(tape[pointer])) end
	elseif code:sub(char,char) == "," then
		if skip == false then
			print("The program requests one unsigned byte. (0-255)")
			input = io.read("*number")
			if input > 255 then input = 1 end
			if input < 0 then input = 255 end
			tape[pointer] = input
		end
	elseif code:sub(char,char) == "[" then
		if tape[pointer] ~= 0 then
			nest = nest + 1
			loop[nest] = char
		else
			if skip == false then skip = true; startingnest = nest end
		end
	elseif code:sub(char,char) == "]" then
		if skip == false then
			if tape[pointer] ~= 0 then
				char = loop[nest]
			else
				nest = nest - 1
				if nest < 0 then nest = 0 end
			end
		else
			if nest == startingnest then skip = false end
		end
	end
	char = char + 1
until char == #code

print("\n===== PROGRAM FINISHED =====")
if dftmode == true then
	print("===== FINAL TAPE DUMP =====")
	for i=1,#tape do
		print(tape[i])
	end
end
