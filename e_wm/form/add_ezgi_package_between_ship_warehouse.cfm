<!---
    File: add_ezgi_package_between_ship_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 08/01/2024
    Description: Depolararası Sevk İrsaliyesi
---> 
<cfset default_process_type = 81>
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
<cfquery name="get_employee_position_departments" datasource="#dsn#">
	SELECT LOCATION_CODE FROM EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE = #session.ep.position_code# AND NOT (LOCATION_CODE IS NULL)
</cfquery>
<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>
<cfquery name="get_shipment_departments" datasource="#dsn3#">
	SELECT DISTINCT REPLACE(SHIPMENT_WAREHOUSE,',','-') AS SHIPMENT_WAREHOUSE FROM EZGI_WM_SETUP_ROW WHERE SHIPMENT_WAREHOUSE IS NOT NULL
</cfquery>
<cfset shipment_depo_list = ValueList(get_shipment_departments.SHIPMENT_WAREHOUSE)>
<cfif not get_shipment_departments.recordcount>
	<script type="text/javascript">
		alert("<Sevkiyat Depo Tanımlanmamış! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>
<cfset default_departments = '#ListGetAt(get_default_departments.SHELF_WAREHOUSE,1)#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
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
        SL.STATUS = 1 AND 
        B.COMPANY_ID = #session.ep.company_id# AND
        PP.PRODUCT_PLACE_ID IS NULL AND
        (
        	<cfloop from="1" to="#Listlen(shipment_depo_list,',')#" index="i">
        		CAST(D.DEPARTMENT_ID AS VARCHAR)+ '-' + CAST(SL.LOCATION_ID AS VARCHAR) <> '#ListGetAt(shipment_depo_list,i,',')#' <cfif Listlen(shipment_depo_list,',') gt i>OR</cfif>
          	</cfloop>
            
       	)
        <cfif get_employee_position_departments.recordcount>
        	AND (
            	<cfloop query="get_employee_position_departments">
                	CAST(D.DEPARTMENT_ID AS VARCHAR)+ '-' + CAST(SL.LOCATION_ID AS VARCHAR) = '#get_employee_position_departments.LOCATION_CODE#' <cfif get_employee_position_departments.recordcount gt get_employee_position_departments.currentrow>OR</cfif>
                </cfloop>
                )
    	</cfif>
  	ORDER BY
    	DEPO_NAME
</cfquery>
<cfquery name="GET_SHELF_LOCATION" datasource="#DSN#">
	SELECT DISTINCT       
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
        SL.STATUS = 1 AND 
        PP.PRODUCT_PLACE_ID IS NOT NULL
  	ORDER BY
    	DEPO_NAME
</cfquery>
<cfset shelf_depo_list = ValueList(GET_SHELF_LOCATION.DEPO)>
<cfset not_shelf_depo_list = ValueList(GET_ALL_LOCATION.DEPO)>
<cfquery name="get_process_cat" datasource="#DSN3#">
	SELECT TOP (1)    
    	SPC.PROCESS_CAT_ID
	FROM         
    	SETUP_PROCESS_CAT AS SPC INNER JOIN
      	SETUP_PROCESS_CAT_FUSENAME AS SPCF ON SPC.PROCESS_CAT_ID = SPCF.PROCESS_CAT_ID INNER JOIN
    	SETUP_PROCESS_CAT_ROWS AS SPCR ON SPC.PROCESS_CAT_ID = SPCR.PROCESS_CAT_ID
	WHERE     
    	SPC.PROCESS_TYPE = #default_process_type# AND 
        SPCF.FUSE_NAME = 'stock.add_ezgi_package_between_ship_warehouse' 
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
                                            <label><cf_get_lang dictionary_id='39093.Ürün Barkodu'></label>
                                        </div>
                                        <div class="col col-9">
                                            <div class="form-group" id="item-barcod">
                                                <input id="add_other_barcod" name="add_other_barcod" type="text" value="">
                                            </div>
                                        </div>
                                    </div>
                               	</div>
                                <div class="col col-12" id="second_area" style="display:none">
                               		<div class="col col-3">
                                      	<label><cf_get_lang dictionary_id='29428.Çıkış Depo'></label>
                                   	</div>
                                 	<div class="col col-9">
                                      	<div class="form-group" id="item-cikis">
                                         	<cfinput type="text" name="txt_department_out_name" id="txt_department_out_name" value="">
                                        	<cfinput type="hidden" name="txt_department_out" id="txt_department_out" value="">
                                    	</div>
                                	</div>
                            	</div>
                        		<div class="col col-12" id="third_area" style="display:none">
                                 	<div class="col col-3">
                                    	<label><cf_get_lang dictionary_id='39412.Giriş Depo'></label>
                                	</div>
                                	<div class="col col-9">
                                     	<div class="form-group" id="item-giris">
                                        	<select name="txt_department_in" id="txt_department_in" onChange="tus_ac()">
                                            	<option value="">Seçiniz</option>	
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
            <cfsavecontent variable="title"><cf_get_lang dictionary_id="739.Depolararası Sevk İrsaliyesi Oluştur"></cfsavecontent>
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
	<cfoutput>
		shelf_depo_list = #shelf_depo_list#;
		not_shelf_depo_list = #not_shelf_depo_list#;
		shipment_depo_list = #shipment_depo_list#;
	</cfoutput>
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
		row_count = document.getElementById('row_count').value;
	 	barcod = ''; stockid=''; productname=''; spectmainid=''; //ilk önce sıfırlıyoruz
		/*var new_sql = "SELECT TOP (1) E.SERIAL_NO, E.STOCK_ID, E.DEPARTMENT_ID, E.LOCATION_ID, E.PRODUCT_PLACE_ID, E.PACKING_ID, E.DEPO, E.SPECT_ID, E.PALET_BARCODE, E.PRODUCT_NAME, E.IS_PROTOTYPE, E.SHELF_CODE,ISNULL(E.IS_SHIPMENT_VERIFACTION,0) IS_SHIPMENT_VERIFACTION, W.DEPO_NAME, ISNULL(E.SHIP_RESULT_ID,0) SHIP_RESULT_ID FROM EZGI_WM_SERIAL_NO_LAST_STATUS AS E INNER JOIN EZGI_WM_DEPARTMENTS AS W ON E.DEPO = W.DEPO WHERE E.SERIAL_NO = '"+barcode+"'";*/ /*Paket Nerede*/
		/*var get_package = wrk_query(new_sql,'dsn3');*/
		
		var listParam = barcode;
		var get_package = wrk_safe_query('get_serial_serialno_ezgi','dsn3',0,listParam);
		
		if (get_package.STOCK_ID == undefined) /*Palet Bulunamadıysa*/
		{
			alert('Paket Bulunamdı !');
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		else if(get_package.recordcount>1)/*Paket Birden Fazla Bulunduysa*/
		{
			alert('Birden Fazla Ürün için Aynı Seri No Oluşmuş Sistem Yöneticinizi Arayın!!!')
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
			if(list_find(shipment_depo_list,get_package.DEPO))
			{
				alert('Paket Sevkiyat Alanındadır. Transfer Edemezsiniz!!!')
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
				return false;
			}
			if(list_find(shelf_depo_list,get_package.DEPO))
			{
				alert('Paket Raflı Alandadır. Transfer Edemezsiniz!!!')
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
		if(document.getElementById('txt_department_in').value=='')
			document.getElementById('onay_div').style.display='none';
		else
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
				window.location.href='<cfoutput>#request.self#?fuseaction=stock.emptypopup_add_ezgi_package_between_ship_warehouse&process_cat=#get_process_cat.process_cat_id#</cfoutput>&dep_in='+document.getElementById('txt_department_in').value+'&dep_out='+document.getElementById('txt_department_out').value+'&row_info_id='+document.getElementById('row_info_id').value;	
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