# Linux Security Agent

A lightweight event-monitoring agent for Linux systems, designed for real-time security analysis, rule-based detection, and integration with Kafka pipelines.


## Architecture Overview

```mermaid
flowchart LR
    subgraph "Docker Container"
        subgraph "Agent Subsystem (Dockerized)"
            EM["Event Monitor Module"]
            RE["Rule Engine"]
            ED["Event Dispatcher (Queue + Throttling)"]
            API["API Client (Daily Rule Updates)"]
            KL["Kafka Listener (Critical Rule Updates)"]
            SM["Security Module (SSH Token Management)"]
            LH["Logging & Health Check"]
        end
    end

    subgraph "External System"
        OS["Linux OS / Host System"]
        KB["Kafka Broker"]
        BE["Backend Server"]
        RA["Rule API"]
    end

    OS --> EM
    EM --> RE
    RE --> ED
    ED --> KB
    API --> RA
    KL --> KB
    KL --> RE
    API --> RE
    ED --> SM
    ED --> LH
    LH --> BE
```