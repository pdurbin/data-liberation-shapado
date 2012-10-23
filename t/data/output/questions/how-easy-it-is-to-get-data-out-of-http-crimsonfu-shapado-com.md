---
title: How easy it is to get data out of http://crimsonfu.shapado.com ?
layout: default
---
http://crimsonfu.shapado.com is not hosted on any servers we control. How easy is it for us to get our data out of it? What if the service goes away? Should we make regular backups of our content? That was more than one question...

*Asked by 5083ea5997cfef5794002881 on 2012-10-21T12:33:47+00:00*

<hr>
## Answer 1 by 5083ea5997cfef5794002881

http://shapado.com/questions/does-shapado-have-a-web-service-api-of-any-kind says "yes shapado have a API, we haven’t had enough time to write the doc" but by poking at URLs and looking at the Shapado code https://github.com/ricodigo/shapado/tree/master/app/controllers I was able to find the following data feeds:

* http://crimsonfu.shapado.com/questions.json
* http://crimsonfu.shapado.com/answers.json
* http://crimsonfu.shapado.com/questions/tags.json
* http://crimsonfu.shapado.com/badges.json
* http://crimsonfu.shapado.com/users/pdurbin.json (for example)

Strangely, it's somewhat difficult to get a list of users out of Shapado. If you try the logical URL, you get an empty hash for every user..

* http://crimsonfu.shapado.com/users.json

... but you can grovel through some HTML here to determine a mapping between uuid's and usernames for users:

* http://crimsonfu.shapado.com/users.js
