pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
 fizzlefader=new_fizzlefader()
 cls()
 player_offset=3
 players_start={
  {0,0},
  {127,127}
 }
 
 enable_mouse=false
 if (enable_mouse) poke(0x5f2d,1)

 players={{},{}} 
 scores={}
 targets={}
 
 init_game() 
end

function _update60()
 if count(targets)==0 then
	 if btnp(🅾️) then
   init_game()
	 end
	 return
 end

 for i=0,1 do
  local p=i+1
  local d=1
  
  if not btn(🅾️,i) then
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
		  local dx=targets[t][1]-players[p][1]-0.5
		  local dy=targets[t][2]-players[p][2]-0.5
		  
		  local plus_score=0
		  local d2=dx*dx+dy*dy
		  if d2<9 then
		   plus_score=10
		  elseif d2<25 then
		   plus_score=4
		  elseif d2<49 then
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
 
 local show_targets=
  equal(players[1],players_start[1]) and equal(players[2],players_start[2]) or
  equal(players[1],players_start[2]) and equal(players[2],players_start[1])
 if (not show_targets) show_targets_t=3
 show_targets_t=max(show_targets_t-1/60,-1)
end

function _draw()
-- cls()
 fizzlefader.draw(400)
 map(0,0,0,0)
 
 if count(targets)==0 then
  color(8)
  print('player 1: ★'..scores[1]..'★',25,58)
  color(12)
  print('player 2: ★'..scores[2]..'★',25,64)
  color(7)
  print('press 🅾️ to continue',25,70)
  return
 end
 
 local show_targets=show_targets_t<=0
 
 if show_targets then
	 for i=1,count(targets) do
--	  spr(6,targets[i][1]-player_offset,targets[i][2]-player_offset)
	  map(18,0,targets[i][1]-8,targets[i][2]-8)
	 end
 end
 
 if target_to_remove~=nil then
  map(18,0,target_to_remove[1]-8,target_to_remove[2]-8)
  target_to_remove=nil
 end
  
 spr(1,players[1][1]-player_offset,players[1][2]-player_offset)
 spr(2,players[2][1]-player_offset,players[2][2]-player_offset)

 color(8)
 print('★'..scores[1]..'★',54,2)
 color(12)
 print('★'..scores[2]..'★',54,127-6)
-- color(7) print(stat(1),6,127-6)

 if 0<=show_targets_t and show_targets_t<2.9 then
  rectfill(62,9,64,13,0)
  color(7)
  print(ceil(show_targets_t),62,9)
 elseif -0.5<=show_targets_t and show_targets_t<0 then
  rectfill(55,9,72,13,0)
  color(7)
  print('hunt!',55,9)
 end
end
-->8
function init_game()
 players[1][1]=0
 players[1][2]=0
 players[2][1]=127
 players[2][2]=127
 scores[1]=0
 scores[2]=0
 generate_targets()
 show_targets_t=0
end

function equal(a,b)
 return a[1]==b[1] and a[2]==b[2]
end

function has_near_target(p)
 for t=1,count(targets) do
  local dx=targets[t][1]-p[1]
  local dy=targets[t][2]-p[2]
  local d2=dx*dx+dy*dy  
  if (d2<49) return true
 end
 
 return false
end

function generate_targets()
 for i=1,8 do
  local dx=i%2==0 and 16+8 or 64+8
  local dy=flr(i/2)%2==0 and 16+8 or 64+8
  local t={
   flr(rnd(3))*16+dx+flr(rnd(3))-2,
   flr(rnd(3))*16+dy+flr(rnd(3))-2
  }
  
  while has_near_target(t) do
   t={
	   flr(rnd(3))*16+dx+flr(rnd(3))-2,
	   flr(rnd(3))*16+dy+flr(rnd(3))-2
	  }
  end
  
  add(targets,t)
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
 local s=1
  
 local function lfsr_14()
	 --14 13 12 2
	 local a=bxor(s,shr(s,1))
	 a=bxor(a,shr(s,2))
	 a=bxor(a,shr(s,12))
	 a=band(a,1)
	 a=shl(a,13)
	 
	 local b=band(s,bnot(1))
	 b=shr(b,1)
	 
	 s=bor(a,b)
	 return s
	end

 return {
  draw = function(n)
   for i=1,n do
    lfsr_14()
    pset(s%128,s/128,0)
   end
  end
 }
end
__gfx__
0000000000080000000c0000077777777777777777777777a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000
0000000000080000000c00007700000000000000000000070aa0aa00000000aaaa00000000000000000000000000000000000000000000000000000000000000
007007000000000000000000700000000000000000000007aa0a0aa00000aaaaaaaa000000000000000000000000000000000000000000000000000000000000
0007700088080880cc0c0cc070000000000000000000000700a0a000000aaa0000aaa00000000000000000000000000000000000000000000000000000000000
000770000000000000000000700000000000000000000007aa0a0aa000aa00000000aa0000000000000000000000000000000000000000000000000000000000
0070070000080000000c00007000000000000000000000070aa0aa0000aa00088000aa0000000000000000000000000000000000000000000000000000000000
0000000000080000000c0000700000000000000000000007a0a0a0a00aa0008888000aa000000000000000000000000000000000000000000000000000000000
000000000000000000000000700000000000000000000007000000000aa0088888800aa000000000000000000000000000000000000000000000000000000000
000000000000000000000000700000000000000000000007000000000aa0088888800aa000000000000000000000000000000000000000000000000000000000
000000000000000000000000700000000000000000000007000000000aa0008888000aa000000000000000000000000000000000000000000000000000000000
0000000000000000000000007000000000000000000000070000000000aa00088000aa0000000000000000000000000000000000000000000000000000000000
0000000000000000000000007000000000000000000000070000000000aa00000000aa0000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000aaa0000aaa00000000000000000000000000000000000000000000000000000000000
000000000000000000000000700000000000000000000007000000000000aaaaaaaa000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000aaaa00000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000070000000000000000000007700000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000077777777777777777777777000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
87887777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777
77808800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
80000080000000000000000000000000000000000000000000000000000099900000000000000000000000000000000000000000000000000000000000000007
88000088000000000000000000000000000000000000000000000000000090900000000000000000000000000000000000000000000000000000000000000007
70080800000000000000000000000000000000000000000000000000000090900000000000000000000000000000000000000000000000000000000000000007
70008000000000000000000000000000000000000000000000000000000090900000000000000000000000000000000000000000000000000000000000000007
70008800008000000000000000000000000000000000000000000000000099900000000000000000000000000000000000000000000000000000000000000007
70000800808800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000088080080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000008800080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000080800800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000080080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000008808008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000080008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000008808088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000080080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000880800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
7000000000000000000000808000000000000000000000000000000000000000000000000000000000000000000000000a0a0a0a000000000000000000000007
70000000000000000000800000800000000000000000000000000000000000000000000000000000000000000000000000aa0aa0000000000000000000000007
7000000000000000000008800000000000000000000000000000000000000000000000000000000000000000000000000aa0a0aa000000000000000000000007
700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0a00000000000000000000000007
7000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000aa0a0aa000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0aa0000000000000000000000007
7000000000000000000000000800800000000000000000000000000000000000000000000000000000000000000000000a0aaaaaa0a000000000000000000007
70000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000aa0aa0000000000000000000007
7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0a0aa000000000000000000007
700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0a00000000000000000000007
7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0a0aa000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0aa0000000000000000000007
7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0a0a0a000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
700000000a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
7000000000aa0aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
700000000aa0a0aa0000000000000000000000000000000000000000000a0a0a0a00000000000000000000000000000000000000000000000000000000000007
70000000000a0a0000000000000000000000000000000000000000000000aa0aa000000000000000000000000000000000000000000000000000000000000007
700000000aa0a0aa0000000000000000000000000000000000000000000aa0a0aa00000000000000000000000000000000000000000000000000000000000007
7000000000aa0aa0000000000000000000000000000000000000000000000a0a0000000000000000000000000000000000000000000000000000000000000007
700000000a0a0a0a0000000000000000000000000000000000000000000aa0a0aa00000000000000000000000000000000000000000000000000000000000007
700000000000000000000000000000000000000000000000000000000000aa0aa000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000a0a0a0a00000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
700000000000000000000000000000000000000000000000a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000007
7000000000000000000000000000000000000000000000000aa0aa00000000000000000000000000000000000000000000000000000000000000000000000007
7000000000000000000000a0a0a0a0000000000000000000aa0a0aa0000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000aa0aa0000000000000000000000a0a000000000000000000000000000000000000000000000000000000000000000000000000007
7000000000000000000000aa0a0aa0000000000000000000aa0a0aa0000000000000000000000000000000000000000000000000000000000000000000000007
700000000000000000000000a0a0000000000000000000000aa0aa00000000000000000000000000000000000000000000000000000000000000000000000007
7000000000000000000000aa0a0aa0000000000000000000a0a0a0a0000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000aa0aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
7000000000000000000000a0a0a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0a0a0a000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0aa0000000000000000000000000007
7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0a0aa000000000000000000000000007
700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0a00000000000000000000000000007
7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0a0aa000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aa0aa0000000000000000000000000007
7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0a0a0a000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
7000000000000000000000000000000000000000000000000000000000000a0a0a0a000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000aa0aa0000000000000000000000000000000000000000000000000000000000007
7000000000000000000000000000000000000000000000000000000000000aa0a0aa000000000000000000000000000000000000000000000000000000000007
700000000000000000000000000000000000000000000000000000000000000a0a00000000000000000000000000000000000000000000000000000000000007
7000000000000000000000000000000000000000000000000000000000000aa0a0aa000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000aa0aa0000000000000000000000000000000000000000000000000000000000007
7000000000000000000000000000000000000000000000000000000000000a0a0a0a000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000009900999000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000000000900909000000000000000000000000000000000000000000000000000000007
70000000000000000000000000000000000000000000000000000000000099900900909000000000000000000000000000000000000000000000000000000007
7000000000000000000000000000000000000000000000000000000000000000090090900000000000000000000000000000000000000000000000000000000c
7000000000000000000000000000000000000000000000000000000000000000999099900000000000000000000000000000000000000000000000000000000c
70000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000077
7777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777cc7c

__map__
0304040404040404040404040404040500000708000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1300000000000000000000000000001500001718000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
