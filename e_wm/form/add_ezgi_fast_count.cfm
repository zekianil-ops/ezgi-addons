<!---
    File: add_ezgi_fast_count.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/12/2025
    Description: Raf Doğrulama
---> 
<cfparam name="attributes.add_other_shelf" default="">
<cfparam name="attributes.anamenu" default="2">
<cfset default_process_type = 112><!--- Fire Fişi--->
<cfif isdefined('attributes.is_submitted') and len(attributes.add_other_shelf)>
	<cfquery name="get_serial" datasource="#dsn3#">
    	SELECT 
        	E.SERIAL_NO, 
            E.STOCK_ID, 
            E.SPECT_ID, 
            E.PALET_BARCODE, 
            E.PRODUCT_NAME, 
            E.SHELF_CODE,
        	O.ORDER_NUMBER,
            ISNULL((
            	SELECT        
                	ISNULL(MAX(DATEDIFF(DAY, PROCESS_DATE, GETDATE())), 1) AS GUN_FARKI
				FROM            
                	EZGI_WM_FAST_COUNT
				GROUP BY 
                	PRODUCT_PLACE_ID
				HAVING        
                	PRODUCT_PLACE_ID = E.PRODUCT_PLACE_ID
            ),1) AS LAST_COUNT
		FROM     
      		EZGI_WM_IS_SERIAL_NO_LIVE INNER JOIN
          	EZGI_WM_SERIAL_NO_LAST_STATUS AS E ON EZGI_WM_IS_SERIAL_NO_LIVE.SERIAL_NO = E.SERIAL_NO LEFT OUTER JOIN
         	ORDER_ROW AS ORR INNER JOIN
         	EZGI_WM_SERIAL_NO_ORDER_LAST_STATUS AS OE ON ORR.ORDER_ROW_ID = OE.RESERVE_ORDER_ROW_ID INNER JOIN
       		ORDERS AS O ON ORR.ORDER_ID = O.ORDER_ID ON E.SERIAL_NO = OE.SERIAL_NO
		WHERE  
        	E.SHELF_CODE = '#attributes.add_other_shelf#'
		ORDER BY 
        	E.PALET_BARCODE, 
            E.SERIAL_NO
    </cfquery>
    <cfif not get_serial.recordcount>
    	<script type="text/javascript">
            alert("Rafta Sayım Yapılacak Ürün Yoktur!");
            window.history.go(-1);
        </script>
    	<cfabort>
    </cfif>
    <cfif get_serial.LAST_COUNT eq 0>
    	<script type="text/javascript">
            alert("Sistemde Bu Güne Ait Sayım Fişi Mevcuttur!");
            window.history.go(-1);
        </script>
    	<cfabort>
    </cfif>
<cfelse>
	<cfset get_serial.recordcount =0>
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
		alert("<cf_get_lang dictionary_id='333.İşlem Kategorisi Tanımlayınız!'>");
		history.back();	
	</script>
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
 	<cfform name="add_ezgi_fast_count" id="add_ezgi_fast_count" action="" method="post">
     	<input name="is_submitted" type="hidden" value="1">	
     	<cf_basket_form id="add_ezgi_package_transfer">
        	<div class="row">
          		<div class="col col-12 uniqueRow">
               		<div class="row formContent">
                  		<cf_box_elements>
                     		<div class="col col-12 uniqueRow" id="first_area" <cfif isdefined('attributes.is_submitted')>style="display:none"</cfif>>
                             	<div class="col col-12">
                                	<div class="col col-3">
                                     	<label><cf_get_lang dictionary_id='45254.Raf No'></label>
                                	</div>
                                 	<div class="col col-9">
                                   		<div class="form-group" id="item-barcod">
                                        	<input id="add_other_shelf" name="add_other_shelf" type="text" value="<cfoutput>#attributes.add_other_shelf#</cfoutput>">
                                     	</div>
                                	</div>
                             	</div>
                       		</div>
                        	<div class="col col-12 uniqueRow" id="second_area" <cfif not isdefined('attributes.is_submitted')>style="display:none"</cfif>>
                            	<div class="col col-12">
                                	<div class="col col-3">
                                      	<label><cf_get_lang dictionary_id='57637.Seri No'></label>
                                 	</div>
                                	<div class="col col-9">
                                   		<div class="form-group" id="item-barcod">
                                         	<input id="add_other_barcod" name="add_other_barcod" type="text" value="">
                                    	</div>
                                 	</div>
                           		</div>
                       		</div>
               			</cf_box_elements>
                  		<cf_box_footer>
                     		<div class="col col-12">
                            	<div class="col col-6" style="text-align:right">
                             	</div>
                             	<div class="col col-6" style="text-align:right;" id="onay_div" style=" display:none">
                                  	<input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" onClick="kontrol_kayit();" />
                            	</div>
                        	</div>
              			</cf_box_footer>
               		</div>
             	</div>
       		</div>
   		</cf_basket_form>
            
      	
        <cfsavecontent variable="sekme1"><cf_get_lang dictionary_id="57314.Kontrol Edilmiş"></cfsavecontent>
        <cfsavecontent variable="sekme2"><cf_get_lang dictionary_id="57315.Kontrol Edilmemiş"></cfsavecontent>
        <div id="basket_main_div">
        	<div class="row">
                <div class="col col-12 uniqueRow">
                    <cf_basket_form id="upd_connect" class="row">
                        <div id="tab-container" class="tabStandart margin-top-5">
                            <div id="tab-head">
                                <ul class="tabNav">
                                	<li class="<cfif attributes.anamenu eq 2>active</cfif>"><a id="href_minfo" href="#icerik"><cfoutput>#sekme2#</cfoutput></a></li>
                                    <li class="<cfif attributes.anamenu eq 1>active</cfif>"><a id="href_urunler" href="#ship_list"><cfoutput>#sekme1#</cfoutput></a></li>
                                    
                                </ul>
                            </div>
                            <div id="tab-content" class="margin-top-10"> 
                                <cfsavecontent variable="title"><cf_get_lang dictionary_id="45667.Raf"> : <cfoutput>#attributes.add_other_shelf#</cfoutput></cfsavecontent>
                                
                                <div id="icerik" class="content row">
									<cf_box title="#title#">
                                        <cf_grid_list>
                                        	<thead>
                                                <tr>
                                                	<th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                    <th style="width:75px"><cf_get_lang dictionary_id='57637.Seri No'></th>
                                                    <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                                </tr>
                                            </thead>
                                            <cfinput type="hidden" id="row_count_sevk" name="row_count_sevk" value="#get_serial.recordcount#">
                                            <tbody>
                                                <cfif get_serial.recordcount>
                                                    <cfoutput query="get_serial">
                                                    	<cfinput type="hidden" name="row_control_#currentrow#" id="row_control_#currentrow#" value="#SERIAL_NO#" >
                                                        <cfinput type="hidden" name="PRODUCT_NAME_#currentrow#" id="PRODUCT_NAME_#currentrow#" value="#PRODUCT_NAME#" >
                                                        <tr id="row#currentrow#" height="20">
                                                        	<td style="text-align:center">#currentrow#</td>
                                                            <td style="text-align:center">#SERIAL_NO#</td>        
                                                            <td style="text-align:left">#PRODUCT_NAME#</td>
                                                         </tr>
                                                    </cfoutput>
                                                </cfif>
                                            </tbody>
                                        
                                        </cf_grid_list>
                                    </cf_box>
                                </div>
                                
                                <div id="ship_list" class="content row">
                                    <cf_box title="#title#">
                                        <cf_grid_list>
                                            <thead>
                                                <tr>
                                                	<th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                    <th style="width:75px"><cf_get_lang dictionary_id='57637.Seri No'></th>
                                                    <th><cf_get_lang dictionary_id='58221.Ürün Adı'></th>
                                                </tr>
                                            </thead>
                                            <cfinput type="hidden" id="row_count_content" name="row_count_content" value="0">
                                         	<tbody name="table2" id="table2">
                                       		</tbody>
                                        </cf_grid_list>
                                    </cf_box>
                             	</div>
                                
                            </div>
                        </div>
                    </cf_basket_form>
                </div>
           	</div>                     
       	</div>                         
	</cfform>
</div>
<script language="javascript" type="text/javascript">
	<cfif isdefined('attributes.is_submitted')>
		document.getElementById('add_other_barcod').focus();
		setTimeout("document.getElementById('add_other_barcod').select();",1000);
	<cfelse>
		document.getElementById('add_other_shelf').focus();
	</cfif>
	document.onkeydown = checkKeycode
	function checkKeycode(e) /*Barkod Okuyup Enter Basıldığında*/
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			<cfif not isdefined('attributes.is_submitted')>
				if (document.getElementById('add_other_shelf').value.length == '') /*Raf Boşsa*/
				{
					alert('Önce Raf Barkodu Okutun.!!!'); 
					document.getElementById('add_other_barcod').value = '';
					document.getElementById('first_area').style.display='none';
					document.getElementById('second_area').style.display='';
					document.getElementById('add_other_shelf').focus();	
				}
				else /*Barkod Doluysa*/
				{
					
					window.location ="<cfoutput>#request.self#</cfoutput>?fuseaction=stock.list_ezgi_fast_count&event=add&is_submitted=1&add_other_shelf="+document.getElementById('add_other_shelf').value;
				}
			<cfelse>
				if (document.getElementById('add_other_barcod').value.length == '') /*Barkod Boşsa*/
				{
					alert('Seri No Boş Olamaz.!!!'); 
					document.getElementById('add_other_barcod').focus();	
				}
				else /*Barkod Doluysa*/
				{
					get_stock(document.getElementById('add_other_barcod').value);
				}
			</cfif>
		}
	}
	
	function get_stock(barcode) /*Ürün Kontrolü*/
    {
		row_count_sevk = document.getElementById('row_count_sevk').value;
		row_count_content = document.getElementById('row_count_content').value;
		buldum=0;
		for(i=1;i<=row_count_sevk;i++)
		{
			satir_serino = document.getElementById('row_control_'+i).value;
			if(barcode==satir_serino)
				buldum=i;
		}
		for(j=1;j<=row_count_content;j++)
		{
			if(document.getElementById('SERIAL_NO'+j).value==barcode)
				buldum = -1;
		}
		if(buldum==0)
		{
			alert('Seri No Bu Rafta Değildir.!!!');
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		else if(buldum==-1)
		{
			alert('Paket daha Önce Okutulmuş. !');
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus(); /*Barkod ve Raf Alanını Temizle ve Barkoda Odaklan*/	
			return false;
		}
		else
		{
			productname = document.getElementById('PRODUCT_NAME_'+buldum).value;
			add_row(barcode,productname);
			document.getElementById('row'+buldum).style.display='none';
			document.getElementById('add_other_barcod').value = '';
			document.getElementById('add_other_barcod').focus();
		}
	}
	function add_row(barcode,productname)
	{
		row_count_content = document.getElementById('row_count_content').value;
		serial_hata = 0;	
		if(serial_hata == 0)
		{
			row_count_content++;
			document.getElementById('row_count_content').value = row_count_content;
			var newRow;
			var newCell;	
			newRow = document.getElementById("table2").insertRow(document.getElementById("table2").rows.length);
			newRow.setAttribute("name","frm_row" + row_count_content);
			newRow.setAttribute("id","frm_row" + row_count_content);		
			newRow.setAttribute("NAME","frm_row" + row_count_content);
			newRow.setAttribute("ID","frm_row" + row_count_content);		
			
				
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input type="hidden" name="row_control_content'+row_count_content+'" id="row_control_content'+row_count_content+'" value="1"><input name="row_number'+row_count_content+'" type="text" value="'+row_count_content+'" style="width:20px">';
			
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="SERIAL_NO'+row_count_content+'" id="SERIAL_NO'+row_count_content+'" type="text" value="'+barcode+'" style="width:75px">';
			
			newCell = newRow.insertCell();
			newCell.innerHTML = '<input name="A_PRODUCT_NAME'+row_count_content+'" id="A_PRODUCT_NAME'+row_count_content+'" type="text" value="'+productname+'" style="width:200px">';
			
			document.getElementById('onay_div').style.display='';
		}
	}
	function kontrol_kayit()
	{
		
		sor = confirm('Raf Doğrulama İşlemini Kaydediyorum.?')
		if(sor==true)
		{
			document.getElementById('onay').disabled = true;
			document.getElementById("add_ezgi_fast_count").action = "<cfoutput>#request.self#?fuseaction=stock.emptypopup_add_ezgi_fast_count&default_process_type=#default_process_type#&process_cat=#get_process_cat.process_cat_id#</cfoutput>";
			document.getElementById("add_ezgi_fast_count").submit();
		}
		else
			return false;
	}

</script>