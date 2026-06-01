<!---
    File: add_ambar_fis_2.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfset default_process_type = 113>
<cfif isdefined('attributes.param') and attributes.param eq 2>
	<cfquery name="get_default_departments" datasource="#dsn#">
        SELECT        
            DEFAULT_RF_TO_SV_DEP AS DEFAULT_MK_TO_RF_DEP, 
            DEFAULT_RF_TO_SV_LOC AS DEFAULT_MK_TO_RF_LOC
        FROM            
            EZGI_PDA_DEPARTMENT_DEFAULTS
        WHERE        
            EPLOYEE_ID = #session.ep.userid#
    </cfquery>
    <cfset default_departments = '#get_default_departments.DEFAULT_MK_TO_RF_DEP#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
    <cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,1)#">
    <cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
<cfelse>
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
    <cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,1)#">
    <cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
</cfif>

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
	background-color: #e6e6fe;
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
  	var stockid = '';
  	var spectmainid = 0;
  	var stockcode = '';
  	var amount = '';
  	var ekle = 0;
  	var cikar = 0;
  	var islemtipi = 0;//0-ekle 1-çıkar
  	var buton = 0;// <1-buton pasif, >0-buton aktif
</script>
<cfform name="form_basket">
	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    	<cf_box scroll="0">
          	<cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
          	<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
          	<input type="hidden" name="kuponlist" value="" />
          	<input type="hidden" name="active_period" value="#session.pda.period_id#" />
            <input type="hidden" name="anabarcode" id="anabarcode" value="" />
            <cfif isdefined('attributes.param')>
            	<cfinput id="param" type="hidden" name="param" value="#attributes.param#">
            </cfif>
            <cf_box_search>
            	<div class="col col-12">
                	<div class="col col-2">
                    	<cf_get_lang dictionary_id='57635.Miktar'>
                    </div>
                	<div class="col col-3">
                    	<cf_get_lang dictionary_id='57633.Barkod'>
                    </div>
                    <div class="col col-3">
                    	<cf_get_lang dictionary_id='36714.Raf'>
                    </div>
                    <div class="col col-4">
                    	<cf_get_lang dictionary_id="30002.Raf Dağılım">
                    </div>
              	</div>
                <div class="col col-12">
                	<div class="col col-2">
                    	<div class="form-group">
                            <cfinput id="add_other_amount" name="add_other_amount" type="text" onfocus="islemtipi=0;" style=" text-align:right" maxlength="6" value="1" />
                    	</div>
                    </div>
                	<div class="col col-3">
                    	<div class="form-group">
                            <cfinput id="add_other_barcod" name="add_other_barcod" type="text"  maxlength="20" value="" />
                        </div>
                    </div>
                    <div class="col col-3">
                    	<div class="form-group">
                            <cfinput id="add_other_shelf" name="add_other_shelf" type="text" onfocus="islemtipi=0;"  maxlength="20" value="" />
                        </div>
                    </div>
                    <div class="col col-4">
                    	<div class="form-group" id="shelf_select_td" style="display:none">
                            <select name="shelf_select" id="shelf_select" style="width:70px;height:20px;text-align:center">
                                <option value=""><cf_get_lang dictionary_id='339.Ürün Rafları'></option>
                            </select>
                        </div>
                    </div>
               	</div>
             	<div class="col col-12">
					<div class="col col-6">
                    	<cf_get_lang dictionary_id='29428.Çıkış Depo'>
                    </div>
                    <div class="col col-6">
                    	<cf_get_lang dictionary_id='339.Giriş Depo'>
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
        <cfsavecontent variable="title"><cf_get_lang dictionary_id="9.Ambardan Mal Kabule"></cfsavecontent>
        <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
            <cf_form_list>
                <thead>
                    <tr>
                        <th style="width:20%"><cf_get_lang dictionary_id='57633.Barkod'></th>
                        <th style="width:100%"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                        <th style="width:15%"><cf_get_lang dictionary_id='57635.Miktar'></th>
                        <th style="width:20%"><cf_get_lang dictionary_id='36714.Raf'></th>
                    </tr>
                </thead>
                <form name="product_row" id="product_row" method="post">
                    <tbody name="table1" id="table1">
                    </tbody>
                </form>
                <tfoot>
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
</cfform>
<script language="javascript" type="text/javascript">
	document.getElementById('add_other_barcod').focus();
	setTimeout("document.getElementById('add_other_barcod').select();",1000);	
	document.onkeydown = checkKeycode
	function checkKeycode(e) 
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
				if (document.getElementById('add_other_barcod').value.length >0 && document.getElementById('add_other_shelf').value.length >0)	
				search_shelf(document.getElementById('add_other_shelf').value);
				else
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
		document.getElementById('anabarcode').value=barcode;
	 	if (k_ == 0)
     	{
			
			/*var new_sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER,S.PRODUCT_NAME,S.IS_PROTOTYPE FROM STOCKS_BARCODES AS SB INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '"+barcode+"'";
			var get_product = wrk_query(new_sql,'dsn3');*/
			
			var listParam = barcode;
			var get_product = wrk_safe_query('get_product_ezgi','dsn3',0,listParam);
			
		 	if (get_product.STOCK_ID == undefined)
		 	{
				ekle = 1;
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
					barcode = get_product.PRODUCT_BARCOD;
					document.getElementById('add_other_shelf').focus();
					set_shelfs(stockid,spectmainid);
					buton_kontrol();
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
		if(spectmainid==0)
		{
			/*var shelf_sql="SELECT REAL_STOCK FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE SHELF_CODE = '"+document.getElementById('add_other_shelf').value+"' AND STOCK_ID = "+stockid+" AND REAL_STOCK > 0 ORDER BY REAL_STOCK DESC";*/
			var listParam = document.getElementById('add_other_shelf').value+ "*" +stockid;
			var get_shelf_amount = wrk_safe_query('get_shelf_stock_stock_id_ezgi','dsn2',0,listParam);
		}
		else
		{
			/*var shelf_sql="SELECT REAL_STOCK FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE SHELF_CODE = '"+document.getElementById('add_other_shelf').value+"' AND STOCK_ID = "+stockid+" AND SPECT_MAIN_ID = "+spectmainid+" AND REAL_STOCK > 0 ORDER BY REAL_STOCK DESC";*/
			var listParam = document.getElementById('add_other_shelf').value+ "*" +stockid+ "*" +spectmainid;
			var get_shelf_amount = wrk_safe_query('get_shelf_stock_spectmainid_ezgi','dsn2',0,listParam);
		}
		/*var get_shelf_amount = wrk_query(shelf_sql,'dsn2');*/
		control_amount=get_shelf_amount.REAL_STOCK;
		if(get_shelf_amount.recordcount)
		{
			if(row_count >0) /*ilk Satırdan sonrası*/
			{
				for(i=1;i<=row_count;i++)
				{
					if(document.getElementById('stockid'+i).value == stockid && document.getElementById('spectmainid'+i).value == spectmainid && document.getElementById('shelf_code'+i).value == shelf_code)
						control_amount=control_amount-document.getElementById('amount'+i).value;
				}
				control_amount=control_amount-document.getElementById('add_other_amount').value;
				if(control_amount<0)
				{
					ekle=1;
					alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='351.Çıkış Rafındaki Stok Miktarı'>: "+get_shelf_amount.REAL_STOCK);
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_shelf').value = '';
					document.getElementById('add_other_barcod').focus();
				}
			}
			else
			{
				control_amount=control_amount-document.getElementById('add_other_amount').value;
				if(control_amount<0)
				{
					ekle=1;
					alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='351.Çıkış Rafındaki Stok Miktarı'>: "+get_shelf_amount.REAL_STOCK);
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_shelf').value = '';
					document.getElementById('add_other_barcod').focus();
				}	
			}
		}
		else
		{
			ekle=1;
			alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='351.Çıkış Rafındaki Stok Miktarı'>: 0");
			document.getElementById('add_other_amount').value = 1;
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_shelf').value = '';
			document.getElementById('add_other_barcod').focus();
		}
		if (ekle == 0)
		{
			document.getElementById('shelf_select_td').style.display='none';
			if(row_count >0) /*ilk Satırdan sonrası*/
			{
				for(i=1;i<=row_count;i++)
				{
					if(document.getElementById('stockid'+i).value == stockid && document.getElementById('spectmainid'+i).value == spectmainid && document.getElementById('shelf_code'+i).value == shelf_code)
					{
						document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
						if (document.getElementById('frm_row'+i).style.display == 'none')
								document.getElementById('frm_row'+i).style.display='block';
						ekle=1;
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
				document.getElementById('shelf_select_td').style.display='none';
				return false;
			}
			add_amount();
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
				newCell.innerHTML = '<input type="hidden" value="'+stockid+'" name="stockid'+row_count+'" id="stockid'+row_count+'" /><input type="hidden" value="'+spectmainid+'" name="spectmainid'+row_count+'" id="spectmainid'+row_count+'" /><input type="text" value="'+barcode+'" name="barcod'+row_count+'" id="barcod'+row_count+'" size="13" readonly="yes" style="border:none;height:20px" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" value="'+stockcode+'" name="stockcode'+row_count+'" id="stockcode'+row_count+'" size="13" readonly="yes" style="border:none" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" style="text-align:right;border:none" value="'+amount+'" name="amount'+row_count+'" id="amount'+row_count+'" size="5" readonly="yes"  style="text-align:" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" value="'+shelf_code+'" name="shelf_code'+row_count+'" id="shelf_code'+row_count+'" size="12" readonly="yes" style="text-align:right;border:none" />';
			}
			else
				ekle = 0;
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_shelf').value = '';
			document.getElementById('add_other_amount').value = 1;
			document.getElementById('add_other_barcod').focus();
		}
	}
	function search_shelf(shelf_8)
	{
		var cikis_depo = document.all.txt_department_out.value;
		
		/*var shelf_sql = "SELECT PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE = '"+shelf_8+"'";
		var get_shelf = wrk_query(shelf_sql,'dsn3');*/
		
		var listParam = shelf_8;
		var get_shelf = wrk_safe_query('get_amount_shelf_amount_ezgi','dsn3',0,listParam);
		
		if(get_shelf.recordcount)
		{
			var cikis_depo_s = get_shelf.STORE_ID.toString()+'-'+get_shelf.LOCATION_ID.toString();
			if(cikis_depo != cikis_depo_s)
			{
					alert('<cf_get_lang dictionary_id='345.Seçtiğiniz Raf Giriş Lokasyonunda Yoktur'>!');	
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_shelf').value = '';
					document.getElementById('add_other_barcod').focus();	
			}
			else
			{
				if (document.getElementById('add_other_barcod').value.length > 0)
				{
					barcode = document.getElementById('add_other_barcod').value;
					shelf_code = document.getElementById('add_other_shelf').value;
					buton_kontrol();
					document.getElementById('txt_department_out').disabled = true;
					add_row(barcode);
				}
				else if (document.getElementById('add_other_barcod').value.length == 0)
				{
						document.getElementById('add_other_barcod').focus();	
				}
				else
				{
						alert('<cf_get_lang dictionary_id='347.Ürün Barkodu Hatalı'>');
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_shelf').value = '';
						document.getElementById('add_other_barcod').focus();
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
	function set_shelfs(stockid,spectmainid)
	{
		document.getElementById('shelf_select_td').style.display='';
		if(spectmainid==0)
		{
			/*var product_shelfs="SELECT REAL_STOCK,SHELF_CODE,PRODUCT_PLACE_ID FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID = "+stockid+" AND REAL_STOCK > 0 ORDER BY REAL_STOCK DESC";*/
			var listParam = form_basket.txt_department_out.value+ "*" +stockid;
			var get_product_shelfs = wrk_safe_query('get_shelf_depo_stock_id_ezgi','dsn2',0,listParam);
		}
		else
		{
			/*var product_shelfs="SELECT REAL_STOCK,SHELF_CODE,PRODUCT_PLACE_ID FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID = "+stockid+" AND SPECT_MAIN_ID = "+spectmainid+" AND REAL_STOCK > 0 ORDER BY REAL_STOCK DESC";*/
			var listParam = form_basket.txt_department_out.value+ "*" +stockid+ "*" +spectmainid;
			var get_product_shelfs = wrk_safe_query('get_shelf_depo_spectmainid_ezgi','dsn2',0,listParam);
		}
		/*var get_product_shelfs = wrk_query(product_shelfs,'dsn2');*/
		var option_count = document.getElementById('shelf_select').options.length; 
		for(x=option_count;x>=0;x--)
			document.getElementById('shelf_select').options[x] = null;
		if(get_product_shelfs.recordcount != 0)
		{	
			for(var xx=0;xx<get_product_shelfs.recordcount;xx++)
			{
				document.getElementById('shelf_select').options[xx]=new Option(get_product_shelfs.SHELF_CODE[xx]+"-"+get_product_shelfs.REAL_STOCK[xx],get_product_shelfs.PRODUCT_PLACE_ID[xx],get_product_shelfs.REAL_STOCK[xx]);
			}
		}
		else
		{
			document.getElementById('shelf_select').options[0] = new Option('Raf Tanımsız','');
			alert('Seçtiğiniz Ürün Lokasyondaki Raflarda Yoktur');
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_shelf').value = '';
			document.getElementById('add_other_barcod').focus();
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
			window.location.href='<cfoutput>#request.self#?fuseaction=pda.add_ambar_fis&ambarfis=2<cfif isdefined('attributes.param')>&param= and attributes.param</cfif></cfoutput>&tersfis=1&dep_in='+form_basket.txt_department_in.value+'&dep_out='+form_basket.txt_department_out.value+'&action_id='+document.getElementById('action_id').value+'&fis_tipi='+form_basket.fis_tipi.value+'&process_cat='+form_basket.process_cat_id.value;
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
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('amount'+i).value + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('shelf_code'+i).value + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + '0'+ '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('spectmainid'+i).value;
				j++;
		  	}
		  	document.getElementById('row_count').value = j;
	  	}
	}

</script>