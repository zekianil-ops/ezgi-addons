<!---
    File: add_ezgi_shipment_from_removel_list_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Sevkiyat Listesinden Çıkarma İşlemi 
--->


<cfparam name="attributes.anamenu" default="1">
<cfparam name="attributes.startrow" default="0">
<cfparam name="attributes.maxrows" default="5000">
<cfparam name="attributes.removel" default="1">
<cfset default_process_type = 113>
<cfquery name="get_default_departments" datasource="#dsn3#">
	SELECT 
    	INTERMEDIATE_WAREHOUSE, 
        PRODUCTION_WAREHOUSE,
        SHELF_WAREHOUSE,
        FIRST_SHELF_ID,
        SHIPMENT_WAREHOUSE
	FROM     
    	EZGI_WM_SETUP_ROW
	WHERE  
    	EMPLOYEE_POSITION_ID = #session.ep.POSITION_CODE#
</cfquery>
<cfparam name="attributes.department_out_id" default="#get_default_departments.SHIPMENT_WAREHOUSE#">
<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT TOP (1)    
    	SPC.PROCESS_CAT_ID
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE = #default_process_type# AND 
        SPCF.FUSE_NAME = '#attributes.fuseaction#' 
  	ORDER BY
    	SPC.PROCESS_CAT_ID DESC      
</cfquery>
<cfif not get_process_cat.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='333.İşlem Kategorisi Tanımlayınız!'>");
		history.back();	
	</script>
</cfif>
<cfscript>
		get_shipment.recordcount=0;
		get_shipment.query_count=0;
		get_pallet_list_action = createObject("component", "addOns.ezgi.cfc.get_ezgi_shipment_verifaction_warehouse");
		get_pallet_list_action.dsn3 = dsn3;
		get_pallet_list_action.dsn_alias = dsn_alias;
		get_shipment = get_pallet_list_action.get_shipment_
		(
		 	dsn_alias : '#dsn_alias#',
			dsn2_alias : '#dsn2_alias#',
			is_type : '#IIf(IsDefined("attributes.is_type"),"attributes.is_type",DE(""))#',
			ship_id : '#IIf(IsDefined("attributes.ship_id"),"attributes.ship_id",DE(""))#',
			removel : '#IIf(IsDefined("attributes.removel"),"attributes.removel",DE(""))#',
		 	startrow : '#iif(isdefined("attributes.startrow"),"attributes.startrow",DE(""))#',
			maxrows : '#iif(isdefined("attributes.maxrows"),"attributes.maxrows",DE(""))#'
		);
</cfscript>
<!---<cfdump var="#get_shipment#">--->
<cfquery name="get_controled_serino" dbtype="query">
	SELECT * FROM get_shipment WHERE IS_SHIPMENT_VERIFACTION = 1
</cfquery>
<cfquery name="get_not_controled_serino" dbtype="query">
	SELECT * FROM get_shipment
</cfquery>
<cfquery name="get_in_depo" datasource="#dsn3#">
	SELECT DEPO_NAME, DEPO FROM EZGI_WM_DEPARTMENTS WHERE DEPO = '#Replace(get_default_departments.SHIPMENT_WAREHOUSE,',','-')#'
</cfquery>
<cfif attributes.is_type eq 1>
 	<cfquery name="upd_ship" datasource="#dsn3#">
     	SELECT ISNULL(SHIPMENT_PACKAGE_AMOUNT,0) AS SHIPMENT_PACKAGE_AMOUNT FROM EZGI_SHIP_RESULT WHERE SHIP_RESULT_ID = #attributes.ship_id#
 	</cfquery>
<cfelse>
	<cfquery name="upd_ship" datasource="#dsn3#">
    	SELECT ISNULL(SHIPMENT_PACKAGE_AMOUNT,0) AS SHIPMENT_PACKAGE_AMOUNT FROM EZGI_SHIP_RESULT_INTERNALDEMAND WHERE SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id#
	</cfquery>
</cfif>

<cfparam name="attributes.department_in_id" default="#get_default_departments.SHELF_WAREHOUSE#">
<cfsavecontent variable="title_"><cf_get_lang dictionary_id='1320.Sevkiyat Doğrulama İşlemi'></cfsavecontent>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfform name="add_ezgi_shipment_verifaction_warehouse" >
    	<cf_box>
         	<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
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
                                <div class="col col-12" id="third_area">
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='45363.Kontrol Edilen Miktar'></label>
                                        </div>
                                      	<div class="col col-3">
                                            <div class="form-group" id="item-serial_control">
                                            	<cfinput type="text" name="serial_control" id="serial_control" value="#get_controled_serino.recordcount#" style="text-align:right; font-weight:bold" readonly="yes">
                                            </div>
                                        </div>
                                        <div class="col col-3">
                                            <div class="form-group" id="item-serial_controled">
                                            	<cfinput type="text" name="serial_controled" id="serial_controled" value="#get_shipment.recordcount#" style="text-align:right; font-weight:bold" readonly="yes">
                                       		</div>
                                        </div>
                                        <div class="col col-3">
                                            <div class="form-group" id="item-all_controled">
                                            	<cfinput type="text" name="all_control" id="all_controled" value="#upd_ship.SHIPMENT_PACKAGE_AMOUNT#" style="text-align:right; font-weight:bold" readonly="yes">
                                       		</div>
                                        </div>
                                    </div>
                              	</div>
               				</cf_box_elements>
                    		<cf_box_footer>
                            	<div class="col col-12">
                                    <div class="col col-6" style="text-align:right">
                                       </div>
                                    <div class="col col-6" style="text-align:right;<cfif upd_ship.SHIPMENT_PACKAGE_AMOUNT neq get_controled_serino.recordcount>display:none</cfif>" id="onay_div">
                                        <input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" onClick="kontrol_kayit();" />
                                 	</div>
                              	</div>
              				</cf_box_footer>
                       	</div>
                  	</div>
              	</div>
    		</cf_basket_form>
      	</cf_box>
        <div id="basket_main_div">
        	<div class="row">
                <div class="col col-12 uniqueRow">
                    <cf_basket_form id="upd_connect" class="row">
                        <div id="tab-container" class="tabStandart margin-top-5">
                            <div id="tab-content" class="margin-top-10"> 
                                <div id="ship_list" class="content row">
                                	<cfsavecontent variable="title"><cfif attributes.is_type eq 1><b><cf_get_lang dictionary_id='382.Sevk Plan No'> :</b><cfelse><b><cf_get_lang dictionary_id='375.Sevk Talep No'> :</b></cfif><cfoutput>#attributes.DELIVER_PAPER_NO#</cfoutput></cfsavecontent>
                                    <cf_box title="#title#">
                                        <cf_grid_list>
                                            <thead>
                                                <tr>
                                                	<th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                    <th style="width:75px"><cf_get_lang dictionary_id='57637.Seri No'></th>
                                                    <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                                </tr>
                                            </thead>
                                            <cfinput type="hidden" id="row_count_sevk" name="row_count_sevk" value="#get_not_controled_serino.recordcount#">
                                            <tbody>
                                                <cfif get_not_controled_serino.recordcount>
                                                    <cfoutput query="get_not_controled_serino">
                                                    	<cfinput type="hidden" name="row_control_#currentrow#" id="row_control_#currentrow#" value="#SERIAL_NO#" >
                                                        <cfinput type="hidden" name="PRODUCT_NAME_#currentrow#" id="PRODUCT_NAME_#currentrow#" value="#PRODUCT_NAME#" >
                                                        <tr id="row#currentrow#" height="20">
                                                        	<td style="text-align:center">#currentrow#</td>
                                                            <td style="text-align:center">#SERIAL_NO#</td>        
                                                            <td style="text-align:left">#PRODUCT_NAME#</td>
                                                         </tr>
                                                    </cfoutput>
                                                </cfif>
                                            </tbody>
                                        </cf_grid_list>
                                    </cf_box>
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
				get_stock(document.getElementById('add_other_barcod').value);
			}
		}
	}
	function get_stock(barcode) /*Ürün Kontrolü*/
    {
		row_count_sevk = document.getElementById('row_count_sevk').value;
		buldum=0;
		for(i=1;i<=row_count_sevk;i++)
		{
			satir_serino = document.getElementById('row_control_'+i).value;
			if(barcode==satir_serino)
				buldum=i;
		}
		if(buldum==0)
		{
			alert('Paket Bu Sevkiyatın Ürünü Değildir. !');
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		else
		{
			document.getElementById('serial_control').value=document.getElementById('serial_control').value-1;
			document.getElementById('serial_controled').value=document.getElementById('serial_controled').value-1;
			document.getElementById('row'+buldum).style.display='none';
			document.getElementById('row_control_'+buldum).value = '';
			AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_add_ezgi_shipment_from_removel_list_warehouse&x_select_process_yontem=#attributes.x_select_process_yontem#&removal_serial=1&is_type=#attributes.is_type#&ship_id=#attributes.ship_id#&serial_no='+barcode+'</cfoutput>','serial_div',1)
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus();
		}
	}
</script>