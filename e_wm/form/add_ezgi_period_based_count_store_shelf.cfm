<!---
    File: add_ezgi_period_based_count_store_shelf.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/03/2025
    Description: Raf ve Depo Sayım İşlemi
---> 
<cf_xml_page_edit>
<cfif isdefined('x_depo') and len(x_depo)>
	<cfset default_depo = x_depo>
<cfelse>
	<cfset default_depo = ''>
</cfif>
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

<cfquery name="get_count" datasource="#dsn3#">
	SELECT 
    	EZGI_WM_COUNT_ID,
  		PROCESS_DATE, 
     	PROCESS_NUMBER,
        RECORD_EMP,
    	RECORD_DATE,
        STATUS
	FROM     
     	EZGI_WM_COUNT WITH (NOLOCK)
  	WHERE
    	STATUS = 1
</cfquery>
<cfif not get_count.recordcount>
	<script type="text/javascript">
		alert("Dönem Bazlı Sayım Fişi Aktif Olarak Yoktur. Lütfen Sistem Yöneticinize Başvurunuz");
	</script>
    <cfabort>
</cfif>

<cfif get_count.recordcount gt 1>
	<script type="text/javascript">
		alert("Birden Fazla Dönem Bazlı Sayım Fişi Aktif Olarak Mevcut. Lütfen Sistem Yöneticinize Başvurunuz");
	</script>
    <cfabort>
</cfif>
<cfset attributes.count_id = get_count.EZGI_WM_COUNT_ID>
<cfquery name="get_count_serial_row" datasource="#DSN3#">
	SELECT 
    	COUNT(*) AS SAYI,
        ISNULL(E.SHELF_CODE,0) SHELF_CODE, 
        ISNULL(E.IS_CONTROL,0) AS IS_CONTROL, 
        D.DEPO_NAME, 
        D.DEPO,
        P.SHELF_TYPE
	FROM     
    	EZGI_WM_COUNT_SERIAL_ROW AS E WITH (NOLOCK) INNER JOIN
        EZGI_WM_DEPARTMENTS AS D WITH (NOLOCK) ON E.DEPARTMENT_ID = D.DEPARTMENT_ID AND E.LOCATION_ID = D.LOCATION_ID LEFT OUTER JOIN
     	EZGI_PRODUCT_PLACE AS P WITH (NOLOCK) ON E.PRODUCT_PLACE_ID = P.PRODUCT_PLACE_ID
	WHERE  
    	E.WM_COUNT_ID = #attributes.count_id#
	GROUP BY 
        D.DEPO_NAME, 
        D.DEPO, 
        P.SHELF_TYPE, 
        E.IS_CONTROL, 
        E.SHELF_CODE
</cfquery>
<cfquery name="get_count_packing_row" datasource="#dsn3#">
	SELECT 
    	COUNT(*) AS SAYI,
    	ISNULL(P.SHELF_CODE, 0) AS SHELF_CODE, 
        ISNULL(E.IS_CONTROL, 0) AS IS_CONTROL, 
        D.DEPO_NAME, 
        D.DEPO, 
        P.SHELF_TYPE
	FROM     
    	EZGI_WM_COUNT_PACKING_ROW AS E WITH (NOLOCK) INNER JOIN
        EZGI_WM_DEPARTMENTS AS D WITH (NOLOCK) ON E.STORE = D.DEPARTMENT_ID AND E.STORE_LOCATION = D.LOCATION_ID LEFT OUTER JOIN
        EZGI_PRODUCT_PLACE AS P WITH (NOLOCK) ON E.SHELF_NUMBER = P.PRODUCT_PLACE_ID
	WHERE  
    	E.WM_COUNT_ID = #attributes.count_id#
	GROUP BY 
        ISNULL(P.SHELF_CODE, 0), 
        ISNULL(E.IS_CONTROL, 0), 
        D.DEPO_NAME, 
        D.DEPO, 
        P.SHELF_TYPE
</cfquery>
<cfif not (get_count_serial_row.recordcount or get_count_packing_row.recordcount)>
	<script type="text/javascript">
     	alert("Sayım Kaydı içinde Palet veya Paket Kaydı Bulunamadı!");
    	window.history.go(-1);
  	</script>
	<cfabort>
<cfelse>
	<cfquery name="GET_ALL_LOCATION" dbtype="query">
    	SELECT
        	SHELF_CODE,
        	DEPO_NAME, 
        	DEPO
    	FROM
        	get_count_serial_row
   		UNION ALL
        SELECT
        	SHELF_CODE,
        	DEPO_NAME, 
        	DEPO
    	FROM
        	get_count_packing_row         
    </cfquery>
    <cfquery name="GET_LOCATION" dbtype="query">
    	SELECT
        	DEPO_NAME, 
        	DEPO
    	FROM
        	GET_ALL_LOCATION
       	GROUP BY
        	DEPO_NAME, 
        	DEPO
    </cfquery>
    <cfquery name="GET_NOT_SHELF_LOCATION" dbtype="query">
    	SELECT
        	DEPO
    	FROM
        	GET_ALL_LOCATION
      	WHERE
        	SHELF_CODE=0	
       	GROUP BY
        	DEPO
    </cfquery>
	<cfif GET_NOT_SHELF_LOCATION.recordcount>
    	<cfset not_shelf_location_list = ValueList(GET_NOT_SHELF_LOCATION.DEPO)>
    <cfelse>
    	<cfset not_shelf_location_list = ''>
    </cfif>
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
        <cfform name="add_ezgi_period_based_count_store_shelf" >
        	<cfinput type="hidden" id="control_type" name="control_type" value="0">
            <cf_basket_form id="add_ezgi_period_based_count_store_shelf">
                <div class="row">
                 	<div class="col col-12 uniqueRow">
                      	<div class="row formContent">
                         	<cf_box_elements>
                            	<div class="col col-12 uniqueRow" id="first_area">
                                    <div class="col col-12">
                                    	<div class="col col-4">
                                            <label><cf_get_lang dictionary_id='58763.Miktar'></label>
                                        </div>
                                        <div class="col col-8">
                                            <div class="form-group" id="item-depo_id">
                                                <select name="depo_id" id="depo_id" onChange="control_depo(this.value)">
                                                	<option value=""><cf_get_lang dictionary_id="57734.Seçiniz"></option>
                                                    <cfoutput query="GET_LOCATION">
                                                    	<option value="#DEPO#" <cfif len(default_depo) and default_depo eq DEPO>selected</cfif>>#DEPO_NAME#</option>
                                                    </cfoutput>
                                                </select> 
                                            </div>
                                        </div>
                                    </div>
                               	</div>
                                <div class="col col-12 uniqueRow" id="second_area" style="display:none">
                                    <div class="col col-12">
                                    	<div class="col col-4">
                                            <label><cf_get_lang dictionary_id='1361.Raf Barkodu'></label>
                                        </div>
                                        <div class="col col-8">
                                            <div class="form-group" id="item-raf">
                                                <input id="shelf_barcod" name="shelf_barcod" type="text" value="">
                                            </div>
                                        </div>
                                    </div>
                               	</div>
                                <div class="col col-12 uniqueRow" id="third_area" style="display:none">
                                    <div class="col col-12">
                                    	<div class="col col-4">
                                            <label><cf_get_lang dictionary_id='37244.Palet'>/<cf_get_lang dictionary_id='1317.Paket barkodu'></label>
                                        </div>
                                        <div class="col col-8">
                                            <div class="form-group" id="item-barcod">
                                                <input id="add_other_barcod" name="add_other_barcod" type="text" value="">
                                            </div>
                                        </div>
                                    </div>
                               	</div>
                               
               				</cf_box_elements>
                       	</div>
                  	</div>
              	</div>
    		</cf_basket_form>
            <cfsavecontent variable="title"><cf_get_lang dictionary_id="1359.WM- Depo-Raf İçeriği Sayım İşlemi"></cfsavecontent>
        	<cf_box title="#title#">
				<div class="col col-12"  id="display_info">
                
                </div>
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
			if(document.getElementById('control_type').value==1)/* Raf Okutma İse*/
			{
				if (document.getElementById('shelf_barcod').value.length == 0)
				{
					alert('Önce Raf Barkodu Okutunuz');
					document.getElementById('shelf_barcod').value = '';
					document.getElementById('shelf_barcod').focus();	
				}
				else
				{
					depo=document.getElementById('depo_id').value;
					if (document.getElementById('add_other_barcod').value.length > 0)
					{
						var bb = '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_period_based_count_store_shelf&count_id=#attributes.count_id#&type=1</cfoutput>&depo='+depo+'&hucre='+document.getElementById('shelf_barcod').value+'&barcode='+document.getElementById('add_other_barcod').value;
						AjaxPageLoad(bb,'display_info',1);
						document.getElementById('add_other_barcod').value='';
						document.getElementById('add_other_barcod').focus();
					}
					else 
					{
						var bb = '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_period_based_count_store_shelf&count_id=#attributes.count_id#&type=0</cfoutput>&depo='+depo+'&hucre='+document.getElementById('shelf_barcod').value;
						AjaxPageLoad(bb,'display_info',1);
						document.getElementById('add_other_barcod').value='';
						document.getElementById('third_area').style.display='';
						document.getElementById('add_other_barcod').focus();
					}
				}
			}
			else /* Depo Okutma İse*/
			{
				depo=document.getElementById('depo_id').value;
				if (document.getElementById('add_other_barcod').value.length > 0)
				{
					var bb = '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_period_based_count_store_shelf&count_id=#attributes.count_id#&type=1</cfoutput>&depo='+depo+'&barcode='+document.getElementById('add_other_barcod').value;
					AjaxPageLoad(bb,'display_info',1);
					document.getElementById('add_other_barcod').value='';
					document.getElementById('add_other_barcod').focus();
				}
			}
		}
	}
	function control_depo(depo)
	{
		not_shelf_location_list=<cfoutput>'#not_shelf_location_list#'</cfoutput>;
		if(list_find(not_shelf_location_list,depo))
		{
			document.getElementById('control_type').value=0;
			document.getElementById('second_area').style.display='none';
			document.getElementById('shelf_barcod').value='';
			document.getElementById('add_other_barcod').value='';
			document.getElementById('third_area').style.display='';
			document.getElementById('add_other_barcod').focus();
		}
		else
		{
			document.getElementById('control_type').value=1;
			document.getElementById('shelf_barcod').value='';
			document.getElementById('add_other_barcod').value='';
			document.getElementById('third_area').style.display='none';
			document.getElementById('second_area').style.display='';
			document.getElementById('shelf_barcod').focus();
		}
		var bb = '<cfoutput>#request.self#?fuseaction=stock.emptypopup_ajax_ezgi_period_based_count_store_shelf&count_id=#attributes.count_id#&type=0</cfoutput>&depo='+depo;
		AjaxPageLoad(bb,'display_info',1);
		
	}
</script>
<cfif len(default_depo)>
	<script language="javascript" type="text/javascript">
		<cfoutput>control_depo('#default_depo#');</cfoutput>
	</script>		
</cfif>