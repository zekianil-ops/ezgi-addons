<!---
    File: upd_ezgi_production_material.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfset module_name="prod">
<cfquery name="get_stock_info" datasource="#dsn3#">
	SELECT        
    	S.PROPERTY, 
        S.PRODUCT_UNIT_ID, 
        S.PRODUCT_CODE, 
        S.PRODUCT_NAME, 
        S.PRODUCT_ID,
        S.STOCK_ID, 
        PU.MAIN_UNIT
	FROM            
    	STOCKS AS S INNER JOIN
      	PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
	WHERE        
    	S.STOCK_ID = #attributes.sid#
</cfquery>
<br />
<cfsavecontent variable="upd_material"><cf_get_lang dictionary_id='582.Malzeme Optimizasyon Güncelle'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#upd_material#">
    	<cfform name="upd_material" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_production_material">
        	<cfinput type="hidden" name="iid" value="#attributes.iid#">
            <cfinput type="hidden" name="sid" value="#attributes.sid#">
            <cfinput type="hidden" name="pid" value="#attributes.pid#">
			<cf_basket_form id="upd_material">
                <div class="row">
                  	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
                          	<cf_box_elements>
                                	<div class="col col-12" type="column" index="1" sort="true">
                                        <div class="form-group" id="item-material_code">
                                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='1069.Ürün Stok Kodu'></label>
                                            <div class="col col-6 col-xs-12">
                                                <cfinput name="product_code" readonly="yes" type="text" style="text-align:left" value="#get_stock_info.PRODUCT_CODE#">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-material_type">
                                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='58221.Ürün Adı'></label>
                                            <div class="col col-6 col-xs-12">
                                                <cfinput type="text" name="product_name" id="product_name" style="text-align:left" value="#get_stock_info.PRODUCT_NAME#">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-material_amount">
                                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='485.Plan İhtiyacı'></label>
                                            <div class="col col-4 col-xs-12">
                                                <cfinput name="plan_demand" readonly="yes" type="text" style="text-align:right" value="#TlFormat(attributes.total,4)#">
                                            </div>
                                            <div class="col col-2 col-xs-12">
                                				<cfinput name="unit" readonly="yes" type="text" style="text-align:left" value="#get_stock_info.MAIN_UNIT#">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-material_file">
                                            <label class="col col-3 col-xs-12"><cf_get_lang dictionary_id='29800.Dosya Adı'></label>
                                            <div class="col col-6 col-xs-12">
                                                <cfinput name="opt_file_name" type="text" style="width:250px; text-align:left" value="">
                                            </div>
                                        </div>
                                  	</div>
                         	</cf_box_elements>
                    		<cf_box_footer>
                             	<cf_workcube_buttons 
                                     	is_upd='1' 
                                        is_cancel='1' 
                                     	is_delete = '0' 
                                     	add_function='kontrol()'>
                			</cf_box_footer>
                		</div>
            		</div>
        		</div>
    		</cf_basket_form>
            <cf_basket id="upd_material_bask">
            	<cf_grid_list sort="0">
                	 <thead style="width:100%">
                     	<tr height="20px">
                        	<th style="text-align:center; width:20px" >
                            	<input type="hidden" name="record_num" id="record_num" value="<cfoutput>#get_stock_info.recordcount#</cfoutput>">
                            	<a href="javascript:add_row();"><img src="/images/plus_list.gif"  border="0"></a>
                            </th>
                          	<th style="text-align:center; width:100%" ><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                         	<th style="text-align:center; width:60px"><cf_get_lang dictionary_id='583.Optimizasyon'></th>
                      	</tr>
                 	</thead>
                 	<tbody name="new_row" id="new_row">
                    	<cfif get_stock_info.recordcount>
                        	<cfoutput query="get_stock_info">
                             	<tr name="frm_row#currentrow#" id="frm_row#currentrow#">
                                 	<td style="height:30px; text-align:left; vertical-align:middle">
                                    	<a style="cursor:pointer" onclick="sil(#currentrow#);">
                                      		<img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0">
                                       	</a>
                                    	<input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                                    </td>
                                	<td style="text-align:left; vertical-align:middle" nowrap>
                                        <input type="hidden" name="pid#currentrow#" id="pid#currentrow#" value="#get_stock_info.product_id#">
                                      	<input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#" value="#get_stock_info.stock_id#">
                                       	<input type="text" name="urun#currentrow#" id="urun#currentrow#" value="#get_stock_info.product_name#" style="width:95%; height:25px; border-style:none">
                                        <a href="javascript://" onclick="pencere_ac(#currentrow#);"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>
                                 	</td>
                                  	<td style="text-align:center; vertical-align:middle">
                                        <input type="text" name="plan_demand_#currentrow#" id="plan_demand_#currentrow#" value="#TlFormat(attributes.total,4)#"  style="text-align:right;border-style:none">
                                  	</td>
                             	</tr>
                     		</cfoutput>
                    	</cfif>
                	</tbody>
                </cf_grid_list>
            </cf_basket>
 		</cfform>
   	</cf_box>
</div>
<script type="text/javascript">
	var row_count=document.getElementById('record_num').value;
	function add_row()
	{
		row_count++;
		var newRow;
		var newCell;
		newRow = document.getElementById("new_row").insertRow(document.getElementById("new_row").rows.length);
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);
		newRow.setAttribute("NAME","frm_row" + row_count);
		newRow.setAttribute("ID","frm_row" + row_count);
		
		document.upd_material.record_num.value = row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='51.Sil'>" border="0"></a>';	
			
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" value="1" id="row_kontrol' + row_count +'" name="row_kontrol' + row_count +'"><input type="text" name="urun' + row_count +'" id="urun'+ row_count +'" style="width:94%; height:40px;border-style:none"><input type="hidden" name="pid' + row_count +'" id="pid'+ row_count +'"><input type="hidden" name="stock_id' + row_count +'" id="stock_id' + row_count +'">&nbsp;&nbsp;<a style="cursor:pointer" href"javascript://" onClick="pencere_ac('+ row_count +');"><img src="/images/plus_thin.gif" align="absmiddle" border="0"></a>';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="plan_demand_' + row_count +'" name="plan_demand_' + row_count +'" value="<cfoutput>#TlFormat(1,4)#</cfoutput>" style="width:140px; text-align:right;border-style:none">';
	}
	function pencere_ac(no)
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=0,3,4&product_id=upd_material.pid" + no +"&field_id=upd_material.stock_id" + no +"&field_name=upd_material.urun" + no,'list');
	}
	function sil(sy)
	{
		document.getElementById('row_kontrol'+sy).value=0;
		document.getElementById('frm_row'+sy).style.display="none";
	} 
	function kontrol()
	{
		stock_id_list ='';
		varyok = 0;
		for(i=1;i<=row_count;i++)
		{
			if(document.getElementById('row_kontrol'+i).value == 1)
			{
				varyok = 1;
				stockid = document.getElementById("stock_id"+i).value;
				if(list_find(stock_id_list,stockid))
				{
					alert('<cf_get_lang dictionary_id='153.Ürünü Birden Fazla Satırda Kullanılmış. Tekrar Düzenleyin'>.');
					document.getElementById("urun"+i).focus();
					return false;
				}
				else
					stock_id_list += stockid+',';
			}
		}
		if(varyok==0)
		{
			alert('<cf_get_lang dictionary_id='59801.En az 1 satır seçmelisiniz!'>.');
			return false;
		}
		else
			return true;
	}
</script>
	


