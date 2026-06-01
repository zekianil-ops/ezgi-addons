<!---
    File: add_ezgi_fast_production_order.cfm
    Folder: Add_Ons\ezgi\e-vts\form
    Author: Ezgi Yazılım
    Date: 01/10/2024
    Description:
--->
<style>
	body{
		background:white!important;
	}
	.box_yazi {font-size:16px;font:bold} 
	.box_yazi_td {font-size:17px!important;font-weight:bold!important;color:green;padding:12px 5px!important;} 
	.box_yazi_td2 {font-size:18px;font:bold}
	.box_yazi_baslik {font-size:15px;font:bold; background-color:LightGray; vertical-align:middle}
	.button_hover:hover{
		background-color:#e3e3e3!important;
		border-color:black!important;
	}
	.button_change{
		font-size:15px; font-weight:bold;height:80px; width:80px;border-radius: 10px;border-color: #00000085;
	}
	.numarator{
		background-color:#e3e3e36b;font-size:22px; font-weight:bold;height:70px; width:70px;border-radius: 10px;margin:2px 0px;
	}
	.numarator_cons{
		background-color:#e3e3e36b;font-size:22px; font-weight:bold;width:217px;height:75px;border-radius: 10px;margin:2px 0px;
	}
	.fire{
		padding:100px;
	}
	.warning_message{
		font-size:56px; font-weight:bold; text-align:center; padding:100px 0px;
	}
	.tablesorter-header-inner{
		font-size:20px!important;
	}
	@media screen and (max-width: 769px) {
		footer {
			display:block;
		}
		/* button{
			width:100px!important;
			height:100px!important;
		} */
		.mobil_info{
			left: 0%!important;
		}
		.numarator_cons{
			width:305px!important;	
		}
	}
	@media screen and (min-width: 1150px) {
		.numarator{
			height:85px!important; 
			width:85px!important;
		}
		.numarator_cons{
			width:265px!important;	
			height:75px!important;	
		}
		
	}
	@media screen and (min-width: 1340px) {
		/* button{
			width:120px!important;
			height:120px!important;
		} */
	}
	@media screen and (max-width: 992px) {
		.fire{
			padding:0px;
		}
	}
	@media screen and (max-width: 578px) {
		footer{
			position:unset!important;
		}
		.numarator_cons {
			width: 220px !important;
		}
		.warning_message{
			font-size:24px;
		}
	}
	</style>
<cfparam name="attributes.operation_type_id" default="">
<cfquery name="get_workstation_name" datasource="#dsn3#">
	SELECT STATION_NAME,STATION_ID,EZGI_PACKAGE_CONTROL FROM WORKSTATIONS WHERE STATION_ID = #attributes.station_id#
</cfquery>

<cfquery name="get_workstation_operations" datasource="#dsn3#">
	SELECT 
    	WP.OPERATION_TYPE_ID, 
        OT.OPERATION_TYPE
	FROM     
    	WORKSTATIONS_PRODUCTS AS WP INNER JOIN
        OPERATION_TYPES AS OT ON WP.OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID
	WHERE  
    	WP.WS_ID = #attributes.station_id# AND 
        NOT (WP.OPERATION_TYPE_ID IS NULL)
</cfquery>

<!---İstasyonda Çalışanların Bilgileri Alınıyor--->
<cfquery name="get_station_employee" datasource="#dsn3#">
	SELECT EMPLOYEE_ID FROM EZGI_STATION_EMPLOYEE WHERE STATION_ID = #attributes.station_id# AND FINISH_DATE IS NULL AND EMPLOYEE_ID <> #attributes.employee_id#
</cfquery>
<cfif not get_workstation_operations.recordcount>
	<script type="text/javascript">
    	alert("Bu İstasyonda Operasyon tanımı Yapılmamış!");
     	window.close()
  	</script>
	<cfabort>
</cfif>
<!---Duraklama Kontrol --->
<cfquery name="get_prod_pause" datasource="#dsn3#">
	SELECT     
    	PROD_PAUSE_TYPE_ID
	FROM         
    	SETUP_PROD_PAUSE
	WHERE     
        STATION_ID = #attributes.station_id# AND 
        EMPLOYEE_ID = #attributes.employee_id# AND 
        PROD_DURATION IS NULL
</cfquery>
<cfif get_prod_pause.recordcount>
	<cfquery name="get_prod_pause_cat" datasource="#dsn3#">
    	SELECT     
        	PROD_PAUSE_CAT_ID
		FROM         
        	SETUP_PROD_PAUSE_TYPE
		WHERE     
        	PROD_PAUSE_TYPE_ID = #get_prod_pause.PROD_PAUSE_TYPE_ID#
    </cfquery>
    <cfif get_prod_pause_cat.recordcount>
    	<cfset pause_cat = get_prod_pause_cat.PROD_PAUSE_CAT_ID>
    <cfelse>
    	<cfset pause_cat = 0>
    </cfif>
<cfelse>
	<cfset pause_cat = 0>
</cfif>
<!---Duraklama Kontrol --->
<cfif isdefined('attributes.p_operation_id')>
    <cfquery name="get_order" datasource="#dsn3#">
        SELECT     	
            PO.P_ORDER_ID, 
            PO.OPERATION_TYPE_ID, 
            ISNULL((	
                    SELECT     	
                        SUM(LOSS_AMOUNT) AS LOSS_AMOUNT
                    FROM       	
                        PRODUCTION_OPERATION_RESULT
                    WHERE     	
                        OPERATION_ID = PO.P_OPERATION_ID
            ),0) LOSS_AMOUNT,
            ISNULL((	
                    SELECT     	
                        SUM(REAL_TIME) AS REAL_TIME
                    FROM       	
                        PRODUCTION_OPERATION_RESULT
                    WHERE     	
                        OPERATION_ID = PO.P_OPERATION_ID
            ),0) REAL_TIME,
            PRO.STOCK_ID,
            PRO.STATION_ID, 
            PRO.START_DATE, 
            PRO.FINISH_DATE, 
            PRO.QUANTITY, 
            PRO.STATUS, 
            PRO.P_ORDER_NO, 
            PRO.PO_RELATED_ID, 
            PRO.SPECT_VAR_ID, 
            PRO.PROD_ORDER_STAGE, 
            PRO.IS_DEMONTAJ, 
            PRO.DEMAND_NO, 
            PRO.LOT_NO, 
            PRO.SPEC_MAIN_ID, 
            PRO.IS_GROUP_LOT, 
            PRO.IS_STAGE, 
            PRO.DETAIL, 
            PRO.SPECT_VAR_NAME, 
            PRO.PROJECT_ID,
            PRO.REFERENCE_NO,
            PRO.RECORD_DATE,
            S.PRODUCT_ID, 
            S.PROPERTY, 
            CASE 
                WHEN 
                    ISNULL(S.IS_PROTOTYPE,0) = 0
                THEN 
                    S.PRODUCT_NAME
                ELSE
                    (
                        SELECT        
                            TOP (1) DESIGN_MAIN_NAME
                        FROM            
                            EZGI_DESIGN_MAIN_ROW
                        WHERE        
                            MAIN_SPECT_RELATED_ID = PRO.SPEC_MAIN_ID
                        ORDER BY 
                            DESIGN_MAIN_ROW_ID DESC
                        UNION ALL
                        SELECT        
                            TOP (1) PACKAGE_NAME
                        FROM        
                            EZGI_DESIGN_PACKAGE_ROW
                        WHERE        
                            PACKAGE_SPECT_RELATED_ID = PRO.SPEC_MAIN_ID
                        ORDER BY 
                            PACKAGE_ROW_ID DESC
                        UNION ALL
                        SELECT        
                            TOP (1) PIECE_NAME
                        FROM            
                            EZGI_DESIGN_PIECE_ROWS
                        WHERE        
                            PIECE_SPECT_RELATED_ID = PRO.SPEC_MAIN_ID
                        ORDER BY 
                            PIECE_ROW_ID DESC
                    )
            END	AS PRODUCT_NAME,
            S.PRODUCT_NAME NAME_PRODUCT, 
            S.STOCK_CODE, 
            S.PRODUCT_CATID,
            ISNULL(S.IS_PROTOTYPE,0) AS IS_PROTOTYPE, 
            ISNULL(S.IS_QUALITY,0) AS IS_QUALITY,
            PU.MAIN_UNIT, 
            O.OPERATION_TYPE, 
            O.OPERATION_TYPE_ID,
            O.OPERATION_CODE,
            PO.P_OPERATION_ID,
         	ISNULL((	
                    SELECT     	
                        SUM(REAL_AMOUNT) AS REAL_AMOUNT
                    FROM       	
                        PRODUCTION_OPERATION_RESULT
                    WHERE     	
                        OPERATION_ID = PO.P_OPERATION_ID
            ),0) REAL_AMOUNT,
            PO.AMOUNT,
            PO.STAGE
        FROM       	
            PRODUCTION_OPERATION AS PO INNER JOIN
            PRODUCTION_ORDERS AS PRO ON PO.P_ORDER_ID = PRO.P_ORDER_ID INNER JOIN
            STOCKS AS S ON PRO.STOCK_ID = S.STOCK_ID INNER JOIN
            OPERATION_TYPES AS O ON PO.OPERATION_TYPE_ID = O.OPERATION_TYPE_ID LEFT OUTER JOIN
            PRODUCT_UNIT AS PU ON S.PRODUCT_ID = PU.PRODUCT_ID
        WHERE     	
            PO.P_OPERATION_ID = #attributes.p_operation_id#  AND 
            PU.IS_MAIN = 1
    </cfquery>
</cfif>

<cf_box>
    <cfform name="add_ezgi_fast_production_order" id="add_ezgi_fast_production_order" method="post" action="#request.self#?fuseaction=production.emptypopup_add_ezgi_fast_production_order">
        <cfinput type="hidden" name="station_id" value="#attributes.station_id#">
        <cfinput type="hidden" name="employee_id" value="#attributes.employee_id#">
        <input type="hidden" name="p_operation_id" id="p_operation_id" value="">
        <input type="hidden" name="p_order_id" id="p_order_id" value="">
        <cf_box_search>
			<div class="form-group" style="margin: 0px 15px 0px 15px!important;">
            	<cfsavecontent variable="baslik"><cf_get_lang dictionary_id='29474.Emir No'></cfsavecontent>
             	<input name="p_order_no" id="p_order_no"  type="text" value="" placeholder="<cfoutput>#baslik#</cfoutput>" style="width:140px; height:50px!important; font-size:17px; font-weight:bold; vertical-align:top">
			</div>
			<!---<div class="form-group">
                <a class="ui-btn ui-btn-green" href="javascript://" onclick="tumu();">
                    <button type="button" name="tumu" style="cursor:pointer; vertical-align:bottom;  background-color:transparent; border:none"><i class="fa fa-search"></i></button>
               	</a>
			</div>--->
		</cf_box_search>
        <cf_box style="box-shadow: none!important;">
			<cf_grid_list>
            	<thead>
                	<tr>
                        <th style="font-size:17px; font-weight:bold; ">Operatör</th>
                        <th style="font-size:17px; font-weight:bold; ">Partner</th>
                        <th style="font-size:17px; font-weight:bold; ">İstasyon</th>
                        <th style="font-size:17px; font-weight:bold; ">Operasyon</th>
                  	</tr>
                </thead>
        		<tbody>
                	<tr>
                        <td style="font-size:17px; font-weight:bold; "><cfoutput>#get_emp_info(employee_id,0,0)#</cfoutput></td>
                        
                        <td style="font-size:17px; font-weight:bold; text-align:center; height:50px">
                            <cfoutput query="get_station_employee">
                                #get_emp_info(get_station_employee.employee_id,0,0)#,&nbsp;
                            </cfoutput>
                        </td>
                        
                        <td style="font-size:17px; font-weight:bold; ">
                            <cfoutput>#get_workstation_name.station_name#</cfoutput>
                        </td>
                        
                        <td style="font-size:18px; font-weight:bold; text-align:center" nowrap>
							<select name="operation_type_id" id="operation_type_id" style="font-size:20px; font-weight:bold; height:50px;">
								<cfoutput query="get_workstation_operations">
                                    <option style=" font-size:17px" value="#OPERATION_TYPE_ID#" <cfif attributes.operation_type_id eq OPERATION_TYPE_ID>selected</cfif>>#OPERATION_TYPE#</option>
                                </cfoutput>
                            </select>
                        </td>
                        
                    </tr>
                </tbody>
          	</cf_grid_list>
        </cf_box>    
        <cf_box style="box-shadow: none!important;">
        	<div style="display:none;">
            	<cf_workcube_process_cat slct_width="140"><cf_workcube_process is_upd='0' process_cat_width='130' is_detail='0'>
            </div>
        	<div id="production_div" style="text-align:center">
            	<cfif isdefined('attributes.p_operation_id')>
                	<cf_grid_list>
                        <thead>
                			<tr>
                                <th style="font-size:17px; font-weight:bold; ">Üretilen Ürün Adı</th>
                                <th style="font-size:17px; font-weight:bold; ">Ü.E. Adedi</th>
                                <th style="font-size:17px; font-weight:bold; ">Üretilen</th>
                                <th style="font-size:17px; font-weight:bold; ">Fire</th>
                                <th style="font-size:17px; font-weight:bold; ">Kalan</th>
                          	</tr>
                        </thead>
                        <tbody>
                        	<cfoutput>
                            <tr>
                                <td style="font-size:17px; font-weight:bold; text-align:center ">#get_order.product_name#</td>
                                <td style="font-size:17px; font-weight:bold; text-align:center ">#get_order.AMOUNT#</td>
                                <td style="font-size:17px; font-weight:bold; text-align:center ">#get_order.REAL_AMOUNT#</td>
                                <td style="font-size:17px; font-weight:bold; text-align:center ">#get_order.LOSS_AMOUNT#</td>
                                <td style="font-size:17px; font-weight:bold; text-align:center ">#get_order.amount-get_order.REAL_AMOUNT-get_order.LOSS_AMOUNT#</td>
                            </tr>
                            </cfoutput>
                        </tbody>
                    </cf_grid_list>
                
                <cfelse>
                	<span style="font-size:40px; font-weight:bold; color:green; text-align:center">
                	İş Emri Okutarak İşleme Başlayın
                   </span> 
                </cfif>
            </div>
            <cfif isdefined('attributes.p_operation_id')>
            <footer style="box-shadow:none!important;background-color:white!important;">
				<div class="container">
					<div class="top">
						<div class="col col-12" style="display:flex;flex-wrap: wrap; text-align: center;margin:20px 0px;">
                        	<!---<div class="col" style="margin:10px 0px;">
								<a href="javascript://" onclick="operation_add(7);">
									<button type="button" name="fire_buton" class="button_hover button_change" style="background-color:#e3e3e36b;" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='29471.Fire'></button>&nbsp;
								</a>
							</div>--->
                            <div class="col" style="margin:10px 0px;">
								<a href="javascript://" onclick="operation_add(6);">
									<button type="button" name="recete" class="button_hover button_change" style="background-color:#e3e3e36b;" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='308.Reçete'></button>&nbsp;
								</a>
							</div>
							<div class="col" style="margin:10px 0px;">
								<a href="javascript://" onclick="operation_add(5);">
									<button type="button" name="tresim" class="button_hover button_change" style="background-color:##e3e3e36b;" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='32796.Görünüm'></button>&nbsp;
								</a>
							</div>
							<div class="col" style="margin:10px 0px;">
								<a href="javascript://" onclick="operation_add(4);">
									<button type="button" name="etiket" class="button_hover button_change" style="background-color:#e3e3e36b;" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='51247.Etiket Bas'></button>&nbsp;
								</a>
							</div>
							<div class="col" style="margin:10px 0px;">
								<a href="javascript://" onclick="operation_add(2);">
									<button type="button" name="uretim_takip" class="button_hover button_change" style="background-color:#e3e3e36b;" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='38033.Üretim Takibi'></button>&nbsp;
								</a>
							</div>
                            <div class="col" style="margin:10px 0px;">
								<a href="javascript://" onclick="operation_add(1);">
									<button type="button" name="rapor" class="button_hover button_change" style="background-color:#e3e3e36b;" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='40659.Günlük Çalışma'></button>&nbsp;
								</a>
							</div>
							<div class="col" style="margin:10px 0px;"> 
								<a href="javascript://" onclick="operation_add(3);"> 
									<button type="button" name="cik" class="button_hover button_change" style="background-color:Gold;" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='1136.Kullanıcı Değiştir'></button>&nbsp;
								</a>
							</div>
                            <cfif pause_cat eq 0>
                                <div class="col" style="margin:10px 0px;"> 
                                    <a href=<cfoutput>"#request.self#?fuseaction=production.upd_ezgi_station_employee&station_id=#attributes.station_id#&employee_id=#attributes.employee_id#&upd_employee=1"</cfoutput>>
                                        <button type="button" name="cik" class="button_hover button_change" style="background-color:red;" title="<cf_get_lang dictionary_id='304.Başlamak İçin Basınız'>"><cf_get_lang dictionary_id='57431.Çıkış'></button>&nbsp;
                                    </a>
                                </div>
                            </cfif>
            			</div>
            		</div>
              	</div>
            </footer>
            </cfif>
        </cf_box>
 	</cfform>
</cf_box>
<script language="javascript">
	document.getElementById('p_order_no').focus();
	setTimeout("document.getElementById('p_order_no').select();",1000);
	document.onkeydown = checkKeycode
	function checkKeycode(e) /*Barkod Okuyup Enter Basıldığında*/
	{
		var keycode;
		if (window.event) keycode = window.event.keyCode;
		else if (e) keycode = e.which;
		if (keycode == 13)
		{
			if (document.getElementById('p_order_no').value.length == '') /*Barkod Boşsa*/
			{
				alert('<cf_get_lang dictionary_id='340.Önce Ürün Barkodu Okutunuz'>'); 
				document.getElementById('p_order_no').value = '';
				document.getElementById('p_order_no').focus();
			}
			else /*Barkod Doluysa*/
			{
				
				/*var get_p_operation_id = 
				wrk_query("SELECT PRO.P_ORDER_ID, PRO.IS_STAGE, PO.P_OPERATION_ID,ISNULL((SELECT SUM(REAL_AMOUNT) AS REAL_AMOUNT FROM PRODUCTION_OPERATION_RESULT WHERE OPERATION_ID = PO.P_OPERATION_ID),0) AS REAL_AMOUNT, PO.P_ORDER_ID, ISNULL(PO.AMOUNT,0) AS AMOUNT, PO.STAGE FROM PRODUCTION_OPERATION AS PO INNER JOIN PRODUCTION_ORDERS AS PRO ON PO.P_ORDER_ID = PRO.P_ORDER_ID INNER JOIN OPERATION_TYPES AS O ON PO.OPERATION_TYPE_ID = O.OPERATION_TYPE_ID INNER JOIN WORKSTATIONS_PRODUCTS AS WP ON O.OPERATION_TYPE_ID = WP.OPERATION_TYPE_ID WHERE PO.STAGE <> 2 AND PRO.IS_STAGE <> 3 AND PRO.STATUS = 1 AND WP.WS_ID = <cfoutput>#attributes.station_id#</cfoutput> AND PRO.P_ORDER_NO = '"+document.getElementById('p_order_no').value+"' AND PO.OPERATION_TYPE_ID ="+document.getElementById('operation_type_id').value,"dsn3");*/
				
				var listParam = <cfoutput>#attributes.station_id#</cfoutput> + "*" + document.getElementById('p_order_no').value + "*" + document.getElementById('operation_type_id').value;
				var get_p_operation_id = wrk_safe_query('get_p_operation_info_stationid_porderno_operationtypeid_ezgi','dsn3',0,listParam);
				
				if(get_p_operation_id.recordcount != 0)
				{
					if((get_p_operation_id.REAL_AMOUNT*1) >= (get_p_operation_id.AMOUNT*1) || get_p_operation_id.STAGE == 2)
					{
						alert('Dikkat Üretim Planına Ait Miktar Tamamlanmıştır.');
						return false;
					}
					else
					{
						document.getElementById('p_operation_id').value = get_p_operation_id.P_OPERATION_ID;
						document.getElementById('p_order_id').value = get_p_operation_id.P_ORDER_ID;
					}
				}
				else
				{
					alert('Üretim Emir No ile Kayıt Bulunamamıştır.!');
					document.getElementById('p_order_no').value = '';
					return false;
				}
			}
		}
	}
	<cfif isdefined('attributes.p_operation_id')>
	function operation_add(type)
	{
		<cfoutput>
			var station_id = #attributes.station_id#;
			var employee_id = #attributes.employee_id#;
			var p_order_id = #get_order.P_ORDER_ID#;
			var p_operation_id = #attributes.p_operation_id#;
		</cfoutput>
		if (type== 1)
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_dsp_ezgi_prod_pause&employee_id='+employee_id,'wwide');
		else if (type== 2)		
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_dsp_ezgi_operasyon_list&p_order_id='+p_order_id,'wwide');
		else if (type== 3)
			window.location.href='<cfoutput>#request.self#?fuseaction=production.employee_ezgi_identification_1</cfoutput>';	
		else if (type== 4)
			windowopen('<cfoutput>#request.self#?fuseaction=objects.popup_ezgi_print_files&print_type=280</cfoutput>&action_id='+p_order_id,'wide');
		else if (type== 5)
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_dsp_ezgi_prod_teknik_resim&p_order_id='+p_order_id+'&p_operation_id='+p_operation_id,'wwide');
		else if (type== 6)		
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_dsp_ezgi_material_list&p_order_id='+p_order_id+'&p_operation_id='+p_operation_id+'&employee_id='+employee_id+'&station_id='+station_id,'wwide');
		else if (type== 7)		
			windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=production.popup_dsp_ezgi_material_list&p_order_id='+p_order_id+'&p_operation_id='+p_operation_id+'&employee_id='+employee_id+'&station_id='+station_id,'wwide');
	}
	</cfif>
</script>