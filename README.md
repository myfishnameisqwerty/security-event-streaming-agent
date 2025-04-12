```mermaid
flowchart TD
    OS[Linux OS / Host System]

    subgraph AG[Agent]
        EM[Event Monitor Module]
        RE[Rule Engine]
        ED[Event Dispatcher & Throttler]
        API["API Client (Daily Updates)"]
        KL["Kafka Listener (Critical Updates)"]
        SM["Security Module (SSH Token)"]
        LH["Logging & Health Check"]
    end

    OS --> EM
    EM --> RE
    RE --> ED
    ED --> SM
    ED -->|Publish Events| Kafka[Kafka Broker]
    API -->|Fetch Rules| RE
    KL -->|Real-Time Updates| RE
    EM --> LH
    ED --> LH





