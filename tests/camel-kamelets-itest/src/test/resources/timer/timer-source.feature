# ---------------------------------------------------------------------------
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ---------------------------------------------------------------------------

Feature: Timer Source Kamelet

  Background:
    Given HTTP server timeout is 5000 ms
    Given HTTP server "test-service"

  Scenario: Create Http server
    Given create Kubernetes service test-service with target port 8080
    Given purge endpoint test-service

  Scenario: Create Kamelet binding
    And variables
      | message  | Hello World |
    Given load Pipe timer-to-http.yaml
    Then Pipe timer-to-http should be available
    Then Camel K integration timer-to-http should be running
    And Camel K integration timer-to-http should print Routes startup

  Scenario: Verify binding
    Given expect HTTP request body: Hello World
    When receive POST /events
    Then send HTTP 200 OK

  Scenario: Remove Camel K resources
    Given delete Pipe timer-to-http
    And delete Kubernetes service test-service
