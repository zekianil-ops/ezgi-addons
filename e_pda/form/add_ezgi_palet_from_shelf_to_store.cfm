<!---
    File: add_ezgi_palet_from_shelf_to_store.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description: Palet - Raftan Depoya
--->
<cfset default_process_type = 113>
<cfquery name="get_default_departments" datasource="#dsn#">
	SELECT        
    	DEFAULT_MK_TO_RF_DEP, 
        DEFAULT_MK_TO_RF_LOC,
        DEFAULT_RF_TO_SV_DEP, 
        DEFAULT_RF_TO_SV_LOC
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
<cfset default_departments = '#get_default_departments.DEFAULT_RF_TO_SV_DEP#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
<cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_RF_TO_SV_LOC,2)#">
<cfparam name="attributes.department_out_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
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
            <cfinput id="store_amount" name="store_amount" type="hidden" value="0"/>
             <cf_box_search>
            	<div class="col col-12">
                	<div class="col col-2">
                    	<cf_get_lang dictionary_id='57635.Miktar'>
                    </div>
                	<div class="col col-5">
                    	<cf_get_lang dictionary_id='57633.Barkod'>
                    </div>
                    <div class="col col-5">
                    	<cf_get_lang dictionary_id='43312.Çıkış Rafı'>
                    </div>
                    <!---<div class="col col-3">
                    	<cf_get_lang dictionary_id='352.Giriş Rafı'>
                    </div>--->
              	</div>
                <div class="col col-12">
                	<div class="col col-2">
                    	<div class="form-group">
                            <input id="add_other_amount" name="add_other_amount" type="text"  onfocus="islemtipi=0;" style="text-align:right" value="1" />
                    	</div>
                    </div>
                	<div class="col col-5">
                    	<div class="form-group">
                            <input id="add_other_barcod" name="add_other_barcod" type="text" value="">
                        </div>
                    </div>
                    <div class="col col-5">
                    	<div class="form-group">
                            <input id="add_out_shelf" name="add_out_shelf" type="text" onfocus="islemtipi=0;" value="" />
                        </div>
                    </div>
                    <!---<div class="col col-3">
                    	<div class="form-group">
                            <input id="add_in_shelf" name="add_in_shelf" type="text" onfocus="islemtipi=0;" value="" />
                        </div>
                    </div>--->
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
                            <select name="txt_department_in" id="txt_department_in" style="width:120px; height:20px" onchange="document.getElementById('department_in').value = this.value">
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
        <cfsavecontent variable="title"><cf_get_lang dictionary_id="1289.Palet-Raftan Depoya"></cfsavecontent>
        <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
            <cf_form_list>
                <thead>
                    <tr>
                        <th style="width:50%"><cf_get_lang dictionary_id='57633.Barkod'></th>
                        <th style="width:50%"><cf_get_lang dictionary_id='43312.Çıkış Rafı'></th>
                        <th style="width:30%"><cf_get_lang dictionary_id='57635.Miktar'></th>
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
                            <input type="hidden" id="palet_action_id" name="palet_action_id" value="" />
                            <input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" onClick="kontrol_kayit();" />
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
	function checkKeycode(e) /*Barkod Okuyup Enter Basıldığında*/
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			if (document.getElementById('add_other_barcod').value.length == '' && (document.getElementById('add_out_shelf').value.length >0))
			{
				alert('<cf_get_lang dictionary_id='340.Önce Ürün Barkodu Okutunuz'>');
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_out_shelf').value = '';
				document.getElementById('add_other_amount').value = 1;
				$('#add_other_barcod').focus();	
			}
			else
			{
				if(document.getElementById('add_out_shelf').value.length >0)		
				{
						search_shelf_out(document.getElementById('add_out_shelf').value);
						$('#add_other_barcod').focus();
						if(ekle==0)
						{
							add_row();
						}
						else
						{
							ekle=0;
							document.getElementById('store_amount').value = 0;
							document.getElementById('add_other_barcod').value = '';
							document.getElementById('add_out_shelf').value = '';
							document.getElementById('add_other_barcod').focus();
							return false;	
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
			document.getElementById('add_out_shelf').value = '';
			document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		else /*Palet Bulunduysa*/
		{	
			paletid = get_product.PACKING_ID;
			barcode = get_product.BARCODE;
			if(get_product.TYPE == 1)
				stockcode = '<cf_get_lang dictionary_id='820.Standart Paket'>';
			else if(get_product.TYPE == 2)
				stockcode = '<cf_get_lang dictionary_id='821.Özel Paket'>';
			else if(get_product.TYPE == 3)
				stockcode = '<cf_get_lang dictionary_id='822.Lokasyon Paleti'>';
			document.getElementById('add_out_shelf').focus(); /*Rafa Odaklan*/
			<!---set_shelfs(paletid);--->
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
					/*var palet_content_sql = "SELECT S.STOCK_ID,S.PRODUCT_NAME,EPR.AMOUNT,EPR.SPECT_MAIN_ID,EPR.LOT_NO,EPR.SERIAL_NO FROM STOCKS AS S INNER JOIN EZGI_PACKING_ROW AS EPR ON S.STOCK_ID = EPR.STOCK_ID INNER JOIN EZGI_PACKING AS EP ON EPR.PACKING_ID = EP.PACKING_ID WHERE EP.BARCODE = '"+document.getElementById('add_other_barcod').value+"'";*/ /*Paletin içerik Listesi Alınıyor*/
					/*var get_palet_content = wrk_query(palet_content_sql,'dsn3');*/
					
					var listParam = document.getElementById('add_other_barcod').value;
					var get_palet_content = wrk_safe_query('get_packing_content_barcode_ezgi','dsn3',0,listParam);
					
					if(get_palet_content.recordcount) /*Palet İçeriği Varsa*/
					{
						for(var ii=0;ii<get_palet_content.recordcount;ii++) /*İçerik Dönüyor*/
						{
/*							if(get_palet_content.SPECT_MAIN_ID[ii]==0)
								var product_shelfs="SELECT REAL_STOCK FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE SHELF_CODE = '"+shelf_8+"' AND DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID = "+get_palet_content.STOCK_ID[ii];
							else
								var product_shelfs="SELECT REAL_STOCK FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE SHELF_CODE = '"+shelf_8+"' AND DEPO = '"+form_basket.txt_department_out.value+"' AND STOCK_ID = "+get_palet_content.STOCK_ID[ii]+" AND SPECT_MAIN_ID = "+get_palet_content.SPECT_MAIN_ID[ii];
							var get_product_shelfs = wrk_query(product_shelfs,'dsn2');*/
							
							if(get_palet_content.SPECT_MAIN_ID[ii]==0)
							{
								var listParam = shelf_8 + "*" + form_basket.txt_department_out.value + "*" + get_palet_content.STOCK_ID[ii];
								var get_product_shelfs = wrk_safe_query('get_shelf_depo_stock_id_shelf_ezgi','dsn2',0,listParam);
							}
							else
							{
								var listParam = shelf_8 + "*" + form_basket.txt_department_out.value + "*" + get_palet_content.STOCK_ID[ii] + "*" + get_palet_content.SPECT_MAIN_ID[ii];
								var get_product_shelfs = wrk_safe_query('get_shelf_depo_stock_id_spectmain_shelf_ezgi','dsn2',0,listParam);
							}
							
							if(get_product_shelfs.recordcount == 0 || get_product_shelfs.REAL_STOCK<=0)
							{
								ekle=1;
								alert(get_palet_content.PRODUCT_NAME[ii]+" - <cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='351.Çıkış Rafındaki Stok Miktarı'>: 0");
								document.getElementById('add_out_shelf').value = '';
								document.getElementById('add_out_shelf').focus();
								return false;
							}
							else
							{
								if(get_product_shelfs.REAL_STOCK<document.getElementById('add_other_amount').value)
								{
									ekle=1;
									alert(get_palet_content.PRODUCT_NAME[ii]+" - <cf_get_lang dictionary_id='342.Yetersiz Stok'>. <cf_get_lang dictionary_id='351.Çıkış Rafındaki Stok Miktarı'>: "+get_product_shelfs.REAL_STOCK);
									document.getElementById('add_out_shelf').value = '';
									document.getElementById('add_out_shelf').focus();
									return false;
								}
								else
								{
									document.getElementById('add_other_amount').disabled = true;
									document.getElementById('add_other_barcod').disabled = true;
									document.getElementById('add_out_shelf').disabled = true;
									document.getElementById('txt_department_out').disabled = true;
									
									<!---$('#add_in_shelf').focus();--->
								}
							}
						}
					}
					else
					{
						alert('Paket İçeriği Belirtilmemiştir.!!');
						ekle=1;
						return false;
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
			ekle=1;
			document.getElementById('store_amount').value = 0;
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_out_shelf').value = '';
			document.getElementById('add_other_barcod').focus();
			return false;
		}
	}
	function add_row()
	{
		amount = document.getElementById('add_other_amount').value;
		barcode = document.getElementById('add_other_barcod').value;
		shelf_code = document.getElementById('add_out_shelf').value;
		add_amount(); /*Palet Daha Önece Aynı Rafa Okutulmuş mu Kontrol Et*/
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
			newCell.innerHTML = '<input type="hidden" value="'+paletid+'" name="paletid'+row_count+'" id="paletid'+row_count+'" /><input type="hidden" value="'+spectmainid+'" name="spectmainid'+row_count+'" id="spectmainid'+row_count+'" /><input type="text" value="'+barcode+'" name="barcod'+row_count+'" id="barcod'+row_count+'" size="13" readonly="yes" style="border:none;height:20px"/>';
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="text" value="'+document.getElementById('add_out_shelf').value+'" name="shelf_code_out'+row_count+'" id="shelf_code_out'+row_count+'" size="12" readonly="yes" style="text-align:right;border:none;height:20px" />';
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="text" style="text-align:right;border:none;height:20px" value="'+amount+'" name="amount'+row_count+'" id="amount'+row_count+'" size="5" readonly="yes" />';
			
				
		}
		else
		{
			 ekle = 0;
		}
		document.getElementById('add_other_amount').disabled = false;
		document.getElementById('add_other_barcod').disabled = false;
		document.getElementById('add_out_shelf').disabled = false;
		document.getElementById('add_other_barcod').value = '';
		document.getElementById('add_out_shelf').value = '';
		document.getElementById('add_other_amount').value = 1;
		document.getElementById('add_other_barcod').focus();
	}
	function add_amount()
	{
		ekle = 0;
		row_count = document.getElementById('row_count').value;	
		for(i=1;i<=row_count;i++)
		{
			if(document.getElementById('paletid'+i).value == paletid) <!---Palet Sadece 1 kez girilebilir--->
			{
				alert('Paleti 2. Kez Giriş Yapamzsınız')	
				ekle = 1;
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_out_shelf').value = '';
				document.getElementById('add_other_amount').value = 1;
				document.getElementById('add_other_barcod').focus();
				return false;
			}
	   	}
	}
	function kontrol_kayit()
	{
		row_count = document.getElementById('row_count').value;	
		if(row_count >0) /*ilk Satırdan sonrası*/
	  	{
			stock_control()
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
				window.location.href='<cfoutput>#request.self#</cfoutput>?fuseaction=pda.add_ambar_fis&tersfis=1&palet_killer=1&ambarfis=12&dep_in='+form_basket.txt_department_in.value+'&dep_out='+form_basket.txt_department_out.value+'&palet_action_id='+document.getElementById('palet_action_id').value+'&fis_tipi='+form_basket.fis_tipi.value+'&process_cat='+form_basket.process_cat_id.value;
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
		row_count = document.getElementById('row_count').value;	
		palet_id_list='';
		amount_list='';
		for(i=1;i<=row_count;i++) /*Satırlardaki paletler ve Bunlara Bağlı okutulan Miktarlar Toplanıyor*/
		{
			palet_id = document.getElementById('paletid'+i).value;
			amount = document.getElementById('amount'+i).value;
			if(list_find(palet_id_list,palet_id))
			{
				paletamount=list_getat(amount_list,list_find(palet_id_list,palet_id));
				paletamount=paletamount- (-1 * amount);
				amount_list=list_setat(amount_list,list_find(palet_id_list,palet_id),paletamount)
			}
			else
			{
				palet_id_list += palet_id+',';
				amount_list += amount+',';
			}
		}
		palet_id_list = palet_id_list.substr(0,palet_id_list.length-1);//sondaki virgülden kurtariyoruz.
		amount_list = amount_list.substr(0,amount_list.length-1);//sondaki virgülden kurtariyoruz.
		//Palet miktarları Bulundu Şimdi Palet İçindeki Stok Miktarlarını Palet Miktarlarıyla Oranlayıp Toplam Stok Miktarını Bulacağız.
		if(list_len(palet_id_list))
		{
			dongu = list_len(palet_id_list);
			palet_stock_id_list='';
			palet_stock_amount_list='';
			for(c=1;c<=dongu;c++)
			{
				packing_id = list_getat(palet_id_list,c);
				packing_amount = list_getat(amount_list,c);
				/*var packing_sql = "SELECT EP.PACKING_ID, EP.BARCODE, EPR.AMOUNT, S.STOCK_ID, EPR.SPECT_MAIN_ID, EPR.LOT_NO, EPR.SERIAL_NO FROM STOCKS AS S INNER JOIN EZGI_PACKING_ROW AS EPR ON S.STOCK_ID = EPR.STOCK_ID INNER JOIN EZGI_PACKING AS EP ON EPR.PACKING_ID = EP.PACKING_ID WHERE EP.PACKING_ID ="+packing_id;
				var get_packing_stock = wrk_query(packing_sql,'dsn3');*/
				
				var listParam = packing_id;
				var get_packing_stock = wrk_safe_query('get_packing_packing_id_ezgi','dsn3',0,listParam);
				
				if(get_packing_stock.recordcount)
				{
					for(var aa=0;aa<get_packing_stock.recordcount;aa++) /*İçerik Dönüyor*/
					{
						stock_id = get_packing_stock.STOCK_ID[aa];
						stock_amount = get_packing_stock.AMOUNT[aa]
						if(list_find(palet_stock_id_list,stock_id))
						{
							row_stock_amount=stock_amount*packing_amount; /*Paletteki Stok miktarı ile PDA Palet sayım Miktarını çarparak satır toplamını buluyoruz.*/
							list_stock_amount=list_getat(palet_stock_amount_list,list_find(palet_stock_amount_list,stock_id));
							list_stock_amount=list_stock_amount- (-1 * row_stock_amount);
							palet_stock_amount_list=list_setat(palet_stock_amount_list,list_find(palet_stock_amount_list,stock_id),list_stock_amount)
							
						}
						else
						{
							
						}
					}
				}
			}
		}
		else
		{
			alert('Palet Okutulmamış');
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
				document.getElementById('palet_action_id').value = document.getElementById('palet_action_id').value + ',';
				document.getElementById('palet_action_id').value = document.getElementById('palet_action_id').value + i + '-';
				document.getElementById('palet_action_id').value = document.getElementById('palet_action_id').value + document.getElementById('paletid'+i).value + '-';
				document.getElementById('palet_action_id').value = document.getElementById('palet_action_id').value + document.getElementById('amount'+i).value + '-';
				document.getElementById('palet_action_id').value = document.getElementById('palet_action_id').value + document.getElementById('shelf_code_out'+i).value + '-';
				document.getElementById('palet_action_id').value = document.getElementById('palet_action_id').value + '0'+ '-';
				document.getElementById('palet_action_id').value = document.getElementById('palet_action_id').value + '0';
				j++;
		  	}
		  	document.getElementById('row_count').value = j;
	  	}
	}
</script>