# ======
#  ESON
# ======


# Global ESON object
ESON = {}

# Expose ESON for browsers
window.ESON = ESON unless typeof window is "undefined"

# Expose ESON for Node.js
module.exports = ESON unless typeof module is "undefined"


