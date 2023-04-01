--SQL Advance Case Study
select * from DIM_CUSTOMER
select * from DIM_DATE
select * from DIM_MANUFACTURER
select * from DIM_LOCATION
select * from DIM_MODEL
select * from FACT_TRANSACTIONS

--Q1--BEGIN 
select State from FACT_TRANSACTIONS t inner join DIM_LOCATION l on t.IDLocation = l.IDLocation
inner join DIM_MODEL m on t.IDModel = m.IDModel
where date between '01-01-2005' and GETDATE()
group by State






--Q1--END

--Q2--BEGIN
select top 1 state, sum(Quantity) quantity_sold from DIM_LOCATION l 
inner join FACT_TRANSACTIONS t on l.IDLocation = t.IDLocation
inner join DIM_MODEL mo on t.IDModel = mo.IDModel
inner join DIM_MANUFACTURER ma on mo.IDManufacturer = ma.IDManufacturer
where Manufacturer_Name = 'samsung' and Country = 'US'
group by state
order by sum(Quantity) desc 


--Q2--END

--Q3--BEGIN      
select Model_Name,State ,ZipCode,COUNT(IDCustomer)[Number_of_transaction]from FACT_TRANSACTIONS t 
inner join DIM_MODEL mo on t.IDModel = mo.IDModel
inner join DIM_LOCATION l on l.IDLocation = t.IDLocation
group by Model_Name,ZipCode,State


--Q3--END

--Q4--BEGIN

select top 1 IDModel ,Model_Name,unit_price from DIM_MODEL 
order by Unit_price 



--Q4--END

--Q5--BEGIN
select model_name, avg(unit_price) Average_Retail_price from DIM_MODEL mo 
inner join DIM_MANUFACTURER ma on mo.IDManufacturer = ma.IDManufacturer
where Manufacturer_Name in
(
select top 5 manufacturer_name from DIM_MODEL mo 
inner join DIM_MANUFACTURER ma on mo.IDManufacturer = ma.IDManufacturer
inner join FACT_TRANSACTIONS t on t.IDModel = mo.IDModel
group by Manufacturer_Name
order by sum(quantity) desc
)
group by Model_Name
order by avg(unit_price) desc



--Q5--END

--Q6--BEGIN
select customer_name ,avg(totalprice) Average_Amt_spent from DIM_CUSTOMER c 
inner join FACT_TRANSACTIONS t on c.IDCustomer = t.IDCustomer
where YEAR(Date) = 2009
group by Customer_Name
Having avg(totalprice) > 500


--Q6--END
	
--Q7--BEGIN  
	select * from (SELECT 
    TOP 5 Manufacturer_name
    FROM Fact_Transactions t
    LEFT JOIN DIM_Model mo ON t.IDModel = mo.IDModel
    LEFT JOIN DIM_MANUFACTURER ma  ON ma.IDManufacturer = mo.IDManufacturer
    Where DATEPART(Year,date)='2008' 
    group by Manufacturer_name, Quantity 
    Order by  SUM(Quantity ) DESC  
    intersect
	SELECT  TOP 5 Manufacturer_name
    FROM Fact_Transactions t
   LEFT JOIN DIM_Model mo ON t.IDModel = mo.IDModel
    LEFT JOIN DIM_MANUFACTURER ma  ON ma.IDManufacturer = mo.IDManufacturer
    Where DATEPART(Year,date)='2009' 
    group by Manufacturer_name, Quantity 
    Order by  SUM(Quantity ) DESC  
    intersect
	SELECT TOP 5 Manufacturer_name
    FROM Fact_Transactions t
    LEFT JOIN DIM_Model mo ON t.IDModel = mo.IDModel
    LEFT JOIN DIM_MANUFACTURER ma  ON ma.IDManufacturer = mo.IDManufacturer
    Where DATEPART(Year,date)='2010' 
    group by Manufacturer_name, Quantity 
    Order by  SUM(Quantity ) DESC)  as A
	

--Q7--END	
--Q8--BEGIN
SELECT  top 1 * 
 from
    (SELECT 
    TOP 2 Manufacturer_name,
    SUM(Quantity )  TotalQuantity1
    FROM Fact_Transactions t
    LEFT JOIN DIM_Model mo ON t.IDModel = mo.IDModel
    LEFT JOIN DIM_MANUFACTURER ma  ON ma.IDManufacturer = mo.IDManufacturer
    Where DATEPART(Year,date)='2009' 
    group by Manufacturer_name, Quantity 
    Order by  SUM(Quantity ) DESC ) as A,


        (SELECT 
    Top 2 Manufacturer_name,
     SUM(Quantity ) TotalQuantityQ2
    FROM Fact_Transactions t2
    LEFT JOIN DIM_Model mo1 ON t2.IDModel = mo1.IDModel
    LEFT JOIN DIM_MANUFACTURER ma1  ON ma1.IDManufacturer = mo1.IDManufacturer
    Where DATEPART(Year,date)='2010' 
    group by Manufacturer_name,Quantity
    Order by  SUM(Quantity )DESC ) as B



--Q8--END
--Q9--BEGIN
	select  manufacturer_name from DIM_MANUFACTURER ma 
inner join DIM_MODEL mo on ma.IDManufacturer = mo.IDManufacturer
inner join FACT_TRANSACTIONS t on t.IDModel = mo.IDModel
where year(date) = 2010 
group by Manufacturer_Name
except
select  manufacturer_name from DIM_MANUFACTURER ma 
inner join DIM_MODEL mo on ma.IDManufacturer = mo.IDManufacturer
inner join FACT_TRANSACTIONS t on t.IDModel = mo.IDModel
where year(date) = 2009
group by Manufacturer_Name

--Q9--END

--Q10--BEGIN
SELECT TOP 100 
YEAR(t.Date) AS [YEAR] , 
t.IDCustomer AS [CUSTOMER NAME],
t.TotalPrice AS [TOTAL AMT],
AVG(t.TotalPrice) AS [AVG SPEND],
AVG(t.Quantity) AS [AVG QUANTITY]
INTO #datasource
FROM 
    FACT_TRANSACTIONS t
INNER JOIN 
    DIM_CUSTOMER c ON t.IDCustomer = c.IDCustomer
GROUP BY t.Date,t.IDCustomer, t.TotalPrice
ORDER BY 
    [AVG SPEND] DESC 

SELECT * ,
[AVG SPEND]-LAG([AVG SPEND], 1, 0) OVER (PARTITION BY [CUSTOMER NAME] ORDER BY [YEAR])
from  #datasource

