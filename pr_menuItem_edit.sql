SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[pr_menuItem_edit]
(
	@menuItemID INT,
    @description VARCHAR(64),
    @anLTID TINYINT,
    @anXID INT,
    @anURL VARCHAR(2048),
    @iconURL VARCHAR(2048),
    @errorMessage VARCHAR(256) = NULL OUTPUT
)
AS
BEGIN
    SET XACT_ABORT ON
    SET NOCOUNT ON


    IF @anLTID IS NOT NULL AND @anURL IS NOT NULL
    SELECT @errorMessage = 'Please provide one or the other but not both... URL or LTID/XID (XID optional).'


    IF @description IS NULL
    SELECT @errorMessage = 'A description/title is required for a new menu item.'


    IF @errorMessage IS NULL
    UPDATE menuItems
    SET description = dbo.sqlProtect_xss(@description,5), ltid = dbo.sqlProtect_xss(@anLTID,7), xid = dbo.sqlProtect_xss(@anXID,7), URL = dbo.fn_stripForURL(@anURL), iconURL = dbo.fn_stripForURL(@iconURL)
    WHERE menuItemID = @menuItemID


    SELECT ISNULL(@errorMessage, NULL)
END
GO
