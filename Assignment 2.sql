

--QUES1
--Create a procedure InsertOrderDetails that takes OrderID, ProductID, UnitPrice, Quantiy, Discount as input parameters and inserts that order information in the Order Details table...... Print a message if the quantity in stock of a product drops below its Reorder Level as a result of the update.
ALTER PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity SMALLINT,
    @Discount FLOAT = NULL
AS
BEGIN
    DECLARE @ActualPrice MONEY;
    DECLARE @Stock INT;
    DECLARE @ReorderPoint INT;
    DECLARE @SpecialOfferID INT = 1; -- Default Special Offer ID (No Discount)

    -- If discount is NULL, set it to 0
    SET @Discount = ISNULL(@Discount, 0);

    -- Get product price if UnitPrice is NULL
    IF @UnitPrice IS NULL
    BEGIN
        SELECT @ActualPrice = ListPrice FROM Production.Product WHERE ProductID = @ProductID;
    END
    ELSE
        SET @ActualPrice = @UnitPrice;

    -- Get current stock and reorder point
    SELECT @Stock = Quantity
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID;

    SELECT @ReorderPoint = ReorderPoint FROM Production.Product WHERE ProductID = @ProductID;

    -- If not enough stock
    IF @Stock IS NULL OR @Stock < @Quantity
    BEGIN
        PRINT 'Failed to place the order. Please try again. Not enough stock.';
        RETURN;
    END

    -- ✅ Insert into SalesOrderDetail with SpecialOfferID
    INSERT INTO Sales.SalesOrderDetail (
        SalesOrderID, ProductID, SpecialOfferID, OrderQty, UnitPrice, UnitPriceDiscount
    )
    VALUES (
        @OrderID, @ProductID, @SpecialOfferID, @Quantity, @ActualPrice, @Discount
    );

    -- Check if insert succeeded
    IF @@ROWCOUNT = 0
    BEGIN
        PRINT 'Failed to place the order. Please try again.';
        RETURN;
    END

    -- Update Inventory
    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @Quantity
    WHERE ProductID = @ProductID;

    -- Warn if below reorder
    IF (@Stock - @Quantity) < @ReorderPoint
    BEGIN
        PRINT 'Warning: Stock has dropped below the reorder level!';
    END
END;


--QUES 2
--Create a procedure UpdateOrderDetails that takes OrderID, ProductID, UnitPrice, Quantity, and discount, and updates these values for that ProductID in that Order.....To accomplish this, look for the ISNULL() function in google or sql server books online. Adjust the UnitsInStock value in products table accordingly.
CREATE PROCEDURE UpdateOrderDetails
    @OrderID INT,
    @ProductID INT,
    @UnitPrice MONEY = NULL,
    @Quantity INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OldQuantity INT;

    -- Get current quantity
    SELECT @OldQuantity = OrderQty
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    IF @OldQuantity IS NULL
    BEGIN
        PRINT 'Order not found.';
        RETURN;
    END

    -- Update only the fields passed
    UPDATE Sales.SalesOrderDetail
    SET
        UnitPrice = ISNULL(@UnitPrice, UnitPrice),
        OrderQty = ISNULL(@Quantity, OrderQty)
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    -- Adjust SafetyStockLevel (used instead of UnitsInStock)
    IF @Quantity IS NOT NULL AND @Quantity <> @OldQuantity
    BEGIN
        DECLARE @StockChange INT = @OldQuantity - @Quantity;

        UPDATE Production.Product
        SET SafetyStockLevel = SafetyStockLevel + @StockChange
        WHERE ProductID = @ProductID;

        -- Check if SafetyStockLevel drops below a threshold
        DECLARE @NewStock INT;
        SELECT @NewStock = SafetyStockLevel
        FROM Production.Product
        WHERE ProductID = @ProductID;

        -- You can define your own reorder level
        IF @NewStock < 100
        BEGIN
            PRINT 'Warning: Product stock below reorder level.';
        END
    END
END;


--QUES 3
--Create a procedure GetOrderDetails that takes OrderID as input parameter and returns all the records for that OrderID. If no records are found in Order Details table, then it should print the line: "The OrderID XXXX does not exits", where XXX should be the OrderID entered by user and the procedure should RETURN the value 1.
CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM Sales.SalesOrderDetail WHERE SalesOrderID = @OrderID
    )
    BEGIN
        PRINT 'The OrderID ' + CAST(@OrderID AS VARCHAR) + ' does not exist';
        RETURN 1;
    END

    -- If exists, return all rows
    SELECT * 
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID;
END;

--QUES 4
--Create a procedure DeleteOrderDetails that takes OrderID and ProductID and deletes that from Order Details table. Your procedure should validate parameters. It should return an error code (-1) and print a message if the parameters are invalid. Parameters are valid if the given order ID appears in the table and if the given product ID appears in that order.
CREATE PROCEDURE DeleteOrderDetails
    @OrderID INT,
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM Sales.SalesOrderDetail 
        WHERE SalesOrderID = @OrderID
    )
    BEGIN
        PRINT 'Invalid OrderID';
        RETURN -1;
    END

    IF NOT EXISTS (
        SELECT 1 FROM Sales.SalesOrderDetail 
        WHERE SalesOrderID = @OrderID AND ProductID = @ProductID
    )
    BEGIN
        PRINT 'ProductID not found in the given OrderID';
        RETURN -1;
    END

    -- If valid, perform delete
    DELETE FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = @OrderID AND ProductID = @ProductID;

    PRINT 'Order detail deleted successfully';
END;

--QUES 5
--Create a function that takes an input parameter type datetime and returns the date in the format MM/DD/YYYY.For example if I pass in 2006-11-21 23:34:05.920', the output of the functions should be 11/21/2006

CREATE FUNCTION dbo.GetDate_MMDDYYYY()
RETURNS VARCHAR(20)
AS
BEGIN
    RETURN CONVERT(VARCHAR(20), GETDATE(), 101);  -- mm/dd/yyyy
END;

--QUES 6
--Create a function that takes an input parameter type datetime and returns the date in the format YYYYMMDD
CREATE FUNCTION dbo.GetDate_DDMMYYYY()
RETURNS VARCHAR(20)
AS
BEGIN
    RETURN CONVERT(VARCHAR(20), GETDATE(), 103);  -- dd/mm/yyyy
END;

--QUES 7
--Create a view vwCustomerOrders which returns CompanyName OrderID. ProductID.Product Name. Quantity UnitPrice.Quantity od.UnitPrice
CREATE VIEW vwCustomerOrders AS
SELECT
    s.Name AS CompanyName,
    soh.SalesOrderID AS OrderID,
    soh.OrderDate,
    sod.ProductID,
    p.Name AS ProductName,
    sod.OrderQty AS Quantity,
    sod.UnitPrice,
    (sod.OrderQty * sod.UnitPrice) AS TotalPrice
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID;

--QUES 8
--Create a copy of the above view and modify it so that it only returns the above information for orders that were placed yesterday
CREATE VIEW vwCustomerOrders_Yesterday AS
SELECT
    s.Name AS CompanyName,
    soh.SalesOrderID AS OrderID,
    soh.OrderDate,
    sod.ProductID,
    p.Name AS ProductName,
    sod.OrderQty AS Quantity,
    sod.UnitPrice,
    (sod.OrderQty * sod.UnitPrice) AS TotalPrice
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
WHERE CAST(soh.OrderDate AS DATE) = CAST(GETDATE() - 1 AS DATE);

--QUES 9
--Use a CREATE VIEW statement to create a view called MyProducts. Your view should contain the ProductID, Product Name, QuantityPerUnit and UnitPrice columns from the Products table. It should also contain the CompanyName column from the Suppliers table and the CategoryName column from the Categories table. Your view should only contain products that are not discontinued.
CREATE VIEW MyProducts AS
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    p.Size AS QuantityPerUnit, -- Approximate, since AdventureWorks doesn't have QuantityPerUnit
    p.ListPrice AS UnitPrice,
    v.Name AS CompanyName,
    pc.Name AS CategoryName
FROM 
    Production.Product p
JOIN 
    Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN 
    Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
JOIN 
    Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
JOIN 
    Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE 
    p.SellEndDate IS NULL;


 --QUES 10
 --If someone cancels an order in northwind database, then you want to delete that order from the Orders table. But you will not be able to delete that Order before deleting the records from Order Details table for that particular order due to referential integrity constraints. Create an Instead of Delete trigger on Orders table so that if some one tries to delete an Order that trigger gets fired and that trigger should first delete everything in order details table and then delete that order from the Orders table
CREATE TRIGGER trg_DeleteOrder_WithCascade
ON Sales.SalesOrderHeader
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Sales.SalesOrderDetail
    WHERE SalesOrderID IN (SELECT SalesOrderID FROM DELETED);

    DELETE FROM Sales.SalesOrderHeader
    WHERE SalesOrderID IN (SELECT SalesOrderID FROM DELETED);
END;

--QUES 11
--When an order is placed for X units of product Y, we must first check the Products table to ensure that there is sufficient stock to fill the order. This trigger will operate on the Order Details table. If sufficient stock exists, then fill the order and decrement X units from the UnitsInStock column in Products. If insufficient stock exists, then refuse the order (ie. do not insert it) and notify the user that the order could not be filled because of insufficient stock.
CREATE TRIGGER trg_CheckStock_BeforeInsert
ON Sales.SalesOrderDetail
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProductID INT, @OrderQty INT, @AvailableStock INT, @SalesOrderID INT;

    SELECT 
        @ProductID = ProductID,
        @OrderQty = OrderQty,
        @SalesOrderID = SalesOrderID
    FROM INSERTED;

    SELECT @AvailableStock = Quantity
    FROM Production.ProductInventory
    WHERE ProductID = @ProductID;

    IF @AvailableStock IS NULL
    BEGIN
        RAISERROR ('Invalid Product ID or no inventory record found.', 16, 1);
        RETURN;
    END

    IF @OrderQty > @AvailableStock
    BEGIN
        RAISERROR ('Not enough stock to fulfill order.', 16, 1);
        RETURN;
    END

    -- Insert the order
    INSERT INTO Sales.SalesOrderDetail (SalesOrderID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate)
    SELECT SalesOrderID, OrderQty, ProductID, UnitPrice, UnitPriceDiscount, rowguid, ModifiedDate
    FROM INSERTED;

    -- Update stock
    UPDATE Production.ProductInventory
    SET Quantity = Quantity - @OrderQty
    WHERE ProductID = @ProductID;
END;
