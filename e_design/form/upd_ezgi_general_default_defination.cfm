<!---
    File: upd_ezgi_general_default_defination.cfm
    Folder: Add_Ons\ezgi\e-design\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_DESIGN_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM EZGI_COLORS WITH (NOLOCK)
</cfquery>
<cfquery name="get_thickness" datasource="#dsn3#">
	SELECT THICKNESS_ID, THICKNESS_VALUE, THICKNESS_NAME, UNIT, THICKNESS_PLUS_VALUE FROM EZGI_THICKNESS WITH (NOLOCK) WHERE IS_ACTIVE = 1 ORDER BY THICKNESS_NAME
</cfquery>
<cfquery name="get_thickness_ext" datasource="#dsn3#">
	SELECT THICKNESS_ID, THICKNESS_VALUE, THICKNESS_PRODUCT_NAME, UNIT FROM EZGI_THICKNESS_EXT WITH (NOLOCK) WHERE IS_ACTIVE = 1 ORDER BY THICKNESS_NAME
</cfquery>
<cfquery name="get_style" datasource="#dsn3#">
	SELECT  * FROM EZGI_DESIGN_PIECE_STYLE WITH (NOLOCK) ORDER BY EZGI_PIECE_STYLE_NAME
</cfquery>
<cfif len(get_defaults.DEFAULT_PACKAGE_CAT_ID)>
	<cfquery name="get_package_product_cat" datasource="#dsn1#">
     	SELECT PRODUCT_CATID, HIERARCHY PRODUCT_CAT_CODE, PRODUCT_CAT FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = #get_defaults.DEFAULT_PACKAGE_CAT_ID#
	</cfquery>	
<cfelse>
	<cfquery name="get_package_product_cat" datasource="#dsn1#">
     	SELECT PRODUCT_CATID, HIERARCHY PRODUCT_CAT_CODE, PRODUCT_CAT FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = 0
	</cfquery>
</cfif>
<cfif len(get_defaults.DEFAULT_PIECE_CAT_ID)>
 	<cfquery name="get_piece_product_cat" datasource="#dsn1#">
     	SELECT PRODUCT_CATID, HIERARCHY PRODUCT_CAT_CODE, PRODUCT_CAT FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = #get_defaults.DEFAULT_PIECE_CAT_ID#
 	</cfquery>
<cfelse>
	<cfquery name="get_piece_product_cat" datasource="#dsn1#">
     	SELECT PRODUCT_CATID, HIERARCHY PRODUCT_CAT_CODE, PRODUCT_CAT FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = 0
 	</cfquery>
</cfif>
<cfif get_defaults.recordcount>
    <cfif len(get_defaults.DEFAULT_PIECE_CAT_ID)>
        <cfquery name="get_piece_product_cat" datasource="#dsn1#">
            SELECT PRODUCT_CATID, HIERARCHY PRODUCT_CAT_CODE, PRODUCT_CAT FROM PRODUCT_CAT WITH (NOLOCK) WHERE PRODUCT_CATID = #get_defaults.DEFAULT_PIECE_CAT_ID#
        </cfquery>
    </cfif>
    <cfif len(get_defaults.DEFAULT_MASTER_PVC_STOCK_ID)>
        <cfquery name="get_stock_info" datasource="#dsn3#">
            SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_defaults.DEFAULT_MASTER_PVC_STOCK_ID#
        </cfquery>
    </cfif>
    <cfif len(get_defaults.PIECE_STOCK_ID_1)>
        <cfquery name="get_stock_info_piece_1" datasource="#dsn3#">
            SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_defaults.PIECE_STOCK_ID_1#
        </cfquery>
    </cfif>
    <cfif len(get_defaults.PIECE_STOCK_ID_2)>
        <cfquery name="get_stock_info_piece_2" datasource="#dsn3#">
            SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_defaults.PIECE_STOCK_ID_2#
        </cfquery>
    </cfif>
    <cfif len(get_defaults.PIECE_STOCK_ID_3)>
        <cfquery name="get_stock_info_piece_3" datasource="#dsn3#">
            SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_defaults.PIECE_STOCK_ID_3#
        </cfquery>
    </cfif>
    <cfif len(get_defaults.PIECE_STOCK_ID_4)>
        <cfquery name="get_stock_info_piece_4" datasource="#dsn3#">
            SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_defaults.PIECE_STOCK_ID_4#
        </cfquery>
    </cfif>
    <cfif len(get_defaults.PIECE_STOCK_ID_5)>
        <cfquery name="get_stock_info_piece_5" datasource="#dsn3#">
            SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_defaults.PIECE_STOCK_ID_5#
        </cfquery>
    </cfif>
    <cfif len(get_defaults.package_STOCK_ID_1)>
        <cfquery name="get_stock_info_package_1" datasource="#dsn3#">
            SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_defaults.package_STOCK_ID_1#
        </cfquery>
    </cfif>
    <cfif len(get_defaults.package_STOCK_ID_2)>
        <cfquery name="get_stock_info_package_2" datasource="#dsn3#">
            SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_defaults.package_STOCK_ID_2#
        </cfquery>
    </cfif>
    <cfif len(get_defaults.package_STOCK_ID_3)>
        <cfquery name="get_stock_info_package_3" datasource="#dsn3#">
            SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_defaults.package_STOCK_ID_3#
        </cfquery>
    </cfif>
    <cfif len(get_defaults.package_STOCK_ID_4)>
        <cfquery name="get_stock_info_package_4" datasource="#dsn3#">
            SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_defaults.package_STOCK_ID_4#
        </cfquery>
    </cfif>
    <cfif len(get_defaults.package_STOCK_ID_5)>
        <cfquery name="get_stock_info_package_5" datasource="#dsn3#">
            SELECT STOCK_ID, PRODUCT_ID, PRODUCT_NAME FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #get_defaults.package_STOCK_ID_5#
        </cfquery>
    </cfif>
    <cfif len(get_defaults.PROTOTIP_PACKAGE_ID)>
        <cfquery name="get_stock_info_PROTOTIP_PACKAGE" datasource="#dsn3#">
        	SELECT       
            	EDM.DESIGN_MAIN_NAME, 
                EDM.DESIGN_MAIN_ROW_ID
			FROM           
            	EZGI_DESIGN AS ED WITH (NOLOCK) INNER JOIN
              	EZGI_DESIGN_MAIN_ROW AS EDM WITH (NOLOCK) ON ED.DESIGN_ID = EDM.DESIGN_ID
			WHERE        
            	ED.IS_PROTOTIP = 1 AND 
                ED.IS_PRIVATE IS NULL
          	ORDER BY
            	EDM.DESIGN_MAIN_NAME
        </cfquery>
    <cfelse>
    	<cfset get_stock_info_PROTOTIP_PACKAGE.PRODUCT_NAME = ''>
    </cfif>
    <cfif len(get_defaults.PROTOTIP_PIECE_1_ID)>
        <cfquery name="get_stock_info_PROTOTIP_PIECE_1_ID" datasource="#dsn3#">
            SELECT PIECE_NAME FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) WHERE PIECE_ROW_ID = #get_defaults.PROTOTIP_PIECE_1_ID#
        </cfquery>
    <cfelse>
    	<cfset get_stock_info_PROTOTIP_PIECE_1_ID.PIECE_NAME = ''>
    </cfif>
    <cfif len(get_defaults.PROTOTIP_PIECE_2_ID)>
        <cfquery name="get_stock_info_PROTOTIP_PIECE_2_ID" datasource="#dsn3#">
            SELECT PIECE_NAME FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) WHERE PIECE_ROW_ID = #get_defaults.PROTOTIP_PIECE_2_ID#
        </cfquery>
    <cfelse>
    	<cfset get_stock_info_PROTOTIP_PIECE_2_ID.PIECE_NAME = ''>
    </cfif>
    <cfif len(get_defaults.PROTOTIP_PIECE_3_ID)>
        <cfquery name="get_stock_info_PROTOTIP_PIECE_3_ID" datasource="#dsn3#">
            SELECT PIECE_NAME FROM EZGI_DESIGN_PIECE_ROWS WITH (NOLOCK) WHERE PIECE_ROW_ID = #get_defaults.PROTOTIP_PIECE_3_ID#
        </cfquery>
    <cfelse>
    	<cfset get_stock_info_PROTOTIP_PIECE_3_ID.PIECE_NAME = ''>
    </cfif>
<cfelse>
	<cfset get_package_product_cat.product_cat = ''>
    <cfset get_package_product_cat.product_catid = ''>
    <cfset get_piece_product_cat.product_cat = ''>
    <cfset get_piece_product_cat.product_catid = ''>
    <cfset get_stock_info_PROTOTIP_PACKAGE.RECORDCOUNT = 0>
    <cfset get_stock_info_PROTOTIP_PIECE_1_ID.PIECE_NAME = ''>
    <cfset get_stock_info_PROTOTIP_PIECE_2_ID.PIECE_NAME = ''>
    <cfset get_stock_info_PROTOTIP_PIECE_3_ID.PIECE_NAME = ''>
</cfif>
<cfquery name="get_product_stage" datasource="#dsn#">
	SELECT 
    	R.PROCESS_ROW_ID, R.STAGE 
   	FROM 
    	PROCESS_TYPE AS P WITH (NOLOCK) INNER JOIN 
        PROCESS_TYPE_ROWS AS R WITH (NOLOCK) ON P.PROCESS_ID = R.PROCESS_ID 
  	WHERE        
    	P.IS_ACTIVE = 1 AND P.FACTION LIKE N'%product.form_upd_product%'
</cfquery>
<cfquery name="get_product_tree_stage" datasource="#dsn#">
	SELECT 
    	R.PROCESS_ROW_ID, R.STAGE 
   	FROM 
    	PROCESS_TYPE AS P WITH (NOLOCK) INNER JOIN 
        PROCESS_TYPE_ROWS AS R WITH (NOLOCK) ON P.PROCESS_ID = R.PROCESS_ID 
  	WHERE        
    	P.IS_ACTIVE = 1 AND P.FACTION LIKE N'%prod.add_product_tree%'
</cfquery>
<cfquery name="get_unit" datasource="#dsn#">
	SELECT UNIT FROM SETUP_UNIT WITH (NOLOCK) ORDER BY UNIT
</cfquery>
<cfquery name="get_product_account_cat" datasource="#dsn3#">
	SELECT PRO_CODE_CATID, PRO_CODE_CAT_NAME FROM SETUP_PRODUCT_PERIOD_CAT WITH (NOLOCK) WHERE IS_ACTIVE = 1
</cfquery>
<cfquery name="get_ws" datasource="#dsn3#">
	SELECT STATION_ID, STATION_NAME FROM WORKSTATIONS WITH (NOLOCK) WHERE UP_STATION IS NULL
</cfquery>
<cfquery name="get_operation" datasource="#dsn3#">
	SELECT OPERATION_TYPE_ID, OPERATION_TYPE FROM OPERATION_TYPES WITH (NOLOCK)
</cfquery>
<cfquery name="get_property" datasource="#dsn1#">
	SELECT PROPERTY_ID, PROPERTY FROM PRODUCT_PROPERTY WITH (NOLOCK)
</cfquery>
<cfquery name="get_model" datasource="#dsn1#">
	SELECT MODEL_ID, MODEL_NAME FROM PRODUCT_BRANDS_MODEL WITH (NOLOCK)
</cfquery>
<cfquery name="get_plus_name" datasource="#dsn3#">
	SELECT * FROM SETUP_PRO_INFO_PLUS_NAMES WITH (NOLOCK) WHERE OWNER_TYPE_ID = - 6
</cfquery>
<cfset property_list =''>
<cfloop from="1" to="20" index="i">
	<cfif len(Evaluate('get_plus_name.PROPERTY#i#_NAME'))>
    	<cfset property_list = ListAppend(property_list,i)>
    </cfif>
</cfloop>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfsavecontent variable="default">
		<cf_get_lang dictionary_id='114.Tasarım Genel Default Tanımları'>
	</cfsavecontent>
   <cf_box title="#default#">
    	<cfform name="add_defaults" method="post" action="#request.self#?fuseaction=prod.emptypopup_upd_ezgi_general_default_defination">
        	<cfoutput>
         	<cf_basket_form id="upd_design">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                     	<div class="row formContent">
							<cf_box_elements>
                             	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true" >
                                	<br>
                                	<div class="form-group" id="item-default_thickness">
                                    	<label class="col col-12 col-xs-12"><span style=" font-weight:bold"><cf_get_lang dictionary_id='105.Tasarım Tanımları'></span></label>
                                 	</div>
                                 	<div class="form-group" id="item-default_thickness">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='115.Yonga Levha Kalınlığı'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="default_thickness" id="default_thickness" >
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_thickness">
                                                    <option value="#thickness_id#"  <cfif get_thickness.thickness_id eq get_defaults.DEFAULT_YONGA_LEVHA_THICKNESS>selected="selected"</cfif>>#THICKNESS_VALUE# #UNIT#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-default_fire_rate">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='880.Yonga Levha Fire Oranı'> %</label>
                                     	<div class="col col-6 col-xs-12">
                                       		<cfinput type="text" name="default_fire_rate" id="default_fire_rate" value="#get_defaults.DEFAULT_YONGA_LEVHA_FIRE_RATE#" style="text-align:right">
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-pvc_default_thickness">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='116.PVC Kalınlığı'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="pvc_default_thickness" id="pvc_default_thickness">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_thickness_ext">
                                                    <option value="#thickness_id#"  <cfif get_thickness_ext.thickness_id eq get_defaults.DEFAULT_PVC_THICKNESS>selected="selected"</cfif>>#TlFormat(THICKNESS_VALUE,1)# #UNIT#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-pvc_default_fire_rate">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='879.PVC Fire Miktarı'> (mm.)</label>
                                     	<div class="col col-6 col-xs-12">
                                       		<cfinput type="text" name="pvc_default_fire_rate" id="pvc_default_fire_rate" value="#get_defaults.DEFAULT_PVC_FIRE_AMOUNT#" style="text-align:right">
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-urun">
                                    	<label class="col col-6 col-xs-12">PVC <cf_get_lang dictionary_id='112.Master Ürün'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<div class="input-group">
                                       			<input type="text" name="urun" id="urun" value="<cfif len(get_defaults.DEFAULT_MASTER_PVC_STOCK_ID)>#get_stock_info.PRODUCT_NAME#</cfif>">
                                            	<input type="hidden" name="pid" id="pid" value="<cfif len(get_defaults.DEFAULT_MASTER_PVC_STOCK_ID)>#get_stock_info.PRODUCT_ID#</cfif>">
                                            	<input type="hidden" name="stock_id" id="stock_id" value="<cfif len(get_defaults.DEFAULT_MASTER_PVC_STOCK_ID)>#get_stock_info.STOCK_ID#</cfif>">
                                            	<span class="input-group-addon icon-ellipsis btnPointer" onclick="pencere_ac();"></span>
                                            </div>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-master_model_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='906.Master Ürün Model Kodu'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="master_model_id" id="master_model_id">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_model">
                                                    <option value="#MODEL_ID#"  <cfif MODEL_ID eq get_defaults.DEFAULT_MASTER_SHORT_CODE_ID>selected="selected"</cfif>>#MODEL_NAME#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-piece_type">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='907.Default Parça Tipi'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="piece_type" id="piece_type">
                                                <option value="1" <cfif get_defaults.DEFAULT_PIECE_TYPE eq 1>selected</cfif>>01-<cf_get_lang dictionary_id='898.Yonga Levha Reçete İşlemi'></option>
                                                <option value="2" <cfif get_defaults.DEFAULT_PIECE_TYPE eq 2>selected</cfif>>02-<cf_get_lang dictionary_id='899.Genel Reçete İşlemi'></option>
                                                <option value="3" <cfif get_defaults.DEFAULT_PIECE_TYPE eq 3>selected</cfif>>03-<cf_get_lang dictionary_id='74.Reçetedeki Ürünün Montajı'></option>
                                                <option value="4" <cfif get_defaults.DEFAULT_PIECE_TYPE eq 4>selected</cfif>>04-<cf_get_lang dictionary_id='900.Hammadde Ekle'></option>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-trim_type">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='887.Yonga Levha Tıraşlama'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="trim_type" id="trim_type">
                                                <option value="0" <cfif get_defaults.DEFAULT_TRIM_TYPE eq 0>selected</cfif>><cf_get_lang dictionary_id='89.Tıraşlama Yok'></option>
                                                <option value="1" <cfif get_defaults.DEFAULT_TRIM_TYPE eq 1>selected</cfif>><cf_get_lang dictionary_id="814.Kenar Bantlama Varsa"></option>
                                                <option value="2" <cfif get_defaults.DEFAULT_TRIM_TYPE eq 2>selected</cfif>><cf_get_lang dictionary_id="815.Tüm Kenarları Traşlama"></option>
                                                <option value="3" <cfif get_defaults.DEFAULT_TRIM_TYPE eq 3>selected</cfif>><cf_get_lang dictionary_id="816.Kenar Seçmeli Traşlama"></option>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-canalizing_type">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='1293.Yonga Levha Kanal Açma'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="canalizing_type" id="canalizing_type">
                                                <option value="0" <cfif get_defaults.DEFAULT_PIECE_CANALIZING eq 0>selected</cfif>><cf_get_lang dictionary_id='58546.Yok'></option>
                                                <option value="1" <cfif get_defaults.DEFAULT_PIECE_CANALIZING eq 1>selected</cfif>><cf_get_lang dictionary_id="58564.Var"></option>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-piece_style_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='1288.Default Parça Sitili'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="piece_style_id" id="piece_style_id">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_style">
                                                    <option value="#EZGI_PIECE_STYLE_ID#"  <cfif EZGI_PIECE_STYLE_ID eq get_defaults.DEFAULT_PIECE_STYLE_ID>selected="selected"</cfif>>#EZGI_PIECE_STYLE_NAME#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-trim_size">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='86.Tıraşlama Payı'> (mm.)</label>
                                     	<div class="col col-6 col-xs-12">
                                       		<cfinput type="text" name="trim_size" id="trim_size" value="#TlFormat(get_defaults.DEFAULT_TRIM_AMOUNT,1)#" style="text-align:right">
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-product_amount">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='878.Genel Üretim Miktarı'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<cfinput type="text" name="product_amount" id="product_amount" value="#TlFormat(get_defaults.DEFAULT_PRODUCTION_AMOUNT,0)#" style="text-align:right">
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-time_type">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='117.Süre Gösterim Bilgisi'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="time_type" id="time_type">
                                                <option value="0" <cfif get_defaults.DEFAULT_IS_STATION_OR_IS_OPERATION eq 0>selected</cfif>><cf_get_lang dictionary_id='29419.Operasyon'></option>
                                                <option value="1" <cfif get_defaults.DEFAULT_IS_STATION_OR_IS_OPERATION eq 1>selected</cfif>><cf_get_lang dictionary_id='58834.İstasyon'></option>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-daily_working_time">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='862.Günlük Çalışma Süresi'> (<cf_get_lang dictionary_id='57491.Saat'>)</label>
                                     	<div class="col col-6 col-xs-12">
                                       		<cfinput type="text" name="daily_working_time" id="daily_working_time" value="#TlFormat(get_defaults.DEFAULT_DAILY_WORKING_TIME,2)#" style="text-align:right">
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-active_operator_amount">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='863.Aktif Operatör Sayısı'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<cfinput type="text" name="active_operator_amount" id="active_operator_amount" value="#TlFormat(get_defaults.DEFAULT_ACTIVE_OPERATOR_AMOUNT,0)#" style="text-align:right">
                                      	</div>
                                 	</div>
                                    <br/>
                                    <div class="form-group" id="item-default_thickness">
                                    	<label class="col col-12 col-xs-12"><span style=" font-weight:bold"><cf_get_lang dictionary_id='119.Tasarım Default Renk Tanım Bilgisi'></span></label>
                                 	</div>
                                    <div class="form-group" id="item-color_property_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='120.Renk Özellik Tanımı'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="color_property_id" id="color_property_id">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_property">
                                                    <option value="#property_id#"  <cfif property_id eq get_defaults.DEFAULT_COLOR_PROPERTY_ID>selected="selected"</cfif>>#property#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-thickness_property_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='121.Kalınlık Özellik Tanımı'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="thickness_property_id" id="thickness_property_id"
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_property">
                                                    <option value="#property_id#"  <cfif property_id eq get_defaults.DEFAULT_THICKNESS_PROPERTY_ID>selected="selected"</cfif>>#property#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-thickness_ext_property_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='122.Kal.Etkisi Özellik Tanımı'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="thickness_ext_property_id" id="thickness_ext_property_id">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_property">
                                                    <option value="#property_id#"  <cfif property_id eq get_defaults.DEFAULT_THICKNESS_EXT_PROPERTY_ID>selected="selected"</cfif>>#property#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                              	</div>
                                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="2" sort="true" style=" border-left:groove">
                                	<br/>
                                 	<div id="piece_" style="width:100%">
										<cfsavecontent variable="piece"><cf_get_lang dictionary_id='123.Parça Standart Eklentileri'></cfsavecontent>
                                        <cf_seperator title="#piece#" id="_piece" is_closed="1">
                                            <cf_form_list id="_piece">
                                            <thead>
                                                <tr height="30">
                                                    <th width="10px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                    <th width="180px"><cf_get_lang dictionary_id='908.Stok Cinsi'></th>
                                                    <th width="10px"></th>
                                                    <th width="180px"><cf_get_lang dictionary_id='58028.Formül'></th>
                                                </tr>
                                            </thead>
                                            <tbody name="piece" id="piece">
                                                <tr height="30">
                                                    <td style="text-align:right">1-</td>
                                                    <td nowrap="nowrap">
                                                        <input type="text"  name="urun_piece_1" id="urun_piece_1" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_1)>#get_stock_info_piece_1.PRODUCT_NAME#</cfif></cfoutput>">
                                                        <input type="hidden" name="pid_piece_1" id="pid_piece_1" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_1)>#get_stock_info_piece_1.PRODUCT_ID#</cfif></cfoutput>">
                                                        <input type="hidden" name="stock_id_piece_1" id="stock_id_piece_1" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_1)>#get_defaults.PIECE_STOCK_ID_1#</cfif></cfoutput>">
                                                    </td>
                                                    <td style="text-align:center; background-color:gainsboro" nowrap="nowrap">
                                                        <a style="cursor:pointer" href"javascript://" onClick="pencere_ac_piece_1();">
                                                            <img src="/images/plus_thin.gif" align="absmiddle" border="0" style="vertical-align:bottom">
                                                        </a>
                                                    </td>
                                                    <td nowrap="nowrap">
                                                        <input type="text" name="piece_formul_1" id="piece_formul_1" style="width:96%; height:25px; border:none" value="<cfoutput><cfif len(get_defaults.PIECE_FORMUL_1)>#get_defaults.PIECE_FORMUL_1#</cfif></cfoutput>">
                                                    </td>
                                                </tr>
                                                <tr height="30">
                                                    <td style="text-align:right">2-</td>
                                                    <td>
                                                        <input type="text" name="urun_piece_2" id="urun_piece_2" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_2)>#get_stock_info_piece_2.PRODUCT_NAME#</cfif></cfoutput>">
                                                        <input type="hidden" name="pid_piece_2" id="pid_piece_2" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_2)>#get_stock_info_piece_2.PRODUCT_ID#</cfif></cfoutput>">
                                                        <input type="hidden" name="stock_id_piece_2" id="stock_id_piece_2" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_2)>#get_defaults.PIECE_STOCK_ID_2#</cfif></cfoutput>">
                                                    </td>
                                                    <td style="text-align:center;background-color:gainsboro"  nowrap="nowrap">
                                                        <a style="cursor:pointer" href"javascript://" onClick="pencere_ac_piece_2();">
                                                            <img src="/images/plus_thin.gif" align="absmiddle" border="0" style="vertical-align:bottom">
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <input type="text" name="piece_formul_2" id="piece_formul_2" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.PIECE_FORMUL_2)>#get_defaults.PIECE_FORMUL_2#</cfif></cfoutput>">
                                                    </td>
                                                </tr>
                                                <tr height="30">
                                                    <td style="text-align:right">3-</td>
                                                    <td>
                                                        <input type="text" name="urun_piece_3" id="urun_piece_3" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_3)>#get_stock_info_piece_3.PRODUCT_NAME#</cfif></cfoutput>">
                                                        <input type="hidden" name="pid_piece_3" id="pid_piece_3" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_3)>#get_stock_info_piece_3.PRODUCT_ID#</cfif></cfoutput>">
                                                        <input type="hidden" name="stock_id_piece_3" id="stock_id_piece_3" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_3)>#get_defaults.PIECE_STOCK_ID_3#</cfif></cfoutput>">
                                                    </td>
                                                    <td style="text-align:center;background-color:gainsboro" nowrap="nowrap">
                                                        <a style="cursor:pointer" href"javascript://" onClick="pencere_ac_piece_3();">
                                                            <img src="/images/plus_thin.gif" align="absmiddle" border="0" style="vertical-align:bottom">
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <input type="text" name="piece_formul_3" id="piece_formul_3" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.PIECE_FORMUL_3)>#get_defaults.PIECE_FORMUL_3#</cfif></cfoutput>">
                                                    </td>
                                                </tr>
                                                <tr height="30">
                                                    <td style="text-align:right">4-</td>
                                                    <td>
                                                        <input type="text" name="urun_piece_4" id="urun_piece_4" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_4)>#get_stock_info_piece_4.PRODUCT_NAME#</cfif></cfoutput>">
                                                        <input type="hidden" name="pid_piece_4" id="pid_piece_4" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_4)>#get_stock_info_piece_4.PRODCUT_ID#</cfif></cfoutput>">
                                                        <input type="hidden" name="stock_id_piece_4" id="stock_id_piece_4" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_4)>#get_defaults.PIECE_STOCK_ID_4#</cfif></cfoutput>">
                                                    </td>
                                                    <td style="text-align:center;background-color:gainsboro"  nowrap="nowrap">
                                                        <a style="cursor:pointer" href"javascript://" onClick="pencere_ac_piece_4();">
                                                            <img src="/images/plus_thin.gif" align="absmiddle" border="0" style="vertical-align:bottom">
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <input type="text" name="piece_formul_4" id="piece_formul_4" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.PIECE_FORMUL_4)>#get_defaults.PIECE_FORMUL_4#</cfif></cfoutput>">
                                                    </td>
                                                </tr>
                                                <tr height="30">
                                                    <td style="text-align:right">5-</td>
                                                    <td>
                                                        <input type="text" name="urun_piece_5" id="urun_piece_5" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_5)>#get_stock_info_piece_5.PRODUCT_NAME#</cfif></cfoutput>">
                                                        <input type="hidden" name="pid_piece_5" id="pid_piece_5" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_5)>#get_stock_info_piece_5.PRODUCT_ID#</cfif></cfoutput>">
                                                        <input type="hidden" name="stock_id_piece_5" id="stock_id_piece_5" value="<cfoutput><cfif len(get_defaults.PIECE_STOCK_ID_5)>#get_defaults.PIECE_STOCK_ID_5#</cfif></cfoutput>">
                                                    </td>
                                                    <td style="text-align:center;background-color:gainsboro"  nowrap="nowrap">
                                                        <a style="cursor:pointer" href"javascript://" onClick="pencere_ac_piece_5();">
                                                            <img src="/images/plus_thin.gif" align="absmiddle" border="0" style="vertical-align:bottom">
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <input type="text" name="piece_formul_5" id="piece_formul_5" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.PIECE_FORMUL_5)>#get_defaults.PIECE_FORMUL_5#</cfif></cfoutput>">
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </cf_form_list>
                                 	</div>
                					<br/>
                                    <div id="package_" style="width:100%">
										<cfsavecontent variable="package"><cf_get_lang dictionary_id='124.Paket Standart Eklentileri'></cfsavecontent>
                                        <cf_seperator title="#package#" id="_package" is_closed="1">
                                            <cf_form_list id="_package">
                                            <thead>
                                                <tr height="30">
                                                    <th width="10"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                    <th width="180"><cf_get_lang dictionary_id='908.Stok Cinsi'></th>
                                                    <th width="10"></th>
                                                    <th width="180"><cf_get_lang dictionary_id='58028.Formül'></th>
                                                </tr>
                                            </thead>
                                            <tbody name="package" id="package">
                                                <tr height="30">
                                                    <td style="text-align:right">1-</td>
                                                    <td>
                                                        <input type="text" name="urun_package_1" id="urun_package_1" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_1)>#get_stock_info_package_1.PRODUCT_NAME#</cfif></cfoutput>">
                                                        <input type="hidden" name="pid_package_1" id="pid_package_1" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_1)>#get_stock_info_package_1.PRODUCT_ID#</cfif></cfoutput>">
                                                        <input type="hidden" name="stock_id_package_1" id="stock_id_package_1" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_1)>#get_defaults.package_STOCK_ID_1#</cfif></cfoutput>">
                                                    </td>
                                                    <td style="text-align:center;background-color:gainsboro"  nowrap="nowrap">
                                                        <a style="cursor:pointer" href"javascript://" onClick="pencere_ac_package_1();">
                                                            <img src="/images/plus_thin.gif" align="absmiddle" border="0" style="vertical-align:bottom">
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <input type="text" name="package_formul_1" id="package_formul_1" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.package_FORMUL_1)>#get_defaults.package_FORMUL_1#</cfif></cfoutput>">
                                                    </td>
                                                </tr>
                                                <tr height="30">
                                                    <td style="text-align:right">2-</td>
                                                    <td>
                                                        <input type="text" name="urun_package_2" id="urun_package_2" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_2)>#get_stock_info_package_2.PRODUCT_NAME#</cfif></cfoutput>">
                                                        <input type="hidden" name="pid_package_2" id="pid_package_2" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_2)>#get_stock_info_package_2.PRODUCT_ID#</cfif></cfoutput>">
                                                        <input type="hidden" name="stock_id_package_2" id="stock_id_package_2" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_2)>#get_defaults.package_STOCK_ID_2#</cfif></cfoutput>">
                                                    </td>
                                                    <td style="text-align:center;background-color:gainsboro"  nowrap="nowrap">
                                                        <a style="cursor:pointer" href"javascript://" onClick="pencere_ac_package_2();">
                                                            <img src="/images/plus_thin.gif" align="absmiddle" border="0" style="vertical-align:bottom">
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <input type="text" name="package_formul_2" id="package_formul_2" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.package_FORMUL_2)>#get_defaults.package_FORMUL_2#</cfif></cfoutput>">
                                                    </td>
                                                </tr>
                                                <tr height="30">
                                                    <td style="text-align:right">3-</td>
                                                    <td>
                                                        <input type="text" name="urun_package_3" id="urun_package_3" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_3)>#get_stock_info_package_3.PRODUCT_NAME#</cfif></cfoutput>">
                                                        <input type="hidden" name="pid_package_3" id="pid_package_3" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_3)>#get_stock_info_package_3.PRODUCT_ID#</cfif></cfoutput>">
                                                        <input type="hidden" name="stock_id_package_3" id="stock_id_package_3" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_3)>#get_defaults.package_STOCK_ID_3#</cfif></cfoutput>">
                                                    </td>
                                                    <td style="text-align:center;background-color:gainsboro"  nowrap="nowrap">
                                                        <a style="cursor:pointer" href"javascript://" onClick="pencere_ac_package_3();">
                                                            <img src="/images/plus_thin.gif" align="absmiddle" border="0" style="vertical-align:bottom">
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <input type="text" name="package_formul_3" id="package_formul_3" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.package_FORMUL_3)>#get_defaults.package_FORMUL_3#</cfif></cfoutput>">
                                                    </td>
                                                </tr>
                                                <tr height="30">
                                                    <td style="text-align:right">4-</td>
                                                    <td>
                                                        <input type="text" name="urun_package_4" id="urun_package_4" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_4)>#get_stock_info_package_4.PRODUCT_NAME#</cfif></cfoutput>">
                                                        <input type="hidden" name="pid_package_4" id="pid_package_4" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_4)>#get_stock_info_package_4.PRODUCT_ID#</cfif></cfoutput>">
                                                        <input type="hidden" name="stock_id_package_4" id="stock_id_package_4" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_4)>#get_defaults.package_STOCK_ID_4#</cfif></cfoutput>">
                                                    </td>
                                                    <td style="text-align:center;background-color:gainsboro"  nowrap="nowrap">
                                                        <a style="cursor:pointer" href"javascript://" onClick="pencere_ac_package_4();">
                                                            <img src="/images/plus_thin.gif" align="absmiddle" border="0" style="vertical-align:bottom">
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <input type="text" name="package_formul_4" id="package_formul_4" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.package_FORMUL_4)>#get_defaults.package_FORMUL_4#</cfif></cfoutput>">
                                                    </td>
                                                </tr>
                                                <tr height="30">
                                                    <td style="text-align:right">5-</td>
                                                    <td>
                                                        <input type="text" name="urun_package_5" id="urun_package_5" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_5)>#get_stock_info_package_5.PRODUCT_NAME#</cfif></cfoutput>">
                                                        <input type="hidden" name="pid_package_5" id="pid_package_5" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_5)>#get_stock_info_package_5.PRODUCT_ID#</cfif></cfoutput>">
                                                        <input type="hidden" name="stock_id_package_5" id="stock_id_package_5" value="<cfoutput><cfif len(get_defaults.package_STOCK_ID_5)>#get_defaults.package_STOCK_ID_5#</cfif></cfoutput>">
                                                    </td>
                                                    <td style="text-align:center;background-color:gainsboro"  nowrap="nowrap">
                                                        <a style="cursor:pointer" href"javascript://" onClick="pencere_ac_package_5();">
                                                            <img src="/images/plus_thin.gif" align="absmiddle" border="0" style="vertical-align:bottom">
                                                        </a>
                                                    </td>
                                                    <td>
                                                        <input type="text" name="package_formul_5" id="package_formul_5" style="width:96%; height:25px; border:none;" value="<cfoutput><cfif len(get_defaults.package_FORMUL_5)>#get_defaults.package_FORMUL_5#</cfif></cfoutput>">
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </cf_form_list>
                                 	</div>
                             	</div>
                                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="3" sort="true" style=" border-left:groove">
                                	<br>
                                	<div class="form-group" id="item-default_thickness">
                                    	<label class="col col-12 col-xs-12"><span style=" font-weight:bold"><cf_get_lang dictionary_id='125.Tasarım Aktarım Tanımları'></span></label>
                                 	</div>
                                 	<div class="form-group" id="item-package_product_catid">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='877.Paket Kategorisi'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<div class="input-group">
                                       			<cfsavecontent variable="message"><cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'>!</cfsavecontent>
                         						<input type="hidden" name="package_product_cat_code" id="package_product_cat_code" value="<cfif len(get_defaults.DEFAULT_PACKAGE_CAT_ID)><cfoutput>#get_package_product_cat..product_cat_code#</cfoutput></cfif>">
                       							<input type="hidden" name="package_product_catid" id="package_product_catid" value="<cfoutput>#get_package_product_cat.PRODUCT_CATID#</cfoutput>">
                         						<cfinput type="text" name="package_product_cat" id="package_product_cat" style="width:150px;" value="#get_package_product_cat.product_cat#" onFocus="AutoComplete_Create('package_product_cat','PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','','PRODUCT_CATID','package_product_catid','','3','200');">
                                                <span class="input-group-addon icon-ellipsis btnPoniter" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_cat_names&field_code=add_defaults.package_product_cat_code&is_sub_category=1&field_id=add_defaults.package_product_catid&field_name=add_defaults.package_product_cat&field_min=add_design.MIN_MARGIN&field_max=add_design.MAX_MARGIN');" title="<cf_get_lang dictionary_id='37157.Ürün Kategorisi Ekle'>!"></span>
                                            </div>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-piece_product_catid">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='876.Parça Kategorisi'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<div class="input-group">
                                       			<cfsavecontent variable="message1"><cf_get_lang dictionary_id='63587.Girilmesi Zorunlu Alan'>!</cfsavecontent>
                                                <input type="hidden" name="piece_product_cat_code" id="piece_product_cat_code" value="<cfif len(get_defaults.DEFAULT_PIECE_CAT_ID)><cfoutput>#get_piece_product_cat..product_cat_code#</cfoutput></cfif>">
                                                <input type="hidden" name="piece_product_catid" id="piece_product_catid" value="<cfoutput>#get_piece_product_cat.PRODUCT_CATID#</cfoutput>">
                                                <cfinput type="text" name="piece_product_cat" id="piece_product_cat" style="width:150px;" value="#get_piece_product_cat.product_cat#" onFocus="AutoComplete_Create('piece_product_cat','PRODUCT_CAT,HIERARCHY','PRODUCT_CAT_NAME','get_product_cat','','PRODUCT_CATID','piece_product_catid','','3','200');">
                                                <span class="input-group-addon icon-ellipsis btnPoniter" onclick="openBoxDraggable('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_product_cat_names&field_code=add_defaults.piece_product_cat_code&is_sub_category=1&field_id=add_defaults.piece_product_catid&field_name=add_defaults.piece_product_cat&field_min=add_design.MIN_MARGIN&field_max=add_design.MAX_MARGIN');" title="<cf_get_lang dictionary_id='37157.Ürün Kategorisi Ekle'>!"></span>
                                            </div>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-product_process_stage">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='875.Ürün Kayıt Süreci'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="product_process_stage" id="product_process_stage">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_product_stage">
                                                    <option value="#PROCESS_ROW_ID#"  <cfif PROCESS_ROW_ID eq get_defaults.DEFAULT_PRODUCT_PROCESS_STAGE>selected="selected"</cfif>>#Stage#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-product_tree_process_stage">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='874.Ürün Ağacı Kayıt Süreci'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="product_tree_process_stage" id="product_tree_process_stage">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_product_tree_stage">
                                                    <option value="#PROCESS_ROW_ID#"  <cfif PROCESS_ROW_ID eq get_defaults.DEFAULT_PRODUCT_TREE_PROCESS_STAGE>selected="selected"</cfif>>#Stage#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-main_unit">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='873.Modül Birim'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="main_unit" id="main_unit">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_unit">
                                                    <option value="#UNIT#"  <cfif UNIT eq get_defaults.DEFAULT_MAIN_UNIT>selected="selected"</cfif>>#UNIT#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-package_unit">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='872.Paket Birim'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="package_unit" id="package_unit">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_unit">
                                                    <option value="#UNIT#"  <cfif UNIT eq get_defaults.DEFAULT_PACKAGE_UNIT>selected="selected"</cfif>>#UNIT#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-piece_unit">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='871.Parça Birim'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="piece_unit" id="piece_unit" style="width:150px; height:20px">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_unit">
                                                    <option value="#UNIT#"  <cfif UNIT eq get_defaults.DEFAULT_PIECE_UNIT>selected="selected"</cfif>>#UNIT#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-main_account_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='141.Modül'> <cf_get_lang dictionary_id='127.Muh.Bt.Hes.Kodu'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="main_account_id" id="main_account_id" style="width:150px; height:20px">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_product_account_cat">
                                                    <option value="#PRO_CODE_CATID#"  <cfif PRO_CODE_CATID eq get_defaults.DEFAULT_MAIN_ACCOUNT_ID>selected="selected"</cfif>>#PRO_CODE_CAT_NAME#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-package_account_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='100.Paket'> <cf_get_lang dictionary_id='127.Muh.Bt.Hes.Kodu'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="package_account_id" id="package_account_id" style="width:150px; height:20px">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_product_account_cat">
                                                    <option value="#PRO_CODE_CATID#"  <cfif PRO_CODE_CATID eq get_defaults.DEFAULT_PACKAGE_ACCOUNT_ID>selected="selected"</cfif>>#PRO_CODE_CAT_NAME#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-piece_account_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='45.Parça'> <cf_get_lang dictionary_id='127.Muh.Bt.Hes.Kodu'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="piece_account_id" id="piece_account_id" style="width:150px; height:20px">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_product_account_cat">
                                                    <option value="#PRO_CODE_CATID#"  <cfif PRO_CODE_CATID eq get_defaults.DEFAULT_PIECE_ACCOUNT_ID>selected="selected"</cfif>>#PRO_CODE_CAT_NAME#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-main_station_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='870.Modül İstasyonu'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="main_station_id" id="main_station_id" style="width:150px; height:20px">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                
                                                <cfloop query="get_ws">
                                                    <option value="#STATION_ID#"  <cfif STATION_ID eq get_defaults.DEFAULT_MAIN_WORKSTATION_ID>selected="selected"</cfif>>#STATION_NAME#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-package_station_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='869.Paket İstasyonu'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="package_station_id" id="package_station_id" style="width:150px; height:20px">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_ws">
                                                    <option value="#STATION_ID#"  <cfif STATION_ID eq get_defaults.DEFAULT_PACKAGE_WORKSTATION_ID>selected="selected"</cfif>>#STATION_NAME#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-piece_station_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='868.Parça İstasyonu'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="piece_station_id" id="piece_station_id" style="width:150px; height:20px">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_ws">
                                                    <option value="#STATION_ID#"  <cfif STATION_ID eq get_defaults.DEFAULT_PIECE_WORKSTATION_ID>selected="selected"</cfif>>#STATION_NAME#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-main_operation_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='867.Modül Operasyonu'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="main_operation_id" id="main_operation_id" style="width:150px; height:20px">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_operation">
                                                    <option value="#OPERATION_TYPE_ID#"  <cfif OPERATION_TYPE_ID eq get_defaults.DEFAULT_MAIN_OPERATION_TYPE_ID>selected="selected"</cfif>>#OPERATION_TYPE#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-package_operation_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='866.Paket Operasyonu'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="package_operation_id" id="package_operation_id" style="width:150px; height:20px">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_operation">
                                                    <option value="#OPERATION_TYPE_ID#"  <cfif OPERATION_TYPE_ID eq get_defaults.DEFAULT_PACKAGE_OPERATION_TYPE_ID>selected="selected"</cfif>>#OPERATION_TYPE#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-cutting_operation_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='865.Ebatlama Operasyonu'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="cutting_operation_id" id="cutting_operation_id" style="width:150px; height:20px">
                                                 <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop query="get_operation">
                                                    <option value="#OPERATION_TYPE_ID#"  <cfif OPERATION_TYPE_ID eq get_defaults.DEFAULT_CUTTING_OPERATION_TYPE_ID>selected="selected"</cfif>>#OPERATION_TYPE#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-transfer_type">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='909.Yonga Levha Transfer Tipi'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="transfer_type" id="transfer_type" style="width:150px; height:20px" >
                                                <option value="0" <cfif get_defaults.DEFAULT_TRANSFER_TYPE eq 0>selected</cfif>><cf_get_lang dictionary_id='910.Direkt Hammadde'></option>
                                                <option value="1" <cfif get_defaults.DEFAULT_TRANSFER_TYPE eq 1>selected</cfif>><cf_get_lang dictionary_id='911.Kesilmiş Yarı Mamül'></option>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-main_transfer_type">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='912.Modül Transfer Tipi'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="main_transfer_type" id="main_transfer_type" style="width:150px; height:20px" >
                                                <option value="1" <cfif get_defaults.DEFAULT_MAIN_TRANSFER_TYPE eq 1>selected</cfif>><cf_get_lang dictionary_id='913.Standart Ürün'></option>
                                                <option value="2" <cfif get_defaults.DEFAULT_MAIN_TRANSFER_TYPE eq 2>selected</cfif>><cf_get_lang dictionary_id='37467.Demonte Ürün'></option>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-sub_transfer_type">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='914.Hizmet Ürünleri Transfer Tipi'></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="sub_transfer_type" id="sub_transfer_type" style="width:150px; height:20px" >
                                                <option value="0" <cfif get_defaults.IS_HIZMET_PHANTOM eq 0>selected</cfif>><cf_get_lang dictionary_id='915.Standart Bağlantı'></option>
                                                <option value="1" <cfif get_defaults.IS_HIZMET_PHANTOM eq 1>selected</cfif>><cf_get_lang dictionary_id='916.Hayalet Bağlantı'></option>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-operation_transfer_type">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id="828.Operasyon Transfer Tipi"></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="operation_transfer_type" id="operation_transfer_type" style="width:150px; height:20px" >
                                                <option value="0" <cfif get_defaults.OPERATION_TRANSFER_TYPE eq 0>selected</cfif>><cf_get_lang dictionary_id="826.E-Designda Tanımlı Miktar"></option>
                                                <option value="1" <cfif get_defaults.OPERATION_TRANSFER_TYPE eq 1>selected</cfif>><cf_get_lang dictionary_id="827.Sabit Tek Operasyon"></option>
                                            </select>
                                      	</div>
                                 	</div>
                             	</div>
                                <div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="4" sort="true" style=" border-left:groove">
                                	<br/>
                                	<div class="form-group" id="item-default_thickness">
                                    	<label class="col col-6 col-xs-12"><span style=" font-weight:bold"><cf_get_lang dictionary_id='886.Ek Bilgi Tanımları'></span></label>
                                 	</div>
                                 	<div class="form-group" id="item-production_expence_rate">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='133.Üretim Gideri Katsayısı'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="production_expence_rate" id="production_expence_rate" style="width:160px; height:20px" >
                                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop list="#property_list#" index="i">
                                                    <option value="#i#" <cfif get_defaults.DEFAULT_PRODUCT_EXPENCE_NO eq i>selected</cfif>>#Evaluate('get_plus_name.PROPERTY#i#_NAME')#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-labor_expence_rate">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='134.İşçilik Gideri Katsayısı'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="labor_expence_rate" id="labor_expence_rate" style="width:160px; height:20px" >
                                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop list="#property_list#" index="i">
                                                    <option value="#i#" <cfif get_defaults.DEFAULT_LABOR_EXPENCE_NO eq i>selected</cfif>>#Evaluate('get_plus_name.PROPERTY#i#_NAME')#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-kanban_expence_rate">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id='135.Kanban Gideri Katsayısı'></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="kanban_expence_rate" id="kanban_expence_rate" style="width:160px; height:20px" >
                                                <option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                                <cfloop list="#property_list#" index="i">
                                                    <option value="#i#" <cfif get_defaults.DEFAULT_KANBAN_EXPENCE_NO eq i>selected</cfif>>#Evaluate('get_plus_name.PROPERTY#i#_NAME')#</option>
                                                </cfloop>
                                            </select>
                                      	</div>
                                 	</div>
                                    <br/>
                                    <div class="form-group" id="item-default_thickness">
                                    	<label class="col col-12 col-xs-12"><span style=" font-weight:bold"><cf_get_lang dictionary_id="885.Özel Tasarım Tanımları"></span></label>
                                 	</div>
                                    <div class="form-group" id="item-design_type">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id="58530.Aktarım Türü"></label>
                                     	<div class="col col-6 col-xs-12">
                                       		<select name="design_type" id="design_type" style="width:160px; height:20px">
                                            	<option value="0"><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                             	<option value="1" <cfif get_defaults.DEFAULT_PROCESS_ID eq 1>selected</cfif>><cf_get_lang dictionary_id='141.Modül'>+<cf_get_lang dictionary_id='100.Paket'>+<cf_get_lang dictionary_id='45.Parça'></option>
                                           		<option value="2" <cfif get_defaults.DEFAULT_PROCESS_ID eq 2>selected</cfif>><cf_get_lang dictionary_id='141.Modül'>+<cf_get_lang dictionary_id='100.Paket'></option>
                                            	<option value="3" <cfif get_defaults.DEFAULT_PROCESS_ID eq 3>selected</cfif>><cf_get_lang dictionary_id='141.Modül'></option>
                                        	</select>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-private_main_id">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id="884.Özel Modül"></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<select name="private_main_id" id="private_main_id" style="width:150px; height:20px">
                                            	<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                                              	<cfif len(get_defaults.PROTOTIP_PACKAGE_ID)>
													<cfif get_stock_info_PROTOTIP_PACKAGE.recordcount>
                                                        <cfloop query="get_stock_info_PROTOTIP_PACKAGE">
                                                            <option value="#get_stock_info_PROTOTIP_PACKAGE.DESIGN_MAIN_ROW_ID#"  <cfif get_stock_info_PROTOTIP_PACKAGE.DESIGN_MAIN_ROW_ID eq get_defaults.PROTOTIP_PACKAGE_ID>selected="selected"</cfif>>#get_stock_info_PROTOTIP_PACKAGE.DESIGN_MAIN_NAME#</option>
                                                        </cfloop>
                                                    </cfif>
                                           		<cfelse>
                                                 	<cfif isdefined('get_stock_info_PROTOTIP_PACKAGE.recordcount') and get_stock_info_PROTOTIP_PACKAGE.recordcount>
                                                        <cfloop query="get_stock_info_PROTOTIP_PACKAGE">
                                                            <option value="#get_stock_info_PROTOTIP_PACKAGE.DESIGN_MAIN_ROW_ID#" >#get_stock_info_PROTOTIP_PACKAGE.DESIGN_MAIN_NAME#</option>
                                                        </cfloop>
                                                    </cfif>
                                                </cfif>
                                            </select>
                                      	</div>
                                 	</div>
                                    
                                    <div class="form-group" id="item-private_piece_id_1">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id="883.Özel Yonga Levha"></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<div class="input-group">
                                       			<input type="text" name="private_piece_1" id="private_piece_1" style="width:200px;" value="<cfif len(get_defaults.PROTOTIP_PIECE_1_ID)>#get_stock_info_PROTOTIP_PIECE_1_ID.PIECE_NAME#</cfif>">
                                                <input type="hidden" name="private_piece_id_1" id="private_piece_id_1" value="#get_defaults.PROTOTIP_PIECE_1_ID#">
                                                <span class="input-group-addon icon-ellipsis btnPointer" onclick="pencere_ac_pieces_1();"></span>
                                            </div>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-private_piece_id_2">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id="882.Özel Genel Reçete"></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<div class="input-group">
                                       			<input type="text" name="private_piece_2" id="private_piece_2" style="width:200px;" value="<cfif len(get_defaults.PROTOTIP_PIECE_2_ID)>#get_stock_info_PROTOTIP_PIECE_2_ID.PIECE_NAME#</cfif>">
                                                <input type="hidden" name="private_piece_id_2" id="private_piece_id_2" value="#get_defaults.PROTOTIP_PIECE_2_ID#">
                                                <span class="input-group-addon icon-ellipsis btnPointer" onclick="pencere_ac_pieces_2();"></span>
                                            </div>
                                      	</div>
                                 	</div>
                                    <div class="form-group" id="item-private_piece_id_3">
                                    	<label class="col col-6 col-xs-12"><cf_get_lang dictionary_id="881.Özel Montaj Ürünü"></label>
                                     	<div class="col col-6 col-xs-12">
                                        	<div class="input-group">
                                       			<input type="text" name="private_piece_3" id="private_piece_3" style="width:200px;" value="<cfif len(get_defaults.PROTOTIP_PIECE_3_ID)>#get_stock_info_PROTOTIP_PIECE_3_ID.PIECE_NAME#</cfif>">
                                                <input type="hidden" name="private_piece_id_3" id="private_piece_id_3" value="#get_defaults.PROTOTIP_PIECE_2_ID#">
                                                <span class="input-group-addon icon-ellipsis btnPointer" onclick="pencere_ac_pieces_3();"></span>
                                            </div>
                                      	</div>
                                 	</div>
                             	</div>
                        	</cf_box_elements>
                            <cf_box_footer>
                                    <div class="col col-12">
                                        <cf_workcube_buttons is_upd='1' is_delete='0' add_function='control()'>
                                    </div>
                       		</cf_box_footer>
                       	</div>
                  	</div>
             	</div>
         	</cf_basket_form>
            </cfoutput>
      	</cfform>
  	</cf_box> 
</div>                         
<script type="text/javascript">
	function pencere_ac()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=3&product_id=add_defaults.pid&field_id=add_defaults.stock_id&field_name=add_defaults.urun",'list');
	}
	function pencere_ac_piece_1()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=4&product_id=add_defaults.pid_piece_1&field_id=add_defaults.stock_id_piece_1&field_name=add_defaults.urun_piece_1",'list');
	}
	function pencere_ac_piece_2()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=4&product_id=add_defaults.pid_piece_2&field_id=add_defaults.stock_id_piece_2&field_name=add_defaults.urun_piece_2",'list');
	}
	function pencere_ac_piece_3()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=4&product_id=add_defaults.pid_piece_3&field_id=add_defaults.stock_id_piece_3&field_name=add_defaults.urun_piece_3",'list');
	}
	function pencere_ac_piece_4()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=4&product_id=add_defaults.pid_piece_4&field_id=add_defaults.stock_id_piece_4&field_name=add_defaults.urun_piece_4",'list');
	}
	function pencere_ac_piece_5()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=4&product_id=add_defaults.pid_piece_5&field_id=add_defaults.stock_id_piece_5&field_name=add_defaults.urun_piece_5",'list');
	}
	function pencere_ac_package_1()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=4&product_id=add_defaults.pid_package_1&field_id=add_defaults.stock_id_package_1&field_name=add_defaults.urun_package_1",'list');
	}
	function pencere_ac_package_2()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=4&product_id=add_defaults.pid_package_2&field_id=add_defaults.stock_id_package_2&field_name=add_defaults.urun_package_2",'list');
	}
	function pencere_ac_package_3()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=4&product_id=add_defaults.pid_package_3&field_id=add_defaults.stock_id_package_3&field_name=add_defaults.urun_package_3",'list');
	}
	function pencere_ac_package_4()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=4&product_id=add_defaults.pid_package_4&field_id=add_defaults.stock_id_package_4&field_name=add_defaults.urun_package_4",'list');
	}
	function pencere_ac_package_5()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_ezgi_product_names&list_order_no=4&product_id=add_defaults.pid_package_5&field_id=add_defaults.stock_id_package_5&field_name=add_defaults.urun_package_5",'list');
	}
	function pencere_ac_pieces_1()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_list_ezgi_pieces&piece_id=add_defaults.private_piece_id_1&field_id=add_defaults.private_piece_id_1&field_name=add_defaults.private_piece_1",'wide');
	}
	function pencere_ac_pieces_2()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_list_ezgi_pieces&piece_id=add_defaults.private_piece_id_2&field_id=add_defaults.private_piece_id_2&field_name=add_defaults.private_piece_2",'wide');
	}
	function pencere_ac_pieces_3()
	{
		windowopen("<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_list_ezgi_pieces&piece_id=add_defaults.private_piece_id_3&field_id=add_defaults.private_piece_id_3&field_name=add_defaults.private_piece_3",'wide');
	}
	function control()
	{
		if(document.getElementById('default_fire_rate').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='880.Yonga Levha Fire Oranı'>');	
			document.getElementById('default_fire_rate').focus();
			return false;
		}
		if(document.getElementById('pvc_default_fire_rate').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> -  <cf_get_lang dictionary_id='879.PVC Fire Miktarı'>');	
			document.getElementById('pvc_default_fire_rate').focus();
			return false;
		}
		if(document.getElementById('trim_type').value != 0)
		{
			if(document.getElementById('trim_size').value <= 0)
			{
				alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='86.Tıraşlama Payı'>');	
				document.getElementById('trim_size').focus();
				return false;
			}
		}
		else
		{
			document.getElementById('trim_size').value = 0;
		}
		if(document.getElementById('product_amount').value <= 0)
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='878.Genel Üretim Miktarı'>');	
			document.getElementById('product_amount').focus();
			return false;
		}
		if(document.getElementById('color_property_id').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='120.Renk Özellik Tanımı'>');	
			document.getElementById('color_property_id').focus();
			return false;
		}
		if(document.getElementById('thickness_property_id').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='121.Kalınlık Özellik Tanımı'>');	
			document.getElementById('thickness_property_id').focus();
			return false;
		}
		if(document.getElementById('thickness_ext_property_id').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='122.Kal.Etkisi Özellik Tanımı'>');	
			document.getElementById('thickness_ext_property_id').focus();
			return false;
		}
		if(document.getElementById('package_product_cat').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='877.Paket Kategorisi'> ');	
			document.getElementById('package_product_cat').focus();
			return false;
		}
		if(document.getElementById('piece_product_cat').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='876.Parça Kategorisi'>');	
			document.getElementById('piece_product_cat').focus();
			return false;
		}
		if(document.getElementById('product_process_stage').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='875.Ürün Kayıt Süreci'>');	
			document.getElementById('product_process_stage').focus();
			return false;
		}
		if(document.getElementById('product_tree_process_stage').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='874.Ürün Ağacı Kayıt Süreci'>');	
			document.getElementById('product_tree_process_stage').focus();
			return false;
		}
		if(document.getElementById('main_unit').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='873.Modül Birim'>');	
			document.getElementById('main_unit').focus();
			return false;
		}
		if(document.getElementById('package_unit').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='872.Paket Birim'>');	
			document.getElementById('package_unit').focus();
			return false;
		}
		if(document.getElementById('piece_unit').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='871.Parça Birim'>');	
			document.getElementById('piece_unit').focus();
			return false;
		}
		if(document.getElementById('main_account_id').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='141.Modül'> <cf_get_lang dictionary_id='127.Muh.Bt.Hes.Kodu'> ');	
			document.getElementById('main_account_id').focus();
			return false;
		}
		if(document.getElementById('package_account_id').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='100.Paket'> <cf_get_lang dictionary_id='127.Muh.Bt.Hes.Kodu'>');	
			document.getElementById('package_account_id').focus();
			return false;
		}
		if(document.getElementById('piece_account_id').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='45.Parça'> <cf_get_lang dictionary_id='127.Muh.Bt.Hes.Kodu'>');	
			document.getElementById('piece_account_id').focus();
			return false;
		}
		if(document.getElementById('main_station_id').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='870.Modül İstasyonu'>');	
			document.getElementById('main_station_id').focus();
			return false;
		}
		if(document.getElementById('package_station_id').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='869.Paket İstasyonu'>');	
			document.getElementById('package_station_id').focus();
			return false;
		}
		if(document.getElementById('piece_station_id').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='868.Parça İstasyonu'>');	
			document.getElementById('piece_station_id').focus();
			return false;
		}
		if(document.getElementById('main_operation_id').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='867.Modül Operasyonu'>');	
			document.getElementById('main_operation_id').focus();
			return false;
		}
		if(document.getElementById('package_operation_id').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='866.Paket Operasyonu'>');	
			document.getElementById('package_operation_id').focus();
			return false;
		}
		if(document.getElementById('cutting_operation_id').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='865.Ebatlama Operasyonu'>');	
			document.getElementById('cutting_operation_id').focus();
			return false;
		}
		if(document.getElementById('urun').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> -  <cf_get_lang dictionary_id='917.PVC Master Ürün'>');	
			document.getElementById('urun').focus();
			return false;
		}
		if(document.getElementById('master_model_id').value == '')
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='112.Master Ürün'> <cf_get_lang dictionary_id='864.Model Kodu'>');	
			document.getElementById('master_model_id').focus();
			return false;
		}
		if(document.getElementById('active_operator_amount').value <= 0)
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='863.Aktif Operatör Sayısı'>');	
			document.getElementById('active_operator_amount').focus();
			return false;
		}
		if(document.getElementById('daily_working_time').value <= 0)
		{
			alert('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='862.Günlük Çalışma Süresi'>');	
			document.getElementById('daily_working_time').focus();
			return false;
		}
	}
</script>                     	