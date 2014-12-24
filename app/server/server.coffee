# for validations
@val =
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

Meteor.publish("cases", -> return Cases.find('owner': @userId))

Meteor.methods

        # lib
        "magicButton": (args...) ->
                
                res = reddit.setFlairOption(args[0])
                console.log res