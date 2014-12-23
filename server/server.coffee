# for validations
val =
        exists: Match.Where (x) -> x?
        isProperString: Match.Where (str) ->
                check(str, String)
                str.length > 0

        isUsername: Match.Where (usr) ->
                check(usr, String)
                try
                        reddit.isUsername(usr)
                catch e
                        return false
                return true

        isPost: Match.Where (url) ->
                check(url, val.isProperString)
                return true

        isTrialRole: Match.Where (role) ->
                check(role, val.isProperString)
                return role in roles

        isTrialStatus: Match.Where (status) ->
                check(status, val.isProperString)
                return status in statuses

        isSr: Match.Where (sr) ->
                check(sr, String)
                try
                        res = reddit.canPostToSr(sr)
                catch e
                        return false
                if res.statusCode is 200
                        return true if res.data.data.id
                return false

Meteor.startup ->

        ServiceConfiguration.configurations.remove
                service: "reddit"

        ServiceConfiguration.configurations.insert
                service: "reddit"
                appId: Meteor.settings.app_id
                secret: Meteor.settings.app_secret

        Accounts.onLogin (o) ->

                @reddit = new Reddit(o.user)

Meteor.publish("cases", ->
                return Cases.find('owner': @userId)
        )

Meteor.methods
        
        "submitNewCase": (kase) ->
                check(kase.role, val.isTrialRole)
                check(kase.status, val.isTrialStatus)
                # check(kase.number, val.isCaseNumber)

                try

                        kase.title = reddit.getArticleTitle(kase.number)

                        Cases.insert
                                'owner': @userId
                                'title': kase.title
                                'number': kase.number
                                'role': kase.role
                                'status': kase.status
                                'notes': kase.notes
                        
                        return true

                catch err

                        console.log "Error creating case: #{err.message}"
                        console.log err.response
                        
                        return false

        "postToFirm": (kase) ->
                check(kase.role, val.isTrialRole)
                check(kase.status, val.isTrialStatus)
                
                kase.sr = reddit.getShortLinkSr(kase.number) unless kase.sr
                firm = Meteor.user().profile.settings?.firm
                
                return {error: "You need to set a firm."} unless firm?
                
                res = reddit.submitCaseLink(kase, firm)

                try
                        postId = res.data.json.data.id
                        reddit.setFlairOption(postId)
                        return res
                catch e
                        return res
                
        "editCase": (kase) ->
                check(kase.role, val.isTrialRole)
                check(kase.status, val.isTrialStatus)

                try
                        id = kase.id
                        o = _.pick(kase, ['role', 'status', 'notes'])

                        Cases.update(id, {$set: o})

                        return true

                catch err

                        console.log "Error saving case: #{err.message}"
                        console.log err.response

                        return false

        "deleteCase": (id) ->

                try

                        Cases.remove('_id': id)
                
                        return true

                catch err

                        console.log "Error removing case: #{err.message}"

                        return false

        "postUpdateToReddit": (kase) ->

                KCnum = reddit.getKCNum(kase.id)
                userSettings = Meteor.user().profile.settings
                recipient = userSettings.recipient
                title = "Update for case no. #{KCnum}"
                msg = """
                        KarmaCourt case no. #{KCnum} has been updated.
                        
                        My role is `#{kase.role}`.
                        
                        The case's status is `#{kase.status}`.
                """
                msg += "\n\nNotes: #{kase.notes}" if kase.notes.length > 0

                switch userSettings.updateMethod
                        when "PM" then return reddit.sendPM(recipient, title, msg)
                        when "Reply" then return reddit.replyToArticle(recipient, msg)

        "updateSettings": (settings) ->
                check(settings.firm, val.isSr) if settings.firm.length > 0
                rec = settings.recipient
                switch settings.updateMethod
                        when "PM" then check(rec, val.isUsername)
                        when "Reply" then check(rec, val.isPost)

                properSettings = () ->
                        z = 0
                        s = _.omit(settings, ['updateMethod'])
                        for key of s
                                z += s[key].length
                        return z > 0

                o = _.omit(Meteor.user(), ['profile'])
                o.profile = _.omit(Meteor.user().profile, ['settings'])
                o.profile.settings = {} if properSettings()

                e = {}
                e.firm = settings.firm if settings.firm.length > 0
                e.recipient = rec if rec.length > 0 and settings.updateMethod isnt "None"
                e.updateMethod = settings.updateMethod if settings.updateMethod isnt "None"

                _.extend(o.profile.settings, e)

                try

                        Meteor.users.update(Meteor.userId(), o)

                catch e

                        console.log e.message
                        throw e

        "magicButton": (args...) ->
                
                res = reddit.setFlairOption(args[0])
                console.log res