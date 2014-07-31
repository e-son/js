# =========
# Stringify
# =========


# Stringify overview
# ------------------
#
# ESON.stringify tries to match JSON.stringify behavior.
# Object can define own .toESON() which is preferred to .toJSON() but
# both can be used to define value to be stringified.
# In lists and tags unserializable values (functions, undefined, ...) are
# converted to nulls. In all other cases unserializable values are ignored.
#
# Implementation of stringify concatenates strings only once - at the end.
# During the object searching these strings are pushed to array named prefix.


# Internal stringify function, pushes strings to array
# Returns whether value is serializable
_stringify = (value, prefix)->

  # Only interesting type is 'object'
  if typeof value is 'object'

    if value == null
      prefix.push 'null'

    # Object can provide custom value to stringify
    else if typeof value.toESON is 'function'
      return _stringify value.toESON(), prefix

    # Support JSON's custom value
    else if typeof value.toJSON is 'function'
      return _stringify value.toJSON(), prefix

    # Tag
    else if value instanceof Tag
      prefix.push '#'
      prefix.push value.id
      prefix.push ' '
      unless _stringify value.data, prefix
        # Inside tags, unserializable values are printed like null-s
        prefix.push 'null'

    # Array
    else if value instanceof Array
      prefix.push '['   # Open array
      comma = false   # There's no comma before first element
      for x in value
        prefix.push ',' if comma
        unless _stringify x, prefix
          # In arrays, unserializable values are printed like null-s
          prefix.push 'null'
        comma = true   # Separate next element
      prefix.push ']'   # Close object

    # Otherwise, object is supposed to be an unordered map
    else
      prefix.push '{'   # Open object
      comma = false   # There's no comma before first element
      for k,v of value
        # To effectively avoid unserializable values,
        # here is some repetitive code which inspects them
        if (typeof v is "object")
          # Most of the objects should be serializable
          prefix.push ',' if comma
          prefix.push JSON.stringify(k)
          prefix.push ':'
          unless _stringify v, prefix
            # This happens only if toESON / toJSON returns unserializable.
            # Supposing this won't happen, handling is not effective.
            prefix.pop() if comma
            prefix.pop()
            prefix.pop()
          else
            # Serialization was successful
            comma = true   # Separate next element
        else
          # Non-objects we can directly serialize by JSON
          str = JSON.stringify(v)
          unless str is undefined
            prefix.push ',' if comma
            prefix.push JSON.stringify(k)
            prefix.push ':'
            prefix.push str
            comma = true   # Separate next element

      prefix.push '}'   # Close object

    return true

  # All the other types are stringified like JSON
  else
    str = JSON.stringify(value)
    unless str is undefined
      prefix.push str
      return true
    else
      return false


# Public stringify function
# Initializes and concatenates list of output tokens
stringify = (value)->
  l = []
  if _stringify(value,l)
    return l.join('')
  else return undefined


# Expose stringify to the world
ESON.stringify = stringify
