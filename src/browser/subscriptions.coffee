###
subscriptions.coffee (js) special js code for the signups page.
###
$(document).ready ->
    # these are the table items selected.
    selected = []

    oTable = $('#subscriptions-table').dataTable(
        "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>"
        # "sDom": "<'row-fluid'<'span6'l><'span6'>r>t<'row-fluid'<'span6'i><'span6'p>>"
        "bProcessing": true
        'bPaginate': true
        "bServerSide": true
        "sAjaxSource": "subscriptions_ajax"
        "sServerMethod": "GET"
        "sPaginationType": "bootstrap"
        "bFilter": true
        "aoColumns": [
            { mDataProp: "_id", sType: "string", sWidth: "20%" }
            { mDataProp: "email", sType: "string", sWidth: "30%" }
            { mDataProp: "type", sType: "string", sWidth: "10%" }
            { mDataProp: "state", sType: "date", sWidth: "10%" }
            { mDataProp: "created_ts", sType: "date", sWidth: "30%" }
        ]
  
        "fnRowCallback": (nRow, aData, iDisplayIndex) ->
            # set the line in the table to selected IF the row is in the 'selected' array
            if aData._id in selected
                $(nRow).addClass 'info'
            return nRow

    )
    .columnFilter({
        aoColumns:[
            null
            { sSelector: "#emailFilter", type: "text"}
            { sSelector: "#typeFilter", type: "select", values: ['invite', 'newsletter']}
            { sSelector: "#stateFilter", type: "select", values: ['(missing)', 'new', 'pending', 'used']}
            null
        ]
    })
    .fnSetFilteringDelay()


    # Click event handler
    $('#subscriptions-table tbody tr').live 'click', ->
        aData = oTable.fnGetData(@)
        iId = aData._id
        if not(iId in selected)
            selected.push iId
        else
            selected = jQuery.grep(selected, (v) -> v != iId)
        $(@).toggleClass 'info'
        updateSelectedCount()


    # set up the dialog window functions.
    $('#confirmedConvertMissing').click( -> window.location='subs_convert_missing')
    $('#confirmedConvertNew').click( -> window.location='subs_convert_new')
    $('#confirmedConvertPending').click( -> window.location='subs_convert_pending')
    $('#downloadPendingCSV').click( -> window.location.href= 'subs_download_csv')

    # handle the clearAll button
    $('#clearAll').click ->
        selected = []
        oTable.fnDraw()
        updateSelectedCount()

    # handle the selectAll button
    $('#selectAll').click ->
        $.getJSON 'subs_ajax_select_all', (data) ->
            updateSelectedIds(data.ids)

    $('#selectFiltered').click ->
        emailCol = 1
        stateCol = 3
        typeCol = 2
        filter =
            email:  oTable.fnSettings().aoPreSearchCols[emailCol].sSearch
            state:  oTable.fnSettings().aoPreSearchCols[stateCol].sSearch
            type:   oTable.fnSettings().aoPreSearchCols[typeCol].sSearch
            search: oTable.fnSettings().oPreviousSearch.sSearch
        $.getJSON 'subs_ajax_select_filtered', filter, (data) ->
            updateSelectedIds(data.ids)

    updateSelectedCount = ->
        $('#selected_count').html(selected.length)
        $('#selected_plural').html(if selected.length == 1 then '' else 's')


    updateSelectedIds = (ids) ->
        selected = []
        for d in ids
            selected.push d
        oTable.fnDraw()
        updateSelectedCount()

    # Send signups to the selected email addresses and convert them to used.
    $('#confirmSignupsBtn').click ->
        # disable the button
        $(@).attr('disabled', 'disabled')
        getter = $.getJSON 'subs_ajax_send_emails', {ids: selected}, (data) ->
            # make a notification to say they went
            errors = ""
            if data.errors? and data.errors.length > 0
                for error in data.errors
                    errors += "<br/>" + JSON.stringify(error)
            if data.error? or data.count == 0
                # show the error message as an alert.
                text = "Didn't send the invites"
                if data.error?
                    text += ": #{data.error}"
                if errors.length > 0
                    text += errors
                $('#alertSendSignups span')
                .html(text)
                $('#alertSendSignups')
                .addClass('alert-error')
                .removeClass('alert-success')
                .removeAttr('hidden')
            else
                text = "Sent <strong>#{data.count}</strong> signup invite emails!"
                if errors.length > 0
                    test += errors 
                $('#alertSendSignups span')
                .html(text)
                $('#alertSendSignups')
                .addClass('alert-success')
                .removeClass('alert-error')
                .removeAttr('hidden')
                # redraw the table because now they will be 'used'
                oTable.fnDraw()

        getter.error ->
            # didn't send things.
            $('#alertSendSignups span')
            .text("Something went wrong - didn't do anything to subscriptions!")
            $('#alertSendSignups')
            .addClass('alert-error')
            .removeClass('alert-success')
            .removeAttr('hidden')
        getter.complete =>
            # dismiss the modal
            $('#confirmSendSignupsModal').modal('hide')  
            $(@).removeAttr('disabled')

    $('#alertSendSignups button').click ->
        $('#alertSendSignups').attr('hidden', 'true')


    # Convert selected Subscriptions back into pending state
    $('#confirmConvertSelectedToNewBtn').click ->
        getter = $.getJSON 'subs_ajax_convert_selected_to_new', {ids: selected}, (data) ->
            oTable.fnDraw()

        getter.complete =>
            $('#confirmConvertSelectedToNewModal').modal('hide')

    # Set up the count and ensure the button is in the right state.
    updateSelectedCount()