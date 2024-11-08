SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[menus](
	[menuID] [int] IDENTITY(1,1) NOT NULL,
	[menuDescription] [varchar](256) NOT NULL,
	[websiteID] [int] NOT NULL,
 CONSTRAINT [PK_menus] PRIMARY KEY NONCLUSTERED 
(
	[menuID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY],
 CONSTRAINT [UQ_menu_description] UNIQUE NONCLUSTERED 
(
	[menuDescription] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_menuDescriptions] ON [dbo].[menus]
(
	[websiteID] ASC,
	[menuID] ASC
)
INCLUDE([menuDescription]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[menus]  WITH CHECK ADD  CONSTRAINT [FK_menus_websiteID] FOREIGN KEY([websiteID])
REFERENCES [dbo].[websites] ([websiteID])
GO
ALTER TABLE [dbo].[menus] CHECK CONSTRAINT [FK_menus_websiteID]
GO
