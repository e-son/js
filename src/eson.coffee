# ======
#  ESON
# ======

# This should be the first file to merge

# Global ESON object
ESON = {}

# Expose ESON for browsers
window.ESON = ESON unless typeof window is "undefined"

# Expose ESON for Node.js
module.exports = ESON unless typeof module is "undefined"

# Tags tree root
# Look at tag tree documentation in registry.coffee
# Defined here, because this is the first file of merge
ESON.tags = {}