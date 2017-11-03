// Red Sky Aerospace
// General boot script

// Set up terminal
clearscreen.

// Initialize Mission name
set mission to "X4".

// Boot and program
set ship:control:pilotmainthrottle to 0.
if hasNewCommand() fetchAndRunNewInstructions().
else if hasStartupScript() runStartupScript().

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
  local result is fileExists(commandName()).
  switch to 1.
  return result.
}

function hasStartupScript { return fileExists("startup.ks"). }

function runStartupScript { run startup.ks. }

function fetchAndRunNewCommand {
  fetchNewCommand().
  runNewCommand().
}

function fetchNewCommand { copypath("0:/"+commandName(),1). }

function runNewCommand {
  rename commandName() to "tmp.exec.ks".
  run tmp.exec.ks.
}

function commandName {
  if not coreHasTagName () assignCoreTagname().
  return core:part:tag + "update.ks".
}

function coreHasTagName { return core:part:tag <> "". }

function assignCoreTagname {
  local n is "".
  until n:length = 14 {
    set n to n + (random + ""):remove(0,2).
    if n:length > 14 set n to n:substring(0,14).
  }
  set core:part:tag to n.
}
