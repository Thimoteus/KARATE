alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

newItem = (str, evt) ->
        evt.preventDefault()

        ev = Session.get(str)

        return Message.error("Ran out of alphabet letters.") if ev.length is alphabet.length

        e = ev[ev.length - 1]
        e.type = "danger"
        e.sign = "-"
        ev.push {num: alphabet[ev.length], type: "success", sign: "+", val: ""}

        Session.set(str, ev)

removeItem = (str, evt) ->
        evt.preventDefault()

        ev = Session.get(str)

        exh = $(evt.target).closest(".input-group").find("input").attr("placeholder")
        num = exh[exh.length - 1]
        ind = alphabet.indexOf(num)

        obj.val = $(".#{str}-group>input")[i].value for obj, i in ev

        nu = (obj for obj in ev when obj.num isnt num)
        obj.num = alphabet[i] for obj, i in nu
        Session.set(str, nu)

Template.tools.events

        'submit #tools-username': (evt, cxt) ->
                evt.preventDefault()

                usr = cxt.$("#search-username")[0].value
                service = cxt.$("#tools-username input[type='radio']:checked")[0].value

                switch service
                        when "redective"
                                window.open('http://www.redective.com/?r=e&a=search&s=user&t=redective&q=' +
                                        encodeURIComponent(usr))
                        when "rcs"
                                window.open('http://redditcommentsearch.com/?query=&user=' +
                                        encodeURIComponent(usr))
                        when "metareddit"
                                window.open('http://metareddit.com/stalk?user=' +
                                        encodeURIComponent(usr))
                        else
                                window.open('https://www.reddit.com/user/' +
                                encodeURIComponent(usr))

        'submit #tools-image': (evt, cxt) ->
                evt.preventDefault()

                imageURL = cxt.$('#search-image')[0].value
                service = cxt.$("#tools-image input[type='radio']:checked")[0].value

                switch service
                        when "karmadecay"
                                window.open('http://karmadecay.com/search?kdtoolver=m2&q=' +
                                        encodeURIComponent(imageURL))
                        when "tineye"
                                window.open('http://www.tineye.com/search?url=' +
                                        encodeURIComponent(imageURL))
                        else
                                window.open('http://images.google.com/searchbyimage?image_url=' +
                                        encodeURIComponent(imageURL))

        'click .charge.success': (evt, cxt) -> newItem("charges", evt)

        'click .evidence.success': (evt, cxt) -> newItem("evidence", evt)

        'click .charge.danger': (evt, cxt) -> removeItem("charges", evt)

        'click .evidence.danger': (evt, cxt) -> removeItem("evidence", evt)

        'submit #tools-file-case': (evt, cxt) ->
                evt.preventDefault()

                updateStuff = (str) ->
                        ev = Session.get(str)
                        obj.val = $(".#{str}-group>input")[i].value for obj, i in ev
                        return ev

                Session.set("evidence", updateStuff("evidence"))
                Session.set("charges", updateStuff("charges"))

                docket =
                        plaintiff: $('#plaintiff')[0].value
                        defendant: $('#defendant')[0].value
                        charges: (obj.val for obj in Session.get("charges") when obj.val.length > 0)
                        explanation: $('#explanation')[0].value
                        evidence: (obj.val for obj in Session.get("evidence") when obj.val.length > 0)

                Message.info("Filing new case ... ")

                Meteor.call("fileNewCase", docket, (e, r) ->

                        if e
                                return Message.error("Something went wrong")
                        else if r.error
                                return Message.warning(r.error)
                        else
                                return Message.success("Case filed!"))

Template.tools.rendered = ->

        ev = ch = [{num: alphabet[0], type: "success", sign: "+", val: ""}]

        Session.set("evidence", ev)
        Session.set("charges", ch)

Template.tools.helpers

        'evidence': -> Session.get("evidence")

        'charges': -> Session.get("charges")
