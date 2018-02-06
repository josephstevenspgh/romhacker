function init_game_specific()


	--notes
	--[[
		stage loading code
		06:50a5 points to 50af ? - 08 into ca86, 03 into ca8d, 35 next byte


		DE00 - OAM buffer ?

		DEC0 - DEC1 - room areas? something to do with loaded rooms, maybe scrolling

		C000 - main character status

		C400 - Sprites?

		C580 - looks like music data

		c898 - some sort of tile animation control pointer?
		c898 - how much of MAP2 to draw? In case of flickering, how high to flicker? mystery stage byte!

		CBE0 - whipped candles?
	]]

	--tsa data pointers at 0x82a5

	--map sets
	mapsets = {}
	for i=1,8 do
		mapsets[i] = {}
	end


	mapsets_generic_tileexceptions = {}
	mapsets_generic_tileexceptions["ID"] = {}
	mapsets_generic_tileexceptions["TileAddress"] = {}

	--these tiles are loaded on every map, outside of the core art address
	AddMapException(mapsets_generic_tileexceptions, 0x00, 0xae80)
	AddMapException(mapsets_generic_tileexceptions, 0x01, 0x14000)
	AddMapException(mapsets_generic_tileexceptions, 0x02, 0x14010)
	AddMapException(mapsets_generic_tileexceptions, 0x03, 0x14020)
	AddMapException(mapsets_generic_tileexceptions, 0x0e, 0x14030)
	AddMapException(mapsets_generic_tileexceptions, 0x0f, 0x14040)
	AddMapException(mapsets_generic_tileexceptions, 0x10, 0x14050)
	AddMapException(mapsets_generic_tileexceptions, 0x11, 0x14060)
	AddMapException(mapsets_generic_tileexceptions, 0x12, 0x14070)
	AddMapException(mapsets_generic_tileexceptions, 0x13, 0x14080)
	AddMapException(mapsets_generic_tileexceptions, 0x14, 0x14090)
	AddMapException(mapsets_generic_tileexceptions, 0x15, 0x140a0)
	AddMapException(mapsets_generic_tileexceptions, 0x16, 0x140b0)
	AddMapException(mapsets_generic_tileexceptions, 0x17, 0x140c0)
	AddMapException(mapsets_generic_tileexceptions, 0x18, 0x140d0)
	AddMapException(mapsets_generic_tileexceptions, 0x19, 0x140e0)
	AddMapException(mapsets_generic_tileexceptions, 0x1a, 0x140f0)
	AddMapException(mapsets_generic_tileexceptions, 0x1b, 0x14100)
	AddMapException(mapsets_generic_tileexceptions, 0x1c, 0x14110)

	mapsets[1].id = 1
	mapsets[1].name = "Plant Castle"
	mapsets[1].mapdata = 0x1a2b4
	mapsets[1].tsadata = 0x84d0
	mapsets[1].tsasize = 0x69
	mapsets[1].tiledata = 0x13f90

	mapsets[2].id = 2
	mapsets[2].name = "Crystal Castle"
	mapsets[2].mapdata = 0x1a55c
	mapsets[2].mapsize = 0x2c
	mapsets[2].tsadata = 0x8bf0
	mapsets[2].tsasize = 0x71
	mapsets[2].tiledata = 0x158a0

	mapsets[3].id = 3
	mapsets[3].name = "Cloud Castle"
	mapsets[3].mapdata = 0x1a8e0
	mapsets[3].mapsize = 0x21
	mapsets[3].tsadata = 0x9300
	mapsets[3].tsasize = 0x71
	mapsets[3].tiledata = 0x15ff0

	mapsets[4].id = 4
	mapsets[4].name = "Rock Castle"
	mapsets[4].mapdata = 0x1abc4
	mapsets[4].mapsize = 0x25
	mapsets[4].tsadata = 0x9af0
	mapsets[4].tsasize = 0x71
	mapsets[4].tiledata = 0x16ac0

	mapsets[5].id = 5
	mapsets[5].name = "Dracula Castle 1"
	mapsets[5].mapdata = 0x1aebc
	mapsets[5].mapsize = 0x22
	mapsets[5].tsadata = 0x9fb0
	mapsets[5].tsasize = 0x71
	mapsets[5].tiledata = 0x170b0

	mapsets[6].id = 6
	mapsets[6].name = "Dracula Castle 2"
	mapsets[6].mapdata = 0x1b18c
	mapsets[6].mapsize = 0x1a
	mapsets[6].tsadata = 0xa500
	mapsets[6].tsasize = 0x71
	mapsets[6].tiledata = 0x176a0

	mapsets[7].id = 7
	mapsets[7].name = "Dracula Castle 2 - boss fight"
	mapsets[7].mapdata = 0x1b3a8
	mapsets[7].mapsize = 0x03
	mapsets[7].tsadata = 0xa500
	mapsets[7].tsasize = 0x71
	mapsets[7].tiledata = 0x176a0

	mapsets[8].id = 8
	mapsets[8].name = "Dracula Castle 3"
	mapsets[8].mapdata = 0x1b3f8
	mapsets[8].mapsize = 0x4
	mapsets[8].tsadata = 0xa500
	mapsets[8].tsasize = 0x71
	mapsets[8].tiledata = 0x176a0
	mapsets[8].tileexceptions = {

		}

	loadedmapset = mapsets[7]

	--crystal castle 	0x8bf0 -- 71 tiles
	--cloud castle 		0x9300
	currentmap = loadedmapset.mapdata
	tsastart = loadedmapset.tsadata
	tsatilenumber = 0
	selected_tsa = 5


	--scrollbar for tsa in map editor

	MapViewBox = {10, 10, 100, 30}
	TSAViewBox = {135, 10, 100, 30}
	LayoutViewBox = {260, 10, 100, 30}
end

function loadnewmap(id)
	if id < 1 or id > #mapsets then
		return
	end
	loadedmapset = mapsets[id]
	currentmap = loadedmapset.mapdata
	tsastart = loadedmapset.tsadata
	tsatilenumber = 0
	selected_tsa = 0
end

function AddMapException(tble, ID, NewArt)
	table.insert(tble["ID"], ID)
	table.insert(tble["TileAddress"], NewArt)
end

function update_game_specific()
end

function draw_game_specific()
	draw_gs_header()
	lprint("Game Specific Editing Mode", 2, 520)
end

function draw_gs_header()
	setcolorbackground()
	love.graphics.rectangle("fill", 0, 0, 320*3, 180*3)
	love.graphics.rectangle("fill", 0, 0, 320*3, 180*3)
	love.graphics.rectangle("fill", 0, 0, 320*3, 180*3)
	setcolorwhite()
	local highlightme = false
	if state == state_map_view then
		highlightme = true
	end
	draw_selector("Map View", MapViewBox, highlightme)
	
	highlightme = false
	if state == state_tsa_view then
		highlightme = true
	end
	draw_selector("doot", TSAViewBox, highlightme)
	
	highlightme = false
	if state == state_layout_view then
		highlightme = true
	end
	draw_selector("Menu", LayoutViewBox, highlightme)
end

function mouse_game_specific()
	mouse_gs_header()
	if state == state_map_view then
		--check for tile selection
		local temp = 0
		for i=1,16 do
			for j=1,8 do
				local drawx = 508 + j * 33 - 48
				local drawy = 18 + i * 33 - 48
				temp = temp + 1
				if mouseover(drawx, drawy, 32, 32) then
					selected_tsa = temp
				end
			end
		end
		--check for tile placement on mapfor b=1,4 do


		local mapstart = currentmap + 1
		local mapactive = mapstart
		local maptileset = loadedmapset.tiledata
		local tsatileset = loadedmapset.tsadata
		for b=1,4 do
			for a=1,5 do
				local drawx = a * 66 - 70
				local drawy = b * 66 + 100
				if mouseover(drawx, drawy, 64, 64) then
					filedata[mapactive] = selected_tsa-1
			local drawx = a * 66 - 70
			local drawy = b * 66 + 100
				end
				mapactive = mapactive + 1
			end
		end
	end
end

function mouse_gs_header()
	if mouseover_box(MapViewBox) then
		state = state_map_view
	elseif mouseover_box(TSAViewBox) then
		state = state_tsa_view
	elseif mouseover_box(LayoutViewBox) then
		state = state_layout_view
	end
end

function mouseover_box(box)
	return mouseover(box[1], box[2], box[3], box[4])
end

function draw_selector(selectortext, boxcoords, highlighted)
	setcolorhighlight()
	local startx = boxcoords[1]
	local starty = boxcoords[2]
	local width = boxcoords[3]
	local height = boxcoords[4]
	love.graphics.rectangle("fill", startx, starty, width, height)
	love.graphics.rectangle("fill", startx, starty, width, height)
	love.graphics.rectangle("fill", startx, starty, width, height)
	if mouseover(startx, starty, width, height) or highlighted then
	love.graphics.rectangle("fill", startx, starty, width, height)
	love.graphics.rectangle("fill", startx, starty, width, height)
	end
	love.graphics.rectangle("line", startx, starty, width, height)
	setcolordimtext()
	if mouseover(startx, starty, width, height) or highlighted then
		setcolorwhite()
	end
	cprint(selectortext, startx, starty+10, width)
	setcolorwhite()
end

function update_map_view()
	if up_button.justpressed then
		loadnewmap(loadedmapset.id - 1)
	end

	if down_button.justpressed then
		loadnewmap(loadedmapset.id + 1)
	end

	if left_button.justpressed then
		currentmap = currentmap - 20
	elseif right_button.justpressed then
		currentmap = currentmap + 20
	end
end

function update_tsa_view()
	if left_button.pressed then
		tsatilenumber = tsatilenumber - 1
		tsastart = tsastart - 0x10
	elseif right_button.pressed then
		tsatilenumber = tsatilenumber + 1
		tsastart = tsastart + 0x10
	end
	if pgup_button.justpressed then
		tsatilenumber = tsatilenumber - 66
		tsastart = tsastart - 0x10*66
	elseif pgdown_button.justpressed then
		tsatilenumber = tsatilenumber + 66
		tsastart = tsastart + 0x10*66
	end
end

function draw_map_view()
	draw_gs_header()

	local mapstart = currentmap + 1
	local mapactive = mapstart
	local maptileset = loadedmapset.tiledata
	local tsatileset = loadedmapset.tsadata
	for b=1,4 do
		for a=1,5 do
			local mapbyte = filedata[mapactive]
			local drawx = a * 66 - 70
			local drawy = b * 66 + 100
			draw_tsa_tile(mapbyte, maptileset, tsatileset, drawx, drawy)
			mapactive = mapactive + 1
			drawx = drawx + 16
			drawy = drawy + 16
			if mouseover(drawx, drawy, 64, 64) then
				setcolorhighlight()
				love.graphics.rectangle("fill", drawx, drawy, 68, 68)
				love.graphics.rectangle("fill", drawx, drawy, 68, 68)
				love.graphics.rectangle("fill", drawx, drawy, 68, 68)
				love.graphics.rectangle("line", drawx, drawy, 68, 68)
				love.graphics.rectangle("line", drawx, drawy, 68, 68)
				setcolorwhite()
			end
		end
	end

	--print tsa selector box
	setcolorhighlight()
	love.graphics.rectangle("fill", 500, 10, 33*8+2, 33*15+2)
	love.graphics.rectangle("fill", 500, 10, 33*8+2, 33*15+2)
	love.graphics.rectangle("fill", 500, 10, 33*8+2, 33*15+2)
	setcolorwhite()
	local tsaid = 0
	for i=1,16 do
		for j=1,8 do
			if tsaid <= loadedmapset.tsasize then
				local drawx = 508 + j * 33 - 48
				local drawy = 18 + i * 33 - 48
				draw_tsa_tile(tsaid, loadedmapset.tiledata, loadedmapset.tsadata, drawx, drawy, true)
				tsaid = tsaid + 1
				drawx = drawx + 8
				drawy = drawy + 8
				if tsaid == selected_tsa then
					setcolorchanged()
					love.graphics.rectangle("fill", drawx, drawy, 34, 34)
					love.graphics.rectangle("fill", drawx, drawy, 34, 34)
					love.graphics.rectangle("fill", drawx, drawy, 34, 34)
					setcolorwhite()
				end


				if mouseover(drawx, drawy, 32, 32) then
					setcolorhighlight()
					love.graphics.rectangle("fill", drawx, drawy, 34, 34)
					love.graphics.rectangle("fill", drawx, drawy, 34, 34)
					love.graphics.rectangle("fill", drawx, drawy, 34, 34)
					setcolorwhite()
				end
			end
		end
	end
	setcolorhighlight()
	setcolorwhite()
	lprint("Map: "..loadedmapset.name, 10, 50)
	lprint("Room ID/offset: "..byte2hex((currentmap-loadedmapset.mapdata)/20).."/"..dec2hex(currentmap), 10, 60)
	lprint("Selected Tile: "..byte2hex(selected_tsa), 10, 70)
end

function draw_tsa_tile(tileid, artoffset, tsaoffset, xpos, ypos, shrink)
	local tsabyteid = tsaoffset + tileid * 16 - 15
	for y=1, 4 do
		for x=1, 4 do
			local tsabyte = filedata[tsabyteid]
			local tsatile = loadtile(artoffset+tsabyte*16, graphicmode_2bppgb)
			--hardcoded tile check
			for i=1,#mapsets_generic_tileexceptions["ID"] do
				if tsabyte == mapsets_generic_tileexceptions["ID"][i] then
					tsatile = loadtile(mapsets_generic_tileexceptions["TileAddress"][i], graphicmode_2bpgb)
				end
			end

			if tileid == 0 then -- white tile
				tsatile = loadtile(0xAE80, graphicmode_2bppgb)
			end

			if shrink == true then
				drawtile1x(tsatile, xpos+x*8, ypos+y*8)
			else
				drawtile(tsatile, xpos+x*16, ypos+y*16)
			end
			tsabyteid = tsabyteid + 1
		end
	end
end

function draw_tsa_view()
	draw_gs_header()
	--read tiles from 0xbf0
	--draw tiles from indexes in 4x4 grid, with starting byte from 0x158A0
	
	local tsaactive = tsastart
	--crystal castle 	0x158a0
	--cloud castle 		0x15ff0

	local artstart = loadedmapset.tiledata
	local tilenumber = tsatilenumber
	--first index
	for a=1,6 do
		for b=1,11 do
			for y=1, 4 do
				for x=1, 4 do
					local tsabyte = filedata[tsaactive + 1]
					tsaactive = tsaactive + 1
					local tsatile = loadtile(artstart+tsabyte*16, graphicmode_2bppgb)
					--hardcoded tile check
					if tsabyte == 0 or tsabyte > 0x7F then -- white tile
						tsatile = loadtile(0xAE80, graphicmode_2bppgb)
					elseif tsabyte == 0x1b then -- rope
						tsatile = loadtile(0x14100, graphicmode_2bppgb)
					elseif tsabyte == 0x1c then -- rope end
						tsatile = loadtile(0x14110, graphicmode_2bppgb)
					elseif tsabyte == 0x17 or tsabyte == 0x19 then --door tiles
						tsatile = loadtile(0x140c0, graphicmode_2bppgb)
					elseif tsabyte == 0x18 or tsabyte == 0x1a then
						tsatile = loadtile(0x140d0, graphicmode_2bppgb)
					end
					drawtile(tsatile, x*16+b*80-80, y*16+a*80-40)
				end
			end
			lprint("tile "..byte2hex(tilenumber+1), b*80-60, a*80-30)
			tilenumber = tilenumber + 1
		end
	end
	lprint("page start address: "..dec2hex(tsastart), 20, 510)
end
