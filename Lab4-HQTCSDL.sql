-- Theo mỗi  OrderID cho biết số lượng Quantity của mỗi ProductID chiếm tỷ lệ bao nhiêu phần trăm 
SELECT OrderID, ProductID, Quantity,
       cast(Quantity * 100.0 / SUM(Quantity) OVER (PARTITION BY ProductID) as decimal(6,2)) AS PercentByProductID
FROM OrderItem
order by OrderID


-- Xuất các hóa đơn kèm theo thông tin ngày trong tuần của hóa đơn là : Thứ 2, 3,4,5,6,7, Chủ Nhật
SELECT ID, OrderDate,
       CASE DATEPART(dw, OrderDate)
           WHEN 1 THEN N'Chủ Nhật'
           WHEN 2 THEN N'Thứ 2'
           WHEN 3 THEN N'Thứ 3'
           WHEN 4 THEN N'Thứ 4'
           WHEN 5 THEN N'Thứ 5'
           WHEN 6 THEN N'Thứ 6'
           WHEN 7 THEN N'Thứ 7'
       END AS DayOfWeek
FROM [Order];

--Với mỗi ProductID trong OrderItem xuất các thông tin gồm OrderID, ProductID, ProductName, UnitPrice, Quantity, ContactInfo, ContactType. Trong đó ContactInfo ưu tiên Fax, nếu không thì dùng Phone của Supplier sản phẩm đó. Còn ContactType là ghi chú đó là loại ContactInfo nào
SELECT oi.OrderID, oi.ProductID, p.ProductName, p.UnitPrice, oi.Quantity,
    COALESCE(s.Fax, s.Phone) AS ContactInfo,
    COALESCE(
        CASE WHEN s.Fax IS NOT NULL THEN 'Fax' ELSE 'Phone' END,
        'N/A'
    ) AS ContactType
FROM OrderItem oi
JOIN Product p ON oi.ProductID = p.ID
JOIN Supplier s ON p.SupplierID = s.ID;

-- Cho biết Id của database Northwind, Id của bảng Supplier, Id của User mà bạn đang đăng nhập là bao nhiêu. Cho biết luôn tên User mà đang đăng nhập
SELECT DB_ID('Northwind') AS DatabaseId;

SELECT OBJECT_ID('Supplier') AS SupplierId;

SELECT CURRENT_USER AS CurrentUserName;

SELECT *FROM master.sys.database_principals;

SELECT principal_id, name
FROM sys.database_principals
WHERE name = 'dbo';

-- Cho biết các thông tin user_update, user_seek, user_scan và user_lookup trên bảng Order trong database Northwind
USE Northwind;

SELECT 
    user_updates AS UserUpdate,
    user_seeks AS UserSeek,
    user_scans AS UserScan,
    user_lookups AS UserLookup
FROM 
    sys.dm_db_index_usage_stats
WHERE 
    object_id = OBJECT_ID('Order');

-- Dùng WITH phân chia cây như sau : Mức 0 là các Quốc Gia(Country), mức 1 là các Thành Phố (City) thuộc Country đó, và mức 2 là các Hóa Đơn (Order) thuộc khách hàng từ Country-City đó
with OrderCategory(Country,City,OrderID,alevel)
as(
	select distinct Country,
	City = cast('' as nvarchar(255)),
	OrderID= cast('' as int),
	alevel = 0
	from Customer

	union all

	select c.Country, 
	City = cast(c.City as nvarchar(255)),
	OrderID = cast('' as int),
	alevel = oc.alevel +1
	from OrderCategory as oc
	inner join Customer c on oc.Country = c.Country
	where oc.alevel =0

	union all

	select c.Country,
	City = cast(c.City as nvarchar(255)),
	OrderID = cast(o.Id as int),
	alevel = oc.alevel +1 
	from Customer  as c
	join [Order] as o on c.Id = o.Id
	join OrderCategory oc on (oc.Country = c.Country and oc.City = c.City)
	where alevel =1
	)
select [Quoc Gia] = case when alevel =0 then Country else '--' end,
		[Thanh Pho] = case when alevel =1 then City else '----' end,
		[ID cua Order] = OrderID,
		Cap = alevel
from OrderCategory
order by Country, City,OrderID, alevel


--Xuất những hóa đơn từ khách hàng France mà có tổng số lượng Quantity lớn hơn 50 của các sản phẩm thuộc hóa đơn ấy
	select o.Id,o.CustomerId,sum(oi.Quantity) as TotalQuantity
	from [Order] as o
	join OrderItem oi on o.Id = oi.Id
	join Customer c on o.CustomerId=c.Id
	where c.Country = 'France'
	group by o.Id, o.CustomerId
	having sum(oi.Quantity) > 50


