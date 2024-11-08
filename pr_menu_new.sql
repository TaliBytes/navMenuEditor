SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[pr_menu_new] (
    @menuName VARCHAR(256),
    @ownerWebsiteID INT,
    @newNavMenuID INT = NULL OUTPUT,
    @errorMessage VARCHAR(256) = NULL OUTPUT
  )
AS 
BEGIN
    SET XACT_ABORT ON
    SET NOCOUNT ON

    DECLARE @checkName VARCHAR(64)
    SELECT @checkName = menuDescription
    FROM menus WHERE menuDescription = @menuName

    IF @checkName IS NOT NULL
    SELECT @errorMessage = 'A menu with this name already exists. Please choose a different name.'


    IF @errorMessage IS NULL
    BEGIN
        INSERT INTO menus (menuDescription, websiteID)
        VALUES (dbo.sqlProtect_xss(@menuName,5), dbo.sqlProtect_xss(@ownerWebsiteID,7))

        SELECT @newNavMenuID = SCOPE_IDENTITY()
    END


    SELECT ISNULL(@errorMessage, NULL), ISNULL(@newNavMenuID, NULL)
END
GO
