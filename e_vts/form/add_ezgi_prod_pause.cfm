<!---
    File: add_ezgi_prod_pause.cfm
    Folder: Add_Ons\ezgi\e-vts\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.prod_pause" default="">
<cfquery name="get_prod_pause_type" datasource="#dsn3#">
	SELECT 
		SPPT.PROD_PAUSE_TYPE_ID,
		SPPT.PROD_PAUSE_TYPE
	FROM
		SETUP_PROD_PAUSE_TYPE SPPT,
		SETUP_PROD_PAUSE_CAT SPPC
	WHERE
		SPPT.PROD_PAUSE_CAT_ID=SPPC.PROD_PAUSE_CAT_ID 
		AND SPPT.PROD_PAUSE_CAT_ID = #type_id#    
  	ORDER BY
    	SPPT.PROD_PAUSE_TYPE
</cfquery>
<cfif isdefined('attributes.operation_id_')>
    <cfquery name="get_operation_name" datasource="#dsn3#">
        SELECT     
            OT.OPERATION_TYPE
        FROM         
            PRODUCTION_OPERATION AS PO INNER JOIN
            OPERATION_TYPES AS OT ON PO.OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID
        WHERE     
            PO.P_OPERATION_ID = #attributes.operation_id_#
    </cfquery>
    <cfquery name="get_result_id" datasource="#dsn3#">
      	SELECT
        	OPERATION_RESULT_ID
      	FROM
         	PRODUCTION_OPERATION_RESULT
      	WHERE     	
        	ACTION_EMPLOYEE_ID = #attributes.employee_id_# AND 
          	STATION_ID = #attributes.station_id_# AND 
          	OPERATION_ID = #attributes.operation_id_# AND 
         	REAL_AMOUNT = 0	 AND 
         	LOSS_AMOUNT = 0	
    </cfquery>
    <cfif get_result_id.recordcount>
    	<cfset attributes.result_id = get_result_id.OPERATION_RESULT_ID>
    </cfif>
</cfif>
<cfquery name="get_station_name" datasource="#dsn3#">
	SELECT STATION_NAME FROM WORKSTATIONS WHERE STATION_ID = #attributes.station_id_#
</cfquery>

<table width="100%">
	<tr>
    	<td>
			<cfsavecontent variable="durak"><cf_get_lang dictionary_id='325.Duraklama Başlangıç'></cfsavecontent>
            <cf_box title="#durak#">
                <cf_ajax_list>
                    <thead>
                        <tr>
                            <th align="center" width="15%">&nbsp;<cf_get_lang dictionary_id='29474.Emir No'></th>
							<th align="center" width="30%">&nbsp;<cf_get_lang dictionary_id='29419.Operasyon'></th>
							<th align="center" width="30%">&nbsp;<cf_get_lang dictionary_id='58834.İstasyon'></th>
                         	<th align="center" width="25%">&nbsp;<cf_get_lang dictionary_id='301.Operatör'></th>
                        </tr>
                    </thead>
                    <tbody>
                   		<tr>
                        	<cfoutput>
							<td>&nbsp;<cfif isdefined('attributes.p_order_no')>#p_order_no#</cfif></td>
                         	<td>&nbsp;<cfif isdefined('attributes.operation_id_')>#get_operation_name.operation_type#</cfif></td>
                          	<td>&nbsp;#get_station_name.station_name#</td>
                          	<td>&nbsp;#get_emp_info(employee_id_,0,0)#</td>
                            </cfoutput>
                    	</tr>
                    </tbody>
                </cf_ajax_list>
            </cf_box>
        </td>
    </tr>
</table>
<cfform name="pause_form" method="post" action="">
	<cf_medium_list_search title="">
		<cf_medium_list_search_area>
			<table>
            	<tr>
                	<td>&nbsp;
                    	<select name="prod_pause" style="width:545px; font-size:22px; font-weight:bold; font-family:'Palatino Linotype', 'Book Antiqua', Palatino, serif">
                         	<option value=""><cf_get_lang dictionary_id='57734.Seçiniz'></option>
                       		<cfoutput query="get_prod_pause_type">
                           		<option value="#PROD_PAUSE_TYPE_ID#"<cfif PROD_PAUSE_TYPE_ID eq attributes.prod_pause>selected</cfif>>&nbsp;#PROD_PAUSE_TYPE#</option>
                        	</cfoutput>
                      	</select>
                    </td>
                </tr>
            </table>
		</cf_medium_list_search_area>
	</cf_medium_list_search>
</cfform>
<cf_popup_box_footer>
	<table style="width:100%">
     	<tr>
          	<td style="width:100%; text-align:center">
            	<input type="button" onclick="sw_start(1)" name="basla" value="<cfoutput><cf_get_lang dictionary_id='325.Duraklama Başlangıç'></cfoutput>" style="width:160px; height:50px">&nbsp;&nbsp;
             	<input type="button" onclick="sw_start(3)" name="vazgec" value="<cfoutput><cf_get_lang dictionary_id='57462.Vazgeç'></cfoutput>" style="width:120px; height:50px">
			</td>
     	</tr>
	</table>
</cf_popup_box_footer>

<script type="text/javascript">
	function sw_start(type)
	{
		
		<cfoutput>
			var p_order_id = <cfif isdefined('attributes.upd_id')>#attributes.upd_id#<cfelse>''</cfif>;
			var station_id = <cfif isdefined('attributes.station_id_')>#attributes.station_id_#<cfelse>''</cfif>; 
			var operation_id = <cfif isdefined('attributes.operation_id_')>#attributes.operation_id_#<cfelse>''</cfif>;
			var employee_id = <cfif isdefined('attributes.employee_id_')>#attributes.employee_id_#<cfelse>''</cfif>;
			var result_id = <cfif isdefined('attributes.result_id')>#attributes.result_id#<cfelse>''</cfif>;
		</cfoutput>
		var prod_pause_ = document.all.prod_pause.value;
		if(type==3)
		{
			window.close();
		}
		if(type==1)
		{
			if(prod_pause_=='')
			{
		 		alert('<cf_get_lang dictionary_id='311.Lütfen Önce Seçim Yapınız'> !!');
			}
			else
			{
				window.location ='<cfoutput>#request.self#</cfoutput>?fuseaction=production.emptypopup_add_ezgi_prod_pause&p_order_id='+p_order_id+'&station_id='+station_id+'&operation_id='+operation_id+'&employee_id='+employee_id+'&prod_pause='+prod_pause_+'&result_id='+result_id;
			}
		}
	}
</script>  