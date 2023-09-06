select *
from 
(
	select RowNum, Id, ProductName, SupplierId, Package, IsDiscontinued, Max(RowNum) over (order by (select 1)) as RowLast
	from(
		select ROW_NUMBER() over (order by UnitPrice) as RowNum,
				Id, ProductName, SupplierId, Package, IsDiscontinued 
		from Product
	) as DerivedTable
) Report
where Report.RowNum >= 0.2 * RowLast


SELECT *
FROM (
  SELECT *,
    ROW_NUMBER() OVER (ORDER BY UnitPrice DESC) as row_num,
    COUNT(*) OVER () as total_rows
  FROM Product
) as subquery
WHERE row_num >= (total_rows * 0.8) + 1
ORDER BY UnitPrice ASC;


select OrderId, ProductId, UnitPrice, Quantity, str([Percent]*100,5,2)+ '%' as [Percent]
from 
(
	select OrderId, ProductId, UnitPrice, Quantity,
	(cast(Quantity as float) / (SUM(Quantity) over (partition by OrderId))) as [Percent]
	from OrderItem
) Report
order by OrderId ASC, Quantity DESC


SELECT 
    CompanyName, 
    ISNULL('USA', 0) AS USA, 
    ISNULL('UK', 0) AS UK,
    ISNULL('France', 0) AS France,
    ISNULL('Germany', 0) AS Germany,
    ISNULL('Others', 0) AS Others
FROM (
    SELECT 
        CompanyName, 
        IF(Country = 'USA',[1], 0) AS 'USA',
        IF(Country = 'UK', [1], 0) AS 'UK', 
        IF(Country = 'France', [1], 0) AS 'France',
        IF(Country = 'Germany', [1], 0) AS 'Germany', 
        IF(Country NOT IN ('USA', 'UK', 'France', 'Germany'), [1], 0) AS 'Others'
    FROM Supplier
) AS tmp
PIVOT (
    SUM('USA') AS 'USA',
    SUM('UK') AS 'UK',
    SUM('France') AS 'France',
    SUM('Germany') AS 'Germany',
    SUM('Others') AS 'Others'
    FOR Country IN ('USA', 'UK', 'France', 'Germany', 'Others')
) AS p;


if exists(select * from INFORMATION_SCHEMA.TABLES
		  where TABLE_NAME = N'tmp' )
begin
	drop table tmp
end

select CompanyName, Country as ctr into tmp
from Supplier

select *
from Supplier



SELECT *
FROM (SELECT CompanyName,
             CASE WHEN country = 'USA' THEN 1 ELSE 0 END AS USA,
             CASE WHEN country = 'UK' THEN 1 ELSE 0 END AS UK,
             CASE WHEN country = 'France' THEN 1 ELSE 0 END AS France,
             CASE WHEN country = 'Germany' THEN 1 ELSE 0 END AS Germany,
             CASE WHEN country NOT IN ('USA', 'UK', 'France', 'Germany') THEN 1 ELSE 0 END AS Others
      FROM supplier) as sup
order by CompanyName

SELECT * FROM (
   SELECT CompanyName
      ,CASE 
         WHEN country = 'USA' THEN 'USA'
         WHEN country = 'UK' THEN 'UK'
         WHEN country = 'France' THEN 'France'
         WHEN country = 'Germany' THEN 'Germany'
         ELSE 'Others' END AS Country
   FROM supplier
) AS sup_data
PIVOT (
   COUNT(Country)
   FOR Country IN ([USA], [UK], [France], [Germany], [Others])
) AS PivotTable;


SELECT 
    o.OrderNumber, 
    CONVERT(varchar, o.OrderDate, 106) AS OrderDate, 
    c.FirstName + ' ' + c.LastName as CustomerName, 
    CONCAT('Phone: ', c.Phone, ', City: ', c.City, ' and Country: ', c.Country) AS Address, 
    CONCAT(FORMAT(o.TotalAmount, 'N0'), ' Euro') AS TotalAmount
FROM 
    [Order] as o 
    JOIN Customer as c ON o.CustomerID = c.Id

SELECT 
	Id,
    ProductName,
	SupplierID,
	UnitPrice,
    Package= STUFF(Package, charindex('bags', Package), len('bags'),N'túi')
FROM 
    Product
WHERE 
    Package LIKE '%bags%'


SELECT 
    Id,
    ProductName,
	SupplierID,
	UnitPrice, 
    REPLACE(Package, 'bags', N'túi') AS Package
FROM 
    Product
WHERE 
    Package LIKE '%bags%'


SELECT 
    c.Id,
    c.LastName, 
    COUNT(o.Id) AS TotalOrders, 
    DENSE_RANK() OVER (ORDER BY COUNT(o.Id) DESC) AS CustomerRank,
    NTILE(3) OVER (ORDER BY COUNT(o.ID) DESC) AS CustomerGroup
FROM 
    Customer c 
    JOIN [Order] as o ON c.Id = o.CustomerID
GROUP BY 
    c.Id,c.LastName
ORDER BY 
    TotalOrders DESC;
