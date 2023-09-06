select top 9 s.Id,CompanyName,ContactName, City, Country, Phone, MIN(p.UnitPrice) as MinPrice,max(p.UnitPrice) as  MaxPrice
from Supplier as s
inner join Product as p on s.Id = p.SupplierId
group by s.Id,CompanyName,ContactName, City, Country, Phone
HAVING MAX(p.UnitPrice) - MIN(p.UnitPrice) <= 30
ORDER BY s.Id ASC

select o.Id, OrderNumber, OrderDate , sum(oi.UnitPrice*oi.Quantity) as TotalPrice, 'VIP' as Description
from [Order] as o
inner join OrderItem as oi on o.Id = oi.OrderId
group by o.Id, OrderNumber, OrderDate
having sum(oi.UnitPrice*oi.Quantity)> 1500
union
select o.Id, OrderNumber, OrderDate , sum(oi.UnitPrice*oi.Quantity) as TotalPrice, 'Normal' as Description
from [Order] as o
inner join OrderItem as oi on o.Id = oi.OrderId
group by o.Id, OrderNumber, OrderDate
having sum(oi.UnitPrice*oi.Quantity) <= 1500

select o.Id, OrderNumber, OrderDate , oi.UnitPrice*oi.Quantity as TotalPrice, 'VIP' as Description
from [Order] as o , OrderItem as oi
where o.Id = oi.OrderId and (oi.UnitPrice*oi.Quantity)> 1500
union
select o.Id, OrderNumber, OrderDate , oi.UnitPrice*oi.Quantity as TotalPrice, 'Normal' as Description
from [Order] as o , OrderItem as oi
where o.Id = oi.OrderId and (oi.UnitPrice*oi.Quantity)<= 1500

select o.Id, OrderNumber, OrderDate
from [Order] as o
where MONTH(OrderDate) = 7
except 
select o.Id, OrderNumber, OrderDate
from [Order] as o, Customer as c
where c.Country= 'France' and o.CustomerId = c.Id

SELECT Id, OrderNumber, OrderDate
FROM [Order]
WHERE MONTH(OrderDate) = 7 AND CustomerId NOT IN (
   SELECT Id
   FROM Customer
   WHERE Country = 'France'
)
EXCEPT
SELECT o.Id, OrderNumber,OrderDate
FROM [Order] as o
INNER JOIN Customer ON o.CustomerId = Customer.Id
WHERE MONTH(OrderDate) = 7 AND Customer.Country = 'France'


SELECT Id, OrderNumber, OrderDate, TotalAmount
FROM [Order]
WHERE TotalAmount IN (
   SELECT TOP 5 TotalAmount
   FROM [Order]
   ORDER BY TotalAmount DESC
)

