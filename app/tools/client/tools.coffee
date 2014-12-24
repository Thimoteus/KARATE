
Template.tools.events

        'submit #tools-username': (evt, cxt) ->
                evt.preventDefault()

                usr = cxt.$("#search-username")[0].value
                service = cxt.$("#tools-username input[type='radio']:checked")[0].value

                switch service
                        when "redective"
                                window.open('http://www.redective.com/?r=e&a=search&s=user&t=redective&q=' + encodeURIComponent(usr))
                        when "rcs"
                                window.open('http://redditcommentsearch.com/?query=&user=' + encodeURIComponent(usr))
                        when "metareddit"
                                window.open('http://metareddit.com/stalk?user=' + encodeURIComponent(usr))
                        else
                                window.open('https://www.reddit.com/user/' + encodeURIComponent(usr))

        'submit #tools-image': (evt, cxt) ->
                evt.preventDefault()

                imageURL = cxt.$('#search-image')[0].value
                service = cxt.$("#tools-image input[type='radio']:checked")[0].value

                switch service
                        when "karmadecay"
                                window.open('http://karmadecay.com/search?kdtoolver=m2&q=' + encodeURIComponent(imageURL))
                        when "tineye"
                                window.open('http://www.tineye.com/search?url=' + encodeURIComponent(imageURL))
                        else
                                window.open('http://images.google.com/searchbyimage?image_url=' + encodeURIComponent(imageURL))