@roles = ["judge","jury","prosecution","defense","bailiff","executioner","reporter"]
@statuses = ["pre-trial","in-session","guilty","not-guilty","dismissed","mistrial", "plea-bargain"]

@getArticleSrAndId = (url) ->
        # https://www.reddit.com/r/KarmaCourt/comments/2oblji/the_people_of_rfunny_vs_umadfotze_for/
        re1 = /r\/(\w+)\/comments\/(\w{6})/
        # http://redd.it/2pu0o2
        re2 = /redd\.it\/(\w{6})/
        # http://www.reddit.com/tb/2phq1j
        re3 = /reddit.com\/tb\/(\w{6})/

        if re1.test url
                return re1.exec(url)[1..2]
        if re2.test url
                return [null, re2.exec(url)[1]]
        if re3.test url
                return [null, re3.exec(url)[1]]
        return null
