objs = {}


objs.fib = (n)->
  if n == 0
    return false
  if n == 1
    return true
  return {first: objs.fib(n-1), second: objs.fib(n-2)}


objs.objList = (l)->
  ({text: "Foo", id: i, list:[]} for i in [0..l])


objs.numList = (l)->
  (i.toString() for i in [0..l])


objs.all = do ->
  result = []

  result.push ()->{name: "true", val: true}
  result.push ()->{name: "false", val: false}
  result.push ()->{name: "null", val: null}
  result.push ()->{name: "number", val: 42}
  result.push ()->{name: "string", val: 'I hate using \\ to write \"'}

  result.push ()->
    name: "undefined",
    val: [
      [1, null, undefined, true, (()->), {toESON: ()->undefined}]
      {n:null, u:undefined, t:true, f:(()->), g:{toESON: ()->undefined}}
    ]

  for i in [0..16] by 2
    do ->
      size = i
      result.push ()->{name: "Fib "+size, val: objs.fib(size)}

  for i in [0,1,5,10,50,100]
    do ->
      size = i
      result.push ()->{name: "ObjList "+size, val: objs.objList(size)}

  for i in [0,1,5,10,50,100,1000,10000]
    do ->
      size = i
      result.push ()->{name: "NumList "+size, val: objs.numList(size)}
  return result


window.JSON_TEST_OBJECTS = objs unless typeof window is 'undefined'
module.exports = objs unless typeof module is 'undefined'