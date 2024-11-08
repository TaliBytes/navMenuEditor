SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[pr_menu_edit] (
    @menuID INT,
    @menuName VARCHAR(256),
    @ownerWebsiteID INT
  )
AS 
BEGIN
    SET XACT_ABORT ON
    SET NOCOUNT ON
    
    UPDATE menus
    SET menuDescription = dbo.sqlProtect_xss(@menuName,5), websiteID = dbo.sqlProtect_xss(@ownerWebsiteID,7)
    WHERE menuID = @menuID
  
END
GO
