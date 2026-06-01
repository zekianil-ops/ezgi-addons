<!---
    File: list_ezgi_product_ws_ajaxproduct.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfsetting showdebugoutput="no">
<cfinclude template="../../../../v16/production_plan/query/get_product_ws_detail.cfm">
<cfset div_uzunluk = get_pro.recordcount*22>
<cfif div_uzunluk gte 88><cfset div_uzunluk = 88><cfelse><cfset div_uzunluk=0></cfif>
<cf_ajax_list>
<tbody>
	<cfif get_pro.recordcount>
		<cfoutput query="GET_PRO" startrow="1" maxrows="20">
			<tr id="deltree#WS_P_ID#">
				<cfif isdefined('attributes.upd')><!--- İstasyton detayından geliyorsa  --->
					<cfset _headers_ = 'PRODUCT_NAME'>
					<td title="#PRODUCT_NAME#">
						<cfif type eq 0>
							<a class="tableyazi" target="_blank" href="#request.self#?fuseaction=prod.list_product_tree&event=upd&stock_id=#STOCK_ID#"> #left(PRODUCT_NAME,20)# </a>
						<cfelse>
							<a class="tableyazi" target="_blank" href="#request.self#?fuseaction=prod.list_operationtype&event=upd&operation_type_id=#OPERATION_TYPE_ID#"> <font color="FF9966">#left(PRODUCT_NAME,20)#</font></a>
						</cfif>
					</td>        
				<cfelse>
					<cfset _headers_ = 'STATION_NAME'>
					<td title="#STATION_NAME#"><a  class="tableyazi" href="#request.self#?fuseaction=prod.upd_ezgi_workstation&station_id=#WS_ID#"> #left(STATION_NAME,25)# </a><cfif isdefined("attributes.is_show_station_detail") and attributes.is_show_station_detail eq 1>-#COMMENT#</cfif> </td>
				</cfif>
				<td>#CAPACITY# - #MAIN_UNIT#</td>
				<td align="center" width="10%" nowrap="nowrap">
					<div id="_deltree_#WS_P_ID#"></div>
					<a style="cursor:pointer;" onClick="AjaxPageLoad('#request.self#?fuseaction=prod.emptypopup_add_ws_product_process&del_row_id=#WS_P_ID#','_deltree_#WS_P_ID#');gizle(deltree#WS_P_ID#);"><img src="/images/delete_list.gif" border="0"></a>
					<cfif isdefined('attributes.ws_id') and len(attributes.ws_id) or isdefined('attributes.upd')>
						<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_ws_product&ws_id=#WS_ID#&upd=#WS_P_ID#','horizantal');" class="tableyazi"><img src="/images/update_list.gif" border="0"></a>
					<cfelseif isdefined('attributes.operation_type_id')>
						<a href="javascript://" onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_ws_product&operation_type_id=#OPERATION_TYPE_ID#&upd=#WS_P_ID#','horizantal');" class="tableyazi"><img src="/images/update_list.gif" border="0"></a>
					</cfif>
				</td>
			</tr>
		</cfoutput>
		<cfif GET_PRO.recordcount gt 20>
			<cfoutput>
				<tr>
					<td colspan="3">
						<cfif isdefined('attributes.upd')>
							<a onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_ws_product&is_upd_workstation=1&ws_id=#attributes.upd#','horizantal');" style="cursor:pointer;"><cf_get_lang dictionary_id="36496.Tamamı">!</a>
						<cfelseif isdefined('attributes.operation_type_id')>
							<a onClick="windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_ws_product&is_upd_workstation=1&operation_type_id=#attributes.operation_type_id#','horizantal');" style="cursor:pointer;"><cf_get_lang dictionary_id="36496.Tamamı">!</a>                    
						</cfif>
					</td>
				</tr>
			</cfoutput>
		</cfif>
	<cfelse>
		<tr>
			<td colspan="3"><cf_get_lang dictionary_id='58486.Kayıt Bulunamadı'>!</td>
		</tr>
	</cfif>
</tbody>
</cf_ajax_list>
<script type="text/javascript">
	if(document.getElementById('_list_product_ws_') != undefined)
		document.getElementById('_list_product_ws_').style.height = <cfoutput>#div_uzunluk#</cfoutput>;
</script>
