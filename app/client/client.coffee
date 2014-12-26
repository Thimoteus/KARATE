Meteor.subscribe("cases")

# lib
@checkFailedValidation = (e) -> /Match failed \[400\]/.test e.message

# lib
@Message =
        msg: (msg, type) ->
                t = if type is "danger" then "Error" else type
                statusMsg = """
                        <div class='alert alert-#{type} alert-dismissible' role='alert'>
                                <button type='button' class='close' data-dismiss='alert'>
                                        <span aria-hidden='true'>&times;</span>
                                        <span class='sr-only'>Close</span>
                                </button>
                                <strong>#{t[0].toUpperCase()+t[1..]}:</strong> #{msg}
                        </div>"""
                $("#statusUpdates").prepend(statusMsg)
        warning: (msg) -> Message.msg(msg, "warning")
        error: (msg) -> Message.msg(msg, "danger")
        info: (msg) -> Message.msg(msg, "info")
        success: (msg) -> Message.msg(msg, "success")

Accounts.ui.config
        requestPermissions:
                reddit: ['read', 'identity', 'submit', 'privatemessages', 'flair', 'edit']

Template.magicButton.events

        'click #magicButton': (evt, cxt) ->
                evt.preventDefault()
                Meteor.call("magicButton", cxt.$("#magicText")[0].value, (e, r) -> console.log r)
