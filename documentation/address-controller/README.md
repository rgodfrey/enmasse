# Address controller

The address controller is about more than controller addresses. The main tasks performed by the address controller are:

   * API server for managing address spaces and addresses (HTTP and AMQP)
   * Implementation of Open Service Broker API for EnMasse
   * Controller for taking action based on address spaces (create/destroy enmasse infrastructure and managing routing + certs) etc.)
   * Controller for taking action based on addresses (create/destroy deployments for addresses pointing to flavors for brokers for instance)

## API server

The API server provides both an HTTP and AMQP API for creating/deleting address spaces and addresses
within those instances. The REST API documentation can be found [here](../address-model/resource-definitions.md).

## Open Service Broker API

TODO

## Address Space controller

TODO

## Address controller

TODO
