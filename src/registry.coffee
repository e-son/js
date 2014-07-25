# ========
# Registry
# ========


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


# Deletes entire tree with root in path if exists
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
# Parent namespace must exist and must be free
ESON.registerTag = (path, data)->
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
  last[tokens[tokens.length-1]] = data


