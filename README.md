Current version: 0.2.1

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
0.2.1

Improvements:

1. Added ability to file new cases in KarmaCourt to the "tools" section. This requires logging out and into the application.

0.2.0

Improvements:

1. Restructured the whole thing
2. Added "reporter" as a new role
3. Can now add and edit notes for individual cases

0.1.2

Impovements:

1. Added case number and role to links posted to the firm.
2. Automatically tries to set case flair to links submitted to a user's firm. You will need to log out and log back in to KARATE for this to work.
3. Added "bailiff" and "executioner" as roles.

Bugfixes:

1. Users without a firm will now not have the "post to firm" button appear when submitting a new case.
2. Updating to reddit is now disabled while editing a case.

0.1.1

Improvements:

1. helpful tooltips when submitting a new case
2. added support for cases from arbitrary subreddits

Bugfixes:

1. you will now get warnings if you try to post a link to your firm and you haven't set a firm
2. shortlinks now work (redd.it/ and reddit.com/tb/)
