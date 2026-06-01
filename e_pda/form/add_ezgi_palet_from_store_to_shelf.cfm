<!---
    File: add_ezgi_palet_from_store_to_shelf.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description: Palet - Depodan Rafa
--->
<cfparam name="attributes.anamenu" default="1">
<cfset default_process_type = 113>
<cfquery name="get_default_departments" datasource="#dsn#">
	SELECT        
    	DEFAULT_MK_TO_RF_DEP, 
        DEFAULT_MK_TO_RF_LOC
	FROM            
    	EZGI_PDA_DEPARTMENT_DEFAULTS
	WHERE        
    	EPLOYEE_ID = #session.ep.userid#
</cfquery>
<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>
<cfset default_departments = '#get_default_departments.DEFAULT_MK_TO_RF_DEP#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
<cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
<cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,1)#">
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
		D.DEPARTMENT_ID IN (#default_departments#) AND
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID AND
		SL.STATUS = 1 AND
		D.BRANCH_ID = B.BRANCH_ID
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
<style type="text/css">
.boxtext {
	text-decoration: none;
	margin: 0px;
	padding: 0px;
	border-top-width: 0px;
	border-right-width: 0px;
	border-bottom-width: 0px;
	border-left-width: 0px;
}
.tablo {
	text-decoration: none;
	margin: 0px;
	padding: 0px;
	border-top-width: 1px;
	border-right-width: 0px;
	border-bottom-width: 1px;
	border-left-width: 0px;
	border-top-color: aec7f0;
	border-right-color: aec7f0;
	border-bottom-color: aec7f0;
	border-left-color: aec7f0;
}
</style>
<script language="javascript" type="text/javascript">
  var row_count = 0;
  var barcod = '';
  var paletid = '';
  var spectmainid = '';
  var stockcode = '';
  var amount = '';
  var ekle = 0;
  var cikar = 0;
  var islemtipi = 0;//0-ekle 1-çıkar
</script>
<cfform name="form_basket">
	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    	<cf_box scroll="0">
        	<cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
         	<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
        	<input type="hidden" name="kuponlist" value="" />
          	<input type="hidden" name="active_period" value="#session.ep.period_id#" />
            <cf_box_search>
            	<div class="col col-12">
                	<div class="col col-2">
                    	<cf_get_lang dictionary_id='57635.Miktar'>
                    </div>
                	<div class="col col-5">
                    	<cf_get_lang dictionary_id='57633.Barkod'>
                    </div>
                    <div class="col col-5">
                    	<cf_get_lang dictionary_id='36714.Raf'>


                    </div>
                    <!---<div class="col col-4">
                    	<cf_get_lang dictionary_id="30002.Raf Dağılım">
                    </div>--->
              	</div>
                <div class="col col-12">
                	<div class="col col-2">
                    	<div class="form-group">
                            <cfinput id="add_other_amount" name="add_other_amount" type="text" onfocus="islemtipi=0;" style=" text-align:right" maxlength="6" value="1"  readonly="yes"/>
                    	</div>
                    </div>
                	<div class="col col-5">
                    	<div class="form-group">
                            <cfinput id="add_other_barcod" name="add_other_barcod" type="text"  maxlength="20" value="" />
                        </div>
                    </div>
                    <div class="col col-5">
                    	<div class="form-group">
                            <cfinput id="add_other_shelf" name="add_other_shelf" type="text" onfocus="islemtipi=0;"  maxlength="20" value="" />
                        </div>
                    </div>
                    <!---<div class="col col-4">
                    	<div class="form-group" id="shelf_select_td" style="display:none">
                            <select name="shelf_select" id="shelf_select" style="width:70px;height:20px;text-align:center">
                                <option value=""><cf_get_lang dictionary_id='339.Ürün Rafları'></option>
                            </select>
                        </div>
                    </div>--->
               	</div>
             	<div class="col col-12">
					<div class="col col-6">
                    	<cf_get_lang dictionary_id='29428.Çıkış Depo'>
                    </div>
                    <div class="col col-6">
                    	<cf_get_lang dictionary_id='39412.Giriş Depo'>
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
          	</cf_box_search>
        </cf_box>
        <div id="basket_main_div">
        	<div class="row">
                <div class="col col-12 uniqueRow">
                    <cf_basket_form id="upd_connect" class="row">
                        <div id="tab-container" class="tabStandart margin-top-5">
                            <div id="tab-head">
                                <ul class="tabNav">
                                    <li class="<cfif attributes.anamenu eq 1>active</cfif>"><a id="href_urunler" href="#palet"><cfoutput>Palet</cfoutput></a></li>
                                    <li class="<cfif attributes.anamenu eq 2>active</cfif>"><a id="href_minfo" href="#icerik"><cfoutput>İçerik</cfoutput></a></li>
                                </ul>
                            </div>
                            <div id="tab-content" class="margin-top-10"> 
                                <div id="palet" class="content row">
                                	<cfsavecontent variable="title"><cf_get_lang dictionary_id="1285.Palet-Depodan Rafa"></cfsavecontent>
        							<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
                                    <cf_form_list>
                                        <thead>
                                            <tr>
                                                <th style="width:50%"><cf_get_lang dictionary_id='57633.Barkod'></th>
                                                <th style="width:50%"><cf_get_lang dictionary_id='36714.Raf'></th>
                                                <th style="width:20%"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                                
                                            </tr>
                                        </thead>
                                        <form name="product_row" id="product_row" method="post">
                                            <tbody name="table1" id="table1">
                                            </tbody>
                                        </form>
                                        <tfoot>
                                            <tr>	
                                                <td colspan="3">
                                                    <input type="hidden" id="department_in" name="department_in" value="" />
                                                    <input type="hidden" id="department_out" name="department_out" value="" />
                                                    <input type="hidden" id="row_count" name="row_count" value="0" />
                                                    <input type="hidden" id="palet_action_id" name="palet_action_id" value="" />
                                                    <input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" onClick="kontrol_kayit();" />
                                                </td>
                                            </tr>
                                        </tfoot>
                                    </cf_form_list>
                                    </cf_box>
                                </div>
                                <div id="icerik" class="content row">
									<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
                                        <cf_form_list>
                                            <thead>
                                                <tr>
                                                    <th style="width:20%"><cf_get_lang dictionary_id='57633.Barkod'></th>
                                                    <th style="width:100%"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                                    <th style="width:15%"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                                </tr>
                                            </thead>
                                            <input type="hidden" id="row_count_content" name="row_count_content" value="0" />
                                            <form name="product_row2" id="product_row2" method="post">
                                                <tbody name="table2" id="table2">
                                                </tbody>
                                            </form>
                                        </cf_form_list>
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
			if (document.getElementById('add_other_barcod').value.length == '' && document.getElementById('add_other_shelf').value.length >0)
			{
				alert('<cf_get_lang dictionary_id='340.Önce Ürün Barkodu Okutunuz'>');
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_shelf').value = '';
				document.getElementById('add_other_amount').value = 1;
				document.getElementById('add_other_barcod').focus();	
			
			}
			else
			{
				if (document.getElementById('add_other_barcod').value.length >0 && document.getElementById('add_other_shelf').value.length >0)	/*Barkod ve Raf Bilgisi Doluysa*/
					search_shelf(document.getElementById('add_other_shelf').value);
				else /*Sadece Barkod Bilgisi Doluysa*/
					get_stock(document.getElementById('add_other_barcod').value);
			}
		}
	}
	function get_stock(barcode) /*Ürün Kontrolü*/
    {
	 	barcod = ''; paletid = ''; stockcode = ''; spectmainid = ''; //ilk önce sıfırlıyoruz
	 	k_= 0;
		/*var new_sql = "SELECT TOP (1) EP.PACKING_ID,EP.BARCODE,EP.TYPE,EPR.AMOUNT,S.STOCK_ID, EPR.SPECT_MAIN_ID,EPR.LOT_NO FROM STOCKS AS S INNER JOIN EZGI_PACKING_ROW AS EPR ON S.STOCK_ID = EPR.STOCK_ID INNER JOIN EZGI_PACKING AS EP ON EPR.PACKING_ID = EP.PACKING_ID WHERE EP.BARCODE = '"+barcode+"'";*/ /*Paket var mı ve Dolu mu*/
		/*var get_product = wrk_query(new_sql,'dsn3');*/
		
		var listParam = barcode;
		varget_product = wrk_safe_query('get_packing_barcode_ezgi','dsn3',0,listParam);
		
		if (get_product.STOCK_ID == undefined) /*Palet Bulunamadıysa*/
		{
			ekle = 1;
			cikar = 1;
			k_=1;
			alert('Palet Bulunamdı veya İçi Boş');
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_shelf').value = '';
			document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		else /*Palet Bulunduysa*/
		{	
			paletid = get_product.PACKING_ID;
			barcode = get_product.BARCODE;
			paletkontrol(paletid);/*Paket Daha Önce Okutulmuş mu?*/
			if(get_product.TYPE == 1)
				stockcode = '<cf_get_lang dictionary_id='820.Standart Paket'>';
			else if(get_product.TYPE == 2)
				stockcode = '<cf_get_lang dictionary_id='821.Özel Paket'>';
			else if(get_product.TYPE == 3)
				stockcode = '<cf_get_lang dictionary_id='822.Lokasyon Paleti'>';
			document.getElementById('add_other_shelf').focus(); /*Rafa Odaklan*/
			<!---set_shelfs(paletid);--->
		}
	}
	function search_shelf(shelf_8)
	{
		shelf_code = document.getElementById('add_other_shelf').value;
		var giris_depo = document.all.txt_department_in.value;
		/*Raf Tipi ve Lokasyonu Aranıyor*/ 
		/*var shelf_sql = "SELECT SHELF_TYPE, PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE = '"+shelf_8+"'";
		var get_shelf = wrk_query(shelf_sql,'dsn3');*/
		
		var listParam = shelf_8;
		var get_shelf = wrk_safe_query('get_amount_shelf_amount_ezgi','dsn3',0,listParam);
		
		if(get_shelf.recordcount)
		{
			var giris_depo_s = get_shelf.STORE_ID.toString()+'-'+get_shelf.LOCATION_ID.toString();/* Form Giriş Depo ile Rafın Bulunduğu Lokasyon Eşitmi*/
			if(giris_depo != giris_depo_s)/* Form Giriş Depo ile Rafın Bulunduğu Lokasyon Eşit Değil ise*/
			{
					alert('<cf_get_lang dictionary_id='345.Seçtiğiniz Raf Giriş Lokasyonunda Yoktur'>.!');	
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_shelf').value = '';
					document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
					return false;
			}
			else /* Form Giriş Depo ile Rafın Bulunduğu Lokasyon Eşit ise*/
			{
				if (document.getElementById('add_other_barcod').value.length > 0)
				{
					if(get_shelf.SHELF_TYPE == 1) /*Adresli Raf İse*/ 
					{
						/*var palet_content_sql = "SELECT S.STOCK_ID, S.PRODUCT_NAME, EPR.SPECT_MAIN_ID, EPR.LOT_NO, EPR.SERIAL_NO, EPR.AMOUNT, S1.BARCOD FROM STOCKS AS S INNER JOIN EZGI_PACKING_ROW AS EPR ON S.STOCK_ID = EPR.STOCK_ID INNER JOIN EZGI_PACKING AS EP ON EPR.PACKING_ID = EP.PACKING_ID INNER JOIN STOCKS AS S1 ON EPR.STOCK_ID = S1.STOCK_ID WHERE EP.BARCODE = '"+document.getElementById('add_other_barcod').value+"'";*/ /*Paletin içerik Listesi Alınıyor*/
						/*var get_palet_content = wrk_query(palet_content_sql,'dsn3');*/
					
						var listParam = document.getElementById('add_other_barcod').value;
						var get_palet_content = wrk_safe_query('get_packing_content_barcode_adres_ezgi','dsn3',0,listParam);
					
						if(get_palet_content.recordcount) /*Palet İçeriği Varsa*/
						{
							for(var ii=0;ii<get_palet_content.recordcount;ii++) /*İçerik Dönüyor*/
							{
								/*var palet_stock_sql = "SELECT PP.SHELF_CODE,PPR.STOCK_ID FROM PRODUCT_PLACE_ROWS AS PPR INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID=PP.PRODUCT_PLACE_ID WHERE PP.SHELF_CODE ='"+shelf_code+"' AND PPR.STOCK_ID = "+get_palet_content.STOCK_ID[ii];*/
								/*var get_palet_stock = wrk_query(palet_stock_sql,'dsn3');*/
								
								var listParam =shelf_code + "*" + get_palet_content.STOCK_ID[ii];
								var get_palet_stock = wrk_safe_query('get_packing_content_shelf_stock_id_ezgi','dsn3',0,listParam);
								
								if(get_palet_stock.recordcount) /*Palet İçeriği Bu rafa Tanımlı İse*/
								{
								}
								else  /*Palet İçeriği Bu rafa Tanımlı Değil İse*/
								{	
									alert('Paket İçeriği Rafa Tanımlı Olmayan Ürün : '+get_palet_content.PRODUCT_NAME[ii]);
									document.getElementById('add_other_barcod').value = '';
									document.getElementById('add_other_shelf').value = '';
									document.getElementById('add_other_amount').value = 1;
									document.getElementById('add_other_barcod').focus();
									ekle = 1;
								}
							}
							if(ekle==0)
							{
								add_row(); /*palete Satır Ekle*/
							}
							for(var ii=0;ii<get_palet_content.recordcount;ii++) /*İçerik Dönüyor*/
							{
								content_spectmainid = get_palet_content.SPECT_MAIN_ID[ii];
								content_stockcode = get_palet_content.PRODUCT_NAME[ii];
								content_stockid = get_palet_content.STOCK_ID[ii];
								content_amount = get_palet_content.AMOUNT[ii];
								content_barcode = get_palet_content.BARCOD[ii];
								row_count_content = document.getElementById('row_count_content').value;
								ekle_content = 0;
								if(row_count_content >0) /*ilk Satırdan sonrası*/
								{
									for(j=1;j<=row_count_content;j++)
									{
										if(document.getElementById('content_stockid'+j).value == content_stockid && document.getElementById('content_spectmainid'+j).value == content_spectmainid)/*İçerik Satırlarında Ürün Bulunduysa*/
										{
											document.getElementById('content_amount'+j).value = document.getElementById('content_amount'+j).value - (-1 * content_amount);
											ekle_content=1;
										}
									}
								}
								if(ekle_content = 0) /*İçerik Satırlarında Ürün Eklenecekse*/
								{
									row_count_content++;
									document.getElementById('row_count_content').value = row_count_content;
									var newRow_content;
									var newCell_content;	
									newRow_content = document.getElementById("table2").insertRow(document.getElementById("table2").rows.length);
									newRow_content.setAttribute("name","frm_row_content" + row_count_content);
									newRow_content.setAttribute("id","frm_row_content" + row_count_content);		
									newRow_content.setAttribute("NAME","frm_row_content" + row_count_content);
									newRow_content.setAttribute("ID","frm_row_content" + row_count_content);		
											
									newCell_content = newRow_content.insertCell();
									newCell_content.innerHTML = '<input type="hidden" value="'+content_stockid+'" name="content_stockid'+row_count_content+'" id="content_stockid'+row_count_content+'" /><input type="hidden" value="'+content_spectmainid+'" name="content_spectmainid'+row_count_content+'" id="content_spectmainid'+row_count_content+'" /><input type="text" value="'+content_barcode+'" name="content_barcod'+row_count_content+'" id="content_barcod'+row_count_content+'" size="14" readonly="yes" style="border:none; height:20px" />';
/**/											
									newCell_content = newRow_content.insertCell();
									newCell_content.innerHTML = '<input type="text" value="'+content_stockcode+'" name="content_stockcode'+row_count_content+'" id="content_stockcode'+row_count_content+'" size="30" readonly="yes" style="border:none" />';
											
									newCell_content = newRow_content.insertCell();
									newCell_content.innerHTML = '<input type="text" style="text-align:right;border:none" value="'+content_amount+'" name="content_amount'+row_count_content+'" id="content_amount'+row_count_content+'" size="4" readonly="yes"/>';
								}
							}
						}
						else /*Palet İçeriği Boşsa*/
						{
							alert('Palet İçi Boş');	
							document.getElementById('add_other_barcod').value = '';
							document.getElementById('add_other_shelf').value = '';
							document.getElementById('add_other_amount').value = 1;
							document.getElementById('add_other_barcod').focus();
							return false;
						}
					}
					else /*Adres Serbest Raf İse*/
					{
						/*var palet_content_sql = "SELECT S.STOCK_ID, S.PRODUCT_NAME, EPR.SPECT_MAIN_ID, EPR.LOT_NO, EPR.SERIAL_NO, EPR.AMOUNT, S1.BARCOD FROM STOCKS AS S INNER JOIN EZGI_PACKING_ROW AS EPR ON S.STOCK_ID = EPR.STOCK_ID INNER JOIN EZGI_PACKING AS EP ON EPR.PACKING_ID = EP.PACKING_ID INNER JOIN STOCKS AS S1 ON EPR.STOCK_ID = S1.STOCK_ID WHERE EP.BARCODE = '"+document.getElementById('add_other_barcod').value+"'";*/ /*Paletin içerik Listesi Alınıyor*/
						/*var get_palet_content = wrk_query(palet_content_sql,'dsn3');*/
						
						var listParam = document.getElementById('add_other_barcod').value;
						var get_palet_content = wrk_safe_query('get_packing_content_barcode_adres_ezgi','dsn3',0,listParam);
						
						if(get_palet_content.recordcount) /*Palet İçeriği Varsa*/
						{
							if(ekle==0)
							{
								add_row();
							}
							for(var ii=0;ii<get_palet_content.recordcount;ii++) /*İçerik Dönüyor*/
							{
								content_spectmainid = get_palet_content.SPECT_MAIN_ID[ii];
								content_stockcode = get_palet_content.PRODUCT_NAME[ii];
								content_stockid = get_palet_content.STOCK_ID[ii];
								content_amount = get_palet_content.AMOUNT[ii];
								content_barcode = get_palet_content.BARCOD[ii];
								row_count_content = document.getElementById('row_count_content').value;
								ekle_content = 0;
								if(row_count_content >0) /*ilk Satırdan sonrası*/
								{
									for(j=1;j<=row_count_content;j++)
									{
										if(document.getElementById('content_stockid'+j).value == content_stockid && document.getElementById('content_spectmainid'+j).value == content_spectmainid)/*İçerik Satırlarında Ürün Bulunduysa*/
										{
											document.getElementById('content_amount'+j).value = document.getElementById('content_amount'+j).value - (-1 * content_amount);
											ekle_content=1;
										}
									}
								}
								if(ekle_content == 0) /*İçerik Satırlarında Ürün Eklenecekse*/
								{
									row_count_content++;
									document.getElementById('row_count_content').value = row_count_content;
									var newRow_content;
									var newCell_content;	
									newRow_content = document.getElementById("table2").insertRow(document.getElementById("table2").rows.length);
									newRow_content.setAttribute("name","frm_row_content" + row_count_content);
									newRow_content.setAttribute("id","frm_row_content" + row_count_content);		
									newRow_content.setAttribute("NAME","frm_row_content" + row_count_content);
									newRow_content.setAttribute("ID","frm_row_content" + row_count_content);		
												
									newCell_content = newRow_content.insertCell();
									newCell_content.innerHTML = '<input type="hidden" value="'+content_stockid+'" name="content_stockid'+row_count_content+'" id="content_stockid'+row_count_content+'" /><input type="hidden" value="'+content_spectmainid+'" name="content_spectmainid'+row_count_content+'" id="content_spectmainid'+row_count_content+'" /><input type="text" value="'+content_barcode+'" name="content_barcod'+row_count_content+'" id="content_barcod'+row_count_content+'" size="14" readonly="yes" style="border:none; height:20px" />';
												
									newCell_content = newRow_content.insertCell();
									newCell_content.innerHTML = '<input type="text" value="'+content_stockcode+'" name="content_stockcode'+row_count_content+'" id="content_stockcode'+row_count_content+'" size="30" readonly="yes" style="border:none" />';
												
									newCell_content = newRow_content.insertCell();
									newCell_content.innerHTML = '<input type="text" style="text-align:right;border:none" value="'+content_amount+'" name="content_amount'+row_count_content+'" id="content_amount'+row_count_content+'" size="4" readonly="yes"/>';
								}
							}
						}
						else /*Palet İçeriği Boşsa*/
						{
							alert('Palet İçi Boş');	
							document.getElementById('add_other_barcod').value = '';
							document.getElementById('add_other_shelf').value = '';
							document.getElementById('add_other_amount').value = 1;
							document.getElementById('add_other_barcod').focus();
							return false;
						}
					}
				}
				else /*Palet Barkodu Bulunamadı İse*/
				{
						alert('Palet Barkodu Hatalı');
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_shelf').value = '';
						document.getElementById('add_other_amount').value = 1;
						document.getElementById('add_other_barcod').focus();
						return false;
				}
			}
		}
		else
		{
			alert('<cf_get_lang dictionary_id='348.Seçtiğiniz Raf Hiç Tanımlanmamış'>!');
			document.getElementById('add_other_shelf').value = '';
			document.getElementById('add_other_shelf').focus();
		}
	}
	
	function add_row()
	{
		amount = document.getElementById('add_other_amount').value;
		barcode = document.getElementById('add_other_barcod').value;
		shelf_code = document.getElementById('add_other_shelf').value;
		if(amount == 0)
		{
			alert('<cf_get_lang dictionary_id='344.Miktar 0 dan Büyük Olmalıdır'>.');
			document.getElementById('add_other_amount').focus();
			return false;
		}
		if (ekle == 0)
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
			newCell.innerHTML = '<input type="hidden" value="'+paletid+'" name="paletid'+row_count+'" id="paletid'+row_count+'" /><input type="hidden" value="'+spectmainid+'" name="spectmainid'+row_count+'" id="spectmainid'+row_count+'" /><input type="text" value="'+barcode+'" name="barcod'+row_count+'" id="barcod'+row_count+'" size="13" class="boxtext" readonly="yes" />';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="text" value="'+shelf_code+'" name="shelf_code'+row_count+'" id="shelf_code'+row_count+'" size="12" class="boxtext" readonly="yes" style="text-align:right" />';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="text" style="text-align:right" value="'+amount+'" name="amount'+row_count+'" id="amount'+row_count+'" size="5" class="boxtext" readonly="yes"  style="text-align:" />';
				
		}
		else
		{
			 ekle = 0;
		}
		document.getElementById('add_other_barcod').value = '';
		document.getElementById('add_other_shelf').value = '';
		document.getElementById('add_other_amount').value = 1;
		document.getElementById('add_other_barcod').focus();
	}

	function include(arr, obj) 
	{
    	for(var i=0; i<arr.length; i++) 
		{
        	if (arr[i] == obj) return true;
    	}
	}
	
	function kontrol_kayit()
	{
		kayit = 1;
		row_count = document.getElementById('row_count').value;	
		if(row_count >0) /*ilk Satırdan sonrası*/
	  	{
			stock_control()
			if(kayit==1)
			{
				if(form_basket.txt_department_in.value == "")
				{
					alert('<cf_get_lang dictionary_id='57723.Önce Depo Seçmelisiniz'>.');
					return false;
				}
				else if(form_basket.txt_department_in.value.indexOf('-') == -1)
				{
					alert('<cf_get_lang dictionary_id='349.Lütfen giriş için doğru depo seçiniz'>.');
					return false;
				}
				else
				{
					document.getElementById('onay').disabled = true;
					actionidolustur();
					window.location.href='<cfoutput>#request.self#</cfoutput>?fuseaction=pda.add_ambar_fis&ambarfis=10&dep_in='+form_basket.txt_department_in.value+'&dep_out='+form_basket.txt_department_out.value+'&palet_action_id='+document.getElementById('palet_action_id').value+'&fis_tipi='+form_basket.fis_tipi.value+'&process_cat='+form_basket.process_cat_id.value;
				}
			}
		}
		else
		{
			alert('Sepette Kayıtlı Ürün Yok');
			return false;
		}
	}
	function stock_control()
	{	
		row_count_content = document.getElementById('row_count_content').value;	
		if(row_count_content > 0)
		{
			for(i=1;i<=row_count_content;i++) /*Satırlardaki paletler ve Bunlara Bağlı okutulan Miktarlar Toplanıyor*/
			{
				content_stockid = document.getElementById('content_stockid'+i).value; 
				content_spectmainid = document.getElementById('content_spectmainid'+i).value;
				content_amount = document.getElementById('content_amount'+i).value;
				content_barcod = document.getElementById('content_barcod'+i).value;
				content_stockcode = document.getElementById('content_stockcode'+i).value;
				
				if(content_spectmainid==0)
				{
				  	/*var stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL WHERE  DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID ="+content_stockid;*/
					var listParam = form_basket.txt_department_out.value + "*" + content_stockid;
					var get_real_stock = wrk_safe_query('get_depo_stock_stock_id_ezgi','dsn2',0,listParam);
				}
				else
				{
					/*var stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_SPECT_LOCATION_TOTAL WHERE  DEPO = '"+form_basket.txt_department_out.value+"' AND SPECT_MAIN_ID ="+content_spectmainid;*/
					var listParam = form_basket.txt_department_out.value + "*" + content_spectmainid;
					var get_real_stock = wrk_safe_query('get_depo_stock_spectmainid_ezgi','dsn2',0,listParam);
				}
				/*var get_real_stock = wrk_query(stock_sql,'dsn2');*/
				
				if (get_real_stock.PRODUCT_STOCK == undefined)
					get_real_stock.PRODUCT_STOCK = 0;
					
				if(get_real_stock.PRODUCT_STOCK <= 0 || get_real_stock.PRODUCT_STOCK*1 < content_amount*1)
				{
					if(content_spectmainid==0)
						alert(content_stockcode+" <cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='343.Çıkış Lokasyonundaki Stok Miktarı'> : "+get_real_stock.PRODUCT_STOCK);
					else
						alert(content_stockcode+" <cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='343.Çıkış Lokasyonundaki Stok Miktarı'> : "+get_real_stock.PRODUCT_STOCK+" - <cf_get_lang dictionary_id='57647.Spekt'> : "+content_spectmainid);
						
					document.getElementById('add_other_amount').focus();
					return false;
					kayit = 0;
				}
			}
		}
		else
		{
			alert('Palet İçiriğ Tamamen Boştur.');
		}
	}
	function paletkontrol(paletid)
	{
		row_count = document.getElementById('row_count').value;
		if(row_count >0) /*Daha Önce Okutulan Varsa*/
		{
			for(j=1;j<=row_count;j++)
			{
				if(document.getElementById('paletid'+j).value == paletid) /*Okutulan Paletler arasında Bu Palet Varmı*/
				{
					alert(document.getElementById('add_other_barcod').value+' Barkodlu Paleti Daha Önce Okutmuşsunuz');
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_shelf').value = '';
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').focus();
					return false;
				}
			}
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
				{
					document.getElementById('palet_action_id').value = document.getElementById('palet_action_id').value + ',';
				}
				document.getElementById('palet_action_id').value = document.getElementById('palet_action_id').value + i + '-';
				document.getElementById('palet_action_id').value = document.getElementById('palet_action_id').value + document.getElementById('paletid'+i).value + '-';
				document.getElementById('palet_action_id').value = document.getElementById('palet_action_id').value + document.getElementById('amount'+i).value + '-';
				document.getElementById('palet_action_id').value = document.getElementById('palet_action_id').value + document.getElementById('shelf_code'+i).value + '-';
				document.getElementById('palet_action_id').value = document.getElementById('palet_action_id').value + '0'+ '-';
				document.getElementById('palet_action_id').value = document.getElementById('palet_action_id').value + '0';
				j++;
		  	}
		  	document.getElementById('row_count').value = j;
	  	}
	}
</script>