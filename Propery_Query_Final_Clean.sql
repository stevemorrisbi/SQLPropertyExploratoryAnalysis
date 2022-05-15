-- All propety sales in Cardiff.
SELECT 
  * 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CARDIFF' 

-- Sales in CF83 ordered by Sale Date.
SELECT 
  column2 as Price, 
  CAST(column3 AS Date) as Sale_Date 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column4 LIKE 'CF83%' 
ORDER BY 
  column3 
  
-- Days of the year where CF83 had more than 1 sale.
SELECT 
  column2 as Price, 
  CAST(column3 AS Date) as Sale_Date, 
  COUNT(*) as Sales 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column4 LIKE 'CF83%' 
GROUP BY 
  column3, 
  column2 
HAVING 
  COUNT(*) > 1 
ORDER BY 
  column3 
  
-- Total of all property sales in 2021 in Cardiff.
SELECT 
  COUNT(*) 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CARDIFF'

-- Total Sales put into catergories of Sale Price.
SELECT 
  column2 Sale_Price, 
  column12 City, 
  COUNT(*) Total_Sales 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CARDIFF' 
GROUP BY 
  column2, 
  column12 
ORDER BY 
  Total_Sales DESC 
  
-- Using a CTE for Avg price of property sales which have less than 5 or more sales in a price bracket.
  WITH orders_under_5 AS (
    SELECT 
      column2 Sale_Price, 
      column12 City, 
      COUNT(*) AS Total_Sales 
    FROM 
      [Property2021].[dbo].[Property_Prices_2021] 
    WHERE 
      column12 = 'CARDIFF' 
    GROUP BY 
      column2, 
      column12 
    HAVING 
      COUNT(*) < 5
  ) 
SELECT 
  AVG(Sale_Price) AS avg_price_under5 
FROM 
  orders_under_5;
  
-- CTE for Avg price of property sales which have a sales price bracket total of more than 5.
WITH orders_over_5 AS (
  SELECT 
    column2 Sale_Price, 
    column12 City, 
    COUNT(*) AS Total_Sales 
  FROM 
    [Property2021].[dbo].[Property_Prices_2021] 
  WHERE 
    column12 = 'CARDIFF' 
  GROUP BY 
    column2, 
    column12 
  HAVING 
    COUNT(*) >= 5
) 
SELECT 
  AVG(Sale_Price) AS avg_price_over5 
FROM 
  orders_over_5 

-- Sales in CF83 between 1st February and 1st April ordered by Date.
SELECT 
  column2 as Price, 
  CAST(column3 AS Date) as Sale_Date 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column4 LIKE 'CF83%' 
  AND column3 BETWEEN '2021-01-31' 
  AND '2021-03-31' 
ORDER BY 
  column3 

-- Putting Sales between 1st February and 1st April into Price Catergories using CASE statement.
SELECT 
  column2 AS Price, 
  CASE WHEN column2 < 150000 THEN 'Cheap' WHEN column2 < 200000 THEN 'Medium Price' WHEN column2 < 300000 THEN 'High Price' ELSE 'Expensive' END AS Price_Rating, 
  CAST(column3 AS Date) as Sale_Date 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column4 LIKE 'CF83%' 
  AND column3 BETWEEN '2021-01-31' 
  AND '2021-03-31' 
ORDER BY 
  column2 
  
/*Note * The two largest sales between February and April both occured on the 2nd February.
Counting records for sales in 'Caerphilly' = 602*/
Select 
  COUNT(*) as all_records 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CAERPHILLY' 
  
/*Counting total records for sales in 'CF83' = 600
(Total should be 602 - the same as the above query)*/
Select 
  COUNT(*) as all_records 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column4 LIKE 'CF83%' 

/*Property sales in Caerphilly without a post code. 
  2 Property Sales are missing a Post Code (This includes the sale of a Farm and a Parking Space)*/
Select 
  * 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CAERPHILLY' 
  AND column4 IS NULL 
  
-- 3 property Sales in the UK are labelled as Parking Space. (The Caerphilly Parking Space sold for £160,000?!)
Select 
  * 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column8 = 'PARKING SPACE' 
  
-- Using a Union to join Property Sales from Cardiff and Property Sales from Caerphilly.
Select 
  column12 AS Location, 
  column2 AS Sale_Price, 
  column3 AS Sale_Date 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CARDIFF' 
UNION 
Select 
  column12 AS Location, 
  column2 AS Sale_Price, 
  column3 AS Sale_Date 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CAERPHILLY' 
ORDER BY 
  column2 DESC 
  
 /* Using a CTE to categorise Price of Sales for Both Caerphilly and Cardiff. 
  Ordered by Sale Price Highest to Lowest*/
  WITH price_cat AS (
    SELECT 
      column12 AS Location, 
      column2 AS Sale_Price, 
      column3 AS Sale_Date 
    FROM 
      [Property2021].[dbo].[Property_Prices_2021] 
    WHERE 
      column12 = 'CARDIFF' 
    UNION 
    Select 
      column12 AS Location, 
      column2 AS Sale_Price, 
      column3 AS Sale_Date 
    FROM 
      [Property2021].[dbo].[Property_Prices_2021] 
    WHERE 
      column12 = 'CAERPHILLY'
  ) 
SELECT 
  Location, 
  Sale_Price, 
  CASE WHEN Sale_Price < 150000 THEN 'Cheap' WHEN Sale_Price < 200000 THEN 'Medium Price' WHEN Sale_Price < 300000 THEN 'High Price' ELSE 'Expensive' END AS Price_Rating 
FROM 
  price_cat 
ORDER BY 
  Sale_Price DESC 
  
-- Using DENSE RANK to rank sales in Cardiff and Caerphilly from Highest to Lowest. 
  WITH price_cat AS (
    SELECT 
      column12 AS Location, 
      column2 AS Sale_Price, 
      column3 AS Sale_Date 
    FROM 
      [Property2021].[dbo].[Property_Prices_2021] 
    WHERE 
      column12 = 'CARDIFF' 
    UNION 
    Select 
      column12 AS Location, 
      column2 AS Sale_Price, 
      column3 AS Sale_Date 
    FROM 
      [Property2021].[dbo].[Property_Prices_2021] 
    WHERE 
      column12 = 'CAERPHILLY'
  ) 
SELECT 
  Location, 
  COUNT(*) AS Total_Sales_Cat, 
  Sale_Price, 
  CASE WHEN Sale_Price < 150000 THEN 'Cheap' WHEN Sale_Price < 200000 THEN 'Medium Price' WHEN Sale_Price < 300000 THEN 'High Price' ELSE 'Expensive' END AS Price_Rating, 
  DENSE_RANK() OVER(
    ORDER BY 
      Sale_Price DESC
  ) AS Rnk_Cat 
FROM 
  price_cat 
GROUP BY 
  Location, 
  Sale_Price 
ORDER BY 
  Rnk_Cat 
  
-- Calculating the AVG 10% morgage price for properties (with Post Codes) in Cardiff.
SELECT 
  column12 AS Location, 
  AVG(column2) / 10 AS Min_Morgage 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CARDIFF' 
  AND column4 IS NOT NULL 
GROUP BY 
  column12 
  
-- Calculating the AVG 10% morgage price for properties (with Post Codes) in Caerphilly.
SELECT 
  column12 AS Location, 
  AVG(column2) / 10 AS Min_Morgage 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CAERPHILLY' 
  AND column4 IS NOT NULL 
GROUP BY 
  column12 

-- Total property sales by month during 2021 in Caerphilly.
SELECT 
  column12 AS Location, 
  COUNT(DISTINCT column2) AS Property_Sales, 
  (
    MONTH(column3)
  ) AS Month_Number 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CAERPHILLY' 
  AND column4 IS NOT NULL 
GROUP BY 
  (
    MONTH(column3)
  ), 
  column12 

-- Total property sales by month during 2021 in Cardiff.
SELECT 
  column12 AS Location, 
  COUNT(DISTINCT column2) AS Property_Sales, 
  (
    MONTH(column3)
  ) AS Month_Number 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CARDIFF' 
  AND column4 IS NOT NULL 
GROUP BY 
  (
    MONTH(column3)
  ), 
  column12 

-- Exloring which months had the highest average sale price in Cardiff.
SELECT 
  column12 AS Location, 
  COUNT(DISTINCT column2) AS Property_Sales, 
  AVG(DISTINCT column2) Avg_Sale_Price, 
  (
    MONTH(column3)
  ) AS Month_Number 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CARDIFF' 
  AND column4 IS NOT NULL 
GROUP BY 
  (
    MONTH(column3)
  ), 
  column12 
ORDER BY 
  Avg_Sale_Price DESC 
  
/*Would like to further investigate if there is a correlation with other cities 
  having a lower avg sale price during the last 3 months of the year*/
  
/*Exloring which months had the highest average sale price in Caerphilly.
  * No correlation with Cardiff on avg sale price and month sold*/
SELECT 
  column12 AS Location, 
  COUNT(DISTINCT column2) AS Property_Sales, 
  AVG(DISTINCT column2) Avg_Sale_Price, 
  (
    MONTH(column3)
  ) AS Month_Number 
FROM 
  [Property2021].[dbo].[Property_Prices_2021] 
WHERE 
  column12 = 'CAERPHILLY' 
  AND column4 IS NOT NULL 
GROUP BY 
  (
    MONTH(column3)
  ), 
  column12 
ORDER BY 
  Avg_Sale_Price DESC 
  
/*Finding Max and Min Sales compared to Avg Sale price.
  * anomaly discovered in Min sale price for Janauary*/
SELECT 
  column12 AS Location, 
  COUNT(DISTINCT column2) AS Property_Sales, 
  AVG(DISTINCT column2) Avg_Sale_Price, 
  (
    MONTH(column3)
  ) AS Month_Number, 
  MAX(DISTINCT column2) AS Max_Sale, 
  MIN(DISTINCT column2) AS Min_Sale 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CAERPHILLY' 
  AND column4 IS NOT NULL 
GROUP BY 
  (
    MONTH(column3)
  ), 
  column12 
ORDER BY 
  Avg_Sale_Price DESC 
  
-- querying to find the total of property sales greater than the Cardiff average sale price.
SELECT 
  column12 AS location, 
  COUNT(*) count_above_avg 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CARDIFF' 
  AND column2 >(
    SELECT 
      AVG(DISTINCT column2) Avg_Sale_Price 
    FROM 
      [Property2021].[dbo].[Property_Prices_2021] 
    WHERE 
      column12 = 'CARDIFF'
  ) 
GROUP BY 
  column12 

-- querying to find the total of property sales less than the Cardiff average sale price.
SELECT 
  column12 AS location, 
  COUNT(*) count_below_avg 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CARDIFF' 
  AND column2 <(
    SELECT 
      AVG(DISTINCT column2) Avg_Sale_Price 
    FROM 
      [Property2021].[dbo].[Property_Prices_2021] 
    WHERE 
      column12 = 'CARDIFF'
  ) 
GROUP BY 
  column12 
  
-- querying the total sales in Caerphilly with avg sale price by month (ordered by highest number of sales per month)
SELECT 
  column12 AS Location, 
  COUNT(DISTINCT column2) AS Property_Sales, 
  AVG(DISTINCT column2) Avg_Sale_Price, 
  (
    MONTH(column3)
  ) AS Month_Number 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CAERPHILLY' 
GROUP BY 
  (
    MONTH(column3)
  ), 
  column12 
ORDER BY 
  2 DESC 
  
-- * For further analysis it would be interesting to explore how the number of bedrooms effects sale price.
  
/*Calculating the average price of property sales per post code in Cardiff. 
  (Ordered by DESC to see in order of most expensive first)*/
SELECT 
  AVG(column2) avg_price, 
  LEFT(column4, 4) post_code, 
  column12 location 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 = 'CARDIFF' 
  and column4 IS NOT NULL 
GROUP BY 
  column4, 
  column12 
ORDER BY 
  avg_price DESC 
  
-- Days of most sales for Caerphilly and Cardiff together.
SELECT 
  LEFT(column3, 10) sale_date, 
  COUNT(3) AS total_sales, 
  SUM(column2) AS price_sum 
FROM 
  [Property2021].[dbo].[Property_Prices_2021]
WHERE 
  column12 IN('CARDIFF', 'CAERPHILLY') 
GROUP BY 
  column3 
ORDER BY 
  total_sales DESC 

/*Using LAG function to compare property sale price to a previous sale price.
  (Caerphilly and Cardiff)*/
  WITH dateclean AS(
    SELECT 
      column2 Sale_Price, 
      LEFT(column3, 10) Sale_Date, 
      column12 Sale_Location1, 
      LAG(column12) OVER (
        ORDER BY 
          column3
      ) as Sale_Location2, 
      LAG(column2) OVER (
        ORDER BY 
          column3
      ) as Previous_Sale_Price, 
      LAG(column3) OVER (
        ORDER BY 
          column3
      ) as Previous_Sale_Date 
    FROM 
      [Property2021].[dbo].[Property_Prices_2021] 
    WHERE 
      column12 IN('CARDIFF', 'CAERPHILLY')
  ) 
SELECT 
  Sale_Location1, 
  Sale_Price, 
  Sale_Date, 
  Sale_Location2, 
  Previous_Sale_Price, 
  LEFT(Previous_Sale_Date, 10) Previous_Sale_Date_Edit 
FROM 
  dateclean
