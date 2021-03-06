/*
 * Copyright 2016 Red Hat Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package enmasse.mqtt.storage.impl;

import enmasse.mqtt.messages.AmqpWillMessage;
import enmasse.mqtt.storage.LwtStorage;
import io.vertx.core.AsyncResult;
import io.vertx.core.Future;
import io.vertx.core.Handler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

/**
 * In memory implementation of the LWT Storage service
 */
@Component
public class InMemoryLwtStorage implements LwtStorage {

    public static final Logger LOG = LoggerFactory.getLogger(InMemoryLwtStorage.class);

    Map<String, AmqpWillMessage> wills;

    @Override
    public void open(Handler<AsyncResult<Void>> handler) {

        if (wills == null) {
            wills = new HashMap<>();
        }

        handler.handle(Future.succeededFuture());
    }

    @Override
    public void add(String clientId, AmqpWillMessage willMessage, Handler<AsyncResult<Integer>> handler) {

        if (this.wills.containsKey(clientId)) {
            LOG.warn("Will already existing for the client {}", clientId);
            handler.handle(Future.failedFuture(new IllegalArgumentException("Will already existing for the client")));
        } else {
            this.wills.put(clientId, willMessage);
            LOG.info("Will added for the client {}", clientId);
            handler.handle(Future.succeededFuture());
        }
    }

    @Override
    public void get(String clientId, Handler<AsyncResult<AmqpWillMessage>> handler) {

        if (!this.wills.containsKey(clientId)) {
            LOG.warn("No will for the client {}", clientId);
            handler.handle(Future.failedFuture(new IllegalArgumentException("No will for the client")));
        } else {
            LOG.info("Will retrieved for the client {}", clientId);
            handler.handle(Future.succeededFuture(this.wills.get(clientId)));
        }
    }

    @Override
    public void update(String clientId, AmqpWillMessage willMessage, Handler<AsyncResult<Integer>> handler) {

        if (!this.wills.containsKey(clientId)) {
            LOG.warn("No will for the client {}", clientId);
            handler.handle(Future.failedFuture(new IllegalArgumentException("No will for the client")));
        } else {
            this.wills.put(clientId, willMessage);
            LOG.info("Will updated for the client {}", clientId);
            handler.handle(Future.succeededFuture());
        }
    }

    @Override
    public void delete(String clientId, Handler<AsyncResult<Integer>> handler) {

        if (!this.wills.containsKey(clientId)) {
            LOG.warn("No will for the client {}", clientId);
            handler.handle(Future.failedFuture(new IllegalArgumentException("No will for the client")));
        } else {
            this.wills.remove(clientId);
            LOG.error("Will deleted for the client {}", clientId);
            handler.handle(Future.succeededFuture());
        }
    }

    @Override
    public void close() {

        // TODO
        if (wills != null) {
            wills.clear();
        }
    }
}
