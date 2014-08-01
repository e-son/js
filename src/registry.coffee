# ========
# Registry
# ========


# Tag parsing handlers
# ----------------------
#
# Tag parsing handler is a function bound to the tag identifier, which takes
# parsed data and returns object that is result of tag parsing.
# They are used by standard parse strategy.


# Tag tree
# --------
#
# Tag tree is structure where tag handlers are organized. It's a tree composed
# of namespaces which can contain other namespaces or handlers.
# Namespace is implemented by objects. Tree elements can be addressed
# by paths. Path is a string of object keys needed to be accessed in order to
# the element separated by slash.


# Get tree element by it's path
ESON.resolveTag = (path)->
  tokens = path.split '/'
  act = ESON.tags

  for t in tokens
    # 'act' should be a registered namespace, so we can get its child
    if act is undefined
      # path does not exist
      return undefined
    act = act[t]

  return act


# Deletes entire subtree with root in path if exists
ESON.deleteTag = (path)->
  tokens = path.split '/'
  act = ESON.tags
  last = undefined
  for t in tokens
    # 'act' should be a registered namespace, so we can get its child
    if act is undefined
      return
    last = act
    act = act[t]

  # 'last' is path's final namespace
  # 'act' is deleted thing
  delete last[tokens[tokens.length-1]]


# Register new function / namespace with the tag
# Parent namespace must exist but path must be free
ESON.registerTag = (path, elem)->
  tokens = path.split '/'
  act = ESON.tags
  last = undefined
  for t in tokens
    # 'act' should be a registered namespace, so we can get its child
    if act is undefined
      throw new Error "Parent namespace not registered"
    last = act
    act = act[t]

  # 'last' is path's final namespace
  # 'act' should be undefined in order to not overwrite it
  unless act is undefined
    throw new Error "Path '#{path}' is already registered"
  last[tokens[tokens.length-1]] = elem
