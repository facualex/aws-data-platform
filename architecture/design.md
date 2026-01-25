## 📊 Plataforma de Analytics para E-commerce (Batch + Streaming)

## 1. Objetivo

Este proyecto diseña e implementa una plataforma escalable de analytics para un e-commerce, combinando procesamiento **batch** y **streaming en tiempo real** sobre AWS.

La arquitectura separa claramente dos tipos de cargas:

- **Batch analytics** para datos transaccionales (usuarios, órdenes, productos), orquestado con Apache Airflow, orientado a backfills, consistencia, control de costos e idempotencia.
- **Streaming analytics** para eventos de comportamiento (clicks, vistas, add-to-cart), utilizando AWS Kinesis como log distribuido y consumidores serverless para ingestión de baja latencia.

El sistema está diseñado con principios de ingeniería de datos reales:

- Ingestión resiliente con retries y backoff.
- Procesamiento idempotente y deduplicación.
- Separación por zonas (RAW, STAGING, MART).
- Soporte para backfills.
- Enfoque en escalabilidad y optimización de costos.
- Preparado para analítica de negocio (funnels, cohortes, LTV, conversión).

En un entorno productivo, esta arquitectura permite capturar eventos en tiempo real mientras mantiene pipelines batch eficientes para analítica histórica y gobierno de datos.

## 2. Dominio

```mermaid
erDiagram
    users ||--o{ orders : ingresa
    orders ||--|{ order_items : contiene
    products ||--o{ order_items : incluye
    users ||--o{ eventos : genera
    products ||--o{ eventos : involucrado_en

    users {
        int user_id PK
        string email
        string country
        datetime created_at
    }

    products {
        int product_id PK
        string name
        string category
        float price
        boolean is_active
        datetime created_at
    }

    orders {
        int order_id PK
        int user_id FK
        string order_status
        float order_total
        datetime created_at
    }

    order_items {
        int order_item_id PK
        int order_id FK
        int product_id FK
        int quantity
        float unit_price
    }

    eventos {
        int event_id PK
        int user_id FK
        int product_id FK
        string event_type
        datetime event_time
        datetime ingestion_time
        string session_id
    }
```

## 3. Architecture Overview

```mermaid
flowchart LR
    %% -------- SOURCES --------
    subgraph Sources
        API[FakeStore API]
        EVGEN[Event Simulator]
    end

    %% -------- STREAMING LAYER --------
    subgraph Streaming
        KIN[Kinesis Data Streams]
        LAMBDA[Lambda Consumer]
    end

    %% -------- ORCHESTRATION --------
    subgraph Orchestration
        AIRFLOW[Airflow Astro]
    end

    %% -------- STORAGE --------
    subgraph Storage
        S3RAW[S3 Raw Zone]
        S3STG[S3 Staging Zone]
    end

    %% -------- PROCESSING --------
    subgraph Processing
        TRANSFORM[Transform Jobs<br/>Python / dbt]
        DQ[Data Quality Checks]
    end

    %% -------- ANALYTICS --------
    subgraph Analytics
        WH[Warehouse]
        BI[BI Dashboard]
    end

    %% -------- FLOWS --------
    API --> AIRFLOW
    AIRFLOW --> S3RAW

    EVGEN --> KIN
    KIN --> LAMBDA
    LAMBDA --> S3RAW

    S3RAW --> TRANSFORM
    TRANSFORM --> DQ
    DQ --> S3STG
    S3STG --> WH
    WH --> BI

    %% -------- FAILURE DESIGN --------
    AIRFLOW -. retries and backoff .-> API
    TRANSFORM -. idempotent loads .-> S3STG
    LAMBDA -. checkpointing .-> KIN
```

## 4. Data Zones

- RAW: immutable ingestion layer
- STAGING: cleaned and typed
- CURATED: analytics-ready

## 5. Batch Ingestion

- Source: FakeStore API
- Orchestration: Airflow
- Retries: exponential backoff
- Timeout handling

## 6. Streaming Ingestion

- Source: Event generator
- Transport: Kinesis
- Deduplication via event_id

## 7. Idempotency Design

- File hashing
- Metadata tracking
- MERGE semantics in warehouse

## 8. Late Data Handling

- event_time vs ingestion_time
- Incremental models
- Backfill strategy

## 9. Failure Scenarios

| Scenario | Detection | Mitigation | Recovery |
|---------|----------|-----------|---------|
| API down | timeout | retries | rerun DAG |
| duplicate file | hash | skip | idempotent merge |
| late events | watermark | buffer | backfill |
| partial write | checksum | atomic write | replay |
| cost growth | metrics | lifecycle | pruning |

## 10. Cost Awareness

- S3 storage estimation
- Redshift compute
- Kinesis shards

## 11. Observability

- Logs
- Metrics
- Alerts

## 12. Future Improvements