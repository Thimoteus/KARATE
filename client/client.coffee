roles = ["judge","jury","prosecution","defense"]
statuses = ["pre-trial","in-session","guilty","not-guilty","dismissed","mistrial", "plea-bargain"]
wins =
        prosecution: ["guilty", "plea-bargain"]
        defense: ["dismissed", "not-guilty"]

Meteor.subscribe "cases"

newCaseInfo = (cxt) ->

        getCaseNumberFromAddress = (url) ->
                # https://www.reddit.com/r/KarmaCourt/comments/2oblji/the_people_of_rfunny_vs_umadfotze_for/
                re = /r\/(\w+)\/comments\/(\w{6})/
                caseInfo = re.exec url

                return if caseInfo then [caseInfo[1],caseInfo[2]] else null

        addr = cxt.$("#case-link")[0].value
        checked = cxt.$("input[type='radio']:checked")
        info = getCaseNumberFromAddress(addr)
        ret =
                number: info[1]
                sr: info[0]
                role: checked[0].value
                status: checked[1].value

        return ret

returnPreSelectedOptions = (array, selector) ->

        selected = (opp, sel) -> if opp is sel then "selected" else ""

        opts = []

        for m in array

                sel = selected(m, selector)
                n = if m isnt "pre-trial" then m.replace("-", " ") else m
                opts.push {value: n, selected: sel}
        return opts

newStatusMessage = (msg, type) ->

        statusMsg= """
                <div class='alert alert-#{type} alert-dismissible' role='alert'>
                        <button type='button' class='close' data-dismiss='alert'>
                                <span aria-hidden='true'>&times;</span>
                                <span class='sr-only'>Close</span>
                        </button>
                        <strong>#{type[0].toUpperCase()+type[1..]}:</strong> #{msg}
                </div>
        """

        $("#statusUpdates").append(statusMsg)

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

                        if not e

                                newStatusMessage("Link posted", "success")
                                cxt.$("button[type='submit']").attr("disabled", false).removeClass("hidden")
                                cxt.$(".btn-post-to-firm").addClass("hidden"))
        
        'submit form': (evt, cxt) ->
                
                evt.preventDefault()

                kase = newCaseInfo(cxt)
                
                newStatusMessage("Submitting new case ... ", "info")
                
                Meteor.call("submitNewCase", kase, (err, res) ->
                
                        if err or not res
                                
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

Template.oldCases.events

        'click .remove-case': (evt, cxt) ->

                evt.preventDefault()

                id = @_id

                Meteor.call("deleteCase", id, (e, r) -> newStatusMessage("Case removed", "success") if not e)

Template.settings.events

        'submit form': (evt, cxt) ->

                evt.preventDefault()

                settings =
                        firm: cxt.$("#firm")[0].value

                Meteor.call("updateSettings", settings, (e, r) ->
                        
                        if not e
                        
                                newStatusMessage("Settings saved", "success")
                        
                        else

                                newStatusMessage(e.message, "danger"))

Template.addNewCase.helpers

        roles: -> {"role": role} for role in roles

        statuses: -> {"status": status, "statusEdited": if status is "pre-trial" then "pre-trial" else status.replace("-", " ")} for status in statuses

Template.currentCases.helpers

        cases: -> Cases.find(status: {$in: statuses[0..1]})
        # statuses = ["pre-trial","in-session","guilty","not-guilty","dismissed","mistrial"]

        shortLink: -> "http://redd.it/#{@number}"

        editText: -> return if Session.get("editing-#{@_id}") then "Save changes" else "Edit case"

        disabled: -> return if Session.get("editing-#{@_id}") then "" else "disabled"

        roleOptions: -> returnPreSelectedOptions(roles, @role)

        statusOptions: -> returnPreSelectedOptions(statuses, @status)

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
                closedCases = Cases.find(status: {$in: statuses[2..]}).count()
                NCPCases = Cases.find(status: {$in: statuses[4..5]}).count()
                NCP = NCPCases/closedCases
                return NCP*100+"%"

Template.settings.helpers

        firm: -> Meteor.user().profile.settings.firm

Template.magicButton.events

        'click #magicButton': (evt, cxt) ->

                evt.preventDefault()

                Meteor.call("magicButton")