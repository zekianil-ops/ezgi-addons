<!---
    File: add_ambar_fis_1.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cf_xml_page_edit>
<cfif attributes.fuseaction eq 'pda.add_ezgi_ship_dispatch'>
	<cfsavecontent variable="title"><cf_get_lang dictionary_id="1300.Depolararası Sevk - PDA"></cfsavecontent>
    <cfset default_process_type = 81>
<cfelse>
	<cfsavecontent variable="title"><cf_get_lang dictionary_id="29630.Ambar Fişi"></cfsavecontent>
    <cfset default_process_type = 113>
</cfif>
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>

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
<cfif x_default_control eq 1>
	<cfset default_departments = '#get_default_departments.DEFAULT_MK_TO_RF_DEP#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
    <cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
    <cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,1)#">
<cfelse>   
	<cfset default_departments = '#get_default_departments.DEFAULT_MK_TO_RF_DEP#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
    <cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,1)#">
    <cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,1)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,1)#">
</cfif>

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
        TBL.STORE_ID IS NULL
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
        <cfif attributes.fuseaction eq 'pda.add_ezgi_ship_dispatch'>
        	SPCF.FUSE_NAME = 'pda.add_ezgi_ship_dispatch'
        <cfelse>
        	SPCF.FUSE_NAME = 'pda.form_add_ambar_fis'
        </cfif> 
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
            <cf_box_search>
            	<div class="col col-12">
                	<div class="col col-5">
                        <label class="col col-5"><cf_get_lang dictionary_id='57635.Miktar'></label>
                        <div class="col col-7">
                            <div class="form-group">
                                <input id="add_other_amount" name="add_other_amount" type="text"  onfocus="islemtipi=0;" style="text-align:right" value="1" />
                            </div>
                        </div>
                    </div>
                    <div class="col col-7">
                        <label class="col col-3"><cf_get_lang dictionary_id='57633.Barkod'></label>
                        <div class="col col-9">
                            <div class="form-group">
                                <input id="add_other_barcod" name="add_other_barcod" type="text" value="" >
                            </div>
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
                            <select name="txt_department_out" id="txt_department_out" style="width:100px" onchange="document.getElementById('department_out').value = this.value">
                				<cfoutput query="get_all_location" group="department_id">
                  					<option disabled="disabled" value="#department_id#"<cfif attributes.department_out_id eq department_id>selected</cfif>>#department_head#</option>
                  						<cfoutput>
                    						<option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_out_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#<cfif not status>-<cf_get_lang dictionary_id='57494.Pasif'></cfif>
                    						</option>
                  						</cfoutput> 
								</cfoutput>
              				</select>
                       	</div>
                    </div>
                    <div class="col col-6">
						<div class="form-group">
                            <select name="txt_department_in" style="width:100px" onchange="document.getElementById('department_in').value = this.value">
                				<cfoutput query="get_all_location" group="department_id">
                  					<option disabled="disabled" value="#department_id#"<cfif attributes.department_in_id eq department_id>selected</cfif>>#department_head#</option>
                  					<cfoutput>
                    					<option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_in_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#<cfif not status>-<cf_get_lang dictionary_id='57494.Pasif'></cfif>
                    					</option>
                  					</cfoutput> 
								</cfoutput>
              				</select>
                       	</div>
                    </div>
             	</div>
                <cfif x_detail_control eq 1>
                <div class="col col-12">
                	<div class="col col-12">
						<div class="form-group">
                         	<input id="detail" name="detail" type="text" placeholder="Açıklama" style="text-align:left" value="">
                       	</div>
                    </div>
             	</div>
                <cfelse>
                	<input id="detail" name="detail" type="hidden" placeholder="Açıklama" style="text-align:left" value="">
                </cfif>
          	</cf_box_search>
        </cf_box>
        <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
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
                <tfoot>
                    <tr>	
                        <td colspan="4">
                            <input type="hidden" id="department_in" name="department_in" value=""  />
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
	$('#add_other_barcod').focus();
	setTimeout("document.getElementById('add_other_barcod').select();",1000);	
	document.onkeydown = checkKeycode
	function checkKeycode(e) {
	var keycode;
	if (window.event) keycode = window.event.keyCode;
	else if (e) keycode = e.which;
	if (keycode == 13)
	{
			if ((document.getElementById('add_other_barcod').value.length > 0) && (islemtipi==0))
			{
				add_row(document.getElementById('add_other_barcod').value);
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_amount').value = '1';
				document.getElementById('add_other_barcod').focus();
			}
			else
			{
				alert('<cf_get_lang dictionary_id='29476.Barkod Hatalı'>');
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcode').focus();
			}
		}
	}
	function add_row(barcode)
	{
		get_stock(barcode);
		if (k_==0)
		{
			  amount = ''; 
			  amount = document.getElementById('add_other_amount').value;
			  if (ekle == 0)
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
				newCell.innerHTML = '<input type="hidden" value="'+stockid+'" name="stockid'+row_count+'" id="stockid'+row_count+'" /><input type="hidden" value="'+spectmainid+'" name="spectmainid'+row_count+'" id="spectmainid'+row_count+'" /><input type="text" value="'+barcode+'" name="barcod'+row_count+'" id="barcod'+row_count+'" size="14" readonly="yes" style="border:none; height:20px" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" value="'+stockcode+'" name="stockcode'+row_count+'" id="stockcode'+row_count+'" size="30" readonly="yes" style="border:none" />';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="text" style="text-align:right;border:none" value="'+amount+'" name="amount'+row_count+'" id="amount'+row_count+'" size="4" readonly="yes"/>';
				newCell = newRow.insertCell();
				newCell.innerHTML = '<input type="hidden" value="'+birim+'" name="birim'+row_count+'" id="birim'+row_count+'" />';
			  }
			  else
			  {
				 ekle = 0;
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
					ekle = 1;
					alert('<cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'> : <cf_get_lang dictionary_id='36006.Spekt ID'>');
				}
				else
				{
					carpan = get_product.MULTIPLIER;
					birim = get_product.MAIN_UNIT;
					stockid = get_product.STOCK_ID;
					stockcode = get_product.PRODUCT_NAME;
					barcode = get_product.PRODUCT_BARCOD;
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
	  	if(row_count >0) /*ilk Satırdan sonrası*/
	  	{
			for(i=1;i<=row_count;i++)
		  	{	
				<cfif x_stock_control>
			  	if(spectmainid==0)
				{
				  	/*var stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL WHERE  DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID ="+stockid;*/
					var listParam = form_basket.txt_department_out.value + "*" + stockid;
					var get_real_stock = wrk_safe_query('get_depo_stock_stock_id_ezgi','dsn2',0,listParam);
				}
				else
				{
					/*var stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_SPECT_LOCATION_TOTAL WHERE  DEPO = '"+form_basket.txt_department_out.value+"' AND SPECT_MAIN_ID ="+spectmainid;*/
					var listParam = form_basket.txt_department_out.value + "*" + spectmainid;
					var get_real_stock = wrk_safe_query('get_depo_stock_spectmainid_ezgi','dsn2',0,listParam);
				}
				/*var get_real_stock = wrk_query(stock_sql,'dsn2');*/
				
				if (get_real_stock.PRODUCT_STOCK == undefined)
					get_real_stock.PRODUCT_STOCK = 0;
					
				if(get_real_stock.PRODUCT_STOCK == 0 || (get_real_stock.PRODUCT_STOCK*1 < document.getElementById('amount'+i).value*1 - (-1 * amount) && document.getElementById('stockid'+i).value == stockid && document.getElementById('spectmainid'+i).value == spectmainid) || get_real_stock.PRODUCT_STOCK*1 < amount*1)
				{
					ekle=1;
					if(spectmainid==0)
						alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='343.Çıkış Lokasyonundaki Stok Miktarı'> : "+get_real_stock.PRODUCT_STOCK);
					else
						alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='343.Çıkış Lokasyonundaki Stok Miktarı'> : "+get_real_stock.PRODUCT_STOCK+" - <cf_get_lang dictionary_id='57647.Spekt'> : "+spectmainid);
					document.getElementById('add_other_amount').focus();
					return false;
				}
				else
				{
					if(document.getElementById('stockid'+i).value == stockid && document.getElementById('spectmainid'+i).value == spectmainid)
					{
						document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
						if(document.getElementById('frm_row'+i).style.display == 'none')
							document.getElementById('frm_row'+i).style.display='block';
						ekle=1;
					}
				}
				<cfelse>
					if(document.getElementById('stockid'+i).value == stockid && document.getElementById('spectmainid'+i).value == spectmainid)
					{
						document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
						if(document.getElementById('frm_row'+i).style.display == 'none')
							document.getElementById('frm_row'+i).style.display='block';
						ekle=1;
					}
				</cfif>
		   }
	   }
	   else
	   {
		   	<cfif x_stock_control>
		    if(spectmainid==0)
			{
				/*var stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_STOCK_LOCATION_TOTAL WHERE  DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID ="+stockid;*/
				var listParam = form_basket.txt_department_out.value + "*" + stockid;
				var get_real_stock = wrk_safe_query('get_depo_stock_stock_id_ezgi','dsn2',0,listParam);
			}
			else
			{
				/*var stock_sql = "SELECT PRODUCT_STOCK FROM EZGI_GET_SPECT_LOCATION_TOTAL WHERE  DEPO = '"+form_basket.txt_department_out.value+"' AND SPECT_MAIN_ID ="+spectmainid;*/
				var listParam = form_basket.txt_department_out.value + "*" + spectmainid;
				var get_real_stock = wrk_safe_query('get_depo_stock_spectmainid_ezgi','dsn2',0,listParam);
			}
			/*var get_real_stock = wrk_query(stock_sql,'dsn2');*/
			
			if (get_real_stock.PRODUCT_STOCK == undefined)
				get_real_stock.PRODUCT_STOCK = 0;
			if(get_real_stock.PRODUCT_STOCK*1 < amount*1)
			{
				ekle=1;
				if(spectmainid==0)
					alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='343.Çıkış Lokasyonundaki Stok Miktarı'> : "+get_real_stock.PRODUCT_STOCK);
				else
					alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='343.Çıkış Lokasyonundaki Stok Miktarı'> : "+get_real_stock.PRODUCT_STOCK+" - <cf_get_lang dictionary_id='57647.Spekt'> : "+spectmainid);
				document.getElementById('add_other_amount').focus();
			}
			else
			{
				document.getElementById('txt_department_out').disabled = true;
			}
			<cfelse>
				document.getElementById('txt_department_out').disabled = true;
			</cfif>
	   }
	   document.getElementById('txt_department_out').disabled = true;
	}
	function kontrol_kayit()
	{
		if(form_basket.txt_department_in.value == form_basket.txt_department_out.value)
		{
			alert('<cf_get_lang dictionary_id='350.Giriş ve Çıkış Lokasyonu Farklı Olmalıdır.'>');
			return false;
		}
		else
		{
			document.getElementById('onay').disabled = true;
			sor = confirm('<cf_get_lang dictionary_id='362.Kaydetmek İstiyor Musunuz'>');
			if(sor == true)
			{
				actionidolustur();
				<cfif attributes.fuseaction eq 'pda.add_ezgi_ship_dispatch'>
					window.location.href='<cfoutput>#request.self#</cfoutput>?fuseaction=pda.emptypopup_add_ezgi_ship_dispatch&ambarfis=1&dep_in='+form_basket.txt_department_in.value+'&dep_out='+form_basket.txt_department_out.value+'&action_id='+document.getElementById('action_id').value+'&fis_tipi='+form_basket.fis_tipi.value+'&process_cat='+form_basket.process_cat_id.value+'&detail='+form_basket.detail.value;
				<cfelse>
					window.location.href='<cfoutput>#request.self#</cfoutput>?fuseaction=pda.add_ambar_fis&ambarfis=1&dep_in='+form_basket.txt_department_in.value+'&dep_out='+form_basket.txt_department_out.value+'&action_id='+document.getElementById('action_id').value+'&fis_tipi='+form_basket.fis_tipi.value+'&process_cat='+form_basket.process_cat_id.value+'&detail='+form_basket.detail.value;
				</cfif>
			}
			else
			{
				document.getElementById('onay').disabled = false;
				return false;
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
			document.getElementById('action_id').value = document.getElementById('action_id').value + ',';
			document.getElementById('action_id').value = document.getElementById('action_id').value + i + '-';
			document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('stockid'+i).value + '-';
			document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('amount'+i).value + '-';
			document.getElementById('action_id').value = document.getElementById('action_id').value + '0'+ '-';
			document.getElementById('action_id').value = document.getElementById('action_id').value + '0'+ '-';
			document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('spectmainid'+i).value;
			j++;
		  }
		  document.getElementById('row_count').value = j;
	  }
	}
</script>