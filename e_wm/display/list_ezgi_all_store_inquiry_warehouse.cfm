<!---
    File: list_ezgi_all_store_inquiry_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\display
    Author: Ezgi Yazılım
    Date: 01/06/2024
    Description: Depo Sorgulama
---> 
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.order_no" default="">
<cfparam name="attributes.department_id" default="">
<cfparam name="attributes.place_cat_id" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.consumer_id" default="">
<cfquery name="get_shelf_cat" datasource="#dsn3#">
	SELECT  EZGI_PLACE_CAT_ID AS CAT_ID, EZGI_PLACE_CAT AS CAT FROM EZGI_WM_SETUP_PLACE_CAT
</cfquery>
<cfquery name="GET_DEPARTMENT" datasource="#DSN#">
	SELECT
		DEPARTMENT_ID,
		DEPARTMENT_HEAD
	FROM
		BRANCH B,
		DEPARTMENT D 
	WHERE
		B.COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		B.BRANCH_ID = D.BRANCH_ID AND
		D.IS_STORE <> 2
		AND D.DEPARTMENT_STATUS = 1 
	ORDER BY
		DEPARTMENT_HEAD
</cfquery>
<cfset branch_dep_list=valuelist(get_department.department_id,',')>
<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT * FROM STOCKS_LOCATION WHERE STATUS = 1
</cfquery>
<cfif isdefined('attributes.is_submitted')>
	<cfquery name="get_serial" datasource="#dsn3#">
    	SELECT 
        	CASE
            	WHEN 
                	ESOS.SHIP_RESULT_TYPE = 1
                THEN
                	(SELECT DELIVER_PAPER_NO FROM EZGI_SHIP_RESULT WHERE SHIP_RESULT_ID = ESOS.SHIP_RESULT_ID)
             	WHEN 
                	ESOS.SHIP_RESULT_TYPE = 2
                THEN
                	(SELECT CAST(SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) AS DELIVER_PAPER_NO FROM EZGI_SHIP_RESULT_INTERNALDEMAND WHERE SHIP_RESULT_INTERNALDEMAND_ID = ESOS.SHIP_RESULT_ID)
           	END AS DELIVER_PAPER_NO,
         	O.ORDER_NUMBER, 
            ORR.ORDER_ROW_ID,
            ESOS.SERIAL_NO, 
            ESOS.PRODUCT_NAME, 
            ESOS.PALET_BARCODE, 
            ESOS.SHELF_CODE, 
            ESOS.DEPO, 
            (SELECT DEPO_NAME FROM EZGI_WM_DEPARTMENTS WITH (NOLOCK) WHERE DEPO = ESOS.DEPO) as DEPO_NAME,
            ESOS.STOCK_ID, 
            S.BARCOD, 
            ESOS.SPECT_ID, 
            S.IS_PROTOTYPE ,
            S.PRODUCT_CODE,
            ESOS.PRODUCT_PLACE_ID
		FROM     
       		EZGI_WM_SERIAL_NO_LAST_STATUS AS ESOS WITH (NOLOCK) INNER JOIN
            STOCKS AS S WITH (NOLOCK) ON ESOS.STOCK_ID = S.STOCK_ID INNER JOIN
            EZGI_WM_IS_SERIAL_NO_LIVE AS EVL ON EVL.SERIAL_NO = ESOS.SERIAL_NO INNER JOIN
            (
            	SELECT 
                	EWM.SERIAL_NO, 
                    EWM.ORDER_ROW_ID AS RESERVE_ORDER_ROW_ID
				FROM     
                	EZGI_WM_ORDER_LAST_STATUS AS EWM WITH (NOLOCK) INNER JOIN
                  	EZGI_WM_IS_SERIAL_NO_LIVE AS EVL WITH (NOLOCK) ON EWM.SERIAL_NO = EVL.SERIAL_NO
				
           	) AS TBL ON ESOS.SERIAL_NO = TBL.SERIAL_NO LEFT OUTER JOIN
       		ORDERS AS O WITH (NOLOCK) INNER JOIN
        	ORDER_ROW AS ORR WITH (NOLOCK) ON O.ORDER_ID = ORR.ORDER_ID ON TBL.RESERVE_ORDER_ROW_ID = ORR.ORDER_ROW_ID
		WHERE  
        	1= 1
            <cfif len(attributes.keyword)>
                AND (
                        S.BARCOD LIKE '%#attributes.keyword#%' OR
                        S.PRODUCT_NAME LIKE '%#attributes.keyword#%' OR
                        S.PRODUCT_CODE LIKE '%#attributes.keyword#%' OR
                        ESOS.SERIAL_NO LIKE '%#attributes.keyword#%' OR
                        ESOS.SHELF_CODE LIKE '%#attributes.keyword#%' OR
                        ESOS.PALET_BARCODE LIKE '%#attributes.keyword#%'
                    )
            </cfif>
            <cfif len(attributes.order_no)>
            	AND O.ORDER_NUMBER LIKE '%#attributes.order_no#%'
            </cfif>
            <cfif len(attributes.department_id)>
            	AND ESOS.DEPO = '#attributes.department_id#'
            </cfif>
            <cfif len(attributes.place_cat_id)>
            	AND ESOS.PRODUCT_PLACE_ID IN (SELECT PRODUCT_PLACE_ID FROM EZGI_PRODUCT_PLACE WHERE PLACE_CAT_ID = #attributes.place_cat_id#)
            </cfif>
            <cfif isdefined('attributes.member_name') and len(attributes.member_name)>
				<cfif isdefined('attributes.company_id') and len(attributes.company_id)>
                 	AND O.COMPANY_ID =#attributes.company_id#
           		</cfif>
            	<cfif isdefined('attributes.consumer_id') and len(attributes.consumer_id)>
               		AND O.CONSUMER_ID =#attributes.consumer_id# 
         		</cfif>
      		</cfif>
     	ORDER BY
        	S.PRODUCT_NAME,
         	ESOS.SERIAL_NO
    </cfquery>
<cfelse>
	<cfset get_serial.recordcount =0>
</cfif> 
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
      	<cfform name="list_ezgi_all_store_inquiry_warehouse" id="list_ezgi_all_store_inquiry_warehouse" action="#request.self#?fuseaction=stock.list_ezgi_all_store_inquiry_warehouse" method="post">
        	<input name="is_submitted" type="hidden" value="1">	
            <cf_basket_form id="add_ezgi_package_transfer">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
                         	<cf_box_search>
                            	<div class="form-group" id="item-barcod">
                                 	<input id="keyword" name="keyword" type="text" placeholder="<cf_get_lang dictionary_id='62273.Filtre'>" value="<cfoutput>#attributes.keyword#</cfoutput>">
                               	</div>
                                <div class="form-group" id="item-barcod">
                                 	<input id="order_no" name="order_no" type="text" placeholder="<cf_get_lang dictionary_id='58211.Sipariş No'>" value="<cfoutput>#attributes.order_no#</cfoutput>">
                               	</div>
                              	
                                <div class="form-group" id="item-store">
                                    <select name="department_id" id="department_id">
                                        <option value=""<cfif attributes.department_id eq ''> selected</cfif>><cf_get_lang dictionary_id="57734.Seçiniz"></option>
                                        <cfoutput query="get_department">
                                            <optgroup label="#department_head#">
                                                <cfquery name="GET_LOCATION" dbtype="query">
                                                    SELECT * FROM GET_ALL_LOCATION WHERE DEPARTMENT_ID = #get_department.department_id[currentrow]#
                                                </cfquery>
                                                <cfif get_location.recordcount>
                                                    <cfloop from="1" to="#get_location.recordcount#" index="s">
                                                        <option value="#department_id#-#get_location.location_id[s]#" <cfif listfind(attributes.department_id,'#department_id#-#get_location.location_id[s]#',',')>selected</cfif>>&nbsp;&nbsp;#get_location.comment[s]#</option>
                                                    </cfloop>
                                                </cfif>
                                            </optgroup>					  
                                        </cfoutput>
                                    </select>
                                </div>
                                <div class="form-group" id="item-cat">
                                    <select name="place_cat_id" id="place_cat_id">
                                        <option value="" <cfif attributes.place_cat_id eq ''> selected</cfif>><cf_get_lang_main no='322.Seçiniz'></option>
                                        <cfoutput query="get_shelf_cat">
                                            <option value="#CAT_ID#" <cfif attributes.place_cat_id eq get_shelf_cat.CAT_ID>selected</cfif>>#CAT#</option>
                                        </cfoutput>
                                    </select>
                                </div>
                                <div class="form-group" id="form_ul_cari">
                                    <div class="input-group">
                                        <input type="hidden" name="consumer_id" id="consumer_id" value="<cfif isdefined("attributes.consumer_id")><cfoutput>#attributes.consumer_id#</cfoutput></cfif>">
                                        <input type="hidden" name="company_id" id="company_id" value="<cfif isdefined("attributes.company_id")><cfoutput>#attributes.company_id#</cfoutput></cfif>">
                                        <input type="hidden" name="member_type" id="member_type" value="<cfif isdefined("attributes.member_type")><cfoutput>#attributes.member_type#</cfoutput></cfif>">
                                        <input name="member_name" type="text" id="member_name" style="width:115px;" onfocus="AutoComplete_Create('member_name','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','MEMBER_NAME,MEMBER_PARTNER_NAME,MEMBER_CODE','get_member_autocomplete','\'1,2\'','CONSUMER_ID,COMPANY_ID,MEMBER_TYPE','consumer_id,company_id,member_type','','3','250');" value="<cfif isdefined("attributes.member_name") and len(attributes.member_name)><cfoutput>#attributes.member_name#</cfoutput></cfif>" autocomplete="off" placeholder="<cf_get_lang dictionary_id='57519.Cari Hesap'>">
                                        <cfset str_linke_ait="&field_consumer=list_ezgi_all_store_inquiry_warehouse.consumer_id&field_comp_id=list_ezgi_all_store_inquiry_warehouse.company_id&field_member_name=list_ezgi_all_store_inquiry_warehouse.member_name&field_type=list_ezgi_all_store_inquiry_warehouse.member_type">
                                        <span class="input-group-addon icon-ellipsis" onclick="windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_all_pars<cfoutput>#str_linke_ait#<cfif fusebox.circuit eq "store">&is_store_module=1</cfif></cfoutput>&select_list=7,8&keyword='+encodeURIComponent(document.list_ezgi_all_store_inquiry_warehouse.member_name.value),'list');"></span>
                                    </div>      
                                </div>
                                <div class="form-group">
                                 	<cf_wrk_search_button search_function='input_control()' button_type="4">
                             	</div>
               				</cf_box_search>
                       	</div>
                  	</div>
              	</div>
    		</cf_basket_form>
        	<cfsavecontent variable="title">Depo Sorgula</cfsavecontent>
    		<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
            	<cf_grid_list>
                   	<thead>
                       	<tr>
                        	<th><cf_get_lang dictionary_id="58577.Sıra"></th>
                            <th><cf_get_lang dictionary_id="58800.Ürün Kodu"></th>
                            <th><cf_get_lang dictionary_id="58221.Ürün Adı"></th>
                            <th><cf_get_lang dictionary_id="58763.Depo"></th>
                            <th><cf_get_lang dictionary_id="45254.Raf No"></th>
                            <th><cf_get_lang dictionary_id="37244.Palet"></th>
                            <th><cf_get_lang dictionary_id="57637.Seri No"></th>
                            <th><cf_get_lang dictionary_id="58211.Sipariş No"></th>
                            <th><cf_get_lang dictionary_id="759.Sevk Belgeleri"></th>
                     	</tr>
                 	</thead>
                 	<tbody name="table1" id="table1">
                    	<cfif get_serial.recordcount>
							<cfoutput query="get_serial">
                            	<cfquery name="GET_DURUM" datasource="#dsn3#">
                                	SELECT 
                                    	PROCESS_NO, 
                                        PROCESS_CAT, 
                                        PURCHASE_START_DATE
									FROM     
                                    	SERVICE_GUARANTY_NEW
									WHERE  
                                    	SERIAL_NO = N'#SERIAL_NO#' AND 
                                        IN_OUT = 1
                                </cfquery>
                                <cfif GET_DURUM.recordcount>
                                	<cfif GET_DURUM.PROCESS_CAT eq 171>
                                    	<cfset belge = 'Üretim Sonucu'>
                                    <cfelseif GET_DURUM.PROCESS_CAT eq 115>
                                		<cfset belge = 'Sayım Sonucu'>
                                	<cfelseif GET_DURUM.PROCESS_CAT eq 76>
                                    	<cfset belge = 'Mal Alım İrsaliyesi'>
                                  	<cfelse>
                                    	<cfset belge = 'Tanımlanmayan Belge - #GET_DURUM.PROCESS_CAT#'>
                                    </cfif>
                                <cfelse>
                                	<cfset belge = ''>
                                </cfif>
                              	<tr title="#belge# - #DateFormat(GET_DURUM.PURCHASE_START_DATE,dateformat_style)# - #GET_DURUM.PROCESS_NO# ">
                                	<input type="hidden" name="row_control_#currentrow#" id="row_control_#currentrow#" value="0">
                                 	<td style="text-align:center; <cfif GET_DURUM.PROCESS_CAT eq 115>color:red;</cfif>">#currentrow#</td>
                                    <td style="text-align:center">#PRODUCT_CODE#</td>
                                    <td style="text-align:left">#PRODUCT_NAME#</td>
                                    <td style="text-align:center">#DEPO_NAME#</td>
                                    <td style="text-align:center">#SHELF_CODE#</td>
                                	<td style="text-align:center">#PALET_BARCODE#</td>
                                  	<td style="text-align:center">#SERIAL_NO#</td>
                                    <td style="text-align:center">#ORDER_NUMBER#</td>
                                    <td style="text-align:center">#DELIVER_PAPER_NO#</td>
                              	</tr>
                            </cfoutput>
                        </cfif>
                    </tbody>
           		</cf_grid_list>
          	</cf_box>
      	</cfform>
   	</cf_box>
</div>
<script language="javascript" type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		if(document.getElementById('keyword').value !='' || document.getElementById('order_no').value !='' || document.getElementById('department_id').value !='')
			return true;
		else
		{
			alert('Filtreye Değer Girmelisiniz!!!')
			return false;
		}
	}
</script>