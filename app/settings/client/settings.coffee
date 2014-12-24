
# settings
preCheckRadios = (array, selector) ->

        checked = (opp, sel) -> if opp is sel then "checked" else ""

        radios = []

        for m in array

                chk = checked(m, selector)
                radios.push {value: m, checked: chk}

        return radios

Template.settings.events
        
        'click [value="None"]': (evt, cxt) -> Session.set("disabledRecipient", "disabled")
        'click [value="PM"]': (evt, cxt) -> Session.set("disabledRecipient", "")
        'click [value="Reply"]': (evt, cxt) -> Session.set("disabledRecipient", "")

        'submit form': (evt, cxt) ->
                evt.preventDefault()

                settings =
                        firm: cxt.$("#firm")[0].value
                        updateMethod: cxt.$("input[name='update-methods']:checked")[0]?.value
                        recipient: cxt.$("#recipient")[0].value

                Message.info("Updating settings ... ")

                Meteor.call("updateSettings", settings, (e, r) ->
                        
                        if not e
                        
                                Message.success("Settings saved")
                        
                        else

                                return Message.error("Check the firm and recipient exist") if checkFailedValidation(e)
                                Message.error("Something went wrong"))


Template.settings.rendered = ->
        UM = @$("[type='radio']:checked")[0].value
        if UM is "None"
                Session.set("disabledRecipient", "disabled")
        else
                Session.set("disabledRecipient", "")

Template.settings.helpers

        firm: -> Meteor.user().profile.settings?.firm

        updateMethods: ->

                methods = ["PM", "Reply", "None"]
                settings = Meteor.user().profile?.settings
                
                if settings?.updateMethod?
                        
                        radios = preCheckRadios(methods, settings.updateMethod)

                else
                        radios = preCheckRadios(methods, "None")

                radios[0].description = "(i.e. send a message to an account with your case updates)"
                radios[1].description = "(i.e. reply to a given post with your case updates)"
                radios[2].description = "(no update method, default)"

                return radios

        recipient: -> Meteor.user().profile?.settings?.recipient ? ""

        recipientDisabled: -> return Session.get("disabledRecipient")