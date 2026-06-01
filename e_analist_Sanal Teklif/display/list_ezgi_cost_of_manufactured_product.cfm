<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.project_head" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.dsp_tablo" default="">
<cfparam name="attributes.dsp_source" default="">
<cfparam name="attributes.company" default="">
<cfparam name="attributes.comp" default="">
<cfparam name="attributes.stock_id" default="">
<cfparam name="attributes.gizle_id" default="1">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.stock_name" default="">
<cfparam name="attributes.spect_main_id" default="">
<cfparam name="attributes.spect_name" default="">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.branch_name" default="">
<cfparam name="attributes.startdate" default="">
<cfparam name="attributes.finishdate" default="">
<!---<cfparam name="attributes.maxrows" default="#session.ep.maxrows#">--->
<cfparam name="attributes.station_name" default="">
<cfparam name="attributes.station_id" default="">
<cfparam name="attributes.form_is_submitted" default="">
<cfset t_product_maliyet= 0>
<cfset t_sarf_maliyet= 0>
<cfset t_puchase_tut_maliyet = 0>
<cfset t_fire= 0>
<cfset it_tut_maliyet= 0>
<cfset it_puchase_tut_maliyet = 0>
<cfquery name="get_branch" datasource="#dsn#">
	SELECT BRANCH_NAME, BRANCH_ID FROM BRANCH WHERE BRANCH_STATUS = 1 AND COMPANY_ID = #session.ep.company_id#
</cfquery>
<cfif isdefined("attributes.form_is_submitted") AND len(attributes.form_is_submitted)>
	<cfif isDate(attributes.startdate)><cf_date tarih = "attributes.startdate"></cfif>
	<cfif isDate(attributes.finishdate)><cf_date tarih = "attributes.finishdate"></cfif>  
</cfif>
<cf_basket_form id="report_orders_">
<!-- sil -->
<table width="100%" border="0" cellpadding="1" cellspacing="1">
	<cfform name="form" action="#request.self#?fuseaction=account.list_ezgi_cost_of_manufactured_product" method="post">
    <input type="hidden" name="form_is_submitted" value="1"> 
	<tr height="20">
    	<td colspan="2">
        	<table width="100%" border="0" align="center" cellpadding="1" cellspacing="1">
            	<tr>
                	<td style="text-align:right; width:40px">Filtre&nbsp;</td>
                    <td style="text-align:right; width:100px">
                    	<cfinput type="text" name="keyword" value="#attributes.keyword#" style="width:100px">
                    </td>
                	<td style="text-align:right; width:50px">İstasyon&nbsp;</td>
					<td style="width:200px">
                     	<cf_multiselect_check 
                            table_name="WORKSTATIONS"  
                            name="STATION_ID"
							data_source="#dsn3#"
                            width="150" 
                            option_name="STATION_NAME" 
                            option_value="STATION_ID" 
							value="#attributes.STATION_ID#" 
							option_text="#getLang('main',1676)#">
                   	</td>
                    <td style="text-align:right; width:40px"><cf_get_lang_main no ='245.Ürün'>&nbsp;</td>
                    <td style="width:170px">
                        <input type="hidden" name="stock_id" id="stock_id" value="<cfoutput>#attributes.stock_id#</cfoutput>">
                        <input type="hidden" name="product_id" id="product_id" value="<cfoutput>#attributes.product_id#</cfoutput>">
                        <cfinput type="text" name="stock_name" id="stock_name" style="width:150px;" value="#attributes.stock_name#" onFocus="AutoComplete_Create('stock_name','PRODUCT_NAME','PRODUCT_NAME,STOCK_CODE','get_product_autocomplete','0','STOCK_ID,PRODUCT_ID','stock_id,product_id','','3','225');" autocomplete="off">
                        <a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=form.stock_id&product_id=form.product_id&field_name=form.stock_name','list');"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a></td>
                    <td style="text-align:right; width:50px"><cf_get_lang_main no ='235.Spec'>&nbsp;</td>
                    <td style="width:180px">
                        <input type="hidden" name="spect_main_id" value="<cfoutput>#attributes.spect_main_id#</cfoutput>">
                        <input style="width:150px;" type="text" name="spect_name" value="<cfoutput>#attributes.spect_name#</cfoutput>">
                        <a href="javascript://" onClick="product_control();"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>
                    </td>
                    <td style="text-align:right; width:40px">Şube&nbsp;</td>
                    <td style="width:100px">
                        <select name="branch_id" style="width:100px; height:20px">
                            <option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                            <cfoutput query="get_branch">
                                <option value="#branch_id#" <cfif attributes.branch_id eq branch_id>selected</cfif>>#BRANCH_NAME#</option>
                            </cfoutput>
                        </select>
                    </td>
                    <td style="text-align:right; width:40px">Liste</td>
                    <td style="width:100px">
                        <select name="gizle_id" style="width:100px; height:20px" onchange="kontrol_due_option()">
                            <option value="1" <cfif attributes.gizle_id eq 1>selected</cfif>>Belge Bazında</option>
                            <option value="2" <cfif attributes.gizle_id eq 2>selected</cfif>>Stok Bazında</option>
                        </select>
                    </td>
                    <td>&nbsp;</td>
                    
                    <td style="text-align:right; width:40px">Tarih&nbsp;</td>
                    <td style="text-align:right; width:270px" nowrap="nowrap">
                    	<cfsavecontent variable="message"><cf_get_lang_main no='370.Tarih Değerini Kontrol Ediniz'>!</cfsavecontent>
						<cfinput type="text" name="startdate" value="#DateFormat(attributes.startdate,'dd/mm/yyyy')#" validate="eurodate" message="#message#" maxlength="10" style="width:65px;">
						<cf_wrk_date_image date_field="startdate">
						<cfinput type="text" name="finishdate" value="#DateFormat(attributes.finishdate,'dd/mm/yyyy')#" validate="eurodate" message="#message#" maxlength="10" style="width:65px;">
						<cf_wrk_date_image date_field="finishdate">
                    	<!---<cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1," required="yes" style="width:25px;">--->
                        <cfsavecontent variable="message"><cf_get_lang_main no ='499.Çalıştır'></cfsavecontent>
                        <cf_workcube_buttons add_function='tarih_kontrolu()' is_upd='0' is_cancel='0' insert_info='#message#' insert_alert=''>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
	<tr>
		<td colspan="2">
            <table width="100%" border="0" align="center" cellpadding="1" cellspacing="1">
                <tr valign="middle">
                	<td style="width:320px" align="left" nowrap="nowrap">
                    	<input type="checkbox" name="dsp_tablo" value="1" <cfif attributes.dsp_tablo eq 1>checked</cfif>> 
                    	Maliyet Tablo Değerleri
                    	<input type="checkbox" name="dsp_source" value="1" <cfif attributes.dsp_source eq 1>checked</cfif>> 
                    	Maliyete Etki Eden Son Belge 
                    </td>
                    
                    <td></td>	
                </tr>
            </table>
		</td>
	</tr>
   	</cfform> 
</table>
<!-- sil -->
<cf_basket id="report_orders_bask_">
   	<!-- sil -->
    <table class="basket_list">
    	<thead>  
            <tr width="40" height="22">
                <th colspan="10" style="text-align:center">Üretim Bilgileri</th>
                <th colspan="8" style="text-align:center">Üretim Çıkış Bilgileri</th>
                <cfif attributes.dsp_tablo eq 1>
                    <th colspan="4" style="text-align:center">Maliyet Tablo Değerleri</th>
                </cfif>
                <cfif attributes.dsp_source eq 1>
                    <th colspan="9" style="text-align:center">Kaynak Bilgileri</th>
                </cfif>
            </tr>
        </thead>
        <cfif isdefined("attributes.form_is_submitted") AND len(attributes.form_is_submitted)>
            <cfquery name="GET_PRODUCT_COST_ID" datasource="#dsn3#">
               	SELECT     	
               		S.STOCK_CODE, 
                  	PORR.NAME_PRODUCT, 
                   	S.STOCK_ID, 
                	S.PRODUCT_ID, 
                  	S_2.STOCK_CODE AS STOCK_CODE_2, 
                  	PORR_2.NAME_PRODUCT AS NAME_PRODUCT_2,
                	S_2.STOCK_ID AS STOCK_ID_2, 
                  	S_2.PRODUCT_ID AS PRODUCT_ID_2,
                 	POR.P_ORDER_ID,
                   	POR.STATION_ID, 
                   	POR.PR_ORDER_ID,
                  	POR.FINISH_DATE, 
                   	POR.RESULT_NO,
                   	PORR_2.PR_ORDER_ROW_ID,
                   	PORR.SPECT_NAME,
                   	PORR.SPEC_MAIN_ID, 
                   	PORR.SPECT_ID,
                  	PORR_2.SPECT_NAME AS SPECT_NAME_2, 
               		PORR_2.SPEC_MAIN_ID AS SPEC_MAIN_ID_2, 
                	PORR_2.SPECT_ID AS SPECT_ID_2,
                 	ISNULL ((
                                        SELECT     	TOP (1) PRODUCT_COST_ID
                                        FROM      	#dsn1_alias#.PRODUCT_COST AS PC_1
                                        WHERE     	(SPECT_MAIN_ID = PORR_2.SPEC_MAIN_ID) AND 
                                                    (START_DATE <= POR.FINISH_DATE) AND 
                                                    (S_2.IS_PRODUCTION = 1) AND 
                                                    (ACTION_PERIOD_ID = #session.ep.period_id#)
                                        ORDER BY 	START_DATE DESC, PRODUCT_COST_ID DESC
                                        UNION ALL
                                        SELECT     	TOP (1) PRODUCT_COST_ID
                                        FROM        #dsn1_alias#.PRODUCT_COST AS PC_2
                                        WHERE     	(PRODUCT_ID = PORR_2.PRODUCT_ID) AND 
                                                    (START_DATE <= POR.FINISH_DATE) AND 
                                                    (S_2.IS_PRODUCTION = 0) AND 
                                                    (ACTION_PERIOD_ID = #session.ep.period_id#)
                                        ORDER BY 	START_DATE DESC, PRODUCT_COST_ID DESC
                  	), 0) AS P_ID,
                 	PORR.AMOUNT, 
                  	PORR.PURCHASE_NET_SYSTEM AS PRODUCT_COST_PURCHASE_NET_SYSTEM, 
                 	PORR.PURCHASE_EXTRA_COST_SYSTEM AS PRODUCT_COST_PURCHASE_EXTRA_COST_SYSTEM, 
                  	PORR.PURCHASE_NET_SYSTEM + PORR.PURCHASE_EXTRA_COST_SYSTEM AS PRODUCT_COST_SYSTEM, 
                 	PORR.PURCHASE_NET AS PRODUCT_COST_PURCHASE_NET, 
                  	PORR.PURCHASE_EXTRA_COST AS PRODUCT_COST_PURCHASE_EXTRA_COST, 
                  	PORR.PURCHASE_NET + PORR.PURCHASE_EXTRA_COST AS PRODUCT_COST, 
                 	PORR.STATION_REFLECTION_COST_SYSTEM,
                 	PORR.LABOR_COST_SYSTEM, 
                   	PORR_2.AMOUNT AS AMOUNT_2, 
                  	PORR_2.PURCHASE_NET_SYSTEM AS PRODUCT_COST_PURCHASE_NET_SYSTEM_2, 
                 	PORR_2.PURCHASE_EXTRA_COST_SYSTEM AS PRODUCT_COST_PURCHASE_EXTRA_COST_SYSTEM_2,
                 	PORR_2.PURCHASE_NET_SYSTEM + PORR_2.PURCHASE_EXTRA_COST_SYSTEM AS PRODUCT_COST_SYSTEM_2,
                  	PORR_2.PURCHASE_NET AS PRODUCT_COST_PURCHASE_NET_2,
                  	PORR_2.PURCHASE_EXTRA_COST AS PRODUCT_COST_PURCHASE_EXTRA_COST_2,
                   	PORR_2.PURCHASE_NET + PORR_2.PURCHASE_EXTRA_COST AS PRODUCT_COST_2,
                  	PORR_2.STATION_REFLECTION_COST_SYSTEM AS STATION_REFLECTION_COST_SYSTEM_2, 
                  	PORR_2.LABOR_COST_SYSTEM AS LABOR_COST_SYSTEM_2
                FROM    	
                	STOCKS AS S_2 INNER JOIN
               		PRODUCTION_ORDER_RESULTS_ROW AS PORR_2 ON S_2.STOCK_ID = PORR_2.STOCK_ID RIGHT OUTER JOIN
                   	STOCKS AS S INNER JOIN
                  	PRODUCTION_ORDER_RESULTS_ROW AS PORR ON S.STOCK_ID = PORR.STOCK_ID INNER JOIN
                  	PRODUCTION_ORDER_RESULTS AS POR ON PORR.PR_ORDER_ID = POR.PR_ORDER_ID ON PORR_2.PR_ORDER_ID = PORR.PR_ORDER_ID
                WHERE     	
                	PORR_2.TYPE = 2 AND 
                   	PORR.TYPE = 1
                   	<cfif Len(attributes.startdate)>
                     	AND POR.FINISH_DATE >= <cfqueryparam cfsqltype="cf_sql_timestamp" value="#attributes.startdate#"> 
                  	</cfif>
                   	<cfif Len(attributes.finishdate)>
                       	AND POR.FINISH_DATE < <cfqueryparam cfsqltype="cf_sql_timestamp" value="#DateAdd('d',1,attributes.finishdate)#"> 
                   	</cfif>
                   	<cfif ListLen(attributes.station_id)>
                     	AND POR.STATION_ID IN (#attributes.station_id#) 
                  	</cfif>
                  	<cfif len(attributes.branch_id)>
                      	AND POR.EXIT_DEP_ID IN(SELECT DEPARTMENT_ID FROM #dsn_alias#.DEPARTMENT WHERE (BRANCH_ID = #attributes.branch_id#))	
                 	</cfif>
               		<cfif len(trim(attributes.stock_name)) and len(attributes.stock_id)>
                     	AND	PORR.STOCK_ID = #attributes.stock_id#
                   	</cfif>
                   	<cfif len(trim(attributes.spect_name)) and len(attributes.spect_main_id)>
                     	AND	PORR.SPEC_MAIN_ID = #attributes.spect_main_id#
                   	</cfif>
                  	<cfif len(attributes.keyword)>
                      	AND (PORR.SPECT_NAME LIKE '%#attributes.keyword#%' OR S.STOCK_CODE LIKE '%#attributes.keyword#%')
                  	</cfif>
                ORDER BY 	
                	POR.FINISH_DATE,
                  	POR.PR_ORDER_ID,
                 	PORR_2.SPECT_NAME DESC
            </cfquery>
               <!--- <cfparam name="attributes.totalrecords" default="#GET_PRODUCT_COST_ID.recordCount#">
                <cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>--->
            <cfif GET_PRODUCT_COST_ID.recordcount>
                <cfif gizle_id eq 1>
                	<thead>
                        <tr style="height:22px">
                            <th style="text-align:center; width:70px">Üretim No</th>
                            <th style="text-align:center; width:70px">Tarih</th>
                            <th style="text-align:center; width:120px">İstasyon</th>
                            <th style="text-align:center; width:100px">Ürün </th>
                            <th style="text-align:center; width:150px">Spec </th>
                            <th style="text-align:center; width:70px">Miktar</th>
                            <th style="text-align:center; width:70px">Net Maliyet</th>
                            <th style="text-align:center; width:70px">Ek Maliyet</th>
                            <th style="text-align:center; width:70px">Toplam Maliyet</th>
                            <th style="text-align:center; width:70px">Tutar</th>
                            
                            <th style="text-align:center; width:70px">Fire</th>
                            <th style="text-align:center; width:100px">Ürün </th>
                            <th style="text-align:center; width:1500px">Spec </th>
                            <th style="text-align:center; width:70px">Miktar</th>
                            <th style="text-align:center; width:70px">Net Maliyet</th>
                            <th style="text-align:center; width:70px">Ek Maliyet</th>
                            <th style="text-align:center; width:70px">Toplam Maliyet</th>
                            <th style="text-align:center; width:70px">Tutar</th>
                            <cfif attributes.dsp_tablo eq 1>
                                <th style="text-align:center; width:70px">Net Maliyet</th>
                                <th style="text-align:center; width:70px">Ek Maliyet</th>
                                <th style="text-align:center; width:70px">Toplam Maliyet</th>
                                <th style="text-align:center; width:70px">Tutar</th>
                            </cfif>
                            <cfif attributes.dsp_source eq 1>
                                <th style="text-align:center; width:160px">Belge Türü</th>
                                <th style="text-align:center; width:110px">Tarih</th>
                                <th style="text-align:center; width:60px">Belge No</th>
                                <th style="text-align:center; width:70px">Net Maliyet</th>
                                <th style="text-align:center; width:70px">Ek Maliyet</th>
                                <th style="text-align:center; width:70px">Toplam Maliyet</th>
                            </cfif> 
                        </tr>
                    </thead>
                	<cfquery name="GET_PRODUCT_COST_GROUP" dbtype="query">
                    	SELECT 		
                    		PR_ORDER_ID,
                         	COUNT(*) AS SAYI 
                    	FROM 		
                        	GET_PRODUCT_COST_ID
                    	GROUP BY	
                        	PR_ORDER_ID
                	</cfquery>
                    <cfloop query="GET_PRODUCT_COST_GROUP">
                        <cfset 'satir#PR_ORDER_ID#' = GET_PRODUCT_COST_GROUP.SAYI>
                    </cfloop>
                	<cfquery name="GET_PRODUCT_COST_GROUP_STOCK" dbtype="query">
                    	SELECT 		
                        	PR_ORDER_ID, SUM(AMOUNT_2) AS AMOUNT_2 
                    	FROM 		
                        	GET_PRODUCT_COST_ID
                    	WHERE		
                        	NAME_PRODUCT_2 NOT LIKE 'Fason%'
                    	GROUP BY	
                        	PR_ORDER_ID
                	</cfquery>
                    <cfloop query="GET_PRODUCT_COST_GROUP_STOCK">
                        <cfset 'AMOUNT_2#PR_ORDER_ID#' = GET_PRODUCT_COST_GROUP_STOCK.AMOUNT_2>
                    </cfloop>
               		<cfloop query="GET_PRODUCT_COST_ID">
                        <cfif P_ID neq 0>
                            <cfquery name="GET_PRODUCT_COST" datasource="#dsn1#">
                                SELECT     	
                                	PC_3.PURCHASE_NET_SYSTEM, 
                               		PC_3.PURCHASE_EXTRA_COST_SYSTEM, 
                                  	PC_3.ACTION_PROCESS_CAT_ID, 
                                	PC_3.ACTION_DATE, 
                                  	IR_3.AMOUNT AS ACT_AMOUNT, 
                                  	IR_3.PRICE AS ACT_COST_PRICE, 
                                  	IR_3.EXTRA_COST AS ACT_EXTRA_COST,
                                 	I_3.INVOICE_DATE AS ACT_DATE, 
                                  	I_3.INVOICE_NUMBER AS ACT_NUMBER
                                FROM       	
                                	PRODUCT_COST AS PC_3 LEFT OUTER JOIN
                                   	#dsn2_alias#.INVOICE AS I_3 ON PC_3.ACTION_ID = I_3.INVOICE_ID LEFT OUTER JOIN
                                  	#dsn2_alias#.INVOICE_ROW AS IR_3 ON PC_3.ACTION_ROW_ID = IR_3.INVOICE_ROW_ID
                                WHERE     	
                                	(PC_3.ACTION_PROCESS_TYPE = 55) AND (PC_3.PRODUCT_COST_ID = #P_ID#) OR
                               		(PC_3.ACTION_PROCESS_TYPE = 59) AND (PC_3.PRODUCT_COST_ID = #P_ID#) OR
                                  	(PC_3.ACTION_PROCESS_TYPE = 62) AND (PC_3.PRODUCT_COST_ID = #P_ID#)
                                UNION ALL
                                SELECT     	
                                	PC_2.PURCHASE_NET_SYSTEM, 
                                 	PC_2.PURCHASE_EXTRA_COST_SYSTEM, 
                                  	PC_2.ACTION_PROCESS_CAT_ID, PC_2.ACTION_DATE, 
                                 	SFR_2.AMOUNT AS ACT_AMOUNT, 
                                   	SFR_2.COST_PRICE AS ACT_COST_PRICE, 
                                  	SFR_2.EXTRA_COST AS ACT_EXTRA_COST,
                                	SF_2.FIS_DATE AS ACT_DATE, 
                                	SF_2.FIS_NUMBER AS ACT_NUMBER
                                FROM       	
                                	PRODUCT_COST AS PC_2 LEFT OUTER JOIN
                                   	#dsn2_alias#.STOCK_FIS AS SF_2 ON PC_2.ACTION_ID = SF_2.FIS_ID LEFT OUTER JOIN
                                	#dsn2_alias#.STOCK_FIS_ROW AS SFR_2 ON PC_2.ACTION_ROW_ID = SFR_2.STOCK_FIS_ROW_ID
                                WHERE     	
                                	(PC_2.ACTION_PROCESS_TYPE = 114) AND (PC_2.PRODUCT_COST_ID = #P_ID#) OR
                                   	(PC_2.ACTION_PROCESS_TYPE = 115) AND (PC_2.PRODUCT_COST_ID = #P_ID#) OR
                                  	(PC_2.ACTION_PROCESS_TYPE = 116) AND (PC_2.PRODUCT_COST_ID = #P_ID#)
                                UNION ALL
                                SELECT     	
                                	PC_1.PURCHASE_NET_SYSTEM, 
                                   	PC_1.PURCHASE_EXTRA_COST_SYSTEM, 
                                	PC_1.ACTION_PROCESS_CAT_ID, 
                                 	PC_1.ACTION_DATE, 
                                   	SFR_1.AMOUNT AS ACT_AMOUNT, 
                                 	SFR_1.COST_PRICE AS ACT_COST_PRICE, 
                                	SFR_1.EXTRA_COST AS ACT_EXTRA_COST,
                                  	SF_1.FIS_DATE AS ACT_DATE, 
                                 	SF_1.FIS_NUMBER AS ACT_NUMBER
                                FROM        
                                	#dsn2_alias#.STOCK_FIS_ROW AS SFR_1 INNER JOIN
                                  	#dsn2_alias#.STOCK_FIS AS SF_1 ON SFR_1.FIS_ID = SF_1.FIS_ID RIGHT OUTER JOIN
                                 	PRODUCT_COST AS PC_1 ON SF_1.PROD_ORDER_RESULT_NUMBER = PC_1.ACTION_ID
                                WHERE     	
                                	(PC_1.PRODUCT_COST_ID = #P_ID#) AND 
                                	(SF_1.FIS_TYPE = 110) AND 
                                 	(PC_1.ACTION_PROCESS_TYPE = 171)
                            </cfquery>
                            <cfif GET_PRODUCT_COST.recordcount>
                                <cfset _PURCHASE_NET_SYSTEM[PR_ORDER_ROW_ID]=GET_PRODUCT_COST.PURCHASE_NET_SYSTEM>
                                <cfset _PURCHASE_EXTRA_COST_SYSTEM[PR_ORDER_ROW_ID]=GET_PRODUCT_COST.PURCHASE_EXTRA_COST_SYSTEM>
                                <cfset _ACTION_PROCESS_CAT_ID[PR_ORDER_ROW_ID]=GET_PRODUCT_COST.ACTION_PROCESS_CAT_ID>
                                <cfset _ACTION_DATE[PR_ORDER_ROW_ID]=GET_PRODUCT_COST.ACTION_DATE>
                                <cfquery name="PROCESS_TYPE_NAME" datasource="#dsn3#">
                                    SELECT     
                                    	PROCESS_CAT
                                    FROM         
                                    	SETUP_PROCESS_CAT
                                    WHERE     
                                    	PROCESS_CAT_ID = #GET_PRODUCT_COST.ACTION_PROCESS_CAT_ID#
                                </cfquery>
                                <cfif PROCESS_TYPE_NAME.recordcount>
                                    <cfset _ACTION_PROCESS_CAT[PR_ORDER_ROW_ID]=PROCESS_TYPE_NAME.PROCESS_CAT>
                                <cfelse>
                                    <cfset _ACTION_PROCESS_CAT[PR_ORDER_ROW_ID]='Belge Tipi Bulunamadı'>
                                </cfif>
                                <cfif GET_PRODUCT_COST.ACT_AMOUNT neq ''>
                                    <cfset _ACT_AMOUNT[PR_ORDER_ROW_ID]=GET_PRODUCT_COST.ACT_AMOUNT> 
                                    <cfset _ACT_COST_PRICE[PR_ORDER_ROW_ID]=GET_PRODUCT_COST.ACT_COST_PRICE> 
                                    <cfset _ACT_EXTRA_COST[PR_ORDER_ROW_ID]=GET_PRODUCT_COST.ACT_EXTRA_COST>
                                    <cfset _ACT_DATE[PR_ORDER_ROW_ID]=GET_PRODUCT_COST.ACT_DATE>
                                    <cfset _ACT_NUMBER[PR_ORDER_ROW_ID]=GET_PRODUCT_COST.ACT_NUMBER>
                                <cfelse>
                                    <cfset maliyet[PR_ORDER_ROW_ID] =2>
                                    <cfset _ACT_AMOUNT[PR_ORDER_ROW_ID]=0> 
                                    <cfset _ACT_COST_PRICE[PR_ORDER_ROW_ID]=0> 
                                    <cfset _ACT_EXTRA_COST[PR_ORDER_ROW_ID]=0>
                                    <cfset _ACT_DATE[PR_ORDER_ROW_ID]=0>
                                    <cfset _ACT_NUMBER[PR_ORDER_ROW_ID]=0>
                                </cfif>      
                                <cfset _ACT_top[PR_ORDER_ROW_ID]=_ACT_COST_PRICE[PR_ORDER_ROW_ID]+_ACT_EXTRA_COST[PR_ORDER_ROW_ID]>
                                <cfset _ACT_tut[PR_ORDER_ROW_ID]=_ACT_AMOUNT[PR_ORDER_ROW_ID]*(_ACT_COST_PRICE[PR_ORDER_ROW_ID]+_ACT_EXTRA_COST[PR_ORDER_ROW_ID])>
                            <cfelse>
                                <cfset maliyet[PR_ORDER_ROW_ID] =3>
                                <cfset _PURCHASE_NET_SYSTEM[PR_ORDER_ROW_ID]=0>
                                <cfset _PURCHASE_EXTRA_COST_SYSTEM[PR_ORDER_ROW_ID]=0>
                                <cfset _ACTION_PROCESS_CAT_ID[PR_ORDER_ROW_ID]=0>
                                <cfset _ACTION_DATE[PR_ORDER_ROW_ID]=''>
                                <cfset _ACTION_PROCESS_CAT[PR_ORDER_ROW_ID]=''>
                            </cfif>
                            <cfset _puchase_top_maliyet[PR_ORDER_ROW_ID] = _PURCHASE_NET_SYSTEM[PR_ORDER_ROW_ID]+_PURCHASE_EXTRA_COST_SYSTEM[PR_ORDER_ROW_ID]>
                            <cfset _puchase_tut_maliyet[PR_ORDER_ROW_ID] = AMOUNT_2*(_PURCHASE_NET_SYSTEM[PR_ORDER_ROW_ID]+_PURCHASE_EXTRA_COST_SYSTEM[PR_ORDER_ROW_ID])>
                            <cfset t_puchase_tut_maliyet = t_puchase_tut_maliyet + _puchase_tut_maliyet[PR_ORDER_ROW_ID]>
                            <cfset maliyet[PR_ORDER_ROW_ID] =1>                
                        <cfelse>
                            <cfset maliyet[PR_ORDER_ROW_ID] =0>
                        </cfif>
                    </cfloop>
                    <cfset k = 1>
                    <!---<cfoutput query="GET_PRODUCT_COST_ID" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">--->
                    <tbody>
						<cfoutput query="GET_PRODUCT_COST_ID">
                            <!---<cfset sira=currentrow>--->
                            <cfif len(STATION_ID)>
                                <cfquery name="GET_STATION_NAME" datasource="#dsn3#">
                                    SELECT     	
                                        STATION_NAME
                                    FROM        
                                        WORKSTATIONS
                                    WHERE     	
                                        STATION_ID = #STATION_ID#
                                </cfquery>
                                <cfset _station_name = GET_STATION_NAME.STATION_NAME>
                            <cfelse>
                                <cfset _station_name = 'İstasyon Yok'>
                            </cfif>
                            <tr style="height:20px">
                                <cfif k eq 0>
                                    <cfif k_id neq PR_ORDER_ID>
                                        <cfset k = 1>
                                    </cfif> 
                                </cfif>
                                <cfif k eq 1>
                                    <td rowspan="#evaluate('satir#PR_ORDER_ID#')#">#RESULT_NO#</td>
                                    <td rowspan="#evaluate('satir#PR_ORDER_ID#')#">#dateformat(FINISH_DATE,'dd/mm/yyyy')#</td>
                                    <td rowspan="#evaluate('satir#PR_ORDER_ID#')#">#_station_name# </td>
                                    <td rowspan="#evaluate('satir#PR_ORDER_ID#')#">#NAME_PRODUCT# </td>
                                    <td rowspan="#evaluate('satir#PR_ORDER_ID#')#">#SPECT_NAME# </td>
                                    <td rowspan="#evaluate('satir#PR_ORDER_ID#')#" style="text-align:right">#TLFormat((AMOUNT),2)#</td>
                                    <td rowspan="#evaluate('satir#PR_ORDER_ID#')#" style="text-align:right">#TLFormat((PRODUCT_COST_PURCHASE_NET_SYSTEM),4)#</td>
                                    <td rowspan="#evaluate('satir#PR_ORDER_ID#')#" style="text-align:right">#TLFormat((PRODUCT_COST_PURCHASE_EXTRA_COST_SYSTEM),4)#</td>
                                    <td rowspan="#evaluate('satir#PR_ORDER_ID#')#" style="text-align:right">#TLFormat((PRODUCT_COST_SYSTEM),4)#</td>
                                    <td rowspan="#evaluate('satir#PR_ORDER_ID#')#" style="text-align:right">#TLFormat((PRODUCT_COST_SYSTEM*AMOUNT),2)#</td>
                                    <td rowspan="#evaluate('satir#PR_ORDER_ID#')#" style="text-align:right"><cfif left(NAME_PRODUCT_2,5) neq 'Fason'> 
                                    #TLFormat((evaluate('AMOUNT_2#PR_ORDER_ID#')-AMOUNT),2)# <br>
                                    (%#TlFormat((evaluate('AMOUNT_2#PR_ORDER_ID#')-AMOUNT)/AMOUNT_2*100,0)#)<cfelse>0</cfif>
                                    </td>
                                    <cfset t_fire=t_fire + evaluate('AMOUNT_2#PR_ORDER_ID#')-AMOUNT>
                                    <cfset t_product_maliyet=t_product_maliyet+PRODUCT_COST_SYSTEM*AMOUNT>
                                    <cfset k_id = PR_ORDER_ID>
                                    <cfset k = 0>
                                </cfif>
                                <td>#NAME_PRODUCT_2#</td>
                                <td>#SPECT_NAME_2# </td>
                                <td style="text-align:right">#TLFormat((AMOUNT_2),2)#</td>
                                <td style="text-align:right">#TLFormat((PRODUCT_COST_PURCHASE_NET_SYSTEM_2),4)#</td>
                                <td style="text-align:right">#TLFormat((PRODUCT_COST_PURCHASE_EXTRA_COST_SYSTEM_2),4)#</td>
                                <td style="text-align:right">#TLFormat((PRODUCT_COST_SYSTEM_2),4)#</td>
                                <td style="text-align:right">#TLFormat((PRODUCT_COST_SYSTEM_2*AMOUNT_2),2)#</td>
                                
                                <cfset t_sarf_maliyet=t_sarf_maliyet+PRODUCT_COST_SYSTEM_2*AMOUNT_2>
                                <cfif attributes.dsp_tablo eq 1>
                                    <td style="text-align:right"><cfif maliyet[PR_ORDER_ROW_ID] neq 0>#TLFormat((_PURCHASE_NET_SYSTEM[PR_ORDER_ROW_ID]),4)#<cfelse><font color="red">0,00</font></cfif></td>
                                    <td style="text-align:right"><cfif maliyet[PR_ORDER_ROW_ID] neq 0>#TLFormat((_PURCHASE_EXTRA_COST_SYSTEM[PR_ORDER_ROW_ID]),4)#<cfelse><font color="red">0,00</font></cfif></td>
                                    <td style="text-align:right"><cfif maliyet[PR_ORDER_ROW_ID] neq 0><cfif TLFormat((PRODUCT_COST_SYSTEM_2),4) neq TLFormat((_puchase_top_maliyet[PR_ORDER_ROW_ID]),4)><font color="red"> #TLFormat((_puchase_top_maliyet[PR_ORDER_ROW_ID]),4)#</font><cfelse>#TLFormat((_puchase_top_maliyet[PR_ORDER_ROW_ID]),4)#</cfif><cfelse><font color="red">0,00</font></cfif></td>
                                    <td style="text-align:right"><cfif maliyet[PR_ORDER_ROW_ID] neq 0>#TLFormat((_puchase_tut_maliyet[PR_ORDER_ROW_ID]),2)#<cfelse><font color="red">0,00</font></cfif></td>
            
                                </cfif>
                                <cfif attributes.dsp_source eq 1>
                                    <td><cfif maliyet[PR_ORDER_ROW_ID] neq 0>#_ACTION_PROCESS_CAT[PR_ORDER_ROW_ID]#<cfelse><font color="red">Kayıt Yok.</font></cfif></td>
                                    <td><cfif maliyet[PR_ORDER_ROW_ID] neq 0>#dateformat(_ACT_DATE[PR_ORDER_ROW_ID],'dd/mm/yyyy')#<cfelse><font color="red">Kayıt Yok.</font></cfif></td>
                                    <td><cfif maliyet[PR_ORDER_ROW_ID] neq 0>#_ACT_NUMBER[PR_ORDER_ROW_ID]#<cfelse><font color="red">Kayıt Yok.</font></cfif></td>
                                    <td style="text-align:right"><cfif maliyet[PR_ORDER_ROW_ID] neq 0>#TLFormat((_ACT_COST_PRICE[PR_ORDER_ROW_ID]),4)#<cfelse><font color="red">0,00</font></cfif></td>
                                    <td style="text-align:right"><cfif maliyet[PR_ORDER_ROW_ID] neq 0>#TLFormat((_ACT_EXTRA_COST[PR_ORDER_ROW_ID]),4)#<cfelse><font color="red">0,00</font></cfif></td>
                                    <td style="text-align:right"><cfif maliyet[PR_ORDER_ROW_ID] neq 0><cfif TLFormat(( _ACT_top[PR_ORDER_ROW_ID]),4) neq TLFormat(( _ACT_top[PR_ORDER_ROW_ID]),4)><font color="red">#TLFormat(( _ACT_top[PR_ORDER_ROW_ID]),4)#</font><cfelse>#TLFormat(( _ACT_top[PR_ORDER_ROW_ID]),4)#</cfif><cfelse><font color="red">0,00</font></cfif></td>
                                </cfif>
                            </tr>
                    	</cfoutput>
                   	</tbody>
                    <tfoot>
                        <tr style="height:20px"><cfoutput>
                            <td colspan="9" style="text-align:center">Toplam Üretim Maliyeti</td>
                            <td style="text-align:right">#TLFormat((t_product_maliyet),2)#</td>
                            <td style="text-align:right">#TLFormat((t_fire),0)#</td>
                            <td colspan="6" style="text-align:left">Toplam Sarf Maliyeti</td>
                            <td style="text-align:right">#TLFormat((t_sarf_maliyet),2)#</td>
                            <cfif attributes.dsp_tablo eq 1>
                                <td style="text-align:right" colspan="3">Maliyet Tablo Toplamı</td>
                                <td style="text-align:right">#TLFormat((t_puchase_tut_maliyet),2)#</td>
                            </cfif>
                            <cfif attributes.dsp_source eq 1>
                                <td style="text-align:right" colspan="6"></td>
                            </cfif></cfoutput>
                        </tr>
                  	</tfoot>
                <cfelse>
                    <cfquery name="get_product_cost_group" dbtype="query">
                        SELECT     	
                        	DISTINCT
                          	STOCK_CODE, 
                          	NAME_PRODUCT, 
                          	STOCK_ID, 
                           	PRODUCT_ID, 
                         	P_ORDER_ID,
                         	STATION_ID, 
                          	PR_ORDER_ID,
                           	FINISH_DATE, 
                          	RESULT_NO,
                         	SPECT_NAME,
                           	SPEC_MAIN_ID, 
                       		SPECT_ID,
                        	AMOUNT, 
                          	PRODUCT_COST_PURCHASE_NET_SYSTEM, 
                           	PRODUCT_COST_PURCHASE_EXTRA_COST_SYSTEM, 
                          	PRODUCT_COST_SYSTEM, 
                          	PRODUCT_COST_PURCHASE_NET, 
                          	PRODUCT_COST_PURCHASE_EXTRA_COST, 
                           	PRODUCT_COST, 
                          	STATION_REFLECTION_COST_SYSTEM,
                         	LABOR_COST_SYSTEM
                        FROM		
                        	GET_PRODUCT_COST_ID
                    </cfquery>
                    <cfquery name="get_product_cost_group_1" dbtype="query">
                        SELECT     	
                        	COUNT(*) AS A_ROW,
                         	STOCK_CODE, 
                         	NAME_PRODUCT, 
                          	STOCK_ID, 
                           	PRODUCT_ID, 
                         	SUM(AMOUNT) AS AMOUNT, 
                          	SUM(PRODUCT_COST_PURCHASE_NET_SYSTEM) AS PRODUCT_COST_PURCHASE_NET_SYSTEM, 
                        	SUM(PRODUCT_COST_PURCHASE_EXTRA_COST_SYSTEM) AS PRODUCT_COST_PURCHASE_EXTRA_COST_SYSTEM, 
                          	SUM(PRODUCT_COST_SYSTEM *  AMOUNT) AS PRODUCT_COST_SYSTEM, 
                        	SUM(PRODUCT_COST_PURCHASE_NET) AS PRODUCT_COST_PURCHASE_NET, 
                         	SUM(PRODUCT_COST_PURCHASE_EXTRA_COST) AS PRODUCT_COST_PURCHASE_EXTRA_COST, 
                           	SUM(PRODUCT_COST) AS PRODUCT_COST, 
                           	SUM(STATION_REFLECTION_COST_SYSTEM) AS STATION_REFLECTION_COST_SYSTEM,
                           	SUM(LABOR_COST_SYSTEM) AS LABOR_COST_SYSTEM
                        FROM		
                        	get_product_cost_group
                        GROUP BY	
                        	STOCK_CODE, 
                           	NAME_PRODUCT, 
                          	STOCK_ID, 
                         	PRODUCT_ID
                        ORDER BY	
                        	NAME_PRODUCT
                    </cfquery>
                    <cfloop query="get_product_cost_group_1">
                        <cfset 'A_ROW#STOCK_ID#' = get_product_cost_group_1.A_ROW>
                        <cfset 'STOCK_CODE#STOCK_ID#' = get_product_cost_group_1.STOCK_CODE>
                        <cfset 'NAME_PRODUCT#STOCK_ID#' = get_product_cost_group_1.NAME_PRODUCT>
                        <cfset 'PRODUCT_ID#STOCK_ID#' = get_product_cost_group_1.PRODUCT_ID>
                        <cfset 'AMOUNT#STOCK_ID#' = get_product_cost_group_1.AMOUNT>
                        <cfset 'PRODUCT_COST_PURCHASE_NET_SYSTEM#STOCK_ID#' = get_product_cost_group_1.PRODUCT_COST_PURCHASE_NET_SYSTEM>
                        <cfset 'PRODUCT_COST_PURCHASE_EXTRA_COST_SYSTEM#STOCK_ID#' = get_product_cost_group_1.PRODUCT_COST_PURCHASE_EXTRA_COST_SYSTEM>
                        <cfset 'PRODUCT_COST_SYSTEM#STOCK_ID#' = get_product_cost_group_1.PRODUCT_COST_SYSTEM>
                        <cfset 'PRODUCT_COST_PURCHASE_NET#STOCK_ID#' = get_product_cost_group_1.PRODUCT_COST_PURCHASE_NET>
                        <cfset 'PRODUCT_COST_PURCHASE_EXTRA_COST#STOCK_ID#' = get_product_cost_group_1.PRODUCT_COST_PURCHASE_EXTRA_COST>
                        <cfset 'PRODUCT_COST#STOCK_ID#' = get_product_cost_group_1.PRODUCT_COST>
                        <cfset 'STATION_REFLECTION_COST_SYSTEM#STOCK_ID#' = get_product_cost_group_1.STATION_REFLECTION_COST_SYSTEM>
                        <cfset 'LABOR_COST_SYSTEM#STOCK_ID#' = get_product_cost_group_1.LABOR_COST_SYSTEM>
                    </cfloop>
                    <cfquery name="get_product_cost_group_2" dbtype="query">
                        SELECT     	
                        	COUNT(*) AS A2_ROW,
                          	STOCK_ID, 
                         	STOCK_CODE_2, 
                          	NAME_PRODUCT_2,
                          	STOCK_ID_2, 
                           	PRODUCT_ID_2,
                         	SUM(AMOUNT_2) AS AMOUNT_2, 
                           	SUM(PRODUCT_COST_PURCHASE_NET_SYSTEM_2) AS PRODUCT_COST_PURCHASE_NET_SYSTEM_2, 
                        	SUM(PRODUCT_COST_PURCHASE_EXTRA_COST_SYSTEM_2) AS PRODUCT_COST_PURCHASE_EXTRA_COST_SYSTEM_2,
                      		SUM(PRODUCT_COST_SYSTEM_2 * AMOUNT_2) AS PRODUCT_COST_SYSTEM_2,
                           	SUM(PRODUCT_COST_PURCHASE_NET_2) AS PRODUCT_COST_PURCHASE_NET_2,
                           	SUM(PRODUCT_COST_PURCHASE_EXTRA_COST_2) AS PRODUCT_COST_PURCHASE_EXTRA_COST_2,
                           	SUM(PRODUCT_COST_2) AS PRODUCT_COST_2,
                       		SUM(STATION_REFLECTION_COST_SYSTEM_2) AS STATION_REFLECTION_COST_SYSTEM_2, 
                        	SUM(LABOR_COST_SYSTEM_2) AS LABOR_COST_SYSTEM_2
                        FROM		
                        	GET_PRODUCT_COST_ID
                        GROUP BY	
                        	STOCK_ID, 
                           	STOCK_CODE_2, 
                           	NAME_PRODUCT_2,
                         	STOCK_ID_2, 
                         	PRODUCT_ID_2               
                    </cfquery>
                    
                    <cfquery name="GET_PRODUCT_COST_GROUP_3" dbtype="query">
                        SELECT 		
                        	STOCK_ID,
                       	COUNT(*) AS SAYI 
                        FROM 		
                        	get_product_cost_group_2
                        GROUP BY	
                        	STOCK_ID
                    </cfquery>
                    <cfloop query="GET_PRODUCT_COST_GROUP_3">
                        <cfset 'satir#STOCK_ID#' = GET_PRODUCT_COST_GROUP_3.SAYI>
                    </cfloop>
                    <cfquery name="GET_PRODUCT_COST_GROUP_STOCK" dbtype="query">
                        SELECT 		
                        	STOCK_ID, SUM(AMOUNT_2) AS AMOUNT2_ 
                        FROM 		
                        	get_product_cost_group_2
                        WHERE		
                        	NAME_PRODUCT_2 NOT LIKE 'Fason%'
                        GROUP BY	
                        	STOCK_ID
                    </cfquery>
                    <cfloop query="GET_PRODUCT_COST_GROUP_STOCK">
                    	<cfset 'AMOUNT2_#STOCK_ID#' = GET_PRODUCT_COST_GROUP_STOCK.AMOUNT2_>
                	</cfloop>
                    <thead>
                        <tr style="height:22px">
                            <th style="text-align:center; width:80px">Stok Kodu</th>
                            <th style="text-align:center; width:100px"">Ürün </th>
                            <th style="text-align:center; width:70px"">Miktar</th>
                            <th style="text-align:center; width:70px"">Net Maliyet</th>
                            <th style="text-align:center; width:70px"">Ek Maliyet</th>
                            <th style="text-align:center; width:70px"">Toplam Maliyet</th>
                            <th style="text-align:center; width:70px"">Tutar</th>
                            <th style="text-align:center; width:70px"">Fire</th>
                            <th></th>
                            <th></th>
                            <th style="text-align:center; width:80px"">Stok Kodu</th>
                            <th style="text-align:center; width:100px"">Ürün </th>
                            <th style="text-align:center; width:70px"">Miktar</th>
                            <th style="text-align:center; width:70px"">Net Maliyet</th>
                            <th style="text-align:center; width:70px"">Ek Maliyet</th>
                            <th style="text-align:center; width:70px"">Toplam Maliyet</th>
                            <th style="text-align:center; width:70px"">Tutar</th>
                            <th></th>
                        </tr>
                    </thead>
                    <cfset k = 1>
                    <tbody>
						<cfoutput query="get_product_cost_group_2">
                            <tr height="20">
                                <cfif k eq 0>
                                    <cfif k_id neq STOCK_ID>
                                        <cfset k = 1>
                                    </cfif> 
                                </cfif>
                                <cfif k eq 1>
                                    <td rowspan="#evaluate('satir#STOCK_ID#')#">#evaluate('STOCK_CODE#STOCK_ID#')#</td>
                                    <td rowspan="#evaluate('satir#STOCK_ID#')#">#evaluate('NAME_PRODUCT#STOCK_ID#')#</td>
                                    <td rowspan="#evaluate('satir#STOCK_ID#')#" style="text-align:right">#TlFormat(evaluate('AMOUNT#STOCK_ID#'),2)#</td>
                                    <td rowspan="#evaluate('satir#STOCK_ID#')#" style="text-align:right">
                                        #TlFormat(evaluate('PRODUCT_COST_PURCHASE_NET_SYSTEM#STOCK_ID#')/evaluate('A_ROW#STOCK_ID#'),4)#
                                    </td>
                                    <td rowspan="#evaluate('satir#STOCK_ID#')#" style="text-align:right">
                                        #TlFormat(evaluate('PRODUCT_COST_PURCHASE_EXTRA_COST_SYSTEM#STOCK_ID#')/evaluate('A_ROW#STOCK_ID#'),4)#
                                    </td>
                                    <td rowspan="#evaluate('satir#STOCK_ID#')#" style="text-align:right">
                                        #TlFormat(evaluate('PRODUCT_COST_SYSTEM#STOCK_ID#')/evaluate('A_ROW#STOCK_ID#'),4)#
                                    </td>
                                    <td rowspan="#evaluate('satir#STOCK_ID#')#" style="text-align:right">
                                        #TlFormat(evaluate('PRODUCT_COST_SYSTEM#STOCK_ID#'),2)#
                                    </td>
                                    <td rowspan="#evaluate('satir#STOCK_ID#')#" colspan="3" style="text-align:right"><cfif left(NAME_PRODUCT_2,5) neq 'Fason'> 
                                        #TLFormat(evaluate('AMOUNT2_#STOCK_ID#')- evaluate('AMOUNT#STOCK_ID#'),2)# <br>
                                        (%#TlFormat((evaluate('AMOUNT2_#STOCK_ID#')- evaluate('AMOUNT#STOCK_ID#')) / AMOUNT_2 * 100,0)#)<cfelse>0</cfif>
                                    </td>
                                    <cfset t_fire=t_fire + evaluate('AMOUNT2_#STOCK_ID#')- evaluate('AMOUNT#STOCK_ID#')>
                                    <cfset t_product_maliyet=t_product_maliyet+ (evaluate('PRODUCT_COST_SYSTEM#STOCK_ID#'))>
                                    <cfset k_id = STOCK_ID>
                                    <cfset k = 0>
                                </cfif>
                                <td>#STOCK_CODE_2# </td>
                                <td>#NAME_PRODUCT_2#</td>
                                <td style="text-align:right">#TLFormat((AMOUNT_2),2)#</td>
                                <td style="text-align:right">#TLFormat((PRODUCT_COST_PURCHASE_NET_SYSTEM_2/A2_ROW),4)#</td>
                                <td style="text-align:right">#TLFormat((PRODUCT_COST_PURCHASE_EXTRA_COST_SYSTEM_2/A2_ROW),4)#</td>
                                <td style="text-align:right">#TLFormat((PRODUCT_COST_SYSTEM_2/A2_ROW),4)#</td>
                                <td style="text-align:right" colspan="2">#TLFormat((PRODUCT_COST_SYSTEM_2),2)#</td>
                                <cfset t_sarf_maliyet=t_sarf_maliyet+PRODUCT_COST_SYSTEM_2>
                            </tr>
                        </cfoutput>
                   	</tbody>
                    <tfoot>
                        <tr height="20">
                            <cfoutput>
                            <td colspan="7" style="text-align:center">Toplam Üretim Maliyeti</td>
                            <td style="text-align:right" colspan="3">#TLFormat((t_product_maliyet),2)#</td>
                            <td style="text-align:right">#TLFormat((t_fire),0)#</td>
                            <td colspan="5">Toplam Sarf Maliyeti</td>
                            <td style="text-align:right" colspan="2">#TLFormat((t_sarf_maliyet),2)#</td>
                            </cfoutput>
                    	</tr>
                   	</tfoot>
                </cfif>
            <cfelse>
                <tr height="20">
                    <td colspan="23">Listelenecek Kayıt Bulunamadı</td>
                </tr>
            </cfif>
        <cfelse>
            <tr height="20">
                <td colspan="23">Filtre Ediniz</td>
            </tr>
        </cfif> 	       
    </table>
</cf_basket_form>
<!---<cfif isdefined("attributes.form_is_submitted") AND len(attributes.form_is_submitted)>
	<cfif attributes.totalrecords gt attributes.maxrows>
        <cfset url_str = "&form_is_submitted=1&datecontrol=1">
        <cfif isdefined("attributes.branch_id") and len(attributes.branch_id)>
            <cfset url_str = "#url_str#&branch_id=#attributes.branch_id#">
        </cfif>
        <cfif isdefined("attributes.keyword") and len(attributes.keyword)>
            <cfset url_str = "#url_str#&keyword=#attributes.keyword#">
        </cfif>
        <cfif isdefined("attributes.dsp_tablo") and len(attributes.dsp_tablo)>
            <cfset url_str = "#url_str#&dsp_tablo=#attributes.dsp_tablo#">
        </cfif>
        <cfif isdefined("attributes.dsp_source") and len(attributes.dsp_source)>
            <cfset url_str = "#url_str#&dsp_source=#attributes.dsp_source#">
        </cfif>
        <cfif isdefined("attributes.company") and len(attributes.company)>
            <cfset url_str = "#url_str#&company=#attributes.company#">
        </cfif>
        <cfif isdefined("attributes.comp") and len(attributes.comp)>
            <cfset url_str = "#url_str#&comp=#attributes.comp#">
        </cfif>
        <cfif isdefined("attributes.stock_id") and len(attributes.stock_id)>
            <cfset url_str = "#url_str#&stock_id=#attributes.stock_id#">
        </cfif>
        <cfif isdefined("attributes.product_id") and len(attributes.product_id)>
            <cfset url_str = "#url_str#&product_id=#attributes.product_id#">
        </cfif>
        <cfif isdefined("attributes.stock_name") and len(attributes.stock_name)>
            <cfset url_str = "#url_str#&stock_name=#attributes.stock_name#">
        </cfif>
        <cfif isdefined("attributes.spect_main_id") and len(attributes.spect_main_id)>
            <cfset url_str = "#url_str#&spect_main_id=#attributes.spect_main_id#">
        </cfif>
        <cfif isdefined("attributes.spect_name") and len(attributes.spect_name)>
            <cfset url_str = "#url_str#&spect_name=#attributes.spect_name#">
        </cfif>
        <cfif isdefined("attributes.branch_name") and len(attributes.branch_name)>
            <cfset url_str = "#url_str#&branch_name=#attributes.branch_name#">
        </cfif>
        <cfif isdefined("attributes.date1") and len(attributes.date1)>
            <cfset url_str = "#url_str#&date1=#attributes.date1#">
        </cfif>
        <cfif isdefined("attributes.date2") and len(attributes.date2)>
            <cfset url_str = "#url_str#&date2=#attributes.date2#">
        </cfif>
        <cfif isdefined("attributes.station_id") and len(attributes.station_id)>
            <cfset url_str = "#url_str#&station_id=#attributes.station_id#">
        </cfif>
        <cfif isdefined("attributes.station_name") and len(attributes.station_name)>
            <cfset url_str = "#url_str#&station_name=#attributes.station_name#">
        </cfif>
        <table width="98%" border="0" cellpadding="0" cellspacing="0" height="35" align="center">
          <tr>
            <td>
              <cf_pages page="#attributes.page#"
                     maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                   startrow="#attributes.startrow#"
                      adres="report.detail_report&report_id=#report_id#&#url_str#">
            </td>
            <!-- sil -->
            <td style="text-align:right" style="text-align:right;"><cfoutput><cf_get_lang_main no='128.Toplam Kayıt'>:#attributes.totalrecords# - <cf_get_lang_main no='169.Sayfa'>:#attributes.page#/#lastpage#</cfoutput></td>
          <!-- sil -->
          </tr>
        </table>
    </cfif>
</cfif>--->
<script type="text/javascript">
	function kontrol_due_option()
	{
		if(document.form.gizle_id.value == 1)
			gizli.style.display='';
		else
			gizli.style.display='none';
	}
	function product_control(){/*Ürün seçmeden spec seçemesin.*/
		if(document.getElementById('stock_id').value=="" || document.getElementById('stock_name').value == "" ){
			alert("<cf_get_lang no='1937.Spec Seçmek İçin Öncelikle Ürün Seçmeniz Gerekmektedir'>");
			return false;
		}
		else
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_spect_main&field_main_id=form.spect_main_id&field_name=form.spect_name&is_display=1&stock_id='+document.getElementById('stock_id').value,'list');
	}
	function tarih_kontrolu()
	{
	
		if( !date_check(document.form.date1, document.form.date2, "<cf_get_lang no ='210.Başlangıç Tarihi Bitiş Tarihinden Büyük Olamaz'>!") )
		return false;
		
		if(form.date1.value.length)
			if (!global_date_check_value("01/01/<cfoutput>#SESSION.EP.PERIOD_YEAR#</cfoutput>",form.date1.value, 'Başlangıç Tarihi'))
				return false;
		
		if(form.date2.value.length)
			if (!global_date_check_value("01/01/<cfoutput>#SESSION.EP.PERIOD_YEAR#</cfoutput>",form.date2.value, 'Bitiş Tarihi'))			
				return false;
		
		if(document.form.is_excel.checked==false)
		{
			document.form.action="<cfoutput>#request.self#?fuseaction=account.list_ezgi_cost_of_product_sold</cfoutput>";
			return true;
		}
		else
			document.form.action="<cfoutput>#request.self#?fuseaction=#fusebox.circuit#.emptypopup_list_account_card_rows</cfoutput>";
	}
	function acc_kontrol()
	{
		if(account_name.code1.value > account_name.code2.value)
		{
			alert("<cf_get_lang no ='211.Muhasebe Hesap Seçiminizi Kontrol ediniz'>!");
			return false;
		}
		return true;
	}
	function pencere_ac_muavin(str_alan_1,str_alan_2,str_alan)
	{
		var txt_keyword = eval(str_alan_1 + ".value" );
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_account_plan_all&field_id='+str_alan_1+'&field_id2='+str_alan_1+'&keyword='+txt_keyword,'list');
	}
	function muavin_pdf_ac()
	{
		if((document.form.code1.value=='') || (document.form.code2.value==''))
		{
			alert("<cf_get_lang no ='196.Önce Hesap Kodlarını Seçiniz'>!");
			return false;
		}
		
		if((document.form.date1.value=='') || (document.form.date2.value==''))
		{
			alert("<cf_get_lang no ='197.Önce Tarihleri Seçiniz'>!");
			return false;
		}
		
		if (!tarih_kontrolu())
		return false;
		
		if(document.form.is_acc_with_action.checked)
			is_acc_with_action_=1;
		else
			is_acc_with_action_=0;
			
		
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=report.popup_rapor_muavin&is_acc_with_action='+is_acc_with_action_+'&date1='+document.form.date1.value+'&date2='+document.form.date2.value+'&code1='+document.form.code1.value+'&code2='+document.form.code2.value,'small');
	}
</script>
