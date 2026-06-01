<cf_xml_page_edit>
<cfset ozel_alan = ''>
<!---<cfquery name="get_virtula_offer" datasource="#dsn3#">
	SELECT PRODUCT_NAME, STOCK_ID, UNIT, QUANTITY FROM EZGI_VIRTUAL_OFFER_ROW WHERE EZGI_ID = #attributes.ezgi_id#
</cfquery>--->
<!---Özel Alan--->
<cfquery name="get_virtula_offer" datasource="#dsn3#">
	SELECT 
    	PRODUCT_NAME, 
        STOCK_ID, 
        UNIT, 
        QUANTITY,
        (SELECT PROPERTY1 FROM PRODUCT_INFO_PLUS WHERE PRO_INFO_ID = 6 AND PRODUCT_ID = E.PRODUCT_ID) AS OZEL_INFO
  	FROM 
    	EZGI_VIRTUAL_OFFER_ROW E
   	WHERE 
    	EZGI_ID = #attributes.ezgi_id#
</cfquery>
<cfif ListLen(get_virtula_offer.OZEL_INFO,';')>
	<cfset ozel_alan = '#get_virtula_offer.OZEL_INFO#'>
</cfif>
<!---Özel Alan--->
<cfquery name="get_row_floor" datasource="#dsn3#">
	SELECT EZGI_ID, TIP,KONUM,DAIRE,MEKAN, ISNULL(IS_PRINT,0) AS IS_PRINT FROM EZGI_VIRTUAL_OFFER_ROW_FLOOR WHERE EZGI_ID = #attributes.ezgi_id# ORDER BY EZGI_VIRTUAL_OFFER_ROW_FLOOR_ID
</cfquery>
<cfoutput query="get_row_floor">
	<cfset 'TIP_#currentrow#'= TIP>
	<cfset 'KONUM_#currentrow#'= KONUM>
    <cfset 'DAIRE_#currentrow#'= DAIRE>
    <cfset 'MEKAN_#currentrow#'= MEKAN>
    <cfset 'IS_PRINT_#currentrow#'= IS_PRINT>
</cfoutput>
<br />
<cfif x_row_control eq 1>
	<cfset satir_sayisi = get_virtula_offer.QUANTITY>
<cfelse>
	<cfset satir_sayisi = 1>
</cfif>
<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id="43355.Konumlar"></cfsavecontent>
<cfsavecontent variable="right_images_">
	<a href="<cfoutput>#request.self#?fuseaction=prod.popup_add_ezgi_virtual_offer_row_file_import_locations&ezgi_id=#attributes.ezgi_id#</cfoutput>">
    	<img src="images/save.gif" border="0" />
 	</a>
</cfsavecontent>
<cfform name="upd_floor" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_virtual_offer_row_floor_info">
<cfinput type="hidden" name="ezgi_id" value="#attributes.ezgi_id#">
<cfinput type="hidden" name="record_num" value="#satir_sayisi#">
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#ezgi_header#" right_images="#right_images_#">
    	<cf_basket id="upd_default_measure_bask">
          	<cf_grid_list sort="0">
              	<thead>
               		<tr height="20px">
                    	<cfif ListFind(x_field_control,1)>
                    		<th style="text-align:center; width:30px" ><cf_get_lang_main no='1165.Sıra'></th>
                        </cfif>
                        <cfif ListFind(x_field_control,2)>
                       		<th style="text-align:center; width:50px" ><cf_get_lang dictionary_id="1326.Tipler"></th>
                        </cfif>
                        <cfif ListFind(x_field_control,3)>
                    		<th style="text-align:center; width:100%" ><cf_get_lang dictionary_id="1323.Ana Konumlar"></th>
                        </cfif>
                        <cfif ListFind(x_field_control,4)>
                      		<th style="text-align:center; width:150px" ><cf_get_lang dictionary_id="1324.Daireler"></th>
                        </cfif>
                        <cfif ListFind(x_field_control,5)>
                     		<th style="text-align:center; width:150px" ><cf_get_lang dictionary_id="1325.Mekanlar"></th>
                        </cfif>
                        <cfif ListFind(x_field_control,6)>
                     		<th style="text-align:center; width:30x" ><cf_get_lang dictionary_id="1327.Tercihler"></th>
                        </cfif>
                  	</tr>
               	</thead>
              	<tbody name="new_row" id="new_row">
               		<cfif satir_sayisi gt 0>
                    	<cfloop from="1" to="#satir_sayisi#" index="i">
                         	<cfoutput>
                            	<tr name="frm_row" id="frm_row#i#">
                                	<cfif ListFind(x_field_control,1)>
                                		<td style="text-align:center; width:30px; cursor:pointer" onclick="kopyala(#i#)">#i#</td>
                                    </cfif>
                                    <cfif ListFind(x_field_control,2)>
                                 		<td><input type="text" name="tip_#i#" id="tip_#i#" value="<cfif isdefined('TIP_#i#')>#Evaluate('TIP_#i#')#</cfif>" maxlength="5" style="width:50px; text-align:center"></td>
                                    </cfif>
                                    <cfif ListFind(x_field_control,3)>
                                 		<td><input type="text" name="konum_#i#" id="konum_#i#" value="<cfif isdefined('KONUM_#i#')>#Evaluate('KONUM_#i#')#<cfelse>#ozel_alan#</cfif>" maxlength="50" style="width:100%;"></td>
                                    </cfif>
                                    <cfif ListFind(x_field_control,4)>
                                  		<td><input type="text" name="daire_#i#" id="daire_#i#" value="<cfif isdefined('DAIRE_#i#')>#Evaluate('DAIRE_#i#')#</cfif>" maxlength="20" style="width:150px; text-align:center"></td>
                                    </cfif>
                                    <cfif ListFind(x_field_control,5)>
                                  		<td><input type="text" name="mekan_#i#" id="mekan_#i#" value="<cfif isdefined('MEKAN_#i#')>#Evaluate('MEKAN_#i#')#</cfif>" maxlength="250" style="width:150px;"></td>
                                  	</cfif>
                                    <cfif ListFind(x_field_control,6)>
                                    	<td style="text-align:center"><input type="checkbox" name="is_print_#i#" id="is_print_#i#" <cfif isdefined('IS_PRINT_#i#') and Evaluate('IS_PRINT_#i#') eq 1>checked</cfif>></td>
                                    </cfif>
                             	</tr>
                          	</cfoutput>
                     	</cfloop>
               		<cfelse>
                     	<tr id="tr_son">
                        	<td colspan="<cfoutput>#ListLen(x_field_control)#</cfoutput>">&nbsp; <cf_get_lang_main no='72.Kayıt Yok'></td>
                     	</tr>
                 	</cfif>
               	</tbody>
              	<tfoot>
                	<tr>
                    	<td colspan="<cfoutput>#ListLen(x_field_control)#</cfoutput>"> 	
                        	<cfif isdefined('attributes.kilit') and attributes.kilit eq 0>
                          	<cf_workcube_buttons 
                                        is_upd='1' 
                                        is_delete = '0' 
                                        add_function='kontrol()'>
                          	</cfif>
                    	</td>
                 	</tr>
           		</tfoot>
          	</cf_grid_list>
      	</cf_basket>
   	</cf_box>
</div>
</cfform>
<script type="text/javascript">
	function kontrol()
	{	
		<cfif ListFind(x_field_control,2)>
		dongu = <cfoutput>#satir_sayisi#</cfoutput>;
		for (var r=1;r<=dongu;r++)
		{
			if(document.getElementById('tip_'+r).value == "")
			{
				alert("<cf_get_lang_main no='782.Girilmesi Zorunlu Alan'> <cf_get_lang_main no='218.Tip'> !");
				document.getElementById('tip_'+r).focus();
				return false;
			}
		}
		</cfif>
		return true;
	}
	function kopyala(row)
	{
		if(row>1)
		{
			row_=row-1;
			document.getElementById('tip_'+row).value=document.getElementById('tip_'+row_).value;
			document.getElementById('konum_'+row).value=document.getElementById('konum_'+row_).value;
			document.getElementById('daire_'+row).value=document.getElementById('daire_'+row_).value;
			document.getElementById('mekan_'+row).value=document.getElementById('mekan_'+row_).value;
		}
	}
</script>