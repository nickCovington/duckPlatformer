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