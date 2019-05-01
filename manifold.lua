-- Manifold
-- v0.0.1 @carltesta
-- https://llllllll.co/t/manifold
--
-- Multieffects Engine and Script
--
-- audio input goes in channel 1(L)
--
-- K1 held is alt
--
-- K2 - delay on/off
-- K3 - pitchshifter on/off
-- E1 - master volume
-- E2 - delay time
-- E3 - pitch shift rate
--
-- alt + K2 - FREEZE on/off
-- alt + K3 - amp mod on/off
-- alt + E3 - amp mod frequency
-- 
-- assign MIDI CC to parameters
-- for greater control

local Formatters = require 'formatters'
local toggle = {0,0,0,0}

function randomFloat(lower, greater)
    return lower + math.random()  * (greater - lower);
end

engine.name = 'Manifold'

function init()
  
  params:add_control("delay","delay",controlspec.new(1,2,'lin',1,1,''))
    params:set_action("delay", function(val) engine.delay(val) redraw() end)
  
  params:add_taper("delayvolume", "delayvolume", -60, 20, -12, -12, "dB")
    params:set_action("delayvolume", function(value) engine.delayvolume(math.pow(10, value / 20)) end)
    
  params:add_taper("delaytime", "delaytime", 0.01, 10, 1, 1, "sec")
    params:set_action("delaytime", function(value) engine.delaytime(value) redraw() end)
    
  params:add_taper("delayfeedback", "delayfeedback", 0, 0.9, 0.5, 0.5, "")
    params:set_action("delayfeedback", function(value) engine.delayfeedback(value) end)
    
  params:add_control("delaynano","delay-nano",controlspec.new(0,1,'lin',1,0,''))
    params:set_action("delaynano", function(val) 
      if val== 1 then 
        params:set("delaytime", randomFloat(0.01,1.0)) 
        params:set("delayfeedback", randomFloat(0.5,0.9))end
      end)
      
  params:add_control("delayshort","delay-short",controlspec.new(0,1,'lin',1,0,''))
    params:set_action("delayshort", function(val) 
      if val== 1 then 
        params:set("delaytime", randomFloat(0.1,1.0)) 
        params:set("delayfeedback", randomFloat(0.1,0.9))end
        end)
  
  params:add_control("delaymed","delay-med",controlspec.new(0,1,'lin',1,0,''))
    params:set_action("delaymed", function(val) 
      if val== 1 then 
        params:set("delaytime", randomFloat(1.0,8.0)) 
        params:set("delayfeedback", randomFloat(0.1,0.9))end
      end)
      
  params:add_control("delaylong","delay-long",controlspec.new(0,1,'lin',1,0,''))
    params:set_action("delaylong", function(val) 
      if val== 1 then 
        params:set("delaytime", randomFloat(3.0,10.0)) 
        params:set("delayfeedback", randomFloat(0.1,0.9))end
      end)

  params:add_separator ()
  
  params:add_control("ampmod","ampmod",controlspec.new(1,2,'lin',1,1,''))
    params:set_action("ampmod", function(val) engine.ampmod(val) redraw() end)
  
  params:add_taper("ampmodvolume", "ampmodvolume", -60, 20, -12, -12, "dB")
    params:set_action("ampmodvolume", function(value) engine.ampmodvolume(math.pow(10, value / 20)) end)
    
  params:add_taper("ampmodfreq", "ampmodfreq", 0.1, 100.0, 7.0, 7.0, "Hz")
    params:set_action("ampmodfreq", function(value) engine.ampmodfreq(value) redraw() end)
  
  params:add_control("ampmodaudio","ampmod-audio",controlspec.new(0,1,'lin',1,0,''))
    params:set_action("ampmodaudio", function(val) 
      if val== 1 then 
        params:set("ampmodfreq", randomFloat(20.0,100.0)) end
      end)
  
  params:add_control("ampmodfast","ampmod-fast",controlspec.new(0,1,'lin',1,0,''))
    params:set_action("ampmodfast", function(val) 
      if val== 1 then 
        params:set("ampmodfreq", randomFloat(10.0,20.0)) end
      end)
      
  params:add_control("ampmodmed","ampmod-med",controlspec.new(0,1,'lin',1,0,''))
    params:set_action("ampmodmed", function(val) 
      if val== 1 then 
        params:set("ampmodfreq", randomFloat(1.0,10.0)) end
      end)
      
  params:add_control("ampmodslow","ampmod-slow",controlspec.new(0,1,'lin',1,0,''))
    params:set_action("ampmodslow", function(val) 
      if val== 1 then 
        params:set("ampmodfreq", randomFloat(0.1,1.0)) end
      end)
    
  params:add_separator ()  
  
  params:add_control("pitchshift","pitchshift",controlspec.new(1,2,'lin',1,1,''))
    params:set_action("pitchshift", function(val) engine.pitchshift(val) redraw() end)
  
  params:add_taper("pitchshiftvolume", "pitchshiftvolume", -60, 20, -12, -12, "dB")
    params:set_action("pitchshiftvolume", function(value) engine.pitchshiftvolume(math.pow(10, value / 20)) end)
    
  params:add_taper("pitchshiftrate", "pitchshiftrate", 0.25, 4.0, 2.0, 2.0, "")
    params:set_action("pitchshiftrate", function(value) engine.pitchshiftrate(value) redraw() end)
    
  params:add_control("pitchshiftquarter","pitchshift-quarter",controlspec.new(0,1,'lin',1,0,''))
    params:set_action("pitchshiftquarter", function(val) 
      if val== 1 then 
        params:set("pitchshiftrate", 0.25) end
      end)
  
  params:add_control("pitchshifthalf","pitchshift-half",controlspec.new(0,1,'lin',1,0,''))
    params:set_action("pitchshifthalf", function(val) 
      if val== 1 then 
        params:set("pitchshiftrate", 0.5) end
      end)  
  
  params:add_control("pitchshiftdouble","pitchshift-double",controlspec.new(0,1,'lin',1,0,''))
    params:set_action("pitchshiftdouble", function(val) 
      if val== 1 then 
        params:set("pitchshiftrate", 2.0) end
      end)  
      
  params:add_control("pitchshiftrandom","pitchshift-random",controlspec.new(0,1,'lin',1,0,''))
    params:set_action("pitchshiftrandom", function(val) 
      if val== 1 then 
        params:set("pitchshiftrate", randomFloat(0.1,4.0)) end
      end)  
    
  params:add_separator ()

  params:add_control("freeze","freeze",controlspec.new(1,2,'lin',1,1,''))
    params:set_action("freeze", function(val) engine.freeze(val) redraw() end)
  
  params:add_taper("freezevolume", "freezevolume", -60, 20, -12, -12, "dB")
    params:set_action("freezevolume", function(value) engine.freezevolume(math.pow(10, value / 20)) redraw() end)
    
  params:read("/home/we/dust/data/manifold/manifold.pset")
  params:bang()
  
end

function enc(n, d)
  if n == 1 then
    mix:delta("output", d)
  elseif n == 2 then
    if alt == 1 then
      params:delta("freezevolume", d)
    else
      params:delta("delaytime", d)
    end
  elseif n == 3 then
    if alt == 1 then
      params:delta("ampmodfreq", d)
    else
      params:delta("pitchshiftrate", d)
    end
  end
end

function key(n, z)
  if n == 1 then
    alt = z
  elseif n == 2 then
    if alt == 1 then
      if z == 1 then
      toggle[1] = 2 - toggle[1]
      params:set("freeze", toggle[1])
      end
    else
      if z == 1 then
      toggle[2] = 2 - toggle[2]
      params:set("delay", toggle[2])
      end
    end
  elseif n == 3 then
    if alt == 1 then
      if z == 1 then
      toggle[3] = 2 - toggle[3]
      params:set("ampmod", toggle[3])
      end
    else
      if z == 1 then
      toggle[4] = 2 - toggle[4]
      params:set("pitchshift", toggle[4])
      end
    end 
  end
end

function redraw()
  screen.clear()
  screen.move(0,30)
  screen.level(7)
  screen.text("Manifold")
  screen.level(15)
  screen.move(15,50)
  if params:get("delay")==2 then screen.text("delay") end
  if params:get("delay")==2 then screen.move(params:get("delaytime")*12.8,0) screen.line(params:get("delaytime")*12.8,64) end
  screen.stroke()
  screen.move(65,10)
  if params:get("ampmod")==1 then 
    screen.update() end
  if params:get("ampmod")==2 then 
    screen.stroke()
    screen.circle(85,32,(params:get("ampmodfreq")/2)) end
  screen.move(70,30)
  if params:get("ampmod")==2 then screen.text("amp mod") end
  screen.move(40,20)
  if params:get("freeze")==2 then screen.text("FREEZE") end
  --if params:get("freeze")==2 then screen.font_size(util.dbamp(params:get("freezevolume"))*3) print(util.dbamp(params:get("freezevolume"))) screen.text("FREEZE") end
  screen.move(80,40)
  screen.font_size(8)
  if params:get("pitchshift")==2 then screen.text("pitchshifter") end
  screen.move(80,50)
  if params:get("pitchshift")==2 then screen.text(params:get("pitchshiftrate")) end
  --screen.circle(32,32,params:get("ampmodfreq"))
  screen.update()
end
