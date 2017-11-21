// RSA Mission X4
// Crew Report below 19,200 meters near Falanghe's Glory
// (C) Mark Lam, 2017

// Initialization
@LAZYGLOBAL OFF.
local runMode is 0.                                       // Track the current step in the mission sequence
local thrott is 0.                                        // Throttle setting
local dTWR is 1.2.                                        // Desired thrust-to-weight ratio, setpoint for pidloop
local kp is 0.01.                                         // KP for pidloop
local ki is 0.006.                                        // KI for pidloop
local kd is 0.006.                                        // KD for pidloop
local minoutput is 0.                                     // Minoutput for pidloop
local maxoutput is 1.                                     // Maxoutput for pidloop
local pThrott is pidloop(kp,ki,kd,minoutput,maxoutput).   // PIDLoop for throttle
local dHdg is 0.                                          // Desired heading to zone
local zDist is 0.                                         // Distance to zone
local wp is waypoint("Wernher's Legacy").                       // Name of the waypoint
local mAlt is 19200.                                      // Mission Altitude Cap/Floor
local dAlt is mAlt * 0.75.                                // Desired altitude for science
local pitchIncrement is 0.                                // Incremental pitchover value
local g is ship:body:mu/ship:body:mass.                   // Gravitational Constant
local gm is 0.
local r is 0.
local resList is "".
local res is "".

// Functions

// Use this to post messages to the HUD
function notify {
  parameter message.
  hudtext(message,3,2,20,yellow,true).
}

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

function setThrottle {
  //set thrott to thrott + pThrott:Update(time:seconds,ship:mass*g/ship:availablethrust).
  set thrott to dTWR * ship:mass * g / ship:availablethrust.
}

Function findG
{
    parameter A.
    set gm to Constant():G * body:mass.
    set r to A + body:radius.
    set g to gm/(r^2).
    return g.
}

Function SetThrottleTWR
{
    Parameter TWR.
    If Ship:AvailableThrust > 0
    {
        Set thrott to TWR * findG(ship:altitude) * (ship:mass/ship:availablethrust).
        if thrott > 1 {Set thrott to 1.}
        lock throttle to thrott.
    }
}

function checkStaging {
  if ship:availablethrust = 0 {
      if stage:number <> 0 {
        wait 2.
        stage.
        wait 2.
        return true.
      } else {
        sas on.
        set ship:control:mainthrottle to 0.
        //set runMode to 9999.
        return false.
      }
    } else {
      // setThrottle().
      SetThrottleTWR(dTWR).
      return true.
    }
    // if stage:number = 0 {
    //   // Final stage - Cleanup
    //   sas on.
    //   set ship:control:mainthrottle to 0.
    //   //lock steering to srfprograde.
    //   set runMode to 9999.
    // } else {
    //   // Not final stage - drop stage and fire the next.
    //   wait 2.
    //   stage.
    //   wait 2.
    // }
}
//}

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
      set thrott to 0.75.
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
    lock steering to heading(dHdg, 85).
    wait 2.
    set runMode to 4.
  }

  // Monitor apoapsis, aiming to meet required parameters
  // TODO - change this out to simply track distance to waypoint, and move
  // staging logic out of the runMode checks
  if runMode = 4 {
    notify("Climbing to desired altitude: " + dAlt).
    set pThrott:setpoint to dTWR.
    until ship:altitude > dAlt {
      set pitchIncrement to max(1, 85 * (1 - ALT:RADAR / dAlt)).
      lock steering to heading(dHdg, pitchIncrement).
      if checkStaging() {
        lock throttle to thrott.
        wait 0.001.
      } else {
        // No more thrust available
        lock steering to latlng(wp:geoposition:lat,wp:geoposition:lng):altitudeposition(dAlt).
        set runMode to 5.
      }
    }
    lock steering to latlng(wp:geoposition:lat,wp:geoposition:lng):altitudeposition(dAlt).
    set runMode to 5.
  }

  // We're now at desired altitude or all staged out
  if runMode = 5 {
    notify("Cruising...").
    // How far are we from waypoint - must be within 8.5 km for credit
    set zDist to wp:altitudeposition - ship:altitude.
    until zDist < 8500 {
      checkStaging().
      wait .01.
    }
    notify("In the target area - collect science!").
    wait 5.
    set runMode to 6.
  }

  // Time to clean up
  if runMode = 6 {
    notify("Exiting the area...").
    until checkStaging() = false {
      checkStaging().
      wait .01.
    }
    set runMode to 9999.
  }

  lock throttle to thrott.
}

// Cleanup
unlock steering.
unlock throttle.
