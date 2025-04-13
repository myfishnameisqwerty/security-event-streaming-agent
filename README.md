# Linux Security Agent

A lightweight event-monitoring agent for Linux systems, designed for real-time security analysis, rule-based detection, and integration with Kafka pipelines.


## Architecture Overview

```mermaid
flowchart TD
    %% Local Systems
    subgraph Local["Local Systems"]
        OS["💻 Linux OS"]
    end

    %% Agent Subsystem (Dockerized)
    subgraph Agent_Subsystem["Agent Subsystem (Dockerized)"]
        EM["📊 Event Monitor Module"]
        RE["⚙️ Rule Engine<br/>(Rules & Commands)"]
        ED["📤 Event Dispatcher<br/>(Queue + Throttling)"]
        SM["🔒 Security Module<br/>(SSH Token Management)"]
        LH["🩺 Logging & Health Check<br/>(Log Sender)"]
        KP_Data["🚀 Kafka Producer<br/>(Outbound Events)"]
        KP_Log["📦 Kafka Producer<br/>(Outbound Logs)"]
        KC["📡 Kafka Consumer<br/>(Broadcast Updates)"]
        RP["📩 RabbitMQ Consumer<br/>(Command Responses)"]
    end

    %% Central Compute Cluster (CCM)
    subgraph CCM["Central Compute Cluster (CCM)"]
        subgraph Event_Processing["Event Processing"]
            EK["☁️ Kafka Broker<br/>(Event Ingestion)"]
            CC["🖥️ Data Aggregation & Processing"]
        end

        subgraph Rule_Distribution["Rule Distribution"]
            RUF["📜 Rule Update Fetcher"]
            CACHE["🗂️ Rule Cache"]
            RMQ["🐇 RabbitMQ<br/>(Targeted Commands & Responses)"]
            BK["📢 Kafka Broadcaster<br/>(Broadcast Updates)"]
        end

        subgraph Log_Processing["Log Processing"]
            LK["📝 Log Kafka<br/>(Log Ingestion)"]
            LA["🚀 Log Aggregator<br/>(Forwarder to Coralogix)"]
        end
    end

    %% External Systems
    subgraph External["External Systems"]
        RA["📜 Rule API"]
        BE["📡 Backend Server"]
        COR["🔔 Coralogix"]
    end

    %% Updated Flows

    %% External Systems to CCM (Event Flow):
    RA --> RUF
    RUF --> CACHE
    CACHE --> RMQ
    CACHE --> BK

    %% Outbound: Event Routing from CCM to Backend
    EK --> CC
    CC --> BE

    %% Log Processing from CCM to Coralogix:
    LK --> LA
    LA --> COR

    %% Agent Subsystem Internal Flows
    EM --> RE
    RE --> ED
    ED --> KP_Data
    LH --> KP_Log
    RP --> RE
    KC --> RE

    %% Flows from Agent Subsystem to CCM
    KP_Data --> EK
    KP_Log --> LK

    %% Connection from Local Systems to Agent Subsystem
    OS --> EM

```

### Agent design
```mermaid
flowchart TB
    %% Agent Subsystem (Dockerized)
    subgraph "Agent Subsystem (Dockerized)"
      
        subgraph EM["📊 Event Monitor Module"]
            EMN1["Process Activity Monitor"]
            EMN2["Network Activity Monitor"]
            EMN3["Resource Usage Tracker"]
        end
        
        subgraph RE["⚙️ Rule Engine"]
            RE1["Local Rules Validator"]
            RE2["Rule Synchronization Handler"]
            RP["📩 RabbitMQ Consumer<br/>(Command Responses)"]
            KC["📡 Kafka Consumer<br/>(Broadcast Updates)"]
        end
        
        subgraph ED["📤 Event Dispatcher<br>(Queue + Throttling)"]
            ED1["Event Queue Manager"]
            ED2["Throttling Controller"]
            KP_Data["🚀 Kafka Producer<br/>(Outbound Events)"]
        end
        
        subgraph SM["🔒 Security Module"]
            SM1["SSH Token Manager"]
            SM2["Encryption Handler"]
        end
        
        subgraph LH["🩺 Logging & Health Check"]
            LH1["Health Check Endpoint"]
            LH2["Structured Logging"]
            KP_Log["📦 Kafka Producer<br/>(Outbound Logs)"]
        end
        
    end

    OS["💻 Linux OS / Host System"] --> EM

    %% Flows within the Agent Subsystem:
    EMN1 --> RE
    EMN2 --> RE
    EMN3 --> RE

    RE1 --> ED
    RE2 --> SM

    ED1 --> SM
    ED2 --> LH

    SM1 --> ED2
    SM2 --> ED2

    LH1 --> LH2
    LH2 --> KP_Log

    ED --> KP_Data

    RP --> RE
    KC --> RE
```