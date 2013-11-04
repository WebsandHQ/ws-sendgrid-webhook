_ = require 'underscore'

###
# Overview metrics route
###
exports.overview = (req, res) ->
  res.render 'overview.jade',
    locals:
      test_local: 1

