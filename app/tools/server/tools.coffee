alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

caseText = (num, charges, explanation, evidence) ->
        CHARGES = ""
        CHARGES += "**CHARGE:** #{ch}\n\n" for ch in charges
        EVIDENCE = ""
        EVIDENCE += "[EXHIBIT #{alphabet[i]}](#{ev})\n\n" for ev, i in evidence

        """
        CASE Number: #{num}

        #{CHARGES}

        #{explanation}

        ---

        Evidence:

        #{EVIDENCE}

        ---

        JUDGE- TBA

        DEFENCE- TBA

        PROSECUTOR- TBA

        BAILIFF: TBA

        Karma Court Reporter: TBA

        Karma Court Reporter Article: TBA
        """

Meteor.methods

        'fileNewCase': (docket) ->
                check(docket.plaintiff, val.isProperString)
                check(docket.defendant, val.isProperString)
                check(docket.charges, val.isProperArray)
                check(docket.explanation, val.isProperString)
                check(docket.evidence, val.isProperArray)

                title = "#{docket.plaintiff} VS #{docket.defendant} FOR #{docket.charges.join(", ")}"

                try
                        res = reddit.postSelfTextToSr("KarmaCourt", title, caseText("", docket.charges, docket.explanation, docket.evidence))
                        name = res.data.json.data.name
                        id = res.data.json.data.id
                        KCnum = reddit.getKCNum(id)
                catch e
                        return {error: "Could not post to reddit."}

                try
                        body = caseText(KCnum, docket.charges, docket.explanation, docket.evidence)
                        reddit.editUserText(name, body)
                        return true
                catch e
                        return {error: "Please log out of KARATE and log back in"} if e.response.statusCode is 403
                        return {error: "Something went wrong"}
