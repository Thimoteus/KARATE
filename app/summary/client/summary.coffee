wins =
        prosecution: ["guilty", "plea-bargain"]
        defense: ["dismissed", "not-guilty"]

@EventDuplicates =
        
        postUpdateToReddit: (kase) ->
                
                Meteor.call("postUpdateToReddit", kase, (e, r) ->
                                if e
                                        return Message.warning("Check the recipient in your settings exists") if checkFailedValidation(e)
                                        Message.error("Something went wrong")
                                else if r.error
                                        Message.warning(r.error)
                                else
                                        Message.success("Update sent to reddit"))

preSelectOptions = (array, selector) ->

        selected = (opp, sel) -> if opp is sel then "selected" else ""

        opts = []
        hyphenExceptions = ["pre-trial"]

        for m in array

                sel = selected(m, selector)
                n = if m not in hyphenExceptions then m.replace("-", " ") else m
                opts.push {value: n, selected: sel}
        
        return opts

Template.currentCases.events

        'click .remove-case': (evt, cxt) ->
                evt.preventDefault()

                id = @_id

                Meteor.call("deleteCase", id, (e, r) ->
                        
                        if not e
                                return Message.success("Case removed")
                        else
                                return Message.error("Something went wrong"))

        'click .edit-case': (evt, cxt) ->

                Session.set("editing-#{@_id}", true)
                cxt.$(".edit-case").removeClass("edit-case").addClass("editing")

        'click .editing': (evt, cxt) ->

                kase =
                        id: @_id
                        role: cxt.$("#role-#{@_id} option:selected")[0].value.replace(" ", "-")
                        status: cxt.$("#status-#{@_id} option:selected")[0].value.replace(" ", "-")
                        notes: cxt.$("#notes-#{@_id}")[0].value

                me = this

                Meteor.call("editCase", kase, (err, res) ->
                                
                                if err
                                
                                        return Message.error("Something went wrong")
                                
                                else
                                
                                        Message.success("Case saved")
                                        cxt.$(".editing").removeClass("editing").addClass("edit-case")
                                        Session.set("editing-#{me._id}", false))

        'click .update-case': (evt, cxt) ->

                role = cxt.$("#role-#{@_id} option:selected")[0].value
                status = cxt.$("#status-#{@_id} option:selected")[0].value
                notes = cxt.$("#notes-#{@_id}")[0].value

                kase =
                        id: @number
                        role: role
                        status: status
                        notes: notes

                Message.info("Sending update message to reddit ... ")

                EventDuplicates.postUpdateToReddit(kase)


Template.oldCases.events

        'click .update-case': (evt, cxt) ->

                Message.info("Sending update message to reddit ... ")

                kase =
                        id: @number
                        role: @role
                        status: @status
                        notes: @notes

                EventDuplicates.postUpdateToReddit(kase)

        'click .remove-case': (evt, cxt) ->
                evt.preventDefault()

                id = @_id

                Meteor.call("deleteCase", id, (e, r) ->
                        if not e
                                Message.success("Case removed")
                        else
                                Message.error("Something went wrong"))

Template.statistics.rendered = ->
        @$(".wins-tooltip").tooltip
                title: "Prosecution wins: plea bargains, guilty verdicts. Defense: dismissals, not guilty verdicts."
        @$(".ncp-tooltip").tooltip
                title: "Chances that one of your cases will be end in mistrial, dismissal or a plea bargain."

Template.currentCases.helpers

        cases: -> Cases.find(status: {$in: statuses[0..1]})
        # statuses = ["pre-trial","in-session","guilty","not-guilty","dismissed","mistrial"]

        shortLink: -> "http://redd.it/#{@number}"

        editText: -> return if Session.get("editing-#{@_id}") then "Save changes" else "Edit case"

        disabled: -> return if Session.get("editing-#{@_id}") then "" else "disabled"
        updateable: -> return if Session.get("editing-#{@_id}") then false else true

        roleOptions: -> preSelectOptions(roles, @role)

        statusOptions: -> preSelectOptions(statuses, @status)

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
                NCPCases = Cases.find(status: {$in: statuses[4..6]}).count()
                NCP = NCPCases/closedCases

                return format(NCPCases/closedCases.valueOf())

Template.updateOnReddit.helpers

        canUpdateCaseOnReddit: ->
                
                settings = Meteor.user().profile?.settings
                
                return settings?.updateMethod?.length > 0 and settings?.recipient?.length > 0