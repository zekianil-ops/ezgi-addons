<!---
    File: add_ezgi_count_warehouse.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/08/2023
    Description: Seri No Sayım Oluşturma
---> 
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfset default_process_type = 115>
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
		alert("<cf_get_lang dictionary_id='29632.Sayım Fişi'> <cf_get_lang dictionary_id='333.İşlem Kategorisi Tanımlayınız!'>");
		history.back();	
	</script>
    <cfabort>
</cfif>

<cfset default_departments = '#ListGetAt(get_default_departments.PRODUCTION_WAREHOUSE,1)#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
<cfparam name="attributes.department_in_id" default="#Replace(get_default_departments.PRODUCTION_WAREHOUSE,',','-')#">
<cfparam name="attributes.department_out_id" default="#get_default_departments.PRODUCTION_WAREHOUSE#">
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

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
        <cfform name="add_ezgi_package_transfer" >
         	<cfinput id="fis_tipi" type="hidden" name="fis_tipi" value="#default_process_type#">
          	<input type="hidden" name="active_period" value="#session.ep.period_id#" />
            <cfinput type="hidden" name="ana_stock_id" id="ana_stock_id" value="">
            <cfinput type="hidden" name="ana_spect_main_id" id="ana_spect_main_id" value="0"> 
            <cfinput type="hidden" name="ana_product_name" id="ana_product_name" value="">
            <cf_basket_form id="add_ezgi_package_transfer">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
                         	<cf_box_elements>
                            	<div class="col col-12 uniqueRow" id="first_area">
                                    <div class="col col-12">
                                    	<div class="col col-4">
                                            <label><cf_get_lang dictionary_id='57635.Miktar'></label>
                                        </div>
                                        <div class="col col-4">


                                            <label><cf_get_lang dictionary_id='39093.Ürün Barkodu'></label>
                                        </div>
                                        <div class="col col-4">
                                            <label><cf_get_lang dictionary_id='45498.Lot No'></label>
                                        </div>
                                        
                                    </div>
                               	</div>
                                <div class="col col-12 uniqueRow" id="second_area">
                                    <div class="col col-12">
                                    	<div class="col col-4">
                                            <div class="form-group" id="item-amount">
                                                <input id="add_other_amount" name="add_other_amount" type="text" style=" text-align:right" maxlength="6" value="1" />
                                            </div>
                                        </div>
                                        <div class="col col-4">
                                            <div class="form-group" id="item-barcod">
                                                <input id="add_other_barcod" name="add_other_barcod" type="text" value="">
                                            </div>
                                        </div>
                                        <div class="col col-4">
                                            <div class="form-group" id="item-lot_no">
                                                <input id="add_other_lotno" name="add_other_lotno" type="text" value="">
                                            </div>
                                        </div>
                                    </div>
                               	</div>
                                <div class="col col-12" style="display:none" id="fourth_area">
                                	<div class="col col-12">
                                        <div class="col col-4">
                                            <label><cf_get_lang dictionary_id='58211.Sipariş No'></label>
                                        </div>
                                        <div class="col col-8"  id="order_select">
                                        	<div class="form-group" id="item-order_select">
												 <select name="get_new_order" id="get_new_order" style="width:120px" onChange="new_order_select(this.value);">
                                                    <option value="">Seçiniz</option>
                                                </select>
                                        	</div>
                                        </div>
                                    </div>
                               	</div>
                             	<div class="col col-12" style="display:none" id="fifth_area">
                                    <div class="col col-12">
                                    	<div class="col col-4">

                                        </div>
                                        <div class="col col-8">
                                            <input id="order_onay1" name="order_onay1" value="Bağla" type="button" style="width:30%; display:none" onClick="order_onay(1);" />

                                        	<input id="order_onay2" name="order_onay2" value="Bağsız" type="button" style="background-color:orange; color:white; width:30%" onClick="order_onay(2);" />

                                        	<input id="order_onay3" name="order_onay3" value="Vazgeç" type="button" style="background-color:red; color:white; width:30%" onClick="order_onay(3);" />
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="col col-12" id="third_area">
                                    <div class="col col-12">
                                        <div class="col col-4">
                                            <label><cf_get_lang dictionary_id='58763.Depo'></label>
                                        </div>
                                        <div class="col col-8"  id="giris_depo_select">
                                        	<div class="form-group" id="item-giris_depo_select">
                                            	<select name="txt_department_in_select" id="txt_department_in_select">
                                                	<option value=""><cf_get_lang dictionary_id="57734.Seçiniz"></option>
                                                	<cfoutput query="GET_ALL_LOCATION">
                                                    	<option value="#DEPO#" <cfif attributes.department_in_id eq DEPO>selected</cfif>>#DEPO_NAME#</option>
                                                    </cfoutput>
                                                </select>
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
            <cfsavecontent variable="title"><cf_get_lang dictionary_id="1337.Seri No Sayım işlemi"></cfsavecontent>
        	<cf_box title="#title#">
            	<cf_grid_list>
                   	<thead>
                       	<tr>
                        	<th width="20%"><cf_get_lang dictionary_id="39093.Ürün Barkodu"></th>
                            <th width="15%"><cf_get_lang dictionary_id="45498.Lot No"></th>
                           	<th width="60%"><cf_get_lang dictionary_id="57657.Ürün"></th>
                            <th width="5%"><cf_get_lang dictionary_id="57635.Miktar"></th>
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
	function checkKeycode(e) 
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			if(document.getElementById('add_other_amount').value.length == 0 || document.getElementById('add_other_amount').value.length == 0)
			{
				alert('<cf_get_lang dictionary_id='29943.Lütfen miktar giriniz.'>');
				document.getElementById('add_other_barcod').focus();	
				return false;
			}
			else
			{
				if (document.getElementById('add_other_barcod').value.length == 0)
				{
					alert('<cf_get_lang dictionary_id='340.Önce Ürün Barkodu Okutunuz'>');
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_lotno').value = '';
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').focus();	
				}
				else
				{
					get_stock(document.getElementById('add_other_barcod').value);
				}
			}
		}
	}

	function get_stock(barcode)
	{
		carpan = ''; birim = ''; barcod = ''; stockid = ''; stockcode = ''; spectmainid = 0; //ilk önce sıfırlıyoruz
		k_= 0;
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
			var new_sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER,S.PRODUCT_NAME,ISNULL(S.IS_PROTOTYPE,0) AS IS_PROTOTYPE, ISNULL(S.IS_SERIAL_NO,0) AS IS_SERIAL_NO FROM STOCKS_BARCODES AS SB INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '"+barcode+"'";
		 	var get_product = wrk_query(new_sql,'dsn3');
				
			if (get_product.STOCK_ID == undefined)
			{
				k_= 1;
				alert('<cf_get_lang dictionary_id='341.Ürün Bulunamadı'>');
			}
			else
			{
				carpan = get_product.MULTIPLIER;
				birim = get_product.MAIN_UNIT;
				stockid = get_product.STOCK_ID;
				product_name = get_product.PRODUCT_NAME;
				lotno=0;
				orderid=0;
				document.getElementById('ana_stock_id').value=stockid;
				document.getElementById('ana_product_name').value=product_name;
				document.getElementById('ana_spect_main_id').value=spectmainid;
				
				if(get_product.IS_SERIAL_NO == 0)
				{
					k_= 1;
					alert('Seri No Girilemeyen Ürün Düzenleme Yapınız!!!');
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus();
				}
				else if(get_product.IS_PROTOTYPE==1 && spectmainid == 0)
				{
					k_= 1;
					alert('<cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'> : <cf_get_lang dictionary_id='36006.Spekt ID'>');
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus();
				}
				else
				{
					document.getElementById('add_other_lotno').focus();
				}
				if (k_ == 0)
					get_lotno(get_product.IS_PROTOTYPE,stockid,spectmainid);
			}
		}
		else
		{
			carpan = ''; birim = ''; barcod = ''; stockid = ''; stockcode = ''; spectmainid = 0;
			return false;
		}
	}

	function add_row(barcod,product_name,stockid,spectmainid,lotno,orderrowid,amount)
	{
		row_count = document.getElementById('row_count').value;
		
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
		newCell.innerHTML = '<input type="hidden" name="row_kontrol'+row_count+'" id="row_kontrol'+row_count+'" value="1"><input name="BARCODE'+row_count+'" id="BARCODE'+row_count+'" type="text" value="'+barcod+'" style="width:80px">';
		
		newCell = newRow.insertCell();
		newCell.innerHTML = '<input name="LOT_NO'+row_count+'" id="LOT_NO'+row_count+'" type="text" value="'+lotno+'" style="width:60px">';
				
		newCell = newRow.insertCell();
		newCell.innerHTML = '<input name="PRODUCT_NAME'+row_count+'" id="PRODUCT_NAME'+row_count+'" type="text" value="'+product_name+'" style="width:100%"><input name="STOCK_ID'+row_count+'" id="STOCK_ID'+row_count+'" type="hidden" value="'+stockid+'"><input name="SPECT_MAIN_ID'+row_count+'" id="SPECT_MAIN_ID'+row_count+'" type="hidden" value="'+spectmainid+'"><input name="ORDER_ROW_ID'+row_count+'" id="ORDER_ROW_ID'+row_count+'" type="hidden" value="'+orderrowid+'"><input name="LOT_NO'+row_count+'" id="LOT_NO'+row_count+'" type="hidden" value="'+lotno+'">';	
		
		newCell = newRow.insertCell();
		newCell.innerHTML = '<input name="AMOUNT'+row_count+'" id="AMOUNT'+row_count+'" type="text" value="'+amount+'" style="width:40px;text-align:right">';
			
		tus_ac();
		
		document.getElementById('order_onay1').style.display='none';
		document.getElementById('fourth_area').style.display='none';
		document.getElementById('fifth_area').style.display='none';
		
		document.getElementById('ana_stock_id').value='';
		document.getElementById('ana_product_name').value='';
		document.getElementById('ana_spect_main_id').value=0;
		
		document.getElementById('add_other_barcod').value = '';
		document.getElementById('add_other_lotno').value = '';
		document.getElementById('add_other_amount').value = 1;
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
			sor = confirm("<cf_get_lang dictionary_id='57535.Kaydetmek İstediğinizden Emin Misiniz?'>");
			if(sor==true)
			{
				window.open('<cfoutput>#request.self#?fuseaction=stock.emptypopup_add_ezgi_count_warehouse&process_cat=#get_process_cat.process_cat_id#</cfoutput>&dep_in='+document.getElementById('txt_department_in_select').value+'&row_info_id='+document.getElementById('row_info_id').value,'_blank');	
				window.location.reload();
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
				document.getElementById('row_info_id').value = document.getElementById('row_info_id').value + document.getElementById('STOCK_ID'+i).value + '-';
				document.getElementById('row_info_id').value = document.getElementById('row_info_id').value + document.getElementById('SPECT_MAIN_ID'+i).value + '-';
				document.getElementById('row_info_id').value = document.getElementById('row_info_id').value + document.getElementById('AMOUNT'+i).value + '-';
				document.getElementById('row_info_id').value = document.getElementById('row_info_id').value + document.getElementById('LOT_NO'+i).value + '-';
				document.getElementById('row_info_id').value = document.getElementById('row_info_id').value + document.getElementById('ORDER_ROW_ID'+i).value;
				j++;
		  	}
	  	}
	}
	function new_order_select(order_id)
	{
		if(document.getElementById('get_new_order').value == '')
			document.getElementById('order_onay1').style.display='none';
		else
			document.getElementById('order_onay1').style.display='';
	}
	function order_onay(type)
	{
		if(type==1)
		{
			orderrowid=document.getElementById('get_new_order').value;	
		}
		else if(type==2)
		{
			orderrowid=0;
		}
		else if(type==3)
		{
			document.getElementById('order_onay1').style.display='none';
			document.getElementById('fourth_area').style.display='none';
			document.getElementById('fifth_area').style.display='none';
			
			document.getElementById('ana_stock_id').value='';
			document.getElementById('ana_product_name').value='';
			document.getElementById('ana_spect_main_id').value=0;
			
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_lotno').value = '';
			document.getElementById('add_other_amount').value = 1;
			document.getElementById('add_other_barcod').focus(); /*Barkod Alanını Temizle ve Yeniden Barkoda Odaklan*/
		}
		if(type==1 || type==2)
		{
			if(document.getElementById('add_other_lotno').value=='')
				lotno=0;
			else
				lotno=document.getElementById('add_other_lotno').value;
			
			stockid=document.getElementById('ana_stock_id').value;
			spectmainid=document.getElementById('ana_spect_main_id').value;
			product_name=document.getElementById('ana_product_name').value;
			add_row(document.getElementById('add_other_barcod').value,product_name,stockid,spectmainid,lotno,orderrowid,document.getElementById('add_other_amount').value);
		}
	}
	function get_lotno(isprototype,stockid,spectmainid)
	{
		document.getElementById('fifth_area').style.display='';	
		if(document.getElementById('add_other_lotno').value == '')
		{
						
		}
		else
		{
			if(spectmainid==0)
			{
				var lot_sql = "SELECT DISTINCT ORR.ORDER_ROW_ID, O.ORDER_NUMBER, O.ORDER_ID, ISNULL(O.COMPANY_ID,0) AS COMPANY_ID, ISNULL(O.CONSUMER_ID,0) AS CONSUMER_ID FROM ORDER_ROW AS ORR INNER JOIN PRODUCTION_ORDERS_ROW AS POR ON ORR.ORDER_ROW_ID = POR.ORDER_ROW_ID INNER JOIN PRODUCTION_ORDERS AS PO ON POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID INNER JOIN ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID WHERE PO.PRODUCTION_LEVEL = '0' AND PO.LOT_NO = '"+document.getElementById('add_other_lotno').value+"' AND PO.STOCK_ID = "+stockid+" UNION ALL SELECT DISTINCT ORR.ORDER_ROW_ID, O.ORDER_NUMBER, O.ORDER_ID, ISNULL(O.COMPANY_ID, 0) AS COMPANY_ID, ISNULL(O.CONSUMER_ID, 0) AS CONSUMER_ID FROM ORDER_ROW AS ORR INNER JOIN ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN EZGI_IFLOW_PRODUCTION_ORDERS_ROW AS PORR ON ORR.ORDER_ROW_ID = PORR.ORDER_ROW_ID INNER JOIN EZGI_IFLOW_PRODUCTION_ORDERS AS EPO ON PORR.PRODUCTION_ORDER_ID = EPO.IFLOW_P_ORDER_ID INNER JOIN PRODUCTION_ORDERS AS PO ON EPO.LOT_NO = PO.LOT_NO WHERE PO.PRODUCTION_LEVEL = '0' AND PO.LOT_NO = '"+document.getElementById('add_other_lotno').value+"' AND PO.STOCK_ID = "+stockid+"";
			}
			else
			{
				var lot_sql = "SELECT DISTINCT ORR.ORDER_ROW_ID, O.ORDER_NUMBER, O.ORDER_ID, ISNULL(O.COMPANY_ID,0) AS COMPANY_ID, ISNULL(O.CONSUMER_ID,0) AS CONSUMER_ID FROM ORDER_ROW AS ORR INNER JOIN PRODUCTION_ORDERS_ROW AS POR ON ORR.ORDER_ROW_ID = POR.ORDER_ROW_ID INNER JOIN PRODUCTION_ORDERS AS PO ON POR.PRODUCTION_ORDER_ID = PO.P_ORDER_ID INNER JOIN ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID WHERE PO.PRODUCTION_LEVEL = '0' AND PO.LOT_NO = '"+document.getElementById('add_other_lotno').value+"' AND PO.STOCK_ID = "+stockid+" AND ISNULL(PO.SPEC_MAIN_ID,0) = "+spectmainid+" UNION ALL SELECT DISTINCT ORR.ORDER_ROW_ID, O.ORDER_NUMBER, O.ORDER_ID, ISNULL(O.COMPANY_ID, 0) AS COMPANY_ID, ISNULL(O.CONSUMER_ID, 0) AS CONSUMER_ID FROM ORDER_ROW AS ORR INNER JOIN ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN EZGI_IFLOW_PRODUCTION_ORDERS_ROW AS PORR ON ORR.ORDER_ROW_ID = PORR.ORDER_ROW_ID INNER JOIN EZGI_IFLOW_PRODUCTION_ORDERS AS EPO ON PORR.PRODUCTION_ORDER_ID = EPO.IFLOW_P_ORDER_ID INNER JOIN PRODUCTION_ORDERS AS PO ON EPO.LOT_NO = PO.LOT_NO WHERE PO.PRODUCTION_LEVEL = '0' AND PO.LOT_NO = '"+document.getElementById('add_other_lotno').value+"' AND PO.STOCK_ID = "+stockid+" AND ISNULL(PO.SPEC_MAIN_ID,0) = "+spectmainid+"";
			}
			var get_lot = wrk_query(lot_sql,'dsn3');
			if (get_lot.recordcount >0)
			{
				document.getElementById('fourth_area').style.display='';
				document.getElementById('fifth_area').style.display='';
				document.getElementById('order_select').focus();
				var option_count = document.getElementById('get_new_order').options.length; 
				for(x=option_count;x>=0;x--)
					document.getElementById('get_new_order').options[x] = null;
				if(get_lot.recordcount != 0)
				{	
					document.getElementById('get_new_order').options[0] = new Option('Seçiniz','');
					for(var xx=0;xx<get_lot.recordcount;xx++)
						document.getElementById('get_new_order').options[xx+1]=new Option(get_lot.ORDER_NUMBER[xx],get_lot.ORDER_ROW_ID[xx]);
				}
				else
					document.getElementById('get_new_order').options[0] = new Option('Seçiniz','');
			}
			else
			{
				alert('<cf_get_lang dictionary_id='34132.Sipariş Kaydı Bulunamdı'>');
				
				document.getElementById('order_onay1').style.display='none';
				document.getElementById('fourth_area').style.display='none';
				document.getElementById('fifth_area').style.display='none';
				
				document.getElementById('ana_stock_id').value='';
				document.getElementById('ana_product_name').value='';
				document.getElementById('ana_spect_main_id').value=0;
				
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_lotno').value = '';
				document.getElementById('add_other_amount').value = 1;
				document.getElementById('add_other_barcod').focus(); /*Barkod Alanını Temizle ve Yeniden Barkoda Odaklan*/
			}	
		}
	}
</script>