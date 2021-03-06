# Subscription Service

The Subscription Service (SS) has an AMQP receiver on the following control address :

* $mqtt.subscriptionservice

It's able to handle following scenarios :

* on client connection (if clean session is FALSE) receiving the “list” message in order to handle session for the client. If needed, the SS checks if a session already exists for the client-id in terms of subscriptions and replies with topics list and related QoS levels.
* on client connection (if clean session is TRUE) receiving the "close" message in order to clean every other previous session for the client-id.
* receiving a request from a client for subscribing to a topic. The SS has to ensure a route from “topic” to the unique client publish address $mqtt.to.[client-id].publish. It's not in charge for delivering but only to ensure that a route is established.
* receiving a request from a client for unsubscribing to a topic.
* ensuring delivering of "lost" messages on subscribed topics when the client was offline.
* ensuring delivering of retained message if it’s available for each subscribed “topic” when a new client subscribes to it.

Due to the nature of the MQTT _CONNECT_, _SUBSCRIBE_ and _UNSUBSCRIBE_ messages which need QoS Level 1 (AT_LEAST_ONCE) on delivery, the AMQP receiver on the control address is attached with :

* rcv-settle-mode : first (0)
* snd-settle-mode : unsettled (0)

The SS replies with the result of the connection (with topics list and related QoS levels, if "list" is requested), subscription (with granted QoS levels) and unsubscription requests to the following client specific address :

* $mqtt.to.[client-id].control
