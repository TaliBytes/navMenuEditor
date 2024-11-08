SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER FUNCTION [dbo].[fn_menuItem_level]
(
  @menuItemID INT
)
RETURNS INT
AS
BEGIN

    DECLARE @resultLevel INT

    ;WITH CTE (menuItemID, parentMenuItemID, level) AS (
        SELECT menuItemID, parentMenuItemID, 0 AS level
        FROM menuItems
        WHERE menuItemID = @menuItemID

        UNION ALL

        SELECT m.menuItemID, m.parentMenuItemID, CTE.level - 1 AS level
        FROM menuItems m
        INNER JOIN CTE ON m.menuItemID = CTE.parentMenuItemID
    )

    SELECT TOP 1 @resultLevel = (level * -1) FROM CTE ORDER BY level ASC

    RETURN ISNULL(@resultLevel, 0) --return self if self has no ancestor
END
GO
