<!---
    File: add_stock_count_loc.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
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
<cfset default_departments = '#get_default_departments.DEFAULT_MK_TO_RF_DEP#'> <!---Depo seçiminde select satırına gelecek Lokasyonların depatmanları tanımlanır--->
<cfparam name="attributes.department_in_id" default="#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_DEP,2)#-#ListGetAt(get_default_departments.DEFAULT_MK_TO_RF_LOC,2)#">
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
  var spectmainid = '';
  var stockcode = '';
  var amount = '';
  var ekle = 0;
  var cikar = 0;
  var islemtipi = 0;//0-ekle 1-çıkar
  var buton = 0;// <1-buton pasif, >0-buton aktif
</script>
<cfform name="add_stock_count" method="post" action="#request.self#?fuseaction=pda.emptypopup_add_ezgi_stock_count_loc_file" enctype="multipart/form-data"> 
	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    	<cf_box scroll="0">
            <cf_box_search>
            	<div class="col col-12">
                	<div class="col col-4">
                    	<cf_get_lang dictionary_id='57635.Miktar'>
                    </div>
                	<div class="col col-8">
                    	<cf_get_lang dictionary_id='57633.Barkod'>
                    </div>
              	</div>
                <div class="col col-12">
                	<div class="col col-4">
                    	<div class="form-group">
                            <cfinput id="add_other_amount" name="add_other_amount" type="text" onfocus="islemtipi=0;" style=" text-align:right" maxlength="6" value="1" />
                    	</div>
                    </div>
                	<div class="col col-8">
                    	<div class="form-group">
                            <cfinput id="add_other_barcod" name="add_other_barcod" type="text"  maxlength="20" value="" />
                        </div>
                    </div>
               	</div>
                <div class="col col-12">
                	<div class="col col-6">
						<div class="form-group">
                            <cf_get_lang dictionary_id='33658.Giriş Depo'>
                       	</div>
                    </div>
                    <div class="col col-6">
						<div class="form-group">
                           <select name="txt_department" id="txt_department" style="width:140px" onchange="document.getElementById('txt_department_in').value = this.value">
							<cfoutput query="get_all_location" group="department_id">
                              <option disabled="disabled"  value="#department_id#"<cfif attributes.department_in_id eq department_id>selected</cfif>>#department_head#</option>
                              <cfoutput>
                                <option <cfif not status>style="color:FF0000"</cfif> value="#department_id#-#location_id#" <cfif attributes.department_in_id eq '#department_id#-#location_id#'>selected</cfif>>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;#comment#
                                <cfif not status>
                                  -
                                  <cf_get_lang dictionary_id='57494.Pasif'>
                                </cfif>
                                </option>
                              </cfoutput> </cfoutput>
                          </select>
                       	</div>
                    </div>
             	</div>
          	</cf_box_search>
        </cf_box>
        <cfsavecontent variable="title"><cf_get_lang dictionary_id="13.Depo Sayım Belgesi"></cfsavecontent>
        <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
            <cf_form_list>
                <thead>
                    <tr>
                    	<th style="width:5%"></th>
                        <th style="width:20%"><cf_get_lang dictionary_id='57633.Barkod'></th>
                        <th style="width:10%"><cf_get_lang dictionary_id='36006.Spekt ID'></th>
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
                        <td colspan="5" style="text-align:right">
                        	<input type="hidden" id="txt_department_in" name="txt_department_in" value="" />
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
	document.getElementById('add_other_amount').focus();
	setTimeout("document.getElementById('add_other_amount').select();",1000);	
	document.onkeydown = checkKeycode
	function checkKeycode(e) 
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			if (document.getElementById('add_other_barcod').value.length > 0)
			{
				add_row(document.getElementById('add_other_barcod').value);
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_amount').value = '1';
				document.getElementById('add_other_barcod').focus();
			}
			else
			{
				alert('<cf_get_lang dictionary_id='356.Ürün Barkod Karakter Sayısı Hatalı'>');
				document.getElementById('add_other_barcod').value = '';
				document.getElementById('add_other_barcod').focus();	
			}
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
	function get_stock(barcode)
    {
	 	barcod = ''; stockid = ''; stockcode = ''; spectmainid = ''; //ilk önce sıfırlıyoruz
		
		if(barcode.substr(0,1)=='j')//Bazı barkod okuyucular okuduktan sonra başına j harfi koyuyor kontrol için yapıldı
			barcode = barcode.substring(1,length(barcode));
		uzunluk = barcode.length;
		spectmainid = '';
		ean = <cfoutput>#get_defaults.EAN#</cfoutput>;
		if(uzunluk > ean)
		{
			spectmainid = barcode.substring(ean,uzunluk);
			barcode = barcode.substring(0,ean);
		}
		
		/*var new_sql = "SELECT SB.STOCK_ID,SB.BARCODE,PU.MAIN_UNIT,PU.MULTIPLIER, S.PRODUCT_NAME, ISNULL(S.IS_PROTOTYPE,0) IS_PROTOTYPE, ISNULL(S.IS_KARMA,0) IS_KARMA FROM STOCKS_BARCODES AS SB INNER JOIN PRODUCT_UNIT AS PU ON SB.UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN STOCKS AS S ON SB.STOCK_ID = S.STOCK_ID WHERE SB.BARCODE= '"+barcode+"'";*/
		/*var get_product = wrk_query(new_sql,'dsn3');*/


		var listParam = barcode;
		var get_product = wrk_safe_query('get_product_ezgi','dsn3',0,listParam);
		
		
		if (get_product.STOCK_ID == undefined)
		{
			ekle = 1;
			alert('<cf_get_lang dictionary_id='341.Ürün Bulunamadı'>');
		}
		else
		{	
				if(get_product.IS_PROTOTYPE==0)
				{
					stockid = get_product.STOCK_ID;
					stockcode = get_product.PRODUCT_NAME;
					barcode = get_product.PRODUCT_BARCOD;
					spectmainid='';
					if(get_product.IS_KARMA==1)
						karma = 1;
					else
						karma = 0;
					buton_kontrol();
				}
				else if(get_product.IS_PROTOTYPE==1 && spectmainid.length==0)
				{
					alert('<cf_get_lang dictionary_id='51.Özelleştirilebilir Ürün'> : <cf_get_lang dictionary_id='36006.Spekt ID'>');
					document.getElementById('add_other_amount').value = 1;
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('add_other_barcod').focus();
					ekle = 1;
					return false;
				}
				else if (get_product.IS_PROTOTYPE==1 && spectmainid.length>0)
				{
					/*var spect_sql = "SELECT SPECT_STATUS, STOCK_ID FROM SPECT_MAIN WHERE STOCK_ID = "+get_product.STOCK_ID+" AND SPECT_MAIN_ID ="+spectmainid;*/
					/*var get_spect = wrk_query(spect_sql,'dsn3');*/
					
					var listParam = get_product.STOCK_ID + "*" + spectmainid;
					var get_spect = wrk_safe_query('get_spect_main_stock_id_spectmainid_ezgi','dsn3',0,listParam);
						
					if (get_spect.STOCK_ID == undefined)
					{
						alert('<cf_get_lang dictionary_id='34603.Ürüne Ait Bir Spec Kaydedilmemiş!'>');
						document.getElementById('add_other_amount').value = 1;
						document.getElementById('add_other_barcod').value = '';
						document.getElementById('add_other_barcod').focus();
						ekle = 1;
						return false;
					}
					else
					{
						stockid = get_product.STOCK_ID;
						stockcode = get_product.PRODUCT_NAME;
						barcode = get_product.PRODUCT_BARCOD;
						karma = 0;
						buton_kontrol();
					}
				}
    	}
	}
	function add_amount()
	{
		for(i=1;i<=row_count;i++)
		{
			if(document.getElementById('stockid'+i).value == stockid && document.getElementById('spectmainid'+i).value == spectmainid)
			{

				document.getElementById('amount'+i).value = document.getElementById('amount'+i).value - (-1 * amount);
				if (document.getElementById('frm_row'+i).style.display == 'none')
					document.getElementById('frm_row'+i).style.display='block';
				ekle=1;
			}
		}
	}
	function add_row(barcode)
	{
		get_stock(barcode);
		if(barcode.substr(0,1)=='j')//Bazı barkod okuyucular okuduktan sonra başına j harfi koyuyor kontrol için yapıldı
		barcode = barcode.substring(1,length(barcode));
		uzunluk = barcode.length;
		spectmainid = '';
		ean = <cfoutput>#get_defaults.EAN#</cfoutput>;
		if(uzunluk > ean)
		{
			spectmainid = barcode.substring(ean,uzunluk);
			barcode = barcode.substring(0,ean);
		}
		document.getElementById('txt_department').disabled = true;
		amount = document.getElementById('add_other_amount').value;
		<!---add_amount();--->
		if(karma==1)
		{
			/*var karma_sql = "SELECT S.STOCK_ID, S.PRODUCT_NAME, S.PRODUCT_CODE, S.BARCOD, KP.PRODUCT_AMOUNT FROM <cfoutput>#dsn1_alias#</cfoutput>.KARMA_PRODUCTS AS KP INNER JOIN STOCKS AS S ON KP.STOCK_ID = S.STOCK_ID INNER JOIN STOCKS AS S1 ON KP.KARMA_PRODUCT_ID = S1.PRODUCT_ID WHERE S1.STOCK_ID ="+stockid;*/
			/*var get_karma = wrk_query(karma_sql,'dsn3');*/
			
			var listParam =stockid;
			var get_karma = wrk_safe_query('get_stockinfo_in_karma_koli_content_stock_id_ezgi','dsn3',0,listParam);
					
			if(get_karma.recordcount >0)
			{
				for(var i=0; i<get_karma.recordcount; i++) 
				{
					spectmainid = '';
					stockid = get_karma.STOCK_ID[i];
					stockcode = get_karma.PRODUCT_NAME[i];
					barcode = get_karma.BARCOD[i];
					satir_ekle(barcode,spectmainid,amount,stockcode,stockid)
				}
			}
			else
			{
				alert('Demonte Ürüne Ait Paket Bulunamadı!!!');
				return false;
			}
		}
		else
		{
			satir_ekle(barcode,spectmainid,amount,stockcode,stockid)
		}
	}
	function satir_ekle(barcode,spectmainid,amount,stockcode,stockid)
	{
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
			newCell.innerHTML = '<a style="cursor:pointer" onclick="sil(' + row_count + ');" ><img src="/images/delete_list.gif" alt="<cf_get_lang dictionary_id='57463.Sil'>" border="0"></a><input type="hidden" value="1" name="row_kontrol'+row_count+'">';
			
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="hidden" value="'+stockid+'" name="stockid'+row_count+'" id="stockid'+row_count+'" /><input type="text" value="'+barcode+'" name="barcod'+row_count+'" id="barcod'+row_count+'" size="12" readonly="yes" style="text-align:center; border:none"/>';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="text" value="'+spectmainid+'" name="spectmainid'+row_count+'" id="spectmainid'+row_count+' readonly="yes" style="text-align:center; border:none" />';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="text" value="'+stockcode+'" name="stockcode'+row_count+'" id="stockcode'+row_count+'" size="11" readonly="yes" style="text-align:right; border:none" />';
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="text" value="'+amount+'" name="amount'+row_count+'" id="amount'+row_count+'" size="3" readonly="yes"  style="text-align:right; border:none" />';
				
		}
		else
		{
			ekle = 0;
		}
	}
	function include(arr, obj) 
	{
    	for(var i=0; i<arr.length; i++) 
		{
        	if (arr[i] == obj) return true;
    	}
	}
	function kontrol_kayit()
	{
		if(add_stock_count.txt_department.value == "")
		{
			alert('<cf_get_lang dictionary_id='57723.Önce Depo Seçmelisiniz'>.');
			return false;
		}
		else if(add_stock_count.txt_department.value.indexOf('-') == -1)
		{
			alert('<cf_get_lang dictionary_id='349.Lütfen giriş için doğru depo seçiniz'>.');
			return false;
		}
		else
		{
			document.getElementById("txt_department_in").value = document.getElementById("txt_department").value;
		}
		document.getElementById("add_stock_count").submit();
	}
	function sil(sy)
	{
		var element=eval("add_stock_count.row_kontrol"+sy);
		element.value=0;
		var element=eval("frm_row"+sy); 
		element.style.display="none";
	}
</script>
