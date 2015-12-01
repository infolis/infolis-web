Welcome to the Datasetifier - a demo of what you can do with our API!

You can combine the different algorithms provided by our API to create new
services and integrate them into your platform.

In this demo, we combined [upload](http://infolis.gesis.org/infolink/api) and
[execute](http://infolis.gesis.org/infolink/api) with the algorithms
[TextExtractor]
(https://github.com/infolis/infolis-web/wiki/API-calls-to-algorithms#textextractor)
and [ApplyPatternAndResolve]
(https://github.com/infolis/infolis-web/wiki/API-calls-to-algorithms#applypatternandresolve).
This enables us to provide a lightweight service to upload pdf files and extract
[EntityLink]
(http://infolis.gesis.org/infolink/api/entityLink)s.
For demonstration purposes, a very limited set of [InfolisPattern]
(http://infolis.gesis.org/infolink/api/infolisPattern)s is used 
for extraction. When creating your own service, you can of course add a more 
extensive set of patterns or include a pattern learning step by calling the
[FrequencyBasedBootstrapping]() algorithm beforehand.

If you'd like to play around with this demo, you might want to try uploading
these documents:
[document1](http://www.ssoar.info/ssoar/handle/document/16963), 
[document2](http://www.ssoar.info/ssoar/handle/document/17519)

