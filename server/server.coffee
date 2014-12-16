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

                try

                        kase.title = reddit.getArticleTitle(kase.number)

                        Cases.insert
                                'owner': @userId
                                'title': kase.title
                                'number': kase.number
                                'role': kase.role
                                'status': kase.status
                        
                        return true

                catch err

                        console.log "Error creating case: #{err.message}"
                        console.log err.response
                        
                        return false

        "postToFirm": (kase) ->

                firm = Meteor.user().settings.firm
                res = reddit.submitCaseLink(kase, firm)
                return res

        "editCase": (kase) ->

                try
                        id = kase.id
                        o =
                                'role': kase.role
                                'status': kase.status

                        Cases.update(id, {$set: o})

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

        "updateSettings": (settings) ->

                o = {}
                o['profile.settings'] = settings

                try

                        Meteor.users.update(Meteor.userId(), {$set: o})

                catch e

                        console.log e.message
                        throw e

        "magicButton": (args...) ->

                # console.log Meteor.userId()
                # console.log @userId
                # console.log Meteor.user()._id
                console.log Meteor.user().settings