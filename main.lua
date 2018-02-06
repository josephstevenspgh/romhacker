--[[
	ROM HACKER v0.10

	hex editor by @splixel joseph.stevens.pgh@gmail.com
	
	I was thinking "man I sure wish I had a hex editor right about now"
	then I remembered I make programs and stuff.

	WTFPL of course.
]]

--[[
	* DONE
	load from rom
	load table file
	insert hex
	highlight changed bytes
	
	goto address

	tile drawing
		1bpp
		2bpp nes
		2bpp gb

	* TODO

	insert characters

	my font sucks, make it better as I go.

	mouse support
		click byte or character to set menuposx/menuposy
		scrollwheel to page up/down
		click+drag scrollbar to navigate

		menu support for mouse


	better save/load
		love's saving is locked to a specific directory and that kinda blows.
		i gotta find a different way to do it

		i need to figure out how to write bytes instead of characters to a file

	features
		search - search for a string of bytes or characters
		insert/overwrite modes

		in-editor assembler

		save as binary or ips patch
]]

function love.load()
	--defaultfilename = "Final Fantasy (USA).nes"
	defaultfilename = "Castlevania II - Belmont's Revenge (USA, Europe).gb"
	defaulttablename = "default.tbl"

	love.filesystem.setIdentity("romhacker")
	--setzlib
	require("setzlib")
	require("belmonthacker")
	init_game_specific()
	--screen size and scaling

	state_editor = 0
	state_menu = 1
	state_goto = 2
	state_search = 3
	state_game_specific = 1000
	state_tsa_view = 1001
	state_map_view = 1002
	state_layout_view = 1003
	--state = state_editor
	state = state_game_specific

	graphicmode_1bpp = 0
	graphicmode_2bpp = 1
	graphicmode_2bppgb = 2
	graphicmode_sms = 3
	graphicmode = graphicmode_2bppgb

	gotoaddress = ""

	screen = {}
	screen.width = 320*4
	screen.height = 180*4
	scaleamount = 1
	love.graphics.setDefaultFilter("nearest", "nearest", 1)
	-- scale with a canvas, not with scale()
	canvas = love.graphics.newCanvas(320*4, 180*4)
	--menus
	menuposx = 0
	menuposy = 0
	--buttonconfig
	joysticks = get_joysticks()
	--control vars
	escape_button = init_button("escape")
	enter_button = init_button("return", false, 900001)
	tab_button = init_button("tab")
	backspace_button = init_button("backspace")
	up_button = init_button("up")
	down_button = init_button("down")
	left_button = init_button("left")
	right_button = init_button("right")
	pgup_button = init_button("pageup", true, 5)
	pgdown_button = init_button("pagedown", true, 5)
	plus_button = init_button("[", true, 20)
	minus_button = init_button("]", true, 20)

	buttons = {}
	table.insert(buttons, escape_button)
	table.insert(buttons, enter_button)
	table.insert(buttons, backspace_button)
	table.insert(buttons, down_button)
	table.insert(buttons, up_button)
	table.insert(buttons, left_button)
	table.insert(buttons, right_button)
	table.insert(buttons, pgup_button)
	table.insert(buttons, pgdown_button)
	table.insert(buttons, plus_button)
	table.insert(buttons, minus_button)

	--numbers
	button0 = init_button("0", true, 7)
	button1 = init_button("1", true, 7)
	button2 = init_button("2", true, 7)
	button3 = init_button("3", true, 7)
	button4 = init_button("4", true, 7)
	button5 = init_button("5", true, 7)
	button6 = init_button("6", true, 7)
	button7 = init_button("7", true, 7)
	button8 = init_button("8", true, 7)
	button9 = init_button("9", true, 7)
	buttona = init_button("a", true, 7)
	buttonb = init_button("b", true, 7)
	buttonc = init_button("c", true, 7)
	buttond = init_button("d", true, 7)
	buttone = init_button("e", true, 7)
	buttonf = init_button("f", true, 7)
	
	numbuttons = {}
	table.insert(numbuttons, button0)
	table.insert(numbuttons, button1)
	table.insert(numbuttons, button2)
	table.insert(numbuttons, button3)
	table.insert(numbuttons, button4)
	table.insert(numbuttons, button5)
	table.insert(numbuttons, button6)
	table.insert(numbuttons, button7)
	table.insert(numbuttons, button8)
	table.insert(numbuttons, button9)
	table.insert(numbuttons, buttona)
	table.insert(numbuttons, buttonb)
	table.insert(numbuttons, buttonc)
	table.insert(numbuttons, buttond)
	table.insert(numbuttons, buttone)
	table.insert(numbuttons, buttonf)

	--fixed width font
	love.graphics.setFont(love.graphics.newImageFont("ClassicFont.png", "abcdefghijklmnopqrstuvwxyz:.!-,()|?<>\"+0123456789 ABCDEFGHIJKLMNOPQRSTUVWXYZ/'"))

	--
	if arg[2] then
		file = arg[2]
	else
		file = defaultfilename
	end


	if arg[3] then
		tablefile = arg[3]
	else
		tablefile = defaulttablename
	end

	loadedtable = loadtable(tablefile)

	loadromfile(file)

	currentpos = 0x0
	startpos = 0x0
	pagesize = 0x30
	curbyte = ""

	newbyte = ""

	--scrollbar
	local minscrollsize = 20
	scrollbarheight = math.floor(pagesize / filesize)
	if scrollbarheight < minscrollsize then
		scrollbarheight = minscrollsize
	end
end

function love.update(dt)
	control_mechanics()
	if state == state_editor then
		update_editor()
	elseif state == state_game_specific then
		update_game_specific()
	elseif state == state_tsa_view then
		update_tsa_view()
	elseif state == state_map_view then
		update_map_view()
	elseif state == state_menu then
		update_menu()
	elseif state == state_goto then
		update_goto()
	elseif state == state_search then
		update_search()
	end
end

function love.draw()
	love.graphics.setCanvas(canvas)
	setcolorbackground()
	if state < state_game_specific then
		draw_editor()
	end
	if state == state_menu then
		draw_menu()
	elseif state == state_game_specific then
		draw_game_specific()
	elseif state == state_tsa_view then
		draw_tsa_view()
	elseif state == state_map_view then
		draw_map_view()
	elseif state == state_goto then
		draw_goto()
	elseif state == state_search then
		draw_search()
	end
	love.graphics.setCanvas()
	love.graphics.draw(canvas, 0, 0, 0, scaleamount)
end

function love.mousepressed(mx, my, button)
	if state > 9 then
		mouse_game_specific()
	end
end


function love.quit()
	print("rip everything")
end


function update_editor()	
	menu_controls(0x10, pagesize)
	if pgup_button.justpressed then
		startpos = startpos - pagesize * 0x10
		if startpos < 0 then
			startpos = 0
		end
	end
	if pgdown_button.justpressed then
		startpos = startpos + pagesize * 0x10
		if startpos > filesize - pagesize * 0x10 then
			startpos = filesize - pagesize * 0x10
		end
	end
	if plus_button.justpressed then
		startpos = startpos - 0x100
		if startpos < 0 then
			startpos = 0
		end
	end
	if minus_button.justpressed then
		startpos = startpos + 0x100
		if startpos > filesize - pagesize * 0x10 then
			startpos = filesize - pagesize * 0x10
		end
	end

	for i=1,#numbuttons do
		if numbuttons[i].justpressed then
			if string.len(newbyte) == 0 then
				newbyte = numbuttons[i].keycode
			elseif string.len(newbyte) == 1 then
				newbyte = newbyte..numbuttons[i].keycode
				filedata[startpos+menuposx+menuposy*0x10+1] = str2hex(newbyte)
				newbyte = ""
				movenext()
			end
		end
	end

	for i=1,#buttons do
		if buttons[i].justpressed then
			curbyte = byte2hex(filedata[startpos+menuposx+menuposy*0x10+1])
			newbyte = ""
		end
	end

	if enter_button.justpressed then
		open_menu()
	end
end

function draw_editor()
	love.graphics.rectangle("fill", 0, 0, 1920, 1080)
	setcolorwhite()

	local menuy = menuposy
	local menux = menuposx
	if state == state_menu then
		menuy = oldypos
		menux = oldxpos
	end

	lprint("ROM HACKER v0.10 -- "..file, 2, 2)

	--print rows
	local curline = 0
	lprint("        ".." ".." 0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F", 6, 20)


	--highlight line
	setcolorhighlight()
	love.graphics.rectangle("fill", 0, 29+menuy*10, 460, 10)
	setcolorwhite()

	--draw data
	for i=1,pagesize do
		local line = string.upper(dec2hex(startpos+curline))
		lprint(line, 2, 20+i*10)
		setcolordimtext()
		for j=0,0xf do
			if filedata[startpos+curline+j+1] ~= origdata[startpos+curline+j+1] then
				setcolorchanged()
				love.graphics.rectangle("fill", 78+j*24, 19+i*10, 24, 10)
				love.graphics.rectangle("fill", 474+j*9, 19+i*10, 9, 10)
				setcolordimtext()
			end
			lprint(""..string.upper(byte2hex(filedata[startpos+curline+j+1])), 82+j*24, 20+i*10)
			lprint(convertbyte(filedata[startpos+curline+j+1]), 475+j*9, 20+i*10)
		end
		--lprint(" ".."00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00", 74, 20+i*10)
		setcolorwhite()
		curline = curline + 0x10
	end

	--draw selector
	setcolorhighlight()
	love.graphics.rectangle("fill", 81+menux*8*3, 29+menuy*10, 18, 10)
	love.graphics.rectangle("line", 81+menux*8*3, 29+menuy*10, 18, 10)
	love.graphics.rectangle("fill", 474+menux*9, 29+menuy*10, 10, 10)
	love.graphics.rectangle("line", 474+menux*9, 29+menuy*10, 10, 10)
	setcolorwhite()
	if string.len(newbyte) > 0 then
		lprint(string.upper(newbyte), 82+menux*8*3, 30+menuy*10)
	else
		lprint(string.upper(byte2hex(filedata[startpos+menux+menuy*0x10+1])), 82+menux*8*3, 30+menuy*10)
	end
	lprint(convertbyte(filedata[startpos+menux+menuy*0x10+1]), 475+menux*9, 30+menuy*10)

	lprint("CURRENT BYTE: "..dec2hex(startpos+menux+menuy*0x10).." "..string.upper(byte2hex(origdata[startpos+menux+menuy*0x10+1])).." "..string.upper(byte2hex(filedata[startpos+menux+menuy*0x10+1])), 2, 530)

	--scrollbar
	local scrollpos = math.floor( (startpos / (filesize - (pagesize * 10) ) ) * (pagesize * 10 - scrollbarheight) )

	setcolorhighlight()
	love.graphics.rectangle("fill", 464, 30, 4, pagesize * 10)
	love.graphics.rectangle("fill", 462, 30+scrollpos, 8, scrollbarheight)
	love.graphics.rectangle("line", 462, 30+scrollpos, 8, scrollbarheight)
	setcolorwhite()

	--tile viewer

	-- i should really generate this on startpos change
	-- but for now its here, which makes it super slow since it regenerates every frame
	-- hey i have a 2500k so i dont care

	local mode = ""
	if graphicmode == graphicmode_1bpp then
		mode = "1bpp"
	elseif graphicmode == graphicmode_2bpp then
		mode = "2bpp NES"
	elseif graphicmode == graphicmode_2bppgb then
		mode = "2bpp GB"
	elseif graphicmode == graphicmode_2bppgb then
		mode = "4bpp SMS"
	end
	lprint(mode, 650, 30)
	setcolorhighlight()
	love.graphics.rectangle("line", 649, 39, 258, 258)

	--draw first tile
	if graphicmode == graphicmode_1bpp then
		for a=1,16 do
			for b=1,16 do
				local bytes = {}
				for i=1,16 do
					if not filedata[startpos+i+a*16+b*16*16] then
						setcolorwhite()
						return
					end
					bytes[i] = getbin(filedata[startpos+i+a*16+b*16*16])
				end
				local tile = {}
				for i=1,8 do
					tile[i] = {}
					for j=1,8 do
						local tmpbit = string.sub(bytes[i], j, j)
						if tmpbit == "0" then
							tile[i][j] = 0
						elseif tmpbit == "1" then
							tile[i][j] = 1
						end
					end
				end
				--draw tile
				drawtile(tile, 632+a*16, 22+b*16)
			end
		end
	elseif graphicmode ==  graphicmode_2bpp then
		for a=1,16 do
			for b=1,16 do
				local bytes = {}
				for i=1,16 do
					if not filedata[startpos+i+a*16+b*16*16] then
						setcolorwhite()
						return
					end
					bytes[i] = getbin(filedata[startpos+i+a*16+b*16*16])
				end
				local tile = {}
				for i=1,8 do
					tile[i] = {}
					for j=1,8 do
						local tmpbit = string.sub(bytes[i*2-2], j, j)
						if tmpbit == "0" then
							tile[i][j] = 0
						elseif tmpbit == "1" then
							tile[i][j] = 1
						end
						tmpbit = string.sub(bytes[i+8], j, j)
						if tmpbit == "0" then
							tile[i][j] = tile[i][j] + 0
						elseif tmpbit == "1" then
							tile[i][j] = tile[i][j] + 10
						end
					end
				end

				--draw tile
				drawtile(tile, 632+a*16, 22+b*16)
			end
		end
	elseif graphicmode == graphicmode_2bppgb then
		for a=1,16 do
			for b=1,16 do
				local bytes = {}
				for i=1,16 do

					if not filedata[startpos+i+a*16+b*16*16] then
						setcolorwhite()
						return
					end
					bytes[i] = getbin(filedata[startpos+i+a*16+b*16*16])
				end
				local tile = {}
				for i=1,8 do
					tile[i] = {}
					for j=1,8 do
						local tmpbit = string.sub(bytes[i*2-1], j, j)
						if tmpbit == "0" then
							tile[i][j] = 0
						elseif tmpbit == "1" then
							tile[i][j] = 1
						end
						tmpbit = string.sub(bytes[i*2], j, j)
						if tmpbit == "0" then
							tile[i][j] = tile[i][j] + 0
						elseif tmpbit == "1" then
							tile[i][j] = tile[i][j] + 10
						end
					end
				end

				--draw tile
				drawtile(tile, 632+a*16, 22+b*16)
			end
		end
	elseif graphicmode ==  graphicmode_sms then
		drawsmstile()
	end

	--reset color
	setcolorwhite()
end

function drawsmstile() --4bpp
	local bppwidth = 32
	for a=1,16 do
		for b=1,16 do
			local bytes = {}
			local tilestart = startpos+(a*bppwidth)+(b*bppwidth)-(bppwidth*2)+a*480-480
			--log("tile no. "..a*16+b-16)
			--log("startpos: "..tilestart)
			for i=1,bppwidth do
				if not filedata[tilestart+i] then
					setcolorwhite()
					return
				end
				--log("reading byte "..tilestart+i.." ..")
				bytes[i] = getbin(filedata[tilestart+i])
			end
			bytes = reverseendian_bytes(bytes)
			--log(bytes)
			local tile = {}
			for i=1,8 do
				tile[i] = {}
			end
			for i=1,8 do
				local line = 1
				local nextbyte = 0
				for j=1,8 do
					local curbyte = (i*4)-3
					curbyte = curbyte + math.floor(nextbyte)
					local tmpbit = string.sub(bytes[curbyte], line, line+3)
					tile[i][j] = get4bppcolor(tmpbit)
					line = line + 4
					if line > 8 then
						line = 1
					end
					nextbyte = nextbyte + .5
				end
			end

			--draw tile
			drawtile(tile, 632+b*16, 22+a*16)
		end
	end
end

function reverseendian_bytes(bytearray)
	if #bytearray%2 == 1 then
		log("array has to be even amount of numbers")
		return
	end

	local iterator = 1
	for i=1,(#bytearray/2) do
		local tempval = bytearray[iterator]
		bytearray[iterator] = bytearray[iterator+1]
		bytearray[iterator+1] = tempval
		iterator = iterator + 2
	end
	return bytearray
end

function reverseendian(num)
	num = num..""
	local retval = string.sub(num, 1, 2)
	retval = string.sub(num, 3, 4)..retval
	log("num: "..num.." | retval: "..retval)
	return retval
end

function drawgenesistile() --4bpp
	local bppwidth = 32
	for a=1,16 do
		for b=1,16 do
			local bytes = {}
			local tilestart = startpos+(a*bppwidth)+(b*bppwidth)-(bppwidth*2)+a*480-480
			log("tile no. "..a*16+b-16)
			log("startpos: "..tilestart)
			for i=1,bppwidth do
				if not filedata[tilestart+i] then
					setcolorwhite()
					return
				end
				--log("reading byte "..tilestart+i.." ..")
				bytes[i] = getbin(filedata[tilestart+i])
			end
			--log(bytes)
			local tile = {}
			for i=1,8 do
				tile[i] = {}
			end
			for i=1,8 do
				local line = 1
				local nextbyte = 0
				for j=1,8 do
					local curbyte = (i*4)-3
					curbyte = curbyte + math.floor(nextbyte)
					local tmpbit = string.sub(bytes[curbyte], line, line+3)
					tile[i][j] = get4bppcolor(tmpbit)
					line = line + 4
					if line > 8 then
						line = 1
					end
					nextbyte = nextbyte + .5
				end
			end

			--draw tile
			drawtile(tile, 632+b*16, 22+a*16)
		end
	end
end

function get2bppcolor(input)
	if input == "0" then
		return 0
	elseif input == "1" then
		return 1
	end
end

function get4bppcolor(input)
	local bpp4 = { "4bpp color table" }
	bpp4["0000"] = 0
	bpp4["0001"] = 1
	bpp4["0010"] = 2
	bpp4["0011"] = 3
	bpp4["0100"] = 4
	bpp4["0101"] = 5
	bpp4["0110"] = 6
	bpp4["0111"] = 7
	bpp4["1000"] = 8
	bpp4["1001"] = 9
	bpp4["1010"] = 10
	bpp4["1011"] = 11
	bpp4["1100"] = 12
	bpp4["1101"] = 13
	bpp4["1110"] = 14
	bpp4["1111"] = 15
	return bpp4[input]
end

--http://stackoverflow.com/questions/9137415/lua-writing-hexadecimal-values-as-a-binary-file
function string.fromhex(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

function string.tohex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

function loadtile(address, mode)
	if mode == graphicmode_1bpp then
		local bytes = {}
		for i=1,16 do
			if not filedata[address+i] then
				setcolorwhite()
				return
			end
			bytes[i] = getbin(filedata[address+i])
		end
		local tile = {}
		for i=1,8 do
			tile[i] = {}
			for j=1,8 do
				local tmpbit = string.sub(bytes[i], j, j)
				if tmpbit == "0" then
					tile[i][j] = 0
				elseif tmpbit == "1" then
					tile[i][j] = 1
				end
			end
		end
		--draw tile
		return tile
	elseif mode == graphicmode_2bpp then
		local bytes = {}
		for i=1,16 do
			if not filedata[address+i] then
				setcolorwhite()
				return
			end
			bytes[i] = getbin(filedata[address+i])
		end
		local tile = {}
		for i=1,8 do
			tile[i] = {}
			for j=1,8 do
				local tmpbit = string.sub(bytes[i*2-2], j, j)
				if tmpbit == "0" then
					tile[i][j] = 0
				elseif tmpbit == "1" then
					tile[i][j] = 1
				end
				tmpbit = string.sub(bytes[i+8], j, j)
				if tmpbit == "0" then
					tile[i][j] = tile[i][j] + 0
				elseif tmpbit == "1" then
					tile[i][j] = tile[i][j] + 10
				end
			end
		end

		--draw tile
		return tile
	elseif graphicmode == graphicmode_2bppgb then
		local bytes = {}
		for i=1,16 do

			if not filedata[address+i] then
				setcolorwhite()
				return
			end
			bytes[i] = getbin(filedata[address+i])
		end
		local tile = {}
		for i=1,8 do
			tile[i] = {}
			for j=1,8 do
				local tmpbit = string.sub(bytes[i*2-1], j, j)
				if tmpbit == "0" then
					tile[i][j] = 0
				elseif tmpbit == "1" then
					tile[i][j] = 1
				end
				tmpbit = string.sub(bytes[i*2], j, j)
				if tmpbit == "0" then
					tile[i][j] = tile[i][j] + 0
				elseif tmpbit == "1" then
					tile[i][j] = tile[i][j] + 10
				end
			end
		end

		--draw tile
		return tile
	elseif graphicmode ==  graphicmode_sms then
		drawsmstile()
	end


	local tile = nil
	return tile
end

function drawtile1x(tile, x, y, colors)
	local startx = x
	local starty = y
	for x=1,#tile do
		for y=1,#tile[x] do
			if graphicmode == graphicmode_sms then
				if tile[y][x] == 0 then
					setcolor(128, 85, 100)
				elseif tile[y][x] == 1 then
					setcolor(0, 170, 255)
				elseif tile[y][x] == 2 then
					setcolor(85, 0, 0)
				elseif tile[y][x] == 3 then
					setcolor(170, 85, 0)
				elseif tile[y][x] == 4 then
					setcolor(255, 170, 0)
				elseif tile[y][x] == 5 then
					setcolor(0, 85, 0)
				elseif tile[y][x] == 6 then
					setcolor(0, 170, 0)
				elseif tile[y][x] == 7 then
					setcolor(0, 255, 0)
				elseif tile[y][x] == 8 then
					setcolor(85, 255, 255)
				elseif tile[y][x] == 9 then
					setcolor(255, 170, 255)
				elseif tile[y][x] == 10 then
					setcolor(0, 85, 255)
				elseif tile[y][x] == 11 then
					setcolor(255, 255, 255)
				elseif tile[y][x] == 12 then
					setcolor(0, 255, 255)
				elseif tile[y][x] == 13 then
					setcolor(170, 255, 255)
				elseif tile[y][x] == 14 then
					setcolor(255, 255, 0)
				elseif tile[y][x] == 15 then
					setcolor(0, 0, 0)
				end
			else --gb palette
				if tile[y][x] == 11 then
					setcolor(0, 0, 0)
				elseif tile[y][x] == 10 then
					setcolor(80, 80, 80)
				elseif tile[y][x] == 1 then
					setcolor(160, 160, 160)
				elseif tile[y][x] == 0 then
					setcolor(255, 255, 255)
				end
			end
			drawpixelnocol(startx+x, starty+y)
			setcolorwhite()
		end
	end
end

function drawtile(tile, x, y, colors)
	local startx = x
	local starty = y
	for x=1,#tile do
		for y=1,#tile[x] do
			if graphicmode == graphicmode_sms then
				if tile[y][x] == 0 then
					setcolor(128, 85, 100)
				elseif tile[y][x] == 1 then
					setcolor(0, 170, 255)
				elseif tile[y][x] == 2 then
					setcolor(85, 0, 0)
				elseif tile[y][x] == 3 then
					setcolor(170, 85, 0)
				elseif tile[y][x] == 4 then
					setcolor(255, 170, 0)
				elseif tile[y][x] == 5 then
					setcolor(0, 85, 0)
				elseif tile[y][x] == 6 then
					setcolor(0, 170, 0)
				elseif tile[y][x] == 7 then
					setcolor(0, 255, 0)
				elseif tile[y][x] == 8 then
					setcolor(85, 255, 255)
				elseif tile[y][x] == 9 then
					setcolor(255, 170, 255)
				elseif tile[y][x] == 10 then
					setcolor(0, 85, 255)
				elseif tile[y][x] == 11 then
					setcolor(255, 255, 255)
				elseif tile[y][x] == 12 then
					setcolor(0, 255, 255)
				elseif tile[y][x] == 13 then
					setcolor(170, 255, 255)
				elseif tile[y][x] == 14 then
					setcolor(255, 255, 0)
				elseif tile[y][x] == 15 then
					setcolor(0, 0, 0)
				end
			else --gb palette
				if tile[y][x] == 11 then
					setcolor(0, 0, 0)
				elseif tile[y][x] == 10 then
					setcolor(80, 80, 80)
				elseif tile[y][x] == 1 then
					setcolor(160, 160, 160)
				elseif tile[y][x] == 0 then
					setcolor(255, 255, 255)
				end
			end
			drawpixelnocol(startx+x*2, starty+y*2)
			drawpixelnocol(startx+x*2+1, starty+y*2)
			drawpixelnocol(startx+x*2, starty+y*2+1)
			drawpixelnocol(startx+x*2+1, starty+y*2+1)
			setcolorwhite()
		end
	end
end

function update_menu()
	menu_controls(1, 6)
	if escape_button.justpressed then
		close_menu()
	end
	if enter_button.justpressed then
		menuoption(menuposy)
	end
end

function draw_menu()
	local menuwidth = 200
	local menuheight = 400
	local xpos = screen.width/2 - menuwidth*1.5
	local ypos = 50

	setcolorbackground()
	love.graphics.rectangle("fill", 0, 0, screen.width, screen.height)
	love.graphics.rectangle("fill", xpos, ypos, menuwidth, menuheight)
	setcolorhighlight()
	love.graphics.rectangle("fill", xpos, ypos, menuwidth, menuheight)
	love.graphics.rectangle("line", xpos, ypos, menuwidth, menuheight)
	love.graphics.rectangle("fill", xpos, ypos+10+menuposy*10, menuwidth, 8)
	setcolorwhite()
	lprint("GOTO ADDRESS", xpos+10, ypos+10)
	lprint("SEARCH", xpos+10, ypos+20)
	lprint("RELOAD FILE", xpos+10, ypos+30)
	lprint("SAVE FILE", xpos+10, ypos+40)
	lprint("CLOSE MENU", xpos+10, ypos+50)
	lprint("QUIT", xpos+10, ypos+60)
	lprint(">", xpos, ypos+10+menuposy*10)
end

function update_goto()
	for i=1,#numbuttons do
		if numbuttons[i].justpressed then
			gotoaddress = gotoaddress..numbuttons[i].keycode
		end
	end
	if backspace_button.justpressed then
		gotoaddress = string.sub(gotoaddress, 0, #gotoaddress-1)
	end
	if escape_button.justpressed then
		state = state_editor
	end
	if enter_button.justpressed then
		jumpaddress(gotoaddress)
	end
end

function draw_goto()
	local menuwidth = 200
	local menuheight = 200
	local xpos = screen.width/2 - menuwidth*1.5
	local ypos = 50

	setcolorbackground()
	love.graphics.rectangle("fill", 0, 0, screen.width, screen.height)
	love.graphics.rectangle("fill", xpos, ypos, menuwidth, menuheight)
	setcolorhighlight()
	love.graphics.rectangle("fill", xpos, ypos, menuwidth, menuheight)
	love.graphics.rectangle("line", xpos, ypos, menuwidth, menuheight)
	love.graphics.rectangle("fill", xpos, ypos+20, menuwidth, 8)
	setcolorwhite()
	lprint("GOTO ADDRESS", xpos+10, ypos+10)
	lprint("0x"..string.upper(gotoaddress), xpos+10, ypos+20)
end

function update_search()
end

function draw_search()
end

function open_menu()
	oldxpos = menuposx
	oldypos = menuposy
	menuposx = 0
	menuposy = 0
	state = state_menu
end

function close_menu()
	menuposx = oldxpos
	menuposy = oldypos
	state = state_editor
end

function menuoption(num)
	if num == 0 then
		-- goto
		close_menu()
		state = state_goto
	elseif num == 1 then
		-- search
		close_menu()
	elseif num == 2 then
		loadromfile(file)
		close_menu()
	elseif num == 3 then
		savefile(file)
		close_menu()
	elseif num == 4 then
		close_menu()
	elseif num == 5 then
		love.event.quit()
	end
end

function movenext()
	menuposx = menuposx + 1
	if menuposx > 0x10 then
		menuposx = 0
		menuposy = menuposy + 1
	end
end

function jumpaddress(add)
	menuposx = 0
	menuposy = 0
	if add == 0 then
		startpos = 0
	elseif #add > 1 then
		jmpad = "0x"..add
		if jmpad % 0x10 ~= 0 then
			menuposx = ("0x"..string.sub(jmpad, #jmpad, #jmpad))+0
			--trim last digit, add 0
			jmpad = string.sub(jmpad, 1, #jmpad-1).."0"
		end
		startpos = jmpad+0
	end
	state = state_editor
end

--table support
function convertbyte(byte)
	if loadedtable[byte2hex(byte)] then
		return loadedtable[byte2hex(byte)]
	else
		return "."
	end
end

--file loading
function loadromfile(filename)
	local loadedfile, err = love.filesystem.newFile(filename, "r")
	if err then
		log(err)
		return
	end
	filesize = loadedfile:getSize()
	print("filename: "..filename)
	print("filesize: 0x"..dec2hex(filesize))
	filedata = {}
	origdata = {}
	unmoddata = {}
	for i=1,filesize do
		unmoddata[i] = loadedfile:read(1)
		filedata[i] = string.byte(unmoddata[i])
		origdata[i] = filedata[i]
	end
	loadedfile:close()
end

function savefile(filename)
	log("saving .. ")
	local loadedfile = love.filesystem.newFile(filename, "w")
	for i=1,filesize do
		if filedata[i] == origdata[i] then 
			if loadedfile:write(unmoddata[i], 1) then
			else
				log("error on byte "..i)
			end
		else
			log("new byte at 0x"..dec2hex(i)..": "..byte2hex(filedata[i]))
			if loadedfile:write((filedata[i]:tohex()), 1) then
			else
				log("error on byte "..i)
			end
		end
	end
	loadedfile:close()
	log("save done..")
	log("reloading ....")	
	loadromfile(filename)
end

function loadtable(filename)
	local loadedfile, err = love.filesystem.newFile(filename, "r")
	if err then
		log(err)
		return
	end
	local tablefile = {}
	local tbl = {}
	for line in loadedfile:lines() do
		local tmp = explode(line, "=")
		tbl[ string.lower(tmp[1]) ] = tmp[2]
	end
	return tbl
end

--controls
function control_mechanics()
	for i=1,#buttons do
		button_mechanics(buttons[i])
	end
	for i=1,#numbuttons do
		button_mechanics(numbuttons[i])
	end
end

--menus
function menu_controls(xamount, yamount)
	if left_button.justpressed then
		menuposx = menuposx - 1
	elseif right_button.justpressed then
		menuposx = menuposx + 1
	end
	if up_button.justpressed then
		menuposy = menuposy - 1
	elseif down_button.justpressed then
		menuposy = menuposy + 1
	end

	--wrap
	if menuposx < 0 then
		menuposx = xamount - 1
		menuposy = menuposy - 1
	elseif menuposx > xamount - 1 then
		menuposy = menuposy + 1
		menuposx = 0
	end

	if menuposy < 0 then
		menuposy = yamount - 1
	elseif menuposy > yamount - 1 then
		menuposy = 0
	end
end

--colors	r, g, b, a
function setcolorbackground()
	love.graphics.setColor(25, 0, 50, 128)
end

function setcolorhighlight()
	love.graphics.setColor(0, 255, 255, 25)
end

function setcolordimtext()
	love.graphics.setColor(180, 180, 180, 255)
end

function setcolorwhite()
	love.graphics.setColor(255, 255, 255, 255)
end

function setcolorchanged()
	love.graphics.setColor(200, 0, 255, 50)
end

function setcolor(r, g, b)
	love.graphics.setColor(r, g, b, 255)
end

function setcolor(r, g, b, a)
	love.graphics.setColor(r, g, b, a)
end