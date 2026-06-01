<!---
    File: form_shipping_control_stock.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.add_other_amount" default="1">
<cfparam name="attributes.del_other_amount" default="1">
<cfif attributes.is_type eq 1>
    <cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
    	SELECT
        	PAKETSAYISI AS PAKETSAYISI,
            CONTROL_AMOUNT,
            STOCK_ID,
            BARCOD,
            STOCK_CODE,
            PRODUCT_NAME,
            SPECT_MAIN_ID
        FROM
            (
            SELECT
                SUM(PAKET_SAYISI) PAKETSAYISI,
                ISNULL(SUM(CONTROL_AMOUNT),0) CONTROL_AMOUNT,
                PAKET_ID STOCK_ID,
                BARCOD,
                STOCK_CODE,
                PRODUCT_NAME,
                PRODUCT_TREE_AMOUNT,
                SPECT_MAIN_ID
            FROM
                (      
                SELECT     
                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                    TBL_1.CONTROL_AMOUNT, 
                    ESRR.SHIP_RESULT_ROW_ID, 
                    ORR.STOCK_ID AS MODUL_STOCK_ID, 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_TREE_AMOUNT,
                    ISNULL((SELECT SPECT_MAIN_ID FROM SPECTS WHERE SPECT_VAR_ID = ORR.SPECT_VAR_ID),0) AS SPECT_MAIN_ID
                FROM  
               		EZGI_SHIP_RESULT AS ESR INNER JOIN
             		EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                	ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
              		EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                  	STOCKS AS S ON EPS.PAKET_ID = S.STOCK_ID INNER JOIN
                 	SPECTS AS SP ON EPS.MODUL_SPECT_ID = SP.SPECT_MAIN_ID AND ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID LEFT OUTER JOIN
                    (
                        SELECT     
                            SHIPPING_ID, 
                            STOCK_ID, 
                            SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                        FROM          
                            EZGI_SHIPPING_PACKAGE_LIST
                        WHERE      
                            TYPE = 1 AND
                            SHIPPING_ROW_ID = #attributes.shipping_row_id#
                        GROUP BY 
                            SHIPPING_ID, 
                            STOCK_ID
                    ) AS TBL_1 ON EPS.PAKET_ID = TBL_1.STOCK_ID AND ESR.SHIP_RESULT_ID = TBL_1.SHIPPING_ID INNER JOIN
                    STOCKS AS S1 ON ORR.STOCK_ID = S1.STOCK_ID
                WHERE     
                    ESR.SHIP_RESULT_ID = #attributes.ship_id# AND
                    ORR.STOCK_ID = #attributes.f_stock_id# AND
                    ESRR.SHIP_RESULT_ROW_ID = #attributes.shipping_row_id# AND
                    ISNULL(S1.IS_PROTOTYPE,0) = 1
                GROUP BY 
                    EPS.PAKET_ID, 
                    TBL_1.CONTROL_AMOUNT, 
                    ESRR.SHIP_RESULT_ROW_ID, 
                    ORR.STOCK_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_TREE_AMOUNT,
                    ORR.SPECT_VAR_ID
             	UNION ALL
                SELECT     
                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                    TBL_1.CONTROL_AMOUNT, 
                    ESRR.SHIP_RESULT_ROW_ID, 
                    ORR.STOCK_ID AS MODUL_STOCK_ID, 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_TREE_AMOUNT,
                    ISNULL((SELECT SPECT_MAIN_ID FROM SPECTS WHERE SPECT_VAR_ID = ORR.SPECT_VAR_ID),0) AS SPECT_MAIN_ID
                FROM  
                    EZGI_SHIP_RESULT AS ESR INNER JOIN
                    EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                    EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                    STOCKS AS S ON EPS.PAKET_ID = S.STOCK_ID LEFT OUTER JOIN
                    (
                        SELECT     
                            SHIPPING_ID, 
                            STOCK_ID, 
                            SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                        FROM          
                            EZGI_SHIPPING_PACKAGE_LIST
                        WHERE      
                            TYPE = 1 AND
                            SHIPPING_ROW_ID = #attributes.shipping_row_id#
                        GROUP BY 
                            SHIPPING_ID, 
                            STOCK_ID
                    ) AS TBL_1 ON EPS.PAKET_ID = TBL_1.STOCK_ID AND ESR.SHIP_RESULT_ID = TBL_1.SHIPPING_ID INNER JOIN
                    STOCKS AS S1 ON ORR.STOCK_ID = S1.STOCK_ID
                WHERE     
                    ESR.SHIP_RESULT_ID = #attributes.ship_id# AND
                    ORR.STOCK_ID = #attributes.f_stock_id# AND
                    ESRR.SHIP_RESULT_ROW_ID = #attributes.shipping_row_id# AND
                    ISNULL(S1.IS_PROTOTYPE,0) = 0
                GROUP BY 
                    EPS.PAKET_ID, 
                    TBL_1.CONTROL_AMOUNT, 
                    ESRR.SHIP_RESULT_ROW_ID, 
                    ORR.STOCK_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_TREE_AMOUNT,
                    ORR.SPECT_VAR_ID
                ) TBL_3
            GROUP BY
                PAKET_ID,
                BARCOD,
                STOCK_CODE,
                PRODUCT_NAME,
                PRODUCT_TREE_AMOUNT,
                SPECT_MAIN_ID
    		) AS TBL_4
    </cfquery>
    <cfquery name="get_spect_var_name" datasource="#dsn3#">
    	SELECT        
            ORR.SPECT_VAR_NAME,
            (SELECT IS_PROTOTYPE FROM STOCKS WHERE STOCK_ID = ORR.STOCK_ID) AS IS_PROTOTYPE,
            ORR.PRODUCT_NAME2,
            (
            	SELECT 
                	TOP (1) PO.LOT_NO
				FROM      
                	PRODUCTION_ORDERS_ROW AS PORR INNER JOIN
                	PRODUCTION_ORDERS AS PO ON PORR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
				WHERE     
                	PORR.TYPE = 1 AND 
                    PORR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
            ) AS LOT_NO
		FROM            
        	EZGI_SHIP_RESULT_ROW AS E INNER JOIN
         	ORDER_ROW AS ORR ON E.ORDER_ROW_ID = ORR.ORDER_ROW_ID
		WHERE        
        	E.SHIP_RESULT_ROW_ID = #attributes.shipping_row_id#
    </cfquery>
<cfelse>
	<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
    	SELECT
        	CASE
            	WHEN 
                	PRODUCT_TREE_AMOUNT IS NOT NULL
              	THEN 
                	PRODUCT_TREE_AMOUNT
               	ELSE
            		PAKETSAYISI
           	END 
            	AS PAKETSAYISI,
            CONTROL_AMOUNT,
            STOCK_ID,
            BARCOD,
            STOCK_CODE,
            PRODUCT_NAME,
            SPECT_MAIN_ID
        FROM
            (
            SELECT
                SUM(PAKET_SAYISI) PAKETSAYISI,
                ISNULL(SUM(CONTROL_AMOUNT),0) CONTROL_AMOUNT,
                PAKET_ID STOCK_ID,
                BARCOD,
                STOCK_CODE,
                PRODUCT_NAME,
                PRODUCT_TREE_AMOUNT,
                SPECT_MAIN_ID
            FROM
                (      
               	SELECT     
                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                    TBL_1.CONTROL_AMOUNT, 
                    ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID SHIP_RESULT_ROW_ID, 
                    ORR.STOCK_ID AS MODUL_STOCK_ID, 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_TREE_AMOUNT,
                    ISNULL((SELECT SPECT_MAIN_ID FROM SPECTS WHERE SPECT_VAR_ID = ORR.SPECT_VAR_ID),0) AS SPECT_MAIN_ID
                FROM  
               		EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
             		EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                	ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
              		EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                  	STOCKS AS S ON EPS.PAKET_ID = S.STOCK_ID INNER JOIN
                 	SPECTS AS SP ON EPS.MODUL_SPECT_ID = SP.SPECT_MAIN_ID AND ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID LEFT OUTER JOIN
                    (
                        SELECT     
                            SHIPPING_ID, 
                            STOCK_ID, 
                            SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                        FROM          
                            EZGI_SHIPPING_PACKAGE_LIST
                        WHERE      
                            TYPE = 2 AND
                            SHIPPING_ROW_ID = #attributes.shipping_row_id#
                        GROUP BY 
                            SHIPPING_ID, 
                            STOCK_ID
                    ) AS TBL_1 ON EPS.PAKET_ID = TBL_1.STOCK_ID AND ESR.SHIP_RESULT_INTERNALDEMAND_ID = TBL_1.SHIPPING_ID INNER JOIN
                    STOCKS AS S1 ON ORR.STOCK_ID = S1.STOCK_ID
                WHERE     
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
                    ORR.STOCK_ID = #attributes.f_stock_id# AND
                    ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID = #attributes.shipping_row_id# AND
                    ISNULL(S1.IS_PROTOTYPE,0) = 1
                GROUP BY 
                    EPS.PAKET_ID, 
                    TBL_1.CONTROL_AMOUNT, 
                    ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID, 
                    ORR.STOCK_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_TREE_AMOUNT,
                    ORR.SPECT_VAR_ID
             	UNION ALL
                SELECT     
                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                    TBL_1.CONTROL_AMOUNT, 
                    ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID AS SHIP_RESULT_ROW_ID, 
                    ORR.STOCK_ID AS MODUL_STOCK_ID, 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_TREE_AMOUNT,
                    ISNULL((SELECT SPECT_MAIN_ID FROM SPECTS WHERE SPECT_VAR_ID = ORR.SPECT_VAR_ID),0) AS SPECT_MAIN_ID
                FROM  
                    EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                    EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                    ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                    EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                    STOCKS AS S ON EPS.PAKET_ID = S.STOCK_ID LEFT OUTER JOIN
                    (
                        SELECT     
                            SHIPPING_ID, 
                            STOCK_ID, 
                            SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                        FROM          
                            EZGI_SHIPPING_PACKAGE_LIST
                        WHERE      
                            TYPE = 2 AND
                            SHIPPING_ROW_ID = #attributes.shipping_row_id#
                        GROUP BY 
                            SHIPPING_ID, 
                            STOCK_ID
                    ) AS TBL_1 ON EPS.PAKET_ID = TBL_1.STOCK_ID AND ESR.SHIP_RESULT_INTERNALDEMAND_ID = TBL_1.SHIPPING_ID INNER JOIN
                    STOCKS AS S1 ON ORR.STOCK_ID = S1.STOCK_ID
                WHERE     
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
                    ORR.STOCK_ID = #attributes.f_stock_id# AND
                    ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID = #attributes.shipping_row_id# AND
                    ISNULL(S1.IS_PROTOTYPE,0) = 0
                GROUP BY 
                    EPS.PAKET_ID, 
                    TBL_1.CONTROL_AMOUNT, 
                    ESRR.SHIP_RESULT_INTERNALDEMAND_ROW_ID, 
                    ORR.STOCK_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME,
                    S.PRODUCT_TREE_AMOUNT,
                    ORR.SPECT_VAR_ID
                ) TBL_3
            GROUP BY
                PAKET_ID,
                BARCOD,
                STOCK_CODE,
                PRODUCT_NAME,
                PRODUCT_TREE_AMOUNT,
                SPECT_MAIN_ID
         	) AS TBL_4       
    </cfquery>
    <cfquery name="get_spect_var_name" datasource="#dsn3#">
    	SELECT        
        	ORR.SPECT_VAR_NAME,
            ISNULL(S.IS_PROTOTYPE,0) AS IS_PROTOTYPE,
            ORR.PRODUCT_NAME2,
            (
            	SELECT TOP (1)
                	PO.LOT_NO
				FROM      
                	#dsn3_alias#.PRODUCTION_ORDERS_ROW AS PORR INNER JOIN
                	#dsn3_alias#.PRODUCTION_ORDERS AS PO ON PORR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID
				WHERE     
                	PORR.TYPE = 1 AND 
                    PORR.ORDER_ROW_ID = ORR.ORDER_ROW_ID
            ) AS LOT_NO
		FROM            
       		EZGI_SHIP_RESULT_INTERNALDEMAND AS SI WITH (NOLOCK) INNER JOIN
          	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS SIR WITH (NOLOCK) ON SI.SHIP_RESULT_INTERNALDEMAND_ID = SIR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
         	ORDER_ROW AS ORR WITH (NOLOCK) ON ORR.ORDER_ROW_ID = SIR.ORDER_ROW_ID INNER JOIN
         	STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID
		WHERE        
        	SI.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.shipping_row_id#
    </cfquery>
</cfif>
<cfset spect_main_id_list = ValueList(GET_SHIP_PACKAGE_LIST.SPECT_MAIN_ID)>
<cfquery name="get_detail_package_list" dbtype="query">
	SELECT * FROM GET_SHIP_PACKAGE_LIST WHERE CONTROL_AMOUNT > 0
</cfquery>
<cfoutput query="get_detail_package_list">
	<cfset 'control_amount#STOCK_ID#' = CONTROL_AMOUNT>
</cfoutput>
<cfset stock_id_list = ValueList(GET_SHIP_PACKAGE_LIST.STOCK_ID,',')>
<cfquery name="get_defaults" datasource="#dsn3#">
  SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfform name="add_package" method="post" action="#request.self#?fuseaction=pda.emptypopup_add_shipping_control_stock&SHIP_ID=#URLDecode(URL.ship_id)#&department_id=#department_id#&date1=#date1#&date2=#date2#&page=#page#&kontrol_status=1&f_stock_id=#attributes.f_stock_id#&is_type=#attributes.is_type#&deliver_paper_no=#attributes.DELIVER_PAPER_NO#">
		<cfsavecontent variable="title">
        	<cfoutput>
        		<b>Ürün : #product_name#</b>
            	<cfif get_spect_var_name.IS_PROTOTYPE eq 1><br />Spekt : #GET_SHIP_PACKAGE_LIST.SPECT_MAIN_ID# - Lot : #get_spect_var_name.LOT_NO#</cfif>
        	</cfoutput>
        </cfsavecontent>
     	<cf_box title="#title#">
        	<cf_basket_form id="shipping_ambar_fis">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
                         	<cf_box_elements>
                            	<div class="col col-12 uniqueRow" id="first_area">
                                	<div class="col col-12">
                                    	<div class="col col-6">
                                            <label>Miktar</label>
                                        </div>
                                        <div class="col col-6">
                                            <label>Barkod</label>
                                        </div>
                                    </div>
                                    <div class="col col-12">
                                    	<div class="col col-6">
                                            <div class="form-group" id="item-amount">
                                                <input id="add_other_amount" name="add_other_amount" type="text" value="1" style="width:25px;text-align:right;font-weight:bold;color:FF0000;" <cfif get_defaults.IS_AMOUNT_INPUT_FREE>readonly</cfif>>
                                            </div>
                                        </div>
                                        <div class="col col-6">
                                            <div class="form-group" id="item-barcod">
                                                <input name="add_other_barcod" id="add_other_barcod" type="text" value="" onKeyDown="if(event.keyCode == 13) {return add_product_to_barkod(this.value,add_other_amount.value,1);}" style="width:120px; height:25px">
                                            </div>
                                        </div>
                                    </div>
                               	</div>
               				</cf_box_elements>
                    		<cf_box_footer>
                            	<div class="col col-12">
                                    <div class="col col-6" style="text-align:right">
                                	</div>
                                    <div class="col col-3" style="text-align:right" id="onay_div">
                                        <input id="onay" name="Onay" style="width:100%" type="button" value="<cfif not get_detail_package_list.recordcount><cf_get_lang dictionary_id='57461.Kaydet'><cfelse><cf_get_lang dictionary_id='57464.Güncelle'></cfif>" onClick="if(confirm('<cf_get_lang dictionary_id='57535.Kaydetmek İstediğinizden Emin Misiniz?'>')) kontrol(); else return false;" />
                                 	</div>
                                    <div class="col col-3" style="text-align:right;" id="vazgec_div">
                                        <input id="vazgec" name="vazgec" style="background-color:red; color:white; width:100%" value="<cf_get_lang dictionary_id="57462.Vazgeç">" type="button" onclick="if(confirm('<cf_get_lang dictionary_id='383.Kaydetmeden Çıkıyorsunuz!'>')) cik(); else return false;" />
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
                                	<cfsavecontent variable="title">
										<cfif attributes.is_type eq 1>
                                        	<b><cf_get_lang dictionary_id='382.Sevk Plan No'> :</b>
                                       	<cfelse>
                                        	<b><cf_get_lang dictionary_id='375.Sevk Talep No'> :</b>
                                      	</cfif>
										<cfoutput>#attributes.DELIVER_PAPER_NO#</cfoutput>
                                 	</cfsavecontent>
                                    <cf_box title="#title#">
                                        <cf_grid_list>    
                                        	<thead>
                                                <tr>
                                                    <th style="width:100%"><cf_get_lang dictionary_id='36590.Paket Bilgisi'></th>
                                                    <th style="width:15%"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                                    <th style="width:15%"><cf_get_lang dictionary_id='45358.Kontrol'></th>
                                                    <!-- sil -->
                                                    <th style="width:10%">&nbsp;&nbsp;&nbsp;</th>
                                                    <!-- sil -->
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <cfif GET_SHIP_PACKAGE_LIST.recordcount>
                                                    <cfset product_barcode_list = ''>
                                                    <input type="hidden" name="f_stock_id" value="#f_stock_id#"/>
                                                    <input type="hidden" name="shipping_row_id" value="<cfoutput>#attributes.shipping_row_id#</cfoutput>"/>
                                                    <input type="hidden" name="stock_id_list" value="<cfoutput>#stock_id_list#</cfoutput>">
                                                    <cfoutput query="GET_SHIP_PACKAGE_LIST">
                                                        <cfquery name="GET_BARCODE" datasource="#DSN3#">
                                                            SELECT TOP 1 BARCODE FROM  STOCKS_BARCODES WHERE STOCK_ID=#STOCK_ID#
                                                        </cfquery>
                                                        <script language="javascript" type="text/javascript">
                                                            <cfoutput>
                                                                var product_name#stock_id# = '#product_name#';
                                                                var barkot#stock_id# = '#get_barcode.barcode#';
                                                            </cfoutput>
                                                        </script>
                                                        <tr id="row#STOCK_ID#" height="20">
                                                            <td>#product_name#<cfif SPECT_MAIN_ID gt 0> - #BARCOD#</cfif></td>
                                                            <input type="hidden" id="PRODUCT_NAME#STOCK_ID#" name="PRODUCT_NAME#STOCK_ID#" value="#PRODUCT_NAME#" class="box" style="width:20px;">
                                                            <cfset product_barcode_list = listdeleteduplicates(ListAppend(product_barcode_list,ValueList(GET_BARCODE.BARCODE),','))>	
                                                            <td style="text-align:right">
                                                                <input type="text" name="amount#STOCK_ID#" id="amount#STOCK_ID#" value="#PAKETSAYISI#" readonly="yes" class="box" style="width:30px;text-align:right;">
                                                            </td>
                                                            <td style="text-align:right">
                                                                <input type="text" name="control_amount#STOCK_ID#" id="control_amount#STOCK_ID#" value="<cfif isdefined('control_amount#STOCK_ID#')>
                                                            #Tlformat(Evaluate('control_amount#STOCK_ID#'),0)# <cfelse>#0#</cfif>" class="box" style="width:30px;text-align:right;color:FF0000;">
                                                            </td>
                                                            <td style="text-align:center">
                                                                <img id="is_ok#STOCK_ID#" name="is_ok#STOCK_ID#"<cfif not isdefined('control_amount#STOCK_ID#') or (isdefined('control_amount#STOCK_ID#') and Evaluate('control_amount#STOCK_ID#') neq PAKETSAYISI)>style="display:none;"</cfif> align="center" src="images\c_ok.gif">
                                                                <img id="is_error#STOCK_ID#" name="is_error#STOCK_ID#"<cfif not isdefined('control_amount#STOCK_ID#') or (isdefined('control_amount#STOCK_ID#') and Evaluate('control_amount#STOCK_ID#') lte PAKETSAYISI)>style="display:none;"</cfif>align="center" src="images\closethin.gif">
                                                            </td>
                                                        </tr>
                                                    </cfoutput>
                                                </cfif>
                                                <input type="hidden" name="changed_stock_id" value=""><!--- Bu hidden alan kontrol yapıldıkça kontrol yapılan satırı renklendirmek için kullanılıyor. --->
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
<script language="javascript">
	setTimeout("document.getElementById('add_other_barcod').select();",1000);	
	function add_product_to_barkod(barcode,amount,type)
	{
		if(barcode.substr(0,1)=='j')//Bazı barkod okuyucular okuduktan sonra başına j harfi koyuyor kontrol için yapıldı
			barcode = barcode.substring(1,length(barcode));
		uzunluk = barcode.length;
		spect = 0;
		if(uzunluk > 8)
		{
			spect = barcode.substring(8,uzunluk);
			barcode = barcode.substring(0,8);
		}
		var amount = filterNum(amount,0)
		if(spect > 0)
		{
			if(list_find('<cfoutput>#spect_main_id_list#</cfoutput>',spect,','))
			{
			}
			else
			{
				alert(spect+' Spect No <cf_get_lang dictionary_id='378.Bu Sevikatın Ürünü Değildir'>');
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcod').focus();
				return false;	
			}
		}
		if(list_find('<cfoutput>#product_barcode_list#</cfoutput>',barcode,','))
		{
			/*var new_sql = "SELECT TOP 1 STOCK_ID FROM STOCKS_BARCODES WHERE BARCODE = '"+barcode+"'";*/
			/*var get_product = wrk_query(new_sql,'dsn1');*/
			var listParam = barcode;
			var get_product = wrk_safe_query('get_product_ezgi','dsn3',0,listParam);
			
			//alert(document.getElementById('control_amount'+get_product.STOCK_ID));
				if(document.getElementById('control_amount'+get_product.STOCK_ID)==undefined)
					alert(barcode +' No <cf_get_lang dictionary_id='384.Ürünün Barkodlarında Sorun Var!'>')		
				else
				{
					if(document.all.changed_stock_id.value != "")//daha önceden bir satır eklenmişse alan dolmuş demektir ve yeni eklenecek alan için satırı renklendiyoruz bir alt satırda
						eval('row'+document.all.changed_stock_id.value).style.background='<cfoutput></cfoutput>';
					if(type==1)//ekleme ise
					{		
						if(filterNum(document.getElementById('control_amount'+get_product.STOCK_ID).value,0) == document.getElementById('amount'+get_product.STOCK_ID).value)
							alert(document.getElementById('PRODUCT_NAME'+get_product.STOCK_ID).value+' <cf_get_lang dictionary_id='385.Ürününde Fazla Çıkış Var'>');
						else
							document.getElementById('control_amount'+get_product.STOCK_ID).value = commaSplit(parseFloat(parseFloat(filterNum(document.getElementById('control_amount'+get_product.STOCK_ID).value))+parseFloat(amount)),0);	
						if(filterNum(document.getElementById('control_amount'+get_product.STOCK_ID).value,0) == document.getElementById('amount'+get_product.STOCK_ID).value)
							document.getElementById('row'+get_product.STOCK_ID).style.display='none';
					}			
					else if(type==0)//silme ise	
						if(filterNum(document.getElementById('control_amount'+get_product.STOCK_ID).value,0) == 0 || filterNum(document.getElementById('control_amount'+get_product.STOCK_ID).value,0) < 0)
							alert('<cf_get_lang dictionary_id='380.Çıkan Ürünlerin Sayısı 0 dan küçük olamaz'>');
						else		
							document.getElementById('control_amount'+get_product.STOCK_ID).value = commaSplit(parseFloat(parseFloat(filterNum(document.getElementById('control_amount'+get_product.STOCK_ID).value))-parseFloat(amount)),0);
								if(filterNum(document.getElementById('control_amount'+get_product.STOCK_ID).value,0) == document.getElementById('amount'+get_product.STOCK_ID).value)
								{eval('document.all.is_ok'+get_product.STOCK_ID).style.display='';
								eval('document.all.is_error'+get_product.STOCK_ID).style.display='none';}	
								if(filterNum(document.getElementById('control_amount'+get_product.STOCK_ID).value,0) > document.getElementById('amount'+get_product.STOCK_ID).value)
								{eval('document.all.is_ok'+get_product.STOCK_ID).style.display='none';
								eval('document.all.is_error'+get_product.STOCK_ID).style.display='';}
								if(filterNum(document.getElementById('control_amount'+get_product.STOCK_ID).value,0) < document.getElementById('amount'+get_product.STOCK_ID).value)
									eval('document.all.is_ok'+get_product.STOCK_ID).style.display='none';
				document.all.add_other_barcod.value='';
				/*document.all.del_other_barcod.value='';*/
				document.all.changed_stock_id.value = get_product.STOCK_ID;
				eval('row'+get_product.STOCK_ID).style.background='FFCCCC';
				}	
			}
		else
			alert('<cf_get_lang dictionary_id='381.Kayıtlı Barkod Yok!'>')
	}
	function kontrol()
	{
	
		for(i=1;i<=<cfoutput>#listlen(stock_id_list,',')#</cfoutput>;i++)
		{
			eval('document.all.control_amount'+list_getat("<cfoutput>#stock_id_list#</cfoutput>",i,",")).value = filterNum(eval('document.all.control_amount'+list_getat("<cfoutput>#stock_id_list#</cfoutput>",i,",")).value,0)
		}
		document.add_package.submit();
	}
	function cik()
	{
		window.location ="<cfoutput>#request.self#?fuseaction=pda.form_shipping_control_fis&ship_id=#attributes.SHIP_ID#&department_id=#department_id#&date1=#date1#&date2=#date2#&page=#page#&kontrol_status=#kontrol_status#&is_type=#attributes.is_type#&deliver_paper_no=#attributes.DELIVER_PAPER_NO#</cfoutput>";
	}
</script>