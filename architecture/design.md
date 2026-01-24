# E-commerce Analytics Platform — Architecture

## 1. Objetivo

Diseñar una plataforma escalable de analytics para un ecommerce. El sistema soporta procesamiento batch y streaming (tiempo real) considerando arquitectura resiliente, idempotente y con enfoques y prácticas para optimización de costos.

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

Events:
- product_view
- add_to_cart
- checkout
- purchase

Key Metrics:
- revenue
- conversion_rate
- avg_order_value
- funnel_dropoff

## 3. Architecture Overview

[diagram]

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