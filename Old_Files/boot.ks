// Red Sky Aerospace
// General boot script
// TODO: additional refactoring - see episode 28 @ 45:11

// Set up terminal
clearscreen.

// Boot and program
// set ship:control:pilotmainthrottle to 0.
// if hasNewCommand() fetchAndRunNewInstructions().
// else if fileExists("startup.ks") run startup.ks.

// General Functions
function notify {
  parameter message.
  hudtext("kOS: "+message,3,2,3,green,true).
}

function circle_bearing {
 parameter p1,p2.
 return mod(360+arctan2(sin(p2:lng-p1:lng)*cos(p2:lat),cos(p1:lat)*sin(p2:lat)-sin(p1:lat)*cos(p2:lat)*cos(p2:lng-p1:lng)),360).
}

function circle_distance {
 parameter p1,p2,radius.
 local A is sin((p1:lat-p2:lat)/2)^2 + cos(p1:lat)*cos(p2:lat)*sin((p1:lng-p2:lng)/2)^2.
 return radius*constant():PI*arctan2(sqrt(A),sqrt(1-A))/90.
}

function fileExists {
 parameter n.
 list files in fl.
 for f in fl if f:name=n return 1.
 return 0.
 }

function hasNewCommand {
  switch to 0.
  local k is fileExists(commandName()).
  switch to 1.
  return k.
}

function fetchAndRunNewCommand {
  copypath("0:/"+commandName(),1).
  rename commandName() to "tmp.exec.ks".
  run tmp.exec.ks.
}

function commandName {
  if core:part:tag = "" assignCoreTagname().
  return core:part:tag + "update.ks".
}

function assignCoreTagname {
  local n is "".
  until n:length = 14 {
    set n to n + (random + ""):remove(0,2).
    if n:length > 14 set n to n:substring(0,14).
  }
  set core:part:tag to n.
}

// Run mission file
//runpath("0:/missions/X4/X4.mission.ks").
//runpath("0:/missions/X4/test.ks").
copypath("0:/missions/X4/X4.mission.ks","1:/").
run X4.mission.ks.
