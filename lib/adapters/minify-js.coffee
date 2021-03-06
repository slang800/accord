Adapter = require '../adapter_base'
W       = require 'when'
_       = require 'lodash'

class MinifyJS extends Adapter
  name: 'minify-js'
  extensions: ['js']
  output: 'js'
  supportedEngines: ['uglify-js']
  isolated: true

  # schema is disabled right now because it doesn't cover all the properties
  #constructor: (args...) ->
  #  super(args...)
  #  @options.schema.sourceMap =
  #    type: 'boolean'
  #    default: true

  _render: (job, options) ->
    options.sourceMap ?= true
    origionalOptions = _.clone(options)

    #options = @options.validate(options)
    if options.sourceMap
      options.outSourceMap = 'out.js.map'
      delete options.sourceMap

    W.try(@engine.minify, job.text, _.extend(options, fromString: true))
      .then (res) ->
        if origionalOptions.sourceMap
          res.code = res.code.replace(
            /\/\/# sourceMappingURL=out\.js\.map$/
            ''
          )
          res.map = JSON.parse(res.map)
          delete res.map.file
        job.setText(res.code, res.map)

module.exports = MinifyJS
