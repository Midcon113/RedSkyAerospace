set MAXIMUM_IMPACT_VELOCITY to 2.

function main {
  initialize_launch().
  perform_ascent().
  perform_circularization().
  transfer_to(Minmus).
  perform__powered_descent().
  gather_science().
  perform_ascent().
  perform_circularization().
  transfer_to(Kerbin).
  perform_unpowered_descent().
}

function initialize_launch {

}

function perform_ascent {

}

function perform_circularization {
  wait until eta:apoapsis < 20.
  lock steering to (prograde).
  lock throttle to 1.
  wait until obt:eccentricity < 0.1.
  lock throttle to 0.
}

function transfer_to {
  local parameter b.

}

function perform_powered_descent {
  lock steering to safe_retrograde().
  until ship:state = "Landed" {
    if velocity_at_impact() > MAXIMUM_IMPACT_VELOCITY {
      lock throttle to 1.
    } else {
      lock throttle to 0.
    }
    wait 0.01.
  }
}

function gather_science {

}

function perform_unpowered_descent {

}

function velocity_at_impact {
  local v0 is -ship:verticalspeed + abs(ship:groundspeed).
  local a is total_acceleration().
  local t is time_to_impact().
  return v0 + a * t.
}

function total_acceleration {
  local a_gravity = body:mu / ((ship:altitude + body:radius)^2).
  local a_thrust = ship:maxthrust / ship:mass.
  return a_gravity - a_thrust.
}

function time_to_impact {
  local d is alt:radar.
  local v is -ship:verticalspeed.
  local a_gravity = body:mu / ((ship:altitude + body:radius)^2).
  return (sqrt(v^2+2*a*d)-v)/a_gravity.
}

function safe_retrograde {
  if ship:verticalspeed < 0 return ship:srfretrograde.
  return heading(90,90).
}

main ().
