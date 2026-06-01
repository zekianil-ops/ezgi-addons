<!---
    File: upd_ezgi_product_tree_creative_piece_rota.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_operation_types" datasource="#dsn3#">
	SELECT OPERATION_TYPE_ID, OPERATION_TYPE, OPERATION_CODE FROM OPERATION_TYPES WHERE OPERATION_STATUS = 1
</cfquery>
<cfquery name="get_operations" datasource="#dsn3#">
	SELECT 
    	* 
  	FROM 
    	EZGI_DESIGN_PIECE_ROTA WITH (NOLOCK)
    WHERE 
    	<cfif isdefined('attributes.piece_id')>
    		PIECE_ROW_ID = #attributes.piece_id# 
      	<cfelseif isdefined('attributes.package_id')>
    		PACKAGE_ROW_ID = #attributes.package_id#
       	<cfelseif isdefined('attributes.main_id')>
    		MAIN_ROW_ID = #attributes.main_id#
     	</cfif>
   	ORDER BY 
    	SIRA
</cfquery>
<cfif get_operations.recordcount>
	<cfset recordnum = get_operations.recordcount>
<cfelse>
	<cfset recordnum = 0>
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="upd_piece_op"><cf_get_lang dictionary_id='36387.Operasyon Güncelle'></cfsavecontent>
	<cf_box title="#upd_piece_op#">
    	<cfform name="upd_piece_rota" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_product_tree_creative_piece_rota">
        	<cfif isdefined('attributes.piece_id')>
                <cfinput type="hidden" name="piece_id" value="#attributes.piece_id#">
            <cfelseif isdefined('attributes.package_id')>
                <cfinput type="hidden" name="package_id" value="#attributes.package_id#">
            <cfelseif isdefined('attributes.main_id')>
                <cfinput type="hidden" name="main_id" value="#attributes.main_id#">
            </cfif>
           	<cfif isdefined('attributes.master_plan_id')>
              	<cfinput type="hidden" name="master_plan_id" value="#attributes.master_plan_id#">
         	</cfif>
            <cfif isdefined('attributes.is_common_piece_list')>
             	<cfinput type="hidden" name="is_common_piece_list" value="#attributes.is_common_piece_list#">
         	</cfif>
            	<cf_grid_list id="operation_panel" sort="0">
                	<thead>
                     	<tr>
							<th width="20px"></th>
                         	<th width="20px">
                             	<input type="hidden" name="record_num" id="record_num" value="<cfoutput>#recordnum#</cfoutput>">
								<a href="javascript:openOperatios();"><img src="/images/plus_list.gif"  border="0"></a>
                          	</th>
                          	<th width="40px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                          	<th nowrap="nowrap"><cf_get_lang dictionary_id='36376.Operasyonlar'></th>
                         	<th width="60px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                     	</tr>
                	</thead>
                    <tbody name="new_row" id="new_row" class="sorter">
                   		<cfif get_operations.recordcount>
                        	<cfoutput query="get_operations">
                           		<tr name="frm_row#currentrow#" id="frm_row#currentrow#">
                                	<input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                               		<td class="text-center"><span class="icn-md icon-align-justify handle"></td>
									<td class="text-center">
                                  		<a style="cursor:pointer" onclick="sil(#currentrow#);" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a>
                                   	</td>
                                 	<td class="row_number">
                                    	<input type="text" name="current_id#currentrow#" id="current_id#currentrow#" value="#currentrow#" readonly="readonly" style="width:25px; text-align:right;">
                                  	</td>
                                	<td nowrap="nowrap">
                                   		<select id="operation_type_id#currentrow#" name="operation_type_id#currentrow#" style="width:100%">
                                        	<option value="0"><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                        	<cfloop query="get_operation_types">
                                           		<option value="#OPERATION_TYPE_ID#" <cfif get_operations.OPERATION_TYPE_ID eq OPERATION_TYPE_ID>selected</cfif>>#OPERATION_CODE# - #OPERATION_TYPE#</option>
                                         	</cfloop>
                                     	</select>
                                 	</td>
                                	<td>
                                  		<input type="text" name="quantity#currentrow#" id="quantity#currentrow#" value="#TlFormat(get_operations.amount,2)#" style="width:65px; text-align:right;">
                                	</td>
                              	</tr>
                        	</cfoutput>
                     	</cfif>
                  	</tbody>
               	</cf_grid_list>
            <div class="row">
            	<div class="col col-12 uniqueRow">
                 	<div class="row formContent">
                     	<cf_box_elements>
            				<cf_box_footer>
                           		<cf_workcube_buttons 
                                	is_upd='1' 
                                   	is_cancel = '1' 
                                 	add_function='kontrol()'
                                    del_function='sil_kontrol()'
                                    >
                			</cf_box_footer>
                      	</cf_box_elements>
                   	</div>
               	</div>
          	</div>
 		</cfform>
   	</cf_box>
</div>
<script type="text/javascript">
	var row_count=document.upd_piece_rota.record_num.value;
	function openOperatios()
	{
		window.open("<cfoutput>#request.self#?fuseaction=prod.popup_list_ezgi_operations</cfoutput>","_blank","width=320,height=600,left=700,top=300");
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
		document.upd_piece_rota.record_num.value = row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.classList.add("text-center");
		newCell.innerHTML = '<span class="icn-md icon-align-justify handle"></span>';

		newCell = newRow.insertCell(newRow.cells.length);
		newCell.classList.add("text-center");
		newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a>';	
			
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.classList.add("row_number");
		newCell.innerHTML = '<input type="text" id="current_id' + row_count +'" name="current_id' + row_count +'" value="' + row_count +'" readonly="readonly"  style="width:25px; text-align:right;">';
			
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" id="operation_type_id'+row_count+'" name="operation_type_id'+row_count+'" value="'+operation_type_id+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="text" name="operation_type' + row_count + '" style="width:190px;" value="'+operation_type+'">';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<input type="text" id="quantity' + row_count +'" name="quantity' + row_count +'" value="<cfoutput>#TlFormat(1,2)#</cfoutput>" style="width:65px; text-align:right;">';

		operationsPanel.find("> tbody").sortable(sortableSettings.operations);
	}
	function sil(sy)
	{
		var element=eval("upd_piece_rota.row_kontrol"+sy);
		element.value=0;
		var element=eval("frm_row"+sy); 
		element.style.display="none";
	} 
	function kontrol()
	{
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
			document.getElementById("upd_piece_rota").submit();
		}
		else
		return false;
	}
	function sil_kontrol()
	{
		sor = confirm("<cf_get_lang dictionary_id='188.Rotayı Silmek İstediğinizden Emin Misiniz'>?");
		if(sor==true)
			window.location ="<cfoutput>#request.self#?fuseaction=prod.emptypopup_del_ezgi_product_tree_creative_piece_rota&<cfif isdefined('attributes.piece_id')>piece_id=#attributes.piece_id#<cfelseif isdefined('attributes.package_id')>package_id=#attributes.package_id#<cfelseif isdefined('attributes.main_id')>main_id=#attributes.main_id#</cfif></cfoutput>";
		else
			return false;
	}

	//sortable

	const operationsPanel = $("#operation_panel");

	var sortableSettings = {
		operations: {
			connectWith: '.sorter',
			handle: '.handle',
			start: function (event, ui) {},
			stop: function (event, ui) {
				operationsPanel.find("> tbody tr").each(function (index) {
					$(this).find("td.row_number input[type = text]").val(index + 1);
				});
			}
		}
	};

	operationsPanel.find("> tbody").sortable(sortableSettings.operations);

</script>