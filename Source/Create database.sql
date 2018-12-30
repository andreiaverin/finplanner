USE [FinPlanner]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspCloseFinancialMonth]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspCloseFinancialMonth]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspCalculateBalanceSheetTotals]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[uspCalculateBalanceSheetTotals]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_GoalSet_Goal]') AND parent_object_id = OBJECT_ID(N'[dbo].[GoalSet]'))
ALTER TABLE [dbo].[GoalSet] DROP CONSTRAINT [FK_GoalSet_Goal]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Balance_Account]') AND parent_object_id = OBJECT_ID(N'[dbo].[Balance]'))
ALTER TABLE [dbo].[Balance] DROP CONSTRAINT [FK_Balance_Account]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Account_Document]') AND parent_object_id = OBJECT_ID(N'[dbo].[Account]'))
ALTER TABLE [dbo].[Account] DROP CONSTRAINT [FK_Account_Document]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vGoals]'))
DROP VIEW [dbo].[vGoals]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vBalanceSheet]'))
DROP VIEW [dbo].[vBalanceSheet]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[GoalSet]') AND type in (N'U'))
DROP TABLE [dbo].[GoalSet]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Goal]') AND type in (N'U'))
DROP TABLE [dbo].[Goal]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Document]') AND type in (N'U'))
DROP TABLE [dbo].[Document]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Balance]') AND type in (N'U'))
DROP TABLE [dbo].[Balance]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Account]') AND type in (N'U'))
DROP TABLE [dbo].[Account]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Account](
	[AccountID] [int] IDENTITY(1,1) NOT NULL,
	[DocumentID] [int] NOT NULL,
	[AccountNo] [nvarchar](10) NOT NULL,
	[AccountName] [nvarchar](255) NOT NULL,
	[Parent] [nvarchar](10) NULL,
 CONSTRAINT [PK_Account] PRIMARY KEY CLUSTERED 
(
	[AccountID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Balance](
	[BalanceID] [int] IDENTITY(1,1) NOT NULL,
	[AccountID] [int] NOT NULL,
	[PostingDate] [datetime] NOT NULL,
	[Amount] [float] NOT NULL,
 CONSTRAINT [PK_Balance] PRIMARY KEY CLUSTERED 
(
	[BalanceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Document](
	[DocumentID] [int] IDENTITY(1,1) NOT NULL,
	[DocumentName] [nvarchar](255) NOT NULL,
 CONSTRAINT [PK_Document] PRIMARY KEY CLUSTERED 
(
	[DocumentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Goal](
	[GoalID] [int] IDENTITY(1,1) NOT NULL,
	[GoalName] [nvarchar](255) NULL,
 CONSTRAINT [PK_Goal] PRIMARY KEY CLUSTERED 
(
	[GoalID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GoalSet](
	[GoalSetID] [int] IDENTITY(1,1) NOT NULL,
	[GoalID] [int] NOT NULL,
	[StartDate] [datetime] NOT NULL,
	[EndDate] [datetime] NOT NULL,
	[Description] [nvarchar](255) NOT NULL,
	[Order] [int] NOT NULL,
 CONSTRAINT [PK_GoalSet] PRIMARY KEY CLUSTERED 
(
	[GoalSetID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vBalanceSheet]
AS
SELECT TOP(1000)
	ACC.AccountNo,
	ACC.AccountName,
	ISNULL(BAL.Amount, 0) AS Amount,
	CASE WHEN ACC.[Parent] IS NULL THEN 0 ELSE 
		CASE WHEN PAR.[Parent] IS NULL THEN 1 ELSE 2 END	
	END AS [Level],
	BAL.PostingDate
FROM
	[dbo].[Account] ACC
LEFT JOIN
	[dbo].[Account] PAR
ON
	ACC.Parent = PAR.AccountNo AND ACC.DocumentID = PAR.DocumentID
LEFT JOIN
(
	SELECT
		SRC1.AccountID,
		SRC1.Amount,
		SRC1.PostingDate
	FROM
		[dbo].[Balance] SRC1
	INNER JOIN
	(
		SELECT
			MIN(BalanceID) AS BalanceID,
			MONTH(PostingDate) AS Month,
			YEAR(PostingDate) AS Year,
			AccountID
		FROM
			[dbo].[Balance] 
		GROUP BY
			AccountID, YEAR(PostingDate), MONTH(PostingDate)
	) SRC2
	ON
		SRC1.AccountID = SRC2.AccountID AND SRC1.BalanceID = SRC2.BalanceID
) BAL
ON
	ACC.AccountID = BAL.AccountID
WHERE
	ACC.DocumentID = 1
ORDER BY
	AccountNo
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vGoals]
AS
SELECT TOP (50) 
	[Order] AS [GoalNo], 
	[Description] AS [GoalName], 
	EndDate AS [Due]
FROM
	dbo.GoalSet
ORDER BY
	[Order]
GO
SET IDENTITY_INSERT [dbo].[Account] ON 
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (1, 1, N'1000', N'Assets', NULL)
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (2, 1, N'1010', N'Checking accounts', N'1000')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (5, 1, N'1040', N'Saving accounts', N'1000')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (6, 1, N'1050', N'Money market accounts', N'1000')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (7, 1, N'1060', N'Money market fund accounts', N'1000')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (8, 1, N'1070', N'Certificates of deposit', N'1000')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (9, 1, N'1080', N'Treasury bills', N'1000')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (10, 1, N'1090', N'Cash value of life insurance', N'1000')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (11, 1, N'1100', N'Total', N'1000')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (12, 1, N'1110', N'Investments', NULL)
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (13, 1, N'1120', N'Stocks', N'1110')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (14, 1, N'1130', N'Bonds', N'1110')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (15, 1, N'1140', N'Mutual fund investments', N'1110')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (16, 1, N'1150', N'Partnership interests', N'1110')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (17, 1, N'1160', N'Other investments', N'1110')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (18, 1, N'1170', N'Total', N'1110')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (19, 1, N'1180', N'Retirement funds', NULL)
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (20, 1, N'1190', N'Pension (present lump-sum value)', N'1180')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (21, 1, N'1200', N'Individual retirement account', N'1180')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (22, 1, N'1210', N'Employee saving plan', N'1180')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (23, 1, N'1220', N'Total', N'1180')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (24, 1, N'1230', N'Personal assets', NULL)
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (25, 1, N'1240', N'Principal residence', N'1230')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (26, 1, N'1250', N'Second residence', N'1230')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (27, 1, N'1260', N'Collectibles/art/antiques', N'1230')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (28, 1, N'1270', N'Automobiles', N'1230')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (29, 1, N'1280', N'Home furnishings', N'1230')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (30, 1, N'1290', N'Furs and jewelry', N'1230')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (31, 1, N'1300', N'Other assets', N'1230')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (32, 1, N'1310', N'Total', N'1230')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (33, 1, N'1320', N'Total assets', NULL)
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (34, 1, N'1330', N'Liabilities', NULL)
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (35, 1, N'1340', N'Charge account balances', N'1330')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (36, 1, N'1350', N'Personal loans', N'1330')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (37, 1, N'1360', N'Student loans', N'1330')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (38, 1, N'1370', N'Auto loans', N'1330')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (39, 1, N'1380', N'401(k) loans', N'1330')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (40, 1, N'1390', N'Investment loans (margin, real estate, etc.)', N'1330')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (41, 1, N'1400', N'Home mortgages', N'1330')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (42, 1, N'1410', N'Home equity loans', N'1330')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (43, 1, N'1420', N'Alimony', N'1330')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (44, 1, N'1430', N'Child support', N'1330')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (45, 1, N'1440', N'Life insurance policy loans', N'1330')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (46, 1, N'1450', N'Projected income tax liablity', N'1330')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (47, 1, N'1460', N'Other liabilities', N'1330')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (48, 1, N'1470', N'Total liabilities', N'1330')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (49, 1, N'1480', N'Net worth', NULL)
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (50, 2, N'1490', N'Income', NULL)
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (51, 2, N'1500', N'Salary', N'1490')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (52, 2, N'1510', N'Bonuses', N'1490')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (53, 2, N'1520', N'Self-employment income', N'1490')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (54, 2, N'1530', N'Dividens', N'1490')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (55, 2, N'1540', N'Capital gains', N'1490')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (56, 2, N'1550', N'Interest', N'1490')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (57, 2, N'1560', N'Net rents and royalties', N'1490')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (58, 2, N'1570', N'Social Security', N'1490')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (59, 2, N'1580', N'Pension distributions from trusts or partnerships', N'1490')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (60, 2, N'1590', N'Other income', N'1490')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (61, 2, N'1600', N'Total cash available', N'1490')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (62, 2, N'1610', N'Expenses', NULL)
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (63, 2, N'1620', N'Home mortgage (or apartment rent)', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (64, 2, N'1630', N'Utility payments', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (65, 2, N'1640', N'Gas/oil', N'1630')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (66, 2, N'1650', N'Electricity', N'1630')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (67, 2, N'1660', N'Water', N'1630')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (68, 2, N'1670', N'Sewer', N'1630')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (69, 2, N'1680', N'Home maintenance', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (70, 2, N'1690', N'Property taxes', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (71, 2, N'1700', N'Car payments', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (72, 2, N'1710', N'Car/commuting expenses', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (73, 2, N'1720', N'Maintenance and repairs', N'1710')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (74, 2, N'1730', N'Gas', N'1710')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (75, 2, N'1740', N'Commuting fees/tolls', N'1710')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (76, 2, N'1750', N'Credit card/loan payments', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (77, 2, N'1760', N'Insurance premiums', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (78, 2, N'1770', N'Life', N'1760')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (79, 2, N'1780', N'Health', N'1760')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (80, 2, N'1790', N'Disability', N'1760')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (81, 2, N'1800', N'Car', N'1760')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (82, 2, N'1810', N'Home', N'1760')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (83, 2, N'1820', N'Liability', N'1760')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (84, 2, N'1830', N'Other', N'1760')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (85, 2, N'1840', N'Income taxes', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (86, 2, N'1850', N'Employment taxes', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (87, 2, N'1860', N'Clothing', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (88, 2, N'1870', N'Child care', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (89, 2, N'1880', N'Food', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (90, 2, N'1890', N'Medical expenses', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (91, 2, N'1900', N'Education', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (92, 2, N'1910', N'Vacations', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (93, 2, N'1920', N'Entertainment', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (94, 2, N'1930', N'Alimony', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (95, 2, N'1940', N'Charitable contributions', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (96, 2, N'1950', N'Gifts', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (97, 2, N'1960', N'Personal items', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (98, 2, N'1970', N'Savings/investments', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (99, 2, N'1980', N'Vacation fund', N'1970')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (100, 2, N'1990', N'Emergency fund', N'1970')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (101, 2, N'2000', N'Investment fund', N'1970')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (102, 2, N'2010', N'Other', N'1970')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (103, 2, N'2020', N'Other payments', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (104, 2, N'2030', N'Total expenses', N'1610')
GO
INSERT [dbo].[Account] ([AccountID], [DocumentID], [AccountNo], [AccountName], [Parent]) VALUES (105, 2, N'2040', N'Net cash', NULL)
GO
SET IDENTITY_INSERT [dbo].[Account] OFF
GO
SET IDENTITY_INSERT [dbo].[Document] ON 
GO
INSERT [dbo].[Document] ([DocumentID], [DocumentName]) VALUES (1, N'Balance Sheet')
GO
INSERT [dbo].[Document] ([DocumentID], [DocumentName]) VALUES (2, N'Cash Flow Statement')
GO
SET IDENTITY_INSERT [dbo].[Document] OFF
GO
SET IDENTITY_INSERT [dbo].[Goal] ON 
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (1, N'Get a new qualification/education')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (2, N'Change of employment')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (3, N'Financial independence')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (4, N'Be protected against inflation')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (5, N'Diversify investment portfolio')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (6, N'Start a business')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (7, N'Fund a buy–sell agreement')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (8, N'Take early retirement')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (9, N'Adequate retirement income')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (10, N'Buy a retirement home')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (11, N'Large purchase (e.g., car, boat, plane, art)')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (12, N'Minimize income tax')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (13, N'Start savings plan')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (14, N'Acquire emergency fund (6 months'' expenses)')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (15, N'Acquire term life insurance')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (16, N'Convert term life insurance policy to cash-value policy')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (17, N'Contribute maximum to IRA')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (18, N'Acquire disability insurance')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (19, N'Adequate disability income')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (20, N'Provide for survivor in event of my death')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (21, N'Have children')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (22, N'Buy a vacation home')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (23, N'Make home improvements')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (24, N'Take a dream vacation')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (25, N'Reduce debt')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (26, N'Pay off credit card or consumer debt')
GO
INSERT [dbo].[Goal] ([GoalID], [GoalName]) VALUES (27, N'Increase level of charitable giving')
GO
SET IDENTITY_INSERT [dbo].[Goal] OFF
GO
ALTER TABLE [dbo].[Account]  WITH CHECK ADD  CONSTRAINT [FK_Account_Document] FOREIGN KEY([DocumentID])
REFERENCES [dbo].[Document] ([DocumentID])
GO
ALTER TABLE [dbo].[Account] CHECK CONSTRAINT [FK_Account_Document]
GO
ALTER TABLE [dbo].[Balance]  WITH CHECK ADD  CONSTRAINT [FK_Balance_Account] FOREIGN KEY([AccountID])
REFERENCES [dbo].[Account] ([AccountID])
GO
ALTER TABLE [dbo].[Balance] CHECK CONSTRAINT [FK_Balance_Account]
GO
ALTER TABLE [dbo].[GoalSet]  WITH CHECK ADD  CONSTRAINT [FK_GoalSet_Goal] FOREIGN KEY([GoalID])
REFERENCES [dbo].[Goal] ([GoalID])
GO
ALTER TABLE [dbo].[GoalSet] CHECK CONSTRAINT [FK_GoalSet_Goal]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Andrei Averin
-- Create date: 26.12.2018
-- Description:	Calculates all totals in the balance sheet
-- =============================================
CREATE PROCEDURE [dbo].[uspCalculateBalanceSheetTotals]
	@monthSelector date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @BalanceValues TABLE 
	( 
		AccountID INT NOT NULL,
		AccountNo NVARCHAR(10) NOT NULL,
		Amount FLOAT
	);

	INSERT INTO @BalanceValues
	SELECT
		SRC1.AccountID,
		ACC.AccountNo,
		SRC1.Amount
	FROM
		[dbo].[Balance] SRC1
	INNER JOIN
	(
		SELECT
			MAX(BalanceID) AS BalanceID,
			AccountID
		FROM
			[dbo].[Balance]
		WHERE
			YEAR([PostingDate]) = YEAR(@monthSelector) AND
			MONTH([PostingDate]) = MONTH(@monthSelector) 
		GROUP BY
			AccountID
	) SRC2
	ON
		SRC1.AccountID = SRC2.AccountID AND SRC1.BalanceID = SRC2.BalanceID
	INNER JOIN
		[dbo].[Account] ACC
	ON
		ACC.AccountID = SRC1.AccountID
	WHERE
		ACC.DocumentID = 1;

	-- Calculate asset total
	UPDATE DST
	SET DST.Amount = SRC.Amount
	FROM @BalanceValues DST
	INNER JOIN
	(
		SELECT SUM(Amount) Amount
		FROM @BalanceValues
		WHERE AccountNo IN ('1010','1040','1050','1060','1070','1080','1090')
	) SRC
	ON (1=1)
	WHERE DST.AccountNo = '1100';
	
	-- Calculate investment total
	UPDATE DST
	SET DST.Amount = SRC.Amount
	FROM @BalanceValues DST
	INNER JOIN
	(
		SELECT SUM(Amount) Amount
		FROM @BalanceValues
		WHERE AccountNo IN ('1120','1130','1140','1150','1160')
	) SRC
	ON (1=1)
	WHERE DST.AccountNo = '1170';

	-- Calculate retirement total
	UPDATE DST
	SET DST.Amount = SRC.Amount
	FROM @BalanceValues DST
	INNER JOIN
	(
		SELECT SUM(Amount) Amount
		FROM @BalanceValues
		WHERE AccountNo IN ('1190','1200','1210')
	) SRC
	ON (1=1)
	WHERE DST.AccountNo = '1220';

	-- Calculate personal asset total
	UPDATE DST
	SET DST.Amount = SRC.Amount
	FROM @BalanceValues DST
	INNER JOIN
	(
		SELECT SUM(Amount) Amount
		FROM @BalanceValues
		WHERE AccountNo IN ('1240','1250','1260','1270','1280','1290','1300')
	) SRC
	ON (1=1)
	WHERE DST.AccountNo = '1310';

	-- Calculate asset total
	UPDATE DST
	SET DST.Amount = SRC.Amount
	FROM @BalanceValues DST
	INNER JOIN
	(
		SELECT SUM(Amount) Amount
		FROM @BalanceValues
		WHERE AccountNo IN ('1100','1170','1220','1310')
	) SRC
	ON (1=1)
	WHERE DST.AccountNo = '1320';
	
	-- Calculate liability total
	UPDATE DST
	SET DST.Amount = SRC.Amount
	FROM @BalanceValues DST
	INNER JOIN
	(
		SELECT SUM(Amount) Amount
		FROM @BalanceValues
		WHERE AccountNo IN ('1340','1350','1360','1370','1380','1390','1400','1410','1420','1430','1440','1450','1460')
	) SRC
	ON (1=1)
	WHERE DST.AccountNo = '1470';
	
	-- Calculate net worth
	UPDATE @BalanceValues
	SET Amount = 
		(SELECT TOP(1) Amount FROM @BalanceValues WHERE AccountNo = '1320') -
		(SELECT TOP(1) Amount FROM @BalanceValues WHERE AccountNo = '1470')
	FROM @BalanceValues
	WHERE AccountNo = '1480';

	UPDATE DST
	SET DST.Amount = SRC.Amount
	FROM
		 [dbo].[Balance] DST
	INNER JOIN
	(
		SELECT
			MAX(BalanceID) AS BalanceID,
			AccountID
		FROM
			[dbo].[Balance]
		GROUP BY
			AccountID
	) REF
	ON
		DST.BalanceID = REF.BalanceID AND DST.AccountID = REF.AccountID 
	INNER JOIN
		@BalanceValues SRC
	ON
		SRC.AccountID = REF.AccountID;

END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		Andrei Averin
-- Create date: 28.12.2018
-- Description:	Close the financial month
-- =============================================
CREATE PROCEDURE [dbo].[uspCloseFinancialMonth]
	@monthSelector date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Create cashflow balance records for the new current month
	INSERT INTO [dbo].[Balance]
           ([AccountID]
           ,[PostingDate]
           ,[Amount])
	SELECT 
		   [AccountID]
		  ,DATEADD(month, DATEDIFF(month, 0, CURRENT_TIMESTAMP), 0)  AS [PostingDate]
		  ,0 AS [Amount]
	FROM 
		[dbo].[Account]
	WHERE
		[DocumentID] = 1;

END
GO
