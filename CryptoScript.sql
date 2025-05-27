-- 🔹 STEP 1: Create and Populate Main Working Table
CREATE TABLE CRYPTO LIKE `cryptocurrency transaction data`;

INSERT INTO CRYPTO 
SELECT * FROM `cryptocurrency transaction data`;

-- 🔹 STEP 2: Data Exploration and Initial Inspection
-- Check date range in the original dataset
SELECT MIN(Timestamp) AS Start_Date, MAX(Timestamp) AS End_Date 
FROM `cryptocurrency transaction data`;

-- 🔹 STEP 3: Data Cleaning
-- Replace empty Gas_Price_Gwei with 0
UPDATE CRYPTO
SET Gas_Price_Gwei = 0
WHERE Gas_Price_Gwei = '';

-- 🔹 STEP 4: Remove Redundant/Not Useful Columns
-- Drop columns with low informational value
SELECT DISTINCT Transaction_Type FROM CRYPTO;
ALTER TABLE CRYPTO DROP COLUMN Transaction_Type;

SELECT DISTINCT Transaction_Status FROM CRYPTO;
ALTER TABLE CRYPTO DROP COLUMN Transaction_Status;

-- 🔹 STEP 5: Add and Format DATE and TIME Fields
ALTER TABLE CRYPTO 
ADD COLUMN DATE DATE,
ADD COLUMN TIME TIME;

-- Extract DATE and TIME from Timestamp
UPDATE CRYPTO
SET DATE = SUBSTRING(Timestamp, 1, 10);

UPDATE CRYPTO
SET TIME = SUBSTRING_INDEX(SUBSTRING(Timestamp, 12, 19), '.', 1);

-- Remove original Timestamp column
ALTER TABLE CRYPTO DROP COLUMN Timestamp;

-- 🔹 STEP 6: Descriptive Aggregates
-- Transactions and amounts grouped by Mining Pool
SELECT Mining_Pool, 
       SUM(Amount) AS Total_Amount,
       COUNT(*) AS Num_Transactions FROM CRYPTO
GROUP BY Mining_Pool;

-- Grouped by Mining Pool and Currency
SELECT Mining_Pool, Currency, 
       SUM(Amount) AS Total_Amount,
       COUNT(*) AS Num_Transactions
FROM CRYPTO
GROUP BY Mining_Pool, Currency
ORDER BY Mining_Pool, Currency;

-- Total amount and fees by Currency
SELECT Currency, SUM(Amount) AS Total_Amount
FROM CRYPTO
GROUP BY Currency;

SELECT Currency, SUM(Transaction_Fee) AS Total_Fee
FROM CRYPTO
GROUP BY Currency;

-- Average amount and fee by Currency
SELECT Currency, 
       AVG(Amount) AS Avg_Amount,
       AVG(Transaction_Fee) AS Avg_Fee
FROM CRYPTO
GROUP BY Currency;

-- Grouped averages by Mining Pool and Currency
SELECT Mining_Pool, Currency, 
       AVG(Amount) AS Avg_Amount, 
       AVG(Transaction_Fee) AS Avg_Fee
FROM CRYPTO
GROUP BY Mining_Pool, Currency;

-- Filtered analysis: Ethermine pool only
SELECT Mining_Pool, Currency, COUNT(*) AS Num_of_Crypto
FROM CRYPTO
GROUP BY Mining_Pool, Currency
HAVING Mining_Pool = 'Ethermine';

-- 🔹 STEP 7: Monthly Aggregation
-- Monthly transaction trends
SELECT DATE_FORMAT(DATE, '%Y-%m') AS Month,
       COUNT(*) AS Num_Transactions,
       SUM(Amount) AS Total_Amount
FROM CRYPTO
GROUP BY Month
ORDER BY Month;

-- Monthly data grouped by Mining Pool and Currency
SELECT DATE_FORMAT(DATE, '%Y-%m') AS Month,
       Mining_Pool, Currency,
       COUNT(*) AS Num_Transactions,
       SUM(Amount) AS Total_Amount
FROM CRYPTO
GROUP BY Month, Mining_Pool, Currency
ORDER BY Month, Mining_Pool, Currency;

-- 🔹 STEP 8: Cumulative (Progressive) Analysis
-- Cumulative totals over time
-- Cumulative totals partitioned by Currency
WITH MonthlyStats AS (
    SELECT DATE_FORMAT(DATE, '%Y-%m') AS YEARMONTH,
           Mining_Pool,
           Currency,
           COUNT(*) AS Num_Transactions,
           SUM(Amount) AS Amount_Currency
    FROM CRYPTO
    GROUP BY YEARMONTH, Mining_Pool, Currency
)
SELECT 
    YEARMONTH,
    Mining_Pool,
    Currency,
    Num_Transactions,
    SUM(Num_Transactions) OVER (
        PARTITION BY Currency ORDER BY YEARMONTH, Mining_Pool
    ) AS Cumulative_Transactions,
    Amount_Currency,
    SUM(Amount_Currency) OVER (
        PARTITION BY Currency ORDER BY YEARMONTH, Mining_Pool
    ) AS Cumulative_Amount
FROM MonthlyStats
ORDER BY YEARMONTH, Mining_Pool;

-- 🔹 STEP 9: Time-Based Behavior Analysis
-- Create a column for Quarter of the Day
ALTER TABLE CRYPTO 
ADD COLUMN QUARTER_Of_the_Day TEXT;

UPDATE CRYPTO
SET QUARTER_Of_the_Day = CASE 
    WHEN TIME BETWEEN '00:00:00' AND '06:00:00' THEN '1st QTR (Midnight–Morning)'
    WHEN TIME BETWEEN '06:00:01' AND '12:00:00' THEN '2nd QTR (Morning–Noon)'
    WHEN TIME BETWEEN '12:00:01' AND '18:00:00' THEN '3rd QTR (Afternoon–Evening)'
    WHEN TIME BETWEEN '18:00:01' AND '23:59:59' THEN '4th QTR (Evening–Night)'
END;

-- Transaction count by time quarters
SELECT QUARTER_Of_the_Day, COUNT(*) AS No_Of_Transaction
FROM CRYPTO
GROUP BY QUARTER_Of_the_Day;

-- Quarter-wise Mining Pool Analysis
SELECT QUARTER_Of_the_Day, Mining_Pool, COUNT(*) AS No_Of_Transaction
FROM CRYPTO
GROUP BY QUARTER_Of_the_Day, Mining_Pool 
ORDER BY QUARTER_Of_the_Day, Mining_Pool;

-- 🔹 STEP 10: Final Snapshot
SELECT * FROM CRYPTO;
