<!---
    File: add_ezgi_pallets_to_shipment_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Sevkiyata Ürün Hazırlama Ajax
--->
<cfparam name="attributes.anamenu" default="1">

<cfquery name="get_default_departments" datasource="#dsn3#">
	SELECT 
    	INTERMEDIATE_WAREHOUSE, 
        PRODUCTION_WAREHOUSE,
        SHELF_WAREHOUSE,
        FIRST_SHELF_ID,
        SHIPMENT_WAREHOUSE
	FROM     
    	EZGI_WM_SETUP_ROW WITH (NOLOCK)
	WHERE  
    	EMPLOYEE_POSITION_ID = #session.ep.POSITION_CODE#
</cfquery>
<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>
<cfset default_departments = '#ListGetAt(get_default_departments.SHELF_WAREHOUSE,1)#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
<cfparam name="attributes.department_in_id" default="#Replace(get_default_departments.SHELF_WAREHOUSE,',','-')#">
<cfparam name="attributes.department_out_id" default="#Replace(get_default_departments.SHELF_WAREHOUSE,',','-')#">
<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT 
		D.DEPARTMENT_HEAD,
		SL.DEPARTMENT_ID,
		SL.LOCATION_ID,
		SL.STATUS,
		SL.COMMENT,
        CAST(SL.DEPARTMENT_ID AS VARCHAR)+'-'+CAST(SL.LOCATION_ID AS VARCHAR) AS DEPO,
        D.DEPARTMENT_HEAD+'-'+SL.COMMENT AS DEPO_NAME
	FROM 
		STOCKS_LOCATION SL WITH (NOLOCK),
		DEPARTMENT D WITH (NOLOCK),
		BRANCH B WITH (NOLOCK)
	WHERE
		D.DEPARTMENT_ID IN (#default_departments#) AND
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
		SL.STATUS = 1 AND
		D.BRANCH_ID = B.BRANCH_ID
</cfquery>
<cfquery name="get_depo" dbtype="query">
	SELECT * FROM GET_ALL_LOCATION WHERE DEPO = '#Replace(attributes.department_out_id,',','-')#'
</cfquery>
<cfquery name="get_shipment_shelfs" datasource="#DSN3#">
	SELECT 
    	PRODUCT_PLACE_ID, 
        SHELF_CODE, 
        DETAIL
	FROM     
    	PRODUCT_PLACE WITH (NOLOCK)
	WHERE  
    	SHELF_TYPE = 5 AND 
        STORE_ID = #ListGetAt(get_default_departments.SHELF_WAREHOUSE,1)# AND 
        LOCATION_ID = #ListGetAt(get_default_departments.SHELF_WAREHOUSE,2)# AND 
        PLACE_STATUS = 1
	ORDER BY 
    	SHELF_CODE
</cfquery>
<cfif isdefined('attributes.ship_id') and len(attributes.ship_id)>
	<cfif attributes.is_type eq 1>
        <cfquery name="get_control" datasource="#dsn3#">
            SELECT 
                (
                    SELECT 
                        SHELF_CODE 
                    FROM 
                        PRODUCT_PLACE WITH (NOLOCK)
                    WHERE 
                        PRODUCT_PLACE_ID=E.SHIPMENT_PRODUCT_PLACE_ID   
                ) AS SHELF_CODE, 
                ISNULL(SHIPMENT_PRODUCT_PLACE_ID, 0) AS SHIPMENT_PRODUCT_PLACE_ID,
                DELIVER_PAPER_NO
            FROM 
                EZGI_SHIP_RESULT E
            WHERE 
                SHIP_RESULT_ID = #attributes.ship_id#
        </cfquery>
    <cfelse>
        <cfquery name="get_control" datasource="#dsn3#">
        	SELECT 
                (
                    SELECT 
                        SHELF_CODE 
                    FROM 
                        PRODUCT_PLACE WITH (NOLOCK)
                    WHERE 
                        PRODUCT_PLACE_ID=E.SHIPMENT_PRODUCT_PLACE_ID   
                ) AS SHELF_CODE, 
                ISNULL(SHIPMENT_PRODUCT_PLACE_ID, 0) AS SHIPMENT_PRODUCT_PLACE_ID,
                CAST(SHIP_RESULT_INTERNALDEMAND_ID AS VARCHAR) AS DELIVER_PAPER_NO
            FROM 
                EZGI_SHIP_RESULT_INTERNALDEMAND E
            WHERE 
                SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
        </cfquery>
    </cfif>

    <cfsavecontent variable="title_"><cf_get_lang dictionary_id='1311.Stoklama Rafına Transfer İşlemi'></cfsavecontent>
    <cf_catalystHeader>
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cfform name="add_ezgi_pallets_to_storage_shelf_warehouse" >
            <cf_box>
                <cf_basket_form id="add_ezgi_pallets_to_storage_shelf_warehouse">
                    <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
                                    <cfif get_control.SHIPMENT_PRODUCT_PLACE_ID eq 0>
                                        <div class="col col-12"  id="zero_area" >
                                            <div class="col col-12">
                                                <div class="col col-3">
                                                    <label><cf_get_lang dictionary_id='1316.Sevkiyat Alanı'></label>
                                                </div>
                                                <div class="col col-8">
                                                    <div class="form-group" id="item-sevkiyat_raf">
                                                        <select name="txt_shelf_out" id="txt_shelf_out" >
                                                            <cfoutput query="get_shipment_shelfs" >
                                                                <option value="#PRODUCT_PLACE_ID#">#SHELF_CODE#</option>
                                                            </cfoutput>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="col col-1">
                                                    <div class="form-group" id="item-sevkiyat">
                                                    <input id="shipment_area_confirm" name="shipment_area_confirm" value="<cf_get_lang dictionary_id="58693.Seç">" type="button" onClick="shipment_area();" />
                                                    </div>
                                                    <div id="shelf_div"></div>
                                                </div>
                                                
                                            </div>
                                        </div>
                                    <cfelse>
                                        <cfinput type="hidden" name="txt_shelf_out" id="txt_shelf_out" value="#get_control.SHIPMENT_PRODUCT_PLACE_ID#">
                                    </cfif>
                                    <div class="col col-12 uniqueRow" id="first_area" <cfif get_control.SHIPMENT_PRODUCT_PLACE_ID eq 0>style="display:none"</cfif>>
                                        <div class="col col-12">
                                            <div class="col col-3">
                                                <label><cf_get_lang dictionary_id='57637.Seri No'></label>
                                            </div>
                                            <div class="col col-9">
                                                <div class="form-group" id="item-barcod">
                                                    <input id="add_other_barcod" name="add_other_barcod" type="text" value="">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col col-12" id="third_area" <cfif get_control.SHIPMENT_PRODUCT_PLACE_ID eq 0>style="display:none"</cfif>>
                                        <div class="col col-12">
                                            <div class="col col-3">
                                                <label><cf_get_lang dictionary_id='1316.Sevkiyat Alanı'></label>
                                            </div>
                                            <div class="col col-3">
                                                <div class="form-group" id="item-giris_raf">
                                                    <cfinput type="text" name="txt_shelf_in_name" id="txt_shelf_in_name" value="#get_control.SHELF_CODE#">
                                                    <cfinput type="hidden" name="txt_shelf_in" id="txt_shelf_in" value="#get_control.SHIPMENT_PRODUCT_PLACE_ID#">
                                                </div>
                                            </div>
                                            <div class="col col-6">
                                                <div class="form-group" id="item-giris">
                                                    <cfinput type="text" name="txt_department_in_name" id="txt_department_in_name" value="#get_depo.DEPO_NAME#" readonly="">
                                                    <cfinput type="hidden" name="txt_department_in" id="txt_department_in" value="#get_depo.DEPO#">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col col-12" id="fourth_area" <cfif get_control.SHIPMENT_PRODUCT_PLACE_ID eq 0>style="display:none"</cfif>>
                                        <div class="col col-12">
                                            <div class="col col-3">
                                                <label><cf_get_lang dictionary_id='45363.Kontrol Edilen Miktar'></label>
                                            </div>
                                            <cfoutput>
                                            <div class="col col-3">
                                                <div class="form-group" id="item-serial_control">
                                                    <input type="text" name="total_control_amount" readonly="readonly" class="box" style="width:25px;text-align:right;font-weight:bold;color:FF0000;" id="total_control_amount" value="" />
                                                </div>
                                            </div>
                                            <div class="col col-6">
                                                <div class="form-group" id="item-serial_controled">
                                                    <input type="text" name="total_paket_sayisi" readonly="readonly" class="box" style="width:25px;text-align:right;font-weight:bold;color:FF0000;" id="total_paket_sayisi" value="" />
                                                </div>
                                            </div>
                                            </cfoutput>
                                        </div>
                                    </div>
                                    <div class="col col-12" id="second_area" style="display:none">
                                        <div class="col col-12">
                                            <div class="col col-3">
                                                <label><cf_get_lang dictionary_id='43312.Çıkış Rafı'></label>
                                            </div>
                                            <div class="col col-3">
                                                <div class="form-group" id="item-cikis_raf">
                                                    <cfinput type="text" name="txt_shelf_out_name" id="txt_shelf_out_name" value="">
                                                    <cfinput type="hidden" name="txt_shelf_out" id="txt_shelf_out" value="">
                                                </div>
                                            </div>
                                            <div class="col col-6">
                                                <div class="form-group" id="item-cikis">
                                                    <cfinput type="text" name="txt_department_out_name" id="txt_department_out_name" value="#get_depo.DEPO_NAME#">
                                                    <cfinput type="hidden" name="txt_department_out" id="txt_department_out" value="#get_depo.DEPO#">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </cf_box_elements>
                                <cf_box_footer>
                                    <div class="col col-12">
                                        <div class="col col-6" style="text-align:right">
                                           </div>
                                        <div class="col col-6" style="text-align:right;display:none" id="onay_div">
                                            <input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" onClick="kontrol_kayit(1);" />
                                        </div>
                                    </div>
                                </cf_box_footer>
                            </div>
                        </div>
                    </div>
                </cf_basket_form>
            </cf_box>
           
            <cfsavecontent variable="sekme1"><cf_get_lang dictionary_id="57718.Seri No lar"></cfsavecontent>
            <cfsavecontent variable="sekme2"><cf_get_lang dictionary_id="57564.Ürünler"></cfsavecontent>
            <div id="basket_main_div">
                <div class="row">
                    <div class="col col-12 uniqueRow">
                        <cf_basket_form id="upd_connect" class="row">
                            <div id="tab-container" class="tabStandart margin-top-5">
                                <div id="tab-head">
                                    <ul class="tabNav">
                                        <li class="<cfif attributes.anamenu eq 1>active</cfif>"><a id="href_sekme1" href="#ship_result_list" onclick="SerialNoListAjax()";><cfoutput>#sekme1#</cfoutput></a></li>
                                        <li class="<cfif attributes.anamenu eq 2>active</cfif>"><a id="href_sekme2" href="#ship_result_list" onclick="ProductListAjax();"><cfoutput>#sekme2#</cfoutput></a></li>
                                        
                                    </ul>
                                </div>
                                <div id="tab-content" class="margin-top-10"> 
                                    <div id="ship_result_list" class="content row">
                                        
                                    </div>
                                </div>
                            </div>
                        </cf_basket_form>
                    </div>
                </div>                     
            </div>
        </cfform>
    </div>
    <div id="serial_div"></div>

    <script language="javascript" type="text/javascript">
        document.getElementById('add_other_barcod').focus();
        setTimeout("document.getElementById('add_other_barcod').select();",1000);
        document.onkeydown = checkKeycode
        function checkKeycode(e) /*Barkod Okuyup Enter Basıldığında*/
        {
            var keycode;
            if (window.event) keycode = window.event.keyCode;
            else if (e) keycode = e.which;
            if (keycode == 13)
            {
                if (document.getElementById('add_other_barcod').value.length == '') /*Barkod Boşsa*/
                {
                    alert('<cf_get_lang dictionary_id='340.Önce Ürün Barkodu Okutunuz'>'); 
                    document.getElementById('add_other_barcod').value = '';
                    document.getElementById('add_other_barcod').focus();	
                }
                else /*Barkod Doluysa*/
                {
					AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_to_shipment_warehouse&type=2&ship_id=#attributes.ship_id#&is_type=#attributes.is_type#&ship_number=#get_control.DELIVER_PAPER_NO#</cfoutput>&serial_no='+document.getElementById('add_other_barcod').value+'&to_shelf_id='+document.getElementById('txt_shelf_in').value+'&to_department_loctaion_id='+document.getElementById('txt_department_in').value,'ship_result_list',1);
					document.getElementById('add_other_barcod').value='';
					document.getElementById('add_other_barcod').focus();
                }
            }
        }
		function shipment_area()
        {
            out_shelf_id=document.getElementById('txt_shelf_out').value;
			AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_to_shipment_warehouse&type=3&ship_id=#attributes.ship_id#&is_type=#attributes.is_type#&out_shelf_id='+out_shelf_id+'</cfoutput>','shelf_div',1)	
        }
		function SerialNoListAjax()
        {
            AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_to_shipment_warehouse&type=2&ship_id=#attributes.ship_id#&is_type=#attributes.is_type#&ship_number=#get_control.DELIVER_PAPER_NO#</cfoutput>','ship_result_list',1);
			document.getElementById('add_other_barcod').focus();
        }
		function ProductListAjax()
        {
            AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_to_shipment_warehouse&type=1&ship_id=#attributes.ship_id#&is_type=#attributes.is_type#&ship_number=#get_control.DELIVER_PAPER_NO#</cfoutput>','ship_result_list',1);
			document.getElementById('add_other_barcod').focus();
        }
		function sil(serialno)
		{
			soru=confirm(serialno+' Seri Nolu Ürünü Rezervasyondan Çıkarıyorum ?')
			if(soru==true)
			{
				AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_to_shipment_warehouse&type=2&sil=1&ship_id=#attributes.ship_id#&is_type=#attributes.is_type#&ship_number=#get_control.DELIVER_PAPER_NO#</cfoutput>&serial_no='+serialno,'ship_result_list',1);
				document.getElementById('add_other_barcod').value='';
				document.getElementById('add_other_barcod').focus();
			}
			else
				return false;
		}
		window.onload = function() {
    	SerialNoListAjax(); // Sayfa yüklendiğinde varsayılan sekme içeriğini getir
};
	</script>
</cfif>
