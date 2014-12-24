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