<!---
    File: form_shipping_control.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cf_xml_page_edit>
<cfquery name="get_url" datasource="#dsn#">
	SELECT     
    	E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS ADI
	FROM         
    	WRK_SESSION AS W INNER JOIN
     	EMPLOYEES AS E ON W.USERID = E.EMPLOYEE_ID
	WHERE     
    	W.ACTION_PAGE LIKE '#fuseaction#%' AND 
        W.ACTION_PAGE LIKE N'%ship_id=#attributes.ship_id#%' AND 
        E.EMPLOYEE_ID <> #session.ep.userid#
</cfquery>
<cfif get_url.recordcount>
	<cfset kullanici = get_url.adi>
	<script language="javascript">
		alert('<cf_get_lang dictionary_id='374.Girmek İstediğiniz Sayfa Kullanılmaktadır'>');
		history.back();
	</script>
</cfif>
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfif not len(get_defaults.EAN)>
	<script language="javascript">
		alert('Default Tanımları Giriniz');
		history.back();
	</script>
    <cfabort>
</cfif>
<cfparam name="attributes.add_other_amount" default="1">
<cfparam name="attributes.del_other_amount" default="1">
<cfif attributes.is_type eq 1>
    <cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
        SELECT     
        	PAKET_SAYISI AS PAKETSAYISI, 
            PAKET_ID AS STOCK_ID, 
            BARCOD, 
            STOCK_CODE, 
            PRODUCT_NAME,
         	(
             SELECT     
            	SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
         	FROM          
            	EZGI_SHIPPING_PACKAGE_LIST
         	WHERE      
            	TYPE = 1 AND 
                STOCK_ID = TBL.PAKET_ID AND 
                ISNULL(SPECT_MAIN_ID,0) = ISNULL(TBL.SPECT_MAIN_ID,0) AND
                SHIPPING_ID = TBL.SHIP_RESULT_ID
        	) AS CONTROL_AMOUNT,
            SPECT_MAIN_ID
		FROM         
        	(
            SELECT
            	SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                PAKET_ID, 
                BARCOD, 
                STOCK_CODE, 
                PRODUCT_NAME, 
                PRODUCT_TREE_AMOUNT, 
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
                    S.PRODUCT_TREE_AMOUNT, 
                    ESR.SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID,
                    <cfif x_package_spect_type eq 1>
                    	ISNULL(SP.SPECT_MAIN_ID,0) AS SPECT_MAIN_ID
                    <cfelseif x_package_spect_type eq 2>
                    	ISNULL(EPS.PAKET_SPECT_ID,0) AS SPECT_MAIN_ID
                    </cfif>
                FROM          
               		STOCKS AS S1 INNER JOIN
                 	EZGI_SHIP_RESULT AS ESR INNER JOIN
                 	EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                  	ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
                 	SPECTS AS SP ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
                 	STOCKS AS S INNER JOIN
                    <cfif x_package_spect_type eq 1>
                 		EZGI_PAKET_SAYISI AS EPS ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID
                    <cfelseif x_package_spect_type eq 2>
                    	EZGI_PAKET_SAYISI_NEW AS EPS ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID
                	</cfif>
                WHERE      
                    ESR.SHIP_RESULT_ID = #attributes.ship_id# AND
                    ORR.ORDER_ROW_CURRENCY = -6 AND
                   	ISNULL(S1.IS_PROTOTYPE,0) = 1
                GROUP BY 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_TREE_AMOUNT, 
                    ESR.SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID,
                    ORR.SPECT_VAR_ID,
                    <cfif x_package_spect_type eq 1>
                  		SP.SPECT_MAIN_ID,	
                    <cfelseif x_package_spect_type eq 2>
               			EPS.PAKET_SPECT_ID,
                    </cfif>
                    ORR.ORDER_ROW_ID
              	UNION ALL
                SELECT     
                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_TREE_AMOUNT, 
                    ESR.SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID,
                    0 AS SPECT_MAIN_ID
             	FROM
                	EZGI_SHIP_RESULT AS ESR INNER JOIN
                	EZGI_SHIP_RESULT_ROW AS ESRR ON ESR.SHIP_RESULT_ID = ESRR.SHIP_RESULT_ID INNER JOIN
                 	ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                    <cfif x_package_spect_type eq 1>
                 		EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                    <cfelseif x_package_spect_type eq 2>
                    	EZGI_PAKET_SAYISI_NEW AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                    </cfif>
                  	STOCKS AS S ON S.STOCK_ID = EPS.PAKET_ID INNER JOIN
                  	STOCKS AS S1 ON S1.STOCK_ID = ORR.STOCK_ID
               	WHERE      
                    ESR.SHIP_RESULT_ID = #attributes.ship_id# AND
                    ORR.ORDER_ROW_CURRENCY = -6 AND
                   	ISNULL(S1.IS_PROTOTYPE,0) = 0
              	GROUP BY
             		EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_TREE_AMOUNT, 
                    ESR.SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID,
                    ORR.SPECT_VAR_ID,
                    ORR.ORDER_ROW_ID
             	) AS TBL1
          	GROUP BY
            	PAKET_ID, 
                BARCOD, 
                STOCK_CODE, 
                PRODUCT_NAME, 
                PRODUCT_TREE_AMOUNT, 
                SHIP_RESULT_ID,
                SPECT_MAIN_ID
        	) AS TBL
  	</cfquery>
   
<cfelse>
   	<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
        SELECT     
        	PAKET_SAYISI AS PAKETSAYISI, 
            PAKET_ID AS STOCK_ID, 
            BARCOD, 
            STOCK_CODE, 
            PRODUCT_NAME,
            (
            SELECT     
            	SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
           	FROM          
            	EZGI_SHIPPING_PACKAGE_LIST
        	WHERE      
            	TYPE = 2 AND 
                STOCK_ID = TBL.PAKET_ID AND 
                SHIPPING_ID = TBL.SHIP_RESULT_ID
          	) AS CONTROL_AMOUNT, 
            SHIP_RESULT_ID,
            SPECT_MAIN_ID
		FROM         
        	(
            SELECT     
            	SUM(PAKET_SAYISI) AS PAKET_SAYISI, 
                PAKET_ID, 
                BARCOD, 
                STOCK_CODE, 
                PRODUCT_NAME, 
                PRODUCT_TREE_AMOUNT, 
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
                    S.PRODUCT_TREE_AMOUNT, 
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID,
                    <cfif x_package_spect_type eq 1>
                    	ISNULL(SP.SPECT_MAIN_ID,0) AS SPECT_MAIN_ID
                    <cfelseif x_package_spect_type eq 2>
                    	ISNULL(EPS.PAKET_SPECT_ID,0) AS SPECT_MAIN_ID
                    </cfif>
                FROM          
               		STOCKS AS S1 INNER JOIN
                 	EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                 	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                  	ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID ON S1.STOCK_ID = ORR.STOCK_ID INNER JOIN
                 	SPECTS AS SP ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
                 	STOCKS AS S INNER JOIN
                    <cfif x_package_spect_type eq 1>
                 		EZGI_PAKET_SAYISI AS EPS ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID
                    <cfelseif x_package_spect_type eq 2>
                    	EZGI_PAKET_SAYISI_NEW AS EPS ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID
                	</cfif>
                WHERE      
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
                    ORR.ORDER_ROW_CURRENCY = -6 AND
                   	ISNULL(S1.IS_PROTOTYPE,0) = 1
                GROUP BY 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_TREE_AMOUNT, 
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                    ESRR.ORDER_ROW_ID,
                    ORR.SPECT_VAR_ID,
                    <cfif x_package_spect_type eq 1>
                  		SP.SPECT_MAIN_ID,	
                    <cfelseif x_package_spect_type eq 2>
               			EPS.PAKET_SPECT_ID,
                    </cfif>
                    ORR.ORDER_ROW_ID
              	UNION ALL
                SELECT     
                    SUM(ORR.QUANTITY * EPS.PAKET_SAYISI) AS PAKET_SAYISI, 
                    EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_TREE_AMOUNT, 
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID AS SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID,
                    0 AS SPECT_MAIN_ID
             	FROM
                	EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS ESRR ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = ESRR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                 	ORDER_ROW AS ORR ON ESRR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                    <cfif x_package_spect_type eq 1>
                 		EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                    <cfelseif x_package_spect_type eq 2>
                    	EZGI_PAKET_SAYISI_NEW AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                    </cfif>
                  	STOCKS AS S ON S.STOCK_ID = EPS.PAKET_ID INNER JOIN
                  	STOCKS AS S1 ON S1.STOCK_ID = ORR.STOCK_ID
               	WHERE      
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID = #attributes.ship_id# AND
                    ORR.ORDER_ROW_CURRENCY = -6 AND
                   	ISNULL(S1.IS_PROTOTYPE,0) = 0
              	GROUP BY
             		EPS.PAKET_ID, 
                    S.BARCOD, 
                    S.STOCK_CODE, 
                    S.PRODUCT_NAME, 
                    S.PRODUCT_TREE_AMOUNT, 
                    ESR.SHIP_RESULT_INTERNALDEMAND_ID,
                    ESRR.ORDER_ROW_ID,
                    ORR.SPECT_VAR_ID,
                    ORR.ORDER_ROW_ID
           		) AS TBL1
         	GROUP BY 
            	PAKET_ID, 
                BARCOD, 
                STOCK_CODE, 
                PRODUCT_NAME, 
                PRODUCT_TREE_AMOUNT, 
                SHIP_RESULT_ID,
                SPECT_MAIN_ID
       		) AS TBL
    </cfquery>


</cfif>
<cfset spect_main_id_list = ValueList(GET_SHIP_PACKAGE_LIST.SPECT_MAIN_ID)>
<cfquery name="get_detail_package_list" dbtype="query">
	SELECT * FROM GET_SHIP_PACKAGE_LIST WHERE CONTROL_AMOUNT > 0
</cfquery>
<cfquery name="get_total_control" dbtype="query">
	SELECT sum(CONTROL_AMOUNT) as CONTROL_AMOUNT, sum(PAKETSAYISI) PAKETSAYISI FROM GET_SHIP_PACKAGE_LIST
</cfquery>
<cfif not len(get_total_control.CONTROL_AMOUNT)>
	<cfset get_total_control.CONTROL_AMOUNT = 0 >
</cfif>
<cfoutput query="get_detail_package_list">
	<cfset 'control_amount#STOCK_ID#_#SPECT_MAIN_ID#' = CONTROL_AMOUNT>
</cfoutput>
<cfset stock_id_list = ''>
<cfoutput query="GET_SHIP_PACKAGE_LIST">
	<cfset stock_id_list = ListAppend(stock_id_list,'#STOCK_ID#_#SPECT_MAIN_ID#')>
</cfoutput>
<cfset product_barcode_list = ''>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cfform name="add_package" method="post" action="#request.self#?fuseaction=pda.emptypopup_add_shipping_package&SHIP_ID=#attributes.ship_id#&department_id=#attributes.department_id#&date1=#attributes.date1#&date2=#attributes.date2#&page=#attributes.page#&kontrol_status=#attributes.kontrol_status#&is_type=#attributes.is_type#">
    	<cf_box>
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
                                                <input id="add_other_amount" name="add_other_amount" type="text" value="1" style="width:25px;text-align:right;font-weight:bold;color:FF0000;" onKeyup="return(FormatCurrency(this,event,0));" <cfif get_defaults.IS_AMOUNT_INPUT_FREE>readonly</cfif>>
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
                                    <div class="col col-3" style="text-align:right;" id="onay_div">
                                        <input type="button" id="onay" name="Onay" style="width:100%"  value="<cfif not get_detail_package_list.recordcount>Kaydet<cfelse><cf_get_lang dictionary_id='57464.Güncelle'></cfif>" onClick="if(confirm('Kaydetmek İstediğinizden Eminmisiniz?')) kontrol(); else return false;" />
                                 	</div>
                                    <div class="col col-3" style="text-align:right;" id="vazgec_div">
                                        <input type="button" id="vazgec" name="vazgec" style="background-color:red; color:white; width:100%" value="<cf_get_lang dictionary_id="57462.Vazgeç">" onclick="if(confirm('<cf_get_lang dictionary_id='383.Kaydetmeden Çıkıyorsunuz!'>')) cik(); else return false;" />
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
                                                    
                                                    <input type="hidden" name="stock_id_list" value="<cfoutput>#stock_id_list#</cfoutput>">
                                                    <cfoutput query="GET_SHIP_PACKAGE_LIST">
                                                        <tr id="row#STOCK_ID#_#SPECT_MAIN_ID#" height="20">
                                                            <td>#product_name#<cfif SPECT_MAIN_ID gt 0><font color="red"> - #SPECT_MAIN_ID#</font></cfif></td>        
                                                                <input type="hidden" id="PRODUCT_NAME#STOCK_ID#_#SPECT_MAIN_ID#" name="PRODUCT_NAME#STOCK_ID#_#SPECT_MAIN_ID#" value="#PRODUCT_NAME#" class="box" style="width:100;">
                                                                <cfquery name="GET_BARCODE" datasource="#DSN3#">
                                                                    SELECT TOP 1 BARCODE FROM  STOCKS_BARCODES WHERE STOCK_ID=#STOCK_ID#
                                                                </cfquery>
                                                                <cfif SPECT_MAIN_ID gt 0>
                                                                    <cfquery name="GET_LOT" datasource="#DSN3#">
                                                                        SELECT TOP 1 BARCODE FROM  STOCKS_BARCODES WHERE STOCK_ID=#SPECT_MAIN_ID#
                                                                    </cfquery>
                                                                </cfif>
                                                                <cfset product_barcode_list = listdeleteduplicates(ListAppend(product_barcode_list,ValueList(GET_BARCODE.BARCODE),','))>	
                                                            <td style="text-align:right">
                                                                <input type="text" name="amount#STOCK_ID#_#SPECT_MAIN_ID#" id="amount#STOCK_ID#_#SPECT_MAIN_ID#" value="#PAKETSAYISI#" readonly="yes" class="box" style="width:30px;text-align:right;">
                                                            </td>
                                                            <td style="text-align:right">
                                                                <input type="text" id="control_amount#STOCK_ID#_#SPECT_MAIN_ID#" name="control_amount#STOCK_ID#_#SPECT_MAIN_ID#" value="<cfif isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')>#Evaluate('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')#</cfif>" class="box"  style="width:30px;text-align:right;color:FF0000;">
                                                            </td>
                                                            <td align="center" valign="middle">      
                                                                <img id="is_ok#STOCK_ID#_#SPECT_MAIN_ID#" name="is_ok#STOCK_ID#_#SPECT_MAIN_ID#"<cfif not isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#') or (isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#') and Evaluate('control_amount#STOCK_ID#_#SPECT_MAIN_ID#') neq PAKETSAYISI)>style="display:none;"</cfif> align="center" src="images\c_ok.gif">
                                                                <img id="warning_#STOCK_ID#_#SPECT_MAIN_ID#" name="warning_#STOCK_ID#_#SPECT_MAIN_ID#"<cfif not isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#') or (isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#') and Evaluate('control_amount#STOCK_ID#_#SPECT_MAIN_ID#') eq PAKETSAYISI)>style="display:none;"</cfif> align="center" src="images\warning.gif">
                                                                <img id="is_error#STOCK_ID#_#SPECT_MAIN_ID#" name="is_error#STOCK_ID#_#SPECT_MAIN_ID#"<cfif not isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#') or (isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#') and Evaluate('control_amount#STOCK_ID#_#SPECT_MAIN_ID#') lte PAKETSAYISI)>style="display:none;"</cfif>align="center" src="images\closethin.gif">
                                                            </td>
                                                        </tr>
                                                    </cfoutput>
                                                    <input type="hidden" name="changed_stock_id" value=""><!--- Bu hidden alan kontrol yapıldıkça kontrol yapılan satırı renklendirmek için kullanılıyor. --->
                                                    <tr style="font-weight:bold">
                                                    	
                                                        <cfoutput>
                                                        <td style="text-align:LEFT">Toplam</td>
                                                        <td style="text-align:right">
                                                            #get_total_control.PAKETSAYISI#
                                                        </td>
                                                        <td style="text-align:right">
                                                            <input type="text" name="total_control_amount" readonly="readonly" class="box" style="width:35px;text-align:right;font-weight:bold;color:FF0000;" id="total_control_amount" value="#get_total_control.CONTROL_AMOUNT#" />
                                                        </td>
                                                        
                                                        <td></td>
                                                        </cfoutput>
                                                    </tr>
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
	
<script language="javascript">
	document.getElementById('add_other_barcod').focus();
	setTimeout("document.getElementById('add_other_barcod').select();",1000);	
	function add_product_to_barkod(barcode,amount,type)
	{	
		<cfoutput>
			var ship_id = #attributes.ship_id#;
			var is_type = #attributes.is_type#;
		</cfoutput>
		if(barcode.substr(0,1)=='j')//Bazı barkod okuyucular okuduktan sonra başına j harfi koyuyor kontrol için yapıldı
			barcode = barcode.substring(1,length(barcode));
		uzunluk = barcode.length;
		spect = 0;
		ean = <cfoutput>#get_defaults.EAN#</cfoutput>;
		if(uzunluk > ean)
		{
			spect = barcode.substring(ean,uzunluk);
			barcode = barcode.substring(0,ean);
		}
		var amount = filterNum(amount,0)
		if(spect > 0)
		{
			if(list_find('<cfoutput>#spect_main_id_list#</cfoutput>',spect,','))
			{
			}
			else
			{
				alert(spect+' Spect No <cf_get_lang dictionary_id='378.Bu Sevikatın Ürünü Değildir'>!');
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcod').focus();
				return false;	
			}
		}
		if(list_find('<cfoutput>#product_barcode_list#</cfoutput>',barcode,','))
		{
			/*var new_sql = "SELECT TOP 1 STOCK_ID FROM STOCKS_BARCODES WHERE BARCODE = '"+barcode+"'";*/
			var listParam = barcode;
			var get_product = wrk_safe_query('get_product_ezgi','dsn3',0,listParam);
			
			/*var get_product = wrk_query(new_sql,'dsn1');*/
				if(document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect)==undefined)
				{
					alert('<cf_get_lang dictionary_id='347.Ürün Barkodu Hatalı'>')	
				}
				else
				{
					if(type==1)//ekleme ise
					{	
						if((document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value*1)-(amount*-1) > (document.getElementById('amount'+get_product.STOCK_ID+'_'+spect).value*1))
							alert(document.getElementById('PRODUCT_NAME'+get_product.STOCK_ID+'_'+spect).value+' <cf_get_lang dictionary_id='379.Fazla Çıkış'>');
						else
						{
							document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value = (document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value*1)+(amount*1);
							document.all.total_control_amount.value=(document.all.total_control_amount.value*1)+(amount*1);
						}
						if(document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value == document.getElementById('amount'+get_product.STOCK_ID+'_'+spect).value)
							document.getElementById('row'+get_product.STOCK_ID+'_'+spect).style.display='none';
					}			
					else if(type==0)//silme ise	
						if(document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value == 0 || document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value < 0)
							alert('<cf_get_lang dictionary_id='380.Çıkan Ürünlerin Sayısı 0 dan küçük olamaz'>');
						else		
							document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value = (document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value*1)-(amount*1);
								if(document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value == document.getElementById('amount'+get_product.STOCK_ID+'_'+spect).value)
								{eval('document.all.is_ok'+get_product.STOCK_ID+'_'+spect).style.display='';
								eval('document.all.is_error'+get_product.STOCK_ID+'_'+spect).style.display='none';}	
								if(document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value > document.getElementById('amount'+get_product.STOCK_ID+'_'+spect).value)
								{eval('document.all.is_ok'+get_product.STOCK_ID+'_'+spect).style.display='none';
								eval('document.all.is_error'+get_product.STOCK_ID+'_'+spect).style.display='';}
								if(document.getElementById('control_amount'+get_product.STOCK_ID+'_'+spect).value < document.getElementById('amount'+get_product.STOCK_ID+'_'+spect).value)
									eval('document.all.is_ok'+get_product.STOCK_ID+'_'+spect).style.display='none';
				document.all.add_other_barcod.value='';
				/*document.all.del_other_barcod.value='';*/
				document.all.changed_stock_id.value = get_product.STOCK_ID;
				eval('row'+get_product.STOCK_ID+'_'+spect).style.background='FFCCCC';
				}	
			}
		else
		{
			/*var palet_sql = "SELECT EPR.STOCK_ID, EPR.SPECT_MAIN_ID, EPR.AMOUNT, S.BARCOD FROM EZGI_PACKING AS E INNER JOIN EZGI_PACKING_ROW AS EPR ON E.PACKING_ID = EPR.PACKING_ID INNER JOIN STOCKS AS S ON EPR.STOCK_ID = S.STOCK_ID WHERE E.BARCODE = '"+barcode+"'";*/
			/*var get_palet = wrk_query(palet_sql,'dsn3');*/
			
			var listParam = barcode;
			var get_palet = wrk_safe_query('get_packing_content_barcode_ezgi','dsn3',0,listParam);
			
			if(get_palet.recordcount != 0)
			{
				for(var xx=0;xx<get_palet.recordcount;xx++)
				{
					st_id = get_palet.STOCK_ID[xx];
					ms_id = get_palet.SPECT_MAIN_ID[xx];
					amnt = get_palet.AMOUNT[xx];
					brcd = get_palet.BARCOD[xx];
					if(document.getElementById('control_amount'+st_id+'_'+ms_id)==undefined)
					{
						alert('Palet İçindeki '+brcd+''+ms_id+'<cf_get_lang dictionary_id='347.Ürün Barkodu Hatalı'>');
						palet_back(xx,barcode);
					}
					else
					{
						if((document.getElementById('control_amount'+st_id+'_'+ms_id).value*1)-(amnt*-1) > (document.getElementById('amount'+st_id+'_'+ms_id).value*1))
						{
							alert(document.getElementById('PRODUCT_NAME'+st_id+'_'+ms_id).value+' ('+brcd+''+ms_id+') <cf_get_lang dictionary_id='379.Fazla Çıkış'>');
							palet_back(xx,barcode);
							return false;
						}
						else
						{
							document.getElementById('control_amount'+st_id+'_'+ms_id).value = (document.getElementById('control_amount'+st_id+'_'+ms_id).value*1)+(amnt*1);
							document.all.total_control_amount.value=(document.all.total_control_amount.value*1)+(amnt*1);
						}
						if(document.getElementById('control_amount'+st_id+'_'+ms_id).value == document.getElementById('amount'+st_id+'_'+ms_id).value)
							document.getElementById('row'+st_id+'_'+ms_id).style.display='none';
					}
				}
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcod').focus();
			}
			else
			{
				alert('<cf_get_lang dictionary_id='381.Kayıtlı Barkod Yok!'>')
			}
		}
	}
	function palet_back(xxl,barcode)
	{
		/*var palet_back_sql = "SELECT EPR.STOCK_ID, EPR.SPECT_MAIN_ID, EPR.AMOUNT, S.BARCOD FROM EZGI_PACKING AS E INNER JOIN EZGI_PACKING_ROW AS EPR ON E.PACKING_ID = EPR.PACKING_ID INNER JOIN STOCKS AS S ON EPR.STOCK_ID = S.STOCK_ID WHERE E.BARCODE = '"+barcode+"'";*/
		/*var get_back_palet = wrk_query(palet_back_sql,'dsn3');*/
		
		var listParam = barcode;
		var get_back_palet = wrk_safe_query('get_packing_content_barcode_ezgi','dsn3',0,listParam);
		
		for(var xxx=0;xxx<xxl;xxx++)
		{
			st_id = get_back_palet.STOCK_ID[xxx];
			ms_id = get_back_palet.SPECT_MAIN_ID[xxx];
			amnt = get_back_palet.AMOUNT[xxx];
			brcd = get_back_palet.BARCOD[xxx];
			document.getElementById('control_amount'+st_id+'_'+ms_id).value = (document.getElementById('control_amount'+st_id+'_'+ms_id).value*1)-(amnt*1);
			if(document.getElementById('control_amount'+st_id+'_'+ms_id).value == document.getElementById('amount'+st_id+'_'+ms_id).value)
				{eval('document.all.is_ok'+st_id+'_'+ms_id).style.display='';
			eval('document.all.is_error'+st_id+'_'+ms_id).style.display='none';}	
			if(document.getElementById('control_amount'+st_id+'_'+ms_id).value > document.getElementById('amount'+st_id+'_'+ms_id).value)
				{eval('document.all.is_ok'+st_id+'_'+ms_id).style.display='none';
			eval('document.all.is_error'+st_id+'_'+ms_id).style.display='';}
			if(document.getElementById('control_amount'+st_id+'_'+ms_id).value < document.getElementById('amount'+st_id+'_'+ms_id).value)
				eval('document.all.is_ok'+st_id+'_'+ms_id).style.display='none';
			document.all.total_control_amount.value=(document.all.total_control_amount.value*1)+(amnt*-1);
		}
		document.getElementById('add_other_barcod').value = '';
		document.getElementById('add_other_barcod').focus();
		return false;	

	}
	function kontrol()
	{
		document.add_package.submit();
	}
	function cik()
	{
		window.location ="<cfoutput>#request.self#?fuseaction=pda.list_shipping</cfoutput>";
	}
</script>