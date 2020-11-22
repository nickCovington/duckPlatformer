pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
--variables

function _init()
		player = {
			sp = 1,
			x = 59,
			y = 59,
			w = 8,
			h = 8,
			flp = false,		--flip sprite l/r
			dx = 0,
			dy = 0,
			max_dx = 2,
			max_dy = 3,
			acc = 0.5,
			boost = 4,
			anim = 0,
			running = false,
			jumping = false,
			falling = false,
			sliding = false,
			landed = false
		}
		
		gravity = 0.3
		friction = 0.85
		
		--camera
		cam_x = 0
		
		--map limits
		map_start = 0
		map_end = 1024
end






-->8
--update n' draw

function _update()
		player_update()
		player_animate()
		camera_follow()
end

function _draw()
		cls()
		map(0, 0)
		spr(player.sp, player.x, player.y, 1, 1, player.flp)
end
-->8
--collisions

function collide_map(obj, aim, flag)
		--obj table needs x,y,w,h
		--aim = left/right/up/down
		local x = obj.x
		local y = obj.y
		local w = obj.w
		local h = obj.h
	
		--player hitbox
		local x1 = 0
		local y1 = 0
		local x2 = 0
		local y2 = 0
	
		if aim == "left" then
			x1 = x - 1
			y1 = y + 1
			x2 = x
			y2 = y + h - 2
		elseif aim == "right" then
			x1 = x + w
			y1 = y + 1
			x2 = x + w + 1
			y2 = y + h - 2
		elseif aim == "up" then
			x1 = x + 1
			y1 = y - 1
			x2 = x + w - 1
			y2 = y
		elseif aim == "down" then
			x1 = x + 1
			y1 = y + h
			x2 = x + w - 1
			y2 = y + h
		end
	
		--pixels to tiles
		x1 /= 8
		y1 /= 8
		x2 /= 8
		y2 /= 8
	
		--checks if hitbox is touching solid
		if fget(mget(x1, y1), flag)
		or fget(mget(x1, y2), flag)
		or fget(mget(x2, y1), flag)
		or fget(mget(x2, y2), flag) then
			return true
		else
			return false
		end
end
-->8
--player

function player_update()
		--physics
		player.dy += gravity
		player.dx *= friction	--multiplying by a fraction reduces value
		
		--cntrls
		if btn(⬅️) then
				player.dx -= player.acc
				player.running = true
				player.flp = true
		end
		if btn(➡️) then
				player.dx += player.acc
				player.running = true
				player.flp = false
		end
		
		--slide
		if player.running
		and not btn(⬅️)
		and not btn(➡️)
		and not player.falling
		and not player.jumping then
				player.running = false
				player.sliding = true
		end
		
		--jump
		if btnp(❎)
		and player.landed then
				player.dy -= player.boost
				player.landed = false
		end
		
		--check for up/down collisions
		if player.dy > 0 then
				player.falling = true
				player.landed = false
				player.jumping = false
				
				player.dy = limit_speed(player.dy, player.max_dy)
				
				if collide_map(player, "down", 0) then
						--arguments: table, direction, flag
						player.landed = true
						player.falling = false
						player.dy = 0
						--prevents getting stuck in ground
						player.y -= ((player.y + player.h + 1) % 8) - 1
				end
		elseif player.dy < 0 then
				player.jumping = true
				if collide_map(player, "up", 1) then
						player.dy = 0
				end		
		end
		
		--collisions for left/right
		if player.dx < 0 then
		
				player.dx = limit_speed(player.dx, player.max_dx)
				
				if collide_map(player, "left", 1) then
						player.dx = 0
				end
		elseif player.dx > 0 then
		
				player.dx = limit_speed(player.dx, player.max_dx)
		
				if collide_map(player, "right", 1) then
						player.dx = 0
				end
		end
		
		--stop sliding
		if player.sliding then
				if abs(player.dx) < .2
				or player.running then
						player.dx = 0
						player.sliding = false
				end
		end
				
		player.x += player.dx
		player.y += player.dy
		
		--limit player to map
		if (player.x < map_start) then
				player.x = map_start
		end
		if (player.x > map_end - player.w) then
				player.x = map_end - player.w
		end
end


function player_animate()
		if player.jumping then
				player.sp = 7
		elseif player.falling then
				player.sp = 8
		elseif player.sliding then
				player.sp = 9
		elseif player.running then
				if time() - player.anim > .1 then
						player.anim = time()
						player.sp += 1
						if player.sp > 6 then
								player.sp = 3
						end
				end
		else 
				--player idle
				if time() - player.anim > .3 then
						player.anim = time()
						player.sp += 1
						if player.sp > 2 then
								player.sp = 1
						end
				end
		end
end


function limit_speed(num, maximum)
		return mid(-maximum, num, maximum)
end


function camera_follow()
		cam_x = player.x - 64 + (player.w / 2)
		--keeps camera from showing anything before map starts	
		if (cam_x < map_start) then
				cam_x = map_start
		end
		--keeps camera from showing anything past map's end
		--(map_end - 128) = final screen of map
		if (cam_x > map_end - 128) then
				cam_x = map_end - 128
		end
		
		camera(cam_x, 0)
end
__gfx__
00000000000aa000000aa000000aa000000aa000000aa000000aa000000aa000000aa00000000000000000000000000000000000000000000000000000000000
00000000000a1a00000a1a00000a1a00000a1a00000a1a00000a1a00000a1a00000a1a00000aa000000000000000000000000000000000000000000000000000
00700700000aaa90000aaa90000aaa90000aaa90000aaa90000aaa90000aaa90000aaa90000a1a00000000000000000000000000000000000000000000000000
000770000000a00000aaaa000000a0000000a0000000a0000000a0000000a000aa00a00a000aaa90000000000000000000000000000000000000000000000000
0007700000aaaa000aa55aa000aaaa0000aaaa0000aaaa0000aaaa0000a5aa000a0aaaa00000a000000000000000000000000000000000000000000000000000
007007000aa55aa0aaaaaa000aa55aa00aa55aa00aa55aa00aa55aa00aaa5aa0a0a55a0000aaaa00000000000000000000000000000000000000000000000000
00000000aaaaaa0009000900aaaaaa99aaaaaa00aa99aa00aaaaaa00aa9aa9000a9aa9000aa55aa0000000000000000000000000000000000000000000000000
000000000990099009900990009900000099009900000990009909900900900000090090aa99aa99000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
43444433444334443344433333434343000043333334000000000000000000000000000000000000000000000000000000000000000000000000000000000000
43343344444344434334334444434444003433444433430000000000000000000000000000000000000000000000000000000000000000000000000000000000
44333444443343334434344444333444043434444443434000000000000000000000000000000000000000000000000000000000000000000000000000000000
43333334334333444334333444333334333333444433333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33444433444433443344443333444343344444333344444300000000000000000000000000000000000000000000000000000000000000000000000000000000
43334344444433344334434443343444434443444434443400000000000000000000000000000000000000000000000000000000000000000000000000000000
33434334334334343344433443434334443443344334434400000000000000000000000000000000000000000000000000000000000000000000000000000000
34434433344344333444443334434433444344333344344400000000000000000000000000000000000000000000000000000000000000000000000000000000
44544445444444444444554444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44544444446444444455544444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44555544444444445554444444244424000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444554444444644454455544444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55444455444444444454554444444244000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45445444444644445544544444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
45544555464444445544554442444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44544445444444444544455444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770770077770d0ddd0d0dddd00d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777777777777777ddd0d0dd0ddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7707707777070770dd0ddd0ddd0ddd0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777777777777770ddddddddd0d0d0d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777777777770777dddddddddddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7707707777007777cddcdddcdddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7770077777777777dcddcdcdddd0ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077700770dcdddd00dddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007777770777770000dddddd0ddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0777777777777770ddddddddd0ddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7700700777070777dd0d0dd0dddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777777777777777ddddddd0dddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0770077077700007ddddddd0d0d0ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0777777077777777ddddddd0dd0dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777077777770dddddd0dddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
777007700077777000dddddddd00ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030303030300000000000000000000030303030000000000000000000000000101010100000000000000000000000001010101000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000444040414042404340424042404041404042404043404040414040404240434041404041404040404340404040404340414040404240404340414040434042404340404142404045
0000710000000073000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000525253500058000000000000000000000000000000004600000000000000000000000000000040420000000000000000004000004700000000000000000000004000000000004340
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005152000044404041404040400044404340414040404040424042404341404042404043404040400044424041404040004000004440404041400044404042004000444043004240
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000053000040000000000000000040000000000000400000000000435757575700000000000047460000000000000043004200004000000000404848484840000000000040004043
0000000000700000007200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040004440404140400041004042400040400044000040404640474043404040424041404040400040400040004000404240434000404040424040004043404041714041
0000000000000000000000630000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000705742004000000000000040734000400000400000400000410040724000570047004740400000000040000000000000000000004000000000000000004000000040004040
0000610000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000000000000000000000040434046404040424040004000404140434000434000400040004047440041004047400044404040404340404240404040004040404043404040004000404040004342
0000000000006000000000000062000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000407040414047430040004046460000000040004000000000000040004060720061000000004100400000004140
4445000000000000000000000000004445000000000000000000000000000044450000000000000000000000000000444500000000000044404245000044404141404340434042404045000044004440424040400000474700406042004046464440430040004040400044424040004062000063000043404000000044404040
4040000000000000000000000000004043000000000000000000007100000042430000000063000000000000000000424300000000000000514243000040000000000000400000004646460040004000000000434040414040400040000040400000400040000042400000400000004070007371444000004000440000004041
4040606170710000000000626372734041000000000000000000000000000040410000000000000000000000000000404100000000000000004041610041004440414500410045004445630041000000006100000000000000000041006240410040407242000000400000404340004040404040000000004073400000004243
4040000000000000000000000000004040000000000044450000000000000043400000000000000000000000000000434000610000000000004340000041004200004000424140004342004040434042404240404041404040424040000043400000420040434000434000000000004000000040004240404200424043004040
4240464646464644424546464646464043000000004441400000000000000041430000000000000000000000000000414300000000000000004143000000004000000000000000004140000000000000000000470000000000000000400057400000000000000000400000440000004600450000000000000000400000004140
4043404242414340414342434041424042404142434042414140434142404342424041424340424141404341424043424240414243404241414042404142434042414140434142404342404042404041404340404240404140404040404240404043404042404340404040404040434040404240434042404040404042404040
5352515051525153535150515251515250515251525351505253505351535052505152515253515052535053515350525051525152535150525350515251525351505253505351535052515052535151525052515352535052515052535151525052515352535052515052535151525052515052535151525052515352535052
5053505250515350515250535152505253505153515253525153525152505150535051535152535251535251525051505350515351525352515353505153515253525153525152505150535251525052535351525052515051535251525052535351525052515051535251525052535351535251525052535351525052515051
