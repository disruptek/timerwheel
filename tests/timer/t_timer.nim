discard """
  cmd:      "nim c -r --styleCheck:hint --panics:on $options $file"
  matrix:   "--gc:arc; -d:widthBits:8 -d:total:32"
  targets:  "c"
  nimout:   ""
  action:   "run"
  exitcode: 0
  timeout:  60.0
"""


include ../../src/timerwheel/timer


block:
  var t = initTimer(1)
  var count = 0
  var event0 = initTimerEvent(proc(args: pointer = nil) =
    inc count)

  # One shot
  discard t.add(event0, 10)

  doAssert count == 0
  t.poll(10)
  doAssert count == 1, $count

  # Repeat five times
  discard t.add(event0, 10, 5)
  for i in 0 ..< 5:
    t.poll(10)
  doAssert count == 6

  discard t.add(event0, 16, 1)
  t.poll(17)
  doAssert count == 7, $count

  discard t.add(event0, 25, 1)
  t.poll(25)
  doAssert count == 8

  ## Repeat forever
  discard t.add(event0, 1, -1)

  for i in 0 ..< 10:
    t.poll(1)
  doAssert count == 18, $count


block:
  var t = initTimer(1)
  var count = 0
  var event0 = initTimerEvent(proc(args: pointer = nil) =
    inc count)

  var event1 = initTimerEvent(proc(args: pointer = nil) =
    discard)

  let n1 = t.add(event0, 15)
  t.cancel(n1)
  # cancel multi times
  t.cancel(n1)
  t.cancel(n1)
  t.poll(16)
  doAssert count == 0

  let n2 = t.add(event0, 198)
  discard t.add(event1, 12)
  t.poll(13)

  t.cancel(n2)

  t.poll(200)

  doAssert count == 0, $count


  let n3 = t.add(event0, 18)
  discard t.add(event1, 12)
  t.cancel(n3)
  t.poll(13)
  doAssert count == 0, $count


block:
  var t = initTimer(10)
  var count = 0
  var event0 = initTimerEvent(proc(args: pointer = nil) = 
    inc count)

  var a = t.add(event0, 20)
  var b = t.add(event0, 15)


  t.cancel(b)
  poll(t, 4)
  poll(t, 1)
  t.cancel(a)
  poll(t, 200)
  doAssert count == 0, $count

block:
  var t = initTimer(1)
  var count = 0
  var event0 = initTimerEvent(proc(args: pointer = nil) = 
    inc count)

  for i in 1 .. 10:
    discard t.add(event0, 10)

  poll(t, 20)
  doAssert count == 10, $count

# block:
#   var t = initTimer(1)
#   var count = 0
#   var event0 = initTimerEvent(proc(args: pointer = nil) = 
#     inc count)


#   var event1 = initTimerEvent(proc(args: pointer = nil) = echo "first")
#   var event2 = initTimerEvent(proc(args: pointer = nil) = echo "second")

#   discard t.add(event1, 2, -1)
#   while true:
#     echo t
#     # echo t.wheel.slotsToString(0)
#     poll(t, 2)



# echo t
# echo t.wheel.slotsToString(0)
# while t.wheel.taskCounter != 0:
#   poll(t, 1000)
#   echo t

# echo t
