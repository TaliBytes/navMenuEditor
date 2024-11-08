SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[pr_menuItem_new]
(
    @menuID INT,
    @parentMenuItemID INT,
    @description VARCHAR(64),
    @anLTID TINYINT,
    @anXID INT,
    @anURL VARCHAR(2048),
    @iconURL VARCHAR(2048),
    @newMenuItemID INT = NULL OUTPUT,
    @errorMessage VARCHAR(256) = NULL OUTPUT
)
AS
BEGIN
    SET XACT_ABORT ON
    SET NOCOUNT ON

    --validate that the parent menu item is actually part of this menu
    IF @parentMenuItemID IS NOT NULL
    BEGIN
        DECLARE @checkParentMenuItemID INT
        SELECT @checkParentMenuItemID = menuItemID
        FROM menuItems
        WHERE menuID = @menuID AND menuItemID = @parentMenuItemID
        
        IF @checkParentMenuItemID IS NULL
        SELECT @errorMessage = 'The parent menu item selected is not part of this menu. Please contact a system administrator if you believe this is in error.'
    END


    --can only have one URL source
    IF @anLTID IS NOT NULL AND @anURL IS NOT NULL
    SELECT @errorMessage = 'Please provide one or the other but not both... URL or LTID/XID (XID optional).'


    IF @description IS NULL
    SELECT @errorMessage = 'A description/title is required for a new menu item.'


    --no errors, can create new menu item
    IF @errorMessage IS NULL
    BEGIN
        DECLARE @menuItemRank INT

        --rank of the new item should be one greater than the previous... this is its default spot.
        --select rank according to parent menu item
        IF @parentMenuItemID IS NOT NULL
        SELECT TOP 1 @menuItemRank = (ISNULL(menuItemRank, 0) + 1)
        FROM menuItems
        WHERE menuID = @menuID AND parentMenuItemID = @parentMenuItemID
        ORDER BY menuItemRank DESC

        IF @parentMenuItemID IS NULL
        SELECT TOP 1 @menuItemRank = (ISNULL(menuItemRank, 0) + 1)
        FROM menuItems
        WHERE menuID = @menuID AND parentMenuItemID IS NULL
        ORDER BY menuItemRank DESC

        INSERT INTO menuItems (menuID, parentMenuItemID, description, ltid, xid, URL, iconURL, menuItemRank)
        VALUES (dbo.sqlProtect_xss(@menuID,7), ISNULL(dbo.sqlProtect_xss(@parentMenuItemID,7), NULL), dbo.sqlProtect_xss(@description, 5), dbo.sqlProtect_xss(@anLTID,7), dbo.sqlProtect_xss(@anXID,7), dbo.fn_stripForURL(@anURL), dbo.fn_stripForURL(@iconURL), ISNULL(@menuItemRank, 1))

        SELECT @newMenuItemID = SCOPE_IDENTITY()
    END


    SELECT ISNULL(@errorMessage, NULL), ISNULL(@newMenuItemID, NULL)
END
GO
