CREATE TABLE ab_experiment_users (
    user_id INT PRIMARY KEY,
    experiment_group VARCHAR(20),   -- Control / Variant
    device VARCHAR(20),             -- Tablet / Mobile / Desktop
    traffic_source VARCHAR(50),     -- Paid Search / Direct / Social / Email / Organic
    age_group VARCHAR(10),          -- 18-24 / 25-34 / 35-44 / 45-54 / 55+
    view BOOLEAN,
    click BOOLEAN,
    add_to_cart BOOLEAN,
    checkout BOOLEAN,
    purchase BOOLEAN,
    order_value FLOAT,
    revenue FLOAT
);

select * from ab_experiment_users;


-- Funnel Analysis

-- Stage counts for Control vs Variant
SELECT
    experiment_group,
    COUNT(*) AS total_users,
    SUM(view::int) AS views,
    SUM(click::int) AS clicks,
    SUM(add_to_cart::int) AS add_to_cart,
    SUM(checkout::int) AS checkouts,
    SUM(purchase::int) AS purchases
FROM ab_experiment_users
GROUP BY experiment_group;

-- Conversion rates between funnel stages
SELECT 
    experiment_group,
    ROUND(SUM(CASE WHEN click = TRUE THEN 1 ELSE 0 END)::numeric /
          NULLIF(SUM(CASE WHEN view = TRUE THEN 1 ELSE 0 END),0), 4) AS view_to_click_rate,
    ROUND(SUM(CASE WHEN add_to_cart = TRUE THEN 1 ELSE 0 END)::numeric /
          NULLIF(SUM(CASE WHEN click = TRUE THEN 1 ELSE 0 END),0), 4) AS click_to_cart_rate,
    ROUND(SUM(CASE WHEN checkout = TRUE THEN 1 ELSE 0 END)::numeric /
          NULLIF(SUM(CASE WHEN add_to_cart = TRUE THEN 1 ELSE 0 END),0), 4) AS cart_to_checkout_rate,
    ROUND(SUM(CASE WHEN purchase = TRUE THEN 1 ELSE 0 END)::numeric /
          NULLIF(SUM(CASE WHEN checkout = TRUE THEN 1 ELSE 0 END),0), 4) AS checkout_to_purchase_rate,
    ROUND(SUM(CASE WHEN purchase = TRUE THEN 1 ELSE 0 END)::numeric /
          NULLIF(SUM(CASE WHEN view = TRUE THEN 1 ELSE 0 END),0), 4) AS overall_conversion_rate
FROM ab_experiment_users
GROUP BY experiment_group;



-- Drop-off rates (1 - conversion rate)
SELECT
    experiment_group,
    ROUND(1 - SUM(click::int)::numeric / NULLIF(SUM(view::int), 0), 4) AS drop_after_view,
    ROUND(1 - SUM(add_to_cart::int)::numeric / NULLIF(SUM(click::int), 0), 4) AS drop_after_click,
    ROUND(1 - SUM(checkout::int)::numeric / NULLIF(SUM(add_to_cart::int), 0), 4) AS drop_after_cart,
    ROUND(1 - SUM(purchase::int)::numeric / NULLIF(SUM(checkout::int), 0), 4) AS drop_after_checkout
FROM ab_experiment_users
GROUP BY experiment_group;


-- Revenue comparison
SELECT 
    experiment_group,
    ROUND(AVG(order_value)::numeric,2) AS avg_order_value,
    ROUND(SUM(revenue)::numeric,2) AS total_revenue
FROM ab_experiment_users
GROUP BY experiment_group;
