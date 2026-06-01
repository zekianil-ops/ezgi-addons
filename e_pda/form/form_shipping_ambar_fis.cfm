<!---
    File: form_shipping_ambar_fis.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cf_xml_page_edit>
<cfparam name="attributes.anamenu" default="1">
<cfset default_process_type = 113>
<cfquery name="get_period_id" datasource="#dsn#">
    	SELECT TOP(1)       
        	PERIOD_YEAR
		FROM            
        	SETUP_PERIOD
		WHERE        
        	OUR_COMPANY_ID = #session.ep.company_id# AND 
            PERIOD_YEAR < #session.ep.period_year#
        ORDER BY
        	PERIOD_YEAR desc
</cfquery>
<cfquery name="get_defaults" datasource="#dsn3#">
  SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfquery name="get_process_cat" datasource="#DSN3#">
	  SELECT TOP (1)    
		  SPC.PROCESS_CAT_ID
	  FROM         
		  SETUP_PROCESS_CAT AS SPC INNER JOIN
			SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
		  SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	  WHERE     
		  SPC.PROCESS_TYPE = #default_process_type# AND 
		  SPCF.FUSE_NAME = 'pda.form_shipping_ambar_stock' 
		ORDER BY
		  SPC.PROCESS_CAT_ID DESC      
  </cfquery>
  <cfif not get_process_cat.recordcount>
	  <script type="text/javascript">
		  alert("<cf_get_lang dictionary_id='333.İşlem Kategorisi Tanımlayınız!'>");
		  history.back();	
	  </script>
  </cfif>
<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT 
    	D.DEPARTMENT_HEAD,
     	D.BRANCH_ID,
      	SL.DEPARTMENT_ID,
   		SL.LOCATION_ID,
      	SL.STATUS,
     	SL.COMMENT,
        CAST(SL.DEPARTMENT_ID AS VARCHAR)+'-'+CAST(SL.LOCATION_ID AS VARCHAR) AS DEPO,
        D.DEPARTMENT_HEAD+'-'+SL.COMMENT AS DEPO_NAME,
        ISNULL((SELECT COUNT(*) AS SAYI FROM #dsn3_alias#.PRODUCT_PLACE WHERE STORE_ID = SL.DEPARTMENT_ID AND LOCATION_ID = SL.LOCATION_ID),0) AS RAFLI
  	FROM 
    	STOCKS_LOCATION SL,
      	DEPARTMENT D,
    	BRANCH B
 	WHERE
     	SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
      	SL.STATUS = 1 AND
   		D.BRANCH_ID = B.BRANCH_ID
</cfquery>
<cfquery name="get_in_depo" dbtype="query">
	SELECT * FROM GET_ALL_LOCATION WHERE DEPO = '#attributes.department_in_id#'
</cfquery>
<cfquery name="get_out_depo" dbtype="query">
	SELECT * FROM GET_ALL_LOCATION WHERE DEPO = '#attributes.department_out_id#'
</cfquery>
<cfset last_year = session.ep.period_year -1> 
<cfif attributes.is_type eq 1>
    <cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
        SELECT     
        	PAKET_SAYISI AS PAKETSAYISI, 
            PAKET_ID AS STOCK_ID, 
            BARCOD, 
            STOCK_CODE, 
            PRODUCT_ID,
            PRODUCT_NAME,
            SPECT_MAIN_ID,
         	ISNULL((
            		SELECT 
                  		SUM(CONTROL_AMOUNT) CONTROL_AMOUNT
                   	FROM
                     	( 
                       	SELECT        
                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                        FROM   
                            #dsn2_alias#.STOCK_FIS AS SF INNER JOIN
                            #dsn2_alias#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                            SPECTS AS SP ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                            STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                        WHERE        
                            SF.FIS_TYPE = 113 AND 
                            SF.REF_NO = '#attributes.DELIVER_PAPER_NO#' AND 
                            SFR.STOCK_ID = TBL.PAKET_ID AND
                            ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                            ISNULL(S.IS_PROTOTYPE,0) = 1
                            <cfif get_period_id.recordcount>
                            	UNION ALL
                            	SELECT        
                                    SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                                FROM   
                                    #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF INNER JOIN
                                    #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                                    SPECTS AS SP ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                                    STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                                WHERE        
                                    SF.FIS_TYPE = 113 AND 
                                    SF.REF_NO = '#attributes.DELIVER_PAPER_NO#' AND 
                                    SFR.STOCK_ID = TBL.PAKET_ID AND
                                    ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                                    ISNULL(S.IS_PROTOTYPE,0) = 1
                            </cfif>
                        UNION ALL
                        SELECT        
                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                        FROM   
                            #dsn2_alias#.STOCK_FIS AS SF INNER JOIN
                            #dsn2_alias#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                            STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                        WHERE        
                            SF.FIS_TYPE = 113 AND 
                            SF.REF_NO = '#attributes.DELIVER_PAPER_NO#' AND 
                            SFR.STOCK_ID = TBL.PAKET_ID AND
                            ISNULL(S.IS_PROTOTYPE,0) = 0
                            <cfif get_period_id.recordcount>
                            	UNION ALL
                                SELECT        
                                    SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                                FROM   
                                    #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF INNER JOIN
                                    #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                                    STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                                WHERE        
                                    SF.FIS_TYPE = 113 AND 
                                    SF.REF_NO = '#attributes.DELIVER_PAPER_NO#' AND 
                                    SFR.STOCK_ID = TBL.PAKET_ID AND
                                    ISNULL(S.IS_PROTOTYPE,0) = 0
                            </cfif>
                		) AS TBL_5
        	),0) AS CONTROL_AMOUNT,
            ISNULL((
            		SELECT        
                    	T.PRODUCT_STOCK
					FROM            
                    	#dsn2_alias#.EZGI_GET_STOCK_LOCATION_TOTAL T INNER JOIN
                        STOCKS S ON S.STOCK_ID=T.STOCK_ID
					WHERE        
                    	T.DEPO = '#attributes.department_out_id#' AND 
                        T.STOCK_ID = TBL.PAKET_ID AND
                        ISNULL(S.IS_PROTOTYPE,0) = 0
                  	UNION ALL
                    SELECT        
                    	T.PRODUCT_STOCK
					FROM            
                    	#dsn2_alias#.EZGI_GET_SPECT_LOCATION_TOTAL T INNER JOIN
                        STOCKS S ON S.STOCK_ID=T.STOCK_ID
					WHERE        
                    	T.DEPO = '#attributes.department_out_id#' AND 
                        T.SPECT_MAIN_ID = TBL.SPECT_MAIN_ID AND
                        T.STOCK_ID = TBL.PAKET_ID AND
                        ISNULL(S.IS_PROTOTYPE,0) = 1
                    
            ),0) AS DEPO,
  			(
            	SELECT TOP (1)
                 	ET.SHELF_CODE
            	FROM     
               		#dsn2_alias#.EZGI_GET_SPECT_SHELF_LOCATION_TOTAL ET INNER JOIN
                 	STOCKS S ON S.STOCK_ID=ET.STOCK_ID
         		WHERE  
                	ISNULL(S.IS_PROTOTYPE,0) = 1 AND
                 	ET.DEPO = '#attributes.department_out_id#' AND 
                 	ET.STOCK_ID = TBL.PAKET_ID AND
                	ET.REAL_STOCK > 0 AND 
                 	ET.SPECT_MAIN_ID = TBL.SPECT_MAIN_ID
              	UNION ALL
                SELECT TOP (1)
                 	ET.SHELF_CODE
            	FROM     
               		#dsn2_alias#.EZGI_GET_SPECT_SHELF_LOCATION_TOTAL ET INNER JOIN
                 	STOCKS S ON S.STOCK_ID=ET.STOCK_ID
         		WHERE  
                	ISNULL(S.IS_PROTOTYPE,0) = 0 AND
                 	ET.DEPO = '#attributes.department_out_id#' AND 
                 	ET.STOCK_ID = TBL.PAKET_ID AND
                	ET.REAL_STOCK > 0
              	ORDER BY
                	REAL_STOCK DESC
            ) AS SHELF_CODE,
            SHIP_RESULT_ID
		FROM         
        	(
            SELECT
            	SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                PAKET_ID, 
                PRODUCT_ID,
                BARCOD, 
                STOCK_CODE, 
                PRODUCT_NAME, 
                SHIP_RESULT_ID,
                SPECT_MAIN_ID
           	FROM
            	(     
                SELECT     
                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_ID, 
                    ESR.SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID,
                    0 AS SPECT_MAIN_ID
                FROM          
                 	STOCKS AS S1 INNER JOIN
                 	EZGI_SHIP_RESULT AS ESR INNER JOIN
                  	EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                  	ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
                  	STOCKS AS S INNER JOIN
                 	EZGI_PAKET_SAYISI AS EPS ON S.STOCK_ID = EPS.PAKET_ID ON S1.STOCK_ID = EPS.MODUL_ID
                WHERE      
                    ESR.SHIP_RESULT_ID = #attributes.ship_id# AND
                    ISNULL(S1.IS_PROTOTYPE,0) = 0
                GROUP BY 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_ID, 
                    ESR.SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID
              	UNION ALL
                SELECT
                	SUM(ORR.QUANTITY) AS PAKET_SAYISI, 
                    S1.STOCK_ID AS PAKET_ID,
                    S1.BARCOD,
                    S1.STOCK_CODE,
                    S1.PRODUCT_NAME,
                    S1.PRODUCT_ID,
                	ESR.SHIP_RESULT_ID, 
                    ESRR.ORDER_ROW_ID, 
                    SP.SPECT_MAIN_ID
				FROM            
                	SPECTS AS SP INNER JOIN
                    EZGI_SHIP_RESULT AS ESR INNER JOIN
                    EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                    STOCKS AS S1 ON ORR.STOCK_ID = S1.STOCK_ID
				WHERE        
                	ESR.SHIP_RESULT_ID = #attributes.ship_id# AND 
                    ISNULL(S1.IS_PROTOTYPE, 0) = 1
				GROUP BY 
                	S1.STOCK_ID,
                	SP.SPECT_MAIN_ID, 
                    ESR.SHIP_RESULT_ID, 
                    ESRR.ORDER_ROW_ID, 
                    S1.STOCK_CODE, 
                    S1.PRODUCT_NAME,
                    S1.PRODUCT_ID, 
                    S1.BARCOD
             	) AS TBL1
          	GROUP BY
            	PAKET_ID, 
                BARCOD, 
                PRODUCT_ID,
                STOCK_CODE, 
                PRODUCT_NAME, 
                SHIP_RESULT_ID,
                SPECT_MAIN_ID
        	) AS TBL
		ORDER BY
			SHELF_CODE
  	</cfquery>
<cfelse>
   	<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
    	SELECT     
        	PAKET_SAYISI AS PAKETSAYISI, 
            PAKET_ID AS STOCK_ID, 
            BARCOD, 
            STOCK_CODE, 
            PRODUCT_ID,
            PRODUCT_NAME,
            SPECT_MAIN_ID,
         	ISNULL((
            		SELECT 
                  		SUM(CONTROL_AMOUNT) CONTROL_AMOUNT
                   	FROM
                     	( 
                       	SELECT        
                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                        FROM   
                                   
                            #dsn2_alias#.STOCK_FIS AS SF INNER JOIN
                            #dsn2_alias#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                            SPECTS AS SP ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                            STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                        WHERE        
                            SF.FIS_TYPE = 113 AND 
                            SF.REF_NO = '#attributes.DELIVER_PAPER_NO#' AND 
                            SFR.STOCK_ID = TBL.PAKET_ID AND
                            ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                            ISNULL(S.IS_PROTOTYPE,0) = 1
                       		<cfif get_period_id.recordcount>
                            	UNION ALL
                            	SELECT        
                                    SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                                FROM   
                                           
                                    #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF INNER JOIN
                                    #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                                    SPECTS AS SP ON SP.SPECT_VAR_ID = SFR.SPECT_VAR_ID INNER JOIN
                                    STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                                WHERE        
                                    SF.FIS_TYPE = 113 AND 
                                    SF.REF_NO = '#attributes.DELIVER_PAPER_NO#' AND 
                                    SFR.STOCK_ID = TBL.PAKET_ID AND
                                    ISNULL(SP.SPECT_MAIN_ID,0) = TBL.SPECT_MAIN_ID AND
                                    ISNULL(S.IS_PROTOTYPE,0) = 1
                            </cfif>
                        UNION ALL
                        SELECT        
                            SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                        FROM   
                            #dsn2_alias#.STOCK_FIS AS SF INNER JOIN
                            #dsn2_alias#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                            STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                        WHERE        
                            SF.FIS_TYPE = 113 AND 
                            SF.REF_NO = '#attributes.DELIVER_PAPER_NO#' AND 
                            SFR.STOCK_ID = TBL.PAKET_ID AND
                            ISNULL(S.IS_PROTOTYPE,0) = 0
                            <cfif get_period_id.recordcount>
                            	UNION ALL
                                SELECT        
                                    SUM(SFR.AMOUNT) AS CONTROL_AMOUNT
                                FROM   
                                    #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF INNER JOIN
                                    #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                                    STOCKS S ON SFR.STOCK_ID=S.STOCK_ID
                                WHERE        
                                    SF.FIS_TYPE = 113 AND 
                                    SF.REF_NO = '#attributes.DELIVER_PAPER_NO#' AND 
                                    SFR.STOCK_ID = TBL.PAKET_ID AND
                                    ISNULL(S.IS_PROTOTYPE,0) = 0
                            </cfif>
                		) AS TBL_5
        	),0) AS CONTROL_AMOUNT,
            ISNULL((
            		SELECT        
                    	T.PRODUCT_STOCK
					FROM            
                    	#dsn2_alias#.EZGI_GET_STOCK_LOCATION_TOTAL T INNER JOIN
                        STOCKS S ON S.STOCK_ID=T.STOCK_ID
					WHERE        
                    	T.DEPO = '#attributes.department_out_id#' AND 
                        T.STOCK_ID = TBL.PAKET_ID AND
                        ISNULL(S.IS_PROTOTYPE,0) = 0
            ),0) AS DEPO,
     		(
            	SELECT TOP (1)
                 	ET.SHELF_CODE
            	FROM     
               		#dsn2_alias#.EZGI_GET_SPECT_SHELF_LOCATION_TOTAL ET INNER JOIN
                 	STOCKS S ON S.STOCK_ID=ET.STOCK_ID
         		WHERE  
                	ISNULL(S.IS_PROTOTYPE,0) = 1 AND
                 	ET.DEPO = '#attributes.department_out_id#' AND 
                 	ET.STOCK_ID = TBL.PAKET_ID AND
                	ET.REAL_STOCK > 0 AND 
                 	ET.SPECT_MAIN_ID = TBL.SPECT_MAIN_ID
              	UNION ALL
                SELECT TOP (1)
                 	ET.SHELF_CODE
            	FROM     
               		#dsn2_alias#.EZGI_GET_SPECT_SHELF_LOCATION_TOTAL ET INNER JOIN
                 	STOCKS S ON S.STOCK_ID=ET.STOCK_ID
         		WHERE  
                	ISNULL(S.IS_PROTOTYPE,0) = 0 AND
                 	ET.DEPO = '#attributes.department_out_id#' AND 
                 	ET.STOCK_ID = TBL.PAKET_ID AND
                	ET.REAL_STOCK > 0
              	ORDER BY
                	REAL_STOCK DESC
            ) AS SHELF_CODE,
            SHIP_RESULT_ID
		FROM         
        	(
            SELECT
            	SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                PAKET_ID, 
                PRODUCT_ID,
                BARCOD, 
                STOCK_CODE, 
                PRODUCT_NAME, 
                SHIP_RESULT_ID,
                SPECT_MAIN_ID
           	FROM
            	(  
                SELECT     
                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_ID, 
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID,
                    0 AS SPECT_MAIN_ID
                FROM          
                 	STOCKS AS S1 INNER JOIN
                 	EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                  	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                  	ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
                  	STOCKS AS S INNER JOIN
                 	EZGI_PAKET_SAYISI AS EPS ON S.STOCK_ID = EPS.PAKET_ID ON S1.STOCK_ID = EPS.MODUL_ID
                WHERE      
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
                    ISNULL(S1.IS_PROTOTYPE,0) = 0
                GROUP BY 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_ID, 
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                    ESRR.ORDER_ROW_ID
              	UNION ALL
                SELECT
                	SUM(ORR.QUANTITY) AS PAKET_SAYISI, 
                    S1.STOCK_ID AS PAKET_ID,
                    S1.BARCOD,
                    S1.STOCK_CODE,
                    S1.PRODUCT_NAME,
                    S1.PRODUCT_ID,
                	ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID, 
                    ESRR.ORDER_ROW_ID, 
                    SP.SPECT_MAIN_ID
				FROM            
                	SPECTS AS SP INNER JOIN
                    EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                    EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                    STOCKS AS S1 ON ORR.STOCK_ID = S1.STOCK_ID
				WHERE        
                	ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND 
                    ISNULL(S1.IS_PROTOTYPE, 0) = 1
				GROUP BY 
                	S1.STOCK_ID,
                	SP.SPECT_MAIN_ID, 
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID, 
                    ESRR.ORDER_ROW_ID, 
                    S1.STOCK_CODE, 
                    S1.PRODUCT_NAME,
                    S1.PRODUCT_ID, 
                    S1.BARCOD
             	) AS TBL1
          	GROUP BY
            	PAKET_ID, 
                BARCOD, 
                PRODUCT_ID,
                STOCK_CODE, 
                PRODUCT_NAME, 
                SHIP_RESULT_ID,
                SPECT_MAIN_ID
        	) AS TBL
		ORDER BY
			SHELF_CODE
    </cfquery>
</cfif>
<!---<cfdump var="#GET_SHIP_PACKAGE_LISt#">--->
<cfquery name="get_total_control" dbtype="query">
	SELECT sum(CONTROL_AMOUNT) AS CONTROL_AMOUNT FROM GET_SHIP_PACKAGE_LIST
</cfquery>
<cfquery name="get_total_package" dbtype="query">
	SELECT sum(PAKETSAYISI) PAKETSAYISI FROM GET_SHIP_PACKAGE_LIST
</cfquery>
<cfquery name="get_detail_package_group" dbtype="query">
	SELECT
    	SPECT_MAIN_ID,
        STOCK_ID,
        COUNT(*) AS CONTROL_AMOUNT
  	FROM
   		GET_SHIP_PACKAGE_LIST
  	GROUP BY
    	SPECT_MAIN_ID,
        STOCK_ID	 	
</cfquery>
<cfif get_out_depo.RAFLI gt 0>
	<cfset rafli =1>
<cfelse>
	<cfset rafli =0>
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfform name="shipping_ambar_fis" >
    	<cf_box>
         	<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
            <cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
            <cfinput id="precess_no" type="hidden" name="precess_no" value="0">
          	<input type="hidden" name="active_period" value="#session.ep.period_id#" />
            <cf_basket_form id="shipping_ambar_fis">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
                         	<cf_box_elements>
                            	<div class="col col-12 uniqueRow" id="first_area">
                                	<div class="col col-12">
                                    	<div class="col col-2">
                                            <label>Miktar</label>
                                        </div>
                                        <div class="col col-5">
                                            <label>Barkod</label>
                                        </div>
                                        <div class="col col-5" id="item-shelf_head" <cfif rafli eq 0> style=" display:none"</cfif>>
                                            <label>Raf</label>
                                        </div>
                                    </div>
                                    <div class="col col-12">
                                    	<div class="col col-2">
                                            <div class="form-group" id="item-amount">
                                                <input id="add_other_amount" name="add_other_amount" type="text" value="1" style="width:25px;text-align:right;font-weight:bold;color:FF0000;" <cfif get_defaults.IS_AMOUNT_INPUT_FREE>readonly</cfif>>
                                            </div>
                                        </div>
                                        <div class="col col-5">
                                            <div class="form-group" id="item-barcod">
                                                <input id="add_other_barcod" name="add_other_barcod" type="text" value="">
                                            </div>
                                        </div>
                                        <div class="col col-5" <cfif rafli eq 0> style=" display:none"</cfif>>
                                            <div class="form-group" id="item-shelf">
                                                <input id="add_other_shelf" name="add_other_shelf" type="text" value="">
                                            </div>
                                        </div>
                                    </div>
                               	</div>
                                <div class="col col-12" id="third_area" style=" display:none">
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='29428.Çıkış Depo'></label>
                                        </div>
                                        <div class="col col-9" id="second_area_2">
                                            <div class="form-group" id="item-cikis">
                                            	<cfinput type="text" name="txt_department_out_name" id="txt_department_out_name" value="#get_out_depo.DEPO_NAME#">
                                                <cfinput type="hidden" name="txt_department_out" id="txt_department_out" value="#get_out_depo.DEPO#">
                                       		</div>
                                        </div>
                                    </div>
                             	</div>
                                <div class="col col-12" id="forth_area" style=" display:none">
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='1316.Sevkiyat Alanı'></label>
                                        </div>
                                 		<div class="col col-9">
                                            <div class="form-group" id="item-giris">
                                            	<cfinput type="text" name="txt_department_in_name" id="txt_department_in_name" value="#get_in_depo.DEPO_NAME#" readonly="">
                                                <cfinput type="hidden" name="txt_department_in" id="txt_department_in" value="#get_in_depo.DEPO#">
                                           	</div>
                                        </div>
                                    </div>
                             	</div>
                                <div class="col col-12" id="fourth_area">
                                    <div class="col col-12">
                                        <cfoutput>
                                      	<div class="col col-6">
                                            <div class="form-group" id="item-serial_control">
                                                <input type="text" name="total_control_amount" readonly="readonly" class="box" style="width:25px;text-align:right;font-weight:bold;color:FF0000;" id="total_control_amount" value="#get_total_control.CONTROL_AMOUNT#" />
                                            </div>
                                        </div>
                                        <div class="col col-6">
                                            <div class="form-group" id="item-serial_controled">
                                            	<input type="text" name="total_paket_sayisi" readonly="readonly" class="box" style="width:25px;text-align:right;font-weight:bold;color:FF0000;" id="total_paket_sayisi" value="#get_total_package.PAKETSAYISI#" />
                                       		</div>
                                        </div>
                                        </cfoutput>
                                    </div>
                              	</div>
               				</cf_box_elements>
                    		<cf_box_footer>
                            	<div class="col col-12">
                                    <div class="col col-6" style="text-align:right">
                                	</div>
                                    <div class="col col-3" style="text-align:right;display:none" id="onay_div">
                                        <input id="onay" name="Onay" style="width:100%" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" onClick="kontrol_kayit(1);" />
                                 	</div>
                                    <div class="col col-3" style="text-align:right;" id="vazgec_div">
                                        <input id="vazgec" name="vazgec" style="background-color:red; color:white; width:100%" value="<cf_get_lang dictionary_id="57462.Vazgeç">" type="button" onClick="kontrol_kayit(2);" />
                                 	</div>
                              	</div>
              				</cf_box_footer>
                       	</div>
                  	</div>
              	</div>
    		</cf_basket_form>
      	</cf_box>
        <cfsavecontent variable="sekme1">Sevk Edilecek Paketler</cfsavecontent>
        <cfsavecontent variable="sekme2">Sevk Edilmiş Paketler</cfsavecontent>
        <div id="basket_main_div">
        	<div class="row">
                <div class="col col-12 uniqueRow">
                    <cf_basket_form id="upd_connect" class="row">
                        <div id="tab-container" class="tabStandart margin-top-5">
                            <div id="tab-head">
                                <ul class="tabNav">
                                    <li class="<cfif attributes.anamenu eq 1>active</cfif>"><a id="href_urunler" href="#ship_list"><cfoutput>#sekme1#</cfoutput></a></li>
                                    <li class="<cfif attributes.anamenu eq 2>active</cfif>"><a id="href_minfo" href="#icerik"><cfoutput>#sekme2#</cfoutput></a></li>
                                </ul>
                            </div>
                            <div id="tab-content" class="margin-top-10"> 
                                <div id="ship_list" class="content row">
                                	<cfsavecontent variable="title"><cfif attributes.is_type eq 1><b><cf_get_lang dictionary_id='382.Sevk Plan No'> :</b><cfelse><b><cf_get_lang dictionary_id='375.Sevk Talep No'> :</b></cfif><cfoutput>#attributes.DELIVER_PAPER_NO#</cfoutput></cfsavecontent>
                                    <cf_box title="#title#">
                                        <cf_grid_list>
                                            <thead>
                                                <tr>
                                                    <cfif rafli eq 1>
                                                    	<th style="width:100px"><cf_get_lang dictionary_id='45254.Raf No'></th>
                                                    </cfif>
                                                    <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                                    <th style="width:25px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                                    <th style="width:20px"><cf_get_lang dictionary_id='45358.Kontrol'></th>
                                                    <!-- sil -->
                                                    <th style="width:20px">&nbsp;&nbsp;&nbsp;</th>
                                                    <!-- sil -->
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <cfif GET_SHIP_PACKAGE_LIST.recordcount>
                                                    <cfoutput query="GET_SHIP_PACKAGE_LIST">
                                                    	<cfquery name="get_shelf_code" datasource="#dsn3#">
                                                            SELECT
                                                                SHELF_CODE,
                                                                REAL_STOCK
                                                            FROM     
                                                                #dsn2_alias#.EZGI_GET_SPECT_SHELF_LOCATION_TOTAL
                                                            WHERE  
                                                                DEPO = '#attributes.department_out_id#' AND 
                                                                STOCK_ID = #STOCK_ID# AND
                                                                REAL_STOCK > 0
                                                                <cfif SPECT_MAIN_ID gt 0>
                                                                	AND SPECT_MAIN_ID = #SPECT_MAIN_ID#
                                                                </cfif>
                                                            ORDER BY
                                                                REAL_STOCK DESC
                                                        </cfquery>
                                                    	<cfif isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')>
															<cfset 'control_amount#currentrow#' = Evaluate('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')>
                                                       	<cfelse>
                                                        	<cfset 'control_amount#currentrow#' = ''>
                                                        </cfif>
                                                    	<cfinput type="hidden" name="row_control_#currentrow#" id="row_control_#currentrow#" value="#STOCK_ID#_#SPECT_MAIN_ID#" >
                                                        <tr id="row#currentrow#" height="20" <cfif PAKETSAYISI eq CONTROL_AMOUNT>style="display:none"</cfif>>
                                                        	<cfif rafli eq 1>
                                                        		<td style="text-align:right">
                                                                	<select name="shelf_code_list" style="width:100px; height:25px">
                                                                        <cfloop query="get_shelf_code">
                                                                            <option value="#get_shelf_code.currentrow#">#get_shelf_code.SHELF_CODE# - #get_shelf_code.REAL_STOCK#</option>
                                                                        </cfloop>
                                                                    </select>
                                                                </td>
                                                            </cfif>
                                                            <td>#product_name#<cfif SPECT_MAIN_ID gt 0><font color="red"> - #SPECT_MAIN_ID#</font></cfif></td>        
                                                                <input type="hidden" id="PRODUCT_NAME#currentrow#" name="PRODUCT_NAME#currentrow#" value="#PRODUCT_NAME#">
                                                            <td style="text-align:right">
                                                                <input type="text" name="amount#currentrow#" id="amount#currentrow#" value="#PAKETSAYISI#" readonly="yes" style="width:25px;text-align:right;">
                                                            </td>
                                                            <td style="text-align:right">
                                                                <input type="text" id="control_amount#currentrow#" name="control_amount#currentrow#" value="#CONTROL_AMOUNT#" class="box"  style="width:25px;text-align:right;color:FF0000;">
                                                            </td>
                                                            <td align="center" valign="middle">   
                                                            	<cfif CONTROL_AMOUNT eq 0>
                                                            		<img id="is_durum#currentrow#" src="images\caution_small.gif">   
                                                            	<cfelseif CONTROL_AMOUNT eq PAKETSAYISI>
                                                                	<img id="is_durum#currentrow#" src="images\c_ok.gif">
                                                               	<cfelseif CONTROL_AMOUNT neq PAKETSAYISI>
                                                                	<img id="is_durum#currentrow#" src="images\warning.gif">
                                                                </cfif>
                                                            </td>
                                                        </tr>
                                                    </cfoutput>
                                                </cfif>
                                            </tbody>
                                        </cf_grid_list>
                                    </cf_box>
                             	</div>
                                <div id="icerik" class="content row">
									<cf_box title="#title#">
                                        <cf_grid_list>
                                            <thead>
                                                <tr>
                                                	<th style="width:20px"></th>
                                                	<th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                    <th>Barkod</th>
                                                    <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                                    <cfif rafli eq 1>
                                                    	<th><cf_get_lang dictionary_id='37540.Raf Kodu'></th>
                                                    </cfif>
                                                    <th style="width:35px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                                </tr>
                                            </thead>
                                            <cfinput type="hidden" id="row_count_content" name="row_count_content" value="0">
                                            <input type="hidden" id="action_id" name="action_id" value="" />
                                         	<tbody name="table2" id="table2">
                                                    	
                                       		</tbody>
                                        </cf_grid_list>
                                    </cf_box>
                                </div>
                            </div>
                        </div>
                    </cf_basket_form>
                </div>
           	</div>                     
       	</div>                         
	</cfform>
</div>
<script language="javascript" type="text/javascript">
	document.getElementById('add_other_barcod').focus();
	setTimeout("document.getElementById('add_other_barcod').select();",1000);
	document.onkeydown = checkKeycode
	function checkKeycode(e) /*Barkod Okuyup Enter Basıldığında*/
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			if (document.getElementById('add_other_barcod').value.length == '') /*Barkod Boşsa*/
			{
				alert('<cf_get_lang dictionary_id='340.Önce Ürün Barkodu Okutunuz'>'); 
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcod').focus();	
			}
			else /*Barkod Doluysa*/
			{
				get_stock(document.getElementById('add_other_barcod').value);
			}
		}
	}
	function get_stock(barcode) /*Ürün Kontrolü*/
    {
		row_count_sevk = <cfoutput>#GET_SHIP_PACKAGE_LIST.recordcount#</cfoutput>;
		carpan = ''; birim = ''; barcod = ''; stockid = ''; productname = ''; spectmainid = 0; //ilk önce sıfırlıyoruz
		k_= 0;
		if(document.getElementById('add_other_amount').value.length == 0 || document.getElementById('add_other_amount').value==0)
		{
			alert('<cf_get_lang dictionary_id='29943.Lütfen miktar giriniz.'>');
			document.getElementById('add_other_amount').value = 1;
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus();
			k_=1;
			return false;
		}
	 	if(barcode.substr(0,1)=='j')//Bazı barkod okuyucular okuduktan sonra başına j harfi koyuyor kontrol için yapıldı
			barcode = barcode.substring(1,length(barcode));
		uzunluk = barcode.length;
		spectmainid = 0;
		ean = <cfoutput>#get_defaults.EAN#</cfoutput>;
		if(uzunluk > ean)
		{
			spectmainid = barcode.substring(ean,uzunluk);
			barcode = barcode.substring(0,ean);
		}
		if (k_ == 0)
     	{
			/*var new_sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER,S.PRODUCT_NAME,S.IS_PROTOTYPE FROM STOCKS_BARCODES AS SB INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '"+barcode+"'";*/
			/*var get_product = wrk_query(new_sql,'dsn3');*/
			
			var listParam = barcode;
			var get_product = wrk_safe_query('get_product_ezgi','dsn3',0,listParam);
		 	if (get_product.STOCK_ID == undefined)
		 	{
				ekle = 1;
				alert('<cf_get_lang dictionary_id='341.Ürün Bulunamadı'>');
				document.getElementById('add_other_amount').value = 1;
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcod').focus();
		 	}
		 	else
		 	{	
				if(get_product.IS_PROTOTYPE==1 && spectmainid==0)
				{
					alert('<cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'> : <cf_get_lang dictionary_id='36006.Spekt ID'>');
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus();
				}
				else
				{
					carpan = get_product.MULTIPLIER;
					birim = get_product.MAIN_UNIT;
					stockid = get_product.STOCK_ID;
					productname = get_product.PRODUCT_NAME;
				
				}
				buldum=0;
				for(i=1;i<=row_count_sevk;i++)
				{
					satir_spect = document.getElementById('row_control_'+i).value;
					seri_spect = stockid+'_'+spectmainid;
					if(satir_spect==seri_spect)
						buldum=i;
				}
				if(buldum==0)
				{
					alert('Paket Bu Sevkiyatın Ürünü Değildir. !');
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
					return false;
				}
				else
				{
					if((document.getElementById('add_other_amount').value*1)+(document.getElementById('control_amount'+buldum).value*1) > (document.getElementById('amount'+buldum).value*1))
					{
						alert(document.getElementById('PRODUCT_NAME'+buldum).value+' <cf_get_lang dictionary_id='379.Fazla Çıkış'>');
						document.getElementById('add_other_amount').value=1;
						document.getElementById('add_other_amount').focus();
					}
					else
					{
						<cfif rafli eq 1>
							document.getElementById('add_other_shelf').focus();
							if(document.getElementById('add_other_shelf').value.length > 0)
							{
								if(spectmainid>0)
								{
								  	/*var stock_sql = "SELECT REAL_STOCK FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE SHELF_CODE = '"+document.getElementById('add_other_shelf').value+"' AND DEPO = '"+document.all.txt_department_out.value+"' AND STOCK_ID = "+stockid+" AND SPECT_MAIN_ID = "+spectmainid;*/
									var listParam = document.getElementById('add_other_shelf').value + "*" + document.all.txt_department_out.value + "*" + stockid + "*" + spectmainid;
									var get_real_stock = wrk_safe_query('get_shelf_depo_stock_id_spectmain_shelf_ezgi','dsn2',0,listParam);
								}
							  	else
								{
								  /*var stock_sql = "SELECT REAL_STOCK FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE SHELF_CODE = '"+document.getElementById('add_other_shelf').value+"' AND DEPO = '"+document.all.txt_department_out.value+"' AND STOCK_ID = "+stockid;*/
									var listParam = document.getElementById('add_other_shelf').value + "*" + document.all.txt_department_out.value + "*" +stockid;
									var get_real_stock = wrk_safe_query('get_shelf_depo_stock_id_shelf_ezgi','dsn2',0,listParam);;	
								}
								/*var get_real_stock = wrk_query(stock_sql,'dsn2');*/
								
							  	if(get_real_stock.REAL_STOCK==undefined)
								  	get_real_stock.REAL_STOCK = 0;
								satir_amount=0;
								for(i=1;i<=row_count_content;i++)
								{
									
									seri_spect = stockid+'_'+spectmainid;
									satir_spect = document.getElementById('row_stock_control'+i).value;
									if(satir_spect==seri_spect && document.getElementById('add_other_shelf').value==document.getElementById('SHELF_CODE'+i).value)
										satir_amount=(satir_amount*1)+(document.getElementById('SEVK_AMOUNT'+i).value*1);
								}
								if((get_real_stock.REAL_STOCK*1) < ((document.getElementById('add_other_amount').value*1)+(satir_amount*1)))
								{
									ekle=1;
									alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. Raf Stok Miktarı : "+get_real_stock.REAL_STOCK);
									document.getElementById('add_other_shelf').value = '';
									document.getElementById('add_other_barcod').value = '';
									document.getElementById('add_other_amount').value = 1;
									document.getElementById('add_other_barcod').focus();
									return false;
								}
								else
								{
									document.getElementById('control_amount'+buldum).value = (document.getElementById('control_amount'+buldum).value*1)+(document.getElementById('add_other_amount').value*1);
									if(document.getElementById('control_amount'+buldum).value == document.getElementById('amount'+buldum).value)
										document.getElementById('row'+buldum).style.display='none';
									shelfcode = document.getElementById('add_other_shelf').value;
									amount = document.getElementById('add_other_amount').value;
									buton_kontrol();
									add_row(barcode,stockid,spectmainid,productname,shelfcode,amount);
									
									document.getElementById('total_control_amount').value = (document.getElementById('total_control_amount').value*1) + (document.getElementById('add_other_amount').value*1);
									document.getElementById('add_other_barcod').value = '';
									document.getElementById('add_other_shelf').value = '';
									document.getElementById('add_other_amount').value = 1;
									document.getElementById('add_other_barcod').focus();
								}
							}
						<cfelse>
							if(spectmainid>0)
							{
								/*var stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_SPECT_LOCATION_TOTAL WHERE DEPO = '"+document.all.txt_department_out.value+"' AND STOCK_ID = "+stockid+" AND SPECT_MAIN_ID = "+spectmainid;*/
								var listParam = document.all.txt_department_out.value + "*" + spectmainid;
								var get_real_stock = wrk_safe_query('get_depo_stock_spectmainid_ezgi','dsn2',0,listParam);
							}
							else
							{
								/*var stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL WHERE DEPO = '"+document.all.txt_department_out.value+"' AND STOCK_ID = "+stockid;*/
								var listParam = document.all.txt_department_out.value + "*" + stockid;
								var get_real_stock = wrk_safe_query('get_depo_stock_stock_id_ezgi','dsn2',0,listParam);
							}
							/*var get_real_stock = wrk_query(stock_sql,'dsn2');*/
							
							if(get_real_stock.PRODUCT_STOCK==undefined)
								get_real_stock.PRODUCT_STOCK = 0;

							if((get_real_stock.PRODUCT_STOCK*1) < (document.getElementById('control_amount'+buldum).value*1)+(document.getElementById('add_other_amount').value*1))
							{
									ekle=1;
									alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. Depo Stok Miktarı : "+get_real_stock. PRODUCT_STOCK);
									document.getElementById('add_other_barcod').value = '';
									document.getElementById('add_other_amount').value = 1;
									document.getElementById('add_other_barcod').focus();
									return false;
							}
							else
							{
									
									document.getElementById('control_amount'+buldum).value = (document.getElementById('control_amount'+buldum).value*1)+(document.getElementById('add_other_amount').value*1);
									if(document.getElementById('control_amount'+buldum).value == document.getElementById('amount'+buldum).value)
										document.getElementById('row'+buldum).style.display='none';
									shelfcode = '';
									amount = document.getElementById('add_other_amount').value;
									buton_kontrol();
									add_row(barcode,stockid,spectmainid,productname,shelfcode,amount);
									document.getElementById('total_control_amount').value = (document.getElementById('total_control_amount').value*1) + (document.getElementById('add_other_amount').value*1);
									document.getElementById('add_other_barcod').value = '';
									document.getElementById('add_other_amount').value = 1;
									document.getElementById('add_other_barcod').focus();
							}
						</cfif>
					}
				}
			}
		}
		else
		{
			carpan = ''; birim = ''; barcod = ''; stockid = ''; productname = ''; spectmainid = 0;
			return false;
		}
	}
	function buton_kontrol()
	{
		document.getElementById('onay_div').style.display='';
	}
	function add_row(barcode,stockid,spect,productname,shelfcode,amount)
	{
		satir_stock = stockid+'_'+spect;
		row_count_content = document.getElementById('row_count_content').value;
		row_count_content++;
		document.getElementById('row_count_content').value = row_count_content;
		var newRow;
		var newCell;	
		newRow = document.getElementById("table2").insertRow(document.getElementById("table2").rows.length);
		newRow.setAttribute("name","frm_row" + row_count_content);
		newRow.setAttribute("id","frm_row" + row_count_content);		
		newRow.setAttribute("NAME","frm_row" + row_count_content);
		newRow.setAttribute("ID","frm_row" + row_count_content);		
			
		newCell = newRow.insertCell();
		newCell.innerHTML = '<a onclick="sil(' + row_count_content + ');"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>';
					
		newCell = newRow.insertCell();
		newCell.innerHTML = '<input type="hidden" name="row_kontrol'+row_count_content+'" id="row_kontrol'+row_count_content+'" value="1"><input type="hidden" name="row_stock_control'+row_count_content+'" id="row_stock_control'+row_count_content+'" value="'+satir_stock+'"><input name="STOCK_ID'+row_count_content+'" id="STOCK_ID'+row_count_content+'" type="hidden" value="'+stockid+'"><input name="SPECT_MAIN_ID'+row_count_content+'" id="SPECT_MAIN_ID'+row_count_content+'" type="hidden" value="'+spect+'"><input name="row_number'+row_count_content+'" type="text" value="'+row_count_content+'"text-align:right">';
			
		newCell = newRow.insertCell();
		newCell.innerHTML = '<input name="BARCODE'+row_count_content+'" id="BARCODE'+row_count_content+'" type="text" value="'+barcode+'">';
			
		newCell = newRow.insertCell();
		newCell.innerHTML = '<input name="PRODUCT_NAME'+row_count_content+'" id="PRODUCT_NAME'+row_count_content+'" type="text" value="'+productname+'">';
		
		<cfif rafli eq 1>	
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="SHELF_CODE'+row_count_content+'" id="SHELF_CODE'+row_count_content+'" type="text" value="'+shelfcode+'" >';	
		</cfif>
		newCell = newRow.insertCell();
		newCell.innerHTML = '<input name="SEVK_AMOUNT'+row_count_content+'" id="SEVK_AMOUNT'+row_count_content+'" type="text" value="'+amount+'" >';
	}
	function sil(sy)
	{
		row_count_sevk = <cfoutput>#GET_SHIP_PACKAGE_LIST.recordcount#</cfoutput>;
		barcode = document.getElementById('BARCODE'+sy).value;
		spectmainid = document.getElementById('SPECT_MAIN_ID'+sy).value;
		stockid = document.getElementById('STOCK_ID'+sy).value;
		amount = document.getElementById('SEVK_AMOUNT'+sy).value;
		sor=confirm(barcode+' Borkodlu Ürünü Sevkiyattan Çıkarıyorum.')
		if(sor==true)
		{
			buldum=0;
			document.getElementById('frm_row'+sy).style.display='none';
			document.getElementById('row_kontrol'+sy).value = 0;
			for(i=1;i<=row_count_sevk;i++)
			{
				satir_spect = document.getElementById('row_control_'+i).value;
				seri_spect = stockid+'_'+spectmainid;
				if(satir_spect==seri_spect)
					buldum=i;
			}
			if(buldum==0)
			{
				alert('Sorun Var. !');
			}
			else
			{
				document.getElementById('control_amount'+buldum).value = (document.getElementById('control_amount'+buldum).value*1)-(amount*1);
				document.getElementById('row'+buldum).style.display='';
				document.getElementById('total_control_amount').value = (document.getElementById('total_control_amount').value*1)-(amount*1);
			}
		}
	}
	function kontrol_kayit(tip)
	{
		if(tip==1)
		{
			sor = confirm('<cf_get_lang dictionary_id='57535.Kaydetmek İstediğinizden Emin Misiniz?'>');
			if(sor==true)
			{
				actionidolustur();
				window.location.href='<cfoutput>#request.self#?fuseaction=pda.add_ambar_fis&ambarfis=6&tersfis=1&date1=#attributes.date1#&date2=#attributes.date2#&is_type=#attributes.is_type#&keyword=#attributes.keyword#&dep_in=#attributes.department_in_id#&dep_out=#attributes.department_out_id#&ref_no=#attributes.deliver_paper_no#&ship_id=#attributes.ship_id#&x_is_pda_control=#x_is_pda_control#</cfoutput>&action_id='+document.getElementById('action_id').value+'&fis_tipi='+document.shipping_ambar_fis.fis_tipi.value+'&process_cat='+document.shipping_ambar_fis.process_cat_id.value;
			}
			else
				return false;
		}
		else
		{
			sor = confirm('<cf_get_lang dictionary_id='383.Kaydetmeden Çıkıyorsunuz!'>');
			if(sor==true)
				window.location.href='<cfoutput>#request.self#?fuseaction=pda.list_shipping_ambar</cfoutput>';
			else
				return false;
		}
	}
	function actionidolustur()
	{
		row_count_content = document.getElementById('row_count_content').value;
	  	var j = 0;
	  	for(i=1;i<=row_count_content;i++)
	  	{
		  	if(document.getElementById('SEVK_AMOUNT'+i).value > 0)
		  	{
				if (j > 0)
				document.getElementById('action_id').value = document.getElementById('action_id').value + ',';
				document.getElementById('action_id').value = document.getElementById('action_id').value + i + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('STOCK_ID'+i).value + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('SEVK_AMOUNT'+i).value + '-';
				<cfif rafli eq 1>
					document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('SHELF_CODE'+i).value + '-';
				<cfelse>
					document.getElementById('action_id').value = document.getElementById('action_id').value + '0'+ '-';
				</cfif>
				document.getElementById('action_id').value = document.getElementById('action_id').value + '0'+ '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('SPECT_MAIN_ID'+i).value;
				j++;
		  	}
		  	document.getElementById('row_count_content').value = j;
	  	}
	}
</script>