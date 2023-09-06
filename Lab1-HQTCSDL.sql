--truy vấn danh sách các customer
select *
from Customer

--Truy vấn danh sách các Customer theo các thông tin Id, FullName (là kết hợp FirstName-LastName), City, Country
select Id, FirstName+' '+LastName as FullName,City,Country
from Customer

--Cho biết có bao nhiêu khách hàng từ Germany và UK, đó là những khách hàng nào
select count(Id)
from Customer
where Country in ('Germany','UK')
select *
from Customer
where Country in ('Germany','UK')

--Liệt kê danh sách khách hàng theo thứ tự tăng dần của FirstName và giảm dần của Country
select FirstName, LastName, Country
from Customer
order by FirstName ASC , Country DESC

--Truy vấn danh sách các khách hàng với ID là 5,10, từ 1-10, và từ 5-10
select *
from Product
where Id = 5 or Id = 10

select top 10 *
from Product

select *
from Product
order by Id ASC
offset 4 Rows
fetch next 6 rows only

--
select *
from Product 
where Package like '%bottles%' and UnitPrice between 15 and 20 and SupplierId != 16