/*
==========================================================================
DDL Script: Create Silver Tables
==========================================================================  
Seript Purpose:
  This script creates tables in the 'silver' schema, dropping existing tables
  if they already exist.
  Run this script to re-define the DDL structure of 'bronze' Tables
==========================================================================
/*
IF OBJECT_ID ('silver.crm_cust_info','U') is not null 
Drop Table silver.crm_cust_info;

Create Table silver.crm_cust_info(
	cst_id int,
	cst_key nvarchar (50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status nvarchar (50),
	cst_gndr nvarchar (50), 
	cst_create_date date ,
	dwh_create_date datetime2 default getdate()

);
IF OBJECT_ID ('silver.crm_prd_info','U') is not null 
Drop Table silver.crm_prd_info;

Create Table silver.crm_prd_info(
	prd_id int,
	cat_id  nvarchar (50),
	prd_key nvarchar (50),
	prd_nm nvarchar (50),
	prd_cost int ,
	prd_line nvarchar (50),
	prd_start_dt date,
	prd_end_dt date,
	dwh_create_date datetime2 default getdate()
);
IF OBJECT_ID ('silver.crm_sales_details','U') is not null 
Drop Table silver.crm_sales_details;


Create Table silver.crm_sales_details(
		sls_ord_num nvarchar (50),
		sls_prd_key nvarchar (50),
		sls_cust_id int,
		sls_order_dt Date,
		sls_ship_dt Date,
		sls_due_dt Date,
		sls_sales int,
		sls_quantity int,
		sls_price int,
		dwh_create_date datetime2 default getdate()
);
IF OBJECT_ID ('silver.erp_CUST_AZ12','U') is not null 
Drop Table silver.erp_CUST_AZ12;



Create Table silver.erp_CUST_AZ12(
CID nvarchar(50), 
BDATE Date, 
GEN nvarchar(30),
dwh_create_date datetime2 default getdate()
);
IF OBJECT_ID ('silver.erp_LOC_A101','U') is not null 
Drop Table silver.erp_LOC_A101;


Create Table silver.erp_LOC_A101(
CID nvarchar(50), 
CNTRY nvarchar(50),
dwh_create_date datetime2 default getdate()
);
IF OBJECT_ID ('silver.erp_PX_CAT_G1V2','U') is not null 
Drop Table silver.erp_PX_CAT_G1V2;


Create Table silver.erp_PX_CAT_G1V2(
ID nvarchar(50),
CAT nvarchar(50), 
SUBCAT nvarchar(50),
MAINTENANCE nvarchar(50),
dwh_create_date datetime2 default getdate()
);
