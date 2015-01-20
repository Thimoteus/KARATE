###
#     ___ __
#    / (_) /_
#   / / / __ \
#  / / / /_/ /
# /_/_/_.___/
###

newCaseInfo = (cxt) ->

        addr = cxt.$("#case-link")[0]?.value
        checked = cxt.$("input[type='radio']:checked")
        notes = cxt.$("#notes")[0].value
        info = getArticleSrAndId(addr)
        return unless info
        ret =
                number: info[1]
                sr: info[0]
                role: checked[0]?.value
                status: checked[1]?.value
                notes: notes

        return ret

formatStatuses = (n, m) ->
        o = []
        for status in statuses[n..m]
                o.push {
                        status: status
                        statusEdited: if status is "pre-trial" then "pre-trial" else status.replace("-", " ")
                }
        return o

cleanup = (cxt) ->
        cxt.$("[type='radio']:checked").attr("checked", false)
        input.value = "" for input in cxt.$("textarea, [type='text']")

###
#                         __
#   ___ _   _____  ____  / /______
#  / _ \ | / / _ \/ __ \/ __/ ___/
# /  __/ |/ /  __/ / / / /_(__  )
# \___/|___/\___/_/ /_/\__/____/
###

Template.addNewCase.events

        'click .post-to-firm-cancel': (evt, cxt) ->
                evt.preventDefault()

                cxt.$("button[type='submit']").attr("disabled", false).removeClass("hidden")
                cxt.$(".btn-post-to-firm").addClass("hidden")
                cleanup(cxt)

        'click .post-to-firm': (evt, cxt) ->
                evt.preventDefault()

                Message.info("Posting new link ... ")

                kase = newCaseInfo(cxt)
                return Message.warning("Your link looks wrong") unless kase

                Meteor.call("postToFirm", kase, (e, r) ->

                        if r.error
                                return Message.warning(r.error)
                        if e
                                return Message.error("Something went wrong")
                        else
                                Message.success("Link posted", "http://redd.it/#{r.data.json.data.id}")
                                cxt.$("button[type='submit']").attr("disabled", false).removeClass("hidden")
                                cxt.$(".btn-post-to-firm").addClass("hidden")
                                cleanup(cxt))

        'submit form': (evt, cxt) ->
                evt.preventDefault()

                kase = newCaseInfo(cxt)
                return Message.warning("Not all fields were filled correctly") unless kase

                Message.info("Submitting new case ... ")

                Meteor.call("submitNewCase", kase, (err, res) ->

                        if err

                                return Message.error("Something went wrong, try again later")

                        else

                                if Meteor.user().profile?.settings?.firm?.length > 0
                                        cxt.$("button[type='submit']").attr("disabled", true).addClass("hidden")
                                        cxt.$(".btn-post-to-firm").removeClass("hidden")
                                else
                                        cleanup(cxt)

                                Message.success("Case saved"))
###
#     __         __
#    / /_  ___  / /___  ___  __________
#   / __ \/ _ \/ / __ \/ _ \/ ___/ ___/
#  / / / /  __/ / /_/ /  __/ /  (__  )
# /_/ /_/\___/_/ .___/\___/_/  /____/
#             /_/
###

Template.addNewCase.helpers

        roles: -> {"role": role} for role in roles

        trialStatuses: -> formatStatuses(0,1)

        verdictStatuses: -> formatStatuses(2,3)

        ncStatuses: -> formatStatuses(4,7)

###
#                         __                   __
#    ________  ____  ____/ /__  ________  ____/ /
#   / ___/ _ \/ __ \/ __  / _ \/ ___/ _ \/ __  /
#  / /  /  __/ / / / /_/ /  __/ /  /  __/ /_/ /
# /_/   \___/_/ /_/\__,_/\___/_/   \___/\__,_/
###

Template.addNewCase.rendered = ->
        @$("[type='submit']").tooltip
                title: "Add a case to the KARATE database."
        @$(".post-to-firm").tooltip
                title: "Post to your firm's subreddit with a link to the trial on KC."
