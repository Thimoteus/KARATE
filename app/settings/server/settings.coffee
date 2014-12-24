Meteor.methods

        # settings
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