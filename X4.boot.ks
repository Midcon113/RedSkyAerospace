// RSA Mission X4
// Crew Report below 19,200 meters near Falanghe's Glory
// (C) Mark Lam, 2017

// Initialization
@LAZYGLOBAL OFF.
local runMode is 0.                                       // Track the current step in the mission sequence
local dTWR is 1.2.                                        // Desired thrust-to-weight ratio, setpoint for pidloop
local kp is 0.                                            // KP for pidloop
local ki is 0.                                            // KI for pidloop
local kd is 0.                                            // KD for pidloop
local minoutput is 0.                                     // Minoutput for pidloop
local maxoutput is 0.                                     // Maxoutput for pidloop
local pThrott is pidloop(kp,ki,kd,minoutput,maxoutput).   // PIDLoop for throttle
local dHdg is 0.                                          // Desired heading to zone
local zDist is 0.                                         // Distance to zone
local wp is waypoint("Falanghe's Glory").                 // Name of the waypoint
local mAlt is 19200.                                      // Mission Altitude Cap/Floor
local dAlt is mAlt * .75.                                 // Desired altitude for science
local pitchIncrement is 0.                                // Incremental pitchover value

// Functions

// Use this to post messages to the HUD
function notify {
  parameter message.
  hudtext(message,3,2,20,yellow,true).
}

// Use to find the initial bearing for the shortest path around a sphere from...
function circle_bearing {
 parameter
  p1, //...this point...
  p2. //...to this point.
 return mod(360+arctan2(sin(p2:lng-p1:lng)*cos(p2:lat),cos(p1:lat)*sin(p2:lat)-sin(p1:lat)*cos(p2:lat)*cos(p2:lng-p1:lng)),360).
}.

// Use to find where you will end up if you travel from...
function circle_destination {
 parameter
  p1,     //...this point...
  b,      // ...with this as your intitial bearing...
  d,      // ...for this distance...
  radius. // ...around a sphere of this radious.
 local lat is arcsin(sin(p1:lat)*cos((d*180)/(radius*constant():pi))+cos(p1:lat)*sin((d*180)/(radius*constant():pi))*cos(b)).
 local lng is 0.
 if abs(Lat) <> 90 {
  set lng to p1:lng+arctan2(sin(b)*sin((d*180)/(radius*constant():pi))*cos(p1:lat),cos((d*180)/(radius*constant():pi))-sin(p1:lat)*sin(lat)).
 }.
}

// Mission Sequence Loop
set runMode to 0.
clearscreen.

until runMode = 9999 {
  // Ensure Connection to KSC
  if runMode = 0 {
    if ship:connection:isconnected {
      notify("Connection to KSC Confirmed").
      wait 2.
      set runMode to 1.
      } else {
      notify("NO CONNECTION TO KSC").
      notify("MISSON ABORT").
      set runMode to 9999.
    }
  }

  // Launch
  if runMode = 1 {
    notify("Launch sequence initiated...").
    wait 1.
    notify("3...").
    wait 1.
    notify("2...").
    wait 1.
    notify("1...").
    wait 1.
    notify("Launch!").
    lock throttle to .75.
    stage.
    wait 2.
    if ship:verticalspeed > 1.0 {
      notify("On our way!").
      set runMode to 2.
      } else {
      notify("Negative engine function - abort").
      lock throttle to 0.
      set runMode to 9999.
    }
  }

  // Roll to proper heading, ascend to 250 meters
  if runMode = 2 {
    notify("Roll program initiated...").
    //set dHdg to circle_bearing(ship:geoposition,wp:geoposition).
    set dHdg to wp:geoposition:heading.
    lock steering to heading(dHdg,90).
    until ship:altitude > 250 {
      wait 0.01.
    }
    set runMode to 3.
  }

  // Begin pitchover
  if runMode = 3 {
    notify("Beginning pitchover...").
    lock steering to latlng(wp:geoposition:lat,wp:geoposition:lng):altitudeposition(dAlt).
    wait 2.
    set runMode to 4.
  }

  // Monitor apoapsis, aiming to meet required parameters
  if runMode = 4 {
    notify("Climbing to desired altitude: " + dAlt).
    until ship:altitude > dAlt {
      set pitchIncrement to (90 - (ship:altitude/dAlt)).
      //lock steering to heading(dHdg, pitchIncrement).
      wait 0.001.
    }
    lock steering to heading(dHdg, 0).
    lock throttle to 0.5.
    set runMode to 5.
  }

    // On burnout, jettison boost stage

    // When reaching target, do science

    // When science is done return control to pilot to execute descent and landing
}
