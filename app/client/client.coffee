Meteor.subscribe("cases")

# lib
@checkFailedValidation = (e) -> /Match failed \[400\]/.test e.message

# lib
@Message =
        msg: (msg, type, link=false) ->
                t = if type is "danger" then "Error" else type
                msg = if link then "<a href='#{link}' target='_blank'> #{msg}</a>" else msg
                if link
                        msg = "<a href='#{link}' target='_blank'>
                                <span class='glyphicon glyphicon-link'></span> #{msg}
                                </a>"
                statusMsg = """
                        <div class='alert alert-#{type} alert-dismissible' role='alert'>
                                <button type='button' class='close' data-dismiss='alert'>
                                        <span aria-hidden='true'>&times;</span>
                                        <span class='sr-only'>Close</span>
                                </button>
                                <strong>#{t[0].toUpperCase()+t[1..]}:</strong> #{msg}
                        </div>"""
                $("#statusUpdates").prepend(statusMsg)
        warning: (msg, link=false) -> Message.msg(msg, "warning", link)
        error: (msg, link=false) -> Message.msg(msg, "danger", link)
        info: (msg, link=false) -> Message.msg(msg, "info", link)
        success: (msg, link=false) -> Message.msg(msg, "success", link)

Accounts.ui.config
        requestPermissions:
                reddit: ['read', 'identity', 'submit', 'privatemessages', 'flair', 'edit']

Template.magicButton.events

        'click #magicButton': (evt, cxt) ->
                evt.preventDefault()
                Meteor.call("magicButton", cxt.$("#magicText")[0].value, (e, r) -> console.log r)
