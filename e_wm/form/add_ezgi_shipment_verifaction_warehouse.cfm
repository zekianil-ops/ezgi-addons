<!---
    File: add_ezgi_shipment_verifaction_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Sevkiyat Doğrulama İşlemi 
--->
<cfparam name="attributes.anamenu" default="1">
<cfparam name="attributes.startrow" default="0">
<cfparam name="attributes.maxrows" default="5000">
<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
	<cfif attributes.is_type eq 1>
     	SELECT     
       		PAKET_SAYISI AS PAKETSAYISI, 
       		PAKET_ID AS STOCK_ID, 
       		BARCOD, 
       		STOCK_CODE, 
       		PRODUCT_NAME,
       		SPECT_MAIN_ID
   		FROM         
       		(
       		SELECT
       		    SUM(PAKET_SAYISI) AS PAKET_SAYISI,
       		    PAKET_ID, 
       		    BARCOD, 
       		    STOCK_CODE, 
       		    PRODUCT_NAME, 
       		    SHIP_RESULT_ID,
       		    SPECT_MAIN_ID
       		FROM
       		    (     
       		    SELECT 
       		        SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
       		        EPS.PAKET_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_ID,
       		        ISNULL(SP.SPECT_MAIN_ID,0) AS SPECT_MAIN_ID
       		    FROM          
       		        STOCKS AS S1 WITH (NOLOCK) INNER JOIN
       		        EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
       		        EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
       		        ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
       		        SPECTS AS SP ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
       		        STOCKS AS S WITH (NOLOCK) INNER JOIN
       		        EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID 
       		    WHERE      
       		        ESR.SHIP_RESULT_ID = #attributes.ship_id# AND
       		        ORR.ORDER_ROW_CURRENCY = -6 AND
       		        ISNULL(S1.IS_PROTOTYPE,0) = 1 
       		    GROUP BY 
       		        EPS.PAKET_ID,
       		        EPS.MODUL_SPECT_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_ID,
       		        ORR.SPECT_VAR_ID,
       		        SP.SPECT_MAIN_ID
       		    UNION ALL
       		    SELECT 
       		        SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
       		        EPS.PAKET_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_ID,
       		        0 AS SPECT_MAIN_ID
       		    FROM
       		        EZGI_SHIP_RESULT AS ESR WITH (NOLOCK) INNER JOIN
       		        EZGI_SHIP_RESULT_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
       		        ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
       		        EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
       		        STOCKS AS S WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID INNER JOIN
       		        STOCKS AS S1 WITH (NOLOCK) ON S1.STOCK_ID = ORR.STOCK_ID
       		    WHERE      
       		        ESR.SHIP_RESULT_ID = #attributes.ship_id# AND
       		        ORR.ORDER_ROW_CURRENCY = -6 AND
       		        ISNULL(S1.IS_PROTOTYPE,0) = 0
       		    GROUP BY
       		        EPS.PAKET_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_ID,
       		        ORR.SPECT_VAR_ID
       		    ) AS TBL1
       		GROUP BY
       		    PAKET_ID, 
       		    BARCOD, 
       		    STOCK_CODE, 
       		    PRODUCT_NAME, 
       		    SHIP_RESULT_ID,
       		    SPECT_MAIN_ID
       		) AS TBL
       	ORDER BY
       		PRODUCT_NAME,
       		SPECT_MAIN_ID
 	<cfelse>
    	SELECT     
       		PAKET_SAYISI AS PAKETSAYISI, 
       		PAKET_ID AS STOCK_ID, 
       		BARCOD, 
       		STOCK_CODE, 
       		PRODUCT_NAME,
       		SPECT_MAIN_ID
   		FROM         
       		(
       		SELECT
       		    SUM(PAKET_SAYISI) AS PAKET_SAYISI,
       		    PAKET_ID, 
       		    BARCOD, 
       		    STOCK_CODE, 
       		    PRODUCT_NAME, 
       		    SHIP_RESULT_ID,
       		    SPECT_MAIN_ID
       		FROM
       		    (     
       		    SELECT 
       		        SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
       		        EPS.PAKET_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
       		        ISNULL(SP.SPECT_MAIN_ID,0) AS SPECT_MAIN_ID
       		    FROM          
       		        STOCKS AS S1 WITH (NOLOCK) INNER JOIN
       		        EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
       		        EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
       		        ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
       		        SPECTS AS SP ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
       		        STOCKS AS S WITH (NOLOCK) INNER JOIN
       		        EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID 
       		    WHERE      
       		        ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
       		        ORR.ORDER_ROW_CURRENCY = -6 AND
       		        ISNULL(S1.IS_PROTOTYPE,0) = 1 
       		    GROUP BY 
       		        EPS.PAKET_ID,
       		        EPS.MODUL_SPECT_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_INTERNALDEMAND_ID,
       		        ORR.SPECT_VAR_ID,
       		        SP.SPECT_MAIN_ID
       		    UNION ALL
       		    SELECT 
       		        SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
       		        EPS.PAKET_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_INTERNALDEMAND_ID,
       		        0 AS SPECT_MAIN_ID
       		    FROM
       		        EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR WITH (NOLOCK) INNER JOIN
       		        EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR WITH (NOLOCK) ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
       		        ORDER_ROW AS ORR WITH (NOLOCK) ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
       		        EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
       		        STOCKS AS S WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID INNER JOIN
       		        STOCKS AS S1 WITH (NOLOCK) ON S1.STOCK_ID = ORR.STOCK_ID
       		    WHERE      
       		        ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
       		        ORR.ORDER_ROW_CURRENCY = -6 AND
       		        ISNULL(S1.IS_PROTOTYPE,0) = 0
       		    GROUP BY
       		        EPS.PAKET_ID, 
       		        S.BARCOD, 
       		        S.STOCK_CODE, 
       		        S.PRODUCT_NAME, 
       		        ESR.SHIP_RESULT_INTERNALDEMAND_ID,
       		        ORR.SPECT_VAR_ID
       		    ) AS TBL1
       		GROUP BY
       		    PAKET_ID, 
       		    BARCOD, 
       		    STOCK_CODE, 
       		    PRODUCT_NAME, 
       		    SHIP_RESULT_ID,
       		    SPECT_MAIN_ID
       		) AS TBL
       	ORDER BY
       		PRODUCT_NAME,
       		SPECT_MAIN_ID
	</cfif>
</cfquery>
<cfquery name="get_total_package" dbtype="query">
 	SELECT sum(PAKETSAYISI) AS PAKETSAYISI FROM GET_SHIP_PACKAGE_LIST
</cfquery>
<cfset default_process_type = 113>
<cfset PACKING_ACTION_TYPE_ID = 0> <!---Palet İşlem Tipi - (Palet Toplama Rafına Transfer- Yok olacak)--->
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
		 	startrow : '#iif(isdefined("attributes.startrow"),"attributes.startrow",DE(""))#',
			maxrows : '#iif(isdefined("attributes.maxrows"),"attributes.maxrows",DE(""))#'
		);
</cfscript>
<cfquery name="get_controled_serino" dbtype="query">
	SELECT * FROM get_shipment WHERE IS_SHIPMENT_VERIFACTION = 1
</cfquery>
<cfquery name="get_not_controled_serino" dbtype="query">
	SELECT * FROM get_shipment WHERE IS_SHIPMENT_VERIFACTION = 0
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
<cfset txt_department_in_name = get_in_depo.DEPO_NAME>
<cfset txt_department_in = get_in_depo.DEPO>
<cfif get_shipment.recordcount>
	<cfset attributes.department_out_id = get_shipment.DEPO>
    <cfif len(get_shipment.DEPO)>
        <cfquery name="get_out_depo" datasource="#dsn3#">
            SELECT DEPO_NAME, DEPO FROM EZGI_WM_DEPARTMENTS WHERE DEPO = '#get_shipment.DEPO#' 
        </cfquery>
    <cfelse>
    	Çıkış Depo Bulunamadı
    	<cfabort>
    </cfif>
    <cfif len(get_shipment.PRODUCT_PLACE_ID)>
		<cfset txt_shelf_out_name = get_shipment.SHELF_CODE>
        <cfset txt_shelf_out = get_shipment.PRODUCT_PLACE_ID>
        <cfset txt_department_out_name = get_out_depo.DEPO_NAME>
        <cfset txt_department_out = get_out_depo.DEPO>
    <cfelse>
    	Çıkış Raf Bulunamadı
    	<cfabort>
    </cfif>
<cfelse>
	<cfset txt_shelf_out_name = ''>
	<cfset txt_shelf_out = 0>
  	<cfset txt_department_out_name = ''>
  	<cfset txt_department_out = 0>
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
                                <div class="col col-12" id="second_area">
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='1316.Sevkiyat Alanı'></label>
                                        </div>
                                        <div class="col col-3">
                                            <div class="form-group" id="item-cikis_raf">
                                            	<cfinput type="text" name="txt_shelf_out_name" id="txt_shelf_out_name" value="#txt_shelf_out_name#">
                                                <cfinput type="hidden" name="txt_shelf_out" id="txt_shelf_out" value="#txt_shelf_out#">
                                            </div>
                                        </div>
                                        <div class="col col-6">
                                            <div class="form-group" id="item-cikis">
                                            	<cfinput type="text" name="txt_department_out_name" id="txt_department_out_name" value="#txt_department_out_name#">
                                                <cfinput type="hidden" name="txt_department_out" id="txt_department_out" value="#txt_department_out#">
                                                
                                                <cfinput type="hidden" name="txt_department_in_name" id="txt_department_in_name" value="#txt_department_in_name#" readonly="">
                                                <cfinput type="hidden" name="txt_department_in" id="txt_department_in" value="#txt_department_in#">
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
                                            	<cfinput type="text" name="all_control" id="all_controled" value="#get_total_package.PAKETSAYISI#" style="text-align:right; font-weight:bold" readonly="yes">
                                       		</div>
                                        </div>
                                    </div>
                              	</div>
               				</cf_box_elements>
                    		<cf_box_footer>
                            	<div class="col col-12">
                                    <div class="col col-6" style="text-align:right">
                                       </div>
                                    <div class="col col-6" style="text-align:right;<cfif get_total_package.PAKETSAYISI neq get_controled_serino.recordcount>display:none</cfif>" id="onay_div">
                                        <input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" onClick="kontrol_kayit();" />
                                 	</div>
                              	</div>
              				</cf_box_footer>
                       	</div>
                  	</div>
              	</div>
    		</cf_basket_form>
      	</cf_box>
        <cfsavecontent variable="sekme2"><cf_get_lang dictionary_id="57314.Kontrol Edilmiş"></cfsavecontent>
        <cfsavecontent variable="sekme1"><cf_get_lang dictionary_id="57315.Kontrol Edilmemiş"></cfsavecontent>
        <div id="basket_main_div">
        	<div class="row">
                <div class="col col-12 uniqueRow">
                    <cf_basket_form id="upd_connect" class="row">
                        <div id="tab-container" class="tabStandart margin-top-5">
                            <div id="tab-head">
                                <ul class="tabNav">
                                    <li class="<cfif attributes.anamenu eq 1>active</cfif>"><a id="href_urunler" href="#ship_list"><cfoutput>#sekme1#</cfoutput></a></li>
                                    <li class="<cfif attributes.anamenu eq 2>active</cfif>"><a id="href_minfo" href="#icerik"><cfoutput>#sekme2#</cfoutput></a></li>
                                </ul>
                            </div>
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
                                <div id="icerik" class="content row">
									<cf_box title="#title#">
                                        <cf_grid_list>
                                            <thead>
                                                <tr>
                                                	<th style="width:20px"></th>
                                                	<th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                    <th style="width:75px"><cf_get_lang dictionary_id='57637.Seri No'></th>
                                                    <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                                </tr>
                                            </thead>
                                            <cfinput type="hidden" id="row_count_content" name="row_count_content" value="#get_controled_serino.recordcount#">
                                         	<tbody name="table2" id="table2">
                                            	<cfif get_controled_serino.recordcount>
                                                	<cfoutput query="get_controled_serino">
                                                    	<tr id="row_content#currentrow#" height="20">
                                                        	<td style="text-align:center">
                                                        		<a onclick="sil(#currentrow#);"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
                                                                <cfinput type="hidden" name="row_control_content#currentrow#" id="row_control_content#currentrow#" value="1" >
                                                                
                                                            </td>
                                                            <td style="text-align:center">#currentrow#</td>
                                                            <td style="text-align:center"><input name="SERIAL_NO#currentrow#" id="SERIAL_NO#currentrow#" type="text" value="#SERIAL_NO#" style="width:75px"></td>        
                                                            <td style="text-align:left"><input name="A_PRODUCT_NAME#currentrow#" id="A_SERIAL_NO#currentrow#" type="text" value="#PRODUCT_NAME#" style="width:200px"></td>    
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
		row_count_content = document.getElementById('row_count_content').value;
		buldum=0;
		for(i=1;i<=row_count_sevk;i++)
		{
			satir_serino = document.getElementById('row_control_'+i).value;
			if(barcode==satir_serino)
				buldum=i;
		}
		for(j=1;j<=row_count_content;j++)
		{
			if(document.getElementById('SERIAL_NO'+j).value==barcode)
				buldum = -1;
		}
		if(buldum==0)
		{
			alert('Paket Bu Sevkiyatın Ürünü Değildir. !');
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		else if(buldum==-1)
		{
			alert('Paket daha Önce Okutulmuş. !');
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		else
		{
			productname = document.getElementById('PRODUCT_NAME_'+buldum).value;
			add_row(barcode,productname);
			document.getElementById('row'+buldum).style.display='none';
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus();
		}
	}
	function add_row(barcode,productname)
	{
		row_count_content = document.getElementById('row_count_content').value;
		serial_hata = 0;	
		if(serial_hata == 0)
		{
			row_count_content++;
			document.getElementById('row_count_content').value = row_count_content;
			var newRow;
			var newCell;	
			newRow = document.getElementById("table2").insertRow(document.getElementById("table2").rows.length);
			newRow.setAttribute("name","frm_row" + row_count_content);
			newRow.setAttribute("id","frm_row" + row_count_content);		
			newRow.setAttribute("NAME","frm_row" + row_count_content);
			newRow.setAttribute("ID","frm_row" + row_count_content);		
			
			newCell = newRow.insertCell();
			newCell.innerHTML = '<a onclick="sil(' + row_count_content + ');"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>';
					
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="hidden" name="row_control_content'+row_count_content+'" id="row_control_content'+row_count_content+'" value="1"><input name="row_number'+row_count_content+'" type="text" value="'+row_count_content+'" style="width:20px">';
			
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="SERIAL_NO'+row_count_content+'" id="SERIAL_NO'+row_count_content+'" type="text" value="'+barcode+'" style="width:75px">';
			
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="A_PRODUCT_NAME'+row_count_content+'" id="A_PRODUCT_NAME'+row_count_content+'" type="text" value="'+productname+'" style="width:200px">';
			
			control_amount = document.getElementById('serial_control').value;
			control_amount = (control_amount*1)+1;
			document.getElementById('serial_control').value = control_amount;
			
			from_shelf_id= document.getElementById('txt_shelf_out').value;
			from_depo= document.getElementById('txt_department_out').value;
			to_depo= document.getElementById('txt_department_in').value;
			
			total_packege = <cfoutput>#get_total_package.PAKETSAYISI#</cfoutput>;
			if(total_packege == control_amount)
				document.getElementById('onay_div').style.display='';
			
			AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_add_ezgi_shipment_verifaction_warehouse&add_serial=1&is_type=#attributes.is_type#&ship_id=#attributes.ship_id#&from_depo='+from_depo+'&from_shelf_id='+from_shelf_id+'&to_depo='+to_depo+'&serial_no='+barcode+'</cfoutput>','serial_div',1)
			
		}
	}
	function sil(sy)
	{
		sor = confirm(sy+'. Satırı Silmek İster misiniz ?')
		if(sor==true)
		{
			barcode = document.getElementById('SERIAL_NO'+sy).value;
			from_shelf_id= document.getElementById('txt_shelf_out').value;
			from_depo= document.getElementById('txt_department_out').value;
			to_depo= document.getElementById('txt_department_in').value;
			AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_add_ezgi_shipment_verifaction_warehouse&del_serial=1&is_type=#attributes.is_type#&ship_id=#attributes.ship_id#&from_depo='+from_depo+'&from_shelf_id='+from_shelf_id+'&to_depo='+to_depo+'&serial_no='+barcode+'</cfoutput>','serial_div',1)
		}
		else
			return false;
	}
	<!---function shipment_area()
	{
		out_shelf_id=document.getElementById('txt_shelf_out').value;
		AjaxPageLoad('<cfoutput>#request.self#?fuseaction=stock.emptypopup_add_ezgi_pallets_to_shipment_warehouse&upd_shelf=1&is_type=#attributes.is_type#&ship_id=#attributes.ship_id#&out_shelf_id='+out_shelf_id+'</cfoutput>','shelf_div',1)	
	}--->
	function kontrol_kayit()
	{
		
		sor = confirm('Transfer Doğrulama İşlemini Kaydediyorum ?')
		if(sor==true)
		{
			document.getElementById('onay').disabled = true;
			from_depo= document.getElementById('txt_department_out').value;
			to_depo= document.getElementById('txt_department_in').value;
			window.location ='<cfoutput>#request.self#?fuseaction=stock.emptypopup_add_ezgi_shipment_verifaction_warehouse&last_process=1&is_type=#attributes.is_type#&ship_id=#attributes.ship_id#&process_cat=#get_process_cat.process_cat_id#&packing_action_type_id=#packing_action_type_id#</cfoutput>&dep_out='+from_depo+'&dep_in='+to_depo;
		}
		else
			return false;
	}
</script>