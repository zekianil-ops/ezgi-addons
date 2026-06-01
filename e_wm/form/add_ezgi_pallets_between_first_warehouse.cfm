<!---
    File: add_ezgi_pallets_between_first_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Giriş Bölümleri Arası Geçiş
--->
<cfset default_process_type = 113>
<cfset PACKING_ACTION_TYPE_ID = 2> <!---Palet İşlem Tipi - (Palet Ambara Transfer)--->
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
<cfset default_departments = '#ListGetAt(get_default_departments.SHELF_WAREHOUSE,1)#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
<cfparam name="attributes.department_in_id" default="#Replace(get_default_departments.SHELF_WAREHOUSE,',','-')#">
<cfparam name="attributes.department_out_id" default="#Replace(get_default_departments.SHELF_WAREHOUSE,',','-')#">
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
<cfquery name="get_first_shelfs" datasource="#DSN3#">
	SELECT 
    	PRODUCT_PLACE_ID, 
        SHELF_CODE, 
        DETAIL
	FROM     
    	PRODUCT_PLACE
	WHERE  
    	SHELF_TYPE = 4 AND 
        STORE_ID = #ListGetAt(get_default_departments.SHELF_WAREHOUSE,1)# AND 
        LOCATION_ID = #ListGetAt(get_default_departments.SHELF_WAREHOUSE,2)# AND 
        PLACE_STATUS = 1
	ORDER BY 
    	SHELF_CODE
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

<cfsavecontent variable="title_"><cf_get_lang dictionary_id='1309.Giriş Bölümleri Arası Geçiş'></cfsavecontent>
<cf_catalystHeader>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#title_#">
        <cfform name="add_ezgi_pallets_between_first_warehouse" >
         	<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
          	<input type="hidden" name="active_period" value="#session.ep.period_id#" />
            <cf_basket_form id="add_ezgi_pallets_between_first_warehouse">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
                         	<cf_box_elements>
                            	<div class="col col-12 uniqueRow" id="first_area">
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='39093.Ürün Barkodu'></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group" id="item-barcod">
                                                <input id="add_other_barcod" name="add_other_barcod" type="text" value="">
                                            </div>
                                        </div>
                                    </div>
                               	</div>
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='29428.Çıkış Depo'></label>
                                        </div>
                                        <div class="col col-6">
                                            <div class="form-group" id="item-cikis">
                                            
                                                <select name="txt_department_out" id="txt_department_out" >
                                                    <cfoutput query="get_all_location" group="department_id">
                                                        <option disabled="disabled" value="#department_id#"<cfif attributes.department_in_id eq department_id>selected</cfif>>#department_head#</option>
                                                        <cfoutput>
                                                            <option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_in_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#<cfif not status>-<cf_get_lang dictionary_id='57494.Pasif'></cfif></option>
                                                        </cfoutput> 
                                                    </cfoutput>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="col col-3">
                                            <div class="form-group" id="item-cikis_raf">
                                                <select name="txt_shelf_out" id="txt_shelf_out" >
                                                    <cfoutput query="get_first_shelfs">
                                                      	<option value="#PRODUCT_PLACE_ID#">#SHELF_CODE#</option>
                                                    </cfoutput>
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col col-12">
                                        <div class="col col-3">
                                            <label><cf_get_lang dictionary_id='39412.Giriş Depo'></label>
                                        </div>
                                        <div class="col col-6">
                                            <div class="form-group" id="item-giris">
                                                <select name="txt_department_in" id="txt_department_in" >
                                                    <cfoutput query="get_all_location" group="department_id">
                                                        <option disabled="disabled"  value="#department_id#"<cfif attributes.department_in_id eq department_id>selected</cfif>>#department_head#</option>
                                                        <cfoutput>
                                                            <option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_in_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#<cfif not status>-<cf_get_lang dictionary_id='57494.Pasif'></cfif></option>
                                                        </cfoutput> 
                                                    </cfoutput>
                                                </select>
                                            </div>
                                        </div>
                                        <div class="col col-3">
                                            <div class="form-group" id="item-giris_raf">
                                                <select name="txt_shelf_in" id="txt_shelf_in" >
                                                    <cfoutput query="get_first_shelfs">
                                                      	<option value="#PRODUCT_PLACE_ID#">#SHELF_CODE#</option>
                                                    </cfoutput>
                                                </select>
                                            </div>
                                        </div>
                                    </div>
               				</cf_box_elements>
                    		<cf_box_footer>
                            	<div class="col col-12">
                                    <div class="col col-6" style="text-align:right">
                                       </div>
                                    <div class="col col-6" style="text-align:right">
                                        <input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" onClick="kontrol_kayit(1);" />
                                 	</div>
                              	</div>
              				</cf_box_footer>
                       	</div>
                  	</div>
              	</div>
    		</cf_basket_form>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id="1308.Paletler"></cfsavecontent>
        	<cf_box title="#title#">
            	<cf_grid_list>
                   	<thead>
                       	<tr>
                        	<th width="5%"></th>
                        	<th width="5%">Sıra</th>
                        	<th width="60%">Palet Barkod</th>
                           	<th width="30%">Palet Türü</th>
                     	</tr>
                 	</thead>
                    	<cfinput type="hidden" id="row_count" name="row_count" value="0" />
                        <cfinput type="hidden" id="row_info_id" name="row_info_id" value="" />
                   		<tbody name="table1" id="table1">
                    	</tbody>
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
	 	barcod = ''; packingid='';  //ilk önce sıfırlıyoruz
		/*var new_sql = "SELECT PACKING_ID, PACKING_SIZE_TYPE_CODE, PACKING_SIZE_TYPE_ID, SHELF_SIZE_TYPE_ID FROM EZGI_WM_PACKING_LAST_STATUS WHERE DEPO = '"+document.getElementById('txt_department_out').value+"' AND SHELF_NUMBER ="+document.getElementById('txt_shelf_out').value+" AND BARCODE = '"+barcode+"'";*/ /*Palet Depoda Mevcutmu*/
		/*var get_palettes = wrk_query(new_sql,'dsn3');*/
		
		var listParam = document.getElementById('txt_department_out').value + "*" + document.getElementById('txt_shelf_out').value + "*" + barcode;
		var get_palettes = wrk_safe_query('get_packing_wm_depocode_shelcode_barcode_ezgi','dsn3',0,listParam);
		
		if (get_palettes.PACKING_ID == undefined) /*Palet Bulunamadıysa*/
		{
			alert('Palet Depoda Bulunamdı !');
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		else /*Palet Bulunduysa*/
		{	
			packingid = get_palettes.PACKING_ID;
			barcod = barcode;
			packing_size_code = get_palettes.PACKING_SIZE_TYPE_CODE;
			packing_size_id = get_palettes.PACKING_SIZE_TYPE_ID;
			amount = 1;
			document.getElementById('txt_department_out').readOnly = true;
			row_count = document.getElementById('row_count').value;
			add_row(packingid,barcod,amount,packing_size_code,packing_size_id);
		}
	}
	function add_row(packingid,barcod,amount,packing_size_code,packing_size_id)
	{
		row_count = document.getElementById('row_count').value;
		serial_hata = 0;	
		for(i=1;i<=row_count;i++)
		{
			if(document.getElementById('BARCODE'+i).value == barcod)
			{
				serial_hata = 1;	
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
			newCell.innerHTML = '<input type="hidden" name="row_kontrol'+row_count+'" id="row_kontrol'+row_count+'" value="1"><input name="PACKING_ID'+row_count+'" id="PACKING_ID'+row_count+'" type="hidden" value="'+packingid+'"><input name="row_number'+row_count+'" type="text" value="'+row_count+'" style="width:25px; text-align:right">';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="BARCODE'+row_count+'" id="BARCODE'+row_count+'" type="text" value="'+barcod+'" style="width:120px">';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="SIZE_TYPE'+row_count+'" id="SIZE_TYPE'+row_count+'" type="text" value="'+packing_size_code+'" style="width:90px"><input name="SIZE_ID'+row_count+'" id="SIZE_ID'+row_count+'" type="hidden" value="'+packing_size_id+'">';	
			
			document.getElementById('txt_department_out').disabled = true; /*Depo Seçim select alanlar disable ediliyor*/
			document.getElementById('txt_shelf_out').disabled = true; /*Raf Seçim select alanlar disable ediliyor*/
			
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
	function sil(sy)
	{
		document.getElementById('row_kontrol'+sy).value=0;
		document.getElementById('frm_row'+sy).style.display="none";
		
		document.getElementById('row_kontrol'+sy).value = 0;
		document.getElementById('BARCODE'+sy).value = '';
		document.getElementById('PACKING_ID'+sy).value = '';
		document.getElementById('SIZE_TYPE'+sy).value = '';
		document.getElementById('SIZE_ID'+sy).value = '';
	
		document.getElementById('add_other_barcod').value = '';
		document.getElementById('add_other_barcod').focus(); /*Barkod Alanını Temizle ve Yeniden Barkoda Odaklan*/		
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
				window.location.href='<cfoutput>#request.self#?fuseaction=stock.emptypopup_add_ezgi_pallets_between_first_warehouse&process_cat=#get_process_cat.process_cat_id#&packing_action_type_id=#PACKING_ACTION_TYPE_ID#</cfoutput>&dep_in='+document.getElementById('txt_department_in').value+'&dep_out='+document.getElementById('txt_department_out').value+'&shelf_in='+document.getElementById('txt_shelf_in').value+'&shelf_out='+document.getElementById('txt_shelf_out').value+'&row_info_id='+document.getElementById('row_info_id').value;	
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
				document.getElementById('row_info_id').value = document.getElementById('row_info_id').value + document.getElementById('PACKING_ID'+i).value;
				j++;
		  	}
	  	}
	}
</script>