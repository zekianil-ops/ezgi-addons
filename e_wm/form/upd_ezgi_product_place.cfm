<cfparam name="attributes.modal_id" default="">
<cf_get_lang_set module_name="product">
<cfquery name="packing_size_type" datasource="#dsn3#">
	SELECT PACKING_SIZE_TYPE_ID, PACKING_SIZE_TYPE_CODE + ' - ' + PACKING_SIZE_TYPE_NAME AS PACKING_SIZE_TYPE_NAME FROM EZGI_WM_SETUP_PACKING_SIZE_TYPE ORDER BY PACKING_SIZE_TYPE_CODE DESC
</cfquery>
<cfquery name="get_shelf_cat" datasource="#dsn3#">
	SELECT  EZGI_PLACE_CAT_ID, EZGI_PLACE_CAT FROM EZGI_WM_SETUP_PLACE_CAT
</cfquery>
<cfif isnumeric(attributes.product_place_id)>
	<cfinclude template="../query/get_ezgi_product_place.cfm">
	<cfinclude template="../query/get_ezgi_shelves.cfm">
    <cfinclude template="../query/get_ezgi_shelves_type.cfm">
<cfelse>
	<cfset get_product_place.recordcount = 0> 
</cfif>
<cfif not get_product_place.recordcount>
	<cfset hata  = 11>
	<cfsavecontent variable="message"><cf_get_lang dictionary_id='57997.Şube Yetkiniz Uygun Değil'> <cf_get_lang dictionary_id='57998.Veya'> <cf_get_lang dictionary_id='58943.Böyle Bir Kayıt Bulunmamaktadır'> !</cfsavecontent>
	<cfset hata_mesaj  = message>
	<cfinclude template="../../dsp_hata.cfm">
<cfelse>
    <cfquery name="get_our_comps" datasource="#dsn#">
        SELECT PERIOD_YEAR,OUR_COMPANY_ID FROM SETUP_PERIOD WHERE OUR_COMPANY_ID = #session.ep.company_id#
    </cfquery>
    <cfquery name="GET_CONTROL" datasource="#DSN#">
        <cfloop query="get_our_comps">
            <cfset new_dsn2 = '#dsn#_#get_our_comps.period_year#_#get_our_comps.our_company_id#'>
                SELECT
                    SHELF_NUMBER
                FROM
                    #new_dsn2#.STOCKS_ROW
                WHERE 
                    SHELF_NUMBER = #attributes.product_place_id#
            <cfif get_our_comps.recordcount neq currentrow>
                UNION
            </cfif>	
        </cfloop>
    </cfquery>
    <cfquery name="get_control_2" datasource="#dsn3#"> <!---Rafta Ürün var mı--->
    	SELECT SERIAL_NO FROM EZGI_WM_SERIAL_NO_LAST_STATUS WHERE PRODUCT_PLACE_ID = #attributes.product_place_id#
    </cfquery>
    <!--- <cf_catalystHeader> --->
    <cf_box title="#getLang('','Raf',45667)# : #get_product_place.product_place_id#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
        <cfform name="add_product_plc" method="post" action="#request.self#?fuseaction=#fusebox.circuit#.emptypopup_upd_product_place_act">
            <input type="hidden" name="product_place_id" id="product_place_id" value="<cfif isdefined('attributes.product_place_id') and len(attributes.product_place_id)><cfoutput>#attributes.product_place_id#</cfoutput></cfif>">
            <cf_box_elements>
                <div class="col col-12 col-md-12 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                    <div class="form-group" id="item-place_status">
                        <label class="col col-2 col-xs-12"><cf_get_lang dictionary_id='57756.Durum'></label>
                        <div class="col col-2 col-xs-12"> 
                        	<cfif get_control_2.recordcount>
                            	<span style="color:red">Rafta Ürün Mevcut</span>
                                <input type="hidden" name="place_status" id="place_status" value="1">
                            <cfelse>
                            	<label>
                                	<input type="checkbox" name="place_status" id="place_status"<cfif get_product_place.place_status>checked</cfif>> <cf_get_lang dictionary_id='57493.aktif'>
                               	</label>
                            </cfif>
                        </div>
                    </div>
                </div>
                <div class="col col-6 col-md-12 col-sm-6 col-xs-12" type="column" index="2" sort="true">
                    <div class="form-group" id="item-txt_department_in">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='30031.Lokasyon'> *</label>
                        <div class="col col-8 col-xs-12"> 
                            <div <cfif not get_control.recordcount>class="input-group"</cfif>>
                                <input type="hidden" name="department_in" id="department_in" value="<cfif len(get_product_place.location_id)><cfoutput>#get_product_place.store_id#-#get_product_place.location_id#</cfoutput><cfelse><cfoutput>#get_product_place.store_id#</cfoutput></cfif>">
                                <input type="text" name="txt_department_in" id="txt_department_in" value="<cfoutput>#get_location_info(get_product_place.store_id,get_product_place.location_id,1)#</cfoutput>" readonly>
                                <cfif not get_control.recordcount> <!--- raf kullanılmıssa, raf lokasyonu degistirilmemeli --->
                                    <span class="input-group-addon icon-ellipsis" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_list_stores_locations&form_name=add_product_plc&field_name=txt_department_in&field_id=department_in<cfif session.ep.isBranchAuthorization>&is_branch=1</cfif>','','ui-draggable-box-small');" title="<cf_get_lang dictionary_id='57582.Ekle'>"></span>
                                </cfif>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-shelf_code">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='37540.Raf Kodu'> *</label>
                        <div class="col col-8 col-xs-12"> 
                            <cfsavecontent variable="message"><cf_get_lang dictionary_id='37539.Raf Kodu Girmelisiniz'>!</cfsavecontent>
                            <cfif not get_control.recordcount>
                                <cfinput type="text" name="shelf_code" value="#get_product_place.shelf_code#" required="yes" message="#message#">
                            <cfelse>
                                <cfinput type="text" name="shelf_code" value="#get_product_place.shelf_code#" readonly="yes" required="yes" message="#message#">
                            </cfif>
                        </div>
                    </div>
                    <div class="form-group" id="item-shelf_type">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='37110.Raf Tipi'> *</label>
                        <div class="col col-8 col-xs-12"> 
                            <select name="shelf_type" id="shelf_type">
                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <cfoutput query="get_shelves">
                                    <option value="#shelf_id#" <cfif shelf_id eq get_product_place.shelf_type> selected</cfif>>#shelf_name#</option>
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
                                    <option value="#SHELF_SIZE_TYPE_ID#" <cfif SHELF_SIZE_TYPE_ID eq get_product_place.SHELF_SIZE_TYPE> selected</cfif>>#SHELF_SIZE_TYPE_CODE# - #SHELF_SIZE_TYPE_NAME#</option>
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
								<option value="#EZGI_PLACE_CAT_ID#" <cfif EZGI_PLACE_CAT_ID eq get_product_place.PLACE_CAT_ID> selected</cfif>>#EZGI_PLACE_CAT#</option>
							</cfoutput>
                        </select>
                    </div>
                </div>
                    <div class="form-group" id="item-shelf_sort">
                        <label class="col col-4 col-xs-12">Öncelik Sıralaması </label>
                        <div class="col col-8 col-xs-12"> 
                            <select name="shelf_sort" id="shelf_sort">
                                <option value="" <cfif  get_product_place.SHELF_SORT eq ''> selected</cfif>><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                <option value="1" style="text-align:center" <cfif  get_product_place.SHELF_SORT eq 1> selected</cfif>>A</option>
                                <option value="2" style="text-align:center" <cfif  get_product_place.SHELF_SORT eq 2> selected</cfif>>B</option>
                                <option value="3" style="text-align:center" <cfif  get_product_place.SHELF_SORT eq 3> selected</cfif>>C</option>
                                <option value="4" style="text-align:center" <cfif  get_product_place.SHELF_SORT eq 4> selected</cfif>>D</option>
                                <option value="5" style="text-align:center" <cfif  get_product_place.SHELF_SORT eq 5> selected</cfif>>E</option>
				<option value="6" style="text-align:center" <cfif  get_product_place.SHELF_SORT eq 6> selected</cfif>>F</option>
                            </select>
                        </div>
                    </div>
                </div>
               	<div class="col col-6 col-md-12 col-sm-6 col-xs-12" type="column" index="3" sort="true">
                    <div class="form-group" id="item-dimensions">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57713.Boyut'>(cm)</label>
                        <div class="col col-8 col-xs-12"> 
                            <div class="input-group">
                                <cfinput name="WIDTH" id="WIDTH" value="#get_product_place.width#" placeholder="#getLang('main','Genişlik',57695)#" type="text">
                                <span class="input-group-addon no-bg"></span>
                                <cfinput name="HEIGHT" id="HEIGHT" value="#get_product_place.height#" placeholder="#getLang('stock','Derinlik',45200)#" type="text"> 
                                <span class="input-group-addon no-bg"></span>
                                <cfinput name="DEPTH" id="DEPTH" value="#get_product_place.depth#" placeholder="#getLang('main','Yükseklik',57696)#" type="text"> 
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-detail">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='57629.Açıklama'></label>
                        <div class="col col-8 col-xs-12"> 
                            <textarea name="detail" id="detail" style="width:150px; height:55px"><cfoutput>#get_product_place.detail#</cfoutput></textarea>
                        </div>
                    </div>
                    <div class="form-group" id="item-dates">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58690.Tarih Aralığı'></label>
                        <div class="col col-4 col-xs-12"> 
                            <div class="input-group">
                                <cfinput value="#dateformat(get_product_place.start_date,dateformat_style)#" validate="#validate_style#" type="text" name="START_DATE">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="START_DATE"></span>
                            </div>

                        </div>
                        <div class="col col-4 col-xs-12"> 
                            <div class="input-group">
                                <cfinput value="#dateformat(get_product_place.finish_date,dateformat_style)#" validate="#validate_style#" type="text" name="FINISH_DATE">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="FINISH_DATE"></span>
                            </div>
                        </div>
                    </div>
                    <div class="form-group" id="item-dates">
                        <label class="col col-4 col-xs-12"><cf_get_lang dictionary_id='58908.Min'>/<cf_get_lang dictionary_id='58909.Min'> <cf_get_lang dictionary_id='57452.Stok'></label>
                        <div class="col col-4 col-xs-12"> 
                            <cfinput type="text" name="min_stock" id="min_stock" value="#TlFormat(get_product_place.min_stock,0)#" style="text-align:center">
                        </div>
                        <div class="col col-4 col-xs-12"> 
                            <cfinput type="text" name="max_stock" id="max_stock" value="#TlFormat(get_product_place.max_stock,0)#" style="text-align:center">
                        </div>
                    </div>
                    <div class="form-group" id="item-collect_sort">
                        <label class="col col-4 col-xs-12">Toplama Sıralaması</label>
                        <div class="col col-4 col-xs-12"> 
                            <cfinput type="text" name="collect_sort" id="collect_sort" value="#TlFormat(get_product_place.collect_sort,0)#" style="text-align:center">
                        </div>
                    </div>
                </div>
            </cf_box_elements>
            <cf_box_footer>
                <cf_record_info query_name="get_product_place" record_emp="record_emp"  record_date="record_date" update_emp="update_emp" update_date="update_date">
                <cf_workcube_buttons type_format='1' is_upd='1' add_function="#iif(isdefined("attributes.draggable"),DE("kontrol_et() && loadPopupBox('add_product_plc' , #attributes.modal_id#)"),DE(""))#" is_delete='0'>
            </cf_box_footer>
                <div class="col col-12 col-md-12 col-sm-12 col-xs-12" type="column" index="4" sort="true">
                    <cf_seperator title="#getLang('main','Stoklar',58166)#" id="detail_seperator">
                    <cf_grid_list id="detail_seperator">
                        <thead>
                            <tr>
                                <th width="20">
                                    <input type="hidden" name="record_num" id="record_num" value="<cfoutput>#get_prod_place_rows.recordcount#</cfoutput>">
                                    <a onclick="add_row();"><i class="fa fa-plus" title="<cf_get_lang dictionary_id='57582.Ekle'>" alt="<cf_get_lang dictionary_id='57582.Ekle'>"></i></a></th>
                                <th width="330"><cf_get_lang dictionary_id='57452.Stok'></th>
                                <th width="200"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                                <th width="200">Palet Tipi</th>
                                <th width="50"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            </tr>
                        </thead>
                        <tbody name="new_row" id="new_row">
                            <cfif get_prod_place_rows.recordcount and len(GET_PRODUCT_PLACE.PRODUCT_PLACE_ID)>
                                <cfoutput query="get_prod_place_rows">
                                    <tr name="frm_row" id="frm_row#currentrow#">
                                        <td>
                                            <a onclick="sil(#currentrow#);"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
                                            <input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                                        </td>
                                        <td>
                                                <div class="form-group">  
                                                    <div class="input-group">
                                                <input type="hidden" name="pid#currentrow#" id="pid#currentrow#" value="#get_prod_place_rows.product_id#">
                                                <input type="hidden" name="stock_id#currentrow#" id="stock_id#currentrow#" value="#get_prod_place_rows.stock_id#">
                                                <input type="text" name="urun#currentrow#" id="urun#currentrow#" value="#get_prod_place_rows.product_name#">
                                                <span class="input-group-addon icon-ellipsis"  href="javascript://" onclick="pencere_ac(#currentrow#);"></span>
                                            </div>     
                                        </div>      
                                        </td>
                                        <td>
                                            <div class="form-group">
                                                <input type="text" tabindex="text" name="stock_code#currentrow#" id="stock_code#currentrow#" readonly="readonly" value="#STOCK_CODE#" />
                                            </div>     
                                        </td>
                                        <td>
                                            <div class="form-group">
                                                <select name="collect_type#currentrow#" id="collect_type#currentrow#">
                                                	<option value=""><cf_get_lang_main no='322.Seçiniz'></option>
                                                    <cfloop query="packing_size_type">
                                                    	<option value="#PACKING_SIZE_TYPE_ID#" <cfif get_prod_place_rows.PACKING_SIZE_TYPE_ID eq packing_size_type.PACKING_SIZE_TYPE_ID>selected</cfif>>#PACKING_SIZE_TYPE_NAME#</option>
                                                    </cfloop>
                                                </select>
                                            </div>    
                                        </td>
                                        <td>
                                            <div class="form-group">
                                                <input type="text" name="quantity#currentrow#" id="quantity#currentrow#" value="#get_prod_place_rows.amount#" onkeyup="isNumber(this);" style="text-align:right;">
                                            </div>
                                        </td>    
                                    </tr>
                                </cfoutput>
                            </cfif>
                        </tbody>
                    </cf_grid_list>
                </div>
           
            
        </cfform>
    </cf_box>
</cfif>
<script type="text/javascript">
var row_count=document.add_product_plc.record_num.value;
function kontrol_et() 
{
	 if(document.add_product_plc.shelf_type.value == '' )
	 {
		 alert("<cf_get_lang dictionary_id ='37722.Lütfen Raf Tipi Seçiniz'>!"); 
		 return false; 
	 }
	 
	 if(!date_check(document.add_product_plc.START_DATE, document.add_product_plc.FINISH_DATE, "<cf_get_lang dictionary_id='58862.Başlangıç Tarihi Bitiş Tarihinden Büyük Olamaz'>!")) return false;
	
	document.add_product_plc.place_status.disabled = false;
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
	newCell.innerHTML = '<a onclick="sil(' + row_count + ');" ><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>';	
		
	newCell=newRow.insertCell(newRow.cells.length);
	newCell.setAttribute('nowrap','nowrap');
	newCell.innerHTML = '<div class="form-group"><div class="input-group"><input type="hidden" value="1" name="row_kontrol' + row_count +'"><input type="text" name="urun' + row_count +'" id="urun'+ row_count +'"><input type="hidden" name="pid' + row_count +'" id="pid'+ row_count +'"><input type="hidden" name="stock_id' + row_count +'" id="stock_id' + row_count +'"><span class="input-group-addon icon-ellipsis" href"javascript://" onClick="pencere_ac('+ row_count +');"></span></div></div>';
	
	newCell=newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '<div class="form-group"><input type="text" name="stock_code' + row_count +'" id="stock_code'+ row_count +'" readonly></div>';
	
	newCell = newRow.insertCell(newRow.cells.length);
	b = '<div class="form-group"><select name="collect_type' + row_count +'" id="collect_type' + row_count +'"><option value=""><cf_get_lang_main no='322.Seçiniz'></option>';
	<cfoutput query="packing_size_type">
		b += '<option value="#PACKING_SIZE_TYPE_ID#">#PACKING_SIZE_TYPE_NAME#</option>';
	</cfoutput>
	newCell.innerHTML = b + '</select></div>';
	
	newCell=newRow.insertCell(newRow.cells.length);
	newCell.innerHTML = '<div class="form-group"><input type="text" name="quantity' + row_count +'" onkeyup="isNumber(this);"></div>';
}
function pencere_ac(no)
{
	openBoxDraggable("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_names&product_id=add_product_plc.pid" + no +"&field_id=add_product_plc.stock_id" + no +"&field_name=add_product_plc.urun" + no+"&field_special_code=add_product_plc.special_code" + no +"&field_code=add_product_plc.stock_code" + no);
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

