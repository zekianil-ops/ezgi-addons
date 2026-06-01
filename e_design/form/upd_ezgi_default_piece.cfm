<!---
    File: upd_ezgi_default_piece.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_operation_types" datasource="#dsn3#">
	SELECT OPERATION_TYPE_ID, OPERATION_TYPE, OPERATION_CODE FROM OPERATION_TYPES WITH (NOLOCK) WHERE OPERATION_STATUS = 1
</cfquery>
<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_PIECE_DEFAULTS WITH (NOLOCK) WHERE PIECE_DEFAULT_ID = #attributes.piece_id#
</cfquery>
<cfquery name="get_operations" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_PIECE_DEFAULTS_ROTA WITH (NOLOCK) WHERE PIECE_DEFAULT_ID = #attributes.piece_id#
</cfquery>
<cfquery name="get_delete_control" datasource="#dsn3#">
	SELECT PIECE_ROW_ID FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) WHERE MASTER_PRODUCT_ID = #attributes.piece_id#
</cfquery>
<cfif get_upd.recordcount>
	<cfset recordnum = get_operations.recordcount>
<cfelse>
	<cfset recordnum = 0>
</cfif>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
    	<cfform name="upd_default_piece" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_default_piece">
          	<cfinput type="hidden" name="piece_id" value="#attributes.piece_id#">
            <cf_basket_form id="upd_default_piece">
                <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
                                	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                                        <div class="form-group" id="item-status">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                                            <div class="col col-8 col-xs-12">
                                                <input type="checkbox" id="status" name="status" value="1" <cfif get_upd.STATUS>checked</cfif>>
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-default_code">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='853.Parça Kodu'> *</label>
                                            <div class="col col-8 col-xs-12">
                                                <cfinput type="text" name="default_code" id="default_code" readonly="yes" value="#get_upd.PIECE_DEFAULT_CODE#" maxlength="20">
                                            </div>
                                        </div>
                                        <div class="form-group" id="item-status">
                                            <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='399.Parça Adı'> *</label>
                                            <div class="col col-8 col-xs-12">
                                            	<div class="input-group">
                                                	<cfinput type="text" name="default_type" id="default_type" value="#get_upd.PIECE_DEFAULT_NAME#" maxlength="50">
                                                    <span class="input-group-addon">
                                                    	<cf_language_info 
                                                            table_name="EZGI_DESIGN_PIECE_DEFAULTS" 
                                                            column_name="PIECE_DEFAULT_NAME" 
                                                            column_id_value="#attributes.piece_id#" 
                                                            maxlength="500" 
                                                            datasource="#dsn3#" 
                                                            column_id="PIECE_DEFAULT_ID" 
                                                            control_type="0">
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                  	</div>
                              	</cf_box_elements>
                    			<cf_box_footer>
                                	<cf_record_info 
                                        query_name="get_upd"
                                        record_emp="RECORD_EMP" 
                                        record_date="record_date"
                                        update_emp="UPDATE_EMP"
                                        update_date="update_date">
									<cfif not get_delete_control.recordcount>
                                        <cf_workcube_buttons 
                                            is_upd='1' 
                                            add_function='kontrol()'
                                            del_function_for_submit='del_kontrol()'>
                                    <cfelse>
                                        <cf_workcube_buttons 
                                            is_upd='1' 
                                            is_delete = '0' 
                                            add_function='kontrol()'>
                                    </cfif>
                				</cf_box_footer>
                			</div>
            			</div>
        		</div>
    		</cf_basket_form>
            <cf_basket id="upd_default_piece_bask">
            	<cf_grid_list sort="0">
                	<thead>
                     	<tr>
                       		<th width="20px">
                           		<input type="hidden" name="record_num" id="record_num" value="<cfoutput>#recordnum#</cfoutput>">
                              	<a href="javascript:openOperatios();"><img src="/images/plus_list.gif"  border="0" title="<cf_get_lang dictionary_id='57582.Ekle'>"></a>
                         	</th>
                        	<th width="40px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        	<th nowrap="nowrap"><cf_get_lang dictionary_id='36376.Operasyonlar'></th>
                         	<th width="100px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                       	</tr>
                  	</thead>
                    <tbody name="new_row" id="new_row">
                   		<cfif get_operations.recordcount>
                       		<cfoutput query="get_operations">
                             	<tr name="frm_row#currentrow#" id="frm_row#currentrow#">
                                	<input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                             		<td>
                                     	<a style="cursor:pointer" onclick="sil(#currentrow#);" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a>
                                 	</td>
                                 	<td>
                                  		<input type="text" name="current_id#currentrow#" id="current_id#currentrow#" value="#currentrow#" readonly="readonly" style="width:25px; text-align:right;">
                                 	</td>
                               		<td nowrap="nowrap">
                                    	<select id="operation_type_id#currentrow#" name="operation_type_id#currentrow#" style="width:350px">
                                         	<option value="0"><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                          	<cfloop query="get_operation_types">
                                            	<option value="#OPERATION_TYPE_ID#" <cfif get_operations.OPERATION_TYPE_ID eq OPERATION_TYPE_ID>selected</cfif>>#OPERATION_CODE# - #OPERATION_TYPE#</option>
                                         	</cfloop>
                                    	</select>
                                 	</td>
                                 	<td>
                                  		<input type="text" name="quantity#currentrow#" id="quantity#currentrow#" value="#TlFormat(get_operations.QUANTITY,2)#" onkeyup="isNumber(this);" style="width:100px; text-align:right;">
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
	document.getElementById('default_type').focus();
	var row_count=document.upd_default_piece.record_num.value;
	function openOperatios()
	{
		window.open("<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_operations</cfoutput>","_blank","width=250,height=600,left=700,top=300");
	}
	function add_row(operation_type_id,operation_type)
	{
		row_count++;
		var newRow;
		var newCell;
		newRow = document.getElementById("new_row").insertRow(document.getElementById("new_row").rows.length);
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);
		newRow.setAttribute("NAME","frm_row" + row_count);
		newRow.setAttribute("ID","frm_row" + row_count);
		document.upd_default_piece.record_num.value = row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a>';	
			
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="current_id' + row_count +'" name="current_id' + row_count +'" value="' + row_count +'" readonly="readonly"  style="width:25px; text-align:right;">';
			
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'" id="row_kontrol'+row_count+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" id="operation_type_id'+row_count+'" name="operation_type_id'+row_count+'" value="'+operation_type_id+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="text" name="operation_type' + row_count + '" style="width:350px;" value="'+operation_type+'">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="quantity' + row_count +'" name="quantity' + row_count +'" value="<cfoutput>#TlFormat(1,2)#</cfoutput>" style="width:100px; text-align:right;"  onkeyup="isNumber(this);">';
	}
	function sil(sy)
	{
		document.getElementById('row_kontrol'+sy).value=0;
		document.getElementById('frm_row'+sy).style.display='none';
	} 
	function kontrol()
	{
		if(document.getElementById("default_type").value == "")
		{
			alert("<cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'> <cf_get_lang dictionary_id='437.Operasyon Adı'> !");
			document.getElementById('default_type').focus();
			return false;
		}
		if(document.getElementById("record_num").value > 0)
		{
			sayi = document.getElementById("record_num").value;
			for (i = 1; i <= sayi; i++)
			{
				if(document.getElementById("quantity"+i).value <=0 && document.getElementById("row_kontrol"+i).value == 1)
				{
					alert(i+'. <cf_get_lang dictionary_id='154.Satırdaki Operasyonun Miktarı Sıfırdan Büyük Olmalıdır'> !');
					document.getElementById("quantity"+i).focus();
					return false;
				}
				if(document.getElementById("operation_type_id"+i).value <=0 && document.getElementById("row_kontrol"+i).value == 1)
				{
					alert(i+'. <cf_get_lang dictionary_id='155.Satırdaki Operasyon Seçilmemiştir'> !');
					document.getElementById("operation_type_id"+i).focus();
					return false;
				}
			}
		}
	}
	function del_kontrol()
	{
		window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_default_piece&piece_id=#attributes.piece_id#</cfoutput>";
		return true;
	}
</script>