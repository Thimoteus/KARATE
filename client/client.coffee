Meteor.subscribe "cases"

wins =
        prosecution: ["guilty", "plea-bargain"]
        defense: ["dismissed", "not-guilty"]

checkFailedValidation = (e) -> /Match failed \[400\]/.test e.message

EventDuplicates =
        
        postUpdateToReddit: (role, status, number) ->
                
                Meteor.call("postUpdateToReddit", role, status, number, (e, r) ->
                                if e
                                        return newStatusMessage("Check the recipient in your settings exists") if checkFailedValidation(e)
                                        return newStatusMessage("Something went wrong", "danger")
                                else if r.error
                                        newStatusMessage(r.error, "warning")
                                else
                                        newStatusMessage("Update sent to reddit", "success"))

newCaseInfo = (cxt) ->

        addr = cxt.$("#case-link")[0]?.value
        checked = cxt.$("input[type='radio']:checked")
        info = getArticleSrAndId(addr)
        ret =
                number: info[1]
                sr: info[0]
                role: checked[0]?.value
                status: checked[1]?.value

        return ret

preCheckRadios = (array, selector) ->

        checked = (opp, sel) -> if opp is sel then "checked" else ""

        radios = []

        for m in array

                chk = checked(m, selector)
                radios.push {value: m, checked: chk}

        return radios

preSelectOptions = (array, selector) ->

        selected = (opp, sel) -> if opp is sel then "selected" else ""

        opts = []
        hyphenExceptions = ["pre-trial"]

        for m in array

                sel = selected(m, selector)
                n = if m not in hyphenExceptions then m.replace("-", " ") else m
                opts.push {value: n, selected: sel}
        
        return opts

newStatusMessage = (msg, type) ->

        t = type
        t = "Error" if type is "danger"

        statusMsg= """
                <div class='alert alert-#{type} alert-dismissible' role='alert'>
                        <button type='button' class='close' data-dismiss='alert'>
                                <span aria-hidden='true'>&times;</span>
                                <span class='sr-only'>Close</span>
                        </button>
                        <strong>#{t[0].toUpperCase()+t[1..]}:</strong> #{msg}
                </div>
        """
        $("#statusUpdates").prepend(statusMsg)

###
                        __      
  ___ _   _____  ____  / /______
 / _ \ | / / _ \/ __ \/ __/ ___/
/  __/ |/ /  __/ / / / /_(__  ) 
\___/|___/\___/_/ /_/\__/____/  
                                
###

Template.addNewCase.events

        'click .post-to-firm-cancel': (evt, cxt) ->
                evt.preventDefault()

                cxt.$("button[type='submit']").attr("disabled", false).removeClass("hidden")
                cxt.$(".btn-post-to-firm").addClass("hidden")

        'click .post-to-firm': (evt, cxt) -> 
                evt.preventDefault()

                newStatusMessage("Posting new link ... ", "info")

                kase = newCaseInfo(cxt)

                Meteor.call("postToFirm", kase, (e, r) ->

                        if r.error
                                newStatusMessage(r.error, "warning")
                                return
                        if e
                                newStatusMessage("Something went wrong, try again later", "danger")
                                return
                        else
                                newStatusMessage("Link posted", "success")
                                cxt.$("button[type='submit']").attr("disabled", false).removeClass("hidden")
                                cxt.$(".btn-post-to-firm").addClass("hidden"))
        
        'submit form': (evt, cxt) ->
                evt.preventDefault()

                kase = newCaseInfo(cxt)
                
                newStatusMessage("Submitting new case ... ", "info")
                
                Meteor.call("submitNewCase", kase, (err, res) ->
                
                        if err
                                
                                newStatusMessage("Something went wrong, try again later", "danger")

                        else

                                newStatusMessage("Case submitted!", "success")
                                cxt.$("button[type='submit']").attr("disabled", true).addClass("hidden")
                                cxt.$(".btn-post-to-firm").removeClass("hidden"))

Template.currentCases.events

        'click .remove-case': (evt, cxt) ->
                evt.preventDefault()

                id = @_id

                Meteor.call("deleteCase", id, (e, r) -> newStatusMessage("Case removed", "success") if not e)

        'click .edit-case': (evt, cxt) ->

                Session.set("editing-#{@_id}", true)
                cxt.$(".edit-case").removeClass("edit-case").addClass("editing")

        'click .editing': (evt, cxt) ->

                kase =
                        id: @_id
                        role: cxt.$("#role-#{@_id} option:selected")[0].value.replace(" ", "-")
                        status: cxt.$("#status-#{@_id} option:selected")[0].value.replace(" ", "-")

                me = this

                Meteor.call("editCase", kase, (err, res) ->
                                if err
                                
                                        newStatusMessage("Something went wrong", "danger")
                                
                                else
                                
                                        newStatusMessage("Changes saved", "success")
                                        cxt.$(".editing").removeClass("editing").addClass("edit-case")
                                        Session.set("editing-#{me._id}", false))

        'click .update-case': (evt, cxt) ->

                role = cxt.$("#role-#{@_id} option:selected")[0].value
                status = cxt.$("#status-#{@_id} option:selected")[0].value

                newStatusMessage("Updating on reddit ... ", "info")

                EventDuplicates.postUpdateToReddit(role, status, @number)


Template.oldCases.events

        'click .update-case': (evt, cxt) ->

                newStatusMessage("Updating on reddit ... ", "info")

                EventDuplicates.postUpdateToReddit(@role, @status, @number)

        'click .remove-case': (evt, cxt) ->
                evt.preventDefault()

                id = @_id

                Meteor.call("deleteCase", id, (e, r) -> newStatusMessage("Case removed", "success") if not e)

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

                newStatusMessage("Updating settings ... ", "info")

                Meteor.call("updateSettings", settings, (e, r) ->
                        
                        if not e
                        
                                newStatusMessage("Settings saved", "success")
                        
                        else

                                return newStatusMessage("Check the firm and recipient exist.", "danger") if checkFailedValidation(e)
                                newStatusMessage(e.message, "danger"))

Template.tools.events

        'submit #tools-username': (evt, cxt) ->
                evt.preventDefault()

                usr = cxt.$("#search-username")[0].value
                service = cxt.$("#tools-username input[type='radio']:checked")[0].value

                switch service
                        when "redective"
                                window.open('http://www.redective.com/?r=e&a=search&s=user&t=redective&q=' + encodeURIComponent(usr))
                        when "rcs"
                                window.open('http://redditcommentsearch.com/?query=&user=' + encodeURIComponent(usr))
                        when "metareddit"
                                window.open('http://metareddit.com/stalk?user=' + encodeURIComponent(usr))
                        else
                                window.open('https://www.reddit.com/user/' + encodeURIComponent(usr))

        'submit #tools-image': (evt, cxt) ->
                evt.preventDefault()

                imageURL = cxt.$('#search-image')[0].value
                service = cxt.$("#tools-image input[type='radio']:checked")[0].value

                switch service
                        when "karmadecay"
                                window.open('http://karmadecay.com/search?kdtoolver=m2&q=' + encodeURIComponent(imageURL))
                        when "tineye"
                                window.open('http://www.tineye.com/search?url=' + encodeURIComponent(imageURL))
                        else
                                window.open('http://images.google.com/searchbyimage?image_url=' + encodeURIComponent(imageURL))
###
    __         __                    
   / /_  ___  / /___  ___  __________
  / __ \/ _ \/ / __ \/ _ \/ ___/ ___/
 / / / /  __/ / /_/ /  __/ /  (__  ) 
/_/ /_/\___/_/ .___/\___/_/  /____/  
            /_/                      
###

Template.splash.rendered = ->
        @$(".wins-tooltip").tooltip
                title: "Prosecution wins: plea bargains, guilty verdicts. Defense: dismissals, not guilty verdicts."
        @$(".ncp-tooltip").tooltip
                title: "Chances that one of your cases will be end in mistrial or dismissal"

Template.addNewCase.rendered = ->
        @$("[type='submit']").tooltip
                title: "Add a case to the KARATE database."
        @$(".post-to-firm").tooltip
                title: "Post to your firm's subreddit with a link to the trial on KC."

Template.settings.rendered = ->
        UM = @$("[type='radio']:checked")[0].value
        if UM is "None"
                Session.set("disabledRecipient", "disabled")
        else
                Session.set("disabledRecipient", "")

Template.addNewCase.helpers

        roles: -> {"role": role} for role in roles

        statuses: -> {"status": status, "statusEdited": if status is "pre-trial" then "pre-trial" else status.replace("-", " ")} for status in statuses

Template.currentCases.helpers

        cases: -> Cases.find(status: {$in: statuses[0..1]})
        # statuses = ["pre-trial","in-session","guilty","not-guilty","dismissed","mistrial"]

        shortLink: -> "http://redd.it/#{@number}"

        editText: -> return if Session.get("editing-#{@_id}") then "Save changes" else "Edit case"

        disabled: -> return if Session.get("editing-#{@_id}") then "" else "disabled"

        roleOptions: -> preSelectOptions(roles, @role)

        statusOptions: -> preSelectOptions(statuses, @status)

Template.updateOnReddit.helpers

        canUpdateCaseOnReddit: ->
                
                settings = Meteor.user().profile?.settings
                
                return settings?.updateMethod?.length > 0 and settings?.recipient?.length > 0

Template.oldCases.helpers

        cases: -> Cases.find(status: {$in: statuses[2..]})

        status: -> if @status is "pre-trial" then "pre-trial" else @status.replace("-", " ")

        shortLink: -> "http://redd.it/#{@number}"

Template.statistics.helpers

        totalCases: -> Cases.find().count()

        incompleted: -> Cases.find(status: {$in: statuses[0..1]}).count()

        wins: ->
                Cases.find(role: "prosecution", status: {$in: wins.prosecution}).count() +
                Cases.find(role: "defense", status: {$in: wins.defense}).count()

        losses: ->
                Cases.find(role: "prosecution", status: {$in: wins.defense}).count()+
                Cases.find(role: "defense", status: {$in: wins.prosecution}).count()

        NCP: ->
                format = (x) ->
                        return "undefined" if not(0<=x<=1)
                        return (Math.floor(x*10000)/100).toString() + "%"
                
                closedCases = Cases.find(status: {$in: statuses[2..]}).count()
                NCPCases = Cases.find(status: {$in: statuses[4..5]}).count()
                NCP = NCPCases/closedCases

                return format(NCPCases/closedCases.valueOf())

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

Template.magicButton.events

        'click #magicButton': (evt, cxt) ->
                evt.preventDefault()
                Meteor.call("magicButton", cxt.$("#magicText")[0].value, (e, r) -> console.log r)