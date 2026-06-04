CREATE TABLE customer_churn_raw (
    "CustomerID" INT,
    "Age" INT,
    "Gender" TEXT,
    "Tenure" INT,
    "Usage Frequency" INT,
    "Support Calls" INT,
    "Payment Delay" INT,
    "Subscription Type" TEXT,
    "Contract Length" TEXT,
    "Total Spend" INT,
    "Last Interaction" INT,
    "Churn" INT
);

COPY customer_churn_raw 
FROM '/tmp/customer_churn_raw.csv'
DELIMITER ',' 
CSV HEADER;

SELECT *
FROM customer_churn_raw;

CREATE TABLE customer_churn_staging AS
SELECT * 
FROM customer_churn_raw;


SELECT *
FROM customer_churn_staging;


-- DATA CLEANING

-- check total records
SELECT COUNT(*) AS total_rows
FROM customer_churn_staging;



-- check nulls
SELECT
    COUNT(*) FILTER (WHERE "CustomerID" IS NULL) AS null_customer_id,
    COUNT(*) FILTER (WHERE "Age" IS NULL) AS null_age,
    COUNT(*) FILTER (WHERE "Gender" IS NULL) AS null_gender,
    COUNT(*) FILTER (WHERE "Tenure" IS NULL) AS null_tenure,
    COUNT(*) FILTER (WHERE "Usage Frequency" IS NULL) AS null_usage_freq,
    COUNT(*) FILTER (WHERE "Support Calls" IS NULL) AS null_support_calls,
    COUNT(*) FILTER (WHERE "Payment Delay" IS NULL) AS null_payment_delay,
    COUNT(*) FILTER (WHERE "Subscription Type" IS NULL) AS null_sub_type,
    COUNT(*) FILTER (WHERE "Contract Length" IS NULL) AS null_contract_length,
    COUNT(*) FILTER (WHERE "Total Spend" IS NULL) AS null_total_spend,
    COUNT(*) FILTER (WHERE "Last Interaction" IS NULL) AS null_last_interaction,
    COUNT(*) FILTER (WHERE "Churn" IS NULL) AS null_churn
FROM customer_churn_staging;



-- check pk duplicates
SELECT "CustomerID", COUNT(*) AS duplicate_customer_id
FROM customer_churn_staging
GROUP BY "CustomerID"
HAVING COUNT(*) > 1;


-- check full duplicates
WITH duplicate_cte AS
   ( SELECT *, ROW_NUMBER() OVER(PARTITION BY
        "CustomerID", "Age", "Gender", "Tenure", "Usage Frequency",
        "Support Calls", "Payment Delay", "Subscription Type",
        "Contract Length", "Total Spend", "Last Interaction", "Churn") AS row_num
	FROM customer_churn_staging )
SELECT *
FROM duplicate_cte
WHERE row_num > 1;


SELECT DISTINCT "Gender"            
FROM customer_churn_staging;

SELECT DISTINCT "Subscription Type" 
FROM customer_churn_staging;

SELECT DISTINCT "Contract Length"   
FROM customer_churn_staging;

SELECT DISTINCT "Churn"             
FROM customer_churn_staging;


SELECT
    MIN("Age") age_min, MAX("Age") age_max,
    MIN("Tenure") tenure_min, MAX("Tenure") tenure_max,
    MIN("Usage Frequency") AS usage_freq_min, MAX("Usage Frequency") AS usage_freq_max,
    MIN("Support Calls") AS support_calls_min, MAX("Support Calls") AS support_calls_max,
    MIN("Payment Delay") AS payment_delay_min, MAX("Payment Delay") AS payment_delay_max,
    MIN("Total Spend") AS total_spend_min, MAX("Total Spend") AS total_spend_max,
    MIN("Last Interaction") AS last_interaction_min, MAX("Last Interaction") AS last_interaction_max
FROM customer_churn_staging;


SELECT "Gender", COUNT(*) 
FROM customer_churn_staging 
GROUP BY 1;

SELECT "Subscription Type", COUNT(*) 
FROM customer_churn_staging 
GROUP BY 1;

SELECT "Contract Length", COUNT(*) 
FROM customer_churn_staging 
GROUP BY 1;

SELECT "Churn", COUNT(*) 
FROM customer_churn_staging 
GROUP BY 1;


SELECT
    COUNT(*) FILTER (WHERE "Gender" != TRIM("Gender")) AS gender_ws,
    COUNT(*) FILTER (WHERE "Subscription Type" != TRIM("Subscription Type")) AS sub_type_ws,
    COUNT(*) FILTER (WHERE "Contract Length" != TRIM("Contract Length")) AS contract_ws
FROM customer_churn_staging;


UPDATE customer_churn_staging
SET
    "Gender" = INITCAP(TRIM("Gender")),
    "Subscription Type" = INITCAP(TRIM("Subscription Type")),
    "Contract Length" = INITCAP(TRIM("Contract Length"));


SELECT DISTINCT "Gender"            
FROM customer_churn_staging;
SELECT DISTINCT "Subscription Type" 
FROM customer_churn_staging;
SELECT DISTINCT "Contract Length"   
FROM customer_churn_staging;




SELECT COUNT(*) AS zero_spend_high_tenure
FROM customer_churn_staging
WHERE "Total Spend" = 0 AND "Tenure" > 12;


SELECT COUNT(*) AS no_usage_not_churned
FROM customer_churn_staging
WHERE "Usage Frequency" = 0 AND "Churn" = 0;


SELECT COUNT(*) AS max_support_calls_low_delay
FROM customer_churn_staging
WHERE "Support Calls" = 10 AND "Payment Delay" = 0 AND "Churn" = 0;



ALTER TABLE customer_churn_staging RENAME COLUMN "CustomerID" TO customer_id;
ALTER TABLE customer_churn_staging RENAME COLUMN "Age" TO age;
ALTER TABLE customer_churn_staging RENAME COLUMN "Gender" TO gender;
ALTER TABLE customer_churn_staging RENAME COLUMN "Tenure" TO tenure;
ALTER TABLE customer_churn_staging RENAME COLUMN "Usage Frequency" TO usage_frequency;
ALTER TABLE customer_churn_staging RENAME COLUMN "Support Calls" TO support_calls;
ALTER TABLE customer_churn_staging RENAME COLUMN "Payment Delay" TO payment_delay;
ALTER TABLE customer_churn_staging RENAME COLUMN "Subscription Type" TO subscription_type;
ALTER TABLE customer_churn_staging RENAME COLUMN "Contract Length" TO contract_length;
ALTER TABLE customer_churn_staging RENAME COLUMN "Total Spend" TO total_spend;
ALTER TABLE customer_churn_staging RENAME COLUMN "Last Interaction"  TO last_interaction;
ALTER TABLE customer_churn_staging RENAME COLUMN "Churn" TO churn;


select * from customer_churn_staging;


-- final validation

SELECT
    (SELECT COUNT(*) FROM customer_churn_raw) AS raw_rows,
    (SELECT COUNT(*) FROM customer_churn_staging) AS staging_rows,
     ((SELECT COUNT(*) FROM customer_churn_raw) -
    (SELECT COUNT(*) FROM customer_churn_staging))AS rows_removed;


SELECT
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS null_id,
    COUNT(*) FILTER (WHERE age IS NULL) AS null_age,
    COUNT(*) FILTER (WHERE churn IS NULL) AS null_churn,
    COUNT(*) FILTER (WHERE gender IS NULL) AS null_gender,
    COUNT(*) FILTER (WHERE subscription_type IS NULL) AS null_sub,
    COUNT(*) FILTER (WHERE contract_length IS NULL) AS null_contract
FROM customer_churn_staging;

SELECT customer_id, COUNT(*) FROM customer_churn_staging
GROUP BY customer_id HAVING COUNT(*) > 1;


SELECT DISTINCT gender FROM customer_churn_staging;
SELECT DISTINCT subscription_type FROM customer_churn_staging;
SELECT DISTINCT contract_length FROM customer_churn_staging;
SELECT DISTINCT churn FROM customer_churn_staging;


SELECT
    MIN(age) AS age_min, MAX(age) AS age_max,
    MIN(tenure) AS tenure_min, MAX(tenure) AS tenure_max,
    MIN(total_spend) AS spend_min, MAX(total_spend) AS spend_max
FROM customer_churn_staging;


DROP TABLE IF EXISTS customer_churn_clean;
CREATE TABLE customer_churn_clean AS
    SELECT * FROM customer_churn_staging;



--  EDA

SELECT * FROM customer_churn_clean;


CREATE OR REPLACE VIEW vw_churn_full AS
SELECT customer_id, age, gender, tenure, usage_frequency, support_calls, payment_delay,
	subscription_type, contract_length, total_spend, last_interaction, churn,
    
	CASE WHEN churn = 1 THEN 'Churned' ELSE 'Retained' 
	END AS churn_status,

    CASE
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        WHEN age BETWEEN 56 AND 65 THEN '56-65'
    END AS age_group,

    CASE
        WHEN tenure BETWEEN 1  AND 12 THEN 'Early (1-12m)'
        WHEN tenure BETWEEN 13 AND 24 THEN 'Growing (13-24m)'
        WHEN tenure BETWEEN 25 AND 36 THEN 'Established (25-36m)'
        WHEN tenure BETWEEN 37 AND 48 THEN 'Loyal (37-48m)'
        WHEN tenure BETWEEN 49 AND 60 THEN 'Champion (49-60m)'
    END AS tenure_band,

    CASE
        WHEN total_spend BETWEEN 100 AND 299  THEN 'Low (100-299)'
        WHEN total_spend BETWEEN 300 AND 499  THEN 'Mid-Low (300-499)'
        WHEN total_spend BETWEEN 500 AND 699  THEN 'Mid (500-699)'
        WHEN total_spend BETWEEN 700 AND 899  THEN 'Mid-High (700-899)'
        WHEN total_spend BETWEEN 900 AND 1000 THEN 'High (900-1000)'
    END AS spend_tier,

    CASE
        WHEN usage_frequency BETWEEN 1  AND 6  THEN 'Very Low (1-6)'
        WHEN usage_frequency BETWEEN 7  AND 12 THEN 'Low (7-12)'
        WHEN usage_frequency BETWEEN 13 AND 18 THEN 'Moderate (13-18)'
        WHEN usage_frequency BETWEEN 19 AND 24 THEN 'High (19-24)'
        WHEN usage_frequency BETWEEN 25 AND 30 THEN 'Very High (25-30)'
    END AS usage_band,

    CASE
        WHEN support_calls = 0 THEN 'No Calls'
        WHEN support_calls BETWEEN 1 AND 2  THEN 'Low (1-2)'
        WHEN support_calls BETWEEN 3 AND 5  THEN 'Medium (3-5)'
        WHEN support_calls BETWEEN 6 AND 8  THEN 'High (6-8)'
        WHEN support_calls BETWEEN 9 AND 10 THEN 'Critical (9-10)'
    END AS support_calls_band,

    CASE
        WHEN payment_delay = 0 THEN 'On Time'
        WHEN payment_delay BETWEEN 1  AND 7  THEN 'Slightly Late (1-7d)'
        WHEN payment_delay BETWEEN 8  AND 15 THEN 'Moderately Late (8-15d)'
        WHEN payment_delay BETWEEN 16 AND 22 THEN 'Very Late (16-22d)'
        WHEN payment_delay BETWEEN 23 AND 30 THEN 'Severely Late (23-30d)'
    END AS payment_delay_band,

    CASE
        WHEN last_interaction BETWEEN 1  AND 7  THEN 'Recent (1-7d)'
        WHEN last_interaction BETWEEN 8  AND 14 THEN 'Mild Gap (8-14d)'
        WHEN last_interaction BETWEEN 15 AND 21 THEN 'Concerning (15-21d)'
        WHEN last_interaction BETWEEN 22 AND 30 THEN 'Neglected (22-30d)'
    END AS last_interaction_band,

    CASE
        WHEN (
          CASE WHEN support_calls >= 5 THEN 30 WHEN support_calls >= 3 THEN 15 ELSE 0 END
          + CASE WHEN payment_delay >= 21 THEN 40 WHEN payment_delay >= 16 THEN 30 ELSE 0 END
          + CASE WHEN usage_frequency <= 5 THEN 20 ELSE 0 END
        ) >= 70 THEN 'Critical'
        WHEN (
            CASE WHEN support_calls >= 5 THEN 30 WHEN support_calls >= 3 THEN 15 ELSE 0 END
          + CASE WHEN payment_delay >= 21 THEN 40 WHEN payment_delay >= 16 THEN 30 ELSE 0 END
          + CASE WHEN usage_frequency <= 5 THEN 20 ELSE 0 END
        ) >= 45 THEN 'High'
        WHEN (
            CASE WHEN support_calls >= 5 THEN 30 WHEN support_calls >= 3 THEN 15 ELSE 0 END
          + CASE WHEN payment_delay >= 21 THEN 40 WHEN payment_delay >= 16 THEN 30 ELSE 0 END
          + CASE WHEN usage_frequency <= 5 THEN 20 ELSE 0 END
        ) >= 25 THEN 'Medium'
        ELSE 'Low'
    END AS risk_label

FROM customer_churn_clean;


select * from vw_churn_full;


SELECT
	COUNT(*) AS total_rows,
    COUNT(age_group) AS age_group_filled,
    COUNT(tenure_band) AS tenure_band_filled,
    COUNT(spend_tier) AS spend_tier_filled,
    COUNT(usage_band) AS usage_band_filled,
    COUNT(support_calls_band) AS support_band_filled,
    COUNT(payment_delay_band) AS payment_delay_band_filled,
    COUNT(last_interaction_band) AS recency_band_filled,
    COUNT(risk_label) AS risk_label_filled
FROM vw_churn_full;





--EDA
-- KPI metrics
-- overall churn rate
SELECT 
COUNT (*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) * 100.0/COUNT(*),2) AS churn_rate
FROM vw_churn_full;
-- 47.37% churn rate, 64374 total customers


-- revenue loss from churning
SELECT SUM(total_spend) AS revenue_loss
FROM vw_churn_full
WHERE churn_status = 'Churned';

 
-- Average customer tenure
select round(avg(tenure), 1) as avg_tenure
from vw_churn_full;

-- Average customer spend
select round(avg(total_spend), 1) as avg_customer_spend
from vw_churn_full;

-- Average age of churned customers
select round(avg(age), 1) as avg_age
from vw_churn_full
where churn = 1;



-- churn by gender 
SELECT gender,
COUNT(*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) * 100.0/COUNT(*),1) AS churn_rate
FROM vw_churn_full
GROUP BY gender;
-- females have a churning rate of 55% while males have 38.6%

--- churn by age-group
SELECT age_group,
COUNT(*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) * 100.0/COUNT(*),2) AS churn_rate
FROM vw_churn_full
GROUP BY age_group
ORDER BY churn_rate DESC;
-- 46+ have 49-52% while 18-45 have~44% - not much difference

-- churn by tenure 
SELECT tenure_band,
COUNT(*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) * 100.0/COUNT(*),1) AS churn_rate
FROM vw_churn_full
GROUP BY tenure_band
ORDER BY churn_rate DESC;
-- 25+ months 55-56% while <24 mo ~31%


-- churn by payment delay
SELECT payment_delay_band,
COUNT(*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) * 100.0/COUNT(*),1) AS churn_rate
FROM vw_churn_full
GROUP BY payment_delay_band
ORDER BY churn_rate DESC;
-- 16+ days 64-76% while <15d ~10%

-- churn by usage frequency
SELECT usage_band,
COUNT(*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) * 100.0/COUNT(*),1) AS churn_rate
FROM vw_churn_full
GROUP BY usage_band
ORDER BY churn_rate DESC;
-- <6d 61.8% churn rate 7+d 42-43%

-- churn by support calls
SELECT support_calls_band,
COUNT(*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) * 100.0/COUNT(*),1) AS churn_rate
FROM vw_churn_full
GROUP BY support_calls_band
ORDER BY churn_rate DESC;
-- 6+ ~60% cr, 3-5 have 41% cr and 0-2 have 23-24% cr


-- churn by subscription type
SELECT subscription_type,
COUNT(*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) * 100.0/COUNT(*),1) AS churn_rate,
sum(total_spend) as total_revenue
FROM vw_churn_full
GROUP BY subscription_type
ORDER BY churn_rate DESC;
-- mostly flat- 46-48%, revenue earned almost similar too ~11.5m

-- by contract length 
SELECT contract_length,
COUNT(*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) * 100.0/COUNT(*),1) AS churn_rate
FROM vw_churn_full
GROUP BY contract_length
ORDER BY churn_rate DESC;
-- Monthly subscribers 51.6%, annual subscribers 46.2% and quarterly 44%


SELECT last_interaction_band,
COUNT(*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) * 100.0/COUNT(*),1) AS churn_rate
FROM vw_churn_full
GROUP BY last_interaction_band
ORDER BY churn_rate DESC;
-- flat- 46-47% 



-- churn by age group and gender
SELECT gender, age_group,
COUNT(*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) * 100.0/COUNT(*),1) AS churn_rate
FROM vw_churn_full
GROUP BY gender, age_group
order by gender, age_group desc;
-- dashboard - 56+ females ~59% and 56+ males ~45%


SELECT gender, age_group, tenure_band,
COUNT(*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) * 100.0/COUNT(*),1) AS churn_rate
FROM vw_churn_full
GROUP BY gender, age_group, tenure_band
order by churn_rate desc;
-- older loyal females have higher cr


select * from vw_churn_full;


-- churn by tenure and payment delay
SELECT payment_delay_band, tenure_band,
COUNT(*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) * 100.0/COUNT(*),1) AS churn_rate
FROM vw_churn_full
GROUP BY payment_delay_band, tenure_band
ORDER BY churn_rate desc;
-- 25+ mo with 15+ delay days have very high churn rate 70-85%


SELECT payment_delay_band, usage_band,
COUNT(*) AS total_customers,
SUM(churn) AS churned_customers,
ROUND(SUM(churn) * 100.0/COUNT(*),1) AS churn_rate
FROM vw_churn_full
GROUP BY payment_delay_band, usage_band
ORDER BY churn_rate DESC;
-- >23d delay >70% cr while active on time users have 0 cr

select subscription_type, contract_length,
count(*) as total_customers,
sum(churn) as churned_customers,
round(sum(churn) * 100.0/count(*), 2)as churn_rate
from vw_churn_full
group by subscription_type, contract_length
order by churn_rate desc;
-- monthly sees more churn rate even tho the difference between subscription type is mostly flat indicating
-- subs type dont have much effect on churn


select * from vw_churn_full;


select tenure_band, support_calls_band,
count(*) as total_customers,
sum(churn) as churned_customers,
round(sum(churn) * 100.0/count(*), 2)as churn_rate
from vw_churn_full
group by tenure_band, support_calls_band
order by churn_rate desc;
-- >6 support calls with 25+ months tenure have >70% cr


select usage_band, support_calls_band,
count(*) as total_customers,
sum(churn) as churned_customers,
round(sum(churn) * 100.0/count(*), 2)as churn_rate
from vw_churn_full
group by usage_band, support_calls_band
order by churn_rate desc;

-- avg spending of churned vs retained customers
SELECT 
    churn_status,
    ROUND(AVG(total_spend), 2) AS avg_customer_spend
FROM vw_churn_full
GROUP BY churn_status;



-- "How many active (retained) customers are currently a ticking time bomb?"
SELECT 
    risk_label,
    COUNT(*) FILTER (WHERE churn_status = 'Retained') AS at_risk_customers,
    COUNT(*) FILTER (WHERE churn_status = 'Churned') AS churned_customers,
    ROUND(COUNT(*) FILTER (WHERE churn_status = 'Churned') * 100.0 / COUNT(*), 2 ) AS churn_rate
FROM vw_churn_full
GROUP BY risk_label
ORDER BY
    CASE risk_label 
        WHEN 'Critical' THEN 1 
        WHEN 'High' THEN 2 
        WHEN 'Medium' THEN 3 
        ELSE 4 
    END;




