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