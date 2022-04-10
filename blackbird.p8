pico-8 cartridge // http://www.pico-8.com
version 35
__lua__

--INITALISE--

function _init()
  
  --INIT TABLES

  game_state={
    welcome=true,
    intro=false,
    playing=false,
    success=false,
    fail=false,
    recap=false,
    help=false,
    lore=false,
  }
  player={
    x=64,
    y=64,
    speed=2,
    alive=true,
    lean=4,
    thrust=false,
    fire_lvl=1,
    color=0,
    offset=5
  }
  photo={
    x=8,
    y=8,
    width=64,
    height=32,
    color=5,
    bar=0
  }

  factory={
    y=-300,
    x=rnd(128),    
    dy=1,
    dx=0,
    speed=0.6,
    sprite=7+rnd(5),
    color=6,
    type=target
  }  
  
  --INIT VARIABLES

  lives=3
  world_speed=1.2
  intro_count=10
  autopilot=100

  taking_photo=false
  in_range=false
  photo_success=0
  linefill=1

  particle_spawn_no=100
  particle_color=6

  jet_step_y=0
  jet_step_x=0
  jet_spawn_no=3

  sam_spawn_no=1



  --INIT SPAWN LOOPS
  particles={}
  for i=1,particle_spawn_no do
    particle_spawn()
  end

  jets={}
  for i=1,jet_spawn_no do
    jet_spawn()
    -- jet_step_y+=10
    -- jet_step_x+=10
  end

  sams={}
  for i=1,sam_spawn_no do
    sam_spawn()
  end
end

--SPAWN FUNCTIONS--

function jet_spawn()
  local temp={
    y=-rnd(100)-200,
    x=rnd(128),
    dy=1,
    dx=0,
    speed=1+rnd(0.3),
    sprite=12,
    color=1,
    type=enemy,
    step=1
  } 
  add(jets,temp)
end
function sam_spawn()
  local temp={
    y=180+rnd(200),
    x=rnd(100)+20,
    dy=1,
    dx=0,
    speed=0.6+rnd(0.28),
    sprite=13,
    color=129,
    type=enemy
  }
  add(sams,temp)
end
function particle_spawn()
  local temp={
    y=-rnd(200),
    x=rnd(128),
    dy=1,
    color=particle_color,
    speed=4
  }
  add(particles,temp)
end

--MOVE FUNCTIONS--

function player_move()
  player.lean=4
  player.thrust=false 
  if btn(0) then 
      player.x-=player.speed 
      player.lean=5
  end

  if btn(1) then 
      player.x+=player.speed 
      player.lean=6
  end

  if btn(2) then 
      player.y-=player.speed 
      player.thrust=true
      world_speed+=0.1
      if player.y<=20 then
        player.y=20
      end
  end

  if btn(3) then 
      player.y+=player.speed 
      world_speed-=0.1
      if player.y>=100 then
        player.y=100
      end
  end

  if btn(4) and in_range==true
    then 
     taking_photo=true
     if linefill<=photo.width-player.offset-1 
      then
      linefill+=1
      if linefill == photo.width-player.offset-1  then photo_success+=1 end
    end
   else
     taking_photo=false
     linefill=0
  end

end

function factory_move()

  if factory.y<=128 then
    factory.y+=factory.speed+world_speed
  else
    factory.y=-30
    factory.x=rnd(110)+4
    factory.sprite=7+rnd(5)
  end

end

function jets_move()

  for eachjet in all(jets) do
    if eachjet.y<=128 then
     eachjet.y+=eachjet.speed+world_speed
    else
      del(jets,eachjet)
      jet_spawn()
    end
  end

end

function sams_move()

  for eachsam in all(sams) do
    if eachsam.y>=-300 then
      eachsam.y-=(eachsam.speed-world_speed*0.2)
    else
      eachsam.y=128+rnd(10)
      eachsam.x=rnd(120)+4
    end
  end

end

function particles_move()

  for eachparticle in all(particles) do
    if eachparticle.y<=128 then
      eachparticle.y+=eachparticle.speed+world_speed
    else
      del(particles,eachparticle)
      particle_spawn()
    end
  end

end

--DRAW FUNCTIONS--

function draw_photo()
  -- rect(
  --   player.x-photo.width/2+player.offset,
  --   player.y-photo.height/2,
  --   player.x+photo.width/2,
  --   player.y+photo.height/2+player.offset,
  --   photo.color
  -- )
  if in_range==true then 
    print("+",player.x-photo.width/2+player.offset-1,player.y-photo.height/2-2,photo.color+rnd(2)) 
    print("+",player.x+photo.width/2-1,player.y-photo.height/2-2,photo.color+rnd(2)) 
    print("+",player.x-photo.width/2+player.offset-1,player.y+photo.height/2+player.offset-2,photo.color+rnd(2)) 
    print("+",player.x+photo.width/2-1,player.y+photo.height/2+player.offset-2,photo.color+rnd(2)) 
  end
  if btn(4) and in_range==true then
    rectfill(
      player.x-photo.width/2+player.offset,
      player.y-photo.height/2,
      (player.x-photo.width/2+player.offset)+linefill,
      player.y+photo.height/2+player.offset,
      5
    )
  end
end

function jets_draw()
  for eachjet in all(jets) do
    pal({[8]=eachjet.color})
    spr(eachjet.sprite,eachjet.x,eachjet.y)
    pal()
    if (abs(eachjet.x-player.x) < 8)
      and
      (abs(eachjet.y-player.y) < 8)
      then
      game_state.playing=false
      game_state.fail=true
    end
  end
end

function sams_draw()
  for eachsam in all(sams) do
    pal({[8]=eachsam.color})
    spr(eachsam.sprite,eachsam.x,eachsam.y)
    pal()
    if (abs(eachsam.x-player.x) < 8)
      and
      (abs(eachsam.y-player.y) < 8)
      then
      -- print("sam collision",10,20,9) 
      game_state.playing=false
      game_state.fail=true
    end
  end
end

function particles_draw()
  for eachparticle in all(particles) do
    pset(eachparticle.x,eachparticle.y,eachparticle.color)
  end
end

function factories_draw()
  pal({[8]=factory.color})
    spr(factory.sprite,factory.x,factory.y)
  pal()

  if
    factory.y > (player.y-photo.height/2)
    and
    factory.y < (player.y+photo.height/2)
    and
    factory.x+6 < (player.x+photo.width/2)
    and
    factory.x > (player.x-photo.width/2)
    then
      print("in range",10,118,6)
      in_range=true
    else
    in_range=false 
  end
end

function _update()
  if game_state.intro==true then  
    particles_move()
  end
  if game_state.playing==true then  
    player_move()
    factory_move()
    jets_move()
    sams_move()
    particles_move()
    if world_speed >=3 then
      world_speed = 3
    end
    if world_speed <=0.2 then
      world_speed = 0.2
    end
  end
end

--DRAW--

function _draw()

  --GAME STATE WELCOME--

  if game_state.welcome==true then 
    cls(5)
    print("blackbird",46,52,7)
    print("196x",56,62,7)
    print("press ❎ to start",30,106,6)
    if btn(5) then
      _init()
      game_state.welcome=false
      game_state.intro=true
    end
  end 

  --GAME STATE INTRO--

  if game_state.intro==true then 
     particle_color=6
    cls(7)
    particles_draw()
    print("enterig ussr airspace in "..flr(intro_count),10,36,6)
    pal({[8]=player.color})
      spr(4,64,autopilot)
    pal()
    if autopilot>64 then
      autopilot-=1
    end
    intro_count-=0.1
    if intro_count <=0 then
      game_state.intro=false
      game_state.playing=true
      intro_count=10
    end
  end 

  --GAME STATE PLAYING--

  if game_state.playing==true then  
    cls(7)
    pal({[8]=6})
      spr(1,100,9)
    pal()
    print(photo_success,110,10,6)
    print("mach "..flr(world_speed),10,10,6)
    draw_photo()
    particles_draw()
    factories_draw()
    jets_draw()
    sams_draw()
    pal({[8]=player.color})
      spr(player.lean,player.x,player.y)
    pal()
  end

  --GAME STATE FAIL--

  if game_state.fail==true then 
    cls(5)
    print("game over",46,56,6)
    intro_count-=0.1
    if intro_count <=0 then
      game_state.fail=false
      game_state.intro=false
      game_state.welcome=true
      intro_count=2
    end
  end

 --HUD--
  -- print("lives "..lives,10,10,6)
  -- print("jet_step_x ="..jet_step_x,10,20,6)
  --print("mach "..flr(world_speed),10,10,6)
  -- print("factory x ".. (factory.x),10,30,6) 
  -- print("player x ".. (player.x),60,30,6) 
  -- print("factory y ".. (factory.y),10,40,6) 
  -- print("player y ".. (player.y),60,40,6) 


  -- print("photo top ".. (player.y-photo.height/2),10,70,1) 
  -- print("photo bottom ".. (player.y+photo.height/2),60,70,2)
  -- print("photo left".. (player.x-photo.width/2),10,80,3) 
  -- print("photo right".. (player.x+photo.width/2),60,80,4) 
 --HUD-- 






end
__gfx__
00000000888888880000000000000000000800000008000000008000000000000800000000000000000000000880080000000000000880000000000000000000
00000000080808080000000000000000008080000008000000008000088088008880800000888800800800800808800000808000000000000000000000000000
00700700888888880000000000000000008880000088000000008800088088008880880008888880080808000800800008888800000880000000000000000000
00077000888888880000000000000000008880000080000000000800088088000800880008800880008880000080080000888000000880000000000000000000
00077000888888880000000000000000088888000088000000008800888888000800880080088008000800000808880008808800000880000000000000000000
00700700888888880000000000000000088888000088000000008800808080800888080008800880008880008880000008808800000880000000000000000000
00000000808080800000000000000000880808800808000000008080888888880800880008888880008880008888000000888000000880000000000000000000
00000000888888880000000000000000000000000000000000000000880808088808008008000080088888008888800000080000008008000000000000000000
00000000888888800000000000088800888088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000808080800000000000888880808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888808888800008080808888088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000808080808080800008888888808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888808888888808080808888088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000808080808080808088888888808080800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000888888888888888888080808888888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000880808088808888888888888808080880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000361006610046100561000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100030061001610006100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001200010061002600066000060000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00020351000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
