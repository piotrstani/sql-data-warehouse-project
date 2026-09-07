
/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None.
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
   CALL bronze.load_bronze();
===============================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    batch_start_time TIMESTAMP;
    batch_end_time TIMESTAMP;
	start_table_time TIMESTAMP;
	end_table_time TIMESTAMP;
    rows_before BIGINT;
    rows_after BIGINT;

BEGIN

    batch_start_time := clock_timestamp();
    RAISE NOTICE E'\n------------------------------------------------';
	RAISE NOTICE E'Loading Bronze Layer at: %', batch_start_time;  

-----------------------------------------------------------------------------------------CRM
	    start_time := clock_timestamp();
        RAISE NOTICE E'------------------------------------------------';
	    RAISE NOTICE E'Loading CRM Tables at: %', start_time;   	

-----------------------------------------------------------------------------------------crm_cust_info	
		RAISE NOTICE E'------------------------------------------------';
	    RAISE NOTICE E'\t>> Truncating Table: bronze.crm_cust_info';
				
	   		    EXECUTE 'TRUNCATE TABLE bronze.crm_cust_info';
  
		start_table_time := clock_timestamp();	 
	    RAISE NOTICE E'\t>> Inserting Data Into: bronze.crm_cust_info at: %', start_table_time;   	

		    EXECUTE '
		        COPY bronze.crm_cust_info
		        FROM ''/data/source_crm/cust_info.csv''
		        WITH (
		            FORMAT csv,
		            HEADER true,
		            DELIMITER '',''
		        )';


		--Liczba rekordów po COPY
		GET DIAGNOSTICS rows_after = ROW_COUNT;

		end_table_time := clock_timestamp();
    	RAISE NOTICE E'\t>> Load Duration: % miliseconds', EXTRACT(EPOCH FROM (end_table_time - start_table_time)) * 1000 ::BIGINT;
 		RAISE NOTICE E'\t>> Records loaded by COPY: %', rows_after;
-----------------------------------------------------------------------------------------crm_cust_info

-----------------------------------------------------------------------------------------crm_prd_info
	    RAISE NOTICE E'------------------------------------------------';
	    RAISE NOTICE E'\t>> Truncating Table: bronze.crm_prd_info';
				
	   		    EXECUTE 'TRUNCATE TABLE bronze.crm_prd_info';

		start_table_time := clock_timestamp();	
	    RAISE NOTICE E'\t>> Inserting Data Into: bronze.crm_prd_info at: %', start_table_time;

		    EXECUTE '
				COPY bronze.crm_prd_info
				FROM ''/data/source_crm/prd_info.csv''
				WITH (
				    FORMAT csv,
				    HEADER true,
				    DELIMITER '',''
				) ';


		--Liczba rekordów po COPY
		GET DIAGNOSTICS rows_after = ROW_COUNT;

		end_table_time := clock_timestamp();
    	RAISE NOTICE E'\t>> Load Duration: % miliseconds', EXTRACT(EPOCH FROM (end_table_time - start_table_time)) * 1000 ::BIGINT;
 		RAISE NOTICE E'\t>> Records loaded by COPY: %', rows_after;
-----------------------------------------------------------------------------------------crm_prd_info

-----------------------------------------------------------------------------------------crm_sales_details
	    RAISE NOTICE E'------------------------------------------------';
	    RAISE NOTICE E'\t>> Truncating Table: bronze.crm_sales_details';
				
	   		    EXECUTE 'TRUNCATE TABLE bronze.crm_sales_details';
	
		start_table_time := clock_timestamp();	
	    RAISE NOTICE E'\t>> Inserting Data Into: bronze.crm_sales_details at: %', start_table_time;

		    EXECUTE '
				COPY bronze.crm_sales_details
				FROM ''/data/source_crm/sales_details.csv''
				WITH (
				    FORMAT csv,
				    HEADER true,
				    DELIMITER '',''
				) ';


		--Liczba rekordów po COPY
		GET DIAGNOSTICS rows_after = ROW_COUNT;

		end_table_time := clock_timestamp();
    	RAISE NOTICE E'\t>> Load Duration: % miliseconds', EXTRACT(EPOCH FROM (end_table_time - start_table_time)) * 1000 ::BIGINT;
 		RAISE NOTICE E'\t>> Records loaded by COPY: %', rows_after;
-----------------------------------------------------------------------------------------crm_sales_details


-----------------------------------------------------------------------------------------ERP
	    start_time := clock_timestamp();
        RAISE NOTICE E'------------------------------------------------';
	    RAISE NOTICE E'Loading ERP Tables at: %', start_time;  

-----------------------------------------------------------------------------------------erp_loc_a101
	    RAISE NOTICE E'------------------------------------------------';
	    RAISE NOTICE E'\t>> Truncating Table: bronze.erp_loc_a101';
				
	   		    EXECUTE 'TRUNCATE TABLE bronze.erp_loc_a101';	

		start_table_time := clock_timestamp();	
	    RAISE NOTICE E'\t>> Inserting Data Into: bronze.erp_loc_a101 at: %', start_table_time;
	
			    EXECUTE '
					COPY bronze.erp_loc_a101
					FROM ''/data/source_erp/LOC_A101.csv''
					WITH (
					    FORMAT csv,
					    HEADER true,
					    DELIMITER '',''
					) ';


		--Liczba rekordów po COPY
		GET DIAGNOSTICS rows_after = ROW_COUNT;

		end_table_time := clock_timestamp();
    	RAISE NOTICE E'\t>> Load Duration: % miliseconds', EXTRACT(EPOCH FROM (end_table_time - start_table_time)) * 1000 ::BIGINT;
 		RAISE NOTICE E'\t>> Records loaded by COPY: %', rows_after;
-----------------------------------------------------------------------------------------erp_loc_a101

-----------------------------------------------------------------------------------------erp_cust_az12
	    RAISE NOTICE E'------------------------------------------------';
	    RAISE NOTICE E'\t>> Truncating Table: bronze.erp_cust_az12';
				
	   		    EXECUTE 'TRUNCATE TABLE bronze.erp_cust_az12';

		start_table_time := clock_timestamp();	
	    RAISE NOTICE E'\t>> Inserting Data Into: bronze.erp_cust_az12 at: %', start_table_time;

			    EXECUTE '
					COPY bronze.erp_cust_az12
					FROM ''/data/source_erp/CUST_AZ12.csv''
					WITH (
					    FORMAT csv,
					    HEADER true,
					    DELIMITER '',''
					) ';


		--Liczba rekordów po COPY
		GET DIAGNOSTICS rows_after = ROW_COUNT;

		end_table_time := clock_timestamp();
     	RAISE NOTICE E'\t>> Load Duration: % miliseconds', EXTRACT(EPOCH FROM (end_table_time - start_table_time)) * 1000 ::BIGINT;
 		RAISE NOTICE E'\t>> Records loaded by COPY: %', rows_after;
-----------------------------------------------------------------------------------------erp_cust_az12
-----------------------------------------------------------------------------------------erp_px_cat_g1v2
	    RAISE NOTICE E'------------------------------------------------';
	    RAISE NOTICE E'\t>> Truncating Table: bronze.erp_px_cat_g1v2';
				
	   		    EXECUTE 'TRUNCATE TABLE bronze.erp_px_cat_g1v2';

		start_table_time := clock_timestamp();	
	    RAISE NOTICE E'\t>> Inserting Data Into: bronze.erp_px_cat_g1v2 at: %', start_table_time;

			    EXECUTE '
					COPY bronze.erp_px_cat_g1v2
					FROM ''/data/source_erp/PX_CAT_G1V2.csv''
					WITH (
					    FORMAT csv,
					    HEADER true,
					    DELIMITER '',''
					) ';


		--Liczba rekordów po COPY
		GET DIAGNOSTICS rows_after = ROW_COUNT;

		end_table_time := clock_timestamp();
    	RAISE NOTICE E'\t>> Load Duration: % miliseconds', EXTRACT(EPOCH FROM (end_table_time - start_table_time)) * 1000 ::BIGINT;
 		RAISE NOTICE E'\t>> Records loaded by COPY: %', rows_after;
-----------------------------------------------------------------------------------------erp_px_cat_g1v2

 batch_end_time := clock_timestamp();
 RAISE NOTICE '------------------------------------------------';
 RAISE NOTICE '%', format('%-45s %s','Loading Bronze Layer Started at:', batch_start_time);
 RAISE NOTICE '%', format('%-45s %s','Loading Bronze Layer is Completed at:', batch_end_time);
 RAISE NOTICE '>> Total Batch Duration: % miliseconds',
 	EXTRACT(EPOCH FROM (batch_end_time - batch_start_time)) * 1000 ::BIGINT;


EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Błąd: %', SQLERRM;
        RAISE NOTICE 'Kod błędu: %', SQLSTATE;


END;
$$;



