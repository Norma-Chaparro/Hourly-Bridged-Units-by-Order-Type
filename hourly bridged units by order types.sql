SELECT [Order Hour]
    ,[customer],[customer-nrhl], [rtv],[store],[assignment]
FROM
(
    SELECT 
        [Order Date]
        ,[Order Hour]
        ,[Order Type]
        ,m.units
    FROM
    (
        SELECT
            CONVERT(DATE, a.event_time) AS [Order Date]
            ,FORMAT(DATEPART(HOUR, a.event_time), '00') AS [Order Hour]
            ,event_time
            ,a.order_id
            ,a.order_type_id AS [Order Type]
            ,b.units
        FROM
            mi_order a
        JOIN (
                SELECT
                    DISTINCT order_id
                    ,SUM(qty) AS units
                FROM
                    mi_pick
                WHERE
                    oel_class = 'OEL_PICK_CREATE'
                    AND event_time >= DATEADD(DAY, -8, GETDATE())
                GROUP BY
                    order_id
            ) AS b ON a.order_id = b.order_id
        WHERE
            a.order_state NOT IN ('ABANDONED')            
            AND a.order_type_id IN ('customer', 'customer-nrhl', 'rtv', 'store', 'assignment')
            AND event_time >= DATEADD(DAY, -8, GETDATE())
            AND a.order_state = 'CREATING'
    ) AS m
    WHERE [Order Date] = CONVERT(DATE, GETDATE())
) AS SourceTable
PIVOT
(
    SUM(units)
    FOR [Order Type] IN ([customer],[customer-nrhl], [rtv],[store],[assignment])
) AS PivotTable
ORDER BY [Order Date]