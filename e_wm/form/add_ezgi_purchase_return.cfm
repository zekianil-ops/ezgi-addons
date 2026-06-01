<!---
    File: add_ezgi_purchase_return.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description: Alım İade İşlemi
--->
<cfparam name="attributes.anamenu" default="1">
<cfparam name="attributes.document_number" default="">
<cfset default_process_type = 78>
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
<cfif isdefined('attributes.is_form_submitted') and len(attributes.document_number)>
	<cfquery name="get_ship" datasource="#dsn2#">
      	SELECT
        	SHIP_ID       
		FROM            
         	SHIP
		WHERE        
        	SHIP_NUMBER = '#attributes.document_number#' AND
            SHIP_TYPE = 78
	</cfquery>
    <cfif not get_ship.recordcount>
    	<script type="text/javascript">
            alert("Girdiğiniz Belge No Bulunamdı!");
            window.location ="<cfoutput>#request.self#?fuseaction=stock.add_ezgi_purchase_return</cfoutput>";
        </script>
    	<cfabort>
    </cfif>
    <cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn3#">
                SELECT
                    SUM(PAKET_SAYISI) AS PAKETSAYISI,
                    PAKET_ID AS STOCK_ID, 
                    BARCOD, 
                    STOCK_CODE, 
                    PRODUCT_NAME, 
                    SHIP_ID,
                    SHIP_TYPE,
                    SPECT_MAIN_ID
                FROM
                    (
                    	SELECT   
                        	SUM(SR.AMOUNT * EPS.PAKET_SAYISI) AS PAKET_SAYISI,     
                        	EPS.PAKET_ID, 
                            S.BARCOD, 
                            S.STOCK_CODE, 
                            S.PRODUCT_NAME, 
                            0 AS SPECT_MAIN_ID, 
                            SH.SHIP_ID,
                            SH.SHIP_TYPE
						FROM            
                        	#dsn2_alias#.SHIP_ROW AS SR WITH (NOLOCK) INNER JOIN
                       		STOCKS AS S WITH (NOLOCK) INNER JOIN
                       		EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON SR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                       		STOCKS AS S1 WITH (NOLOCK) ON SR.STOCK_ID = S1.STOCK_ID INNER JOIN
                        	#dsn2_alias#.SHIP AS SH WITH (NOLOCK) ON SR.SHIP_ID = SH.SHIP_ID
						WHERE        
                        	ISNULL(S1.IS_PROTOTYPE, 0) = 0 AND 
                            SH.SHIP_ID = #get_ship.SHIP_ID#
                      	GROUP BY 
                        	EPS.PAKET_ID, 
                            S.BARCOD, 
                            S.STOCK_CODE, 
                            S.PRODUCT_NAME, 
                            SH.SHIP_ID,
                            SH.SHIP_TYPE
                      	UNION ALL
                        SELECT  
                        	SUM(SR.AMOUNT * EPS.PAKET_SAYISI) AS PAKET_SAYISI,      
                        	EPS.PAKET_ID, 
                            S.BARCOD, 
                            S.STOCK_CODE, 
                            S.PRODUCT_NAME, 
                            ISNULL(SP.SPECT_MAIN_ID,0) AS SPECT_MAIN_ID, 
                            SH.SHIP_ID,
                            SH.SHIP_TYPE
						FROM            
                        	#dsn2_alias#.SHIP_ROW AS SR WITH (NOLOCK) INNER JOIN
                         	STOCKS AS S1 WITH (NOLOCK) ON SR.STOCK_ID = S1.STOCK_ID INNER JOIN
                         	#dsn2_alias#.SHIP AS SH WITH (NOLOCK) ON SR.SHIP_ID = SH.SHIP_ID INNER JOIN
                         	SPECTS AS SP WITH (NOLOCK) ON SR.SPECT_VAR_ID = SP.SPECT_VAR_ID INNER JOIN
                         	STOCKS AS S WITH (NOLOCK) INNER JOIN
                         	EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID
						WHERE        
                        	ISNULL(S1.IS_PROTOTYPE, 0) = 1 AND 
                            SH.SHIP_ID = #get_ship.SHIP_ID#
                    	GROUP BY 
                        	EPS.PAKET_ID, 
                            S.BARCOD, 
                            S.STOCK_CODE, 
                            S.PRODUCT_NAME,
                            SP.SPECT_MAIN_ID,
                            SH.SHIP_ID,
                            SH.SHIP_TYPE
                    ) AS TBL1
              	GROUP BY
                	PAKET_ID, 
                    BARCOD, 
                    STOCK_CODE, 
                    PRODUCT_NAME, 
                    SHIP_ID,
                    SHIP_TYPE,
                    SPECT_MAIN_ID
            	ORDER BY
                    PRODUCT_NAME
    </cfquery>
	<cfif GET_SHIP_PACKAGE_LIST.recordcount>  
    	<cfquery name="get_depo" datasource="#dsn2#">
        	SELECT       
             	E.DEPO, 
                E.DEPO_NAME
			FROM            
            	SHIP AS SH INNER JOIN
                #dsn3_alias#.EZGI_WM_DEPARTMENTS AS E ON SH.DELIVER_STORE_ID = E.DEPARTMENT_ID AND SH.LOCATION = E.LOCATION_ID
			WHERE        
            	SH.SHIP_ID = #get_ship.SHIP_ID#
        </cfquery>  
        <cfquery name="get_detail_package_list" datasource="#DSN3#">
        	SELECT        
            	SG.STOCK_ID, 
                SG.SERIAL_NO, 
                SG.SPECT_ID AS SPECT_MAIN_ID,
                S.PRODUCT_NAME
			FROM            
            	SERVICE_GUARANTY_NEW AS SG INNER JOIN
                STOCKS AS S ON SG.STOCK_ID = S.STOCK_ID
			WHERE        
            	SG.PROCESS_CAT = #GET_SHIP_PACKAGE_LIST.SHIP_TYPE# AND 
                SG.PROCESS_ID = #GET_SHIP_PACKAGE_LIST.SHIP_ID#
        </cfquery>
        <cfquery name="get_total_control" dbtype="query">
            SELECT COUNT(*) AS CONTROL_AMOUNT FROM get_detail_package_list
        </cfquery>
        <cfquery name="get_total_package" dbtype="query">
            SELECT sum(PAKETSAYISI) PAKETSAYISI FROM GET_SHIP_PACKAGE_LIST
        </cfquery>
    
        <cfif not len(get_total_control.CONTROL_AMOUNT)>
            <cfset get_total_control.CONTROL_AMOUNT = 0 >
        </cfif>
        <cfquery name="get_detail_package_group" dbtype="query">
            SELECT
                SPECT_MAIN_ID,
                STOCK_ID,
                COUNT(*) AS CONTROL_AMOUNT
            FROM
                get_detail_package_list
            GROUP BY
                SPECT_MAIN_ID,
                STOCK_ID	 	
        </cfquery>
        <cfoutput query="get_detail_package_group">
            <cfset 'control_amount#STOCK_ID#_#SPECT_MAIN_ID#' = CONTROL_AMOUNT>
        </cfoutput>
    <cfelse>
    	<cfset GET_SHIP_PACKAGE_LIST.recordcount = 0>
    </cfif>
<cfelse>
	<cfset GET_SHIP_PACKAGE_LIST.recordcount = 0>
</cfif>

<cfsavecontent variable="title_"><cf_get_lang dictionary_id='45510.Mal Alım İade İrsaliyesi'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cfform name="add_ezgi_purchase_return" id="add_ezgi_purchase_return" action="" method="post">
            <cf_box>
                <input type="hidden" name="is_form_submitted" value="1" />
                <cfif isdefined('attributes.is_form_submitted') and len(attributes.document_number)>
                    <cfinput name="ship_id" type="hidden" value="#GET_SHIP_PACKAGE_LIST.SHIP_ID#">
                    <cfinput name="ship_type" type="hidden" value="#GET_SHIP_PACKAGE_LIST.SHIP_TYPE#">
                    <cfinput name="ship_number" type="hidden" value="#attributes.document_number#">
                </cfif>
                <cf_basket_form id="add_ezgi_purchase_return">
                    <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
                                    <cfif not isdefined('attributes.is_form_submitted')>
                                        <div class="col col-12"  id="zero_area" >
                                            <div class="col col-12">
                                                <div class="col col-3">
                                                    <label><cf_get_lang dictionary_id='57880.Belge No'></label>
                                                </div>
                                                <div class="col col-8">
                                                    <div class="form-group" id="item-sevkiyat_raf">
                                                       	<input id="document_number" name="document_number" type="text" value=""> 
                                                    </div>
                                                </div>
                                    
                                                <div class="col col-1">
                                                    <div class="form-group" id="item-sevkiyat">
                                                    <input id="shipment_area_confirm" name="shipment_area_confirm" value="<cf_get_lang dictionary_id="58693.Seç">" type="button" onClick="shipment_area();" />
                                                    </div>
                                                </div>
                                                
                                            </div>
                                        </div>
                                    <cfelse>
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
                                                    <label><cf_get_lang dictionary_id='1316.Sevkiyat Alanı'></label>
                                                </div>
                                                <div class="col col-9">
                                                    <div class="form-group" id="item-giris">
                                                        <cfinput type="text" name="txt_department_out_name" id="txt_department_out_name" value="#get_depo.DEPO_NAME#">
                                                        <cfinput type="hidden" name="txt_department_out" id="txt_department_out" value="#get_depo.DEPO#">
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col col-12" id="fourth_area">
                                            <div class="col col-12">
                                                <div class="col col-3">
                                                    <label><cf_get_lang dictionary_id='45363.Kontrol Edilen Miktar'></label>
                                                </div>
                                                <cfoutput>
                                                <div class="col col-3">
                                                    <div class="form-group" id="item-serial_control">
                                                        <input type="text" name="total_control_amount" readonly="readonly" class="box" style="width:25px;text-align:right;font-weight:bold;color:FF0000;" id="total_control_amount" value="#get_total_control.CONTROL_AMOUNT#" />
                                                    </div>
                                                </div>
                                                <div class="col col-6">
                                                    <div class="form-group" id="item-serial_controled">
                                                        <input type="text" name="total_paket_sayisi" readonly="readonly" class="box" style="width:25px;text-align:right;font-weight:bold;color:FF0000;" id="total_paket_sayisi" value="#get_total_package.PAKETSAYISI#" />
                                                    </div>
                                                </div>
                                                </cfoutput>
                                            </div>
                                        </div>
                                 	</cfif>
                                </cf_box_elements>
                                <cf_box_footer>
                                    <div class="col col-12">
                                        <div class="col col-6" style="text-align:right">
                                           </div>
                                        <div class="col col-6" style="text-align:right;display:none" id="onay_div">
                                            <input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" onClick="kontrol_kayit();" />
                                        </div>
                                    </div>
                                </cf_box_footer>
                            </div>
                        </div>
                    </div>
                </cf_basket_form>
            </cf_box>
         	<cfsavecontent variable="sekme1"><cf_get_lang dictionary_id='45510.Mal Alım İade İrsaliyesi'></cfsavecontent>
            <cfsavecontent variable="sekme2"><cf_get_lang dictionary_id="57718.Seri No lar"></cfsavecontent>
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
                                        <cfsavecontent variable="title"><cf_get_lang dictionary_id='57880.Belge No'> : <cfoutput>#attributes.document_number#</cfoutput></cfsavecontent>
                                        <cf_box title="#title#">
                                            <cf_grid_list>
                                                <thead>
                                                    <tr>
                                                        <th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                        <th style="width:100%"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                                        <th style="width:25px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                                        <th style="width:20px"><cf_get_lang dictionary_id='45358.Kontrol'></th>
                                                        <th style="width:120px">&nbsp;&nbsp;&nbsp;</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <cfif GET_SHIP_PACKAGE_LIST.recordcount>
                                                        <cfoutput query="GET_SHIP_PACKAGE_LIST">
                                                            <cfif isdefined('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')>
                                                                <cfset 'control_amount#currentrow#' = Evaluate('control_amount#STOCK_ID#_#SPECT_MAIN_ID#')>
                                                            <cfelse>
                                                                <cfset 'control_amount#currentrow#' = ''>
                                                            </cfif>
                                                            <cfinput type="hidden" name="row_control_#currentrow#" id="row_control_#currentrow#" value="#STOCK_ID#_#SPECT_MAIN_ID#" >
                                                            <tr id="row#currentrow#" height="20">
                                                                <td style="text-align:right">#currentrow#</td>
                                                                <td>#product_name#<cfif SPECT_MAIN_ID gt 0><font color="red"> - #SPECT_MAIN_ID#</font></cfif></td> 
                                                                 <input type="hidden" id="PRODUCT_NAME#currentrow#" name="PRODUCT_NAME#currentrow#" value="#PRODUCT_NAME#">
                                                                <td style="text-align:right">
                                                                    <input type="text" name="amount#currentrow#" id="amount#currentrow#" value="#PAKETSAYISI#" readonly="yes" style="width:25px;text-align:right;">
                                                                </td>
                                                                <td style="text-align:right">
                                                                    <input type="text" id="control_amount#currentrow#" name="control_amount#currentrow#" value="<cfif isdefined('control_amount#currentrow#')>#Evaluate('control_amount#currentrow#')#</cfif>" class="box"  style="width:25px;text-align:right;color:FF0000;">
                                                                </td>
                                                                <td align="center" valign="middle">      
                                                                    <cfif len(Evaluate('control_amount#currentrow#')) and Evaluate('control_amount#currentrow#') eq PAKETSAYISI>
                                                                        <img id="is_durum#currentrow#" src="images\c_ok.gif">
                                                                    <cfelseif len(Evaluate('control_amount#currentrow#')) and Evaluate('control_amount#currentrow#') neq PAKETSAYISI>
                                                                        <img id="is_durum#currentrow#" src="images\warning.gif">
                                                                    </cfif>
                                                                </td>
                                                            </tr>
                                                            <!-- sil -->
                                                            <tr id="order_row#currentrow#" class="table_detail">
                                                                <td colspan="6">
                                                                    <div align="left" id="DISPLAY_ORDER_STOCK_INFO#currentrow#"></div>
                                                                </td>
                                                            </tr>
                                                            <!-- sil -->
                                                        </cfoutput>
                                                        <input type="hidden" name="changed_stock_id" value=""><!--- Bu hidden alan kontrol yapıldıkça kontrol yapılan satırı renklendirmek için kullanılıyor. --->
                                                    </cfif>
                                                </tbody>
                                            </cf_grid_list>
                                        </cf_box>
                                    </div>
                                    <div id="icerik" class="content row">
                                        <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
                                            <cf_grid_list>
                                                <thead>
                                                    <tr>
                                                        <th style="width:20px"></th>
                                                        <th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                        <th><cf_get_lang dictionary_id='57637.Seri No'></th>
                                                        <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                                    </tr>
                                                </thead>
                                                
                                                <tbody name="table2" id="table2">
                                                	<cfif GET_SHIP_PACKAGE_LIST.recordcount>
                                                    	<cfinput type="hidden" id="row_count_content" name="row_count_content" value="#get_detail_package_list.recordcount#">
														<cfif get_detail_package_list.recordcount>
                                                            <cfoutput query="get_detail_package_list">
                                                                <tr id="frm_row#currentrow#" height="20">
                                                                    <td style="text-align:center">
                                                                        <a onclick="sil(#currentrow#);"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
                                                                    </td>
                                                                    <td style="text-align:left">
                                                                        <input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1" >
                                                                        <input name="STOCK_ID#currentrow#" id="STOCK_ID#currentrow#" type="hidden" value="#STOCK_ID#">
                                                                        <input name="SPECT_MAIN_ID#currentrow#" id="SPECT_MAIN_ID#currentrow#" type="hidden" value="#SPECT_MAIN_ID#">
                                                                         </td>
                                                                    <td style="text-align:left"><input name="SERIAL#currentrow#" id="SERIAL#currentrow#" type="text" value="#SERIAL_NO#" style="width:70px"></td>
                                                                    <td style="text-align:left"><input name="PRODUCT_NAME#currentrow#" id="PRODUCT_NAME#currentrow#" type="text" value="#PRODUCT_NAME#"></td>
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
        </cfform>
    </div>
    <div id="serial_div"></div>
    <script language="javascript" type="text/javascript">
		<cfif not isdefined('attributes.is_form_submitted')>
			document.getElementById('document_number').focus();
		<cfelse>
       	 	document.getElementById('add_other_barcod').focus();
		</cfif>
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
            row_count_sevk = <cfoutput>#GET_SHIP_PACKAGE_LIST.recordcount#</cfoutput>;
            row_count_content = document.getElementById('row_count_content').value;
			depo = document.getElementById('txt_department_out').value;
			/*var new_sql = "SELECT EPS.STOCK_ID, EPS.PRODUCT_PLACE_ID, EPS.DEPO, ISNULL(EPS.IS_PROTOTYPE, 0) AS IS_PROTOTYPE, EPS.SHELF_CODE, EPS.SPECT_ID, EPS.PRODUCT_NAME, EPS.SERIAL_NO FROM EZGI_WM_SERIAL_NO_LAST_STATUS AS EPS INNER JOIN EZGI_WM_IS_SERIAL_NO_LIVE AS EVL ON EPS.SERIAL_NO = EVL.SERIAL_NO WHERE EPS.DEPO = '"+depo+"' AND EPS.SERIAL_NO = '"+barcode+"'";*/
            /*var get_package = wrk_query(new_sql,'dsn3');*/
			
			var listParam = depo + "*" + barcode;
			var get_package = wrk_safe_query('get_serial_for_return_depocode_serialno_ezgi','dsn3',0,listParam);
			
			
            if (get_package.STOCK_ID == undefined) /*Palet Bulunamadıysa*/
            {
                alert('Seri Nolu Ürün Bulunamadı !');
                document.getElementById('add_other_barcod').value = '';
                document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
                return false;
            }
            else /*Paket Bulunduysa*/
            {	
                if(get_package.IS_PROTOTYPE >0)
                    spect=get_package.SPECT_ID;
                else
                    spect=0;	
                    
                stockid=get_package.STOCK_ID;
                productname=get_package.PRODUCT_NAME;
                prototype=get_package.IS_PROTOTYPE;
                from_depo=get_package.DEPO;
                buldum=0;
                for(i=1;i<=row_count_sevk;i++)
                {
                    satir_spect = document.getElementById('row_control_'+i).value;
                    seri_spect = stockid+'_'+spect;
                    if(satir_spect==seri_spect)
                        buldum=i;
                }
                for(i=1;i<=row_count_content;i++)
                {
                    if(document.getElementById('SERIAL'+i).value==barcode)
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
                    if(document.getElementById('control_amount'+buldum)==undefined)
                    {
                        alert('<cf_get_lang dictionary_id='347.Ürün Barkodu Hatalı'>')
                        document.getElementById('add_other_barcod').value = '';
                        document.getElementById('add_other_barcod').focus();
                        return false;
                    }
                    else
                    {
                        if((document.getElementById('control_amount'+buldum).value*1)-(1*-1) > (document.getElementById('amount'+buldum).value*1))
                            alert(document.getElementById('PRODUCT_NAME'+buldum).value+' <cf_get_lang dictionary_id='379.Fazla Çıkış'>');
                        else
                        {
                            document.getElementById('control_amount'+buldum).value = (document.getElementById('control_amount'+buldum).value*1)+(1*1);
                            document.all.total_control_amount.value=(document.all.total_control_amount.value*1)+(1*1);
                            add_row(barcode,stockid,spect,productname,prototype);
                        }
                        if(document.getElementById('control_amount'+buldum).value == document.getElementById('amount'+buldum).value)
                            document.getElementById('row'+buldum).style.display='none';
                        document.getElementById('add_other_barcod').value = '';
                        document.getElementById('add_other_barcod').focus();
                    }
                }
            }
        }
        function add_row(barcode,stockid,spect,productname,prototype)
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
                newCell.innerHTML = '<input type="hidden" name="row_kontrol'+row_count_content+'" id="row_kontrol'+row_count_content+'" value="1"><input name="STOCK_ID'+row_count_content+'" id="STOCK_ID'+row_count_content+'" type="hidden" value="'+stockid+'"><input name="SPECT_MAIN_ID'+row_count_content+'" id="SPECT_MAIN_ID'+row_count_content+'" type="hidden" value="'+spect+'"><input name="row_number'+row_count_content+'" type="text" value="'+row_count_content+'"text-align:right">';
                
                newCell = newRow.insertCell();
                newCell.innerHTML = '<input name="SERIAL'+row_count_content+'" id="SERIAL'+row_count_content+'" type="text" value="'+barcode+'">';
                
                newCell = newRow.insertCell();
                newCell.innerHTML = '<input name="PRODUCT_NAME'+row_count_content+'" id="PRODUCT_NAME'+row_count_content+'" type="text" value="'+productname+'">';
				
				document.getElementById('onay_div').style.display='';
                
            }
        }
        function sil(sy)
		{
			row_count_sevk = <cfoutput>#GET_SHIP_PACKAGE_LIST.recordcount#</cfoutput>;
			barcode = document.getElementById('SERIAL'+sy).value;
			spectmainid = document.getElementById('SPECT_MAIN_ID'+sy).value;
			stockid = document.getElementById('STOCK_ID'+sy).value;
			amount = 1;
			sor=confirm(barcode+' Borkodlu Ürünü Sevkiyattan Çıkarıyorum.')
			if(sor==true)
			{
				buldum=0;
				document.getElementById('frm_row'+sy).style.display='none';
				document.getElementById('row_kontrol'+sy).value = 0;
				for(i=1;i<=row_count_sevk;i++)
				{
					satir_spect = document.getElementById('row_control_'+i).value;
					seri_spect = stockid+'_'+spectmainid;
					if(satir_spect==seri_spect)
						buldum=i;
				}
				if(buldum==0)
				{
					alert('Sorun Var. !');
				}
				else
				{
					document.getElementById('onay_div').style.display='';
					document.getElementById('control_amount'+buldum).value = (document.getElementById('control_amount'+buldum).value*1)-(amount*1);
					document.getElementById('row'+buldum).style.display='';
					document.getElementById('total_control_amount').value = (document.getElementById('total_control_amount').value*1)-(amount*1);
				}
			}
		}
        function shipment_area()
        {
			if(document.getElementById('document_number').value=='')
			{
				alert('Belge No Girmelisiniz');
				return false;
			}
			else
			{
				window.location ="<cfoutput>#request.self#</cfoutput>?fuseaction=stock.add_ezgi_purchase_return&is_form_submitted=1&document_number="+document.getElementById('document_number').value;
			}
        }
        function kontrol_kayit()
        {
			document.getElementById('onay').disabled = true;
			sor=confirm('Kayit Etmek Istiyor musunuz?');
			if (sor == true)
			{
				document.getElementById("add_ezgi_purchase_return").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=stock.emptypopup_add_ezgi_purchase_return";
				document.getElementById("add_ezgi_purchase_return").submit();
			}
			else
				return false;
			document.getElementById('onay').disabled = false;
        }
    </script>
