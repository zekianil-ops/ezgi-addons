<!---
    File: add_ambar_fis_3.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
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
<cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT        
    	D.DEPARTMENT_HEAD, 
        SL.DEPARTMENT_ID, 
        SL.LOCATION_ID, 
        SL.STATUS, 
        SL.COMMENT, 
        TBL.STORE_ID
	FROM            
    	STOCKS_LOCATION AS SL INNER JOIN
    	DEPARTMENT AS D ON SL.DEPARTMENT_ID = D.DEPARTMENT_ID INNER JOIN
      	BRANCH AS B ON D.BRANCH_ID = B.BRANCH_ID LEFT OUTER JOIN
     	(
        	SELECT        
            	STORE_ID, LOCATION_ID
         	FROM            
            	#dsn3_alias#.PRODUCT_PLACE
        	GROUP BY STORE_ID, LOCATION_ID
    	) AS TBL ON SL.LOCATION_ID = TBL.LOCATION_ID AND SL.DEPARTMENT_ID = TBL.STORE_ID
	WHERE        
    	D.DEPARTMENT_ID IN (#default_departments#) AND 
        SL.STATUS = 1 AND 
        TBL.STORE_ID IS NOT NULL
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
          	<input type="hidden" name="active_period" value="#session.ep.period_id#" />
            <input type="hidden" name="anabarcode" id="anabarcode" value="" />
            <cfinput id="store_amount" name="store_amount" type="hidden" value="0"/>
             <cf_box_search>
            	<div class="col col-12">
                	<div class="col col-2">
                    	<cf_get_lang dictionary_id='57635.Miktar'>
                    </div>
                	<div class="col col-4">
                    	<cf_get_lang dictionary_id='57633.Barkod'>
                    </div>
                    <div class="col col-3">
                    	<cf_get_lang dictionary_id='43312.Çıkış Rafı'>
                    </div>
                    <div class="col col-3">
                    	<cf_get_lang dictionary_id='352.Giriş Rafı'>
                    </div>
              	</div>
                <div class="col col-12">
                	<div class="col col-2">
                    	<div class="form-group">
                            <input id="add_other_amount" name="add_other_amount" type="text"  onfocus="islemtipi=0;" style="text-align:right" value="1" />
                    	</div>
                    </div>
                	<div class="col col-4">
                    	<div class="form-group">
                            <input id="add_other_barcod" name="add_other_barcod" type="text" value="">
                        </div>
                    </div>
                    <div class="col col-3">
                    	<div class="form-group">
                            <input id="add_out_shelf" name="add_out_shelf" type="text" onfocus="islemtipi=0;" value="" />
                        </div>
                    </div>
                    <div class="col col-3">
                    	<div class="form-group">
                            <input id="add_in_shelf" name="add_in_shelf" type="text" onfocus="islemtipi=0;" value="" />
                        </div>
                    </div>
               	</div>
             	
                <div class="col col-12" id="shelf_select_td" style="display:none">
                	<label class="col col-6"><cf_get_lang dictionary_id='353.Çıkış Raf Miktarı'></label>
                    <div class="col col-6">
                    	<div class="form-group">
                            <select name="shelf_select" id="shelf_select" style="width:85px; text-align:center">
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
          	</cf_box_search>
        </cf_box>
        <cfsavecontent variable="title"><cf_get_lang dictionary_id="11.Raf Değiştir"></cfsavecontent>
        <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
            <cf_form_list>
                <thead>
                    <tr>
                        <th style="width:100%"><cf_get_lang dictionary_id='57633.Barkod'></th>
                        <th style="width:15%"><cf_get_lang dictionary_id='57635.Miktar'></th>
                        <th style="width:25%"><cf_get_lang dictionary_id='43312.Çıkış Rafı'></th>
                        <th style="width:25%"><cf_get_lang dictionary_id='352.Giriş Rafı'></th>
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
			if (document.getElementById('add_other_barcod').value.length == '' && (document.getElementById('add_out_shelf').value.length >0 || document.getElementById('add_in_shelf').value.length > 0))
			{
				alert('<cf_get_lang dictionary_id='340.Önce Ürün Barkodu Okutunuz'>');
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_out_shelf').value = '';
				document.getElementById('add_other_amount').value = 1;
				$('#add_other_barcod').focus();	
			}
			else
			{
				if (document.getElementById('add_out_shelf').value.length >0)
					search_shelf_out(document.getElementById('add_out_shelf').value);
				if(document.getElementById('add_in_shelf').value.length >0)
					search_shelf_in(document.getElementById('add_in_shelf').value);
				if(document.getElementById('add_in_shelf').value.length >0 && document.getElementById('add_out_shelf').value.length >0)		
				{
					if(document.getElementById('add_in_shelf').value == document.getElementById('add_out_shelf').value)
					{
						alert('<cf_get_lang dictionary_id='354.Giriş ve Çıkış Rafları Aynı Olamaz'>');
						document.getElementById('add_in_shelf').value = '';
						$('#add_in_shelf').focus();
						return false;
					}
					else	
					{
						$('#add_other_barcod').focus();
						get_stock(document.getElementById('add_other_barcod').value);
					}
				}
				else	
				{
					if (document.getElementById('add_other_barcod').value.length == '')
					{
						$('#add_other_barcod').focus();
						return false;
					}
					else
					{
						get_stock(document.getElementById('add_other_barcod').value);
						if (ekle==0)
							$('#add_out_shelf').focus();
						else
						{
							ekle=0;
							document.getElementById('store_amount').value = 0;
							document.getElementById('add_other_barcod').value = '';
							document.getElementById('add_other_barcod').focus();
							return false;	
						}
					}
				}
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
			/*var new_sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER, S.PRODUCT_NAME, S.IS_PROTOTYPE FROM STOCKS_BARCODES AS SB INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '"+barcode+"'";*/
		 	/*var get_product = wrk_query(new_sql,'dsn3');*/
			
			var listParam = barcode;
			var get_product = wrk_safe_query('get_product_ezgi','dsn3',0,listParam);
			
		 	if (get_product.STOCK_ID == undefined)
		 	{
				ekle = 1;
				alert('<cf_get_lang dictionary_id='341.Ürün Bulunamadı'>');
				document.getElementById('add_other_amount').value = 1;
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcod').focus();
				return false;
		 	}
		 	else
		 	{	
				if(get_product.IS_PROTOTYPE==1 && spectmainid==0)
				{
					alert('<cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'> : <cf_get_lang dictionary_id='36006.Spekt ID'>');
					ekle = 1;
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus();
					return false;
				}
				else
				{
					carpan = get_product.MULTIPLIER;
					birim = get_product.MAIN_UNIT;
					stockid = get_product.STOCK_ID;
					stockcode = get_product.PRODUCT_NAME;
					barcode = get_product.BARCODE;
					$('#add_out_shelf').focus();
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
	function set_shelfs(stockid,spectmainid)
	{
		/*var product_shelfs = wrk_query("SELECT PP.SHELF_CODE, PP.PRODUCT_PLACE_ID, EE.DEPO, EE.REAL_STOCK, EE.REAL_STOCK AS AMOUNT FROM <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS PP INNER JOIN EZGI_GET_SPECT_SHELF_LOCATION_TOTAL AS EE ON PP.PRODUCT_PLACE_ID = EE.PRODUCT_PLACE_ID WHERE EE.DEPO = '"+form_basket.txt_department_out.value+"' AND EE.STOCK_ID = "+stockid+" AND EE.SPECT_MAIN_ID = "+spectmainid+" ORDER BY PP.SHELF_TYPE","dsn2");*/
		
		var listParam =form_basket.txt_department_out.value + "*" + stockid + "*" + spectmainid;
		var product_shelfs = wrk_safe_query('get_shelf_depo_stockid_spectmainid_ezgi','dsn2',0,listParam);
		
		if(product_shelfs.recordcount != 0)
		{	
			if(spectmainid==0)
			{
				/*var depo_stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL WHERE  DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID ="+stockid;*/
				var listParam = form_basket.txt_department_out.value + "*" + stockid;
				var depo_stock = wrk_safe_query('get_depo_stock_stock_id_ezgi','dsn2',0,listParam);
			}
			else
			{
				/*var depo_stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_SPECT_LOCATION_TOTAL WHERE  DEPO = '"+form_basket.txt_department_out.value+"' AND SPECT_MAIN_ID ="+spectmainid;*/
				var listParam = form_basket.txt_department_out.value + "*" + spectmainid;
				var depo_stock = wrk_safe_query('get_depo_stock_spectmainid_ezgi','dsn2',0,listParam);
			}
			/*var depo_stock = wrk_query(depo_stock_sql,'dsn2');*/
			
			if(depo_stock.PRODUCT_STOCK == undefined)
				depo_stock.PRODUCT_STOCK = 0;
			if(depo_stock.PRODUCT_STOCK<=0)
			{
				if(spectmainid==0)
					alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='343.Çıkış Lokasyonundaki Stok Miktarı'> : "+depo_stock.PRODUCT_STOCK);
				else
					alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='343.Çıkış Lokasyonundaki Stok Miktarı'> : "+depo_stock.PRODUCT_STOCK+" - <cf_get_lang dictionary_id='57647.Spekt'> : "+spectmainid);
				ekle=1;
			}
			else
			{
				document.getElementById('shelf_select_td').style.display='';
				var option_count = document.getElementById('shelf_select').options.length; 
				for(x=option_count;x>=0;x--)
				document.getElementById('shelf_select').options[x] = null;
				for(var xx=0;xx<product_shelfs.recordcount;xx++)
				{
					document.getElementById('shelf_select').options[xx]=new Option(product_shelfs.SHELF_CODE[xx]+"-"+product_shelfs.REAL_STOCK[xx],product_shelfs.PRODUCT_PLACE_ID[xx],product_shelfs.AMOUNT[xx]);
				}
				
				document.getElementById('store_amount').value = depo_stock.PRODUCT_STOCK;
				if(row_count >0)
				{
					for(i=1;i<=row_count;i++)
					{
						if(document.getElementById('stockid'+i).value == stockid && document.getElementById('spectmainid'+i).value == spectmainid)
						{
							document.getElementById('store_amount').value = ((document.getElementById('store_amount').value*1) - (document.getElementById('amount'+i).value*1));
						}
					}
				}
				document.getElementById('store_amount').value = ((document.getElementById('store_amount').value*1)-(document.getElementById('add_other_amount').value*1));
				if(document.getElementById('store_amount').value<0)
				{
					if(spectmainid==0)
						alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='343.Çıkış Lokasyonundaki Stok Miktarı'> : "+depo_stock.PRODUCT_STOCK);
					else
						alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='343.Çıkış Lokasyonundaki Stok Miktarı'> : "+depo_stock.PRODUCT_STOCK+" - <cf_get_lang dictionary_id='57647.Spekt'> : "+spectmainid);
					ekle=1;
					document.getElementById('store_amount').value = 0;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus();
				}
			}
		}
		else
		{
			document.getElementById('shelf_select').options[0] = new Option('Raf Tanımsız','');
		}
	}
	function search_shelf_out(shelf_8)
	{
		var cikis_depo = document.all.txt_department_out.value;
		/*var shelf_sql = "SELECT SHELF_TYPE, PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE = '"+shelf_8+"'";
		var get_shelf = wrk_query(shelf_sql,'dsn3');*/
		var listParam = shelf_8;
		var get_shelf = wrk_safe_query('get_amount_shelf_amount_ezgi','dsn3',0,listParam);
		if(get_shelf.recordcount)
		{
			var cikis_depo_s = get_shelf.STORE_ID.toString()+'-'+get_shelf.LOCATION_ID.toString();
			if(cikis_depo != cikis_depo_s)
			{
					ekle=1;
					alert('<cf_get_lang dictionary_id='355.Seçtiğiniz Raf Çıkış Lokasyonunda Yoktur.'>!');	
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_out_shelf').value = '';
					$('#add_other_barcod').focus();	
			}
			else
			{
				if (document.getElementById('add_other_barcod').value.length > 0)
				{
					if(spectmainid==0)
					{
						/*var product_shelfs="SELECT REAL_STOCK FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE SHELF_CODE = '"+shelf_8+"' AND DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID = "+stockid;*/
						var listParam = shelf_8 + "*" + form_basket.txt_department_out.value + "*" + stockid;
						var get_product_shelfs = wrk_safe_query('get_shelf_depo_stock_id_shelf_ezgi','dsn2',0,listParam);
					}
					else
					{
						/*var product_shelfs="SELECT REAL_STOCK FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE SHELF_CODE = '"+shelf_8+"' AND DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID = "+stockid+" AND SPECT_MAIN_ID = "+spectmainid;*/
						var listParam = shelf_8 + "*" + form_basket.txt_department_out.value + "*" + stockid + "*" + spectmainid;
						var get_product_shelfs = wrk_safe_query('get_shelf_depo_stock_id_spectmain_shelf_ezgi','dsn2',0,listParam);
					}
					/*var get_product_shelfs = wrk_query(product_shelfs,'dsn2');*/
					if(get_product_shelfs.recordcount == 0 || get_product_shelfs.REAL_STOCK<=0)
					{
						ekle=1;
						alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='351.Çıkış Rafındaki Stok Miktarı'>: 0");
						document.getElementById('add_out_shelf').value = '';
						document.getElementById('add_out_shelf').focus();
						return false;
					}
					else
					{
						if((get_product_shelfs.REAL_STOCK*1)<(document.getElementById('add_other_amount').value*1))
						{
							ekle=1;
							alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='351.Çıkış Rafındaki Stok Miktarı'>: "+get_product_shelfs.REAL_STOCK);
							document.getElementById('add_out_shelf').value = '';
							document.getElementById('add_out_shelf').focus();
							return false;
						}
						else
						{
							document.getElementById('add_other_amount').disabled = true;
							document.getElementById('add_other_barcod').disabled = true;
							document.getElementById('add_out_shelf').disabled = true;
							$('#add_in_shelf').focus();
						}
					}
				}
				else if (document.getElementById('add_other_barcod').value.length == 0)
				{
					ekle=1;
					document.getElementById('add_other_barcod').focus();	
				}
				else
				{
						alert('<cf_get_lang dictionary_id='347.Ürün Barkodu Hatalı'>');
						ekle=1;
						document.getElementById('store_amount').value = 0;
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_out_shelf').value = '';
						document.getElementById('add_other_barcod').focus();
						return false;
				}
			}
		}
		else
		{
			alert('<cf_get_lang dictionary_id='348.Seçtiğiniz Raf Hiç Tanımlanmamış'>!');
			document.getElementById('add_out_shelf').value = '';
			document.getElementById('add_in_shelf').value = '';
			$('#add_out_shelf').focus();
		}
	}
	function search_shelf_in(shelf_8)
	{
		var giris_depo = document.all.txt_department_in.value;
		/*var shelf_sql = "SELECT SHELF_TYPE, PRODUCT_PLACE_ID, STORE_ID, LOCATION_ID FROM PRODUCT_PLACE WHERE PLACE_STATUS = 1 AND SHELF_CODE = '"+shelf_8+"'";
		var get_shelf = wrk_query(shelf_sql,'dsn3');*/
		var listParam = shelf_8;
		var get_shelf = wrk_safe_query('get_amount_shelf_amount_ezgi','dsn3',0,listParam);
		
		if(get_shelf.recordcount)
		{
			var giris_depo_s = get_shelf.STORE_ID.toString()+'-'+get_shelf.LOCATION_ID.toString();
			if(giris_depo != giris_depo_s)
			{
					alert('<cf_get_lang dictionary_id='345.Seçtiğiniz Raf Giriş Lokasyonunda Yoktur'>.!');	
					document.getElementById('store_amount').value = 0;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_in_shelf').value = '';
					document.getElementById('add_in_shelf').focus();	
			}
			else
			{
				if (document.getElementById('add_other_barcod').value.length > 0)
				{
					if(get_shelf.SHELF_TYPE == 1)
					{
						/*var new_sql = "SELECT SB.STOCK_ID, SB.BARCODE, S.PRODUCT_NAME, PP.SHELF_CODE FROM STOCKS_BARCODES AS SB INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID INNER JOIN PRODUCT_PLACE_ROWS AS PPR ON S.PRODUCT_ID = PPR.PRODUCT_ID INNER JOIN PRODUCT_PLACE AS PP ON PPR.PRODUCT_PLACE_ID = PP.PRODUCT_PLACE_ID WHERE SB.BARCODE = '"+document.getElementById('anabarcode').value+"' AND PP.SHELF_CODE ='"+document.getElementById('add_in_shelf').value+"'";
						var get_product = wrk_query(new_sql,'dsn3');*/
						var listParam = document.getElementById('anabarcode').value + "*" + document.getElementById('add_other_shelf').value;
						var get_product = wrk_safe_query('get_product_by_shelf_code_ezgi','dsn3',0,listParam);
						
						if (get_product.STOCK_ID == undefined)
						{
							alert('<cf_get_lang dictionary_id='346.Ürün Bu Rafa Tanıtılmamış'>');
							document.getElementById('add_in_shelf').value = '';
							document.getElementById('add_in_shelf').focus();
						}
						else
						{	
							stockid = get_product.STOCK_ID;
							stockcode = get_product.PRODUCT_NAME;
							barcode = document.getElementById('add_other_barcod').value;
							shelf_code = get_product.SHELF_CODE; 
							buton_kontrol();
							add_row(barcode);
							document.getElementById('store_amount').value = 0;
							document.getElementById('add_other_barcod').value = '';
							document.getElementById('add_in_shelf').value = '';
							document.getElementById('add_other_amount').value = 1;
							document.getElementById('add_other_barcod').focus();
						}
					}
					else
					{
						/*var new_sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER, S.PRODUCT_NAME FROM STOCKS_BARCODES AS SB INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '"+document.getElementById('anabarcode').value+"'";
		 				var get_product = wrk_query(new_sql,'dsn3');*/
						var listParam = document.getElementById('anabarcode').value;
						var get_product = wrk_safe_query('get_product_ezgi','dsn3',0,listParam);
						
						stockid = get_product.STOCK_ID;
						stockcode = get_product.PRODUCT_NAME;
						barcode = document.getElementById('add_other_barcod').value;
						shelf_code = document.getElementById('add_in_shelf').value;
						buton_kontrol();
						add_row(barcode);
						document.getElementById('add_other_amount').disabled = false;
						document.getElementById('add_other_barcod').disabled = false;
						document.getElementById('add_out_shelf').disabled = false;
						document.getElementById('store_amount').value = 0;
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_in_shelf').value = '';
						document.getElementById('add_out_shelf').value = '';
						document.getElementById('add_other_amount').value = 1;
						document.getElementById('add_other_barcod').focus();
						
					}
				}
				else if (document.getElementById('add_other_barcod').value.length == 0)
				{
					document.getElementById('add_other_barcod').focus();	
				}
				else
				{
					alert('<cf_get_lang dictionary_id='347.Ürün Barkodu Hatalı'>');
					document.getElementById('store_amount').value = 0;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_in_shelf').value = '';
					document.getElementById('add_other_barcod').focus();
				}
			}
		}
		else
		{
			alert('12');
			alert('<cf_get_lang dictionary_id='348.Seçtiğiniz Raf Hiç Tanımlanmamış'>!');
			document.getElementById('store_amount').value = 0;
			document.getElementById('add_in_shelf').value = '';
			document.getElementById('add_in_shelf').focus();
		}
	}
	function add_amount()
	{
	  document.getElementById('shelf_select_td').style.display='none';
	  if(row_count >0) /*ilk Satırdan sonrası*/
	  {
		  for(i=1;i<=row_count;i++)
		  {
			  if(document.getElementById('stockid'+i).value == stockid)
			  {
				  /*var stock_sql = "SELECT ISNULL(S.REAL_STOCK, 0) AS PRODUCT_STOCK FROM GET_STOCK_LAST_SHELF AS S INNER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS P ON S.SHELF_NUMBER = P.PRODUCT_PLACE_ID WHERE P.SHELF_CODE = '"+document.getElementById('add_out_shelf').value+"' AND S.STOCK_ID ="+stockid;
				  var get_real_stock = wrk_query(stock_sql,'dsn2');*/
				  	var listParam = document.getElementById('add_out_shelf').value + "*" + stockid;
					var get_real_stock = wrk_safe_query('get_amount_stock_id_depo_ezgi','dsn2',0,listParam);
				  
				  if((get_real_stock.PRODUCT_STOCK*1) < (document.getElementById('amount'+i).value*1) - (-1 * amount))
				  {
					ekle=1;
					alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='351.Çıkış Rafındaki Stok Miktarı'>: "+get_real_stock.PRODUCT_STOCK);
					$('#add_other_amount').focus();
				  }
				  else
				  {
					  if(document.getElementById('stockid'+i).value == stockid && document.getElementById('shelf_code_out'+i).value == shelf_code_out && document.getElementById('shelf_code_in'+i).value == shelf_code_in)
					  {
						document.getElementById('amount'+i).value = (document.getElementById('amount'+i).value*1) - (-1 * amount);
						if (document.getElementById('frm_row'+i).style.display == 'none')
							document.getElementById('frm_row'+i).style.display='block';
						ekle=1;
					  }
				  }
			  }
		   }
	   }
	   else
	   {
		    /*var stock_sql = "SELECT ISNULL(S.REAL_STOCK, 0) AS PRODUCT_STOCK FROM GET_STOCK_LAST_SHELF AS S INNER JOIN <cfoutput>#dsn3_alias#</cfoutput>.PRODUCT_PLACE AS P ON S.SHELF_NUMBER = P.PRODUCT_PLACE_ID WHERE P.SHELF_CODE = '"+document.getElementById('add_out_shelf').value+"' AND S.STOCK_ID ="+stockid;
			var get_real_stock = wrk_query(stock_sql,'dsn2');*/
			var listParam = document.getElementById('add_out_shelf').value + "*" + stockid;
			var get_real_stock = wrk_safe_query('get_amount_stock_id_depo_ezgi','dsn2',0,listParam);
			
			if((get_real_stock.PRODUCT_STOCK*1) < (amount*1))
			{
				ekle=1;
				alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='351.Çıkış Rafındaki Stok Miktarı'>: "+get_real_stock.PRODUCT_STOCK);
				$('#add_other_amount').focus();
			}
	   	}
	}
	
	function add_row(barcode)
	{
		amount = document.getElementById('add_other_amount').value;
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
			newCell.innerHTML = '<input type="text" style="text-align:right;border:none;height:20px" value="'+amount+'" name="amount'+row_count+'" id="amount'+row_count+'" size="5" readonly="yes" />';
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="text" value="'+document.getElementById('add_out_shelf').value+'" name="shelf_code_out'+row_count+'" id="shelf_code_out'+row_count+'" size="12" readonly="yes" style="text-align:right;border:none;height:20px" />';
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="text" value="'+document.getElementById('add_in_shelf').value+'" name="shelf_code_in'+row_count+'" id="shelf_code_in'+row_count+'" size="12" readonly="yes" style="text-align:right;border:none;height:20px" />';
		}
		else
		{
			ekle = 0;
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
			window.location.href='<cfoutput>#request.self#</cfoutput>?fuseaction=pda.add_ambar_fis&ambarfis=3&change_shelf_fis=1&dep_in='+form_basket.txt_department_in.value+'&dep_out='+form_basket.txt_department_out.value+'&action_id='+document.getElementById('action_id').value+'&fis_tipi='+form_basket.fis_tipi.value+'&process_cat='+form_basket.process_cat_id.value;
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
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('shelf_code_out'+i).value + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('shelf_code_in'+i).value + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('spectmainid'+i).value;
				j++;
		  	}
		  	document.getElementById('row_count').value = j;
	  	}
	}
</script>