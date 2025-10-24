
-- Create supply chain tables
CREATE TABLE dbo.Materials (
    MaterialID NVARCHAR(50) PRIMARY KEY,
    MaterialName NVARCHAR(255),
    Category NVARCHAR(100),
    UnitPrice DECIMAL(10,2),
    CreatedDate DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE dbo.SalesOrders (
    OrderID NVARCHAR(50) PRIMARY KEY,
    CustomerID NVARCHAR(50),
    MaterialID NVARCHAR(50),
    Quantity INT,
    OrderDate DATETIME2,
    Status NVARCHAR(50),
    FOREIGN KEY (MaterialID) REFERENCES dbo.Materials(MaterialID)
);

CREATE TABLE dbo.Shipments (
    ShipmentID NVARCHAR(50) PRIMARY KEY,
    OrderID NVARCHAR(50),
    CarrierID NVARCHAR(50),
    ShipDate DATETIME2,
    DeliveryDate DATETIME2,
    Status NVARCHAR(50),
    FOREIGN KEY (OrderID) REFERENCES dbo.SalesOrders(OrderID)
);
        