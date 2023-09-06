CREATE FUNCTION GetTotalAmountByCustomerId (@CustomerId INT)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @TotalAmount DECIMAL(18, 2)

    SELECT @TotalAmount = SUM(OrderItem.UnitPrice * OrderItem.Quantity)
    FROM [Order] o
    INNER JOIN OrderItem ON o.ID = OrderItem.OrderID
    WHERE o.CustomerID = @CustomerId

    RETURN @TotalAmount
END
-- Xuất ra 1 khách hàng
DECLARE @CustomerId INT
SET @CustomerId = 1
SELECT dbo.GetTotalAmountByCustomerId(@CustomerId) AS TotalAmount
-- Xuất ra tất cả khách hàng
SELECT Customer.ID, Customer.LastName, dbo.GetTotalAmountByCustomerId(Customer.ID) AS TotalAmount
FROM Customer
order by Customer.Id


--Viết hàm truyền vào hai số và xuất ra danh sách các sản phẩm có UnitPrice nằm trong khoảng hai số đó. 
CREATE FUNCTION GetProductsByPriceRange (@MinPrice DECIMAL(18, 2), @MaxPrice DECIMAL(18, 2))
RETURNS TABLE
AS
RETURN
(
    SELECT ID, ProductName, UnitPrice
    FROM Product
    WHERE UnitPrice BETWEEN @MinPrice AND @MaxPrice
)

DECLARE @MinPrice DECIMAL(18, 2) = 10.00
DECLARE @MaxPrice DECIMAL(18, 2) = 30.00

SELECT ID, ProductName, UnitPrice
FROM dbo.GetProductsByPriceRange(@MinPrice, @MaxPrice)


--Viết hàm truyền vào một danh sách các tháng 'June;July;August;September' và xuất ra thông tin của các hóa đơn có trong những tháng đó. Viết cả hai hàm dưới dạng inline và multi statement sau đó cho biết thời gian thực thi của mỗi hàm, so sánh và đánh giá
--Inline Function:
CREATE FUNCTION GetInvoicesByMonths_Inline (@Months NVARCHAR(MAX))
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM [Order]
    WHERE FORMAT(OrderDate, 'MMMM') IN (SELECT value FROM STRING_SPLIT(@Months, ';'))
)
--Multi-Statement Function:
CREATE FUNCTION GetInvoicesByMonths_MultiStatement (@Months NVARCHAR(MAX))
RETURNS @Result TABLE (
    InvoiceID INT,
    CustomerID INT,
    InvoiceDate DATE,
    TotalAmount DECIMAL(18, 2)
)
AS
BEGIN
    INSERT INTO @Result
    SELECT ID, CustomerID, OrderDate, TotalAmount
    FROM [Order]
    WHERE FORMAT(OrderDate, 'MMMM') IN (SELECT value FROM STRING_SPLIT(@Months, ';'))

    RETURN
END

Set statistics time on

DECLARE @Months NVARCHAR(MAX) = 'June;July;August;September'
-- Inline Function
SELECT *
FROM dbo.GetInvoicesByMonths_Inline(@Months)

-- Multi-Statement Function
SELECT *
FROM dbo.GetInvoicesByMonths_MultiStatement(@Months)

set statistics time off

--Viết hàm kiểm tra mỗi hóa đơn không có quá 5 sản phẩm (kiểm tra trong bảng OrderItem). Nếu insert quá 5 sản phẩm cho một hóa đơn thì báo lỗi và không cho insert.
CREATE FUNCTION CheckOrderItemCount(@OrderId INT)
RETURNS BIT
AS
	BEGIN
		DECLARE @ItemCount INT;
		DECLARE @Existence BIT;

		SELECT @ItemCount = COUNT(*)
		FROM OrderItem
		WHERE OrderID = @OrderId;

		IF (@ItemCount>5)
			set @Existence = 0; -- False
		ELSE 
			set @Existence = 1;

		return @Existence;
	END
GO

alter table OrderItem
add constraint CheckOrderItemCount
	check(CheckOrderItemCount(OrderID) = 1)

SELECT ID, CustomerID
FROM [Order]
WHERE dbo.CheckOrderItemCount(ID) = 1;

drop FUNCTION dbo.CheckOrderItemCount

