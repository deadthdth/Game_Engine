IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'game')
CREATE USER [game] FOR LOGIN [game] WITH DEFAULT_SCHEMA=[game]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fnGetMax]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

/* 최대값 구하는 함수 */
CREATE  FUNCTION [fnGetMax]
	(@n1 int, 
	 @n2 int)
RETURNS int
AS
BEGIN
RETURN (CASE WHEN @n1 > @n2 THEN @n1 ELSE @n2 END)
END


' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[fnGetMin]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'

/* 최소값 구하는 함수 */
CREATE  FUNCTION [fnGetMin]
	(@n1 int, 
	 @n2 int)
RETURNS int
AS
BEGIN
RETURN (CASE WHEN @n1 < @n2 THEN @n1 ELSE @n2 END)
END


' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[inet_aton]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
BEGIN
execute dbo.sp_executesql @statement = N'
CREATE FUNCTION [inet_aton] (@IP VARCHAR(15))
RETURNS BIGINT
AS
BEGIN
	DECLARE @A BIGINT, @B BIGINT, @C BIGINT, @D BIGINT
	DECLARE @iBegin INT, @iEnd INT
	
	SELECT @iBegin=1
	SELECT @iEnd=CHARINDEX(''.'', @IP)
	SELECT @A=CAST(SUBSTRING(@IP, @iBegin, @iEnd-@iBegin) AS BIGINT)
	
	SELECT @iBegin=@iEnd+1
	SELECT @iEnd=CHARINDEX(''.'', @IP, @iBegin)
	SELECT @B=CAST(SUBSTRING(@IP, @iBegin, @iEnd-@iBegin) AS BIGINT)
	
	SELECT @iBegin=@iEnd+1
	SELECT @iEnd=CHARINDEX(''.'', @IP, @iBegin)
	SELECT @C=CAST(SUBSTRING(@IP, @iBegin, @iEnd-@iBegin) AS BIGINT)
	
	SELECT @iBegin=@iEnd+1
	SELECT @iEnd=CHARINDEX(''.'', @IP, @iBegin)
	SELECT @D=CAST(SUBSTRING(@IP, @iBegin, 15) AS BIGINT)
	
	DECLARE @IPNumber BIGINT
	SELECT @IPNumber=@A*16777216+@B*65536+@C*256+@D
	
	RETURN @IPNumber
END

' 
END

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CashSetShop]') AND type in (N'U'))
BEGIN
CREATE TABLE [CashSetShop](
	[CSSID] [int] NOT NULL,
	[Name] [varchar](64) NULL,
	[Description] [varchar](1024) NULL,
	[CashPrice] [int] NOT NULL,
	[WebImgName] [varchar](64) NULL,
	[NewItemOrder] [tinyint] NULL,
	[ResSex] [tinyint] NULL,
	[ResLevel] [int] NULL,
	[Weight] [int] NULL,
	[Opened] [tinyint] NULL,
	[RegDate] [datetime] NULL,
	[RentType] [tinyint] NULL,
 CONSTRAINT [CashSetShop_PK] PRIMARY KEY CLUSTERED 
(
	[CSSID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Account]') AND type in (N'U'))
BEGIN
CREATE TABLE [Account](
	[AID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](20) NOT NULL,
	[UGradeID] [int] NOT NULL,
	[PGradeID] [int] NOT NULL,
	[RegDate] [datetime] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Email] [varchar](50) NULL,
	[RegNum] [varchar](50) NULL,
	[Age] [smallint] NULL,
	[Sex] [tinyint] NULL,
	[ZipCode] [varchar](50) NULL,
	[Address] [varchar](256) NULL,
	[Country] [varchar](50) NULL,
	[LastCID] [int] NULL,
	[Cert] [tinyint] NULL,
	[HackingType] [tinyint] NULL,
	[HackingRegTime] [smalldatetime] NULL,
	[EndHackingBlockTime] [smalldatetime] NULL,
	[LastLoginTime] [smalldatetime] NULL,
	[ServerID] [tinyint] NULL,
	[LastLogoutTime] [smalldatetime] NULL,
 CONSTRAINT [Account_PK] PRIMARY KEY CLUSTERED 
(
	[AID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AccountPenaltyLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [AccountPenaltyLog](
	[PenaltyLogID] [int] IDENTITY(1,1) NOT NULL,
	[AID] [int] NULL,
	[UGradeID] [int] NULL,
	[DayLeft] [int] NULL,
	[RegDate] [smalldatetime] NULL,
	[GMID] [varchar](20) NULL,
PRIMARY KEY NONCLUSTERED 
(
	[PenaltyLogID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetHourMaxPlayerCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE proc [spGetHourMaxPlayerCount] 
 @begin smalldatetime
, @end smalldatetime
as
 set nocount on

 if 0 <> datediff(dd, @begin, @end) return

 select t.hour, max(t.playercount) as maxplayercount
 from
 (
  select datepart(hh, time) as hour, sum(playercount) as playercount
  from logdb.game.serverlogstorage(nolock)
  where time >= @begin and time <= @end
  group by time
 ) as t
 group by t.hour
 order by t.hour

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[BillingMethod]') AND type in (N'U'))
BEGIN
CREATE TABLE [BillingMethod](
	[BillingMethodID] [int] NOT NULL,
	[Name] [varchar](256) NOT NULL,
 CONSTRAINT [BillingMethod_PK] PRIMARY KEY CLUSTERED 
(
	[BillingMethodID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[BlockCountryCode]') AND type in (N'U'))
BEGIN
CREATE TABLE [BlockCountryCode](
	[CountryCode3] [char](3) NOT NULL,
	[RoutingURL] [varchar](64) NULL,
	[IsBlock] [tinyint] NULL CONSTRAINT [DF__BlockCoun__IsBlo__0E04126B]  DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[CountryCode3] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetLadderTeamMemberByCID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 팀멤버 얻어오기
CREATE PROC [spGetLadderTeamMemberByCID]
	@CID		int
AS
RETURN


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CashShopNewItem]') AND type in (N'U'))
BEGIN
CREATE TABLE [CashShopNewItem](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Category] [varchar](32) NOT NULL,
	[NewOrder] [int] NOT NULL,
	[IsSetItem] [int] NOT NULL,
	[CSID] [int] NULL,
	[CSSID] [int] NULL,
	[Slot] [varchar](32) NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[ResSex] [int] NOT NULL,
	[ResLevel] [int] NOT NULL,
	[CashPrice] [int] NOT NULL,
	[WebImgName] [varchar](64) NULL,
	[RegDate] [datetime] NOT NULL CONSTRAINT [DF__CashShopN__RegDa__2D67AF2B]  DEFAULT (getdate())
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CashShopNewItemCategory]') AND type in (N'U'))
BEGIN
CREATE TABLE [CashShopNewItemCategory](
	[CategoryID] [int] NOT NULL,
	[Description] [varchar](12) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Description] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CashShopRank]') AND type in (N'U'))
BEGIN
CREATE TABLE [CashShopRank](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Rank] [int] NOT NULL,
	[Category] [varchar](32) NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[Count] [int] NOT NULL,
	[CSID] [int] NULL,
	[CSSID] [int] NULL,
	[Slot] [varchar](32) NOT NULL,
	[ResSex] [int] NOT NULL,
	[ResLevel] [int] NOT NULL,
	[CashPrice] [int] NOT NULL,
	[RegDate] [datetime] NOT NULL CONSTRAINT [DF__CashShopR__RegDa__1C3D2329]  DEFAULT (getdate()),
 CONSTRAINT [pk_CashShopRank_id] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CharacterMakingLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [CharacterMakingLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[AID] [int] NULL,
	[CharName] [varchar](32) NULL,
	[Type] [varchar](20) NULL,
	[Date] [datetime] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CharacterMgrType]') AND type in (N'U'))
BEGIN
CREATE TABLE [CharacterMgrType](
	[CharMgrTypeID] [tinyint] NOT NULL,
	[Description] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[CharMgrTypeID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ClanAdsBoard]') AND type in (N'U'))
BEGIN
CREATE TABLE [ClanAdsBoard](
	[Seq] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](20) NOT NULL,
	[Subject] [varchar](50) NOT NULL,
	[RegDate] [smalldatetime] NOT NULL,
	[ReadCount] [int] NOT NULL CONSTRAINT [DF__ClanAdsBo__ReadC__2D7CBDC4]  DEFAULT ((0)),
	[Recommend] [int] NULL CONSTRAINT [DF__ClanAdsBo__Recom__2E70E1FD]  DEFAULT ((0)),
	[Content] [varchar](2000) NOT NULL,
	[FileName] [varchar](128) NULL,
	[Link] [varchar](255) NULL,
	[HTML] [smallint] NOT NULL CONSTRAINT [DF__ClanAdsBoa__HTML__2F650636]  DEFAULT ((0)),
	[CommentCount] [int] NOT NULL CONSTRAINT [DF__ClanAdsBo__Comme__30592A6F]  DEFAULT ((0)),
	[GR_ID] [int] NOT NULL CONSTRAINT [DF__ClanAdsBo__GR_ID__314D4EA8]  DEFAULT ((0)),
	[GR_Depth] [int] NOT NULL CONSTRAINT [DF__ClanAdsBo__GR_De__324172E1]  DEFAULT ((0)),
	[GR_Pos] [int] NOT NULL CONSTRAINT [DF__ClanAdsBo__GR_Po__3335971A]  DEFAULT ((0)),
	[Thread] [int] NOT NULL CONSTRAINT [DF__ClanAdsBo__Threa__3429BB53]  DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[Seq] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ClanAdsComment]') AND type in (N'U'))
BEGIN
CREATE TABLE [ClanAdsComment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Seq] [int] NOT NULL,
	[UserID] [varchar](20) NOT NULL,
	[RegDate] [smalldatetime] NOT NULL,
	[Content] [varchar](500) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ClanBoard]') AND type in (N'U'))
BEGIN
CREATE TABLE [ClanBoard](
	[Seq] [int] IDENTITY(1,1) NOT NULL,
	[CLID] [int] NOT NULL,
	[UserID] [varchar](20) NOT NULL,
	[Subject] [varchar](50) NOT NULL,
	[RegDate] [smalldatetime] NOT NULL,
	[ReadCount] [int] NOT NULL CONSTRAINT [DF__ClanBoard__ReadC__45544755]  DEFAULT ((0)),
	[Recommend] [int] NULL CONSTRAINT [DF__ClanBoard__Recom__46486B8E]  DEFAULT ((0)),
	[Content] [varchar](4000) NOT NULL,
	[FileName] [varchar](128) NULL,
	[Link] [varchar](255) NULL,
	[HTML] [smallint] NOT NULL CONSTRAINT [DF__ClanBoard__HTML__473C8FC7]  DEFAULT ((0)),
	[CommentCount] [int] NOT NULL CONSTRAINT [DF__ClanBoard__Comme__4830B400]  DEFAULT ((0)),
	[GR_ID] [int] NOT NULL CONSTRAINT [DF__ClanBoard__GR_ID__4924D839]  DEFAULT ((0)),
	[GR_Depth] [int] NOT NULL CONSTRAINT [DF__ClanBoard__GR_De__4A18FC72]  DEFAULT ((0)),
	[GR_Pos] [int] NOT NULL CONSTRAINT [DF__ClanBoard__GR_Po__4B0D20AB]  DEFAULT ((0)),
	[Thread] [int] NOT NULL CONSTRAINT [DF__ClanBoard__Threa__4C0144E4]  DEFAULT ((0)),
PRIMARY KEY CLUSTERED 
(
	[Seq] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ClanBoardComment]') AND type in (N'U'))
BEGIN
CREATE TABLE [ClanBoardComment](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Seq] [int] NOT NULL,
	[UserID] [varchar](20) NOT NULL,
	[RegDate] [smalldatetime] NOT NULL,
	[Content] [varchar](500) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ClanMemberGrade]') AND type in (N'U'))
BEGIN
CREATE TABLE [ClanMemberGrade](
	[GradeID] [int] NOT NULL,
	[Grade] [varchar](24) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[GradeID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CountryCode]') AND type in (N'U'))
BEGIN
CREATE TABLE [CountryCode](
	[CountryCode3] [char](3) NOT NULL,
	[CountryName] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[CountryCode3] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CustomIP]') AND type in (N'U'))
BEGIN
CREATE TABLE [CustomIP](
	[IPFrom] [bigint] NOT NULL,
	[IPTo] [bigint] NOT NULL,
	[IsBlock] [tinyint] NOT NULL,
	[CountryCode3] [char](3) NOT NULL,
	[Comment] [varchar](128) NULL,
	[RegDate] [smalldatetime] NULL,
UNIQUE NONCLUSTERED 
(
	[IPFrom] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[IPTo] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[DayRanking]') AND type in (N'U'))
BEGIN
CREATE TABLE [DayRanking](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](24) NOT NULL,
	[Level] [smallint] NOT NULL,
	[Point] [int] NULL,
	[Rank] [int] NULL,
 CONSTRAINT [PK_DayRanking_ID] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertConnLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spInsertConnLog] 
 @AID int
, @IPPart1 tinyint
, @IPPart2 tinyint
, @IPPart3 tinyint
, @IPPart4 tinyint
, @CountryCode3	char(3)
AS
 SET NOCOUNT ON
 INSERT INTO LogDB.game.ConnLog( AID, Time, IPPart1, IPPart2, IPPart3, IPPart4, CountryCode3)
 VALUES (@AID, GETDATE(), @IPPart1, @IPPart2, @IPPart3, @IPPart4, @CountryCode3)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Effect]') AND type in (N'U'))
BEGIN
CREATE TABLE [Effect](
	[ID] [int] NOT NULL,
	[Name] [varchar](32) NOT NULL,
	[Area] [int] NULL,
	[Time] [int] NULL,
	[ModHP] [int] NULL,
	[ModAP] [int] NULL,
	[ModMaxWT] [int] NULL,
	[ModSF] [int] NULL,
	[ModFR] [int] NULL,
	[ModCR] [int] NULL,
	[ModPR] [int] NULL,
	[ModLR] [int] NULL,
	[ResAP] [int] NULL,
	[ResFR] [int] NULL,
	[ResCR] [int] NULL,
	[ResPR] [int] NULL,
	[ResLR] [int] NULL,
	[Stun] [int] NULL,
	[KnockBack] [int] NULL,
	[Smoke] [int] NULL,
	[Flash] [int] NULL,
	[Tear] [int] NULL,
	[Flame] [int] NULL,
 CONSTRAINT [Effect_PK] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Event]') AND type in (N'U'))
BEGIN
CREATE TABLE [Event](
	[AID] [int] NOT NULL,
	[CID] [int] NOT NULL,
	[RegDate] [smalldatetime] NOT NULL,
	[Checked] [bit] NULL,
	[EventName] [varchar](24) NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Event_ClanPointRanking]') AND type in (N'U'))
BEGIN
CREATE TABLE [Event_ClanPointRanking](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Rank] [int] NOT NULL,
	[CLID] [int] NOT NULL,
	[Name] [varchar](24) NOT NULL,
	[Count] [int] NOT NULL,
	[Point] [int] NOT NULL,
	[RegDate] [datetime] NOT NULL CONSTRAINT [DF__Event_Cla__RegDa__49CEE3AF]  DEFAULT (getdate())
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[GameLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [GameLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[GameName] [varchar](64) NULL,
	[MasterCID] [int] NULL,
	[Map] [varchar](32) NULL,
	[GameType] [varchar](24) NULL,
	[Round] [int] NULL,
	[StartTime] [datetime] NOT NULL,
	[PlayerCount] [tinyint] NULL,
	[Players] [varchar](1000) NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[GameType]') AND type in (N'U'))
BEGIN
CREATE TABLE [GameType](
	[GameTypeID] [int] NOT NULL,
	[Name] [varchar](256) NULL,
 CONSTRAINT [GameType_PK] PRIMARY KEY CLUSTERED 
(
	[GameTypeID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertLocatorLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE  PROC [spInsertLocatorLog]  
 @LocatorID int  
, @CountryCode3 varchar(3)  
, @Count int   
AS  
 SET NOCOUNT ON   
 INSERT INTO LogDB.game.LocatorLog(LocatorID, CountryCode3, Count, RegDate)  
 VALUES (@LocatorID, @CountryCode3, @Count, GETDATE())  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[IPtoCountry]') AND type in (N'U'))
BEGIN
CREATE TABLE [IPtoCountry](
	[IPFrom] [varchar](8000) NULL,
	[IPTo] [varchar](8000) NULL,
	[CountryCode2] [varchar](8000) NULL,
	[CountryCode3] [varchar](8000) NULL,
	[CountryName] [varchar](8000) NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[IPtoCountryOld060612]') AND type in (N'U'))
BEGIN
CREATE TABLE [IPtoCountryOld060612](
	[IPFrom] [numeric](18, 0) NOT NULL,
	[IPTo] [numeric](18, 0) NOT NULL,
	[CountryCode2] [char](2) NOT NULL,
	[CountryCode3] [char](3) NOT NULL,
	[CountryName] [varchar](50) NOT NULL,
 CONSTRAINT [PK_IPtoCountry_IPRange] PRIMARY KEY CLUSTERED 
(
	[IPFrom] ASC,
	[IPTo] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ItemSlotType]') AND type in (N'U'))
BEGIN
CREATE TABLE [ItemSlotType](
	[SlotType] [int] NOT NULL,
	[Description] [varchar](24) NULL,
	[Category] [varchar](24) NULL,
PRIMARY KEY CLUSTERED 
(
	[SlotType] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[LevelUpLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [LevelUpLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[CID] [int] NULL,
	[Level] [smallint] NULL,
	[BP] [int] NULL,
	[KillCount] [int] NULL,
	[DeathCount] [int] NULL,
	[PlayTime] [int] NULL,
	[Date] [datetime] NULL,
 CONSTRAINT [LevelUpLog_PK_20050310] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spLeague_FetchLeagueInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [spLeague_FetchLeagueInfo]
AS
	RETURN

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetCustomIP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetCustomIP]  
 @RegDateFrom smalldatetime  
, @RegDateTo smalldatetime  
AS  
 SET NOCOUNT ON  
 DECLARE @TmpIP bigint  
  
 SET @RegDateTo = DATEADD( dd, 1, @RegDateTo )  
  
 SELECT GunzDB.game.inet_ntoa(IPFrom) AS IPFrom, GunzDB.game.inet_ntoa(IPTo) AS IPTo,   
  CountryCode3, Comment, IsBlock, RegDate  
 FROM CustomIP(NOLOCK)  
 WHERE RegDate >= @RegDateFrom AND RegDate <= @RegDateTo  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[LocatorCountryStatistics]') AND type in (N'U'))
BEGIN
CREATE TABLE [LocatorCountryStatistics](
	[LocatorID] [int] NULL,
	[CountryCode3] [char](3) NULL,
	[Count] [int] NULL,
	[RegDate] [smalldatetime] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spLeague_GetCID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [spLeague_GetCID]
AS
	RETURN


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetCustomIPByIP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetCustomIPByIP]  
 @IP varchar(15)  
, @RegDateFrom smalldatetime  
, @RegDateTo smalldatetime  
AS  
 SET NOCOUNT ON  
 DECLARE @TmpIP bigint  
  
 SET @TmpIP = GunzDB.game.inet_aton( @IP )  
 SET @RegDateTo = DATEADD( dd, 1, @RegDateTo )  
  
 SELECT GunzDB.game.inet_ntoa(IPFrom) AS IPFrom, GunzDB.game.inet_ntoa(IPTo) AS IPTo,   
  CountryCode3, Comment, IsBlock, RegDate  
 FROM CustomIP(NOLOCK)  
 WHERE RegDate >= @RegDateFrom AND RegDate <= @RegDateTo AND  
  IPFrom <= @TmpIP AND IPTo >= @TmpIP  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[LocatorLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [LocatorLog](
	[LocatorID] [int] NULL,
	[CountryCode3] [varchar](3) NULL,
	[Count] [int] NULL,
	[RegDate] [smalldatetime] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[KillLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [KillLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[AttackerCID] [int] NULL,
	[VictimCID] [int] NULL,
	[Time] [datetime] NULL,
 CONSTRAINT [KillLog_PK] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Level]') AND type in (N'U'))
BEGIN
CREATE TABLE [Level](
	[Level] [smallint] NOT NULL,
	[MinXP] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Level] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spItemList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create procedure [spItemList]
	@ItemType	int,
	@ResSex		int,
	@ResLevel	int,
	@ResText	nvarchar(100),
	
	@Page		int,
	@PageSize	int,
	@PageCount	int output
AS
set NoCount On

declare @Rows int
declare @ViewCount int
select @Rows = @Page * @PageSize
declare @PageHead INT
declare @RowCount INT


if @ItemType = -1																/* ITEMTYPE  = -1 */
	begin
		if @ResSex = -1														/* ITEMTYPE  = -1  RESSEX  = -1 */
			begin
				if @ResLevel = -1												/* ITEMTYPE  = -1  RESSEX  = -1  RESLEVEL  = -1 */
					begin
						if @ResText = ''''										/* ITEMTYPE  = -1  RESSEX  = -1  RESLEVEL  = -1  RESTEXT  = '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								order by cs.csid desc
							end
						else													/* ITEMTYPE  = -1  RESSEX  = -1  RESLEVEL  = -1  RESTEXT <> '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc
							end
					end
				else															/* ITEMTYPE  = -1  RESSEX  = -1  RESLEVEL <> -1 */
					begin
						if @ResText = ''''										/* ITEMTYPE  = -1  RESSEX  = -1  RESLEVEL <> -1  RESTEXT  = '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and i.ResLevel <= @ResLevel
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and i.ResLevel <= @ResLevel
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and i.ResLevel <= @ResLevel
								order by cs.csid desc
							end
						else													/* ITEMTYPE  = -1  RESSEX  = -1  RESLEVEL <> -1  RESTEXT <> '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and i.ResLevel <= @ResLevel
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and i.ResLevel <= @ResLevel
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and i.ResLevel <= @ResLevel
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc
							end
					end
			end
		else																	/* ITEMTYPE  = -1  RESSEX <> -1 */
			begin
				if @ResLevel = -1												/* ITEMTYPE  = -1  RESSEX <> -1  RESLEVEL  = -1 */
					begin
						if @ResText = ''''										/* ITEMTYPE  = -1  RESSEX <> -1  RESLEVEL  = -1  RESTEXT  = '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and i.ResSex = @ResSex
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and i.ResSex = @ResSex
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and i.ResSex = @ResSex
								order by cs.csid desc
							end
						else													/* ITEMTYPE  = -1  RESSEX <> -1  RESLEVEL  = -1  RESTEXT <> '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and i.ResSex = @ResSex
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and i.ResSex = @ResSex
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and i.ResSex = @ResSex
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc
							end
					end
				else															/* ITEMTYPE  = -1  RESSEX <> -1  RESLEVEL <> -1 */
					begin
						if @ResText = ''''										/* ITEMTYPE  = -1  RESSEX <> -1  RESLEVEL <> -1  RESTEXT  = '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and i.ResSex = @ResSex
								and i.ResLevel <= @ResLevel
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and i.ResSex = @ResSex
								and i.ResLevel <= @ResLevel
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and i.ResSex = @ResSex
								and i.ResLevel <= @ResLevel
								order by cs.csid desc
							end
						else													/* ITEMTYPE  = -1  RESSEX <> -1  RESLEVEL <> -1  RESTEXT <> '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and i.ResSex = @ResSex
								and i.ResLevel <= @ResLevel
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and i.ResSex = @ResSex
								and i.ResLevel <= @ResLevel
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and i.ResSex = @ResSex
								and i.ResLevel <= @ResLevel
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc
							end
					end
			end
	end
else
	begin
		if @ResSex = -1														/* ITEMTYPE <> -1  RESSEX  = -1 */
			begin
				if @ResLevel = -1												/* ITEMTYPE <> -1  RESSEX  = -1  RESLEVEL  = -1 */
					begin
						if @ResText = ''''										/* ITEMTYPE <> -1  RESSEX  = -1  RESLEVEL  = -1  RESTEXT  = '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								order by cs.csid desc
							end
						else													/* ITEMTYPE <> -1  RESSEX  = -1  RESLEVEL  = -1  RESTEXT <> '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc
							end
					end
				else															/* ITEMTYPE <> -1  RESSEX  = -1  RESLEVEL <> -1 */
					begin
						if @ResText = ''''										/* ITEMTYPE <> -1  RESSEX  = -1  RESLEVEL <> -1  RESTEXT  = '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResLevel <= @ResLevel
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResLevel <= @ResLevel
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResLevel <= @ResLevel
								order by cs.csid desc
							end
						else													/* ITEMTYPE <> -1  RESSEX  = -1  RESLEVEL <> -1  RESTEXT <> '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResLevel <= @ResLevel
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResLevel <= @ResLevel
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResLevel <= @ResLevel
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc
							end
					end
			end
		else																	/* ITEMTYPE <> -1  RESSEX <> -1 */
			begin
				if @ResLevel = -1												/* ITEMTYPE <> -1  RESSEX <> -1  RESLEVEL  = -1 */
					begin
						if @ResText = ''''										/* ITEMTYPE <> -1  RESSEX <> -1  RESLEVEL  = -1  RESTEXT  = '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResSex = @ResSex
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResSex = @ResSex
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResSex = @ResSex
								order by cs.csid desc
							end
						else													/* ITEMTYPE <> -1  RESSEX <> -1  RESLEVEL  = -1  RESTEXT <> '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResSex = @ResSex
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResSex = @ResSex
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResSex = @ResSex
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc
							end
					end
				else															/* ITEMTYPE <> -1  RESSEX <> -1  RESLEVEL <> -1 */
					begin
						if @ResText = ''''										/* ITEMTYPE <> -1  RESSEX <> -1  RESLEVEL <> -1  RESTEXT  = '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResSex = @ResSex
								and i.ResLevel <= @ResLevel
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResSex = @ResSex
								and i.ResLevel <= @ResLevel
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResSex = @ResSex
								and i.ResLevel <= @ResLevel
								order by cs.csid desc
							end
						else													/* ITEMTYPE <> -1  RESSEX <> -1  RESLEVEL <> -1  RESTEXT <> '''' */
							begin
								select @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
								from CashShop cs(nolock), viewItem i(nolock)
								where i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResSex = @ResSex
								and i.ResLevel <= @ResLevel
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								
								select @RowCount = ((@Page -1) * @PageSize + 1)
								set rowcount @RowCount
								select @PageHead = cs.csid from CashShop cs(NOLOCK), viewItem i(nolock) 
								where cs.ItemID=i.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResSex = @ResSex
								and i.ResLevel <= @ResLevel
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc

								set rowcount @PageSize
								select cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
								cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
								i.ResSex as ResSex, i.ResLevel as ResLevel, i.Weight as Weight,
								i.Description as Description, cs.RegDate as RegDate, cs.NewItemOrder as IsNewItem,
								cs.RentType as RentType
								from CashShop cs(nolock), viewItem i(nolock)
								where csid <= @PageHead and i.ItemID = cs.ItemID and cs.Opened=1
								and i.SlotEx = @ItemType
								and i.ResSex = @ResSex
								and i.ResLevel <= @ResLevel
								and (i.Name like ''%'' + @ResText + ''%'' or i.Description like ''%'' + @ResText + ''%'')
								order by cs.csid desc
							end
					end
			end
	end


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[LocatorStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [LocatorStatus](
	[LocatorID] [int] NOT NULL,
	[IP] [varchar](15) NOT NULL,
	[Port] [int] NOT NULL,
	[RecvCount] [int] NULL,
	[SendCount] [int] NULL,
	[BlockCount] [int] NULL,
	[DuplicatedCount] [int] NULL,
	[UpdateElapsedTime] [int] NOT NULL,
	[LastUpdatedTime] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[LocatorID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[IP] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Login]') AND type in (N'U'))
BEGIN
CREATE TABLE [Login](
	[UserID] [varchar](20) NOT NULL,
	[AID] [int] NOT NULL,
	[Password] [varchar](20) NULL,
	[LastConnDate] [datetime] NULL,
	[LastIP] [varchar](20) NULL,
 CONSTRAINT [Login_PK] PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spRegularTranslateServerLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE   PROC [spRegularTranslateServerLog]
AS 
 SET NOCOUNT ON

 DECLARE @StartTime char(16)
 DECLARE @EndTime char(16)

 SET @StartTime = CONVERT(char(13), DATEADD(hh, -1, GETDATE()), 120) + '':00''
 SET @EndTime = CONVERT(char(13), GETDATE(), 120) + '':00''

 INSERT INTO LogDB.game.ServerLogStorage(ServerID
  , PlayerCount, GameCount, BlockCount, NonBlockCount
  , Time)
 SELECT ServerID, PlayerCount, GameCount, BlockCount, NonBlockCount, Time
 FROM GunzDB.game.ServerLog(NOLOCK)
 WHERE ServerID < 200 AND Time >= @StartTime AND Time < @EndTime
 ORDER BY ServerID, Time



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Map]') AND type in (N'U'))
BEGIN
CREATE TABLE [Map](
	[MapID] [int] NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[MaxPlayer] [int] NOT NULL,
 CONSTRAINT [Map_PK] PRIMARY KEY CLUSTERED 
(
	[MapID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[PenaltyLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [PenaltyLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[AID] [int] NOT NULL,
	[UGradeID] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
 CONSTRAINT [PenaltyLog_PK] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[PersonalinfoGunz]') AND type in (N'U'))
BEGIN
CREATE TABLE [PersonalinfoGunz](
	[AID] [int] NOT NULL,
	[birthday] [smalldatetime] NULL,
	[city] [nvarchar](50) NULL,
	[state] [char](2) NULL,
	[connecType] [nvarchar](30) NULL,
	[phone] [varchar](15) NULL,
	[speed] [varchar](50) NULL,
	[msgLU] [bit] NULL,
	[statusLUA] [bit] NOT NULL CONSTRAINT [DF_PersonalinfoGunz_statusLUA]  DEFAULT ((1)),
 CONSTRAINT [PK_PersonalinfoGunz] PRIMARY KEY CLUSTERED 
(
	[AID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[PlayerLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [PlayerLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[CID] [int] NULL,
	[DisTime] [datetime] NULL,
	[PlayTime] [int] NULL,
	[Kills] [int] NULL,
	[Deaths] [int] NULL,
	[XP] [int] NULL,
	[TotalXP] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[PremiumGrade]') AND type in (N'U'))
BEGIN
CREATE TABLE [PremiumGrade](
	[PGradeID] [int] NOT NULL,
	[Name] [varchar](128) NOT NULL,
 CONSTRAINT [PremiumGrade_PK] PRIMARY KEY CLUSTERED 
(
	[PGradeID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[PurchaseMethod]') AND type in (N'U'))
BEGIN
CREATE TABLE [PurchaseMethod](
	[PurchaseMethodID] [int] NOT NULL,
	[Name] [varchar](256) NULL,
 CONSTRAINT [PurchaseMethod_PK] PRIMARY KEY CLUSTERED 
(
	[PurchaseMethodID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetServerLog10Min]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



------------------------------------------------------------------------------------------------------------------------

CREATE   PROC [spAdmWebGetServerLog10Min]
 @ServerID tinyint
, @StartTime smalldatetime
, @EndTime smalldatetime
AS
 SET NOCOUNT ON

 IF @StartTime > @EndTime RETURN

 SELECT	a.ServerID, ss.ServerName,
	CONVERT(smalldatetime,DATEADD(mi,a.time*10 ,@StartTime)) as starttime,  
	CONVERT(smalldatetime,DATEADD(mi,(a.time*10+10)-1 ,@StartTime)) as endtime,  
	SUM(playercount)/10/(DATEDIFF(DAY,@StartTime, @EndTime)+ 1) as PlayerCount
 FROM(
	SELECT	ServerID, ISNULL(playercount,0) as PlayerCount, DATEPART(mi,DATEADD(mi, -1, time)) /10 as time
	FROM	LogDB.game.ServerLogStorage(NOLOCK)
	WHERE	Time BETWEEN @StartTime AND @EndTime 
		AND datediff(hh,@StartTime, DATEADD(mi, -1, time) ) % 24 = 0
 ) as a, ServerStatus ss(NOLOCK)
 WHERE  a.ServerID = @ServerID AND ss.ServerID = a.ServerID
 Group By a.ServerID, ss.ServerName, a.Time
 Order By a.Time



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[QuestGameLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [QuestGameLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[GameName] [varchar](64) NULL,
	[Master] [int] NOT NULL,
	[Player1] [int] NULL,
	[Player2] [int] NULL,
	[Player3] [int] NULL,
	[TotalQItemCount] [tinyint] NULL,
	[ScenarioID] [smallint] NOT NULL,
	[StartTime] [smalldatetime] NOT NULL,
	[EndTime] [smalldatetime] NOT NULL,
PRIMARY KEY NONCLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetServerLogDayHour]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE   PROC [spAdmWebGetServerLogDayHour]
 @ServerType tinyint -- 0:전체, 1:일반, 2:클랜, 3:퀘스트, 4:이벤트
, @StartDate smalldatetime
, @EndDate smalldatetime
AS
 SET NOCOUNT ON

 IF @StartDate > @EndDate RETURN

 DECLARE @StartServerID int
 DECLARE @EndServerID int

 IF 0 = @ServerType -- all
  SELECT @StartServerID = 1, @EndServerID = 255
 ELSE IF 1 = @ServerType -- normal
  SELECT @StartServerID = 1, @EndServerID = 49
 ELSE IF 2 = @ServerType -- clan
  SELECT @StartServerID = 50, @EndServerID = 99
 ELSE IF 3 = @ServerType -- quest
  SELECT @STartServerID = 100, @EndServerID = 149
 ELSE IF 4 = @ServerType -- event
  RETURN
 ELSE -- error
  RETURN

 SELECT ss.ServerID, ss.ServerName, 
  SUM(CASE DATEPART(hh, t.Time) WHEN 0 THEN t.PlayerCount ELSE 0 END) AS H0
 , SUM(CASE DATEPART(hh, t.Time) WHEN 1 THEN t.PlayerCount ELSE 0 END) AS H1
 , SUM(CASE DATEPART(hh, t.Time) WHEN 2 THEN t.PlayerCount ELSE 0 END) AS H2
 , SUM(CASE DATEPART(hh, t.Time) WHEN 3 THEN t.PlayerCount ELSE 0 END) AS H3
 , SUM(CASE DATEPART(hh, t.Time) WHEN 4 THEN t.PlayerCount ELSE 0 END) AS H4
 , SUM(CASE DATEPART(hh, t.Time) WHEN 5 THEN t.PlayerCount ELSE 0 END) AS H5
 , SUM(CASE DATEPART(hh, t.Time) WHEN 6 THEN t.PlayerCount ELSE 0 END) AS H6
 , SUM(CASE DATEPART(hh, t.Time) WHEN 7 THEN t.PlayerCount ELSE 0 END) AS H7
 , SUM(CASE DATEPART(hh, t.Time) WHEN 8 THEN t.PlayerCount ELSE 0 END) AS H8
 , SUM(CASE DATEPART(hh, t.Time) WHEN 9 THEN t.PlayerCount ELSE 0 END) AS H9
 , SUM(CASE DATEPART(hh, t.Time) WHEN 10 THEN t.PlayerCount ELSE 0 END) AS H10
 , SUM(CASE DATEPART(hh, t.Time) WHEN 11 THEN t.PlayerCount ELSE 0 END) AS H11
 , SUM(CASE DATEPART(hh, t.Time) WHEN 12 THEN t.PlayerCount ELSE 0 END) AS H12
 , SUM(CASE DATEPART(hh, t.Time) WHEN 13 THEN t.PlayerCount ELSE 0 END) AS H13
 , SUM(CASE DATEPART(hh, t.Time) WHEN 14 THEN t.PlayerCount ELSE 0 END) AS H14
 , SUM(CASE DATEPART(hh, t.Time) WHEN 15 THEN t.PlayerCount ELSE 0 END) AS H15
 , SUM(CASE DATEPART(hh, t.Time) WHEN 16 THEN t.PlayerCount ELSE 0 END) AS H16
 , SUM(CASE DATEPART(hh, t.Time) WHEN 17 THEN t.PlayerCount ELSE 0 END) AS H17
 , SUM(CASE DATEPART(hh, t.Time) WHEN 18 THEN t.PlayerCount ELSE 0 END) AS H18
 , SUM(CASE DATEPART(hh, t.Time) WHEN 19 THEN t.PlayerCount ELSE 0 END) AS H19
 , SUM(CASE DATEPART(hh, t.Time) WHEN 20 THEN t.PlayerCount ELSE 0 END) AS H20
 , SUM(CASE DATEPART(hh, t.Time) WHEN 21 THEN t.PlayerCount ELSE 0 END) AS H21
 , SUM(CASE DATEPART(hh, t.Time) WHEN 22 THEN t.PlayerCount ELSE 0 END) AS H22
 , SUM(CASE DATEPART(hh, t.Time) WHEN 23 THEN t.PlayerCount ELSE 0 END) AS H23
 , SUM(t.PlayerCount) / 24 AS AVG
 FROM (
  SELECT ServerID
  , CASE(DATEPART(mi, Time) % 10)
    WHEN 0 THEN DATEADD(mi, -1, Time)
    ELSE DATEADD(mi, (DATEPART(mi, Time) % 10) * -1, Time) END
    AS Time
  , PlayerCount
  FROM LogDB.game.ServerLogStorage(NOLOCK)
  WHERE (Time BETWEEN @StartDate AND @EndDate) 
   AND (ServerID BETWEEN @StartServerID AND @EndServerID)
 ) AS t, ServerStatus ss(NOLOCK)
 WHERE ss.ServerID = t.ServerID
 GROUP BY ss.ServerID, ss.ServerName
 ORDER BY ss.ServerID


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[QuestItem]') AND type in (N'U'))
BEGIN
CREATE TABLE [QuestItem](
	[QIID] [int] NOT NULL,
	[Name] [char](32) NULL,
	[Level] [tinyint] NULL,
	[Description] [varchar](200) NULL,
	[Price] [int] NULL,
	[UniqueItem] [bit] NOT NULL,
	[Sacrifice] [bit] NOT NULL,
	[Type] [char](10) NULL,
	[Param] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[QIID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[QUniqueItemLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [QUniqueItemLog](
	[QUILID] [int] IDENTITY(1,1) NOT NULL,
	[QGLID] [int] NULL,
	[CID] [int] NOT NULL,
	[QIID] [int] NOT NULL,
PRIMARY KEY NONCLUSTERED 
(
	[QUILID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetServerLogMaxPlayerCntHour]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


----------------------------------------------------------------------------------------------------------------------------

CREATE  PROC [spAdmWebGetServerLogMaxPlayerCntHour] 
 @ServerType tinyint  
, @StartDate smalldatetime  
, @EndDate smalldatetime  
AS  
 SET NOCOUNT ON  

 IF @StartDate > @EndDate RETURN

 DECLARE @StartServerID tinyint  
 DECLARE @EndServerID tinyint  

 IF 0 = @ServerType -- all  
  SELECT @StartServerID = 1, @EndServerID = 255  
 ELSE IF 1 = @ServerType -- normal  
  SELECT @StartServerID = 1, @EndServerID = 49  
 ELSE IF 2 = @ServerType -- clan  
  SELECT @StartServerID = 50, @EndServerID = 99  
 ELSE IF 3 = @ServerType -- quest  
  SELECT @STartServerID = 100, @EndServerID = 149  
 ELSE IF 4 = @ServerType -- event  
  RETURN  
 ELSE  
  RETURN  

SELECT t.ServerID, t.ServerName  
 , MAX(CASE t.Time WHEN 0 THEN t.MaxPlayerCount ELSE 0 END) AS H0  
 , MAX(CASE t.Time WHEN 1 THEN t.MaxPlayerCount ELSE 0 END) AS H1  
 , MAX(CASE t.Time WHEN 2 THEN t.MaxPlayerCount ELSE 0 END) AS H2  
 , MAX(CASE t.Time WHEN 3 THEN t.MaxPlayerCount ELSE 0 END) AS H3  
 , MAX(CASE t.Time WHEN 4 THEN t.MaxPlayerCount ELSE 0 END) AS H4  
 , MAX(CASE t.Time WHEN 5 THEN t.MaxPlayerCount ELSE 0 END) AS H5  
 , MAX(CASE t.Time WHEN 6 THEN t.MaxPlayerCount ELSE 0 END) AS H6  
 , MAX(CASE t.Time WHEN 7 THEN t.MaxPlayerCount ELSE 0 END) AS H7  
 , MAX(CASE t.Time WHEN 8 THEN t.MaxPlayerCount ELSE 0 END) AS H8  
 , MAX(CASE t.Time WHEN 9 THEN t.MaxPlayerCount ELSE 0 END) AS H9  
 , MAX(CASE t.Time WHEN 10 THEN t.MaxPlayerCount ELSE 0 END) AS H10  
 , MAX(CASE t.Time WHEN 11 THEN t.MaxPlayerCount ELSE 0 END) AS H11  
 , MAX(CASE t.Time WHEN 12 THEN t.MaxPlayerCount ELSE 0 END) AS H12  
 , MAX(CASE t.Time WHEN 13 THEN t.MaxPlayerCount ELSE 0 END) AS H13  
 , MAX(CASE t.Time WHEN 14 THEN t.MaxPlayerCount ELSE 0 END) AS H14  
 , MAX(CASE t.Time WHEN 15 THEN t.MaxPlayerCount ELSE 0 END) AS H15  
 , MAX(CASE t.Time WHEN 16 THEN t.MaxPlayerCount ELSE 0 END) AS H16  
 , MAX(CASE t.Time WHEN 17 THEN t.MaxPlayerCount ELSE 0 END) AS H17  
 , MAX(CASE t.Time WHEN 18 THEN t.MaxPlayerCount ELSE 0 END) AS H18  
 , MAX(CASE t.Time WHEN 19 THEN t.MaxPlayerCount ELSE 0 END) AS H19  
 , MAX(CASE t.Time WHEN 20 THEN t.MaxPlayerCount ELSE 0 END) AS H20  
 , MAX(CASE t.Time WHEN 21 THEN t.MaxPlayerCount ELSE 0 END) AS H21  
 , MAX(CASE t.Time WHEN 22 THEN t.MaxPlayerCount ELSE 0 END) AS H22  
 , MAX(CASE t.Time WHEN 23 THEN t.MaxPlayerCount ELSE 0 END) AS H23  
 , SUM(t.MaxPlayerCount) / 24 AS ''AVG''
 FROM (  
  SELECT sls.ServerID, ss.ServerName, DATEPART(hh, DATEADD(mi, -1, sls.Time)) AS Time, MAX(PlayerCount) as MaxPlayerCount
  FROM LogDB.game.ServerLogStorage sls(NOLOCK), ServerStatus ss(NOLOCK)
  WHERE (sls.Time BETWEEN @StartDate AND @EndDate)   
   AND (sls.ServerID BETWEEN @StartServerID AND @EndServerID)
   AND ss.ServerID = sls.ServerID
  GROUP BY sls.ServerID, ss.ServerName, DATEPART(hh, DATEADD(mi, -1, sls.Time))
 ) AS t 
 GROUP BY t.ServerID, t.ServerName 
 ORDER BY t.ServerID  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RentPeriodDay]') AND type in (N'U'))
BEGIN
CREATE TABLE [RentPeriodDay](
	[Day] [int] NOT NULL,
	[Hour] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Day] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Hour] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RentType]') AND type in (N'U'))
BEGIN
CREATE TABLE [RentType](
	[TypeID] [int] NOT NULL,
	[Description] [varchar](256) NULL,
PRIMARY KEY CLUSTERED 
(
	[TypeID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ServerLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [ServerLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ServerID] [smallint] NULL,
	[PlayerCount] [smallint] NULL,
	[GameCount] [smallint] NULL,
	[Time] [smalldatetime] NULL,
	[BlockCount] [int] NULL,
	[NonBlockCount] [int] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ServerStatus]') AND type in (N'U'))
BEGIN
CREATE TABLE [ServerStatus](
	[ServerID] [int] NOT NULL,
	[CurrPlayer] [smallint] NULL,
	[MaxPlayer] [smallint] NULL,
	[Time] [datetime] NULL,
	[IP] [varchar](32) NULL,
	[Port] [int] NULL,
	[ServerName] [varchar](64) NULL,
	[Opened] [tinyint] NULL,
	[Type] [int] NULL,
 CONSTRAINT [ServerStatus_PK] PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetUV]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetUV] 
 @StartDate smalldatetime
, @EndDate smalldatetime
AS
 SET NOCOUNT ON

 IF @StartDate > @EndDate RETURN
 IF 3 < DATEDIFF(dd, @StartDate, @EndDate) RETURN

 SELECT  t.Time, COUNT(t.AID) as UCount
 FROM
 (
 SELECT AID, CONVERT(char(10),Time,120) as Time
 FROM LogDB.game.ConnLog(NOLOCK) 
 WHERE time >= @StartDate and time <= @EndDate
 GROUP BY AID, CONVERT(char(10),Time,120)
 ) as t
 GROUP BY t.Time 
 ORDER BY t.Time 

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ServerType]') AND type in (N'U'))
BEGIN
CREATE TABLE [ServerType](
	[Type] [int] NOT NULL,
	[Description] [varchar](128) NULL,
PRIMARY KEY CLUSTERED 
(
	[Type] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TESTE]') AND type in (N'U'))
BEGIN
CREATE TABLE [TESTE](
	[AID] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](20) NOT NULL,
	[UGradeID] [int] NOT NULL,
	[PGradeID] [int] NOT NULL,
	[RegDate] [datetime] NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Email] [varchar](50) NULL,
	[RegNum] [varchar](50) NULL,
	[Age] [smallint] NULL,
	[Sex] [tinyint] NULL,
	[ZipCode] [varchar](50) NULL,
	[Address] [varchar](256) NULL,
	[Country] [varchar](50) NULL,
	[LastCID] [int] NULL,
	[Cert] [tinyint] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[TotalRanking]') AND type in (N'U'))
BEGIN
CREATE TABLE [TotalRanking](
	[Rank] [int] IDENTITY(1,1) NOT NULL,
	[UserID] [varchar](20) NULL,
	[Name] [varchar](24) NOT NULL,
	[Level] [smallint] NOT NULL,
	[XP] [int] NULL,
	[KillCount] [int] NULL,
	[DeathCount] [int] NULL,
 CONSTRAINT [PK_TotalRanking_Rank] PRIMARY KEY CLUSTERED 
(
	[Rank] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[UV]') AND type in (N'U'))
BEGIN
CREATE TABLE [UV](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Time] [smalldatetime] NOT NULL,
	[Count] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[UserGrade]') AND type in (N'U'))
BEGIN
CREATE TABLE [UserGrade](
	[UGradeID] [int] NOT NULL,
	[Name] [varchar](128) NOT NULL,
 CONSTRAINT [UserGrade_PK] PRIMARY KEY CLUSTERED 
(
	[UGradeID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dtproperties]') AND type in (N'U'))
BEGIN
CREATE TABLE [dtproperties](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[objectid] [int] NULL,
	[property] [varchar](64) NOT NULL,
	[value] [varchar](255) NULL,
	[uvalue] [nvarchar](255) NULL,
	[lvalue] [image] NULL,
	[version] [int] NOT NULL CONSTRAINT [DF__dtpropert__versi__0A9D95DB]  DEFAULT ((0)),
 CONSTRAINT [pk_dtproperties] PRIMARY KEY CLUSTERED 
(
	[id] ASC,
	[property] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[sjr_TableSizeIncr]') AND type in (N'U'))
BEGIN
CREATE TABLE [sjr_TableSizeIncr](
	[name] [varchar](40) NULL,
	[rows] [int] NULL,
	[reserved] [varchar](100) NULL,
	[date] [varchar](100) NULL,
	[index_size] [varchar](100) NULL,
	[unused] [varchar](100) NULL,
	[rd] [datetime] NULL CONSTRAINT [DF__sjr_TableSiz__rd__1229A90A]  DEFAULT (getdate())
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[LUG_ChkLogon]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE PROC [LUG_ChkLogon]
(
	@userId NVARCHAR(24),
	@passwd NVARCHAR(24),
	@result BIT OUTPUT
)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM game.login (NOLOCK) WHERE [userId] = @userId AND password = @passwd)
		SET @result = 1
	ELSE
		SET @result = 0
END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[LUG_UpdateTheDuelAccountData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE  Procedure [LUG_UpdateTheDuelAccountData]
(
	@gameUserId	VARCHAR(24),
	@userNameAcc	VARCHAR(50),
	@email		VARCHAR(50),
	@birthday	DATETIME,
	@sex		BIT,
	@zipcode	VARCHAR(10),
	@address	VARCHAR(250),
	@country	VARCHAR(3),
	@city		VARCHAR(50),
	@state		VARCHAR(2),
	@connecType	INT,
	@phone		VARCHAR(13),
	@speed		INT,
	@msgLU		BIT
)
AS

SET XACT_ABORT ON

BEGIN TRAN

	--Realizando UPDATE na base RA
	UPDATE
	      game.Account
	SET	
		name = @userNameAcc,
		email = @email,
		age = SUBSTRING(CONVERT(VARCHAR, @birthday,103), 7, 4),
		sex = @sex,
		zipcode = @zipcode,
		address = @address,
		country = @country
	WHERE 	
		userid = @gameUserId

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		RETURN
	END

	--Realizando UPDATE na base RA	
	UPDATE
		personal
	SET	
		birthday = convert(smalldatetime, @birthday, 112),
		city = @city,
		state = @state,
		connecType = @connecType,
		phone	= @phone,
		speed	= @speed,
		msgLU	= @msgLU
	FROM
		game.personalInfoGunz personal
		INNER JOIN game.Account acc ON personal.AID = acc.AID
	WHERE
		acc.userid = @gameUserId

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		RETURN
	END

COMMIT TRAN


' 
END
GO
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[LUG_UpdateTheDuelAccountEmail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE  Procedure [LUG_UpdateTheDuelAccountEmail]
(
	@gameUserId	VARCHAR(24),
	@email		VARCHAR(50)
)
AS

SET XACT_ABORT ON

BEGIN TRAN

	--Realizando UPDATE na base RA
	UPDATE
	      game.Account
	SET	
		email = @email
	WHERE 	
		aid = @gameUserId

	IF @@ERROR <> 0
	BEGIN
		ROLLBACK TRAN
		RETURN
	END


COMMIT TRAN
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[LUG_ValidateForumUserTD]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [LUG_ValidateForumUserTD] 
@userId VARCHAR(24),
@passwd VARCHAR(24)
AS

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

DECLARE @email VARCHAR(200)

SELECT @email = b.email
FROM game.login a
	INNER JOIN game.account b
		ON a.AID = b.AID 
WHERE a.userid = @userId
AND a.[password] COLLATE Latin1_General_CS_AI = @passwd

SELECT @email AS email 



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[LUG_checkAccountByEmail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE Procedure [LUG_checkAccountByEmail]
 
 (
  @UserID VARCHAR(24),
  @email VARCHAR(50),
  @result BIT OUTPUT
 )
 

AS
 
-- LEVEUP UP BRAZIL - Please, do not modify this procedure!
-- Return 0 = Not Exist
-- Return 1 = Exist
 
SET NOCOUNT ON
 
-- Check if user exists
IF EXISTS (SELECT 1 FROM game.account WHERE UserID = @UserID AND email = @email)
 SET @result = 1
ELSE
 SET @result = 0
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[USP_sjr_TableSizeIncr]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

create proc [USP_sjr_TableSizeIncr]

as
begin 
	SET NOCOUNT ON

	select identity(int,1,1) idx ,'' insert sjr_TableSizeIncr (name,rows,reserved,date,index_size,unused) '' +char(10)+
	''exec sp_spaceused ''+name  as sql  into #spaceusedTb
	from Gunzdb.dbo.sysobjects where xtype = ''U''
	 
	
	DECLARE @sql varchar(400) 
	DECLARE SQL_cursor CURSOR FOR 
	SELECT  sql
	FROM #spaceusedTb
	ORDER BY idx
	OPEN SQL_cursor
	FETCH NEXT FROM SQL_cursor 
	INTO @sql
	WHILE @@FETCH_STATUS = 0
	BEGIN
	   exec (@sql)
	   FETCH NEXT FROM SQL_cursor 
	   INTO @sql
	END
	CLOSE SQL_cursor
	DEALLOCATE SQL_cursor

end 
 

 


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_addtosourcecontrol]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create proc [dt_addtosourcecontrol]
    @vchSourceSafeINI varchar(255) = '''',
    @vchProjectName   varchar(255) ='''',
    @vchComment       varchar(255) ='''',
    @vchLoginName     varchar(255) ='''',
    @vchPassword      varchar(255) =''''

as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId = 0

declare @iStreamObjectId int
select @iStreamObjectId = 0

declare @VSSGUID varchar(100)
select @VSSGUID = ''SQLVersionControl.VCS_SQL''

declare @vchDatabaseName varchar(255)
select @vchDatabaseName = db_name()

declare @iReturnValue int
select @iReturnValue = 0

declare @iPropertyObjectId int
declare @vchParentId varchar(255)

declare @iObjectCount int
select @iObjectCount = 0

    exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 GOTO E_OAError


    /* Create Project in SS */
    exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
											''AddProjectToSourceSafe'',
											NULL,
											@vchSourceSafeINI,
											@vchProjectName output,
											@@SERVERNAME,
											@vchDatabaseName,
											@vchLoginName,
											@vchPassword,
											@vchComment


    if @iReturn <> 0 GOTO E_OAError

    /* Set Database Properties */

    begin tran SetProperties

    /* add high level object */

    exec @iPropertyObjectId = dbo.dt_adduserobject_vcs ''VCSProjectID''

    select @vchParentId = CONVERT(varchar(255),@iPropertyObjectId)

    exec dbo.dt_setpropertybyid @iPropertyObjectId, ''VCSProjectID'', @vchParentId , NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, ''VCSProject'' , @vchProjectName , NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, ''VCSSourceSafeINI'' , @vchSourceSafeINI , NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, ''VCSSQLServer'', @@SERVERNAME, NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, ''VCSSQLDatabase'', @vchDatabaseName, NULL

    if @@error <> 0 GOTO E_General_Error

    commit tran SetProperties
    
    select @iObjectCount = 0;

CleanUp:
    select @vchProjectName
    select @iObjectCount
    return

E_General_Error:
    /* this is an all or nothing.  No specific error messages */
    goto CleanUp

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    goto CleanUp



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_displayoaerror]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dt_displayoaerror]
    @iObject int,
    @iresult int
as

set nocount on

declare @vchOutput      varchar(255)
declare @hr             int
declare @vchSource      varchar(255)
declare @vchDescription varchar(255)

    exec @hr = master.dbo.sp_OAGetErrorInfo @iObject, @vchSource OUT, @vchDescription OUT

    select @vchOutput = @vchSource + '': '' + @vchDescription
    raiserror (@vchOutput,16,-1)

    return


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetAgoDay]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 현재 날짜를 기준으로 틀정 일수 이전의 날을 구함( EX, 2004-10-15 )
-- spRegularUpdateConnLog의 의존성때문에 먼저 생성해 줘야 함.
CREATE PROC [spGetAgoDay]
	@DiffDay int
,	@AgoDay datetime OUTPUT
AS
	SET NOCOUNT ON
	DECLARE @CurDay datetime

	SELECT @CurDay = CONVERT( varchar(30), GETDATE(), 2 )
	SELECT @AgoDay = DATEADD( dd, -@DiffDay, @CurDay )



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_vcsenabled]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create proc [dt_vcsenabled]

as

set nocount on

declare @iObjectId int
select @iObjectId = 0

declare @VSSGUID varchar(100)
select @VSSGUID = ''SQLVersionControl.VCS_SQL''

    declare @iReturn int
    exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 raiserror('''', 16, -1) /* Can''t Load Helper DLLC */



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_verstamp006]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
**	This procedure returns the version number of the stored
**    procedures used by legacy versions of the Microsoft
**	Visual Database Tools.  Version is 7.0.00.
*/
create procedure [dt_verstamp006]
as
	select 7000

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_verstamp007]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
**	This procedure returns the version number of the stored
**    procedures used by the the Microsoft Visual Database Tools.
**	Version is 7.0.05.
*/
create procedure [dt_verstamp007]
as
	select 7005

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetCheckBlockedIP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spGetCheckBlockedIP]
@IP varchar(15)
AS
BEGIN
	SELECT ic.CountryName as Name, bcc.CountryCode3 as Code, bcc.IsBlock
	FROM BlockCountryCode bcc(NOLOCK), IPtoCountry ic(NOLOCK)
	WHERE   ic.CountryCode3 = bcc.CountryCode3 and 
		ic.IPFrom <= GunzDB.game.inet_aton( @IP ) and ic.IPTo >= GunzDB.game.inet_aton( @IP ) 
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[SetItemPurchaseLogByCash]') AND type in (N'U'))
BEGIN
CREATE TABLE [SetItemPurchaseLogByCash](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[AID] [int] NULL,
	[CSSID] [int] NULL,
	[Date] [datetime] NOT NULL,
	[Cash] [int] NULL,
	[RentHourPeriod] [int] NULL,
	[MobileCode] [char](16) NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RentCashSetShopPrice]') AND type in (N'U'))
BEGIN
CREATE TABLE [RentCashSetShopPrice](
	[RCSSPID] [int] IDENTITY(1,1) NOT NULL,
	[CSSID] [int] NULL,
	[RentHourPeriod] [smallint] NULL,
	[CashPrice] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[RCSSPID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CashSetItem]') AND type in (N'U'))
BEGIN
CREATE TABLE [CashSetItem](
	[CSIID] [int] IDENTITY(1,1) NOT NULL,
	[CSSID] [int] NOT NULL,
	[CSID] [int] NOT NULL,
 CONSTRAINT [CashSetItem_PK] PRIMARY KEY CLUSTERED 
(
	[CSIID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CashItemPresentLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [CashItemPresentLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[SenderUserID] [varchar](20) NOT NULL,
	[ReceiverAID] [int] NOT NULL,
	[CSID] [int] NULL,
	[CSSID] [int] NULL,
	[Cash] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
	[RentHourPeriod] [int] NULL,
	[MobileCode] [char](16) NULL,
 CONSTRAINT [CashItemPresentLog_PK] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[BringAccountItemLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [BringAccountItemLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[AID] [int] NULL,
	[CID] [int] NULL,
	[ItemID] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
 CONSTRAINT [BringAccountItemLog_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AccountPenaltyPeriod]') AND type in (N'U'))
BEGIN
CREATE TABLE [AccountPenaltyPeriod](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[AID] [int] NOT NULL,
	[DayLeft] [int] NOT NULL,
 CONSTRAINT [AccountPenaltyPeriod_PK] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[AccountItem]') AND type in (N'U'))
BEGIN
CREATE TABLE [AccountItem](
	[AIID] [int] IDENTITY(1,1) NOT NULL,
	[AID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[RentDate] [datetime] NULL CONSTRAINT [DF__AccountIt__RentD__116A8EFB]  DEFAULT (NULL),
	[RentHourPeriod] [smallint] NULL CONSTRAINT [DF__AccountIt__RentH__125EB334]  DEFAULT (NULL),
	[Cnt] [smallint] NULL CONSTRAINT [DF__AccountItem__Cnt__1352D76D]  DEFAULT (NULL),
 CONSTRAINT [Table1_PK] PRIMARY KEY CLUSTERED 
(
	[AIID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Character]') AND type in (N'U'))
BEGIN
CREATE TABLE [Character](
	[CID] [int] IDENTITY(1,1) NOT NULL,
	[AID] [int] NOT NULL,
	[Name] [varchar](24) NOT NULL,
	[Level] [smallint] NOT NULL,
	[Sex] [tinyint] NOT NULL,
	[CharNum] [smallint] NOT NULL,
	[Hair] [tinyint] NULL,
	[Face] [tinyint] NULL,
	[XP] [int] NOT NULL,
	[BP] [int] NOT NULL,
	[HP] [smallint] NULL,
	[AP] [smallint] NULL,
	[FR] [int] NULL,
	[CR] [int] NULL,
	[ER] [int] NULL,
	[WR] [int] NULL,
	[head_slot] [int] NULL,
	[chest_slot] [int] NULL,
	[hands_slot] [int] NULL,
	[legs_slot] [int] NULL,
	[feet_slot] [int] NULL,
	[fingerl_slot] [int] NULL,
	[fingerr_slot] [int] NULL,
	[melee_slot] [int] NULL,
	[primary_slot] [int] NULL,
	[secondary_slot] [int] NULL,
	[custom1_slot] [int] NULL,
	[custom2_slot] [int] NULL,
	[RegDate] [datetime] NULL,
	[LastTime] [datetime] NULL,
	[PlayTime] [int] NULL,
	[GameCount] [int] NULL,
	[KillCount] [int] NULL,
	[DeathCount] [int] NULL,
	[DeleteFlag] [tinyint] NULL,
	[DeleteName] [varchar](24) NULL,
	[head_itemid] [int] NULL,
	[chest_itemid] [int] NULL,
	[hands_itemid] [int] NULL,
	[legs_itemid] [int] NULL,
	[feet_itemid] [int] NULL,
	[fingerl_itemid] [int] NULL,
	[fingerr_itemid] [int] NULL,
	[melee_itemid] [int] NULL,
	[primary_itemid] [int] NULL,
	[secondary_itemid] [int] NULL,
	[custom1_itemid] [int] NULL,
	[custom2_itemid] [int] NULL,
	[QuestItemInfo] [binary](292) NULL,
 CONSTRAINT [Character_PK] PRIMARY KEY CLUSTERED 
(
	[CID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ItemPurchaseLogByCash]') AND type in (N'U'))
BEGIN
CREATE TABLE [ItemPurchaseLogByCash](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[AID] [int] NULL,
	[ItemID] [int] NOT NULL,
	[Date] [datetime] NOT NULL,
	[Cash] [int] NULL,
	[RentHourPeriod] [int] NULL,
	[MobileCode] [char](16) NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CharacterMgrLogByGM]') AND type in (N'U'))
BEGIN
CREATE TABLE [CharacterMgrLogByGM](
	[CharMgrLogID] [int] IDENTITY(1,1) NOT NULL,
	[CID] [int] NULL,
	[CharName] [varchar](24) NOT NULL,
	[CharMgrTypeID] [tinyint] NULL,
	[GMID] [varchar](20) NOT NULL,
	[NewName] [varchar](24) NULL,
	[OrgValue] [int] NULL,
	[NewValue] [int] NULL,
	[RegDate] [smalldatetime] NULL,
PRIMARY KEY NONCLUSTERED 
(
	[CharMgrLogID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ClanGameLog]') AND type in (N'U'))
BEGIN
CREATE TABLE [ClanGameLog](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[WinnerCLID] [int] NOT NULL,
	[LoserCLID] [int] NOT NULL,
	[WinnerClanName] [varchar](24) NULL,
	[LoserClanName] [varchar](24) NULL,
	[WinnerMembers] [varchar](110) NULL,
	[LoserMembers] [varchar](110) NULL,
	[RoundWins] [tinyint] NOT NULL,
	[RoundLosses] [tinyint] NOT NULL,
	[MapID] [tinyint] NOT NULL,
	[GameType] [tinyint] NOT NULL,
	[RegDate] [datetime] NOT NULL,
	[WinnerPoint] [int] NULL,
	[LoserPoint] [int] NULL,
 CONSTRAINT [ClanGameLog_PK] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ClanHonorRanking]') AND type in (N'U'))
BEGIN
CREATE TABLE [ClanHonorRanking](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[CLID] [int] NULL,
	[ClanName] [varchar](24) NOT NULL,
	[Point] [int] NULL,
	[Wins] [int] NULL,
	[Losses] [int] NULL,
	[Ranking] [int] NULL,
	[Year] [smallint] NULL,
	[Month] [tinyint] NULL,
	[RankIncrease] [int] NOT NULL CONSTRAINT [DF__ClanHonor__RankI__0504B816]  DEFAULT ((0)),
 CONSTRAINT [PK_ClanHonorRanking_ID] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ClanMember]') AND type in (N'U'))
BEGIN
CREATE TABLE [ClanMember](
	[CMID] [int] IDENTITY(1,1) NOT NULL,
	[CLID] [int] NULL,
	[CID] [int] NULL,
	[Grade] [tinyint] NOT NULL,
	[RegDate] [datetime] NOT NULL,
	[ContPoint] [int] NOT NULL CONSTRAINT [DF__ClanMembe__ContP__6B44E613]  DEFAULT ((0)),
 CONSTRAINT [ClanMember_PK] PRIMARY KEY CLUSTERED 
(
	[CMID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Item]') AND type in (N'U'))
BEGIN
CREATE TABLE [Item](
	[ItemID] [int] NOT NULL,
	[Name] [varchar](256) NOT NULL,
	[TotalPoint] [int] NULL,
	[ResSex] [tinyint] NULL,
	[ResRace] [tinyint] NULL,
	[ResLevel] [int] NULL,
	[Slot] [tinyint] NULL,
	[Weight] [int] NULL,
	[BountyPrice] [int] NULL,
	[Damage] [int] NULL,
	[Delay] [int] NULL,
	[EffectID] [int] NULL,
	[Controllability] [int] NULL,
	[Magazine] [int] NULL,
	[ReloadTime] [int] NULL,
	[SlugOutput] [tinyint] NULL,
	[Gadget] [int] NULL,
	[HP] [int] NULL,
	[AP] [int] NULL,
	[MAXWT] [int] NULL,
	[SF] [int] NULL,
	[FR] [int] NULL,
	[CR] [int] NULL,
	[PR] [int] NULL,
	[LR] [int] NULL,
	[BlendColor] [int] NULL,
	[ModelName] [varchar](64) NULL,
	[Description] [varchar](1024) NULL,
	[MaxBullet] [int] NULL,
	[LimitSpeed] [tinyint] NULL,
	[IsCashItem] [tinyint] NULL,
 CONSTRAINT [Item_PK] PRIMARY KEY CLUSTERED 
(
	[ItemID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ItemPurchaseLogByBounty]') AND type in (N'U'))
BEGIN
CREATE TABLE [ItemPurchaseLogByBounty](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[ItemID] [int] NOT NULL,
	[CID] [int] NULL,
	[Date] [datetime] NULL,
	[Bounty] [int] NULL,
	[CharBounty] [int] NULL,
	[Type] [varchar](20) NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CashShop]') AND type in (N'U'))
BEGIN
CREATE TABLE [CashShop](
	[CSID] [int] NOT NULL,
	[ItemID] [int] NOT NULL,
	[NewItemOrder] [tinyint] NULL,
	[CashPrice] [int] NOT NULL,
	[WebImgName] [varchar](64) NULL,
	[Opened] [tinyint] NULL,
	[RegDate] [datetime] NULL,
	[RentType] [tinyint] NULL,
 CONSTRAINT [CashShop_PK] PRIMARY KEY CLUSTERED 
(
	[CSID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[RentCashShopPrice]') AND type in (N'U'))
BEGIN
CREATE TABLE [RentCashShopPrice](
	[RCSPID] [int] IDENTITY(1,1) NOT NULL,
	[CSID] [int] NULL,
	[RentHourPeriod] [smallint] NULL,
	[CashPrice] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[RCSPID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Friend]') AND type in (N'U'))
BEGIN
CREATE TABLE [Friend](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[CID] [int] NOT NULL,
	[FriendCID] [int] NOT NULL,
	[Type] [int] NOT NULL,
	[Favorite] [tinyint] NULL,
	[DeleteFlag] [tinyint] NULL,
 CONSTRAINT [Friend_PK] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[CharacterItem]') AND type in (N'U'))
BEGIN
CREATE TABLE [CharacterItem](
	[CIID] [int] IDENTITY(1,1) NOT NULL,
	[CID] [int] NULL,
	[ItemID] [int] NOT NULL,
	[RegDate] [datetime] NULL,
	[RentDate] [datetime] NULL CONSTRAINT [DF__Character__RentD__0E8E2250]  DEFAULT (NULL),
	[RentHourPeriod] [smallint] NULL CONSTRAINT [DF__Character__RentH__0F824689]  DEFAULT (NULL),
	[Cnt] [smallint] NULL CONSTRAINT [DF__CharacterIt__Cnt__10766AC2]  DEFAULT (NULL),
 CONSTRAINT [CharacterItem_PK] PRIMARY KEY CLUSTERED 
(
	[CIID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[Clan]') AND type in (N'U'))
BEGIN
CREATE TABLE [Clan](
	[CLID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](24) NULL,
	[Exp] [int] NOT NULL CONSTRAINT [DF__Clan__Exp__740F363E]  DEFAULT ((0)),
	[Level] [tinyint] NOT NULL CONSTRAINT [DF__Clan__Level__75035A77]  DEFAULT ((1)),
	[Point] [int] NOT NULL CONSTRAINT [DF_Clan_Point]  DEFAULT ((1000)),
	[MasterCID] [int] NULL,
	[Wins] [int] NOT NULL CONSTRAINT [DF__Clan__Wins__76EBA2E9]  DEFAULT ((0)),
	[MarkWebImg] [varchar](48) NULL,
	[Introduction] [varchar](1024) NULL,
	[RegDate] [datetime] NOT NULL,
	[DeleteFlag] [tinyint] NULL CONSTRAINT [DF__Clan__DeleteFlag__78D3EB5B]  DEFAULT ((0)),
	[DeleteName] [varchar](24) NULL,
	[Homepage] [varchar](128) NULL,
	[Losses] [int] NOT NULL CONSTRAINT [DF__Clan__Losses__6774552F]  DEFAULT ((0)),
	[Draws] [int] NOT NULL CONSTRAINT [DF__Clan__Draws__68687968]  DEFAULT ((0)),
	[Ranking] [int] NOT NULL CONSTRAINT [DF__Clan__Ranking__695C9DA1]  DEFAULT ((0)),
	[TotalPoint] [int] NOT NULL CONSTRAINT [DF__Clan__TotalPoint__6A50C1DA]  DEFAULT ((0)),
	[Cafe_Url] [varchar](20) NULL,
	[Email] [varchar](70) NULL,
	[EmblemUrl] [varchar](256) NULL,
	[RankIncrease] [int] NOT NULL CONSTRAINT [DF__Clan__RankIncrea__7E57BA87]  DEFAULT ((0)),
	[EmblemChecksum] [int] NOT NULL CONSTRAINT [DF__Clan__EmblemChec__004002F9]  DEFAULT ((0)),
	[LastDayRanking] [int] NOT NULL CONSTRAINT [DF__Clan__LastDayRan__031C6FA4]  DEFAULT ((0)),
	[LastMonthRanking] [int] NOT NULL CONSTRAINT [DF__Clan__LastMonthR__041093DD]  DEFAULT ((0)),
 CONSTRAINT [Clan_PK] PRIMARY KEY CLUSTERED 
(
	[CLID] ASC
)WITH (PAD_INDEX  = OFF, IGNORE_DUP_KEY = OFF, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebDeleteCashSetShopItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebDeleteCashSetShopItem]
 @CSSID int
, @Ret int OUTPUT
AS
 SET NOCOUNT ON
 DELETE CashSetShop WHERE CSSID = @CSSID
 IF 0 <> @@ERROR BEGIN
  SET @Ret = 0
  RETURN
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetCashSetItemPresentSendLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetCashSetItemPresentSendLog]      
 @AID int      
AS      
 SET NOCOUNT ON       
 SELECT cpl.id, cpl.SenderUserID, aa.UserID AS ReceiverUserID    
  , css.Name AS ItemName, cpl.Date, cpl.Cash      
  , CASE ISNULL(cpl.RentHourPeriod, 0)    
    WHEN 0 THEN ''0''    
    ELSE CAST(cpl.RentHourPeriod AS varchar(10))     
   END AS ''RentHourPeriod''    
 FROM ((Account a(NOLOCK) JOIN CashItemPresentLog cpl(NOLOCK)      
 ON a.AID = @AID AND cpl.SenderUserID = a.UserID) JOIN CashSetShop css(NOLOCK)      
 ON css.CSSID = cpl.CSSID) JOIN Account aa(NOLOCK)     
 ON aa.AID = cpl.ReceiverAID     
 ORDER BY cpl.Date DESC      

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetCashSetItemPresentRecvLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetCashSetItemPresentRecvLog]  
 @AID int  
AS  
 SET NOCOUNT ON  
 SELECT cpl.id, cpl.SenderUserID, a.UserID AS ReceiverUserID
  , css.Name AS ItemName, cpl.Date, cpl.Cash
  , CASE ISNULL(cpl.RentHourPeriod, 0)
    WHEN 0 THEN ''0''
    ELSE CAST(cpl.RentHourPeriod AS varchar(10))
   END AS ''RentHourPeriod''
 FROM (Account a(NOLOCK) JOIN CashItemPresentLog cpl(NOLOCK)  
 ON a.AID = @AID AND cpl.ReceiverAID = a.AID) JOIN CashSetShop css(NOLOCK)  
 ON css.CSSID = cpl.CSSID  
 ORDER BY cpl.Date DESC  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetCashSetShopList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetCashSetShopList]
AS
 SET NOCOUNT ON
 SELECT CSSID, Name
 FROM CashSetShop(NOLOCK)
 ORDER BY CSSID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spRegularUpdateShopRanking]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [spRegularUpdateShopRanking]
AS
SET NOCOUNT ON
BEGIN
	BEGIN TRAN
		/* 원거리 무기 인기순위 */
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name LIKE ''#TempShopRankRange%'')
		DROP TABLE #TempShopRankRange
		
	
		SELECT TOP 5 IDENTITY(INT,1,1) Rank, ''range weapon'' AS Category, i.Name, COUNT(l.ItemID) AS Count, c.CSID, NULL AS CSSID, i.Slot,
			i.ResSex, i.ResLevel, c.CashPrice
		INTO #TempShopRankRange
		FROM ItemPurchaseLogByCash l(NOLOCK), Item i(NOLOCK), CashShop c(NOLOCK)
		WHERE Date > DATEADD(day, -7, GetDate()) AND i.Slot=2 AND l.ItemID=i.ItemID AND l.ItemID=c.ItemID
		GROUP BY l.ItemID, i.Slot, i.Name, c.CSID, i.ResSex, i.ResLevel, c.CashPrice
		ORDER BY Count DESC
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK
			RETURN (-1)
		END
		
		/* 근접 무기 인기순위 */
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name LIKE ''#TempShopRankMelee%'')
		DROP TABLE #TempShopRankMelee
		
		SELECT TOP 5 IDENTITY(INT,1,1) Rank, ''melee weapon'' AS Category, i.Name, COUNT(l.ItemID) AS Count, c.CSID, NULL AS CSSID, i.Slot,
			i.ResSex, i.ResLevel, c.CashPrice
		INTO #TempShopRankMelee
		FROM ItemPurchaseLogByCash l(NOLOCK), Item i(NOLOCK), CashShop c(NOLOCK)
		WHERE Date > DATEADD(day, -7, GetDate()) AND i.Slot=1 AND l.ItemID=i.ItemID AND l.ItemID=c.ItemID
		GROUP BY l.ItemID, i.Slot, i.Name, c.CSID, i.ResSex, i.ResLevel, c.CashPrice
		ORDER BY Count DESC
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK
			RETURN (-1)
		END
		
		/* 특수아이템 인기순위 */
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name LIKE ''#TempShopRankSpecial%'')
		DROP TABLE #TempShopRankSpecial
		
		SELECT TOP 5 IDENTITY(INT,1,1) Rank, ''specail item'' AS Category, i.Name, COUNT(l.ItemID) AS Count, c.CSID, NULL AS CSSID, i.Slot,
			i.ResSex, i.ResLevel, c.CashPrice
		INTO #TempShopRankSpecial
		FROM ItemPurchaseLogByCash l(NOLOCK), Item i(NOLOCK), CashShop c(NOLOCK)
		WHERE Date > DATEADD(day, -7, GetDate()) AND i.Slot=3 AND l.ItemID=i.ItemID AND l.ItemID=c.ItemID
		GROUP BY l.ItemID, i.Slot, i.Name, c.CSID, i.ResSex, i.ResLevel, c.CashPrice
		ORDER BY Count DESC
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK
			RETURN (-1)
		END
		
		/* 방어구 인기순위 */
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name LIKE ''#TempShopRankArmor%'')
		DROP TABLE #TempShopRankArmor
		
		SELECT TOP 5 IDENTITY(INT,1,1) Rank, ''defence'' AS Category, i.Name, COUNT(l.ItemID) AS Count, c.CSID, NULL AS CSSID, 
			CASE i.Slot 
				WHEN 0 THEN ''no limit''
				WHEN 1 THEN ''melee weapon''
				WHEN 2 THEN ''range weapon''
				WHEN 3 THEN ''item''
				WHEN 4 THEN ''haed''
				WHEN 5 THEN ''chest''
				WHEN 6 THEN ''hands''
				WHEN 7 THEN ''legs''
				WHEN 8 THEN ''feet''
				WHEN 9 THEN ''finger''
			END AS Slot, i.ResSex, i.ResLevel, c.CashPrice
		INTO #TempShopRankArmor
		FROM ItemPurchaseLogByCash l(NOLOCK), Item i(NOLOCK), CashShop c(NOLOCK)
		WHERE Date > DATEADD(day, -7, GetDate()) AND 4<=i.Slot AND i.Slot<=9 AND l.ItemID=i.ItemID AND l.ItemID=c.ItemID
		GROUP BY l.ItemID, i.Slot, i.Name, c.CSID, i.ResSex, i.ResLevel, c.CashPrice
		ORDER BY COUNT(l.ItemID) DESC
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK
			RETURN (-1)
		END
		
		/* 세트 인기순위 */
		IF EXISTS (SELECT name FROM tempdb.dbo.sysobjects WHERE name LIKE ''#TempShopRankSet%'')
		DROP TABLE #TempShopRankSet
		
		SELECT TOP 5 IDENTITY(INT,1,1) Rank, ''set'' AS Category, s.Name, COUNT(l.CSSID) AS Count, NULL AS CSID, l.CSSID, 
			''set'' AS Slot, s.ResSex, s.ResLevel, s.CashPrice
		INTO #TempShopRankSet
		FROM SetItemPurchaseLogByCash l(NOLOCK), CashSetShop s(NOLOCK)
		WHERE Date > DATEADD(day, -7, GetDate()) AND l.CSSID=s.CSSID
		GROUP BY l.CSSID, s.Name, s.ResSex, s.ResLevel, s.CashPrice
		ORDER BY Count DESC
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK
			RETURN (-1)
		END
		
		/* 샵랭킹 리셋 */
		DELETE FROM CashShopRank
		
		INSERT INTO CashShopRank (Rank, Category, Name, Count, CSID, CSSID, Slot, ResSex, ResLevel, CashPrice)
			 SELECT * FROM #TempShopRankRange
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK
			RETURN (-1)
		END

		INSERT INTO CashShopRank (Rank, Category, Name, Count, CSID, CSSID, Slot, ResSex, ResLevel, CashPrice)
			SELECT * FROM #TempShopRankMelee
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK
			RETURN (-1)
		END

		INSERT INTO CashShopRank (Rank, Category, Name, Count, CSID, CSSID, Slot, ResSex, ResLevel, CashPrice)
			SELECT * FROM #TempShopRankSpecial
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK
			RETURN (-1)
		END

		INSERT INTO CashShopRank (Rank, Category, Name, Count, CSID, CSSID, Slot, ResSex, ResLevel, CashPrice)
			SELECT * FROM #TempShopRankArmor
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK
			RETURN (-1)
		END

		INSERT INTO CashShopRank (Rank, Category, Name, Count, CSID, CSSID, Slot, ResSex, ResLevel, CashPrice)
			SELECT * FROM #TempShopRankSet
		IF @@ERROR <> 0
		BEGIN
			ROLLBACK
			RETURN (-1)
		END
		
		DROP TABLE #TempShopRankRange
		DROP TABLE #TempShopRankMelee
		DROP TABLE #TempShopRankSpecial
		DROP TABLE #TempShopRankArmor
		DROP TABLE #TempShopRankSet
	COMMIT TRAN
	RETURN (1)
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spPresentCashSetItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


--------------------------------------------------------------------------------


CREATE  PROC [spPresentCashSetItem]
	@SenderUserID	varchar(20)
,	@ReceiverUserID	varchar(20)
,	@CSSID		int
,	@Cash		int
,	@RentHourPeriod	smallint = NULL
, 	@MobileCode char(16) = NULL
AS
	SET NoCount On

	DECLARE @ReceiverAID	int

	SELECT @ReceiverAID = AID FROM Account WHERE UserID = @ReceiverUserID

	IF @ReceiverAID IS NOT NULL
	BEGIN
		DECLARE @RentDate		datetime			

		-- @RentHourPeriod값을 가지고 기간제인지 검사.
		IF @RentHourPeriod = 0 OR @RentHourPeriod IS NULL
		BEGIN
			-- 기간제 아이템일 경우 영구 아이템 판매 여부 검사
			DECLARE @RentType 	TINYINT
			DECLARE @RCSSPID	INT

			SELECT @RentType = RentType FROM CashSetShop WHERE CSSID=@CSSID
			IF @RentType = 1
			BEGIN
				SELECT @RCSSPID = RCSSPID FROM RentCashSetShopPrice WHERE CSSID=@CSSID AND RentHourPeriod is NULL
				IF @RCSSPID IS NULL
				BEGIN
					RETURN 0
				END
			END

			-- 일반 아이템일 경우
			SET @RentDate = NULL
		END
		ELSE
		BEGIN
			SET @RentDate = GETDATE()
		END


		BEGIN TRAN
			DECLARE curBuyCashSetItem 	INSENSITIVE CURSOR

			FOR
				SELECT CSID FROM CashSetItem WHERE CSSID = @CSSID
			FOR READ ONLY

			OPEN curBuyCashSetItem

			DECLARE @varCSID	int
			DECLARE @ItemID		int

			FETCH FROM curBuyCashSetItem INTO @varCSID

			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @ItemID = ItemID FROM CashShop WHERE CSID = @varCSID

				IF @ItemID IS NOT NULL
				BEGIN	
					-- 아이템 생성.
					INSERT INTO AccountItem (AID, ItemID, RentDate, RentHourPeriod)
					VALUES (@ReceiverAID, @ItemID, @RentDate, @RentHourPeriod)
					
					IF @@ERROR <> 0
					BEGIN
						ROLLBACK
						CLOSE curBuyCashSetItem
						DEALLOCATE curBuyCashSetItem
						RETURN 0
					END					
				END
				
				FETCH FROM curBuyCashSetItem INTO @varCSID
			END

		CLOSE curBuyCashSetItem
		DEALLOCATE curBuyCashSetItem

		-- 셋트아이템 선물 로그 생성.
		INSERT INTO CashItemPresentLog (SenderUserID, ReceiverAID, CSSID, Date, RentHourPeriod, Cash, MobileCode)
		VALUES (@SenderUserID, @ReceiverAID, @CSSID, GETDATE(), @RentHourPeriod, @Cash, @MobileCode)

		IF @@ERROR <> 0
		BEGIN
			ROLLBACK
			RETURN 0
		END
				
		COMMIT TRAN
		RETURN 1

	END
	ELSE
	BEGIN
		RETURN 0
	END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetSetItemPurchaseLogByCash]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetSetItemPurchaseLogByCash]  
 @AID int  
AS  
 SET NOCOUNT ON  
 SELECT sipl.id, a.UserID AS SenderUserID, a.UserID AS ReceiverUserID
  , css.Name AS ItemName, sipl.Date, sipl.Cash  
  , CASE ISNULL(sipl.RentHourPeriod, 0)
   WHEN 0 THEN ''0''
   ELSE CAST(sipl.RentHourPeriod AS varchar(10))
  END AS ''RentHourPeriod''
 FROM (Account a(NOLOCK) JOIN SetItemPurchaseLogByCash sipl(NOLOCK)  
 ON a.AID = @AID AND sipl.AID = a.AID) JOIN CashSetShop css(NOLOCK)  
 ON css.CSSID = sipl.CSSID  
 ORDER BY Date DESC  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebInsertCashSetShopItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebInsertCashSetShopItem]
 @Name varchar(64)
, @ResSex tinyint
, @ResLevel int
, @Weight int
, @Description varchar(1024)
, @Opened tinyint
, @CashPrice int
, @WebImgName varchar(64)
, @RentType tinyint
, @Ret int OUTPUT
AS
 SET NOCOUNT ON 
 IF (@Name IS NULL) OR (@ResSex IS NULL) OR (@ResLevel IS NULL) 
  OR (@Weight IS NULL) OR (@Description IS NULL) OR (@Opened IS NULL)
  OR (@CashPrice IS NULL) OR (@WebImgName IS NULL) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 declare @cssid int
 select @cssid = max(cssid) + 1 from CashSetShop(nolock)

 INSERT INTO CashSetShop(cssid, Name, ResSex, ResLevel, Weight, Description, Opened,
  CashPrice, WebImgName, RentType, RegDate)
 VALUES (@cssid, @Name, @ResSex, @ResLevel, @Weight, @Description, @Opened,
  @CashPrice, @WebImgName, @RentType, GETDATE())
 IF 0 <> @@ERROR BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = @cssid
 RETURN @Ret


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebInsertSetItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebInsertSetItem]
	@UserID varchar( 20 )
,	@CSSID int
,	@RentHourPeriod smallint
,	@GMID varchar(20)
,	@Ret int OUTPUT
AS 
 SET NOCOUNT ON
  
 DECLARE @AID  int  
   
 SELECT @AID = AID FROM Account WHERE UserID = @UserID  
  
 -- 존제하는 유저인지 검사.  
 IF @AID IS NULL  
 BEGIN  
  SET @Ret = 0
  RETURN @Ret
 END  
 ELSE  
 BEGIN  
  DECLARE @RentDate  datetime     
  
  -- @RentHourPeriod값을 가지고 기간제인지 검사.  
  IF @RentHourPeriod = 0 OR @RentHourPeriod IS NULL  
  BEGIN  
   -- 기간제 아이템일 경우 영구 아이템 판매 여부 검사  
   DECLARE @RentType  TINYINT  
   DECLARE @RCSSPID  INT  
  
   SELECT @RentType = RentType FROM CashSetShop WHERE CSSID=@CSSID  
   IF @RentType = 1  
   BEGIN  
    SELECT @RCSSPID = RCSSPID FROM RentCashSetShopPrice WHERE CSSID=@CSSID AND RentHourPeriod is NULL  
    IF @RCSSPID IS NULL  
    BEGIN  
     SET @Ret = 0
     RETURN @Ret
    END  
   END  
  
   -- 일반 아이템일 경우  
   SET @RentDate = NULL  
  END  
  ELSE  
  BEGIN  
   SET @RentDate = GETDATE()  
  END  
      
  BEGIN TRAN  
  
  DECLARE curBuyCashSetItem  INSENSITIVE CURSOR  
  
  FOR  
   SELECT CSID FROM CashSetItem (NOLOCK) WHERE CSSID = @CSSID  
  FOR READ ONLY  
  
  OPEN curBuyCashSetItem   
  
  DECLARE @varCSID  int  
  DECLARE @ItemID   int  
  
  FETCH FROM curBuyCashSetItem INTO @varCSID  
  
  WHILE @@FETCH_STATUS = 0  
  BEGIN  
   SELECT @ItemID = cs.ItemID  
   FROM CashShop cs (NOLOCK)   
   WHERE cs.CSID = @varCSID   
  
   IF @ItemID IS NOT NULL  
   BEGIN  
    -- 아이템 생성.  
    INSERT INTO AccountItem(AID, ItemID, RentDate, RentHourPeriod)  
    VALUES (@AID, @ItemID, @RentDate, @RentHourPeriod)  
   END  
  
   FETCH curBuyCashSetItem  INTO @varCSID  
  END  
  
  CLOSE curBuyCashSetItem   
  DEALLOCATE curBuyCashSetItem   
  
  -- GM로그 기록.
  
  COMMIT TRAN  
  SET @Ret = 1
  RETURN @Ret
 END 


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[viewCashSetItemPresentLog]'))
EXEC dbo.sp_executesql @statement = N'

--------------------

CREATE   VIEW [viewCashSetItemPresentLog] -- M
AS

SELECT cpl.id AS id, cpl.SenderUserID AS SenderUserID, a.UserID AS ReceiverUserID, 
css.Name AS SetItemName, cpl.Date AS Date, MobileCode
FROM CashItemPresentLog cpl, Account a(nolock), CashSetShop css(nolock)
WHERE cpl.ReceiverAID=a.AID AND cpl.CSSID IS Not NULL AND cpl.cssid=css.cssid

' 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spCashShopGetRankedList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [spCashShopGetRankedList]
	@Category	varchar(32)
	-- @Category : 원거리무기, 근접무기, 특수아이템, 방어구, 세트
AS
SET NOCOUNT ON
BEGIN
	IF (@Category = ''세트'')
	BEGIN
		SELECT TOP 5 r.Category, r.Rank, r.Name, r.CSID, r.CSSID, r.Slot, r.ResSex, r.ResLevel, r.CashPrice, r.RegDate, s.WebImgName
		FROM CashShopRank r(NOLOCK), CashSetShop s(NOLOCK)
		WHERE r.CSSID=s.CSSID AND Category=@Category AND s.Opened=1
	END
	ELSE
	BEGIN
		SELECT TOP 5 r.Category, r.Rank, r.Name, r.CSID, r.CSSID, r.Slot, r.ResSex, r.ResLevel, r.CashPrice, r.RegDate, s.WebImgName
		FROM CashShopRank r(NOLOCK), CashShop s(NOLOCK)
		WHERE r.CSID=s.CSID AND Category=@Category AND s.Opened=1
	END
END




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spCashShopNewItemList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE   PROC [spCashShopNewItemList]
	@IsSetItem		INT
AS
BEGIN
	IF @IsSetItem=0
	BEGIN
		SELECT TOP 4 n.* FROM CashShopNewItem n(NOLOCK), CashShop c(NOLOCK)
		WHERE n.CSID=c.CSID AND c.Opened=1 AND IsSetItem=0 ORDER BY NewOrder
	END
	ELSE
	BEGIN
		SELECT TOP 4 n.* FROM CashShopNewItem n(NOLOCK), CashSetShop c(NOLOCK)
		WHERE n.CSSID=c.CSSID AND c.Opened=1 AND  IsSetItem=1 ORDER BY NewOrder
	END
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spBuyCashSetItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE    PROC [spBuyCashSetItem]      
 @UserID  varchar(20),      
 @CSSID  int,      
 @Cash  int,      
 @RentHourPeriod smallint = NULL,      
 @MobileCode char(16) = NULL      
AS      
 SET NoCount On      
    
 IF NOT EXISTS(SELECT CSSID FROM CashSetShop(NOLOCK) WHERE CSSID = @CSSID)     
  RETURN 0    
      
 DECLARE @AID  int      
       
 SELECT @AID = AID FROM Account WHERE UserID = @UserID      
      
 -- 존제하는 유저인지 검사.      
 IF @AID IS NULL      
 BEGIN      
  RETURN 0      
 END      
 ELSE      
 BEGIN      
  DECLARE @RentDate  datetime         
    
    
      
  -- @RentHourPeriod값을 가지고 기간제인지 검사.      
  IF @RentHourPeriod = 0 OR @RentHourPeriod IS NULL      
  BEGIN      
   -- 기간제 아이템일 경우 영구 아이템 판매 여부 검사      
   DECLARE @RentType  TINYINT      
   DECLARE @RCSSPID  INT      
      
   SELECT @RentType = RentType FROM CashSetShop WHERE CSSID=@CSSID      
   IF @RentType = 1      
   BEGIN      
    SELECT @RCSSPID=RCSSPID FROM RentCashSetShopPrice WHERE CSSID=@CSSID AND RentHourPeriod is NULL      
    IF @RCSSPID IS NULL      
    BEGIN      
     RETURN 0      
    END      
   END      
      
   -- 일반 아이템일 경우      
   SET @RentDate = NULL      
  END      
  ELSE      
  BEGIN      
   SET @RentDate = GETDATE()      
  END      
      
      
      
  BEGIN TRAN      
      
   DECLARE curBuyCashSetItem  INSENSITIVE CURSOR      
   FOR      
    SELECT CSID FROM CashSetItem (NOLOCK) WHERE CSSID = @CSSID      
   FOR READ ONLY      
       
   OPEN curBuyCashSetItem       
       
   DECLARE @varCSID  int      
   DECLARE @ItemID   int      
       
   FETCH FROM curBuyCashSetItem INTO @varCSID      
       
   WHILE @@FETCH_STATUS = 0      
   BEGIN      
    SELECT @ItemID = cs.ItemID      
    FROM CashShop cs (NOLOCK)       
    WHERE cs.CSID = @varCSID       
       
    IF @ItemID IS NOT NULL      
    BEGIN      
     -- 아이템 생성.      
     INSERT INTO AccountItem(AID, ItemID, RentDate, RentHourPeriod)      
     VALUES (@AID, @ItemID, @RentDate, @RentHourPeriod)      
           
     IF @@ERROR <> 0      
     BEGIN      
      ROLLBACK      
      CLOSE curBuyCashSetItem       
      DEALLOCATE curBuyCashSetItem       
      RETURN 0      
     END           
    END      
       
    FETCH curBuyCashSetItem  INTO @varCSID      
   END      
       
   CLOSE curBuyCashSetItem       
   DEALLOCATE curBuyCashSetItem       
       
   -- 셋트 아이템 구입 로그.      
   INSERT INTO SetItemPurchaseLogByCash (AID, CSSID, Date, RentHourPeriod, Cash, MobileCode)      
   VALUES (@AID, @CSSID, GETDATE(), @RentHourPeriod, @Cash, @MobileCode)      
      
   IF @@ERROR <> 0      
   BEGIN      
    ROLLBACK      
    RETURN 0      
   END      
             
  COMMIT TRAN      
  RETURN 1      
 END      
    
  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[viewSetItemPurchaseLogByCash]'))
EXEC dbo.sp_executesql @statement = N'

---------------------------------

CREATE   VIEW [viewSetItemPurchaseLogByCash] -- M
AS
SELECT id, a.UserID AS UserID, css.Name AS SetItemName, sipl.Date AS Date, sipl.Cash, MobileCode
FROM SetItemPurchaseLogByCash sipl, Account a, CashSetShop css
WHERE sipl.AID = a.AID AND css.cssid = sipl.cssid

' 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebUpdateCashSetShopItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebUpdateCashSetShopItem]  
 @CSSID int  
, @Name varchar(64)
, @ResSex tinyint  
, @ResLevel int  
, @Weight int  
, @Description varchar(1024)
, @Opened tinyint  
, @CashPrice int  
, @WebImgName varchar(64)  
, @RentType tinyint
, @Ret int OUTPUT  
 AS  
 SET NOCOUNT ON  
 IF (@CSSID IS NULL) OR (@ResSex IS NULL) OR (@Weight IS NULL)  
  OR (@Opened IS NULL) OR (@Description IS NULL ) OR (@CashPrice IS NULL)
  OR (@WebImgName IS NULL) OR (@RentType IS NULL) OR (@Name IS NULL) BEGIN  
  SET @Ret = 0  
  RETURN @Ret  
 END  
  
 UPDATE CashSetShop  
 SET ResSex = @ResSex, ResLevel = @ResLevel, Weight = @Weight,   
  Description = @Description, Opened = @Opened, CashPrice = @CashPrice,   
  WebImgName = @WebImgName, RentType = @RentType, Name = @Name
 WHERE CSSID = @CSSID  
 IF 0 = @@ROWCOUNT BEGIN  
  SET @Ret = 0  
  RETURN   
 END  
  
 SET @Ret = 1  
 RETURN @Ret  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebUpdateCashShopNewItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebUpdateCashShopNewItem]
 @NewOrder int
, @CSID int
, @CSSID int
, @IsSetItem int
, @CategoryID int
, @Ret int OUTPUT
AS
 SET NOCOUNT ON

 DECLARE @Category varchar(12)
 SELECT @Category = Description FROM CashShopNewItemCategory(NOLOCK)
 WHERE CategoryID = @CategoryID

 IF 0 = @IsSetItem BEGIN
  UPDATE CashShopNewItem 
  SET Category = @Category, NewOrder = @NewOrder, IsSetItem = @IsSetItem,
   CSID = @CSID, CSSID = @CSSID, Slot = ist.Description, Name = i.Name,
   ResSex = i.ResSex, ResLevel = i.ResLevel, CashPrice = cs.CashPrice, 
   WebImgName = cs.WebImgName, RegDate = cs.RegDate
  FROM (Item i(NOLOCK) JOIN CashShop cs(NOLOCK)
  ON cs.CSID = @CSID AND i.ItemID = cs.ItemID) 
   JOIN ItemSlotType ist(NOLOCK) ON ist.SlotType = i.Slot
  WHERE NewOrder = @NewOrder
  IF 0 = @@ROWCOUNT BEGIN
   SET @Ret = 0
   RETURN @Ret
  END
 END
 ELSE IF 1 = @IsSetItem BEGIN
  UPDATE CashShopNewItem
  SET Category = @Category, NewOrder = @NewOrder, IsSetItem = @IsSetItem,
   CSID = @CSID, CSSID = @CSSID, Slot = ist.Description, Name = css.Name,
   ResSex = css.ResSex, ResLevel = css.ResLevel, CashPrice = css.CashPrice,
   WebImgName = css.WebImgName, RegDate = css.RegDate
  FROM CashSetShop css(NOLOCK) JOIN ItemSlotType ist(NOLOCK)
  ON css.CSSID = @CSSID AND ist.SlotType = 10
  WHERE NewOrder = @NewOrder
  IF 0 = @@ROWCOUNT BEGIN
   SET @Ret = 0
   RETURN @Ret
  END
 END

 SET @Ret = 1
 RETURN @Ret


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetCashSetItemImageFile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 캐쉬 세트아이템 이미지파일 알아오기
CREATE PROC [spGetCashSetItemImageFile]
	@CSSID			int
,	@RetImageFileName	varchar(64) OUTPUT
AS
SET NOCOUNT ON

SELECT @RetImageFileName=WebImgName FROM CashSetShop css(nolock) WHERE CSSID=@CSSID

RETURN 1


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetCashSetItemInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 세트아이템의 상세 정보 보기 */
CREATE  PROC [spGetCashSetItemInfo]
	@CSSID	int
AS
	SET NOCOUNT ON

	SELECT CSSID AS CSSID, Name AS Name, CashPrice AS Cash, WebImgName AS WebImgName, 
	ResSex AS ResSex, ResLevel AS ResLevel, Weight AS Weight,
	Description AS Description, NewItemOrder As IsNewItem, RentType AS RentType

	FROM CashSetShop css(nolock)
	WHERE CSSID = @CSSID



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetCashSetItemList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 세트아이템 목록 보기 */
CREATE PROC [spGetCashSetItemList]
	@Page		int,
	@PageCount	int OUTPUT
AS
SET NoCount On
DECLARE @Rows int
DECLARE @ViewCount int

DECLARE @PageSize INT
SELECT @PageSize = 8		/* 한페이지에 8개씩 보여준다 */

DECLARE @PageHead INT
DECLARE @RowCount INT

SELECT @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize FROM CashSetShop css(nolock) WHERE css.Opened=1
SELECT @RowCount = ((@Page -1) * @PageSize + 1)

SET ROWCOUNT @RowCount
SELECT @PageHead = css.CSSID FROM CashSetShop css(nolock)
WHERE css.Opened=1
ORDER BY css.cssid DESC


SET ROWCOUNT @PageSize
SELECT CSSID AS CSSID, Name AS Name, CashPrice AS Cash, WebImgName AS WebImgName, 
	ResSex AS ResSex, ResLevel AS ResLevel, Weight AS Weight,
	Description AS Description, RegDate AS RegDate, NewItemOrder AS IsNewItem,
	RentType AS RentType
FROM CashSetShop css(nolock)
WHERE cssid <= @PageHead AND css.Opened=1
ORDER BY css.cssid DESC


SET ROWCOUNT 0



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spCashShopNewItemUpdate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [spCashShopNewItemUpdate]
	@NewOrder		INT,
	@IsSetItem		INT,
	@CSID			INT,
	@CSSID			INT
AS
SET NOCOUNT ON
BEGIN

	IF EXISTS(SELECT id FROM CashShopNewItem(NOLOCK) WHERE NewOrder=@NewOrder)
	BEGIN
		DELETE CashShopNewItem WHERE NewOrder=@NewOrder
	END

	IF @IsSetItem = 0
	BEGIN
		INSERT INTO CashShopNewItem (NewOrder, Category, IsSetItem, CSID, CSSID, Slot, Name, ResSex, ResLevel, CashPrice, WebImgName)
		SELECT @NewOrder AS NewOrder, 
			CASE i.Slot 
				WHEN 0 THEN ''제한없음''
				WHEN 1 THEN ''근접무기''
				WHEN 2 THEN ''원거리무기''
				WHEN 3 THEN ''특수아이템''
				WHEN 4 THEN ''방어구''
				WHEN 5 THEN ''방어구''
				WHEN 6 THEN ''방어구''
				WHEN 7 THEN ''방어구''
				WHEN 8 THEN ''방어구''
				WHEN 9 THEN ''방어구''
			END AS Category, 
			@IsSetItem, s.CSID, NULL AS CSSID,
			CASE i.Slot 
				WHEN 0 THEN ''제한없음''
				WHEN 1 THEN ''근접무기''
				WHEN 2 THEN ''원거리무기''
				WHEN 3 THEN ''아이템''
				WHEN 4 THEN ''머리''
				WHEN 5 THEN ''가슴''
				WHEN 6 THEN ''손''
				WHEN 7 THEN ''다리''
				WHEN 8 THEN ''발''
				WHEN 9 THEN ''손가락''
			END AS Slot, 
			i.Name, i.ResSex, i.ResLevel, CashPrice, s.WebImgName
		FROM CashShop s(NOLOCK), Item i(NOLOCK) 
		WHERE s.ItemID=i.ItemID AND CSID=@CSID
	END
	ELSE
	BEGIN
		INSERT INTO CashShopNewItem (NewOrder, Category, IsSetItem, CSID, CSSID, Slot, Name, ResSex, ResLevel, CashPrice, WebImgName)
		SELECT @NewOrder AS NewOrder, ''세트'', @IsSetItem, NULL AS CSID, CSSID, ''세트'' AS Slot, Name, ResSex, ResLevel, CashPrice, WebImgName
		FROM CashSetShop(NOLOCK)
		WHERE CSSID=@CSSID
	END
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetCashSetItemImageFile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 캐쉬 세트아이템 이미지파일과 아이템 이름 알아오기.
CREATE PROC [spWebGetCashSetItemImageFile]
 	@CSSID   int  
, 	@RetImageFileName varchar(64) OUTPUT  
,	@RetSetItemName varchar(64) OUTPUT
AS  
SET NOCOUNT ON
BEGIN
	SELECT @RetImageFileName = css.WebImgName, @RetSetItemName = css.Name
	FROM CashSetShop css(NOLOCK)
	WHERE css.CSSID=@CSSID  
  
	RETURN 1  
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetAccountMaxLevel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [spWebGetAccountMaxLevel]
	@UserID varchar(20)
AS
BEGIN
	SET NOCOUNT ON
	SELECT MAX(c.Level) FROM Account a(NOLOCK), Character c(NOLOCK)
	WHERE a.UserID=@UserID AND a.AID=c.AID AND c.DeleteFlag=0
END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetCLIDbyUserID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spWebGetCLIDbyUserID]  
 @UserID varchar(20)  
AS  
 SET NOCOUNT ON
 SELECT cm.CLID  
 FROM Account ac(NOLOCK), Character ch(NOLOCK), ClanMember cm(NOLOCK)  
 WHERE ac.UserID = @UserID AND ch.AID = ac.AID AND cm.CID  = ch.CID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spCheckRegisteredUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



CREATE   PROC [spCheckRegisteredUser]
	@UserID VARCHAR(20)
AS
BEGIN
 SET NOCOUNT ON
	DECLARE @AID INT

	SELECT @AID = AID FROM Account WHERE UserID = @UserID

	IF @@ERROR <> 0
	BEGIN
		RETURN	-- 디비장애
	END

	IF @AID IS NULL
	BEGIN
		RETURN -1	-- 미가입자
	END
		select 1
	RETURN 1 -- 가입자 확인
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spConfirmBuyCashItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 일반 아이템 구매가능인지 확인하기 */
CREATE PROC [spConfirmBuyCashItem]
	@UserID								varchar(20),
	@CSID									int,
	@RetEnableBuyItem			int OUTPUT,
	@RetRepeatBuySameItem	int OUTPUT
AS
SET NoCount On
	
DECLARE @AID		int
DECLARE @ItemID	int
DECLARE @AIID		int


SELECT @AID = AID FROM Account(nolock) where UserID = @UserID
SELECT @ItemID = ItemID FROM CashShop(nolock) WHERE CSID=@CSID

IF @AID IS NULL
BEGIN
	SELECT @RetEnableBuyItem = 0
	SELECT @RetRepeatBuySameItem = 0
END
ELSE
BEGIN
	SELECT @RetEnableBuyItem = 1


	IF (@ItemID IS NOT NULL)
	BEGIN
		SELECT TOP 1 @AIID = AIID FROM AccountItem(nolock) WHERE AID=@AID AND ItemID=@ItemID
		IF (@AIID IS NOT NULL)
		BEGIN
			SELECT @RetRepeatBuySameItem = 1
		END
		ELSE
		BEGIN
			SELECT @RetRepeatBuySameItem = 0
		END
	END
	ELSE
	BEGIN
		SELECT @RetRepeatBuySameItem = 0
	END


END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spConfirmBuyCashSetItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



/* 세트 아이템 구매가능인지 확인하기 */
CREATE PROC [spConfirmBuyCashSetItem]
	@UserID								varchar(20),
	@CSSID								int,
	@RetEnableBuyItem			int OUTPUT,
	@RetRepeatBuySameItem	int OUTPUT
AS
SET NoCount On
	
DECLARE @AID		int
DECLARE @SIL_ID	int
DECLARE @LAST_ID int

SELECT @AID = AID FROM Account(nolock) where UserID = @UserID


IF @AID IS NULL
BEGIN
	SELECT @RetEnableBuyItem = 0
	SELECT @RetRepeatBuySameItem = 0
END
ELSE
BEGIN
	SELECT @RetEnableBuyItem = 1

	SELECT TOP 1 @LAST_ID = id FROM SetItemPurchaseLogByCash spl(nolock) order by id desc

	SELECT TOP 1 @SIL_ID = id FROM SetItemPurchaseLogByCash spl(nolock) 
	WHERE id > (@LAST_ID-10000) AND AID=@AID AND CSSID=@CSSID

	IF (@SIL_ID IS NOT NULL)
	BEGIN
		SELECT @RetRepeatBuySameItem = 1
	END
	ELSE
	BEGIN
		SELECT @RetRepeatBuySameItem = 0
	END

END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spFetchTotalRanking]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 전체 랭킹을 산출한다. - 디비 에이전트에서 실행시키는 프로시져 */
CREATE PROC [spFetchTotalRanking]
AS
SET NOCOUNT ON
TRUNCATE TABLE TotalRanking

INSERT into TotalRanking(UserID, Name, Level, XP, KillCount, DeathCount)

SELECT Account.UserID, c.name, c.Level, c.XP, c.KillCount, c.DeathCount
FROM Character c(nolock), Account(nolock)
WHERE Account.AID=c.aid AND c.DeleteFlag=0 AND c.XP >= 500
ORDER BY c.xp DESC, c.KillCount DESC, c.DeathCount ASC, c.PlayTime DESC


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebLeaveClan]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 자신의 클랜 탈퇴.
CREATE PROC [spWebLeaveClan]
	@CharName varchar(24) /* 캐릭터 이름 */
AS
BEGIN TRAN
	SET NOCOUNT ON

	DECLARE @CLID int
	DECLARE @CID int
	DECLARE @MasterCID int

	-- 존재하는 아이디인가?
	SELECT @CLID = cm.CLID, @CID = c.CID, @MasterCID = cl.MasterCID
	FROM Account a (NOLOCK), Character c (NOLOCK), Clan cl(NOLOCK), ClanMember cm (NOLOCK)
	WHERE c.Name = @CharName AND a.AID = c.AID AND cm.CID = c.CID AND cl.CLID = cm.CLID

	-- 클랜마스터가 아니고 클랜에 가입되 있을 경우만.
	IF (@CID IS NULL) OR (@MasterCID = @CID) OR (@CLID IS NULL)
	BEGIN
		ROLLBACK TRAN
		SET NOCOUNT OFF 
		RETURN
	END
		
	DELETE ClanMember WHERE CID = @CID
	IF 0 <> @@ERROR
	BEGIN
		ROLLBACK TRAN
		SET NOCOUNT OFF 
		RETURN
	END

	SET NOCOUNT OFF 
COMMIT TRAN


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebItemUseLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 캐쉬아이템 사용기록
CREATE     PROC [spWebItemUseLog]
	@UserID		VARCHAR(32)
AS
SET NOCOUNT ON
BEGIN

	DECLARE @TargetAID INT
	SELECT @TargetAID = AID FROM Account(NOLOCK) WHERE UserID=@UserID

	SELECT l.AID, l.CID, c.Name AS CharName, i.ItemID, i.Name AS ItemName, l.Date, c.DeleteName 
	FROM BringAccountItemLog l(NOLOCK), Item i(NOLOCK), Character c(NOLOCK)
	WHERE l.AID=@TargetAID AND l.CID=c.CID AND l.ItemID=i.ItemID
	ORDER BY  Date DESC
END




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetMyClanList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



-- 가입한 클랜 리스트를 Ranking으로 정렬해서 보여줌. 클랜이 중복으로 보일수 있음.
CREATE PROC [spWebGetMyClanList]
	@UserID varchar(20) /* 넷마블 아이디 */
AS
SET NOCOUNT ON
BEGIN
	SELECT t.Ranking, t.RankIncrease, t.ClanName, t.Point, t.Wins, t.Losses, t.CLID, t.EmblemUrl, ch.Name AS Master, t.RegDate
	FROM 
	(
		SELECT cl.CLID, cl.Name AS ClanName, cl.Point, cl.Wins, cl.Losses, cl.EmblemUrl, cl.Ranking, cl.RankIncrease, cl.MasterCID, cl.RegDate
		FROM Account ac (NOLOCK), Character ch(NOLOCK), ClanMember cm(NOLOCK), Clan cl(NOLOCK)
		WHERE ac.UserID = @UserID AND ac.AID = ch.AID AND cm.CID = ch.CID AND cl.CLID = cm.CLID
	) AS t, Character ch(NOLOCK)
	WHERE t.MasterCID = ch.CID ORDER BY t.Ranking DESC
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebInsertAccount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-------------------------------------------------------------------

 CREATE    PROC [spWebInsertAccount]   
 @UserID varchar(20)  
, @Password varchar(20)  
, @Cert tinyint  
, @Name varchar(30)  
, @Age smallint  
, @Country char(3)  
, @Sex tinyint  
, @Email varchar(50)=NULL  
, @Ret int OutPut  
AS  
 SET NOCOUNT ON  
 DECLARE @AIDIdent int  
  
 BEGIN TRAN  
 INSERT INTO Account (UserID, Cert, Name, Age, Sex, UGradeID, PGradeID, RegDate, Email,  Country)  
 VALUES (@UserID, @Cert, @Name, @Age, @Sex, 0, 0, GETDATE(), @Email,  @Country)  
 IF @@ERROR <> 0 BEGIN  
  ROLLBACK TRAN  
  SET @Ret = 0  
  RETURN @Ret   
 END  
  
 SET @AIDIdent = @@IDENTITY  
 INSERT INTO login(UserID, AID, Password)  
 VALUES (@UserID, @AIDIdent, @Password)  
 IF @@ERROR <> 0 BEGIN  
  ROLLBACK TRAN  
  SET @Ret = 0  
  RETURN @Ret   
 END  
 COMMIT TRAN  
  
 SET @Ret = 1  
 RETURN @Ret  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetMyClanInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- My랭킹정보.
CREATE PROC [spWebGetMyClanInfo]
	@CharName varchar(24) /* 캐릭터 이름 */
AS
SET NOCOUNT ON
BEGIN
	DECLARE @CLID int

	SELECT @CLID = cm.CLID 
	FROM Account a (NOLOCK), Character c (NOLOCK), ClanMember cm (NOLOCK)
	WHERE c.Name = @CharName AND a.AID = c.AID AND cm.CID = c.CID

	IF @CLID IS NOT NULL
	BEGIN
		SELECT cl.Name, ch.Name AS Master, cl.IntroDuction, cl.RegDate, cl.Homepage, cl.EmblemUrl, cl.Ranking
		FROM Clan cl(NOLOCK), Character ch(NOLOCK)
		WHERE cl.CLID = @CLID AND cl.DeleteFlag = 0 AND ch.CID = cl.MasterCID
	END
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetAccountInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE  PROC [spGetAccountInfo]
 @AID  int      
, @ServerID int = 0
AS    
BEGIN  
 SET NOCOUNT ON    

 SELECT AID, UserID, UGradeID, Name, HackingType
 , DATEPART(yy, EndHackingBlockTime) AS HackBlockYear, DATEPART(mm, EndHackingBlockTime) AS HackBlockMonth    
 , DATEPART(dd, EndHackingBlockTime) AS HackBlockDay, DATEPART(hh, EndHackingBlockTime) AS HackBlockHour    
 , DATEPART(mi, EndHackingBlockTime) AS HackBlockMin
 FROM Account(NOLOCK) WHERE AID = @AID      

 update Account set LastLoginTime = getdate(), ServerID = @ServerID  where aid = @aid  
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[viewItemPurchaseLogByCash]'))
EXEC dbo.sp_executesql @statement = N'

-----------------------------

CREATE   VIEW [viewItemPurchaseLogByCash]  -- M
AS
SELECT ipl.id AS id, a.UserID AS UserID, i.Name AS ItemName, ipl.Date AS Date, ipl.Cash AS Cash, ipl.MobileCode
FROM ItemPurchaseLogByCash ipl, Account a, Item i
WHERE ipl.AID = a.AID AND ipl.ItemID=i.ItemID

' 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebCheckRegisteredUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE   PROC [spWebCheckRegisteredUser]  
 @UserID VARCHAR(20),  
 @Ret int Output  
AS  
 SET NOCOUNT ON  
 DECLARE @AID INT  
 SELECT @AID = AID FROM Account(NOLOCK) WHERE UserID = @UserID  
 IF @@ERROR <> 0 BEGIN  
  SET @Ret = 0  
  RETURN @Ret -- 디비장애  
 END  
  
 IF @AID IS NULL BEGIN  
  SET @Ret = -1  
  RETURN @Ret  -- 미가입자  
 END  
   
 SET @Ret = 1   
 RETURN @Ret -- 가입자 확인  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spBuyCashItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
--------------------------------------------------------------------------------    
    
-- cash shop에서 거래된 아이템을 accountitme에 추가.    
CREATE   PROC [spBuyCashItem]    
 @UserID  varchar(20),    
 @CSID  int,    
 @Cash  int,    
 @RentHourPeriod smallint = NULL,    
 @MobileCode char(16) = NULL    
AS    
 SET NoCount On    
    
 DECLARE @AID  int    
 DECLARE @ItemID  int    
    
 -- Account 검사    
 SELECT @AID = AID FROM Account WHERE UserID = @UserID    
 IF @AID IS NULL    
 BEGIN    
  RETURN 0    
 END    
 ELSE    
 BEGIN    
  SELECT @ItemID = ItemID FROM CashShop cs (NOLOCK) WHERE cs.CSID = @CSID    
    
  IF @ItemID IS NOT NULL    
  BEGIN     
   DECLARE @RentDate datetime    
    
   -- @RentHourPeriod값을 가지고 기간제인지 검사.    
   IF @RentHourPeriod = 0 OR @RentHourPeriod IS NULL    
   BEGIN    
    -- 기간제 아이템일 경우 영구 아이템 판매 여부 검사    
    DECLARE @RentType  TINYINT    
    DECLARE @RCSPID  INT    
    
    SELECT @RentType = RentType FROM CashShop WHERE CSID=@CSID    
    IF @RentType = 1    
    BEGIN    
     SELECT @RCSPID = RCSPID FROM RentCashShopPrice WHERE CSID=@CSID AND RentHourPeriod is NULL    
     IF @RCSPID IS NULL    
     BEGIN    
      RETURN 0    
     END    
    END    
    
    -- 일반 아이템인 경우    
    SET @RentDate = NULL    
   END    
   ELSE    
   BEGIN    
    SET @RentDate = GETDATE()    
   END    
    
    
   BEGIN TRAN tranBuyCashItem  
       
    -- 아이템 생성.    
    INSERT INTO accountitem(AID, ItemID, RentDate, RentHourPeriod)     
    VALUES (@AID, @ItemID, @RentDate, @RentHourPeriod)    
    
    IF @@ERROR <> 0    
    BEGIN    
     ROLLBACK TRAN tranBuyCashItem  
     RETURN 0    
    END    
     
    -- 아이템 거래 log생성.    
    INSERT INTO ItemPurchaseLogByCash(AID, ItemID, Date, RentHourPeriod, Cash, MobileCode)     
    VALUES (@AID, @ItemID, GETDATE(), @RentHourPeriod, @Cash, @MobileCode)    
        
    IF @@ERROR <> 0    
    BEGIN    
     ROLLBACK TRAN tranBuyCashItem  
     RETURN 0    
    END    
        
   COMMIT TRAN tranBuyCashItem  
    
   RETURN 1    
    
  END     
  ELSE    
  BEGIN    
   RETURN 0    
  END    
 END    
    
 RETURN 1    
    
    
  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[viewEventGetCharacterLevel]'))
EXEC dbo.sp_executesql @statement = N'

-----------------------

CREATE VIEW [viewEventGetCharacterLevel]
AS

SELECT a.userid AS userid, c.name AS chr_name, c.level AS chr_level FROM Account a(nolock), Character c(nolock)
WHERE 
a.aid=c.aid AND c.DeleteFlag=0

' 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebUpdateAccountPenaltyPeriod]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebUpdateAccountPenaltyPeriod]
	@AID int
,	@UGradeID int
,	@Period int 
,	@GMID varchar(20)
,	@Ret int OUTPUT
AS
	SET NOCOUNT ON

	IF NOT EXISTS (SELECT AID FROM Account(NOLOCK) WHERE AID = @AID) BEGIN
		SET @Ret = 0
		RETURN @Ret
	END

	IF (0 > @Period) OR (@Period IS NULL) OR (0 > @UGradeID) OR (@UGradeID IS NULL) BEGIN
		SET @Ret = 0
		RETURN @Ret
	END

	BEGIN TRAN
	UPDATE Account SET UGradeID = @UGradeID WHERE AID = @AID
	IF 0 = @@ROWCOUNT BEGIN
		ROLLBACK TRAN
		SET @Ret = 0
		RETURN @Ret
	END

	IF NOT EXISTS (SELECT AID FROM AccountPenaltyPeriod(NOLOCK) WHERE AID = @AID) BEGIN
		IF 0 < @Period BEGIN
			-- 처음 재제를 받을경우.
			INSERT INTO AccountPenaltyPeriod( AID, DayLeft ) VALUES (@AID, @Period)
			IF 0 <> @@ERROR BEGIN 
				ROLLBACK TRAN
				SET @Ret = 0
				RETURN @Ret
			END
		END
	END
	ELSE BEGIN
		IF 0 < @Period BEGIN
			-- 이미 다른 재제를 받을경우 기간만 수정함.
			UPDATE AccountPenaltyPeriod SET DayLeft = @Period WHERE AID = @AID
				IF 0 = @@ROWCOUNT BEGIN
				ROLLBACK TRAN
				SET @Ret = 0
				RETURN @Ret
			END
		END
		ELSE BEGIN
			DELETE AccountPenaltyPeriod WHERE AID = @AID
			IF 0 <> @@ERROR BEGIN
				ROLLBACK TRAN	
				SET @Ret = 0
				RETURN @Ret
			END
		END
	END

	INSERT INTO AccountPenaltyLog( AID, UGradeID, DayLeft, RegDate, GMID )
	VALUES (@AID, @UGradeID, @Period, GETDATE(), @GMID )
	IF 0 <> @@ERROR BEGIN 
		ROLLBACK TRAN
		SET @Ret = 0
		RETURN @Ret
	END
	COMMIT TRAN

	SET @Ret = 1
	RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[viewCashItemPresentLog]'))
EXEC dbo.sp_executesql @statement = N'
CREATE VIEW [viewCashItemPresentLog]
AS

SELECT cpl.id AS id, cpl.SenderUserID AS SenderUserID, a.UserID AS ReceiverUserID, 
i.Name AS ItemName, cpl.Date AS Date FROM CashItemPresentLog cpl, Account a(nolock), CashShop cs(nolock), Item i(nolock)
WHERE cpl.ReceiverAID=a.AID AND cpl.CSID IS Not NULL AND cpl.csid=cs.csid AND cs.ItemID=i.ItemID

' 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebItemUseLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebItemUseLog]  
 @UserID  VARCHAR(32)  
AS  
BEGIN  
 SET NOCOUNT ON 
 DECLARE @TargetAID INT  
 SELECT @TargetAID = AID FROM Account(NOLOCK) WHERE UserID=@UserID  
  
 SELECT l.AID, l.CID, c.Name AS CharName, i.ItemID, i.Name AS ItemName, l.Date, c.DeleteName   
 FROM BringAccountItemLog l(NOLOCK), Item i(NOLOCK), Character c(NOLOCK)  
 WHERE l.AID=@TargetAID AND l.CID=c.CID AND l.ItemID=i.ItemID  
 ORDER BY  Date DESC  
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spUpdateAccountUGrade]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 패널티 적용
CREATE PROC [spUpdateAccountUGrade]
	@AID		int
,	@UGrade		int
,	@Period		int
AS
BEGIN TRAN
	SET NOCOUNT ON
	UPDATE Account SET UGradeID=@UGrade WHERE AID=@AID
	IF 0 = @@ROWCOUNT BEGIN 
		ROLLBACK TRAN
		RETURN
	END


	IF (@UGrade >= 100) AND (@UGrade<=253) BEGIN
		INSERT INTO PenaltyLog(AID, UGradeID, Date) Values(@AID, @UGrade, GETDATE())
		IF 0 <> @@ERROR BEGIN
			ROLLBACK TRAN
			RETURN
		END
	END

	IF @UGrade = 104 OR @UGrade=105 BEGIN
		INSERT INTO AccountPenaltyPeriod(AID, DayLeft) VALUES(@AID, @Period)
		IF 0 <> @@ERROR	BEGIN
			ROLLBACK TRAN
			RETURN
		END
	END
	ELSE
	BEGIN
		-- 기간 패널티 해제
		DELETE FROM AccountPenaltyPeriod WHERE AID=@AID
		IF 0 <> @@ERROR BEGIN
			ROLLBACK TRAN
			RETURN
		END	
	END
COMMIT TRAN



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spUpdateAccountLastLogoutTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spUpdateAccountLastLogoutTime]
 @AID int
AS
BEGIN
 SET NOCOUNT ON

 UPDATE Account SET LastLogoutTime = GETDATE() WHERE AID = @AID
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebInsertAccountItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebInsertAccountItem]
 @AID int
, @ItemID int
, @Period int 
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON
 IF (500001 > @ItemID) OR ((@Period IS NOT NULL) AND (0 > @Period)) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 IF NOT EXISTS (SELECT AID FROM Account(NOLOCK) WHERE AID = @AID) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 DECLARE @RentHourPeriod int
 DECLARE @RentDate datetime
	
 IF (0 = @Period) OR (@Period IS NULL)
  SELECT @RentHourPeriod = NULL, @RentDate = NULL
 ELSE
  SELECT @RentHourPeriod = @Period, @RentDate = GETDATE()

 INSERT INTO AccountItem( AID, ItemID, RentDate, RentHourPeriod)
 VALUES (@AID, @ItemID, @RentDate, @RentHourPeriod )
 IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetSimpleLiveCharInfoByOneCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetSimpleLiveCharInfoByOneCharName]
	@CharName varchar( 24 )
AS
	SET NOCOUNT ON

	DECLARE @AID int
	
	SELECT @AID = a.AID
	FROM Character c(NOLOCK) JOIN Account a(NOLOCK)
	ON c.Name = @CharName AND a.AID = c.AID

	IF @AID IS NULL RETURN

	SELECT Name, CID FROM Character(NOLOCK) WHERE AID = @AID AND DeleteFlag <> 1
	ORDER BY CharNum

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetItemPurchaseLogByCash]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetItemPurchaseLogByCash]
 @AID int  
AS  
 SET NOCOUNT ON  
 SELECT ipl.id, a.UserID AS SenderUserID, a.UserID AS ReceiverUserID, 
  i.Name AS ItemName, ipl.Date, ipl.Cash
  , CASE ISNULL(ipl.RentHourPeriod, 0) 
   WHEN 0 THEN ''0''
   ELSE CAST(ipl.RentHourPeriod AS varchar(10)) 
   END AS ''RentHourPeriod''
 FROM (Account a(NOLOCK) JOIN ItemPurchaseLogByCash ipl(NOLOCK)  
 ON a.AID = @AID AND ipl.AID = a.AID) JOIN Item i(NOLOCK)  
 ON i.ItemID = ipl.ItemID  
 ORDER BY ipl.Date DESC  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetLiveCharInfoByAID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetLiveCharInfoByAID]
 @AID int
AS
 SET NOCOUNT ON

 SELECT c.Name, c.AID, c.CID, c.RegDate, c.PlayTime, c.LastTime, 
  c.Sex, c.CharNum, c.Level, c.XP, c.BP, c.KillCount, c.DeathCount
 FROM Account a(NOLOCK) JOIN Character c(NOLOCK)
 ON a.AID = @AID AND c.AID = a.AID 
 WHERE c.DeleteFlag <> 1

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetLiveCharNameCIDByUserID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetLiveCharNameCIDByUserID]
	@UserID varchar(20)
AS
	SET NOCOUNT ON 

	SELECT c.Name, c.CID, c.DeleteFlag
	FROM Account a(NOLOCK) JOIN Character c(NOLOCK)
	ON a.UserID = @UserID AND c.AID = a.AID
	WHERE c.DeleteFlag <> 1
	ORDER BY c.DeleteFlag, c.CharNum

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetLiveCharListByUserID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetLiveCharListByUserID]
	@UserID varchar( 20 )
AS 
	SET NOCOUNT ON

	SELECT c.Name, c.AID, c.CID, c.RegDate, c.PlayTime, c.LastTime, 
		c.Sex, c.CharNum, c.Level, c.XP, c.BP, c.KillCount, c.DeathCount
	FROM Account a(NOLOCK) JOIN Character c(NOLOCK)
	ON a.UserID = @UserID AND c.AID = a.AID
	WHERE c.DeleteFlag <> 1
	ORDER BY c.CharNum

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetLiveCharInfoByOneCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetLiveCharInfoByOneCharName]
 @CharName varchar(24)
AS
 SET NOCOUNT ON
 
 SELECT c2.Name, c2.CID
 FROM (Character c1(NOLOCK) JOIN Account a(NOLOCK)
 ON c1.Name = @CharName AND a.AID = c1.AID) JOIN Character c2(NOLOCK)
 ON c2.AID = a.AID
 WHERE c2.DeleteFlag <> 1
 ORDER BY c2.CharNum

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spResetAccountHackingBlock]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [spResetAccountHackingBlock]
 @AID INT
, @HackingType TINYINT
AS
BEGIN
 SET NOCOUNT ON

 UPDATE Account
 SET HackingType = @HackingType
 WHERE AID = @AID
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetCharLogByCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetCharLogByCharName]
 @CharName varchar(24)
AS
 SET NOCOUNT ON

 SELECT a.UserID, cml.CharName, cml.Type, cml.Date
 FROM CharacterMakingLog cml(NOLOCK) JOIN Account a(NOLOCK)
 ON cml.CharName = @CharName AND a.AID = cml.AID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetClanMemberInfoByCLID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetClanMemberInfoByCLID]      
 @CLID int      
AS      
 SET NOCOUNT ON       
      
 SELECT cm.CLID, cm.Grade, a.AID, a.UserID, c.Name, cm.CID, c.Level, cm.ContPoint, cm.RegDate      
 FROM (ClanMember cm(NOLOCK) JOIN Character c(NOLOCK)      
 ON cm.CLID = @CLID AND c.CID = cm.CID) JOIN Account a( NOLOCK)      
 ON a.AID = c.AID      
 WHERE c.DeleteFlag <> 1      
Order by cm.Grade, cm.RegDate    
  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spPresentCashItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



--------------------------------------------------------------------------------



-- 단일 아이템 선물하기
CREATE  PROC [spPresentCashItem]
	@SenderUserID	varchar(20)
,	@ReceiverUserID	varchar(20)
,	@CSID		int
,	@Cash		int
,	@RentHourPeriod	smallint = NULL
,	@MobileCode char(16) = NULL
AS
	SET NoCount On

	DECLARE	@ItemID		int
	DECLARE @ReceiverAID	int

	SELECT @ReceiverAID = AID FROM Account (NOLOCK) WHERE UserID = @ReceiverUserID
	
	IF @ReceiverAID IS NULL
	BEGIN
		RETURN 0
	END
	ELSE
	BEGIN
		DECLARE @RentDate	datetime
		-- @RentHourPeriod값을 가지고 기간제인지 검사.
		IF @RentHourPeriod = 0 OR @RentHourPeriod IS NULL
		BEGIN
			-- 기간제 아이템일 경우 영구 아이템 판매 여부 검사
			DECLARE @RentType 	TINYINT
			DECLARE @RCSPID		INT

				SELECT @RentType = RentType FROM CashShop WHERE CSID=@CSID
			IF @RentType = 1
			BEGIN
				SELECT @RCSPID = RCSPID FROM RentCashShopPrice WHERE CSID=@CSID AND RentHourPeriod is NULL
				IF @RCSPID IS NULL
				BEGIN
					RETURN 0
				END
			END

			-- 일반 아이템인 경우
			SET @RentDate = NULL
		END
		ELSE
		BEGIN
			SET @RentDate = GETDATE()
		END


		SELECT @ItemID = ItemID FROM CashShop (NOLOCK) WHERE CSID = @CSID

		IF @ItemID IS NOT NULL
		BEGIN
			BEGIN TRAN
			
				-- 아이템 생성.
				INSERT INTO AccountItem (AID, ItemID, RentDate, RentHourPeriod)
				VALUES (@ReceiverAID, @ItemID, @RentDate, @RentHourPeriod)
				
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK
					RETURN 0
				END
									
				-- 선물 로그 생성.
				INSERT INTO CashItemPresentLog (SenderUserID, ReceiverAID, CSID, Date, Cash, RentHourPeriod, MobileCode)
				VALUES (@SenderUserID, @ReceiverAID, @CSID, GETDATE(), @Cash, @RentHourPeriod, @MobileCode)
				
				IF @@ERROR <> 0
				BEGIN
					ROLLBACK
					RETURN 0
				END
					
			COMMIT TRAN
		END
		ELSE
		BEGIN
			RETURN 0
		END

		
		RETURN 1
	END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetCaracterMakingLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetCaracterMakingLog]  
 @CharName varchar(24)  
AS  
 SET NOCOUNT ON  
 SELECT a.UserID, cml.AID,  cml.CharName, cml.Type, cml.Date  
 FROM Account a(nolock), CharacterMakingLog cml(nolock)   
 WHERE cml.CharName = @CharName AND a.AID = cml.AID   
 ORDER BY cml.Date DESC  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetCashItemPresentSendLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetCashItemPresentSendLog]
 @AID int  
AS  
 SET NOCOUNT ON   
 SELECT cpl.id, cpl.SenderUserID, ar.UserID AS ReceiverUserID
  , i.Name AS ItemName, cpl.Date, cpl.Cash  
  , CASE ISNULL(cpl.RentHourPeriod, 0)
    WHEN 0 THEN ''0''
    ELSE CAST(cpl.RentHourPeriod AS varchar(10))
   END AS ''RentHourPeriod''
 FROM (((Account a(NOLOCK) JOIN CashItemPresentLog cpl(NOLOCK)  
 ON a.AID = @AID AND cpl.SenderUserID = a.UserID) JOIN CashShop cs(NOLOCK)  
 ON cs.CSID = cpl.CSID) JOIN Item i(NOLOCK)  
 ON i.ItemID = cs.ItemID) JOIN Account ar(NOLOCK)   
 ON ar.AID = cpl.ReceiverAID  
 ORDER BY cpl.Date DESC  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetCharInfoByUserID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetCharInfoByUserID]  
 @UserID varchar(20)  
AS  
 SET NOCOUNT ON  
  
 SELECT c.Name, c.AID, c.CID, c.RegDate, c.PlayTime, c.LastTime,c.Sex,  
  c.CharNum, c.Level, c.XP, c.BP, c.DeleteFlag, c.DeleteName,  
  c.KillCount, c.DeathCount  
 FROM Account a(NOLOCK) JOIN Character c(NOLOCK)  
 ON a.UserID = @UserID AND c.AID = a.AID  
 ORDER BY DeleteFlag, CharNum

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebDeleteAccountItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebDeleteAccountItem]
	@AID int
,	@AIID int
,	@ItemID int
,	@GMID varchar(20)
,	@Ret int OUTPUT
AS
 SET NOCOUNT ON 

 IF NOT EXISTS (SELECT AID FROM Account(NOLOCK) 
 WHERE AID = @AID) BEGIN
  SET @Ret = 0
  RETURN @Ret	
 END

 DELETE AccountItem WHERE AIID = @AIID AND AID = @AID AND ItemID = @ItemID
 IF 0 <> @@ERROR BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebUpdateAccount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE    PROC [spWebUpdateAccount]     
 @UserID varchar(20)    
, @Password varchar(20)=NULL    
, @Cert tinyint    
, @Name  varchar(30)    
, @Age smallint    
, @Country char(3)    
, @Sex tinyint    
, @Email varchar(50)=NULL    
, @Ret int OutPut    
AS    
 SET NOCOUNT ON    
 BEGIN TRAN    
 UPDATE Account SET  Cert = @Cert, Name = @Name, Age = @Age, Sex = @Sex, Email = @Email,     
  Country = @Country    
 WHERE UserID = @UserID    
 IF 0 = @@ROWCOUNT BEGIN    
  ROLLBACK TRAN    
  SET @Ret = 0    
  RETURN @Ret     
 END    
    
 IF (@Password <> '''') AND (@Password IS NOT NULL) BEGIN    
  UPDATE  login SET Password = @Password    
  WHERE UserID = @UserID    
  IF 0 = @@ROWCOUNT BEGIN    
   ROLLBACK TRAN    
   SET @Ret = 0    
   RETURN @Ret     
  END    
 END    
  
 COMMIT TRAN    
    
 SET @Ret = 1    
 RETURN @Ret  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetAccountInfoByUserID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetAccountInfoByUserID]
	@UserID varchar( 20 )
AS
	SET NOCOUNT ON

	SELECT AID, UserID, Name, Age, Sex, UGradeID, RegDate
	FROM Account(NOLOCK)
	WHERE UserID = @UserID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetAccountJoinStatistics]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetAccountJoinStatistics]
 @StartDate smalldatetime
, @EndDate smalldatetime
AS
 SET NOCOUNT ON 

 SELECT  convert(char(10), RegDate, 120) as Date ,count(AID) as Count
 FROM Account(nolock)  
 WHERE RegDate between convert(datetime, @StartDate) and convert(datetime, @EndDate)
 GROUP BY convert(char(10), RegDate, 120)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetAllCharInfoByOneCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetAllCharInfoByOneCharName]
 @CharName varchar(24)
AS
 SET NOCOUNT ON 

 SELECT c2.Name, c2.CID
 FROM (Character c1(NOLOCK) JOIN Account a(NOLOCK)
 ON c1.Name = @CharName AND a.AID = c1.AID) JOIN Character c2(NOLOCK)
 ON c2.AID = a.AID
 ORDER BY c2.DeleteFlag, c2.CharNum

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetAllCharInfoByAID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetAllCharInfoByAID]  
 @AID int  
AS  
 SET NOCOUNT ON  
  
 SELECT c.Name, c.AID, c.CID, c.RegDate, c.PlayTime, c.LastTime
  , c.Sex, c.CharNum, c.Level, c.XP, c.BP, c.KillCount, c.DeathCount, c.DeleteFlag, c.DeleteName  
 FROM Account a(NOLOCK) JOIN Character c(NOLOCK)  
 ON a.AID = @AID AND c.AID = a.AID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetSexInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [spGetSexInfo]
	@AID		int
AS
SET NOCOUNT ON
SELECT Sex, RegNum, Email FROM Account WHERE AID=@AID


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetAccountInfoByCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetAccountInfoByCharName]
	@CharName varchar( 24 ) 
AS
	SET NOCOUNT ON

	SELECT a.UserID, a.AID, a.RegDate, a.UGradeID, a.Sex, a.Age, a.Name
	FROM Character c(NOLOCK) JOIN Account a(NOLOCK)
	ON c.Name = @CharName AND c.AID = a.AID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetAccountInfoByAID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetAccountInfoByAID]  
	@AID int
AS  
 	SET NOCOUNT ON  
  
 	SELECT AID, UserID, Name, Age, Sex, UGradeID, RegDate  
 	FROM Account(NOLOCK)  
 	WHERE AID = @AID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetAllSimpleCharInfoByOneCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetAllSimpleCharInfoByOneCharName]
 @CharName varchar( 24 )
AS
 SET NOCOUNT ON

 SELECT c2.Name, c2.CID
 FROM (Character c1(NOLOCK) JOIN Account a(NOLOCK)
 ON c1.Name = ''sunge_se'' AND a.AID = c1.AID) JOIN Character c2(NOLOCK)
 ON c2.AID = a.AID
 ORDER BY c2.DeleteFlag, c2.CharNum

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetAllCharNameCIDByUserID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetAllCharNameCIDByUserID]
	@UserID varchar(20)
AS
	SET NOCOUNT ON

	SELECT c.Name, c.CID, c.DeleteFlag
	FROM Account a(NOLOCK) JOIN Character c(NOLOCK)
	ON a.UserID = @UserID AND c.AID = a.AID
	ORDER BY c.DeleteFlag, c.CharNum

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetAllCharInfoByUserID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetAllCharInfoByUserID]
 @UserID varchar( 20 )
AS
 SET NOCOUNT ON

 SELECT c.Name, c.AID, c.CID, c.RegDate, c.PlayTime, c.LastTime, 
  c.Sex, c.CharNum, c.Level, c.XP, c.BP, c.DeleteFlag, 
  c.DeleteName, c.KillCount, c.DeathCount
 FROM Account a(NOLOCK) JOIN Character c(NOLOCK)
 ON a.UserID = @UserID AND c.AID = a.AID
 ORDER BY c.DeleteFlag, c.CharNum

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetCashItemPresentRecvLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetCashItemPresentRecvLog]
 @AID int  
AS  
 SET NOCOUNT ON  
 SELECT cpl.id, cpl.SenderUserID, a.UserID AS ReceiverUserID
  , i.Name AS ItemName, cpl.Date, cpl.Cash  
  , CASE ISNULL(cpl.RentHourPeriod, 0)
   WHEN 0 THEN ''0''
   ELSE CAST(cpl.RentHourPeriod AS varchar(10))
   END AS ''RentHourPeriod''
 FROM ((Account a(NOLOCK) JOIN CashItemPresentLog cpl(NOLOCK)  
 ON a.AID = @AID AND cpl.ReceiverAID = a.AID) JOIN CashShop cs(NOLOCK)  
 ON cs.CSID = cpl.CSID) JOIN Item i(NOLOCK)  
 ON i.ItemID = cs.ItemID  
 ORDER BY cpl.Date DESC  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebDeleteChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebDeleteChar]
 @AID  int
, @CharNum smallint
, @CharName varchar(24)
, @GMID varchar(20)
, @Ret int OUTPUT	
AS
 SET NOCOUNT ON 

 DECLARE @CID int
 DECLARE @ErrSlot int
 DECLARE @ErrDelInfo int
 DECLARE @ErrName int

 SELECT @CID = CID FROM Character(NOLOCK) 
 WHERE AID = @AID AND Name = @CharName AND CharNum = @CharNum
 IF @CID IS NULL BEGIN 
  SET @Ret = 0
  RETURN @Ret
 END

 BEGIN TRAN
 -- 캐쉬아이템은 중앙은행으로 돌려줘야 함.
 INSERT INTO AccountItem( AID, ItemID, RentDate, RentHourPeriod, Cnt )
 SELECT @AID AS AID, ItemID, RentDate, RentHourPeriod, Cnt
 FROM CharacterItem(NOLOCK)
 WHERE CID = @CID AND ItemID > 499999
 IF 0 <> @@ERROR BEGIN 
  ROLLBACK TRAN
  SET @Ret = 0
  RETURN @Ret
 END

 DELETE CharacterItem WHERE CID = @CID
 IF 0 <> @@ERROR BEGIN 
  ROLLBACK TRAN
  SET @Ret = 0
  RETURN @Ret
 END

 UPDATE Character SET head_slot = NULL, chest_slot = NULL, hands_slot = NULL,
 legs_slot = NULL, feet_slot = NULL, fingerl_slot = NULL, 
 fingerr_slot = NULL, melee_slot = NULL, primary_slot = NULL, 
 secondary_slot = NULL, custom1_slot = NULL, custom2_slot = NULL
 WHERE CID = @CID
 SET @ErrSlot = @@ROWCOUNT

 UPDATE Character SET DeleteName = Name, DeleteFlag = 1 WHERE CID = @CID
 SET @ErrDelInfo = @@ROWCOUNT

 UPDATE Character SET Name = '''' WHERE CID = @CID
 SET @ErrName = @@ROWCOUNT

 IF (0 = @ErrSlot) OR (0 = @ErrDelInfo) OR (0 = @ErrName) BEGIN
  ROLLBACK TRAN
  SET @Ret = 0
  RETURN @Ret
 END
 COMMIT TRAN
	
 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spSelectAccountItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 중앙은행 아이템 보기 */
CREATE PROC [spSelectAccountItem]
	@AID			int
AS
SET NOCOUNT ON

DECLARE @NowTime DATETIME
SELECT @NowTime = GETDATE()

SELECT AIID, ItemID, (RentHourPeriod*60) - (DateDiff(n, RentDate, @NowTime)) AS RentPeriodRemainder
FROM AccountItem(NOLOCK)
WHERE AID=@AID ORDER BY AIID




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spBringBackAccountItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 내 캐릭터 캐쉬아이템을 창고에 넣기 ---------
CREATE PROC [spBringBackAccountItem]
	@AID		int,
	@CID		int,
	@CIID		int
AS
SET NOCOUNT ON

DECLARE @ItemID int
DECLARE @RentDate		DATETIME
DECLARE @RentHourPeriod	SMALLINT
DECLARE @Cnt			SMALLINT

DECLARE @HeadCIID 	int
DECLARE @ChestCIID	int
DECLARE @HandsCIID	int
DECLARE @LegsCIID	int
DECLARE @FeetCIID	int
DECLARE @FingerLCIID	int
DECLARE @FingerRCIID	int
DECLARE @MeleeCIID	int
DECLARE @PrimaryCIID	int
DECLARE @SecondaryCIID	int
DECLARE @Custom1CIID	int
DECLARE @Custom2CIID	int

SELECT 
@HeadCIID=head_slot, @ChestCIID=chest_slot, @HandsCIID=hands_slot, 
@LegsCIID=legs_slot, @FeetCIID=feet_slot, @FingerLCIID=fingerl_slot, @FingerRCIID=fingerr_slot, 
@MeleeCIID=melee_slot, @PrimaryCIID=primary_slot, @SecondaryCIID=secondary_slot, 
@Custom1CIID=custom1_slot, @Custom2CIID=custom2_slot
FROM Character(nolock) WHERE cid=@CID AND aid=@AID

SELECT @ItemID=ItemID, @RentDate=RentDate, @RentHourPeriod=RentHourPeriod, @Cnt=Cnt
FROM CharacterItem WHERE CIID=@CIID AND CID=@CID

IF ((@ItemID IS NOT NULL) AND (@ItemID >= 400000) AND
   (@HeadCIID IS NULL OR @HeadCIID != @CIID) AND
   (@ChestCIID IS NULL OR @ChestCIID != @CIID) AND 
   (@HandsCIID IS NULL OR @HandsCIID != @CIID) AND
   (@LegsCIID IS NULL OR @LegsCIID != @CIID) AND 
   (@FeetCIID IS NULL OR @FeetCIID != @CIID) AND
   (@FingerLCIID IS NULL OR @FingerLCIID != @CIID) AND 
   (@FingerRCIID IS NULL OR @FingerRCIID != @CIID) AND
   (@MeleeCIID IS NULL OR @MeleeCIID != @CIID) AND 
   (@PrimaryCIID IS NULL OR @PrimaryCIID != @CIID) AND
   (@SecondaryCIID IS NULL OR @SecondaryCIID != @CIID) AND 
   (@Custom1CIID IS NULL OR @Custom1CIID != @CIID) AND
   (@Custom2CIID IS NULL OR @Custom2CIID != @CIID))
BEGIN
	BEGIN TRAN -------------
	UPDATE CharacterItem SET CID=NULL WHERE CIID=@CIID AND CID=@CID
	IF 0 = @@ROWCOUNT BEGIN
		ROLLBACK TRAN
		RETURN
	END

	INSERT INTO AccountItem (AID, ItemID, RentDate, RentHourPeriod, Cnt) 
	VALUES (@AID, @ItemID, @RentDate, @RentHourPeriod, @Cnt)
	IF 0 <> @@ERROR BEGIN
		ROLLBACK TRAN
		RETURN
	END
	COMMIT TRAN -----------
END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spBringAccountItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 창고 아이템 내 캐릭터로 가져오기 ----------
CREATE PROC [spBringAccountItem]
	@AID		int,
	@CID		int,
	@AIID		int
AS
SET NoCount On

DECLARE @ItemID int
DECLARE @CAID int
DECLARE @OrderCIID int

DECLARE @RentDate			DATETIME
DECLARE @RentHourPeriod		SMALLINT
DECLARE @Cnt				SMALLINT

SELECT @ItemID=ItemID, @RentDate=RentDate, @RentHourPeriod=RentHourPeriod, @Cnt=Cnt
FROM AccountItem WHERE AIID = @AIID


SELECT @CAID = AID FROM Character WHERE CID=@CID

IF @ItemID IS NOT NULL AND @CAID = @AID
BEGIN
	BEGIN TRAN ----------------
	DELETE FROM AccountItem WHERE AIID = @AIID
	IF 0 <> @@ERROR BEGIN
		ROLLBACK TRAN 
		RETURN
	END

	INSERT INTO CharacterItem (CID, ItemID, RegDate, RentDate, RentHourPeriod, Cnt)
	VALUES (@CID, @ItemID, GETDATE(), @RentDate, @RentHourPeriod, @Cnt)
	IF 0 <> @@ERROR BEGIN 
		ROLLBACK TRAN
		RETURN 
	END

	SET @OrderCIID = @@IDENTITY

	INSERT INTO BringAccountItemLog	(ItemID, AID, CID, Date)
	VALUES (@ItemID, @AID, @CID, GETDATE())
	IF 0 <> @@ERROR BEGIN
		ROLLBACK TRAN
		RETURN
	END

	COMMIT TRAN ---------------

	SELECT @OrderCIID AS ORDERCIID, @ItemID AS ItemID, (@RentHourPeriod*60) - (DateDiff(n, @RentDate, GETDATE())) AS RentPeriodRemainder
END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spDeleteExpiredAccountItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 중앙은행의 기간만료 아이템 삭제 */
CREATE PROC [spDeleteExpiredAccountItem]
	@AIID		int
AS
SET NOCOUNT ON

DELETE FROM AccountItem WHERE AIID=@AIID AND RentDate IS NOT NULL



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebAccountItemInfoByAID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebAccountItemInfoByAID] 
 @AID int
AS
 SET NOCOUNT ON
 SELECT ai.AIID, ai.RentHourPeriod, i.Name, i.ItemID
  , CASE ISNULL(RentDate, 0 )
    WHEN 0 THEN ''0''
    ELSE (RentHourPeriod-DATEDIFF (hh, RentDate, GetDate()))  
    END AS RentRemain
  , CASE ISNULL(ai.RentDate, 0)
    WHEN 0 THEN ''0''
    ELSE CAST(ai.RentDate AS varchar(24))
    END as RentDate
 FROM   AccountItem ai(NOLOCK) JOIN Item i(NOLOCK) 
 ON ai.AID = @AID AND i.ItemID = ai.ItemID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebUpdateBlockCountryCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebUpdateBlockCountryCode]  
 @CountryCode3 char(3)  
, @RoutingURL varchar(64)  
, @IsBlock tinyint  
, @Ret int Output  
AS  
 SET NOCOUNT ON  
 UPDATE BlockCountryCode   
 SET RoutingURL = @RoutingURL , IsBlock = @IsBlock  
 WHERE CountryCode3 = @CountryCode3   
 IF 0 = @@ROWCOUNT SET @Ret = 0  
 ELSE SET @Ret = 1  
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetBlockCountryCodeList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetBlockCountryCodeList]
 @Code char
AS
 SET NOCOUNT ON

 SELECT bcc.CountryCode3, bcc.RoutingURL, bcc.IsBlock, cc.CountryName
 FROM BlockCountryCode bcc(NOLOCK) JOIN CountryCode cc(NOLOCK)
 ON cc.CountryCode3 = bcc.CountryCode3
 WHERE cc.CountryName LIKE @Code + ''%''
 ORDER BY CountryName ASC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spIPFltGetBlockCountryCodeList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spIPFltGetBlockCountryCodeList]
AS
 SET NOCOUNT ON
 SELECT CountryCode3, RoutingURL, IsBlock
 FROM BlockCountryCode(NOLOCK)
 ORDER BY CountryCode3

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebDeleteOneCashSetItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebDeleteOneCashSetItem]
 @CSSID int
, @CSID int
, @Ret int OUTPUT
AS 
 SET NOCOUNT ON
 DELETE CashSetItem WHERE CSSID = @CSSID AND CSID = @CSID
 IF (0 <> @@ERROR) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END
 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebInsertOneCashSetItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebInsertOneCashSetItem]
 @CSSID int
, @CSID int
, @Ret int OUTPUT
AS
 SET NOCOUNT ON
 IF (@CSSID IS NULL) OR (@CSID IS NULL) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 INSERT INTO CashSetItem(CSSID, CSID) VALUES (@CSSID, @CSID)
 IF 0 <> @@ERROR BEGIN
  SET @Ret = 0
  RETURN @Ret
 END
 
 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetCashSetItemComposition]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 세트 아이템의 세부아이템 목록 보기 */
CREATE PROC [spGetCashSetItemComposition]
	@CSSID		int,
	@OutRowCount	int OUTPUT
AS
SET NOCOUNT ON

SELECT @OutRowCount = COUNT(*)
FROM CashSetItem csi(nolock), CashShop cs(nolock), Item i(nolock)
WHERE @CSSID = csi.CSSID AND csi.csid = cs.csid	AND cs.ItemID = i.ItemID

SELECT cs.csid AS CSID, i.name AS Name, i.Slot AS Slot, 
	cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
	i.ResSex AS ResSex, i.ResLevel AS ResLevel, i.Weight AS Weight,
	i.Description AS Description, cs.RegDate As RegDate,
	cs.NewItemOrder AS IsNewItem

FROM CashSetItem csi(nolock), CashShop cs(nolock), Item i(nolock)
WHERE @CSSID = csi.CSSID AND csi.csid = cs.csid	AND cs.ItemID = i.ItemID




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetCharItemByCID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetCharItemByCID]
	@CID int
AS
BEGIN
	SET NOCOUNT ON

	SELECT ci.ItemID, i.Name, ci.CIID, ci.RegDate AS RegDate,  
		CASE 
		WHEN ci.RentHourPeriod IS NOT NULL THEN (RentHourPeriod) - (DateDiff(hh, RentDate, GETDATE()))
		WHEN ci.RentHourPeriod IS NULL THEN -1
		ELSE -2 -- error.
		END AS RentPeriodRemainderHour,
		CASE ci.CIID 
		WHEN c.head_slot THEN ''Head''
		WHEN c.chest_slot THEN ''Chest''
		WHEN c.hands_slot THEN ''Hands''
		WHEN c.legs_slot THEN ''Legs''
		WHEN c.feet_slot THEN ''Feet''
		WHEN c.fingerl_slot THEN ''Left finger''
		WHEN c.fingerr_slot THEN ''Right finger''
		WHEN c.melee_slot THEN ''Melee''
		WHEN c.primary_slot THEN ''Primary''
		WHEN c.secondary_slot THEN ''Secondary''
		WHEN c.custom1_slot THEN ''Custom1''
		WHEN c.custom2_slot THEN ''Custom2''
		ELSE ''Free item''
		END AS KeepOnPosition,
		CASE ci.CIID
		WHEN c.head_slot THEN 11
		WHEN c.chest_slot THEN 12
		WHEN c.hands_slot THEN 13
		WHEN c.legs_slot THEN 14
		WHEN c.feet_slot THEN 15
		WHEN c.fingerl_slot THEN 16
		WHEN c.fingerr_slot THEN 17
		WHEN c.melee_slot THEN 18
		WHEN c.primary_slot THEN 19
		WHEN c.secondary_slot THEN 20
		WHEN c.custom1_slot THEN 21
		WHEN c.custom2_slot THEN 22
		ELSE 23
		END AS Orders
	FROM (Character c(NOLOCK) JOIN CharacterItem ci(NOLOCK)
	ON c.CID = @CID AND ci.CID = c.CID) JOIN Item i(NOLOCK)
	ON i.ItemID = ci.ItemID
	ORDER BY Orders 
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebDeleteCharacterItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebDeleteCharacterItem]
 @CID int
, @CIID int
, @ItemID int
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON

 IF NOT EXISTS (SELECT CID FROM Character(NOLOCK) WHERE CID = @CID) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 -- 삭제하려는 아이템을 착용하고 있다면 먼저 해제시쳐야 함.
 BEGIN TRAN
 UPDATE Character SET head_slot = NULL WHERE CID = @CID AND head_slot = @CIID
 UPDATE Character SET chest_slot = NULL WHERE CID = @CID AND chest_slot = @CIID
 UPDATE Character SET hands_slot = NULL WHERE CID = @CID AND hands_slot = @CIID
 UPDATE Character SET legs_slot = NULL WHERE CID = @CID AND legs_slot = @CIID
 UPDATE Character SET feet_slot = NULL WHERE CID = @CID AND feet_slot = @CIID
 UPDATE Character SET fingerl_slot = NULL WHERE CID = @CID AND fingerl_slot = @CIID
 UPDATE Character SET fingerr_slot = NULL WHERE CID = @CID AND fingerr_slot = @CIID
 UPDATE Character SET melee_slot = NULL WHERE CID = @CID AND melee_slot = @CIID
 UPDATE Character SET primary_slot = NULL WHERE CID = @CID AND primary_slot = @CIID
 UPDATE Character SET secondary_slot = NULL WHERE CID = @CID AND secondary_slot = @CIID
 UPDATE Character SET custom1_slot = NULL WHERE CID = @CID AND custom1_slot = @CIID
 UPDATE Character SET custom2_slot = NULL WHERE CID = @CID AND custom2_slot = @CIID

 DELETE CharacterItem WHERE CIID = @CIID AND CID = @CID AND ItemID = @ItemID
 IF 0 <> @@ERROR BEGIN
  ROLLBACK TRAN
  SET @Ret = 0
  RETURN @Ret
 END
 COMMIT TRAN	

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 캐릭터 추가 */
CREATE PROC [spInsertChar]
	@AID		int,
	@CharNum	smallint,
	@Name		varchar(24),
	@Sex		tinyint,
	@Hair		int,  
	@Face		int,
	@Costume	int
AS
SET NOCOUNT ON
BEGIN TRAN
IF EXISTS (SELECT CID FROM Character where (AID=@AID AND CharNum=@CharNum) OR (Name=@Name))
BEGIN	
	ROLLBACK TRAN
	return(-1)
END

DECLARE @CharIdent 	int
DECLARE @ChestCIID	int
DECLARE @LegsCIID	int
DECLARE @MeleeCIID	int
DECLARE @PrimaryCIID	int
DECLARE @SecondaryCIID  int
DECLARE @Custom1CIID	int
DECLARE @Custom2CIID	int

DECLARE @ChestItemID	int
DECLARE @LegsItemID	int
DECLARE @MeleeItemID	int
DECLARE @PrimaryItemID	int
DECLARE @SecondaryItemID  int
DECLARE @Custom1ItemID	int
DECLARE @Custom2ItemID	int

SET @SecondaryCIID = NULL
SET @SecondaryItemID = NULL

SET @Custom1CIID = NULL
SET @Custom1ItemID = NULL

SET @Custom2CIID = NULL
SET @Custom2ItemID = NULL

INSERT INTO Character (AID, Name, CharNum, Level, Sex, Hair, Face, XP, BP, FR, CR, ER, WR, 
         		           GameCount, KillCount, DeathCount, RegDate, PlayTime, DeleteFlag)
Values (@AID, @Name, @CharNum, 1, @Sex, @Hair, @Face, 0, 0, 0, 0, 0, 0, 0, 0, 0, GETDATE(), 0, 0)
IF 0 <> @@ERROR BEGIN
	ROLLBACK TRAN
	RETURN (-1)
END


SET @CharIdent = @@IDENTITY

  /* Melee */
  SET @MeleeItemID = 
    CASE @Costume
    WHEN 0 THEN 1
    WHEN 1 THEN 2
    WHEN 2 THEN 1
    WHEN 3 THEN 2
    WHEN 4 THEN 2
    WHEN 5 THEN 1
    END

  INSERT INTO CharacterItem (CID, ItemID) Values (@CharIdent, @MeleeItemID)
  IF 0 <> @@ERROR BEGIN
	ROLLBACK TRAN
	RETURN (-1)
  END

  SET @MeleeCIID = @@IDENTITY

  /* Primary */
  SET @PrimaryItemID = 
    CASE @Costume
    WHEN 0 THEN 5001
    WHEN 1 THEN 5002
    WHEN 2 THEN 4005
    WHEN 3 THEN 4001
    WHEN 4 THEN 4002
    WHEN 5 THEN 4006
    END

  INSERT INTO CharacterItem (CID, ItemID) Values (@CharIdent, @PrimaryItemID)
  IF 0 <> @@ERROR BEGIN
	ROLLBACK TRAN
	RETURN (-1)
  END

  SET @PrimaryCIID = @@IDENTITY

  /* Secondary */
IF @Costume = 0 OR @Costume = 2 BEGIN
  SET @SecondaryItemID =
    CASE @Costume
    WHEN 0 THEN 4001
    WHEN 1 THEN 0
    WHEN 2 THEN 5001
    WHEN 3 THEN 4006
    WHEN 4 THEN 0
    WHEN 5 THEN 4006
    END

  IF @SecondaryItemID <> 0 BEGIN
    INSERT INTO CharacterItem (CID, ItemID) Values (@CharIdent, @SecondaryItemID)
    IF 0 <> @@ERROR BEGIN
	ROLLBACK TRAN
	RETURN (-1)
    END

    SET @SecondaryCIID = @@IDENTITY
  END
END
  SET @Custom1ItemID = 
    CASE @Costume
    WHEN 0 THEN 30301
    WHEN 1 THEN 30301
    WHEN 2 THEN 30401
    WHEN 3 THEN 30401
    WHEN 4 THEN 30401
    WHEN 5 THEN 30101
    END

  /* Custom1 */
  INSERT INTO CharacterItem (CID, ItemID) Values (@CharIdent, @Custom1ItemID)
  IF 0 <> @@ERROR BEGIN
	ROLLBACK TRAN
	RETURN (-1)
  END

  SET @Custom1CIID = @@IDENTITY

  /* Custom2 */
IF @Costume = 4 OR @Costume = 5
BEGIN
  SET @Custom2ItemID =
    CASE @Costume
    WHEN 0 THEN 0
    WHEN 1 THEN 0
    WHEN 2 THEN 0
    WHEN 3 THEN 0
    WHEN 4 THEN 30001
    WHEN 5 THEN 30001
    END

  IF @Custom2ItemID <> 0
  BEGIN
    INSERT INTO CharacterItem (CID, ItemID) Values (@CharIdent, @Custom2ItemID)
    IF 0 <> @@ERROR BEGIN
	ROLLBACK TRAN
	RETURN (-1)
    END

    SET @Custom2CIID = @@IDENTITY
  END
END


IF @Sex = 0		/* 남자일 경우 */
BEGIN

  /* Chest */
  SET @ChestItemID =
    CASE @Costume
    WHEN 0 THEN 21001
    WHEN 1 THEN 21001
    WHEN 2 THEN 21001
    WHEN 3 THEN 21001
    WHEN 4 THEN 21001
    WHEN 5 THEN 21001
    END


  INSERT INTO CharacterItem (CID, ItemID) Values (@CharIdent, @ChestItemID)
  IF 0 <> @@ERROR BEGIN
	ROLLBACK TRAN
	RETURN (-1)
  END

  SET @ChestCIID = @@IDENTITY

  /* Legs */
  SET @LegsItemID =
    CASE @Costume
    WHEN 0 THEN 23001
    WHEN 1 THEN 23001
    WHEN 2 THEN 23001
    WHEN 3 THEN 23001
    WHEN 4 THEN 23001
    WHEN 5 THEN 23001
    END


  INSERT INTO CharacterItem (CID, ItemID) Values (@CharIdent, @LegsItemID)
  IF 0 <> @@ERROR BEGIN 
	ROLLBACK TRAN
	RETURN (-1)
  END

  SET @LegsCIID = @@IDENTITY

END
ELSE
BEGIN			/* 여자일 경우 */

  /* Chest */
  SET @ChestItemID =
    CASE @Costume
    WHEN 0 THEN 21501
    WHEN 1 THEN 21501
    WHEN 2 THEN 21501
    WHEN 3 THEN 21501
    WHEN 4 THEN 21501
    WHEN 5 THEN 21501
    END


  INSERT INTO CharacterItem (CID, ItemID) Values (@CharIdent, @ChestItemID)
  IF 0 <> @@ERROR BEGIN
	ROLLBACK TRAN
	RETURN (-1)
  END
  SET @ChestCIID = @@IDENTITY

  /* Legs */
  SET @LegsItemID =
    CASE @Costume
    WHEN 0 THEN 23501
    WHEN 1 THEN 23501
    WHEN 2 THEN 23501
    WHEN 3 THEN 23501
    WHEN 4 THEN 23501
    WHEN 5 THEN 23501
    END


  INSERT INTO CharacterItem (CID, ItemID) Values (@CharIdent, @LegsItemID)
  IF 0 <> @@ERROR BEGIN
	ROLLBACK TRAN
	RETURN (-1)
  END
  SET @LegsCIID = @@IDENTITY

END  

UPDATE Character
SET chest_slot = @ChestCIID, legs_slot = @LegsCIID, melee_slot = @MeleeCIID,
    primary_slot = @PrimaryCIID, secondary_slot = @SecondaryCIID, custom1_slot = @Custom1CIID,
    custom2_slot = @Custom2CIID,
    chest_itemid = @ChestItemID, legs_itemid = @LegsItemID, melee_itemid = @MeleeItemID,
    primary_itemid = @PrimaryItemID, secondary_itemid = @SecondaryItemID, custom1_itemid = @Custom1ItemID,
    custom2_itemid = @Custom2ItemID
WHERE CID=@CharIdent
IF 0 = @@ROWCOUNT BEGIN
	ROLLBACK TRAN
	RETURN (-1)
END
COMMIT TRAN



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertCharItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 캐릭터 아이템 추가 - 땜빵 */
CREATE PROC [spInsertCharItem]
	@CID		int,
	@ItemID		int
AS
SET NOCOUNT ON 

DECLARE @OrderCIID	int
DECLARE @varBP 		int
-- 땜빵
SELECT @varBP = BP FROM Character where CID=@CID
IF @varBP < 0
BEGIN
	UPDATE Character SET BP=0 WHERE CID=@CID
	RETURN (-1)
END


BEGIN TRAN
INSERT INTO CharacterItem (CID, ItemID, RegDate) Values (@CID, @ItemID, GETDATE())
IF 0 <> @@ERROR BEGIN
	ROLLBACK TRAN
	RETURN (-1)
END
COMMIT TRAN

SET @OrderCIID = @@IDENTITY
SELECT @OrderCIID as ORDERCIID




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spBuyBountyItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE   PROC [spBuyBountyItem]
	@CID		INT,
	@ItemID		INT,
	@Price		INT
AS
SET NOCOUNT ON
BEGIN
	DECLARE @OrderCIID	int
	DECLARE @Bounty	INT

	BEGIN TRAN
		-- 잔액검사
		SELECT @Bounty=BP FROM Character(NOLOCK) WHERE CID=@CID
		IF @Bounty IS NULL OR @Bounty < @Price
		BEGIN
			ROLLBACK TRAN
			RETURN 0
		END

		-- Bounty 감소
		UPDATE Character SET BP=BP-@Price WHERE CID=@CID
		IF 0 = @@ROWCOUNT
		BEGIN
			ROLLBACK TRAN
			RETURN (-1)
		END

		-- Item 추가
		INSERT INTO CharacterItem (CID, ItemID, RegDate) Values (@CID, @ItemID, GETDATE())
		IF 0 <> @@ERROR
		BEGIN
			ROLLBACK TRAN
			RETURN (-1)
		END

		SELECT @OrderCIID = @@IDENTITY
		
		-- Item 구매로그 추가
		INSERT INTO ItemPurchaseLogByBounty (ItemID, CID, Date, Bounty, CharBounty, Type)
		VALUES (@ItemID, @CID, GETDATE(), @Price, @Bounty, ''구입'')
		IF 0 <> @@ERROR BEGIN
			ROLLBACK TRAN
			RETURN (-1)
		END

		SELECT @OrderCIID as ORDERCIID
	COMMIT TRAN

	RETURN 1
END




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spSellBountyItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 게임내 상점에서 아이템 판매
CREATE   PROC [spSellBountyItem]
	@CID		INT,
	@ItemID		INT,
	@CIID		INT,
	@Price		INT,
	@CharBP		INT
AS
SET NOCOUNT ON
BEGIN
	BEGIN TRAN
		-- Item 삭제
		UPDATE CharacterItem SET CID=NULL WHERE CID=@CID AND CIID=@CIID
		IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		BEGIN
			ROLLBACK
			RETURN (-1)
		END

		-- Bounty 증가
		UPDATE Character SET BP=BP+@Price WHERE CID=@CID
		IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		BEGIN
			ROLLBACK
			RETURN (-1)
		END

		-- Item 판매 로그 추가
		INSERT INTO ItemPurchaseLogByBounty (ItemID, CID, Date, Bounty, CharBounty, Type)
		VALUES (@ItemID, @CID, GETDATE(), @Price, @CharBP, ''판매'')
		IF 0 <> @@ERROR BEGIN
			ROLLBACK TRAN
			RETURN (-1)
		END

		SELECT 1 as Ret
	COMMIT TRAN

	RETURN 1
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebInsertCharacterItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebInsertCharacterItem]
	@CID int
,	@ItemID int
,	@Period smallint 
,	@GMID varchar(20)
,	@Ret int OUTPUT
AS
	SET NOCOUNT ON 
	IF (500000 < @ItemID) OR ((@Period IS NOT NULL) AND (0 > @Period)) BEGIN
		SET @Ret = 0
		RETURN @Ret
	END

	IF NOT EXISTS( SELECT CID FROM Character(NOLOCK) WHERE CID = @CID) BEGIN
		SET @Ret = 0
		RETURN @Ret
	END

	DECLARE @RentHourPeriod smallint
	DECLARE @RentDate datetime
	
	IF (0 = @Period) OR (@Period IS NULL)
		SELECT @RentHourPeriod = NULL, @RentDate = NULL
	ELSE
		SELECT @RentHourPeriod = @Period, @RentDate = GETDATE()

	INSERT INTO CharacterItem( CID, ItemID, RegDate, RentDate, RentHourPeriod )
	VALUES (@CID, @ItemID, GETDATE(), @RentDate, @RentHourPeriod )
	IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
		SET @Ret = 0
		RETURN @Ret
	END

	SET @Ret = 1
	RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spSelectCharItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 캐릭터 아이템 보기 */
CREATE PROC [spSelectCharItem]
	@CID		int
AS
SET NOCOUNT ON

DECLARE @NowTime DATETIME
SELECT @NowTime = GETDATE()

SELECT CIID, ItemID, (RentHourPeriod*60) - (DateDiff(n, RentDate, @NowTime)) AS RentPeriodRemainder
FROM CharacterItem (nolock)
WHERE CID=@CID ORDER BY CIID




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spDeleteChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 캐릭터 삭제 */  
CREATE  PROC [spDeleteChar]  
 @AID  int,  
 @CharNum smallint,  
 @CharName varchar(24)  
AS  
DECLARE @CID  int  
DECLARE @CashItemCount int  
  
SELECT @CID=CID FROM Character WITH (nolock) WHERE AID=@AID and CharNum=@CharNum  
IF (@CID IS NULL)  
BEGIN  
 return (-1)  
END  
  
SELECT @CashItemCount=COUNT(*) FROM CharacterItem(nolock) WHERE CID=@CID AND ItemID>=500000  
  
IF (@CashItemCount > 0) OR  
   (EXISTS (SELECT TOP 1 CLID FROM ClanMember WHERE CID=@CID))  
BEGIN  
 return (-1)  
END  
  
BEGIN TRAN

UPDATE Character SET CharNum = -1, DeleteFlag = 1, Name='''', DeleteName=@CharName  
WHERE AID=@AID AND CharNum=@CharNum AND Name=@CharName  
IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
 ROLLBACK TRAN
 RETURN (-1)
END

INSERT INTO CharacterMakingLog(AID, CharName, Type, Date)
VALUES(@AID, @CharName, ''삭제'', GETDATE())
IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
 ROLLBACK TRAN
 RETURN (-1) 
END
  
COMMIT TRAN
SELECT 1 AS Ret  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spDeleteCharItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


/* 캐릭터 아이템 삭제 */
CREATE PROC [spDeleteCharItem]
	@CID		int,
	@CIID		int
AS
SET NOCOUNT ON

UPDATE CharacterItem SET CID=NULL
WHERE CID=@CID AND CIID=@CIID

/* 예전꺼
DELETE FROM CharacterItem 
WHERE CID=@CID AND CIID=@CIID
*/


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebResetChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 캐릭터 초기화
CREATE   PROC [spWebResetChar]
	@CID		INT
AS
SET NOCOUNT ON

BEGIN
	-- 스탯 초기화
	UPDATE Character SET Level=1, XP=0, BP=0, 

	head_slot=NULL, chest_slot=NULL, hands_slot=NULL, legs_slot=NULL, feet_slot=NULL,
	fingerl_slot=NULL, fingerr_slot=NULL, melee_slot=NULL, primary_slot=NULL, secondary_slot=NULL,
	custom1_slot=NULL, custom2_slot=NULL,
	GameCount=0, KillCount=0, DeathCount=0, 
	head_itemid=NULL, chest_itemid=NULL, hands_itemid=NULL, legs_itemid=NULL, feet_itemid=NULL,
	fingerl_itemid=NULL, fingerr_itemid=NULL, melee_itemid=NULL, primary_itemid=NULL, secondary_itemid=NULL,
	custom1_itemid=NULL, custom2_itemid=NULL, QuestItemInfo=NULL

	WHERE CID=@CID

	-- 아이템 삭제(상용 아이템은 제외)
	UPDATE CharacterItem SET CID=NULL WHERE CID=@CID AND ItemID < 500000

END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertCharMakingLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


/* 캐릭터 생성 로그 */
CREATE PROC [spInsertCharMakingLog]
	@AID		int,
	@CharName	varchar(32),
	@Type		varchar(20)
AS
SET NOCOUNT ON
BEGIN TRAN
INSERT INTO CharacterMakingLog (AID, CharName, Type, Date)
VALUES (@AID, @CharName, @Type, GETDATE())
IF 0 <> @@ERROR BEGIN
	ROLLBACK TRAN
	RETURN
END
COMMIT TRAN


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetClanInfoByCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetClanInfoByCharName]
 @CharName varchar(24)
AS
 SET NOCOUNT ON

 DECLARE @CLID int

 SELECT @CLID = cm.CLID
 FROM Character c(NOLOCK) JOIN ClanMember cm(NOLOCK)
 ON c.Name = @CharName AND cm.CID = c.CID
 IF @CLID IS NULL RETURN

 SELECT cl.CLID, cl.Name, c.Name AS ''MastName'', cl.Introduction, cl.RegDate, cl.HomePage, cl.EmblemURL, cl.DeleteFlag
 FROM Clan cl(NOLOCK) JOIN Character c(NOLOCK)
 ON cl.CLID = @CLID AND cl.MasterCID = c.CID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetClanInfoByClanName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetClanInfoByClanName]
 @ClanName varchar(24)
AS
 SET NOCOUNT ON

 SELECT cl.CLID, cl.Name, c.Name AS ''MastName'', cl.Introduction, 
  cl.RegDate, cl.HomePage, cl.EmblemURL, cl.DeleteFlag
 FROM Clan cl(NOLOCK) JOIN Character c(NOLOCK)
 ON cl.Name = @ClanName AND cl.MasterCID = c.CID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetClanRankInfoByCLID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetClanRankInfoByCLID]  
 @CLID int   
AS  
 SELECT Exp, Point, TotalPoint, Wins, Losses, Ranking, LastDayRanking, LastMonthRanking, RankIncrease  
 FROM Clan(NOLOCK)  
 WHERE CLID = @CLID  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spReserveCloseClan]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spReserveCloseClan]    
 @CLID  int  
, @ClanName varchar(24)  
, @MasterCID int    
, @DeleteDate smalldatetime  
AS    
 UPDATE Clan SET DeleteFlag=2 WHERE CLID=@CLID AND Name=@ClanName AND MasterCID=@MasterCID    

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spRegularUpdateClanRankIncrease]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 클랜 랭킹 증가분 업데이트 - 매일 새벽 12시에 업데이트
CREATE PROC [spRegularUpdateClanRankIncrease]
AS
	SET NOCOUNT ON

	-- 꼴등랭킹을 구한다.
	DECLARE @LowestRank int
	SELECT TOP 1 @LowestRank=Ranking FROM Clan 
	WHERE DeleteFlag=0 AND Ranking>0 
	order by ranking desc

	IF @LowestRank is NULL SELECT @LowestRank = 0

	UPDATE Clan
	SET RankIncrease=(LastDayRanking-Ranking)
	WHERE DeleteFlag=0 AND Ranking>0 AND LastDayRanking != 0

	-- 처음 랭킹에 진입했을 경우
	UPDATE Clan
	SET RankIncrease=@LowestRank-Ranking
	WHERE DeleteFlag=0 AND Ranking>0 AND LastDayRanking = 0

	-- LastDayRanking 업데이트
	UPDATE Clan 
	SET LastDayRanking=Ranking 
	where DeleteFlag=0 and Ranking>0


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spRegularUpdateClanRanking]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [spRegularUpdateClanRanking]
AS
SET NOCOUNT ON

DECLARE @varRanking int
SELECT @varRanking = 0

DECLARE curRankClan INSENSITIVE CURSOR
FOR
	SELECT CLID
	FROM Clan(nolock)
	WHERE DeleteFlag=0 AND ((Wins != 0) OR (Losses != 0)) 
	ORDER BY Point Desc, Wins Desc, Losses Asc

FOR READ ONLY

OPEN curRankClan

DECLARE @varCLID int
DECLARE @sql varchar(100)

FETCH FROM curRankClan INTO @varCLID

WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT @varRanking = @varRanking + 1

	-- 랭킹 업데이트
	UPDATE Clan SET Ranking = @varRanking WHERE CLID=@varCLID


	FETCH FROM curRankClan INTO @varCLID
END

CLOSE curRankClan
DEALLOCATE curRankClan



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spRegularUpdateDeleteClan]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE proc [spRegularUpdateDeleteClan]  
as  
 set nocount on  
  
 declare @DelClanID table( clid int )  
  
 begin tran  
 insert into @DelClanID  
 select CLID from Clan(nolock) where DeleteFlag = 2  
 if (0 <> @@ERROR) or (0 = @@ROWCOUNT) begin  
  rollback tran  
  return  
 end  
  
 delete ClanMember   
 from @DelClanID dci, ClanMember cm(nolock)  
 where cm.CLID = dci.CLID  
 if (0 <> @@ERROR) begin  
  rollback tran  
  return  
 end  
  
 update Clan  
 set MasterCID = null, DeleteFlag = 1, DeleteName = Name, Name = null  
 from @DelClanID dci, Clan c(nolock)  
 where c.CLID = dci.CLID  
 if (0 <> @@ERROR) OR (0 = @@ROWCOUNT) begin  
  rollback tran  
  return  
 end  
   
 commit tran  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebDeleteClanByCID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebDeleteClanByCID]  
 @MasterCID int /* 마스터 CID */  
AS  
 SET NOCOUNT ON
 DECLARE @CLID int  
  
 SELECT @CLID = c.CLID  
 FROM Clan c(NOLOCK)  
 WHERE c.MasterCID = @MasterCID  
  
 -- 요청 조건 검사.  
 IF (@MasterCID IS NULL) OR (@CLID IS NULL) BEGIN  
  SELECT 0 AS Ret  
  ROLLBACK TRAN  
  RETURN  
 END  

 BEGIN TRAN    
 -- Clan Member 삭제.  
 DELETE ClanMember WHERE CLID = @CLID  
 IF 0  <> @@ERROR BEGIN  
  SELECT 0 AS Ret  
  ROLLBACK TRAN  
  RETURN  
 END  
  
 -- Clan을 유효하지 않은 상태로 설정.  
 UPDATE Clan SET DeleteFlag = 1, MasterCID = NULL WHERE CLID = @CLID  
 UPDATE Clan SET DeleteName = Name WHERE CLID = @CLID  
 UPDATE Clan SET Name = NULL WHERE CLID = @CLID  
 COMMIT TRAN  
 
 SELECT 1 AS Ret  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetClanRankingSearchByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [spGetClanRankingSearchByName]
	@Name VARCHAR(24)
AS
SET NOCOUNT ON
BEGIN
	SELECT TOP 20 Ranking, RankIncrease, Name as ClanName, Point, Wins, Losses, CLID, EmblemUrl FROM Clan(NOLOCK) 
	WHERE DeleteFlag=0 AND Ranking>0 AND Name=@Name ORDER BY Ranking
END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebChangeWinsLosses]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebChangeWinsLosses]
 @CLID int
, @NewWins int
, @NewLosses int
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON

 IF (0 > @NewWins) OR (0 > @NewLosses) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 UPDATE Clan SET Wins = @NewWins, Losses = @NewLosses 
 WHERE CLID = @CLID AND DeleteFlag <> 1
 IF 0=@@ROWCOUNT BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetClanRankingSearchByRanking]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 클랜 랭킹찾기 (순위로)
    Arg1 : @Ranking (순위) */
CREATE PROC [spGetClanRankingSearchByRanking]
	@Ranking INT
AS
SET NOCOUNT ON
BEGIN
	SELECT TOP 20 Ranking, RankIncrease, Name as ClanName, Point, Wins, Losses, CLID, EmblemUrl FROM Clan(NOLOCK) 
	WHERE DeleteFlag=0 AND Ranking>0 AND Ranking=@Ranking ORDER BY Ranking
END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWinTheClanGame]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
-- 클랜전 결과 업데이트  
CREATE  PROC [spWinTheClanGame]  
 @WinnerCLID  int,  
 @LoserCLID  int,  
 @IsDrawGame  tinyint,  
 @WinnerPoint  int,  
 @LoserPoint  int,  
 @WinnerClanName  varchar(24),  
 @LoserClanName  varchar(24),  
 @RoundWins  tinyint,  
 @RoundLosses  tinyint,  
 @MapID   tinyint,  
 @GameType  tinyint,  
 @WinnerMembers  varchar(110),  
 @LoserMembers  varchar(110)  
AS  
 SET NOCOUNT ON -- 추가.  
  
 IF @IsDrawGame = 0  
 BEGIN  
  BEGIN TRAN  
  -- 이긴팀 Wins+1  
  UPDATE Clan SET Wins=Wins+1, Point=Point+@WinnerPoint, TotalPoint=TotalPoint+@WinnerPoint WHERE CLID=@WinnerCLID  
  IF 0 = @@ROWCOUNT BEGIN -- 여기 추가.  
   ROLLBACK TRAN  
   RETURN  
  END  
  
  -- 진팀 Losses+1  
  UPDATE Clan SET Losses=Losses+1, Point= game.fnGetMax(0, Point+(@LoserPoint)) WHERE CLID=@LoserCLID  
  IF 0 = @@ROWCOUNT BEGIN -- 여기 추가.  
   ROLLBACK TRAN  
   RETURN  
  END  
--  UPDATE Clan SET Point=0 WHERE CLID=@LoserCLID AND Point<0  
  
  -- 전적 로그를 남긴다.  
  INSERT INTO ClanGameLog(WinnerCLID, LoserCLID, WinnerClanName, LoserClanName, RoundWins, RoundLosses, MapID, GameType, RegDate, WinnerMembers, LoserMembers, WinnerPoint, LoserPoint)  
  VALUES (@WinnerCLID, @LoserCLID, @WinnerClanName, @LoserClanName, @RoundWins, @RoundLosses, @MapID, @GameType, GETDATE(), @WinnerMembers, @LoserMembers, @WinnerPoint, @LoserPoint)  
  IF 0 <> @@ERROR BEGIN -- 여기 추가.  
   ROLLBACK TRAN  
   RETURN  
  END  
  COMMIT TRAN  
 END  
 ELSE  
 BEGIN  
  UPDATE Clan SET Draws=Draws+1 WHERE CLID=@WinnerCLID OR CLID=@LoserCLID  
 END  
  
  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetClanRanking]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- Master이름과 RegDate추가.
/* 클랜 랭킹보기 : 한페이지 20개씩 고정  
    Arg1 : @Page (페이지넘버)  
    Arg2 : @Backward (생략하면 정상순서, 1일경우 역순 */  
CREATE PROC [spGetClanRanking]  
 @Page INT,  
 @Backward INT  = 0  
AS  
SET NOCOUNT ON
BEGIN  
 /* 한페이지에 20개씩 보여준다 (속도를위해 갯수 고정) */  
 DECLARE @RowCount INT  
 DECLARE @PageHead INT  
  
 IF @Backward = 0  
 BEGIN  
  SELECT @RowCount = ((@Page -1) * 20 + 1)  
  SELECT TOP 20 cl.Ranking, cl.RankIncrease, cl.Name as ClanName, cl.Point, cl.Wins, cl.Losses, cl.CLID, cl.EmblemUrl, ch.Name AS Master, cl.RegDate
  FROM Clan cl(NOLOCK), Character ch(NOLOCK)
  WHERE cl.DeleteFlag=0 AND cl.Ranking>0 AND cl.Ranking >= @RowCount  AND ch.CID = cl.MasterCID
  ORDER BY cl.Ranking  
 END  
 ELSE  
 BEGIN  
  SELECT @RowCount = ((@Page -1) * 20 + 1)  
   
  SET ROWCOUNT @RowCount  
  SELECT @PageHead = Ranking FROM Clan(NOLOCK) WHERE DeleteFlag=0 ORDER BY Ranking DESC  
   
  SET ROWCOUNT 20  
  SELECT Ranking, RankIncrease, ClanName, Point, Wins, Losses, CLID, EmblemUrl, Master, RegDate FROM  
  (  
  -- SELECT TOP 20 Ranking, RankIncrease, Name as ClanName, Point, Wins, Losses, CLID, EmblemUrl 
   SELECT TOP 20 cl.Ranking, cl.RankIncrease, cl.Name as ClanName, cl.Point, cl.Wins, cl.Losses, cl.CLID, cl.EmblemUrl, ch.Name AS Master, cl.RegDate
   FROM Clan cl(NOLOCK), Character ch(NOLOCK)
   WHERE cl.DeleteFlag=0 AND cl.Ranking>0 AND cl.Ranking <= @PageHead AND ch.CID = cl.MasterCID
   ORDER BY cl.Ranking DESC  
  ) AS t ORDER BY Ranking  
 END  
END  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetClanRankingMaxPage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [spGetClanRankingMaxPage]
AS
SET NOCOUNT ON
BEGIN
	DECLARE @MaxPage INT
	SELECT TOP 1 @MaxPage = Ranking / 20 + 1 FROM Clan(NOLOCK) WHERE DeleteFlag=0 AND Ranking>0 ORDER BY Ranking DESC
--	SELECT @MaxPage
	RETURN @MaxPage
END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebChangeClanTotalPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebChangeClanTotalPoint]
 @CLID int
, @NewClanTotalPoint int
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON 

 IF 0 > @NewClanTotalPoint BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 UPDATE Clan SET TotalPoint = @NewClanTotalPoint 
 WHERE CLID = @CLID AND DeleteFlag <> 1
 IF 0 = @@ROWCOUNT BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetClanRankingHistory]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 클랜 역대 랭킹찾기
    Arg1 : @Year (년도) 
    Arg2 : @Month (월) 
    Arg3 : @Page (페이지) 
    Arg4 : @Backward (역순) */
CREATE  PROC [spGetClanRankingHistory]
	@Year INT,
	@Month INT,
	@Page INT,
	@Backward INT = 0
AS
SET NOCOUNT ON
BEGIN
	/* 한페이지에 20개씩 보여준다 (속도를위해 갯수 고정) */
	DECLARE @RowCount INT
	DECLARE @PageHead INT

	IF @Backward = 0
	BEGIN
		SELECT @RowCount = ((@Page -1) * 20 + 1)
		SELECT TOP 20 Ranking, ClanName as ClanName, Point, Wins, Losses, CLID FROM ClanHonorRanking(NOLOCK) 
		WHERE Year=@Year AND Month=@Month AND Ranking>0 AND Ranking >= @RowCount ORDER BY Ranking
	END
	ELSE
	BEGIN
		SELECT @RowCount = ((@Page -1) * 20 + 1)
	
		SET ROWCOUNT @RowCount
		SELECT @PageHead = Ranking FROM Clan(NOLOCK) WHERE DeleteFlag=0 ORDER BY Ranking DESC
	
		SET ROWCOUNT 20
		SELECT  Ranking, RankIncrease=0, ClanName, Point, Wins, Losses, CLID, EmblemUrl=NULL FROM
		(
			SELECT TOP 20 Ranking, ClanName, Point, Wins, Losses, CLID FROM ClanHonorRanking(NOLOCK) 
			WHERE Year=@Year AND Month=@Month AND Ranking>0 AND Ranking <= @PageHead ORDER BY Ranking DESC
		) AS t ORDER BY Ranking
	END
END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebChangeClanName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebChangeClanName]
 @CLID int
, @NewClanName varchar(24)
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON 

 IF EXISTS (SELECT CLID FROM Clan(NOLOCK) 
  WHERE Name = @NewClanName AND DeleteFlag <> 1) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 UPDATE Clan SET Name = @NewClanName 
 WHERE CLID = @CLID AND DeleteFlag <> 1
 IF 0 = @@ROWCOUNT BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebChangeClanPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebChangeClanPoint]
 @CLID int
, @NewClanPoint int
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON

 IF 0 > @NewClanPoint BEGIN 
  SET @Ret = 0
  RETURN @Ret
 END

 UPDATE Clan SET Point = @NewClanPoint 
  WHERE CLID = @CLID AND DeleteFlag <> 1
 IF 0 = @@ROWCOUNT BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetClanListSearchByMaster]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



/* 클랜 목록찾기 (마스터이름으로)  
    Arg1 : @CharName (클랜 마스터 이름) */  
CREATE PROC [spWebGetClanListSearchByMaster]  
 	@CharName VARCHAR(24)  
AS  
SET NOCOUNT ON
BEGIN  
  	SELECT TOP 1 cl.Ranking, cl.RankIncrease, cl.Name as ClanName, cl.Point, cl.Wins, cl.Losses, cl.CLID, cl.EmblemUrl, c.Name AS Master, cl.RegDate
	FROM Clan cl(NOLOCK), Character c(nolock)  
  	WHERE c.Name = @CharName AND cl.DeleteFlag = 0 AND cl.MasterCID = c.CID
END  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spConfirmExistClan]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 클랜이 존재하는지 확인하기
CREATE PROC [spConfirmExistClan]
	@ClanName		varchar(24)
AS
	SET NOCOUNT ON
	SELECT COUNT(*) FROM Clan(NOLOCK) WHERE Name=@ClanName


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spCreateClan]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 클랜 생성하기
CREATE PROC [spCreateClan]
	@ClanName		varchar(24),
	@MasterCID		int,
	@Member1CID		int,
	@Member2CID		int,
	@Member3CID		int,
	@Member4CID		int
AS
	DECLARE @NewCLID	int

	-- 클랜이름이 중복인지 검사해야한다.
	SELECT @NewCLID=CLID FROM Clan(NOLOCK) WHERE Name=@ClanName

	IF @NewCLID IS NOT NULL
	BEGIN
		SELECT 0 AS Ret, 0 AS NewCLID
		RETURN
	END


	DECLARE @CNT		int

	-- 클랜원이 모두 가입 가능한지 검사해야한다.
	SELECT @CNT = COUNT(*) FROM ClanMember cm(NOLOCK), Character c(NOLOCK) WHERE ((cm.CID=@MasterCID) OR (cm.CID=@Member1CID) OR (cm.CID=@Member2CID) OR (cm.CID=@Member3CID) OR
(cm.CID=@Member4CID) ) AND cm.CID=c.CID AND c.DeleteFlag=0

	IF @CNT != 0
	BEGIN
		SELECT 0 AS Ret, 0 AS NewCLID
		RETURN
	END


	BEGIN TRAN
	-- 클랜 생성
	INSERT INTO Clan (Name, MasterCID, RegDate) VALUES (@ClanName, @MasterCID, GETDATE())
	IF 0 <> @@ERROR BEGIN
		ROLLBACK TRAN
		SELECT 0 AS Ret, 0 AS NewCLID
		RETURN
	END

	SELECT @NewCLID = @@IDENTITY
	IF (@NewCLID IS not NULL)
	BEGIN
		DECLARE @Err1 int
		DECLARE @Err2 int
		DECLARE @Err3 int
		DECLARE @Err4 int
		DECLARE @Err5 int

		-- 클랜원 가입
		INSERT INTO ClanMember (CLID, CID, Grade, RegDate) VALUES (@NewCLID, @MasterCID, 1, GETDATE())
		SET @Err1 = @@ERROR		
		INSERT INTO ClanMember (CLID, CID, Grade, RegDate) VALUES (@NewCLID, @Member1CID, 9, GETDATE())
		SET @Err2 = @@ERROR
		INSERT INTO ClanMember (CLID, CID, Grade, RegDate) VALUES (@NewCLID, @Member2CID, 9, GETDATE())
		SET @Err3 = @@ERROR
		INSERT INTO ClanMember (CLID, CID, Grade, RegDate) VALUES (@NewCLID, @Member3CID, 9, GETDATE())
		SET @Err4 = @@ERROR
		INSERT INTO ClanMember (CLID, CID, Grade, RegDate) VALUES (@NewCLID, @Member4CID, 9, GETDATE())
		SET @Err5 = @@ERROR

		IF (0 <> @Err1) OR (0 <> @Err2) OR (0 <> @Err3) OR (0 <> @Err4) OR (0 <> @Err5) BEGIN
			ROLLBACK TRAN
			SELECT 0 AS Ret, 0 AS NewCLID
			RETURN
		END
	END
	COMMIT TRAN

	-- 마스터 바운티 삭제
	--UPDATE Character SET BP=BP-1000 WHERE CID=@MasterCID


	SELECT 1 AS Ret, @NewCLID AS NewCLID


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetClanRankByMaster]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 클랜 랭킹을 마스터 이름을 사용해서 검색.
CREATE PROC [spWebGetClanRankByMaster]
	@MasterName varchar(24)
AS
SET NOCOUNT ON
BEGIN
	SELECT cl.CLID, cl.Name AS ClanName, cl.Point, cl.Wins, cl.Losses, cl.EmblemUrl, cl.Ranking, cl.RankIncrease, c.Name AS Master, cl.RegDate
	FROM Clan cl(NOLOCK) JOIN Character c(NOLOCK) 
	ON c.Name = @MasterName AND cl.MasterCID = c.CID AND cl.Ranking > 0
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spDeleteClan]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 클랜 삭제하기
CREATE PROC [spDeleteClan]
	@CLID		int,
	@ClanName	varchar(24)

AS
	SET NOCOUNT ON
	-- 클랜원 모두 삭제
	DELETE FROM ClanMember WHERE CLID=@CLID

	-- 클랜 삭제
	UPDATE Clan SET Name=NULL, DeleteFlag=1, DeleteName=@ClanName WHERE CLID=@CLID



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetClanRanking]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- Master이름과 RegDate추가.
/* 클랜 랭킹보기 : 한페이지 20개씩 고정  
    Arg1 : @Page (페이지넘버)  
    Arg2 : @Backward (생략하면 정상순서, 1일경우 역순 */  
CREATE PROC [spWebGetClanRanking]  
 @Page INT,  
 @Backward INT  = 0  
AS  
SET NOCOUNT ON
BEGIN  
 /* 한페이지에 20개씩 보여준다 (속도를위해 갯수 고정) */  
 DECLARE @RowCount INT  
 DECLARE @PageHead INT  
  
 IF @Backward = 0  
 BEGIN  
  SELECT @RowCount = ((@Page -1) * 20 + 1)  
  SELECT TOP 20 cl.Ranking, cl.RankIncrease, cl.Name as ClanName, cl.Point, cl.Wins, cl.Losses, cl.CLID, cl.EmblemUrl, ch.Name AS Master, cl.RegDate
  FROM Clan cl(NOLOCK), Character ch(NOLOCK)
  WHERE cl.DeleteFlag=0 AND cl.Ranking>0 AND cl.Ranking >= @RowCount  AND ch.CID = cl.MasterCID
  ORDER BY cl.Ranking  
 END  
 ELSE  
 BEGIN  
  SELECT @RowCount = ((@Page -1) * 20 + 1)  
   
  SET ROWCOUNT @RowCount  
  SELECT @PageHead = Ranking FROM Clan(NOLOCK) WHERE DeleteFlag=0 ORDER BY Ranking DESC  
   
  SET ROWCOUNT 20  
  SELECT Ranking, RankIncrease, ClanName, Point, Wins, Losses, CLID, EmblemUrl, Master, RegDate FROM  
  (  
  -- SELECT TOP 20 Ranking, RankIncrease, Name as ClanName, Point, Wins, Losses, CLID, EmblemUrl 
   SELECT TOP 20 cl.Ranking, cl.RankIncrease, cl.Name as ClanName, cl.Point, cl.Wins, cl.Losses, cl.CLID, cl.EmblemUrl, ch.Name AS Master, cl.RegDate
   FROM Clan cl(NOLOCK), Character ch(NOLOCK)
   WHERE cl.DeleteFlag=0 AND cl.Ranking>0 AND cl.Ranking <= @PageHead AND ch.CID = cl.MasterCID
   ORDER BY cl.Ranking DESC  
  ) AS t ORDER BY Ranking  
 END  
END  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetClanRankingSearchByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 클랜 이름으로 검색.
CREATE PROC [spWebGetClanRankingSearchByName]  
 	@Name VARCHAR(24)  /* 클랜 이름 */
AS  
SET NOCOUNT ON
BEGIN  
 	SELECT TOP 1 cl.Ranking, cl.RankIncrease, cl.Name as ClanName, cl.Point, cl.Wins, cl.Losses, cl.CLID, cl.EmblemUrl, ch.Name AS Master, cl.RegDate
	FROM Clan cl(NOLOCK), Character ch(NOLOCK)
 	WHERE ch.CID = cl.MasterCID AND cl.Ranking>0 AND cl.DeleteFlag=0 AND cl.Name=@Name
END  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebLeaveClanByCID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



-- CID로 클랜 탈퇴.
CREATE  PROC [spWebLeaveClanByCID]
	@CID int /* 탈퇴요청 캐릭터 CID */
AS
SET NOCOUNT ON
BEGIN TRAN
	

	DECLARE @CLID int
	DECLARE @MasterCID int

	-- 존재하는 아이디인가?
	SELECT @CLID = cm.CLID, @MasterCID = cl.MasterCID
	FROM Clan cl(NOLOCK), ClanMember cm (NOLOCK)
	WHERE cm.CID = @CID AND cl.CLID = cm.CLID

	-- 클랜마스터가 아니고 클랜에 가입되 있을 경우만.
	IF (@CID IS NULL) OR (@MasterCID = @CID) OR (@CLID IS NULL)
	BEGIN
		ROLLBACK TRAN
		SELECT 0
		RETURN
	END
		
	DELETE ClanMember WHERE CID = @CID
	IF 0 <> @@ERROR
	BEGIN
		ROLLBACK TRAN
		SELECT 0
		RETURN
	END

	SELECT 1	
COMMIT TRAN
SET NOCOUNT OFF


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetCharClan]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 클랜이름 알아오기
CREATE PROC [spGetCharClan]
	@CID			int
AS
	SET NOCOUNT ON
	SELECT cl.CLID AS CLID, cl.Name AS ClanName FROM ClanMember cm(nolock), Clan cl(nolock) WHERE cm.cid=@CID AND cm.CLID=cl.CLID


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAddClanMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 멤버 추가
CREATE PROC [spAddClanMember]
	@CLID		int,
	@CID		int,
	@Grade		tinyint
AS
	SET NOCOUNT ON
	-- 클랜이 존재하는지 체크
	DECLARE @varClanCount		int

	SELECT @varClanCount=COUNT(*) FROM Clan(nolock) WHERE CLID=@CLID AND ((DeleteFlag IS NULL) OR (DeleteFlag=0))
	IF (@varClanCount = 0)
	BEGIN
		SELECT 0 AS Ret
		return (-1)
	END

	-- 클랜원수 체크
	DECLARE @MemberCount		int

	SELECT @MemberCount=COUNT(*) FROM ClanMember(nolock) WHERE CLID=@CLID
	IF @MemberCount >= 64	-- 최대 64명까지 가능
	BEGIN
		SELECT 0 AS Ret
		return (-1)
	END

	BEGIN TRAN
	INSERT INTO ClanMember (CLID, CID, Grade, RegDate) VALUES (@CLID, @CID, @Grade, GETDATE())
	IF 0 <> @@ERROR BEGIN
		ROLLBACK TRAN
		SELECT 0 AS Ret
		RETURN (-1)
	END
	COMMIT TRAN
	SELECT 1 AS Ret


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetMyClanInfoByCID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- My랭킹정보를 CID로 가져옴.  
CREATE PROC [spWebGetMyClanInfoByCID]  
 	@CID int /* 캐릭터 CID */  
AS  
SET NOCOUNT ON
BEGIN  
	SELECT t.Name, t.Name AS Master, t.IntroDuction, t.RegDate, t.Homepage, t.EmblemUrl, t.Ranking
	FROM 
	(
	 	SELECT cl.Name, cl.MasterCID, cl.IntroDuction, cl.RegDate, cl.Homepage, cl.EmblemUrl, cl.Ranking
	 	FROM ClanMember cm(NOLOCK), Clan cl(NOLOCK), Character ch(NOLOCK)  
	 	WHERE cm.CID = @CID AND cl.CLID = cm.CLID AND ch.CID = @CID  
	) AS t, Character ch(NOLOCK)
	WHERE t.MasterCID = ch.CID
END  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetMyClanInfoByCLID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE PROC [spWebGetMyClanInfoByCLID]
	@CLID int
AS
SET NOCOUNT ON
BEGIN
	SELECT cl.Name, ch.Name AS Master, cl.IntroDuction, cl.RegDate, cl.Homepage, cl.EmblemUrl, cl.Ranking
	FROM Clan cl(NOLOCK), Character ch(NOLOCK)
	WHERE cl.CLID = @CLID AND cl.DeleteFlag = 0 AND ch.CID = cl.MasterCID
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetAccountCharInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 캐릭터선택시 캐릭터 정보 가져오기
CREATE PROC [spGetAccountCharInfo]
	@AID		int
,	@CharNum	smallint
AS
SET NOCOUNT ON
DECLARE @CID		int
DECLARE @CLID		int
DECLARE @ClanName	varchar(24)
DECLARE @ClanGrade	int
DECLARE @ClanContPoint	int

SELECT @CID=CID FROM Character WITH (nolock) WHERE AID=@AID and CharNum=@CharNum

SELECT @CID AS CID, c.Name AS Name, c.CharNum AS CharNum, c.Level AS Level, c.Sex AS Sex, c.Hair AS Hair, c.Face AS Face,
       c.XP AS XP, c.BP AS BP,
       (SELECT cl.Name FROM Clan cl(nolock), ClanMember cm(nolock) WHERE cm.cid=@CID AND cm.CLID=cl.CLID) AS ClanName,
	head_itemid, chest_itemid, hands_itemid, legs_itemid, feet_itemid, fingerl_itemid, 
	fingerr_itemid, melee_itemid, primary_itemid, secondary_itemid, custom1_itemid, custom2_itemid
FROM Character AS c WITH (nolock)
WHERE c.CID = @CID



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetCLIDFromClanName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 클랜이름으로 CLID알아오기
CREATE PROC [spGetCLIDFromClanName]
	@ClanName		varchar(24)
AS
	SET NOCOUNT ON
	SELECT CLID FROM Clan(NOLOCK) WHERE Name=@ClanName


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebLeaveClanByCID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebLeaveClanByCID]  
 @CID int /* 탈퇴요청 캐릭터 CID */  
, @GMID varchar(20)
, @Ret int OUTPUT
AS  
 IF (@CID IS NULL) OR (@GMID IS NULL) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 DECLARE @CLID int  
 DECLARE @MasterCID int  
  
 -- 존재하는 아이디인가?  
 SELECT @CLID = cm.CLID, @MasterCID = cl.MasterCID  
 FROM Clan cl(NOLOCK), ClanMember cm(NOLOCK)  
 WHERE cm.CID = @CID AND cl.CLID = cm.CLID  
  
 -- 클랜마스터가 아니고 클랜에 가입되 있을 경우만.  
 IF (@CID IS NULL) OR (@MasterCID = @CID) OR (@CLID IS NULL) BEGIN  
  SET @Ret = 0
  RETURN @Ret
 END  
    
 DELETE ClanMember WHERE CID = @CID  
 IF 0 <> @@ERROR  
 BEGIN  
  SET @Ret = 0
  RETURN @Ret
 END  
  
 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[viewHonorRankGunzClan]'))
EXEC dbo.sp_executesql @statement = N'

----------------------------

CREATE  VIEW [viewHonorRankGunzClan]
AS

SELECT chr.CLID, chr.ClanName, chr.Point, chr.Wins, chr.Losses, c.EmblemUrl, chr.Ranking, chr.RankIncrease, chr.Year, chr.Month
FROM ClanHonorRanking chr(nolock), Clan c(nolock)
WHERE chr.CLID=c.CLID

' 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebDeleteClan]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 웹에서 클랜 폐쇄.
CREATE PROC [spWebDeleteClan]
	@MasterName varchar(24)	/* 마스터 이름 */
,	@ClanName varchar(24)	/* 방출할 클랜원 이름 */
AS
SET NOCOUNT ON
BEGIN TRAN
	SET NOCOUNT ON

	DECLARE @MasterCID int
	DECLARE @CLID int

	SELECT @MasterCID = c.MasterCID, @CLID = c.CLID
	FROM Clan c (NOLOCK), Character ch(NOLOCK)
	WHERE ch.Name = @MasterName AND c.MasterCID = ch.CID

	-- 요청 조건 검사.
	IF (@MasterCID IS NULL) OR (@CLID IS NULL)
	BEGIN
		SELECT 0 AS Ret
		ROLLBACK TRAN
		SET NOCOUNT OFF
		RETURN
	END

	-- Clan Member 삭제.
	DELETE ClanMember WHERE CLID = @CLID
	IF 0  <> @@ERROR
	BEGIN
		SELECT 0 AS Ret
		ROLLBACK TRAN
		SET NOCOUNT OFF
		RETURN
	END

	-- Clan을 유효하지 않은 상태로 설정.
	UPDATE Clan SET DeleteFlag = 1, MasterCID = NULL, DeleteName = Name WHERE CLID = @CLID
	IF 0 = @@ROWCOUNT BEGIN 
		SELECT 0 AS Ret
		ROLLBACK TRAN
		SET NOCOUNT OFF
		RETURN
	END

	UPDATE Clan SET Name = NULL WHERE CLID = @CLID
	IF 0 = @@ROWCOUNT BEGIN 
		SELECT 0 AS Ret
		ROLLBACK TRAN
		SET NOCOUNT OFF
		RETURN
	END

	SELECT 1 AS Ret

	SET NOCOUNT OFF
COMMIT TRAN


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[viewRankGunzClan]'))
EXEC dbo.sp_executesql @statement = N'

-------------------------------

CREATE  VIEW [viewRankGunzClan]
AS

SELECT CLID, Name as ClanName, Point, Wins, Losses, EmblemUrl, Ranking, RankIncrease
FROM Clan(nolock)
WHERE DeleteFlag=0 and Ranking>0

' 
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebDeleteClanByCID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- CID로 클랜 폐쇄.
CREATE  PROC [spWebDeleteClanByCID]
	@MasterCID int /* 마스터 CID */
AS
SET NOCOUNT ON
BEGIN TRAN

	DECLARE @CLID int

	SELECT @CLID = c.CLID
	FROM Clan c(NOLOCK)
	WHERE c.MasterCID = @MasterCID

	-- 요청 조건 검사.
	IF (@MasterCID IS NULL) OR (@CLID IS NULL)
	BEGIN
		SELECT 0 AS Ret
		ROLLBACK TRAN
--		SET NOCOUNT OFF
		Select 0
		RETURN
	END

	-- Clan Member 삭제.
	DELETE ClanMember WHERE CLID = @CLID
	IF 0  <> @@ERROR
	BEGIN
		SELECT 0 AS Ret
		ROLLBACK TRAN
--		SET NOCOUNT OFF
		Select 0
		RETURN
	END

	-- Clan을 유효하지 않은 상태로 설정.
	UPDATE Clan SET DeleteFlag = 1, MasterCID = NULL, DeleteName = Name WHERE CLID = @CLID
	-- UPDATE Clan SET DeleteName = Name WHERE CLID = @CLID
	IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN -- 여기 추가.
		SELECT 0 AS Ret
		ROLLBACK TRAN
		Select 0
		RETURN
	END
	UPDATE Clan SET Name = NULL WHERE CLID = @CLID
	IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN -- 여기 추가.
		SELECT 0 AS Ret
		ROLLBACK TRAN
		Select 0
		RETURN
	END

	SELECT 1

	
COMMIT TRAN
SET NOCOUNT OFF


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebFireClanMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 마스터가 클랜원 방출.
CREATE PROC [spWebFireClanMember]
	@Master varchar(24) 	/* 클랜 마스터 CID */
,	@ClanMem varchar(24) 	/* 방출할 클랜원 캐릭터 CID */
AS
SET NOCOUNT ON
BEGIN TRAN
	DECLARE @MasterCID int
	DECLARE @CLID int
	DECLARE @ClanMemCID int

	-- 자격 검사를 위해 클랜아이디와 마스터 아이티를 구함.
	SELECT @CLID = cl.CLID, @MasterCID = cl.MasterCID
	FROM Character ch(NOLOCK), Clan cl(NOLOCK)
	WHERE ch.Name = @Master AND cl.MasterCID = ch.CID

	-- 방충하려는 클랜 맴버.
	SELECT @ClanMemCID = ch.CID
	FROM Character ch(NOLOCK)
	WHERE ch.Name = @ClanMem

	-- 클랜이 존재하고 클랜맴버가 존재해야 하고 방출되는 맴버가 마스터가 아니어야 함.
	IF (@CLID IS NULL) OR (@ClanMemCID IS NULL) OR (@MasterCID = @ClanMemCID)
	BEGIN
		ROLLBACK TRAN
		SELECT 0
		RETURN
	END

	DELETE ClanMember 
	WHERE CLID = @CLID AND 	CID = @ClanMemCID
	IF 0 <> @@ERROR
	BEGIN
		ROLLBACK TRAN
		SELECT 0
		RETURN
	END

	SELECT 1
COMMIT TRAN
SET NOCOUNT OFF


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebAddClanMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebAddClanMember]
 @CLID int
, @NewCID int
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON 

 IF NOT EXISTS (SELECT CID FROM Character(NOLOCK)
  WHERE CID = @NewCID AND DeleteFlag <> 1) BEGIN 
  SET @Ret = 0
  RETURN @Ret
 END 

 IF NOT EXISTS (SELECT CLID FROM Clan(NOLOCK) 
  WHERE CLID = @CLID AND DeleteFlag <> 1) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 IF EXISTS (SELECT CMID FROM ClanMember(NOLOCK)
  WHERE CID = @NewCID) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 INSERT INTO ClanMember(CLID, CID, Grade, RegDate, ContPoint)
 VALUES (@CLID, @NewCID, 9, GETDATE(), 0)
 IF 0 <> @@ERROR BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetCharInfoByCharNum]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 캐릭터 정보 가져오기
CREATE  PROC [spGetCharInfoByCharNum]
	@AID		int
,	@CharNum	smallint
AS
SET NOCOUNT ON

DECLARE @CID		int
DECLARE @CLID		int
DECLARE @ClanName	varchar(24)
DECLARE @ClanGrade	int
DECLARE @ClanContPoint	int
BEGIN
SELECT @CID=CID FROM Character WITH (nolock) WHERE AID=@AID and CharNum=@CharNum
SELECT @CLID=cl.CLID, @ClanName=cl.Name, @ClanGrade=cm.Grade, @ClanContPoint=cm.ContPoint FROM ClanMember cm(nolock), Clan cl(nolock) WHERE cm.cid=@CID AND cm.CLID=cl.CLID

SELECT CID, AID, Name, Level, Sex, CharNum, Hair, Face, XP, BP, HP, AP, FR, CR, ER, WR, GameCount, KillCount, DeathCount, PlayTime,
       head_slot, chest_slot, hands_slot, legs_slot, feet_slot, fingerl_slot, fingerr_slot, melee_slot, primary_slot,
       secondary_slot, custom1_slot, custom2_slot,
       @CLID AS CLID, @ClanName AS ClanName, @ClanGrade AS ClanGrade, @ClanContPoint AS ClanContPoint 
FROM Character WITH (nolock) where cid=@CID
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetClanInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 클랜 정보 얻기
CREATE PROC [spGetClanInfo]
	@CLID			int
AS
SET NOCOUNT ON

SELECT cl.CLID AS CLID, cl.Name AS Name, cl.TotalPoint AS TotalPoint, cl.Level AS Level, cl.Ranking AS Ranking,
cl.Point AS Point, cl.Wins AS Wins, cl.Losses AS Losses, cl.Draws AS Draws,
c.Name AS ClanMaster,
(SELECT COUNT(*) FROM ClanMember WHERE CLID=@CLID) AS MemberCount,
cl.EmblemUrl AS EmblemUrl, cl.EmblemChecksum AS EmblemChecksum

FROM Clan cl(nolock), Character c(nolock)
WHERE cl.CLID=@CLID and cl.MasterCID=c.CID




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetClanHonorRanking]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 클랜 명예의 전당 보기 월별 10위까지 
	2004년 9월 ~ 현재저번달까지(이달 제외) */
CREATE PROC [spGetClanHonorRanking]
	@Year INT,
	@Month INT
AS
SET NOCOUNT ON
BEGIN
	SELECT TOP 10 r.Ranking, r.ClanName, r.Point, r.Wins, r.Losses, r.CLID, c.EmblemUrl 
	FROM ClanHonorRanking r(NOLOCK), Clan c(NOLOCK)
	WHERE r.CLID=c.CLID AND Year = @Year AND Month = @Month
	ORDER BY r.Ranking
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetClanList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 클랜 목록 보기 
    한페이지 15개씩 고정, 최대 페이지 수를 위해 COUNT(*) 알아내지 말것.(이전,다음 페이지로 해결) 
    Arg1 : @Page (페이지넘버)
    Arg2 : @Backward (생략하면 정상순서, 1일경우 역순 					*/
CREATE PROC [spGetClanList]
	@Page INT,
	@Backward INT  = 0
AS
SET NOCOUNT ON
BEGIN
	DECLARE @PageHead INT
	DECLARE @RowCount INT

	IF @Backward = 0
	BEGIN
		SELECT @RowCount = ((@Page -1) * 15 + 1)
		
		SET ROWCOUNT @RowCount
		SELECT @PageHead = CLID FROM Clan(NOLOCK) WHERE DeleteFlag=0 ORDER BY CLID DESC
		
		SET ROWCOUNT 15
		SELECT cl.CLID AS CLID, cl.Name as ClanName, c.Name AS Master, cl.RegDate AS RegDate, cl.EmblemUrl AS EmblemUrl, cl.Point AS Point
		FROM Clan cl(NOLOCK), Character c(nolock)
		WHERE cl.MasterCID=c.CID AND cl.DeleteFlag=0 AND cl.CLID<@PageHead 
		ORDER BY cl.CLID DESC
	END
	ELSE
	BEGIN	-- 역순
		SELECT @RowCount = ((@Page -1) * 15 + 1)
		
		SET ROWCOUNT @RowCount
		SELECT @PageHead = CLID FROM Clan(NOLOCK) WHERE DeleteFlag=0 ORDER BY CLID
		
		SET ROWCOUNT 15
		SELECT CLID, ClanName, Master, RegDate, EmblemUrl, Point
		FROM
		(
			SELECT TOP 15 cl.CLID AS CLID, cl.Name as ClanName, c.Name AS Master, cl.RegDate AS RegDate, cl.EmblemUrl AS EmblemUrl, cl.Point AS Point
			FROM Clan cl(NOLOCK), Character c(nolock)
			WHERE cl.MasterCID=c.CID AND cl.DeleteFlag=0 AND cl.CLID>=@PageHead ORDER BY cl.CLID
		) AS t
		ORDER BY CLID DESC
	END
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebChangeClanEXP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebChangeClanEXP]
 @CLID int
, @NewEXP int
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON

 IF 0 > @NewEXP BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 UPDATE Clan SET EXP = @NewEXP 
  WHERE CLID = @CLID AND DeleteFlag <> 1
 IF 0 = @@ROWCOUNT BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetClanListSearchByMaster]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 클랜 목록찾기 (마스터이름으로)
    Arg1 : @CharName (클랜이름) */
CREATE PROC [spGetClanListSearchByMaster]
	@CharName VARCHAR(24)
AS
SET NOCOUNT ON
BEGIN

SELECT TOP 20 cl.CLID, cl.Name as ClanName, c.Name AS Master, cl.RegDate, cl.EmblemUrl, cl.Point
FROM Clan cl(NOLOCK), Character c(nolock)

WHERE cl.DeleteFlag=0 AND cl.MasterCID=c.CID and c.Name=@CharName
ORDER BY cl.CLID

END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebChangeClanHomepage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebChangeClanHomepage]
 @CLID int
, @NewHomePage varchar(128)
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON 

 UPDATE Clan SET Homepage = @NewHomepage 
  WHERE CLID = @CLID AND DeleteFlag <> 1
 IF 0 = @@ROWCOUNT BEGIN 
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetClanListSearchByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 클랜 목록찾기 (이름으로)
    Arg1 : @Name (클랜이름) */
CREATE PROC [spGetClanListSearchByName]
	@Name VARCHAR(24)
AS
SET NOCOUNT ON
BEGIN
	SELECT TOP 20 cl.CLID AS CLID, cl.Name as ClanName, c.Name AS Master, cl.RegDate AS RegDate, cl.EmblemUrl AS EmblemUrl, cl.Point AS Point
	FROM Clan cl(NOLOCK), Character c(NOLOCK)
	WHERE cl.MasterCID=c.CID AND c.DeleteFlag=0 AND cl.Name=@Name 
	ORDER BY cl.CLID
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebChangeClanIntroduction]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebChangeClanIntroduction]  
 @CLID int  
, @NewIntroduction varchar(1024)  
, @GMID varchar(20)
, @Ret int OUTPUT  
AS  
 SET NOCOUNT ON  
  
 UPDATE Clan SET Introduction = @NewIntroduction WHERE CLID = @CLID  
 IF 0 = @@ROWCOUNT BEGIN  
  SET @Ret = 0  
  RETURN @Ret  
 END  
  
 SET @Ret = 1  
 RETURN @Ret  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebReplyClanAdsBoard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------

-- 게시물 답글
CREATE PROC [spWebReplyClanAdsBoard]
 @Seq		int,
 @UserID	varchar(20),
 @Subject	varchar(50),
 @Content	varchar(2000),
 @FileName	varchar(128),
 @Link		varchar(255),
 @HTML		smallint,
 @GR_ID		int,
 @GR_Depth	int,
 @GR_Pos	int
AS
 SET NOCOUNT ON
 DECLARE @ParentThread       int
 DECLARE @PrevThread          int

 SELECT @ParentThread = Thread FROM ClanAdsBoard(NOLOCK) WHERE Seq = @Seq
 SELECT @PrevThread = @ParentThread -1000 FROM ClanAdsBoard(NOLOCK) WHERE GR_ID =@GR_ID and GR_Depth = ''0''

 BEGIN TRAN
 UPDATE ClanAdsBoard 
 SET Thread = Thread - 1
 WHERE Thread < @ParentThread and Thread > @PrevThread
 IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
  ROLLBACK TRAN
  RETURN
 END

 UPDATE ClanAdsBoard SET GR_Pos =GR_Pos+1
 WHERE GR_ID = @GR_ID and GR_Pos = @GR_Pos
 IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
  ROLLBACK TRAN
  RETURN
 END

 SET @GR_Depth = @GR_Depth+1;
 SET @GR_Pos = @GR_Pos + 1;

 INSERT INTO ClanAdsBoard (UserID, Subject, Content,  Regdate, ReadCount,  FileName, Link, HTML, GR_ID, GR_Depth, GR_Pos, Thread)
 VALUES	(@UserID, @Subject, @Content,  GetDate(), 0, @FileName, @Link, @HTML, @GR_ID, @GR_Depth, @GR_Pos, @ParentThread-1)
 IF (@@ERROR <> 0) BEGIN
  ROLLBACK TRAN
  RETURN
 END

 COMMIT TRAN

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebSearchClanAdsBoardbySubject]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------

-- 게시물 검색 by Subject 
CREATE PROC [spWebSearchClanAdsBoardbySubject]
 @Subject	varchar(30)
AS
 SET NOCOUNT ON
 SELECT Seq, Userid, Subject, RegDate, ReadCount, Recommend, CommentCount
 FROM ClanAdsBoard(NOLOCK)
 WHERE Subject like @Subject
 ORDER BY Thread DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebSearchClanAdsBoardbyUserID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------

CREATE PROC [spWebSearchClanAdsBoardbyUserID]
 @UserID	varchar(20)
AS
 SET NOCOUNT ON
 SELECT Seq, Userid, Subject, RegDate, ReadCount, Recommend, CommentCount
 FROM ClanAdsBoard (NOLOCK)
 WHERE UserID = @UserID
 ORDER BY Thread DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebDeleteClanAdsComment]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------

-- 코멘트 게시물 삭제
CREATE PROC [spWebDeleteClanAdsComment]
 @ID int
AS
 SET NOCOUNT ON
 DECLARE @Seq    int

 SELECT @Seq = Seq FROM ClanAdsComment(NOLOCK) WHERE ID = @ID

 BEGIN TRAN
 DELETE ClanAdsComment WHERE ID = @ID
 IF (@@ERROR <> 0) BEGIN
  ROLLBACK TRAN
  RETURN
 END

 UPDATE ClanAdsBoard SET CommentCount = CommentCount - 1 WHERE Seq = @Seq
 IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
  ROLLBACK TRAN
  RETURN
 END

 COMMIT TRAN

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebDeleteClanAdsBoard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------

-- 게시물 삭제
CREATE PROC [spWebDeleteClanAdsBoard]
 @Seq int
AS
 SET NOCOUNT ON
 BEGIN TRAN
 DELETE ClanAdsBoard  WHERE Seq = @Seq
 IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
  ROLLBACK TRAN
  RETURN
 END

 DECLARE @SEQCOUNT int

 SELECT @SEQCOUNT = COUNT(Seq) FROM ClanAdsComment(NOLOCK) WHERE Seq = @Seq

 IF ( @SEQCOUNT > 0) BEGIN
  DELETE ClanAdsComment  WHERE Seq = @Seq
  IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
   ROLLBACK TRAN
   RETURN 
  END
 END
 COMMIT TRAN

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebInsertClanAdsBoard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spWebInsertClanAdsBoard]
 @UserID	varchar(20),
 @Subject	varchar(50),
 @Content	varchar(2000),
 @FileName	varchar(128),
 @Link		varchar(255),
 @HTML		smallint
AS
 SET NOCOUNT ON
 DECLARE @NewThread int
 SELECT @NewThread = ISNULL(MAX(Thread), 0) + 1000 FROM ClanAdsBoard(NOLOCK) 

 BEGIN TRAN
 INSERT INTO ClanAdsboard (UserID, Subject, Content,  Regdate, ReadCount, FileName, Link, HTML, GR_ID, GR_Depth,GR_Pos,Thread)
 VALUES (@UserID, @Subject, @Content,  GetDate(), 0, @FileName, @Link, @HTML, 0,0,0,@NewThread)
 IF 0 <> @@ERROR BEGIN
  ROLLBACK TRAN
  RETURN
 END

 UPDATE ClanAdsBoard SET GR_ID = seq where GR_ID = 0
 IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
  ROLLBACK TRAN
  RETURN
 END

 COMMIT TRAN

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebInsertClanAdsComment]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------

-- 코멘트 게시물 등록
CREATE PROC [spWebInsertClanAdsComment]
 @Seq int,
 @Userid varchar(20),
 @Content varchar(500)
AS
 SET NOCOUNT ON

 BEGIN TRAN
 INSERT INTO ClanAdsComment (Seq, UserID, Content, RegDate)
 VALUES(@Seq,  @UserID, @Content, GetDate())
 IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
  ROLLBACK TRAN
  RETURN
 END

 UPDATE ClanAdsBoard SET CommentCount = CommentCount + 1 WHERE Seq = @Seq
 IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
  ROLLBACK TRAN
  RETURN
 END

 COMMIT TRAN

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetClanAdsBoardContent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------

-- 게시물 내용 조회
CREATE PROC [spWebGetClanAdsBoardContent]
 @Seq int
AS
 SET NOCOUNT ON
 SELECT Seq, Userid, Subject, Content, RegDate, ReadCount, Recommend, FileName, 
  Link, HTML, CommentCount, GR_ID, GR_Depth, GR_Pos, Thread
 FROM ClanAdsBoard 
 WHERE Seq = @Seq
 ORDER BY Thread DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetClanAdsBoardList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------

-- 게시물 조회
CREATE PROC [spWebGetClanAdsBoardList]
AS
 SET NOCOUNT ON
 SELECT Seq, Userid, Subject, RegDate, ReadCount, Recommend, CommentCount
 FROM ClanAdsBoard(NOLOCK)
 ORDER BY Thread DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebUpdateClanAdsBoard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------

-- 게시물 수정
CREATE PROC [spWebUpdateClanAdsBoard]
 @Seq		int,
 @Subject	varchar(50),
 @Content	varchar(2000),
 @FileName	varchar(128),
 @Link		varchar(255),
 @HTML		smallint
AS
 SET NOCOUNT ON
 UPDATE ClanAdsBoard
 SET Subject= @Subject, Content=@Content, FileName=@FileName, Link=@Link, HTML=@HTML
 WHERE Seq = @Seq

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebUpdateClanAdsBoardReadCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------

CREATE PROC [spWebUpdateClanAdsBoardReadCount]
 @Seq int
AS
 SET NOCOUNT ON
 UPDATE ClanAdsBoard SET ReadCount = ReadCount + 1 WHERE Seq = @Seq

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetClanAdsCommentContent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------

-- 게시물 코멘트 내용 조회
CREATE PROC [spWebGetClanAdsCommentContent]
 @Seq int
AS
 SET NOCOUNT ON
 SELECT ID, Userid, Content, RegDate
 FROM ClanAdsComment(NOLOCK)
 WHERE Seq = @Seq
 ORDER BY RegDate

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetClanAdsCommentContentByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

----------------------------------------------------------------------------

CREATE PROC [spWebGetClanAdsCommentContentByID]
 @ID int
AS
 SET NOCOUNT ON
 SELECT ID, Userid, Content, RegDate
 FROM ClanAdsComment(NOLOCK)
 WHERE ID = @ID
 ORDER BY RegDate

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebDeleteClanBoardComment]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------------------------------------------------------------------

-- 코멘트 게시물 삭제

CREATE PROC [spWebDeleteClanBoardComment]
 @ID int
AS
 SET NOCOUNT ON
 DECLARE @Seq    int

 SELECT @Seq = Seq FROM ClanBoardComment(NOLOCK) Where ID = @ID

 BEGIN TRAN
 DELETE ClanBoardComment WHERE ID = @ID
 IF (@@ERROR <> 0) BEGIN
  ROLLBACK TRAN
  RETURN
 END

 Update ClanBoard Set CommentCount = CommentCount - 1 WHERE Seq = @Seq
 IF (0 <> @@ERROR) BEGIN
  ROLLBACK TRAN
  RETURN
 END
 COMMIT TRAN

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebDeleteClanBoard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------------------------------------------------------------------

-- 게시물 삭제

CREATE PROC [spWebDeleteClanBoard]
 	@Seq int
AS
 SET NOCOUNT ON
 BEGIN TRAN
 DELETE ClanBoard  WHERE Seq = @Seq
 IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
  ROLLBACK TRAN
  RETURN
 END

 DECLARE @SEQCOUNT int

 SELECT @SEQCOUNT = COUNT(Seq) FROM ClanBoardComment(NOLOCK) WHERE Seq = @Seq

 IF ( @SEQCOUNT > 0) BEGIN
  DELETE ClanBoardComment  WHERE Seq = @Seq
  IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
   ROLLBACK TRAN
   RETURN 
  END
 END
 COMMIT TRAN


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebInsertClanBoard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------------------------------------------------------------------

/***************************************************************************/
/****			클랜  게시판 관련 프로시져			****/
/***************************************************************************/


-- 게시물 등록

CREATE   PROC [spWebInsertClanBoard]
 @CLID		int,
 @UserID		varchar(20),
 @Subject	varchar(50),
 @Content	varchar(4000),
 @FileName	varchar(128),
 @Link		varchar(255),
 @HTML		smallint
AS
 SET NOCOUNT ON
 DECLARE @NewThread int
 SELECT @NewThread = ISNULL(MAX(Thread),0) + 1000 FROM ClanBoard(NOLOCK)

 BEGIN TRAN
 INSERT INTO ClanBoard (CLID, UserID, Subject, Content,  Regdate, ReadCount, FileName, Link, HTML, GR_ID, GR_Depth,GR_Pos,Thread)
 VALUES	(@CLID, @UserID, @Subject, @Content,  GetDate(), 0, @FileName, @Link, @HTML, 0,0,0,@NewThread)
 IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
  ROLLBACK TRAN
  RETURN
 END

 UPDATE ClanBoard SET GR_ID = seq where GR_ID = 0
 IF( 0 <> @@ERROR) BEGIN
  ROLLBACK TRAN
  RETURN
 END
 COMMIT TRAN

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetClanBoardList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------------------------------------------------------------------

-- 게시물 조회

CREATE PROC [spWebGetClanBoardList]
 @CLID int
AS
 SET NOCOUNT ON
 SELECT Seq, CLID, Userid, Subject, RegDate, ReadCount, Recommend, CommentCount
 FROM ClanBoard(NOLOCK)
 WHERE CLID = @CLID
 ORDER BY Thread DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebInsertClanBoardComment]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------------------------------------------------------------------

-- 코멘트 게시물 등록

CREATE PROC [spWebInsertClanBoardComment]
 @Seq int,
 @UserID varchar(20),
 @Content varchar(500)
AS
 SET NOCOUNT ON
 BEGIN TRAN
 INSERT INTO ClanBoardComment (Seq, UserID, Content, RegDate)
 VALUES(@Seq,  @UserID, @Content, GetDate())
 IF (@@ERROR <> 0)  BEGIN
  ROLLBACK TRAN
  RETURN
 END

 Update ClanBoard Set CommentCount = CommentCount + 1 WHERE Seq = @Seq
 IF (0 <> @@ERROR) BEGIN
  ROLLBACK TRAN
  RETURN
 END
 COMMIT TRAN

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetClanBoardContent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------------------------------------------------------------------

-- 게시물 내용 조회

CREATE PROC [spWebGetClanBoardContent]
 @Seq int
AS
 SET NOCOUNT ON
 SELECT Seq, CLID, Userid, Subject, Content, RegDate, ReadCount, Recommend, FileName,
  Link, HTML, CommentCount, GR_ID, GR_Depth, GR_Pos, Thread
 FROM ClanBoard (NOLOCK)
 WHERE Seq = @Seq
 ORDER BY Thread DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebUpdateClanBoard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------------------------------------------------------------------


-- 게시물 수정

CREATE   PROC [spWebUpdateClanBoard]
 @Seq		int,
 @Subject	varchar(50),
 @Content	varchar(4000),
 @FileName	varchar(128),
 @Link		varchar(255),
 @HTML		smallint
AS
 SET NOCOUNT ON
 UPDATE ClanBoard
 SET Subject= @Subject, Content=@Content,
   FileName=@FileName, Link=@Link, HTML=@HTML
 WHERE Seq = @Seq

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebUpdateClanBoardReadCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------------------------------------------------------------------

-- 조회수 증가 

CREATE PROC [spWebUpdateClanBoardReadCount]
 @Seq int
AS
 SET NOCOUNT ON
 Update ClanBoard Set ReadCount = ReadCount + 1 WHERE Seq = @Seq

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebReplyClanBoard]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------------------------------------------------------------------

-- 게시물 답글

CREATE   PROC [spWebReplyClanBoard]
 @Seq		int,
 @UserID	varchar(20),
 @Subject	varchar(50),
 @Content	varchar(4000),
 @FileName	varchar(128),
 @Link		varchar(255),
 @HTML		smallint,
 @GR_ID		int,
 @GR_Depth	int,
 @GR_Pos	int
AS
 SET NOCOUNT ON
 DECLARE @CLID	int
 DECLARE @ParentThread       int
 DECLARE @PrevThread          int

 SELECT @CLID = CLID FROM ClanBoard(NOLOCK) Where Seq = @Seq
 SELECT @ParentThread = Thread FROM ClanBoard(NOLOCK) Where Seq = @Seq
 SELECT @PrevThread = @ParentThread -1000 FROM ClanBoard(NOLOCK) where GR_ID =@GR_ID and GR_Depth = ''0''

 BEGIN TRAN
 UPDATE ClanBoard 
 SET Thread = Thread - 1
 Where Thread < @ParentThread and Thread > @PrevThread
 IF (@@ERROR <> 0) BEGIN
  ROLLBACK TRAN
  RETURN
 END

 UPDATE ClanBoard SET GR_Pos =GR_Pos+1
 WHERE GR_ID = @GR_ID and GR_Pos = @GR_Pos
 IF (@@ERROR <> 0) BEGIN
  ROLLBACK TRAN
  RETURN
 END

 SET @GR_Depth = @GR_Depth+1;
 SET @GR_Pos = @GR_Pos + 1;

 INSERT INTO ClanBoard (CLID, UserID, Subject, Content,  Regdate, ReadCount,  FileName, Link, HTML, GR_ID, GR_Depth, GR_Pos, Thread)
 VALUES (@CLID, @UserID, @Subject, @Content,  GetDate(), 0, @FileName, @Link, @HTML, @GR_ID, @GR_Depth, @GR_Pos, @ParentThread-1)
 IF (@@ERROR <> 0) BEGIN
  ROLLBACK TRAN
  RETURN
 END
 COMMIT TRAN

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebSearchClanBoardbySubject]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------------------------------------------------------------------

-- 게시물 검색 by Subject 

CREATE PROC [spWebSearchClanBoardbySubject]
 @CLID int
, @Subject varchar(30)
AS
 SET NOCOUNT ON
 SELECT Seq, CLID, Userid, Subject, RegDate, ReadCount, Recommend, CommentCount
 FROM ClanBoard(NOLOCK)
 WHERE CLID = @CLID and Subject like @Subject
 ORDER BY Thread DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebSearchClanBoardbyUserID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------------------------------------------------------------------

-- 게시물 검색 by UserID 

CREATE PROC [spWebSearchClanBoardbyUserID]
 @CLID int
, @UserID varchar(20)
AS
 SET NOCOUNT ON
 SELECT Seq, CLID, Userid, Subject, RegDate, ReadCount, Recommend, CommentCount
 FROM ClanBoard(NOLOCK)
 WHERE CLID = @CLID and UserID = @UserID
 ORDER BY Thread DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetClanBoardCommentContentByID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------------------------------------------------------------------

-- 게시물 코멘트 내용 조회 By ID

CREATE PROC [spWebGetClanBoardCommentContentByID]
 @ID int
AS
 SET NOCOUNT ON
 SELECT ID, Userid, Content, RegDate
 FROM ClanBoardComment(NOLOCK)
 WHERE ID = @ID
 ORDER BY RegDate

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetClanBoardCommentContent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------------------------------------------------------------------

-- 게시물 코멘트 내용 조회

CREATE PROC [spWebGetClanBoardCommentContent]
 @Seq int
AS
 SET NOCOUNT ON
 SELECT ID, Userid, Content, RegDate
 FROM ClanBoardComment (NOLOCK)
 WHERE Seq = @Seq
 ORDER BY RegDate

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebSearchClanMemberByCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

---------------------------------------------------------------------------

CREATE PROC [spWebSearchClanMemberByCharName]  
 @CLID int  
, @CharName varchar(20)  
AS  
 SET NOCOUNT ON  
 SELECT cm.CLID, cm.Grade, c.Name, c.Level, c.XP, cm.RegDate  
 FROM ClanMember cm(NOLOCK) JOIN Character c(NOLOCK)  
 ON cm.CLID = @CLID AND c.CID = cm.CID AND c.Name = @CharName  
 ORDER BY cm.RegDate DESC  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetClanMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 클랜원 알아오기
CREATE PROC [spGetClanMember]
	@CLID		int
AS
	SET NOCOUNT ON
	SELECT cm.clid AS CLID, cm.Grade AS ClanGrade, c.cid AS CID, c.name AS CharName
	FROM ClanMember cm(nolock), Character c(nolock)
	WHERE CLID=@CLID AND cm.cid=c.cid


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spUpdateClanGrade]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



-- 권한 변경
CREATE PROC [spUpdateClanGrade]
	@CLID		int,
	@CID		int,
	@NewGrade	tinyint
AS
	SET NOCOUNT ON
	UPDATE ClanMember SET Grade=@NewGrade WHERE CLID=@CLID AND CID=@CID


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spUpdateCharClanContPoint]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 클랜기여도 업데이트
CREATE PROC [spUpdateCharClanContPoint]
	@CID		int,
	@CLID		int,
	@AddedContPoint	int
AS
	SET NOCOUNT ON
	Update ClanMember SET ContPoint=ContPoint+@AddedContPoint WHERE CID=@CID AND CLID=@CLID


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetClanMembers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spWebGetClanMembers]
 @CLID int
AS
 SET NOCOUNT ON
 SELECT cm.CLID, cm.Grade, c.Name, c.Level, c.XP, cm.RegDate
 FROM ClanMember cm(NOLOCK) JOIN Character c(NOLOCK)
 ON cm.CLID = @CLID AND c.CID = cm.CID
 ORDER BY cm.RegDate DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebChangeClanMemberGrade]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebChangeClanMemberGrade]
 @CLID int
, @CID int
, @NewGrade int
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON 

 IF NOT EXISTS (SELECT GradeID FROM ClanMemberGrade(NOLOCK) 
  WHERE GradeID=@NewGrade) BEGIN
  SET @Ret=0
  RETURN @Ret
 END

 IF 1=@NewGrade BEGIN -- master duplication check.
  IF EXISTS (SELECT CID FROM ClanMember(NOLOCK) 
   WHERE CLID=@CLID AND Grade=@NewGrade) BEGIN
   SET @Ret=0
   RETURN @Ret
  END
 END

 UPDATE ClanMember SET Grade=@NewGrade WHERE CLID=@CLID AND CID=@CID
 IF 0=@@ROWCOUNT BEGIN
  SET @Ret=0
  RETURN @Ret
 END

 SET @Ret=1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spRemoveClanMember]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 멤버 삭제
CREATE PROC [spRemoveClanMember]
	@CLID		int,
	@CID		int
AS
	SET NOCOUNT ON
	DELETE FROM ClanMember WHERE (CLID=@CLID) AND (CID=@CID) AND (Grade != 1)


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spRemoveClanMemberFromCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 멤버 이름으로 멤버 삭제
CREATE PROC [spRemoveClanMemberFromCharName]
	@CLID				int,
	@AdminGrade			int,		-- 탈퇴시키려고 하는 사람의 권한
	@MemberCharName		varchar(36)
AS
	SET NOCOUNT ON
	DECLARE @CID				int
	DECLARE @MemberGrade		int


	SELECT @CID=c.cid, @MemberGrade=cm.Grade FROM Character c(nolock), ClanMember cm(nolock)
	WHERE cm.clid=@CLID AND c.cid=cm.cid AND c.Name=@MemberCharName AND (DeleteFlag=0)

	IF (@CID IS NULL)
	BEGIN
		SELECT 0 As Ret
		return (-1)
	END

	IF @AdminGrade >= @MemberGrade
	BEGIN
		SELECT 2 As Ret
		return (-1)
	END


	IF @CID IS NOT NULL
	BEGIN
		BEGIN TRAN
		DELETE FROM ClanMember WHERE (CLID=@CLID) AND (CID=@CID) AND (Grade != 1)
		IF 0 <> @@ERROR BEGIN 
			ROLLBACK TRAN
			SELECT 3 AS Ret -- 수정된 부분. By SungE
			RETURN
		END
		COMMIT TRAN
		SELECT 1 As Ret
	END

/* Ret값 설명 : 1 - 성공, 0 - 해당클랜원이 없다. , 2 - 권한이 맞지 않다. */


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spIPFltGetCountryCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spIPFltGetCountryCode]
AS
 SET NOCOUNT ON
 SELECT CountryCode3, CountryName
 FROM CountryCode(NOLOCK)
 ORDER BY CountryCode3 ASC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spIPFltGetCustomIP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spIPFltGetCustomIP]
 @IP varchar(15)
AS
 SET NOCOUNT ON
 DECLARE @TmpIP bigint

 SET @TmpIP = GunzDB.game.inet_aton( @IP )

 SELECT IPFrom, IPTo, IsBlock, Comment, RegDate 
 FROM CustomIP(NOLOCK)        
 WHERE IPFrom <= @TmpIP AND IPTo >= @TmpIP

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spIPFltGetCustomIPList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spIPFltGetCustomIPList]
AS
 SET NOCOUNT ON
 SELECT IPFrom, IPTo, IsBlock, CountryCode3, Comment FROM CustomIP(NOLOCK)
 ORDER BY IPFrom

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spIPFltCheckIsDuplicateRange]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spIPFltCheckIsDuplicateRange]
 @IPFrom bigint
, @IPTo bigint
, @Ret int OUTPUT
AS
 SET NOCOUNT ON
  IF EXISTS (SELECT CountryCode3 FROM CustomIP(NOLOCK) 
  WHERE (IPFrom <= @IPFrom AND IPTo >= @IPFrom) OR
   (IPFrom <= @IPTo AND IPTo >= @IPTo)) SET @Ret = 1
 ELSE SET @Ret = 0

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spIPFltDeleteCustomIP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spIPFltDeleteCustomIP]
 @IPFrom varchar(15)
, @IPTo varchar(15)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON
 DECLARE @TmpIPFrom BIGINT
 DECLARE @TmpIPTo BIGINT
 
 SET @TmpIPFrom = GunzDB.game.inet_aton( @IPFrom )
 SET @TmpIPTo = GunzDB.game.inet_aton( @IPTo )
 IF @TmpIPFrom > @TmpIPTo BEGIN
  SET @Ret = 0
  RETURN @Ret
 END
 
 DELETE CustomIP WHERE IPFrom = @TmpIPFrom AND IPTo = @TmpIPTo
 IF 0 <> @@ERROR SET @Ret = 0
 ELSE SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebDeleteCustomIP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE  PROC [spAdmWebDeleteCustomIP]
 @IPFrom varchar(15)
, @IPTo varchar(15)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON
 DECLARE @TmpIPFrom BIGINT
 DECLARE @TmpIPTo BIGINT
 
 SET @TmpIPFrom = GunzDB.game.inet_aton( @IPFrom )
 SET @TmpIPTo = GunzDB.game.inet_aton( @IPTo )
 IF @TmpIPFrom > @TmpIPTo BEGIN
  SET @Ret = 0
  RETURN @Ret
 END
 
 DELETE CustomIP WHERE IPFrom = @TmpIPFrom AND IPTo = @TmpIPTo
 IF 0 <> @@ERROR SET @Ret = 0
 ELSE SET @Ret = 1
 RETURN @Ret


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebInsertCustomIP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*  
 * @Ret(0:Fail, 1:Success, 2:Duplicate, 3:Invers range)  
 */  
CREATE PROC [spAdmWebInsertCustomIP]  
 @IPFrom varchar(15)  
, @IPTo varchar(15)  
, @IsBlock tinyint  
, @CountryCode3 char(3)  
, @Comment varchar(128)  
, @Ret int OUTPUT  
AS  
 SET NOCOUNT ON  
 DECLARE @DupRet int  
 DECLARE @TmpIPFrom BIGINT  
 DECLARE @TmpIPTo BIGINT  
  
 SET @TmpIPFrom = GunzDB.game.inet_aton( @IPFrom )  
 SET @TmpIPTo = GunzDB.game.inet_aton( @IPTo )  
 IF @TmpIPFrom > @TmpIPTo BEGIN  
  SET @Ret = 3  
  RETURN @Ret  
 END  
  
 EXEC spIPFltCheckIsDuplicateRange @TmpIPFrom, @TmpIPTo, @DupRet OUTPUT  
 IF 1 = @DupRet BEGIN  
  SET @Ret = 2  
  RETURN @Ret  
 END   
  
 INSERT INTO CustomIP(IPFrom, IPTo, CountryCode3, IsBlock, Comment, RegDate)  
 VALUES (@TmpIPFrom, @TmpIPTo, @CountryCode3, @IsBlock, @Comment, GETDATE() )  
 IF 0 <> @@ERROR SET @Ret = 0  
 ELSE SET @Ret = 1  
 RETURN @Ret  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebUpdateCustomIP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*  
 * @Ret(0:Fail, 1:Success, 2:Duplicate, 3:Invers range)  
 */  
CREATE PROC [spAdmWebUpdateCustomIP]  
 @IPFrom varchar(15)  
, @IPTo varchar(15)  
, @NewIPFrom varchar(15)  
, @NewIPTo varchar(15)  
, @IsBlock tinyint  
, @CountryCode3 char(3)  
, @Comment varchar(128)  
, @Ret int OUTPUT  
AS  
 SET NOCOUNT ON   
 DECLARE @DupRet bigint  
 DECLARE @TmpIPFrom BIGINT  
 DECLARE @TmpIPTo BIGINT  
 DECLARE @TmpNewIPFrom bigint  
 DECLARE @TmpNewIPTo bigint  
  
 SET @TmpIPFrom = GunzDB.game.inet_aton( @IPFrom )  
 SET @TmpIPTo = GunzDB.game.inet_aton( @IPTo )  
  
 IF @TmpIPFrom > @TmpIPTo BEGIN  
  SET @Ret = 3  
  RETURN @Ret  
 END  
  
 SET @TmpNewIPFrom = GunzDB.game.inet_aton( @NewIPFrom )  
 SET @TmpNewIPTo = GunzDB.game.inet_aton( @NewIPTo )  
  
 IF @TmpNewIPFrom > @TmpNewIPTo BEGIN  
  SET @Ret = 0  
  RETURN @Ret  
 END  
  
 -- 이전 IP범위와 같으면 IP변경 없이 다른 데이터만 변경하는 것임.  
 IF (@TmpIPFrom <> @TmpNewIPFrom) OR (@TmpIPTo <> @TmpNewIPTo) BEGIN  
  EXEC spIPFltCheckIsDuplicateRange @TmpNewIPFrom, @TmpNewIPTo, @DupRet OUTPUT  
  IF 1 = @DupRet BEGIN   
   SET @Ret = 2  
   RETURN @Ret  
  END  
 END  
  
 UPDATE CustomIP  
 SET IPFrom = @TmpNewIPFrom, IPTo = @TmpNewIPTo,  
  IsBlock = @IsBlock, CountryCode3 = @CountryCode3,  
  Comment = @Comment  
 WHERE IPFrom = @TmpIPFrom AND IPTo = @TmpIPTo  
 IF 0 <> @@ERROR OR 0 = @@ROWCOUNT SET @Ret = 0  
 ELSE SET @Ret = 1  
 RETURN @Ret  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertEvent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spInsertEvent] 
 @AID int
, @CID int
, @EventName varchar(24)
AS
 SET NOCOUNT ON 
 INSERT INTO Event( AID, CID, RegDate, Checked, EventName )
 VALUES (@AID, @CID, GETDATE(), 0, @EventName)


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spRemoveFriend]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 친구 삭제
CREATE PROC [spRemoveFriend]
	@CID		int
,	@FriendCID	int
AS
SET NOCOUNT ON
UPDATE Friend 
SET DeleteFlag=1
WHERE CID=@CID AND FriendCID=@FriendCID


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetFriendList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 친구 목록 가져오기
CREATE PROC [spGetFriendList]
	@CID		int
AS
SET NOCOUNT ON
SELECT  f.FriendCID, f.Favorite,  c.Name 
FROM Friend f(NOLOCK), Character c(NOLOCK) 
WHERE f.CID=@CID AND f.FriendCID=c.CID AND f.DeleteFlag=0 AND f.Type=1


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAddFriend]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- sp 

-- 친구 추가
CREATE PROC [spAddFriend]
	@CID		int
,	@FriendCID	int
,	@Favorite	tinyint
AS
BEGIN TRAN
	SET NOCOUNT ON
	DECLARE @ID	int
	INSERT INTO Friend(CID, FriendCID, Favorite, DeleteFlag, Type) Values (@CID, @FriendCID, @Favorite, 0, 1)
	IF 0 <> @@ERROR BEGIN
		ROLLBACK TRAN
		RETURN
	END
	SET @ID = @@IDENTITY
	SELECT @ID as ID
COMMIT TRAN


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertGameLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


/* 게임 로그 추가 */
CREATE PROC [spInsertGameLog]
	@GameName	varchar(64),
	@Map		varchar(32),
	@GameType	varchar(24),
	@Round		int,
	@MasterCID	int,
	@PlayerCount	tinyint,
	@Players	varchar(1000)

AS
SET NOCOUNT ON
BEGIN TRAN
INSERT INTO GameLog (GameName, Map, GameType, Round, MasterCID, StartTime, PlayerCount, Players)
VALUES (@GameName, @Map, @GameType, @Round, @MasterCID, GETDATE(), @PlayerCount, @Players)
IF 0 <> @@ERROR BEGIN 
	ROLLBACK TRAN
	RETURN
END
COMMIT TRAN


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetIPtoCountryList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spGetIPtoCountryList]  
AS  
 SELECT IPFrom, IPTo, CountryCode3   
 FROM IPtoCountry(NOLOCK)  
 ORDER BY IPFrom  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetIPtoCountry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [spGetIPtoCountry]  
@IP VARCHAR(15),  
@Code VARCHAR(3) OUTPUT  
AS  
BEGIN  
 DECLARE @IPNumber BIGINT  
 SELECT @IPNumber=GunzDB.game.inet_aton(@IP)  
   
 SELECT @Code=CountryCode3 FROM IPtoCountry(NOLOCK)   
 WHERE IPFrom <= @IPNumber AND IPTo >= @IPNumber  
END  



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetIPCountryCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spGetIPCountryCode]         
 @IP char(15)        
AS        
 SET NOCOUNT ON        
        
 DECLARE @IPNumber BIGINT        
 SET @IPNumber = GunzDB.game.inet_aton(@IP)        
        
 SELECT IPFrom, IPTo, CountryCode3 FROM IPtoCountry(NOLOCK)        
 WHERE IPFrom <= @IPNumber AND IPTo >= @IPNumber        


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spIPFltGetIPtoCountry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spIPFltGetIPtoCountry]
 @IP char(15)
AS
 SET NOCOUNT ON
 DECLARE @IPNumber BIGINT        
 SET @IPNumber = GunzDB.game.inet_aton( @IP )
        
 SELECT IPFrom, IPTo, CountryCode3 FROM IPtoCountry(NOLOCK)        
 WHERE IPFrom <= @IPNumber AND IPTo >= @IPNumber        

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spIPFltGetIPtoCountryCode]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spIPFltGetIPtoCountryCode]
 @IP char(15)
AS
 SET NOCOUNT ON
 DECLARE @IPNumber BIGINT        
 SET @IPNumber = GunzDB.game.inet_aton( @IP )
        
 SELECT CountryCode3 FROM IPtoCountry(NOLOCK)        
 WHERE IPFrom <= @IPNumber AND IPTo >= @IPNumber        

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spIPFltGetIPtoCountryList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spIPFltGetIPtoCountryList]
AS
 SET NOCOUNT ON
 SELECT IPFrom, IPTo, CountryCode3
 FROM IPtoCountry(NOLOCK)
 ORDER BY IPFrom

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetBountyItemPurchaseLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetBountyItemPurchaseLog]
 @CID int
, @ItemID int
AS
 SET NOCOUNT ON

 SELECT ipl.id AS ID, c.Name AS CharName, ipl.ItemID, i.Name, c.CID, 
  0 AS CIID, ipl.Bounty, ipl.CharBounty, i.Slot, ipl.Type, ipl.Date
 FROM (Character c(NOLOCK) JOIN ItemPurchaseLogByBounty ipl(NOLOCK)
 ON c.CID = @CID AND ipl.CID = c.CID) JOIN Item i(NOLOCK)
 ON i.ItemID = ipl.ItemID
 WHERE ipl.ItemID = @ItemID
 ORDER BY ipl.id DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetBountyItemPurchaseLogByCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetBountyItemPurchaseLogByCharName]  
 @CharName varchar( 24 )  
AS  
 SET NOCOUNT ON  
  
 SELECT ipl.id AS ID, ipl.ItemID, i.Name, c.CID, 0 AS CIID, ipl.Bounty,    
  ipl.CharBounty, i.Slot, ipl.type, ipl.Date  
 FROM (Character c(NOLOCK) JOIN ItemPurchaseLogByBounty ipl(NOLOCK)  
 ON c.Name = @CharName AND ipl.CID = c.CID) JOIN Item i(NOLOCK)  
 ON i.ItemID = ipl.ItemID  
 ORDER BY ipl.Date DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetNewCashItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE  PROC [spGetNewCashItem]
	@ItemCount	int 	= 0
AS
SET NoCount On

IF @ItemCount != 0
BEGIN
	SET ROWCOUNT @ItemCount
END

	SELECT cs.csid AS CSID, i.name AS Name, i.Slot AS Slot, 
		cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
		i.ResSex AS ResSex, i.ResLevel AS ResLevel, i.Weight AS Weight,
		i.Description AS Description, cs.RentType AS RentType
	FROM CashShop cs (nolock) , Item i (nolock)
	WHERE i.ItemID = cs.ItemID AND cs.NewItemOrder > 0 AND Opened=1 
	order by cs.NewItemOrder asc



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetCashShopList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetCashShopList]
AS
 SET NOCOUNT ON
  SELECT cs.CSID, i.Name, i.Slot, cs.Opened, cs.NewItemOrder,
  cs.CashPrice, cs.WebImgName, ISNULL(cs.RentType, 0) AS ''RentType''
 FROM CashShop cs(NOLOCK) JOIN Item i(NOLOCK)
 ON i.ItemID = cs.ItemID 

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetItemList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetItemList]
AS
 SET NOCOUNT ON
 SELECT ItemID, Name, Slot, IsCashItem
 FROM Item(NOLOCK)
 ORDER BY ItemID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spSearchCashItem2]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 아이템 검색 */
CREATE  PROC [spSearchCashItem2]
	@Slot		tinyint,
	@ResSex		tinyint,
	@ResMinLevel	int = NULL,
	@ResMaxLevel	int = NULL,
	@ItemName	varchar(256) = '''',
	@Page		int = 1,
	@PageCount	int OUTPUT
AS
SET NOCOUNT ON

SELECT @PageCount = 1

SELECT cs.csid AS CSID, i.name AS Name, i.Slot AS Slot, cs.CashPrice AS Cash, 
cs.WebImgName AS WebImgName, i.ResSex AS ResSex, i.ResLevel AS ResLevel, i.Weight AS Weight, 
i.Description AS Description, cs.NewItemOrder AS IsNewItem, cs.RentType AS RentType FROM CashShop cs(nolock), Item i(nolock) 
WHERE i.ItemID = cs.ItemID AND i.Name=@ItemName AND cs.Opened=1
ORDER BY cs.csid DESC



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spSearchCashItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 아이템 검색 */
CREATE  PROC [spSearchCashItem]
	@Slot		tinyint,
	@ResSex		tinyint,
	@ResMinLevel	int = NULL,
	@ResMaxLevel	int = NULL,
	@ItemName	varchar(256) = '''',
	@Page		int = 1,
	@PageCount	int OUTPUT
AS
SET NOCOUNT ON

SELECT @PageCount = 1

SELECT cs.csid AS CSID, i.name AS Name, i.Slot AS Slot, cs.CashPrice AS Cash, 
cs.WebImgName AS WebImgName, i.ResSex AS ResSex, i.ResLevel AS ResLevel, i.Weight AS Weight, 
i.Description AS Description, cs.NewItemOrder AS IsNewItem, cs.RentType AS RentType FROM CashShop cs(nolock), Item i(nolock) 
WHERE i.ItemID = cs.ItemID AND i.Name=@ItemName AND cs.Opened=1
ORDER BY cs.csid DESC



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebGetCashItemImageFile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 이미지 파일 이름과 아이템 이름을 가져옴.
CREATE PROC [spWebGetCashItemImageFile]
	@CSID int
,	@RetImageFileName varchar(64) OUT
,	@RetItemName varchar(256) OUT
AS
BEGIN
	SET NOCOUNT ON
	SELECT @RetImageFileName = cs.WebImgName, @RetItemName = i.Name
	FROM CashShop cs(NOLOCK), Item i(NOLOCK)
	WHERE cs.CSID = @CSID AND i.ItemID = cs.ItemID

	RETURN 1
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetCashItemInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE  PROC [spGetCashItemInfo]
	@CSID		int
AS
	SET NOCOUNT ON

	SELECT cs.csid AS CSID, i.name AS Name, i.Slot AS Slot, 
		cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
		i.ResSex AS ResSex, i.ResLevel AS ResLevel, i.Weight AS Weight,
		i.Damage AS Damage, i.Delay AS Delay, i.Controllability AS Controllability,
		i.Magazine AS Magazine, i.MaxBullet AS MaxBullet, i.ReloadTime AS ReloadTime, 
		i.HP AS HP, i.AP AS AP,	i.MAXWT AS MaxWeight, i.LimitSpeed AS LimitSpeed,
		i.FR AS FR, i.CR AS CR, i.PR AS PR, i.LR AS LR,
		i.Description AS Description, cs.NewItemOrder AS IsNewItem,
		cs.RentType AS RentType
	FROM CashShop cs(nolock), Item i(nolock)
	WHERE i.ItemID = cs.ItemID AND cs.csid = @CSID



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetCashItemList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 아이템 리스트 가져오기 */
CREATE PROC [spGetCashItemList]
	@ItemType	int,
	@Page		int,		
	@PageCount	int OUTPUT
AS
SET NoCount On

DECLARE @Rows int
DECLARE @ViewCount int

SELECT @Rows = @Page * 8	/* 한페이지에 8개씩 보여준다 */

DECLARE @PageSize INT
SELECT @PageSize = 8

DECLARE @PageHead INT
DECLARE @RowCount INT


IF @ItemType = 1 /* 근접무기 */
BEGIN

	SELECT @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
	FROM CashShop cs(nolock), Item i(nolock)
	WHERE i.ItemID = cs.ItemID AND i.Slot = 1 AND cs.Opened=1

	SELECT @RowCount = ((@Page -1) * @PageSize + 1)

	SET ROWCOUNT @RowCount
	SELECT @PageHead = cs.csid FROM CashShop cs(NOLOCK), Item i(nolock) 
	WHERE cs.ItemID=i.ItemID AND i.Slot=1 AND cs.Opened=1
	ORDER BY cs.csid DESC

	SET ROWCOUNT @PageSize
	SELECT cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
		cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
		i.ResSex AS ResSex, i.ResLevel AS ResLevel, i.Weight AS Weight,
		i.Description AS Description, cs.RegDate As RegDate, cs.NewItemOrder AS IsNewItem,
		cs.RentType AS RentType
	FROM CashShop cs(nolock), Item i(nolock)
	WHERE csid <= @PageHead AND i.ItemID = cs.ItemID AND i.Slot = 1 AND cs.Opened=1
	ORDER BY cs.csid DESC

END
ELSE
IF @ItemType=2 		/* 원거리무기 */
BEGIN

	SELECT @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
	FROM CashShop cs(nolock), Item i(nolock)
	WHERE i.ItemID = cs.ItemID AND i.Slot = 2 AND cs.Opened=1

	SELECT @RowCount = ((@Page -1) * @PageSize + 1)

	SET ROWCOUNT @RowCount
	SELECT @PageHead = cs.csid FROM CashShop cs(NOLOCK), Item i(nolock) 
	WHERE cs.ItemID=i.ItemID AND i.Slot=2 AND cs.Opened=1
	ORDER BY cs.csid DESC

	SET ROWCOUNT @PageSize
	SELECT cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
		cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
		i.ResSex AS ResSex, i.ResLevel AS ResLevel, i.Weight AS Weight,
		i.Description AS Description, cs.RegDate As RegDate, cs.NewItemOrder AS IsNewItem,
		cs.RentType AS RentType
	FROM CashShop cs(nolock), Item i(nolock)
	WHERE csid <= @PageHead AND i.ItemID = cs.ItemID AND i.Slot = 2 AND cs.Opened=1
	ORDER BY cs.csid DESC

END
ELSE
IF @ItemType=3 		/* 방어구 */
BEGIN

	SELECT @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
	FROM CashShop cs(nolock), Item i(nolock)
	WHERE i.ItemID = cs.ItemID AND i.Slot BETWEEN 4 AND 8 AND cs.Opened=1

	SELECT @RowCount = ((@Page -1) * @PageSize + 1)

	SET ROWCOUNT @RowCount
	SELECT @PageHead = cs.csid FROM CashShop cs(NOLOCK), Item i(nolock) 
	WHERE cs.ItemID=i.ItemID AND i.Slot BETWEEN 4 AND 8 AND cs.Opened=1
	ORDER BY cs.csid DESC

	SET ROWCOUNT @PageSize
	SELECT cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
		cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
		i.ResSex AS ResSex, i.ResLevel AS ResLevel, i.Weight AS Weight,
		i.Description AS Description, cs.RegDate As RegDate, cs.NewItemOrder AS IsNewItem,
		cs.RentType AS RentType
	FROM CashShop cs(nolock), Item i(nolock)
	WHERE csid <= @PageHead AND i.ItemID = cs.ItemID AND i.Slot BETWEEN 4 AND 8 AND cs.Opened=1
	ORDER BY cs.csid DESC

END
ELSE
IF @ItemType=4 		/* 특수아이템 */
BEGIN

	SELECT @PageCount = (COUNT(*) + (@PageSize-1)) / @PageSize
	FROM CashShop cs(nolock), Item i(nolock)
	WHERE i.ItemID = cs.ItemID AND (i.Slot = 3 OR i.Slot=9) AND cs.Opened=1

	SELECT @RowCount = ((@Page -1) * @PageSize + 1)

	SET ROWCOUNT @RowCount
	SELECT @PageHead = cs.csid FROM CashShop cs(NOLOCK), Item i(nolock) 
	WHERE cs.ItemID=i.ItemID AND (i.Slot = 3 OR i.Slot=9) AND cs.Opened=1
	ORDER BY cs.csid DESC

	SET ROWCOUNT @PageSize
	SELECT cs.csid AS CSID, i.name AS Name, i.Slot AS Slot,
		cs.CashPrice AS Cash, cs.WebImgName As WebImgName,
		i.ResSex AS ResSex, i.ResLevel AS ResLevel, i.Weight AS Weight,
		i.Description AS Description, cs.RegDate As RegDate, cs.NewItemOrder AS IsNewItem,
		cs.RentType AS RentType
	FROM CashShop cs(nolock), Item i(nolock)
	WHERE csid <= @PageHead AND i.ItemID = cs.ItemID AND (i.Slot = 3 OR i.Slot=9) AND cs.Opened=1
	ORDER BY cs.csid DESC

END

SET ROWCOUNT 0







' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertItemPurchaseLogByBounty]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


/* 아이템 구매(바운티) 로그 */
CREATE PROC [spInsertItemPurchaseLogByBounty]
	@ItemID		int,
	@CID		int,
	@Bounty		int,
	@CharBounty	int,
	@Type		varchar(20)
AS
SET NOCOUNT ON
INSERT INTO ItemPurchaseLogByBounty
	(ItemID, CID, Date, Bounty, CharBounty, Type)
VALUES
	(@ItemID, @CID, GETDATE(), @Bounty, @CharBounty, @Type)


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertKillLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


/* 킬 로그 추가 */
CREATE PROC [spInsertKillLog]
	@AttackerCID	int,
	@VictimCID	int
AS
SET NOCOUNT ON
BEGIN TRAN
INSERT INTO KillLog (AttackerCID, VictimCID, Time)
VALUES (@AttackerCID, @VictimCID, GETDATE())
IF 0 <> @@ERROR BEGIN
	ROLLBACK TRAN
	RETURN
END
COMMIT TRAN


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebEditCharLevel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebEditCharLevel]  
 @CID int  
, @Level smallint  
, @GMID varchar(20)  
, @Ret int OUTPUT  
AS  
 SET NOCOUNT ON  
  
 IF (1 > @Level) OR (99 < @Level)  BEGIN  
  SET @Ret = -1  
  RETURN @Ret  
 END  

 IF NOT EXISTS (SELECT CID FROM Character(NOLOCK) WHERE CID = @CID) BEGIN
  SET @Ret = -2
  RETURN @Ret
 END
  
 IF EXISTS (SELECT CID FROM Character(NOLOCK)   
  WHERE CID = @CID AND Level = @Level) BEGIN  
  SET @Ret = 1  
  RETURN @Ret  
 END  
  
 DECLARE @XP int  
  
 SELECT @XP = MinXP FROM Level(NOLOCK) WHERE Level = @Level  
 IF @XP IS NULL BEGIN  
  SET @Ret = -3  
  RETURN @Ret  
 END  
  
 UPDATE Character SET Level = @Level, XP = @XP WHERE CID = @CID AND DeleteFlag <> 1  
 IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN  
  SET @Ret = -4  
  RETURN @Ret  
 END  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebEditCharXP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebEditCharXP]
 @CID int
, @XP int
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON

 IF 0 > @XP BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 DECLARE @MaxMinXP int
 DECLARE @Level smallint

 SELECT TOP 1 @MaxMinXP = MinXP FROM Level(NOLOCK) 
 ORDER BY MinXP DESC

 IF @MaxMinXP > @XP BEGIN
  SELECT TOP 1 @Level = Level FROM Level(NOLOCK) 
  WHERE MinXP <= @XP ORDER BY Level DESC
 END
 ELSE BEGIN
  SELECT TOP 1 @Level = Level FROM Level(NOLOCK) 
  ORDER BY Level DESC
 END

 UPDATE Character SET Level = @Level, XP = @XP 
 WHERE CID = @CID AND DeleteFlag <> 1
 IF 0 = @@ROWCOUNT BEGIN 
  SET @Ret = 0
  RETURN @Ret
 END
 
 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertLevelUpLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



-- 레벨업 로그 추가
CREATE PROC [spInsertLevelUpLog]
	@CID			int,
	@Level			smallint,
	@BP				int,
	@KillCount		int,
	@DeathCount		int,
	@PlayTime		int
AS
SET NOCOUNT ON
BEGIN TRAN
	INSERT INTO LevelUpLog(CID, Level, BP, KillCount, DeathCount, PlayTime, Date)
	VALUES (@CID, @Level, @BP, @KillCount, @DeathCount, @PlayTime, GETDATE())
	IF 0 <> @@ERROR BEGIN
		ROLLBACK TRAN
		RETURN
	END
COMMIT TRAN


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spUpdateLocatorStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spUpdateLocatorStatus]
 @LocatorID int
, @RecvCount int
, @SendCount int
, @BlockCount int
, @DuplicatedCount int
AS 
 SET NOCOUNT ON 
 UPDATE LocatorStatus 
 SET RecvCount = @RecvCount, SendCount = @SendCount, 
  BlockCount = @BlockCount, DuplicatedCount = @DuplicatedCount,
  LastUpdatedTime = GETDATE()
 WHERE LocatorID = @LocatorID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spStartUpLocatorStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spStartUpLocatorStatus]
 @LocatorID int
, @IP varchar(15)
, @Port int
, @UpdateElapsedTime int
AS
 SET NOCOUNT ON 
 IF EXISTS (SELECT LocatorID FROM LocatorStatus(NOLOCK) 
	    WHERE LocatorID = @LocatorID) BEGIN
  UPDATE LocatorStatus 
  SET IP = @IP, Port = @Port, UpdateElapsedTime = @UpdateElapsedTime, 
   LastUpdatedTime = GETDATE()
  WHERE LocatorID = @LocatorID
 END
 ELSE BEGIN
  INSERT INTO LocatorStatus(LocatorID, IP, Port, UpdateElapsedTime, LastUpdatedTime)
  VALUES (@LocatorID, @IP, @Port, @UpdateElapsedTime, GETDATE())
 END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spUpdateLastConnDate]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* LastConn, IP를 저장한다. */
CREATE PROC [spUpdateLastConnDate]
	@IP		varchar(20),
	@UserID		varchar(20)
AS
SET NOCOUNT ON
UPDATE Login SET LastConnDate=GETDATE(), LastIP=@IP WHERE UserID = @UserID



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spCheckUserPassword]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
--  -1:DB Failure
--  0:Unregistered user
--  1:Wrong Password
--  2:Valid User
CREATE PROC [spCheckUserPassword]
        @UserID VARCHAR(20),
        @Password VARCHAR(20)
AS
BEGIN
        DECLARE @AID INT
        SELECT @AID=AID FROM LOGIN(NOLOCK) WHERE UserID=@UserID

        IF @@ERROR <> 0
        BEGIN
                RETURN        -1   -- DB Failure
        END

        IF @AID IS NULL
        BEGIN
                RETURN 0        -- Unregistered user
        END

        DECLARE @AID2 INT
        SELECT @AID2=AID FROM LOGIN(NOLOCK) WHERE UserID=@UserID AND Password=@Password

        IF @AID2 IS NULL
        BEGIN
                RETURN 1        -- Wrong Password
        END

        RETURN 2 -- Valid User
END
 


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetLoginInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* LoginInfo 얻어옴 */
CREATE PROC [spGetLoginInfo]
	@UserID		varchar(20)
AS
SET NOCOUNT ON
SELECT AID, UserID, Password FROM Login(nolock) WHERE UserID = @UserID




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebInsertCashShopItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebInsertCashShopItem]  
 @ItemID int  
, @Opened tinyint  
, @CashPrice int  
, @WebImgName varchar(64)  
, @RentType tinyint  
, @Ret int OUTPUT  
AS  
 SET NOCOUNT ON  
 IF (@ItemID IS NULL) OR (500000 > @ItemID) OR (@Opened IS NULL)
  OR (@CashPrice IS NULL) BEGIN  
  SET @Ret = 0  
  RETURN @Ret  
 END  

 declare @csid int

 select @csid = max(csid) + 1 from CashShop(nolock) 
  
 INSERT INTO CashShop(csid,  ItemID, Opened, CashPrice, WebImgName, RegDate, RentType )  
 VALUES (@csid, @ItemID, @Opened, @CashPrice, @WebImgName, GETDATE(), @RentType)  
 IF 0 <> @@ERROR BEGIN  
  SET @Ret = 0  
  RETURN @Ret  
 END  
   
 SET @Ret = @csid
 RETURN @Ret  


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebUpdateCashShopItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebUpdateCashShopItem]  
 @CSID int  
, @Opened tinyint  
, @CashPrice int  
, @WebImgName varchar(64)  
, @RentType tinyint
, @Ret int OUTPUT  
AS  
 UPDATE CashShop   
 SET Opened = @Opened, CashPrice = @CashPrice, WebImgName = @WebImgName,
  RentType = @RentType
 WHERE CSID = @CSID  
 IF 0 = @@ROWCOUNT BEGIN  
  SET @Ret = 0  
  RETURN @Ret  
 END  
   
 SET @Ret = 1  
 RETURN @Ret  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetCashItemImageFile]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 캐쉬 일반아이템 이미지파일 알아오기
CREATE PROC [spGetCashItemImageFile]
	@CSID			int
,	@RetImageFileName	varchar(64) OUTPUT
AS
SET NOCOUNT ON

SELECT @RetImageFileName = WebImgName
FROM CashShop cs(nolock)
WHERE cs.csid=@CSID

RETURN 1



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebDeleteCashShopItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebDeleteCashShopItem]
 @CSID int
, @Ret int OUTPUT
AS
 SET NOCOUNT ON 

 BEGIN TRAN
 DELETE CashShop WHERE CSID = @CSID
 IF (0 <> @@ERROR) OR (0 = @@ROWCOUNT) BEGIN
  ROLLBACK TRAN
  SET @Ret = 0
  RETURN @Ret 
 END

 DELETE RentCashShopPrice WHERE CSID = @CSID
 IF 0 <> @@ERROR BEGIN
  ROLLBACK TRAN
  SET @Ret = 0
  RETURN @Ret
 END 
 COMMIT TRAN

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertPlayerLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 플레이어 로그 */
CREATE PROC [spInsertPlayerLog]
	@CID          int,
	@PlayTime     int,
	@Kills        int,
	@Deaths       int,
	@XP           int,
	@TotalXP      int
AS
SET NOCOUNT ON
BEGIN TRAN
INSERT INTO PlayerLog (CID, DisTime, PlayTime, Kills, Deaths, XP, TotalXP)
VALUES	(@CID, GETDATE(), @PlayTime, @Kills, @Deaths, @XP, @TotalXP)
IF 0 <> @@ERROR BEGIN 
	ROLLBACK TRAN
	RETURN
END
COMMIT TRAN


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetCharQuestItemInfoByCID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetCharQuestItemInfoByCID]
	@CID int
AS
	SET NOCOUNT ON

	SELECT QuestItemInfo FROM Character(NOLOCK) WHERE CID = @CID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spIsExistCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 캐릭터 이름 중복 검사
CREATE PROC [spIsExistCharName]
	@CharName	varchar(24)
AS
SET NOCOUNT ON
IF EXISTS (SELECT TOP 1 CID FROM Character(nolock) where (Name=@CharName) AND (DeleteFlag=0))
BEGIN
	SELECT 1 AS Ret
END
ELSE
BEGIN
	SELECT 0 AS Ret
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetCharQuestItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetCharQuestItem]
	@CharName varchar( 24 )
AS	
BEGIN
	SET NOCOUNT ON

	SELECT QuestItemInfo
	FROM Character( NOLOCK )
	WHERE Name = @CharName
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetLiveCharInfoByCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetLiveCharInfoByCharName]
 @CharName varchar( 24 )
AS 
 SET NOCOUNT ON

 SELECT Name, AID, CID, RegDate, PlayTime, LastTime, Sex, 
  CharNum, Level, XP, BP, KillCount, DeathCount
 FROM Character(NOLOCK)
 WHERE Name = @CharName AND DeleteFlag <> 1
 ORDER BY CharNum 

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetQuestItemInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetQuestItemInfo]
 @CID int
AS
 SET NOCOUNT ON 
 SELECT CID, Name, QuestItemInfo 
 FROM Character(NOLOCK)
 WHERE CID = @CID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebEditCharPlayTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebEditCharPlayTime]
 @CID int
, @PlayTime int
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON 
 IF (0 > @PlayTime) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 UPDATE Character SET PlayTime = @PlayTime WHERE CID = @CID
 IF 0 = @@ROWCOUNT BEGIN 
  SET @Ret = 0
  RETURN @Ret
 END
	
 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebEditCharKillDeathCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebEditCharKillDeathCount]
 @CID int
, @KillCount int
, @DeathCount int
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 IF (0 > @KillCount) OR (0 > @DeathCount) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 UPDATE Character SET KillCount = @KillCount, DeathCount = @DeathCount
 WHERE CID = @CID
 IF 0 = @@ROWCOUNT BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetAllCharInfoByCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetAllCharInfoByCharName]
 @CharName varchar( 24 )
AS
 SET NOCOUNT ON
 
 SELECT Name, AID, CID, RegDate, PlayTime, LastTime, Sex,
  CharNum, Level, XP, BP, DeleteFlag, DeleteName, 
  KillCount, DeathCount
 FROM Character(NOLOCK)
 WHERE Name = @CharName
 ORDER BY DeleteFlag, CharNum

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebEditCharBP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebEditCharBP]
 @CID int
, @BP int
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON
 UPDATE Character SET BP = @BP WHERE CID = @CID
 IF 0 = @@ROWCOUNT BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebUndeleteChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


CREATE  PROC [spWebUndeleteChar]
	@CID INT
AS
SET NOCOUNT ON
BEGIN
	DECLARE @AID INT
	DECLARE @Name VARCHAR(64)
	SELECT @Name = DeleteName, @AID=AID FROM Character(NOLOCK) WHERE CID=@CID
	
	IF @AID IS NULL
	BEGIN
		SELECT ''It is not exist character.'' AS ERROR, @CID AS CID
		GOTO label_finish
	END
	
	--SELECT @Name AS Name
	IF @Name IS NULL
	BEGIN
		SELECT ''already exist character'' AS ERROR, @CID AS CID
		GOTO label_finish
	END
	
	-- find empty slot.
	DECLARE @CharNum INT
	SELECT @CharNum=a.CharNum FROM
	(
		SELECT 0 AS CharNum UNION 
		SELECT 1 AS CharNum UNION 
		SELECT 2 AS CharNum UNION 
		SELECT 3 AS CharNum
	) a WHERE NOT EXISTS
	(
		SELECT CharNum FROM Character(NOLOCK) 
		WHERE AID=@AID AND DeleteFlag=0 AND CharNum=a.CharNum
	)
	IF @CharNum IS NULL
	BEGIN
		SELECT ''no more empty slot'' AS ERROR, @CID AS CID
		GOTO label_finish
	END
	
	DECLARE @ExistName VARCHAR(64)
	SELECT @ExistName = Name FROM Character(NOLOCK) WHERE AID=@AID AND CharNum=@CharNum
	IF @ExistName IS NOT NULL
	BEGIN
		SELECT ''already exist slot.'' AS ERROR, @CID AS CID
		GOTO label_finish
	END
	
	DECLARE @Count int
	SELECT @Count=COUNT(*) FROM Character(NOLOCK) WHERE Name=@Name
	
	--SELECT @Name AS UndeleteTarget
	
	IF ( @Count <= 0 )
	BEGIN
		Update Character Set Name=@Name WHERE CID=@CID
		Update Character Set CharNum=@CharNum WHERE CID=@CID
		Update Character Set DeleteFlag=0 WHERE CID=@CID
		Update Character Set DeleteName=NULL WHERE CID=@CID
	
		SELECT ''completed restore'' AS ERROR, @Name AS ''Name''
	END
	ELSE
	BEGIN
		SELECT ''already exist name'' AS ERROR, @Name AS ''Name'', @Count AS ''Count''
	END
		
label_finish:
END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetCIDbyCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------

create proc [spGetCIDbyCharName]
 @Name varchar(24)
as
 set nocount on
 select cid from character(nolock) where name = @Name

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spChangeCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 캐릭터 이름 변경
CREATE PROC [spChangeCharName]
	@AID		int,
	@CID		int,
	@NewName	varchar(24)
AS
SET NOCOUNT ON
IF (LEN(@NewName) <= 0) OR (LEN(@NewName) > 12)
BEGIN
	SELECT 0 AS Ret
END

IF EXISTS (SELECT TOP 1 CID FROM Character where (Name=@NewName) AND (DeleteFlag=0))
BEGIN
	SELECT 0 AS Ret
	return (-1)
END

UPDATE Character SET Name=@NewName WHERE AID=@AID AND CID=@CID
IF 0 = @@ROWCOUNT BEGIN
	SELECT 0 AS Ret
	RETURN (-1)
END

SELECT 1 AS Ret



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spCheckDuplicateCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create proc [spCheckDuplicateCharName]   
 @Name varchar(24)  
as
 set nocount on  
 select top 1 cid from character(nolock) where deleteflag <> 1 and name = @Name  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spClearAllEquipedItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 캐릭터 모든 장비 해제  */
CREATE PROC [spClearAllEquipedItem]
	@CID		int
AS
SET NOCOUNT ON

UPDATE Character WITH (rowlock)
SET head_slot=NULL, chest_slot=NULL, hands_slot=NULL, legs_slot=NULL, feet_slot=NULL,
  fingerl_slot=NULL, fingerr_slot=NULL, melee_slot=NULL, primary_slot=NULL, secondary_slot=NULL, custom1_slot=NULL, custom2_slot=NULL,
  head_itemid=NULL, chest_itemid=NULL, hands_itemid=NULL, legs_itemid=NULL, feet_itemid=NULL,
  fingerl_itemid=NULL, fingerr_itemid=NULL, melee_itemid=NULL, primary_itemid=NULL, secondary_itemid=NULL, custom1_itemid=NULL, custom2_itemid=NULL

WHERE CID=@CID




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spUpdateEquipItem]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 아이템 장비 */
CREATE PROC [spUpdateEquipItem]
	@CID			int,
	@ItemParts		int,
	@CIID			int,
	@ItemID			int
AS

SET NoCount ON

DECLARE @Ret int
DECLARE @IF_CIID	int

SELECT @Ret = 1

-- Head
IF @ItemParts = 0
BEGIN
	IF @CIID = 0
	BEGIN
		UPDATE Character SET head_slot=NULL, head_itemid=NULL WHERE CID=@CID
	END
	ELSE
	BEGIN
		UPDATE Character SET head_slot=@CIID, head_itemid=@ItemID WHERE CID=@CID
	END
END
-- Chest
ELSE IF @ItemParts = 1
BEGIN
	IF @CIID = 0
	BEGIN
		UPDATE Character SET chest_slot=NULL, chest_itemid=NULL WHERE CID=@CID
	END
	ELSE
	BEGIN
		UPDATE Character SET chest_slot=@CIID, chest_itemid=@ItemID WHERE CID=@CID
	END
END
-- Hands
ELSE IF @ItemParts = 2
BEGIN
	IF @CIID = 0
	BEGIN
		UPDATE Character SET hands_slot=NULL, hands_itemid=NULL WHERE CID=@CID
	END
	ELSE
	BEGIN
		UPDATE Character SET hands_slot=@CIID, hands_itemid=@ItemID WHERE CID=@CID
	END
END
-- Legs
ELSE IF @ItemParts = 3
BEGIN
	IF @CIID = 0
	BEGIN
		UPDATE Character SET legs_slot=NULL, legs_itemid=NULL WHERE CID=@CID
	END
	ELSE
	BEGIN
		UPDATE Character SET legs_slot=@CIID, legs_itemid=@ItemID WHERE CID=@CID
	END
END
-- Feet
ELSE IF @ItemParts = 4
BEGIN
	IF @CIID = 0
	BEGIN
		UPDATE Character SET feet_slot=NULL, feet_itemid=NULL WHERE CID=@CID
	END
	ELSE
	BEGIN
		UPDATE Character SET feet_slot=@CIID, feet_itemid=@ItemID WHERE CID=@CID
	END
END
-- FingerL
ELSE IF @ItemParts = 5
BEGIN
	IF @CIID = 0
	BEGIN
		UPDATE Character SET fingerl_slot=NULL, fingerl_itemid=NULL WHERE CID=@CID
	END
	ELSE
	BEGIN
		SELECT @IF_CIID = fingerr_slot FROM Character(nolock) WHERE CID=@CID
		IF (@IF_CIID IS NOT NULL) AND (@IF_CIID = @CIID)
		BEGIN
			SELECT @Ret = 0
		END
		ELSE
		BEGIN
			UPDATE Character SET fingerl_slot=@CIID, fingerl_itemid=@ItemID WHERE CID=@CID
		END
	END
END
-- FingerR
ELSE IF @ItemParts = 6
BEGIN
	IF @CIID = 0
	BEGIN
		UPDATE Character SET fingerr_slot=NULL, fingerr_itemid=NULL WHERE CID=@CID
	END
	ELSE
	BEGIN
		SELECT @IF_CIID = fingerl_slot FROM Character(nolock) WHERE CID=@CID
		IF (@IF_CIID IS NOT NULL) AND (@IF_CIID = @CIID)
		BEGIN
			SELECT @Ret = 0
		END
		ELSE
		BEGIN
			UPDATE Character SET fingerr_slot=@CIID, fingerr_itemid=@ItemID WHERE CID=@CID
		END
	END
END
-- Melee
ELSE IF @ItemParts = 7
BEGIN
	IF @CIID = 0
	BEGIN
		UPDATE Character SET melee_slot=NULL, melee_itemid=NULL WHERE CID=@CID
	END
	ELSE
	BEGIN
		UPDATE Character SET melee_slot=@CIID, melee_itemid=@ItemID WHERE CID=@CID
	END
END
-- Primary
ELSE IF @ItemParts = 8
BEGIN
	IF @CIID = 0
	BEGIN
		UPDATE Character SET primary_slot=NULL, primary_itemid=NULL WHERE CID=@CID
	END
	ELSE
	BEGIN
		SELECT @IF_CIID = secondary_slot FROM Character(nolock) WHERE CID=@CID
		IF (@IF_CIID IS NOT NULL) AND (@IF_CIID = @CIID)
		BEGIN
			SELECT @Ret = 0
		END
		ELSE
		BEGIN
			UPDATE Character SET primary_slot=@CIID, primary_itemid=@ItemID WHERE CID=@CID
		END
	END
END
-- Secondary
ELSE IF @ItemParts = 9
BEGIN
	IF @CIID = 0
	BEGIN
		UPDATE Character SET secondary_slot=NULL, secondary_itemid=NULL WHERE CID=@CID
	END
	ELSE
	BEGIN
		SELECT @IF_CIID = primary_slot FROM Character(nolock) WHERE CID=@CID
		IF (@IF_CIID IS NOT NULL) AND (@IF_CIID = @CIID)
		BEGIN
			SELECT @Ret = 0
		END
		ELSE
		BEGIN
			UPDATE Character SET secondary_slot=@CIID, secondary_itemid=@ItemID WHERE CID=@CID
		END
	END
END
-- Custom1
ELSE IF @ItemParts = 10
BEGIN
	IF @CIID = 0
	BEGIN
		UPDATE Character SET custom1_slot=NULL, custom1_itemid=NULL WHERE CID=@CID
	END
	ELSE
	BEGIN
		SELECT @IF_CIID = custom2_slot FROM Character(nolock) WHERE CID=@CID
		IF (@IF_CIID IS NOT NULL) AND (@IF_CIID = @CIID)
		BEGIN
			SELECT @Ret = 0
		END
		ELSE
		BEGIN
			UPDATE Character SET custom1_slot=@CIID, custom1_itemid=@ItemID WHERE CID=@CID
		END
	END
END
-- Custom2
ELSE IF @ItemParts = 11
BEGIN
	IF @CIID = 0
	BEGIN
		UPDATE Character SET custom2_slot=NULL, custom2_itemid=NULL WHERE CID=@CID
	END
	ELSE
	BEGIN
		SELECT @IF_CIID = custom1_slot FROM Character(nolock) WHERE CID=@CID
		IF (@IF_CIID IS NOT NULL) AND (@IF_CIID = @CIID)
		BEGIN
			SELECT @Ret = 0
		END
		ELSE
		BEGIN
			UPDATE Character SET custom2_slot=@CIID, custom2_itemid=@ItemID WHERE CID=@CID
		END
	END
END



SELECT @Ret AS Ret



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebUpdateQuestItemInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebUpdateQuestItemInfo]
 @CID int
, @QuestItemInfo binary(292)
AS
 SET NOCOUNT ON 
 UPDATE Character
 SET QuestItemInfo = @QuestItemInfo
 WHERE CID = @CID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spSimpleUpdateChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


/* 캐릭터 정보 업데이트 - 한사람 죽일때마다 업데이트한다. */
CREATE PROC [spSimpleUpdateChar]
	@CID		int,
	@Name		varchar(24),
	@Level		smallint,
	@XP		int,
	@BP		int
AS
SET NOCOUNT ON
UPDATE Character WITH (rowlock)
SET Level=@Level, XP=@XP, BP=@BP
WHERE CID=@CID AND Name=@Name


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spSelectCharQuestItemInfoByCID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE  PROC [spSelectCharQuestItemInfoByCID]
	@CID	int
AS
BEGIN
	SET NOCOUNT ON
	SELECT QuestItemInfo FROM Character (NOLOCK) WHERE CID = @CID
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spUpdateCharLevel]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


/* 레벨 업데이트 */
CREATE PROC [spUpdateCharLevel]
  @Level        smallint,
  @CID          int
AS
SET NOCOUNT ON
UPDATE Character 
Set Level=@Level 
WHERE CID=@CID



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spUpdateCharInfoData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



/* 캐릭터 정보(XP, BP, KillCount, DeathCount) 업데이트 */
CREATE PROC [spUpdateCharInfoData]
  @XPInc        int,
  @BPInc        int,
  @KillInc      int,
  @DeathInc     int,
  @CID          int
AS
SET NOCOUNT ON
  
UPDATE Character 
SET XP=XP+(@XPInc), BP=BP+(@BPInc), KillCount=KillCount+(@KillInc), DeathCount=DeathCount+(@DeathInc)
WHERE CID=@CID



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spUpdateCharPlayTime]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'




/* 캐릭터 플레이 시간 업데이트 */
CREATE PROC [spUpdateCharPlayTime]
  @PlayTimeInc    int,
  @CID            int
AS
SET NOCOUNT ON

UPDATE Character 
SET PlayTime=PlayTime+(@PlayTimeInc), LastTime=GETDATE() 
WHERE CID=@CID



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebUndeleteCharacter]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE   PROC [spAdmWebUndeleteCharacter]    
 @AID int    
, @CID int
, @GMID varchar(20)  
, @Ret int OUTPUT    
AS    
 SET NOCOUNT ON   
  
 IF EXISTS (SELECT LiveChar.CID FROM Character DelChar(NOLOCK) JOIN Character LiveChar(NOLOCK)
	ON DelChar.CID = @CID AND DelChar.DeleteFlag = 1 AND LiveChar.Name = DelChar.DeleteName
	WHERE LiveChar.DeleteFlag <> 1) BEGIN
  SET @Ret = 0    
  RETURN @Ret   
 END    
  
 DECLARE @CharCount int     
    
 SELECT @CharCount = COUNT(CID) FROM Character(NOLOCK) WHERE AID = @AID AND DeleteFlag <> 1    
 IF 4 > @CharCount BEGIN     
  DECLARE @FreeNum int    
  DECLARE @tb table( a int )  
  
  INSERT @tb VALUES( 0 )  
  INSERT @tb VALUES( 1 )  
  INSERT @tb VALUES( 2 )  
  INSERT @tb VALUES( 3 )  
  
  SELECT TOP 1 @FreeNum = t.a  
  FROM @tb t LEFT OUTER JOIN Character c(NOLOCK)  
  ON c.AID = @AID AND c.DeleteFlag <> 1 AND c.CharNum = t.a  
  WHERE c.CharNum IS NULL  
  
  IF @FreeNum IS NULL BEGIN    
   SET @Ret = 0    
   RETURN @Ret    
  END    
    
  BEGIN TRAN    
  UPDATE Character     
  SET Name = DeleteName, CharNum = @FreeNum, DeleteFlag = 0, DeleteName = ''''
  WHERE CID = @CID AND AID = @AID AND DeleteFlag = 1 
  IF 0 = @@ROWCOUNT BEGIN    
   ROLLBACK TRAN    
   SET @Ret = 0    
   RETURN  @Ret  
  END    
  COMMIT TRAN    
  SET @Ret = 1    
  RETURN @Ret  
 END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spUpdateChar]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 캐릭터 정보 업데이트 - 아이템 정보는 업데이트 하지 않는다. */
CREATE PROC [spUpdateChar]
	@Name		varchar(24),
	@CharNum	smallint,
	@Level		smallint,
	@Sex		tinyint,
	@Hair		tinyint,
	@Face		tinyint,
	@XP		int,
	@BP		int,
	@HP		smallint,
	@AP		smallint,
	@FR		smallint,
	@CR		smallint,
	@ER		smallint,
	@WR		smallint
AS
SET NOCOUNT ON
UPDATE Character WITH (rowlock)
SET Name=@Name, Level=@Level, Sex=@Sex, Hair=@Hair, Face=@Face, XP=@XP, BP=@BP, 
  HP=@HP, AP=@AP, FR=@FR, CR=@CR, ER=@ER, WR=@WR
WHERE Name=@Name and CharNum=@CharNum



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spUpdateCharBP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



/* BP 업데이트 */
CREATE PROC [spUpdateCharBP]
  @BPInc        int,
  @CID          int
AS
SET NOCOUNT ON
UPDATE Character 
SET BP=BP+(@BPInc) 
WHERE CID=@CID



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetCharList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 계정의 캐릭터 리스트 가져오기  */
CREATE PROC [spGetCharList]
	@AID		int
AS
SET NOCOUNT ON
SELECT c.CID AS CID, c.Name AS Name, c.CharNum AS CharNum, c.Level AS Level
FROM Character AS c WITH (nolock)
WHERE c.AID=@AID AND c.DeleteFlag = 0


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetCharNameByCID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

--------------------------------------------

create proc [spGetCharNameByCID]
 @CID int
as 
 set nocount on
 select name from character(nolock) where CID = @CID

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebChangeCharDeathCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebChangeCharDeathCount]
 @CID int
, @DeathCount int
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON

 IF (0 > @DeathCount) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 UPDATE Character SET DeathCount = @DeathCount
 WHERE CID = @CID
 IF 0 = @@ROWCOUNT BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebChangeCharName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebChangeCharName]
 @CID int
, @CharName varchar(24)
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON
 IF NOT EXISTS( SELECT CID FROM Character(NOLOCK) 
  WHERE (DeleteFlag <> 1) AND (Name = @CharName)) BEGIN
  UPDATE Character SET Name = @CharName WHERE CID = @CID
  IF 0 = @@ROWCOUNT BEGIN
   SET @Ret = 0
   RETURN @Ret
  END
 END
 ELSE BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebChangeCharKillCount]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebChangeCharKillCount]
 @CID int
, @KillCount int
, @GMID varchar(20)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON
 IF (0 > @KillCount) BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 UPDATE Character SET KillCount = @KillCount 
 WHERE CID = @CID
 IF 0 = @@ROWCOUNT BEGIN 
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetUniqueQuestItemInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetUniqueQuestItemInfo]
 @CID int
AS
 SET NOCOUNT ON 

 SELECT qi.Name, qgl.StartTime, qgl.EndTime
 FROM QuestGameLog qgl(NOLOCK), QUniqueItemLog qul(NOLOCK), QuestItem qi(NOLOCK)
 WHERE qgl.ID = qul.QGLID AND qul.QIID = qi.QIID AND qul.CID = @CID
 ORDER BY qgl.StartTime DESC

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertQUniqueItemLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 퀘스트 유니크 아이템 저장 프로시져.
CREATE PROC [spInsertQUniqueItemLog]
	@QGLID int
,	@CID int
,	@QIID int
AS
BEGIN
	SET NOCOUNT ON
	INSERT INTO QUniqueItemLog(QGLID, CID, QIID) VALUES (@QGLID, @CID, @QIID)
END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertQuestGameLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 퀘스트 게임 로그 정보 저장 프로시져.
CREATE PROC [spInsertQuestGameLog]
	@GameName varchar(64)
,	@Master int 
,	@Player1 int 
,	@Player2 int
,	@Player3 int
,	@TotalQItemCount smallint 
,	@ScenarioID smallint 
,	@GamePlayTime tinyint 
AS
SET NOCOUNT ON

BEGIN TRAN
	INSERT INTO QuestGameLog(GameName, Master, Player1, Player2, Player3, TotalQItemCount, ScenarioID, StartTime, EndTime)
	VALUES (@GameName, @Master, @Player1, @Player2, @Player3, @TotalQItemCount, @ScenarioID, DATEADD(n, -(@GamePlayTime), GETDATE()), GETDATE() )
	IF 0 <> @@ERROR BEGIN -- 여기 추가.
		ROLLBACK TRAN
		RETURN
	END

	SELECT @@IDENTITY AS ''ORDERQGLID''
COMMIT TRAN



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebInsertRentCashSetShopPrice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebInsertRentCashSetShopPrice]  
 @CSSID int  
, @RentHourPeriod int  
, @CashPrice int  
, @Ret int OUTPUT  
AS  
 SET NOCOUNT ON  
 IF (@CSSID IS NULL) OR (@CashPrice IS NULL) BEGIN  
  SET @Ret = 0  
  RETURN @Ret  
 END  

 IF 0 = @RentHourPeriod SET @RentHourPeriod = NULL
  
 INSERT INTO RentCashSetShopPrice(CSSID, RentHourPeriod, CashPrice)  
 VALUES (@CSSID, @RentHourPeriod, @CashPrice)  
 IF 0 <> @@ERROR BEGIN  
  SET @Ret = 0  
  RETURN @Ret  
 END  
  
 SET @Ret = 1  
 RETURN @Ret  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertRentCashSetShopPrice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 기간제 세트 아이템 상품 가격 입력
CREATE PROC [spInsertRentCashSetShopPrice]
	@CSSID		int,
	@RentHourPeriod	smallint,
	@CashPrice	int
AS
	SET NOCOUNT ON
	INSERT INTO RentCashSetShopPrice(CSSID, RentHourPeriod, CashPrice) 
	VALUES (@CSSID, @RentHourPeriod, @CashPrice)


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetRentCashSetShopPriceByHour]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [spGetRentCashSetShopPriceByHour]
	@CSSID		int
,	@RentHourPeriod	smallint
AS
	SET NOCOUNT ON
	IF @RentHourPeriod IS NOT NULL
	BEGIN
		-- 기간제 아이템
		SELECT CashPrice
		FROM RentCashSetShopPrice(nolock)
		WHERE CSSID = @CSSID AND RentHourPeriod = @RentHourPeriod
	END
	ELSE IF @RentHourPeriod IS NULL
	BEGIN
		-- 영구 아이템.
		SELECT CashPrice
		FROM RentCashSetShopPrice(nolock)
		WHERE CSSID = @CSSID AND RentHourPeriod IS NULL
	END



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebDeleteRentCashSetShopPrice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebDeleteRentCashSetShopPrice]
 @RCSSPID int
, @CSSID int
, @Ret int OUTPUT
AS
 SET NOCOUNT ON
 DELETE RentCashSetShopPrice WHERE RCSSPID = @RCSSPID AND CSSID = @CSSID
 IF 0 <> @@ERROR BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetRentCashSetShopPrice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 기간제 세트 아이템 상품 가격 보기
CREATE  PROC [spGetRentCashSetShopPrice]
	@CSSID		int
AS
	SET NOCOUNT ON
	SELECT RentHourPeriod, CashPrice 
	FROM RentCashSetShopPrice(nolock) WHERE CSSID = @CSSID
	ORDER BY CashPrice



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebDeleteRentCashShopPrice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebDeleteRentCashShopPrice]
 @RCSPID int
, @CSID int
, @Ret int OUTPUT
AS
 SET NOCOUNT ON
 DELETE RentCashShopPrice WHERE RCSPID = @RCSPID AND CSID = @CSID
 IF 0 <> @@ERROR BEGIN
  SET @Ret = 0
  RETURN @Ret
 END
 SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetRentCashShopPriceByHour]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE   PROC [spGetRentCashShopPriceByHour]
	@CSID		int
,	@RentHourPeriod	smallint
AS
	SET NOCOUNT ON
	IF @RentHourPeriod IS NOT NULL
	BEGIN
		-- 기간제 아이템
		SELECT CashPrice 
		FROM RentCashShopPrice (nolock)
		WHERE CSID = @CSID AND RentHourPeriod = @RentHourPeriod
	END
	ELSE IF @RentHourPeriod IS NULL
	BEGIN
		-- 영구 아이템
		SELECT CashPrice
		FROM RentCashShopPrice (nolock)
		WHERE CSID = @CSID AND RentHourPeriod IS NULL
	END





' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetRentCashShopPrice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 기간제 아이템 상품 가격 보기
CREATE PROC [spGetRentCashShopPrice]
	@CSID		int
AS
	SET NOCOUNT ON
	SELECT RentHourPeriod, CashPrice 
	FROM RentCashShopPrice(nolock) WHERE CSID = @CSID
	ORDER BY CashPrice



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertRentCashShopPrice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 기간제 아이템 상품 가격 입력
CREATE PROC [spInsertRentCashShopPrice]
	@CSID			int
,	@RentHourPeriod		smallint
,	@CashPrice		int
AS
	SET NOCOUNT ON
	INSERT INTO RentCashShopPrice (CSID, RentHourPeriod, CashPrice)
	VALUES (@CSID, @RentHourPeriod, @CashPrice)


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebInsertRentCashShopPrice]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebInsertRentCashShopPrice]  
 @CSID int  
, @RentHourPeriod int  
, @CashPrice int  
, @Ret int OUTPUT  
AS  
 SET NOCOUNT ON  
  
 IF (@CSID IS NULL) OR (@CashPrice IS NULL) BEGIN  
  SET @Ret = 0  
  RETURN @Ret  
 END  

 IF 0 = @RentHourPeriod SET @RentHourPeriod = NULL
  
 INSERT INTO RentCashShopPrice(CSID, RentHourPeriod, CashPrice)  
 VALUES (@CSID, @RentHourPeriod, @CashPrice)  
 IF 0 <> @@ERROR BEGIN  
  SET @Ret = 0  
  RETURN @Ret  
 END  
 SET @Ret = 1  
 RETURN @Ret  

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetRentPeriodDayList]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [spAdmWebGetRentPeriodDayList]
AS
 SET NOCOUNT ON
 SELECT  Day FROM RentPeriodDay(NOLOCK) ORDER BY Day

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spInsertServerLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spInsertServerLog]
 @ServerID smallint
, @PlayerCount smallint
, @GameCount smallint
, @BlockCount int
, @NonBlockCount int
AS
 SET NOCOUNT ON
 INSERT INTO ServerLog(ServerID, PlayerCount, 
  GameCount, Time, BlockCount, NonBlockCount)
 VALUES (@ServerID, @PlayerCount, @GameCount, 
  GETDATE(), @BlockCount, @NonBlockCount )

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetServerLogMaxPlayerCntDay]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



-------------------------------------------------------------------------------------------------------------

CREATE   PROC [spAdmWebGetServerLogMaxPlayerCntDay] 
 @ServerType tinyint  
, @StartDate smalldatetime
, @EndDate smalldatetime
AS
 SET NOCOUNT ON    

 IF @StartDate > @EndDate RETURN
 
 DECLARE @TmpStartDate smalldatetime
 DECLARE @TmpEndDate smalldatetime
 DECLARE @RangeStartDate smalldatetime
 DECLARE @RangeEndDate smalldatetime
 DECLARE @DayDiff int
 DECLARE @StartServerID tinyint    
 DECLARE @EndServerID tinyint    
 DECLARE @LiveServerCount tinyint   
 DECLARE @Date smalldatetime  
 DECLARE @Query varchar(8000)

 SELECT TOP 1 @TmpStartDate = Time FROM LogDB.game.ServerLogStorage(NOLOCK) ORDER BY Time 
 SELECT TOP 1 @TmpEndDate = Time FROM LogDB.game.ServerLogStorage(NOLOCK) ORDER BY Time DESC

 IF @StartDate < @TmpStartDate 
  SET @StartDate = @TmpStartDate
 IF @EndDate > @TmpEndDate
  SET @EndDate = @TmpEndDate

 SET @RangeStartDate = DATEADD(mi, -1, @StartDate)
 SET @RangeEndDate = DATEADD(mi, -1, @EndDate)
 SET @DayDiff = DATEDIFF(dd, @RangeStartDate, @RangeEndDate) + 1
    
 IF 0 = @ServerType SELECT @StartServerID = 1, @EndServerID = 255   -- all
 ELSE IF 1 = @ServerType SELECT @StartServerID = 1, @EndServerID = 49 -- normal    
 ELSE IF 2 = @ServerType SELECT @StartServerID = 50, @EndServerID = 99 -- clan    
 ELSE IF 3 = @ServerType SELECT @STartServerID = 100, @EndServerID = 149 -- quest    
 ELSE IF 4 = @ServerType RETURN-- event 
 ELSE RETURN    

 SELECT @LiveServerCount = COUNT(ServerID) 
 FROM ServerStatus(NOLOCK) 
 WHERE ServerID >= @StartServerID AND ServerID <= @EndServerID AND Opened <> 0    

 SET @Query = ''SELECT t.ServerID, t.ServerName, ''    

 -- 날짜만을 비교하기 위해서 시간과 분은 0으로 설정함.
 SET @Date = DATEADD(hh, DATEPART(hh, @RangeStartDate) * -1, @RangeStartDate)
 SET @Date = DATEADD(mi, DATEPART(mi, @RangeStartDate) * -1, @Date)

 WHILE @Date <= @RangeEndDate BEGIN
  SET @Query = @Query + ''MAX(CASE t.Day WHEN '' + CAST(DATEPART(dd, @Date) AS varchar(8))
   + '' THEN t.MaxPlayerCount ELSE 0 END)  AS '' + '''''''' + ''Day'' 
   + CAST(DATEPART(dd, @Date) AS varchar(8)) + ''''''''

  SET @Date = DATEADD(dd, 1, @Date)
  IF @Date > @RangeEndDate BREAK
  SET @Query = @Query + '', ''    
 END    

 SET @Query = @Query + '', SUM(MaxPlayerCount) / '' + CAST(@DayDiff AS varchar(8)) + '' AS AVG
 FROM
 (
 SELECT sls.ServerID, ss.ServerName, DATEPART(dd, DATEADD(mi, -1, sls.Time)) AS Day, MAX(PlayerCount) AS MaxPlayerCount
 FROM LogDB.game.ServerLogStorage sls(NOLOCK), ServerStatus ss(NOLOCK)
 WHERE sls.ServerID < 200 AND sls.ServerID >= '' + CAST(@StartServerID AS varchar(4)) 
  + '' AND sls.ServerID <= '' + CAST(@EndServerID AS varchar(4))
  + '' AND sls.Time >= '' + '''''''' + CAST(@StartDate AS varchar(64)) + '''''''' + '' 
  AND sls.Time <= '' + '''''''' + CAST(@EndDate AS varchar(64)) + '''''''' + ''
  AND ss.ServerID = sls.ServerID
  GROUP BY sls.ServerID, ss.ServerName, DATEPART(dd, DATEADD(mi, -1, sls.Time))
 ) as t
 GROUP BY t.ServerID, t.ServerName
 ORDER BY t.ServerID''

 EXEC (@Query)



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetServerLogTimeDay]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROC [spAdmWebGetServerLogTimeDay]  
 @ServerType tinyint    
, @StartDate smalldatetime      
, @EndDate smalldatetime      
AS       
 SET NOCOUNT ON      
  
 IF @StartDate > @EndDate RETURN  
   
 DECLARE @TmpStartDate smalldatetime  
 DECLARE @TmpEndDate smalldatetime  
 DECLARE @RangeStartDate smalldatetime  
 DECLARE @RangeEndDate smalldatetime  
 DECLARE @DayDiff int  
 DECLARE @StartServerID tinyint      
 DECLARE @EndServerID tinyint      
 DECLARE @LiveServerCount tinyint     
 DECLARE @Date smalldatetime    
 DECLARE @Query varchar(8000)  
  
 SELECT TOP 1 @TmpStartDate = Time FROM LogDB.game.ServerLogStorage(NOLOCK) ORDER BY Time   
 SELECT TOP 1 @TmpEndDate = Time FROM LogDB.game.ServerLogStorage(NOLOCK) ORDER BY Time DESC  
  
 IF @StartDate < @TmpStartDate   
  SET @StartDate = @TmpStartDate  
 IF @EndDate > @TmpEndDate  
  SET @EndDate = @TmpEndDate  
  
 SET @RangeStartDate = DATEADD(mi, -1, @StartDate)  
 SET @RangeEndDate = DATEADD(mi, -1, @EndDate)  
 SET @DayDiff = DATEDIFF(dd, @RangeStartDate, @RangeEndDate) + 1  
      
 IF 0 = @ServerType SELECT @StartServerID = 1, @EndServerID = 255   -- all  
 ELSE IF 1 = @ServerType SELECT @StartServerID = 1, @EndServerID = 49 -- normal      
 ELSE IF 2 = @ServerType SELECT @StartServerID = 50, @EndServerID = 99 -- clan      
 ELSE IF 3 = @ServerType SELECT @STartServerID = 100, @EndServerID = 149 -- quest      
 ELSE IF 4 = @ServerType RETURN-- event   
 ELSE RETURN      
  
  
 SELECT @LiveServerCount = COUNT(ServerID)   
 FROM ServerStatus(NOLOCK)   
 WHERE ServerID >= @StartServerID AND ServerID <= @EndServerID AND Opened <> 0      
  
 SET @Query = ''SELECT t.TimeGroup, ''      
  
 -- 날짜만을 비교하기 위해서 시간과 분은 0으로 설정함.  
 SET @Date = DATEADD(hh, DATEPART(hh, @RangeStartDate) * -1, @RangeStartDate)  
 SET @Date = DATEADD(mi, DATEPART(mi, @RangeStartDate) * -1, @Date)  
  
 WHILE @Date <= @RangeEndDate BEGIN  
    SET @Query = @Query + ''SUM(CASE t.Date WHEN '' + CAST(DATEPART(dd, @Date) AS varchar(8))  
    + '' THEN t.PlayerCount ELSE 0 END) AS '' + '''''''' + ''Day'' +      
   CAST(DATEPART(dd, @Date) AS varchar(8)) + ''''''''      
  
  SET @Date = DATEADD(dd, 1, @Date)  
  IF @Date > @RangeEndDate BREAK  
  SET @Query = @Query + '', ''  
 END  
  
 SET @Query = @Query + '', SUM(t.PlayerCount) / '' + CAST((@DayDiff  ) AS varchar(8)) + '' AS AVG  FROM       
 (     
 SELECT  tt.Date, tt.TimeGroup as TimeGroup,SUM(tt.PlayerCount )  as PlayerCount  
 FROM  
 (  
  SELECT SUM(PlayerCount ) /60 as PlayerCount, ServerID  
 ,DATEPART(dd, Time) as Date  
 ,DATEPART(hh, DATEADD(mi, -1, Time)) as TimeGroup  
  FROM LogDB.game.ServerLogStorage(NOLOCK)       
  WHERE Time >= '' + '''''''' + CAST(@StartDate AS varchar(64)) + '''''''' + ''  AND Time <= '' + '''''''' + CAST(@EndDate AS      
 varchar(64)) + '''''''' + ''  AND ServerID >= '' + CAST(@StartServerID AS varchar(8)) + ''   AND ServerID <= '' + CAST(@EndServerID AS      
 varchar(8)) + ''   
 GROUP BY DATEPART(dd, Time), DATEPART(hh, DATEADD(mi, -1, Time)), ServerID  
   
 ) as tt  
 GROUP BY tt.Date, tt.TimeGroup  
 ) AS t      
 GROUP BY  t.TimeGroup      
 ORDER BY  t.TimeGroup''      
  
 EXEC (@Query)

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetServerLogServerIDDay]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'



----------------------------------------------------------------------------------------------------------------------

CREATE   PROC [spAdmWebGetServerLogServerIDDay]
 @ServerType tinyint  
, @StartDate smalldatetime
, @EndDate smalldatetime
AS
 SET NOCOUNT ON    

 IF @StartDate > @EndDate RETURN
 
 DECLARE @TmpStartDate smalldatetime
 DECLARE @TmpEndDate smalldatetime
 DECLARE @RangeStartDate smalldatetime
 DECLARE @RangeEndDate smalldatetime
 DECLARE @DayDiff int
 DECLARE @StartServerID tinyint    
 DECLARE @EndServerID tinyint    
 DECLARE @LiveServerCount tinyint   
 DECLARE @Date smalldatetime  
 DECLARE @Query varchar(8000)

 SELECT TOP 1 @TmpStartDate = Time FROM LogDB.game.ServerLogStorage(NOLOCK) ORDER BY Time 
 SELECT TOP 1 @TmpEndDate = Time FROM LogDB.game.ServerLogStorage(NOLOCK) ORDER BY Time DESC

 IF @StartDate < @TmpStartDate 
  SET @StartDate = @TmpStartDate
 IF @EndDate > @TmpEndDate
  SET @EndDate = @TmpEndDate

 SET @RangeStartDate = DATEADD(mi, -1, @StartDate)
 SET @RangeEndDate = DATEADD(mi, -1, @EndDate)
 SET @DayDiff = DATEDIFF(dd, @RangeStartDate, @RangeEndDate) + 1
    
 IF 0 = @ServerType SELECT @StartServerID = 1, @EndServerID = 255   -- all
 ELSE IF 1 = @ServerType SELECT @StartServerID = 1, @EndServerID = 49 -- normal    
 ELSE IF 2 = @ServerType SELECT @StartServerID = 50, @EndServerID = 99 -- clan    
 ELSE IF 3 = @ServerType SELECT @STartServerID = 100, @EndServerID = 149 -- quest    
 ELSE IF 4 = @ServerType RETURN-- event 
 ELSE RETURN    

 SELECT @LiveServerCount = COUNT(ServerID) 
 FROM ServerStatus(NOLOCK) 
 WHERE ServerID >= @StartServerID AND ServerID <= @EndServerID AND Opened <> 0    

 SET @Query = ''SELECT sls.ServerID, ss.ServerName, ''

 -- 날짜만을 비교하기 위해서 시간과 분은 0으로 설정함.
 SET @Date = DATEADD(hh, DATEPART(hh, @RangeStartDate) * -1, @RangeStartDate)
 SET @Date = DATEADD(mi, DATEPART(mi, @RangeStartDate) * -1, @Date)

 WHILE @Date <= @RangeEndDate BEGIN
  SET @Query = @Query + ''(SUM(CASE DATEPART(dd, DATEADD(mi, -1, sls.Time)) WHEN '' + CAST(DATEPART(dd, @Date) AS varchar(8))
   + '' THEN sls.PlayerCount ELSE 0 END) / 1440) AS '' + '''''''' + ''Day'' 
   + CAST(DATEPART(dd, @Date) AS varchar(8)) + ''''''''

  SET @Date = DATEADD(dd, 1, @Date)
  IF @Date > @RangeEndDate BREAK
  SET @Query = @Query + '', ''    
 END    

 SET @Query = @Query + '', SUM(sls.PlayerCount) / '' + CAST((@DayDiff * 1440) AS varchar(8)) + '' AS AVG
 FROM LogDB.game.ServerLogStorage sls(NOLOCK), ServerStatus ss(NOLOCK)
 WHERE sls.ServerID < 200 AND sls.ServerID >= '' + CAST(@StartServerID AS varchar(4)) 
  + '' AND sls.ServerID <= '' + CAST(@EndServerID AS varchar(4)) 
  + '' AND sls.Time >= '' + '''''''' + CAST(@StartDate AS varchar(64)) + '''''''' + '' 
  AND sls.Time <= '' + '''''''' + CAST(@EndDate AS varchar(64)) + '''''''' 
  + '' AND ss.ServerID = sls.ServerID
 GROUP BY sls.ServerID, ss.ServerName
 ORDER BY sls.ServerID''

 EXEC (@Query)



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spAdmWebGetServerLogMaxTimeDay]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-------------------------------------------------------------------------------------------------------------

CREATE PROC [spAdmWebGetServerLogMaxTimeDay]  
 @ServerType tinyint    
, @StartDate smalldatetime      
, @EndDate smalldatetime      
AS       
 SET NOCOUNT ON      
  
 IF @StartDate > @EndDate RETURN  
   
 DECLARE @TmpStartDate smalldatetime  
 DECLARE @TmpEndDate smalldatetime  
 DECLARE @RangeStartDate smalldatetime  
 DECLARE @RangeEndDate smalldatetime  
 DECLARE @DayDiff int  
 DECLARE @StartServerID tinyint      
 DECLARE @EndServerID tinyint      
 DECLARE @LiveServerCount tinyint     
 DECLARE @Date smalldatetime    
 DECLARE @Query varchar(8000)  
  
 SELECT TOP 1 @TmpStartDate = Time FROM LogDB.game.ServerLogStorage(NOLOCK) ORDER BY Time   
 SELECT TOP 1 @TmpEndDate = Time FROM LogDB.game.ServerLogStorage(NOLOCK) ORDER BY Time DESC  
  
 IF @StartDate < @TmpStartDate   
  SET @StartDate = @TmpStartDate  
 IF @EndDate > @TmpEndDate  
  SET @EndDate = @TmpEndDate  
  
 SET @RangeStartDate = DATEADD(mi, -1, @StartDate)  
 SET @RangeEndDate = DATEADD(mi, -1, @EndDate)  
 SET @DayDiff = DATEDIFF(dd, @RangeStartDate, @RangeEndDate) + 1  
      
 IF 0 = @ServerType SELECT @StartServerID = 1, @EndServerID = 255   -- all  
 ELSE IF 1 = @ServerType SELECT @StartServerID = 1, @EndServerID = 49 -- normal      
 ELSE IF 2 = @ServerType SELECT @StartServerID = 50, @EndServerID = 99 -- clan      
 ELSE IF 3 = @ServerType SELECT @STartServerID = 100, @EndServerID = 149 -- quest      
 ELSE IF 4 = @ServerType RETURN-- event   
 ELSE RETURN      
  
SELECT @LiveServerCount = COUNT(ServerID)   
 FROM ServerStatus(NOLOCK)   
 WHERE ServerID >= @StartServerID AND ServerID <= @EndServerID AND Opened <> 0      
  
 SET @Query = ''SELECT   
  t.TimeGroup  AS TimeGroup, ''      
  
 -- 날짜만을 비교하기 위해서 시간과 분은 0으로 설정함.  
 SET @Date = DATEADD(hh, DATEPART(hh, @RangeStartDate) * -1, @RangeStartDate)  
 SET @Date = DATEADD(mi, DATEPART(mi, @RangeStartDate) * -1, @Date)  
  
 WHILE @Date <= @RangeEndDate BEGIN  
  SET @Query = @Query + ''MAX(CASE t.Date WHEN '' + CAST(DATEPART(dd, @Date) AS varchar(8))  
    + '' THEN t.MaxPlayerCount ELSE 0 END) AS '' + '''''''' + ''Day'' +      
   CAST(DATEPART(dd, @Date) AS varchar(8)) + ''''''''      
  
  SET @Date = DATEADD(dd, 1, @Date)  
  IF @Date > @RangeEndDate BREAK  
  SET @Query = @Query + '', ''  
 END  
  
 SET @Query = @Query + '', SUM(t.MaxPlayerCount) / '' + CAST(@DayDiff AS varchar(8)) + '' AS AVG      
 FROM       
 (      
SELECT tt.Date, tt.TimeGroup, SUM(tt.MaxPlayerCount) as MaxPlayerCount  
 FROM  
 (  
 SELECT ServerID, DATEPART(dd, DATEADD(mi, -1, Time)) as Date   
   ,DATEPART(hh, DATEADD(mi, -1, Time)) AS TimeGroup,  
  MAX(PlayerCount) AS MaxPlayerCount  
  FROM LogDB.game.ServerLogStorage(NOLOCK)       
  WHERE Time >= '' + '''''''' + CAST(@StartDate AS varchar(64)) + '''''''' + ''  AND Time <=  '' + '''''''' + CAST(@EndDate AS      
 varchar(64)) + '''''''' + '' AND ServerID >= '' + CAST(@StartServerID AS varchar(8)) + ''  AND ServerID <=  '' + CAST(@EndServerID AS      
 varchar(8)) + ''  
   GROUP BY ServerID, DATEPART(dd, DATEADD(mi, -1,Time))  
    , DATEPART(hh, DATEADD(mi, -1, Time))   
 ) AS tt  
GROUP BY tt.Date, tt.TimeGroup   
) AS t      
 GROUP BY t.TimeGroup      
 ORDER BY CAST(t.TimeGroup AS float)''  
  
 EXEC(@Query)


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spUpdateServerStatus]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


/* 서버 동접자 상태 */
CREATE PROC [spUpdateServerStatus]
  @CurrPlayer   smallint,
  @ServerID     int
AS
SET NOCOUNT ON
UPDATE ServerStatus 
Set CurrPlayer=@CurrPlayer, Time=GETDATE() 
WHERE ServerID=@ServerID



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spGetTotalRanking]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


/* 전체 랭킹 보기 */
CREATE PROC [spGetTotalRanking]
	@MinRank		int,
	@MaxRank		int
AS
SET NOCOUNT ON

SELECT Rank, Level, UserID, Name, XP, KillCount, DeathCount FROM TotalRanking(nolock)
WHERE Rank BETWEEN @MinRank AND @MaxRank
ORDER BY Rank



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spSearchTotalRankingByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 순위 검색 */
CREATE PROC [spSearchTotalRankingByName]
	@Name				varchar(24)
AS
SET NOCOUNT ON
-- 와일드카드 문자 처리
--SELECT @Name = REPLACE(@Name, ''['', ''[[]'')
--SELECT @Name = REPLACE(@Name, ''%'', ''[%]'')
--SELECT @Name = REPLACE(@Name, ''_'', ''[_]'')

SELECT Rank, Level, UserID, Name, XP, KillCount, DeathCount 
FROM TotalRanking(nolock)
WHERE Name=@Name




' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spSearchTotalRankingByNetmarbleID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 자신의 랭킹 정보.
CREATE PROC [spSearchTotalRankingByNetmarbleID]
	@UserID varchar(20)
AS
SET NOCOUNT ON
BEGIN
	SELECT Rank, Level, Name, XP, KillCount, DeathCount, UserID 
	FROM TotalRanking (NOLOCK)
	WHERE Name = @UserID
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebSearchTotalRankingByNetmarbleID]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'


-- 자신의 랭킹 정보.
CREATE PROC [spWebSearchTotalRankingByNetmarbleID]
	@UserID varchar(20)
AS
SET NOCOUNT ON
BEGIN
	SELECT Rank, Level, Name, XP, KillCount, DeathCount, UserID 
	FROM TotalRanking (NOLOCK)
	WHERE UserID = @UserID
END


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spWebSearchTotalRankingByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

/* 캐릭터 이름으로 순위 검색 */    
CREATE PROC [spWebSearchTotalRankingByName]    
  @Name    varchar(24)    
AS  
SET NOCOUNT ON
BEGIN    
 SELECT Rank, Level, Name, XP, KillCount, DeathCount, UserID  
 FROM TotalRanking(NOLOCK)    
 WHERE Name = @Name    
END  



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_adduserobject_vcs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create procedure [dt_adduserobject_vcs]
    @vchProperty varchar(64)

as

set nocount on

declare @iReturn int
    /*
    ** Create the user object if it does not exist already
    */
    begin transaction
        select @iReturn = objectid from dbo.dtproperties where property = @vchProperty
        if @iReturn IS NULL
        begin
            insert dbo.dtproperties (property) VALUES (@vchProperty)
            update dbo.dtproperties set objectid=@@identity
                    where id=@@identity and property=@vchProperty
            select @iReturn = @@identity
        end
    commit
    return @iReturn



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_adduserobject]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
**	Add an object to the dtproperties table
*/
create procedure [dt_adduserobject]
as
	set nocount on
	/*
	** Create the user object if it does not exist already
	*/
	begin transaction
		insert dbo.dtproperties (property) VALUES (''DtgSchemaOBJECT'')
		update dbo.dtproperties set objectid=@@identity 
			where id=@@identity and property=''DtgSchemaOBJECT''
	commit
	return @@identity

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_getpropertiesbyid_vcs]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create procedure [dt_getpropertiesbyid_vcs]
    @id       int,
    @property varchar(64),
    @value    varchar(255) = NULL OUT

as

    set nocount on

    select @value = (
        select value
                from dbo.dtproperties
                where @id=objectid and @property=property
                )


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_getpropertiesbyid_u]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
**	Retrieve properties by id''s
**
**	dt_getproperties objid, null or '''' -- retrieve all properties of the object itself
**	dt_getproperties objid, property -- retrieve the property specified
*/
create procedure [dt_getpropertiesbyid_u]
	@id int,
	@property varchar(64)
as
	set nocount on

	if (@property is null) or (@property = '''')
		select property, version, uvalue, lvalue
			from dbo.dtproperties
			where  @id=objectid
	else
		select property, version, uvalue, lvalue
			from dbo.dtproperties
			where  @id=objectid and @property=property

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_getobjwithprop]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
**	Retrieve the owner object(s) of a given property
*/
create procedure [dt_getobjwithprop]
	@property varchar(30),
	@value varchar(255)
as
	set nocount on

	if (@property is null) or (@property = '''')
	begin
		raiserror(''Must specify a property name.'',-1,-1)
		return (1)
	end

	if (@value is null)
		select objectid id from dbo.dtproperties
			where property=@property

	else
		select objectid id from dbo.dtproperties
			where property=@property and value=@value

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_generateansiname]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/* 
**	Generate an ansi name that is unique in the dtproperties.value column 
*/ 
create procedure [dt_generateansiname](@name varchar(255) output) 
as 
	declare @prologue varchar(20) 
	declare @indexstring varchar(20) 
	declare @index integer 
 
	set @prologue = ''MSDT-A-'' 
	set @index = 1 
 
	while 1 = 1 
	begin 
		set @indexstring = cast(@index as varchar(20)) 
		set @name = @prologue + @indexstring 
		if not exists (select value from dtproperties where value = @name) 
			break 
		 
		set @index = @index + 1 
 
		if (@index = 10000) 
			goto TooMany 
	end 
 
Leave: 
 
	return 
 
TooMany: 
 
	set @name = ''DIAGRAM'' 
	goto Leave 

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_getpropertiesbyid]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
**	Retrieve properties by id''s
**
**	dt_getproperties objid, null or '''' -- retrieve all properties of the object itself
**	dt_getproperties objid, property -- retrieve the property specified
*/
create procedure [dt_getpropertiesbyid]
	@id int,
	@property varchar(64)
as
	set nocount on

	if (@property is null) or (@property = '''')
		select property, version, value, lvalue
			from dbo.dtproperties
			where  @id=objectid
	else
		select property, version, value, lvalue
			from dbo.dtproperties
			where  @id=objectid and @property=property

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_getobjwithprop_u]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
**	Retrieve the owner object(s) of a given property
*/
create procedure [dt_getobjwithprop_u]
	@property varchar(30),
	@uvalue nvarchar(255)
as
	set nocount on

	if (@property is null) or (@property = '''')
	begin
		raiserror(''Must specify a property name.'',-1,-1)
		return (1)
	end

	if (@uvalue is null)
		select objectid id from dbo.dtproperties
			where property=@property

	else
		select objectid id from dbo.dtproperties
			where property=@property and uvalue=@uvalue

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_dropuserobjectbyid]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
**	Drop an object from the dbo.dtproperties table
*/
create procedure [dt_dropuserobjectbyid]
	@id int
as
	set nocount on
	delete from dbo.dtproperties where objectid=@id

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_droppropertiesbyid]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
**	Drop one or all the associated properties of an object or an attribute 
**
**	dt_dropproperties objid, null or '''' -- drop all properties of the object itself
**	dt_dropproperties objid, property -- drop the property
*/
create procedure [dt_droppropertiesbyid]
	@id int,
	@property varchar(64)
as
	set nocount on

	if (@property is null) or (@property = '''')
		delete from dbo.dtproperties where objectid=@id
	else
		delete from dbo.dtproperties 
			where objectid=@id and property=@property


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_checkoutobject]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create proc [dt_checkoutobject]
    @chObjectType  char(4),
    @vchObjectName varchar(255),
    @vchComment    varchar(255),
    @vchLoginName  varchar(255),
    @vchPassword   varchar(255),
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0/* 0 => Checkout, 1 => GetLatest, 2 => UndoCheckOut */

as

	set nocount on

	declare @iReturn int
	declare @iObjectId int
	select @iObjectId =0

	declare @VSSGUID varchar(100)
	select @VSSGUID = ''SQLVersionControl.VCS_SQL''

	declare @iReturnValue int
	select @iReturnValue = 0

	declare @vchTempText varchar(255)

	/* this is for our strings */
	declare @iStreamObjectId int
	select @iStreamObjectId = 0

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = ''VCSProjectID'')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSProject'',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSSourceSafeINI'', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSSQLServer'',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSSQLDatabase'',   @vchDatabaseName  OUT

    if @chObjectType = ''PROC''
    begin
        /* Procedure Can have up to three streams
           Drop Stream, Create Stream, GRANT stream */

        exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
												''CheckOut_StoredProcedure'',
												NULL,
												@sProjectName = @vchProjectName,
												@sSourceSafeINI = @vchSourceSafeINI,
												@sObjectName = @vchObjectName,
												@sServerName = @vchServerName,
												@sDatabaseName = @vchDatabaseName,
												@sComment = @vchComment,
												@sLoginName = @vchLoginName,
												@sPassword = @vchPassword,
												@iVCSFlags = @iVCSFlags,
												@iActionFlag = @iActionFlag

        if @iReturn <> 0 GOTO E_OAError


        exec @iReturn = master.dbo.sp_OAGetProperty @iObjectId, ''GetStreamObject'', @iStreamObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        create table #commenttext (id int identity, sourcecode varchar(255))


        select @vchTempText = ''STUB''
        while @vchTempText is not null
        begin
            exec @iReturn = master.dbo.sp_OAMethod @iStreamObjectId, ''GetStream'', @iReturnValue OUT, @vchTempText OUT
            if @iReturn <> 0 GOTO E_OAError
            
            if (@vchTempText = '''') set @vchTempText = null
            if (@vchTempText is not null) insert into #commenttext (sourcecode) select @vchTempText
        end

        select ''VCS''=sourcecode from #commenttext order by id
        select ''SQL''=text from syscomments where id = object_id(@vchObjectName) order by colid

    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    GOTO CleanUp



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_checkinobject]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create proc [dt_checkinobject]
    @chObjectType  char(4),
    @vchObjectName varchar(255),
    @vchComment    varchar(255)='''',
    @vchLoginName  varchar(255),
    @vchPassword   varchar(255)='''',
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0,   /* 0 => AddFile, 1 => CheckIn */
    @txStream1     Text = '''', /* drop stream   */ /* There is a bug that if items are NULL they do not pass to OLE servers */
    @txStream2     Text = '''', /* create stream */
    @txStream3     Text = ''''  /* grant stream  */


as

	set nocount on

	declare @iReturn int
	declare @iObjectId int
	select @iObjectId = 0
	declare @iStreamObjectId int

	declare @VSSGUID varchar(100)
	select @VSSGUID = ''SQLVersionControl.VCS_SQL''

	declare @iPropertyObjectId int
	select @iPropertyObjectId  = 0

    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = ''VCSProjectID'')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    declare @iReturnValue	  int
    declare @pos			  int
    declare @vchProcLinePiece varchar(255)

    
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSProject'',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSSourceSafeINI'', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSSQLServer'',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSSQLDatabase'',   @vchDatabaseName  OUT

    if @chObjectType = ''PROC''
    begin
        if @iActionFlag = 1
        begin
            /* Procedure Can have up to three streams
            Drop Stream, Create Stream, GRANT stream */

            begin tran compile_all

            /* try to compile the streams */
            exec (@txStream1)
            if @@error <> 0 GOTO E_Compile_Fail

            exec (@txStream2)
            if @@error <> 0 GOTO E_Compile_Fail

            exec (@txStream3)
            if @@error <> 0 GOTO E_Compile_Fail
        end

        exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = master.dbo.sp_OAGetProperty @iObjectId, ''GetStreamObject'', @iStreamObjectId OUT
        if @iReturn <> 0 GOTO E_OAError
        
        if @iActionFlag = 1
        begin
            
            declare @iStreamLength int
			
			select @pos=1
			select @iStreamLength = datalength(@txStream2)
			
			if @iStreamLength > 0
			begin
			
				while @pos < @iStreamLength
				begin
						
					select @vchProcLinePiece = substring(@txStream2, @pos, 255)
					
					exec @iReturn = master.dbo.sp_OAMethod @iStreamObjectId, ''AddStream'', @iReturnValue OUT, @vchProcLinePiece
            		if @iReturn <> 0 GOTO E_OAError
            		
					select @pos = @pos + 255
					
				end
            
				exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
														''CheckIn_StoredProcedure'',
														NULL,
														@sProjectName = @vchProjectName,
														@sSourceSafeINI = @vchSourceSafeINI,
														@sServerName = @vchServerName,
														@sDatabaseName = @vchDatabaseName,
														@sObjectName = @vchObjectName,
														@sComment = @vchComment,
														@sLoginName = @vchLoginName,
														@sPassword = @vchPassword,
														@iVCSFlags = @iVCSFlags,
														@iActionFlag = @iActionFlag,
														@sStream = ''''
                                        
			end
        end
        else
        begin
        
            select colid, text into #ProcLines
            from syscomments
            where id = object_id(@vchObjectName)
            order by colid

            declare @iCurProcLine int
            declare @iProcLines int
            select @iCurProcLine = 1
            select @iProcLines = (select count(*) from #ProcLines)
            while @iCurProcLine <= @iProcLines
            begin
                select @pos = 1
                declare @iCurLineSize int
                select @iCurLineSize = len((select text from #ProcLines where colid = @iCurProcLine))
                while @pos <= @iCurLineSize
                begin                
                    select @vchProcLinePiece = convert(varchar(255),
                        substring((select text from #ProcLines where colid = @iCurProcLine),
                                  @pos, 255 ))
                    exec @iReturn = master.dbo.sp_OAMethod @iStreamObjectId, ''AddStream'', @iReturnValue OUT, @vchProcLinePiece
                    if @iReturn <> 0 GOTO E_OAError
                    select @pos = @pos + 255                  
                end
                select @iCurProcLine = @iCurProcLine + 1
            end
            drop table #ProcLines

            exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
													''CheckIn_StoredProcedure'',
													NULL,
													@sProjectName = @vchProjectName,
													@sSourceSafeINI = @vchSourceSafeINI,
													@sServerName = @vchServerName,
													@sDatabaseName = @vchDatabaseName,
													@sObjectName = @vchObjectName,
													@sComment = @vchComment,
													@sLoginName = @vchLoginName,
													@sPassword = @vchPassword,
													@iVCSFlags = @iVCSFlags,
													@iActionFlag = @iActionFlag,
													@sStream = ''''
        end

        if @iReturn <> 0 GOTO E_OAError

        if @iActionFlag = 1
        begin
            commit tran compile_all
            if @@error <> 0 GOTO E_Compile_Fail
        end

    end

CleanUp:
	return

E_Compile_Fail:
	declare @lerror int
	select @lerror = @@error
	rollback tran compile_all
	RAISERROR (@lerror,16,-1)
	goto CleanUp

E_OAError:
	if @iActionFlag = 1 rollback tran compile_all
	exec dbo.dt_displayoaerror @iObjectId, @iReturn
	goto CleanUp



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_setpropertybyid]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
**	If the property already exists, reset the value; otherwise add property
**		id -- the id in sysobjects of the object
**		property -- the name of the property
**		value -- the text value of the property
**		lvalue -- the binary value of the property (image)
*/
create procedure [dt_setpropertybyid]
	@id int,
	@property varchar(64),
	@value varchar(255),
	@lvalue image
as
	set nocount on
	declare @uvalue nvarchar(255) 
	set @uvalue = convert(nvarchar(255), @value) 
	if exists (select * from dbo.dtproperties 
			where objectid=@id and property=@property)
	begin
		--
		-- bump the version count for this row as we update it
		--
		update dbo.dtproperties set value=@value, uvalue=@uvalue, lvalue=@lvalue, version=version+1
			where objectid=@id and property=@property
	end
	else
	begin
		--
		-- version count is auto-set to 0 on initial insert
		--
		insert dbo.dtproperties (property, objectid, value, uvalue, lvalue)
			values (@property, @id, @value, @uvalue, @lvalue)
	end


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_addtosourcecontrol_u]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create proc [dt_addtosourcecontrol_u]
    @vchSourceSafeINI nvarchar(255) = '''',
    @vchProjectName   nvarchar(255) ='''',
    @vchComment       nvarchar(255) ='''',
    @vchLoginName     nvarchar(255) ='''',
    @vchPassword      nvarchar(255) =''''

as
	-- This procedure should no longer be called;  dt_addtosourcecontrol should be called instead.
	-- Calls are forwarded to dt_addtosourcecontrol to maintain backward compatibility
	set nocount on
	exec dbo.dt_addtosourcecontrol 
		@vchSourceSafeINI, 
		@vchProjectName, 
		@vchComment, 
		@vchLoginName, 
		@vchPassword



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_displayoaerror_u]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dt_displayoaerror_u]
    @iObject int,
    @iresult int
as
	-- This procedure should no longer be called;  dt_displayoaerror should be called instead.
	-- Calls are forwarded to dt_displayoaerror to maintain backward compatibility.
	set nocount on
	exec dbo.dt_displayoaerror
		@iObject,
		@iresult



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spRegularUpdateConnLog]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

CREATE PROC [spRegularUpdateConnLog]
AS
SET NOCOUNT ON
-- 다음 날자의 ConnLog테이블 생성 쿼리.
DECLARE @NewTableName varchar(20)
DECLARE @CreateConnLogQuery varchar( 255 )
DECLARE @NextDate smalldatetime

DECLARE @Month int
DECLARE @Day int

EXEC spGetAgoDay -1, @NextDate OUTPUT

SET @Month = DATEPART(mm, @NextDate)
SET @Day = DATEPART(dd, @NextDate)

SELECT @NewTableName = ''ConnLog_'' + 
	CAST( DATEPART(yy, @NextDate) AS varchar(4) ) + 
	CASE WHEN @Month < 10 THEN ''0''  ELSE '''' END + CAST(@Month AS varchar(4)) +
	CASE WHEN @Day < 10 THEN ''0'' ELSE '''' END + CAST(@Day AS varchar(4))

SELECT @CreateConnLogQuery = ''CREATE TABLE '' + @NewTableName + ''(id int identity PRIMARY KEY, AID int NOT NULL, Time smalldatetime NOT NULL, IP char(12) NOT NULL)''

EXEC (@CreateConnLogQuery )



-- 이전 날짜ConnLog의 UV처리 쿼리
DECLARE @TableName varchar(20) 
DECLARE @UVQuery varchar(512)
DECLARE @BefDate datetime


EXEC spGetAgoDay 1, @BefDate OUTPUT

SET @Month = DATEPART(mm, @BefDate)
SET @Day  = DATEPART(dd, @BefDate)

SELECT @TableName = ''ConnLog_'' + 
	CAST( DATEPART(yy, @BefDate) AS varchar(4) ) + 
	CASE WHEN @Month < 10 THEN ''0'' ELSE '''' END + CAST(@Month AS varchar(4)) +
	CASE WHEN @Day < 10 THEN ''0'' ELSE '''' END + CAST(@Day AS varchar(4)) 

SELECT @UVQuery = ''
DECLARE @Count int
DECLARE @Date smalldatetime

EXEC spGetAgoDay 1, @Date OUTPUT

SELECT @Count = COUNT(*) FROM (SELECT AID FROM '' + @TableName + '' (NOLOCK) GROUP BY AID) A

INSERT INTO UV(Time, Count) VALUES (@Date, @Count)''

EXEC (@UVQuery)

--EXEC (''TRUNCATE TABLE '' + @TableName)
--EXEC (''DROP TABLE '' + @TableName)



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spIPFltInsertCustomIP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
 * @Ret(0:Fail, 1:Success, 2:Duplicate, 3:Invers range)
 */
CREATE PROC [spIPFltInsertCustomIP]
 @IPFrom varchar(15)
, @IPTo varchar(15)
, @IsBlock tinyint
, @CountryCode3 char(3)
, @Comment varchar(128)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON
 DECLARE @DupRet int
 DECLARE @TmpIPFrom BIGINT
 DECLARE @TmpIPTo BIGINT

 SET @TmpIPFrom = GunzDB.game.inet_aton( @IPFrom )
 SET @TmpIPTo = GunzDB.game.inet_aton( @IPTo )
 IF @TmpIPFrom > @TmpIPTo BEGIN
  SET @Ret = 3
  RETURN @Ret
 END

 EXEC spIPFltCheckIsDuplicateRange @TmpIPFrom, @TmpIPTo, @DupRet OUTPUT
 IF 1 = @DupRet BEGIN
  SET @Ret = 2
  RETURN @Ret
 END 

 INSERT INTO CustomIP(IPFrom, IPTo, CountryCode3, IsBlock, Comment, RegDate)
 VALUES (@TmpIPFrom, @TmpIPTo, @CountryCode3, @IsBlock, @Comment, GETDATE() )
 IF 0 <> @@ERROR SET @Ret = 0
 ELSE SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spIPFltUpdateCustomIP]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
 * @Ret(0:Fail, 1:Success, 2:Duplicate, 3:Invers range)
 */
CREATE PROC [spIPFltUpdateCustomIP]
 @IPFrom varchar(15)
, @IPTo varchar(15)
, @NewIPFrom varchar(15)
, @NewIPTo varchar(15)
, @IsBlock tinyint
, @CountryCode3 char(3)
, @Comment varchar(128)
, @Ret int OUTPUT
AS
 SET NOCOUNT ON 
 DECLARE @DupRet bigint
 DECLARE @TmpIPFrom BIGINT
 DECLARE @TmpIPTo BIGINT
 DECLARE @TmpNewIPFrom bigint
 DECLARE @TmpNewIPTo bigint

 SET @TmpIPFrom = GunzDB.game.inet_aton( @IPFrom )
 SET @TmpIPTo = GunzDB.game.inet_aton( @IPTo )

 IF @TmpIPFrom > @TmpIPTo BEGIN
  SET @Ret = 3
  RETURN @Ret
 END

 SET @TmpNewIPFrom = GunzDB.game.inet_aton( @NewIPFrom )
 SET @TmpNewIPTo = GunzDB.game.inet_aton( @NewIPTo )

 IF @TmpNewIPFrom > @TmpNewIPTo BEGIN
  SET @Ret = 0
  RETURN @Ret
 END

 -- 이전 IP범위와 같으면 IP변경 없이 다른 데이터만 변경하는 것임.
 IF (@TmpIPFrom <> @TmpNewIPFrom) OR (@TmpIPTo <> @TmpNewIPTo) BEGIN
  EXEC spIPFltCheckIsDuplicateRange @TmpNewIPFrom, @TmpNewIPTo, @DupRet OUTPUT
  IF 1 = @DupRet BEGIN 
   SET @Ret = 2
   RETURN @Ret
  END
 END

 UPDATE CustomIP
 SET IPFrom = @TmpNewIPFrom, IPTo = @TmpNewIPTo,
  IsBlock = @IsBlock, CountryCode3 = @CountryCode3,
  Comment = @Comment
 WHERE IPFrom = @TmpIPFrom AND IPTo = @TmpIPTo
 IF 0 <> @@ERROR OR 0 = @@ROWCOUNT SET @Ret = 0
 ELSE SET @Ret = 1
 RETURN @Ret

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[spRegularUpdateHonorRanking]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'

-- 한달에 한번씩 명예의 전당 업데이트, 꼭 그 다음달의 1일에 해야한다.
CREATE PROC [spRegularUpdateHonorRanking]
AS
SET NOCOUNT ON
BEGIN TRAN -------------

EXEC [spRegularUpdateClanRanking]

DECLARE @Year		int
DECLARE @Month		int

SELECT @Year = YEAR(GETDATE())
SELECT @Month = MONTH(GETDATE())

IF (@Month = 1) 
BEGIN
	SELECT @Year = @Year-1
END

SELECT @Month = @Month - 1

IF (@Month = 0)
BEGIN
	SELECT @Month = 12
END

INSERT INTO ClanHonorRanking(CLID, ClanName, Point, Wins, Losses, Ranking, Year, Month)
SELECT CLID, Name AS ClanName, Point, Wins, Losses, Ranking, @Year, @Month
FROM Clan 
WHERE DeleteFlag=0 AND Ranking>0
ORDER BY Ranking
IF 0 <> @@ERROR BEGIN -- 여기 추가.
	ROLLBACK TRAN
	RETURN
END

-- 클랜 리셋
UPDATE Clan SET Ranking=0, Wins=0, Losses=0, Point=1000, RankIncrease=0, LastDayRanking=0
IF 0 = @@ROWCOUNT BEGIN -- 여기 추가.
	ROLLBACK TRAN
	RETURN
END

COMMIT TRAN -----------


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_isundersourcecontrol]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create proc [dt_isundersourcecontrol]
    @vchLoginName varchar(255) = '''',
    @vchPassword  varchar(255) = '''',
    @iWhoToo      int = 0 /* 0 => Just check project; 1 => get list of objs */

as

	set nocount on

	declare @iReturn int
	declare @iObjectId int
	select @iObjectId = 0

	declare @VSSGUID varchar(100)
	select @VSSGUID = ''SQLVersionControl.VCS_SQL''

	declare @iReturnValue int
	select @iReturnValue = 0

	declare @iStreamObjectId int
	select @iStreamObjectId   = 0

	declare @vchTempText varchar(255)

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = ''VCSProjectID'')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSProject'',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSSourceSafeINI'', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSSQLServer'',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSSQLDatabase'',   @vchDatabaseName  OUT

    if (@vchProjectName = '''')	set @vchProjectName		= null
    if (@vchSourceSafeINI = '''') set @vchSourceSafeINI	= null
    if (@vchServerName = '''')	set @vchServerName		= null
    if (@vchDatabaseName = '''')	set @vchDatabaseName	= null
    
    if (@vchProjectName is null) or (@vchSourceSafeINI is null) or (@vchServerName is null) or (@vchDatabaseName is null)
    begin
        RAISERROR(''Not Under Source Control'',16,-1)
        return
    end

    if @iWhoToo = 1
    begin

        /* Get List of Procs in the project */
        exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
												''GetListOfObjects'',
												NULL,
												@vchProjectName,
												@vchSourceSafeINI,
												@vchServerName,
												@vchDatabaseName,
												@vchLoginName,
												@vchPassword

        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = master.dbo.sp_OAGetProperty @iObjectId, ''GetStreamObject'', @iStreamObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        create table #ObjectList (id int identity, vchObjectlist varchar(255))

        select @vchTempText = ''STUB''
        while @vchTempText is not null
        begin
            exec @iReturn = master.dbo.sp_OAMethod @iStreamObjectId, ''GetStream'', @iReturnValue OUT, @vchTempText OUT
            if @iReturn <> 0 GOTO E_OAError
            
            if (@vchTempText = '''') set @vchTempText = null
            if (@vchTempText is not null) insert into #ObjectList (vchObjectlist ) select @vchTempText
        end

        select vchObjectlist from #ObjectList order by id
    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    goto CleanUp



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_setpropertybyid_u]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
/*
**	If the property already exists, reset the value; otherwise add property
**		id -- the id in sysobjects of the object
**		property -- the name of the property
**		uvalue -- the text value of the property
**		lvalue -- the binary value of the property (image)
*/
create procedure [dt_setpropertybyid_u]
	@id int,
	@property varchar(64),
	@uvalue nvarchar(255),
	@lvalue image
as
	set nocount on
	-- 
	-- If we are writing the name property, find the ansi equivalent. 
	-- If there is no lossless translation, generate an ansi name. 
	-- 
	declare @avalue varchar(255) 
	set @avalue = null 
	if (@uvalue is not null) 
	begin 
		if (convert(nvarchar(255), convert(varchar(255), @uvalue)) = @uvalue) 
		begin 
			set @avalue = convert(varchar(255), @uvalue) 
		end 
		else 
		begin 
			if ''DtgSchemaNAME'' = @property 
			begin 
				exec dbo.dt_generateansiname @avalue output 
			end 
		end 
	end 
	if exists (select * from dbo.dtproperties 
			where objectid=@id and property=@property)
	begin
		--
		-- bump the version count for this row as we update it
		--
		update dbo.dtproperties set value=@avalue, uvalue=@uvalue, lvalue=@lvalue, version=version+1
			where objectid=@id and property=@property
	end
	else
	begin
		--
		-- version count is auto-set to 0 on initial insert
		--
		insert dbo.dtproperties (property, objectid, value, uvalue, lvalue)
			values (@property, @id, @avalue, @uvalue, @lvalue)
	end

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_removefromsourcecontrol]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create procedure [dt_removefromsourcecontrol]

as

    set nocount on

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = ''VCSProjectID'')

    exec dbo.dt_droppropertiesbyid @iPropertyObjectId, null

    /* -1 is returned by dt_droppopertiesbyid */
    if @@error <> 0 and @@error <> -1 return 1

    return 0



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_validateloginparams]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create proc [dt_validateloginparams]
    @vchLoginName  varchar(255),
    @vchPassword   varchar(255)
as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId =0

declare @VSSGUID varchar(100)
select @VSSGUID = ''SQLVersionControl.VCS_SQL''

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = ''VCSProjectID'')

    declare @vchSourceSafeINI varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSSourceSafeINI'', @vchSourceSafeINI OUT

    exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 GOTO E_OAError

    exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
											''ValidateLoginParams'',
											NULL,
											@sSourceSafeINI = @vchSourceSafeINI,
											@sLoginName = @vchLoginName,
											@sPassword = @vchPassword
    if @iReturn <> 0 GOTO E_OAError

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    GOTO CleanUp



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_whocheckedout]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create proc [dt_whocheckedout]
        @chObjectType  char(4),
        @vchObjectName varchar(255),
        @vchLoginName  varchar(255),
        @vchPassword   varchar(255)

as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId =0

declare @VSSGUID varchar(100)
select @VSSGUID = ''SQLVersionControl.VCS_SQL''

    declare @iPropertyObjectId int

    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = ''VCSProjectID'')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSProject'',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSSourceSafeINI'', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSSQLServer'',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, ''VCSSQLDatabase'',   @vchDatabaseName  OUT

    if @chObjectType = ''PROC''
    begin
        exec @iReturn = master.dbo.sp_OACreate @VSSGUID, @iObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        declare @vchReturnValue varchar(255)
        select @vchReturnValue = ''''

        exec @iReturn = master.dbo.sp_OAMethod @iObjectId,
												''WhoCheckedOut'',
												@vchReturnValue OUT,
												@sProjectName = @vchProjectName,
												@sSourceSafeINI = @vchSourceSafeINI,
												@sObjectName = @vchObjectName,
												@sServerName = @vchServerName,
												@sDatabaseName = @vchDatabaseName,
												@sLoginName = @vchLoginName,
												@sPassword = @vchPassword

        if @iReturn <> 0 GOTO E_OAError

        select @vchReturnValue

    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    GOTO CleanUp



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_checkinobject_u]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create proc [dt_checkinobject_u]
    @chObjectType  char(4),
    @vchObjectName nvarchar(255),
    @vchComment    nvarchar(255)='''',
    @vchLoginName  nvarchar(255),
    @vchPassword   nvarchar(255)='''',
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0,   /* 0 => AddFile, 1 => CheckIn */
    @txStream1     text = '''',  /* drop stream   */ /* There is a bug that if items are NULL they do not pass to OLE servers */
    @txStream2     text = '''',  /* create stream */
    @txStream3     text = ''''   /* grant stream  */

as	
	-- This procedure should no longer be called;  dt_checkinobject should be called instead.
	-- Calls are forwarded to dt_checkinobject to maintain backward compatibility.
	set nocount on
	exec dbo.dt_checkinobject
		@chObjectType,
		@vchObjectName,
		@vchComment,
		@vchLoginName,
		@vchPassword,
		@iVCSFlags,
		@iActionFlag,   
		@txStream1,		
		@txStream2,		
		@txStream3		



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_checkoutobject_u]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create proc [dt_checkoutobject_u]
    @chObjectType  char(4),
    @vchObjectName nvarchar(255),
    @vchComment    nvarchar(255),
    @vchLoginName  nvarchar(255),
    @vchPassword   nvarchar(255),
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0/* 0 => Checkout, 1 => GetLatest, 2 => UndoCheckOut */

as

	-- This procedure should no longer be called;  dt_checkoutobject should be called instead.
	-- Calls are forwarded to dt_checkoutobject to maintain backward compatibility.
	set nocount on
	exec dbo.dt_checkoutobject
		@chObjectType,  
		@vchObjectName, 
		@vchComment,    
		@vchLoginName,  
		@vchPassword,  
		@iVCSFlags,    
		@iActionFlag 



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_getpropertiesbyid_vcs_u]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create procedure [dt_getpropertiesbyid_vcs_u]
    @id       int,
    @property varchar(64),
    @value    nvarchar(255) = NULL OUT

as

    -- This procedure should no longer be called;  dt_getpropertiesbyid_vcsshould be called instead.
	-- Calls are forwarded to dt_getpropertiesbyid_vcs to maintain backward compatibility.
	set nocount on
    exec dbo.dt_getpropertiesbyid_vcs
		@id,
		@property,
		@value output


' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_isundersourcecontrol_u]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create proc [dt_isundersourcecontrol_u]
    @vchLoginName nvarchar(255) = '''',
    @vchPassword  nvarchar(255) = '''',
    @iWhoToo      int = 0 /* 0 => Just check project; 1 => get list of objs */

as
	-- This procedure should no longer be called;  dt_isundersourcecontrol should be called instead.
	-- Calls are forwarded to dt_isundersourcecontrol to maintain backward compatibility.
	set nocount on
	exec dbo.dt_isundersourcecontrol
		@vchLoginName,
		@vchPassword,
		@iWhoToo 



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_validateloginparams_u]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create proc [dt_validateloginparams_u]
    @vchLoginName  nvarchar(255),
    @vchPassword   nvarchar(255)
as

	-- This procedure should no longer be called;  dt_validateloginparams should be called instead.
	-- Calls are forwarded to dt_validateloginparams to maintain backward compatibility.
	set nocount on
	exec dbo.dt_validateloginparams
		@vchLoginName,
		@vchPassword 



' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dt_whocheckedout_u]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
create proc [dt_whocheckedout_u]
        @chObjectType  char(4),
        @vchObjectName nvarchar(255),
        @vchLoginName  nvarchar(255),
        @vchPassword   nvarchar(255)

as

	-- This procedure should no longer be called;  dt_whocheckedout should be called instead.
	-- Calls are forwarded to dt_whocheckedout to maintain backward compatibility.
	set nocount on
	exec dbo.dt_whocheckedout
		@chObjectType, 
		@vchObjectName,
		@vchLoginName, 
		@vchPassword  



' 
END
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Account_SetItemPurchaseLogByCash_FK1]') AND parent_object_id = OBJECT_ID(N'[SetItemPurchaseLogByCash]'))
ALTER TABLE [SetItemPurchaseLogByCash]  WITH CHECK ADD  CONSTRAINT [Account_SetItemPurchaseLogByCash_FK1] FOREIGN KEY([AID])
REFERENCES [Account] ([AID])
GO
ALTER TABLE [SetItemPurchaseLogByCash] CHECK CONSTRAINT [Account_SetItemPurchaseLogByCash_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[CashSetShop_SetItemPurchaseLogByCash_FK1]') AND parent_object_id = OBJECT_ID(N'[SetItemPurchaseLogByCash]'))
ALTER TABLE [SetItemPurchaseLogByCash]  WITH CHECK ADD  CONSTRAINT [CashSetShop_SetItemPurchaseLogByCash_FK1] FOREIGN KEY([CSSID])
REFERENCES [CashSetShop] ([CSSID])
GO
ALTER TABLE [SetItemPurchaseLogByCash] CHECK CONSTRAINT [CashSetShop_SetItemPurchaseLogByCash_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[FK__RentCashS__CSSID__48BAC3E5]') AND parent_object_id = OBJECT_ID(N'[RentCashSetShopPrice]'))
ALTER TABLE [RentCashSetShopPrice]  WITH CHECK ADD FOREIGN KEY([CSSID])
REFERENCES [CashSetShop] ([CSSID])
ON UPDATE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[CashSetShop_CashSetItem_FK1]') AND parent_object_id = OBJECT_ID(N'[CashSetItem]'))
ALTER TABLE [CashSetItem]  WITH CHECK ADD  CONSTRAINT [CashSetShop_CashSetItem_FK1] FOREIGN KEY([CSSID])
REFERENCES [CashSetShop] ([CSSID])
GO
ALTER TABLE [CashSetItem] CHECK CONSTRAINT [CashSetShop_CashSetItem_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Item_CashSetItem_FK1]') AND parent_object_id = OBJECT_ID(N'[CashSetItem]'))
ALTER TABLE [CashSetItem]  WITH CHECK ADD  CONSTRAINT [Item_CashSetItem_FK1] FOREIGN KEY([CSID])
REFERENCES [CashShop] ([CSID])
GO
ALTER TABLE [CashSetItem] CHECK CONSTRAINT [Item_CashSetItem_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Account_CashItemPresentLog_FK1]') AND parent_object_id = OBJECT_ID(N'[CashItemPresentLog]'))
ALTER TABLE [CashItemPresentLog]  WITH CHECK ADD  CONSTRAINT [Account_CashItemPresentLog_FK1] FOREIGN KEY([ReceiverAID])
REFERENCES [Account] ([AID])
GO
ALTER TABLE [CashItemPresentLog] CHECK CONSTRAINT [Account_CashItemPresentLog_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Account_BringAccountItemLog_FK1]') AND parent_object_id = OBJECT_ID(N'[BringAccountItemLog]'))
ALTER TABLE [BringAccountItemLog]  WITH CHECK ADD  CONSTRAINT [Account_BringAccountItemLog_FK1] FOREIGN KEY([AID])
REFERENCES [Account] ([AID])
GO
ALTER TABLE [BringAccountItemLog] CHECK CONSTRAINT [Account_BringAccountItemLog_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Character_BringAccountItemLog_FK1]') AND parent_object_id = OBJECT_ID(N'[BringAccountItemLog]'))
ALTER TABLE [BringAccountItemLog]  WITH CHECK ADD  CONSTRAINT [Character_BringAccountItemLog_FK1] FOREIGN KEY([CID])
REFERENCES [Character] ([CID])
GO
ALTER TABLE [BringAccountItemLog] CHECK CONSTRAINT [Character_BringAccountItemLog_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Item_BringAccountItemLog_FK1]') AND parent_object_id = OBJECT_ID(N'[BringAccountItemLog]'))
ALTER TABLE [BringAccountItemLog]  WITH CHECK ADD  CONSTRAINT [Item_BringAccountItemLog_FK1] FOREIGN KEY([ItemID])
REFERENCES [Item] ([ItemID])
GO
ALTER TABLE [BringAccountItemLog] CHECK CONSTRAINT [Item_BringAccountItemLog_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[AccountPenaltyPeriod_Account_FK1]') AND parent_object_id = OBJECT_ID(N'[AccountPenaltyPeriod]'))
ALTER TABLE [AccountPenaltyPeriod]  WITH CHECK ADD  CONSTRAINT [AccountPenaltyPeriod_Account_FK1] FOREIGN KEY([AID])
REFERENCES [Account] ([AID])
GO
ALTER TABLE [AccountPenaltyPeriod] CHECK CONSTRAINT [AccountPenaltyPeriod_Account_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Account_Table1_FK1]') AND parent_object_id = OBJECT_ID(N'[AccountItem]'))
ALTER TABLE [AccountItem]  WITH CHECK ADD  CONSTRAINT [Account_Table1_FK1] FOREIGN KEY([AID])
REFERENCES [Account] ([AID])
GO
ALTER TABLE [AccountItem] CHECK CONSTRAINT [Account_Table1_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Item_Table1_FK1]') AND parent_object_id = OBJECT_ID(N'[AccountItem]'))
ALTER TABLE [AccountItem]  WITH CHECK ADD  CONSTRAINT [Item_Table1_FK1] FOREIGN KEY([ItemID])
REFERENCES [Item] ([ItemID])
GO
ALTER TABLE [AccountItem] CHECK CONSTRAINT [Item_Table1_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Account_Character_FK1]') AND parent_object_id = OBJECT_ID(N'[Character]'))
ALTER TABLE [Character]  WITH CHECK ADD  CONSTRAINT [Account_Character_FK1] FOREIGN KEY([AID])
REFERENCES [Account] ([AID])
GO
ALTER TABLE [Character] CHECK CONSTRAINT [Account_Character_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Account_PurchaseLogByCash_FK1]') AND parent_object_id = OBJECT_ID(N'[ItemPurchaseLogByCash]'))
ALTER TABLE [ItemPurchaseLogByCash]  WITH CHECK ADD  CONSTRAINT [Account_PurchaseLogByCash_FK1] FOREIGN KEY([AID])
REFERENCES [Account] ([AID])
GO
ALTER TABLE [ItemPurchaseLogByCash] CHECK CONSTRAINT [Account_PurchaseLogByCash_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Item_PurchaseLogByCash_FK1]') AND parent_object_id = OBJECT_ID(N'[ItemPurchaseLogByCash]'))
ALTER TABLE [ItemPurchaseLogByCash]  WITH CHECK ADD  CONSTRAINT [Item_PurchaseLogByCash_FK1] FOREIGN KEY([ItemID])
REFERENCES [Item] ([ItemID])
GO
ALTER TABLE [ItemPurchaseLogByCash] CHECK CONSTRAINT [Item_PurchaseLogByCash_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[FK__Character__CharM__3A6CA48E]') AND parent_object_id = OBJECT_ID(N'[CharacterMgrLogByGM]'))
ALTER TABLE [CharacterMgrLogByGM]  WITH CHECK ADD FOREIGN KEY([CharMgrTypeID])
REFERENCES [CharacterMgrType] ([CharMgrTypeID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[FK__CharacterMg__CID__3B60C8C7]') AND parent_object_id = OBJECT_ID(N'[CharacterMgrLogByGM]'))
ALTER TABLE [CharacterMgrLogByGM]  WITH CHECK ADD FOREIGN KEY([CID])
REFERENCES [Character] ([CID])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[ClanGameLog_LoserCLID_FK1]') AND parent_object_id = OBJECT_ID(N'[ClanGameLog]'))
ALTER TABLE [ClanGameLog]  WITH CHECK ADD  CONSTRAINT [ClanGameLog_LoserCLID_FK1] FOREIGN KEY([LoserCLID])
REFERENCES [Clan] ([CLID])
GO
ALTER TABLE [ClanGameLog] CHECK CONSTRAINT [ClanGameLog_LoserCLID_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[ClanGameLog_WinnerCLID_FK1]') AND parent_object_id = OBJECT_ID(N'[ClanGameLog]'))
ALTER TABLE [ClanGameLog]  WITH CHECK ADD  CONSTRAINT [ClanGameLog_WinnerCLID_FK1] FOREIGN KEY([WinnerCLID])
REFERENCES [Clan] ([CLID])
GO
ALTER TABLE [ClanGameLog] CHECK CONSTRAINT [ClanGameLog_WinnerCLID_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[ClanHonorRanking_CLID_FK1]') AND parent_object_id = OBJECT_ID(N'[ClanHonorRanking]'))
ALTER TABLE [ClanHonorRanking]  WITH CHECK ADD  CONSTRAINT [ClanHonorRanking_CLID_FK1] FOREIGN KEY([CLID])
REFERENCES [Clan] ([CLID])
GO
ALTER TABLE [ClanHonorRanking] CHECK CONSTRAINT [ClanHonorRanking_CLID_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[ClanMember_Clan_FK1]') AND parent_object_id = OBJECT_ID(N'[ClanMember]'))
ALTER TABLE [ClanMember]  WITH CHECK ADD  CONSTRAINT [ClanMember_Clan_FK1] FOREIGN KEY([CLID])
REFERENCES [Clan] ([CLID])
GO
ALTER TABLE [ClanMember] CHECK CONSTRAINT [ClanMember_Clan_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[ClanMember_Clan_FK2]') AND parent_object_id = OBJECT_ID(N'[ClanMember]'))
ALTER TABLE [ClanMember]  WITH CHECK ADD  CONSTRAINT [ClanMember_Clan_FK2] FOREIGN KEY([CID])
REFERENCES [Character] ([CID])
GO
ALTER TABLE [ClanMember] CHECK CONSTRAINT [ClanMember_Clan_FK2]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Effect_Item_FK1]') AND parent_object_id = OBJECT_ID(N'[Item]'))
ALTER TABLE [Item]  WITH CHECK ADD  CONSTRAINT [Effect_Item_FK1] FOREIGN KEY([EffectID])
REFERENCES [Effect] ([ID])
GO
ALTER TABLE [Item] CHECK CONSTRAINT [Effect_Item_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Character_PurchaseItemByBountyHistory_FK20050314]') AND parent_object_id = OBJECT_ID(N'[ItemPurchaseLogByBounty]'))
ALTER TABLE [ItemPurchaseLogByBounty]  WITH CHECK ADD  CONSTRAINT [Character_PurchaseItemByBountyHistory_FK20050314] FOREIGN KEY([CID])
REFERENCES [Character] ([CID])
GO
ALTER TABLE [ItemPurchaseLogByBounty] CHECK CONSTRAINT [Character_PurchaseItemByBountyHistory_FK20050314]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Item_PurchaseItemByBountyHistory_FK20050314]') AND parent_object_id = OBJECT_ID(N'[ItemPurchaseLogByBounty]'))
ALTER TABLE [ItemPurchaseLogByBounty]  WITH CHECK ADD  CONSTRAINT [Item_PurchaseItemByBountyHistory_FK20050314] FOREIGN KEY([ItemID])
REFERENCES [Item] ([ItemID])
GO
ALTER TABLE [ItemPurchaseLogByBounty] CHECK CONSTRAINT [Item_PurchaseItemByBountyHistory_FK20050314]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Item_CashShop_FK1]') AND parent_object_id = OBJECT_ID(N'[CashShop]'))
ALTER TABLE [CashShop]  WITH CHECK ADD  CONSTRAINT [Item_CashShop_FK1] FOREIGN KEY([ItemID])
REFERENCES [Item] ([ItemID])
GO
ALTER TABLE [CashShop] CHECK CONSTRAINT [Item_CashShop_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[FK__RentCashSh__CSID__49AEE81E]') AND parent_object_id = OBJECT_ID(N'[RentCashShopPrice]'))
ALTER TABLE [RentCashShopPrice]  WITH CHECK ADD FOREIGN KEY([CSID])
REFERENCES [CashShop] ([CSID])
ON UPDATE CASCADE
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Character_Friend_FK1]') AND parent_object_id = OBJECT_ID(N'[Friend]'))
ALTER TABLE [Friend]  WITH CHECK ADD  CONSTRAINT [Character_Friend_FK1] FOREIGN KEY([CID])
REFERENCES [Character] ([CID])
GO
ALTER TABLE [Friend] CHECK CONSTRAINT [Character_Friend_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Character_Friend_FK2]') AND parent_object_id = OBJECT_ID(N'[Friend]'))
ALTER TABLE [Friend]  WITH CHECK ADD  CONSTRAINT [Character_Friend_FK2] FOREIGN KEY([FriendCID])
REFERENCES [Character] ([CID])
GO
ALTER TABLE [Friend] CHECK CONSTRAINT [Character_Friend_FK2]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Character_CharacterItem_FK1]') AND parent_object_id = OBJECT_ID(N'[CharacterItem]'))
ALTER TABLE [CharacterItem]  WITH CHECK ADD  CONSTRAINT [Character_CharacterItem_FK1] FOREIGN KEY([CID])
REFERENCES [Character] ([CID])
GO
ALTER TABLE [CharacterItem] CHECK CONSTRAINT [Character_CharacterItem_FK1]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[Clan_Character_FK1]') AND parent_object_id = OBJECT_ID(N'[Clan]'))
ALTER TABLE [Clan]  WITH CHECK ADD  CONSTRAINT [Clan_Character_FK1] FOREIGN KEY([MasterCID])
REFERENCES [Character] ([CID])
GO
ALTER TABLE [Clan] CHECK CONSTRAINT [Clan_Character_FK1]
USE [GunzDB]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[Item_PurchaseItemByBountyHistory_FK20050314]') AND parent_object_id = OBJECT_ID(N'[dbo].[ItemPurchaseLogByBounty]'))
ALTER TABLE [dbo].[ItemPurchaseLogByBounty] DROP CONSTRAINT [Item_PurchaseItemByBountyHistory_FK20050314]
GO