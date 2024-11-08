SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER FUNCTION [dbo].[tb_menuItems_full] (
    @menuID INT
   )

   /* returns all menu items in a menu regardless of access rights (used in ecreport_navMenus */

RETURNS @aTable TABLE (menuItemID INT, parentMenuItemID INT, description VARCHAR(MAX), LTID TINYINT, XID INT, url VARCHAR(2048), iconURL VARCHAR(2048), level INT, sortBy FLOAT)
AS
BEGIN

    ;WITH tree (menuItemID, parentMenuItemID, description, LTID, XID, URL, iconURL, level, sortBy) AS (
        SELECT      menuItemID, parentMenuItemID, description, LTID, XID, ISNULL(URL, CONCAT('/console?ltid=', LTID, IIF(XID IS NOT NULL, CONCAT('&xid=', XID), ''))) AS URL, ISNULL(iconURL, dbo.fn_linkedTableIcon(LTID)) AS iconURL, 0 AS level, CAST(ROW_NUMBER() OVER (ORDER BY ISNULL(menuItemRank,10), menuItemID) AS FLOAT)
        FROM        menuItems
        WHERE       menuID = @menuID and parentMenuItemID IS NULL

        UNION ALL

        SELECT      c2.menuItemID, c2.parentMenuItemID, c2.description, c2.LTID, c2.XID, ISNULL(c2.URL, CONCAT('/console?ltid=', c2.LTID, IIF(c2.XID IS NOT NULL, CONCAT('&xid=', c2.XID), ''))) AS URL, ISNULL(c2.iconURL, dbo.fn_linkedTableIcon(c2.LTID)) AS iconURL, tree.level + 1,1/POWER(CAST(ROW_NUMBER() OVER (ORDER BY ISNULL(c2.menuItemRank, 10) desc, c2.menuItemID desc) AS FLOAT)*100,tree.level+1) + tree.SortBy
        FROM        menuItems c2 
        INNER JOIN  tree ON tree.menuItemID = c2.parentMenuItemID
    )

    INSERT INTO @aTable
    SELECT TOP(99999) menuItemID, parentMenuItemID, description, LTID, XID, url, iconURL, level, sortBy FROM tree ORDER BY sortBy

    RETURN
END
GO
