Setting up Full-Text-Search using eXist
=======================================

Installing and configuring eXist
--------------------------------

Do this once when configuring a host:

1. Get eXist
2. Install it somewhere: `java -jar eXist-db-setup-2.2.jar -console`
3. configure the built-in Jetty server. To do so, edit tools/jetty/etc/jetty.xml. Look for some properties and edit the corresponding settings:

   1. `jetty.host` to `127.0.0.1` to avoid connections from outside
   2. `jetty.port` to some port

Configuring the web server
--------------------------

Add proxy statements towards the eXist scripts, e.g., for port 5555:

```
ProxyRequests off
ProxyPass /search http://localhost:5555/exist/apps/faust
ProxyPassReverse /search http://localhost:5555/exist/apps/faust
ProxyPassReverseCookiePath /exist /
<Proxy *>
   RequestHeader unset Authorization
</Proxy>
```


Uploading script and data
-------------------------

See faust-gen, the maven build builds an eXist app.
