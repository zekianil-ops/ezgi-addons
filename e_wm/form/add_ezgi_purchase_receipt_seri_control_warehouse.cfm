<!---
    File: add_ezgi_purchase_receipt_seri_control_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Mal Alım İrsaliyesi Seri No Kontrol
--->
<!---<cfdump var="#attributes#"><cfabort>--->
<cfparam name="attributes.anamenu" default="1">
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
		STOCKS_LOCATION SL,
		DEPARTMENT D,
		BRANCH B
	WHERE
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
		SL.STATUS = 1 AND
		D.BRANCH_ID = B.BRANCH_ID
</cfquery>

<cfquery name="GET_SHIP_INFO" datasource="#dsn2#">
	SELECT SHIP_NUMBER, COMPANY_ID, SHIP_DATE, IS_DELIVERED FROM SHIP WHERE SHIP_ID = #attributes.ship_id#
</cfquery>

<cfquery name="get_company_control" datasource="#DSN#">
    SELECT EZGI_COMPANY_OUR_COMPANY_ID, OUR_COMPANY_ID FROM EZGI_COMPANY_OUR_COMPANY_RELATED WHERE COMPANY_ID = #GET_SHIP_INFO.COMPANY_ID#
</cfquery>

<cfif not get_company_control.recordcount>
	<script type="text/javascript">
		alert("Şirket ve Bizim Şirket Tanımı yapılmamış");
		history.back();	
	</script>
    <cfabort>
</cfif>

<cfquery name="get_period" datasource="#dsn#">
	SELECT PERIOD_ID FROM SETUP_PERIOD WHERE PERIOD_YEAR = #year(GET_SHIP_INFO.SHIP_DATE)# AND OUR_COMPANY_ID = #get_company_control.OUR_COMPANY_ID#
</cfquery>

<cfset new_dsn3 = '#dsn#_#get_company_control.OUR_COMPANY_ID#'>
<cfset new_dsn2 = '#dsn#_#year(GET_SHIP_INFO.SHIP_DATE)#_#get_company_control.OUR_COMPANY_ID#'>

<cfquery name="get_old_ship_control" datasource="#new_dsn2#">
	SELECT SHIP_ID FROM SHIP WHERE  SHIP_NUMBER = '#GET_SHIP_INFO.SHIP_NUMBER#'
</cfquery>

<cfif not get_old_ship_control.recordcount>
	<script type="text/javascript">
		alert("<cfoutput>#GET_SHIP_INFO.SHIP_NUMBER#</cfoutput> Nolu İrsaliye Gönderilen Şirkette Bulunamamıştır.");
		history.back();	
	</script>
    <cfabort>
</cfif>








<cfsavecontent variable="title_"><cf_get_lang dictionary_id='1375.Alım İrsaliyesi Seri No Kontrol'></cfsavecontent>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        
            <cf_box>
                <cf_basket_form id="add_ezgi_pallets_to_storage_shelf_warehouse">
                    <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
                                    
                                    <div class="col col-12 uniqueRow" id="first_area">
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
                                </cf_box_elements>
                            </div>
                        </div>
                    </div>
                </cf_basket_form>
            </cf_box>
            <cfsavecontent variable="sekme1"><cf_get_lang dictionary_id="29581.Mal Alım İrsaliyesi"></cfsavecontent>
            <cfsavecontent variable="sekme2"><cf_get_lang dictionary_id="54447.Kontrol Edilenler"></cfsavecontent>
            <cfsavecontent variable="sekme3"><cf_get_lang dictionary_id="54448.Kontrol Edilmeyenler"></cfsavecontent>
            <div id="basket_main_div">
                <div class="row">
                    <div class="col col-12 uniqueRow">
                        <cf_basket_form id="upd_connect" class="row">
                            <div id="tab-container" class="tabStandart margin-top-5">
                                <div id="tab-head">
                                    <ul class="tabNav">
                                        <li class="<cfif attributes.anamenu eq 1>active</cfif>"><a id="href_urunler" href="#ship_list" onclick="ShipListAjax()";><cfoutput>#sekme1#</cfoutput></a></li>
                                        <li class="<cfif attributes.anamenu eq 2>active</cfif>"><a id="href_minfo" href="#ship_list" onclick="ControlAjax();"><cfoutput>#sekme2#</cfoutput></a></li>
                                      	<li class="<cfif attributes.anamenu eq 3>active</cfif>"><a id="href_minfo1" href="#ship_list" onclick="NoControlAjax();"><cfoutput>#sekme3#</cfoutput></a></li>
                                    </ul>
                                </div>
                                <div id="tab-content" class="margin-top-10"> 
                                    <div id="ship_list" class="content row">
                                        
                                    </div>
                                    <div id="icerik" class="content row">

                                    </div>
                                    
                                    <div id="icerik2" class="content row">

                                    </div>
                                    
                                </div>
                            </div>
                        </cf_basket_form>
                    </div>
                </div>                     
            </div>                         
       
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
					AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_purchase_receipt_seri_control_warehouse&type=0&new_dsn2=#new_dsn2#&new_dsn3=#new_dsn3#&ship_id=#attributes.ship_id#&old_ship_id=#get_old_ship_control.SHIP_ID#&period_id=#get_period.PERIOD_ID#</cfoutput>&barcode='+document.getElementById('add_other_barcod').value,'ship_list',1);
					document.getElementById('add_other_barcod').value='';
					document.getElementById('add_other_barcod').focus();
                }
            }
        }

		
		function NoControlAjax()
        {
            AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_purchase_receipt_seri_control_warehouse&type=2&new_dsn2=#new_dsn2#&new_dsn3=#new_dsn3#&ship_id=#attributes.ship_id#&old_ship_id=#get_old_ship_control.SHIP_ID#&period_id=#get_period.PERIOD_ID#</cfoutput>','ship_list',1);
			document.getElementById('add_other_barcod').focus();

        }
		function ControlAjax()
        {
			AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_purchase_receipt_seri_control_warehouse&type=1&new_dsn2=#new_dsn2#&new_dsn3=#new_dsn3#&ship_id=#attributes.ship_id#&old_ship_id=#get_old_ship_control.SHIP_ID#&period_id=#get_period.PERIOD_ID#</cfoutput>','ship_list',1);
			document.getElementById('add_other_barcod').focus();
        }
		function ShipListAjax()
        {
            AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_purchase_receipt_seri_control_warehouse&type=0&new_dsn2=#new_dsn2#&new_dsn3=#new_dsn3#&ship_id=#attributes.ship_id#&old_ship_id=#get_old_ship_control.SHIP_ID#&period_id=#get_period.PERIOD_ID#</cfoutput>','ship_list',1);
			document.getElementById('add_other_barcod').focus();

        }
		window.onload = function() {
    ShipListAjax(); // Sayfa yüklendiğinde varsayılan sekme içeriğini getir
};
    </script>
