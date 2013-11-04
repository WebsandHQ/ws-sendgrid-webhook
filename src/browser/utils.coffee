# browser utils.coffee

# grab sSearch_x parameters for use in filters
jQuery.fn.dataTableExt.oApi.fnSetupCopySearchValues = (oSettings, asSearch_copy) ->

  fnServerDataOriginal = oSettings.fnServerData

  oSettings.fnServerData = (sSource, aoData, fnCallback) ->
    for s in aoData
      m = s.name.match /^sSearch_(\d+)$/
      if m
        asSearch_copy[parseInt(m[1])] = s.value

    if fnServerDataOriginal
      try
        fnServerDataOriginal sSource, aoData, fnCallback, oSettings
      catch error
        fnServerDataOriginal sSource, aoData, fnCallback
    else
      $.getJSON sSource, aoData, (json) ->
        fnCallback(json)

  # allow the datatable to be chained to another function.
  return @
