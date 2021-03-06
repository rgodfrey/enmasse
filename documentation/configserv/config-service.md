The configuration service is an AMQP service accepting subscriptions to the EnMasse address
configuration.

To use the configuration service, the client have to attach a receiver with a source address `maas`.

Once subscribed, the configuration service will notify the client of any updates to the address
configuration. 

The format of the address configuration is a JSON object describing the addresses and their
properties. Example config with all possible values of an address definition:

```
    {
        "anycast": {
            "store_and_forward": false,
            "multicast": false
        },
        "broadcast": {
            "store_and_forward": false,
            "multicast": true
        },
        "mytopic": {
            "store_and_forward": true,
            "multicast": true,
            "flavor": "vanilla-topic"
        },
        "myqueue": {
            "store_and_forward": true,
            "multicast": false,
            "flavor": "vanilla-queue"
        }
    }
```
