CREATE TRIGGER trg_DeleteOrder
ON [dbo].[Order]
AFTER DELETE
AS
BEGIN
    -- Kiểm tra sự tồn tại của Foreign Key Constraint
    IF EXISTS (
        SELECT *
        FROM sys.foreign_keys
        WHERE parent_object_id = OBJECT_ID('OrderItem') 
          AND referenced_object_id = OBJECT_ID('Order') 
    )
    BEGIN
        -- Xóa Foreign Key Constraint
        ALTER TABLE OrderItem
        DROP CONSTRAINT FK_ORDERITE_REFERENCE_ORDER; 
    END;

    -- Xóa các thông tin của Order trong bảng OrderItem
    DELETE FROM OrderItem
    WHERE OrderId IN (SELECT deleted.Id FROM deleted);
END;

-- Đơn hàng id =10
select  * from [Order] where Id = 10

-- Xóa FK_ORDERITE_REFERENCE_ORDER để kiểm nghiệm trigger
alter table [OrderItem] drop constraint FK_ORDERITE_REFERENCE_ORDER

Delete from [Order] where id = 10

-- Kiem tra lai
select * from OrderItem where OrderId =10



--Viết trigger khi xóa hóa đơn của khách hàng Id = 1 thì báo lỗi không cho xóa sau đó ROLL BACK lại. Lưu ý: Đưa trigger này lên làm Trigger đầu tiên thực thi xóa dữ liệu trên bảng Order

CREATE TRIGGER trg_PreventDeleteOrder
ON [Order]
FOR DELETE
AS
BEGIN
    -- Kiểm tra nếu hóa đơn được xóa có khách hàng Id = 1
    IF EXISTS (
        SELECT *
        FROM deleted
        WHERE CustomerId = 1
    )
    BEGIN
        -- Báo lỗi và rollback
        RAISERROR ('Không được xóa hóa đơn của khách hàng Id = 1', 16, 1)
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;

EXEC sp_settriggerorder @triggername = 'trg_PreventDeleteOrder', @order = 'First', @stmttype = 'DELETE';

delete from [order] where CustomerId = 1


--

CREATE TRIGGER trg_PreventUpdateSupplierPhone
ON Supplier
INSTEAD OF UPDATE
AS
BEGIN
    -- Kiểm tra các cột Phone bị cập nhật
    IF EXISTS (
        SELECT *
        FROM inserted
        WHERE (Phone IS NULL OR Phone LIKE '%[a-zA-Z]%')
    )
    BEGIN
        -- Báo lỗi và rollback
        RAISERROR ('Không được cập nhật Phone là NULL hoặc chứa chữ cái', 16, 1)
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- Cập nhật các dòng không vi phạm
    UPDATE s
    SET s.Phone = i.Phone
    FROM Supplier s
    INNER JOIN inserted i ON s.SupplierId = i.SupplierId;
END;


-- 

CREATE TRIGGER trg_PreventUpdateSupplierPhone
ON Supplier
FOR UPDATE
AS
BEGIN
    -- Kiểm tra các cột Phone bị cập nhật
    IF EXISTS (
        SELECT *
        FROM inserted
        WHERE (Phone IS NULL OR Phone LIKE '%[a-zA-Z]%')
    )
    BEGIN
        -- Báo lỗi và rollback
        RAISERROR ('Không được cập nhật Phone là NULL hoặc chứa chữ cái', 16, 1)
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;

update Supplier set Phone = null where id =1

--
CREATE FUNCTION dbo.GetCompaniesByCountry
(
    @Country NVARCHAR(100)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Result NVARCHAR(MAX);

    SELECT @Result = CONCAT('Companies in ', @Country, ' are: ');

    SELECT @Result = CONCAT(@Result, CompanyName, '(ID:', CAST(ID AS NVARCHAR(10)), '); ')
    FROM Supplier -- Thay thế YourTable bằng tên bảng chứa thông tin công ty
    WHERE Country = @Country;

    RETURN @Result;
END;
-- Kiem tra ket qua
DECLARE @Country NVARCHAR(100) = 'USA';
DECLARE @Output NVARCHAR(MAX);

SET @Output = dbo.GetCompaniesByCountry(@Country);

SELECT @Output AS [OUTPUT];

--


begin try
	BEGIN TRANSACTION UpdateQuantity
		
		set nocount on;

		DECLARE @UpdatedOrdersCount INT = 0;
		DECLARE @DFactor int; -- Giá trị DFactor
		SET @DFactor = 0; -- Thay đổi giá trị DFactor tùy theo yêu cầu

		UPDATE OrderItem
		SET Quantity = Quantity / @DFactor
		WHERE OrderID IN (
			SELECT OrderID
			FROM [Order]
			WHERE CustomerID IN (
				SELECT CustomerID
				FROM Customer
				WHERE Country = 'USA'
			)
		);

		SET @UpdatedOrdersCount = @@ROWCOUNT;
		print 'cap nhat thanh cong '+LTRIM(STR(@UpdatedOrdersCount)) + 'dong trong bang '
	commit transaction UpdateQuantity
end try
BEGIN catch
    ROLLBACK TRAN UpdateQuantity;
	print'Cap nhat that bai'
	print ERROR_MESSAGE();
END catch;





--
begin try
BEGIN TRANSACTION CompareSupplierCount

	set nocount on;

	-- Input: Hai quốc gia
	DECLARE @Country1 NVARCHAR(100) = 'USA';
	DECLARE @Country2 NVARCHAR(100) = 'UK';

	-- Sử dụng bảng tạm #
	CREATE TABLE #TempCountrySupplier (
		Country NVARCHAR(100),
		SupplierId INT
	);

	-- Sử dụng bảng tạm @
	DECLARE @TempCountrySupplier TABLE (
		Country NVARCHAR(100),
		SupplierId INT
	);

	-- Lấy số lượng nhà cung cấp cho quốc gia 1 và lưu vào bảng tạm #
	INSERT INTO #TempCountrySupplier
	SELECT @Country1,Id
	FROM Supplier
	WHERE Country = @Country1;

	-- Lấy số lượng nhà cung cấp cho quốc gia 2 và lưu vào bảng tạm @
	INSERT INTO @TempCountrySupplier
	SELECT @Country2,Id
	FROM Supplier
	WHERE Country = @Country2;

	declare @NumSup1 int
	set @NumSup1 = (select count(distinct SupplierId) from  #TempCountrySupplier);
	declare @NumSup2 int
	set @NumSup2 = (select count(distinct SupplierId) from  @TempCountrySupplier);


	-- Kiểm tra và xuất thông tin về quốc gia có số lượng nhà cung cấp nhiều hơn
	print 'So luong san pham cung cap cua USA ' + LTRIM(STR(@NumSup1))
	print 'So luong san pham cung cap cua UK ' + LTRIM(STR(@NumSup2))

	print
	case
		when @NumSup1 > @NumSup2
			then 'So luong san pham cung cap cua USA nhieu hon UK'
		when @NumSup1 < @NumSup2
			then 'So luong san pham cung cap cua USA it hon UK'
		else 'So luong san pham cung cap cua USA va UK bang nhau'
	end

	-- Xóa bảng tạm #
	DROP TABLE #TempCountrySupplier;

COMMIT TRANSACTION CompareSupplierCount
end try
begin catch
	rollback tran CompareSupplierCount
	print 'Co loi xay ra. Xem chi tiet : ';
	print ERROR_MESSAGE();
end catch