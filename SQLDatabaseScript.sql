USE [master]
GO
/****** Object:  Database [TextCenterShare]    Script Date: 10/11/2020 1:58:36 PM ******/
CREATE DATABASE [TextCenterShare]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'TextCenterShare', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\TextCenterShare.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'TextCenterShare_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\TextCenterShare_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO
ALTER DATABASE [TextCenterShare] SET COMPATIBILITY_LEVEL = 150
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [TextCenterShare].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [TextCenterShare] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [TextCenterShare] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [TextCenterShare] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [TextCenterShare] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [TextCenterShare] SET ARITHABORT OFF 
GO
ALTER DATABASE [TextCenterShare] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [TextCenterShare] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [TextCenterShare] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [TextCenterShare] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [TextCenterShare] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [TextCenterShare] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [TextCenterShare] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [TextCenterShare] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [TextCenterShare] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [TextCenterShare] SET  DISABLE_BROKER 
GO
ALTER DATABASE [TextCenterShare] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [TextCenterShare] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [TextCenterShare] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [TextCenterShare] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [TextCenterShare] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [TextCenterShare] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [TextCenterShare] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [TextCenterShare] SET RECOVERY FULL 
GO
ALTER DATABASE [TextCenterShare] SET  MULTI_USER 
GO
ALTER DATABASE [TextCenterShare] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [TextCenterShare] SET DB_CHAINING OFF 
GO
ALTER DATABASE [TextCenterShare] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [TextCenterShare] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [TextCenterShare] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'TextCenterShare', N'ON'
GO
ALTER DATABASE [TextCenterShare] SET QUERY_STORE = OFF
GO
USE [TextCenterShare]
GO
/****** Object:  User [THM]    Script Date: 10/11/2020 1:58:36 PM ******/
CREATE USER [THM] FOR LOGIN [THM] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [TextCenterShare]    Script Date: 10/11/2020 1:58:36 PM ******/
CREATE USER [TextCenterShare] FOR LOGIN [TextCenterShare] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [THM]
GO
ALTER ROLE [db_accessadmin] ADD MEMBER [THM]
GO
ALTER ROLE [db_securityadmin] ADD MEMBER [THM]
GO
ALTER ROLE [db_ddladmin] ADD MEMBER [THM]
GO
ALTER ROLE [db_backupoperator] ADD MEMBER [THM]
GO
ALTER ROLE [db_datareader] ADD MEMBER [THM]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [THM]
GO
ALTER ROLE [db_owner] ADD MEMBER [TextCenterShare]
GO
/****** Object:  Table [dbo].[Person]    Script Date: 10/11/2020 1:58:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Person](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[DynamicData] [nvarchar](max) NULL,
 CONSTRAINT [PK_Person] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[GetPersons]    Script Date: 10/11/2020 1:58:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- [dbo].[GetPersons]
CREATE PROCEDURE  [dbo].[GetPersons]
AS
DECLARE @Json nvarchar(MAX)
SET @Json = 
( SELECT 
  Id,
  FirstName,
  LastName,
  JSON_QUERY( DynamicData) DynamicData
  FROM Person FOR JSON PATH
)
SELECT @Json
GO
/****** Object:  StoredProcedure [dbo].[InsertUpdatePersons]    Script Date: 10/11/2020 1:58:36 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[InsertUpdatePersons]
 @JsonData nvarchar(MAX)
AS

MERGE Person AS target
Using(
	SELECT
	*
	FROM   OPENJSON(@JsonData) WITH
	(
	   Id nvarchar(50) '$.Id',
	   FirstName nvarchar(50) '$.FirstName',
	   LastName nvarchar(50) '$.LastName',
	   DynamicData nvarchar(MAX) '$.DynamicData' AS JSON
	) 
) AS source 
  (Id,FirstName,LastName,DynamicData) ON (target.Id = source.Id)
 WHEN MATCHED THEN
        UPDATE SET FirstName = source.FirstName, 
		           LastName = source.LastName,  
				   DynamicData = source.DynamicData
  WHEN NOT MATCHED THEN  
        INSERT (FirstName,LastName,DynamicData)  
        VALUES (FirstName,LastName,DynamicData);
GO
USE [master]
GO
ALTER DATABASE [TextCenterShare] SET  READ_WRITE 
GO
