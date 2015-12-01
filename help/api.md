Feel free to look around and test our API.

It consists of three different parts: 
*essential*, *advanced* and a list of *rest-Id* methods.

*essential* contains methods for uploading files (_upload_) and executing
algorithms (_execute_). Please note that uploaded files will not be available for
download for copyright reasons.

*advanced* contains methods for monitoring executions and the provenance chains
of produced resources (_monitor_). Furthermore, it allows importing database 
dumps (_json-import_) and displaying the current state of the data store
(_stats_).

The *rest-Id* methods enable the search for specific resources in the data store.

Check out some [example API
calls](https://github.com/infolis/infolis-web/wiki/API-calls-to-algorithms) and
a collection of [URIs of example
resources](https://gist.github.com/bolandka/7b307b45f1f8b93e7b89) to try out
different methods and make yourself familiar with the API.

Please note: This API is in rapid development. If you have problems using it or
if you find a bug, please [create an issue]
(https://github.com/infolis/infolis-web/issues).
