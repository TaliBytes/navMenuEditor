SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE OR ALTER PROCEDURE [dbo].[pr_menuItems_swap] (
    @action VARCHAR (32),
    @toMenuItemID INT,
    @fromMenuItemID INT,
    @errorMessage VARCHAR(256) = NULL OUTPUT
  )
AS 
BEGIN
    SET XACT_ABORT ON
    SET NOCOUNT ON

    IF @action NOT IN ('setToMenuTop', 'setToMenuBottom', 'setParentMenuItem', 'dragSwap')
    SELECT @errorMessage = 'Invalid action passed to procedure. Please contact a system administrator.'

    IF @errorMessage IS NULL
    BEGIN
        DECLARE @menuID INT
        SELECT @menuID = menuID FROM menuItems WHERE menuItemID = @fromMenuItemID   --using fromItem because this is guaranteed to be not null


        --vars needed for certain operations
        DECLARE @targetMenuRank SMALLINT, @hasParent BIT, @parentID INT                         --setToMenuTop, setToMenuBottom 
        DECLARE @bottomMenuItemRank SMALLINT                                                    --setParentMenuItem (@bottomMenuItemRank also used for dragSwap)
        DECLARE @toRank SMALLINT, @fromRank SMALLINT, @toParentID INT, @fromParentID INT        --dragSwap




        --set fromMenuItemID's parentID to toMenuItemID
        IF @action = 'setParentMenuItem'
        BEGIN
            --get lowest rank (bottom of list... larger number = lower down/priority)
            SELECT TOP 1 @bottomMenuItemRank = menuItemRank
            FROM menuItems
            WHERE parentMenuItemID = @toMenuItemID AND menuItemID != @fromMenuItemID AND menuID = @menuID
            ORDER BY menuItemRank DESC

            UPDATE menuItems
            SET parentMenuItemID = dbo.sqlProtect_xss(@toMenuItemID, 7), menuItemRank = (ISNULL(@bottomMenuItemRank, -1) + 1)
            WHERE menuItemID = @fromMenuItemID AND menuID = @menuID
        END




        --move fromMenuItemID to menu root (no parentID) at the top
        ELSE IF @action = 'setToMenuTop'         
        BEGIN
            --if the item is a root item or not determines how it is handled
            SELECT @hasParent = IIF(parentMenuItemID IS NOT NULL, 1, 0)
            FROM menuItems WHERE menuItemID = @fromMenuItemID AND menuID = @menuID

            --does not have a parent item
            IF ISNULL(@hasParent, 0) = 0
            BEGIN
                --store current item's menuRank
                SELECT @targetMenuRank = menuItemRank
                FROM menuItems WHERE menuItemID = @fromMenuItemID AND menuID = @menuID

                --shift all root items, at a lower physical position than target, to one position higher
                UPDATE menuItems SET menuItemRank = (menuItemRank - 1)
                WHERE menuItemRank > @targetMenuRank AND parentMenuItemID IS NULL AND menuID = @menuID

                --shift all root items one position lower
                UPDATE menuItems SET menuItemRank = (menuItemRank + 1)
                WHERE parentMenuItemID IS NULL AND menuID = @menuID

                UPDATE menuItems SET menuItemRank = 1
                WHERE menuItemID = @fromMenuItemID AND menuID = @menuID
            END

            --has a parent item
            IF ISNULL(@hasParent, 0) = 1
            BEGIN
                --get menuItems rank
                SELECT @targetMenuRank = menuItemRank, @parentID = parentMenuItemID
                FROM menuItems WHERE menuItemID = @fromMenuItemID AND menuID = @menuID

                --shift all nested items, at a lower physical position than target, to one position higher
                UPDATE menuItems SET menuItemRank = (menuItemRank - 1)
                WHERE menuItemRank > @targetMenuRank AND parentMenuItemID = @parentID AND menuID = @menuID

                --move menu item to bottom of root elements
                UPDATE menuItems
                SET menuItemRank = (SELECT TOP 1 (menuItemRank + 1) FROM menuItems WHERE parentMenuItemID IS NULL AND menuID = @menuID ORDER BY menuItemRank DESC), parentMenuItemID = NULL
                WHERE menuItemID = @fromMenuItemID AND menuID = @menuID

                --move all root items down one phsyical position
                UPDATE menuItems
                SET menuItemRank = (menuItemRank + 1)
                WHERE parentMenuItemID IS NULL AND menuID = @menuID

                --move menuItem to the top
                UPDATE menuItems
                SET menuItemRank = 1
                WHERE menuItemID = @fromMenuItemID AND menuID = @menuID
            END
        END




        --move fromMenuItemID to menu root (no parentID) at the bottom
        ELSE IF @action = 'setToMenuBottom'      
        BEGIN
            --if the item is a root item or not determines how it is handled
            SELECT @hasParent = IIF(parentMenuItemID IS NOT NULL, 1, 0)
            FROM menuItems WHERE menuItemID = @fromMenuItemID AND menuID = @menuID

            --does not have a parent item
            IF ISNULL(@hasParent, 0) = 0
            BEGIN
                --store current item's menuRank
                SELECT @targetMenuRank = menuItemRank
                FROM menuItems WHERE menuItemID = @fromMenuItemID AND menuID = @menuID

                --shift all root items, at a lower physical position than target, to one position higher
                UPDATE menuItems SET menuItemRank = (menuItemRank - 1)
                WHERE menuItemRank > @targetMenuRank AND parentMenuItemID IS NULL AND menuID = @menuID

                --move target menuItem to bottom physical position
                UPDATE menuItems SET menuItemRank = (SELECT TOP 1 (menuItemRank + 1) FROM menuItems WHERE parentMenuItemID IS NULL AND menuID = @menuID ORDER BY menuItemRank DESC)
                WHERE menuItemID = @fromMenuItemID AND menuID = @menuID
            END

            --has a parent item
            IF ISNULL(@hasParent, 0) = 1
            BEGIN
                --get menuItems rank
                SELECT @targetMenuRank = menuItemRank, @parentID = parentMenuItemID
                FROM menuItems WHERE menuItemID = @fromMenuItemID AND menuID = @menuID

                --shift all nested items, at a lower physical position than target, to one position higher
                UPDATE menuItems SET menuItemRank = (menuItemRank - 1)
                WHERE menuItemRank > @targetMenuRank AND parentMenuItemID = @parentID AND menuID = @menuID

                --move menu item to bottom of root elements
                UPDATE menuItems
                SET menuItemRank = (SELECT TOP 1 (menuItemRank + 1) FROM menuItems WHERE parentMenuItemID IS NULL AND menuID = @menuID ORDER BY menuItemRank DESC), parentMenuItemID = NULL
                WHERE menuItemID = @fromMenuItemID
            END
        END




        --drag-drop swap between fromMenuItemID and toMenuItemID (swap their places)
        ELSE IF @action = 'dragSwap'             
        BEGIN
            IF @toMenuItemID IS NULL OR @fromMenuItemID IS NULL
            SELECT @errorMessage = 'Either the dragged menuItemID or target menuItemID was not provided. Please contact a system administrator'

            IF @errorMessage IS NULL
            BEGIN
                SELECT @toParentID = parentMenuItemID, @toRank = menuItemRank
                FROM menuItems
                WHERE menuItemID = @toMenuItemID AND menuID = @menuID

                --get the important details about the from/dragged item
                SELECT @fromParentID = parentMenuItemID, @fromRank = menuItemRank
                FROM menuItems
                WHERE menuItemID = @fromMenuItemID AND menuID = @menuID

                --swap if they are on the same level
                IF dbo.fn_menuItem_level(@fromMenuItemID) = dbo.fn_menuItem_level(@toMenuItemID)
                BEGIN
                    UPDATE menuItems
                    SET parentMenuItemID = CASE
                        WHEN parentMenuItemID = @toParentID THEN @fromParentID
                        WHEN parentMenuItemID = @fromParentID THEN @toParentID
                        ELSE parentMenuItemID
                    END, menuItemRank = CASE
                        WHEN menuItemRank = @toRank THEN @fromRank
                        WHEN menuItemRank = @fromRank THEN @toRank
                        ELSE menuItemRank
                    END
                    WHERE menuItemID IN (@fromMenuItemID, @toMenuItemID) AND menuID = @menuID
                END

                --if they are different levels, move fromMenuItem to nest under toMenuItem (INSTEAD OF SWAP)
                IF dbo.fn_menuItem_level(@fromMenuItemID) != dbo.fn_menuItem_level(@toMenuItemID)
                BEGIN
                    --get toParentID (where toParentID is current parent of the menuItem)
                    SELECT @toParentID = ISNULL(parentMenuItemID, 0) FROM menuItems WHERE menuItemID = @fromMenuItemID AND menuID = @menuID
 
                    --if they are the same, then this item needs to be moved to bottom of list and all items below it shifted up
                    IF @toParentID = @toMenuItemID
                    BEGIN
                        --get current rank
                        SELECT @targetMenuRank = menuItemRank
                        FROM menuItems WHERE menuItemID = @fromMenuItemID AND menuID = @menuID

                        --shift items up
                        UPDATE menuItems
                        SET menuItemRank = (menuItemRank - 1)
                        WHERE menuItemRank > @targetMenuRank AND parentMenuItemID = @toParentID AND menuID = @menuID

                        SELECT TOP 1 @bottomMenuItemRank = menuItemRank
                        FROM menuItems
                        WHERE parentMenuItemID = @toParentID AND menuItemID != @fromMenuItemID AND menuID = @menuID
                        ORDER BY menuItemRank DESC

                        --move this item to bottom of nested items
                        UPDATE menuItems
                        SET menuItemRank = (ISNULL(@bottomMenuItemRank, -1) + 1)
                        WHERE menuItemID = @fromMenuItemID AND menuID = @menuID
                    END

                    --giving this item a different parent
                    ELSE IF @toParentID != @toMenuItemID
                    BEGIN
                        --get current rank
                        SELECT @targetMenuRank = menuItemRank
                        FROM menuItems WHERE menuItemID = @fromMenuItemID AND menuID = @menuID

                        --shift items up (if this is omitted, the removing a menuItem from a nested list will cause the other items to have "rank gaps" between them)
                        UPDATE menuItems
                        SET menuItemRank = (menuItemRank - 1)
                        WHERE menuItemRank > @targetMenuRank AND parentMenuItemID = @toParentID AND menuID = @menuID

                        --get rank of target's nested items
                        SELECT TOP 1 @bottomMenuItemRank = menuItemRank
                        FROM menuItems
                        WHERE parentMenuItemID = @toMenuItemID AND menuItemID != @fromMenuItemID AND menuID = @menuID
                        ORDER BY menuItemRank DESC

                        --move target item and set new rank at bottom
                        UPDATE menuItems
                        SET parentMenuItemID = @toMenuItemID, menuItemRank = (ISNULL(@bottomMenuItemRank, -1) + 1)
                        WHERE menuItemID = @fromMenuItemID AND menuID = @menuID
                    END
                END
            END
        END
    END




    SELECT ISNULL(@errorMessage, NULL)
END
GO
