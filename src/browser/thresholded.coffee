###
# This script finds all the elements with the 'thresholded' class, finds the
# child element with the 'settings' class (see below) and colours the parent
# thresholded element appropriately. 2 settings classes can be chained as well
# to create an upper and lower threshold. Examples below.
# 
# The settings class needs to defined as follows:
#
# '(above OR below)-(threshold limit)-(good OR bad)' 
#
# Examples: 'above-10-good', 'below-2-bad'
# 
# Usage example:
#
# <div class='thresholded'>
#   <span class='above-70-good'>71</span>%
# </div>
#
# The above will output 71% with a green colour (or whatever goodColour is)
#
# Chained usage example:
#
# <div class='thresholded'>
#   <span class='above-69-good below-70-bad'>60</span>%
# </div>
#
# The above will output 60% with a red colour (or whatever badColour is)
#
# <div class='thresholded'>
#   <span class='above-69-good below-70-bad'>70</span>%
# </div>
#
# The above will output 70% with a green colour (or whatever green is)
#
# Note: only the last 2 of the chained settings classes will be considered
###

# Define your 'good' and 'bad' colours here
goodColour = '#00b31f'
badColour = '#ff0200'

$ ->
  # Cycle through all the thresholded elements
  for thresholded in $('.thresholded')
    thresholdedParent = $ thresholded

    for child in thresholdedParent.children()
      thresholdChild = $ child
      elClass = thresholdChild.attr 'class'

      # If this element actually has a class
      if elClass
        goodBadSettings = elClass.match /(above|below)-\d+-(good|bad)/g

        # If this element has at least one 'settings' class
        if goodBadSettings 
          for setting in goodBadSettings
            settings = setting.split '-'

            aboveBelow = settings[0]
            threshold = parseFloat settings[1] 
            goodBad = settings[2]

            # Check values are actually numbers
            elVal = parseFloat thresholdChild.text()

            if not isNaN(elVal) and not isNaN(threshold)
              changeCol = false

              switch aboveBelow
                when 'above'
                  if elVal > threshold
                    changeCol = true
                when 'below'
                  if elVal < threshold
                    changeCol = true

              if changeCol
                switch goodBad
                  when 'good'
                    thresholdedParent.css 'color', goodColour
                  when 'bad'
                    thresholdedParent.css 'color', badColour
