CREATE VIEW uvw_DetailProductInOrder 
AS
SELECT
	o.Id as OrderID,
    o.OrderNumber,
    o.OrderDate,
    p.Id ProductID,
    CONCAT(p.ProductName , ' x ', p.Package) AS ProductInfo,
    oi.UnitPrice,
    oi.Quantity
FROM [Order] o
    INNER JOIN OrderItem oi ON o.Id = oi.OrderId
    INNER JOIN Product p ON oi.ProductId = p.Id;

Create view uvw_AllProductInOrder
as 
select 
	o.Id,
	o.OrderNumber,
	o.OrderDate,
	STUFF((
        SELECT ',' + CAST(oi.ProductId AS VARCHAR(10))
		from OrderItem oi
		where o.Id = oi.OrderId
        FOR XML PATH('')
    ), 1, 1, '') AS ProductList,
	SUM(oi.UnitPrice * Quantity) as TotalAmount
from [Order] o
inner join OrderItem oi on o.Id = oi.OrderId
group by o.Id, o.OrderNumber, o.OrderDate

--
set statistics io, time on
go

select * from uvw_DetailProductInOrder where month(OrderDate) = 7
go


select * from uvw_AllProductInOrder where LEN(ProductList) >= 3
go

set statistics io, time off
go

--
Create trigger uvw_Trigger_DetailProductInOrder
on uvw_DetailProductInOrder
instead of insert,update,delete
as
begin
	raiserror('You are not allowed to insert, update, or delete through this view',16,1)
end

Create trigger uvw_Trigger_AllProductInOrder
on uvw_AllProductInOrder
instead of insert,update,delete
as
begin
	raiserror('You are not allowed to insert, update, or delete through this view',16,1)
end