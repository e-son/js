# ======
#  ESON
# ======


# Global ESON object
ESON = {}

# Expose ESON for browsers
window.ESON = ESON unless typeof window is "undefined"

# Expose ESON for Node.js
module.exports = ESON unless typeof module is "undefined"

# Tags tree root
# Tree is built by objects in nodes and handlers in leafs
# Tree paths use slash seperator
ESON.tags = {}