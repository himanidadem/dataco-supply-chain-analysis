-- ============================================================
-- DataCo Supply Chain - Star Schema
-- ============================================================
-- Drops existing tables (clean slate) and creates star schema
-- with 1 fact table and 5 dimension tables.
-- ============================================================

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS fact_order_items CASCADE;
DROP TABLE IF EXISTS dim_orders CASCADE;
DROP TABLE IF EXISTS dim_products CASCADE;
DROP TABLE IF EXISTS dim_categories CASCADE;
DROP TABLE IF EXISTS dim_customers CASCADE;
DROP TABLE IF EXISTS dim_dates CASCADE;

-- ============================================================
-- DIMENSION: Customers
-- ============================================================
CREATE TABLE dim_customers (
    customer_id       INTEGER PRIMARY KEY,
    customer_segment  VARCHAR(50),
    customer_city     VARCHAR(100),
    customer_state    VARCHAR(100),
    customer_country  VARCHAR(100),
    customer_zipcode  INTEGER
);

-- ============================================================
-- DIMENSION: Categories
-- ============================================================
CREATE TABLE dim_categories (
    category_id    INTEGER PRIMARY KEY,
    category_name  VARCHAR(100)
);

-- ============================================================
-- DIMENSION: Products
-- ============================================================
CREATE TABLE dim_products (
    product_card_id  INTEGER PRIMARY KEY,
    product_name     VARCHAR(255),
    product_price    NUMERIC(10, 2),
    category_id      INTEGER REFERENCES dim_categories(category_id),
    department_id    INTEGER,
    department_name  VARCHAR(100)
);

-- ============================================================
-- DIMENSION: Dates
-- ============================================================
CREATE TABLE dim_dates (
    date_key          DATE PRIMARY KEY,
    year              INTEGER,
    month             INTEGER,
    quarter           INTEGER,
    day_of_week       VARCHAR(15),
    is_weekend        BOOLEAN,
    year_month        VARCHAR(7)
);

-- ============================================================
-- DIMENSION: Orders (order-header info, excluding measures)
-- ============================================================
CREATE TABLE dim_orders (
    order_id                  INTEGER PRIMARY KEY,
    customer_id               INTEGER REFERENCES dim_customers(customer_id),
    order_date                DATE,
    shipping_date             DATE,
    order_status              VARCHAR(50),
    payment_type              VARCHAR(50),
    delivery_status           VARCHAR(50),
    delivery_performance      VARCHAR(20),
    late_delivery_risk        INTEGER,
    days_shipping_real        INTEGER,
    days_shipping_scheduled   INTEGER,
    shipping_delay_days       INTEGER,
    shipping_mode             VARCHAR(50),
    market                    VARCHAR(50),
    order_city                VARCHAR(100),
    order_state               VARCHAR(100),
    order_country             VARCHAR(100),
    order_region              VARCHAR(100),
    order_zipcode             INTEGER
);

-- ============================================================
-- FACT: Order Items
-- ============================================================
CREATE TABLE fact_order_items (
    order_item_id              INTEGER PRIMARY KEY,
    order_id                   INTEGER REFERENCES dim_orders(order_id),
    product_card_id            INTEGER REFERENCES dim_products(product_card_id),
    customer_id                INTEGER REFERENCES dim_customers(customer_id),
    category_id                INTEGER REFERENCES dim_categories(category_id),
    date_key                   DATE REFERENCES dim_dates(date_key),
    
    -- Measures
    order_item_quantity        INTEGER,
    line_item_sales            NUMERIC(10, 2),
    sales_after_discount       NUMERIC(10, 2),
    order_item_discount        NUMERIC(10, 2),
    order_item_discount_rate   NUMERIC(5, 4),
    profit_per_order           NUMERIC(10, 2),
    profit_margin              NUMERIC(7, 4),
    discount_pct               NUMERIC(5, 2),
    
    -- Flags / categorical
    is_profitable              BOOLEAN,
    order_value_tier           VARCHAR(10)
);

-- ============================================================
-- INDEXES (for query performance)
-- ============================================================
CREATE INDEX idx_fact_order_id      ON fact_order_items(order_id);
CREATE INDEX idx_fact_product_id    ON fact_order_items(product_card_id);
CREATE INDEX idx_fact_customer_id   ON fact_order_items(customer_id);
CREATE INDEX idx_fact_date          ON fact_order_items(date_key);
CREATE INDEX idx_orders_customer    ON dim_orders(customer_id);
CREATE INDEX idx_products_category  ON dim_products(category_id);