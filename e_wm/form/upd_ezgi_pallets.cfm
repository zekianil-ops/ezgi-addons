<!---
    File: upd_ezgi_pallets.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Palet Oluştur
--->
<cfset default_process_type = 113>
<cfset PACKING_ACTION_TYPE_ID = 1> <!---Palet İşlem Tipi - (Palet Oluşturma)--->
<cfquery name="get_default_departments" datasource="#dsn3#">
	SELECT 
    	INTERMEDIATE_WAREHOUSE, 
        PRODUCTION_WAREHOUSE
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
<cfset default_departments = '#ListGetAt(get_default_departments.PRODUCTION_WAREHOUSE,1)#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
<cfparam name="attributes.department_in_id" default="#Replace(get_default_departments.INTERMEDIATE_WAREHOUSE,',','-')#">
<cfparam name="attributes.department_out_id" default="#Replace(get_default_departments.PRODUCTION_WAREHOUSE,',','-')#">
<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT        
    	D.DEPARTMENT_HEAD, 
        SL.DEPARTMENT_ID, 
        SL.LOCATION_ID, 
        SL.STATUS, 
        SL.COMMENT,
   	 	D.DEPARTMENT_HEAD + ' - ' + SL.COMMENT AS DEPO_NAME, 
        CAST(D.DEPARTMENT_ID AS VARCHAR)+ '-' + CAST(SL.LOCATION_ID AS VARCHAR) AS DEPO
	FROM            
  		STOCKS_LOCATION AS SL INNER JOIN
        DEPARTMENT AS D ON SL.DEPARTMENT_ID = D.DEPARTMENT_ID INNER JOIN
        BRANCH AS B ON D.BRANCH_ID = B.BRANCH_ID LEFT OUTER JOIN
        #dsn3_alias#.PRODUCT_PLACE AS PP ON SL.LOCATION_ID = PP.LOCATION_ID AND SL.DEPARTMENT_ID = PP.STORE_ID
	WHERE        
    	D.DEPARTMENT_ID IN (#default_departments#) AND 
        SL.STATUS = 1 AND 
        PP.PRODUCT_PLACE_ID IS NULL
 	ORDER BY
    	DEPO_NAME
</cfquery>
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT TOP (1)    
    	SPC.PROCESS_CAT_ID
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE = #default_process_type# AND 
        SPCF.FUSE_NAME = 'pda.form_add_ambar_fis' 
  	ORDER BY
    	SPC.PROCESS_CAT_ID DESC      
</cfquery>
<cfif not get_process_cat.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='333.İşlem Kategorisi Tanımlayınız!'>");
		history.back();	
	</script>
</cfif>
<cfquery name="get_packing_size" datasource="#dsn3#">
   	SELECT 
   		PACKING_SIZE_TYPE_ID, 
   		PACKING_SIZE_TYPE_CODE, 
      	PACKING_SIZE_TYPE_NAME, 
      	SHELF_SIZE_TYPE_ID
	FROM     
   		EZGI_WM_SETUP_PACKING_SIZE_TYPE
   	ORDER BY
    	PACKING_SIZE_TYPE_CODE
</cfquery>
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_PACKING WHERE PACKING_ID = #attributes.packing_id#
</cfquery>
<cfif get_upd.IS_KARMA eq 1>
	<cfquery name="get_upd_row" datasource="#dsn3#">
        SELECT 
            EPR.PACKING_ROW_ID, 
            EPR.STOCK_ID, 
            ISNULL(EPR.SPECT_MAIN_ID,0) AS SPECT_MAIN_ID, 
            EPR.LOT_NO, 
            EPR.SERIAL_NO, 
            S.PRODUCT_NAME
        FROM     
         	EZGI_PACKING_ROW AS EPR INNER JOIN
         	STOCKS AS S ON EPR.STOCK_ID = S.STOCK_ID INNER JOIN
          	EZGI_WM_IS_SERIAL_NO_LIVE AS ESL ON EPR.SERIAL_NO = ESL.SERIAL_NO
        WHERE  
            EPR.PACKING_ID = #attributes.packing_id#
    </cfquery>
<cfelse>
    <cfquery name="get_upd_row" datasource="#dsn3#">
        SELECT 
            EPR.PACKING_ROW_ID, 
            EPR.STOCK_ID, 
            ISNULL(EPR.SPECT_MAIN_ID,0) AS SPECT_MAIN_ID, 
            EPR.LOT_NO, 
            EPR.SERIAL_NO, 
            S.PRODUCT_NAME
        FROM     
            EZGI_PACKING_ROW AS EPR INNER JOIN
         	STOCKS AS S ON EPR.STOCK_ID = S.STOCK_ID INNER JOIN
          	EZGI_WM_IS_SERIAL_NO_LIVE AS ESL ON EPR.SERIAL_NO = ESL.SERIAL_NO
        WHERE  
            EPR.PACKING_ID = #attributes.packing_id#
    </cfquery>
</cfif>
<cfif get_upd.recordcount>
	<cfset recordnum = get_upd_row.recordcount>
<cfelse>
	<cfset recordnum = 0>
</cfif>
<cfset attributes.PACKING_SIZE_TYPE_ID = get_upd.PACKING_SIZE_TYPE_ID>
<cfif get_upd_row.recordcount>
	<cfquery name="get_upd_action" datasource="#dsn3#">
        SELECT TOP (1) 
            STORE, 
            STORE_LOCATION, 
            SHELF_NUMBER, 
            OUT_STORE, 
            OUT_STORE_LOCATION, 
            OUT_SHELF_NUMBER, 
            EZGI_PACKING_ACTION_TYPE_ID
        FROM     
            EZGI_PACKING_ACTION
        WHERE  
            PACKING_ID = #attributes.packing_id# AND 
            EZGI_PACKING_ACTION_TYPE_ID = #PACKING_ACTION_TYPE_ID#
        ORDER BY 
            PROCESS_DATE DESC
  	</cfquery>
    <cfset attributes.department_in_id='#get_upd_action.STORE#-#get_upd_action.STORE_LOCATION#'>
	<cfset attributes.department_out_id='#get_upd_action.OUT_STORE#-#get_upd_action.OUT_STORE_LOCATION#'>
    <cfset stock_id = get_upd.STOCK_ID>
    <cfset PRODUCT_PLACE_ID = get_upd.PRODUCT_PLACE_ID>
    <cfset PROCESS_STATUS = get_upd.PROCESS_STATUS>
    <cfif len(stock_id)>
        <cfquery name="get_stock_info" datasource="#dsn3#">
        	SELECT 
            	ETS.PRODUCT_STOCK, 
                ETS.STOCK_ID, 
                S.PRODUCT_NAME 
           	FROM 
                #dsn2_alias#.EZGI_GET_STOCK_LOCATION_TOTAL AS ETS INNER JOIN 
                STOCKS AS S ON ETS.STOCK_ID = S.STOCK_ID 
           	WHERE 
            	ETS.DEPO = '#attributes.department_in_id#'  
                AND S.STOCK_ID = #stock_id#
       </cfquery>
       	<cfif get_stock_info.recordcount>
        	<cfset product_name = get_stock_info.PRODUCT_NAME>
            <cfset kalandepomiktar = get_stock_info.PRODUCT_STOCK>
            <cfset depomiktar = get_stock_info.PRODUCT_STOCK+get_upd_row.recordcount>
      	<cfelse>
        	<cfset kalandepomiktar = 0>
            <cfset depomiktar = 0>
        	<cfset product_name = ''>
        </cfif>
    <cfelse>
    	<cfset product_name = ''>
        <cfset kalandepomiktar = 0>
      	<cfset depomiktar = 0>
    </cfif>
    <cfif len(attributes.PACKING_SIZE_TYPE_ID)>
    	<cfquery name="get_packing_size_info" datasource="#dsn3#">
        	SELECT 
            	PACKING_SIZE_TYPE_ID, 
                PACKING_SIZE_TYPE_CODE, 
                PACKING_SIZE_TYPE_NAME, 
                SHELF_SIZE_TYPE_ID
			FROM     
            	EZGI_WM_SETUP_PACKING_SIZE_TYPE
			WHERE  
            	PACKING_SIZE_TYPE_ID = #attributes.PACKING_SIZE_TYPE_ID#
        </cfquery>
        <cfif get_packing_size_info.recordcount and len(get_packing_size_info.PACKING_SIZE_TYPE_CODE)>
        	<cfset PACKING_SIZE_TYPE_CODE = get_packing_size_info.PACKING_SIZE_TYPE_CODE>
        <cfelse>
        	<cfset PACKING_SIZE_TYPE_CODE = ''>
        </cfif>
    <cfelse>
    	<cfset PACKING_SIZE_TYPE_CODE = ''>
    </cfif>
    <cfif get_upd.IS_KARMA eq 1>
    	<cfset get_durum.recordcount = 0> 
    <cfelse>
        <cfquery name="get_durum" datasource="#dsn3#">
            SELECT 
                ISNULL(AMOUNT,0) AS AMOUNT, 
                PACKING_SIZE_TYPE_CODE, 
                PACKING_SIZE_TYPE_ID 
            FROM 
                EZGI_PRODUCT_PLACE_ROWS 
            WHERE 
                STOCK_ID = #stock_id# 
                AND PLACE_STATUS = 1
        </cfquery>
    </cfif>
    <cfif get_durum.recordcount>
    	<cfset kalanamount = get_durum.amount-get_upd_row.recordcount>
        <cfset amount = get_durum.amount>
    <cfelse>
    	<cfset kalanamount = 0>
        <cfset amount = 0>
    </cfif>
<cfelse>
    <cfset stock_id = ''>
    <cfset PRODUCT_PLACE_ID = ''>
    <cfset PROCESS_STATUS = 0>
    <cfset product_name = ''>
    <cfset PACKING_SIZE_TYPE_CODE = ''>
    <cfset kalanamount = 0>
    <cfset amount = 0>
    <cfset kalandepomiktar = 0>
	<cfset depomiktar = 0>
</cfif>
<cfquery name="get_this_depo" datasource="#dsn3#">
	SELECT 
    	EVD.DEPO_NAME, 
        EVD.DEPO
	FROM     
    	EZGI_WM_PACKING_LAST_STATUS AS EVL INNER JOIN
        EZGI_WM_DEPARTMENTS AS EVD ON EVL.STORE = EVD.DEPARTMENT_ID AND EVL.STORE_LOCATION = EVD.LOCATION_ID
	WHERE  
    	EVL.PACKING_ID = #attributes.packing_id#
</cfquery>
<cfif not get_this_depo.recordcount>
    <cfquery name="get_this_depo" datasource="#dsn3#">
        SELECT DEPO_NAME, DEPO FROM EZGI_WM_DEPARTMENTS WHERE DEPO = '#attributes.department_in_id#'
    </cfquery>
    </cfif>
<cfif not len(get_defaults.EAN) and not isnumeric(get_defaults.EAN)>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='356.Ürün Barkod Karakter Sayısı Hatalı'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>
<cfsavecontent variable="title_">
    <cfoutput>#get_upd.barcode#</cfoutput>
</cfsavecontent>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#title_#">
        <cfform name="upd_packings" >
          	<cfinput type="hidden" name="packing_id" value="#attributes.packing_id#">
         	<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
        	<input type="hidden" name="kuponlist" value="" />
          	<input type="hidden" name="active_period" value="#session.ep.period_id#" />
            <cfinput type="hidden" name="active_stock_id" id="active_stock_id" value="#stock_id#" />
            <input type="hidden" name="row_stock_id" id="row_stock_id" value="" />
            <cf_basket_form id="upd_packings">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
                         	<cf_box_elements>
                            	
                                <div class="col col-12 uniqueRow" id="zero_area">
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='57493.Aktif'></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group" id="item-status">
                                                <input id="status" name="status" type="checkbox" value="1" <cfif get_upd.STATUS eq 1>checked</cfif>>
                                            </div>
                                        </div>
                                    </div>
                               	</div>
                                
                            	<div class="col col-12 uniqueRow" id="first_area" <cfif get_upd_row.recordcount or get_upd.IS_KARMA eq 1>style="display:none"</cfif>>
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='39093.Ürün Barkodu'></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group" id="item-barcod">
                                                <input id="add_other_barcod" name="add_other_barcod" type="text" value="">
                                            </div>
                                        </div>
                                    </div>
                               	</div>
                                <div class="col col-12 uniqueRow" id="second_area" <cfif (get_upd.IS_KARMA eq 0 and not get_upd_row.recordcount) or get_upd.PROCESS_STATUS eq 2>style="display:none"</cfif>>
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='57637.Seri No'></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group" id="item-serial">
                                                <input id="add_other_serial" name="add_other_serial" type="text" value="">
                                            </div>
                                        </div>
                                    </div>
                               	</div>
                                
                                <div class="col col-12 uniqueRow" id="third_area" >
                                    <div class="col col-12" id="cikis_depo" <cfif get_upd.PROCESS_STATUS gt 0>style="display:none"</cfif>>
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='29428.Çıkış Depo'></label>
                                        </div>
                                        
                                        <div class="col col-9">
                                            <div class="form-group" id="item-cikis">
                                            
                                                <select name="txt_department_out" id="txt_department_out" style="width:120px; height:20px" <cfif get_upd_row.recordcount>disabled</cfif>>
                                                    <cfoutput query="get_all_location" group="department_id">
                                                        <option disabled="disabled" value="#department_id#"<cfif attributes.department_out_id eq get_all_location.depo>selected</cfif>>#department_head#</option>
                                                        <cfoutput>
                                                            <option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_out_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#<cfif not status>-<cf_get_lang dictionary_id='57494.Pasif'></cfif></option>
                                                        </cfoutput> 
                                                    </cfoutput>
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col col-12" <cfif get_upd.PROCESS_STATUS gt 0>style="display:none"</cfif>>
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='39412.Giriş Depo'></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group" id="item-giris">
                                                <select name="txt_department_in" id="txt_department_in" style="width:120px; height:20px" <cfif get_upd_row.recordcount>disabled</cfif>>
                                                    <cfoutput query="get_all_location" group="department_id">
                                                        <option disabled="disabled"  value="#department_id#"<cfif attributes.department_in_id eq department_id>selected</cfif>>#department_head#</option>
                                                        <cfoutput>
                                                            <option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_in_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#<cfif not status>-<cf_get_lang dictionary_id='57494.Pasif'></cfif></option>
                                                        </cfoutput> 
                                                    </cfoutput>
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="col col-12" <cfif get_upd.PROCESS_STATUS eq 0>style="display:none"</cfif>>
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='58763.Depo'></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group" id="item-depo">
                                                <input id="this_store" name="this_store" type="text" value="<cfoutput>#get_this_depo.DEPO_NAME#</cfoutput>">
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="col col-12" id="palet_turu">
                                        <div class="col col-3">
                                            <label><label><cf_get_lang dictionary_id='823.Palet Türü'></label></label>
                                        </div>
                                        <div class="col col-3">
                                            <div class="form-group" id="item-palet_turu">
                                                <select name="palet_tur" id="palet_tur" style="width:120px; height:20px" onChange="control_pallete_type(this.value)" <cfif get_upd_row.recordcount>disabled</cfif>>
            										<option value="1" <cfif  get_upd.IS_KARMA eq 1>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cf_get_lang dictionary_id='1330.Karma Palet'></option>
                                                    <option value="0" <cfif not len(get_upd.IS_KARMA) or get_upd.IS_KARMA eq 0>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<cf_get_lang dictionary_id='820.Standart Palet'></option>
                                                    
                                                </select>
                                            </div>
                                        </div>
                                    	<div class="col col-6" id="div_collect_type" <cfif not len(get_upd.IS_KARMA) or get_upd.IS_KARMA eq 0>style="display:none"</cfif>>
                                        	<div class="col col-12">
                                                <div class="col col-6">
                                                    <label><cf_get_lang dictionary_id='1305.Palet Tipi'></label>
                                                </div>
                                                <div class="col col-6">
                                                    <div class="form-group" id="item-collect_type">
                                                    	<select name="collect_type_id_2" id="collect_type_id_2">
                                                        	<cfoutput query="get_packing_size">
                                                        		<option value="#get_packing_size.PACKING_SIZE_TYPE_ID#" <cfif attributes.PACKING_SIZE_TYPE_ID eq get_packing_size.PACKING_SIZE_TYPE_ID>selected</cfif>>#get_packing_size.PACKING_SIZE_TYPE_CODE#</option>
                                                            </cfoutput>
                                                      	</select>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                               </div>
                               <div class="col col-12 uniqueRow" id="fourth_area" <cfif not get_upd_row.recordcount or get_upd.is_karma eq 1>style="display:none"</cfif>>
                                	<div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='58221.Ürün Adı'></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group" id="item-pname">
                                                <input id="product_name" name="product_name" type="text" value="<cfoutput>#product_name#</cfoutput>" readonly style="font-weight:bold">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='1305.Palet Tipi'></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group" id="item-collect_type">
                                                <input id="collect_type" name="collect_type" type="text" value="<cfoutput>#PACKING_SIZE_TYPE_CODE#</cfoutput>" readonly>
                                                <input id="collect_type_id" name="collect_type_id" type="hidden" value="<cfoutput>#attributes.PACKING_SIZE_TYPE_ID#</cfoutput>">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='39425.Depo Miktar'></label>
                                        </div>
                                        <div class="col col-3">
                                            <div class="form-group" id="item-depo_miktar">
                                                <input id="depo_miktar" name="depo_miktar" type="text" value="<cfoutput>#depomiktar#</cfoutput>" readonly class="box">
                                            </div>
                                        </div>
                                        <div class="col col-1"></div>
                                        <div class="col col-2">
                                            <label><cf_get_lang dictionary_id='58444.Kalan'></label>
                                        </div>
                                        <div class="col col-3">
                                            <div class="form-group" id="item-depo_kalan">
                                                <input id="depo_kalan" name="depo_kalan" type="text" value="<cfoutput>#kalandepomiktar#</cfoutput>" readonly class="box" style="font-weight:bold">
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='1306.Palet Miktarı'></label>
                                        </div>
                                        <div class="col col-3">
                                            <div class="form-group" id="item-palet_miktar">
                                                <input id="palet_miktar" name="palet_miktar" type="text" value="<cfoutput>#amount#</cfoutput>" readonly class="box">
                                            </div>
                                        </div>
                                        <div class="col col-1"></div>
                                        <div class="col col-2">
                                            <label><cf_get_lang dictionary_id='58444.Kalan'></label>
                                        </div>
                                        <div class="col col-3">
                                            <div class="form-group" id="item-palet_kalan">
                                                <input id="palet_kalan" name="palet_kalan" type="text" value="<cfoutput>#kalanamount#</cfoutput>" readonly class="box" style="font-weight:bold">
                                            </div>
                                        </div>
                                    </div>
                                </div>
               				</cf_box_elements>
                    		<cf_box_footer>
                            	<div class="col col-12">
                                	<div class="col col-12" style="text-align:right">
                                    	<cf_record_info 
                                            query_name="get_upd"
                                            record_emp="RECORD_EMP" 
                                            record_date="record_date"
                                            update_emp="UPDATE_EMP"
                                            update_date="update_date">
                                    </div>
                                    <div class="col col-6" style="text-align:right">
                                    	<cfif get_upd.PROCESS_STATUS eq 0>
                                    		<img src="/images/production/Open_Pack.png" height="30px"><span style="color:red; font-weight:bold">Açık Palet</span>
                                        <cfelseif get_upd.PROCESS_STATUS eq 1>
                                        	<a style="cursor:pointer" onclick="pallet_status_change(0);">
                                        		<img src="/images/production/Open_Pack_1.png" height="30px"><span style="color:orange; font-weight:bold">Yarım Palet</span>
                                          	</a>
                                        <cfelseif get_upd.PROCESS_STATUS eq 2>
                                        	<img src="/images/production/Closed_Pack.png" height="30px"><span style="color:green; font-weight:bold">Onaylı Palet</span>
                                        </cfif>
                                    </div>
                                    <div class="col col-6" style="text-align:right">
                                    	<cfif get_upd.PROCESS_STATUS eq 0> <!---Açık Palet Değilse--->
                                            <input id="sil" name="sil" style="background-color:red" value="<cf_get_lang dictionary_id="57463.Sil">" type="button"  onClick="kontrol_kayit(0);" />
                                        </cfif>
                                        <cfif get_upd.PROCESS_STATUS neq 2 or (not get_upd_row.recordcount)>
                                        	<input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57464.Güncelle">" type="button" onClick="kontrol_kayit(1);" />
                                        </cfif>
                                 	</div>
                              	</div>
              				</cf_box_footer>
                       	</div>
                  	</div>
              	</div>
    		</cf_basket_form>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id="57718.Seri No lar"></cfsavecontent>
        	<cf_box title="#title#">
            	<cf_grid_list>
                   	<thead>
                       	<tr>
                        	<th width="5%"></th>
                        	<th width="5%">Sıra</th>
                        	<th width="60%">Ürün</th>
                           	<th width="30%">Seri No</th>
                     	</tr>
                 	</thead>
                    	<cfinput type="hidden" id="row_count" name="row_count" value="#get_upd_row.recordcount#" />
                        <cfinput type="hidden" id="action_id" name="action_id" value="" />
                   		<tbody name="table1" id="table1">
                        	<cfoutput query="get_upd_row">
                                <input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                                <input type="hidden" name="STOCK_ID#currentrow#" id="STOCK_ID#currentrow#" value="#STOCK_ID#">
                                <input type="hidden" name="SPECT_MAIN_ID#currentrow#" id="SPECT_MAIN_ID#currentrow#" value="#SPECT_MAIN_ID#">
                             	<tr name="frm_row#currentrow#" id="frm_row#currentrow#">
                                	<td style="text-align:center"></td>
                                    <td >
                                    	<input name="PACKING_ROW_ID#currentrow#" id="PACKING_ROW_ID#currentrow#" type="hidden" value="#PACKING_ROW_ID#">
                                        <input name="row_number#currentrow#" type="text" value="#currentrow#" style="width:25px; text-align:right">
                                    </td>
                                    <td>
                                    	<input name="PRODUCT_NAME#currentrow#" id="PRODUCT_NAME#currentrow#" type="text" value="#PRODUCT_NAME#" style="width:120px">
                                    </td>
                                    <td >
                                    	<input name="SERIAL_NO#currentrow#" id="SERIAL_NO#currentrow#" type="text" value="#SERIAL_NO#" style="width:90px">
                                    </td>
                                </tr>
                            </cfoutput>
                    	</tbody>
           		</cf_grid_list>
          	</cf_box>
      	</cfform>
   	</cf_box>
</div>
<script language="javascript" type="text/javascript">
	<cfif get_upd_row.recordcount or  get_upd.IS_KARMA eq 1>
		document.getElementById('add_other_serial').focus();
		setTimeout("document.getElementById('add_other_serial').select();",1000);
	<cfelse>
		document.getElementById('add_other_barcod').focus();
		setTimeout("document.getElementById('add_other_barcod').select();",1000);
	</cfif>
	document.onkeydown = checkKeycode
	function checkKeycode(e) /*Barkod Okuyup Enter Basıldığında*/
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			if (document.getElementById('add_other_serial').value.length == '')/*serial Boşsa*/
			{
				if (document.getElementById('add_other_barcod').value.length == '') /*Barkod Boşsa*/
				{
					alert('<cf_get_lang dictionary_id='340.Önce Ürün Barkodu Okutunuz'>'); 
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_shelf').value = '';
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').focus();	
				
				}
				else /*Barkod Doluysa*/
				{
					get_stock(document.getElementById('add_other_barcod').value);
				}
			}
			else
			{
				serial_control(document.getElementById('add_other_serial').value);
			}
		}
	}
	function get_stock(barcode) /*Ürün Kontrolü*/
    {
	 	barcod = ''; stockid=''; stockcode = ''; spectmainid = ''; //ilk önce sıfırlıyoruz
		/*var new_sql = "SELECT ETS.PRODUCT_STOCK, ETS.STOCK_ID, S.PRODUCT_NAME FROM <cfoutput>#dsn2_alias#</cfoutput>.EZGI_GET_STOCK_LOCATION_TOTAL AS ETS INNER JOIN STOCKS AS S ON ETS.STOCK_ID = S.STOCK_ID WHERE ETS.DEPO = '"+document.getElementById('txt_department_out').value+"' AND S.BARCOD = '"+barcode+"'";*/ /*Paket Depoda Mevcutmu*/
		/*var get_product = wrk_query(new_sql,'dsn3');*/
		
		var listParam = document.getElementById('txt_department_out').value + "*" + barcode;
		var get_product = wrk_safe_query('get_stock_wm_depocode_barcode_ezgi','dsn3',0,listParam);
			
		
		if (get_product.STOCK_ID == undefined) /*Palet Bulunamadıysa*/
		{
			alert('Ürün Bulunamdı !');
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		else /*Palet Bulunduysa*/
		{	
			stockid = get_product.STOCK_ID;
			barcod = barcode;
			amount = get_product.PRODUCT_STOCK;
			if(amount<=0) /*Miktar 0 veya eksideyse*/
			{
				alert('Ürün Depoda Mevcut Değildir!');
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
				return false;
			}
			else /*Miktar 0 dan büyükse*/
			{
				/*var durum_sql = "SELECT ISNULL(AMOUNT,0) AS AMOUNT, PACKING_SIZE_TYPE_CODE, PACKING_SIZE_TYPE_ID FROM EZGI_PRODUCT_PLACE_ROWS WHERE SHELF_TYPE = 1 AND STOCK_ID = "+stockid+" AND PLACE_STATUS = 1";*/ /*Paket Raf Durumu Sorgulanıyor*/
				/*var get_durum = wrk_query(durum_sql,'dsn3');*/
				
				var listParam = stockid;
				var get_durum = wrk_safe_query('get_shelf_wm_stockid_ezgi','dsn3',0,listParam);
				
				if (get_durum.AMOUNT == undefined) /*Paket Durum Bulunamadıysa*/
				{
					
					alert('Paket Toplama Raflarına Tanımlı Değildir Lütfen Önce Tanımlama Yapın !');
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
					return false;
				}
				else if(get_durum.AMOUNT<=0)/*Paket Durum Miktar Belirtilmemişse*/
				{
					alert('Paket Toplama Raflarında Ürün İçin Miktar 0 dan Büyük Olmalıdır. !');
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
					return false;
				}
				else if(get_durum.PACKING_SIZE_TYPE_CODE=='')/*Paket Durum Palet Tipi Belirtilmemişse*/
				{
					alert('Paket Toplama Raflarında Ürün İçin Palet Tipi Belirtilmemiştir. Düzenleme Yapınız. !');
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
					return false;
				}
				else if(get_durum.recordcount >1) /*Paket Durum birden fazla bulunduysa*/
				{
					alert('Paket Toplama Raflarına Birden Fazla Tanımlanmış. Önce Düzenleme Yapın !');
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
					return false;
				}
				else
				{
					
					document.getElementById('first_area').style.display='none';
					document.getElementById('palet_turu').style.display='none';
					document.getElementById('second_area').style.display='';
					document.getElementById('fourth_area').style.display='';
					
					document.getElementById('product_name').value = get_product.PRODUCT_NAME;
					document.getElementById('collect_type').value = get_durum.PACKING_SIZE_TYPE_CODE;
					document.getElementById('collect_type_id').value = get_durum.PACKING_SIZE_TYPE_ID;
					document.getElementById('depo_miktar').value = get_product.PRODUCT_STOCK;
					document.getElementById('depo_kalan').value = get_product.PRODUCT_STOCK;
					document.getElementById('palet_miktar').value = get_durum.AMOUNT;
					document.getElementById('palet_kalan').value = get_durum.AMOUNT;
					document.getElementById('active_stock_id').value = get_product.STOCK_ID;
					document.getElementById('add_other_serial').focus();
				}
			}
		}
	}
	function serial_control(serial_no)
	{
		row_count = document.getElementById('row_count').value;
		serial_hata = 0;	
		for(i=1;i<=row_count;i++)
		{
			if(document.getElementById('SERIAL_NO'+i).value == serial_no)
			{
				serial_hata = 1;	
			}
		}
		/*var serial_sql = "SELECT E.PALET_BARCODE, E.SERIAL_NO, E.DEPO, E.PRODUCT_NAME, E.STOCK_ID, E.SPECT_ID, ISNULL(E.IS_PROTOTYPE, 0) AS IS_PROTOTYPE FROM EZGI_WM_SERIAL_NO_LAST_STATUS AS E INNER JOIN EZGI_WM_IS_SERIAL_NO_LIVE AS LV ON E.SERIAL_NO = LV.SERIAL_NO WHERE E.SERIAL_NO = '"+serial_no+"'";*/ /*Seri No Hala Bizde mi?*/
		/*var get_serial = wrk_query(serial_sql,'dsn3');*/
		
		var listParam = serial_no;
		var get_serial = wrk_safe_query('get_serial_livecontrol_serialno_ezgi','dsn3',0,listParam);
		
		stockid = get_serial.STOCK_ID;
		if(get_serial.IS_PROTOTYPE==1)
			spectmainid = get_serial.SPECT_ID;
		else
			spectmainid = 0;
		document.getElementById('row_stock_id').value=get_serial.STOCK_ID;
		if (get_serial.SERIAL_NO == undefined) /*Paket Durum Bulunamadıysa*/
		{
			alert('Seri No Kaydı Yoktur.!');
			document.getElementById('add_other_serial').value = '';
			document.getElementById('add_other_serial').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		else if(serial_hata == 1)
		{
			alert('Seri No Daha Önce Seçilmiştir..!');
			document.getElementById('add_other_serial').value = '';
			document.getElementById('add_other_serial').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		else if(get_serial.DEPO != document.getElementById('txt_department_out').value)
		{
			alert('Seri No Seçtiğiniz Lokasyonda Bulunmamaktadır.!');
			document.getElementById('add_other_serial').value = '';
			document.getElementById('add_other_serial').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		<cfif get_upd.IS_KARMA eq 0>
			else if(document.getElementById('row_stock_id').value != document.getElementById('active_stock_id').value)
			{
				alert('Seri No Seçtiğiniz Farklı Ürüne Bağlıdır.!');
				document.getElementById('add_other_serial').value = '';
				document.getElementById('add_other_serial').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
				return false;
			}
		</cfif>
		else if(get_serial.PALET_BARCODE !='')
		{
			alert(get_serial.PALET_BARCODE+' No lu Palette Daha Önce Kaydedilmiştir.!');
			document.getElementById('add_other_serial').value = '';
			document.getElementById('add_other_serial').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		else
		{
			row_count++;
			document.getElementById('row_count').value = row_count;
			var newRow;
			var newCell;	
			newRow = document.getElementById("table1").insertRow(document.getElementById("table1").rows.length);
			newRow.setAttribute("name","frm_row" + row_count);
			newRow.setAttribute("id","frm_row" + row_count);		
			newRow.setAttribute("NAME","frm_row" + row_count);
			newRow.setAttribute("ID","frm_row" + row_count);		
			
			newCell = newRow.insertCell();
			newCell.innerHTML = '<a onclick="sil(' + row_count + ');"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>';
					
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="hidden" name="row_kontrol'+row_count+'" id="row_kontrol'+row_count+'" value="1"><input name="PACKING_ROW_ID'+row_count+'" id="PACKING_ROW_ID'+row_count+'" type="hidden" value="0"><input name="STOCK_ID'+row_count+'" id="STOCK_ID'+row_count+'" type="hidden" value="'+stockid+'"><input name="SPECT_MAIN_ID'+row_count+'" id="SPECT_MAIN_ID'+row_count+'" type="hidden" value="'+spectmainid+'"><input name="row_number'+row_count+'" type="text" value="'+row_count+'" style="width:25px; text-align:right">';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="PRODUCT_NAME'+row_count+'" id="PRODUCT_NAME'+row_count+'" type="text" value="'+get_serial.PRODUCT_NAME+'" style="width:120px">';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="SERIAL_NO'+row_count+'" id="SERIAL_NO'+row_count+'" type="text" value="'+get_serial.SERIAL_NO+'" style="width:90px">';
			
			document.getElementById('depo_kalan').value = document.getElementById('depo_kalan').value*1 -1; /*Kalan Hesabı yeniden düzenleniyor*/
			document.getElementById('palet_kalan').value = document.getElementById('palet_kalan').value*1 -1;
			
			document.getElementById('txt_department_out').disabled = true; /*Depo Seçim select alanlar disable ediliyor*/
			document.getElementById('txt_department_in').disabled = true;
			
			document.getElementById('add_other_serial').value = '';
			document.getElementById('add_other_serial').focus(); /*Barkod ve Raf Alanını Temizle ve Yeniden Barkoda Odaklan*/	
			if(document.getElementById('palet_kalan').value == 0)
			{
				alert('Palet Doldu.!!!');
				document.getElementById('add_other_serial').disabled = true;
			}
		}
	}
	function sil(sy)
	{
		document.getElementById('row_kontrol'+sy).value=0;
		document.getElementById('frm_row'+sy).style.display="none";
		
		document.getElementById('row_kontrol'+sy).value = 0;
		document.getElementById('SERIAL_NO'+sy).value = '';
		document.getElementById('STOCK_ID'+sy).value = '';
		document.getElementById('SPECT_MAIN_ID'+sy).value = '';
		document.getElementById('PRODUCT_NAME'+sy).value = '';
		document.getElementById('PACKING_ROW_ID'+sy).value= -1;
		
		
		document.getElementById('depo_kalan').value = document.getElementById('depo_kalan').value*1 +1; 
		document.getElementById('palet_kalan').value = document.getElementById('palet_kalan').value*1 +1;
		
		document.getElementById('add_other_serial').disabled = false;
		document.getElementById('add_other_serial').value = '';
		document.getElementById('add_other_serial').focus(); /*Raf Alanını Aktif et Temizle ve Yeniden Odaklan*/	
	}
	function kontrol_kayit(process_type)
	{
		if(document.getElementById('status').checked==true)
			is_status =1;
		else
			is_status =0;
		if(process_type == 1) /*Güncelleme Basıldıysa*/
		{
			if(document.getElementById('palet_tur').value ==0) /*Standart Paletse*/
			{
				
				packing_closed_type = 2;
				if(document.getElementById('palet_kalan').value > 0)
				{
					alert('Paletteki Paket Sayısı Henüz Tamamlanmadı');
					packing_closed_type = 1;
				}
				if(document.getElementById('palet_kalan').value < 0)
				{
					alert('Paletteki Paket Sayısı Sınırı Aştı');
				}
				row_count = document.getElementById('row_count').value;	
				if(row_count >0) /*ilk Satırdan sonrası*/
				{
					document.getElementById('onay').disabled = true;
					action_doldur();
					sor = confirm("<cf_get_lang dictionary_id='57536.Güncellemek İstediğinizden Emin misiniz?'>");
					if(sor==true)
					{
						window.location.href='<cfoutput>#request.self#?fuseaction=stock.emptypopup_upd_ezgi_pallets&is_karma=0&packing_id=#attributes.packing_id#&process_status=#get_upd.PROCESS_STATUS#&process_cat=#get_process_cat.process_cat_id#&packing_action_type_id=#PACKING_ACTION_TYPE_ID#</cfoutput>&action_id='+document.getElementById('action_id').value+'&collect_type_id='+document.getElementById('collect_type_id').value+'&dep_in='+document.getElementById('txt_department_in').value+'&dep_out='+document.getElementById('txt_department_out').value+'&packing_closed_type='+packing_closed_type+'&stock_id='+document.getElementById('active_stock_id').value+'&is_status='+is_status;	
					}
					else
					{
						document.getElementById('onay').disabled = true;
						return false;
					}
				}
				else
				{
					alert('Sepette Kayıtlı Ürün Yok');
					return false;
				}
			}
			else /*Karma Paletse*/
			{
				packing_closed_type = 1;
				row_count = document.getElementById('row_count').value;	
				if(row_count >0) /*ilk Satırdan sonrası*/
				{
					action_doldur();
					document.getElementById('onay').disabled = true;
					sor = confirm("<cf_get_lang dictionary_id='57536.Güncellemek İstediğinizden Emin misiniz?'>");
					if(sor==true)
					{
						window.location.href='<cfoutput>#request.self#?fuseaction=stock.emptypopup_upd_ezgi_pallets&is_karma=1&packing_id=#attributes.packing_id#&process_status=#get_upd.PROCESS_STATUS#&process_cat=#get_process_cat.process_cat_id#&packing_action_type_id=#PACKING_ACTION_TYPE_ID#</cfoutput>&action_id='+document.getElementById('action_id').value+'&collect_type_id='+document.getElementById('collect_type_id').value+'&dep_in='+document.getElementById('txt_department_in').value+'&dep_out='+document.getElementById('txt_department_out').value+'&packing_closed_type='+packing_closed_type+'&collect_type_id_2='+document.getElementById('collect_type_id_2').value+'&is_status='+is_status;	
					}
					else
					{
						document.getElementById('onay').disabled = true;
						return false;
					}
				}
				else
				{
					document.getElementById('onay').disabled = true;
					sor = confirm("<cf_get_lang dictionary_id='57536.Güncellemek İstediğinizden Emin misiniz?'>");
					if(sor==true)
					{
						window.location.href='<cfoutput>#request.self#?fuseaction=stock.emptypopup_upd_ezgi_pallets&is_karma=1&packing_id=#attributes.packing_id#&process_status=#get_upd.PROCESS_STATUS#&packing_action_type_id=#PACKING_ACTION_TYPE_ID#&packing_closed_type=1</cfoutput>&dep_in='+document.getElementById('txt_department_in').value+'&collect_type_id_2='+document.getElementById('collect_type_id_2').value+'&dep_out='+document.getElementById('txt_department_out').value+'&is_status='+is_status;	
					}
					else
					{
						document.getElementById('onay').disabled = true;
						return false;
					}
				}
			}
		}
		else  /*Sil Basıldıysa*/
		{
			document.getElementById('sil').disabled = true;
			sor = confirm("<cf_get_lang dictionary_id='62142.Silmek istediğinize emin misiniz?'>");
			if(sor==true)
			{
				window.location.href='<cfoutput>#request.self#?fuseaction=stock.emptypopup_upd_ezgi_pallets&sil=1&is_karma=1&packing_id=#attributes.packing_id#</cfoutput>';	
			}
			else
			{
				document.getElementById('sil').disabled = false;
				return false;
			}
		}
	}
	function action_doldur()
	{
		var j = 1;
	  	for(i=1;i<=row_count;i++)
	  	{
		  	if(document.getElementById('row_kontrol'+i).value == 1 && document.getElementById('PACKING_ROW_ID'+i).value == 0)
		  	{
				if (j > 1)
					document.getElementById('action_id').value = document.getElementById('action_id').value + ',';
				document.getElementById('action_id').value = document.getElementById('action_id').value + j + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('PACKING_ROW_ID'+i).value + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('STOCK_ID'+i).value + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('SPECT_MAIN_ID'+i).value + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('SERIAL_NO'+i).value + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + '-'; /*Giriş Raf - Rezerve*/
				document.getElementById('action_id').value = document.getElementById('action_id').value + '-';/*Çıkış Raf - Rezerve*/
				document.getElementById('action_id').value = document.getElementById('action_id').value + '0'
				j++;
		  	}
	  	}
	}
	function pallet_status_change(process_type)
	{
		if(document.getElementById('status').checked==true)
			is_status =1;
		else
			is_status =0;
		if(process_type == 0)
		sor = confirm("Paleti Onaylıyorum.!");
		if(sor==true)
		{
			window.location.href='<cfoutput>#request.self#?fuseaction=stock.emptypopup_upd_ezgi_pallets&packing_id=#attributes.packing_id#&process_status=#get_upd.PROCESS_STATUS#</cfoutput>&process_action_type=2&is_status='+is_status;	
		}
	}
	function control_pallete_type(palette_type)
	{
		if(palette_type==1)
		{
			document.getElementById('cikis_depo').style.display='none';
			document.getElementById('first_area').style.display='none';
			document.getElementById('div_collect_type').style.display='';
		}
		else
		{
			document.getElementById('cikis_depo').style.display='';
			document.getElementById('first_area').style.display='';
			document.getElementById('div_collect_type').style.display='none';
		}
	}
</script>