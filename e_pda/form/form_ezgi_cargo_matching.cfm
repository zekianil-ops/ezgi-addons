<!---
    File: form_ezgi_cargo_matching.cfm
    Folder: Add_Ons\ezgi\e_pda\form
    Author: Ezgi Yazılım
    Date: 01/06/2024
    Description:
--->
<cfset default_process_type = 113>
<cfset product_barcode_list = ''>
<cfquery name="get_url" datasource="#dsn#">
	SELECT     
    	E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS ADI
	FROM         
    	WRK_SESSION AS W WITH (NOLOCK) INNER JOIN
     	EMPLOYEES AS E WITH (NOLOCK) ON W.USERID = E.EMPLOYEE_ID
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
	SELECT * FROM EZGI_SHIPPING_DEFAULTS WITH (NOLOCK)
</cfquery>
<cfif not len(get_defaults.EAN)>
	<script language="javascript">
		alert('Default Tanımları Giriniz');
		history.back();
	</script>
    <cfabort>
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

<cfparam name="attributes.add_other_amount" default="1">
<cfparam name="attributes.del_other_amount" default="1">
<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
        SELECT     
        	PAKET_SAYISI AS PAKETSAYISI, 
            PAKET_ID AS STOCK_ID, 
            BARCOD, 
            STOCK_CODE, 
            PRODUCT_NAME,
         	ISNULL((
             SELECT     
            	SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
         	FROM          
            	EZGI_SHIPPING_PACKAGE_LIST WITH (NOLOCK)
         	WHERE      
            	TYPE = 1 AND 
                STOCK_ID = TBL.PAKET_ID AND 
                SHIPPING_ID = TBL.SHIP_RESULT_ID
        	),0) AS CONTROL_AMOUNT
		FROM         
        	(
            SELECT
            	SUM(PAKET_SAYISI) AS PAKET_SAYISI,
                PAKET_ID, 
                BARCOD, 
                STOCK_CODE, 
                PRODUCT_NAME, 
                PRODUCT_TREE_AMOUNT, 
                SHIP_RESULT_ID
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
                    ESRR.ORDER_ROW_ID
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
                    S.PRODUCT_TREE_AMOUNT, 
                    ESR.SHIP_RESULT_ID,
                    ESRR.ORDER_ROW_ID,
                    ORR.ORDER_ROW_ID
             	) AS TBL1
          	GROUP BY
            	PAKET_ID, 
                BARCOD, 
                STOCK_CODE, 
                PRODUCT_NAME, 
                PRODUCT_TREE_AMOUNT, 
                SHIP_RESULT_ID
        	) AS TBL
</cfquery>
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
	<cfset 'control_amount#STOCK_ID#' = CONTROL_AMOUNT>
</cfoutput>
<cfset stock_id_list = ''>
<cfoutput query="GET_SHIP_PACKAGE_LIST">
	<cfset stock_id_list = ListAppend(stock_id_list,'#STOCK_ID#')>
</cfoutput>
<cfform name="add_package" method="post" action="">
	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
		<table cellpadding="1" cellspacing="1" align="left" class="color-border" width="100%">
  			<tr class="color-list">
				<td style="width:100%">
					<table cellpadding="2" cellspacing="1" width="99%">
                    	<tr class="color-list">
                        	<td colspan="4" style="width:100%">
                                <table class="color-border" style="width:100%">
                                    <tr class="color-list">
                                        <td style="width:20%;height:30px;vertical-align:middle; text-align:center; font-weight:bold;"><cf_get_lang dictionary_id='57635.Miktar'></td>
                                        <td style="width:20%;vertical-align:middle; text-align:center;">
                                            <input name="add_other_amount" type="text" readonly value="<cfoutput>#attributes.add_other_amount#</cfoutput>" onKeyup="return(FormatCurrency(this,event,0));" class="moneybox" style="width:100%; height:25px" >
                                        </td>
                                        <td style="width:20%;vertical-align:middle; text-align:center; font-weight:bold;" nowrap="nowrap"><cf_get_lang dictionary_id='44630.Ekle'></td>                     
                                        <td style="width:20%;vertical-align:middle; text-align:center;">
                                            <input name="add_other_barcod" id="add_other_barcod" type="text" value="" onKeyDown="if(event.keyCode == 13) {return add_product_to_barkod(this.value,add_other_amount.value,1);}" style="width:100%; height:25px">
                           				</td>
                                        <td style="width:20%;vertical-align:middle; text-align:center;">
                                        	<input type="button" value="<cfoutput><cf_get_lang dictionary_id='57462.Vazgeç'></cfoutput>" name="vazgec" onclick="if(confirm('<cf_get_lang dictionary_id='383.Kaydetmeden Çıkıyorsunuz!'>')) cik(); else return false;" /> 
                                        </td>
                                   	</tr>
                               	</table>
                           	</td>
                    	</tr>
					</table>
				</td>
			</tr>
      	</table>
  	</div>
	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">    
        <cfsavecontent variable="title"><b><cf_get_lang dictionary_id='382.Sevk Plan No'> :</b><cfoutput>#attributes.DELIVER_PAPER_NO#</cfoutput></cfsavecontent>
        <cf_box scroll="0">
            <cf_form_list>
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
                            <tr id="row#STOCK_ID#" height="20">
                                <td>#product_name#</td>        
                            	<input type="hidden" id="PRODUCT_NAME#STOCK_ID#" name="PRODUCT_NAME#STOCK_ID#" value="#PRODUCT_NAME#" class="box" style="width:100;">
                                <cfif PAKETSAYISI gt CONTROL_AMOUNT>
                             		<cfset product_barcode_list = listdeleteduplicates(ListAppend(product_barcode_list,ValueList(GET_SHIP_PACKAGE_LIST.BARCOD),','))>	
                                </cfif>
                                <td style="text-align:right">
                                    <input type="text" name="amount#STOCK_ID#" id="amount#STOCK_ID#" value="#PAKETSAYISI#" readonly="yes" class="box" style="width:30px;text-align:right;">
                                </td>
                                <td style="text-align:right">
                                    <input type="text" id="control_amount#STOCK_ID#" name="control_amount#STOCK_ID#" value="<cfif isdefined('control_amount#STOCK_ID#')>#Evaluate('control_amount#STOCK_ID#')#</cfif>" class="box"  style="width:30px;text-align:right;color:FF0000;">
                                </td>
                                <td align="center" valign="middle">      
                                    <img id="is_ok#STOCK_ID#" name="is_ok#STOCK_ID#"<cfif not isdefined('control_amount#STOCK_ID#') or (isdefined('control_amount#STOCK_ID#') and Evaluate('control_amount#STOCK_ID#') neq PAKETSAYISI)>style="display:none;"</cfif> align="center" src="images\c_ok.gif">
                                    <img id="warning_#STOCK_ID#" name="warning_#STOCK_ID#"<cfif not isdefined('control_amount#STOCK_ID#') or (isdefined('control_amount#STOCK_ID#') and Evaluate('control_amount#STOCK_ID#') eq PAKETSAYISI)>style="display:none;"</cfif> align="center" src="images\warning.gif">
                                    <img id="is_error#STOCK_ID#" name="is_error#STOCK_ID#"<cfif not isdefined('control_amount#STOCK_ID#') or (isdefined('control_amount#STOCK_ID#') and Evaluate('control_amount#STOCK_ID#') lte PAKETSAYISI)>style="display:none;"</cfif>align="center" src="images\closethin.gif">
                                </td>
                            </tr>
                        </cfoutput>
                        <input type="hidden" name="changed_stock_id" value=""><!--- Bu hidden alan kontrol yapıldıkça kontrol yapılan satırı renklendirmek için kullanılıyor. --->
                        <tr class="color-list">
                        	<cfoutput>
                            <td  align="right">
                                <!---<input type="button" value="<cfif not get_detail_package_list.recordcount>Kaydet<cfelse><cf_get_lang dictionary_id='57464.Güncelle'></cfif>" onClick="if(confirm('Kaydetmek İstediğinizden Eminmisiniz?')) kontrol(); else return false;">--->
                               
                            </td>
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
           	</cf_form_list>
     	</cf_box>
	</div>
    <div id="barcode_div"></div>
</cfform>
<script language="javascript">
	document.getElementById('add_other_barcod').focus();
	setTimeout("document.getElementById('add_other_barcod').select();",1000);	
	function add_product_to_barkod(barcode,amount,type)
	{	
		<cfoutput>
			var ship_id = #attributes.ship_id#;
			var is_type = #attributes.is_type#;
		</cfoutput>
		if(list_find('<cfoutput>#product_barcode_list#</cfoutput>',barcode,','))
		{
			var new_sql = "SELECT TOP 1 STOCK_ID FROM STOCKS_BARCODES WHERE BARCODE = '"+barcode+"'";
			var get_product = wrk_query(new_sql,'dsn1');
			if(document.getElementById('control_amount'+get_product.STOCK_ID)==undefined)
			{
				alert('<cf_get_lang dictionary_id='347.Ürün Barkodu Hatalı'>')	;
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcod').focus();
			}
			else
			{
				document.all.total_control_amount.value=(document.all.total_control_amount.value*1)+(amount*1);
				control_amount = (document.getElementById('control_amount'+get_product.STOCK_ID).value*1)+(amount*1);
				row_amount = document.getElementById('amount'+get_product.STOCK_ID).value;
				if(row_amount >= control_amount)
				{
					if(document.all.total_control_amount.value==<cfoutput>#get_total_control.PAKETSAYISI#</cfoutput>)
						stock_fis =1;
					else
						stock_fis =0;
				   	AjaxPageLoad('<cfoutput>#request.self#?fuseaction=pda.emptypopup_ezgi_cargo_matching&process_cat=#get_process_cat.process_cat_id#&SHIP_ID=#attributes.ship_id#&department_id=#attributes.department_id#&is_type=#attributes.is_type#</cfoutput>&control_amount='+control_amount+'&amount='+row_amount+'&stock_id='+get_product.STOCK_ID+'&stock_fis='+stock_fis,'barcode_div',1);
				<!---window.location ="<cfoutput>#request.self#</cfoutput>?fuseaction=pda.list_ezgi_cargo_matching";--->
				}
				else
				{
					alert('Ürün Fazla Okutuldu.');	
					
				}
			}
		}
		else
		{
			alert('<cf_get_lang dictionary_id='381.Kayıtlı Barkod Yok!'>')
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus();
		}
	}
	function cik()
	{
		window.location ="<cfoutput>#request.self#?fuseaction=pda.list_ezgi_cargo_matching</cfoutput>";
	}
</script>