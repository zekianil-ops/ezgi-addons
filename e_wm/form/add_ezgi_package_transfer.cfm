<!---
    File: add_ezgi_package_transfer.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Paket Transfer
---> 
<cfset default_process_type = 113>
<cfset PACKING_ACTION_TYPE_ID = 3> <!---Palet İşlem Tipi - (Palet Ambara Transfer)--->
<cfquery name="get_default_departments" datasource="#dsn3#">
	SELECT 
    	INTERMEDIATE_WAREHOUSE, 
        PRODUCTION_WAREHOUSE,
        SHELF_WAREHOUSE,
        FIRST_SHELF_ID
	FROM     
    	EZGI_WM_SETUP_ROW
	WHERE  
    	EMPLOYEE_POSITION_ID = #session.ep.POSITION_CODE#
</cfquery>
<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>
<cfset default_departments = '#ListGetAt(get_default_departments.PRODUCTION_WAREHOUSE,1)#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
<cfparam name="attributes.department_in_id" default="#get_default_departments.SHELF_WAREHOUSE#">
<cfparam name="attributes.department_out_id" default="#get_default_departments.SHELF_WAREHOUSE#">
<cfquery name="GET_ALL_LOCATION" datasource="#DSN#">
	SELECT        
    	D.DEPARTMENT_HEAD, 
        SL.DEPARTMENT_ID, 
        SL.LOCATION_ID, 
        SL.STATUS, 
        SL.COMMENT,
   	 	D.DEPARTMENT_HEAD + ' - ' + SL.COMMENT AS DEPO_NAME, 
        CAST(D.DEPARTMENT_ID AS VARCHAR)+ '-' + CAST(SL.LOCATION_ID AS VARCHAR) AS DEPO
	FROM            
  		STOCKS_LOCATION AS SL INNER JOIN
        DEPARTMENT AS D ON SL.DEPARTMENT_ID = D.DEPARTMENT_ID INNER JOIN
        BRANCH AS B ON D.BRANCH_ID = B.BRANCH_ID LEFT OUTER JOIN
        #dsn3_alias#.PRODUCT_PLACE AS PP ON SL.LOCATION_ID = PP.LOCATION_ID AND SL.DEPARTMENT_ID = PP.STORE_ID
	WHERE        
    	D.DEPARTMENT_ID IN (#default_departments#) AND 
        SL.STATUS = 1 AND 
        PP.PRODUCT_PLACE_ID IS NULL
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
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
        <cfform name="add_ezgi_package_transfer" >
         	<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
            <cfinput id="precess_no" type="hidden" name="precess_no" value="0">
          	<input type="hidden" name="active_period" value="#session.ep.period_id#" />
            <input type="hidden" name="kapma_process" id="kapma_process" value="0" />
            <cf_basket_form id="add_ezgi_package_transfer">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
                         	<cf_box_elements>
                            	<div class="col col-12 uniqueRow" id="first_area">
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id="57637.Seri No"></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group" id="item-barcod">
                                                <input id="add_other_barcod" name="add_other_barcod" type="text" value="">
                                            </div>
                                        </div>
                                    </div>
                               	</div>
                                
                                <div class="col col-12" style="display:none" id="third_area">
                                	<div class="col col-12">
                                        <div class="col col-12">
                                            <label><strong><cf_get_lang dictionary_id='1329.Paket Lokasyon Bilgisi'> (<cf_get_lang dictionary_id='57554.Giriş'>)</strong></label>
                                        </div>
                                  	</div> 
                                    <div class="col col-12">
                                        <div class="col col-4">
                                            <label><cf_get_lang dictionary_id='45667.Raf'></label>
                                        </div>
                                        <div class="col col-4">
                                            <label><cf_get_lang dictionary_id='37244.Palet'></label>
                                        </div>
                                        <div class="col col-4">
                                            <label><cf_get_lang dictionary_id='58763.Depo'></label>
                                        </div>
                                    </div>
                                    <div class="col col-12">
                                        <div class="col col-4">
                                            <div class="form-group" id="item-giris_raf" >
                                            	<cfinput type="text" name="txt_shelf_in_name" id="txt_shelf_in_name" value="">
                                                <cfinput type="hidden" name="txt_shelf_in" id="txt_shelf_in" value="">
                                            </div>
                                        </div>
                                        <div class="col col-4">
                                            <div class="form-group" id="item-giris_palet">
                                            	<cfinput type="text" name="txt_packing_in_name" id="txt_packing_in_name" value="">
                                                <cfinput type="hidden" name="txt_packing_in" id="txt_packing_in" value="">
                                            </div>
                                        </div>
                                        <div class="col col-4"  id="giris_depo_select">
                                        	<div class="form-group" id="item-giris_depo_select">
                                            	<select name="txt_department_in_select" id="txt_department_in_select" onChange="select_depo(this.value);">
                                                	<option value=""><cf_get_lang dictionary_id="57734.Seçiniz"></option>
                                                	<cfoutput query="GET_ALL_LOCATION">
                                                    	<option value="#DEPO#">#DEPO_NAME#</option>
                                                    </cfoutput>
                                                </select>
                                        	</div>
                                        </div>
                                        <div class="col col-4" id="giris_depo_input" style="display:none">
                                        	<div class="form-group" id="item-giris_depo_input">
                                          		<cfinput type="text" name="txt_department_in_name" id="txt_department_in_name" value="">
                                                <cfinput type="hidden" name="txt_department_in" id="txt_department_in" value="">
                                        	</div>
                                        </div>
                                    </div>
                             	</div>
                                
                                <div class="col col-12" style="display:none" id="second_area">
                                    <div class="col col-12">
                                        <div class="col col-12">
                                            <label><strong><cf_get_lang dictionary_id='1329.Paket Lokasyon Bilgisi'> (<cf_get_lang dictionary_id='57431.Çıkış'>)</strong></label>
                                        </div>
                                  	</div>  
                                    <div class="col col-12">
                                    	<div class="form-group" id="item-cikis_depo">
                                    		<cfinput type="text" name="txt_product_name" id="txt_product_name" value="">
                                        </div>
                                    </div>
                                    <div class="col col-12">
                                        <div class="col col-4">
                                            <label><cf_get_lang dictionary_id='45667.Raf'></label>
                                        </div>
                                        <div class="col col-4">
                                            <label><cf_get_lang dictionary_id='37244.Palet'></label>
                                        </div>
                                        <div class="col col-4">
                                            <label><cf_get_lang dictionary_id='58763.Depo'></label>
                                        </div>
                                    </div>
                                    <div class="col col-12">
                                        <div class="col col-4">
                                            <div class="form-group" id="item-cikis_raf">
                                            	<cfinput type="text" name="txt_shelf_out_name" id="txt_shelf_out_name" value="">
                                                <cfinput type="hidden" name="txt_shelf_out" id="txt_shelf_out" value="">
                                            </div>
                                        </div>
                                        <div class="col col-4">
                                            <div class="form-group" id="item-cikis_palet">
                                            	<cfinput type="text" name="txt_packing_out_name" id="txt_packing_out_name" value="">
                                                <cfinput type="hidden" name="txt_packing_out" id="txt_packing_out" value="">
                                            </div>
                                        </div>
                                        <div class="col col-4">
                                        	<div class="form-group" id="item-cikis_depo">
                                          		<cfinput type="text" name="txt_department_out_name" id="txt_department_out_name" value="">
                                                <cfinput type="hidden" name="txt_department_out" id="txt_department_out" value="">
                                        	</div>
                                        </div>
                                    </div>
                              	</div>
               				</cf_box_elements>
                    		<cf_box_footer>
                            	<div class="col col-12">
                                    <div class="col col-6" style="text-align:right">
                                       </div>
                                    <div class="col col-6" style="text-align:right;display:none" id="onay_div">
                                        <input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" onClick="kontrol_kayit(1);" />
                                 	</div>
                              	</div>
              				</cf_box_footer>
                       	</div>
                  	</div>
              	</div>
    		</cf_basket_form>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id="1328.Paket Transfer"></cfsavecontent>
        	<cf_box title="#title#">
            	<cf_grid_list>
                   	<thead>
                       	<tr>
                        	<th width="5%"></th>
                        	<th width="5%"><cf_get_lang dictionary_id="58577.Sıra"></th>
                        	<th width="30%"><cf_get_lang dictionary_id="57637.Seri No"></th>
                           	<th width="60%"><cf_get_lang dictionary_id="57657.Ürün"></th>
                     	</tr>
                 	</thead>
                  	<cfinput type="hidden" id="row_count" name="row_count" value="0" />
                 	<cfinput type="hidden" id="row_info_id" name="row_info_id" value="" />
                 	<tbody name="table1" id="table1"></tbody>
           		</cf_grid_list>
          	</cf_box>
      	</cfform>
   	</cf_box>
</div>
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
			if (document.getElementById('add_other_barcod').value.length == '') /*Barkod Boşsa*/
			{
				row_count = document.getElementById('row_count').value;
				if(row_count>0 && document.getElementById('txt_shelf_in_name').value.length >0) /*Barkod Boşsa ve Raf Okutulmuşsa*/
				{
					/*var raf_sql = "SELECT PP.PRODUCT_PLACE_ID, PP.SHELF_CODE, PP.DEPO, PP.SHELF_TYPE, W.DEPO_NAME FROM EZGI_PRODUCT_PLACE AS PP INNER JOIN EZGI_WM_DEPARTMENTS AS W ON PP.DEPO = W.DEPO AND PP.PLACE_STATUS = 1 AND PP.SHELF_CODE = '"+document.getElementById('txt_shelf_in_name').value+"'";*/ /*RAF Doğrulama*/
					/*var get_raf = wrk_query(raf_sql,'dsn3');*/	
					
					var listParam = document.getElementById('txt_shelf_in_name').value;
					var get_raf = wrk_safe_query('get_shelf_wm_shelfcode_ezgi','dsn3',0,listParam);
		
					if(get_raf.PRODUCT_PLACE_ID == undefined) /*Palet Bulunamadıysa*/
					{
						alert('Raf Bulunamadı !');
						document.getElementById('txt_shelf_in_name').value = '';
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_barcod').focus(); /*Barkod Alanını Temizle ve Yeniden Barkoda Odaklan*/		
						return false;
					}
					else	
					{
						if(get_raf.SHELF_TYPE==5)
						{
							alert(document.getElementById('txt_shelf_in_name').value+' Rafı Sevkiyat Rafıdır. Sadece Sevkiyata Transfer İşlemi İle İşlem Yapılır.!');
							document.getElementById('txt_shelf_in_name').value = '';
							document.getElementById('add_other_barcod').value = '';
							document.getElementById('add_other_barcod').focus(); /*Barkod Alanını Temizle ve Yeniden Barkoda Odaklan*/		
							return false;	
						}
						else if(get_raf.SHELF_TYPE==1)
						{
							/*var t_raf_sql = "SELECT  E.STOCK_ID, E.MAIN_SPECT_ID, S.PRODUCT_NAME FROM EZGI_PRODUCT_PLACE_ROWS AS E INNER JOIN STOCKS AS S ON E.STOCK_ID = S.STOCK_ID WHERE E.SHELF_CODE = '"+document.getElementById('txt_shelf_in_name').value+"'";*/ /*RAF Doğrulama*/
							/*var get_t_raf = wrk_query(t_raf_sql,'dsn3');*/
							
							var listParam = document.getElementById('txt_shelf_in_name').value;
							var get_t_raf = wrk_safe_query('get_shelf_collect_wm_shelfcode_ezgi','dsn3',0,listParam);
							
							if(get_t_raf.STOCK_ID == undefined || get_t_raf.STOCK_ID =='')
							{
								alert(document.getElementById('txt_shelf_in_name').value+' Rafı Toplama Rafı olduğu Halde Stok Tanımı Yapılmamıştır..!');
								document.getElementById('txt_shelf_in_name').value = '';
								document.getElementById('add_other_barcod').value = '';
								document.getElementById('add_other_barcod').focus(); /*Barkod Alanını Temizle ve Yeniden Barkoda Odaklan*/		
								return false;
							}
							else
							{
								stock_hata = 0;
								for(i=1;i<=row_count;i++)
								{
									if(document.getElementById('STOCK_ID'+i).value != get_t_raf.STOCK_ID)
										stock_hata = 1;	
								}
								if(stock_hata ==1)
								{
									alert(document.getElementById('txt_shelf_in_name').value+' Rafı Toplama Rafıdır. Sadece Rafa Tanımlı Olan Ürün Transfer Edilebilir. Tanımlı Ürün : '+get_t_raf.PRODUCT_NAME);
									document.getElementById('txt_shelf_in_name').value = '';
									document.getElementById('add_other_barcod').value = '';
									document.getElementById('add_other_barcod').focus(); /*Barkod Alanını Temizle ve Yeniden Barkoda Odaklan*/		
									return false;
								}
								else
								{
									document.getElementById('giris_depo_select').style.display='none';
									document.getElementById('giris_depo_input').style.display='';
									document.getElementById('txt_department_in_name').value = get_raf.DEPO_NAME;
									document.getElementById('txt_department_in').value = get_raf.DEPO;
									document.getElementById('txt_shelf_in_name').value = get_raf.SHELF_CODE;
									document.getElementById('txt_shelf_in').value = get_raf.PRODUCT_PLACE_ID;
									tus_ac();
								}
							}
						}
						else if(get_raf.SHELF_TYPE==2)
						{
							alert(document.getElementById('txt_shelf_in_name').value+' Rafı Stoklama Rafıdır. Sadece Raftaki Palet Barkodu Okutularak Transfer Edilebilir.!');
							document.getElementById('add_other_barcod').value = '';
							document.getElementById('add_other_barcod').focus(); /*Barkod Alanını Temizle ve Yeniden Barkoda Odaklan*/		
							return false;
						}
						else
						{
							document.getElementById('giris_depo_select').style.display='none';
							document.getElementById('giris_depo_input').style.display='';
							document.getElementById('txt_department_in_name').value = get_raf.DEPO_NAME;
							document.getElementById('txt_department_in').value = get_raf.DEPO;
							document.getElementById('txt_shelf_in_name').value = get_raf.SHELF_CODE;
							document.getElementById('txt_shelf_in').value = get_raf.PRODUCT_PLACE_ID;
							tus_ac();
						}
					}
				}
				else if(row_count>0 && document.getElementById('txt_packing_in_name').value.length >0) /*Barkod Boşsa ve Palet Okutulmuşsa*/
				{
					/*var packing_sql = "SELECT E.PACKING_ID, ISNULL(PP.PRODUCT_PLACE_ID,0) PRODUCT_PLACE_ID, E.DEPO, E.BARCODE, E.PACKING_SIZE_TYPE_CODE, E.STOCK_ID, E.AMOUNT, ISNULL(E.IS_KARMA, 0) AS IS_KARMA, PP.SHELF_CODE, D.DEPO_NAME, S.PRODUCT_NAME FROM EZGI_WM_PACKING_LAST_STATUS AS E LEFT OUTER JOIN STOCKS AS S ON E.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN EZGI_WM_DEPARTMENTS AS D ON E.DEPO = D.DEPO LEFT OUTER JOIN EZGI_PRODUCT_PLACE AS PP ON E.SHELF_NUMBER = PP.PRODUCT_PLACE_ID WHERE E.STATUS = 1 AND E.BARCODE = '"+document.getElementById('txt_packing_in_name').value+"'";*/ /*Palet Doğrulama*/
					/*var get_packing = wrk_query(packing_sql,'dsn3');*/
					
					var listParam = document.getElementById('txt_packing_in_name').value;
					var get_packing = wrk_safe_query('get_packing_wm_packingbarcode_ezgi','dsn3',0,listParam);
					
					if(get_packing.PRODUCT_PLACE_ID == undefined) /*Palet Bulunamadıysa*/
					{
						alert('Palet Bulunamadı !');
						document.getElementById('txt_packing_in_name').value ='';
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_barcod').focus(); /*Barkod Alanını Temizle ve Yeniden Barkoda Odaklan*/		
						return false;
					}
					else	
					{
						if(get_packing.IS_KARMA == 0)
						{
							stock_hata = 0;	
							for(i=1;i<=row_count;i++)
							{
								if(document.getElementById('STOCK_ID'+i).value != get_packing.STOCK_ID)
									stock_hata = 1;	
							}
							if(stock_hata ==1)
							{
								alert(document.getElementById('txt_packing_in_name').value+' Karma Palet Değildir. Sadece Palete Tanımlı Olan Ürün Transfer Edilebilir. Tanımlı Ürün : '+get_packing.PRODUCT_NAME);
								document.getElementById('txt_packing_in_name').value ='';
								document.getElementById('add_other_barcod').value = '';
								document.getElementById('add_other_barcod').focus(); /*Barkod Alanını Temizle ve Yeniden Barkoda Odaklan*/		
								return false;
							}
							else
							{
								document.getElementById('giris_depo_select').style.display='none';
								document.getElementById('giris_depo_input').style.display='';
								document.getElementById('txt_department_in_name').value = get_packing.DEPO_NAME;
								document.getElementById('txt_department_in').value = get_packing.DEPO;
								document.getElementById('txt_packing_in_name').value = get_packing.BARCODE;
								document.getElementById('txt_packing_in').value = get_packing.PACKING_ID;
								if(get_packing.PRODUCT_PLACE_ID > 0)
								{
									document.getElementById('txt_shelf_in_name').value = get_packing.SHELF_CODE;
									document.getElementById('txt_shelf_in').value = get_packing.PRODUCT_PLACE_ID;
								}
								tus_ac();
							}
						}
						else
						{
							document.getElementById('giris_depo_select').style.display='none';
							document.getElementById('giris_depo_input').style.display='';
							document.getElementById('txt_department_in_name').value = get_packing.DEPO_NAME;
							document.getElementById('txt_department_in').value = get_packing.DEPO;
							document.getElementById('txt_packing_in_name').value = get_packing.BARCODE;
							document.getElementById('txt_packing_in').value = get_packing.PACKING_ID;
							if(get_packing.PRODUCT_PLACE_ID > 0)
							{
								document.getElementById('txt_shelf_in_name').value = get_packing.SHELF_CODE;
								document.getElementById('txt_shelf_in').value = get_packing.PRODUCT_PLACE_ID;
							}
							tus_ac();
						}
					}
				}
				else /*Barkod, Palet ve Raf boş ise*/
				{
					alert('<cf_get_lang dictionary_id='340.Önce Ürün Barkodu Okutunuz'>'); 
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus();
				}
			}
			else /*Barkod Doluysa*/
			{
				get_stock(document.getElementById('add_other_barcod').value);
			}
		}
	}
	function get_stock(barcode) /*Ürün Kontrolü*/
    {
		row_count = document.getElementById('row_count').value;
	 	barcod = ''; stockid=''; productname=''; spectmainid=''; //ilk önce sıfırlıyoruz
		/*var new_sql = "SELECT E.SERIAL_NO, E.STOCK_ID, E.DEPARTMENT_ID, E.LOCATION_ID, E.PRODUCT_PLACE_ID, E.PACKING_ID, E.DEPO, E.SPECT_ID, E.PALET_BARCODE, E.PRODUCT_NAME, E.IS_PROTOTYPE, E.SHELF_CODE,ISNULL(E.IS_SHIPMENT_VERIFACTION,0) IS_SHIPMENT_VERIFACTION, W.DEPO_NAME, ISNULL(E.SHIP_RESULT_ID,0) SHIP_RESULT_ID FROM EZGI_WM_SERIAL_NO_LAST_STATUS AS E INNER JOIN EZGI_WM_DEPARTMENTS AS W ON E.DEPO = W.DEPO INNER JOIN EZGI_WM_IS_SERIAL_NO_LIVE AS LV ON E.SERIAL_NO = LV.SERIAL_NO WHERE E.SERIAL_NO = '"+barcode+"'";*/ /*Paket Nerede*/
		/*var get_package = wrk_query(new_sql,'dsn3');*/
		
		var listParam = barcode;
		var get_package = wrk_safe_query('get_serial_livecontrol_serialno_ezgi','dsn3',0,listParam);
		
		if (get_package.STOCK_ID == undefined) /*Palet Bulunamadıysa*/
		{
			alert('Paket Bulunamdı !');
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		else /*Paket Bulunduysa*/
		
		{	if(document.getElementById('txt_department_out').value !='')
			{
				if(document.getElementById('txt_department_out').value != get_package.DEPO)
				{
					alert('Paketin Bulunduğu Depo Aynı Olmalıdır. Depo :'+get_package.DEPO_NAME);
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
					return false;	
				}
			}
			if(get_package.SHIP_RESULT_ID>0)
			{
				alert('Palet Sevkiyat İşlemindedir. Transfer Edemezsiniz!!!')
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
				return false;
			}
			else
			{
				document.getElementById('third_area').style.display='';
				document.getElementById('second_area').style.display='';
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('txt_department_out_name').value = get_package.DEPO_NAME;
				document.getElementById('txt_department_out').value = get_package.DEPO;
				document.getElementById('txt_shelf_out_name').value = get_package.SHELF_CODE;
				document.getElementById('txt_shelf_out').value = get_package.PRODUCT_PLACE_ID;
				document.getElementById('txt_packing_out_name').value = get_package.PALET_BARCODE;
				document.getElementById('txt_packing_out').value = get_package.PACKING_ID;
				document.getElementById('txt_product_name').value = get_package.PRODUCT_NAME;
				productname=get_package.PRODUCT_NAME;
				stockid=get_package.STOCK_ID;
				spectmainid=get_package.SPECT_ID;
				add_row(barcode,productname,stockid,spectmainid);
			}
		}
	}
	function add_row(barcod,product_name,stockid,spectmainid)
	{
		row_count = document.getElementById('row_count').value;
		serial_hata = 0;	
		karma = 0;
		for(i=1;i<=row_count;i++)
		{
			if(document.getElementById('BARCODE'+i).value == barcod)
			{
				serial_hata = 1;	
			}
			if(document.getElementById('STOCK_ID'+i).value != stockid)
			{
				document.getElementById('kapma_process').value = 1;
				document.getElementById('txt_shelf_in_name').placeholder = 'Karma Raf Seçin';
				document.getElementById('txt_packing_in_name').placeholder = 'Karma Palet Seçin';
				document.getElementById('txt_shelf_in_name').style.placeholderColor ="red";
				document.getElementById('txt_packing_in_name').style.placeholderColor ="red";
				karma = 1;
			}
		}
		if(serial_hata == 0)
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
			newCell.innerHTML = '<a onclick="sil(' + row_count + ');"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>';
					
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="hidden" name="row_kontrol'+row_count+'" id="row_kontrol'+row_count+'" value="1"><input name="row_number'+row_count+'" type="text" value="'+row_count+'" style="width:25px; text-align:right">';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="BARCODE'+row_count+'" id="BARCODE'+row_count+'" type="text" value="'+barcod+'" style="width:120px">';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="PRODUCT_NAME'+row_count+'" id="PRODUCT_NAME'+row_count+'" type="text" value="'+product_name+'" style="width:160px"><input name="STOCK_ID'+row_count+'" id="STOCK_ID'+row_count+'" type="hidden" value="'+stockid+'"><input name="SPECT_MAIN_ID'+row_count+'" id="SPECT_MAIN_ID'+row_count+'" type="hidden" value="'+spectmainid+'">';	
			
			document.getElementById('txt_department_out_name').disabled = true; /*Depo Seçim select alanlar disable ediliyor*/
			document.getElementById('txt_shelf_out_name').disabled = true; /*Raf Seçim select alanlar disable ediliyor*/
			document.getElementById('txt_packing_out_name').disabled = true; /*Palet Seçim select alanlar disable ediliyor*/
			
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus(); /*Barkod Alanını Temizle ve Yeniden Barkoda Odaklan*/
		}
		else
		{
			alert('Barcod Daha Önce Seçilmiştir..!');
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus(); /*Barkod Alanını Temizle ve Yeniden Barkoda Odaklan*/	
			return false;
		}
	}
	function select_depo(depo)
	{
		/*var depo_sql = "SELECT DEPO_NAME, DEPO FROM EZGI_WM_DEPARTMENTS WHERE DEPO = '"+depo+"'";*/ /*Depo Doğrulama*/
		/*var get_depo = wrk_query(depo_sql,'dsn3');*/	
		
		var listParam = depo;
		var get_depo = wrk_safe_query('get_department_wm_depocode_ezgi','dsn3',0,listParam);
		
		if(get_depo.DEPO_NAME == undefined) /*Palet Bulunamadıysa*/
		{
			alert('Depo Bulunamadı !');
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus(); /*Barkod Alanını Temizle ve Yeniden Barkoda Odaklan*/		
			return false;
		}
		else
		{
			document.getElementById('giris_depo_select').style.display='none';
			document.getElementById('giris_depo_input').style.display='';
			document.getElementById('txt_department_in_name').value = get_depo.DEPO_NAME;
			document.getElementById('txt_department_in').value = get_depo.DEPO;
			tus_ac();
		}
	}
	function sil(sy)
	{
		document.getElementById('row_kontrol'+sy).value=0;
		document.getElementById('frm_row'+sy).style.display="none";
		
		document.getElementById('row_kontrol'+sy).value = 0;
		document.getElementById('BARCODE'+sy).value = '';
		document.getElementById('STOCK_ID'+sy).value = '';
		document.getElementById('SPECT_MAIN_ID'+sy).value = '';
		document.getElementById('PRODUCT_NAME'+sy).value = '';
	
		document.getElementById('add_other_barcod').value = '';
		document.getElementById('add_other_barcod').focus(); /*Barkod Alanını Temizle ve Yeniden Barkoda Odaklan*/		
	}
	function tus_ac()
	{
		document.getElementById('onay_div').style.display='';	
	}
	function kontrol_kayit()
	{
		row_count = document.getElementById('row_count').value;	
		if(row_count >0) /*ilk Satırdan sonrası*/
	  	{
			action_doldur();
			document.getElementById('onay').disabled = true;
			sor = confirm("<cf_get_lang dictionary_id='57536.Güncellemek İstediğinizden Emin misiniz?'>");
			if(sor==true)
			{
				window.location.href='<cfoutput>#request.self#?fuseaction=stock.emptypopup_add_ezgi_package_transfer&process_cat=#get_process_cat.process_cat_id#</cfoutput>&dep_in='+document.getElementById('txt_department_in').value+'&dep_out='+document.getElementById('txt_department_out').value+'&shelf_in='+document.getElementById('txt_shelf_in').value+'&packing_in='+document.getElementById('txt_packing_in').value+'&row_info_id='+document.getElementById('row_info_id').value+'&shelf_out='+document.getElementById('txt_shelf_out').value+'&packing_out='+document.getElementById('txt_packing_out').value;	
			}
			else
			{
				document.getElementById('onay').disabled = false;
				return false;
			}
		}
		else
		{
			alert('Sepette Kayıtlı Ürün Yok');
			return false;
		}
	}
	function action_doldur()
	{
		var j = 1;
	  	for(i=1;i<=row_count;i++)
	  	{
		  	if(document.getElementById('row_kontrol'+i).value == 1)
		  	{
				if (j > 1)
					document.getElementById('row_info_id').value = document.getElementById('row_info_id').value + ',';
				document.getElementById('row_info_id').value = document.getElementById('row_info_id').value + j + '-';
				document.getElementById('row_info_id').value = document.getElementById('row_info_id').value + document.getElementById('BARCODE'+i).value;
				j++;
		  	}
	  	}
	}
</script>