@roles = ["judge","jury","prosecution","defense"]
@statuses = ["pre-trial","in-session","guilty","not-guilty","dismissed","mistrial", "plea-bargain"]

@getArticleSrAndId = (url) ->

        # https://www.reddit.com/r/KarmaCourt/comments/2oblji/the_people_of_rfunny_vs_umadfotze_for/
        re = /r\/(\w+)\/comments\/(\w{6})/
        caseInfo = re.exec url

        return if caseInfo then [caseInfo[1],caseInfo[2]] else null