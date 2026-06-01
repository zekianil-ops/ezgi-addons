<!---
    File: add_ambar_fis_5.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cf_xml_page_edit>
<cfparam name="attributes.anamenu" default="1">
<cfparam name="attributes.department_in_id" default="">
<cfparam name="attributes.process_cat_id" default="">
<cfparam name="attributes.lot_no" default="">
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfset default_process_type = '113,111'>
<cfquery name="get_default_departments" datasource="#dsn#">
    SELECT        
        DEFAULT_MK_TO_RF_DEP, 
        DEFAULT_MK_TO_RF_LOC
    FROM            
        EZGI_PDA_DEPARTMENT_DEFAULTS
    WHERE        
        EPLOYEE_ID = #session.ep.userid#
</cfquery>
<cfset default_departments = '#get_default_departments.DEFAULT_MK_TO_RF_DEP#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
<cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>

<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT 
		D.DEPARTMENT_HEAD,
		SL.DEPARTMENT_ID,
		SL.LOCATION_ID,
		SL.STATUS,
		SL.COMMENT
	FROM 
		STOCKS_LOCATION SL,
		DEPARTMENT D,
		BRANCH B
	WHERE
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
		SL.STATUS = 1 AND
		D.BRANCH_ID = B.BRANCH_ID AND
        B.COMPANY_ID=#session.ep.company_id# 
</cfquery>

<cfset attributes.department_out_id = "#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
<cfset attributes.department_in_id ="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,1)#">

<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT DISTINCT  
    	SPC.PROCESS_CAT_ID,
        SPC.PROCESS_CAT
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE IN (#default_process_type#) AND 
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
<cfset statu = 0>
<cfset stock_id_list = ''>
<cfset barcod_list = ''>
<cfif len(attributes.lot_no) or (isdefined('attributes.p_order_id') and len(attributes.p_order_id))>
	<cfquery name="get_period" datasource="#dsn#">
            SELECT     
                TOP (2)
                PERIOD_YEAR
            FROM         
                SETUP_PERIOD WITH (NOLOCK)
            WHERE     
                OUR_COMPANY_ID = #session.ep.company_id#
            ORDER BY
                PERIOD_YEAR desc      
 	</cfquery>
    <cfset our_company_years = Valuelist(get_period.PERIOD_YEAR)>
    <cfif isdefined('attributes.p_order_id') and len(attributes.p_order_id)>
    	<cfquery name="GET_P_ORDER_NO" datasource="#dsn3#">
            SELECT P_ORDER_NO FROM PRODUCTION_ORDERS WHERE P_ORDER_ID = #attributes.p_order_id#
        </cfquery>
    	<cfset statu = 1>
    <cfelse>
        <cfquery name="get_lot" datasource="#dsn3#">
            SELECT P_ORDER_ID FROM PRODUCTION_ORDERS WHERE LOT_NO = '#attributes.lot_no#'
        </cfquery>
        <cfif get_lot.recordcount>
            <cfset statu = 1>
        <cfelse>
            <cfquery name="get_p_order" datasource="#dsn3#">
                SELECT LOT_NO FROM PRODUCTION_ORDERS WHERE P_ORDER_NO = '#attributes.lot_no#'
            </cfquery>
            <cfif get_p_order.recordcount>
                <cfset statu = 2>
            <cfelse>
                <script type="text/javascript">
                    alert("Lot No veya Emir No Bulunamadı!");
                    window.location ="<cfoutput>#request.self#?fuseaction=pda.add_ambar_fis_5</cfoutput>";
                </script>
                <cfabort>
            </cfif> 	
        </cfif>
    </cfif>
  	<cfif statu eq 1>
   		<cfquery name="GET_LOT_NO_ROW" datasource="#dsn3#">
            SELECT        
                POS.STOCK_ID, 
                POS.SPECT_MAIN_ID, 
                SUM(POS.AMOUNT) AS AMOUNT, 
                S.PRODUCT_CODE, 
                S.PRODUCT_NAME,
                S.BARCOD,
                PO.LOT_NO,
                PU.MAIN_UNIT,
                ISNULL((
                    SELECT
                        SUM(AMOUNT) AS AMBAR_STOCK
                    FROM
                        (      
                        <cfloop list="#our_company_years#" index="comp_ii">
                            SELECT     
                                SR.AMOUNT,
                                SR.STOCK_ID
                            FROM         
                                #dsn#_#comp_ii#_#session.ep.company_id#.STOCK_FIS AS SF WITH (NOLOCK) INNER JOIN
                                #dsn#_#comp_ii#_#session.ep.company_id#.STOCK_FIS_ROW AS SR WITH (NOLOCK) ON SF.FIS_ID = SR.FIS_ID
                            WHERE     
                                SF.FIS_TYPE IN (113,111) AND 
                                <cfif isdefined('attributes.p_order_id') and len(attributes.p_order_id)>
                                	SF.PROD_ORDER_NUMBER = #attributes.p_order_id# AND
                                <cfelse>
                                	SF.REF_NO = '#attributes.lot_no#' AND
                                </cfif>
                                SR.STOCK_ID = POS.STOCK_ID
                                <cfif listlen(our_company_years) neq 1 and comp_ii neq listlast(our_company_years,',')> UNION ALL </cfif>
                        </cfloop>
                         ) AS TBL
                ),0) AS AMBAR_STOCK
            FROM            
                PRODUCTION_ORDERS AS PO WITH (NOLOCK) INNER JOIN
                PRODUCTION_ORDERS_STOCKS AS POS WITH (NOLOCK) ON PO.P_ORDER_ID = POS.P_ORDER_ID INNER JOIN
                STOCKS AS S WITH (NOLOCK) ON POS.STOCK_ID = S.STOCK_ID INNER JOIN
                PRODUCT_UNIT AS PU WITH (NOLOCK) ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID
            WHERE        
                <cfif isdefined('attributes.p_order_id') and len(attributes.p_order_id)>
                	PO.P_ORDER_ID = #attributes.p_order_id# AND
                <cfelse>
                	PO.LOT_NO = '#attributes.lot_no#' AND 
                </cfif>
                POS.TYPE = 2
            GROUP BY 
                POS.STOCK_ID, 
                POS.SPECT_MAIN_ID, 
                S.PRODUCT_CODE, 
                S.PRODUCT_NAME,
                S.BARCOD,
                PO.LOT_NO,
                PU.MAIN_UNIT
            HAVING        
                S.PRODUCT_CODE LIKE '01.150%'
            ORDER BY 
                S.PRODUCT_CODE
        </cfquery>
        <cfif isdefined('attributes.p_order_id') and len(attributes.p_order_id)>
        	<cfset attributes.lot_no = GET_LOT_NO_ROW.LOT_NO>
        </cfif>
        <cfset stock_id_list = ValueList(GET_LOT_NO_ROW.STOCK_ID)>
    	<cfset barcod_list = ValueList(GET_LOT_NO_ROW.BARCOD)>
    <cfelseif statu eq 2>
    	<cfquery name="GET_SUB_ORDERS" datasource="#dsn3#">
            SELECT 
            	PO.QUANTITY, 
                PO.P_ORDER_NO, 
                PO.LOT_NO, 
                PO.IS_STAGE, 
                S.PRODUCT_NAME, 
                S.PRODUCT_CODE, 
                PO.P_ORDER_ID
			FROM     
            	PRODUCTION_ORDERS AS PO INNER JOIN
                STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID
			WHERE  
            	PO.PO_RELATED_ID =
                      				(
                                    	SELECT 
                                        	P_ORDER_ID
                       					FROM      
                                        	PRODUCTION_ORDERS AS PRODUCTION_ORDERS_1
                       					WHERE   
                                        	P_ORDER_NO = '#attributes.lot_no#'
                                  	) AND 
            	PO.STATUS = 1 AND 
                PO.IS_STOCK_RESERVED = 1
        </cfquery>
    </cfif>
</cfif>

<script language="javascript" type="text/javascript">
	var row_count = 0;
  	var barcod = '';
  	var stockid = '';
  	var spectmainid = 0;
  	var stockcode = '';
  	var amount = '';
  	var cikar = 0;
  	var islemtipi = 0;//0-ekle 1-çıkar
  	var buton = 0;// <1-buton pasif, >0-buton aktif
</script>
<cfform name="form_basket" id="form_basket">
	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    	<cf_box scroll="0">
        	<cfinput id="ekle" type="hidden" name="ekle" value="0">
          	<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
          	<input type="hidden" name="active_period" value="#session.pda.period_id#" />
            <cfif isdefined('attributes.param')>
            	<cfinput id="param" type="hidden" name="param" value="#attributes.param#">
            </cfif>
            <cfif isdefined('attributes.p_order_id') and len(attributes.p_order_id)>
            	<cfinput type="hidden" name="p_order_id" id="p_order_id" value="#attributes.p_order_id#">
            </cfif>
            <cf_box_search>
            	<div class="col col-12" id="area_1" <cfif len(attributes.lot_no)>style="display:none"</cfif>>
                  	<div class="col col-4">
                     	<label><cf_get_lang dictionary_id='41701.Lot No'></label>
               		</div>
                	<div class="col col-4">
                     	<div class="form-group">
                         	<input type="text" name="lot_no" id="lot_no" value="<cfoutput>#attributes.lot_no#</cfoutput>">
                     	</div>
                 	</div>
                    <div class="col col-4">
                    	<div class="form-group">
                         	<input id="lot_no_confirm" name="lot_no_confirm" style="color:white" value="<cf_get_lang dictionary_id="58693.Seç">" type="button" onClick="lot_no_area();" />
                      	</div>
                    	<div id="internaldemand_div"></div>
               		</div>
               	</div>
                <div class="col col-12" id="area_4" <cfif statu neq 2>style="display:none"</cfif>>
                  	<div class="col col-12">
                     	<cf_box title="Alt Emirler">
                          	<cf_grid_list>
                             	<thead>
                                  	<tr>
                                     	<th ><cf_get_lang dictionary_id='58577.Sıra'></th>
                                        <th ><cf_get_lang dictionary_id='29474.Emir No'></th>
                                        <th ><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                       					<th ><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                        				<th ><cf_get_lang dictionary_id='57635.Miktar'></th>
                        				<th >DRM</th>
                               		</tr>
                             	</thead>
                            	<tbody name="table_order" id="table_order">
                                	<cfif statu eq 2 and GET_SUB_ORDERS.recordcount>
                                    	<cfoutput query="GET_SUB_ORDERS">
                                      		<tr id="row_order#currentrow#" height="20">
                                            	<td style="text-align:right">#currentrow#</td>
                                              	<td style="text-align:center">
                                                	<a style="cursor:pointer" onclick="add_order_row(#P_ORDER_ID#);" class="tableyazi">
                                                    	#P_ORDER_NO#
                                                    </a>
                                                </td>
                                                <td style="text-align:left">#PRODUCT_CODE#</td>
                                                <td style="text-align:left">#PRODUCT_NAME#</td>
                                             	<td style="text-align:right">#AmountFormat(QUANTITY,2)#</td>
                                            	<td style="text-align:center"></td>
                                        	</tr>
                                   		</cfoutput>
                                 	</cfif>
                             	</tbody>
                          	</cf_grid_list>
                      	</cf_box>
               		</div>
               	</div>
                 <div id="area_2" <cfif statu neq 1>style="display:none"</cfif>>
                    <div class="col col-12">
                        <div class="col col-6">
                            <cf_get_lang dictionary_id='57635.Miktar'>
                        </div>
                        <div class="col col-6">
                            <cf_get_lang dictionary_id='57633.Barkod'>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="col col-6">
                            <div class="form-group">
                                <cfinput id="add_other_amount" name="add_other_amount" type="text" onfocus="islemtipi=0;" style=" text-align:right" maxlength="6" value="1" />
                            </div>
                        </div>
                        <div class="col col-6">
                            <div class="form-group">
                                <cfinput id="add_other_barcod" name="add_other_barcod" type="text"  maxlength="20" value="" />
                            </div>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="col col-6">
                            <cf_get_lang dictionary_id='29428.Çıkış Depo'>
                        </div>
                        <div class="col col-6">
                            <cf_get_lang dictionary_id='33658.Giriş Depo'>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="col col-6">
                            <div class="form-group">
                                <select name="txt_department_out" id="txt_department_out" style="width:120px; height:20px" onchange="document.getElementById('department_out').value = this.value">
                                    <cfoutput query="get_all_location" group="department_id">
                                        <option disabled="disabled" value="#department_id#"<cfif attributes.department_out_id eq department_id>selected</cfif>>#department_head#</option>
                                    <cfoutput>
                                    <option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_out_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#<cfif not status>-<cf_get_lang dictionary_id='57494.Pasif'></cfif></option>
                                    </cfoutput> 
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                        <div class="col col-6">
                            <div class="form-group">
                                <select name="txt_department_in" style="width:120px; height:20px" onchange="document.getElementById('department_in').value = this.value">
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
                    <div class="col col-12">
                        <div class="col col-12">
                            <cf_get_lang dictionary_id='45271.Fiş Tipi'>
                        </div>
                    </div>
                    <div class="col col-12">
                        <div class="col col-12">
                            <div class="form-group">
                                <select name="process_cat_id" id="process_cat_id" style="height:20px">
                                	<cfoutput query="get_process_cat">
                                    	<option value="#PROCESS_CAT_ID#"<cfif attributes.process_cat_id eq PROCESS_CAT_ID>selected</cfif>>#PROCESS_CAT#</option>
                                    </cfoutput>
                                </select>
                            </div>
                        </div>
                    </div>
                </div>
          	</cf_box_search>
        </cf_box>
        <cfsavecontent variable="sekme1">Stok Fişi</cfsavecontent>
        <cfsavecontent variable="sekme2">Kontrol</cfsavecontent>
        <div id="basket_main_div" <cfif statu eq 2>style="display:none"</cfif>>
        	<div class="row">
                <div class="col col-12 uniqueRow">
                    <cf_basket_form id="upd_connect" class="row">
                        <div id="tab-container" class="tabStandart margin-top-5">
                            <div id="tab-head">
                                <ul class="tabNav">
                                    <li class="<cfif attributes.anamenu eq 1>active</cfif>"><a id="href_liste" href="#liste"><cfoutput>#sekme1#</cfoutput></a></li>
                                    <li class="<cfif attributes.anamenu eq 2>active</cfif>"><a id="href_kontrol" href="#kontrol"><cfoutput>#sekme2#</cfoutput></a></li>
                                </ul>
                            </div>
                            <div id="tab-content" class="margin-top-10"> 
                                <div id="liste" class="content row">
                                	<cfsavecontent variable="title">
                                    	<cf_get_lang dictionary_id="1356.Lot Bazlı Ambar Fişi"> : 
										<cfoutput>
                                        	<cfif statu eq 1>
                                        		<cfif len(attributes.lot_no)>#GET_LOT_NO_ROW.LOT_NO#</cfif>
                                                <cfif isdefined('attributes.p_order_id') and len(attributes.p_order_id)>
                                                	- #GET_P_ORDER_NO.P_ORDER_NO#
                                                </cfif>
                                            </cfif>
										</cfoutput>
                                   	</cfsavecontent>
                                    <cf_box title="#title#">
                                    	<cf_form_list>
                                            <thead>
                                                <tr>
                                                    <th style="width:20%"><cf_get_lang dictionary_id='57633.Barkod'></th>
                       								<th style="width:100%"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                        							<th style="width:15%"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                                </tr>
                                            </thead>
                                            <form name="product_row" id="product_row" method="post">
                                                <tbody name="table1" id="table1">
                                                </tbody>
                                            </form>
        									<tfoot <cfif not len(attributes.lot_no)>style="display:none"</cfif>>
                                                <tr>	
                                                    <td colspan="4">
                                                        <input type="hidden" id="department_in" name="department_in" value="" />
                                                        <input type="hidden" id="department_out" name="department_out" value="" />
                                                        <input type="hidden" id="row_count" name="row_count" value="0" />
                                                        <input type="hidden" id="action_id" name="action_id" value="" />
                                                        <input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" disabled="disabled" onClick="kontrol_kayit();" />
                                                    </td>
                                                </tr>
                							</tfoot>
        								</cf_form_list>
                                  	</cf_box>
                              	</div>
                           		<div id="kontrol" class="content row">
									<cf_box title="#title#">
                                        <cf_grid_list>
                                        	<thead>
                                                <tr>
                                                	<th ><cf_get_lang dictionary_id='58577.Sıra'></th>
                       								<th ><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                        							<th ><cf_get_lang dictionary_id='57635.Miktar'></th>
                        							<th >CNT</th>
                                                    <th >Kalan</th>
                                                </tr>
                                            </thead>
                                            <tbody name="table2" id="table2">
                                            	<cfif statu eq 1>
													<cfif len(attributes.lot_no) and GET_LOT_NO_ROW.recordcount>
                                                        <cfinput type="hidden" id="row_count_content" name="row_count_content" value="#GET_LOT_NO_ROW.recordcount#">
                                                        <cfoutput query="GET_LOT_NO_ROW">
                                                            <tr id="row#currentrow#" height="20">
                                                                <td style="text-align:left">
                                                                    <input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1" >
                                                                    <input name="STOCK_ID#currentrow#" id="STOCK_ID#currentrow#" type="hidden" value="#STOCK_ID#">
                                                                    <input name="SPECT_MAIN_ID#currentrow#" id="SPECT_MAIN_ID#currentrow#" type="hidden" value="#SPECT_MAIN_ID#">
                                                                    <input name="row_number#currentrow#" type="text" value="#currentrow#" style="width:10px">
                                                                </td>
                                                                <td style="text-align:left"><input name="PRODUCT_NAME#currentrow#" id="PRODUCT_NAME#currentrow#" type="text" value="#PRODUCT_NAME#"></td>
                                                                <td style="text-align:right">
                                                                    <input name="MIKTAR#currentrow#" id="MIKTAR#currentrow#" type="text" value="#TlFormat(AMOUNT,3)#" style="text-align:right; width:40px">
                                                                </td>
                                                                <td style="text-align:right">
                                                                    <input name="KONTROL#currentrow#" id="KONTROL#currentrow#" type="text" value="#TlFormat(AMBAR_STOCK,3)#" style="text-align:right; width:40px">
                                                                </td>
                                                                <td style="text-align:right">
                                                                    <input name="KALAN#currentrow#" id="KALAN#currentrow#" type="text" value="#TlFormat(AMOUNT-AMBAR_STOCK,3)#" style="text-align:right; width:40px">
                                                                </td>
                                                            </tr>
                                                        </cfoutput>
                                                    </cfif>
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
    </div>
</cfform>
<script language="javascript" type="text/javascript">
	<cfif len(attributes.lot_no)>
		document.getElementById('add_other_barcod').focus();
	<cfelse>
		document.getElementById('lot_no').focus();
	</cfif>
	setTimeout("document.getElementById('add_other_barcod').select();",1000);	
	document.onkeydown = checkKeycode
	function checkKeycode(e) 
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			if (document.getElementById('add_other_barcod').value.length == '')
			{
				alert('<cf_get_lang dictionary_id='340.Önce Ürün Barkodu Okutunuz'>');
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_amount').value = 1;
				document.getElementById('add_other_barcod').focus();	
			
			}
			else
			{
				get_stock(document.getElementById('add_other_barcod').value);
			}
		}
	}
	function get_stock(barcode)
    {
	 	carpan = ''; birim = ''; barcod = ''; stockid = ''; stockcode = ''; spectmainid = 0; //ilk önce sıfırlıyoruz
		k_= 0;
		if(document.getElementById('add_other_amount').value.length == 0)
		{
			alert('<cf_get_lang dictionary_id='29943.Lütfen miktar giriniz.'>');
			k_=1;
			return false;
		}
	 	if(barcode.substr(0,1)=='j')//Bazı barkod okuyucular okuduktan sonra başına j harfi koyuyor kontrol için yapıldı
			barcode = barcode.substring(1,length(barcode));
		uzunluk = barcode.length;
		spectmainid = 0;
		ean = <cfoutput>#get_defaults.EAN#</cfoutput>;
		if(uzunluk > ean)
		{
			spectmainid = barcode.substring(ean,uzunluk);
			barcode = barcode.substring(0,ean);
		}
		<cfif len(attributes.lot_no)>
			if(list_find('<cfoutput>#barcod_list#</cfoutput>',barcode,','))
			{
				
			}
			else
			{
				alert("İç Talepte Olmayan Ürün: "+barcode);
				document.getElementById('add_other_amount').value = 1;
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcod').focus();
				k_ = 1;
				return false;
				
			}
		</cfif>
	 	if (k_ == 0)
     	{
			/*var new_sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER,S.PRODUCT_NAME,S.IS_PROTOTYPE FROM STOCKS_BARCODES AS SB INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '"+barcode+"'";
			var get_product = wrk_query(new_sql,'dsn3');*/
			
			var listParam = barcode;
			var get_product = wrk_safe_query('get_product_ezgi','dsn3',0,listParam);
			
		 	if (get_product.STOCK_ID == undefined)
		 	{
				document.getElementById('ekle').value = 1;
				alert('<cf_get_lang dictionary_id='341.Ürün Bulunamadı'>');
		 	}
		 	else
		 	{	
				if(get_product.IS_PROTOTYPE==1 && spectmainid==0)
				{
					alert('<cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'> : <cf_get_lang dictionary_id='36006.Spekt ID'>');
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus();
				}
				else
				{
					carpan = get_product.MULTIPLIER;
					birim = get_product.MAIN_UNIT;
					stockid = get_product.STOCK_ID;
					stockcode = get_product.PRODUCT_NAME;
					barcode = get_product.BARCODE;
					buton_kontrol();
					add_row(barcode)
				}
    		}
		}
		else
		{
			carpan = ''; birim = ''; barcod = ''; stockid = ''; stockcode = ''; spectmainid = 0;
			return false;
		}
	}
	function buton_kontrol()
	{
		if (islemtipi == 0)
			buton++;
		else if (buton>0)
			buton--;
		if (buton < 1)
			document.getElementById('onay').disabled = true;
		else
			document.getElementById('onay').disabled = false;
	}
	function add_amount()
	{
		amount_control(stockid,spectmainid);
		if(spectmainid==0)
		{
			/*var store_sq="SELECT PRODUCT_STOCK AS REAL_STOCK FROM EZGI_GET_SPECT_LOCATION_TOTAL WHERE DEPO = '"+document.getElementById('txt_department_out').value+"' AND STOCK_ID = "+stockid+" AND PRODUCT_STOCK > 0";*/
			var listParam = document.getElementById('txt_department_out').value + "*" + stockid;
			var get_store_amount = wrk_safe_query('get_depo_stock_no_zero_stock_id_ezgi','dsn2',0,listParam);
		}
		else
		{
			/*var store_sq="SELECT PRODUCT_STOCK AS REAL_STOCK FROM EZGI_GET_SPECT_LOCATION_TOTAL WHERE DEPO = '"+document.getElementById('txt_department_out').value+"' AND STOCK_ID = "+stockid+" AND SPECT_MAIN_ID = "+spectmainid+" AND PRODUCT_STOCK > 0";*/
			var listParam = document.getElementById('txt_department_out').value + "*" + spectmainid;
			var get_store_amount = wrk_safe_query('get_depo_stock_no_zero_spectmainid_ezgi','dsn2',0,listParam);
		}
		
		/*var get_store_amount = wrk_query(store_sq,'dsn2');*/
		control_amount=get_store_amount.REAL_STOCK;
		if(get_store_amount.recordcount)
		{
			if(row_count >0) /*ilk Satırdan sonrası*/
			{
				for(i=1;i<=row_count;i++)
				{
					if(document.getElementById('stockid'+i).value == stockid && document.getElementById('spectmainid'+i).value == spectmainid)
						control_amount=control_amount-document.getElementById('amount'+i).value;
				}
				control_amount=control_amount-document.getElementById('add_other_amount').value;
				if(control_amount<0)
				{
					document.getElementById('ekle').value=1;
					alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='39425.Depo Miktarı'>: "+get_store_amount.REAL_STOCK);
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus();
					return false;
				}
			}
			else
			{
				control_amount=control_amount-document.getElementById('add_other_amount').value;
				if(control_amount<0)
				{
					document.getElementById('ekle').value=1;
					alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='39425.Depo Miktarı'>: "+get_store_amount.REAL_STOCK);
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus();
					return false;
				}	
			}
		}
		else
		{
			document.getElementById('ekle').value=1;
			alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='39425.Depo Miktarı'>: 0");
			document.getElementById('add_other_amount').value = 1;
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus();
			return false;
		}
		if (document.getElementById('ekle').value==0)
		{
			if(row_count >0)
			{
				for(i=1;i<=row_count;i++)
				{
					if(document.getElementById('stockid'+i).value == stockid && document.getElementById('spectmainid'+i).value == spectmainid)
					{
						document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
						if (document.getElementById('frm_row'+i).style.display == 'none')
								document.getElementById('frm_row'+i).style.display='block';
						document.getElementById('ekle').value=1;
					}
				}
			}
			else
				document.getElementById('txt_department_out').disabled = true;
		}
	}
	function add_row(barcode)
	{
		if (k_==0)
		{
			amount = document.getElementById('add_other_amount').value;
			if(amount == 0)
			{
				alert('<cf_get_lang dictionary_id='344.Miktar 0 dan Büyük Olmalıdır'>.');
				return false;
			}
			add_amount();
			if (document.getElementById('ekle').value == 0)
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
				newCell.innerHTML = '<input type="hidden" value="'+stockid+'" name="stockid'+row_count+'" id="stockid'+row_count+'" /><input type="hidden" value="'+spectmainid+'" name="spectmainid'+row_count+'" id="spectmainid'+row_count+'" /><input type="text" value="'+barcode+'" name="barcod'+row_count+'" id="barcod'+row_count+'" size="13" readonly="yes" style="border:none;height:20px" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" value="'+stockcode+'" name="stockcode'+row_count+'" id="stockcode'+row_count+'" size="13" readonly="yes" style="border:none" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" style="text-align:right;border:none" value="'+amount+'" name="amount'+row_count+'" id="amount'+row_count+'" size="5" readonly="yes"  style="text-align:" />'
			}
			else
				document.getElementById('ekle').value = 0;
				
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_amount').value = 1;
			document.getElementById('add_other_barcod').focus();
		}
	}
	function amount_control(stockid,spectmainid)
	{
		row_count_content = document.getElementById('row_count_content').value;
		for(i=1;i<=row_count_content;i++)
		{
			if(document.getElementById('STOCK_ID'+i).value==stockid)
			{
				document.getElementById('KONTROL'+i).value = commaSplit(parseFloat(filterNum(document.getElementById('KONTROL'+i).value,3))+parseFloat(filterNum(document.getElementById('add_other_amount').value,3)),3);
				document.getElementById('KALAN'+i).value = commaSplit(parseFloat(filterNum(document.getElementById('KALAN'+i).value,3))-parseFloat(filterNum(document.getElementById('add_other_amount').value,3)),3);

			}
		}
	}
	function kontrol_kayit()
	{
		if(form_basket.txt_department_in.value == "")
		{
			alert('<cf_get_lang dictionary_id='57723.Önce Depo Seçmelisiniz'>');
			return false;
		}
		else if(form_basket.txt_department_in.value.indexOf('-') == -1)
		{
			alert('<cf_get_lang dictionary_id='349.Lütfen giriş için doğru depo seçiniz'>');
			return false;
		}
		else
		{
			actionidolustur();
			<cfif len(attributes.lot_no) AND STATU eq 1>
			window.location.href='<cfoutput>#request.self#?fuseaction=pda.add_ambar_fis&e_lot_no=#attributes.lot_no#&ref_no=#GET_LOT_NO_ROW.LOT_NO#&ambarfis=15<cfif isdefined('attributes.param')>&param= and attributes.param</cfif><cfif isdefined('attributes.p_order_id') and len(attributes.p_order_id)>&p_order_id=#attributes.p_order_id#</cfif></cfoutput>&tersfis=1&dep_in='+form_basket.txt_department_in.value+'&dep_out='+form_basket.txt_department_out.value+'&action_id='+document.getElementById('action_id').value+'&fis_tipi='+form_basket.fis_tipi.value+'&process_cat='+form_basket.process_cat_id.value;
			</cfif>
		}
	}
	function actionidolustur()
	{
	  	var j = 0;
	  	for(i=1;i<=row_count;i++)
	  	{
		  	if(document.getElementById('amount'+i).value > 0)
		  	{
				if (j > 0)
				document.getElementById('action_id').value = document.getElementById('action_id').value + ',';
				document.getElementById('action_id').value = document.getElementById('action_id').value + i + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('stockid'+i).value + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + parseFloat(filterNum(document.getElementById('amount'+i).value,3)) + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + '0'+ '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + '0'+ '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('spectmainid'+i).value;
				j++;
		  	}
		  	document.getElementById('row_count').value = j;
	  	}
	}
	function lot_no_area()
	{
		document.getElementById("form_basket").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=pda.add_ambar_fis_5";
		document.getElementById("form_basket").submit();
	}
	function add_order_row(p_order_id)
	{
		document.getElementById("form_basket").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=pda.add_ambar_fis_5&p_order_id="+p_order_id;
		document.getElementById("form_basket").submit();
	}
</script>