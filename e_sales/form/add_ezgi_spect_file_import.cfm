<cfsavecontent variable="img_">
	<cfoutput>
 	<cfif isdefined("attributes.stock_id") and len(attributes.stock_id) and isdefined('session.ep')><a href="#request.self#?fuseaction=objects.popup_list_spect_main&main_to_add_spect=1&#url_str#"><img src="/images/cuberelation.gif" align="absmiddle" border="0" title="<cf_get_lang no ='1530.Konfigüratör'>"></a></cfif>
    </cfoutput>
</cfsavecontent>
<cfquery name="get_asset" datasource="#dsn3#">
	SELECT  FILE_TYPE_ID, FILE_NAME, FILE_NAME_OLD FROM EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE WHERE EZGI_ID = #attributes.ezgi_id#
</cfquery>
<cfoutput query="get_asset">
	<cfset 'FILE_NAME_#FILE_TYPE_ID#' = FILE_NAME>
    <cfset 'FILE_NAME_OLD_#FILE_TYPE_ID#' = FILE_NAME_OLD>
</cfoutput>
<cfsavecontent variable="ezgi_header"><cfoutput>#getLang('objects',1529)# - #get_product.PRODUCT_NAME# - (#getLang('main',818)# = #get_product.SORT_NO#)</cfoutput></cfsavecontent>
<cfform name="form_basket" id="form_basket" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_virtual_offer_row_spect">
	<cf_box title="#ezgi_header#" right_images="#right_images_#">
        <cfinput name="ezgi_id" value="#attributes.ezgi_id#" type="hidden">
        <!---<cfinput type="hidden" name="is_price_change" id="is_price_change" value="1">--->
        <cfinput type="hidden" name="uploaded_file" id="uploaded_file" value="UTF-8">
        <cfinput name="kilit_stage" value="#attributes.kilit_stage#" type="hidden">
        <cfinput type="hidden" name="record_num" id="record_num" value="#get_row.recordcount#">
        <cfif isdefined('attributes.ezgi_kilit')>
       		<cfinput name="ezgi_kilit" value="#attributes.ezgi_kilit#" type="hidden">
        </cfif>
        <cf_box_elements>
        	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
            	<div class="col col-2" type="column" index="1" sort="true" >
                	<cfquery name="get_special_images" datasource="#dsn3#">
                            	SELECT TOP (1) 
                                	VIRTUAL_OFFER_ROW_IMPORT_FILE_ID, 
                                    EZGI_ID, 
                                    FILE_TYPE_ID, 
                                    FILE_NAME, 
                                    FILE_NAME_OLD
								FROM     
                                	EZGI_VIRTUAL_OFFER_ROW_IMPORT_FILE
								WHERE  
                                	EZGI_ID = #attributes.ezgi_id# AND
                                    FILE_TYPE_ID = 5
              		</cfquery>
                	<cfif get_special_images.recordcount and len(get_special_images.FILE_NAME)>
                       	<cfoutput>
                         	<img src="/documents/temp/#get_special_images.FILE_NAME#" style="height:160px; width:160px; vertical-align:middle">
                     	</cfoutput>
                	</cfif>
            	</div>
                <div class="col col-5" type="column" index="1" sort="true" style="border:solid; border-color:silver">
                    <br>
                    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
                        <div class="form-group require" id="transfer_type">
                            <label class="col col-3 col-sm-12"><cf_get_lang_main no='1118.Aktarım Türü'></label>
                            <div class="col col-8 col-sm-12">
                                <select name="import_file_type" id="import_file_type" style="width:200px; height:20px">
                                    <cfif not isdefined('attributes.ezgi_kilit')>
                                        <option value="1">Satış Fiyatı Aktarım</option>
                                        <option value="2">Çalışma Dosyası Aktarım</option>
                                        <option value="3">İmalat Dosyası Aktarım</option>
                                    <cfelseif isdefined('attributes.ezgi_kilit') and attributes.ezgi_kilit eq 2>
                                        <option value="3">İmalat Dosyası Aktarım</option>
                                    </cfif>
                                    <option value="4">Teknik Detay Dosyası Aktarım</option>
                                    <option value="5">Müşteri Özel Resmi</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
                        <div class="form-group require" id="item-document">
                            <label class="col col-3 col-sm-12"><cf_get_lang_main no='56.Belge'>*</label>
                            <div class="col col-8 col-sm-12">
                                <input type="file" name="uploaded_file" id="uploaded_file" style="width:200px;height:20px">
                            </div>
                        </div>
                    </div>
                    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
                        <div class="form-group require" id="item-buton">
                            <div class="col col-8 col-sm-12">
                            </div>
                            <div class="col col-4 col-sm-12">
                            <input type="button" value="  Aktar  " style="width:60px" onClick="aktar();">
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col col-5" type="column" index="2" sort="true">
                    <table cellpadding="2" cellspacing="0" width="100%">
                        <tr>
                            <td style="width:200px; text-align:right">Fiyat Aktarım Dosyası</td>
                            <td style="text-align:left; height:20px; width:30px">
                                <cfif isdefined('FILE_NAME_1')>
                                    <cfoutput>
                                        <a href="#request.self#?fuseaction=objects.popup_download_file&file_name=temp\#FILE_NAME_1#" class="tableyazi" >
                                            <img src="/images/doc_export.gif" border="0" title="#FILE_NAME_1#" />
                                        </a>
                                    </cfoutput>
                                </cfif>
                            </td>
                            <td nowrap="nowrap" style="text-align:left; width:200px"><cfif isdefined('FILE_NAME_OLD_1')><cfoutput>#Left(Evaluate('FILE_NAME_OLD_1'),80)#</cfoutput><cfif len(Evaluate('FILE_NAME_OLD_1')) gt 80>...</cfif></cfif></td>
                        </tr>
                        <tr>
                            <td style="text-align:right">Çalışma Dosyası</td>
                            <td style="text-align:left; height:20px;">
                                <cfif isdefined('FILE_NAME_2')>
                                    <cfoutput>
                                        <a href="#request.self#?fuseaction=objects.popup_download_file&file_name=temp\#FILE_NAME_2#" class="tableyazi" >
                                            <img src="/images/doc_export.gif" border="0" title="#FILE_NAME_2#" />
                                        </a>
                                    </cfoutput>
                                </cfif>
                            </td>
                            <td nowrap="nowrap" style="text-align:left;"><cfif isdefined('FILE_NAME_OLD_2')><cfoutput>#Left(Evaluate('FILE_NAME_OLD_2'),80)#</cfoutput><cfif len(Evaluate('FILE_NAME_OLD_2')) gt 80>...</cfif></cfif></td>
                        </tr>
                        <tr>
                            <td style="text-align:right">İmalat Dosyası</td>
                            <td style="text-align:left; height:20px;">
                                <cfif isdefined('FILE_NAME_3')>
                                    <cfoutput>
                                        <a href="#request.self#?fuseaction=objects.popup_download_file&file_name=temp\#FILE_NAME_3#" class="tableyazi" >
                                            <img src="/images/doc_export.gif" border="0" title="#FILE_NAME_3#" />
                                        </a>
                                    </cfoutput>
                                </cfif>
                            </td>
                            <td nowrap="nowrap" style="text-align:left;"><cfif isdefined('FILE_NAME_OLD_3')><cfoutput>#Left(Evaluate('FILE_NAME_OLD_3'),80)#</cfoutput><cfif len(Evaluate('FILE_NAME_OLD_3')) gt 80>...</cfif></cfif></td>
                        </tr>
                        <tr>
                            <td style="text-align:right">Teknik Detay Dosyası</td>
                            <td style="text-align:left; height:20px;">
                                <cfif isdefined('FILE_NAME_4')>
                                    <cfoutput>
                                        <a href="#request.self#?fuseaction=objects.popup_download_file&file_name=temp\#FILE_NAME_4#" class="tableyazi" >
                                            <img src="/images/doc_export.gif" border="0" title="#FILE_NAME_4#" />
                                        </a>
                                    </cfoutput>
                                </cfif>
                            </td>
                            <td nowrap="nowrap" style="text-align:left;"><cfif isdefined('FILE_NAME_OLD_4')><cfoutput>#Left(Evaluate('FILE_NAME_OLD_4'),80)#</cfoutput><cfif len(Evaluate('FILE_NAME_OLD_4')) gt 80>...</cfif></cfif></td> 
                        </tr>
                    </table>
                </div>
            </div>
        </cf_box_elements>
  	</cf_box>
    <cf_box title="Malzeme Listesi">
    	 <cf_basket id="price_detail">
          	<cf_grid_list sort="0">
           		<thead>
           		    <tr>
           		    	<th nowrap width="55px" id="basket_header_add" style="text-align:center">
							<cfif not attributes.kilit_stage>
           		                <a href="javascript://" onClick="openProducts();"><img src="/images/plus_list.gif" border="0" id="basket_header_add" title="Malzeme Ekle"></a>
           		            </cfif>
           		        </th>
           		        <th><cf_get_lang_main no='106.Stok Kodu'></th>
           		        <th><cf_get_lang_main no='809.Ürün Adı'></th>
           		        <th style="width:50px"><cf_get_lang_main no='223.Miktar'></th>
           		        <th><cf_get_lang_main no='224.Birim'></th>
           		        <cfif Listfind(session.ep.POWER_USER_LEVEL_ID,56)>
           		            <th style="width:70px"><cf_get_lang_main no='672.Fiyat'></th>
           		            <th style="width:50px"><cf_get_lang_main no='265.Döviz'></th>
           		            <th><cf_get_lang_main no='261.Tutar'></th>
           		            <th><cf_get_lang_main no='265.Döviz'></th>
           		        </cfif>
           		    </tr>
           		</thead>
           		<tbody name="new_row" id="new_row">
           			<cfif get_row.recordcount>
           		    	<cfoutput query="get_row">
                        	<input type="hidden" value="1" name="row_kontrol#currentrow#">
                            <input type="hidden" value="#TlFormat(Evaluate('RATE2_#sales_price_money#'),4)#" id="row_rate2_#currentrow#" name="row_rate2_#currentrow#">
           		        	<tr height="20" id="frm_row#currentrow#">
           		            	<td nowrap style="text-align:right;">
           		                	<cfif not attributes.kilit_stage>
                                    	<cfif x_import_update_info eq 1>
                                            <a style="cursor:pointer" onclick="sil(#currentrow#);" >
                                                <img src="/images/delete_list.gif" alt="<cf_get_lang_main no='1559.Satır Sil'>" title="<cf_get_lang_main no='1559.Satır Sil'>" border="0">
                                            </a>
                                        </cfif>
           		                        &nbsp;#currentrow#&nbsp;
           		                    </cfif>
           		                </td>
           		            	<td style="text-align:center">
                                	<input type="text" name="product_code#currentrow#" id="product_code#currentrow#" value="#product_code#" style="text-align:left;" readonly>
                                </td>
           		                <td style="text-align:left">
                                	<input type="text" name="product_name#currentrow#" id="product_name#currentrow#" value="#product_name#" style="text-align:left;" readonly>
                                </td>
           		                <td style="text-align:right">
                                	<input type="text" name="amount#currentrow#" id="amount#currentrow#" value="#TlFormat(AMOUNT,4)#" style="text-align:right; width:50px" onchange="hesapla(#currentrow#)" <cfif x_import_update_info neq 1>readonly</cfif>>
                                </td>
           		                <td style="text-align:left">#MAIN_UNIT#</td>
           		                <cfif Listfind(session.ep.POWER_USER_LEVEL_ID,56)>
           		                    <td style="text-align:right">
                                    	<input type="text" name="sales_price#currentrow#" id="sales_price#currentrow#" value="#TlFormat(SALES_PRICE,2)#" style="text-align:right; width:70px" onchange="hesapla(#currentrow#)" <cfif x_import_update_info neq 1>readonly</cfif>>
                                   	</td>
           		                    <td style="text-align:left">
                                    	<input type="text" name="sales_price_money#currentrow#" id="sales_price_money#currentrow#" value="#SALES_PRICE_MONEY#" style="text-align:left; width:50px">
                                    </td>
           		                    <td style="text-align:right">
           		                        <cfif isdefined('RATE2_#SALES_PRICE_money#')>
                                        	<input type="text" name="row_total#currentrow#" id="row_total#currentrow#" value="#TlFormat(SALES_PRICE*AMOUNT*Evaluate('RATE2_#SALES_PRICE_money#'),2)#" style="text-align:right; width:70px" <cfif x_import_update_info neq 1>readonly</cfif>>
           		                        <cfelse>
                                        	<input type="text" name="row_total#currentrow#" id="row_total#currentrow#" value="#TlFormat(0,2)#" style="text-align:right; width:70px" <cfif x_import_update_info neq 1>readonly</cfif>>
           		                        </cfif>
           		                    </td>
           		                    <td style="text-align:left">#session.ep.money#</td>
           		                <cfelse>
                                	<input type="hidden" name="sales_price#currentrow#" id="sales_price#currentrow#" value="#TlFormat(SALES_PRICE,2)#">
                                	<input type="hidden" name="sales_price_money#currentrow#" id="sales_price_money#currentrow#" value="#SALES_PRICE_MONEY#">
                                </cfif>
                                <input type="hidden" name="purchase_price#currentrow#" id="purchase_price#currentrow#" value="#TlFormat(purchase_PRICE,2)#">
                                <input type="hidden" name="purchase_price_money#currentrow#" id="purchase_price_money#currentrow#" value="#PURCHASE_PRICE_MONEY#">
                                <input type="hidden" name="cost_price#currentrow#" id="cost_price#currentrow#" value="#TlFormat(cost_PRICE,2)#">
                                <input type="hidden" name="cost_price_money#currentrow#" id="cost_price_money#currentrow#" value="#cost_PRICE_MONEY#">
           		                <cfset toplam = toplam+(SALES_PRICE*AMOUNT*Evaluate('RATE2_#SALES_PRICE_money#'))>
           		                <cfset purchase_total = purchase_total+(PURCHASE_PRICE*AMOUNT*Evaluate('RATE2_#PURCHASE_PRICE_money#'))>
           		                <cfset cost_total = cost_total+(COST_PRICE*AMOUNT*Evaluate('RATE2_#COST_PRICE_money#'))>
           		            </tr>
           		        </cfoutput>
           		    </cfif>
           		</tbody>
               	<tfoot>
                	<tr>
           		     	<cfoutput>
                         	<td colspan="<cfif Listfind(session.ep.POWER_USER_LEVEL_ID,56)>7<cfelse>3</cfif>"><b>Toplam</b></td>
                          	<td style="text-align:right">
                            	<input type="text" name="total" id="total" value="#TlFormat(toplam,2)#" style="text-align:right; font-weight:bold;width:70px">
                            </td>
                         	<td style="text-align:left">#session.ep.money#</td>
           		     	</cfoutput>
           			</tr>
                </tfoot> 
       		</cf_grid_list>
        </cf_basket>  
        <cf_basket_form_button>
        	<cfif not isdefined('attributes.revision') and not attributes.kilit_stage>
              	<input type="checkbox" name="is_price_change" id="is_price_change" value="1" checked><cf_get_lang_main no ='133.Teklif'> <cf_get_lang no ='1532.Fiyatı Güncelle'>
         	</cfif>
        	<cfif get_product.is_prototip eq 1>
             	<cf_workcube_buttons is_upd='1' is_delete='0' add_function="control()">
         	<cfelse>
             	<font color="FF0000"><cf_get_lang no="870.Ürün Özelleştirilebilir Olmadığı İçin Spec Kaydedemezsiniz"> !</font>
         	</cfif>
        </cf_basket_form_button>
	</cf_box>
</cfform>

<script type="text/javascript">
	var row_count = document.form_basket.record_num.value;
	function aktar()
	{
		if(document.getElementById('uploaded_file').value == '')
		{
			alert('Lütfen Dosya Seçiniz!');	
			return false;
		}
		else
		{
			var sor = confirm('Dosyayı Aktarıyorsunuz !');
			if(sor==true)
			{
				document.getElementById("form_basket").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=prod.emptypopup_upd_ezgi_virtual_offer_row_spect_aktar";
				document.getElementById("form_basket").enctype = "multipart/form-data";
				document.getElementById("form_basket").submit();
				
			}
			else
				return false;
		}
	}
	function control()
	{
		if(parseFloat(filterNum(document.getElementById('total').value,2)) > 0)
		{
			document.getElementById("form_basket").action = "<cfoutput>#request.self#?fuseaction=prod.emptypopup_upd_ezgi_virtual_offer_row_spect_aktar&upd=1&toplam=#toplam#&money=#session.ep.money#&purchase_total=#purchase_total#&cost_total=#cost_total#</cfoutput>";
			document.getElementById("form_basket").submit();
			return true;
		}
		else
		{
			alert('Satır veya Birim Fiyat Giriniz!!');
			return false;
		}
	}
	function openProducts()
	{
		windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_list_ezgi_virtual_offer_material','list');
	}
	function sil(sy)
	{
		sil_sor = confirm('Malzeme Satırını Siliyorsunuz Emin misiniz?');
		if(sil_sor == 1)
		{
			var element=eval("form_basket.row_kontrol"+sy);
			element.value=0;
			var element=eval("frm_row"+sy); 
			element.style.display="none";	
			document.getElementById('amount'+sy).value = 0;
			document.getElementById('row_total'+sy).value = 0;
			sub_total();
		}
		else
		{
			return false;

		}
	}
	function add_row(price_cat_row_id,product_name,stock_code,sales_price,sales_price_money,purchase_price,purchase_price_money,cost_price,cost_price_money,is_rate)
	{
		row_count++;
		var newRow;
		var newCell;
		newRow = document.getElementById("new_row").insertRow(document.getElementById("new_row").rows.length);
		newRow.className = 'color-row';
		newRow.setAttribute("name","frm_row" + row_count);
		newRow.setAttribute("id","frm_row" + row_count);
		newRow.setAttribute("NAME","frm_row" + row_count);
		newRow.setAttribute("ID","frm_row" + row_count);
		document.form_basket.record_num.value = row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang_main no='51.Sil'>" border="0"></a>&nbsp;'+row_count+'&nbsp;';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" value="1" id="row_rate2_'+ row_count +'" name="row_rate2_'+ row_count +'">'
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'center';
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" id="product_code' + row_count +'" name="product_code' + row_count +'" value="'+stock_code+'" style="text-align:left;" readonly>';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" value="1" name="row_kontrol'+row_count+'">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'left';
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" id="product_name' + row_count +'" name="product_name' + row_count +'" value="'+product_name+'" style="text-align:left;" readonly>';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" id="amount' + row_count +'" name="amount' + row_count +'" value="<cfoutput>#TlFormat(1,2)#</cfoutput>" style="width:50px; text-align:right;" onchange="hesapla('+row_count+');">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'left';
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" id="sales_price' + row_count +'" name="sales_price' + row_count +'" value="'+commaSplit(sales_price,2)+'" style="width:70px; text-align:right;" onchange="hesapla('+row_count+');">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" id="sales_price_money' + row_count +'" name="sales_price_money' + row_count +'" value="'+sales_price_money+'" style="width:50px; text-align:left;" onchange="hesapla('+row_count+');">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'right';
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<input type="text" id="row_total' + row_count +'" name="row_total' + row_count +'" value="'+commaSplit(0,2)+'" style="width:70px; text-align:right;" onchange="hesapla('+row_count+');">';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.style.textAlign = 'left';
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<cfoutput>#session.ep.money#</cfoutput>';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" id="purchase_price' + row_count +'" name="purchase_price' + row_count +'" value="'+commaSplit(purchase_price,2)+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" id="purchase_price_money' + row_count +'" name="purchase_price_money' + row_count +'" value="'+purchase_price_money+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" id="cost_price' + row_count +'" name="cost_price' + row_count +'" value="'+commaSplit(cost_price,2)+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" id="cost_price_money' + row_count +'" name="cost_price_money' + row_count +'" value="'+cost_price_money+'">';
		newCell.innerHTML = newCell.innerHTML + '<input type="hidden" id="is_rate' + row_count +'" name="is_rate' + row_count +'" value="'+is_rate+'">';
		
		<cfoutput query="get_money">
			money_ = '#MONEY#';
			rate_ = #RATE2#;
			if(document.getElementById('sales_price_money'+row_count).value == money_)
			{
				document.getElementById('row_rate2_'+row_count).value = commaSplit(rate_,4);
			}
		</cfoutput>
		hesapla(row_count);
	}
	function hesapla(row)
	{
		
		document.getElementById('row_total'+row).value = commaSplit(parseFloat(filterNum(document.getElementById('sales_price'+row).value,2)) * parseFloat(filterNum(document.getElementById('amount'+row).value,2)) * parseFloat(filterNum(document.getElementById('row_rate2_'+row).value,4)),2);
		sub_total()
	}
	function sub_total()
	{
		document.getElementById('total').value = 0;
		for (var r=1;r<=document.form_basket.record_num.value;r++)
		{
			document.getElementById('total').value = commaSplit(parseFloat(filterNum(document.getElementById('total').value,2))+parseFloat(filterNum(document.getElementById('row_total'+r).value,2)),2);
		}
	}
</script>