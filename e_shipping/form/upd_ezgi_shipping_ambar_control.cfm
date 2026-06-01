<!---
    File: upd_ezgi_shipping_ambar_control.cfm
    Folder: Add_Ons\ezgi\e-shipping\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfset default_process_type = 113>
<cfquery name="get_default_departments" datasource="#dsn#">
	SELECT        
    	DEFAULT_RF_TO_SV_DEP, 
        DEFAULT_RF_TO_SV_LOC
	FROM            
    	EZGI_PDA_DEPARTMENT_DEFAULTS
	WHERE        
    	EPLOYEE_ID = #session.ep.userid#
</cfquery>
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
<cfset last_year = session.ep.period_year -1>
<cfif not get_default_departments.recordcount>
	<cfset type = 0>
<cfelse>
	<cfset type = 1>
    <cfset default_departments = '#get_default_departments.DEFAULT_RF_TO_SV_DEP#'> 
    <cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_LOC,2)#">
    <cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_LOC,1)#">
    <cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
        SELECT 
            D.DEPARTMENT_HEAD,
            D.BRANCH_ID,
            SL.DEPARTMENT_ID,
            SL.LOCATION_ID,
            SL.STATUS,
            SL.COMMENT
        FROM 
            STOCKS_LOCATION SL,
            DEPARTMENT D,
            BRANCH B
        WHERE
            D.DEPARTMENT_ID IN (#default_departments#) AND
            SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
            SL.STATUS = 1 AND
            D.BRANCH_ID = B.BRANCH_ID
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
            SPCF.FUSE_NAME = 'stock.form_add_fis' 
        ORDER BY
            SPC.PROCESS_CAT_ID DESC      
    </cfquery>
  	<cfif not get_process_cat.recordcount>
		<script type="text/javascript">
            alert("<cf_get_lang dictionary_id='333.İşlem Kategorisi Tanımlayınız!'>!");
            window.close();
        </script>
    </cfif>  
</cfif>
<cfif attributes.is_type eq 1>
    <cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
        SELECT     
        	PAKET_SAYISI AS PAKETSAYISI, 
            PAKET_ID AS STOCK_ID, 
            BARCOD, 
            STOCK_CODE, 
            PRODUCT_ID,
            PRODUCT_NAME,
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
                            SF.REF_NO = '#attributes.ref_no#' AND 
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
                                    SF.REF_NO = '#attributes.ref_no#' AND 
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
                            SF.REF_NO = '#attributes.ref_no#' AND 
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
                                    SF.REF_NO = '#attributes.ref_no#' AND 
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
			PRODUCT_NAME
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
                            SF.REF_NO = '#attributes.ref_no#' AND 
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
                                    SF.REF_NO = '#attributes.ref_no#' AND 
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
                            SF.REF_NO = '#attributes.ref_no#' AND 
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
                                    SF.REF_NO = '#attributes.ref_no#' AND 
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
                SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
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
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID,
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
                	ESR.SHIP_RESULT_INTERNALDEMAND_ID, 
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
                SHIP_RESULT_INTERNALDEMAND_ID,
                SPECT_MAIN_ID
        	) AS TBL
		ORDER BY
			PRODUCT_NAME
    </cfquery>
</cfif> 
<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id='769.Ambar Fişi Hazırlama Kontrol Listesi'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#ezgi_header#" right_images="">
    	<cfform name="shipping_ambar" action="" method="post"> 
    		<cf_basket id="upd_form">
            	<div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
            						<div class="col col-6 col-xs-12" type="column" index="1" sort="true">
                                    	<div class="form-group" id="item-dep_in">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='29428.Çıkış Depo'></label>
	                            			<div class="col col-8 col-xs-12">
                                             	<select name="department_out_id" id="department_out_id" style="width:120px">
													<cfoutput query="get_all_location" group="department_id">
                                                        <option disabled="disabled" value="#department_id#">#department_head#</option>
                                                        <cfoutput>
                                                        <option value="#department_id#-#location_id#-#branch_id#-#comment#" <cfif department_id is #ListFirst(attributes.department_out_id,'-')# and location_id is #ListGetAt(attributes.department_out_id,2,'-')#>selected="selected"</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#</option>
                                                        </cfoutput> 
                                                    </cfoutput>
                                                </select>
                                          	</div>
                                     	</div>
        							</div>
                                    <div class="col col-6 col-xs-12" type="column" index="2" sort="true">
                                    	<div class="form-group" id="item-dep_out">
	                            			<label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='36506.Giriş Depo'></label>
	                            			<div class="col col-8 col-xs-12">
                                             	<select name="department_in_id" id="department_in_id" style="width:120px">
													<cfoutput query="get_all_location" group="department_id">
                                                        <option disabled="disabled" value="#department_id#">#department_head#</option>
                                                        <cfoutput>
                                                        <option value="#department_id#-#location_id#-#branch_id#-#comment#" <cfif department_id is #ListFirst(attributes.department_in_id,'-')# and location_id is #ListGetAt(attributes.department_in_id,2,'-')#>selected="selected"</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#</option>
                                                        </cfoutput> 
                                                    </cfoutput>
                                                </select>
                                          	</div>
                                     	</div>
        							</div>
                             	</cf_box_elements>
                         	</div>
                      	</div>
              	</div>
           	</cf_basket>
          	<cf_basket id="upd_default_measure_bask">
                <cf_grid_list sort="0">
                    <thead>
                        <tr>
                        	<th width="140px"><cf_get_lang dictionary_id='57633.Barkod'></th>
                            <th width="120px"><cf_get_lang dictionary_id='58585.Kod'></th>
                            <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                            <th width="60px"><cf_get_lang dictionary_id='39425.Depo Miktarı'></th>
                            <th width="60px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            <th width="60px"><cf_get_lang dictionary_id='58761.Sevk'></th>
                            <th width="60px"><cf_get_lang dictionary_id='58444.Kalan'></th>
                            <th width="60px"><cf_get_lang dictionary_id='45358.Kontrol'></th>
                            <th width="20px" align="center"><cf_get_lang dictionary_id='52513.Ok'></th>
                       	</tr>
                   	</thead>
                	<tbody>
						<cfoutput query="GET_SHIP_PACKAGE_LIST">
                            <cfinput type="hidden" name="stock_id_#currentrow#" value="#stock_id#">
                            <cfset kalan_amount= PAKETSAYISI - control_amount>
                            <cfquery name="get_detay" datasource="#dsn3#">
                            	SELECT 
                                	0 AS LAST_YEAR,       
                                	SF.FIS_ID, 
                                    SF.FIS_NUMBER, 
                                    SF.FIS_DATE, 
                                    SFR.AMOUNT, 
                                    SFR.SPECT_VAR_NAME, 
                                    SFR.UNIT,
                                    S.PRODUCT_ID, 
                                    SFR.STOCK_ID, 
                                    TBL.DEPO_NAME, 
                                    PP.SHELF_CODE
								FROM            
                                	#dsn2_alias#.STOCK_FIS AS SF INNER JOIN
                         			#dsn2_alias#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                             		(
                                    	SELECT        
                                            D.DEPARTMENT_ID, 
                                            SL.LOCATION_ID, 
                                            D.DEPARTMENT_HEAD + ' - ' + SL.COMMENT AS DEPO_NAME
                               			FROM            
                                        	#dsn_alias#.DEPARTMENT AS D WITH (NOLOCK) INNER JOIN
                                          	#dsn_alias#.STOCKS_LOCATION AS SL WITH (NOLOCK) ON D.DEPARTMENT_ID = SL.DEPARTMENT_ID
                                 	) AS TBL ON SF.DEPARTMENT_OUT = TBL.DEPARTMENT_ID AND SF.LOCATION_OUT = TBL.LOCATION_ID INNER JOIN
                        			STOCKS AS S ON SFR.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
                       				PRODUCT_PLACE AS PP ON SFR.SHELF_NUMBER = PP.PRODUCT_PLACE_ID
								WHERE        
                                	SF.REF_NO = '#attributes.ref_no#' AND 
                                    SF.FIS_TYPE = 113 AND 
                                    SFR.STOCK_ID = #GET_SHIP_PACKAGE_LIST.STOCK_ID#
                            		<cfif get_period_id.recordcount>
                                        UNION ALL
                                        SELECT 
                                        	1 AS LAST_YEAR,       
                                            SF.FIS_ID, 
                                            SF.FIS_NUMBER, 
                                            SF.FIS_DATE, 
                                            SFR.AMOUNT, 
                                            SFR.SPECT_VAR_NAME, 
                                            SFR.UNIT,
                                            S.PRODUCT_ID, 
                                            SFR.STOCK_ID, 
                                            TBL.DEPO_NAME, 
                                            PP.SHELF_CODE
                                        FROM            
                                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS AS SF INNER JOIN
                                            #dsn#_#last_year#_#session.ep.company_id#.STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
                                            (
                                                SELECT        
                                                    D.DEPARTMENT_ID, 
                                                    SL.LOCATION_ID, 
                                                    D.DEPARTMENT_HEAD + ' - ' + SL.COMMENT AS DEPO_NAME
                                                FROM            
                                                    #dsn_alias#.DEPARTMENT AS D WITH (NOLOCK) INNER JOIN
                                                    #dsn_alias#.STOCKS_LOCATION AS SL WITH (NOLOCK) ON D.DEPARTMENT_ID = SL.DEPARTMENT_ID
                                            ) AS TBL ON SF.DEPARTMENT_OUT = TBL.DEPARTMENT_ID AND SF.LOCATION_OUT = TBL.LOCATION_ID INNER JOIN
                                            STOCKS AS S ON SFR.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
                                            PRODUCT_PLACE AS PP ON SFR.SHELF_NUMBER = PP.PRODUCT_PLACE_ID
                                        WHERE        
                                            SF.REF_NO = '#attributes.ref_no#' AND 
                                            SF.FIS_TYPE = 113 AND 
                                            SFR.STOCK_ID = #GET_SHIP_PACKAGE_LIST.STOCK_ID#
                              		</cfif>
                            </cfquery>
                            <tr>
                                <td style="height:25px">#BARCOD#</td>
                                <td>
                                	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_detail_product&pid=#product_id#&sid=#stock_id#','wide');">#STOCK_CODE#</a>
                                
                                </td>
                                <td>#product_name#</td>
                                <td style="text-align:right;<cfif depo-kalan_amount lt 0>background-color:tomato; color:white</cfif>">
                                	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=stock.detail_store_stock_popup&stock_id=#stock_id#&product_id=#product_id#','list');"><strong>#Tlformat(DEPO,3)#</strong></a>
                                </td>
                                <td style="text-align:right"><strong>#Tlformat(PAKETSAYISI,3)#</strong></td>
                                <td style="text-align:right">
                                	<a href="javascript://" onclick="control_goster(#stock_id#)">
                                    	#Tlformat(control_amount,3)#
                                  	</a>
                               	</td>
                                <cfset kalan_amount= PAKETSAYISI - control_amount>
                                <input type="hidden" name="kalan_amount" id="kalan_amount_#currentrow#" value="#Tlformat(kalan_amount,3)#"/>
                                <td style="text-align:right"><strong>#Tlformat(kalan_amount,3)#</strong></td>
                                <td style="text-align:right">
                                    <cfif type eq 1>
                                        <input name="control_amount" id="control_amount_#currentrow#" value="#Tlformat(0,3)#" style="text-align:right; width:50px" readonly="readonly" class="box"/>
                                    <cfelse>
                                        <strong>#Tlformat(0,3)#</strong>
                                    </cfif>
                                </td>
                                <td style="text-align:center">
                                    <cfif control_amount eq 0>
                                        <cfif type eq 1>
                                            <a href="javascript://" class="tableyazi" onclick="gonder(#currentrow#);">
                                                <img src="images\closethin.gif" title="<cf_get_lang dictionary_id='770.Ambar Fişi Yapılmadı'>">
                                            </a>
                                        <cfelse>
                                            <img src="images\closethin.gif" title="<cf_get_lang dictionary_id='770.Ambar Fişi Yapılmadı'>">
                                        </cfif>
                                    <cfelseif paketsayisi eq control_amount>
                                        <img src="images\c_ok.gif" title="<cf_get_lang dictionary_id='771.Hepsi Ambar Fişi Yapıldı'>">
                                    <cfelseif paketsayisi gt control_amount>
                                        <cfif type eq 1>
                                            <a href="javascript://" class="tableyazi" onclick="gonder(#currentrow#);">
                                                <img src="images\warning.gif" title="<cf_get_lang dictionary_id='772.Eksik Ambar Fişi Yapıldı'>">
                                            </a>
                                        <cfelse>
                                            <img src="images\warning.gif" title="<cf_get_lang dictionary_id='772.Eksik Ambar Fişi Yapıldı'>">
                                        </cfif>
                                    </cfif>
                                </td>
                            </tr>
                            <input type="hidden" id="ambar_row_goster_#stock_id#" name="ambar_row_goster_#stock_id#" value="0"> 
                            <tr id="ambar_row_#stock_id#" style="display:none">
                            	<td colspan="9">
                                	<table cellpadding="0" cellspacing="0" border="1" style="width:100%">
										<cfif get_detay.recordcount>
                                            <cfloop query="get_detay">
                                                <tr>
                                                    <td style="text-align:center">
                                                    	<cfif get_detay.LAST_YEAR eq 0>
															<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=stock.form_add_fis&event=upd&upd_id=#get_detay.FIS_ID#','longpage');">
																#FIS_NUMBER#
															</a>
                                                        <cfelse>
                                                        	#FIS_NUMBER#
                                                        </cfif>
                                                    </td>
                                                    <td style="text-align:center">#DateFormat(FIS_DATE,dateformat_style)#</td>
                                                    <td style="text-align:left">#DEPO_NAME#</td>
                                                    <td style="text-align:center">#SHELF_CODE#</td>
                                                    <td style="text-align:right">#AmountFormat(AMOUNT,2)# #UNIT#</td>
                                                </tr>
                                            </cfloop>
                                        </cfif>
                               		</table>
                         		</td>
                         	</tr>
                      	 </cfoutput>
                    </tbody>
              	</cf_grid_list>
           	</cf_basket>
     	</cfform>
       	<tfoot>
        	<tr>
             	<td colspan="9" style="text-align:right; height:30px">
                 	<cfif type eq 1>
                     	<input type="button" value="<cf_get_lang dictionary_id='57553.Kapat'>" onClick="kontrol(0);">&nbsp;
                       	<input type="button" value="<cf_get_lang dictionary_id='36898.Ambar Fişi Oluştur'>" name="ambar_fisi" id="ambar_fisi" onClick="kontrol(1);" style="width:140px;">
                  	<cfelse>
                    	<input type="button" value="<cf_get_lang dictionary_id='57553.Kapat'>" onClick="kontrol(0);">
                   	</cfif>
              	</td>
      		</tr>
      	</tfoot>
  	</cf_box>
</div>
<form name="aktar_form" method="post">
    <input type="hidden" name="list_price" id="list_price" value="0">
    <input type="hidden" name="price_cat" id="price_cat" value="">
    <input type="hidden" name="CATALOG_ID" id="CATALOG_ID" value="">
    <input type="hidden" name="NUMBER_OF_INSTALLMENT" id="NUMBER_OF_INSTALLMENT" value="">
    <input type="hidden" name="convert_stocks_id" id="convert_stocks_id" value="">
	<input type="hidden" name="convert_amount_stocks_id" id="convert_amount_stocks_id" value="">
	<input type="hidden" name="convert_price" id="convert_price" value="">
	<input type="hidden" name="convert_price_other" id="convert_price_other" value="">
	<input type="hidden" name="convert_money" id="convert_money" value="">
    <input type="hidden" name="location_out" id="location_out" value="" />
    <input type="hidden" name="department_out" id="department_out" value="" />
    <input type="hidden" name="txt_departman_out" id="txt_departman_out" value="" />
    <input type="hidden" name="location_in" id="location_in" value="" />
    <input type="hidden" name="department_in" id="department_in" value="" />
    <input type="hidden" name="txt_department_in" id="txt_department_in" value="" />
    <input type="hidden" name="ref_no" id="ref_no" value="<cfoutput>#attributes.ref_no#</cfoutput>" />
</form>
<script language="javascript">
	function gonder(rowi)
	{
		<cfoutput query="GET_SHIP_PACKAGE_LIST">
			rowa = #currentrow#;
			if(rowi == rowa)
			{
				document.getElementById("control_amount_"+rowi).value = document.getElementById("kalan_amount_"+rowi).value;
			}
		</cfoutput>
	}
	function kontrol(type)
	{
		if(type==0)
		window.close();
		if(type==1)
		{
			department_out_id = document.getElementById('department_out_id').value;
			department_in_id = document.getElementById('department_in_id').value;
			var convert_list ="";
			var convert_list_amount ="";
			var convert_list_price ="";
			var convert_list_price_other="";
			var convert_list_money ="";	
			<cfoutput query="GET_SHIP_PACKAGE_LIST">
				if(filterNum(document.getElementById('control_amount_#currentrow#').value) > 0)
				{
					money = '#session.ep.money#';
					stock_id = #stock_id#;
					convert_list += stock_id+',';
					convert_list_amount += filterNum(document.getElementById('control_amount_#currentrow#').value)+',';
					convert_list_price_other += '0,';
					convert_list_price += '0,';
					convert_list_money += money+',';
				}
			</cfoutput>
			document.getElementById('convert_stocks_id').value=convert_list;
			document.getElementById('convert_amount_stocks_id').value=convert_list_amount;
			document.getElementById('convert_price').value=convert_list_price;
			document.getElementById('convert_price_other').value=convert_list_price_other;
			document.getElementById('convert_money').value=convert_list_money;
			document.getElementById('department_out').value = list_getat(department_out_id,1,'-');
			document.getElementById('location_out').value = list_getat(department_out_id,2,'-');
			document.getElementById('txt_departman_out').value = list_getat(department_out_id,4,'-');
			document.getElementById('department_in').value = list_getat(department_in_id,1,'-');
			document.getElementById('location_in').value = list_getat(department_in_id,2,'-');
			document.getElementById('txt_department_in').value = list_getat(department_in_id,4,'-');
			if(convert_list)//Ürün Seçili ise
			{
				 windowopen('','longpage','cc_paym');
				 if(type==1)
				 {
					 aktar_form.action="<cfoutput>#request.self#</cfoutput>?fuseaction=stock.form_add_fis&type=convert";
					 document.getElementById('ambar_fisi').disabled=true;
				 }
				 aktar_form.target='cc_paym';
				 aktar_form.submit();
			 }
			 else
				alert("<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='57657.Ürün'>.");
		}
	}
	function control_goster(stockid)
	{
		if(document.getElementById('ambar_row_goster_'+stockid).value==0)
		{
			document.getElementById('ambar_row_'+stockid).style.display = '';
			document.getElementById('ambar_row_goster_'+stockid).value=1;
		}
		else
		{
			document.getElementById('ambar_row_'+stockid).style.display = 'none';
			document.getElementById('ambar_row_goster_'+stockid).value=0;
		}
	}
</script>