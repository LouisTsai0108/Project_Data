﻿--- BÀI 1.
--- TẠO BẢNG:
CREATE TABLE SALE_X1
(SELLER_ID INT,
CATEGORY VARCHAR(20),
SALES_MILIIONS_VND FLOAT)
--- THÊM DỮ LIỆU VÀO
INSERT INTO SALE_X1 (SELLER_ID, CATEGORY, SALES_MILIIONS_VND)
VALUES ('1','Book','258'),
       ('2','Electronics','299'),
       ('3','Electronics','123'),
       ('4','Book','272'),
       ('5','FMCG','485'),
       ('6','Book','187'),
       ('7','FMCG','349'),
       ('8','FMCG','61'),
       ('9','Electronics','321'),
       ('10','FMCG','20')
--- CÂU 1A. VIẾT QUERY TÌM RA BEST SELLER CỦA MỖI HẠNG MỤC
--- Ý TƯỞNG: NHÓM THEO CATEGORY, ĐÁNH RANK ĐỂ LẤY SỐ TIỀN SALES LỚN NHẤT MỖI MỤC
WITH CTE AS
(SELECT SELLER_ID, CATEGORY, MAX(SALES_MILIIONS_VND) AS REVENUE,
        ROW_NUMBER() OVER(PARTITION BY CATEGORY ORDER BY MAX(SALES_MILIIONS_VND) DESC) AS ROW_NUM
FROM SALE_X1
GROUP BY SELLER_ID, CATEGORY)
SELECT SELLER_ID, CATEGORY, REVENUE FROM CTE WHERE ROW_NUM = 1

--- CÂU 1B. CHO 3 CỘT TRONG BẢNG Y DƯỚI ĐÂY
--- TẠO BẢNG AWARD_Y1
CREATE TABLE AWARD_Y1
(AWARD_YEAR INT,
AWARD VARCHAR(20),
SELLER_ID INT)
--- THÊM DỮ LIỆU VÀO
INSERT INTO AWARD_Y1(AWARD_YEAR, AWARD, SELLER_ID)
VALUES ('2017','Best Seller','9'),
       ('2018','Best Seller','5'),
       ('2017','Best Operations','5'),
       ('2018','Best Quality','10'),
       ('2018','Best Operations','6'),
       ('2017','Best Seller','4'),
       ('2017','Best Operations','5'),
       ('2017','Best Quality','7'),
       ('2017','Best Quality','10')
--- TÌM RA 3 BEST SELLER Ở CÂU A, CÓ BAO NHIÊU GIẢI THƯỞNG ĐƯỢC NHẬN VÀO NĂM 2017
--- Ý TƯỞNG: CHO 2 BẢNG SALE_X VÀ AWARD_YEAR NĂM 2017 JOIN VỚI NHAU SAU ĐÓ TẠO RA CỘT AWARD_YEAR,SELLER_ID,CATEGORY,SALES_MILLIONS_VND,COUNT(AWARD), ĐÁNH RANK RỒI SẮP XẾP THEO SỐ TIỀN CAO NHẤT
--- LẤY NHỮNG CATEGORY CÓ ROWNUM = 1
WITH CTE AS
(SELECT T2.AWARD_YEAR,
        T1.SELLER_ID,
        T1.CATEGORY,
	    T1.SALES_MILLIONS_VND,
        COUNT(T2.AWARD) AS TOTAL_AWARD,
        ROW_NUMBER () OVER (PARTITION BY T1.CATEGORY ORDER BY T1.SALES_MILLIONS_VND DESC) AS ROWNUM
FROM SALE_X T1
LEFT JOIN AWARD_Y T2
ON T1.SELLER_ID = T2.SELLER_ID
WHERE AWARD_YEAR = '2017'
GROUP BY T2.AWARD_YEAR,
         T1.SELLER_ID,
         T1.CATEGORY,
	     T1.SALES_MILLIONS_VND)  --- TẠO BẢNG GỒM CÁC CỘT NĂM 2017

SELECT CTE.SELLER_ID, 
       CTE.CATEGORY, 
       CTE.TOTAL_AWARD,
       CTE.ROWNUM 
FROM CTE
WHERE ROWNUM = 1

--- CÂU 2. VIẾT QUERY TÌM SỐ LƯỢNG SẢN PHẨM CÓ SẴN VÀO CUỐI MỖI THÁNG.
ALTER TABLE product_history
ALTER COLUMN DATE DATE
---
SELECT T1.YEAR,
       T1.MONTH,
       T2.PRODUCT_ID,
       T2.STOCK
FROM
(SELECT YEAR(DATE) AS YEAR,
        MONTH(DATE) AS MONTH,
        MAX(DAY(DATE)) AS LAST_DAY --- LẤY NGÀY CUỐI THÁNG VỚI PRODUCT_ID CÓ HÀNG
FROM product_history
WHERE PRODUCT_STATUS = 'ON' --- ON LÀ CÓ HÀNG
GROUP BY YEAR(DATE),
         MONTH(DATE)) AS T1
--- JOIN NGƯỢC LẠI ĐỂ LẤY STOCK VÀ PRODUCT_ID
LEFT JOIN
(SELECT *,          ---Ý TƯỞNG LÀ TẠO RA BẢNG GỒM CÁC CỘT YEAR, MONTH, DAY
YEAR(DATE) AS YEAR,
MONTH(DATE) AS MONTH,
DAY(DATE) AS DAY
FROM product_history
WHERE PRODUCT_STATUS = 'ON') AS T2
ON T2.DAY = T1.LAST_DAY AND T1.MONTH = T2.MONTH AND T1.YEAR = T2.YEAR
ORDER BY T1.YEAR DESC, T1.MONTH DESC
--- VIẾT CÂU TRUY VẤN ĐỂ TÌM MÃ SẢN PHẨM VỚI TRUNG BÌNH LƯU KHO BỞI THÁNG
--- BƯỚC 1. TẠO BẢNG LẤY SỐ NGÀY TRONG THÁNG, PRODUCTID SAU ĐÓ JOIN VỚI LẠI CHÍNH BẢNG PRODUCT_HISTORY LẤY STOCK
--- BƯỚC 2. TẠO CỘT TOTAL_STOCK_IN_MONTH, AVG_STOCK = TOTAL_STOCK_IN_MONTH/TOTAL_DAYS_IN_MONTH
SELECT * FROM
(SELECT T1.*,
       CAST(T2.STOCK AS FLOAT) AS TOTAL_STOCK_IN_MONTH,
       CAST(T2.STOCK AS FLOAT) / T1.TOTAL_DAYS_IN_MONTH AS AVG_STOCK,
       ROW_NUMBER() OVER(PARTITION BY T1.YEAR_DATE, T1.MONTH_DATE,T1.TOTAL_DAYS_IN_MONTH ORDER BY CAST(T2.STOCK AS FLOAT) / T1.TOTAL_DAYS_IN_MONTH DESC) AS ROWNUM FROM
(SELECT YEAR(DATE) AS YEAR_DATE,
       MONTH(DATE) AS MONTH_DATE,
       MAX(DATE) AS DATE,
       DAY(EOMONTH(DATE)) AS TOTAL_DAYS_IN_MONTH,
       PRODUCT_ID FROM PRODUCT_HISTORY
GROUP BY YEAR(DATE),
         MONTH(DATE),
         DAY(EOMONTH(DATE)),
         PRODUCT_ID) AS T1
LEFT JOIN PRODUCT_HISTORY AS T2
ON T1.PRODUCT_ID = T2.PRODUCT_ID) AS T3
WHERE ROWNUM = 1

SELECT DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE
     TABLE_NAME = 'PRODUCT_HISTORY' AND
     COLUMN_NAME = 'STOCK' 

SELECT TRY_CAST (STOCK AS FLOAT) 
FROM PRODUCT_HISTORY