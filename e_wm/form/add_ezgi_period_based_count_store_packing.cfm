<!---
    File: add_ezgi_period_based_count_store_packing.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/03/2025
    Description: Palet İçeriği Sayım İşlemi
---> 
<cf_xml_page_edit>
<cfquery name="get_default_departments" datasource="#dsn3#">
	SELECT 
    	INTERMEDIATE_WAREHOUSE, 
        PRODUCTION_WAREHOUSE,
        SHELF_WAREHOUSE,
        FIRST_SHELF_ID
	FROM     
    	EZGI_WM_SETUP_ROW
	WHERE  
    	EMPLOYEE_POSITION_ID = #session.ep.POSITION_CODE#
</cfquery>
<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>
<cfquery name="get_count" datasource="#dsn3#">
	SELECT
    	ISNULL(IS_PALETTE_CONTENT_SAVE,0) IS_PALETTE_CONTENT_SAVE,
    	EZGI_WM_COUNT_ID,
  		PROCESS_DATE, 
     	PROCESS_NUMBER,
        RECORD_EMP,
    	RECORD_DATE,
        STATUS
	FROM     
     	EZGI_WM_COUNT WITH (NOLOCK)
  	WHERE
    	STATUS = 1
</cfquery>
<cfif not get_count.recordcount>
	<script type="text/javascript">
		alert("Dönem Bazlı Sayım Fişi Aktif Olarak Yoktur. Lütfen Sistem Yöneticinize Başvurunuz");
	</script>
    <cfabort>
</cfif>

<cfif get_count.recordcount gt 1>
	<script type="text/javascript">
		alert("Birden Fazla Dönem Bazlı Sayım Fişi Aktif Olarak Mevcut. Lütfen Sistem Yöneticinize Başvurunuz");
	</script>
    <cfabort>
</cfif>
<cfif get_count.IS_PALETTE_CONTENT_SAVE eq 1>
	<script type="text/javascript">
		alert("Dönemsel Sayım İşlemi Palet İçeriği Kaydeder İşaretlidir. Palet İçeriği Okutmak İçin Bu Kutucuk Boş Olmalıdır.");
	</script>
    <cfabort>
</cfif>
<cfset attributes.count_id = get_count.EZGI_WM_COUNT_ID>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
        <cfform name="add_ezgi_period_based_count_store_shelf" >
        	<cfinput type="hidden" id="control_type" name="control_type" value="0">
            <cf_basket_form id="add_ezgi_period_based_count_store_shelf">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
                         	<cf_box_elements>
                                 <div class="col col-12 uniqueRow" id="first_area">
                                    <div class="col col-12">
                                    	<div class="col col-4">
                                            <label><cf_get_lang dictionary_id='1312.Palet Barkodu'></label>
                                        </div>
                                        <div class="col col-8">
                                            <div class="form-group" id="item-barcod">
                                                <input id="packing_barcod" name="packing_barcod" type="text" value="">
                                            </div>
                                        </div>
                                    </div>
                               	</div>
                                <div class="col col-12 uniqueRow" id="second_area" style="display:none">
                                    <div class="col col-12">
                                    	<div class="col col-4">
                                            <label><cf_get_lang dictionary_id='1317.Paket Barkodu'></label>
                                        </div>
                                        <div class="col col-8">
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
            <cfsavecontent variable="title"><cf_get_lang dictionary_id="1360.WM- Palet İçeriği Sayım İşlem"></cfsavecontent>
        	<cf_box title="#title#">
				<div class="col col-12"  id="display_info">
                
                </div>
          	</cf_box>
      	</cfform>
   	</cf_box>
</div>
<script language="javascript" type="text/javascript">
	document.getElementById('add_other_barcod').focus();
	setTimeout("document.getElementById('add_other_barcod').select();",1000);
	document.onkeydown = checkKeycode
	function checkKeycode(e) 
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
				if (document.getElementById('packing_barcod').value.length == 0)
				{
					alert('Önce Palet Barkodu Okutunuz');
					document.getElementById('packing_barcod').value = '';
					document.getElementById('packing_barcod').focus();	
				}
				else
				{
					if (document.getElementById('add_other_barcod').value.length > 0)
					{
						var bb = '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_period_based_count_store_packing&count_id=#attributes.count_id#&type=1</cfoutput>&packing_barcode='+document.getElementById('packing_barcod').value+'&barcode='+document.getElementById('add_other_barcod').value;
						AjaxPageLoad(bb,'display_info',1);
						document.getElementById('add_other_barcod').value='';
						document.getElementById('add_other_barcod').focus();
					}
					else 
					{
						var bb = '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_period_based_count_store_packing&count_id=#attributes.count_id#&type=0</cfoutput>&packing_barcode='+document.getElementById('packing_barcod').value;
						AjaxPageLoad(bb,'display_info',1);
						document.getElementById('add_other_barcod').value='';
						document.getElementById('second_area').style.display='';
						document.getElementById('add_other_barcod').focus();
					}
				}
		}
	}
</script>