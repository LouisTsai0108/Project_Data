﻿/* 1. PRODUCT SALES ANALYSIS */
SELECT *          
FROM PRODUCTION.PRODUCT A  
LEFT JOIN SALES.SALESORDERDETAIL B                                           
ON A.PRODUCTID = B.PRODUCTID
LEFT JOIN SALES.SALESORDERHEADER C
ON B.SALESORDERID = C.SALESORDERID
WHERE C.STATUS = 5 

--- 1. SALES VOLUME: 
SELECT     A.NAME AS PRODUCTNAME,
           SUM(ORDERQTY) AS SALESVOLUME,
           COUNT(A.PRODUCTID) AS TOTAL_PRODUCT
FROM PRODUCTION.PRODUCT A  
LEFT JOIN SALES.SALESORDERDETAIL B                                           
ON A.PRODUCTID = B.PRODUCTID
LEFT JOIN SALES.SALESORDERHEADER C
ON B.SALESORDERID = C.SALESORDERID
WHERE C.STATUS = 5 
GROUP BY A.NAME WITH ROLLUP;

--- 2. SALES VOLUME BY PRODUCT 
SELECT YEAR(C.ORDERDATE) AS [YEAR], 
       A.NAME, 
       C.STATUS, 
       COUNT(A.PRODUCTID) AS TOTAL_PRODUCT, 
       SUM(ORDERQTY) AS SALES_VOLUME FROM PRODUCTION.PRODUCT A
LEFT JOIN SALES.SALESORDERDETAIL B 
ON A.PRODUCTID = B.PRODUCTID       
LEFT JOIN SALES.SALESORDERHEADER C
ON B.SALESORDERID = C.SALESORDERID
WHERE C.STATUS = 5 
GROUP BY YEAR(C.ORDERDATE), A.NAME, C.STATUS 
ORDER BY YEAR(C.ORDERDATE) ASC

--- 3. SALES VOLUME BY PRODUCT CATEGORY
WITH CTE AS
    (SELECT    E.NAME AS CATEGORY,
           COUNT(DISTINCT E.NAME) AS NUMOFPRODUCTSCATEGORY,       
           COUNT(E.PRODUCTCATEGORYID) AS TOTAL_PRODUCT_CATEGORYID,
           SUM(ORDERQTY) AS SALES_VOLUME
FROM PRODUCTION.PRODUCT A  
LEFT JOIN SALES.SALESORDERDETAIL B                                           
ON A.PRODUCTID = B.PRODUCTID
LEFT JOIN SALES.SALESORDERHEADER C
ON B.SALESORDERID = C.SALESORDERID
LEFT JOIN PRODUCTION.PRODUCTSUBCATEGORY D
ON A.PRODUCTSUBCATEGORYID = D.PRODUCTSUBCATEGORYID
LEFT JOIN PRODUCTION.PRODUCTCATEGORY E
ON D.PRODUCTCATEGORYID = E.PRODUCTCATEGORYID
WHERE C.STATUS = 5 
GROUP BY E.NAME
UNION ALL
SELECT     'TOTAL' AS CATEGORY,
            COUNT(DISTINCT E.NAME) AS NUMOFPRODUCTSCATEGORY,          
            COUNT(E.PRODUCTCATEGORYID) AS TOTAL_PRODUCT_CATEGORYID,
            SUM(ORDERQTY) AS SALES_VOLUME
FROM PRODUCTION.PRODUCT A  
LEFT JOIN SALES.SALESORDERDETAIL B                                           
ON A.PRODUCTID = B.PRODUCTID
LEFT JOIN SALES.SALESORDERHEADER C
ON B.SALESORDERID = C.SALESORDERID
LEFT JOIN PRODUCTION.PRODUCTSUBCATEGORY D
ON A.PRODUCTSUBCATEGORYID = D.PRODUCTSUBCATEGORYID
LEFT JOIN PRODUCTION.PRODUCTCATEGORY E
ON D.PRODUCTCATEGORYID = E.PRODUCTCATEGORYID
WHERE C.STATUS = 5)

SELECT CTE.CATEGORY, CTE.SALES_VOLUME, 100.0 * SUM(SALES_VOLUME) / (SELECT SUM(ORDERQTY) FROM SALES.SALESORDERDETAIL) AS PERCENT_VOLUME 
FROM CTE 
GROUP BY CTE.CATEGORY, CTE.SALES_VOLUME

--- 4. SALES REVENUE BY PRODUCT
SELECT     A.NAME AS PRODUCTNAME,
           COUNT(DISTINCT A.NAME) AS NUMOFPRODUCTS, 
           COUNT(A.PRODUCTID) AS TOTAL_PRODUCT,
           SUM(B.ORDERQTY) AS SALES_VOLUME,
           SUM(B.LINETOTAL) AS REVENUE           
FROM PRODUCTION.PRODUCT A  
LEFT JOIN SALES.SALESORDERDETAIL B                                           
ON A.PRODUCTID = B.PRODUCTID
LEFT JOIN SALES.SALESORDERHEADER C
ON B.SALESORDERID = C.SALESORDERID
WHERE C.STATUS = 5 
GROUP BY A.NAME WITH ROLLUP; 

--- 5. SALES REVENUE BY PRODUCT CATEGORY
WITH CTE AS
    (SELECT   DISTINCT COUNT(C.SALESORDERID) AS TOTAL_ORDER,
              E.NAME AS CATEGORY,
              COUNT(DISTINCT E.NAME) AS NUMOFPRODUCTSCATEGORY,        
              COUNT(E.PRODUCTCATEGORYID) AS TOTAL_PRODUCT_CATEGORYID,
              COUNT(DISTINCT A.NAME) AS NUMOFPRODUCTS,
              SUM(B.ORDERQTY) AS SALES_VOLUME,
              SUM(B.LINETOTAL) AS REVENUE,
              SUM(LINETOTAL) - SUM(STANDARDCOST) AS MARGIN              
FROM PRODUCTION.PRODUCT A  
LEFT JOIN SALES.SALESORDERDETAIL B                                           
ON A.PRODUCTID = B.PRODUCTID
LEFT JOIN SALES.SALESORDERHEADER C
ON B.SALESORDERID = C.SALESORDERID
LEFT JOIN PRODUCTION.PRODUCTSUBCATEGORY D
ON A.PRODUCTSUBCATEGORYID = D.PRODUCTSUBCATEGORYID
LEFT JOIN PRODUCTION.PRODUCTCATEGORY E
ON D.PRODUCTCATEGORYID = E.PRODUCTCATEGORYID
WHERE C.STATUS = 5 
GROUP BY E.NAME
UNION ALL 
SELECT     DISTINCT COUNT(C.SALESORDERID) AS TOTAL_ORDER,
           'TOTAL' AS CATEGORY, 
           COUNT(DISTINCT E.NAME) AS NUMOFPRODUCTSCATEGORY,        
           COUNT(E.PRODUCTCATEGORYID) AS TOTAL_PRODUCT_CATEGORYID,
           COUNT(DISTINCT A.NAME) AS NUMOFPRODUCTS,
           SUM(B.ORDERQTY) AS SALES_VOLUME,
           SUM(B.LINETOTAL) AS REVENUE,
           SUM(LINETOTAL) - SUM(STANDARDCOST) AS MARGIN
FROM PRODUCTION.PRODUCT A  
LEFT JOIN SALES.SALESORDERDETAIL B                                           
ON A.PRODUCTID = B.PRODUCTID
LEFT JOIN SALES.SALESORDERHEADER C
ON B.SALESORDERID = C.SALESORDERID
LEFT JOIN PRODUCTION.PRODUCTSUBCATEGORY D
ON A.PRODUCTSUBCATEGORYID = D.PRODUCTSUBCATEGORYID
LEFT JOIN PRODUCTION.PRODUCTCATEGORY E
ON D.PRODUCTCATEGORYID = E.PRODUCTCATEGORYID
WHERE C.STATUS = 5)

SELECT CTE.CATEGORY, CTE.REVENUE, 100.0 * SUM(REVENUE) / (SELECT SUM(LINETOTAL) FROM SALES.SALESORDERDETAIL) AS PERCENT_REVENUE, CTE.MARGIN, CTE.TOTAL_ORDER, CTE.SALES_VOLUME, CTE.NUMOFPRODUCTS 
FROM CTE 
GROUP BY CTE.CATEGORY, CTE.REVENUE, CTE.MARGIN, CTE.TOTAL_ORDER, CTE.SALES_VOLUME, CTE.NUMOFPRODUCTS  

--- 6. HOW MUCH SUCCESSFUL TRANSACTIONS IN 4 YEARS?
SELECT A.SALESORDERID AS TRANSACTIONID, 
       SUM(LINETOTAL) AS REVENUE 
FROM SALES.SALESORDERHEADER A 
LEFT JOIN SALES.SALESORDERDETAIL B
ON A.SALESORDERID = B.SALESORDERID 
GROUP BY A.SALESORDERID 
ORDER BY A.SALESORDERID ASC;


/* 2. SALES ANALYSIS BY LOCATION */
SELECT     E.NAME,
           F.NAME,
           COUNT(DISTINCT E.NAME) AS NUMOFPRODUCTSCATEGORY,        
           COUNT(E.PRODUCTCATEGORYID) AS TOTAL_PRODUCT_CATEGORY,
           SUM(B.LINETOTAL) AS REVENUE 
FROM PRODUCTION.PRODUCT A  
LEFT JOIN SALES.SALESORDERDETAIL B                                           
ON A.PRODUCTID = B.PRODUCTID
LEFT JOIN SALES.SALESORDERHEADER C
ON B.SALESORDERID = C.SALESORDERID
LEFT JOIN PRODUCTION.PRODUCTSUBCATEGORY D
ON A.PRODUCTSUBCATEGORYID = D.PRODUCTSUBCATEGORYID
LEFT JOIN PRODUCTION.PRODUCTCATEGORY E
ON D.PRODUCTCATEGORYID = E.PRODUCTCATEGORYID
LEFT JOIN SALES.SALESTERRITORY F
ON C.TERRITORYID = F.TERRITORYID
WHERE C.STATUS = 5 
GROUP BY E.NAME, F.NAME WITH ROLLUP;