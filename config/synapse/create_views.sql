
-- Create analytical views
CREATE VIEW dbo.SupplyChainAnalytics AS
SELECT 
    m.MaterialName,
    m.Category,
    COUNT(so.OrderID) as TotalOrders,
    SUM(so.Quantity) as TotalQuantity,
    AVG(so.Quantity) as AvgQuantity,
    MAX(so.OrderDate) as LastOrderDate
FROM dbo.Materials m
LEFT JOIN dbo.SalesOrders so ON m.MaterialID = so.MaterialID
GROUP BY m.MaterialID, m.MaterialName, m.Category;
        