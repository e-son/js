
class Checker

  constructor: (obj)->
    @np = 0
    @ns = 0
    @row =  document.getElementById("output").insertRow(-1)
    @row.insertCell(-1).innerHTML = obj.name
    @obj = obj
    @s = ESON.stringify(obj)

    t1 = + new Date()
    while t1 + 50 > (+ new Date())
      JSON.parse(@s)
      @np++
    t1 = + new Date()
    for i in [1..@np]
      JSON.parse(@s)
    t2 = + new Date()
    @tp = t2-t1

    t1 = + new Date()
    while t1 + 50 > (+ new Date())
      JSON.stringify(@obj)
      @ns++
    t1 = + new Date()
    for i in [1..@ns]
      JSON.stringify(@obj)
    t2 = + new Date()
    @ts = t2-t1


  testS: (f)->
    t1 = + new Date()
    try
      for i in [1..@ns]
        f(@obj)
      t2 = + new Date()
      @row.insertCell(-1).innerHTML =
        "Stringify " + @ns + " times: "+ (t2-t1) + "ms to " + @ts + "ms = " +
          Math.ceil(100 * (t2-t1) / @ts)/100.0 + "x JSON"
    catch error
      @row.insertCell(-1).innerHTML = error


  testP: (f)->
    t1 = + new Date()
    try
      for i in [1..@np]
        + new Date()
        f(@s)
      t2 = + new Date()
      @row.insertCell(-1).innerHTML =
        "Parse " + @np + " times: "+ (t2-t1) + "ms to " + @tp + "ms = " +
          Math.ceil(100 * (t2-t1) / @tp)/100.0 + "x JSON"
    catch error
      @row.insertCell(-1).innerHTML = error


asyncTest = (objs)->
  return unless objs
  obj = objs[0]()
  checker = new Checker(obj)
  checker.testS(ESON.stringify)
  checker.testP(ESON.parse)
  setTimeout (()-> asyncTest objs.slice 1), 0

testIt = (sample)->
  objs = JSON_TEST_OBJECTS.all;
  objs.push(() -> sample);
  asyncTest(objs);

window.testIt = testIt unless typeof window is "undefined"
