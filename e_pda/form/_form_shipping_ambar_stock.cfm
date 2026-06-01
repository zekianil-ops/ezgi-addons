<!---
    File: form_shipping_ambar_stock.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<script language="javascript" type="text/javascript">
	var islemtipi = 0;//0-ekle 1-çıkar
	var buton = 0;// <1-buton pasif, >0-buton aktif
  </script>
  <cfquery name="get_defaults" datasource="#dsn3#">
	  SELECT * FROM EZGI_SHIPPING_DEFAULTS
  </cfquery>
  <cfset default_process_type = 113> 
  <cfparam name="attributes.department_in_id" default="">
  <cfparam name="attributes.department_out_id" default="">
  <cfquery name="get_process_cat" datasource="#DSN3#">
	  SELECT TOP (1)    
		  SPC.PROCESS_CAT_ID
	  FROM         
		  SETUP_PROCESS_CAT AS SPC INNER JOIN
			SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
		  SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	  WHERE     
		  SPC.PROCESS_TYPE = #default_process_type# AND 
		  SPCF.FUSE_NAME = 'pda.form_shipping_ambar_stock' 
		ORDER BY
		  SPC.PROCESS_CAT_ID DESC      
  </cfquery>
  <cfif not get_process_cat.recordcount>
	  <script type="text/javascript">
		  alert("<cf_get_lang dictionary_id='333.İşlem Kategorisi Tanımlayınız!'>");
		  history.back();	
	  </script>
  </cfif>
  <cfquery name="get_stock_info" datasource="#dsn3#">
	  SELECT        
		  SB.STOCK_ID, 
		  SB.BARCODE, 
		  S.PRODUCT_NAME, 
		  S.STOCK_CODE, 
		  S.STOCK_CODE_2
	  FROM            
		  STOCKS_BARCODES AS SB INNER JOIN
			 STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID
	  WHERE        
		  SB.STOCK_ID = #attributes.f_stock_id#
  </cfquery>
  <cfquery name="get_store_type" datasource="#dsn3#">
	  SELECT        
		  COUNT(*) AS RAF
	  FROM            
		  PRODUCT_PLACE
	  WHERE        
		  LOCATION_ID = #ListGetAt(attributes.department_out_id,2,"-")#  AND 
		  STORE_ID = #ListGetAt(attributes.department_in_id,1,"-")# AND 
		  PLACE_STATUS = 1
  </cfquery>
  <cfquery name="get_ambar_fis" datasource="#dsn2#">
		  SELECT        
			  SUM(SFR.AMOUNT) AS AMOUNT, 
			  PP.SHELF_CODE, 
			  S.STOCK_CODE, 
			  S.PRODUCT_ID, 
			  S.PROPERTY, 
			  S.BARCOD, 
			  S.PRODUCT_NAME,
			  SFR.STOCK_ID
		  FROM 
			  STOCK_FIS AS SF INNER JOIN
				STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID INNER JOIN
				 #dsn3_alias#.STOCKS AS S ON SFR.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
			   #dsn3_alias#.PRODUCT_PLACE AS PP ON SFR.SHELF_NUMBER = PP.PRODUCT_PLACE_ID          
		  WHERE        
			  SF.REF_NO = '#attributes.deliver_paper_no#' AND 
			  SFR.STOCK_ID = #attributes.f_stock_id#
			  <cfif isdefined('attributes.spect_main_id') and attributes.spect_main_id gt 0>
				  AND SFR.SPECT_VAR_ID IN (SELECT SPECT_VAR_ID FROM #dsn3_alias#.SPECTS WHERE SPECT_MAIN_ID = #attributes.spect_main_id#)
			  </cfif>
		  GROUP BY 
			  PP.SHELF_CODE, 
			  S.STOCK_CODE, 
			  S.PRODUCT_ID, 
			  S.PROPERTY, 
			  S.BARCOD, 
			  S.PRODUCT_NAME,
			  SFR.STOCK_ID
  </cfquery>
  <cfif get_store_type.raf gt 0>
	  <cfquery name="get_shelf_stock" datasource="#dsn2#">
		  SELECT 
			  REAL_STOCK, 
			  SHELF_CODE,
			  PRODUCT_PLACE_ID
		  FROM     
			  EZGI_GET_SPECT_SHELF_LOCATION_TOTAL
		  WHERE 
			  REAL_STOCK > 0 AND 
			  STOCK_ID = #attributes.f_stock_id# AND 
			  <cfif isdefined('attributes.spect_main_id') and attributes.spect_main_id gt 0>
				  SPECT_MAIN_ID = #attributes.spect_main_id# AND 
			  </cfif>
			  DEPO = '#attributes.department_out_id#'
		  ORDER BY 
			  REAL_STOCK DESC
	  </cfquery>
	  <cfif get_shelf_stock.recordcount>
		  <cfquery name="get_shelf_stock_group" dbtype="query">
			  SELECT
				  SUM(REAL_STOCK) AS REAL_STOCK
				FROM
				  get_shelf_stock
		  </cfquery>
		  <cfif not len(get_shelf_stock_group.REAL_STOCK) and get_shelf_stock_group.REAL_STOCK eq 0>
			  <script type="text/javascript">
				  alert("Ürün Bu Lokasyonda Bulunmamamktadır.");
				  window.history.go(-1);
			  </script>
			  <cfabort>
		  </cfif>
	  <cfelse>
		  <script type="text/javascript">
			  alert("Ürün Bu Lokasyonda Bulunmamamktadır.");
			  window.history.go(-1);
		  </script>
		  <cfabort>
	  </cfif>
  <cfelse>
	  <cfquery name="get_ambar_fis" dbtype="query">
		  SELECT        
			  SUM(AMOUNT) AS AMOUNT,
			  STOCK_CODE, 
			  PRODUCT_ID, 
			  PROPERTY, 
			  BARCOD, 
			  PRODUCT_NAME,
			  STOCK_ID
		  FROM            
			  get_ambar_fis
			GROUP BY
			  STOCK_CODE, 
			  PRODUCT_ID, 
			  PROPERTY, 
			  BARCOD, 
			  PRODUCT_NAME,
			  STOCK_ID
		 </cfquery>
	  <cfquery name="get_depo_stok" datasource="#dsn2#">
		  SELECT 
			  PRODUCT_STOCK 
			 FROM 
		  <cfif isdefined('attributes.spect_main_id') and attributes.spect_main_id gt 0>
			  EZGI_GET_SPECT_LOCATION_TOTAL
		  <cfelse>
			  EZGI_GET_STOCK_LOCATION_TOTAL
		  </cfif>
			 WHERE  
			  DEPO = '#attributes.department_out_id#' AND 
			  STOCK_ID =#attributes.f_stock_id#
			  <cfif isdefined('attributes.spect_main_id') and attributes.spect_main_id gt 0>
				  AND SPECT_MAIN_ID = #attributes.spect_main_id#
			  </cfif>
	  </cfquery>
	  <cfif get_depo_stok.PRODUCT_STOCK lte 0>
		  <script type="text/javascript">
			  alert("Ürün Bu Lokasyonda Bulunmamamktadır.");
			  window.history.go(-1);
		  </script>
		  <cfabort>
	  </cfif>
  </cfif>
  <cfquery name="get_ambar_fis_group" datasource="#dsn2#">
		  SELECT        
			  ISNULL(SUM(SFR.AMOUNT),0) AS AMOUNT
		  FROM            
			  STOCK_FIS AS SF INNER JOIN
			   STOCK_FIS_ROW AS SFR ON SF.FIS_ID = SFR.FIS_ID
		  WHERE 
			  SF.REF_NO = '#attributes.deliver_paper_no#' AND 
			  SFR.STOCK_ID = #attributes.f_stock_id#
			  <cfif isdefined('attributes.spect_main_id') and attributes.spect_main_id gt 0>
				  AND SFR.SPECT_VAR_ID IN 
									  (
										  SELECT 
											  SPECT_VAR_ID
										  FROM     
											  #dsn3_alias#.SPECTS
										  WHERE  
											  SPECT_MAIN_ID = #attributes.spect_main_id#
										 )
			  </cfif>
  </cfquery>
  <cfif get_ambar_fis_group.recordcount>
	  <cfset all_amount = attributes.paket_sayisi-get_ambar_fis_group.amount>
  <cfelse>
	  <cfset all_amount = attributes.paket_sayisi>
  </cfif>
  <cfform name="form_basket">
		<cfinput id="txt_department_out" name="txt_department_out" type="hidden" value="#attributes.department_out_id#">
		<cfinput id="txt_department_in" name="txt_department_in" type="hidden" value="#attributes.department_in_id#">
		<cfinput id="process_cat_id" type="hidden" name="process_cat_id" value="#get_process_cat.process_cat_id#">
		<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
		<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
		  <cf_box scroll="0">
			  <cf_box_search>
				  <div class="col col-12">
					  <div class="col col-2">
						  <cf_get_lang dictionary_id='57635.Miktar'>
					  </div>
					  <div class="col col-5">
						  <cf_get_lang dictionary_id='57633.Barkod'>
					  </div>
					  <cfif get_store_type.raf gt 0>
					  <div class="col col-5">
						  <cf_get_lang dictionary_id='36714.Raf'>
					  </div>
					  </cfif>
					</div>
				  
				  <div class="col col-12">
					  <div class="col col-2">
						  <div class="form-group">
							  <input id="add_other_amount" name="add_other_amount" type="text" onfocus="islemtipi=0;" value="1" />
						  </div>
					  </div>
					  <div class="col col-5">
						  <div class="form-group">
							  <input id="add_other_barcod" name="add_other_barcod" type="text" value="" >
						  </div>
					  </div>
					  <cfif get_store_type.raf gt 0>
					  <div class="col col-5">
						  <div class="form-group">
							  <input id="add_other_shelf" name="add_other_shelf" type="text" onfocus="islemtipi=0;" value="" />
						  </div>
					  </div>
					  </cfif>
					 </div>
				  <input type="hidden" value="" name="anabarcode" id="anabarcode">
					 <cfinput type="hidden" value="#all_amount#" name="all_amount" id="all_amount" >
					<cfinput type="hidden" value="#attributes.paket_sayisi#" name="paket_sayisi" id="paket_sayisi">
				</cf_box_search>
		  </cf_box>
		  <cfsavecontent variable="title"><cf_get_lang dictionary_id="8.Depodan Sevkiyata"></cfsavecontent>
		  <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
			  <cf_form_list>
				  <thead>
					  <tr>
						  <th style="width:20%"><cf_get_lang dictionary_id='57633.Barkod'></th>
						  <th style="width:100%"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
						  <th style="width:15%"><cf_get_lang dictionary_id='57635.Miktar'></th>
						  <cfif get_store_type.raf gt 0>
						  <th style="width:20%"><cf_get_lang dictionary_id='36714.Raf'></th>
						  </cfif>
					  </tr>
				  </thead>
				  <form name="product_row" id="product_row" method="post">
					  <tbody id="table0">
						  <cfoutput query="get_ambar_fis">
							  <tr height="20">
								  <td><cfinput type="text" value="#barcod##attributes.spect_main_id#" name="barcod" id="barcod" size="13" readonly="yes" style="font-weight:bold; border:none" /></td>
								  <td><cfinput type="text" value="#PRODUCT_NAME#" name="stockcode" id="stockcode" size="15" readonly="yes" style="font-weight:bold; border:none" /></td>
								  <td><cfinput type="text" value="#amount#" name="amount" id="amount" size="4" readonly="yes" style="text-align:right;font-weight:bold; border:none" /></td>
								  <cfif get_store_type.raf gt 0>
									  <td><cfinput type="text" value="#shelf_code#" name="shelf_code" id="shelf_code" size="8" readonly="yes" style="text-align:right;font-weight:bold; border:none" /></td>
								  </cfif>
							  </tr>
						  </cfoutput>
					  </tbody>
					  <tbody id="table1">
					  </tbody>
					  <cfinput type="hidden" id="row_count" name="row_count" value="0" />
				  </form>
				  <tfoot>
					  <tr>
						  <td  style="text-align:left" colspan="5" title="<cf_get_lang dictionary_id='39425.Depo Miktarı'>">
							  <table width="100%">
								  <tr>
									  <td width="40%" style="text-align:left">
										  <cfif get_store_type.raf gt 0>
											  <select name="shelf_select" style="width:100%; text-align:left; height:30px">
												  <cfoutput query="get_shelf_stock">
													  <option value="">#SHELF_CODE# - #REAL_STOCK#</option>
												  </cfoutput>
											  </select>
										  <cfelse>
											  <cf_get_lang dictionary_id='39425.Depo Miktarı'> : <cfoutput>#AmountFormat(get_depo_stok.product_stock)#</cfoutput>
										  </cfif>
									  </td>
									  <td width="60%">
										  <input type="hidden" id="department_in" name="department_in" value="" />
										  <input type="hidden" id="action_id" name="action_id" value="" />
										  <input id="geri" name="geri" value="Vazgeç" type="button" onClick="history.go(-1);" />
										  <input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" disabled="disabled" onClick="kontrol_kayit();" />
									  </td>
									 </tr>
								</table>
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
	  row_count=document.getElementById('row_count').value;
	  document.onkeydown = checkKeycode
	  function checkKeycode(e) 
	  {
		  ekle=0;
		  var keycode;
		  if (window.event) keycode = window.event.keyCode;
		  else if (e) keycode = e.which;
		  if (keycode == 13)
		  {
			  <cfoutput>
				  f_barcode = '#get_stock_info.barcode#';
				  f_spect_main_id = #attributes.spect_main_id#;
				  f_stock_id = #attributes.f_stock_id#;
				  f_amount = #all_amount#;
				  stockcode = '#get_stock_info.PRODUCT_NAME#';
			  </cfoutput>
			  if(document.getElementById('add_other_amount').value=='' && document.getElementById('add_other_amount').value<=0)
			  {
				  ekle = 1;
				  alert('<cf_get_lang dictionary_id='344.Miktar 0 dan Büyük Olmalıdır'>');
				  document.getElementById('add_other_amount').value = 1;
				  document.getElementById('add_other_amount').focus();
			  }
			  else if(document.getElementById('add_other_amount').value>document.getElementById('paket_sayisi').value)
			  {
				  ekle = 1;
				  alert('Miktar, Sevk Edilecek Miktardan Daha Fazladır!');
				  document.getElementById('add_other_amount').value = 1;
				  document.getElementById('add_other_amount').focus();
			  }
			  else
			  {
				  if (document.getElementById('add_other_barcod').value.length >0) 
				  {
					  barcode = document.getElementById('add_other_barcod').value;
					  if(barcode.substr(0,1)=='j')//Bazı barkod okuyucular okuduktan sonra başına j harfi koyuyor kontrol için yapıldı
						  barcode = barcode.substring(1,length(barcode));
					  uzunluk = barcode.length;
					  spectmainid = 0;
					  document.getElementById('anabarcode').value=barcode;
					  ean = <cfoutput>#get_defaults.EAN#</cfoutput>;
					  if(uzunluk > ean)
					  {
						  spectmainid = barcode.substring(ean,uzunluk);
						  barcode = barcode.substring(0,ean);
					  }
					  if(barcode!=f_barcode)
					  {
						  ekle = 1;
						  alert('Sevk Edilecek Ürün Bu Değildir.');
						  document.getElementById('add_other_barcod').value='';
						  document.getElementById('add_other_barcod').focus();
						  return false;
					  }
					  else
					  {
						  if(f_spect_main_id >0 && spectmainid ==0)
						  {
							  ekle = 1;
							  alert('<cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'> : <cf_get_lang dictionary_id='36006.Spekt ID'>');
							  document.getElementById('add_other_barcod').value='';
							  document.getElementById('add_other_barcod').focus();
							  return false;
						  }
						  if(f_spect_main_id >0 && spectmainid!=f_spect_main_id)
						  {
							  ekle = 1;
							  alert('Sevk Edilecek Spekt Bu Değildir.');
							  document.getElementById('add_other_barcod').value='';
							  document.getElementById('add_other_barcod').focus();
							  return false;
						  }
					  }
					  <cfif get_store_type.raf gt 0>
						  document.getElementById('add_other_shelf').focus();
						  if (document.getElementById('add_other_shelf').value.length >0)
						  {
						  
							  	if(spectmainid>0)
								{
								  	/*var stock_sql = "SELECT REAL_STOCK FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE SHELF_CODE = '"+document.getElementById('add_other_shelf').value+"' AND DEPO = '"+document.all.txt_department_out.value+"' AND STOCK_ID = "+stockid+" AND SPECT_MAIN_ID = "+spectmainid;*/
									var listParam = document.getElementById('add_other_shelf').value + "*" + document.all.txt_department_out.value + "*" + stockid + "*" + spectmainid;
									var get_real_stock = wrk_safe_query('get_shelf_depo_stock_id_spectmain_shelf_ezgi','dsn2',0,listParam);
								}
							  	else
								{
								  /*var stock_sql = "SELECT REAL_STOCK FROM EZGI_GET_SPECT_SHELF_LOCATION_TOTAL WHERE SHELF_CODE = '"+document.getElementById('add_other_shelf').value+"' AND DEPO = '"+document.all.txt_department_out.value+"' AND STOCK_ID = "+stockid;*/
									var listParam = document.getElementById('add_other_shelf').value + "*" + document.all.txt_department_out.value + "*" +stockid;
									var get_real_stock = wrk_safe_query('get_shelf_depo_stock_id_shelf_ezgi','dsn2',0,listParam);;	
								}
								/*var get_real_stock = wrk_query(stock_sql,'dsn2');*/
							  
							  
							  	if(get_real_stock.REAL_STOCK==undefined)
								  get_real_stock.REAL_STOCK = 0;
							 	if(row_count>0)
							  	{
								  f_stock_amount = 0;
								  for(i=1;i<=row_count;i++)
								  {
									  f_stock_amount = f_stock_amount -(-1*document.getElementById('amount'+i).value)
									  if((f_stock_amount-(-1*document.getElementById('add_other_amount').value))>f_amount)
									  {
										  ekle = 1;
										  alert('Miktar, Sevk Edilecek Miktardan Daha Fazladır!');
										  document.getElementById('add_other_shelf').value = '';
										  document.getElementById('add_other_barcod').value = '';
										  document.getElementById('add_other_amount').value = 1;
										  document.getElementById('add_other_barcod').focus();
										  return false;
									  }
									  else
									  {
										  if(document.getElementById('shelf_code'+i).value == document.getElementById('add_other_shelf').value)
										  {
											  if((get_real_stock.REAL_STOCK*1) < (document.getElementById('add_other_amount').value*1)-(-1*document.getElementById('amount'+i).value))
											  {
												  ekle=1;
												  alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. Raf Stok Miktarı : "+get_real_stock.REAL_STOCK);
												  document.getElementById('add_other_shelf').value = '';
												  document.getElementById('add_other_barcod').value = '';
												  document.getElementById('add_other_amount').value = 1;
												  document.getElementById('add_other_barcod').focus();
												  return false;
											  }
											  else
											  {
												  ekle = 1;
												  document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1*document.getElementById('add_other_amount').value);
												  document.getElementById('add_other_shelf').value = '';
												  document.getElementById('add_other_barcod').value = '';
												  document.getElementById('add_other_amount').value = 1;
												  document.getElementById('add_other_barcod').focus();
											  }
										  }
										  else
										  {
											  if((get_real_stock.REAL_STOCK*1) < (document.getElementById('add_other_amount').value*1))
											  {
												  ekle=1;
												  alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. Raf Stok Miktarı : "+get_real_stock.REAL_STOCK);
												  document.getElementById('add_other_shelf').value = '';
												  document.getElementById('add_other_barcod').value = '';
												  document.getElementById('add_other_amount').value = 1;
												  document.getElementById('add_other_barcod').focus();
												  return false;
											  }
										  }
									  }
								  }
								  {
									  buton_kontrol();
									  add_row();
								  }
							  }
							  else
							  {
								  if((get_real_stock.REAL_STOCK*1) < (document.getElementById('add_other_amount').value*1))
								  {
									  ekle=1;
									  alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. Raf Stok Miktarı : "+get_real_stock.REAL_STOCK);
									  document.getElementById('add_other_shelf').value = '';
									  document.getElementById('add_other_barcod').value = '';
									  document.getElementById('add_other_amount').value = 1;
									  document.getElementById('add_other_barcod').focus();
									  return false;
								  }
								  else
								  {
									  buton_kontrol();
									  add_row();
								  }
							  }
							}
					  <cfelse>
						  amount = <cfoutput>#get_depo_stok.product_stock#</cfoutput>;
						  if(row_count>0)
						  {
							  
							  if((document.getElementById('amount1').value -(-1*document.getElementById('add_other_amount').value))>f_amount)
							  {
								  ekle = 1;
								  alert('Miktar, Sevk Edilecek Miktardan Daha Fazladır!');
								  document.getElementById('add_other_barcod').value = '';
								  document.getElementById('add_other_amount').value = 1;
								  document.getElementById('add_other_barcod').focus();
								  return false;
							  }
							  if((document.getElementById('amount1').value -(-1*document.getElementById('add_other_amount').value))>amount)
							  {
								  ekle = 1;
								  alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. Depo Stok Miktarı : "+amount);
								  document.getElementById('add_other_barcod').value = '';
								  document.getElementById('add_other_amount').value = 1;
								  document.getElementById('add_other_barcod').focus();
								  return false;
							  }
							  else
								  document.getElementById('amount1').value = document.getElementById('amount1').value-(-1*document.getElementById('add_other_amount').value);
								  document.getElementById('add_other_barcod').value = '';
								  document.getElementById('add_other_amount').value = 1;
								  document.getElementById('add_other_barcod').focus();
						  }
						  else
						  {
							  if(document.getElementById('add_other_amount').value>amount)
							  {
								  ekle = 1;
								  alert("<cf_get_lang dictionary_id='342.Yetersiz Stok'>. Depo Stok Miktarı : "+amount);
								  document.getElementById('add_other_barcod').value = '';
								  document.getElementById('add_other_amount').value = 1;
								  document.getElementById('add_other_barcod').focus();
								  return false;
							  }
							  else
							  {
								  buton_kontrol();
								  add_row();
							  }
						  }
					  </cfif>
				  }
			  }
		  }
	  }
	  function add_row()
	  {
		  barcode=document.getElementById('anabarcode').value;
		  if (ekle == 0)
		  {
			  amount=document.getElementById('add_other_amount').value;
			  <cfif get_store_type.raf gt 0>
				  shelf_code=document.getElementById('add_other_shelf').value;
			  </cfif>
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
			  newCell.innerHTML = '<input type="hidden" value="'+f_stock_id+'" name="stockid'+row_count+'" id="stockid'+row_count+'" /><input type="hidden" value="'+spectmainid+'" name="spectmainid'+row_count+'" id="spectmainid'+row_count+'" /><input type="text" value="'+barcode+'" name="barcod'+row_count+'" id="barcod'+row_count+'" size="13" readonly="yes" style="height:20px;border:none"/>';
			  newCell = newRow.insertCell();
			  newCell.innerHTML = '<input type="text" value="'+stockcode+'" name="stockcode'+row_count+'" id="stockcode'+row_count+'" size="15" readonly="yes" style="border:none"/>';
			  newCell = newRow.insertCell();
			  newCell.innerHTML = '<input type="text" value="'+amount+'" name="amount'+row_count+'" id="amount'+row_count+'" size="5" readonly="yes" style="text-align:right;border:none"/>';
			  <cfif get_store_type.raf gt 0>
				  newCell = newRow.insertCell();
				  newCell.innerHTML = '<input type="text" value="'+shelf_code+'" name="shelf_code'+row_count+'" id="shelf_code'+row_count+'" size="8" readonly="yes" style="border:none" />';
				  document.getElementById('add_other_shelf').value = '';
			  </cfif>
			  document.getElementById('add_other_barcod').value = '';
			  document.getElementById('add_other_amount').value = 1;
			  document.getElementById('add_other_barcod').focus();
		  }
		  else
		  {
			  ekle = 0;
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
	  function kontrol_kayit()
	  {
		  document.getElementById('onay').disabled = true;
		  if(form_basket.txt_department_out.value == "")
		  {
			  document.getElementById('onay').disabled = false;
			  alert('<cf_get_lang dictionary_id='57723.Önce Depo Seçmelisiniz'>');
			  return false;
		  }
		  else if(form_basket.txt_department_out.value.indexOf('-') == -1)
		  {
			  document.getElementById('onay').disabled = false;
			  alert('<cf_get_lang dictionary_id='349.Lütfen giriş için doğru depo seçiniz'>');
			  return false;
		  }
		  else
		  {
			  actionidolustur();
			  window.location.href='<cfoutput>#request.self#?fuseaction=pda.add_ambar_fis&ambarfis=6&tersfis=1&date1=#attributes.date1#&date2=#attributes.date2#&is_type=#attributes.is_type#&keyword=#attributes.keyword#&dep_in=#attributes.department_in_id#&dep_out=#attributes.department_out_id#&ref_no=#attributes.deliver_paper_no#&ship_id=#attributes.ship_id#</cfoutput>&action_id='+document.getElementById('action_id').value+'&fis_tipi='+document.form_basket.fis_tipi.value+'&process_cat='+document.form_basket.process_cat_id.value;
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
				  <cfif get_store_type.raf gt 0>
					  document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('shelf_code'+i).value + '-';
				  <cfelse>
					  document.getElementById('action_id').value = document.getElementById('action_id').value + '0'+ '-';
				  </cfif>
				  document.getElementById('action_id').value = document.getElementById('action_id').value + '0'+ '-';
				  document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('spectmainid'+i).value;
				  j++;
				}
				document.getElementById('row_count').value = j;
			}
	  }
  </script>
  