SELECT c.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Person.Person p
    ON c.PersonID = p.BusinessEntityID;
--2
SELECT c.CustomerID, s.Name AS CompanyName
FROM Sales.Customer c
JOIN Sales.Store s
    ON c.StoreID = s.BusinessEntityID
WHERE s.Name LIKE '%N';
--3
SELECT DISTINCT c.CustomerID, p.FirstName, p.LastName, a.City
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
WHERE a.City IN ('Berlin', 'London');
--4
SELECT DISTINCT c.CustomerID, p.FirstName, p.LastName, cr.Name AS Country
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name IN ('United Kingdom', 'United States');
--5
SELECT ProductID, Name
FROM Production.Product
ORDER BY Name ASC;
--6
SELECT ProductID, Name
FROM Production.Product
WHERE Name LIKE 'A%';
--7
SELECT DISTINCT c.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID;
--8
SELECT DISTINCT c.CustomerID, p.FirstName, p.LastName, a.City, pr.Name AS Product
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
JOIN Person.Address a ON bea.AddressID = a.AddressID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
WHERE a.City = 'London' AND pr.Name = 'Adjustable Race';
--9
SELECT c.CustomerID, p.FirstName, p.LastName
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE c.CustomerID NOT IN (
    SELECT CustomerID FROM Sales.SalesOrderHeader
);
--10
SELECT DISTINCT c.CustomerID, p.FirstName, p.LastName, pr.Name AS Product
FROM Sales.Customer c
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
WHERE pr.Name = 'Adjustable Race'; 
--11
SELECT TOP 1 *
FROM Sales.SalesOrderHeader
ORDER BY OrderDate ASC;
--12
SELECT TOP 1 OrderDate, SalesOrderID, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;
--13
SELECT SalesOrderID, AVG(OrderQty) AS AvgQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;
--14
SELECT SalesOrderID, MIN(OrderQty) AS MinQty, MAX(OrderQty) AS MaxQty
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID;
--15
SELECT 
    mgr.BusinessEntityID AS ManagerID,
    p.FirstName + ' ' + p.LastName AS ManagerName,
    COUNT(emp.BusinessEntityID) AS NumberOfReports
FROM HumanResources.Employee emp
JOIN HumanResources.Employee mgr
    ON emp.OrganizationNode.GetAncestor(1) = mgr.OrganizationNode
JOIN Person.Person p 
    ON mgr.BusinessEntityID = p.BusinessEntityID
GROUP BY mgr.BusinessEntityID, p.FirstName, p.LastName;
--16
SELECT SalesOrderID, SUM(OrderQty) AS TotalQuantity
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID
HAVING SUM(OrderQty) > 300;
--17
SELECT *
FROM Sales.SalesOrderHeader
WHERE OrderDate >= '1996-12-31';
--18
SELECT *
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'Canada';
--19
SELECT SalesOrderID, OrderDate, CustomerID, TotalDue
FROM Sales.SalesOrderHeader
WHERE TotalDue > 200;
--20
SELECT cr.Name AS Country, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;
--21
SELECT p.FirstName + ' ' + p.LastName AS ContactName, COUNT(soh.SalesOrderID) AS OrdersPlaced
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY p.FirstName, p.LastName;
--22
SELECT p.FirstName + ' ' + p.LastName AS ContactName, COUNT(soh.SalesOrderID) AS OrdersPlaced
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY p.FirstName, p.LastName
HAVING COUNT(soh.SalesOrderID) > 3;
--23
SELECT DISTINCT p.ProductID, p.Name, soh.OrderDate
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE p.SellEndDate IS NOT NULL
  AND soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';
--24
SELECT 
    e.BusinessEntityID AS EmployeeID,
    e_p.FirstName AS EmployeeFirst,
    e_p.LastName AS EmployeeLast,
    m_p.FirstName AS ManagerFirst,
    m_p.LastName AS ManagerLast
FROM HumanResources.Employee e
JOIN HumanResources.Employee m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
JOIN Person.Person e_p ON e.BusinessEntityID = e_p.BusinessEntityID
JOIN Person.Person m_p ON m.BusinessEntityID = m_p.BusinessEntityID;
--25
SELECT e.BusinessEntityID AS EmployeeID, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN HumanResources.Employee e ON sp.BusinessEntityID = e.BusinessEntityID
GROUP BY e.BusinessEntityID;
--26
SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person
WHERE FirstName LIKE '%a%';
--27
SELECT 
    mgr.BusinessEntityID AS ManagerID,
    p.FirstName + ' ' + p.LastName AS ManagerName,
    COUNT(emp.BusinessEntityID) AS ReportCount
FROM HumanResources.Employee emp
JOIN HumanResources.Employee mgr 
    ON emp.OrganizationNode.GetAncestor(1) = mgr.OrganizationNode
JOIN Person.Person p ON mgr.BusinessEntityID = p.BusinessEntityID
GROUP BY mgr.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(emp.BusinessEntityID) > 4;
--28
SELECT soh.SalesOrderID, pr.Name AS ProductName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID;
--29
WITH TotalPerCustomer AS (
    SELECT CustomerID, SUM(TotalDue) AS TotalSpent
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
)
SELECT soh.SalesOrderID, soh.OrderDate, soh.TotalDue
FROM Sales.SalesOrderHeader soh
JOIN TotalPerCustomer tpc ON soh.CustomerID = tpc.CustomerID
WHERE tpc.TotalSpent = (
    SELECT MAX(TotalSpent) FROM TotalPerCustomer
);
--30
SELECT soh.SalesOrderID, soh.OrderDate, p.FirstName, p.LastName
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.PersonPhone pp ON p.BusinessEntityID = pp.BusinessEntityID
WHERE p.BusinessEntityID NOT IN (
    SELECT BusinessEntityID FROM Person.EmailAddress WHERE EmailAddress LIKE '%fax%'
);
--31
SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE pr.Name = 'Adjustable Race';  
--32
SELECT DISTINCT pr.Name AS ProductName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product pr ON sod.ProductID = pr.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'France';
--33
SELECT p.Name AS ProductName, pc.Name AS Category
FROM Production.Product p
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
WHERE p.Name LIKE '%Biscuit%'; 
--34
SELECT p.ProductID, p.Name
FROM Production.Product p
WHERE p.ProductID NOT IN (
    SELECT DISTINCT ProductID FROM Sales.SalesOrderDetail
);
--35
SELECT pi.ProductID, p.Name, pi.Quantity
FROM Production.ProductInventory pi
JOIN Production.Product p ON pi.ProductID = p.ProductID
WHERE pi.Quantity < 10;
--36
SELECT TOP 10 cr.Name AS Country, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name
ORDER BY TotalSales DESC;
--37
SELECT e.BusinessEntityID AS EmployeeID, p.FirstName + ' ' + p.LastName AS EmployeeName, COUNT(soh.SalesOrderID) AS OrdersHandled
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN HumanResources.Employee e ON sp.BusinessEntityID = e.BusinessEntityID
JOIN Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
WHERE soh.CustomerID BETWEEN 1 AND 100
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName;
--38
SELECT TOP 1 SalesOrderID, OrderDate, TotalDue
FROM Sales.SalesOrderHeader
ORDER BY TotalDue DESC;
--39
SELECT 
    p.Name AS ProductName,
    SUM(sod.LineTotal) AS TotalRevenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalRevenue DESC;
--40
SELECT BusinessEntityID AS SupplierID, COUNT(DISTINCT ProductID) AS NumberOfProducts
FROM Purchasing.ProductVendor
GROUP BY BusinessEntityID;
--41
SELECT TOP 10 c.CustomerID, p.FirstName + ' ' + p.LastName AS CustomerName, SUM(soh.TotalDue) AS TotalSpent
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY c.CustomerID, p.FirstName, p.LastName
ORDER BY TotalSpent DESC;
--42
SELECT SUM(TotalDue) AS TotalCompanyRevenue
FROM Sales.SalesOrderHeader;

