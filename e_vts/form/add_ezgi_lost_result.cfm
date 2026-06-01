<!---
    File: add_ezgi_lost_result.cfm
    Folder: Add_Ons\ezgi\e-vts\form
    Author: Ezgi Yazılım
    Date: 01/04/2023
    Description:
--->

<style>
	.box_yazi {font-size:16px;font:bold} 
	.box_yazi_td {font-size:15px;font:bold;color:blue} 
	.box_yazi_td2 {font-size:13px;font:bold}
	.fade 
		{
			   opacity: 1;
			   transition: opacity .25s ease-in-out;
			   -moz-transition: opacity .25s ease-in-out;
			   -webkit-transition: opacity .25s ease-in-out;
		}
   .fade:hover {opacity: 0.5;}
</style>
<cfquery name="get_reason" datasource="#dsn3#">
	SELECT 
    	LOST_REASON_ID, 
        LOST_REASON_NAME, 
        LOST_REASON_TYPE
	FROM     
    	EZGI_VTS_LOST_REASON
	WHERE  
    	LOST_REASON_STATUS = 1 AND
	LOST_REASON_TYPE =1
	ORDER BY 
    	LOST_REASON_NAME 
</cfquery>
<cfquery name="GET_LOST_ROW" datasource="#dsn3#">
	SELECT 
    	POS.AMOUNT/PO.QUANTITY AS AMOUNT, 
        POS.POR_STOCK_ID,
    	POS.PRODUCT_ID, 
        POS.STOCK_ID, 
        POS.SPECT_MAIN_ID, 
        POS.PRODUCT_UNIT_ID, 
        PU.MAIN_UNIT,
        S.PRODUCT_NAME, 
        S.PRODUCT_CODE, 
        S.IS_PRODUCTION
	FROM     
    	PRODUCTION_ORDERS_STOCKS AS POS INNER JOIN
        STOCKS AS S ON POS.STOCK_ID = S.STOCK_ID  INNER JOIN
      	PRODUCT_UNIT AS PU ON POS.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID  INNER JOIN
      	PRODUCTION_ORDERS AS PO ON POS.P_ORDER_ID = PO.P_ORDER_ID
	WHERE  
    	POS.P_ORDER_ID = #attributes.upd_id# AND 
        ISNULL(S.IS_LIMITED_STOCK, 0) = 0 AND
        POS.TYPE = 2
</cfquery>
<cfform name="lost_form" id="lost_form" method="post" action="">
	<cfinput type="hidden" name="upd_id" id="upd_id" value="#attributes.upd_id#">
    <cfinput type="hidden" name="operation_id_" id="operation_id_" value="#attributes.operation_id_#">
    <cfinput type="hidden" name="station_id_" id="station_id_" value="#attributes.station_id_#">
    <cfinput type="hidden" name="employee_id_" id="employee_id_" value="#attributes.employee_id_#">
    <cfinput type="hidden" name="realized_amount_" id="realized_amount_" value="#attributes.realized_amount_#">
    <cfinput type="hidden" name="loss_amount_" id="loss_amount_" value="#attributes.loss_amount_#">
    <cfinput type="hidden" name="operation_gurup_id" id="operation_gurup_id" value="#attributes.operation_gurup_id#">
    <cfinput type="hidden" name="trace_no" id="trace_no" value="#attributes.trace_no#">
    <cfinput type="hidden" id="stock_id_list" name="stock_id_list" value="#ValueList(GET_LOST_ROW.STOCK_ID)#">
	<cf_box>
   		<cfsavecontent variable="title_">Fire İşlemi</cfsavecontent>
   		<cf_box title="#title_#">
   		    <cf_ajax_list>
   		        <thead>
   		            <tr>
   		                <th style="width:5%; text-align:right" ><cf_get_lang dictionary_id="58577.Sıra"></th>
   		                <th style="width:15%; text-align:Left"><cf_get_lang dictionary_id="58800.Ürün Kodu"></th>
   		                <th style="width:45%; text-align:left"><cf_get_lang dictionary_id="58221.Ürün Adı"></th>
   		                <th style="width:10%; text-align:right"><cf_get_lang dictionary_id="40196.Sarf"></th>
   		                <th style="width:5%; text-align:left"><cf_get_lang dictionary_id="57636.Birim"></th>
   		                <th style="width:15%; text-align:right"><cf_get_lang dictionary_id="29471.Fire"></th>
   		                <th style="width:5%; text-align:center"></th>
   		            </tr>
   		        </thead>
   		        <tbody>
   		            <cfoutput query="GET_LOST_ROW">
   		                <tr>
   		   					<td style=" height:40px; text-align:right">#currentrow#&nbsp;</td>
   		                    <td style="text-align:center">#PRODUCT_CODE#</td>
   		                    <td style="text-align:left">&nbsp;#PRODUCT_NAME#</td>
   		                    <td style="text-align:right">#tlFormat(AMOUNT*attributes.loss_amount_,8)#&nbsp;</td>
   		                    <td style="text-align:left">&nbsp;#MAIN_UNIT#</td>
   		                    <td style="text-align:right">
   		                    	<input type="text" value="#tlFormat(AMOUNT*attributes.loss_amount_,8)#" id="amount_#POR_STOCK_ID#" name="amount_#POR_STOCK_ID#" style="text-align:right; width:100px">
   		                    </td>
   		                    <td style="text-align:center" class="box_yazi_td2">
   		                    	<input type="checkbox" name="check_#POR_STOCK_ID#" id="check_#POR_STOCK_ID#" value="1">
   		                    </td>
   		                </tr>
               		</cfoutput>
   		        </tbody>
   		    </cf_ajax_list>
   		</cf_box>
        <cf_popup_box_footer>
            <table style="width:100%">
                <tr>
                    <td style="width:10%; text-align:left" class="box_yazi">
                        <cf_get_lang dictionary_id='320.Fire Sebebi'>
                    </td>
                    <td style="width:35%; text-align:left">
                        
                        <select id="reason_id" name="reason_id#" style="height:38px; width:90%" class="box_yazi">
                            <cfoutput query="get_reason">
                                <option value="#LOST_REASON_ID#">#LOST_REASON_NAME#</option>
                            </cfoutput>
                        </select> 
                    </td>
                    <td style="width:20%; text-align:left" class="box_yazi">
                    	<input type="checkbox" name="product_demand" id="product_demand" value="1">&nbsp;Üretim Talebi Oluştur
                    </td>
                    <td style="width:35%; text-align:right">
                        <input type="button" onclick="kontrol(2)" name="vazgec" value="<cf_get_lang dictionary_id='57462.Vazgeç'>" style="width:120px; height:50px; background-color:red">&nbsp;&nbsp;
                        <input type="button" onclick="kontrol(1)" name="kaydet" value="<cf_get_lang dictionary_id='57461.Kaydet'>" style="width:120px; height:50px">
                    </td>
                    <tr>
                    	<td style="display:none" colspan="4"><cf_workcube_process is_upd='0' process_cat_width='125' is_detail='0'></td>
                    <tr>
                </tr>
            </table>
        </cf_popup_box_footer>
    </cf_box>
</cfform>
<script type="text/javascript">
	function kontrol(type)
	{
		if(type==2)
		{
			window.close();
			wrk_opener_reload();
		}
		if(type==1)
		{
			if(list_len(document.getElementById('stock_id_list').value))
			{
				sor = confirm("<cf_get_lang dictionary_id='57535.Kaydetmek İstediğinizden Emin Misiniz?'>");
				if(sor==true)
				{
					if(document.getElementById('product_demand').checked==true)
						product_demand = 1;
					else
						product_demand = 0;
					var convert_list = '';
					<cfoutput query="GET_LOST_ROW">
						ch_id = #GET_LOST_ROW.por_stock_id#;
						if(document.getElementById('check_'+ch_id).checked==true)
						{
							amount =  filterNum(document.getElementById('amount_'+ch_id).value,8);
							if(amount >0)
							{
								convert_list +=ch_id+'_'+amount+',';
							}
							else
							{
								alert('#currentrow#. Satırın Miktarı 0 dan büyük Olmalıdır.');	
								return false;
							}
						}
					</cfoutput>
					if(list_len(convert_list))
					{
						if(process_cat_control())
						{
						process_stage = document.all.process_stage.value;
						convert_list = convert_list.substr(0,convert_list.length-1);
						window.location='<cfoutput>#request.self#?fuseaction=production.addoperationresult_ezgi&operasyon=1&trace_no=#attributes.trace_no#</cfoutput>&upd_id='+document.getElementById('upd_id').value+'&operation_id_='+document.getElementById('operation_id_').value+'&station_id_='+document.getElementById('station_id_').value+'&realized_amount_='+document.getElementById('realized_amount_').value+'&employee_id_='+document.getElementById('employee_id_').value+'&operation_gurup_id='+document.getElementById('operation_gurup_id').value+'&convert_list_='+convert_list+'&process_stage='+process_stage+'&product_demand='+product_demand+'&loss_amount_='+document.getElementById('loss_amount_').value+'&reason_id='+document.getElementById('reason_id').value;
							return true;
						}
						else
							return false;
					}
				}
				else
					return false;
			}
		}
	}
</script>
