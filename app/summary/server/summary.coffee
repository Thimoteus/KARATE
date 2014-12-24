Meteor.methods

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