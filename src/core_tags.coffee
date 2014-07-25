# ==============
# Core namespace
# ==============


# Set of built-in tag revivers
ESON.tags.core =

  # Datetime should be ISO format, but it can be anything Date accepts
  datetime: (str)-> new Date(str)


# Tell Date how to stringify
# It has built-in tag and uses ISO format
Date.prototype.toESON = ()->
  new Tag 'core/datetime', @toISOString()