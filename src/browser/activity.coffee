###
activity.coffee - code for the activity page
###

$(document).ready ->
  # these are the table items selected.
  selected = []
  detailsColsHidden = false
  statsColsHidden = false
  campaignsColsHidden = false
  campaignAction = 'add'  # or remove
  campaignLabel = ''
  sSearch_copy = []

  oTable = $('#activity-table').dataTable(
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>"
    # "sDom": "<'row-fluid'<'span6'l><'span6'>r>t<'row-fluid'<'span6'i><'span6'p>>"
    "bProcessing": true
    'bPaginate': true
    "bServerSide": true
    "sAjaxSource": "activity_ajax"
    "sServerMethod": "GET"
    "sPaginationType": "bootstrap"
    "bFilter": true
    "bAutoWidth": false
    "aoColumns": [
      { mDataProp: "_id", sType: "string" }
      { mDataProp: "email", sType: "string" }
      { mDataProp: "signupDate", sType: "date" }
      { mDataProp: "signupAgeDays", sType: "numeric" }
      { mDataProp: "invited", sType: "string" }
      { mDataProp: "hasUser", sType: "string" }
      { mDataProp: "userDate", sType: "date" }
      { mDataProp: "userAgeDays", sType: "numeric"}
      { mDataProp: "displayName", sType: "string" }
      { mDataProp: "company", sType: "string" }
      { mDataProp: "numPersonas", sType: "numeric" }
      { mDataProp: "personaEmails", sType: "string" }
      { mDataProp: "lastLoginDate", sType: "date" }
      { mDataProp: "lastLoginAgeDays", sType: "numeric"}
      { mDataProp: "numLogins", sType: "numeric"}
      { mDataProp: "lastActivityDate", sType: "date" }
      { mDataProp: "lastActivityAgeDays", sType: "numeric"}
      { mDataProp: "numActivities", sType: "numeric" }
      { mDataProp: "numAccounts", sType: "numeric" }
      { mDataProp: "numProjects", sType: "numeric" }
      { mDataProp: "numRequirements", sType: "numeric" }
      { mDataProp: "numTasks", sType: "numeric" }
      { mDataProp: "numFriends", sType: "numeric" }
      { mDataProp: "friendsEmails", sType: "string" }
      { mDataProp: "campaignLabels", sType: "string" }
    ]

    "fnRowCallback": (nRow, aData, iDisplayIndex) ->
      # set the line in the table to selected IF the row is in the 'selected' array
      if aData._id in selected
        $(nRow).addClass 'info'
      return nRow

  )
  # get at the filter values for ajax selection filtering later on.
  .fnSetupCopySearchValues(sSearch_copy)
  .columnFilter({
    aoColumns:[
      null # 0. _id
      { sSelector: "#emailFilter", type: "text"} 
      null  # 2. signupDate
      { sSelector: "#signupAgeFilter", type: "number-range"}
      { sSelector: "#invitedFilter", type: "select", values: ['true', 'false']}
      { sSelector: "#hasUserFilter", type: "select", values: ['true', 'false']}
      null # 6. userDate
      { sSelector: "#userAgeFilter", type: "number-range"}
      { sSelector: "#nameFilter", type: "text"}
      { sSelector: "#companyFilter", type: "text"}
      null # 10. numPersonas
      null # 11. personaEmails
      null # 12. lastLoginDate
      { sSelector: "#lastLoginAgeFilter", type: "number-range"}
      null # 14. numLogins
      null # 15. lastActivityDate
      { sSelector: "#lastActivityAgeFilter", type: "number-range"}
      null # 17. numActivities
      null # 18. numAccounts
      null # 19. numProjects
      null # 20. numRequirements
      null # 21. numTasks
      null # 22. numFriends
      null # 23. friendsEmails
      { sSelector: "#campaignFilter", type: "text"}
    ]
    bUseColVis: true
  })
  .fnSetFilteringDelay()



  # hide a set of columns by number that aren't needed by default.
  _detailsColsCanHide = [0, 2, 6, 11, 12, 15, 23]
  toggleDetailsTableColumns = ->
    detailsColsHidden = if detailsColsHidden then false else true
    _updateVisOnCols _detailsColsCanHide, not(detailsColsHidden)

  _statsColsCanHide = [3, 7, 10, 11, 13, 14, 16, 17, 18, 19, 20, 21, 22]
  toggleStatsTableColumns = ->
    statsColsHidden = if statsColsHidden then false else true
    _updateVisOnCols _statsColsCanHide, not(statsColsHidden)

  _campaignColsCanHide = [24,]
  toggleCampaignTableColumns = ->
    campaignsColsHidden = if campaignsColsHidden then false else true
    _updateVisOnCols _campaignColsCanHide, not(campaignsColsHidden)

  # function to show or hide a column
  _updateVisOnCols = (iCols, state) ->
    _commonIterateArray iCols, (iCol) ->
      oTable.fnSetColumnVis(iCol, state)

  _toggleVisOnCols = (iCols) ->
    _commonIterateArray iCols, (iCol) ->
      bVis = oTable.fnSettings().aoColumns[iCol].bVisible
      oTable.fnSetColumnVis(iCol, if bVis then false else true)

  _commonIterateArray = (cols, fn) ->
    if not _.isArray cols
      iCols = [cols]
    else
      iCols = cols
    for iCol in iCols
      do (iCol) ->
        fn.call fn, iCol

  $('#toggleDetailsCols').click -> toggleDetailsTableColumns()
  $('#toggleStatsCols').click -> toggleStatsTableColumns()
  $('#toggleCampaignCols').click -> toggleCampaignTableColumns()


  # Click event handler
  $('#activity-table tbody tr').live 'click', ->
    aData = oTable.fnGetData(@)
    iId = aData._id
    if not(iId in selected)
      selected.push iId
    else
      selected = jQuery.grep(selected, (v) -> v != iId)
    $(@).toggleClass 'info'
    updateSelectedCount()

  # handle the clearAll button
  $('#clearAll').click ->
    selected = []
    oTable.fnDraw()
    updateSelectedCount()

  # handle the selectAll button
  $('#selectAll').click ->
    $.getJSON 'activity_ajax_select_all', (data) ->
      updateSelectedIds(data.ids)


  _getFilter = ->
    emailCol = 1
    hasUserCol = 5
    invitedCol = 4
    companyCol = 9    
    displayNameCol = 8
    signupAgeCol = 3
    userAgeCol = 7
    lastLoginAgeCol = 13
    lastActivityAgeCol = 16
    campaignLabelsCol = 24
    return {
      email:  sSearch_copy[emailCol]
      hasUser: sSearch_copy[hasUserCol]
      invited: sSearch_copy[invitedCol]
      dislayName:  sSearch_copy[displayNameCol]
      signupAgeDays: sSearch_copy[signupAgeCol]
      userAgeDays: sSearch_copy[userAgeCol]
      lastLoginAgeDays: sSearch_copy[lastLoginAgeCol]
      lastActivityAgeDays: sSearch_copy[lastActivityAgeCol]
      campaignLabels: sSearch_copy[campaignLabelsCol]
      search: oTable.fnSettings().oPreviousSearch.sSearch
    }

  $('#selectFiltered').click ->
    $.getJSON 'activity_ajax_select_filtered', _getFilter(), (data) ->
      updateSelectedIds(data.ids)

  updateSelectedCount = ->
    $('#selected_count').html(selected.length)
    $('#selected_plural').html(if selected.length == 1 then '' else 's')
    if selected.length > 0
      $('#addCampaignBtn').removeAttr('disabled')
      $('#removeCampaignBtn').removeAttr('disabled')
      $('#downloadEmailsCSVBtn').removeAttr('disabled')
    else
      $('#addCampaignBtn').attr('disabled', 'disabled')
      $('#removeCampaignBtn').attr('disabled', 'disabled')
      $('#downloadEmailsCSVBtn').attr('disabled', 'disabled')

  updateSelectedIds = (ids) ->
    selected = []
    for d in ids
      selected.push d
    oTable.fnDraw()
    updateSelectedCount()

  # fetch the last updated date for the summary stats and update the screen
  updateSummaryDate = ->
    getter = $.getJSON 'activity_ajax_summary_date', (data) ->
      if data.error
        $('#updated').html(data.error)
      else
        $('#updated').html(data.date)

    getter.error ->
      $('#updated').html('Error getting summary date.')


  _commonGetJSONwithDialogAndError = (buttonId, modalId, fnUrl, successText, fnSuccess) ->
    $(buttonId).click ->
      $(@).attr('disabled', 'disabled')
      [url, submitData] = fnUrl()
      getter = $.getJSON url, submitData, (data) ->
        # console.log data
        if data.error?
          $('#alertForError span')
          .html(data.error)
          $('#alertForError')
          .addClass('alert-error')
          .removeClass('alert-success')
          .removeAttr('hidden')
        else
          $('#alertForError span')
          .html(successText)
          $('#alertForError')
          .addClass('alert-success')
          .removeClass('alert-error')
          .removeAttr('hidden')
          fnSuccess(data)

      getter.error ->
        $('#alertForError span')
        .html('AJAX error?')
        $('#alertForError')
        .addClass('alert-error')
        .removeClass('alert-success')
        .removeAttr('hidden')

      getter.complete =>
        # dismiss the modal
        $(modalId).modal('hide')  
        $(@).removeAttr('disabled')

  $('#alertForError button').click ->
      $('#alertForError').attr('hidden', 'true')


  _commonGetJSONwithDialogAndError '#confirmUpdateSummaryStatsBtn',
    '#confirmUpdateSummaryStatsModal',
    -> ['activity_ajax_update_summary_stats', undefined],
    'Summary Stats updated',
    (data) ->
      updateSummaryDate()
      oTable.fnDraw()

  $('#confirmDownloadCSVBtn').click ->
    $('#confirmDownloadCSVModal').modal('hide')
    window.location.href = 'activity_summary_CSV'


  $('#confirmDownloadEmailsCSVBtn').click ->
    $('#confirmDownloadEmailsCSVModal').modal('hide')
    console.log selected
    params = $.param({ids: selected})
    window.location.href = 'activity_selected_emails?' + params


  $('#addCampaignBtn').click ->
    if selected.length > 0
      campaignLabel = $('#campaignText').val()
      campaignAction = 'add'
      $('#confirmCampaignActionModalHeader').html('Add Campaign Lableto Selected Items?')
      $('#confirmCampaignActionModalBody p').html("Are you sure you wish to add <strong>#{campaignLabel}</strong> to <strong>#{selected.length}</strong> selected items?")
      $('#confirmCampaignActionModal').modal({show: true})

  $('#removeCampaignBtn').click ->
    if selected.length > 0
      campaignLabel = $('#campaignText').val()
      campaignAction = 'remove'
      $('#confirmCampaignActionModalHeader').html('Remove Campaign Lable From Selected Items?')
      $('#confirmCampaignActionModalBody p').html("Are you sure you wish to REMOVE <strong>#{campaignLabel}</strong> lable to <strong>#{selected.length}</strong> selected items?")
      $('#confirmCampaignActionModal').modal({show: true})

  _commonGetJSONwithDialogAndError '#confirmCampaignActionBtn',
    '#confirmCampaignActionModal',
    -> ['activity_ajax_campaign_ids', {function: campaignAction, label: campaignLabel, ids: selected},],
    "Campaign Action Successful",
    (data) ->
      oTable.fnDraw()


  # finally, fetch the updateSummary
  updateSummaryDate()
  updateSelectedCount()
  toggleDetailsTableColumns()
  toggleStatsTableColumns()