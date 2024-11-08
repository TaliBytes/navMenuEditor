SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[pr_menuItem_delete]
(
    @menuID INT,
	@menuItemID INT,
    @errorMessage VARCHAR(256) = NULL OUTPUT
)
AS
BEGIN
    SET XACT_ABORT ON
    SET NOCOUNT ON

    DECLARE @temp TABLE (menuItemID INT)

    DECLARE @checkMenuID INT
    SELECT @checkMenuID = menuID FROM menuItems WHERE menuItemID = @menuItemID AND menuID = @menuID


    IF @checkMenuID IS NOT NULL
    BEGIN
        --get this menu item and descendants
        ;WITH CTE (menuItemID, parentMenuItemID, description, level) AS (
            SELECT      menuItemID, parentMenuItemID, description, 0 AS level
            FROM        menuItems
            WHERE       menuID = @menuID AND menuItemID = ISNULL(@menuItemID, 0)

            UNION ALL

            SELECT      c2.menuItemID, c2.parentMenuItemID, c2.description, CTE.level + 1
            FROM        menuItems c2 
            INNER JOIN  CTE ON CTE.menuItemID = c2.parentMenuItemID
        )


        --store in correct order
        INSERT INTO @temp
        SELECT menuItemID FROM CTE ORDER BY level DESC

        --delete items
        DELETE FROM menuItems
        WHERE menuItemID IN (SELECT menuItemID FROM @temp)
    END


    IF @checkMenuID IS NULL
    SELECT @errorMessage = 'This menu item is not part of this menu. Please contact a system administrator if you believe this is in error.'


    SELECT ISNULL(@errorMessage, NULL)
END
GO
