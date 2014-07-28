# =====
#  TAG
# =====


# Tag
# The only way to create an object which stringifies with tag.
# Meant to be returned by object's toESON()
Tag = (tag, data)->
    @tag = tag
    @data = data
    return this

# Expose Tag to the world
ESON.Tag = Tag
