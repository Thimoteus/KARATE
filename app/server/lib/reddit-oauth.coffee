class @RedditOAuth

        constructor: (@accessToken, @refreshToken, @expiresIn) ->

                @oauth_base_url = "https://oauth.reddit.com"
                @anon_base_url = "http://www.reddit.com"
                @userAgent = "Meteor/1.0"

        call: (method, url, options = {}) ->
                me = this
                doCall = ->
                        options.headers =
                                "Authorization": "bearer #{me.accessToken}"
                                "User-Agent": me.userAgent

                        Meteor.http.call(method, url, options)

                try
                        res = doCall()
                        return res
                catch e
                        res = e.response

                        if res.statusCode is 401
                                if @_refreshAccessToken(@refreshToken)
                                        return doCall()

                        throw e


        get: (url, options = {}) -> @call("GET", url, options)

        post: (url, options = {}) -> @call("POST", url, options)

        _refreshAccessToken: (refreshToken) ->

                config = ServiceConfiguration.configurations.findOne('service': 'reddit')
                params =
                        "grant_type": "refresh_token"
                        "refresh_token": refreshToken
                opts =
                        params: params
                        auth: "#{config.appId}:#{config.secret}"

                res = Meteor.http.post("https://ssl.reddit.com/api/v1/access_token", opts)

                if res.data and res.data.access_token

                        accessToken = res.data.access_token
                        expiresIn = res.data.expires_in
                        o = {}
                        o['services.reddit.accessToken'] = accessToken
                        o['services.reddit.expiresIn'] = expiresIn
                        @accessToken = accessToken
                        @expiresIn = expiresIn

                        Meteor.users.update(Meteor.userId(), {$set: o})

                        return true
                else
                        return false

class @Reddit extends @RedditOAuth

        constructor: (u) ->

                r = u.services.reddit
                super(r.accessToken, r.refreshToken, r.expiresIn)
                @needsCaptchaError = error: "Please authenticate your email on reddit"

        _getApiItem: (endpt, params = {}) ->

                url = @oauth_base_url + endpt
                opts = if (key for key of params).length is 0 then {} else params: params

                return @get(url, opts)

        _postToApi: (endpt, data = {}) ->

                url = @oauth_base_url + endpt
                opts = if (key for key of data).length is 0 then {} else params: data

                return @post(url, opts)

        _getArticle: (id, sr = null) ->

                if not this[id]?

                        sr = @getShortLinkSr(id) unless sr?
                        this[id] =
                                article: @_getApiItem("/r/#{sr}/comments/#{id}.json")
                                expires: Date.now()+1000*3600

                else if this[id].expires <= Date.now()

                        sr = @getShortLinkSr(id) unless sr?
                        this[id] =
                                article: @_getApiItem("/r/#{sr}/comments/#{id}.json")
                                expires: Date.now()+1000*3600

                return this[id].article

        _getArticleJson: (id) -> @_getArticle(id).data[0].data.children[0].data

        getArticleTitle: (id) -> @_getArticleJson(id).title

        getArticleCreationDate: (id) -> @_getArticleJson(id).created*1000

        needsCaptcha: -> @_getApiItem('/api/needs_captcha.json').data

        canPostToSr: (sr) -> @_getApiItem("/r/#{sr}/about.json")

        isUsername: (usr) -> @_getApiItem("/user/#{usr}/about.json")

        getKCNum: (id) ->

                d = new Date(@getArticleCreationDate(id))

                return "#{d.getFullYear().toString()[2..]}KCC-#{d.getMonth()+1}-#{id}"

        postLinkToSr: (sr, title, url) ->

                data =
                        api_type: 'json'
                        kind: 'link'
                        sr: sr
                        title: title
                        url: url
                        resubmit: true
                        extension: 'json'
                        then: 'comments'

                return @needsCaptchaError if @needsCaptcha()
                return @_postToApi('/api/submit', data)

        postSelfTextToSr: (sr, title, body) ->

                data =
                        api_type: 'json'
                        kind: 'self'
                        sr: sr
                        title: title
                        text: body
                        extension: 'json'
                        then: 'comments'

                return @needsCaptchaError if @needsCaptcha()
                return @_postToApi('/api/submit', data)

        submitCaseLink: (kase, sr) -> return @postLinkToSr(sr, kase.title, "http://redd.it/#{kase.number}")

        sendPM: (recipient, title, msg) ->

                data =
                        api_type: 'json'
                        subject: title
                        text: msg
                        to: recipient

                return @needsCaptchaError if @needsCaptcha()
                return @_postToApi('/api/compose', data)

        replyToArticle: (recipient, msg) ->

                data =
                        api_type: 'json'
                        text: msg
                        parent: "t3_" + getArticleSrAndId(Meteor.user().profile.settings.recipient)[1]

                return @needsCaptchaError if @needsCaptcha()
                return @_postToApi('/api/comment', data)

        _getShortLinkInfo: (id) -> return @_getApiItem("/by_id/t3_#{id}")

        _getShortLinkJson: (id) -> return @_getShortLinkInfo(id).data.data.children[0].data

        getShortLinkSr: (id) -> return @_getShortLinkJson(id).subreddit

        _getFlairOptionsForPost: (id) ->

                sr = @getShortLinkSr(id)
                data =
                        link: "t3_#{id}"

                return @_postToApi("/r/#{sr}/api/flairselector", data)

        setFlairOption: (id, flair = /case/i) ->

                flairOptions = @_getFlairOptionsForPost(id).data.choices

                for opt in flairOptions
                        flairTemplateId = opt.flair_template_id if flair.test(opt.flair_text)

                return false unless flairTemplateId

                sr = @getShortLinkSr(id)
                data =
                        api_type: 'json'
                        link: "t3_#{id}"
                        flair_template_id: flairTemplateId

                return @_postToApi("/r/#{sr}/api/selectflair", data)

        editUserText: (name, text) ->

                data =
                        api_type: 'json'
                        text: text
                        thing_id: name

                return @_postToApi("/api/editusertext", data)
