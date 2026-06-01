<!---
    File: dsp_ezgi_prod_pause.cfm
    Folder: Add_Ons\ezgi\e-vts\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cfset t_d_time = 0>
<cfset t_c_time = 0>
<cfparam name="attributes.is_submitted" default="1">
<cfif isdefined("attributes.finish_date") and isdate(attributes.finish_date)>
  <cf_date tarih="attributes.finish_date">
  <cfelse>
  <cfset attributes.finish_date = wrk_get_today()>
</cfif>
<cfif isdefined("attributes.start_date") and isdate(attributes.start_date)>
  <cf_date tarih="attributes.start_date">
  <cfelse>
  <cfset attributes.start_date = wrk_get_today()>
</cfif>
<cfif isdefined("attributes.is_submitted")>
    <cfquery name="get_daily_works" datasource="#dsn3#">
        SELECT     
            POR.OPERATION_RESULT_ID, 
            POR.REAL_AMOUNT, 
            POR.REAL_TIME, 
            POR.ACTION_START_DATE, 
            S.PRODUCT_NAME, 
            W.STATION_NAME, 
            OT.OPERATION_TYPE,
            PO.LOT_NO, 
            PO.P_ORDER_NO
        FROM         
            PRODUCTION_OPERATION_RESULT AS POR INNER JOIN
            PRODUCTION_ORDERS AS PO ON POR.P_ORDER_ID = PO.P_ORDER_ID INNER JOIN
            STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID INNER JOIN
            WORKSTATIONS AS W ON POR.STATION_ID = W.STATION_ID INNER JOIN
            PRODUCTION_OPERATION AS PRO ON POR.OPERATION_ID = PRO.P_OPERATION_ID INNER JOIN
            OPERATION_TYPES AS OT ON PRO.OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID
        WHERE     
            POR.ACTION_EMPLOYEE_ID = #attributes.employee_id# AND 
            POR.REAL_AMOUNT <> 0 AND 
            POR.REAL_TIME IS NOT NULL AND 
            POR.ACTION_START_DATE > #attributes.start_date# AND 
            POR.ACTION_START_DATE < #DateAdd('d',1,attributes.finish_date)#
    </cfquery>
    <cfquery name="get_daily_duration" datasource="#dsn3#">
        SELECT     
            PRP.PROD_DURATION, 
            PRPT.PROD_PAUSE_TYPE, 
            OT.OPERATION_TYPE, 
            S.PRODUCT_NAME, 
            W.STATION_NAME, 
            PRO.P_ORDER_NO, 
            PRO.LOT_NO, 
            PRP.ACTION_DATE
        FROM         
            PRODUCTION_ORDERS AS PRO INNER JOIN
            STOCKS AS S ON PRO.STOCK_ID = S.STOCK_ID RIGHT OUTER JOIN
            SETUP_PROD_PAUSE AS PRP INNER JOIN
            SETUP_PROD_PAUSE_TYPE AS PRPT ON PRP.PROD_PAUSE_TYPE_ID = PRPT.PROD_PAUSE_TYPE_ID ON 
            PRO.P_ORDER_ID = PRP.P_ORDER_ID LEFT OUTER JOIN
            PRODUCTION_OPERATION AS PO INNER JOIN
            OPERATION_TYPES AS OT ON PO.OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID ON PRP.OPERATION_ID = PO.P_OPERATION_ID LEFT OUTER JOIN
            WORKSTATIONS AS W ON PRP.STATION_ID = W.STATION_ID
        WHERE     
            PRP.EMPLOYEE_ID = #attributes.employee_id# AND 
            PRP.ACTION_DATE > #attributes.start_date# AND 
            PRP.ACTION_DATE < #DateAdd('d',1,attributes.finish_date)#
    </cfquery>
<cfelse>
	<cfset get_daily_works.recordcount = 0>
    <cfset get_daily_duration.recordcount = 0>
</cfif>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
		<cfform name="daily_control" id="daily_control" method="post" action="#request.self#?fuseaction=production.popup_dsp_ezgi_prod_pause&employee_id=#attributes.employee_id#">
    	<input name="is_submitted" id="is_submitted" value="1" type="hidden">
            <cf_box_search>
            	<div class="form-group" id="piece_type_">
                	<div class="col col-12">
                        <div class="col col-6">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                                <cfinput type="text" maxlength="10" name="start_date" value="#dateformat(attributes.start_date,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="start_date"></span>
                            </div>
                        </div>
                        <div class="col col-6">
                            <div class="input-group">
                                <cfsavecontent variable="message"><cf_get_lang dictionary_id='58503.Lütfen Tarih Giriniz'></cfsavecontent>
                                <cfinput type="text" maxlength="10" name="finish_date" value="#dateformat(attributes.finish_date,dateformat_style)#" validate="eurodate" message="#message#" style="width:70px;">
                                <span class="input-group-addon"><cf_wrk_date_image date_field="finish_date"></span>
                            </div>
                        </div>
                   	</div>
             	</div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>
                <div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
          	</cf_box_search>
        </cfform>
    </cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='309.İş Raporu'></cfsavecontent>
    <cf_box title="#title#">
     	<cf_grid_list>
        			<thead>
                        <tr height="20px">
                            <th style="width:45;text-align:center;"><cf_get_lang dictionary_id='58577.Sıra'></th>
                         	<th style="width:100;text-align:left;"><cf_get_lang dictionary_id='58834.İstasyon'></th>
                       		<th style="width:80;text-align:center;"><cf_get_lang dictionary_id='29474.Emir No'></th>
                          	<th style="width:80;text-align:center;"><cf_get_lang dictionary_id='45498.Lot No'></th>
                          	<th style="text-align:left;"><cf_get_lang dictionary_id='57657.Ürün'></th>
                          	<th style="text-align:left;"><cf_get_lang dictionary_id='29419.Operasyon'></th>
                          	<th style="width:40;text-align:right;"><cf_get_lang dictionary_id='57635.Miktar'></th>
                          	<th style="width:90;text-align:center;"><cf_get_lang dictionary_id='57502.Bitiş'></th>
                          	<th style="width:80;text-align:right;"><cf_get_lang dictionary_id='310.Çalışma'></th>
                        </tr>
                    </thead>
                    <tbody>
                    	<cfif get_daily_works.recordcount>
							<cfoutput query="get_daily_works">
                   				<tr>
                                	<td style="background-color:FFFFCC;text-align:center;">#currentrow#&nbsp;</td>
                                  	<td style="background-color:FFFFCC;text-align:left;">&nbsp;#STATION_NAME#</td>
                                 	<td style="background-color:FFFFCC;text-align:center;">#P_ORDER_NO#</td>
                                 	<td style="background-color:FFFFCC;text-align:center;">#LOT_NO#</td>
                                 	<td style="background-color:FFFFCC;text-align:left;">&nbsp;#PRODUCT_NAME#</td>
                                  	<td style="background-color:FFFFCC;text-align:left;">&nbsp;#OPERATION_TYPE#</td>
                                  	<td style="background-color:FFFFCC;text-align:right;">#REAL_AMOUNT#</td>
                                	<td style="background-color:FFFFCC;text-align:center;">#TimeFormat(DateAdd('H',session.ep.time_zone,ACTION_START_DATE), 'HH:MM')#</td>
                                 	<td style="background-color:FFFFCC;text-align:right;">#REAL_TIME# Sn.&nbsp;</td>
                    			</tr>
                             	<cfset t_c_time = t_c_time + REAL_TIME>
                          	</cfoutput>
                      	</cfif>
                    </tbody>
      	</cf_grid_list>
  	</cf_box>
    <cfsavecontent variable="title"><cf_get_lang dictionary_id='40721.Duraklama Raporu'></cfsavecontent>
    <cf_box title="#title#" >
     	<cf_grid_list>
        			<thead>
                        <tr height="20px">
                            <th style="width:45;text-align:center;"><cf_get_lang dictionary_id='58577.Sıra'></th>
							<th style="width:100;text-align:left;"><cf_get_lang dictionary_id='58834.İstasyon'></th>
							<th style="width:80;text-align:center;"><cf_get_lang dictionary_id='29474.Emir No'></th>
							<th style="width:80;text-align:center;"><cf_get_lang dictionary_id='45498.Lot No'></th>
							<th style="text-align:left;"><cf_get_lang dictionary_id='57657.Ürün'></th>
							<th style="text-align:left;"><cf_get_lang dictionary_id='29419.Operasyon'></th>
                          	<th style="width:150;text-align:left;"><cf_get_lang dictionary_id='37910.Duraklama Nedeni'></th>
                         	<th style="width:90;text-align:center;"><cf_get_lang dictionary_id='58467.Başlama'></th>
                         	<th style="width:80;text-align:right;"><cf_get_lang dictionary_id='300.Duraklama'></th>
                        </tr>
                    </thead>
                    <tbody>
                    	<cfif get_daily_duration.recordcount>
							<cfoutput query="get_daily_duration">
                   				<tr height="15">
                               		<td style="background-color:FFFFCC;text-align:center;">#currentrow#&nbsp;</td>
                                  	<td style="background-color:FFFFCC;text-align:left;">&nbsp;#STATION_NAME#</td>
                                  	<td style="background-color:FFFFCC;text-align:center;">#P_ORDER_NO#</td>
                                  	<td style="background-color:FFFFCC;text-align:center;">#LOT_NO#</td>
                                 	<td style="background-color:FFFFCC;text-align:left;">&nbsp;#PRODUCT_NAME#</td>
                                  	<td style="background-color:FFFFCC;text-align:left;">&nbsp;#OPERATION_TYPE#</td>
                                 	<td style="background-color:FFFFCC;text-align:left;">#PROD_PAUSE_TYPE#</td>
                                  	<td style="background-color:FFFFCC;text-align:center;">#TimeFormat(DateAdd('H',session.ep.time_zone,ACTION_DATE), 'HH:MM')#</td>
                                 	<td style="background-color:FFFFCC;text-align:right;">#PROD_DURATION# Sn&nbsp;.</td>
                    			</tr>
                             	<cfset t_d_time = t_d_time + PROD_DURATION>
                          	</cfoutput>
                      	</cfif>
                    </tbody>
                    <table width="100%">
                    	<tr height="50">
                        	<td colspan="9" align="right">
                    			<input type="button" value="<cfoutput><cf_get_lang dictionary_id='57553.Kapat'></cfoutput>" name="kapat" onClick="window.close();" style=" width:100px; height:40px; background-color:red">
                        	</td>
                        </tr>
                    </table>
      	</cf_grid_list>
  	</cf_box>
</div>
<script type="text/javascript">
	document.getElementById('keyword').focus();
	function input_control()
	{
		return true;
	}
</script>