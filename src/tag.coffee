# =====
#  TAG
# =====


# Tag class
# ---------
#
# Tag class is an official representation of Tag structure from ESON format.
# It has properties `id` (tag identifier) and `data` (tagged value).
# It is the only structure stringified to ESON tag .
# It can be parsed using ESON.struct_parse .

Tag = (id, data)->
    @id = id
    @data = data
    return this

# Expose Tag to the world
ESON.Tag = Tag
