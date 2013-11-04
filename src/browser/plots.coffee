###
# TODO - Make plots rezise with page
###

$ ->
  # Get data from hidden html element
  rollingSumsJson = $.parseJSON($('#hidden-rollingsums-data').text())
  dailyCountsJson = $.parseJSON($('#hidden-dailycounts-data').text())

  # Build date/value arrays for rolling sums
  rollingSumsPoints = []
  for dateVal in rollingSumsJson
    rollingSumsPoints.push [new Date(dateVal.date), dateVal.count]

  # Build date/value arrays for daily counts
  dailyCountsPoints = []
  for dateVal in dailyCountsJson
    dailyCountsPoints.push [new Date(dateVal._id), dateVal.value]

  ###
  # Build accumulative line graph
  ###

  lineGraphEl = $('#line-graph')

  # Graphs need squishing in by 50px -
  # bootstrap adds scroll bars to them otherwise
  lineGraphEl.width lineGraphEl.width() - 50

  # Apply plot
  $.plot lineGraphEl, [rollingSumsPoints], {
    series: {
      show: true
      shadowSize: 0
      lines: {
        lineWidth: 5
        show: true
      }
      points: {show: true}
    }
    grid: {hoverable: true}
    yaxis: {
      ticks: 10
      min: 0
    }
    xaxis: {
      mode: 'time'
      ticks: 10
    }
  }

  ###
  # build bar charts to plot number of each collection created per day
  ###

  barChartEl = $('#bar-chart')

  # set width as the same as the line graph
  # bootstrap sets it to 0 apparently...
  barChartEl.width lineGraphEl.width()

  # setup line graph
  $.plot barChartEl, [dailyCountsPoints], {
    grid: {hoverable: true}
    yaxis: {
      min: 0
      tickDecimals: 0
      labelWidth: 10
    }
    xaxis: {
      mode: 'time'
      ticks: 10
    }
    bars: {
      show: true
      barWidth: 30000000
    }
  }

  ###
  # Add tooltips to all plots
  ###
  
  elems = [lineGraphEl, barChartEl]
  for el in elems
    # Setup tooltip
    el.qtip {
      prerender: true
      content: "Loading..."
      position:{
        viewport: $(window)
        target: "mouse"
        adjust: {x: 7}
      }
      show: true
      style: {
        classes: "ui-tooltip-shadow ui-tooltip-tipsy"
        tip: true
      }
    }

    # Bind hover event
    el.bind "plothover", (event, coords, item) ->
      self = $(this)
      api = $(this).qtip()
      previousPoint = undefined
      content = undefined

      unless item
        api.cache.point = false
        return api.hide(event)

      previousPoint = api.cache.point
      if previousPoint isnt item.dataIndex
        api.cache.point = item.dataIndex
        dateStamp = new Date(item.datapoint[0])
        content = dateStamp.toString('ddd MMM d') + " = " + item.datapoint[1]
        api.set "content.text", content
        api.elements.tooltip.stop 1, 1
        api.show coords

  # Again, graphs end up being too high so add some padding to stop Bootstrap 
  # adding scroll bars
  tabContentElem = $('.plot-tab')
  tabContentElem.height tabContentElem.height() + 20
