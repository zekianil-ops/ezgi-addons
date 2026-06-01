<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.page" default="1">
<cfparam name="attributes.department_id" default="">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.department_txt" default="">
<cfparam name="attributes.report_type" default="4">
<cfparam name="attributes.unit_type" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.uretim_ay" default="0">
<cfparam name="attributes.product_code" default="">
<cfparam name="attributes.product_cat_id" default="">
<cfparam name="attributes.product_cat" default="">
<cfparam name="attributes.yontem" default="1">
<cfset stock_id_list = ''>
<cfset t_real_stock = 0>
<cfset s_t_real_stock = 0>
<cfset son_row = 0>
<cfset this_year_max_month = Month(now())>
<cfset this_year_min_month = 1>
<cfset last_year_max_month = 12>
<cfset last_year_min_month = this_year_max_month>
<cfset this_year = Year(now())>
<cfset last_year = this_year -1>
<cfquery name="get_last_period" datasource="#dsn#">
	SELECT PERIOD_ID FROM SETUP_PERIOD WHERE OUR_COMPANY_ID = #session.ep.company_id# AND PERIOD_YEAR = #last_year#
</cfquery>
<cfquery name="get_branch" datasource="#dsn#">
	SELECT BRANCH_ID, BRANCH_NAME FROM BRANCH WHERE BRANCH_STATUS = 1 AND COMPANY_ID = #session.ep.company_id#
</cfquery>
<cfquery name="get_unit" datasource="#dsn#">
	SELECT UNIT_ID, UNIT FROM SETUP_UNIT
</cfquery>
<cfoutput query="get_unit">
	<cfset 'UNIT_#UNIT_ID#' = UNIT>
</cfoutput>

<cfif isdefined("attributes.is_submitted")>
 	<cfset attributes.list_with_store = 1>
    <cfif attributes.branch_id neq ''>
        <cfquery name="get_departments" datasource="#DSN#">
                SELECT        
                    DEPARTMENT_ID 
                FROM            
                    STOCKS_LOCATION
                WHERE        
                    DEPARTMENT_ID IN
                                    (
                                        SELECT        
                                            DEPARTMENT_ID
                                        FROM            
                                            DEPARTMENT
                                        WHERE        
                                            BRANCH_ID = #attributes.branch_id# AND 
                                            DEPARTMENT_STATUS = 1 AND 
                                            IS_STORE IN (2, 3)
                                    )
                    AND ISNULL(IS_SCRAP,0) = 0
                ORDER BY 
                    DEPARTMENT_ID, 
                    LOCATION_ID
        </cfquery>
        <cfset attributes.department_id = ValueList(get_departments.DEPARTMENT_ID)>
  	</cfif>
	<cfif Len(attributes.product_code) and Len(attributes.product_cat)>
        <cfquery name="GET_CATEGORIES" datasource="#DSN1#">
            SELECT PRODUCT_ID FROM PRODUCT WHERE PRODUCT_CODE LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#attributes.product_code#.%">
        </cfquery>
    </cfif>
	<cfquery name="get_demonte_product" datasource="#dsn3#">
    	SELECT DISTINCT
        	TBL.STOCK_ID, 
            TBL.PRODUCT_ID,
            TBL.PRODUCT_NAME, 
            TBL.PRODUCT_CODE, 
            TBL.REAL_STOCK,
        	TBL.URETIM,
        	TBL.SIPARIS,
            TBL.TALEP,
            TBL.SHIP_INTERNAL_STOCK,
            PU.MAIN_UNIT,
            PU.UNIT_ID
     	FROM
        	(       
    		SELECT        
                S.PRODUCT_NAME AS MODUL_PRODUCT_NAME, 
                S.PRODUCT_CODE AS MODUL_PRODUCT_CODE, 
                K.STOCK_ID, 
                S1.STOCK_CODE, 
                S1.PRODUCT_NAME, 
                S1.PRODUCT_CODE, 
                S1.PRODUCT_ID,
                S1.PRODUCT_UNIT_ID,
                K.PRODUCT_AMOUNT,
                ISNULL((
                		SELECT 
                        	SUM(STOCK_IN - STOCK_OUT) AS REAL_STOCK 
                    	FROM 
                        	#dsn2_alias#.STOCKS_ROW WITH (NOLOCK)
                      	<CFif isdefined('attributes.department_id') and len(attributes.department_id)>
                            WHERE
                                STORE IN (#attributes.department_id#)
                      	</CFif> 
                      	GROUP BY 
                        	PRODUCT_ID 
                      	HAVING 
                        	PRODUCT_ID = K.PRODUCT_ID
               	),0) AS REAL_STOCK,
                ISNULL((
                        SELECT 
                            SUM(KP.PRODUCT_AMOUNT * ORR.QUANTITY) AS SHIP_INTERNAL_STOCK
                        FROM  
                        	EZGI_SHIP_RESULT_INTERNALDEMAND AS SI WITH (NOLOCK) INNER JOIN
                            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS SIR WITH (NOLOCK) ON SI.SHIP_RESULT_INTERNALDEMAND_ID = SIR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                            ORDER_ROW AS ORR WITH (NOLOCK) ON ORR.ORDER_ROW_ID = SIR.ORDER_ROW_ID INNER JOIN
                            STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
                            #dsn1_alias#.KARMA_PRODUCTS AS KP WITH (NOLOCK) ON S.PRODUCT_ID = KP.KARMA_PRODUCT_ID LEFT OUTER JOIN
                            #dsn2_alias#.SHIP AS SH ON SI.SHIP_RESULT_INTERNALDEMAND_ID = SH.DISPATCH_SHIP_ID
                        WHERE  
                            ISNULL(SI.IS_CLOSED,0) <> 1 AND 
                            SH.SHIP_ID IS NULL AND 
                            ISNULL(S.IS_KARMA, 0) = 1 AND
                            KP.STOCK_ID = K.STOCK_ID
                            <CFif isdefined('attributes.department_id') and len(attributes.department_id)>
                                AND SI.DEPARTMENT_ID IN (#attributes.department_id#)
                            </CFif>
                        GROUP BY 
                            KP.STOCK_ID
                ),0) AS SHIP_INTERNAL_STOCK,
                <!---ISNULL((SELECT PURCHASE_PROD_STOCK FROM #dsn2_alias#.GET_STOCK_LAST_PROFILE WHERE STOCK_ID = K.STOCK_ID),0) AS URETIM,--->
                ISNULL((
                		SELECT 
                        	STOCK_ARTIR - STOCK_AZALT AS RESERVED_STOCK
                  		FROM     
                        	GET_PRODUCTION_RESERVED 
                       	WHERE 
                        	STOCK_ID = K.STOCK_ID
              	), 0) AS URETIM,
                ISNULL((
                		SELECT
                        	SUM(RESERVE_SALE_ORDER_STOCK) AS RESERVE_SALE_ORDER_STOCK
                       	FROM
                        	(
                            		SELECT 
                                        SUM(RESERVE_SALE_ORDER_STOCK) AS RESERVE_SALE_ORDER_STOCK 
                                    FROM 
                                        #dsn3_alias#.EZGI_SALE_ORDER_RESERVED_LOCATION_DEMONTE WITH (NOLOCK)
                                    WHERE 
                                        STOCK_ID = K.STOCK_ID 
                                        <CFif isdefined('attributes.department_id') and len(attributes.department_id)>
                                            AND DELIVER_DEPT_ID IN (#attributes.department_id#)
                                        </CFif> 
                                   	GROUP BY 
                                    	STOCK_ID
                                    UNION ALL
                                    SELECT 
                                        SUM(ORR.RESERVE_STOCK_OUT-ORR.STOCK_OUT) AS RESERVE_SALE_ORDER_STOCK
                                    FROM     
                                        #dsn3_alias#.GET_ORDER_ROW_RESERVED AS ORR WITH (NOLOCK) INNER JOIN
                                        #dsn3_alias#.ORDERS AS ORDS WITH (NOLOCK) ON ORR.ORDER_ID = ORDS.ORDER_ID INNER JOIN
                                        #dsn3_alias#.STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID
                                    WHERE  
                                        ORR.RESERVE_STOCK_OUT - ORR.STOCK_OUT > 0 AND 
                                        S.IS_KARMA = 0 AND 
                                        ORDS.RESERVED = 1 AND 
                                        ORDS.ORDER_STATUS = 1 AND
                                        S.STOCK_ID = K.STOCK_ID 
                                        <CFif isdefined('attributes.department_id') and len(attributes.department_id)>
                                            AND ORDS.DELIVER_DEPT_ID IN (#attributes.department_id#)
                                        </CFif>
                     		) AS TBLS
              	),0) AS SIPARIS,
                <!---(SELECT MAIN_UNIT FROM #dsn1_alias#.PRODUCT_UNIT WITH (NOLOCK) WHERE PRODUCT_UNIT_ID = S1.PRODUCT_UNIT_ID) AS MAIN_UNIT,
                (SELECT UNIT_ID FROM #dsn1_alias#.PRODUCT_UNIT WITH (NOLOCK) WHERE PRODUCT_UNIT_ID = S1.PRODUCT_UNIT_ID) AS UNIT_ID,--->
                ISNULL((
                	SELECT
                    	SUM(TALEP)
                   	FROM
                    	(
                        SELECT        
                            ISNULL(SUM(E.QUANTITY * K.PRODUCT_AMOUNT), 0) - ISNULL(SUM(EPR.QUANTITY * K.PRODUCT_AMOUNT), 0) AS TALEP, 
                            K.STOCK_ID
                        FROM            
                            STOCKS AS S2 WITH (NOLOCK) INNER JOIN
                            EZGI_PRODUCTION_DEMAND_ROW AS E WITH (NOLOCK) ON S2.STOCK_ID = E.STOCK_ID INNER JOIN
                            EZGI_PRODUCTION_DEMAND AS EPD WITH (NOLOCK) ON E.EZGI_DEMAND_ID = EPD.EZGI_DEMAND_ID INNER JOIN
                            #dsn1_alias#.KARMA_PRODUCTS AS K WITH (NOLOCK) ON S2.PRODUCT_ID = K.KARMA_PRODUCT_ID LEFT OUTER JOIN
                            EZGI_IFLOW_PRODUCTION_ORDERS AS EPR WITH (NOLOCK) ON E.EZGI_DEMAND_ROW_ID = EPR.ACTION_ID
                        WHERE      
                            ISNULL(S2.IS_KARMA, 0) = 1 AND K.STOCK_ID = S.STOCK_ID
                        GROUP BY 
                            K.STOCK_ID
                        UNION ALL
                        SELECT        	
                            ISNULL(SUM(E.QUANTITY), 0) - ISNULL(SUM(EPR.QUANTITY), 0) AS TALEP, 
                            S3.STOCK_ID
                        FROM            
                            STOCKS AS S3 WITH (NOLOCK) INNER JOIN
                            EZGI_PRODUCTION_DEMAND_ROW AS E WITH (NOLOCK) ON S3.STOCK_ID = E.STOCK_ID INNER JOIN
                            EZGI_PRODUCTION_DEMAND AS EPD WITH (NOLOCK) ON E.EZGI_DEMAND_ID = EPD.EZGI_DEMAND_ID LEFT OUTER JOIN
                            EZGI_IFLOW_PRODUCTION_ORDERS AS EPR WITH (NOLOCK) ON E.EZGI_DEMAND_ROW_ID = EPR.ACTION_ID
                        WHERE        
                            S3.IS_KARMA = 1 AND S3.STOCK_ID = S.STOCK_ID
                        GROUP BY 
                            S3.STOCK_ID
                    	) AS TBL3
                ),0) AS TALEP
            FROM            
                STOCKS AS S WITH (NOLOCK) INNER JOIN
                #dsn1_alias#.KARMA_PRODUCTS AS K WITH (NOLOCK) ON S.PRODUCT_ID = K.KARMA_PRODUCT_ID INNER JOIN
                STOCKS AS S1 WITH (NOLOCK) ON K.STOCK_ID = S1.STOCK_ID
            WHERE        
                S.PRODUCT_STATUS = 1 AND 
                S.IS_KARMA = 1
                <cfif len(attributes.keyword)>
                	AND 
                    (
                        S.PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
                        S1.PRODUCT_NAME LIKE '%#attributes.keyword#%'
                    )
                </cfif>
                <cfif isdefined('attributes.product_code') and Len(attributes.product_code) and Len(attributes.product_cat)>
                    AND S1.PRODUCT_CODE LIKE '#attributes.product_code#.%'
                </cfif>
         	) AS TBL INNER JOIN
        	#dsn1_alias#.PRODUCT_UNIT AS PU WITH (NOLOCK) ON PU.PRODUCT_UNIT_ID = TBL.PRODUCT_UNIT_ID
   		WHERE
        	1=1
            <cfif len(attributes.unit_type)>
            	AND PU.UNIT_ID = #attributes.unit_type#
            </cfif> 
      	ORDER BY
        	TBL.PRODUCT_NAME		
    </cfquery>
	<cfset product_id_list = Valuelist(get_demonte_product.PRODUCT_ID)>
    <cfif get_demonte_product.recordcount>
    	<cfquery name="get_karma_info" datasource="#dsn1#">
        	SELECT        
                S.STOCK_ID
			FROM            
           		KARMA_PRODUCTS AS KP INNER JOIN
              	STOCKS AS S ON KP.KARMA_PRODUCT_ID = S.PRODUCT_ID
			WHERE        
            	KP.PRODUCT_ID IN (#product_id_list#)
          	GROUP BY
            	S.STOCK_ID
        </cfquery>
        <cfset k_stock_id_list = Valuelist(get_karma_info.STOCK_ID)>
        <cfif len(attributes.uretim_ay) and attributes.uretim_ay gt 0>
    		<cfquery name="get_all_sales" datasource="#dsn2#">
                SELECT
                    TBL.YIL, 
                    TBL.AY, 
                    ISNULL(SUM(TBL.SATIS * K.PRODUCT_AMOUNT), 0) AS SATIS, 
                    K.STOCK_ID
                FROM
                    (
                    SELECT     
                    	CASE WHEN I.PURCHASE_SALES = 0 THEN IR.AMOUNT * - 1 ELSE IR.AMOUNT END AS SATIS, 
                        MONTH(I.INVOICE_DATE) AS AY, 
                        YEAR(I.INVOICE_DATE) AS YIL, 
                      	IR.STOCK_ID
					FROM         
                    	INVOICE AS I WITH (NOLOCK) INNER JOIN
                      	INVOICE_ROW AS IR WITH (NOLOCK) ON I.INVOICE_ID = IR.INVOICE_ID
                    WHERE
                        I.IS_IPTAL = 0 AND 
                        ISNULL(IR.IS_PROMOTION, 0) <> 1 AND 
                        <cfif isdefined('attributes.ihr_sat') and len(attributes.ihr_sat)>
                        	I.INVOICE_CAT IN (52,53,54,55,531) AND
                        <cfelse>
                        	I.INVOICE_CAT IN (52,53,54,55) AND
                        </cfif>
                        IR.STOCK_ID IN (#k_stock_id_list#) AND
                        MONTH(I.INVOICE_DATE) >= #this_year_min_month# AND 
                        MONTH(I.INVOICE_DATE) <= #this_year_max_month# AND
                        MONTH(I.INVOICE_DATE) <> #month(now())#
                    <cfif get_last_period.recordcount>
                    	UNION ALL
                        SELECT     
                            CASE WHEN I.PURCHASE_SALES = 0 THEN IR.AMOUNT * - 1 ELSE IR.AMOUNT END AS SATIS, 
                            MONTH(I.INVOICE_DATE) AS AY, 
                            YEAR(I.INVOICE_DATE) AS YIL, 

                            IR.STOCK_ID
                        FROM         
                            #dsn#_#last_year#_#session.ep.company_id#.INVOICE AS I WITH (NOLOCK) INNER JOIN
                            #dsn#_#last_year#_#session.ep.company_id#.INVOICE_ROW AS IR WITH (NOLOCK) ON I.INVOICE_ID = IR.INVOICE_ID
                        WHERE
                            I.IS_IPTAL = 0 AND 
                            ISNULL(IR.IS_PROMOTION, 0) <> 1 AND 
                            <cfif isdefined('attributes.ihr_sat') and len(attributes.ihr_sat)>
                                I.INVOICE_CAT IN (52,53,54,55,531) AND
                            <cfelse>
                                I.INVOICE_CAT IN (52,53,54,55) AND
                            </cfif>
                            IR.STOCK_ID IN (#k_stock_id_list#) AND
                            MONTH(I.INVOICE_DATE) >= #last_year_min_month#  AND 
                            MONTH(I.INVOICE_DATE) <= #LAST_year_max_month# 
                    </cfif>
                    ) AS TBL INNER JOIN
              		#dsn1_alias#.STOCKS AS S WITH (NOLOCK) ON TBL.STOCK_ID = S.STOCK_ID INNER JOIN
                  	#dsn1_alias#.KARMA_PRODUCTS AS K WITH (NOLOCK) ON S.PRODUCT_ID = K.KARMA_PRODUCT_ID
				GROUP BY 
                	TBL.YIL, 
                    TBL.AY, 
                    K.STOCK_ID
                ORDER BY
                    K.STOCK_ID,
                    TBL.YIL,
                    TBL.AY
      		</cfquery>
        
        	<cfset stock_id_list = Valuelist(get_all_sales.STOCK_ID)>
            <cfloop list="#stock_id_list#" index="i">
                <cfquery name="get_info" dbtype="query">
                    SELECT * FROM get_all_sales WHERE STOCK_ID = #i# AND SATIS >0
                </cfquery>
                <cfquery name="get_info_total" dbtype="query">
                    SELECT sum(SATIS) AS SATIS FROM get_info
                </cfquery>
                    <cfif get_info.recordcount>
                        <cfif attributes.yontem eq 1> 
                            <cfset 'ortalama_#i#' = get_info_total.SATIS/get_info.recordcount>
                        <cfelseif attributes.yontem eq 2>
                            <cfset 'ortalama_#i#' = get_info_total.SATIS/12>
                        </cfif>
                        <cfif isdefined('attributes.calc_method') and len(attributes.calc_method)>
                            <cfset 'sapma_#i#' = 0>
                            <cfloop query="get_info">
                                <cfset 'sapma_#i#' = Evaluate('sapma_#i#') + (get_info.satis-Evaluate('ortalama_#i#'))^2>
                            </cfloop>
                            <cfif Evaluate('sapma_#i#') gt 0>
                                <cfset 'sapma_#i#' = SQR(Evaluate('sapma_#i#')/(get_info.recordcount-1))>
                                <cfset 'sapma_#i#' = Evaluate('sapma_#i#') + Evaluate('ortalama_#i#')>
                            <cfelse>
                                <cfset 'sapma_#i#' = Evaluate('ortalama_#i#')>
                            </cfif>
                        <cfelse>
                            <cfloop query="get_info">
                                <cfset 'sapma_#i#' = Evaluate('ortalama_#i#')>
                            </cfloop>
                        </cfif>
                    </cfif>
                </cfloop>
          	</cfif>
       	</cfif>
<cfelse>
	<cfset get_demonte_product.recordcount=0>
</cfif>
<cfif get_demonte_product.recordcount>
  	<cfset ilk_satirlar = queryNew("stock_id, product_id,product_code,product_name,manufact_code,unit,RESERVED_PROD_STOCK,real_stock,RESERVE_PURCHASE_ORDER_STOCK, RESERVE_SALE_ORDER_STOCK,URETIM,IS_KARMA,URETIM_PLANI,TALEP,SHIP_INTERNAL_STOCK,SALEABLE_STOCK,SIPARIS,sapma,UNIT_ID","integer,integer,VarChar,VarChar,VarChar,VarChar,Decimal,Decimal,Decimal,Decimal,Decimal,Bit,Decimal,Decimal,Decimal,Decimal,Decimal,Decimal,integer") />
  	<cfoutput query="get_demonte_product">
		<cfset Temp = QueryAddRow(ilk_satirlar)>
   		<cfset Temp = QuerySetCell(ilk_satirlar, "stock_id", stock_id)> 
		<cfset Temp = QuerySetCell(ilk_satirlar, "product_id", product_id)>
    	<cfset Temp = QuerySetCell(ilk_satirlar, "product_code", product_code)>
     	<cfset Temp = QuerySetCell(ilk_satirlar, "product_name", product_name)>
     	<cfset Temp = QuerySetCell(ilk_satirlar, "unit", Evaluate('UNIT_#UNIT_ID#'))> 
      	<cfset Temp = QuerySetCell(ilk_satirlar, "real_stock", real_stock)> 
        <cfset Temp = QuerySetCell(ilk_satirlar, "TALEP", TALEP)> 
        <cfset Temp = QuerySetCell(ilk_satirlar, "SHIP_INTERNAL_STOCK", SHIP_INTERNAL_STOCK)>
        <cfset Temp = QuerySetCell(ilk_satirlar, "URETIM", URETIM)> 
        <cfset Temp = QuerySetCell(ilk_satirlar, "SIPARIS", SIPARIS)> 
        <cfset Temp = QuerySetCell(ilk_satirlar, "UNIT_ID", UNIT_ID)> 
     	<cfif isdefined('sapma_#STOCK_ID#')>
          	<cfset Temp = QuerySetCell(ilk_satirlar, "sapma", round(Evaluate('sapma_#STOCK_ID#'))*attributes.uretim_ay)> 
      	<cfelse>
         	<cfset Temp = QuerySetCell(ilk_satirlar, "sapma", 0)>
     	</cfif>
 	</cfoutput>
   	<cfif ilk_satirlar.recordcount>
     	<cfquery name="satirlar" dbtype="query">
          	SELECT
          		*
          	FROM
            	ilk_satirlar
           	WHERE
             	1=1
         		<cfif attributes.report_type eq 1>
                    <cfif isdefined('attributes.is_production') and len(attributes.is_production)>
                        AND (REAL_STOCK+TALEP)-(SIPARIS+SAPMA+SHIP_INTERNAL_STOCK) < 0
                 	<cfelse>
                        AND (REAL_STOCK+URETIM+TALEP)-(SIPARIS+SAPMA+SHIP_INTERNAL_STOCK) < 0
                    </cfif>
               	</cfif>
             	<cfif attributes.report_type eq 2>
					<cfif isdefined('attributes.is_production') and len(attributes.is_production)>
                        AND (REAL_STOCK+TALEP)-(SIPARIS+SAPMA+SHIP_INTERNAL_STOCK) > 0
                 	<cfelse>
                    	AND (REAL_STOCK+URETIM+TALEP)-(SIPARIS+SAPMA+SHIP_INTERNAL_STOCK) > 0
                    </cfif>
             	</cfif> 
                
          	ORDER BY
            	MANUFACT_CODE,
             	PRODUCT_NAME
      	</cfquery> 
  	<cfelse>
    	<cfset satirlar.recordcount =0>
    </cfif>
<cfelse>
	<cfset satirlar.recordcount =0>
</cfif>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.totalrecords" default="#satirlar.recordcount#">
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="list_order" method="post" action="#request.self#?fuseaction=prod.popup_list_ezgi_production_demonte_need">
        	<input type="hidden" name="is_submitted" id="is_submitted" value="1">
            <cfif isdefined('attributes.upd_id')>
            	<cfinput type="hidden" name="upd_id" value="#attributes.upd_id#">
            </cfif>
            <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
            <cf_box_search>
                <div class="form-group">
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group">
                	<select name="report_type" id="report_type" style=" width:150px; height:20px" onChange="report_type_chng();">
                        	<option value=""><cf_get_lang dictionary_id='57708.Tümü'></option>
                            <option value="1" <cfif attributes.report_type eq 1>selected</cfif>><cf_get_lang dictionary_id='277.İhtiyacı Karşılamayanlar'></option>
                            <option value="2" <cfif attributes.report_type eq 2>selected</cfif>><cf_get_lang dictionary_id='278.İhtiyaç Fazlası Olanlar'></option>
                            <option value="3" <cfif attributes.report_type eq 3>selected</cfif>><cf_get_lang dictionary_id='279.Net Bakiye'></option>
                            <option value="4" <cfif attributes.report_type eq 4>selected</cfif>><cf_get_lang dictionary_id='280.Üretim Talebi Hesaplama'></option>
                	</select>
                </div>
                <div class="form-group medium">
                	<select name="unit_type" id="unit_type" style="50px; height:20px">
                        	<option value=""><cf_get_lang dictionary_id='57636.Birim'></option>
                            <cfoutput query="get_unit">
                            	<option value="#UNIT_ID#" <cfif attributes.unit_type eq UNIT_ID>selected</cfif>>#UNIT#</option>
                            </cfoutput>
                  	</select>
                </div>
                <div class="form-group medium">
                	<select name="branch_id" id="branch_id" style="70px; height:20px">
                        	<option value=""><cf_get_lang dictionary_id='29495.Tüm Şubeler'></option>
                            <cfoutput query="get_branch">
                            	<option value="#BRANCH_ID#" <cfif attributes.branch_id eq BRANCH_ID>selected</cfif>>#BRANCH_NAME#</option>
                            </cfoutput>
               		</select>
                </div>
                <div class="form-group">
                	<select name="yontem" id="yontem" style="width:120px; height:20px">
                        	<option value="1" <cfif attributes.yontem eq 1>selected</cfif>><cf_get_lang dictionary_id='29436.Standart Hesap'></option>
                            <option value="2" <cfif attributes.yontem eq 2>selected</cfif>><cf_get_lang dictionary_id='32614.12 Aylık'></option>
                	</select>
                </div>
                <div class="form-group">
                	<div class="input-group">

                    	<cfoutput>
                      	<input type="hidden" name="product_code" id="product_code" value="<cfif len(attributes.product_cat) and len(attributes.product_code)>#attributes.product_code#</cfif>">
                  		<input type="hidden" name="product_cat_id" id="product_cat_id" value="<cfif len(attributes.product_cat) and len(attributes.product_cat_id)>#attributes.product_cat_id#</cfif>">
                    	<input type="text" name="product_cat" id="product_cat" style="width:160px;" onFocus="AutoComplete_Create('product_cat','PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','0','PRODUCT_CATID,HIERARCHY','product_cat_id,product_code','','3','175','','1');" value="<cfif len(attributes.product_cat) and len(attributes.product_code)>#attributes.product_cat#</cfif>" autocomplete="off">
						<span class="input-group-addon icon-ellipsis btnPoniter" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_cat_names&is_sub_category=1&field_id=list_order.product_cat_id&field_code=list_order.product_code&field_name=list_order.product_cat&field_min=add_design.MIN_MARGIN&field_max=add_design.MAX_MARGIN');" title="<cf_get_lang dictionary_id='37157.Ürün Kategorisi Ekle'>!"></span>
                       	</cfoutput> 
                  	</div>
                </div>
                <div class="form-group">
                	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='282.Stoklama Zamanı'> (<cf_get_lang dictionary_id='40689.Ay'>)</label>
                	<div class="col col-6 col-xs-12">
                		<cfinput type="text" name="uretim_ay" id="uretim_ay" value="#attributes.uretim_ay#" style="width:20px; text-align:center">
                   	</div>
                </div>
                <div id="ihr_sat_td" class="form-group">
                	<cf_get_lang dictionary_id='281.İhracat Satışlarını Dahil Et'> 
                	<input id="ihr_sat" name="ihr_sat" value="1" type="checkbox" <cfif isdefined('attributes.ihr_sat') and len(attributes.ihr_sat)>checked</cfif>>
                </div>
                <div id="sapma_td" class="form-group">
                    <cf_get_lang dictionary_id='40054.Sapma'>
                    <input id="calc_method" name="calc_method" value="1" type="checkbox" <cfif isdefined('attributes.calc_method') and len(attributes.calc_method)>checked</cfif>>
                </div>
                <div id="uretim_td" class="form-group">
                    <cf_get_lang dictionary_id='1123.Üretim Hariç'>
                    <input id="is_production" name="is_production" value="1" type="checkbox" <cfif isdefined('attributes.is_production') and len(attributes.is_production)>checked</cfif>>
                </div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,250" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
           	</cf_box_search>
      	</cfform>
    </cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id="273.Demonte Ürün Hesaplama"></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
    	<cf_grid_list>
        	<thead>
                <tr>
                    <th width="30"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th width="100"><cf_get_lang dictionary_id='57537.Stok Kodu'></th>
                    <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                    <th width="40"><cf_get_lang dictionary_id='57636.Birim'></th>
                    <th width="50"><cf_get_lang dictionary_id='58120.Gerçek Stok'></th>
                	<th width="50"><cf_get_lang dictionary_id='283.Üretimden Gelecek'></th>
                  	<th width="50"><cf_get_lang dictionary_id='36388.Üretim Talebi'></th>
                  	<th width="50"><cf_get_lang dictionary_id='284.Toplam Artan'></th>
                    <th width="50"><cf_get_lang dictionary_id='40224.Alınan Sipariş'></th>
                    <cfif attributes.branch_id neq ''>
                    	<th width="50"><cf_get_lang dictionary_id='45525.Sevk Talebi'></th>
                  	</cfif>
                    <th width="50"><cf_get_lang dictionary_id='286.Toplam Azalan'></th>
                 	<th width="50"><cf_get_lang dictionary_id='45241.Satılabilir Stok'></th>
              		<th width="50"><cf_get_lang dictionary_id='1124.Dönem İhtiyacı'></th>
                    <th width="50"><cf_get_lang dictionary_id='36437.İhtiyaç'></th>
                 	<th style="text-align:center; width:15px">
                    	<input type="checkbox" style="text-align:center;" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="grupla(-1);">
                   	</th>
                </tr>
            </thead>
            <tbody>
                <cfif satirlar.recordcount>
                	<cfoutput query="satirlar">
						<cfset s_t_real_stock = s_t_real_stock + REAL_STOCK>
                    </cfoutput>
                    <cfoutput query="satirlar"  startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                        <tr>
                            <td style="text-align:right;">#currentrow#</td>
                            <td>
                               <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_detail_product&sid=#stock_id#','list');" class="tableyazi">
                               #PRODUCT_CODE#
                               </a>
                            </td>
                            <td>
                            	<a href="javascript://" onclick="windowopen('#request.self#?fuseaction=product.list_product&event=det&pid=#product_id#','longpage');" class="tableyazi">
                            	#PRODUCT_NAME#
                                </a>
                            </td>
                            <td>#Evaluate('UNIT_#UNIT_ID#')#</td>
                            <td style="text-align:right;">
                            	<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=stock.detail_store_stock_popup&stock_id=#stock_id#&product_id=#product_id#','page');">
                                	#Amountformat(REAL_STOCK,0)#
                              	</a>
                          	</td>
                            <td style="text-align:right;">
                                <a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=prod.popup_dsp_ezgi_reserved_production_orders&type=1&pid=#product_id#','medium');">
									#AmountFormat(URETIM,0)#
                                </a>
                            </td>
                         	<td style="text-align:right;">
                              	<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=prod.popup_dsp_ezgi_production_demand&sid=#STOCK_id#','medium');">#AmountFormat(TALEP,0)#</a>
                          	</td>
                            <td style="text-align:right;"><strong>#Amountformat(REAL_STOCK+URETIM+TALEP,0)#</strong></td>	
                            <td style="text-align:right;"><a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=objects.popup_reserved_orders&taken=1&pid=#product_id#','medium');">#Amountformat(SIPARIS,0)#</a></td>
                            <cfif attributes.branch_id neq ''>
                             	<td style="text-align:right;">#AmountFormat(SHIP_INTERNAL_STOCK,0)#</td>
                                <td style="text-align:right;"><strong>#Amountformat(SIPARIS+SHIP_INTERNAL_STOCK,0)#</strong></td>
                          	<cfelse>
                            	<td style="text-align:right;"><strong>#Amountformat(SIPARIS,0)#</strong></td>
                          	</cfif>
                       		<td style="text-align:right;">
                            	<strong>
                            	<cfif isdefined('attributes.is_production')> 
                                	<cfif attributes.branch_id neq ''>
                                    	#AmountFormat((REAL_STOCK+TALEP)-(SIPARIS + SHIP_INTERNAL_STOCK),0)#
                                    <cfelse>
                            			#AmountFormat((REAL_STOCK+TALEP)-(SIPARIS),0)#
                                    </cfif>
                                <cfelse>
                                	<cfif attributes.branch_id neq ''>
                                    	#AmountFormat((REAL_STOCK+URETIM+TALEP)-(SIPARIS  + SHIP_INTERNAL_STOCK),0)#
                                    <cfelse>
                                    	#AmountFormat((REAL_STOCK+URETIM+TALEP)-(SIPARIS),0)#
                                    </cfif>
                                </cfif>
                            	</strong>
                            </td>
                          	<td style="text-align:right;">
                                	<cfif isdefined('sapma_#STOCK_ID#')>
                                    	<a href="javascript://" class="tableyazi" onclick="windowopen('#request.self#?fuseaction=prod.popup_dsp_ezgi_production_need&sid=#STOCK_id#&is_demonte=1<cfif isdefined('attributes.ihr_sat')>&ihr_sat=#attributes.ihr_sat#</cfif>&uretim_ay=#attributes.uretim_ay#','small');">
                                			#TlFormat(sapma,0)#
                                      	</a>  
                                  	<cfelse>
                                    	0
                                    </cfif>
                          	 </td>
                            <cfset need_stock = 0>
                         	<td style="text-align:right;">
									<cfif isdefined('attributes.is_production')> 
                                    	<cfif attributes.branch_id neq ''>
                                        	<cfset need_stock = (REAL_STOCK+TALEP)-(SIPARIS+SAPMA+SHIP_INTERNAL_STOCK)>
                                        <cfelse>
                                        	<cfset need_stock = (REAL_STOCK+TALEP)-(SIPARIS+SAPMA)>
                                        </cfif>
                                    <cfelse>
                                    	<cfif attributes.branch_id neq ''>
                                        	<cfset need_stock = (REAL_STOCK+URETIM+TALEP)-(SIPARIS+SAPMA+SHIP_INTERNAL_STOCK) >
                                        <cfelse>
                                        	<cfset need_stock = (REAL_STOCK+URETIM+TALEP)-(SIPARIS+SAPMA) >
                                        </cfif>
                                    </cfif>
                                    <cfif need_stock lt 0>
                                        <cfset need_stock = need_stock * -1>
                                    <cfelse>
                                        <cfset need_stock = 0>
                                    </cfif>

    							<input type="text" name="need_stock_#STOCK_ID#"  id="need_stock_#STOCK_ID#" value="#TlFormat(need_stock,0)#" style="text-align:right; width:50px" class="box">
                      		</td>
                        	<td style="text-align:center;">
                            	<input type="checkbox" name="select_production_#STOCK_ID#" id="select_production_#STOCK_ID#" value="1">
                          	</td>
                            <cfset son_row = currentrow>
                        </tr>
                    </cfoutput>
                <cfelse>
                    <tr>
                        <td colspan="14" class="color-row"><cfif isdefined("attributes.is_submitted")><cf_get_lang dictionary_id='57484.Kayıt Yok'><cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz'></cfif>!</td>
                    </tr>
                </cfif>
                <cfif isdefined("attributes.is_submitted")>
                    <tfoot>
                        <tr>
                            <cfif isdefined("attributes.is_submitted") and attributes.totalrecords gt son_row>
                                <cfoutput>
                                    <td style="text-align:right;" colspan="4"><cf_get_lang dictionary_id='39183.Sayfa Toplam'></td>
                                    <td style="text-align:right;">#AmountFormat(t_real_stock,0)#</td>
                                    <td colspan="6"></td>
                                    <td style="text-align:center;" colspan="3">
                                        <button  value="" id="product_demand" onClick="grupla(-2);" style="width:140px; height:25px;">&nbsp;<cf_get_lang dictionary_id='287.Üretim Talebine Ekle'></button>
                                    </td>
                                </cfoutput>
                            <cfelse>
                                <cfoutput>
                                    <td style="text-align:right;" colspan="4"><strong><cf_get_lang dictionary_id='57680.Genel Toplam'></strong></td>
                                    <td style="text-align:right;"><strong>#AmountFormat(s_t_real_stock,0)#</strong></td>
                                    <td colspan="6"></td>
                                    <td style="text-align:center;" colspan="3">
                                        <button  value="" id="product_demand" onClick="grupla(-2);" style="width:140px; height:25px;">&nbsp;<cf_get_lang dictionary_id='287.Üretim Talebine Ekle'></button>
                                    </td>
                                </cfoutput>
                            </cfif>     
                        </tr>
                    </tfoot>
                </cfif>
            </tbody>
     	</cf_grid_list>
        <cfset adres="prod.popup_list_ezgi_production_need&is_submitted=1">
		<cfif len(attributes.keyword)>
            <cfset adres = "#adres#&keyword=#attributes.keyword#">
        </cfif>
        <cfif isdefined('attributes.report_type') and len(attributes.report_type)>
            <cfset adres = "#adres#&report_type=#attributes.report_type#">
        </cfif>
        <cfif Len(attributes.product_code)>
            <cfset adres = "#adres#&product_code=#attributes.product_code#">
        </cfif>
        <cfif Len(attributes.product_cat)>
            <cfset adres = "#adres#&product_cat=#attributes.product_cat#">
        </cfif>
        <cfif isdefined('attributes.upd_id') and len(attributes.upd_id)>
            <cfset adres = "#adres#&upd_id=#attributes.upd_id#">
        </cfif>
        <cfif isdefined('attributes.ihr_sat') and len(attributes.ihr_sat)>
            <cfset adres = "#adres#&ihr_sat=#attributes.ihr_sat#">
        </cfif>
        <cfif isdefined('attributes.calc_method') and len(attributes.calc_method)>
            <cfset adres = "#adres#&calc_method=#attributes.calc_method#">
        </cfif>
        <cfif isdefined('attributes.is_production') and len(attributes.is_production)>
            <cfset adres = "#adres#&is_production=#attributes.is_production#">
        </cfif>
        <cfif isdefined('attributes.yontem') and len(attributes.yontem)>
            <cfset adres = "#adres#&yontem=#attributes.yontem#">
        </cfif>
        <cfif isdefined('attributes.unit_type') and len(attributes.unit_type)>
            <cfset adres = "#adres#&unit_type=#attributes.unit_type#">
        </cfif>
        <cfif isdefined('attributes.branch_id') and len(attributes.branch_id)>
            <cfset adres = "#adres#&branch_id=#attributes.branch_id#">
        </cfif>
        <cf_paging page="#attributes.page#"
            maxrows="#attributes.maxrows#"
            totalrecords="#attributes.totalrecords#"
            startrow="#attributes.startrow#"
            adres="#adres#">
    </cf_box>
</div>
<script language="javascript">
	function grupla(type)
	{
		stock_id_list = '';
		<cfif satirlar.recordcount>
        	<cfoutput query="satirlar"  startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
				stockid = #stock_id#;
				if(eval('document.all.select_production_'+stockid).checked==true)
				{
					if(document.getElementById('need_stock_'+stockid).value > 0)
						stock_id_list +=stockid+'_'+document.getElementById('need_stock_'+stockid).value+',';
				}
				if(type == -1)
				{//hepsini seç denilmişse	
					if(eval('document.all.select_production_'+stockid).checked==true)
						document.getElementById('select_production_'+stockid).checked = false;
					else
						document.getElementById('select_production_'+stockid).checked = true;
				}
			</cfoutput>
		</cfif>
		if(type == -2)
		{
			stock_id_list = stock_id_list.substr(0,stock_id_list.length-1);//sondaki virgülden kurtarıyoruz.
			if(stock_id_list!='')
			{
				document.getElementById('product_demand').disabled = true;
				<cfif isdefined('attributes.upd_id')>
					window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_upd_ezgi_production_demand&upd_id=#attributes.upd_id#&stock_id_list=</cfoutput>"+stock_id_list;
				<cfelse>
					windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.list_ezgi_e_planning&event=add&stock_id_list='+stock_id_list,'longpage');
				</cfif>
			}
		}
	}
	function input_control()
	{
		return true;
	}
</script>
