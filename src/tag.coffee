# =====
#  TAG
# =====


# Class Tag
# The only way to create an object which stringifies with tag.
# Meant to be returned by object's toESON()
class Tag

  constructor: (tag, data)->
    @tag = tag
    @data = data

  # Pushes splitted Tag's representation to array for future concatenation
  _tagToESON: (prefix)->
    prefix.push '#'
    prefix.push @tag
    prefix.push ' '
    _stringify @data, prefix


# Expose Tag to the world
ESON.Tag = Tag
