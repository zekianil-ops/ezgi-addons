<!---
    File: dsp_ezgi_project_disccount_sub_con.cfm
    Folder: Add_Ons\ezgi\e_connect\display
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description:
--->
<cfquery name="get_product_list" datasource="#DSN3#">
	SELECT
    	E.DISC_SUB_CONDITION_ID, 
        E.PROJECT_ID, 
        E.CON_PRODUCT_ID, 
        E.PRODUCT_ID, 
        E.QUANTITY, 
        P.PRODUCT_CODE, 
        P.BARCOD, 
        P.PRODUCT_NAME, 
        P.PRODUCT_STATUS
	FROM     
    	EZGI_CONNECT_PROJECT_DISCOUNT_SUB_CONDITIONS AS E INNER JOIN
        #dsn1_alias#.PRODUCT AS P ON E.PRODUCT_ID = P.PRODUCT_ID
	WHERE  
    	E.CON_PRODUCT_ID = #attributes.product_id# AND 
        E.PROJECT_ID = #attributes.project_id#
</cfquery>
<cfset attributes.pid = attributes.product_id>
<cfparam name="attributes.modal_id" default="">

<cfform name="form_basket" method="post" action="#request.self#?fuseaction=sales.emptypopup_upd_ezgi_project_disccount_sub_con">
	<cfinput type="hidden" name="project_id" value="#attributes.project_id#">
    <cfinput type="hidden" name="product_id" value="#attributes.product_id#">
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cf_box>
        	<cf_box_elements>
            	<div class="col col-12" type="column" index="1" sort="true">
                	<div class="form-group" id="spect_tur">
                   		<div class="col col-8 col-xs-12">
                         	<cfoutput>
                            	<input type="Hidden" name="record_num" id="record_num" value="#get_product_list.recordcount#">
                        	</cfoutput>
                      	</div>
                 	</div>
              	</div>
			</cf_box_elements>
            <cf_flat_list>
                <thead>
                    <tr>
                        <th>
                            <a href="javascript:openProducts();" title="<cf_get_lang dictionary_id='29410.Ürün Ekle'>"><i class="fa fa-plus"></i></a>
                        </th>
                        <th width="30"><cf_get_lang dictionary_id='57487.No'></th>
                        <th><cf_get_lang dictionary_id='36199.Açıklama'></th>
                        <th width="65" style="text-align:right;"><cf_get_lang dictionary_id='57635.Miktar'></th>
                    </tr>
                </thead>
                <tbody name="table1" id="table1">
                    <cfif get_product_list.recordcount>
                        <cfoutput query="get_product_list">
                            <input type="Hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                            <input type="Hidden" name="product_id#currentrow#" id="product_id#currentrow#" value="#PRODUCT_ID#">
                            <tr id="frm_row#currentrow#">
                                <td align="center" width="15">
                                    <cfsavecontent variable="alert"><cf_get_lang dictionary_id='48604.Silmek İstediğinizden Emin misiniz'></cfsavecontent>
                                    <a style="cursor:pointer" onClick="sil(#currentrow#);"><img  src="images/delete_list.gif" border="0" title="<cf_get_lang dictionary_id='37781.Ürünü Sil'>"></a>
                                </td>
                                <td nowrap>#currentrow#</td>
                                <td><input type="text" name="product_name#currentrow#" id="product_name#currentrow#" style="width:300px; border:none" value="#product_name#" readonly></td>
                                <td><input type="text" name="row_amount#currentrow#" id="row_amount#currentrow#" style="width:65px;border:none; text-align:right" value="#AmountFormat(QUANTITY,0)#"></td>
                            </tr>
                        </cfoutput>
                    </cfif>
                </tbody>
            </cf_flat_list>
            <cf_box_footer>
                <cf_workcube_buttons 
                    is_upd='1' 
                    is_delete='0'
                 >
            </cf_box_footer>
        </cf_box>
    </div>
</cfform>
<script type="text/javascript">
	row_count=<cfoutput>#get_product_list.recordcount#</cfoutput>;
	function add_row(stockid,stockprop,sirano,product_id,product_name,manufact_code,tax,tax_purchase,add_unit,product_unit_id,money,is_serial_no,discount1,discount2,discount3,discount4,spect_main_id,amount)
	{
		row_count++;
		var newRow;
		var newCell;
		newRow = document.getElementById("table1").insertRow(document.getElementById("table1").rows.length);
		newRow.className = 'color-row';
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);		
		newRow.setAttribute("NAME","frm_row" + row_count);
		newRow.setAttribute("ID","frm_row" + row_count);
		document.form_basket.record_num.value=row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML='<a style="cursor:pointer" onclick="sil('+row_count+');"><img src="images/delete_list.gif" border="0" alt=""></a>';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML=row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="Hidden" name="stock_id'+row_count+'" value="' + stockid + '">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="product_id'+row_count+'" value="'+product_id+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" name="unit_id'+row_count+'" value="'+product_unit_id+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="text" name="product_name' + row_count + '" style="width:340px;border-style:none" value="'+product_name+'">';
	
		newCell = newRow.insertCell(newRow.cells.length);//Miktar
		newCell.innerHTML = '<input type="text" name="row_amount' + row_count + '" style="width:65px;border-style:none;text-align:right" value="1">';
		

	}	
	function sil(sy)
	{
		
		var my_element=eval("form_basket.row_kontrol"+sy);
		my_element.value=0;
		var my_element=eval("frm_row"+sy);
		my_element.style.display="none";
	}
	function openProducts()
	{
		windowopen('<cfoutput>#request.self#?fuseaction=prod.popup_ezgi_stocks&ezgi_secim_type=1&list_order_no=3,4,6,9&price_cat=-2&add_product_cost=1&module_name=product&var_=upd_purchase_basket&is_action=1&startdate=&price_lists='</cfoutput>,'page');
	}
</script>
          	
                    