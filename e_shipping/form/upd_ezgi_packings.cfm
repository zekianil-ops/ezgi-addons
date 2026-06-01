<!---
    File: upd_ezgi_packings.cfm
    Folder: Add_Ons\ezgi\e_shipping\form
    Author: Ezgi Yazılım
    Date: 01/01/2022
    Description:
--->
<cf_xml_page_edit>
<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_SHIPPING_DEFAULTS
</cfquery>
<cfquery name="get_upd" datasource="#dsn3#">
	SELECT * FROM .EZGI_PACKING WHERE PACKING_ID = #attributes.packing_id#
</cfquery>
<cfquery name="get_upd_row" datasource="#dsn3#">
	SELECT * FROM EZGI_PACKING_ROW WHERE PACKING_ID = #attributes.packing_id#
</cfquery>
<cfif get_upd.TYPE eq 2 or get_upd.TYPE eq 3 or get_upd.TYPE eq 4>
	<cfif len(get_upd.ORDER_ID)>
        <cfquery name="get_order" datasource="#dsn3#">
        	SELECT ORDER_NUMBER FROM ORDERS WHERE ORDER_ID = #get_upd.ORDER_ID#
        </cfquery>
    </cfif>
    <cfif get_upd.type eq 4 AND len(get_upd.ORDER_ID)>
    	<cfquery name="GET_PACKETS" datasource="#DSN3#">
        	SELECT 
                TBL.PAKET_ID, 
                TBL.PRODUCT_NAME, 
                TBL.SPECT_MAIN_ID, 
                SUM(TBL.PAKET_SAYISI) AS PAKET_SAYISI, 
                ISNULL(TBL_1.AMOUNT, 0) AS CONTROL_AMOUNT,
                TBL.BARCOD
            FROM     
                (
                    SELECT 
                    	#get_upd.ORDER_ID# AS ORDER_ID,
                        EPS.PAKET_ID, 
                        ORR.QUANTITY * EPS.PAKET_SAYISI AS PAKET_SAYISI, 
                        S1.PRODUCT_NAME, 
                        ISNULL(SP.SPECT_MAIN_ID, 0) AS SPECT_MAIN_ID,
                        S1.BARCOD
                    FROM      
                        EZGI_IFLOW_PRODUCTION_ORDERS AS EIPO WITH (NOLOCK) INNER JOIN
                        EZGI_IFLOW_PRODUCTION_ORDERS_ROW AS EIPOR WITH (NOLOCK) ON EIPO.IFLOW_P_ORDER_ID = EIPOR.PRODUCTION_ORDER_ID INNER JOIN
                        ORDER_ROW AS ORR WITH (NOLOCK) ON EIPOR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                        ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
                        EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON ORR.STOCK_ID = EPS.MODUL_ID INNER JOIN
                        STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID INNER JOIN
                        STOCKS AS S1 WITH (NOLOCK) ON EPS.PAKET_ID = S1.STOCK_ID LEFT OUTER JOIN
                        SPECTS AS SP WITH (NOLOCK) ON ORR.SPECT_VAR_ID = SP.SPECT_VAR_ID
                    WHERE   
                        EIPO.LOT_NO = '#get_upd.LOT_NO#' AND 
                        O.ORDER_ID = #get_upd.ORDER_ID# AND 
                        ISNULL(S.IS_PROTOTYPE,0) = 0
                    UNION ALL
                    SELECT 
                    	#get_upd.ORDER_ID# AS ORDER_ID,
                        EPS.PAKET_ID, 
                        ORR.QUANTITY * EPS.PAKET_SAYISI AS PAKET_SAYISI, 
                        S1.PRODUCT_NAME, 
                        ISNULL(SP.SPECT_MAIN_ID, 0) AS SPECT_MAIN_ID,
                        S1.BARCOD
                    FROM     
                        SPECTS AS SP WITH (NOLOCK) INNER JOIN
                        EZGI_IFLOW_PRODUCTION_ORDERS AS EIPO WITH (NOLOCK) INNER JOIN
                        EZGI_IFLOW_PRODUCTION_ORDERS_ROW AS EIPOR WITH (NOLOCK) ON EIPO.IFLOW_P_ORDER_ID = EIPOR.PRODUCTION_ORDER_ID INNER JOIN
                        ORDER_ROW AS ORR WITH (NOLOCK) ON EIPOR.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
                        ORDERS AS O WITH (NOLOCK) ON ORR.ORDER_ID = O.ORDER_ID INNER JOIN
                        STOCKS AS S WITH (NOLOCK) ON ORR.STOCK_ID = S.STOCK_ID ON SP.SPECT_VAR_ID = ORR.SPECT_VAR_ID INNER JOIN
                        STOCKS AS S1 WITH (NOLOCK) INNER JOIN
                        EZGI_PAKET_SAYISI AS EPS WITH (NOLOCK) ON S1.STOCK_ID = EPS.PAKET_ID ON SP.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID
                    WHERE  
                        EIPO.LOT_NO = '#get_upd.LOT_NO#' AND 
                        O.ORDER_ID = #get_upd.ORDER_ID# AND 
                        ISNULL(S.IS_PROTOTYPE, 0) = 1
                ) AS TBL LEFT OUTER JOIN

                (
                    SELECT 
                        EPR.STOCK_ID, 
                        EPR.SPECT_MAIN_ID, 
                        SUM(EPR.AMOUNT) AS AMOUNT,
                        EP.ORDER_ID
                    FROM      
                        EZGI_PACKING_ROW AS EPR WITH (NOLOCK) INNER JOIN
                        EZGI_PACKING AS EP WITH (NOLOCK) ON EPR.PACKING_ID = EP.PACKING_ID
                    WHERE   
                        EP.LOT_NO = '#get_upd.LOT_NO#'
                    GROUP BY 
                        EPR.STOCK_ID, 
                        EPR.SPECT_MAIN_ID,
                        EP.ORDER_ID
                ) AS TBL_1 ON TBL.ORDER_ID = TBL_1.ORDER_ID AND TBL.SPECT_MAIN_ID = TBL_1.SPECT_MAIN_ID AND TBL.PAKET_ID = TBL_1.STOCK_ID
            GROUP BY 
                TBL.PAKET_ID, 
                TBL.PRODUCT_NAME, 
                TBL.SPECT_MAIN_ID, 
                TBL_1.STOCK_ID, 
                TBL_1.AMOUNT,
                TBL.BARCOD
            ORDER BY 
                TBL.PRODUCT_NAME
        </cfquery>
    </cfif>
</cfif>
<cfif get_upd.recordcount>
	<cfset recordnum = get_upd_row.recordcount>
<cfelse>
	<cfset recordnum = 0>
</cfif>
<cfif not len(get_defaults.EAN) and not isnumeric(get_defaults.EAN)>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='356.Ürün Barkod Karakter Sayısı Hatalı'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
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
  var barcode_boy = <cfoutput>#get_defaults.EAN#</cfoutput>
</script>
<cfsavecontent variable="title_">
	<cfif get_upd.type eq 1><cf_get_lang dictionary_id='820.Standart Paket'></cfif>
   	<cfif get_upd.type eq 2><cf_get_lang dictionary_id='821.Özel Paket'></cfif>
    <cfif get_upd.type eq 3><cf_get_lang dictionary_id='822.Lokasyon Paleti'></cfif>
 	<cfif get_upd.type eq 4><cf_get_lang dictionary_id='59323.Lot Bazında'> <cf_get_lang dictionary_id='37244.Palet'></cfif>
    : <cfoutput>#get_upd.barcode# <cfif get_upd.TYPE eq 2 or get_upd.TYPE eq 3 or get_upd.TYPE eq 4> - #get_order.ORDER_NUMBER#</cfif></cfoutput>
</cfsavecontent>
<cf_catalystHeader>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#title_#">
    	<cfform name="upd_packings">
          	<cfinput type="hidden" name="packing_id" value="#attributes.packing_id#">
            <cf_basket_form id="upd_packings">
                <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
                                	<div class="col col-3 col-md-4 col-sm-6 col-xs-12" type="column" index="1" sort="true">
                                        <div class="form-group" id="item-status">
                                            <label class="col col-2 col-xs-12"><cf_get_lang dictionary_id='57493.Aktif'></label>
                                            <div class="col col-3 col-xs-12">
                                                <input type="checkbox" id="status" name="status" value="1" <cfif get_upd.STATUS>checked</cfif>>
                                            </div>
                                            <cfif get_upd.TYPE eq 2 or get_upd.TYPE eq 3>
                                                <label class="col col-2 col-xs-12"><cf_get_lang dictionary_id='58211.Sipariş No'></label>
                                                <div class="col col-5 col-xs-12">
                                                    <cfif isdefined('get_order.order_number')>
                                                    <input type="text" name="order_number" readonly value="<cfoutput>#get_order.order_number#</cfoutput>" >
                                                    </cfif>
                                                </div>
                                            </cfif>
                                            <cfif get_upd.TYPE eq 4>
                                                <label class="col col-2 col-xs-12"><cf_get_lang dictionary_id='41701.Lot No'></label>
                                                <div class="col col-5 col-xs-12">
                                                    <input type="text" name="lot_no" readonly value="<cfoutput>#get_upd.LOT_NO#</cfoutput>" >
                                                </div>
                                            </cfif>
                                        </div>
                                        <div class="form-group" id="item-input">
                                        	<label class="col col-2 col-xs-12"><cf_get_lang dictionary_id='57635.Miktar'></label>
                                        	<div class="col col-3 col-xs-12">
                                            	<input name="add_other_amount" id="add_other_amount" type="text" onfocus="islemtipi=0;" style="text-align:right" value="1" onKeyup="return(FormatCurrency(this,event,0));">
                                            </div>
                                            <label class="col col-2 col-xs-12"><cf_get_lang dictionary_id='57633.Barkod'></label>
                                            <div class="col col-5 col-xs-12">
                                            	<input id="add_other_barcod" name="add_other_barcod" type="text" value="" onKeyPress="return noenter()">
                                            </div>
                                            <cfif get_defaults.PALET_BARCODE_LOT eq 1>
                                            	<label class="col col-2 col-xs-12"><cf_get_lang dictionary_id='41701.Lot No'></label>
                                                <div class="col col-5 col-xs-12">
                                                    <input id="add_other_lot" name="add_other_lot" type="text" value="" onKeyPress="return noenter()">
                                                </div>	
                                            </cfif>
                                        </div>
                                  	</div>
                              	</cf_box_elements>
                    			<cf_box_footer>
                                	<cf_record_info 
                                        query_name="get_upd"
                                        record_emp="RECORD_EMP" 
                                        record_date="record_date"
                                        update_emp="UPDATE_EMP"
                                        update_date="update_date">
                                      	<input id="sil" name="sil" style="background-color:red" value="<cf_get_lang dictionary_id="57463.Sil">" type="button"  onClick="kontrol_kayit(0);" />
                                        <input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57464.Güncelle">" type="button" onClick="kontrol_kayit(1);" />
                				</cf_box_footer>
                			</div>
            			</div>
        		</div>
    		</cf_basket_form>
            <cf_basket id="upd_packings_bask">
            	<cf_form_list>
                	<thead>
                     	<tr>
                       		<th style="width:20px">
                           		<input type="hidden" name="record_num" id="record_num" value="<cfoutput>#recordnum#</cfoutput>">
                         	</th>
                            <th style="width:100px"><cf_get_lang dictionary_id='57633.Barkod'></th>
                            <cfif get_defaults.PALET_BARCODE_LOT eq 1>
                            	<th style="width:80px"><cf_get_lang dictionary_id='41701.Lot No'></th>
                            </cfif>
                        	<th style="width:100%"><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                         	<th style="width:40px"><cf_get_lang dictionary_id='57635.Miktar'></th>
                       	</tr>
                  	</thead>
                    <tbody name="table1" id="table1" >
                   		<cfif get_upd_row.recordcount>
                       		<cfoutput query="get_upd_row">
                            	<cfquery name="get_stock_info" datasource="#dsn3#">
                                	SELECT PRODUCT_NAME,BARCOD FROM STOCKS WITH (NOLOCK) WHERE STOCK_ID = #STOCK_ID# AND IS_PROTOTYPE = 0
                                    UNION ALL
                                    SELECT E.PACKAGE_NAME AS PRODUCT_NAME, S.BARCOD FROM EZGI_DESIGN_PACKAGE_ROW AS E WITH (NOLOCK) INNER JOIN STOCKS AS S WITH (NOLOCK) ON E.PACKAGE_RELATED_ID = S.STOCK_ID WHERE E.PACKAGE_SPECT_RELATED_ID = #SPECT_MAIN_ID# AND S.IS_PROTOTYPE = 1
                                </cfquery>
                            	<input type="hidden" name="row_kontrol#currentrow#" id="row_kontrol#currentrow#" value="1">
                             	<tr name="frm_row#currentrow#" id="frm_row#currentrow#">
                             		<td><a style="cursor:pointer" onclick="sil(#currentrow#);" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a></td>
                                    <td class="boxtext" style="width:100px">
                                    	
                                        <input type="text" name="barcode#currentrow#" value="#get_stock_info.barcod#<cfif get_upd_row.SPECT_MAIN_ID gt 0>#get_upd_row.SPECT_MAIN_ID#</cfif>" style="width:100px; height:20px; border-style:hidden">
                                        <input type="hidden" value="#STOCK_ID#" name="stockid#currentrow#" id="stockid#currentrow#" />
                                        <input type="hidden" value="#SPECT_MAIN_ID#" name="spectmainid#currentrow#" id="spectmainid#currentrow#" />
                                    </td>
                                    <cfif get_defaults.PALET_BARCODE_LOT eq 1>
                                    <td ><input type="text" name="lot_no#currentrow#" id="lot_no#currentrow#" value="#get_upd_row.LOT_NO#" style="width:80px; height:20px; border-style:hidden"></td>
                                    </cfif>
                                 	<td ><input type="text" name="product_name#currentrow#" value="#get_stock_info.PRODUCT_NAME#" style="width:98%; height:20px; border-style:hidden"></td>
                                 	<td style="text-align:right">
                                  		<input type="text" name="amount#currentrow#" id="amount#currentrow#" value="#TlFormat(get_upd_row.AMOUNT,0)#" onkeyup="isNumber(this);"  style="width:40px; text-align:right; height:20px; border-style:hidden">
                                  	</td>
                             	</tr>
                          	</cfoutput>
                   		</cfif>
                 	</tbody>
                    <tfoot>
                    <tr>	
                        <td colspan="5">
                            <input type="hidden" id="row_count" name="row_count" value="<cfoutput>#recordnum#</cfoutput>" />
                            <input type="hidden" id="action_id" name="action_id" value="" />
                       	</td>
                    </tr>
                </tfoot>
               	</cf_form_list>
            </cf_basket>
 		</cfform>
   	</cf_box>
</div>
<cfif get_upd.type eq 4>
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cf_box title="Lot Listesi"> 
        	<cf_grid_list>
              	<thead>
                  	<tr>
                       	<th>Ürün Adı</th>
                      	<th style="width:30px">Miktar</th>
                      	<th style="width:30px; height:15px">Kontrol</th>
                   	</tr>
               	</thead>
           		<tbody>
                	<cfif GET_PACKETS.recordcount>
                     	<cfoutput query="GET_PACKETS">
                         	<tr>
                             	<td>#PRODUCT_NAME#</td>
                              	<td style="text-align:right">#TlFormat(PAKET_SAYISI,0)#</td>
                              	<td style="text-align:right; color:<cfif PAKET_SAYISI lt CONTROL_AMOUNT>red<cfelseif PAKET_SAYISI eq CONTROL_AMOUNT>green<cfelse>black</cfif>">#TlFormat(CONTROL_AMOUNT,0)#</td>
                        	</tr>
                       	</cfoutput>
            		</cfif>
             	</tbody>
   			</cf_grid_list>
        </cf_box>
    </div>
</cfif>
<script language="javascript" type="text/javascript">
	row_count = document.getElementById('row_count').value;
	$('#add_other_barcod').focus();
	setTimeout("document.getElementById('add_other_barcod').select();",1000);
	document.onkeydown = checkKeycode
	function checkKeycode(e) 
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			if ((document.getElementById('add_other_barcod').value.length > 0) )
			{
				<cfif get_defaults.PALET_BARCODE_LOT eq 1>
					if(document.getElementById('add_other_lot').value.length > 0)
					{
						add_row(document.getElementById('add_other_barcod').value);
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_amount').value = '1';
						document.getElementById('add_other_lot').value = '';
						document.getElementById('add_other_barcod').focus();
					}
					else
					{
						document.getElementById('add_other_lot').focus();
					}
				<cfelse>
					add_row(document.getElementById('add_other_barcod').value);
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_amount').value = '1';
					document.getElementById('add_other_barcod').focus();
				</cfif>
				
			}
			else
			{
				alert('<cf_get_lang dictionary_id='29476.Barkod Hatalı'>');
				document.getElementById('add_other_barcod').value = '';
				<cfif get_defaults.PALET_BARCODE_LOT eq 1>
					document.getElementById('add_other_lot').value = '';
				</cfif>
				document.getElementById('add_other_barcode').focus();
			}
		}
	}
	function noenter() 
	{
  		return !(window.event && window.event.keyCode == 13);
	}
	function actionidolustur()
	{
	  	var j = 0;
	  	for(i=1;i<=row_count;i++)
	  	{
		  	if(document.getElementById('amount'+i).value > 0 && document.getElementById('row_kontrol'+i).value == 1)
		  	{
				if (j > 0)
					document.getElementById('action_id').value = document.getElementById('action_id').value + ',';
				document.getElementById('action_id').value = document.getElementById('action_id').value + i + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('stockid'+i).value + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('spectmainid'+i).value + '-';
				document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('amount'+i).value + '-';
				<cfif get_defaults.PALET_BARCODE_LOT eq 1>
					document.getElementById('action_id').value = document.getElementById('action_id').value + document.getElementById('lot_no'+i).value + '-';
				</cfif>
				document.getElementById('action_id').value = document.getElementById('action_id').value + '0'
				j++;
		  }
		  document.getElementById('row_count').value = j;
	  	}
	}
	function get_stock(barcode)
    {
	 	carpan = ''; birim = ''; barcod = ''; stockid = ''; stockcode = ''; spectmainid = 0; //ilk önce sıfırlıyoruz
	 	k_= 0;
		ekle = 0;
		if(document.getElementById('add_other_amount').value.length == 0)
		{
			alert('<cf_get_lang dictionary_id='29943.Lütfen miktar giriniz.'>');
			k_=1;
			return false;
		}
	 	var uzunluk = barcode.length;
	 	if(barcode.substr(0,1)=='j')//Bazı barkod okuyucular okuduktan sonra başına j harfi koyuyor kontrol için yapıldı
		{
			barcode = barcode.substring(1,barcode_boy+1);
		}
		if(uzunluk > barcode_boy)
		{
			spectmainid = barcode.substring(barcode_boy,uzunluk);
			barcode = barcode.substring(0,barcode_boy);
		}
		<cfif get_defaults.PALET_BARCODE_LOT eq 1>
			lot_no = document.getElementById('add_other_lot').value;
			/*var lot_sql = "SELECT S.STOCK_ID FROM PRODUCTION_ORDERS AS PO INNER JOIN STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID WHERE PO.LOT_NO = '"+lot_no+"' AND S.BARCOD = '"+barcode+"'";*/
		 	/*var get_lot = wrk_query(lot_sql,'dsn3');*/
			
			var listParam = barcode + "*" + lot_no;
			var get_lot = wrk_safe_query('get_p_order_info_barcode_lotno_ezgi','dsn3',0,listParam);
			
		 	if(get_lot.STOCK_ID == undefined)
		 	{
				ekle = 1;
				k_=1;
				alert('<cf_get_lang dictionary_id='38028.Lot No İle Uyuşan Üretim Yok'>');
				return false;
		 	}
		</cfif>
	 	if (k_ == 0)
     	{
		 	/*var new_sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER,S.PRODUCT_NAME FROM STOCKS_BARCODES AS SB INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '"+barcode+"'";*/
		 	/*var get_product = wrk_query(new_sql,'dsn3');*/
			
			var listParam = barcode;
			var get_product = wrk_safe_query('get_product_ezgi','dsn3',0,listParam);
			
		 	if (get_product.STOCK_ID == undefined)
		 	{
				ekle = 1;
				k_=1;
				alert('<cf_get_lang dictionary_id='341.Ürün Bulunamadı'>');
				return false;
		 	}
			else
		 	{	
				carpan = get_product.MULTIPLIER;
				birim = get_product.MAIN_UNIT;
				stockid = get_product.STOCK_ID;
				stockcode = get_product.PRODUCT_NAME;
    		}
		}
		else
		{
			carpan = ''; birim = ''; barcode = ''; stockid = ''; stockcode = ''; spectmainid = 0;
			return false;
		}
		<cfif get_upd.TYPE eq 2 or get_upd.TYPE eq 4> <!---Lokasyon paleti veya stnadart Palet İse Bu Bloğa Girmiyor Ancak, Lokasyon Paleti Yapılmalı--->
			<cfif get_upd.TYPE eq 2> <!---Özel Palet--->
				<!---Koltuk Gibi Özel Ürün Olmadığı halde (Özelleştirilemez) Paket Kontrol Tipi Bileşenleri seçili Tepe Üretimi Yapıldığı için Modül Bakodu okutulabilmesi için İlk UNION yapıldı.--->
				if(spectmainid==0)
				{
					/*var new_sql = "SELECT TOP (1) S.STOCK_ID AS PAKET_ID FROM STOCKS AS S INNER JOIN ORDER_ROW AS ORR ON ORR.STOCK_ID = S.STOCK_ID WHERE S.BARCOD = '"+barcode+"' AND ORR.ORDER_ID = <cfoutput>#get_upd.ORDER_ID#</cfoutput> AND ISNULL(S.IS_PROTOTYPE,0) = 0 UNION ALL SELECT TOP (1) EPS.PAKET_ID FROM STOCKS AS S INNER JOIN ORDER_ROW AS ORR ON S.STOCK_ID = ORR.STOCK_ID INNER JOIN EZGI_PAKET_SAYISI AS EPS ON ORR.STOCK_ID = EPS.MODUL_ID WHERE EPS.BARCOD = '"+barcode+"' AND ORR.ORDER_ID = <cfoutput>#get_upd.ORDER_ID#</cfoutput> AND ISNULL(S.IS_PROTOTYPE,0) = 0";*/
					
					var listParam = <cfoutput>#get_upd.ORDER_ID#</cfoutput> + "*" + barcode;
					var get_control = wrk_safe_query('get_p_order_info_barcode_order_id_ezgi','dsn3',0,listParam);
				}
				else
				{
					/*var new_sql = "SELECT TOP (1) S.STOCK_ID AS PAKET_ID FROM STOCKS AS S INNER JOIN ORDER_ROW AS ORR ON ORR.STOCK_ID = S.STOCK_ID WHERE S.BARCOD = '"+barcode+"' AND ORR.ORDER_ID = <cfoutput>#get_upd.ORDER_ID#</cfoutput> AND ISNULL(S.IS_PROTOTYPE,0) = 1 UNION ALL SELECT TOP (1) EPS.PAKET_ID FROM STOCKS AS S INNER JOIN ORDER_ROW AS ORR ON S.STOCK_ID = ORR.STOCK_ID INNER JOIN SPECTS AS SPC ON ORR.SPECT_VAR_ID = SPC.SPECT_VAR_ID INNER JOIN EZGI_PAKET_SAYISI AS EPS ON SPC.SPECT_MAIN_ID = EPS.MODUL_SPECT_ID WHERE  EPS.MODUL_SPECT_ID = "+spectmainid+" AND EPS.BARCOD = '"+barcode+"' AND ORR.ORDER_ID = <cfoutput>#get_upd.ORDER_ID#</cfoutput> AND ISNULL(S.IS_PROTOTYPE, 0) = 1";*/
					
					var listParam = <cfoutput>#get_upd.ORDER_ID#</cfoutput>+"*"+spectmainid+"*"+ barcode;
					<cfif x_package_spect_type eq 1>
						var get_control = wrk_safe_query('get_p_order_info_order_id_spectmainid_barcode_ezgi','dsn3',0,listParam);
					<cfelseif x_package_spect_type eq 2>
						var get_control = wrk_safe_query('get_p_order_info_order_id_spectmainid_barcode_ezgi_new','dsn3',0,listParam);
						stockcode = get_control.PRODUCT_NAME
					</cfif>
					
				}
				/*var get_control = wrk_query(new_sql,'dsn3');*/
			<cfelseif get_upd.TYPE eq 4> <!---Lot Bazında Palet--->
				if(spectmainid==0)
				{
					/*var new_sql = "SELECT EPS.PAKET_ID FROM PRODUCTION_ORDERS AS PO INNER JOIN STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID INNER JOIN EZGI_PAKET_SAYISI AS EPS ON PO.STOCK_ID = EPS.MODUL_ID WHERE PO.PRODUCTION_LEVEL = '0' AND PO.LOT_NO = '<cfoutput>#get_upd.LOT_NO#</cfoutput>' AND ISNULL(S.IS_PROTOTYPE, 0) = 0 AND EPS.BARCOD = '"+barcode+"'";*/
					
					var listParam = <cfoutput>#get_upd.LOT_NO#</cfoutput> + "*" + barcode;
					var get_control = wrk_safe_query('get_p_order_info_4_lotno_barcode_ezgi','dsn3',0,listParam);
				}
				else
				{
					/*var new_sql = "SELECT EPS.PAKET_ID FROM PRODUCTION_ORDERS AS PO INNER JOIN STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID INNER JOIN EZGI_PAKET_SAYISI AS EPS ON PO.SPEC_MAIN_ID = EPS.MODUL_SPECT_ID WHERE PO.PRODUCTION_LEVEL = '0' AND PO.LOT_NO = '<cfoutput>#get_upd.LOT_NO#</cfoutput>' AND ISNULL(S.IS_PROTOTYPE, 0) = 1 AND EPS.MODUL_SPECT_ID = "+spectmainid+" AND EPS.BARCOD = '"+barcode+"'";*/
					
					var listParam = <cfoutput>#get_upd.LOT_NO#</cfoutput> + "*" + barcode  + "*" + spectmainid;
					var get_control = wrk_safe_query('get_p_order_info_4_lotno_barcode_spectmainid_ezgi','dsn3',0,listParam);
				}
				/*var get_control = wrk_query(new_sql,'dsn3');*/
			</cfif>
			if(get_control.PAKET_ID == undefined)
			{
				ekle = 1;
				k_=1;
				<cfif get_upd.TYPE eq 3>
					alert('Ürün Bu Lokasyona Bağlı Değil');
				<cfelseif get_upd.TYPE eq 2>
					alert('Ürün Bu Siparişe Bağlı Değil');
				<cfelseif get_upd.TYPE eq 4>
					alert('Ürün Bu Lota Bağlı Değil');
				</cfif>
				return false;
			}
		</cfif>
	}
	function add_amount()
	{
		if(row_count >0) /*ilk Satırdan sonrası*/
	  	{
			for(i=1;i<=row_count;i++)
			{
				if(document.getElementById('stockid'+i).value == stockid && document.getElementById('spectmainid'+i).value == spectmainid <cfif get_defaults.PALET_BARCODE_LOT eq 1>&& document.getElementById('lot_no'+i).value == lot_no</cfif>)
				{
					document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
					if (document.getElementById('frm_row'+i).style.display == 'none')
						document.getElementById('frm_row'+i).style.display='block';
					ekle=1;
				}
			}
		}
	}
	function add_row(barcode)
	{
		if(document.getElementById('row_count').value >14)
		{
			alert('<cf_get_lang dictionary_id='1108.Maksimum Kayıt Sayısına Ulaştınız. Bu Ürün İçin Başka Palet Oluşturun'>');	
			return false;
		}
		else
		{
			get_stock(barcode);
			if (k_==0)
			{
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
					newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang_main no='51.Sil'>" border="0"></a';
				
					newCell = newRow.insertCell();
					newCell.innerHTML = '<input type="hidden" value="1" name="row_kontrol'+row_count+'" id="row_kontrol'+row_count+'" /><input type="hidden" value="'+stockid+'" name="stockid'+row_count+'" id="stockid'+row_count+'" /><input type="hidden" value="'+spectmainid+'" name="spectmainid'+row_count+'" id="spectmainid'+row_count+'" /><input type="text" value="'+barcode+'" name="barcod'+row_count+'" id="barcod'+row_count+'" style="width:100px; height:20px; border-style:hidden" readonly="yes" />';
					<cfif get_defaults.PALET_BARCODE_LOT eq 1>
						newCell = newRow.insertCell();
						newCell.innerHTML = '<input type="text" value="'+lot_no+'" name="lot_no'+row_count+'" id="lot_no'+row_count+'" style="width:80px; height:20px; border-style:hidden" readonly="yes" />';
					</cfif>
					newCell = newRow.insertCell();
					newCell.innerHTML = '<input type="text" value="'+stockcode+'" name="stockcode'+row_count+'" id="stockcode'+row_count+'"  readonly="yes" style="width:98%; height:20px; border-style:hidden" />';
					
					newCell = newRow.insertCell();
					newCell.innerHTML = '<input type="text" style="width:40px; text-align:right; height:20px; border-style:hidden" value="'+amount+'" name="amount'+row_count+'" id="amount'+row_count+'" /><input type="hidden" value="'+birim+'" name="birim'+row_count+'" id="birim'+row_count+'" />';
	
				  }
				  else
				  {
					 ekle = 0;
				  }
			}
		}
	}
	function kontrol_kayit(secenek)
	{
		if(secenek ==0)
		{
			sor = confirm("<cf_get_lang dictionary_id='57533.Silmek İstediğinizden Emin Misiniz?'>");
			if(sor==true)
				window.location.href='<cfoutput>#request.self#?fuseaction=sales.emptypopup_upd_ezgi_packings&packing_id=#attributes.packing_id#</cfoutput>&sil=1';	
			else
				return false;
		}
		else
		{
			document.getElementById('action_id').value = '';
			actionidolustur();
			uzunluk = document.getElementById('action_id').value;
			if(uzunluk.length>0)
			{
				sor = confirm("<cf_get_lang dictionary_id='57536.Güncellemek İstediğinizden Emin misiniz?'>");
				if(sor==true)
					window.location.href='<cfoutput>#request.self#?fuseaction=sales.emptypopup_upd_ezgi_packings&packing_id=#attributes.packing_id#</cfoutput>&action_id='+document.getElementById('action_id').value;	
				else
					return false;
			}
		}
	}
	function sil(sy)
	{
		document.getElementById('row_kontrol'+sy).value=0;
		document.getElementById('frm_row'+sy).style.display="none";
	}
</script>
