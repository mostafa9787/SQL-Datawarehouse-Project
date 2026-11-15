/*
====================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
====================================================================================
Script Purpose:
  This stored procedure loads data into the 'bronze' schema from external CSV files.
  It performs the following actions:
  - Truncates the bronze tables before loading data.
  - Uses the `BULK INSERT' command to load data from csv Files to bronze tables.

Parameters:
    None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC bronze.load_bronze;
====================================================================================
*/


Create OR Alter procedure bronze.load_bronze As 
Begin
Declare @start_Time Datetime, @End_Time Datetime, @batch_stat_time Datetime , @batch_End_time Datetime ; 
begin try

Set @batch_stat_time = GETDATE() ; 
print '======================================';
print 'Loding Bronze Layer';
print '======================================';

print '--------------------------------------';
print 'Loding CRM Tables';
print '--------------------------------------';

Set @start_Time = GETDATE();
print'>> Truncating Table : bronze.crm_cust_info';
Truncate Table bronze.crm_cust_info ;

print'>> Inserting data into: bronze.crm_cust_info';
Bulk Insert bronze.crm_cust_info
from 'E:\My n8n\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
With(
firstrow  = 2 ,
Fieldterminator = ',',
Tablock
); 
Set @End_Time = GETDATE();
print'>>>Load Duration : '+ Cast(datediff(second, @start_time, @End_time)As Nvarchar ) + ' Seconds' ;
print'>>>-------------';



Set @start_Time = GETDATE();
print'>> Truncating Table : bronze.crm_prd_info';
Truncate Table bronze.crm_prd_info ;

print'>> Inserting data into: bronze.crm_prd_info';
Bulk Insert bronze.crm_prd_info
from 'E:\My n8n\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
With(
firstrow  = 2 ,
Fieldterminator = ',',
Tablock
);
Set @End_Time = GETDATE();
print'>>>Load Duration : '+ Cast(datediff(second, @start_time, @End_time)As Nvarchar ) + ' Seconds' ;
print'>>>-------------';



Set @start_Time = GETDATE();
print'>> Truncating Table : bronze.crm_cust_info';
Truncate Table bronze.crm_sales_details ;

print'>> Inserting data into:bronze.crm_sales_details ';
Bulk Insert bronze.crm_sales_details
from 'E:\My n8n\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
With(
firstrow  = 2 ,
Fieldterminator = ',',
Tablock 
);
Set @End_Time = GETDATE();
print'>>>Load Duration : '+ Cast(datediff(second, @start_time, @End_time)As Nvarchar ) + ' Seconds' ;
print'>>>-------------';



print '--------------------------------------';
print 'Loding ERP Tables';
print '--------------------------------------';


Set @start_Time = GETDATE();
print'>> Truncating Table : bronze.erp_CUST_AZ12';
Truncate Table bronze.erp_CUST_AZ12 ;

print'>> Inserting data into:bronze.erp_CUST_AZ12';
Bulk Insert bronze.erp_CUST_AZ12
from 'E:\My n8n\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
With(
firstrow  = 2 ,
Fieldterminator = ',',
Tablock 
);
Set @End_Time = GETDATE();
print'>>>Load Duration : '+ Cast(datediff(second, @start_time, @End_time)As Nvarchar ) + ' Seconds' ;
print'>>>-------------';


Set @start_Time = GETDATE();
print'>> Truncating Table : erp_LOC_A101';
Truncate Table bronze.erp_LOC_A101 ;

print'>> Inserting data into:bronze.erp_LOC_A101';
Bulk Insert bronze.erp_LOC_A101
from 'E:\My n8n\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
With(
firstrow  = 2 ,
Fieldterminator = ',',
Tablock 
);
Set @End_Time = GETDATE();
print'>>>Load Duration : '+ Cast(datediff(second, @start_time, @End_time)As Nvarchar ) + ' Seconds' ;
print'>>>-------------';


Set @start_Time = GETDATE();
print'>> Truncating Table : bronze.erp_PX_CAT_G1V2';
Truncate Table bronze.erp_PX_CAT_G1V2 ;

print'>> Inserting data into:erp_PX_CAT_G1V2';
Bulk Insert bronze.erp_PX_CAT_G1V2
from 'E:\My n8n\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
With(
firstrow  = 2 ,
Fieldterminator = ',',
Tablock 
);
Set @End_Time = GETDATE();
print'>>>Load Duration : '+ Cast(datediff(second, @start_time, @End_time)As Nvarchar ) + ' Seconds' ;
print'>>>-------------';

Set  @batch_End_time = GETDATE() ;
print'===========================================';
print'Loding Bronze Layer is Completed' ;
print'  -Total Load Duration ' + Cast(Datediff(Second,@batch_stat_time,@batch_End_time) As Nvarchar) + ' Seconds' ; 
print'==========================================='

End try 
Begin catch 
print'===========================================';
print 'Error OCCURED DURING lOADING BRONZE LAYER'
print 'Error Message ' + Error_message();
print 'Error Message ' + Cast (Error_Number() As Nvarchar );
print 'Error Message ' + Cast (Error_state() As Nvarchar );
End Catch
End 
