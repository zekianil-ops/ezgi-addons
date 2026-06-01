<!---
    File: list_ezgi_material_system.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->


<cfset sifir = 0>
<cfparam name="attributes.price_cat" default="-1">
<cfparam name="attributes.ezgi_type" default="1">
<cfparam name="attributes.controller_emp_id" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.is_filtre" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.list_type" default="1">
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
<cfquery name="get_alt_plan_no" datasource="#dsn3#">
	SELECT MASTER_PLAN_ID,MASTER_ALT_PLAN_NO FROM EZGI_MASTER_ALT_PLAN WHERE MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
</cfquery>

<cfset attributes.master_plan_id = get_alt_plan_no.MASTER_PLAN_ID>
<cfset alt_plan_no = get_alt_plan_no.MASTER_ALT_PLAN_NO>

<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT 
    	EMO.MASTER_PLAN_CAT_ID, 
        PD.DEFAULT_RAW_STORE_ID, 
        PD.DEFAULT_RAW_LOC_ID, 
        PD.DEFAULT_PRODUCTION_STORE_ID, 
        PD.DEFAULT_PRODUCTION_LOC_ID
	FROM     
    	EZGI_MASTER_PLAN AS EMO WITH (NOLOCK) INNER JOIN
        EZGI_MASTER_PLAN_DEFAULTS AS PD WITH (NOLOCK) ON EMO.MASTER_PLAN_CAT_ID = PD.SHIFT_ID
	WHERE  
    	EMO.MASTER_PLAN_ID = #attributes.master_plan_id#
</cfquery>
<cfif not get_defaults.recordcount or not len(get_defaults.DEFAULT_RAW_STORE_ID) or not len(get_defaults.DEFAULT_PRODUCTION_STORE_ID)>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='919.Üretim Genel Default Tanımlarını Yapınız'>");
		window.close()
	</script>
    <cfabort>
</cfif>
<cfquery name="get_production_location" datasource="#dsn#">
	SELECT        
        COMMENT
	FROM            
    	STOCKS_LOCATION WITH (NOLOCK)
	WHERE        
    	DEPARTMENT_ID = #get_defaults.DEFAULT_PRODUCTION_STORE_ID# AND
        LOCATION_ID = #get_defaults.DEFAULT_PRODUCTION_LOC_ID#
</cfquery>
<cfquery name="get_ready_location" datasource="#dsn#">
	SELECT        
        COMMENT
	FROM            
    	STOCKS_LOCATION WITH (NOLOCK)
	WHERE        
    	DEPARTMENT_ID = #get_defaults.DEFAULT_RAW_STORE_ID# AND
        LOCATION_ID = #get_defaults.DEFAULT_RAW_LOC_ID#
</cfquery>
<cfparam name="attributes.production_dep_id" default="#get_defaults.DEFAULT_PRODUCTION_STORE_ID#">
<cfparam name="attributes.production_loc_id" default="#get_defaults.DEFAULT_PRODUCTION_LOC_ID#">
<cfparam name="attributes.production_loc_name" default="#get_production_location.COMMENT#">
<cfparam name="attributes.ready_dep_id" default="#get_defaults.DEFAULT_RAW_STORE_ID#">
<cfparam name="attributes.ready_loc_id" default="#get_defaults.DEFAULT_RAW_LOC_ID#">
<cfparam name="attributes.ready_loc_name" default="#get_ready_location.COMMENT#">
<cfif isdefined("attributes.form_varmi")>
	<cfquery name="metarial_system_row" datasource="#dsn3#">
    	SELECT  
        	IS_PRODUCTION,   
        	PRODUCT_ID, 
            STOCK_ID, 
            STOCK_CODE, 
            PRODUCT_NAME, 
            UNIT, 
            SUM(AMOUNT) AS AMOUNT, 
            SPECT_MAIN_ID,
            PRODUCT_CATID,
            SUM(SARF_MIKTAR) AS SARF_MIKTAR
		FROM         
        	(
            SELECT   
            	S.IS_PRODUCTION,
            	S.PRODUCT_ID, 
                S.STOCK_ID, 
                S.STOCK_CODE, 
                S.PRODUCT_NAME + ' - ' + ISNULL(S.PROPERTY, '') AS PRODUCT_NAME, 
                S.PRODUCT_CATID,
                PU.ADD_UNIT AS UNIT, 
                POS.AMOUNT, 
                POS.SPECT_MAIN_ID,
                ISNULL((
                SELECT     
                	SUM(PORR.AMOUNT) AS SARF_MIKTAR
				FROM         
                	PRODUCTION_ORDER_RESULTS AS POR WITH (NOLOCK) INNER JOIN
                    PRODUCTION_ORDER_RESULTS_ROW AS PORR WITH (NOLOCK) ON POR.PR_ORDER_ID = PORR.PR_ORDER_ID
				WHERE     
                	POR.P_ORDER_ID = PO.P_ORDER_ID AND 
                    POR.IS_STOCK_FIS = 1 AND 
                    PORR.TYPE = 2 AND 
                    PORR.STOCK_ID = S.STOCK_ID
                ),0) AS SARF_MIKTAR
         	FROM          
            	STOCKS AS S INNER JOIN
                PRODUCTION_ORDERS_STOCKS AS POS WITH (NOLOCK) ON S.STOCK_ID = POS.STOCK_ID INNER JOIN
                PRODUCT_UNIT AS PU WITH (NOLOCK) ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN
                PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON POS.P_ORDER_ID = PO.P_ORDER_ID
            WHERE 
            	<cfif len(attributes.is_filtre)>
                	(S.STOCK_CODE LIKE '%#attributes.is_filtre#%' OR PRODUCT_NAME LIKE '%#attributes.is_filtre#%') AND
                </cfif> 
                POS.TYPE = 2 AND 
                S.IS_PURCHASE = 1 AND
                S.IS_PRODUCTION = 0 AND
                <cfif attributes.list_type eq 1><!--- MRP Ürünler İse--->
                	ISNULL(S.IS_LIMITED_STOCK,0) = 0 AND 
                <cfelseif attributes.list_type eq 2><!--- Kanban Ürünler İse--->
                	S.IS_LIMITED_STOCK = 1 AND 
                </cfif> 
                PO.P_ORDER_ID IN 
                                (
                                SELECT     
        							P.P_ORDER_ID
                                FROM         
                                    EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) INNER JOIN
                                    EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) ON EMAP.MASTER_ALT_PLAN_ID = EMPR.MASTER_ALT_PLAN_ID INNER JOIN
                                    PRODUCTION_ORDERS AS P WITH (NOLOCK) ON EMPR.P_ORDER_ID = P.P_ORDER_ID
                                WHERE     
                                    EMAP.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id# OR
                                    EMAP.RELATED_MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
                                )
        	) AS TBL
		GROUP BY 
        	IS_PRODUCTION, 
        	PRODUCT_ID, 
            STOCK_ID, 
            STOCK_CODE, 
            PRODUCT_NAME, 
            UNIT, 
            SPECT_MAIN_ID,
            PRODUCT_CATID
		ORDER BY 
        	STOCK_CODE
	</cfquery>
    <cfif metarial_system_row.recordcount>
		<cfset stock_id_list = Valuelist(metarial_system_row.STOCK_ID)>
        <cfquery name="get_stock" datasource="#dsn2#">
            SELECT 
                SUM(SR.STOCK_IN-SR.STOCK_OUT) PRODUCT_STOCK,
                SR.STOCK_ID,
                SR.STORE AS DEPARTMENT_ID,
                SR.STORE_LOCATION AS LOCATION_ID
            FROM 
                STOCKS_ROW SR WITH (NOLOCK)
            WHERE
                SR.STORE IN (#attributes.production_dep_id#,#attributes.ready_dep_id#) AND
                SR.STORE_LOCATION IN (#attributes.production_loc_id#,#attributes.ready_loc_id#) AND
                SR.STOCK_ID IN (#stock_id_list#)
            GROUP BY
                SR.STOCK_ID,
                SR.STORE,
                SR.STORE_LOCATION
            ORDER BY
                SR.STOCK_ID,
                SR.STORE,
                SR.STORE_LOCATION      
        </cfquery>
        <cfoutput query="get_stock">
        	<cfset 'PRODUCT_STOCK_#STOCK_ID#_#DEPARTMENT_ID#_#LOCATION_ID#' = PRODUCT_STOCK>
        </cfoutput>
        <cfquery name="get_period" datasource="#dsn#">
            SELECT     
            	TOP (2)
                PERIOD_YEAR
            FROM         
                SETUP_PERIOD WITH (NOLOCK)
            WHERE     
                OUR_COMPANY_ID = #session.ep.company_id#
          	ORDER BY
            	PERIOD_YEAR desc      
        </cfquery>
        <!---Bu Plan için Üretime çıkılmış Ambar Fişleri için 2 seneleik period arıyoruz--->
        <cfset our_company_years = Valuelist(get_period.PERIOD_YEAR)>
        <cfquery name="get_ambar_fis" datasource="#dsn3#">
        	SELECT
            	SUM(STOCK_IN) AS AMBAR_STOCK,
                STOCK_ID
          	FROM
            	(      
                <cfloop list="#our_company_years#" index="comp_ii">
                    SELECT     
                        SR.STOCK_IN,
                        SR.STOCK_ID
                    FROM         
                        #dsn#_#comp_ii#_#session.ep.company_id#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                        #dsn#_#comp_ii#_#session.ep.company_id#.STOCKS_ROW AS SR WITH (NOLOCK) ON SF.FIS_ID = SR.UPD_ID
                    WHERE     
                        SF.FIS_TYPE = 113 AND 
                        SF.REF_NO = '#alt_plan_no#' AND 
                        SR.STORE = #attributes.production_dep_id# AND 
                        SR.STORE_LOCATION = #attributes.production_loc_id# AND 
                        SR.STOCK_IN > 0 AND 
                        SR.STOCK_ID IN (#stock_id_list#)
                        <cfif listlen(our_company_years) neq 1 and comp_ii neq listlast(our_company_years,',')> UNION ALL </cfif>
                </cfloop>
                ) AS TBL
          	GROUP BY
            	STOCK_ID
        </cfquery>
        <cfoutput query="get_ambar_fis">
        	<cfset 'AMBAR_STOCK_#STOCK_ID#' = AMBAR_STOCK>
        </cfoutput>
        <!---Bu Plan için Açılmış İç Talepleri arıyoruz--->
        <cfquery name="GET_INTERNALDEMAND" datasource="#dsn3#">
        	SELECT     
            	IR.STOCK_ID, 
                SUM(IR.QUANTITY) AS TALEP_STOCK
			FROM         
            	INTERNALDEMAND AS I WITH (NOLOCK) INNER JOIN
                INTERNALDEMAND_ROW AS IR WITH (NOLOCK) ON I.INTERNAL_ID = IR.I_ID
			WHERE     
            	I.REF_NO = '#alt_plan_no#' AND
                IR.STOCK_ID IN (#stock_id_list#) AND
                <cfif attributes.ezgi_type eq 1>
                	DEMAND_TYPE = 0
                <cfelse>
                	DEMAND_TYPE = 1
                </cfif>
			GROUP BY 
            	IR.STOCK_ID
        </cfquery>
        <cfoutput query="GET_INTERNALDEMAND">
        	<cfset 'TALEP_STOCK_#STOCK_ID#' = TALEP_STOCK>
        </cfoutput>
        <cfquery name="GET_MONEY" datasource="#DSN2#">
            SELECT * FROM SETUP_MONEY WITH (NOLOCK)
        </cfquery>
        <!--- ÜRÜN FİYATLAR --->
    	<cfquery name="GET_PRICE" datasource="#DSN3#">
        	SELECT
            	P.MONEY,
               	P.PRICE,
               	S.STOCK_ID
          	FROM
				<cfif attributes.price_cat eq -1>
					PRICE_STANDART P WITH (NOLOCK),
				<cfelse>
					PRICE P WITH (NOLOCK),
				</cfif>
              	STOCKS S WITH (NOLOCK)
       		WHERE
            	S.PRODUCT_ID = P.PRODUCT_ID AND
                S.STOCK_ID IN (#stock_id_list#) AND
				<cfif attributes.price_cat eq -1>
					P.PRICESTANDART_STATUS = 1 AND
					P.PURCHASESALES = 0
				<cfelse>
					ISNULL(P.STOCK_ID,0)=0 AND
					ISNULL(P.SPECT_VAR_ID,0)=0 AND
					P.STARTDATE <= #now()# AND
					(P.FINISHDATE >= #now()# OR P.FINISHDATE IS NULL) AND
					P.PRICE_CATID = #attributes.price_cat#
				</cfif>
      	</cfquery>
        <cfif GET_PRICE.RECORDCOUNT>
        	<cfscript>
            	for(prod_xx=1;prod_xx lte GET_PRICE.recordcount; prod_xx=prod_xx+1)
				{
                	'product_price_#GET_PRICE.STOCK_ID[prod_xx]#' = GET_PRICE.PRICE[prod_xx];
					'product_money_#GET_PRICE.STOCK_ID[prod_xx]#' = GET_PRICE.MONEY[prod_xx];
				}
         	</cfscript>
      	</cfif>
    </cfif>
</cfif>

<cfif isdefined("attributes.form_varmi")>
	<cfif not isdefined("metarial_system_row.QUERY_COUNT")>
    	<cfparam name="attributes.totalrecords" default="#metarial_system_row.recordcount#">
    <cfelse>
    	<cfparam name="attributes.totalrecords" default="0">
    </cfif>
<cfelse>
	<cfparam name="attributes.totalrecords" default="0">
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="list_meterials" id="list_meterials" method="post" action="#request.self#?fuseaction=prod.popup_ezgi_material_system">
            <input name="form_varmi" id="form_varmi" value="1" type="hidden">
            <cfinput name="master_alt_plan_id" id="master_alt_plan_id" value="#attributes.master_alt_plan_id#" type="hidden">
            <cf_box_search>
                <div class="form-group"  id="item-is_filtre">
                    <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="is_filtre" value="#attributes.is_filtre#">
               	</div>
                <div class="form-group"  id="item-list_type">	
                    <select name="list_type" style="width:120px; height:20px">
                     	<option value="1" <cfif attributes.list_type eq 1>selected</cfif>> <cf_get_lang dictionary_id='1033.MRP Ürünler'></option>
                    	<option value="2" <cfif attributes.list_type eq 2>selected</cfif>> <cf_get_lang dictionary_id='1034.Kanban Ürünler'></option>
               		</select>
              	</div>
                <div class="form-group"  id="item-ezgi_type">	
                    <select name="ezgi_type" id="ezgi_type" style="width:150px; height:20px">
                    	<option value="1" <cfif attributes.ezgi_type eq 1>selected</cfif>><cf_get_lang dictionary_id='58798.İç Talep'></option>
                        <option value="2" <cfif attributes.ezgi_type eq 2>selected</cfif>><cf_get_lang dictionary_id='49752.Satınalma Talebi'></option>
                     	<option value="3" <cfif attributes.ezgi_type eq 3>selected</cfif>><cf_get_lang dictionary_id='29630.Ambar Fişi'></option>
                   	</select>
              	</div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>
          		<div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
			</cf_box_search>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id='480.Alt Plan Malzeme Kontrol Sistemi'></cfsavecontent>
    		<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
      			<cf_grid_list>
                	<thead>
                        <tr>
                            <th style="width:30px;text-align:center; height:20px" class="header_icn_txt"><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th style="text-align:right;width:90px"><cf_get_lang dictionary_id ='57518.Stok Kodu'></th>
                            <th><cf_get_lang dictionary_id ='57657.Ürün'></th>
                            <th style="width:60px; text-align:center" class="txtbold"><cfoutput>#attributes.ready_loc_name#</cfoutput></th>
                            <th style="width:60px; text-align:center" class="txtbold"><cfoutput>#attributes.production_loc_name#</cfoutput></th>
                            <th style="text-align:right;width:60px"><cf_get_lang dictionary_id='484.Depo Toplamı'></th>
                            <th style="text-align:right;width:60px"><cf_get_lang dictionary_id='485.Plan İhtiyacı'></th>
                            <th style="text-align:right;width:40px" title="<cf_get_lang dictionary_id ='57636.Birim'>"><cf_get_lang dictionary_id ='57636.Birim'></th>
                            <th style="text-align:right;width:60px"><cf_get_lang dictionary_id='29628.Sarf Fişi'></th>
                            <th style="text-align:right;width:60px"><cf_get_lang dictionary_id='1048.Kalan İhtiyaç'></th>
                            <th style="text-align:right;width:60px" title="<cf_get_lang dictionary_id='1032.Verilen İç Talep Miktarı'>"><cf_get_lang dictionary_id='58798.İç Talep'></th>
                            <th style="text-align:right;width:60px" title="<cf_get_lang dictionary_id='487.Ambar Fişi Miktarı'>"><cf_get_lang dictionary_id='29630.Ambar Fişi'></th>
                            <th style="text-align:right;width:60px"><cfif attributes.ezgi_type eq 1><cf_get_lang dictionary_id='58798.İç Talep'><cfelse><cf_get_lang dictionary_id='29630.Ambar Fişi'></cfif> <cf_get_lang dictionary_id ='58444.Kalan'></th>
                            
                            <th style="width:20px; text-align:center"></th>
                       </tr>
                    </thead>
                    <cfset renk = 1>
                    
    				<tbody>
						<cfif isdefined("attributes.form_varmi") and metarial_system_row.recordcount>
                        	<cfset category = metarial_system_row.PRODUCT_CATID>
                            <cfoutput query="metarial_system_row" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                            	<cfif category neq metarial_system_row.PRODUCT_CATID> 
                            		<cfif renk eq 1>
                                    	<cfset renk = 2>
                                  	<cfelse>
                                    	<cfset renk = 1>
                                  	</cfif>
                                    <cfset category = metarial_system_row.PRODUCT_CATID>
                              	</cfif>
                                <tr style="background-color:<cfif renk eq 1>gainsboro<cfelse>white</cfif>">
                                    <cfset toplam_urun = 0>
                                    <td style="text-align:right">
                                        <cfif metarial_system_row.IS_PRODUCTION eq 1>
                                            <font style="background-color:orange">
                                        </cfif>
                                        #currentrow#
                                        <cfif metarial_system_row.IS_PRODUCTION eq 1>
                                            </font>
                                        </cfif>
                                    </td>
                                    <td style="text-align:center">
                                        <cfif metarial_system_row.IS_PRODUCTION eq 1>
                                            <font style="background-color:orange">
                                        </cfif>
                                        #STOCK_CODE#
                                        <cfif metarial_system_row.IS_PRODUCTION eq 1>
                                            </font>
                                        </cfif>
                                    </td>
                                    <td style="text-align:left">
                                        <cfif metarial_system_row.IS_PRODUCTION eq 1>
                                            <font style="background-color:orange">
                                        </cfif>
                                        #product_name#
                                        <cfif metarial_system_row.IS_PRODUCTION eq 1>
                                            </font>
                                        </cfif>
                                    </td>
                                    <td style="text-align:right">
                                        <cfif isdefined('PRODUCT_STOCK_#metarial_system_row.STOCK_ID#_#attributes.ready_dep_id#_#attributes.ready_loc_id#')>
                                            #TlFormat(Evaluate('PRODUCT_STOCK_#metarial_system_row.STOCK_ID#_#attributes.ready_dep_id#_#attributes.ready_loc_id#'),2)#
                                            <cfset toplam_urun = Evaluate('PRODUCT_STOCK_#metarial_system_row.STOCK_ID#_#attributes.ready_dep_id#_#attributes.ready_loc_id#')>
                                        <cfelse>
                                            #TlFormat(0,2)#
                                        </cfif>
                                    </td>
                                    
                                    <td style="text-align:right">
                                        <cfif isdefined('PRODUCT_STOCK_#metarial_system_row.STOCK_ID#_#attributes.production_dep_id#_#attributes.production_loc_id#')>	
                                            #TlFormat(Evaluate('PRODUCT_STOCK_#metarial_system_row.STOCK_ID#_#attributes.production_dep_id#_#attributes.production_loc_id#'),2)#
                                            <cfset toplam_urun = toplam_urun + Evaluate('PRODUCT_STOCK_#metarial_system_row.STOCK_ID#_#attributes.production_dep_id#_#attributes.production_loc_id#')>
                                        <cfelse>
                                            #TlFormat(0,2)#
                                        </cfif>
                                    </td>
                                    
                                    <td style="text-align:right">
                                        <cfif toplam_urun lt 0>
                                            <font color="red">
                                        <cfelse>     
                                            <font color="black">
                                        </cfif>
                                            #TlFormat(toplam_urun,2)#
                                        </font>
                                    </td> 
                                    <td style="text-align:right">#TlFormat(amount,2)#</td>
                                    <td style="text-align:left">#unit#</td>
                                    <td style="text-align:right">#TlFormat(SARF_MIKTAR,2)#</td>
                                    <td style="text-align:right">
                                        <cfif amount-SARF_MIKTAR lt 0>
                                            <font color="red">
                                        <cfelseif amount-SARF_MIKTAR eq 0>    
                                            <font color="green">
                                        <cfelse>     
                                            <font color="black">
                                        </cfif>
                                        #TlFormat(amount-SARF_MIKTAR,2)#
                                        </font>
                                    </td>
                                    <td style="text-align:right">
                                        <cfif isdefined('TALEP_STOCK_#STOCK_ID#')>
                                            <cfif amount - Evaluate('TALEP_STOCK_#STOCK_ID#') lte 0>    
                                                <font color="green">
                                            <cfelse>     
                                                <font color="black">
                                            </cfif>
                                                #TlFormat(Evaluate('TALEP_STOCK_#STOCK_ID#'),2)#
                                            </font>
                                        <cfelse>
                                            #TlFormat(sifir,2)#     
                                        </cfif>
                                    </td>
                                    <td style="text-align:right">
                                        <cfif isdefined('AMBAR_STOCK_#STOCK_ID#')>
                                            <cfif amount - Evaluate('AMBAR_STOCK_#STOCK_ID#') lte 0>    
                                                <font color="green">
                                            <cfelse>     
                                                <font color="black">
                                            </cfif>
                                                #TlFormat(Evaluate('AMBAR_STOCK_#STOCK_ID#'),2)#
                                            </font>     
                                        <cfelse>
                                            #TlFormat(sifir,2)#       
                                        </cfif>
                                    </td>
                                    <td style="text-align:right">
                                        <cfif attributes.ezgi_type eq 1>
                                            <cfif isdefined('TALEP_STOCK_#STOCK_ID#')>
                                                <cfset row_total_need = amount - Evaluate('TALEP_STOCK_#STOCK_ID#')>
                                            <cfelse>
                                                <cfset row_total_need = amount>
                                            </cfif>     
                                        <cfelse>
                                            <cfif isdefined('AMBAR_STOCK_#STOCK_ID#')>
                                                <cfset row_total_need = amount - Evaluate('AMBAR_STOCK_#STOCK_ID#')>
                                            <cfelse>
                                                <cfset row_total_need = amount>
                                            </cfif>
                                        </cfif>
                                        <cfif row_total_need lt 0><cfset row_total_need = 0></cfif>
                                        <input type="text" name="row_total_need_#stock_id#" id="row_total_need_#stock_id#" value="#tlformat(row_total_need)#" class="box" style="width:80px;" onKeyup="return(FormatCurrency(this,event));" onBlur="hesapla(#stock_id#);">
                                    </td>
                                    <td style="text-align:center">
                                        <input type="checkbox" name="conversion_product_#stock_id#" value="#stock_id#" id="_conversion_product_#currentrow#">
                                    </td>
                                    <cfif isdefined('product_price_#STOCK_ID#')>
                                        <cfset row_price =  Evaluate('product_price_#STOCK_ID#')>
                                    <cfelse>
                                        <cfset row_price = 0 >
                                    </cfif>
                                    <input type="hidden" name="row_price_unit_#stock_id#" id="row_price_unit_#stock_id#" value="#tlformat(row_price)#">
                                    <input type="hidden" name="row_price_#stock_id#" id="row_price_#stock_id#" value="#tlformat(row_total_need*row_price)#" onKeyup="return(FormatCurrency(this,event));">
                                    <select name="row_stock_money_#stock_id#" id="row_stock_money_#stock_id#" style="width:45px;display:none;">
                                        <cfloop query="get_money">
                                                        <option value="#money#,#RATE2#"<cfif isdefined('product_money_#metarial_system_row.STOCK_ID#') and Evaluate('product_money_#metarial_system_row.STOCK_ID#') is money>selected</cfif>>#money#</option>
                                        </cfloop>
                                    </select>
                                </tr>
                                <cfset son_row = currentrow>
                            </cfoutput>
                            <tfoot>
                                <tr>
                                    <td colspan="13" style="text-align:right">
                                        <cfif attributes.ezgi_type eq 3>
                                            <button name="ambar_fisi" id="ambar_fisi" onClick="kota_kontrol(3);" style="width:160px; background-color:silver"><cf_get_lang dictionary_id='36898.Ambar Fişi Oluştur'></button>
                                    	<cfelseif attributes.ezgi_type eq 1>
                                            <button name="ic_talep" id="ic_talep" onClick="kota_kontrol(1);" style="width:160px; background-color:silver"><cf_get_lang dictionary_id='51117.İç Talep Ekle'></button>
                                        <cfelseif attributes.ezgi_type eq 2>
                                             <button name="satin_alma_talebi" id="satin_alma_talebi" onClick="kota_kontrol(2);" style="width:160px; background-color:silver"><cf_get_lang dictionary_id='36901.Satın Alma Talebi Ekle'></button>
                                        </cfif>
                                    </td>
                                    <td style="text-align:center">
                                        <input type="checkbox" name="all_conv_product" id="all_conv_product" onClick="javascript: wrk_select_all2('all_conv_product','_conversion_product_',<cfoutput>#metarial_system_row.recordcount#</cfoutput>);">
                                    </td>
                                </tr>
                            </tfoot>  
                            
                        <cfelse>
                            <tr><td class="color-row" colspan="20"><cfif not isdefined("attributes.form_varmi")><cf_get_lang dictionary_id='57701.Filtre ediniz'> !<cfelse><cf_get_lang dictionary_id='57484.Kayıt Yok'> !</cfif></td></tr>
                        </cfif>
    				</tbody>
              	</cf_grid_list>
                <cfset adres="prod.popup_ezgi_material_system">
				<cfif len(attributes.is_filtre)>
					<cfset adres = "#adres#&is_filtre=#attributes.is_filtre#">
                </cfif>
                <cfif len(attributes.master_alt_plan_id)>
                    <cfset adres = "#adres#&master_alt_plan_id=#attributes.master_alt_plan_id#">
                </cfif>
                <cfif len(attributes.ezgi_type)>
                    <cfset adres = "#adres#&ezgi_type=#attributes.ezgi_type#">
                </cfif>
                <cf_paging 
                    page="#attributes.page#"
                    maxrows="#attributes.maxrows#"
                    totalrecords="#attributes.totalrecords#"
                    startrow="#attributes.startrow#"
                    adres="#adres#&form_varmi=1">  
         	</cf_box>
		</cfform>
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
</form>
<script type="text/javascript">
	document.getElementById('is_filtre').focus();
	function input_control()
	{
		return true;	
	}
	function kota_kontrol(type)
	{
				/*
		___Type__
		2:Ambar Fişi
		3:Satın Alma Talebi
		*/
		 var convert_list ="";
		 var convert_list_amount ="";
		 var convert_list_price ="";
		 var convert_list_price_other="";
		 var convert_list_money ="";
		 //
		 <cfif isdefined("attributes.form_varmi")>
			 <cfoutput query="metarial_system_row" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
				 if(document.all.conversion_product_#stock_id#.checked && filterNum(document.getElementById('row_total_need_#stock_id#').value) > 0)
				 {
					convert_list += "#stock_id#,";
					convert_list_amount += filterNum(document.getElementById('row_total_need_#stock_id#').value,3)+',';
					convert_list_price_other += filterNum(document.getElementById('row_price_unit_#stock_id#').value,3)+',';
					convert_list_price += list_getat(document.getElementById('row_stock_money_#stock_id#').value,2,',')*filterNum(document.getElementById('row_price_unit_#stock_id#').value,8)+',';
					convert_list_money += list_getat(document.getElementById('row_stock_money_#stock_id#').value,1,',')+',';
				 }
			 </cfoutput>
		</cfif>
		document.getElementById('convert_stocks_id').value=convert_list;
		document.getElementById('convert_amount_stocks_id').value=convert_list_amount;
		document.getElementById('convert_price').value=convert_list_price;
		document.getElementById('convert_price_other').value=convert_list_price_other;
		document.getElementById('convert_money').value=convert_list_money;
		if(convert_list)//Ürün Seçili ise
		{
			 windowopen('','wide','cc_paym');
			 if(type==3)
			 {
				 aktar_form.action="<cfoutput>#request.self#?fuseaction=stock.form_add_fis&type=convert&ref_no=#alt_plan_no#&location_in=#attributes.production_loc_id#&department_in=#attributes.production_dep_id#&location_out=#attributes.ready_loc_id#&department_out=#attributes.ready_dep_id#</cfoutput>";
				 document.getElementById('ambar_fisi').disabled=true;
			 }
			 if(type==1)

			 {
				 aktar_form.action="<cfoutput>#request.self#?fuseaction=purchase.list_internaldemand&event=add&type=convert&ref_no=#alt_plan_no#&location_in=#attributes.ready_loc_id#&department_in=#attributes.ready_dep_id#</cfoutput>";
				  document.getElementById('ic_talep').disabled=true;
			 }
			 if(type==2)

			 {
				 aktar_form.action="<cfoutput>#request.self#?fuseaction=purchase.list_purchasedemand&event=add&type=convert&ref_no=#alt_plan_no#&location_in=#attributes.ready_loc_id#&department_in=#attributes.ready_dep_id#</cfoutput>";
				  document.getElementById('satin_alma_talebi').disabled=true;
			 }
			 aktar_form.target='cc_paym';
			 aktar_form.submit();
		 }
		 else
		 	alert("<cf_get_lang dictionary_id='57471.Eksik Veri'> : <cf_get_lang dictionary_id ='57657.Ürün'>.");
	}
	function wrk_select_all2(all_conv_product,_conversion_product_,number)
	{
		for(var cl_ind=1; cl_ind <= number; cl_ind++)
		{
			if(document.getElementById(all_conv_product).checked == true)
			{
				if(document.getElementById('_conversion_product_'+cl_ind).checked == false)
					document.getElementById('_conversion_product_'+cl_ind).checked = true;
			}
			else
			{
				if(document.getElementById('_conversion_product_'+cl_ind).checked == true)
					document.getElementById('_conversion_product_'+cl_ind).checked = false;
			}
		}
	}
</script>	