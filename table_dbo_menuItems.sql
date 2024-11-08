SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[menuItems](
	[menuID] [int] NOT NULL,
	[menuItemID] [int] IDENTITY(1,1) NOT NULL,
	[parentMenuItemID] [int] NULL,
	[description] [varchar](64) NOT NULL,
	[ltid] [int] NULL,
	[xid] [int] NULL,
	[url] [varchar](2048) NULL,
	[iconURL] [varchar](2048) NULL,
	[menuItemRank] [smallint] NULL,
 CONSTRAINT [PK_menuItems] PRIMARY KEY NONCLUSTERED 
(
	[menuItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [idx_menuItems] ON [dbo].[menuItems]
(
	[menuID] ASC,
	[menuItemID] ASC,
	[parentMenuItemID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[menuItems]  WITH CHECK ADD  CONSTRAINT [FK_menuItems_menuID] FOREIGN KEY([menuID])
REFERENCES [dbo].[menus] ([menuID])
GO
ALTER TABLE [dbo].[menuItems] CHECK CONSTRAINT [FK_menuItems_menuID]
GO
ALTER TABLE [dbo].[menuItems]  WITH CHECK ADD  CONSTRAINT [FK_menuItems_parentMenuItemID] FOREIGN KEY([parentMenuItemID])
REFERENCES [dbo].[menuItems] ([menuItemID])
GO
ALTER TABLE [dbo].[menuItems] CHECK CONSTRAINT [FK_menuItems_parentMenuItemID]
GO
ALTER TABLE [dbo].[menuItems]  WITH CHECK ADD CHECK  (([ltid] IS NOT NULL OR [url] IS NOT NULL))
GO
