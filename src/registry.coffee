# ========
# Registry
# ========


# Tags tree root
# Tree is built by objects in nodes and functions in leafs
# Tree paths use slash seperator
ESON.tags = {}


# Get tree element by it's path
ESON.resolveTag = (path)->
  tokens = path.split '/'
  act = ESON.tags
  for t in tokens
    act = act[t]
  return act


# Rewrite specified path to new value
# Path parent must be created
ESON.registerTag = (path, data)->
  tokens = path.split '/'
  act = ESON.tags
  last = undefined
  for t in tokens
    last = act
    act = act[t]
  last[tokens[tokens.length-1]] = data
