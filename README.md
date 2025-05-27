# 🪙 Cryptocurrency Transaction Data Cleaning & Analysis (SQL Project) + Power BI Dashboard

This project involves a structured approach to cleaning, transforming, and analyzing a cryptocurrency transaction dataset using SQL. The objective is to draw meaningful insights by performing data preparation, aggregation, and time-based analysis.

---

## 📂 Dataset Overview

**Source Table:** `cryptocurrency transaction data`
**Working Table:** `CRYPTO`

---

## 🔹 STEP 1: Create and Populate Working Table

```sql
CREATE TABLE CRYPTO LIKE `cryptocurrency transaction data`;

INSERT INTO CRYPTO 
SELECT * FROM `cryptocurrency transaction data`;
```

---

## 🔹 STEP 2: Initial Data Exploration

```sql
SELECT MIN(Timestamp) AS Start_Date, MAX(Timestamp) AS End_Date 
FROM `cryptocurrency transaction data`;
```

---

## 🔹 STEP 3: Data Cleaning

* Replace empty values in `Gas_Price_Gwei` with `0`

```sql
UPDATE CRYPTO
SET Gas_Price_Gwei = 0
WHERE Gas_Price_Gwei = '';
```

---

## 🔹 STEP 4: Remove Redundant Columns

```sql
-- Examine unique values before dropping
SELECT DISTINCT Transaction_Type FROM CRYPTO;
ALTER TABLE CRYPTO DROP COLUMN Transaction_Type;

SELECT DISTINCT Transaction_Status FROM CRYPTO;
ALTER TABLE CRYPTO DROP COLUMN Transaction_Status;
```

---

## 🔹 STEP 5: Extract DATE and TIME

```sql
ALTER TABLE CRYPTO 
ADD COLUMN DATE DATE,
ADD COLUMN TIME TIME;

UPDATE CRYPTO
SET DATE = SUBSTRING(Timestamp, 1, 10);

UPDATE CRYPTO
SET TIME = SUBSTRING_INDEX(SUBSTRING(Timestamp, 12, 19), '.', 1);

ALTER TABLE CRYPTO DROP COLUMN Timestamp;
```

---

## 🔹 STEP 6: Descriptive Aggregation

* **By Mining Pool**
* **By Mining Pool & Currency**
* **By Currency**
* **Averages**
* **Ethermine Specific**

```sql
SELECT Mining_Pool, SUM(Amount) AS Total_Amount, COUNT(*) AS Num_Transactions FROM CRYPTO GROUP BY Mining_Pool;

SELECT Mining_Pool, Currency, SUM(Amount) AS Total_Amount, COUNT(*) AS Num_Transactions FROM CRYPTO GROUP BY Mining_Pool, Currency;

SELECT Currency, SUM(Amount) AS Total_Amount FROM CRYPTO GROUP BY Currency;

SELECT Currency, AVG(Amount) AS Avg_Amount, AVG(Transaction_Fee) AS Avg_Fee FROM CRYPTO GROUP BY Currency;

SELECT Mining_Pool, Currency, COUNT(*) AS Num_of_Crypto FROM CRYPTO GROUP BY Mining_Pool, Currency HAVING Mining_Pool = 'Ethermine';
```

---

## 🔹 STEP 7: Monthly Aggregation

```sql
SELECT DATE_FORMAT(DATE, '%Y-%m') AS Month, COUNT(*) AS Num_Transactions, SUM(Amount) AS Total_Amount FROM CRYPTO GROUP BY Month;

SELECT DATE_FORMAT(DATE, '%Y-%m') AS Month, Mining_Pool, Currency, COUNT(*) AS Num_Transactions, SUM(Amount) AS Total_Amount FROM CRYPTO GROUP BY Month, Mining_Pool, Currency;
```

---

## 🔹 STEP 8: Cumulative Analysis

```sql
WITH MonthlyStats AS (
    SELECT DATE_FORMAT(DATE, '%Y-%m') AS YEARMONTH,
           Mining_Pool, Currency,
           COUNT(*) AS Num_Transactions,
           SUM(Amount) AS Amount_Currency
    FROM CRYPTO
    GROUP BY YEARMONTH, Mining_Pool, Currency
)
SELECT YEARMONTH, Mining_Pool, Currency,
       Num_Transactions,
       SUM(Num_Transactions) OVER (PARTITION BY Currency ORDER BY YEARMONTH, Mining_Pool) AS Cumulative_Transactions,
       Amount_Currency,
       SUM(Amount_Currency) OVER (PARTITION BY Currency ORDER BY YEARMONTH, Mining_Pool) AS Cumulative_Amount
FROM MonthlyStats;
```

---

## 🔹 STEP 9: Time-Based Behavior Analysis

* **Quarter of the Day Classification**

```sql
ALTER TABLE CRYPTO ADD COLUMN QUARTER_Of_the_Day TEXT;

UPDATE CRYPTO
SET QUARTER_Of_the_Day = CASE 
    WHEN TIME BETWEEN '00:00:00' AND '06:00:00' THEN '1st QTR (Midnight–Morning)'
    WHEN TIME BETWEEN '06:00:01' AND '12:00:00' THEN '2nd QTR (Morning–Noon)'
    WHEN TIME BETWEEN '12:00:01' AND '18:00:00' THEN '3rd QTR (Afternoon–Evening)'
    WHEN TIME BETWEEN '18:00:01' AND '23:59:59' THEN '4th QTR (Evening–Night)'
END;

SELECT QUARTER_Of_the_Day, COUNT(*) AS No_Of_Transaction FROM CRYPTO GROUP BY QUARTER_Of_the_Day;

SELECT QUARTER_Of_the_Day, Mining_Pool, COUNT(*) AS No_Of_Transaction FROM CRYPTO GROUP BY QUARTER_Of_the_Day, Mining_Pool;
```

---

## 🔹 STEP 10: Final Snapshot

```sql
SELECT * FROM CRYPTO;
```

---

## 🧠 Skills Demonstrated

* Data Cleaning & Transformation
* Aggregation & Grouping
* Cumulative Calculations using Window Functions
* Time Series & Behavioral Analysis
* SQL Query Optimization

---

📊 Power BI Dashboard
The Power BI report CryptoP5.pbix includes:
 * Monthly transaction volume trends
 * 💰 Currency-wise transaction analysis
 * 🕒 Quarter-of-day behavioral insights
 * 🧱 Mining pool comparison
   
---

## 📌 Technologies

* SQL (MySQL syntax)
* Data Aggregation
* Window Functions
* Time and String Functions
* Power BI

---

## ✍️ Author

**Abhay Gomkale**
*Computer Science Student | Data Analyst Aspirant*

