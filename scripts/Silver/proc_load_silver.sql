/*
========================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
========================================================================================
Script Purpose:
  This stored procedure performs the ETL (Extract, Transform, Load) process to
  populate the 'silver' schema tables from the 'bronze' schema.
  Actions Performed:
  - Truncates Silver tables.
  - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC Silver.load_silver;
========================================================================================
*/
Create Or Alter Procedure silver.load_silver As 
Begin
	Declare @start_Time Datetime, @End_Time Datetime, @batch_stat_time Datetime , @batch_End_time Datetime ; 
	begin try
	 Set @batch_stat_time = GETDATE() ; 
	print '======================================';
	print 'Loding Silver Layer';
	print '======================================';

	print '--------------------------------------';
	print 'Loding CRM Tables';
	print '--------------------------------------';

	Set @start_Time = GETDATE();
		Print'>>Truncating TAble : silver.crm_cust_info'
		TRUNCATE TABLE silver.crm_cust_info;
		print'>> Inserting data into:silver.crm_cust_info';
		Insert into silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date)
		Select 
		cst_id,
		cst_key,
		Trim(cst_firstname) AS cst_firstname,
		Trim(cst_lastname) AS cst_lastname,
		Case when Upper(Trim(cst_marital_status)) ='S' Then 'Single'
			 when Upper(Trim(cst_marital_status)) ='M' Then 'Married'
			 Else 'n/a'
		End cst_marital_status, 
		Case when Upper(Trim(cst_gndr)) ='F' Then 'Female'
			 when Upper(Trim(cst_gndr)) ='M' Then 'Male'
			 Else 'n/a'
		End cst_gndr ,
		cst_create_date
		from (
		Select * ,
		Row_Number() over(partition by cst_id order by cst_create_date desc ) As flag_last
		from bronze.crm_cust_info
		where cst_id is not null 
		) t
		where flag_last = 1
		Set @End_Time = GETDATE();
	print'>>>Load Duration : '+ Cast(datediff(second, @start_time, @End_time)As Nvarchar ) + ' Seconds' ;
	print'>>>-------------';

	Set @start_Time = GETDATE();
		Print'>>Truncating TAble : silver.crm_prd_info'
		TRUNCATE TABLE silver.crm_prd_info;
		print'>> Inserting data into: silver.crm_prd_info';
		Insert into silver.crm_prd_info(  
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)
			Select 
			prd_id,
			Replace(substring(prd_key,1,5), '-', '_') As cat_id,
			SUBSTRING(prd_key,7,Len(prd_key)) As prd_key,
			prd_nm, 
			isnull (prd_cost,0) As prd_cost,
			Case Upper(Trim(prd_line))
				when 'M' then 'Mountain'
				when 'R' then 'Road'
				when 'S' then 'Other Sales'
				when 'T' then 'Touring'
				Else 'n/a' 
			End As prd_line,
			 Cast(prd_start_dt As date) As prd_start_dt,
			 Cast(Lead (prd_start_dt) Over (partition By prd_key Order By prd_start_dt)-1 As date) As prd_end_dt
			from bronze.crm_prd_info
		Set @End_Time = GETDATE();
	print'>>>Load Duration : '+ Cast(datediff(second, @start_time, @End_time)As Nvarchar ) + ' Seconds' ;
	print'>>>-------------';
 

		Set @start_Time = GETDATE();
		Print'>>Truncating TAble : silver.crm_sales_details'
		TRUNCATE TABLE silver.crm_sales_details
		print'>> Inserting data into:silver.crm_sales_details';
		Insert Into silver.crm_sales_details(
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
		)
			select 
				sls_ord_num,
				sls_prd_key,
				sls_cust_id,

			Case when sls_order_dt = 0 or len(sls_order_dt) != 8 Then null 
				 Else Cast(Cast(sls_order_dt As varchar) As Date) 
				End As sls_order_dt,

			Case when sls_ship_dt = 0 or len(sls_ship_dt) != 8 Then null 
				 Else Cast(Cast(sls_ship_dt As varchar) As Date) 
				End As sls_ship_dt,

			Case when sls_due_dt = 0 or len(sls_due_dt) != 8 Then null 
				 Else Cast(Cast(sls_due_dt As varchar) As Date) 
				End As sls_due_dt,


			Case when sls_sales is null or sls_sales <= 0 or sls_sales != sls_quantity * Abs(sls_price)
				Then sls_quantity * Abs(sls_price)
				Else sls_sales
				End As sls_sales, 

			sls_quantity,

			Case When sls_price is null or sls_price <= 0  
				Then sls_sales /nullif( sls_quantity,0) 
				Else sls_price
				End As sls_price
			from bronze.crm_sales_details
			Set @End_Time = GETDATE();
	print'>>>Load Duration : '+ Cast(datediff(second, @start_time, @End_time)As Nvarchar ) + ' Seconds' ;
	print'>>>-------------';

		print '--------------------------------------';
		print 'Loding ERP Tables';
		print '--------------------------------------';

		Set @start_Time = GETDATE();
		Print'>>Truncating TAble : silver.erp_CUST_AZ12'
		TRUNCATE TABLE silver.erp_CUST_AZ12
		print'>> Inserting data into:silver.erp_CUST_AZ12';
		Insert Into silver.erp_CUST_AZ12 (CID,BDATE,GEN)
		select 
		Case When CID Like 'NAS%' Then SUBSTRING(CID,4,len(CID))
			Else CID
		End cid,
		Case When BDATE > GETDATE() Then Null 
			Else Cast(BDATE As date) 
		End bdate ,
		Case When Upper(TRIM(GEN)) IN  ('F','FEMALE') Then 'Female'
			 When Upper(TRIM(GEN)) IN  ('M','MALE') Then 'Male'
			 Else 'n/a'
		End As gen
		from bronze.erp_CUST_AZ12
		Set @End_Time = GETDATE();
	print'>>>Load Duration : '+ Cast(datediff(second, @start_time, @End_time)As Nvarchar ) + ' Seconds' ;
	print'>>>-------------';

	Set @start_Time = GETDATE();
		Print'>>Truncating TAble : silver.erp_LOC_A101'
		TRUNCATE TABLE silver.erp_LOC_A101
		print'>> Inserting data into:silver.erp_LOC_A101';
		Insert Into silver.erp_LOC_A101 (CID,CNTRY)
		select
		Replace(cid, '-',' ' ) cid,
		Case When Trim(cntry) = 'DE' Then 'Germany'
   			 When Trim(cntry) IN ('US','USA') Then 'United States'
			 When Trim(cntry) = '' OR cntry is null Then 'n/a'
			 Else Trim(cntry)
		End As cntry
		from bronze.erp_LOC_A101
	Set @End_Time = GETDATE();
	print'>>>Load Duration : '+ Cast(datediff(second, @start_time, @End_time)As Nvarchar ) + ' Seconds' ;
	print'>>>-------------';

		Set @start_Time = GETDATE();
		Print'>>Truncating TAble : silver.erp_PX_CAT_G1V2'
		TRUNCATE TABLE silver.erp_PX_CAT_G1V2
		print'>> Inserting data into:silver.erp_PX_CAT_G1V2';
		Insert Into silver.erp_PX_CAT_G1V2 (ID,CAT,SUBCAT,MAINTENANCE)
		select 
		ID,
		CAT,
		SUBCAT,
		MAINTENANCE
		from bronze.erp_PX_CAT_G1V2
		Set @End_Time = GETDATE();
	print'>>>Load Duration : '+ Cast(datediff(second, @start_time, @End_time)As Nvarchar ) + ' Seconds' ;
	print'>>>-------------';

	Set  @batch_End_time = GETDATE() ;
	print'===========================================';
	print'Loding silver Layer is Completed' ;
	print'  -Total Load Duration ' + Cast(Datediff(Second,@batch_stat_time,@batch_End_time) As Nvarchar) + ' Seconds' ; 
	print'==========================================='

	End try 
	Begin catch 
	print'===========================================';
	print 'Error OCCURED DURING lOADING Silver LAYER'
	print 'Error Message ' + Error_message();
	print 'Error Message ' + Cast (Error_Number() As Nvarchar );
	print 'Error Message ' + Cast (Error_state() As Nvarchar );
	End Catch
End
