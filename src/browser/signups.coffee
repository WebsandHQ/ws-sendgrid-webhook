###
Signups.coffee (js) special js code for the signups page.
###

$(document).ready ->
    $('#signups-table').dataTable(
        "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>"
        # "sDom": "<'row-fluid'<'span6'l><'span6'>r>t<'row-fluid'<'span6'i><'span6'p>>"
        "bProcessing": true
        'bPaginate': true
        "bServerSide": true
        "sAjaxSource": "signups_ajax"
        "sServerMethod": "GET"
        "sPaginationType": "bootstrap"
        "bFilter": true
        "aoColumns": [
            { "mDataProp": "_id", "sType": "string" }
            { "mDataProp": "email", "sType": "string", "sWidth": "20%" }
            { "mDataProp": "code", "sType": "string", "sWidth": "20%" }
            { "mDataProp": "expire", "sType": "date", "sWidth": "20%" }
            { "mDataProp": "used", "sType": "string"}
            { "mDataProp": "invite_id", "sType": "string" }
            { "mDataProp": "created_ts", "sType": "date", "sWidth": "20%" }
        ]
        "fnCreatedRow": (nRow, aData, iDataIndex) ->
            value = ".." + aData._id[-5..]
            $('td:eq(0)', nRow).html(value).tooltip({title: aData._id})
    )
    .columnFilter({
        aoColumns:[
            { sSelector: "#_idFilter", type: "text"}
            { sSelector: "#emailFilter", type: "text"}
            { sSelector: "#codeFilter", type: "text"}
            null
            { sSelector: "#usedFilter", type: "select", values: ['true', 'false']}
            { sSelector: "#invitedFilter", type: "text"}
            null
        ]
    })
    .fnSetFilteringDelay()
