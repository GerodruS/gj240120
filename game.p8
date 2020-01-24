pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
 player_offset=3
 players_start={
  {0,0},
  {127,127}
 }
 
 enable_mouse=false
 if (enable_mouse) poke(0x5f2d,1)

 players={
  {0,0},
  {127,127}
 }
 
 scores={0,0}
 
 targets={}
 generate_targets()
 
 fizzlefader=new_fizzlefader()
end

function _update60()
 if count(targets)==0 then
	 if (btnp(🅾️)) generate_targets()
	 return
 end

 for i=0,1 do
  local p=i+1
  local d=1
  
  if btn(🅾️,i) then
	  if (btnp(➡️,i)) players[p][1]+=d
		 if (btnp(⬅️,i)) players[p][1]-=d
		 if (btnp(⬆️,i)) players[p][2]-=d
		 if (btnp(⬇️,i)) players[p][2]+=d
  else
   if (btn(➡️,i)) players[p][1]+=d
		 if (btn(⬅️,i)) players[p][1]-=d
		 if (btn(⬆️,i)) players[p][2]-=d
		 if (btn(⬇️,i)) players[p][2]+=d
  end
  
  if enable_mouse and i==0 then
   players[p][1]=stat(32)
   players[p][2]=stat(33)
  end

  players[p][1]=max(0,players[p][1])
  players[p][1]=min(127,players[p][1])
  players[p][2]=max(0,players[p][2])
  players[p][2]=min(127,players[p][2])
 
  if is_fire(i) then
   local target_to_remove
   for t=1,count(targets) do
		  local dx=targets[t][1]-players[p][1]
		  local dy=targets[t][2]-players[p][2]
		  
		  local plus_score=0
		  if dx==0 and dy==0 then
		   plus_score=10
		  elseif abs(dx)<3 and abs(dy)<3 then
		   plus_score=4
		  elseif abs(dx)<4 and abs(dy)<4 then
		   plus_score=1
		  end
		  
		  if (0<plus_score) target_to_remove=targets[t]
		  scores[p]+=plus_score
		 end
		 
		 if target_to_remove~=nil then
		  del(targets,target_to_remove)
   else
    scores[p]-=10
   end
  end 
 end
end

function _draw()
-- cls()
 fizzlefader.draw(400)
 map(0,0,0,0)
 
 if count(targets)==0 then
	 color(9)
	 print('player 1: ' .. scores[1],25,58)
	 print('player 2: ' .. scores[2],25,64)
	 color(7)
	 print('press 🅾️ to continue',25,70)
  return
 end
 
 local show_targets=
  equal(players[1],players_start[1]) and equal(players[2],players_start[2]) or
  equal(players[1],players_start[2]) and equal(players[2],players_start[1])
 
 if show_targets then
	 for i=1,count(targets) do
	  spr(6,targets[i][1]-player_offset,targets[i][2]-player_offset)
	 end
 end
  
 spr(1,players[1][1]-player_offset,players[1][2]-player_offset)
 spr(2,players[2][1]-player_offset,players[2][2]-player_offset)

 color(9)
 print(scores[1],60,2)
-- print(scores[2],60,127-6)
 print(stat(1),60,127-6)
end
-->8
function equal(a,b)
 return a[1]==b[1] and a[2]==b[2]
end

function generate_targets()
 for i=1,8 do
  local dx=i%2==0 and 10 or 64
  local dy=flr(i/2)%2==0 and 10 or 64
	 add(targets,{
	   flr(rnd(64-10))+dx,
	   flr(rnd(64-10))+dy
	  })
 end
end

function is_fire(p)
 return
  btnp(❎,p) or
  p==0 and mouse_clicked()
end

function mouse_clicked()
 if enable_mouse then
  local state=stat(34)
  if previous_mouse_state~=state then
   previous_mouse_state=state
   return state==1
  end
 end
 return false
end
-->8
function new_fizzlefader()
 local x = 0
 local y = 0
-- local c = 1
 local x2 = 0
 local y2 = 0
 local f = {}
 local step = function()
  -- next pixel
  if x < 127 then
   x += 1
  elseif y < 127 then
   x = 0
   y += 1
  else
   x = 0
   y = 0
--   c = c + 1
--   if c > 15 then
--    c = 0
--   end
  end
  
  -- function for feistel
  -- transform
  --
  -- this is the transform
  -- from antirez's page, but
  -- the final binary and is
  -- 0x7f instead of 0xff to
  -- match pico-8's drawable
  -- range of 0,127
  function f(n)
   n = bxor((n*11)+shr(n,5)+7*127,n)
   n = band(n,0x7f)
   return n
  end
  
  -- permute with feistel net
  -- use x2 as "left", y2 as
  -- "right"
  x2=x
  y2=y
  for round=1,8 do
   next_x2=y2
   y2=bxor(x2,f(y2))
   x2=next_x2
  end
  -- no need for a final
  -- recomposition step
  -- in our case:
  -- we just use x2 and y2
  -- (l and r) directly
 end
 
 f.draw = function(count)  
  for i=0,count do
   pset(x2,y2,0)
   step()
  end
 end

 return f
end
__gfx__
0000000000080000000c0000077777777777777777777777a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000080000000c00007700000000000000000000070aa0aa00000000000000000000000000000000000000000000000000000000000000000000000000
007007000000000000000000700000000000000000000007aa0a0aa0000000000000000000000000000000000000000000000000000000000000000000000000
0007700088080880cc0c0cc070000000000000000000000700a0a000000000000000000000000000000000000000000000000000000000000000000000000000
000770000000000000000000700000000000000000000007aa0a0aa0000000000000000000000000000000000000000000000000000000000000000000000000
0070070000080000000c00007000000000000000000000070aa0aa00000000000000000000000000000000000000000000000000000000000000000000000000
0000000000080000000c0000700000000000000000000007a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000077777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0304040404040404040404040404040500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2324242424242424242424242424242500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
