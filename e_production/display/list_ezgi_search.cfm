<!---
    File: list_ezgi_search.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cf_get_lang_set module_name="prod">
<cfsetting showdebugoutput="yes">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.is_form_submitted" default="">
<cfif len(attributes.is_form_submitted)>
	<cfquery name="get_prod_order" datasource="#dsn3#">
    	WITH CTE_MASTER_ALT_PLAN AS 
        (
            SELECT 
                MASTER_ALT_PLAN_ID,
                MASTER_ALT_PLAN_NO,
                MASTER_PLAN_ID,
                PROCESS_ID
            FROM 
                EZGI_MASTER_ALT_PLAN WITH (NOLOCK)
        ),
        CTE_COMPANY_CONSUMER_EMPLOYEE AS 
        (
            SELECT 
                COMPANY_ID,
                NULL AS CONSUMER_ID,
                NULL AS EMPLOYEE_ID,
                NICKNAME AS UNVAN
            FROM #dsn_alias#.COMPANY WITH (NOLOCK)
            UNION ALL
            SELECT 
                NULL AS COMPANY_ID,
                CONSUMER_ID,
                NULL AS EMPLOYEE_ID,
                CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS UNVAN
            FROM #dsn_alias#.CONSUMER WITH (NOLOCK)
            UNION ALL
            SELECT 
                NULL AS COMPANY_ID,
                NULL AS CONSUMER_ID,
                EMPLOYEE_ID,
                EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS UNVAN
            FROM #dsn_alias#.EMPLOYEES WITH (NOLOCK)
        ),
        CTE_PARENT_PRODUCT AS 
        (
            SELECT 
                PO1.P_ORDER_ID,
                S1.PRODUCT_NAME AS UST_EMIR
            FROM 
                PRODUCTION_ORDERS AS PO1 WITH (NOLOCK)
            INNER JOIN 
                STOCKS AS S1 ON PO1.STOCK_ID = S1.STOCK_ID
        )
        SELECT 
            PO.P_ORDER_ID, 
            S.PRODUCT_CODE, 
            S.PRODUCT_NAME, 
            S.STOCK_ID, 
            S.PRODUCT_ID, 
            PO.STATION_ID, 
            PO.START_DATE, 
            PO.FINISH_DATE,
            ISNULL(PO.PRINT_COUNT, 0) AS PRINT_COUNT, 
            PO.QUANTITY, 
            PO.STATUS, 
            PO.P_ORDER_NO, 
            PO.PO_RELATED_ID, 
            PO.ORDER_ROW_ID, 
            PO.SPECT_VAR_NAME,
            PO.SPECT_VAR_ID, 
            PO.PROD_ORDER_STAGE, 
            PO.IS_STOCK_RESERVED, 
            PO.SPEC_MAIN_ID, 
            PO.PRODUCTION_LEVEL, 
            ISNULL(PO.IS_GROUP_LOT, 0) AS IS_GROUP_LOT, 
            PO.IS_STAGE, 
            PO.DETAIL,
            W.STATION_NAME, 
            W.BRANCH,
            PTR.STAGE,
            ISNULL(PTIP.PROPERTY2, 0) AS PRODUCT_POINT,
            ISNULL(PTIP.PROPERTY2, 0) * PO.QUANTITY AS P_ORDER_POINT,
            CTE_PARENT_PRODUCT.UST_EMIR,
            PO.LOT_NO,
            O.ORDER_ID, 
            O.ORDER_NUMBER, 
            O.ORDER_DATE, 
            O.ORDER_STATUS, 
            O.DELIVERDATE,
            O.IS_INSTALMENT,
            ISNULL(CCE.UNVAN, 'Stok Üretim') AS UNVAN,
            MAP.MASTER_ALT_PLAN_NO,
            MAP.MASTER_PLAN_ID,
            MAP.PROCESS_ID,
            EMPR.MASTER_ALT_PLAN_ID
        FROM 
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN 
            STOCKS AS S WITH (NOLOCK) ON PO.STOCK_ID = S.STOCK_ID INNER JOIN 
            WORKSTATIONS AS W WITH (NOLOCK) ON PO.STATION_ID = W.STATION_ID INNER JOIN 
            #dsn_alias#.PROCESS_TYPE_ROWS AS PTR WITH (NOLOCK) ON PO.PROD_ORDER_STAGE = PTR.PROCESS_ROW_ID INNER JOIN 
            EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) ON PO.P_ORDER_ID = EMPR.P_ORDER_ID LEFT JOIN 
            ORDERS AS O WITH (NOLOCK) ON PO.ORDER_ROW_ID = O.ORDER_ID LEFT JOIN 
            CTE_MASTER_ALT_PLAN AS MAP ON EMPR.MASTER_ALT_PLAN_ID = MAP.MASTER_ALT_PLAN_ID LEFT JOIN 
            PRODUCT_TREE_INFO_PLUS AS PTIP WITH (NOLOCK) ON S.STOCK_ID = PTIP.STOCK_ID LEFT JOIN 
            CTE_PARENT_PRODUCT ON PO.PO_RELATED_ID = CTE_PARENT_PRODUCT.P_ORDER_ID LEFT JOIN 
            CTE_COMPANY_CONSUMER_EMPLOYEE AS CCE ON (O.COMPANY_ID = CCE.COMPANY_ID OR O.CONSUMER_ID = CCE.CONSUMER_ID OR O.EMPLOYEE_ID = CCE.EMPLOYEE_ID)
		WHERE     	
       		PO.LOT_NO LIKE '%#attributes.keyword#%' OR
            PO.P_ORDER_NO LIKE '%#attributes.keyword#%'
		ORDER BY 	
    		DELIVERDATE
	</cfquery>
    <cfset control_list=Valuelist(get_prod_order.P_ORDER_ID)>
    <cfquery name="order_group_control" dbtype="query">
        SELECT SPEC_MAIN_ID FROM GET_PROD_ORDER WHERE IS_STAGE <> 1 AND IS_STAGE <> 2 GROUP BY SPEC_MAIN_ID HAVING (COUNT(*) > 1)
    </cfquery>
    <cfquery name="order_related_control" dbtype="query">
        SELECT SPEC_MAIN_ID FROM GET_PROD_ORDER WHERE PO_RELATED_ID IS NOT NULL
    </cfquery>
    <cfquery name="p_order_is_group_control" dbtype="query">
        SELECT P_ORDER_ID FROM GET_PROD_ORDER WHERE IS_GROUP_LOT = 0 AND IS_STAGE <> 1 AND IS_STAGE <> 2
    </cfquery>
    <cfquery name="get_row_say" dbtype="query">
        SELECT LOT_NO, COUNT(*) AS ROWSAY FROM GET_PROD_ORDER GROUP BY LOT_NO
    </cfquery>
<cfelse>
	<cfset arama_yapilmali=1>
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search_product" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
			<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <cf_box_search>
                <div class="form-group">
                	<cfsavecontent variable="message_1"><cf_get_lang dictionary_id='44561.Lütfen Filtre Giriniz'></cfsavecontent>
                    <cfsavecontent variable="filter"><cf_get_lang dictionary_id='45498.Lot No'> <cf_get_lang dictionary_id='29474.Emir No'></cfsavecontent>
              		<cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#" required="yes" message="#message_1#">
              	</div>
           		<div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
          	</cf_box_search>
    	</cfform>
  	</cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='649.Üretim Emirleri'></cfsavecontent>
    <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
      	<cf_grid_list>
            <thead>
                <tr>
                    <th width="35"></th>
                    <th width="70"><cf_get_lang dictionary_id='1019.Alt Plan No'> </th>
                    <th width="60"><cf_get_lang dictionary_id='29474.Emir No'></th>
                    <th width="60"><cf_get_lang dictionary_id='58211.Sipariş No'></th>
                    <th width="60"><cf_get_lang dictionary_id='29501.Sipariş Tarihi'></th>
                    <th width="60"><cf_get_lang dictionary_id='209.Termin Tarihi'></th>
                    <th width="60"><cf_get_lang dictionary_id='45498.Lot No'></th>
                    <th><cf_get_lang dictionary_id='1035.Cari Ünvan'></th>
                    <th><cf_get_lang dictionary_id='57657.Ürün'></th>
                    <th width="90">Spec</th>
                    <th width="60"><cf_get_lang dictionary_id='58859.Süreç'></th>
                    <th><cf_get_lang dictionary_id='36604.Hedef Başlangıç'><br /><cf_get_lang dictionary_id='36606.Hedef Bitiş'></th>
                    <th width="50"><cf_get_lang dictionary_id='57635.Miktar'></th>
                    <th width="20"></th>
                    <th width="20"></th>
                </tr>
            </thead>
            <tbody>
                <cfif len(attributes.is_form_submitted)>
                    <cfif get_prod_order.recordcount>
                        <cfset i=1>
                        <cfoutput query="get_prod_order">
                            <tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
                                <td>#currentrow#</td>
                                <td align="center"><a href="#request.self#?fuseaction=prod.upd_ezgi_master_sub_plan_manual&master_plan_id=#master_plan_id#&master_alt_plan_id=#master_alt_plan_id#&islem_id=#PROCESS_ID#" class="tableyazi">#MASTER_ALT_PLAN_NO#</a></td>
                                <td align="center"><a href="#request.self#?fuseaction=prod.order&event=upd&upd=#P_ORDER_ID#" class="tableyazi" target="_blank">#P_ORDER_NO#</a></td>
                                <cfif is_instalment eq 1>
                                    <cfset page_type = 'upd_fast_sale'>
                                <cfelse>
                                    <cfset page_type = 'detail_order'>
                                </cfif>
                                <td align="center">
                                    <cfset fuse_type = 'sales'>
                                    <cfif get_prod_order.is_instalment eq 1>
                                        <cfset page_type = 'list_order_instalment&event=upd'>
                                    <cfelse>
                                        <cfset page_type = 'list_order&event=upd'>
                                    </cfif>
                                    <cfif len(get_prod_order.order_id)>
                                        <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=#fuse_type#.#page_type#&order_id=#get_prod_order.order_id#','longpage');" class="tableyazi" title="Satış Siparişine Git">
                                            #ORDER_NUMBER#
                                        </a>
                                    <cfelse>
                                    
                                    </cfif>
                                </td>
                                <td align="center">#DateFormat(ORDER_DATE,dateformat_style)#</td>
                                <td align="center">#DateFormat(DELIVERDATE,dateformat_style)#</td>
                                <td align="center">#LOT_NO#</td>
                                <td align="center">#unvan#</td>
                                <td><a href="#request.self#?fuseaction=prod.list_product_tree&event=upd&stock_id=#stock_id#" class="tableyazi">#product_name#</a></td>
                                <td align="left">
                                <cfif len(SPECT_VAR_ID)>
                                    <a  href="javascript://" onClick="windowopen('#request.self#?fuseaction=objects.popup_upd_spect&id=#SPECT_VAR_ID#&stock_id=#stock_id#','list');" class="tableyazi">#spec_main_id#-#spect_var_id#</a>	
                                </cfif>
                                </td>
                                <td align="center">#STAGE#</td>
                                <td align="center" nowrap>#DateFormat(start_date,dateformat_style)#<br />#DateFormat(finish_date,dateformat_style)#</td>
                                <td style="text-align:right">#TlFormat(QUANTITY,2)#</td>
                              	<td align="center">
                                                <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_iflow_production_order_result&p_order_id=#get_prod_order.p_order_id#','small');"><img src="/images/plus_list.gif" title="<cf_get_lang dictionary_id='57582.Ekle'>"></a>
                                            </td>
                                            <td align="center">
                                                <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=objects.popup_print_files&print_type=281&iid=#get_prod_order.P_ORDER_ID#&master_alt_plan_id=#get_prod_order.MASTER_ALT_PLAN_ID#','wide');">
                                                <cfif IS_STAGE eq 4>
                                                    <cfif IS_GROUP_LOT eq 1>
                                                         <img src="/images/g_blue_glob.gif" title="<cf_get_lang dictionary_id ='36892.Gruplandı Fakat Operatöre Gönderilmedi'>">
                                                    <cfelse>
                                                         <img src="/images/blue_glob.gif" title="<cf_get_lang dictionary_id ='476.Başlamadı'>">
                                                    </cfif>       
                                                <cfelseif IS_STAGE eq 0>
                                                    <img src="/images/yellow_glob.gif" title="<cf_get_lang dictionary_id ='36891.Operatöre Gönderildi'>">
                                                <cfelseif IS_STAGE eq 1>
                                                    <img src="/images/green_glob.gif" title="<cf_get_lang dictionary_id ='398.Başladı'>">
                                                <cfelseif IS_STAGE eq 2>
                                                    <img src="/images/red_glob.gif" title="<cf_get_lang dictionary_id ='305.Bitti'>">
                                                <cfelseif IS_STAGE eq 3>
                                                    <img src="/images/grey_glob.gif" title="<cf_get_lang dictionary_id ='476.Başlamadı'>">
                                                </cfif>
                                                </a>
                                            </td>
                                        </tr>
                                    </cfoutput>
                                <cfelse>
                                    <tr>
                                        <td class="color-row" colspan="15"><cf_get_lang dictionary_id='524.Emir Bulunamadı'> !</td>
                                    </tr>
                                </cfif>
                <cfelse>
                    <tr> 
                        <td colspan="15" height="20"><cf_get_lang dictionary_id='525.Lütfen Lot No Giriniz'> !</td>
                    </tr>
                </cfif>
            </tbody>
   		</cf_grid_list>
  	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;	
	}
</script>