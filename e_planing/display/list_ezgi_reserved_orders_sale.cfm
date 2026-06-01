<cfparam name="attributes.order_stage" default="">
<cfparam name="attributes.keyword" default=''>
<cfparam name="attributes.company" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.listing_type" default="2">
<cfparam name="attributes.page" default=1>
<cfsetting showdebugoutput="no">
<cfif isdefined("attributes.is_from_stock")>
	<cfquery name="GET_ORDER_LIST" datasource="#DSN3#">
		SELECT
			O.ORDER_DATE,
			O.ORDER_ID,
			O.ORDER_NUMBER,
			O.PARTNER_ID,
			O.COMPANY_ID,
			O.CONSUMER_ID,
			O.DELIVERDATE,
			O.SHIP_METHOD,
			O.ORDER_STAGE,
			O.DELIVER_DEPT_ID,
			O.LOCATION_ID,
			ISNULL(O.IS_INSTALMENT,0) IS_INSTALMENT,
			(ORR.QUANTITY* PU.MULTIPLIER) QUANTITY,
			PU.MAIN_UNIT UNIT,
			(ORR.QUANTITY -
			(SELECT 
				  ISNULL(SUM(SR.AMOUNT),0)
			FROM 
				  #dsn2_alias#.SHIP_ROW SR
			WHERE
				SR.WRK_ROW_RELATION_ID IS NOT NULL  AND
				(
					SR.WRK_ROW_RELATION_ID = ORR.WRK_ROW_ID OR 
					SR.WRK_ROW_RELATION_ID IN (SELECT IRR.WRK_ROW_ID FROM #dsn2_alias#.INVOICE_ROW IRR WHERE IRR.WRK_ROW_RELATION_ID = ORR.WRK_ROW_ID)
				)
			)) KALAN
		FROM
			STOCKS S,
			ORDERS O,
			PRODUCT_UNIT PU,
			ORDER_ROW ORR
		WHERE
			O.ORDER_STATUS = 1 AND
			ORR.ORDER_ID = O.ORDER_ID AND
			(	
				(
					O.PURCHASE_SALES = 1 AND
					O.ORDER_ZONE = 0
				 )  
				OR
				(	O.PURCHASE_SALES = 0 AND
					O.ORDER_ZONE = 1
				)
			) AND		
			S.STOCK_ID = ORR.STOCK_ID AND 
			S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID AND
            <cfif isdefined("attributes.sid") and len(attributes.sid)>
				ORR.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sid#"> AND
            <cfelse>
	            ORR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pid#"> AND
            </cfif>
			<cfif attributes.spect_var_id neq 0>
				ORR.SPECT_VAR_ID IN
				(
					SELECT 
						SPECTS.SPECT_VAR_ID
					FROM
						SPECTS
					WHERE
						SPECTS.SPECT_MAIN_ID = (SELECT SPP.SPECT_MAIN_ID FROM SPECTS SPP WHERE SPP.SPECT_VAR_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.spect_var_id#">)
				) AND
			</cfif>
			<cfif isdefined("attributes.spect_main_id") and len(attributes.spect_main_id)>
				ORR.SPECT_VAR_ID IN
				(
					SELECT 
						SPECTS.SPECT_VAR_ID
					FROM
						SPECTS
					WHERE
						SPECTS.SPECT_MAIN_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.spect_main_id#">)
				) AND
			</cfif>
			<cfif isdefined("attributes.dept_id") and len(attributes.dept_id)>
				AND O.DELIVER_DEPT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.dept_id#">
			</cfif>
			<cfif isdefined("attributes.loc_id") and len(attributes.loc_id)>
				AND O.LOCATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.loc_id#">
			</cfif>
			<cfif isdefined("attributes.order_row_id") and len(attributes.order_row_id)>
				AND O.ORDER_ID NOT IN(SELECT OR_.ORDER_ID FROM ORDER_ROW OR_ WHERE OR_.ORDER_ROW_ID IN(#attributes.order_row_id#))
			</cfif>
			ORR.ORDER_ROW_CURRENCY NOT IN(-9,-10,-3,-8)
		ORDER BY
			O.ORDER_DATE
	</cfquery>
<cfelse>
	<cfquery name="GET_ORDER_LIST" datasource="#DSN3#">
		SELECT

          	DISTINCT QUANTITY,
            ORDER_DATE,
            ORDER_ID,
            ORDER_NUMBER,
            PARTNER_ID,
            COMPANY_ID,
            CONSUMER_ID,
            SHIP_METHOD,
            ORDER_STAGE,
            IS_INSTALMENT,
            UNIT,
        	ORDER_ROW_ID,
       		DELIVER_DEPT_ID,
         	LOCATION_ID,
       		DELIVERDATE
		FROM
		(
			SELECT
				O.ORDER_DATE,
				O.ORDER_ID,
				O.ORDER_NUMBER,
				O.PARTNER_ID,
				O.COMPANY_ID,
				O.CONSUMER_ID,
				O.SHIP_METHOD,
				O.ORDER_STAGE,
				ISNULL(O.IS_INSTALMENT,0) IS_INSTALMENT,
				PU.MAIN_UNIT UNIT
					,OR_R.ORDER_ROW_ID
					,(OR_R.QUANTITY-ORR.STOCK_OUT) QUANTITY
					,ISNULL(OR_R.DELIVER_DEPT,O.DELIVER_DEPT_ID) DELIVER_DEPT_ID
					,ISNULL(OR_R.DELIVER_LOCATION,O.LOCATION_ID) LOCATION_ID
					,ISNULL(OR_R.DELIVER_DATE,O.DELIVERDATE) DELIVERDATE

			FROM
				STOCKS S,
				GET_ORDER_ROW_RESERVED ORR, 
				ORDERS O,
				PRODUCT_UNIT PU
					,ORDER_ROW OR_R
			WHERE
				O.RESERVED = 1 AND
				O.ORDER_STATUS = 1 AND
				ORR.ORDER_ID = O.ORDER_ID AND
				(	
					(
						O.PURCHASE_SALES = 1 AND
						O.ORDER_ZONE = 0
					 )  
					OR
					(	O.PURCHASE_SALES = 0 AND
						O.ORDER_ZONE = 1
					)
				) AND		
				S.STOCK_ID = ORR.STOCK_ID AND 
				S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID AND
				(ORR.RESERVE_STOCK_OUT-ORR.STOCK_OUT) > 0 AND <!--- tamamen kapatılmıs satırların gelmemesi icin eklendi --->
                <cfif isdefined("attributes.sid") and  len(attributes.sid)>
					ORR.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sid#"> 
                <cfelse>
                	ORR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pid#"> 
                </cfif>
				<cfif len(attributes.keyword)>
					AND O.ORDER_NUMBER LIKE  '<cfif len(attributes.keyword) gt 2>%</cfif>#attributes.keyword#%'
				</cfif>
				<cfif len(attributes.order_stage)>
					AND O.ORDER_STAGE = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_stage#"> 
				</cfif>
				<cfif isdefined("attributes.spect_main_id") and len(attributes.spect_main_id)>
                    AND	ORR.SPECT_VAR_ID IN
					(
						SELECT 
							SPECTS.SPECT_VAR_ID
						FROM
							SPECTS
						WHERE
							SPECTS.SPECT_MAIN_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.spect_main_id#">
					) 
				</cfif>
				<cfif isdefined("attributes.order_row_id") and len(attributes.order_row_id)>
					AND O.ORDER_ID NOT IN(SELECT OR_.ORDER_ID FROM ORDER_ROW OR_ WHERE OR_.ORDER_ROW_ID IN(#attributes.order_row_id#))
				</cfif>
				<cfif attributes.listing_type eq 2>
                AND OR_R.RESERVE_TYPE <> -4 
					AND O.ORDER_ID = OR_R.ORDER_ID
					AND ORR.STOCK_ID = OR_R.STOCK_ID
					<cfif isdefined("attributes.dept_id") and len(attributes.dept_id)>
						AND ISNULL(OR_R.DELIVER_DEPT,O.DELIVER_DEPT_ID) = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.dept_id#">
					</cfif>
					<cfif isdefined("attributes.loc_id") and len(attributes.loc_id)>
						AND ISNULL(OR_R.DELIVER_LOCATION,O.LOCATION_ID) = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.loc_id#">
					</cfif>
				<cfelse>
					<cfif isdefined("attributes.dept_id") and len(attributes.dept_id)>
						AND O.DELIVER_DEPT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.dept_id#">
					</cfif>
					<cfif isdefined("attributes.loc_id") and len(attributes.loc_id)>
						AND O.LOCATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.loc_id#">
					</cfif>
				</cfif>
			UNION ALL
			SELECT	
				O.ORDER_DATE,
				O.ORDER_ID,
				O.ORDER_NUMBER,
				O.PARTNER_ID,
				O.COMPANY_ID,
				O.CONSUMER_ID,
				O.SHIP_METHOD,
				O.ORDER_STAGE,
				ISNULL(O.IS_INSTALMENT,0) IS_INSTALMENT,
				PU.MAIN_UNIT UNIT 
					,OR_R.ORDER_ROW_ID
					,(OR_R.QUANTITY-ORR.STOCK_OUT) QUANTITY
					,ISNULL(OR_R.DELIVER_DEPT,O.DELIVER_DEPT_ID) DELIVER_DEPT_ID
					,ISNULL(OR_R.DELIVER_LOCATION,O.LOCATION_ID) LOCATION_ID
					,ISNULL(OR_R.DELIVER_DATE,O.DELIVERDATE) DELIVERDATE

			FROM
				STOCKS S,
				GET_ORDER_ROW_RESERVED ORR, 
				ORDERS O,
				SPECTS_ROW SR,
				PRODUCT_UNIT PU
					,ORDER_ROW OR_R
			WHERE
				SR.SPECT_ID = ORR.SPECT_VAR_ID AND
				SR.IS_SEVK=1 AND
				O.RESERVED = 1 AND
				O.ORDER_STATUS = 1 AND
				(	
					(
						O.PURCHASE_SALES = 1 AND
						O.ORDER_ZONE = 0
					 )  
					OR
					(	O.PURCHASE_SALES = 0 AND
						O.ORDER_ZONE = 1
					)
				) AND
				ORR.ORDER_ID = O.ORDER_ID AND
				SR.STOCK_ID = S.STOCK_ID AND
				S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID AND
				(ORR.RESERVE_STOCK_OUT-ORR.STOCK_OUT) > 0 AND
                <cfif isdefined("attributes.sid") and  len(attributes.sid)>
					SR.STOCK_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.sid#"> 
                <cfelse>
                	SR.PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pid#"> 
                </cfif>
				<cfif len(attributes.keyword)>
					AND O.ORDER_NUMBER LIKE  '<cfif len(attributes.keyword) gt 2>%</cfif>#attributes.keyword#%'
				</cfif>
				<cfif len(attributes.order_stage)>
					AND O.ORDER_STAGE = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.order_stage#">
				</cfif>
				<cfif isdefined("attributes.spect_main_id") and len(attributes.spect_main_id)>
					AND	ORR.SPECT_VAR_ID IN
					(
						SELECT 
							SPECTS.SPECT_VAR_ID
						FROM
							SPECTS
						WHERE
							SPECTS.SPECT_MAIN_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.spect_main_id#">
					) 
				</cfif>
				<cfif isdefined("attributes.order_row_id") and len(attributes.order_row_id)>
					AND O.ORDER_ID NOT IN(SELECT OR_.ORDER_ID FROM ORDER_ROW OR_ WHERE OR_.ORDER_ROW_ID IN(#attributes.order_row_id#))
				</cfif>
				<cfif attributes.listing_type eq 2>
                	AND OR_R.RESERVE_TYPE <> -4 
					AND O.ORDER_ID = OR_R.ORDER_ID
					AND ORR.STOCK_ID = OR_R.STOCK_ID
					<cfif isdefined("attributes.dept_id") and len(attributes.dept_id)>
						AND ISNULL(OR_R.DELIVER_DEPT,O.DELIVER_DEPT_ID) = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.dept_id#">
					</cfif>
					<cfif isdefined("attributes.loc_id") and len(attributes.loc_id)>
						AND ISNULL(OR_R.DELIVER_LOCATION,O.LOCATION_ID) = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.loc_id#">
					</cfif>
				<cfelse>
					<cfif isdefined("attributes.dept_id") and len(attributes.dept_id)>
						AND O.DELIVER_DEPT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.dept_id#">
					</cfif>
					<cfif isdefined("attributes.loc_id") and len(attributes.loc_id)>
						AND O.LOCATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.loc_id#">
					</cfif>
				</cfif>
		)T1

		ORDER BY 
			DELIVERDATE
	</cfquery>
</cfif>
<cfquery name="get_other_orders" datasource="#dsn3#">
	SELECT  
    	DISTINCT
    	CASE
        	WHEN ORDS.COMPANY_ID IS NOT NULL THEN
                   (
                    SELECT     
                      	NICKNAME
					FROM         
                    	#dsn_alias#.COMPANY
					WHERE     
                   		COMPANY_ID = ORDS.COMPANY_ID
                  	)
        	WHEN ORDS.CONSUMER_ID IS NOT NULL THEN      
                   	(	
                  	SELECT     
                     	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
					FROM         
                      	#dsn_alias#.CONSUMER
					WHERE     
                		CONSUMER_ID = ORDS.CONSUMER_ID
               		)
          	WHEN ORDS.EMPLOYEE_ID IS NOT NULL THEN
                  	(
                   	SELECT     
                    	EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
					FROM         
                  		#dsn_alias#.EMPLOYEES
					WHERE     
                     	EMPLOYEE_ID = ORDS.EMPLOYEE_ID
                 	)
      	END AS UNVAN,      
    	ORDS.LOCATION_ID, 
        ORDS.DELIVER_DEPT_ID, 
        ORDS.IS_INSTALMENT,
        ORR.RESERVE_STOCK_OUT - ORR.STOCK_OUT AS RESERVE_SALE_ORDER_STOCK, 
        ORDS.DELIVERDATE,
        ORDS.ORDER_NUMBER, 
        ORDS.ORDER_DATE, 
        ORDS.ORDER_ID,
        ORDS.COMPANY_ID,
        ORDS.CONSUMER_ID,
        ORDS.EMPLOYEE_ID,
        S.PRODUCT_ID,
        S.PRODUCT_NAME, 
        S.PRODUCT_CODE,
        (SELECT MAIN_UNIT FROM PRODUCT_UNIT WHERE PRODUCT_ID = S.PRODUCT_ID AND IS_MAIN = 1) AS UNIT
	FROM            
    	GET_ORDER_ROW_RESERVED AS ORR INNER JOIN
     	ORDERS AS ORDS ON ORR.ORDER_ID = ORDS.ORDER_ID INNER JOIN
     	STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
    	#dsn1_alias#.KARMA_PRODUCTS AS KP ON S.PRODUCT_ID = KP.KARMA_PRODUCT_ID
	WHERE        
    	ORR.RESERVE_STOCK_OUT - ORR.STOCK_OUT > 0 AND 
        S.IS_KARMA = 1 AND
        S.PRODUCT_ID <> #attributes.pid#
       	<cfif isdefined("attributes.dept_id") and len(attributes.dept_id)> 
        	AND ORDS.DELIVER_DEPT_ID  = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.dept_id#">
      	</cfif>
        <cfif isdefined("attributes.loc_id") and len(attributes.loc_id)>
         	AND ORDS.LOCATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.loc_id#">
     	</cfif>
        <cfif isdefined("attributes.pid") and  len(attributes.pid)>
        	AND KP.PRODUCT_ID IN
                             	(
                                	SELECT        
                                    	PRODUCT_ID
                               		FROM            
                                    	#dsn1_alias#.KARMA_PRODUCTS
                               		WHERE        
                                    	KARMA_PRODUCT_ID = #attributes.pid#
                              	)
    	</cfif>

</cfquery>
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default=#get_order_list.recordcount#>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfset toplam_stok = 0>
<cfquery name="GET_PROCESS_TYPE" datasource="#DSN#">
	SELECT
		PTR.STAGE,
		PTR.PROCESS_ROW_ID 
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.IS_ACTIVE = 1 AND
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%sales.list_order%">
	ORDER BY
		PTR.LINE_NUMBER
</cfquery>
<cfif not isdefined('attributes.sid')>
<cfform action="#request.self#?fuseaction=prod.popup_dsp_ezgi_planning_reserved_orders&taken=#attributes.taken#&pid=#attributes.pid#" method="post">
    <cfsavecontent variable="siparisler"><cf_get_lang dictionary_id='34049.Alınan Siparişler'></cfsavecontent>
	<cf_big_list_search title="#siparisler# : <cfoutput>#get_product_name.PRODUCT_NAME#</cfoutput>">
         <cf_big_list_search_area>
            <!---<div class="row">
				<div class="col col-12">
					<div class="row form-inline">
                        <cfinput type="hidden" name="is_form_submitted" id="is_form_submitted" value="1">
					<div class="form-group x-12" id="item-keyword"
						<cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>	
                        <cfinput type="text" name="keyword" id="keyword" placeholder="#filter#" style="width:100px;" value="#attributes.keyword#">
                    </div>
					<div class="form-group x-16" id="item-order_stage">	
						<select name="order_stage" id="order_stage" style="width:100px;">
							<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
							<cfoutput query="get_process_type">
								<option value="#process_row_id#"<cfif attributes.order_stage eq process_row_id>selected</cfif>>#stage#</option>
							</cfoutput>
						</select>
                    </div>
                    <div class="form-group x-3_5">
						<cfsavecontent variable="message"><cf_get_lang dictionary_id='34135.Sayi_Hatasi_Mesaj'></cfsavecontent>
						<cfinput type="text" name="maxrows" value="#attributes.maxrows#" required="yes" validate="integer" range="1,999" message="#message#" maxlength="3" style="width:25px;">
                    </div>
                    <div class="form-group x-3_5">
						<cf_wrk_search_button>
					</div>
                </div>
            </div>
		</div>--->	
        </cf_big_list_search_area>
    </cf_big_list_search>
</cfform>
<cfelse>
	<cfset attributes.maxrows = get_order_list.recordcount>
</cfif>
<br/>
<table width="99%" align="center" cellpadding="0" cellspacing="0">
	<tr>
    	<td>
            <cf_medium_list>
                    <thead>
                        <tr>
                            <th><cf_get_lang dictionary_id='57496.No'></th>
							<th><cf_get_lang dictionary_id='57519.Cari Hesap'></th>
							<th width="60"><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></th>
							<th width="60"><cf_get_lang dictionary_id='57645.Teslim Tarihi'></th>
							<th><cf_get_lang dictionary_id='45219.Depo Lokasyon'></th>							
							<th><cf_get_lang dictionary_id='58859.Süreç'></th>
							<th style="text-align:right;"><cf_get_lang dictionary_id='57635.Miktar'></th>
							<th style="text-align:right;"><cf_get_lang dictionary_id='40163.Toplam Miktar'></th>
                        </tr>
                    </thead>
                    <tbody>
                        <cfif get_order_list.recordcount>
                            <cfset order_stage_list=''>
                            <cfset dept_id_list=''>
                            <cfset partner_id_list = "">
                            <cfset consumer_id_list = "">
                            <cfoutput query="get_order_list" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                                <cfif len(order_stage) and not listfind(order_stage_list,order_stage)>
                                    <cfset order_stage_list=listappend(order_stage_list,order_stage)>
                                </cfif>
                                <cfif len(deliver_dept_id) and not listfind(dept_id_list,deliver_dept_id)>
                                    <cfset dept_id_list=listappend(dept_id_list,deliver_dept_id)>
                                </cfif>
                                <cfif len(partner_id) and not listfind(partner_id_list,partner_id)>
                                    <cfset partner_id_list=listappend(partner_id_list,partner_id)>
                                </cfif>
                                <cfif len(consumer_id) and not listfind(consumer_id_list,consumer_id)>
                                    <cfset consumer_id_list=listappend(consumer_id_list,consumer_id)>
                                </cfif>
                            </cfoutput>
                            <cfif len(order_stage_list)>
                                <cfset order_stage_list=listsort(order_stage_list,"numeric","ASC",",")>
                                <cfquery name="ORDER_PROCESS_TYPE" datasource="#DSN#">
                                    SELECT
                                        STAGE,
                                        PROCESS_ROW_ID
                                    FROM
                                        PROCESS_TYPE_ROWS
                                    WHERE
                                        PROCESS_ROW_ID IN(#order_stage_list#)
                                    ORDER BY
                                        PROCESS_ROW_ID
                                </cfquery>
                            </cfif>
                            <cfif listlen(dept_id_list)>
                                <cfset dept_id_list=listsort(dept_id_list,"numeric","ASC",",")>
                                <cfquery name="GET_LOC_DETAIL" datasource="#DSN#">
                                    SELECT 
                                        (SELECT D.DEPARTMENT_HEAD FROM DEPARTMENT D WHERE D.DEPARTMENT_ID = SL.DEPARTMENT_ID) AS DEPARTMENT_HEAD,
                                        SL.DEPARTMENT_ID,
                                        SL.COMMENT,
                                        SL.LOCATION_ID
                                    FROM 
                                        STOCKS_LOCATION SL
                                    WHERE
                                        DEPARTMENT_ID IN (#dept_id_list#)	
                                </cfquery>
                                <cfif get_loc_detail.recordcount>
                                    <cfloop query="get_loc_detail">
                                        <cfset 'dep_loc_#department_id#_#location_id#' = '#department_head#-#comment#'>
                                    </cfloop>
                                </cfif>
                            </cfif>
                            <cfif ListLen(partner_id_list)>
                                <cfset partner_id_list=listsort(partner_id_list,"numeric","ASC",",")>
                                <cfquery name="GET_PARTNER_LIST" datasource="#DSN#">
                                    SELECT
                                        C.NICKNAME,
                                        CP.PARTNER_ID,
                                        CP.COMPANY_PARTNER_NAME,
                                        CP.COMPANY_PARTNER_SURNAME
                                    FROM
                                        COMPANY C,
                                        COMPANY_PARTNER CP
                                    WHERE
                                        C.COMPANY_ID = CP.COMPANY_ID AND
                                        CP.PARTNER_ID IN (#partner_id_list#)
                                    ORDER BY
                                        CP.PARTNER_ID
                                </cfquery>
                                <cfset partner_id_list = ListSort(ListDeleteDuplicates(ValueList(get_partner_list.partner_id,",")),"numeric","asc",",")>
                            </cfif>
                            <cfif ListLen(consumer_id_list)>
                                <cfset consumer_id_list=listsort(consumer_id_list,"numeric","ASC",",")>
                                <cfquery name="GET_CONSUMER_LIST" datasource="#DSN#">
                                    SELECT CONSUMER_ID, CONSUMER_NAME, CONSUMER_SURNAME FROM CONSUMER WHERE CONSUMER_ID IN (#consumer_id_list#) ORDER BY CONSUMER_ID
                                </cfquery>
                                <cfset consumer_id_list = ListSort(ListDeleteDuplicates(ValueList(get_consumer_list.consumer_id,",")),"numeric","asc",",")>
                            </cfif>
                            <cfset toplam_kalan = 0>
                            <cfif attributes.totalrecords gt attributes.maxrows>
                                <cfif attributes.page neq 1>
                                    <cfset max_ = (attributes.page-1)*attributes.maxrows>
                                    <cfoutput query="get_order_list" startrow="1" maxrows="#max_#">					
                                                <cfset toplam_stok = toplam_stok + QUANTITY>						
                                    </cfoutput>
                                </cfif>
                            </cfif>		
                            <!---<tr>
                                <td colspan="7" class="txtboldblue"><cf_get_lang dictionary_id='58034.Devreden'><</td>                                
                                    <td align="right" style="text-align:right;">               
                                  <cfoutput>  #TlFormat(toplam_stok)#    </cfoutput>           
                                    </td>                              
                            </tr>   --->             
                            <cfoutput query="get_order_list" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                            	<cfquery name="get_control" datasource="#dsn3#">
                                	SELECT        
                                    	ORDER_ROW_ID, 
                                        ISNULL(SUM(PAKET_SAYISI),0) AS PAKET_SAYISI,
                             			ISNULL((
                                                SELECT        
                                                    SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                                                FROM            
                                                    EZGI_SHIPPING_PACKAGE_LIST
                                                WHERE        
                                                    TYPE = 1 AND 
                                                    SHIPPING_ROW_ID = TBL.SHIP_RESULT_ROW_ID
                                     	),0) AS CONTROL_AMOUNT
									FROM            
                                    	(
                                        	SELECT        
                                            	CASE 
                                                	WHEN S.PRODUCT_TREE_AMOUNT IS NOT NULL THEN S.PRODUCT_TREE_AMOUNT 
                                               		ELSE SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) 
                                            	END AS PAKET_SAYISI, 
                                                ORR.ORDER_ROW_ID, 
                                            	ESRR.SHIP_RESULT_ROW_ID
                          					FROM            
                                            	EZGI_SHIP_RESULT AS ESR INNER JOIN
                                             	EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                                             	ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                                           		EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                                            	STOCKS AS S ON EPS.PAKET_ID = S.STOCK_ID
                          					GROUP BY 
                                            	EPS.PAKET_ID, 
                                                S.BARCOD, 
                                                S.STOCK_CODE, 
                                                S.PRODUCT_NAME, 
                                                S.PRODUCT_TREE_AMOUNT, 
                                                ESR.SHIP_RESULT_ID, 
                                                ESRR.ORDER_ROW_ID, 
                                                ORR.ORDER_ROW_ID, 
                                                ESRR.SHIP_RESULT_ROW_ID
                          					HAVING         
                                            	ORR.ORDER_ROW_ID = #ORDER_ROW_ID#
                                      	) AS TBL
									GROUP BY 
                                    	ORDER_ROW_ID,
                                        SHIP_RESULT_ROW_ID
                                </cfquery>
                                <cfif get_control.recordcount>
                                	<cfif get_control.CONTROL_AMOUNT eq 0>
                                    	<cfset kontrol =0>
                                    <cfelse>
										<cfif get_control.CONTROL_AMOUNT lt get_control.PAKET_SAYISI>
                                        	<cfset kontrol =1>
                                        <cfelse>
                                        	<cfset kontrol =2>
                                        </cfif>
                                    </cfif>
                                <cfelse>
                                	<cfset kontrol =0>
                                </cfif>
                                <tr>
                                    <td>
                                        <cfif is_instalment eq 1>
                                            <a href="#request.self#?fuseaction=sales.upd_fast_sale&order_id=#order_id#" class="tableyazi" target="_blank">#order_number#</a>
                                        <cfelse>	
                                            <a href="#request.self#?fuseaction=sales.list_order&event=upd&order_id=#order_id#" class="tableyazi" target="_blank">#order_number#</a>
                                        </cfif>			  
                                    </td>
                                    <td><cfif Len(partner_id)>
                                            #get_partner_list.nickname[ListFind(partner_id_list,partner_id,',')]# - #get_partner_list.company_partner_name[ListFind(partner_id_list,partner_id,',')]# #get_partner_list.company_partner_surname[ListFind(partner_id_list,partner_id,',')]#
                                        <cfelseif Len(consumer_id)>
                                            #get_consumer_list.consumer_name[ListFind(consumer_id_list,consumer_id,',')]# #get_consumer_list.consumer_surname[ListFind(consumer_id_list,consumer_id,',')]#
                                        </cfif>
                                    </td>
									<td nowrap>#DateFormat(order_date,dateformat_style)#</td>
									<td nowrap>#DateFormat(deliverdate,dateformat_style)#</td>
                                    <td style="color:<cfif kontrol eq 1>green<cfelseif kontrol eq 2>red<cfelse>black</cfif>">
                                        <cfif isdefined('dep_loc_#deliver_dept_id#_#location_id#')>
                                            #Evaluate('dep_loc_#deliver_dept_id#_#location_id#')#
                                        </cfif>
                                    </td>                                    
                                    <td><cfif len(order_stage)>#order_process_type.stage[listfind(order_stage_list,order_stage,',')]#</cfif></td>
                                    <td  style="text-align:right;">#TlFormat(quantity)# #unit#</td>
                                    <td style="text-align:right;"><cfset toplam_stok = toplam_stok + QUANTITY> #TlFormat(toplam_stok)# #UNIT#</td>
                                </tr>
                            </cfoutput>
                            
                        <cfelse>
                            <tr>
                                <td colspan="11"><cf_get_lang dictionary_id='58486.Kayit Bulunamadi'>!</td>
							</tr>
                        </cfif>
                    </tbody>
                    <cfoutput>
                    <!---<tfoot>
                    <cfif isdefined('is_karma')>
                      	<tr>
                            <td colspan="7"><cf_get_lang dictionary_id='289.Diğer Ürünlerden Gelen Rezerve Miktar'></td>
                            <td style="text-align:right;">#TlFormat(attributes.sale_order-toplam_stok)# #get_order_list.UNIT#</td>
                     	</tr>
                        <cfset toplam_stok = attributes.sale_order>
                    </cfif>
                    <tr>
                        <td colspan="7" width="%100px"><b><cf_get_lang dictionary_id='57492.Toplam'></b></td>
                      	<td style="text-align:right;">
                             #TlFormat(toplam_stok)# #get_order_list.UNIT#</b>
                      	</td>
                     </tr>
                    </tfoot>--->
                    <cfif get_other_orders.recordcount>
                    	<thead>
                        	<th width="70px"><cf_get_lang dictionary_id='57496.No'></th>
                            <th width="170px"><cf_get_lang dictionary_id='57519.Cari Hesap'></th>
                            <th width="70px"><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></th>
                            <th width="60"><cf_get_lang dictionary_id='57645.Teslim Tarihi'></th>
                            <th><cf_get_lang dictionary_id='45219.Depo Lokasyon'></th>	
                            <th width="200px" ><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                        	<th width="45px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            <th width="75px"><cf_get_lang dictionary_id='40163.Toplam Miktar'></th>
                        </thead>
                        <tbody>
                        	<cfloop query="get_other_orders">
                        	<tr>
                            	<td>
                                	<cfif is_instalment eq 1>
                                     	<a href="#request.self#?fuseaction=sales.upd_fast_sale&order_id=#order_id#" class="tableyazi" target="_blank">#order_number#</a>
                                  	<cfelse>	
                                     	<a href="#request.self#?fuseaction=sales.list_order&event=upd&order_id=#order_id#" class="tableyazi" target="_blank">#order_number#</a>
                                  	</cfif>			  
                             	</td>
                                <td>#UNVAN#</td>
                            	<td nowrap>#DateFormat(order_date,dateformat_style)#</td>
                                <td nowrap>#DateFormat(deliverdate,dateformat_style)#</td>
                                
                                <td >
                                 	<cfif isdefined('dep_loc_#deliver_dept_id#_#location_id#')>
                                    	#Evaluate('dep_loc_#deliver_dept_id#_#location_id#')#
                                 	</cfif>
                            	</td>
                                <td style="color:black">#PRODUCT_NAME#</td>
                                <td  style="text-align:right;">#TlFormat(RESERVE_SALE_ORDER_STOCK)# #UNIT#</td>
                           		<td style="text-align:right;"><cfset toplam_stok = toplam_stok + RESERVE_SALE_ORDER_STOCK> #TlFormat(toplam_stok)# #UNIT#</td>
                            </tr>
                            </cfloop>
                        </tbody>
                    </cfif>
                </cfoutput>
            </cf_medium_list>
        </td>
    </tr>
</table>
<!---<cf_popup_box_footer>
<cfif attributes.totalrecords gt attributes.maxrows>
	<table width="99%">
		<tr>
			<td>
				<cfset adres = attributes.fuseaction & "&taken=#attributes.taken#&pid=#attributes.pid#">
				<cfif len(attributes.keyword)>
				  <cfset adres = "#adres#&keyword=#attributes.keyword#">
				</cfif>
				<cfif isdefined("attributes.order_stage") and len(attributes.order_stage)>
					<cfset adres ="#adres#&order_stage=#attributes.order_stage#">
				</cfif>
				<cf_pages page="#attributes.page#" 
						maxrows="#attributes.maxrows#"
						totalrecords="#attributes.totalrecords#"
						startrow="#attributes.startrow#"
						adres="#adres#">
				</td>
			<td style="text-align:right;"><cf_get_lang dictionary_id='57492.toplam'>:<cfoutput>#attributes.totalrecords#-&nbsp;<cf_get_lang dictionary_id='57581.sayfa'>:#attributes.page#/#lastpage#</cfoutput></td>
		</tr>
	</table>
</cfif>
</cf_popup_box_footer>--->
