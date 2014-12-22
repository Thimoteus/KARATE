The **Kar**ma **A**ttorney **T**ool **E**ngine is a tool developed by [/u/Thimoteus](https://www.reddit.com/user/Thimoteus) to help [KarmaCourt](https://www.reddit.com/r/KarmaCourt) attorneys keep track of their cases.

Dependencies: 

1. accounts-base
2. accounts-oauth
3. accounts-reddit
4. accounts-ui
5. coffeescript
6. less
7. meteor-platform
8. mizzao:bootstrap-3
9. service-configuration

######changelog
0.1.2

Impovements:

1. Added case number and role to links posted to the firm.
2. Automatically tries to set case flair to links submitted to a user's firm. You will need to log out and log back in to KARATE for this to work.

<!-- Bugfixes: -->

<!-- 1.  -->

0.1.1

Improvements:

1. helpful tooltips when submitting a new case
2. added support for cases from arbitrary subreddits

Bugfixes:

1. you will now get warnings if you try to post a link to your firm and you haven't set a firm
2. shortlinks now work (redd.it/ and reddit.com/tb/)
