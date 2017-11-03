// RSA Career
// X4 Mission - collect a crew report below 17,500 meters from Zone
//              3B-8G
// 10/24/2017 MRL

// Mission Text: Take a crew in flight below 17,500 meters near Zone 3B-8G.

// Get bearing to waypoint
// Get distance to waypoint
// Knowing the altitude restraint, calculate a max altitude for our
//  flight - we're going to put the apoapsis at that altitude and
//  try to keep it there until we've entered the zone.
// Launch
// Roll to proper heading
// Pitch to 70 degrees to begin ascent
// Adjust throttle to maintain a roughly constant TWR of 1.2
// Monitor ascent to put apoapsis at target altitude
// Since kOS can't do a crew report automatically, the user will have to
//  collect the report once in the zone.
// Once report is collected, kill engine, jettison it, and prepare for
//  landing.
// Land

sas off.
local TARGET_ALTITUDE is 17500.
set message to "".
set runmode to 0.
lock throttle to 0.
local wp is waypoint("Zone 3B-8G").
set targetDistance to circle_distance(ship:geoposition,wp:geoposition,body:radius).
set desiredHeading to circle_bearing(ship:geoposition, wp:geoposition).
set desiredAltitude to (TARGET_ALTITUDE * .75).
set pitchIncrement to (90 - (ship:altitude/desiredAltitude)).

until runmode = 999 {
  if runmode = 0 {
    // Launch
    set message to "Launch".
    lock steering to up.
    set tVal to 1.
    stage.

    // Next runmode
    set runmode to 1.
  }

  if runmode = 1 {
    // Start navigating above 300 meters
    set message to "Climb to 300".

    if altitude > 300 {
      set runmode to 2.
    }
  }

  if runmode = 2 {
    // Climb to altitude
    set message to "Climb to Altitude".
    lock steering to heading(desiredHeading,pitchIncrement).

    if altitude > desiredAltitude {
      set runmode to 3.
    }
  }

  if runmode = 3 {
    // Hold pitch until waypoint is reached
    lock steering to heading(desiredHeading,0).
    set tVal to .75.

    until (targetDistance / 1000) < 5 {
      notify("Cruising to target").
      wait 0.01.
    }

    // Move to next runmode
    set runmode to 4.
  }

  if runmode = 4 {
    // Waypoint reached
    notify("Get science").

    // Cutoff engine
    set tVal to 0.

    // Pause, then jettison engine stack
    wait 2.
    stage.

    // End program.
    set runmode to 999.
  }

  // Progressively pitch over until horizontal at waypoint.
  set pitchIncrement to (90 - (ship:altitude/desiredAltitude)).

  // Update distance to waypoint
  set targetDistance to circle_distance(ship:geoposition,wp:geoposition,body:radius).

  // Update throttle
  set finalTVal to tVal.
  lock throttle to finalTVal.

  // Update telemetry
  print "Message:       " + message +         "       " at (5,3).
  print "Runmode:       " + runmode +         "       " at (5,4).
  print "D_Heading:     " + desiredHeading +  "       " at (5,5).
  print "S_Heading:     " + ship:heading +    "       " at (5,6).
  print "Altitude:      " + altitude +        "       " at (5,7).
  print "WP Distance:   " + targetDistance +  "       " at (5,8).
  print "P_Increment:   " + pitchIncrement +  "       " at (5,9).
}

// Give control to the pilot
notify("Ship control to pilot").
