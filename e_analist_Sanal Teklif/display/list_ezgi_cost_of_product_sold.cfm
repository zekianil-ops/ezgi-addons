<cfparam name="attributes.project_id" default="">
<cfparam name="attributes.project_head" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.dsp_tablo" default="">
<cfparam name="attributes.dsp_source" default="">
<cfparam name="attributes.company" default="">
<cfparam name="attributes.comp" default="">
<cfparam name="attributes.stock_id" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.stock_name" default="">
<cfparam name="attributes.spect_main_id" default="">
<cfparam name="attributes.spect_name" default="">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.branch_name" default="">
<cfparam name="attributes.date1" default="#now()#"> 
<cfparam name="attributes.date2" default="#now()#">
<cfparam name="attributes.maxrows" default="#session.ep.maxrows#">
<cfparam name="attributes.url_str" default="">
<cfparam name="attributes.page" default=1>
<cfparam name="bakiye" default="0">
<cfparam name="attributes.form_is_submitted" default="">
<cfset t_kal_tutar= 0>
<cfset t_tut_maliyet= 0>
<cfset t_puchase_tut_maliyet = 0>
<cfset it_kal_tutar= 0>
<cfset it_tut_maliyet= 0>
<cfset it_puchase_tut_maliyet = 0>
<cfquery name="get_branch" datasource="#dsn#">
	SELECT BRANCH_NAME, BRANCH_ID FROM BRANCH WHERE BRANCH_STATUS = 1 AND COMPANY_ID = #session.ep.company_id#
</cfquery>
<cfif isdefined("attributes.form_is_submitted") AND len(attributes.form_is_submitted)>
	<cfif isdefined("attributes.date1") AND isdate(attributes.date1)>
        <cf_date tarih='attributes.date1'>
    </cfif>
	<cfif isdefined("attributes.date2") AND isdate(attributes.date2)>
        <cf_date tarih='attributes.date2'>
    </cfif>    
</cfif>
<cf_basket_form id="report_orders_">
<!-- sil -->
<table width="100%" border="0" style="text-align:center" cellpadding="1" cellspacing="1">
	<cfform name="form" action="#request.self#?fuseaction=account.list_ezgi_cost_of_product_sold" method="post">
    <input type="hidden" name="form_is_submitted" value="1"> 
	<tr height="20">
    	<td colspan="2">
        	<table width="100%" border="0" style="text-align:center" cellpadding="1" cellspacing="1">
            	<tr>
                	<td align="left" width="50">Filtre</td>
                    <td align="left" width="100">
                    	<cfinput type="text" name="keyword" value="#attributes.keyword#" style="width:100px">
                    </td>
                	<td align="left" width="60">Müşteri</td>
                    <td align="left" width="180">
                        <input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined('attributes.consumer_id') and len(attributes.company)><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
                        <input type="hidden" name="company_id" id="company_id" value="<cfif len(attributes.company)><cfoutput>#attributes.company_id#</cfoutput></cfif>">
                        <input type="hidden" name="employee_id2" id="employee_id2" value="<cfif len(attributes.company)><cfoutput>#attributes.employee_id2#</cfoutput></cfif>">
                        <input type="text" name="company" id="company" style="width:160px;" onFocus="AutoComplete_Create('company','MEMBER_NAME,MEMBER_PARTNER_NAME','MEMBER_NAME,MEMBER_CODE,MEMBER_PARTNER_NAME','get_member_autocomplete','\'1,2,3\',0,0,0','COMPANY_ID,CONSUMER_ID,EMPLOYEE_ID','company_id,consumer_id,employee_id2','','3','250');" value="<cfif len(attributes.company)><cfoutput>#attributes.company#</cfoutput></cfif>" autocomplete="off">
                        <a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_pars&field_comp_name=form.company&field_comp_id=form.company_id&field_consumer=form.consumer_id&field_emp_id=form.employee_id2&field_name=form.company&field_member_name=form.company&select_list=2,3,1,9','list');"><img src="/images/plus_thin.gif" border="0" align="absmiddle"></a>
                    </td>
                    <td align="left" valign="middle" width="50"><cf_get_lang_main no ='245.Ürün'></td>
                    <td align="left" valign="middle" width="170">
                        <input type="hidden" name="stock_id" id="stock_id" value="<cfoutput>#attributes.stock_id#</cfoutput>">
                        <input type="hidden" name="product_id" id="product_id" value="<cfoutput>#attributes.product_id#</cfoutput>">
                        <cfinput type="text" name="stock_name" id="stock_name" style="width:150px;" value="#attributes.stock_name#" onFocus="AutoComplete_Create('stock_name','PRODUCT_NAME','PRODUCT_NAME,STOCK_CODE','get_product_autocomplete','0','STOCK_ID,PRODUCT_ID','stock_id,product_id','','3','225');" autocomplete="off">
                        <a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&field_id=form.stock_id&product_id=form.product_id&field_name=form.stock_name','list');"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a></td>
                    <td align="left" valign="middle" width="40"><cf_get_lang_main no ='235.Spec'></td>
                    <td align="left" valign="middle" width="170">
                        <input type="hidden" name="spect_main_id" value="<cfoutput>#attributes.spect_main_id#</cfoutput>">
                        <input style="width:150px;" type="text" name="spect_name" value="<cfoutput>#attributes.spect_name#</cfoutput>">
                        <a href="javascript://" onClick="product_control();"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>
                    </td>
                    <td align="left" width="50">Şube</td>
                    <td align="left" width="100">
                        <select name="branch_id" style="width:100px; height:20px">
                            <option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                            <cfoutput query="get_branch">
                                <option value="#branch_id#" <cfif attributes.branch_id eq branch_id>selected</cfif>>#BRANCH_NAME#</option>
                            </cfoutput>
                        </select>
                    </td>
                    <td align="left" width="50">Proje</td>
                    <td align="left" width="175">
                        <input type="hidden" name="project_id" id="project_id" value="<cfoutput>#attributes.project_id#</cfoutput>">
                        <input type="text" name="project_head" id="project_head" value="<cfif len(attributes.project_head)><cfoutput>#attributes.project_head#</cfoutput></cfif>" style="width:150px;" onFocus="AutoComplete_Create('project_head','PROJECT_ID,PROJECT_HEAD','PROJECT_HEAD','get_project','','PROJECT_ID','project_id','','3','135')"autocomplete="off">
                        <a href="javascript://" onClick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_projects&project_id=form.project_id&project_head=form.project_head','list');"><img src="/images/plus_list.gif" align="absmiddle" border="0"></a>	
                    </td>
                    
                    <td></td>
                </tr>
            </table>
        </td>
    </tr>
	<tr>
		<td colspan="2">
            <table width="100%" border="0" cellpadding="1" cellspacing="1">
                <tr valign="middle">
                	<td style="text-align:right" nowrap="nowrap">
                    	<input type="checkbox" name="dsp_tablo" value="1" <cfif attributes.dsp_tablo eq 1>checked</cfif>> 
                    	Tablo Değerleri Görünsün
                    	<input type="checkbox" name="dsp_source" value="1" <cfif attributes.dsp_source eq 1>checked</cfif>> 
                    	Kaynak Bilgileri Görünsün 
                        <cfsavecontent variable="message"><cf_get_lang_main no='59.Eksik veri'>:<cf_get_lang_main no='641.Başlangıç Tarihi'>!</cfsavecontent>
                        <cfinput type="text" name="date1" maxlength="10" value="#dateformat(attributes.date1,'dd/mm/yyyy')#" required="yes" message="#message#" style="width:65px;" validate="eurodate">
                        <cf_wrk_date_image date_field="date1">
                        <cfsavecontent variable="message"><cf_get_lang_main no='59.Eksik veri'>:<cf_get_lang_main no='288.Bitiş Tarihi'>!</cfsavecontent>
                        <cfinput type="text" name="date2" maxlength="10" value="#dateformat(attributes.date2,'dd/mm/yyyy')#" required="yes" message="#message#" style="width:65px;" validate="eurodate">
                        <cf_wrk_date_image date_field="date2">
                    	<cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1," required="yes" style="width:25px;">
                        <cfsavecontent variable="message"><cf_get_lang_main no ='499.Çalıştır'></cfsavecontent>
                        <cf_workcube_buttons add_function='tarih_kontrolu()' is_upd='0' is_cancel='0' insert_info='#message#' insert_alert=''>
                    </td>	
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
            <tr style="height:20px">
                <th colspan="4">Fatura Bilgileri</th>
                <th colspan="6">Fatura Kalem Bilgileri</th>
                <cfif attributes.dsp_tablo eq 1>
                    <th colspan="4">Fatura Kalem Maliyetleri</th>
                    <th colspan="4" >Maliyet Tablo Değerleri</th>
                <cfelse>
                    <th colspan="6" >Fatura Kalem Maliyetleri</th>
                </cfif>
                <cfif attributes.dsp_source eq 1>
                    <th colspan="9" >Kaynak Bilgileri</th>
                </cfif>
            </tr>			
            <tr height="22">
                <th style="text-align:center; width:70px"  >Fatura No</th>
                <th style="text-align:center; width:70px"  >Tarih</th>
                <th style="text-align:center; width:150px"  >Cari Hesap </th>
                <th style="text-align:center; width:70px"  >Proje </th>
                <th style="text-align:center; width:70px"  >Ürün Kodu</th>	
                <th style="text-align:center; width:180px"  >Ürün </th>
                <th style="text-align:center;"  >Spec </th>
                <th style="text-align:center; width:70px"  >Miktar</th>
                <th style="text-align:center; width:70px"  >Birim Fiyat</th>
                <th style="text-align:center; width:70px"  >Tutar</th>
                <th style="text-align:center; width:70px"  >Net Maliyet</th>
                <th style="text-align:center; width:70px"  >Ek Maliyet</th>
                <th style="text-align:center; width:70px"  >Toplam Maliyet</th>
                <th style="text-align:center; width:70px"  >Tutar</th>
                <cfif attributes.dsp_tablo eq 1>	
                    <th style="text-align:center; width:70px"  >Net Maliyet</th>
                    <th style="text-align:center; width:70px"  >Ek Maliyet</th>
                    <th style="text-align:center; width:70px"  >Toplam Maliyet</th>
                    <th style="text-align:center; width:70px"  >Tutar</th>
                <cfelse>
                    <th style="text-align:center; width:70px"  >Kar / Zarar</th>
                    <th style="text-align:center; width:70px"  >Oran %</th>
                </cfif>
                <cfif attributes.dsp_source eq 1>
                    <th style="text-align:center; width:160px"  >Belge Türü</th>
                    <th style="text-align:center; width:110px"  >Tarih</th>
                    <th style="text-align:center; width:60px"  >Belge No</th>
                    <th style="text-align:center; width:70px"  >Net Maliyet</th>
                    <th style="text-align:center; width:70px"  >Ek Maliyet</th>
                    <th style="text-align:center; width:70px"  >Toplam Maliyet</th>
                </cfif>      
            </tr>
        </thead>
        <cfif isdefined("attributes.form_is_submitted") AND len(attributes.form_is_submitted)>
            <cfquery name="GET_PRODUCT_COST_ID" datasource="#dsn2#">
                SELECT     	
                	I.INVOICE_ID, 
                	I.INVOICE_DATE, 
                	I.INVOICE_NUMBER, 
                	I.COMPANY_ID,
                	I.CONSUMER_ID,
                	I.EMPLOYEE_ID, 
                	I.PROJECT_ID, 
                	I.IS_COST,
                	P.PRODUCT_CODE, 
                	IR.INVOICE_ROW_ID, 
                	IR.PRODUCT_ID, 
                	IR.STOCK_ID, 
                	IR.SPECT_VAR_ID, 
                	IR.NAME_PRODUCT, 
                	IR.SPECT_VAR_NAME, 
                	IR.AMOUNT, 
                	IR.UNIT, 
                	IR.PRICE, 
                	IR.PRICE_OTHER, 
                	IR.COST_PRICE, 
                	IR.EXTRA_COST,
                	I.PURCHASE_SALES, 
                	S.SPECT_MAIN_ID,
                	ISNULL((	
                    		SELECT  	
                        		TOP (1) PC_1.PRODUCT_COST_ID
                     		FROM      	
                            	#dsn1_alias#.PRODUCT_COST PC_1
                         	WHERE      	
                            	PC_1.SPECT_MAIN_ID = S.SPECT_MAIN_ID AND 
                                PC_1.START_DATE <= I.INVOICE_DATE AND 
                                P.IS_PRODUCTION=1 AND 
                                PC_1.ACTION_PERIOD_ID = #session.ep.period_id#
                          	ORDER BY 	
                            	PC_1.START_DATE DESC, 
                                PC_1.PRODUCT_COST_ID
                           	UNION ALL
                           	SELECT  	
                            	TOP (1) PC_2.PRODUCT_COST_ID
                          	FROM      	
                            	#dsn1_alias#.PRODUCT_COST PC_2
                          	WHERE      	
                            	PC_2.PRODUCT_ID = IR.PRODUCT_ID AND 
                                PC_2.START_DATE <= I.INVOICE_DATE AND 
                                P.IS_PRODUCTION=0 AND 
                                PC_2.ACTION_PERIOD_ID = #session.ep.period_id#
                          	ORDER BY 	
                            	PC_2.START_DATE DESC , 
                                PC_2.PRODUCT_COST_ID
            		),0) AS P_ID
                FROM   		
                	INVOICE AS I INNER JOIN
                 	INVOICE_ROW AS IR ON I.INVOICE_ID = IR.INVOICE_ID INNER JOIN
                  	#dsn1_alias#.PRODUCT AS P ON IR.PRODUCT_ID = P.PRODUCT_ID LEFT OUTER JOIN
                   	#dsn3_alias#.SPECTS AS S ON IR.SPECT_VAR_ID = S.SPECT_VAR_ID
                WHERE     	
                	(
                    	(I.PURCHASE_SALES = 1) AND (I.INVOICE_CAT = 53) OR 
                       	(I.PURCHASE_SALES = 0) AND (I.INVOICE_CAT = 55) OR
                      	(I.PURCHASE_SALES = 1) AND (I.INVOICE_CAT = 531)
                   	) 
                    AND I.INVOICE_DATE BETWEEN #attributes.date1# AND #attributes.date2#
                   	<cfif len(trim(attributes.company)) and len(attributes.company_id)>
                		AND I.COMPANY_ID = #attributes.company_id#
                   	</cfif>
                  	<cfif isdefined('attributes.consumer_id') and len(trim(attributes.company)) and len(attributes.consumer_id)>
                       	AND I.CONSUMER_ID = #attributes.consumer_id#
                   	</cfif>
                   	<cfif isdefined('attributes.employee_id2') and len(trim(attributes.company)) and len(attributes.employee_id2)>
                       	AND I.EMPLOYEE_ID = #attributes.employee_id2#
                   	</cfif>
                   	<cfif len(attributes.branch_id)>
                      	AND I.DEPARTMENT_ID IN(SELECT DEPARTMENT_ID FROM #dsn_alias#.DEPARTMENT WHERE (BRANCH_ID = #attributes.branch_id#))	
                   	</cfif>
                   	<cfif len(trim(attributes.stock_name)) and len(attributes.stock_id)>
                      	AND	IR.STOCK_ID = #attributes.stock_id#
                   	</cfif>
                   	<cfif len(trim(attributes.spect_name)) and len(attributes.spect_main_id)>
                     	AND	SPECT_MAIN_ID = #attributes.spect_main_id#
                  	</cfif>
                  	<cfif len(attributes.project_id)>
                    	AND PROJECT_ID = #attributes.project_id#
                   	</cfif>
                   	<cfif len(attributes.keyword)>
                      	AND P.PRODUCT_CODE LIKE '%#attributes.keyword#%'
                   	</cfif>
              	ORDER BY 	
                	I.PURCHASE_SALES, 
                    I.INVOICE_DATE
            </cfquery>
            <cfparam name="attributes.totalrecords" default="#GET_PRODUCT_COST_ID.recordCount#">
            <cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>
            <cfif GET_PRODUCT_COST_ID.recordcount>
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
                            	(SF_1.FIS_TYPE = 110) <!---AND 
                            	(PC_1.ACTION_PROCESS_TYPE = 171)--->
                        </cfquery>
                        <cfif GET_PRODUCT_COST.recordcount>
                            <cfset kal_tutar=PRICE*AMOUNT>
                            <cfset top_maliyet =EXTRA_COST+COST_PRICE>
                            <cfset tut_maliyet =AMOUNT*(EXTRA_COST+COST_PRICE)>
                            <cfif PURCHASE_SALES eq 1>
                                <cfset t_kal_tutar=t_kal_tutar+kal_tutar>
                                <cfset t_tut_maliyet=t_tut_maliyet+tut_maliyet>
                            <cfelse>
                                <cfset it_kal_tutar=it_kal_tutar+kal_tutar>
                                <cfset it_tut_maliyet=it_tut_maliyet+tut_maliyet>
                            </cfif>
                            <cfset _PURCHASE_NET_SYSTEM[INVOICE_ROW_ID]=GET_PRODUCT_COST.PURCHASE_NET_SYSTEM>
                            <cfset _PURCHASE_EXTRA_COST_SYSTEM[INVOICE_ROW_ID]=GET_PRODUCT_COST.PURCHASE_EXTRA_COST_SYSTEM>
                            <cfset _ACTION_PROCESS_CAT_ID[INVOICE_ROW_ID]=GET_PRODUCT_COST.ACTION_PROCESS_CAT_ID>
                            <cfset _ACTION_DATE[INVOICE_ROW_ID]=GET_PRODUCT_COST.ACTION_DATE>
                            <cfquery name="PROCESS_TYPE_NAME" datasource="#dsn3#">
                                SELECT     
                                	PROCESS_CAT
                                FROM         
                                	SETUP_PROCESS_CAT
                                WHERE     
                                	PROCESS_CAT_ID = #GET_PRODUCT_COST.ACTION_PROCESS_CAT_ID#
                            </cfquery>
                            <cfif PROCESS_TYPE_NAME.recordcount>
                                <cfset _ACTION_PROCESS_CAT[INVOICE_ROW_ID]=PROCESS_TYPE_NAME.PROCESS_CAT>
                            <cfelse>
                                <cfset _ACTION_PROCESS_CAT[INVOICE_ROW_ID]='Belge Tipi Bulunamadı'>
                            </cfif>
                            <cfif GET_PRODUCT_COST.ACT_AMOUNT neq ''>
                                <cfset _ACT_AMOUNT[INVOICE_ROW_ID]=GET_PRODUCT_COST.ACT_AMOUNT> 
                                <cfset _ACT_COST_PRICE[INVOICE_ROW_ID]=GET_PRODUCT_COST.ACT_COST_PRICE> 
                                <cfset _ACT_EXTRA_COST[INVOICE_ROW_ID]=GET_PRODUCT_COST.ACT_EXTRA_COST>
                                <cfset _ACT_DATE[INVOICE_ROW_ID]=GET_PRODUCT_COST.ACT_DATE>
                                <cfset _ACT_NUMBER[INVOICE_ROW_ID]=GET_PRODUCT_COST.ACT_NUMBER>
                            <cfelse>
                                <cfset maliyet[INVOICE_ROW_ID] =2>
                                <cfset _ACT_AMOUNT[INVOICE_ROW_ID]=0> 
                                <cfset _ACT_COST_PRICE[INVOICE_ROW_ID]=0> 
                                <cfset _ACT_EXTRA_COST[INVOICE_ROW_ID]=0>
                                <cfset _ACT_DATE[INVOICE_ROW_ID]=0>
                                <cfset _ACT_NUMBER[INVOICE_ROW_ID]=0>
                            </cfif>      
                            <cfset _ACT_top[INVOICE_ROW_ID]=_ACT_COST_PRICE[INVOICE_ROW_ID]+_ACT_EXTRA_COST[INVOICE_ROW_ID]>
                            <cfset _ACT_tut[INVOICE_ROW_ID]=_ACT_AMOUNT[INVOICE_ROW_ID]*(_ACT_COST_PRICE[INVOICE_ROW_ID]+_ACT_EXTRA_COST[INVOICE_ROW_ID])>
                        <cfelse>
                            <cfset maliyet[INVOICE_ROW_ID] =3>
                            <cfset _PURCHASE_NET_SYSTEM[INVOICE_ROW_ID]=0>
                            <cfset _PURCHASE_EXTRA_COST_SYSTEM[INVOICE_ROW_ID]=0>
                            <cfset _ACTION_PROCESS_CAT_ID[INVOICE_ROW_ID]=0>
                            <cfset _ACTION_DATE[INVOICE_ROW_ID]=''>
                            <cfset _ACTION_PROCESS_CAT[INVOICE_ROW_ID]=''>
                        </cfif>
                        <cfif PURCHASE_SALES eq 1>
                            <cfset _puchase_top_maliyet[INVOICE_ROW_ID] = _PURCHASE_NET_SYSTEM[INVOICE_ROW_ID]+_PURCHASE_EXTRA_COST_SYSTEM[INVOICE_ROW_ID]>
                            <cfset _puchase_tut_maliyet[INVOICE_ROW_ID] = AMOUNT*(_PURCHASE_NET_SYSTEM[INVOICE_ROW_ID]+_PURCHASE_EXTRA_COST_SYSTEM[INVOICE_ROW_ID])>
                            <cfset t_puchase_tut_maliyet = t_puchase_tut_maliyet + _puchase_tut_maliyet[INVOICE_ROW_ID]>
                        <cfelse>
                            <cfset _puchase_top_maliyet[INVOICE_ROW_ID] = _PURCHASE_NET_SYSTEM[INVOICE_ROW_ID]+_PURCHASE_EXTRA_COST_SYSTEM[INVOICE_ROW_ID]>
                            <cfset _puchase_tut_maliyet[INVOICE_ROW_ID] = AMOUNT*(_PURCHASE_NET_SYSTEM[INVOICE_ROW_ID]+_PURCHASE_EXTRA_COST_SYSTEM[INVOICE_ROW_ID])>
                            <cfset it_puchase_tut_maliyet = it_puchase_tut_maliyet + _puchase_tut_maliyet[INVOICE_ROW_ID]>
                        </cfif>       
                        <cfset maliyet[INVOICE_ROW_ID] =1>                
                    <cfelse>
                        <cfset maliyet[INVOICE_ROW_ID] =0>
                    </cfif>
                </cfloop>
                <cfset t_kal_tutar= 0>
                <cfset t_tut_maliyet= 0>
                <cfset it_kal_tutar= 0>
                <cfset it_tut_maliyet= 0>
                <cfoutput query="GET_PRODUCT_COST_ID" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                    <cfset sira=currentrow>
                    <cfif len(company_id)>
                        <cfquery name="GET_CMP_ID" datasource="#dsn#">
                            SELECT     
                            	NICKNAME AS NAME
                            FROM         
                            	COMPANY
                            WHERE     
                            	COMPANY_ID = #COMPANY_ID#
                        </cfquery>
                    <cfelseif len(consumer_id)>
                        <cfquery name="GET_CMP_ID" datasource="#dsn#">
                            SELECT    	
                            	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS NAME
                            FROM        
                            	CONSUMER
                            WHERE     	
                            	CONSUMER_ID = #CONSUMER_ID#
                        </cfquery>
                    <cfelseif len(employee_id)>
                        <cfquery name="GET_CMP_ID" datasource="#dsn#">
                            SELECT     	
                            	EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS NAME
                            FROM      	
                            	EMPLOYEES
                            WHERE     	
                            	EMPLOYEE_ID = #EMPLOYEE_ID#
                        </cfquery>
                    </cfif>
                    <cfif isdefined('PROJECT_ID') and len(PROJECT_ID)>		
                        <cfquery name="GET_PRJ_ID" datasource="#dsn#">
                            SELECT     
                            	PROJECT_HEAD
                            FROM         
                            	PRO_PROJECTS
                            WHERE     
                            	PROJECT_ID = #PROJECT_ID#
                        </cfquery>
                        <cfset _project_head=GET_PRJ_ID.PROJECT_HEAD>
                    <cfelse>
                        <cfset _project_head='Proje Yok'>
                    </cfif>
                    <cfset kal_tutar=PRICE*AMOUNT>
                    <cfset top_maliyet =EXTRA_COST+COST_PRICE>
                    <cfset tut_maliyet =AMOUNT*(EXTRA_COST+COST_PRICE)>
                    <cfif PURCHASE_SALES eq 1>
                        <cfset t_kal_tutar=t_kal_tutar+kal_tutar>
                        <cfset t_tut_maliyet=t_tut_maliyet+tut_maliyet>
                    <cfelse>
                        <cfset it_kal_tutar=it_kal_tutar+kal_tutar>
                        <cfset it_tut_maliyet=it_tut_maliyet+tut_maliyet>
                    </cfif>
                    <tbody>
                        <cfif PURCHASE_SALES eq 1>
                            <tr height="30">
                                <td >#INVOICE_NUMBER#</td>
                        <cfelse>
                            <tr height="30">
                                <td >İADE - #INVOICE_NUMBER#</td>
                        </cfif>
                            <td >#dateformat(INVOICE_DATE,'dd/mm/yyyy')#</td>
                            <td >#GET_CMP_ID.NAME# </td>
                            <td >#_project_head# </td>
                            <td>#PRODUCT_CODE# </td>
                            <td>#NAME_PRODUCT# </td>
                            <td>#SPECT_VAR_NAME# </td>
                            <td style="text-align:right">#TLFormat((AMOUNT),2)#</td>
                            <td style="text-align:right">#TLFormat((PRICE),2)#</td>
                            <td style="text-align:right">#TLFormat((kal_tutar),2)#</td>
                            <td style="text-align:right">#TLFormat((COST_PRICE),2)#</td>
                            <td style="text-align:right">#TLFormat((EXTRA_COST),2)#</td>
                            
                            <td style="text-align:right">#TLFormat((top_maliyet),2)#</td>
                            <td style="text-align:right">#TLFormat((tut_maliyet),2)#</td>
                            <cfif attributes.dsp_tablo eq 1>
                                <td style="text-align:right"><cfif maliyet[INVOICE_ROW_ID] neq 0>#TLFormat((_PURCHASE_NET_SYSTEM[INVOICE_ROW_ID]),2)#<cfelse><font color="red">0,00</font></cfif></td>
                                <td style="text-align:right"><cfif maliyet[INVOICE_ROW_ID] neq 0>#TLFormat((_PURCHASE_EXTRA_COST_SYSTEM[INVOICE_ROW_ID]),2)#<cfelse><font color="red">0,00</font></cfif></td>
                                <td style="text-align:right"><cfif maliyet[INVOICE_ROW_ID] neq 0><cfif TLFormat((top_maliyet),2) neq TLFormat((_puchase_top_maliyet[INVOICE_ROW_ID]),2)><font color="red"> #TLFormat((_puchase_top_maliyet[INVOICE_ROW_ID]),2)#</font><cfelse>#TLFormat((_puchase_top_maliyet[INVOICE_ROW_ID]),2)#</cfif><cfelse><font color="red">0,00</font></cfif></td>
                                <td style="text-align:right"><cfif maliyet[INVOICE_ROW_ID] neq 0>#TLFormat((_puchase_tut_maliyet[INVOICE_ROW_ID]),2)#<cfelse><font color="red">0,00</font></cfif></td>
                            <cfelse>
                                <cfif PURCHASE_SALES eq 1>      
                                    <td style="text-align:right">#TLFormat((kal_tutar - tut_maliyet),2)#</td>
                                    <td style="text-align:center"><cfif tut_maliyet neq 0 >#TLFormat(((kal_tutar - tut_maliyet)/tut_maliyet)*100,2)#<cfelse>0</cfif></td>
                                <cfelse>
                                    <td style="text-align:right">#TLFormat((tut_maliyet - kal_tutar),2)#</td>
                                    <td style="text-align:center"><cfif tut_maliyet neq 0 >#TLFormat(((tut_maliyet - kal_tutar)/tut_maliyet)*100,2)#<cfelse><font color="red">0,00</font></cfif></td>
                                </cfif>
                            </cfif>
                            <cfif attributes.dsp_source eq 1>
                                <td><cfif maliyet[INVOICE_ROW_ID] neq 0>#_ACTION_PROCESS_CAT[INVOICE_ROW_ID]#<cfelse><font color="red">Kayıt Yok.</font></cfif></td>
                                <td><cfif maliyet[INVOICE_ROW_ID] neq 0>#dateformat(_ACT_DATE[INVOICE_ROW_ID],'dd/mm/yyyy')#<cfelse><font color="red">Kayıt Yok.</font></cfif></td>
                                <td><cfif maliyet[INVOICE_ROW_ID] neq 0>#_ACT_NUMBER[INVOICE_ROW_ID]#<cfelse><font color="red">Kayıt Yok.</font></cfif></td>
                                <td style="text-align:right"><cfif maliyet[INVOICE_ROW_ID] neq 0>#TLFormat((_ACT_COST_PRICE[INVOICE_ROW_ID]),2)#<cfelse><font color="red">0,00</font></cfif></td>
                                <td style="text-align:right"><cfif maliyet[INVOICE_ROW_ID] neq 0>#TLFormat((_ACT_EXTRA_COST[INVOICE_ROW_ID]),2)#<cfelse><font color="red">0,00</font></cfif></td>
                                <td style="text-align:right"><cfif maliyet[INVOICE_ROW_ID] neq 0><cfif TLFormat(( _ACT_top[INVOICE_ROW_ID]),2) neq TLFormat(( _ACT_top[INVOICE_ROW_ID]),2)><font color="red">#TLFormat(( _ACT_top[INVOICE_ROW_ID]),2)#</font><cfelse>#TLFormat(( _ACT_top[INVOICE_ROW_ID]),2)#</cfif><cfelse><font color="red">0,00</font></cfif></td>
                            </cfif>
                        </tr>
                    </tbody>
                </cfoutput>
                <cfif isdefined("attributes.form_is_submitted") AND len(attributes.form_is_submitted)>
                    <tfoot>
                        <cfif attributes.totalrecords eq sira>
                            <tr style="height:20px; font-weight:bold"><cfoutput>
                                <td colspan="4" >Satılan Malın Maliyeti</td>
                                <td style="text-align:right" colspan="5" >Fatura Mal Satış Toplamı</td>
                                <td style="text-align:right" >#TLFormat((t_kal_tutar),2)#</td>
                                
                                <td style="text-align:right" colspan="3" >Fatura - Malın Maliyeti Toplamı</td>
                                <td style="text-align:right" >#TLFormat((t_tut_maliyet),2)#</td>
                                <cfif attributes.dsp_tablo eq 1>
                                    <td style="text-align:right" colspan="3" >Maliyet Tablosu - Toplamı</td>
                                    <td style="text-align:right" >#TLFormat((t_puchase_tut_maliyet),2)#</td>
                                <cfelse>      
                                    <td style="text-align:right">#TLFormat((t_kal_tutar - t_tut_maliyet),2)#</td>
                                    <td style="text-align:center"><cfif t_kal_tutar - t_tut_maliyet neq 0 and t_tut_maliyet neq 0 and t_kal_tutar neq 0>#TLFormat(((t_kal_tutar - t_tut_maliyet)/t_tut_maliyet)*100,2)#<cfelse>0</cfif></td>
                                </cfif>
                                <cfif attributes.dsp_source eq 1>
                                    <td style="text-align:right" colspan="6" ></td>
                                </cfif></cfoutput>
                            </tr>
                            <cfif it_puchase_tut_maliyet gt 0>
                                <tr height="20"><cfoutput>
                                    <td align="left" colspan="4" >İade Alınan Malın Maliyeti</td>
                                    <td style="text-align:right" colspan="5" >Fatura Mal İade Toplamı</td>
                                    <td style="text-align:right" >#TLFormat((it_kal_tutar),2)#</td>
                                    <td style="text-align:right" colspan="3" >Fatura - Malın Maliyeti Toplamı</td>
                                    <td style="text-align:right" >#TLFormat((it_tut_maliyet),2)#</td>
                                    <cfif attributes.dsp_tablo eq 1>
                                        <td style="text-align:right" colspan="3" >Maliyet Tablosu - Toplamı</td>
                                        <td style="text-align:right" >#TLFormat((it_puchase_tut_maliyet),2)#</td>
                                    <cfelse>      
                                        <td style="text-align:right">#TLFormat((it_tut_maliyet - it_kal_tutar),2)#</td>
                                        <td style="text-align:center">#TLFormat(((it_tut_maliyet - it_kal_tutar)/it_tut_maliyet)*100,2)#</td>
                                    </cfif>
                                    <cfif attributes.dsp_source eq 1>
                                        <td style="text-align:right" colspan="6" ></td>
                                    </cfif>
                                </tr>
                                <tr height="20">
                                    <td align="left" colspan="4" >SONUÇ</td>
                                    <td style="text-align:right" colspan="5" >Fatura Toplamı</td>
                                    <td style="text-align:right" >#TLFormat((t_kal_tutar-it_kal_tutar),2)#</td>
                                    <td style="text-align:right" colspan="3" >Maliyet Toplamı</td>
                                    <td style="text-align:right" >#TLFormat((t_tut_maliyet-it_tut_maliyet),2)#</td>
                                    <cfif attributes.dsp_tablo eq 1>
                                        <td style="text-align:right" colspan="3" >Tablo Toplamı</td>
                                        <td style="text-align:right" >#TLFormat((t_puchase_tut_maliyet-it_puchase_tut_maliyet),2)#</td>
                                    <cfelse>      
                                        <td style="text-align:right">#TLFormat(((t_kal_tutar-it_kal_tutar)-(t_tut_maliyet-it_tut_maliyet)),2)#</td>
                                        <td style="text-align:center">#TLFormat((((t_kal_tutar-it_kal_tutar)-(t_tut_maliyet-it_tut_maliyet))/(t_tut_maliyet-it_tut_maliyet))*100,2)#</td>
                                    </cfif>
                                    <cfif attributes.dsp_source eq 1>
                                        <td style="text-align:right" colspan="6" ></td>
                                    </cfif></cfoutput>
                                </tr>
                            </cfif>
                        </cfif>
                    </tfoot>
                </cfif>
            <cfelse>
                <tr height="20" >
                    <td align="left" colspan="24">Listelenecek Kayıt Bulunamadı</td>
                </tr>
            </cfif>
        <cfelse>
            <tr height="20">
                <td align="left" colspan="24">Filtre Ediniz</td>
            </tr>
        </cfif> 	       
    </table>
</cf_basket_form>
<cfif isdefined("attributes.form_is_submitted") AND len(attributes.form_is_submitted)>
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
        <table width="98%" border="0" cellpadding="0" cellspacing="0" height="35" style="text-align:center">
          <tr>
            <td>
              <cf_pages page="#attributes.page#"
                     maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                   startrow="#attributes.startrow#"
                      adres="account.list_ezgi_cost_of_product_sold&#url_str#">
            </td>
            <!-- sil -->
            <td style="text-align:right" style="text-align:right;"><cfoutput><cf_get_lang_main no='128.Toplam Kayıt'>:#attributes.totalrecords# - <cf_get_lang_main no='169.Sayfa'>:#attributes.page#/#lastpage#</cfoutput></td>
          <!-- sil -->
          </tr>
        </table>
    </cfif>
</cfif>
<script type="text/javascript">
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
