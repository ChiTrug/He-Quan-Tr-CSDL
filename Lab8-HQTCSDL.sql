CREATE PROCEDURE usp_GetOrderID_CustomerID_MaxAndMinTotalAmount
    @CustomerId INT,
    @MaxOrderId INT OUTPUT,
    @MaxTotalAmount DECIMAL(10, 2) OUTPUT,
    @MinOrderId INT OUTPUT,
    @MinTotalAmount DECIMAL(10, 2) OUTPUT
AS
BEGIN
    -- Tìm hóa đơn có Total Amount nhỏ nhất cho khách hàng
    SELECT TOP 1 @MinOrderId = Id, @MinTotalAmount = TotalAmount
    FROM [Order]
    WHERE CustomerId = @CustomerId
    ORDER BY TotalAmount ASC;

    -- Tìm hóa đơn có Total Amount lớn nhất cho khách hàng
    SELECT TOP 1 @MaxOrderId = Id, @MaxTotalAmount = TotalAmount
    FROM [Order]
    WHERE CustomerId = @CustomerId
    ORDER BY TotalAmount DESC;
END;



DECLARE @MaxOrderId INT, @MaxTotalAmount DECIMAL(10, 2), @MinOrderId INT, @MinTotalAmount DECIMAL(10, 2);

EXEC usp_GetOrderID_CustomerID_MaxAndMinTotalAmount
    @CustomerId = 1,
    @MaxOrderId = @MaxOrderId OUTPUT,
    @MaxTotalAmount = @MaxTotalAmount OUTPUT,
    @MinOrderId = @MinOrderId OUTPUT,
    @MinTotalAmount = @MinTotalAmount OUTPUT;

SELECT 'Hóa đơn có Total Amount nho nhat:',
    @MinOrderId AS OrderId,
    @MinTotalAmount AS TotalAmount;

SELECT 'Hóa đơn có Total Amount lon nhat:',
    @MaxOrderId AS OrderId,
    @MaxTotalAmount AS TotalAmount;



--
CREATE PROCEDURE usp_AddCustomer
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @City NVARCHAR(50),
    @Country NVARCHAR(50),
    @Phone NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra các thông tin đầu vào không được rỗng
    IF @FirstName = '' OR @LastName = '' OR @City = '' OR @Country = '' OR @Phone = ''
    BEGIN
        RAISERROR ('Các thông tin đầu vào không được rỗng.', 16, 1);
        RETURN;
    END;

    -- Kiểm tra xem khách hàng đã tồn tại trong bảng hay chưa
    IF EXISTS (SELECT 1 FROM Customer WHERE FirstName = @FirstName AND LastName = @LastName)
    BEGIN
        RAISERROR ('Khách hàng đã tồn tại trong bảng.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Thêm khách hàng mới vào bảng
        INSERT INTO Customer (FirstName, LastName, City, Country, Phone)
        VALUES (@FirstName, @LastName, @City, @Country, @Phone);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;

EXEC usp_AddCustomer
    @FirstName = 'John',
    @LastName = 'Doe',
    @City = 'New York',
    @Country = 'USA',
    @Phone = '1234567890';
