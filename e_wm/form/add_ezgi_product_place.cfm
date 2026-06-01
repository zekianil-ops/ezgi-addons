<cfparam name="attributes.modal_id" default="">
<cf_get_lang_set module_name="product">
<cfinclude template="../query/get_ezgi_shelves.cfm">
<cfinclude template="../query/get_ezgi_shelves_type.cfm">
<cfquery name="packing_size_type" datasource="#dsn3#">
	SELECT PACKING_SIZE_TYPE_ID, PACKING_SIZE_TYPE_CODE + ' - ' + PACKING_SIZE_TYPE_NAME AS PACKING_SIZE_TYPE_NAME FROM EZGI_WM_SETUP_PACKING_SIZE_TYPE ORDER BY PACKING_SIZE_TYPE_CODE DESC
</cfquery>
<cfif isdefined("pid") and len(pid)>
	<cfquery name="GET_PRODUCT" datasource="#DSN3#">
		SELECT PRODUCT_ID, STOCK_ID, PRODUCT_NAME + ' ' + ISNULL(PROPERTY,'') AS PRODUCT_NAME FROM STOCKS WHERE PRODUCT_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.pid#">
	</cfquery>
</cfif>
<cfquery name="get_shelf_cat" datasource="#dsn3#">
	SELECT  EZGI_PLACE_CAT_ID, EZGI_PLACE_CAT FROM EZGI_WM_SETUP_PLACE_CAT
</cfquery>
<!--- <cf_catalystHeader> --->
<cf_box title="#getLang('','Raf Ekle',32038)#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
    <cfform name="add_product_plc" method="post" action="#request.self#?fuseaction=#fusebox.circuit#.emptypopup_add_product_place_act">
        <cf_box_elements>
            <div class="col col-12 col-md-12 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                <div class="form-group" id="item-place_status">
                    <label class="col col-2 col-xs-12"><cf_get_lang dictionary_id='57756.Durum'></label>
                    <div class="col col-2 col-xs-12"> 
                        <label><input type="checkbox" name="place_status" id="place_status" checked> <cf_get_lang dictionary_id='57493.aktif'></label>
                    </div>
                </div>
            </div>
            <div class="col col-6 col-md-12 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                <div class="form-group" id="item-txt_department_in">
                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='30031.Lokasyon'> *</label>
                    <div class="col col-8 col-xs-12"> 
                        <div class="input-group">
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='37412.Lokasyon Girmelisiniz'> !</cfsavecontent>
                            <cfif isdefined('attributes.dep_in') and len(attributes.dep_in)>
                                <input type="hidden" name="department_in" id="department_in" value="<cfoutput>#attributes.dep_in#</cfoutput>">
                                <cfinput type="text" name="txt_department_in" required="yes" message="#message#" value="#URLDecode(loc_name)#" readonly="yes">
                            <cfelse>
                                <input type="hidden" name="department_in" id="department_in">
                                <cfinput type="text" name="txt_department_in" required="yes" message="#message#" readonly="yes">
                            </cfif>
                            <span class="input-group-addon icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_stores_locations&form_name=add_product_plc&field_name=txt_department_in&field_id=department_in<cfif session.ep.isBranchAuthorization>&is_branch=1</cfif>','','ui-draggable-box-small');" title="<cf_get_lang dictionary_id='57582.Ekle'>"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-shelf_code">
                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='37540.Raf Kodu'> *</label>
                    <div class="col col-8 col-xs-12"> 
                        <cfsavecontent variable="message"><cf_get_lang dictionary_id='37539.Raf Kodu Girmelisiniz'> !</cfsavecontent>
                        <cfinput type="text" name="shelf_code" value="" required="yes" message="#message#">
                    </div>
                </div>
                <div class="form-group" id="item-shelf_type">
                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='37110.Raf Tipi'> *</label>
                    <div class="col col-8 col-xs-12"> 
                        <select name="shelf_type" id="shelf_type">
                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            <cfoutput query="get_shelves">
                                <option value="#shelf_id#">#shelf_name#</option>
                            </cfoutput>
                        </select>
                    </div>
                </div>
                <div class="form-group" id="item-shelf_size_type">
                    <label class="col col-4 col-xs-12">Adres Tipi </label>
                    <div class="col col-8 col-xs-12"> 
                        <select name="shelf_size_type" id="shelf_size_type">
                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            <cfoutput query="get_shelves_type">
                                <option value="#SHELF_SIZE_TYPE_ID#">#SHELF_SIZE_TYPE_CODE# - #SHELF_SIZE_TYPE_NAME#</option>
                            </cfoutput>
                        </select>
                    </div>
                </div>
                <div class="form-group" id="item-shelves_cat">
                    <label class="col col-4 col-xs-12">Raf Kategorisi</label>
                    <div class="col col-8 col-xs-12"> 
                        <select name="shelves_cat" id="shelves_cat">
                        	<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                            <cfoutput query="get_shelf_cat">
								<option value="#EZGI_PLACE_CAT_ID#">#EZGI_PLACE_CAT#</option>
							</cfoutput>
                        </select>
                    </div>
                </div>
                <div class="form-group" id="item-shelf_sort">
                    <label class="col col-4 col-xs-12">Öncelik Sıralaması </label>
                    <div class="col col-8 col-xs-12"> 
                        <select name="shelf_sort" id="shelf_sort">
                            <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                      		<option value="1" style="text-align:center">A</option>
                            <option value="2" style="text-align:center">B</option>
                            <option value="3" style="text-align:center">C</option>
                            <option value="4" style="text-align:center">D</option>
                            <option value="5" style="text-align:center">E</option>
			    <option value="6" style="text-align:center">F</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="col col-6 col-md-12 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                <div class="form-group" id="item-dimensions">
                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57713.Boyut'>(cm)</label>
                    <div class="col col-8 col-xs-12"> 
                        <div class="input-group">
                            <input name="WIDTH" id="WIDTH" placeholder="<cfoutput>#getLang('main','Genişlik',57695)#</cfoutput>" type="text">
                            <span class="input-group-addon no-bg"></span>
                            <input name="HEIGHT" id="HEIGHT" placeholder="<cfoutput>#getLang('stock','Derinlik',45200)#</cfoutput>" type="text"> 
                            <span class="input-group-addon no-bg"></span>
                            <input name="DEPTH" id="DEPTH" placeholder="<cfoutput>#getLang('main','Yükseklik',57696)#</cfoutput>" type="text"> 
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-detail">
                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                    <div class="col col-8 col-xs-12"> 
                        <textarea name="detail" id="detail" style="width:150px; height:60px"></textarea>
                    </div>
                </div>
                <div class="form-group" id="item-dates">
                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58690.Tarih Aralığı'></label>
                    <div class="col col-4 col-xs-12"> 
                        <div class="input-group">
                            <cfinput type="text" name="START_DATE" value="" validate="#validate_style#">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="START_DATE"></span>
                        </div>
                    </div>
                    <div class="col col-4 col-xs-12"> 
                        <div class="input-group">
                            <cfinput type="text" name="FINISH_DATE" value="" validate="#validate_style#">
                            <span class="input-group-addon"><cf_wrk_date_image date_field="FINISH_DATE"></span>
                        </div>
                    </div>
                </div>
                <div class="form-group" id="item-dates">
                    <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58908.Min'>/<cf_get_lang dictionary_id='58909.Min'> <cf_get_lang dictionary_id='57452.Stok'></label>
                    <div class="col col-4 col-xs-12"> 
                    	<cfinput type="text" name="min_stock" id="min_stock" value="#TlFormat(0,0)#" style="text-align:center">
                    </div>
                    <div class="col col-4 col-xs-12"> 
                    	<cfinput type="text" name="max_stock" id="max_stock" value="#TlFormat(0,0)#" style="text-align:center">
                    </div>
                </div>
              	<div class="form-group" id="item-dates">
                    <label class="col col-4 col-xs-12">Toplama Sıralaması</label>
                    <div class="col col-4 col-xs-12"> 
                    	<cfinput type="text" name="collect_sort" id="collect_sort" value="#TlFormat(0,0)#" style="text-align:center">
                    </div>
                </div>
            </div>
        </cf_box_elements>
            <div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="4" sort="true">
                <cf_seperator title="#getLang('main','Stoklar',58166)#" id="detail_seperator">
                <cf_grid_list id="detail_seperator">
                    <thead>
                        <!--- <tr>
                            <th style="background-color:#c9d8c5;" colspan="3"><cfoutput>#getLang('main',754)#</cfoutput></th>
                        </tr>  --->  
                        <tr>
                            <th width="20">
                                <input type="hidden" name="record_num" id="record_num" value="<cfif isdefined("pid") and len(pid) and get_product.recordcount><cfoutput>#get_product.recordcount#</cfoutput><cfelse>0</cfif>">
                                <a onclick="add_row();"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a>                         
                            </th>
                            <th width="300"><cf_get_lang dictionary_id='57452.Stok'></th>
                            <th width="200">Palet Tipi</th>
                            <th width="100"><cf_get_lang dictionary_id='57635.Miktar'></th>
                        </tr>
                    </thead>
                    <tbody name="new_row" id="new_row">
                        <cfif isdefined("pid") and len(pid) and get_product.recordcount>
                            <cfoutput query="get_product">
                                <tr name="frm_row" id="frm_row#currentrow#">
                                    <td><a onclick="sil(#currentrow#);"><i class="fa fa-minus" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
                                        <input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                                    </td>
                                    <td>
                                        <div class="form-group">
                                            <div class="input-group">
                                                <input type="hidden" name="pid#currentrow#" id="pid#currentrow#" value="#get_product.product_id#">
                                                <input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#" value="#get_product.stock_id#">
                                                <input type="text" name="urun#currentrow#" id="urun#currentrow#" value="#get_product.product_name#">
                                                <span class="input-group-addon icon-ellipsis" href="javascript://" onclick="pencere_ac(#currentrow#);"></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <input type="text" name="collect_type#currentrow#" id="collect_type#currentrow#" value="">
                                    </td>
                                    <td><input type="text" name="quantity#currentrow#" id="quantity#currentrow#" value="" onkeyup="isNumber(this);"></td>
                                </tr>
                            </cfoutput>
                        </cfif>
                    </tbody>
                </cf_grid_list>
            </div>
        <cf_box_footer>
            <cf_workcube_buttons type_format='1' is_upd='0' add_function="#iif(isdefined("attributes.draggable"),DE("kontrol_et() && loadPopupBox('add_product_plc' , #attributes.modal_id#)"),DE(""))#">
        </cf_box_footer>
    </cfform>
</cf_box>
<script type="text/javascript">
	var row_count=document.add_product_plc.record_num.value;
	function kontrol_et()
	{
		if(!date_check(document.add_product_plc.START_DATE, document.add_product_plc.FINISH_DATE, "<cf_get_lang dictionary_id='58862.Başlangıç Tarihi Bitiş Tarihinden Büyük Olamaz'>!")) return false;
		if(trim(document.add_product_plc.shelf_code.value) == '')
		{
			alert("<cf_get_lang dictionary_id='37539.Raf Kodu Girmelisiniz'>! ");
			return false;
		}
		
		if(document.add_product_plc.shelf_type.value == '')
		{
			alert("<cf_get_lang dictionary_id ='37722.Lütfen Raf Tipi Seçiniz'>!");
			return false;
		}
		return true;
	}
	
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
		
		document.add_product_plc.record_num.value = row_count;
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.innerHTML = '<a onclick="sil(' + row_count + ');"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>';	
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="hidden" value="1" name="row_kontrol' + row_count +'"><input type="text" name="urun' + row_count +'" id="urun'+ row_count +'" style="width:300px!important;"><input type="hidden" name="pid' + row_count +'" id="pid'+ row_count +'"><input type="hidden" name="stock_id' + row_count +'" id="stock_id' + row_count +'"><span class="input-group-addon icon-ellipsis" href"javascript://" onClick="pencere_ac('+ row_count +');"></span></div></div>';
		
		newCell = newRow.insertCell(newRow.cells.length);
		newCell.setAttribute("nowrap","nowrap");
		b = '<div class="form-group"><select name="collect_type' + row_count +'" id="collect_type' + row_count +'"><option value=""><cf_get_lang_main no='322.Seçiniz'></option>';
		<cfoutput query="packing_size_type">
				b += '<option value="#PACKING_SIZE_TYPE_ID#">#PACKING_SIZE_TYPE_NAME#</option>';
		</cfoutput>
		newCell.innerHTML = b + '</select></div>';
		
		newCell=newRow.insertCell(newRow.cells.length);
		newCell.setAttribute('nowrap','nowrap');
		newCell.innerHTML = '<div class="form-group"><input type="text" name="quantity' + row_count +'"  onkeyup="isNumber(this);" text-align:right;"></div>';
	}
	function pencere_ac(no)
	{
		openBoxDraggable("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=add_product_plc.pid" + no +"&field_id=add_product_plc.stock_id" + no +"&field_name=add_product_plc.urun" + no);
	}
	function sil(sy)
	{
		var element=eval("add_product_plc.row_kontrol"+sy);
		element.value=0;
		var element=eval("frm_row"+sy); 
		element.style.display="none";	
	} 
</script>
<cf_get_lang_set module_name="#lcase(listgetat(attributes.fuseaction,1,'.'))#">
