USE [master]
GO
/****** Object:  Database [InsuranceServicesDB]    Script Date: 12.12.2019 16:00:40 ******/
CREATE DATABASE [InsuranceServicesDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'InsuranceServicesDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\InsuranceServicesDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'InsuranceServicesDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\InsuranceServicesDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [InsuranceServicesDB] SET COMPATIBILITY_LEVEL = 140
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [InsuranceServicesDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [InsuranceServicesDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [InsuranceServicesDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [InsuranceServicesDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [InsuranceServicesDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [InsuranceServicesDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [InsuranceServicesDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [InsuranceServicesDB] SET  MULTI_USER 
GO
ALTER DATABASE [InsuranceServicesDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [InsuranceServicesDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [InsuranceServicesDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [InsuranceServicesDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [InsuranceServicesDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [InsuranceServicesDB] SET QUERY_STORE = OFF
GO
USE [InsuranceServicesDB]
GO
/****** Object:  Schema [Customer]    Script Date: 12.12.2019 16:00:41 ******/
CREATE SCHEMA [Customer]
GO
/****** Object:  Schema [Insurance]    Script Date: 12.12.2019 16:00:41 ******/
CREATE SCHEMA [Insurance]
GO
/****** Object:  Schema [Log]    Script Date: 12.12.2019 16:00:41 ******/
CREATE SCHEMA [Log]
GO
/****** Object:  UserDefinedFunction [Customer].[Account_table]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Fonksiyonlar

--1 There is a raise for insurance types with less than the specified price

CREATE FUNCTION [Customer].[Account_table] (@Price MONEY)
RETURNS @Temporary_Account TABLE(InsuranceType nvarchar(50), Price MONEY,New_Price MONEY) 
AS
BEGIN
	INSERT INTO @Temporary_Account (InsuranceType, Price, New_Price) 
	SELECT InsuranceType.Type, InsuranceType.Price, InsuranceType.Price
	FROM Insurance.InsuranceType WHERE Price<@Price 
	UPDATE @Temporary_Account SET New_Price=New_Price*1.50 
	RETURN 	
END
GO
/****** Object:  UserDefinedFunction [Customer].[FindAge]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create function [Customer].[FindAge]
(
@BOD date
)
returns tinyint
as
   begin
     return Year(getdate())- year(@BOD)
   end
GO
/****** Object:  UserDefinedFunction [Customer].[FindName]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [Customer].[FindName] (@id INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
DECLARE @name VARCHAR(MAX)
SET @name=(SELECT C.CustomerName FROM Customer.Customer as C WHERE C.CustomerID=@id)
RETURN @name
END
GO
/****** Object:  UserDefinedFunction [Customer].[Raise_StaffSalary_ByWorkYear]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create Function [Customer].[Raise_StaffSalary_ByWorkYear] (@staffid int)
RETURNS @SalaryInfo TABLE 
(
    WorkYear int PRIMARY KEY NOT NULL, 
    OldSalary money NULL, 
    NewSalary money NULL
)
as
begin
declare @RaiceDiscount int
declare @WorkYear int
declare @OldSalary money
declare @UpdatedSalary money

select @WorkYear = (YEAR(GETDATE()) - isnull(Year(JoiningYear),2014)) , @OldSalary = Salary from Customer.Staff where StaffID = @staffid

if (@WorkYear > 1 and @WorkYear <= 5)
begin
select @RaiceDiscount = 5
end
else if(@WorkYear > 5 and @WorkYear <= 10)
begin
select @RaiceDiscount = 10
end
else if(@WorkYear > 10)
begin
select @RaiceDiscount = 15
end


select  @UpdatedSalary = @OldSalary + ((@OldSalary * @RaiceDiscount) / 100)

 INSERT @SalaryInfo
 SELECT @WorkYear, @OldSalary, @UpdatedSalary;
return; 
end
GO
/****** Object:  UserDefinedFunction [dbo].[FindAge]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--3 elle girilen doğum yılını yaşa çeviriyo (Saçma alakasız)
create function [dbo].[FindAge]
(
@BOD date
)
returns tinyint
as
   begin
     return Year(getdate())- year(@BOD)
   end
GO
/****** Object:  UserDefinedFunction [dbo].[Raise_StaffSalary_ByWorkYear]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--5 çalışan id gönder geriye zam dön 1-5 yıl arasındaki %5 5-10 yıl arasındakilere %10 üstüne %15 
Create Function [dbo].[Raise_StaffSalary_ByWorkYear] (@staffid int)
RETURNS @SalaryInfo TABLE 
(
    WorkYear int PRIMARY KEY NOT NULL, 
    OldSalary money NULL, 
    NewSalary money NULL
)
as
begin
declare @RaiceDiscount int
declare @WorkYear int
declare @OldSalary money
declare @UpdatedSalary money

select @WorkYear = (YEAR(GETDATE()) - isnull(Year(JoiningYear),2014)) , @OldSalary = Salary from Customer.Staff where StaffID = @staffid

if (@WorkYear > 1 and @WorkYear <= 5)
begin
select @RaiceDiscount = 5
end
else if(@WorkYear > 5 and @WorkYear <= 10)
begin
select @RaiceDiscount = 10
end
else if(@WorkYear > 10)
begin
select @RaiceDiscount = 15
end


select  @UpdatedSalary = @OldSalary + ((@OldSalary * @RaiceDiscount) / 100)

 INSERT @SalaryInfo
 SELECT @WorkYear, @OldSalary, @UpdatedSalary;
return; 
end


GO
/****** Object:  UserDefinedFunction [Insurance].[Account_table]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Insurance].[Account_table] (@Price MONEY)
RETURNS @Temporary_Account TABLE(InsuranceType nvarchar(50), Price MONEY,New_Price MONEY) 
AS
BEGIN
	INSERT INTO @Temporary_Account (InsuranceType, Price, New_Price) 
	SELECT InsuranceType.Type, InsuranceType.Price, InsuranceType.Price
	FROM Insurance.InsuranceType WHERE Price<@Price 
	UPDATE @Temporary_Account SET New_Price=New_Price*1.50 
	RETURN 	
END
GO
/****** Object:  Table [Insurance].[InsuranceType]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insurance].[InsuranceType](
	[InsuranceTypeID] [int] IDENTITY(1,1) NOT NULL,
	[Type] [nvarchar](150) NULL,
	[Price] [money] NULL,
	[Description] [nvarchar](max) NULL,
	[RegenerationTime] [tinyint] NULL,
 CONSTRAINT [PK_InsuranceType] PRIMARY KEY CLUSTERED 
(
	[InsuranceTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [Insurance].[fn_Interval]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [Insurance].[fn_Interval]
(@Price MONEY)
RETURNS TABLE
AS
RETURN(SELECT * FROM Insurance.InsuranceType WHERE Price<@Price) 
GO
/****** Object:  Table [Insurance].[Vehicle]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insurance].[Vehicle](
	[VehicleID] [int] IDENTITY(1,1) NOT NULL,
	[Model] [nvarchar](50) NULL,
	[Year] [date] NULL,
	[LicencePlate] [nvarchar](50) NULL,
	[Color] [nvarchar](20) NULL,
 CONSTRAINT [PK_Vehicle] PRIMARY KEY CLUSTERED 
(
	[VehicleID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Insurance].[InsuranceDetail]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insurance].[InsuranceDetail](
	[InsuranceDetailID] [int] IDENTITY(1,1) NOT NULL,
	[InsuranceTypeID] [int] NOT NULL,
	[CreateDate] [date] NULL,
	[VehicleID] [int] NULL,
	[HousingID] [int] NULL,
	[InsuranceID] [int] NULL,
	[Price] [money] NULL,
 CONSTRAINT [PK_InsuranceDetail] PRIMARY KEY CLUSTERED 
(
	[InsuranceDetailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Insurance].[Top_Model_Vehicle]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Insurance].[Top_Model_Vehicle]
as
SELECT TOP 1 Model, SUM(InsuranceDetailID) as ToplamMiktar FROM Insurance.Vehicle as V left Join Insurance.InsuranceDetail as ID
on V.VehicleID=ID.VehicleID
GROUP BY Model ORDER BY SUM(InsuranceDetailID) DESC
GO
/****** Object:  Table [Customer].[Staff]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Customer].[Staff](
	[StaffID] [int] IDENTITY(1,1) NOT NULL,
	[StaffName] [nvarchar](20) NULL,
	[StaffSurname] [nvarchar](50) NULL,
	[DateOfBirth] [date] NULL,
	[Gender] [nvarchar](10) NULL,
	[Role] [nvarchar](50) NULL,
	[Nationality] [nvarchar](50) NULL,
	[Salary] [smallmoney] NULL,
	[StaffContactID] [int] NULL,
	[CompanyID] [int] NULL,
	[UserName] [nvarchar](50) NULL,
	[Password] [nvarchar](50) NULL,
	[image] [nvarchar](255) NULL,
	[JoiningYear] [date] NULL,
 CONSTRAINT [PK_Staff] PRIMARY KEY CLUSTERED 
(
	[StaffID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Insurance].[StaffSalayTop]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Insurance].[StaffSalayTop]
as
SELECT TOP 1 * FROM Customer.Staff ORDER BY Salary desc
GO
/****** Object:  Table [Customer].[Company]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Customer].[Company](
	[CompanyID] [int] IDENTITY(1,1) NOT NULL,
	[FoundationYear] [int] NULL,
	[CompanyName] [nvarchar](50) NULL,
	[ProvinceID] [int] NULL,
 CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED 
(
	[CompanyID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Insurance].[Insurance]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insurance].[Insurance](
	[InsuranceID] [int] IDENTITY(1,1) NOT NULL,
	[StaffID] [int] NOT NULL,
	[CustomerID] [int] NULL,
	[InsuranceDate] [date] NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
 CONSTRAINT [PK_Insurance] PRIMARY KEY CLUSTERED 
(
	[InsuranceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Customer].[Staff_Information]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Customer].[Staff_Information]
 as
 select StaffName,StaffSurname,Gender,DateOfBirth,Role,CompanyName,
 (select  count (InsuranceID) from Insurance.Insurance as I where S.StaffID=I.StaffID  ) as Insurance_Count
 from Customer.Staff as S 
 right outer join Customer.Company as C on S.CompanyID=C.CompanyID
GO
/****** Object:  Table [Customer].[CustomerContact]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Customer].[CustomerContact](
	[CustomerContactID] [int] IDENTITY(1,1) NOT NULL,
	[Email] [nvarchar](50) NULL,
	[Phone] [nchar](11) NULL,
	[Address] [nvarchar](150) NULL,
	[ProvinceID] [int] NULL,
 CONSTRAINT [PK_CustomerContact] PRIMARY KEY CLUSTERED 
(
	[CustomerContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Customer].[Customer]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Customer].[Customer](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerName] [nvarchar](50) NULL,
	[CustomerSurname] [nvarchar](50) NULL,
	[DateOfBirth] [date] NULL,
	[Gender] [nvarchar](10) NULL,
	[CustomerContactID] [int] NULL,
	[StaffID] [int] NULL,
	[InsuranceTypeID] [int] NULL,
	[CreateDate] [date] NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Customer].[ShowCustomerInfo]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create view [Customer].[ShowCustomerInfo]
as
select CustomerID,(CustomerName+' '+CustomerSurname) AS Customer,
Email,Phone,Address,(StaffName+' '+StaffSurname)as Staff
from Customer.Customer as C INNER JOIN Customer.CustomerContact as CC on  C.CustomerContactID=CC.CustomerContactID
INNER JOIN Customer.Staff as S
on S.StaffID=C.StaffID;
GO
/****** Object:  Table [Customer].[Province]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Customer].[Province](
	[ProvinceID] [int] IDENTITY(1,1) NOT NULL,
	[ProvinceName] [nvarchar](50) NULL,
	[IncreasePercentage] [int] NULL,
 CONSTRAINT [PK_Province] PRIMARY KEY CLUSTERED 
(
	[ProvinceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Customer].[Province_Sum_Price]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Customer].[Province_Sum_Price]
  as
  select sum(Price) as 'Sum of Price' ,ProvinceName from Insurance.InsuranceType as IT
  inner  join Customer.Customer as C on IT.InsuranceTypeID=C.InsuranceTypeID
  inner  join Customer.CustomerContact as CC on C.CustomerContactID = CC.CustomerContactID
  inner  join Customer.Province as P 
  on CC.ProvinceID =P.ProvinceID 
  group by P.ProvinceName 
GO
/****** Object:  View [Customer].[Customer_Total_Insurance]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 CREATE view [Customer].[Customer_Total_Insurance]
 as
 select CustomerName,CustomerSurname,C.Gender, C.DateOfBirth,StaffName,StaffSurname,
 (select count(InsuranceTypeID) from Insurance.InsuranceType as IT where C.InsuranceTypeID=IT.InsuranceTypeID ) as CountInsurance
 from Customer.Customer as C
 inner join Customer.Staff as S on C.StaffID=S.StaffID
GO
/****** Object:  Table [Customer].[StaffContact]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Customer].[StaffContact](
	[StaffContactID] [int] IDENTITY(1,1) NOT NULL,
	[Email] [nvarchar](50) NULL,
	[Phone] [nchar](11) NULL,
	[Address] [nvarchar](80) NULL,
	[ProvinceID] [int] NULL,
 CONSTRAINT [PK_StaffContact] PRIMARY KEY CLUSTERED 
(
	[StaffContactID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [Customer].[Company_Staff_Count]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [Customer].[Company_Staff_Count]
as
select Count (StaffID) as CountStaff ,P.ProvinceName, C.CompanyName 
from Customer.Staff as S inner  join Customer.StaffContact as SC on S.StaffContactID = SC.StaffContactID
left outer join Customer.Province as P on SC.ProvinceID= P.ProvinceID 
left outer join Customer.Company as C on S.CompanyID=C.CompanyID
group by C.CompanyName , P.ProvinceName
GO
/****** Object:  View [Customer].[Customer_InsuranceCount_By_Year]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create View [Customer].[Customer_InsuranceCount_By_Year]
as
select  isnull(YEAR(INS.InsuranceDate),2019) as 'Year', CU.CustomerID,CU.CustomerName,Count(INS.InsuranceID) As 'Insurance Count',Sum(INSD.Price) as 'Total Price' 
from Insurance.Insurance INS
left join Customer.Customer CU on CU.CustomerID = INS.CustomerID
left join Insurance.InsuranceDetail INSD on INSD.InsuranceID = INS.InsuranceID
GROUP BY isnull(YEAR(INS.InsuranceDate),2019) , CU.CustomerID,CU.CustomerName
GO
/****** Object:  View [Insurance].[Company_InsuranceCount_By_Year]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create View [Insurance].[Company_InsuranceCount_By_Year]
as
select  isnull(YEAR(INS.InsuranceDate),2019) as 'Year',CO.CompanyName,COUNT(INS.InsuranceID) AS 'Insurance Count'
from Insurance.Insurance INS
left join Customer.Staff ST on ST.StaffID = INS.StaffID
left join Customer.Company CO on CO.CompanyID = ST.CompanyID
group by isnull(YEAR(INS.InsuranceDate),2019) ,CO.CompanyID,CO.CompanyName
GO
/****** Object:  View [Customer].[Customer_Top3_PayedCustomer]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create View [Customer].[Customer_Top3_PayedCustomer]
as
select top 3 CU.CustomerID,CU.CustomerName,Sum(INSD.Price) as 'Total Price' from Insurance.Insurance INS
left join Customer.Customer CU on CU.CustomerID = INS.CustomerID
left join Insurance.InsuranceDetail INSD on INSD.InsuranceID = INS.InsuranceID
GROUP BY CU.CustomerID,CU.CustomerName
order by Sum(INSD.Price) desc
GO
/****** Object:  UserDefinedFunction [dbo].[fn_Interval]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--2 price verilen fiyattan az olan insurance tipleri geliyor view olmalı sanırsam

CREATE FUNCTION [dbo].[fn_Interval]
(@Price MONEY)
RETURNS TABLE
AS
RETURN(SELECT * FROM Insurance.InsuranceType WHERE Price<@Price) 
GO
/****** Object:  Table [Customer].[CustomerInsurance]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Customer].[CustomerInsurance](
	[CustomerInsuranceID] [int] IDENTITY(1,1) NOT NULL,
	[InsuranceID] [int] NOT NULL,
	[CustomerID] [int] NULL,
 CONSTRAINT [PK_CustomerInsurance] PRIMARY KEY CLUSTERED 
(
	[CustomerInsuranceID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Insurance].[Housing]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Insurance].[Housing](
	[HousingID] [int] IDENTITY(1,1) NOT NULL,
	[Model] [nvarchar](50) NULL,
	[Year] [int] NULL,
	[Area] [int] NULL,
 CONSTRAINT [PK_Housing] PRIMARY KEY CLUSTERED 
(
	[HousingID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [Log].[Log]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Log].[Log](
	[LogID] [int] IDENTITY(1,1) NOT NULL,
	[LogTable] [nvarchar](50) NULL,
	[StaffID] [int] NULL,
	[LogDate] [date] NULL,
	[LogProcedure] [nvarchar](50) NULL,
 CONSTRAINT [PK_Log] PRIMARY KEY CLUSTERED 
(
	[LogID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [Customer].[Company] ON 

INSERT [Customer].[Company] ([CompanyID], [FoundationYear], [CompanyName], [ProvinceID]) VALUES (10, 1980, N'Axa Insurance', 14)
INSERT [Customer].[Company] ([CompanyID], [FoundationYear], [CompanyName], [ProvinceID]) VALUES (11, 1985, N'Allianz Insurance', 14)
INSERT [Customer].[Company] ([CompanyID], [FoundationYear], [CompanyName], [ProvinceID]) VALUES (12, 1998, N'Güneş Insurance', 15)
INSERT [Customer].[Company] ([CompanyID], [FoundationYear], [CompanyName], [ProvinceID]) VALUES (13, 2000, N'Halk Insurance', 15)
INSERT [Customer].[Company] ([CompanyID], [FoundationYear], [CompanyName], [ProvinceID]) VALUES (14, 2005, N'BNP Insurance', 17)
INSERT [Customer].[Company] ([CompanyID], [FoundationYear], [CompanyName], [ProvinceID]) VALUES (15, 1980, N'Anadolu Hayat Pension', 17)
INSERT [Customer].[Company] ([CompanyID], [FoundationYear], [CompanyName], [ProvinceID]) VALUES (16, 1998, N'Ak Insurance', 14)
INSERT [Customer].[Company] ([CompanyID], [FoundationYear], [CompanyName], [ProvinceID]) VALUES (17, 1980, N'Merkez Insurance', 15)
INSERT [Customer].[Company] ([CompanyID], [FoundationYear], [CompanyName], [ProvinceID]) VALUES (18, 2000, N'SBN Insurance', 22)
SET IDENTITY_INSERT [Customer].[Company] OFF
SET IDENTITY_INSERT [Customer].[Customer] ON 

INSERT [Customer].[Customer] ([CustomerID], [CustomerName], [CustomerSurname], [DateOfBirth], [Gender], [CustomerContactID], [StaffID], [InsuranceTypeID], [CreateDate]) VALUES (24, N'Zeynep', N'Günay', CAST(N'1998-05-04' AS Date), N'Female', 15, 30, 9, CAST(N'2016-04-16' AS Date))
INSERT [Customer].[Customer] ([CustomerID], [CustomerName], [CustomerSurname], [DateOfBirth], [Gender], [CustomerContactID], [StaffID], [InsuranceTypeID], [CreateDate]) VALUES (25, N'Ezgi', N'Sarı', CAST(N'1993-11-24' AS Date), N'Female', 16, 33, 14, CAST(N'2016-04-21' AS Date))
INSERT [Customer].[Customer] ([CustomerID], [CustomerName], [CustomerSurname], [DateOfBirth], [Gender], [CustomerContactID], [StaffID], [InsuranceTypeID], [CreateDate]) VALUES (26, N'Metin', N'Koç', CAST(N'1990-01-12' AS Date), N'Male', 18, 30, 15, CAST(N'2010-08-25' AS Date))
INSERT [Customer].[Customer] ([CustomerID], [CustomerName], [CustomerSurname], [DateOfBirth], [Gender], [CustomerContactID], [StaffID], [InsuranceTypeID], [CreateDate]) VALUES (27, N'Aslı', N'Tanyeri', CAST(N'1996-12-12' AS Date), N'Female', 17, 31, 9, CAST(N'2018-08-14' AS Date))
INSERT [Customer].[Customer] ([CustomerID], [CustomerName], [CustomerSurname], [DateOfBirth], [Gender], [CustomerContactID], [StaffID], [InsuranceTypeID], [CreateDate]) VALUES (28, N'Emre', N'Bolat', CAST(N'2000-02-12' AS Date), N'Male', 19, 33, 11, CAST(N'2019-08-14' AS Date))
INSERT [Customer].[Customer] ([CustomerID], [CustomerName], [CustomerSurname], [DateOfBirth], [Gender], [CustomerContactID], [StaffID], [InsuranceTypeID], [CreateDate]) VALUES (29, N'Piyer', N'İş', CAST(N'1991-05-14' AS Date), N'Male', 20, 26, 11, CAST(N'2002-06-14' AS Date))
INSERT [Customer].[Customer] ([CustomerID], [CustomerName], [CustomerSurname], [DateOfBirth], [Gender], [CustomerContactID], [StaffID], [InsuranceTypeID], [CreateDate]) VALUES (30, N'Kaan', N'Akın', CAST(N'1997-03-19' AS Date), N'Male', 21, 31, 15, CAST(N'2010-06-04' AS Date))
INSERT [Customer].[Customer] ([CustomerID], [CustomerName], [CustomerSurname], [DateOfBirth], [Gender], [CustomerContactID], [StaffID], [InsuranceTypeID], [CreateDate]) VALUES (31, N'Harun', N'Yılmaz', CAST(N'1995-04-22' AS Date), N'Male', 22, 31, 9, CAST(N'2015-06-24' AS Date))
INSERT [Customer].[Customer] ([CustomerID], [CustomerName], [CustomerSurname], [DateOfBirth], [Gender], [CustomerContactID], [StaffID], [InsuranceTypeID], [CreateDate]) VALUES (32, N'Şevval', N'Karakoyun', CAST(N'2001-10-01' AS Date), N'Female', 23, 25, 14, NULL)
INSERT [Customer].[Customer] ([CustomerID], [CustomerName], [CustomerSurname], [DateOfBirth], [Gender], [CustomerContactID], [StaffID], [InsuranceTypeID], [CreateDate]) VALUES (33, N'Özge', N'Güngör', CAST(N'1989-10-21' AS Date), N'Female', 24, 25, 14, NULL)
SET IDENTITY_INSERT [Customer].[Customer] OFF
SET IDENTITY_INSERT [Customer].[CustomerContact] ON 

INSERT [Customer].[CustomerContact] ([CustomerContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (15, N'ZeynepGunay@gmail.com', N'05435437077', N'Beylikdüzü', 14)
INSERT [Customer].[CustomerContact] ([CustomerContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (16, N'EzgiSarı@gmail.com', N'05478548962', N'Zeytinburnu', 14)
INSERT [Customer].[CustomerContact] ([CustomerContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (17, N'AsliTanyeri@gmail.com', N'05079345487', N'Bahçelievler', 15)
INSERT [Customer].[CustomerContact] ([CustomerContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (18, N'MetinKoc@gmail.com', N'05485487874', N'Sapanca', 15)
INSERT [Customer].[CustomerContact] ([CustomerContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (19, N'EmreBolat@gmail.com', N'05486431558', N'Ortaköy', 14)
INSERT [Customer].[CustomerContact] ([CustomerContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (20, N'Piyerİs@gmail.com', N'05327899656', N'Yenimahalle', 15)
INSERT [Customer].[CustomerContact] ([CustomerContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (21, N'KaanAkin@gmail.com', N'05322568496', N'Kadıköy', 14)
INSERT [Customer].[CustomerContact] ([CustomerContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (22, N'HarunYilmaz@gmail.com', N'05356859685', N'Alsancak', 17)
INSERT [Customer].[CustomerContact] ([CustomerContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (23, N'SevvalKarakoyun@gmail.com', N'05384568525', N'Beşiktaş', 14)
INSERT [Customer].[CustomerContact] ([CustomerContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (24, N'ÖzgeGüngör@hotmail.com', N'05364569674', N'Bahçelievler', 17)
SET IDENTITY_INSERT [Customer].[CustomerContact] OFF
SET IDENTITY_INSERT [Customer].[CustomerInsurance] ON 

INSERT [Customer].[CustomerInsurance] ([CustomerInsuranceID], [InsuranceID], [CustomerID]) VALUES (37, 43, 30)
INSERT [Customer].[CustomerInsurance] ([CustomerInsuranceID], [InsuranceID], [CustomerID]) VALUES (38, 44, 30)
INSERT [Customer].[CustomerInsurance] ([CustomerInsuranceID], [InsuranceID], [CustomerID]) VALUES (39, 45, 30)
INSERT [Customer].[CustomerInsurance] ([CustomerInsuranceID], [InsuranceID], [CustomerID]) VALUES (40, 46, 25)
INSERT [Customer].[CustomerInsurance] ([CustomerInsuranceID], [InsuranceID], [CustomerID]) VALUES (41, 47, 31)
SET IDENTITY_INSERT [Customer].[CustomerInsurance] OFF
SET IDENTITY_INSERT [Customer].[Province] ON 

INSERT [Customer].[Province] ([ProvinceID], [ProvinceName], [IncreasePercentage]) VALUES (14, N'İstanbul', 50)
INSERT [Customer].[Province] ([ProvinceID], [ProvinceName], [IncreasePercentage]) VALUES (15, N'Ankara', 45)
INSERT [Customer].[Province] ([ProvinceID], [ProvinceName], [IncreasePercentage]) VALUES (16, N'Bursa', 40)
INSERT [Customer].[Province] ([ProvinceID], [ProvinceName], [IncreasePercentage]) VALUES (17, N'İzmir', 45)
INSERT [Customer].[Province] ([ProvinceID], [ProvinceName], [IncreasePercentage]) VALUES (18, N'Eskişehir', 40)
INSERT [Customer].[Province] ([ProvinceID], [ProvinceName], [IncreasePercentage]) VALUES (19, N'Antalya', 35)
INSERT [Customer].[Province] ([ProvinceID], [ProvinceName], [IncreasePercentage]) VALUES (20, N'Gaziantep', 35)
INSERT [Customer].[Province] ([ProvinceID], [ProvinceName], [IncreasePercentage]) VALUES (21, N'Tekirdağ', 20)
INSERT [Customer].[Province] ([ProvinceID], [ProvinceName], [IncreasePercentage]) VALUES (22, N'Kocaeli', 25)
INSERT [Customer].[Province] ([ProvinceID], [ProvinceName], [IncreasePercentage]) VALUES (23, N'Yalova', 20)
INSERT [Customer].[Province] ([ProvinceID], [ProvinceName], [IncreasePercentage]) VALUES (24, N'Kayseri', 10)
INSERT [Customer].[Province] ([ProvinceID], [ProvinceName], [IncreasePercentage]) VALUES (28, N'Balıkesir', 15)
INSERT [Customer].[Province] ([ProvinceID], [ProvinceName], [IncreasePercentage]) VALUES (29, N'Sakarya', 15)
SET IDENTITY_INSERT [Customer].[Province] OFF
SET IDENTITY_INSERT [Customer].[Staff] ON 

INSERT [Customer].[Staff] ([StaffID], [StaffName], [StaffSurname], [DateOfBirth], [Gender], [Role], [Nationality], [Salary], [StaffContactID], [CompanyID], [UserName], [Password], [image], [JoiningYear]) VALUES (25, N'Furkan', N'Turkan', CAST(N'1998-11-16' AS Date), N'Male', N'Salesman', N'Turkish', 2484.0000, 17, 10, N'Furkan.Turkan', N'1234', N'Staff1', CAST(N'2015-02-04' AS Date))
INSERT [Customer].[Staff] ([StaffID], [StaffName], [StaffSurname], [DateOfBirth], [Gender], [Role], [Nationality], [Salary], [StaffContactID], [CompanyID], [UserName], [Password], [image], [JoiningYear]) VALUES (26, N'Dilek', N'Medeni', CAST(N'1990-01-17' AS Date), N'Female', N'Presentation', N'Italy', 6500.0000, 14, 16, N'Dilek.Medeni', N'1235', N'Staff2', CAST(N'2005-12-04' AS Date))
INSERT [Customer].[Staff] ([StaffID], [StaffName], [StaffSurname], [DateOfBirth], [Gender], [Role], [Nationality], [Salary], [StaffContactID], [CompanyID], [UserName], [Password], [image], [JoiningYear]) VALUES (27, N'Gökçe', N'Kırgın', CAST(N'1992-11-01' AS Date), N'Female', N'Salesman', N'Turkish', 3202.5000, 18, 16, N'Gökçe.Kırgın', N'1236', N'Staff3', CAST(N'2008-12-14' AS Date))
INSERT [Customer].[Staff] ([StaffID], [StaffName], [StaffSurname], [DateOfBirth], [Gender], [Role], [Nationality], [Salary], [StaffContactID], [CompanyID], [UserName], [Password], [image], [JoiningYear]) VALUES (28, N'Burak', N'Koçak', CAST(N'1989-12-21' AS Date), N'Male', N'Salesman', N'Turkish', 3662.5000, 19, 12, N'Burak.Koçak', N'1237', N'Staff4', CAST(N'2002-07-24' AS Date))
INSERT [Customer].[Staff] ([StaffID], [StaffName], [StaffSurname], [DateOfBirth], [Gender], [Role], [Nationality], [Salary], [StaffContactID], [CompanyID], [UserName], [Password], [image], [JoiningYear]) VALUES (29, N'Beyza', N'Kahraman', CAST(N'1998-05-21' AS Date), N'Female', N'Presentation', N'German', 4160.0000, 20, 15, N'Beyza.Kahraman', N'1238', N'Staff5', CAST(N'2002-07-24' AS Date))
INSERT [Customer].[Staff] ([StaffID], [StaffName], [StaffSurname], [DateOfBirth], [Gender], [Role], [Nationality], [Salary], [StaffContactID], [CompanyID], [UserName], [Password], [image], [JoiningYear]) VALUES (30, N'Kübra', N'Çelebi', CAST(N'1991-05-27' AS Date), N'Female', N'Salesman', N'Turkish', 3950.0000, 13, 15, N'Kübra.Çelebi', N'1239', N'Staff6', CAST(N'2012-02-01' AS Date))
INSERT [Customer].[Staff] ([StaffID], [StaffName], [StaffSurname], [DateOfBirth], [Gender], [Role], [Nationality], [Salary], [StaffContactID], [CompanyID], [UserName], [Password], [image], [JoiningYear]) VALUES (31, N'Beyza', N'Pehlivan', CAST(N'1994-04-17' AS Date), N'Female', N'Salesman', N'German', 3737.5000, 15, 10, N'Beyza.Pehlivan', N'1119', N'Staff7', CAST(N'2017-12-11' AS Date))
INSERT [Customer].[Staff] ([StaffID], [StaffName], [StaffSurname], [DateOfBirth], [Gender], [Role], [Nationality], [Salary], [StaffContactID], [CompanyID], [UserName], [Password], [image], [JoiningYear]) VALUES (32, N'Eda', N'Yeniay', CAST(N'2000-07-04' AS Date), N'Female', N'Salesman', N'German', 2288.5000, 23, 11, N'Eda.Yeniay', N'1789', N'Staff9', CAST(N'2019-11-11' AS Date))
INSERT [Customer].[Staff] ([StaffID], [StaffName], [StaffSurname], [DateOfBirth], [Gender], [Role], [Nationality], [Salary], [StaffContactID], [CompanyID], [UserName], [Password], [image], [JoiningYear]) VALUES (33, N'Engin', N'Uzun', CAST(N'1995-02-24' AS Date), N'Male', N'Salesman', N'Turkish', 4500.0000, 24, 11, N'Engin.Uzun', N'1589', N'Staff10', CAST(N'2014-10-06' AS Date))
SET IDENTITY_INSERT [Customer].[Staff] OFF
SET IDENTITY_INSERT [Customer].[StaffContact] ON 

INSERT [Customer].[StaffContact] ([StaffContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (13, N'Kubracelebi@gmail.com', N'05356987885', N'Bakırköy', 14)
INSERT [Customer].[StaffContact] ([StaffContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (14, N'DilekMedeni@gmail.com', N'05257864512', N'Çengelköy', 14)
INSERT [Customer].[StaffContact] ([StaffContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (15, N'BeyzaPehlivan@gmail.com', N'05427859636', N'Bakırköy', 14)
INSERT [Customer].[StaffContact] ([StaffContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (16, N'BünyaminK@gmail.com', N'05314859625', N'Yenimahalle', 15)
INSERT [Customer].[StaffContact] ([StaffContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (17, N'FurkanTurkan@gmail.com', N'05312134541', N'Altınova', 17)
INSERT [Customer].[StaffContact] ([StaffContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (18, N'GökçeKirgin@gmail.com', N'05317849625', N'Yenimahalle', 15)
INSERT [Customer].[StaffContact] ([StaffContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (19, N'BurakKocak@gmail.com', N'05352457637', N'Bakırköy', 14)
INSERT [Customer].[StaffContact] ([StaffContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (20, N'BeyzaKahraman@gmail.com', N'05436874521', N'Bornova', 17)
INSERT [Customer].[StaffContact] ([StaffContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (21, N'CevatYildiz@gmail.com', N'05478963525', N'Bornova', 17)
INSERT [Customer].[StaffContact] ([StaffContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (22, N'BünyaminÇelik@gmail.com', N'05495487845', N'Bakırköy', 14)
INSERT [Customer].[StaffContact] ([StaffContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (23, N'EsraYıldız@gmail.com', N'05555487845', N'Yenimahalle', 15)
INSERT [Customer].[StaffContact] ([StaffContactID], [Email], [Phone], [Address], [ProvinceID]) VALUES (26, N'EnginUzun@hotmail.com', N'05495487845', N'Bornova', 17)
SET IDENTITY_INSERT [Customer].[StaffContact] OFF
SET IDENTITY_INSERT [Insurance].[Housing] ON 

INSERT [Insurance].[Housing] ([HousingID], [Model], [Year], [Area]) VALUES (8, N'Duplex', 2000, 140)
INSERT [Insurance].[Housing] ([HousingID], [Model], [Year], [Area]) VALUES (9, N'Wooden', 1998, 90)
INSERT [Insurance].[Housing] ([HousingID], [Model], [Year], [Area]) VALUES (10, N'Villa', 2008, 180)
INSERT [Insurance].[Housing] ([HousingID], [Model], [Year], [Area]) VALUES (11, N'Apartment', 1996, 100)
INSERT [Insurance].[Housing] ([HousingID], [Model], [Year], [Area]) VALUES (12, N'Triplex', 2005, 170)
INSERT [Insurance].[Housing] ([HousingID], [Model], [Year], [Area]) VALUES (13, N'Stone Houses', 1997, 110)
SET IDENTITY_INSERT [Insurance].[Housing] OFF
SET IDENTITY_INSERT [Insurance].[Insurance] ON 

INSERT [Insurance].[Insurance] ([InsuranceID], [StaffID], [CustomerID], [InsuranceDate], [StartDate], [EndDate]) VALUES (43, 24, 30, CAST(N'2016-05-16' AS Date), CAST(N'2016-05-18T00:00:00.000' AS DateTime), CAST(N'2017-02-01T00:00:00.000' AS DateTime))
INSERT [Insurance].[Insurance] ([InsuranceID], [StaffID], [CustomerID], [InsuranceDate], [StartDate], [EndDate]) VALUES (44, 25, 30, CAST(N'2012-05-13' AS Date), CAST(N'2012-05-17T00:00:00.000' AS DateTime), CAST(N'2013-05-14T00:00:00.000' AS DateTime))
INSERT [Insurance].[Insurance] ([InsuranceID], [StaffID], [CustomerID], [InsuranceDate], [StartDate], [EndDate]) VALUES (45, 26, 30, CAST(N'2018-02-14' AS Date), CAST(N'2018-02-14T00:00:00.000' AS DateTime), CAST(N'2018-11-17T00:00:00.000' AS DateTime))
INSERT [Insurance].[Insurance] ([InsuranceID], [StaffID], [CustomerID], [InsuranceDate], [StartDate], [EndDate]) VALUES (46, 32, 25, CAST(N'2019-08-12' AS Date), CAST(N'2019-09-12T00:00:00.000' AS DateTime), CAST(N'2020-09-12T00:00:00.000' AS DateTime))
INSERT [Insurance].[Insurance] ([InsuranceID], [StaffID], [CustomerID], [InsuranceDate], [StartDate], [EndDate]) VALUES (47, 30, 31, CAST(N'2014-02-01' AS Date), CAST(N'2014-02-02T00:00:00.000' AS DateTime), CAST(N'2015-01-01T00:00:00.000' AS DateTime))
SET IDENTITY_INSERT [Insurance].[Insurance] OFF
SET IDENTITY_INSERT [Insurance].[InsuranceDetail] ON 

INSERT [Insurance].[InsuranceDetail] ([InsuranceDetailID], [InsuranceTypeID], [CreateDate], [VehicleID], [HousingID], [InsuranceID], [Price]) VALUES (46, 9, CAST(N'2016-11-14' AS Date), 13, NULL, 46, 180.0000)
INSERT [Insurance].[InsuranceDetail] ([InsuranceDetailID], [InsuranceTypeID], [CreateDate], [VehicleID], [HousingID], [InsuranceID], [Price]) VALUES (48, 12, CAST(N'2018-12-24' AS Date), NULL, NULL, 45, 250.0000)
INSERT [Insurance].[InsuranceDetail] ([InsuranceDetailID], [InsuranceTypeID], [CreateDate], [VehicleID], [HousingID], [InsuranceID], [Price]) VALUES (50, 10, CAST(N'2000-11-14' AS Date), NULL, 13, 47, 200.0000)
INSERT [Insurance].[InsuranceDetail] ([InsuranceDetailID], [InsuranceTypeID], [CreateDate], [VehicleID], [HousingID], [InsuranceID], [Price]) VALUES (52, 9, CAST(N'2016-11-14' AS Date), 13, NULL, 44, 180.0000)
INSERT [Insurance].[InsuranceDetail] ([InsuranceDetailID], [InsuranceTypeID], [CreateDate], [VehicleID], [HousingID], [InsuranceID], [Price]) VALUES (54, 11, CAST(N'2012-07-01' AS Date), NULL, NULL, 46, 180.0000)
INSERT [Insurance].[InsuranceDetail] ([InsuranceDetailID], [InsuranceTypeID], [CreateDate], [VehicleID], [HousingID], [InsuranceID], [Price]) VALUES (56, 9, CAST(N'2014-11-06' AS Date), 14, NULL, 43, 180.0000)
SET IDENTITY_INSERT [Insurance].[InsuranceDetail] OFF
SET IDENTITY_INSERT [Insurance].[InsuranceType] ON 

INSERT [Insurance].[InsuranceType] ([InsuranceTypeID], [Type], [Price], [Description], [RegenerationTime]) VALUES (9, N'Kasko', 180.0000, N'Insurance, accident, crash, crash, burning, theft and attempted theft. secures the vehicle in such cases. When you make a car insurance query via Sigortam.net, you can see the contracted insurance companies car insurance price page. You can buy the most suitable insurance for your budget with a price advantage of up to 50%.', 1)
INSERT [Insurance].[InsuranceType] ([InsuranceTypeID], [Type], [Price], [Description], [RegenerationTime]) VALUES (10, N'Housing', 250.0000, N'With your home insurance, your home, which you value most, is theft, burning, destruction, etc. protection against incidents. You can even have your belongings covered for a minimal cost', 3)
INSERT [Insurance].[InsuranceType] ([InsuranceTypeID], [Type], [Price], [Description], [RegenerationTime]) VALUES (11, N'Travel Insurance', 180.0000, N'Travel Insurance allows you to travel comfortably inside and outside the country. Accidents, illnesses, loss of suitcases, etc. that you may encounter during your travels. risks.', 1)
INSERT [Insurance].[InsuranceType] ([InsuranceTypeID], [Type], [Price], [Description], [RegenerationTime]) VALUES (12, N'Life Insurance', 300.0000, N'Private health insurance ensures that costs are met in case of illnesses and health problems caused by accidents. Health insurance coverage varies, you can add the insurance coverage you need to your insurance.', 1)
INSERT [Insurance].[InsuranceType] ([InsuranceTypeID], [Type], [Price], [Description], [RegenerationTime]) VALUES (13, N'Pension Insurance', 220.0000, N'BES’e By joining Private Pension, you guarantee your future. The Private Pension System allows you to live a prosperous retirement by adding an additional benefit to your existing retirement benefit..', 3)
INSERT [Insurance].[InsuranceType] ([InsuranceTypeID], [Type], [Price], [Description], [RegenerationTime]) VALUES (14, N'Health Insurance', 100.0000, N'Life insurance guarantees the family financially against the risk of loss of life. Having an annual life insurance ensures that the living standard of your family, your most valuable asset, is maintained.', 2)
INSERT [Insurance].[InsuranceType] ([InsuranceTypeID], [Type], [Price], [Description], [RegenerationTime]) VALUES (15, N'Vehicle', 150.0000, N'Traffic insurance is a compulsory insurance types that taking a motor vehicle port in Turkey. Obligatory traffic insurance, accident and the third party in the room and vehicle damage that occurs in the room is assured. The material protection of the bully is also protected.', 2)
SET IDENTITY_INSERT [Insurance].[InsuranceType] OFF
SET IDENTITY_INSERT [Insurance].[Vehicle] ON 

INSERT [Insurance].[Vehicle] ([VehicleID], [Model], [Year], [LicencePlate], [Color]) VALUES (11, N'BMW', CAST(N'2016-12-18' AS Date), N'34', N'Red')
INSERT [Insurance].[Vehicle] ([VehicleID], [Model], [Year], [LicencePlate], [Color]) VALUES (12, N'Ford', CAST(N'2018-10-25' AS Date), N'54', N'Red')
INSERT [Insurance].[Vehicle] ([VehicleID], [Model], [Year], [LicencePlate], [Color]) VALUES (13, N'Audi', CAST(N'2019-01-05' AS Date), N'34', N'Black')
INSERT [Insurance].[Vehicle] ([VehicleID], [Model], [Year], [LicencePlate], [Color]) VALUES (14, N'Citroen', CAST(N'2015-05-06' AS Date), N'35', N'Black')
INSERT [Insurance].[Vehicle] ([VehicleID], [Model], [Year], [LicencePlate], [Color]) VALUES (15, N'Nissan', CAST(N'2018-04-06' AS Date), N'35', N'Red')
INSERT [Insurance].[Vehicle] ([VehicleID], [Model], [Year], [LicencePlate], [Color]) VALUES (16, N'Toyota', CAST(N'2019-05-25' AS Date), N'59', N'Blue')
INSERT [Insurance].[Vehicle] ([VehicleID], [Model], [Year], [LicencePlate], [Color]) VALUES (17, N'Opel', CAST(N'2017-02-15' AS Date), N'59', N'White')
INSERT [Insurance].[Vehicle] ([VehicleID], [Model], [Year], [LicencePlate], [Color]) VALUES (18, N'Renault', CAST(N'2015-02-07' AS Date), N'01', N'Grey')
INSERT [Insurance].[Vehicle] ([VehicleID], [Model], [Year], [LicencePlate], [Color]) VALUES (19, N'Volkswagen', CAST(N'2018-01-05' AS Date), N'34', N'White')
INSERT [Insurance].[Vehicle] ([VehicleID], [Model], [Year], [LicencePlate], [Color]) VALUES (20, N'Honda', CAST(N'2017-02-08' AS Date), N'34', N'Black')
SET IDENTITY_INSERT [Insurance].[Vehicle] OFF
SET IDENTITY_INSERT [Log].[Log] ON 

INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (3, N'Zeynep', 1, CAST(N'2019-12-11' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (4, N'Ezgi', 10, CAST(N'2019-12-11' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (5, N'Metin', 7, CAST(N'2019-12-11' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (6, N'Aslı', 9, CAST(N'2019-12-11' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (7, N'Emre', 9, CAST(N'2019-12-11' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (8, N'Piyer', 7, CAST(N'2019-12-11' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (9, N'Kaan', 6, CAST(N'2019-12-11' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (10, N'Harun', 7, CAST(N'2019-12-11' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (11, N'Şevval', 6, CAST(N'2019-12-11' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (12, N'Özge', 2, CAST(N'2019-12-11' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (13, N'Zeynep', 1, CAST(N'2019-12-12' AS Date), N'Delete')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (14, N'Zeynep', 30, CAST(N'2019-12-12' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (15, N'Ezgi', 33, CAST(N'2019-12-12' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (16, N'Metin', 30, CAST(N'2019-12-12' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (17, N'Aslı', 31, CAST(N'2019-12-12' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (18, N'Emre', 33, CAST(N'2019-12-12' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (19, N'Piyer', 26, CAST(N'2019-12-12' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (20, N'Kaan', 31, CAST(N'2019-12-12' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (21, N'Harun', 31, CAST(N'2019-12-12' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (22, N'Şevval', 25, CAST(N'2019-12-12' AS Date), N'insert')
INSERT [Log].[Log] ([LogID], [LogTable], [StaffID], [LogDate], [LogProcedure]) VALUES (23, N'Özge', 25, CAST(N'2019-12-12' AS Date), N'insert')
SET IDENTITY_INSERT [Log].[Log] OFF
ALTER TABLE [Customer].[Company]  WITH NOCHECK ADD  CONSTRAINT [FK_Company_Province] FOREIGN KEY([ProvinceID])
REFERENCES [Customer].[Province] ([ProvinceID])
GO
ALTER TABLE [Customer].[Company] NOCHECK CONSTRAINT [FK_Company_Province]
GO
ALTER TABLE [Customer].[Customer]  WITH NOCHECK ADD  CONSTRAINT [FK_Customer_CustomerContact] FOREIGN KEY([CustomerContactID])
REFERENCES [Customer].[CustomerContact] ([CustomerContactID])
GO
ALTER TABLE [Customer].[Customer] NOCHECK CONSTRAINT [FK_Customer_CustomerContact]
GO
ALTER TABLE [Customer].[Customer]  WITH NOCHECK ADD  CONSTRAINT [FK_Customer_Staff] FOREIGN KEY([StaffID])
REFERENCES [Customer].[Staff] ([StaffID])
GO
ALTER TABLE [Customer].[Customer] NOCHECK CONSTRAINT [FK_Customer_Staff]
GO
ALTER TABLE [Customer].[CustomerContact]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomerContact_Province] FOREIGN KEY([ProvinceID])
REFERENCES [Customer].[Province] ([ProvinceID])
GO
ALTER TABLE [Customer].[CustomerContact] NOCHECK CONSTRAINT [FK_CustomerContact_Province]
GO
ALTER TABLE [Customer].[CustomerInsurance]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomerInsurance_Customer] FOREIGN KEY([CustomerID])
REFERENCES [Customer].[Customer] ([CustomerID])
GO
ALTER TABLE [Customer].[CustomerInsurance] NOCHECK CONSTRAINT [FK_CustomerInsurance_Customer]
GO
ALTER TABLE [Customer].[CustomerInsurance]  WITH NOCHECK ADD  CONSTRAINT [FK_CustomerInsurance_Insurance] FOREIGN KEY([InsuranceID])
REFERENCES [Insurance].[Insurance] ([InsuranceID])
GO
ALTER TABLE [Customer].[CustomerInsurance] NOCHECK CONSTRAINT [FK_CustomerInsurance_Insurance]
GO
ALTER TABLE [Customer].[Staff]  WITH NOCHECK ADD  CONSTRAINT [FK_Staff_Company] FOREIGN KEY([CompanyID])
REFERENCES [Customer].[Company] ([CompanyID])
GO
ALTER TABLE [Customer].[Staff] NOCHECK CONSTRAINT [FK_Staff_Company]
GO
ALTER TABLE [Customer].[StaffContact]  WITH NOCHECK ADD  CONSTRAINT [FK_StaffContact_Province] FOREIGN KEY([ProvinceID])
REFERENCES [Customer].[Province] ([ProvinceID])
GO
ALTER TABLE [Customer].[StaffContact] NOCHECK CONSTRAINT [FK_StaffContact_Province]
GO
ALTER TABLE [Insurance].[Insurance]  WITH NOCHECK ADD  CONSTRAINT [FK_Insurance_Staff] FOREIGN KEY([StaffID])
REFERENCES [Customer].[Staff] ([StaffID])
GO
ALTER TABLE [Insurance].[Insurance] NOCHECK CONSTRAINT [FK_Insurance_Staff]
GO
ALTER TABLE [Insurance].[InsuranceDetail]  WITH NOCHECK ADD  CONSTRAINT [FK_InsuranceDetail_Housing] FOREIGN KEY([HousingID])
REFERENCES [Insurance].[Housing] ([HousingID])
GO
ALTER TABLE [Insurance].[InsuranceDetail] NOCHECK CONSTRAINT [FK_InsuranceDetail_Housing]
GO
ALTER TABLE [Insurance].[InsuranceDetail]  WITH NOCHECK ADD  CONSTRAINT [FK_InsuranceDetail_Insurance] FOREIGN KEY([InsuranceID])
REFERENCES [Insurance].[Insurance] ([InsuranceID])
GO
ALTER TABLE [Insurance].[InsuranceDetail] NOCHECK CONSTRAINT [FK_InsuranceDetail_Insurance]
GO
ALTER TABLE [Insurance].[InsuranceDetail]  WITH NOCHECK ADD  CONSTRAINT [FK_InsuranceDetail_InsuranceType] FOREIGN KEY([InsuranceTypeID])
REFERENCES [Insurance].[InsuranceType] ([InsuranceTypeID])
GO
ALTER TABLE [Insurance].[InsuranceDetail] NOCHECK CONSTRAINT [FK_InsuranceDetail_InsuranceType]
GO
ALTER TABLE [Insurance].[InsuranceDetail]  WITH NOCHECK ADD  CONSTRAINT [FK_InsuranceDetail_Vehicle] FOREIGN KEY([VehicleID])
REFERENCES [Insurance].[Vehicle] ([VehicleID])
GO
ALTER TABLE [Insurance].[InsuranceDetail] NOCHECK CONSTRAINT [FK_InsuranceDetail_Vehicle]
GO
ALTER TABLE [Log].[Log]  WITH NOCHECK ADD  CONSTRAINT [FK_Log_Staff] FOREIGN KEY([StaffID])
REFERENCES [Customer].[Staff] ([StaffID])
GO
ALTER TABLE [Log].[Log] NOCHECK CONSTRAINT [FK_Log_Staff]
GO
/****** Object:  StoredProcedure [Customer].[fifth_year_Customer_discount]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Customer].[fifth_year_Customer_discount]
as
declare @InsuranceYear int
select @InsuranceYear = year(getdate())-5
update Insurance.InsuranceDetail set Price = Price - 50 where InsuranceID in(
(SELECT max(InsuranceID) FROM Insurance.Insurance Where CustomerID in(
select CU.CustomerID from Insurance.Insurance INS
left join Customer.Customer CU on CU.CustomerID = INS.CustomerID
group by Year(INS.InsuranceDate),CU.CustomerID
having Year(INS.InsuranceDate) <= @InsuranceYear)
group by CustomerID))
GO
/****** Object:  StoredProcedure [Customer].[fifth_year_Staff]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Customer].[fifth_year_Staff]
as  
select StaffName,StaffSurname,JoiningYear,Salary   
from Customer.Staff as S   
update Customer.Staff Set Salary = (Salary +500) where Year(getdate())- year(JoiningYear) > 5  
GO
/****** Object:  StoredProcedure [Customer].[Find_Staff_Contact]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Customer].[Find_Staff_Contact] ( @StaffName nvarchar(50))
as
select (StaffName +' '+StaffSurname )as Staff ,Email,Phone,Address 
from Customer.Staff as S inner join Customer.StaffContact as SC 
on S.StaffContactID= SC.StaffContactID
where @StaffName=StaffName
GO
/****** Object:  StoredProcedure [Customer].[Foundation]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Customer].[Foundation]
as
select * from Customer.Company
Where FoundationYear<2000
GO
/****** Object:  StoredProcedure [Customer].[FoundationUpdate]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create proc [Customer].[FoundationUpdate]
as
Select * from Customer.Company where FoundationYear > 2000
GO
/****** Object:  StoredProcedure [Customer].[PRC_SalaryReport]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create procedure [Customer].[PRC_SalaryReport]
as 
begin
select C.CompanyID,C.CompanyName,
(select TOP 1 (SA.StaffName + ' ' + SA.StaffSurname) from Customer.Staff SA where SA.Salary = MAX(S.Salary)) AS ISIM_SOYISIM,
MAX(S.Salary) MAX_SALARY,
(select TOP 1 (SA.StaffName + ' ' + SA.StaffSurname) from Customer.Staff SA where SA.Salary = MIN(S.Salary))AS ISIM_SOYISIM,
MIN(S.Salary) MIN_SALARY
from Customer.Staff S
left outer join Customer.Company C on C.CompanyID = S.CompanyID
group by C.CompanyID,C.CompanyName
END
GO
/****** Object:  StoredProcedure [Customer].[Salary_Increase]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Customer].[Salary_Increase]
as
if exists(select StaffName ,StaffSurname,JoiningYear,Salary from Customer.Staff )
update Customer.Staff Set Salary=Salary*1.20 where DATEPART(Year,JoiningYear)>10
GO
/****** Object:  StoredProcedure [Customer].[Salary_interval]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [Customer].[Salary_interval]
(
@StaffSalary1 money, @staffSalary2 money)
as
Select * from Customer.Staff Where Salary Between @StaffSalary1 and @staffSalary2
order by Salary desc
GO
/****** Object:  StoredProcedure [Customer].[sp_staff_avg]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create procedure [Customer].[sp_staff_avg]
as
declare @avrageSalary money
begin 
select @avrageSalary = avg(Salary) from Customer.Staff;
--ortalama maaş altında olanlara yüzde 15 zam yapıldı.
update Customer.Staff set Salary =  Salary + ((Salary * 15) / 100) where Salary < @avrageSalary
end
GO
/****** Object:  StoredProcedure [Customer].[SP_Staff_Role]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [Customer].[SP_Staff_Role] (@Role nvarchar(50))
as
begin
	update Customer.Staff set Salary=Salary *1.20 where Role=@Role
end
GO
/****** Object:  StoredProcedure [Customer].[UpdateStaff]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [Customer].[UpdateStaff]
(@oldf_name nvarchar(50), @newf_name nvarchar(50) , @newl_name nvarchar(50))
as
update Customer.Staff
set StaffName=@newf_name, StaffSurname=@newl_name,
UserName = @newf_name + '.' + @newl_name
where  [StaffName]=@oldf_name
GO
/****** Object:  StoredProcedure [Insurance].[SP_Find_Insurance_Type]    Script Date: 12.12.2019 16:00:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROC [Insurance].[SP_Find_Insurance_Type]
@InsuranceType NVARCHAR(150)
AS
declare @TypeCount int
BEGIN
     select @TypeCount = count(IT.Type) from Insurance.InsuranceType IT group by IT.Type having IT.Type = @InsuranceType and count(IT.Type) > 1
	 if(@TypeCount > 1)
	 begin
	 WHILE @TypeCount > 1
	BEGIN
	 update Insurance.InsuranceType set Type = Type + Convert(nvarchar(100),@TypeCount) where InsuranceTypeID = (select top 1 InsuranceTypeID from Insurance.InsuranceType where Type = @InsuranceType order by InsuranceTypeID desc)
	select @TypeCount = count(IT.Type) from Insurance.InsuranceType IT group by IT.Type having IT.Type = @InsuranceType 
	END
	
	 end
END
GO
USE [master]
GO
ALTER DATABASE [InsuranceServicesDB] SET  READ_WRITE 
GO
