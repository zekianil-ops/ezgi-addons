<!---
    File: add_ezgi_quality_control_result.cfm
    Folder: Add_Ons\ezgi\e-vts\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<cf_xml_page_edit>
<cfdump var="#x_qualite_control_confirmation#">
<cfdump var="#x_video_control#">
<cfdump var="#x_photo_control#">
<style>
	.box_yazi {font-size:16px;font:bold} 
	.box_yazi_td {font-size:15px;font:bold;color:blue} 
	.box_yazi_td2 {font-size:18px;font:bold}
	.fade 
		{
			   opacity: 1;
			   transition: opacity .25s ease-in-out;
			   -moz-transition: opacity .25s ease-in-out;
			   -webkit-transition: opacity .25s ease-in-out;
		}
   .fade:hover {opacity: 0.5;}
</style>
<cfquery name="get_process_type" datasource="#dsn#">
	SELECT
		PTR.STAGE,
		PTR.PROCESS_ROW_ID 
	FROM
		PROCESS_TYPE_ROWS PTR,
		PROCESS_TYPE_OUR_COMPANY PTO,
		PROCESS_TYPE PT
	WHERE
		PT.IS_ACTIVE = 1 AND		
		PT.PROCESS_ID = PTR.PROCESS_ID AND
		PT.PROCESS_ID = PTO.PROCESS_ID AND
		PTO.OUR_COMPANY_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.ep.company_id#"> AND
		PT.FACTION LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="%production.popup_add_ezgi_quality_control_result%">
	ORDER BY
		PTR.LINE_NUMBER
</cfquery>
<cfif not get_process_type.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='57976.Lütfen Süreçlerinizi Tanımlayınız ve/veya Tanımlanan Süreçler Üzerinde Yetkiniz Yok'>");
		window.close();
		wrk_opener_reload();
	</script>
    <cfabort>
</cfif>
<cfquery name="get_succsess" datasource="#dsn3#">
	SELECT 
    	SUCCESS_ID, 
        SUCCESS, 
        DETAIL, 
        QUALITY_COLOR, 
        IS_SUCCESS_TYPE, 
        IS_DEFAULT_TYPE
	FROM     
    	QUALITY_SUCCESS
  	ORDER BY
    	ISNULL(IS_DEFAULT_TYPE,0) DESC 
</cfquery>
<cfquery name="GET_QUALITY_ROW" datasource="#dsn3#">
	SELECT 
    	PQ.QUALITY_TYPE_ID, 
        PQ.DEFAULT_VALUE, 
        QCT.QUALITY_CONTROL_TYPE, 
        QCR.QUALITY_CONTROL_ROW, 
        QCR.QUALITY_CONTROL_ROW_ID
	FROM     
    	PRODUCT_QUALITY AS PQ INNER JOIN
        QUALITY_CONTROL_TYPE AS QCT ON PQ.QUALITY_TYPE_ID = QCT.TYPE_ID INNER JOIN
        QUALITY_CONTROL_ROW AS QCR ON QCT.TYPE_ID = QCR.QUALITY_CONTROL_TYPE_ID
	WHERE  
    	PQ.PRODUCT_ID = #attributes.product_id# AND 
        PQ.PROCESS_CAT = - 1 AND 
        PQ.OPERATION_TYPE_ID = '#attributes.operation_type_id#' AND 
        QCT.IS_ACTIVE = 1
	ORDER BY 
    	PQ.ORDER_NO
</cfquery>
<cfquery name="GET_QUALITY_ROW_group" dbtype="query">
	SELECT DISTINCT
    	QUALITY_TYPE_ID,
        QUALITY_CONTROL_TYPE
  	FROM
		GET_QUALITY_ROW
</cfquery>
<cfquery name="get_operation_type" datasource="#dsn3#">
	SELECT OPERATION_TYPE_ID FROM PRODUCTION_OPERATION WHERE P_OPERATION_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#attributes.operation_id_#">
</cfquery>
<cfdump var="#get_operation_type.OPERATION_TYPE_ID#">
<cfform name="quality_form" id="quality_form" method="post" action="">
	<cfinput type="hidden" name="upd_id" id="upd_id" value="#attributes.upd_id#">
    <cfinput type="hidden" name="operation_id_" id="operation_id_" value="#attributes.operation_id_#">
    <cfinput type="hidden" name="station_id_" id="station_id_" value="#attributes.station_id_#">
    <cfinput type="hidden" name="employee_id_" id="employee_id_" value="#attributes.employee_id_#">
    <cfinput type="hidden" name="realized_amount_" id="realized_amount_" value="#attributes.realized_amount_#">
    <cfinput type="hidden" name="operation_gurup_id" id="operation_gurup_id" value="#attributes.operation_gurup_id#">
    <cfinput type="hidden" name="process_stage" id="process_stage" value="#attributes.process_stage#">
    <cfinput type="hidden" name="process_cat" id="process_cat" value="#attributes.process_cat#">
    <cfinput type="hidden" id="quality_type_id_list" name="quality_type_id_list" value="#ValueList(GET_QUALITY_ROW_group.QUALITY_TYPE_ID)#">
	<cf_box>
    <table width="100%">
        <tr>
            <td>
            	<cfsavecontent variable="title_"><cf_get_lang dictionary_id="61295.Üretim Kalite Kontrol"></cfsavecontent>
                <cf_box title="#title_#">
                    <cf_ajax_list>
                        <thead>
                            <tr>
                            	<th align="center" width="5%">&nbsp;<cf_get_lang dictionary_id="58577.Sıra"></th>
                                <th align="center" width="65%">&nbsp;<cf_get_lang dictionary_id="43705.Kalite Kontrol Kategorisi"></th>
                                <th align="center" width="30%">&nbsp;<cf_get_lang dictionary_id="41580.Sonuç"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <cfoutput query="GET_QUALITY_ROW_group">
                            	 
                            	<cfquery name="GET_QUALITY_ROW_detail" dbtype="query">
                                    SELECT DISTINCT
                                        QUALITY_CONTROL_ROW_ID,
                                        QUALITY_CONTROL_ROW
                                    FROM
                                        GET_QUALITY_ROW
                                  	WHERE
                                    	QUALITY_TYPE_ID = #GET_QUALITY_ROW_group.QUALITY_TYPE_ID#	
                                   	ORDER BY
                                    	QUALITY_CONTROL_ROW_ID
                                </cfquery>
                                <tr>
                                	<td style=" height:40px; text-align:right">#currentrow#&nbsp;</td>
                                    <td>&nbsp;#QUALITY_CONTROL_TYPE#</td>
                                    <td>
                                    	<select id="quality_control_row_id_#GET_QUALITY_ROW_group.QUALITY_TYPE_ID#" name="quality_control_row_id_#GET_QUALITY_ROW_group.QUALITY_TYPE_ID#" style="height:38px; width:100%">
                                        	<cfloop query="GET_QUALITY_ROW_detail">
                                            	<option value="#QUALITY_CONTROL_ROW_ID#">#QUALITY_CONTROL_ROW#</option>
                                            </cfloop>
                                        </select> 
                                    </td>
                                </tr>
                            </cfoutput>
                        </tbody>
                    </cf_ajax_list>
                </cf_box>
            </td>
        </tr>
    </table>
    <cf_popup_box_footer>
        <table style="width:100%">
            <tr>
            	<td style="width:25%; text-align:left;<cfif not ListFind(x_qualite_control_confirmation,get_operation_type.OPERATION_TYPE_ID)>display:none</cfif>">
            		<cf_get_lang dictionary_id='43704.Kalite Kontrol Sonuçları'>
              	</td>
            	<td style="width:25%; text-align:left;<cfif not ListFind(x_qualite_control_confirmation,get_operation_type.OPERATION_TYPE_ID)>display:none</cfif>">
                	
                    <select id="success_id" name="success_id#" style="height:38px; width:100%">
                      	<cfoutput query="get_succsess">
                        	<option value="#success_id#">#success#</option>
                    	</cfoutput>
                	</select> 
                </td>
                <td style="width:50%; text-align:right">
                    <input type="button" onclick="kontrol(2)" name="vazgec" value="<cf_get_lang dictionary_id='57462.Vazgeç'>" style="width:120px; height:50px; background-color:red">&nbsp;&nbsp;
                    <input type="button" onclick="kontrol(1)" name="kaydet" value="<cf_get_lang dictionary_id='57461.Kaydet'>" style="width:120px; height:50px">
                </td>
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
			if(list_len(document.getElementById('quality_type_id_list').value))
			{
				sor = confirm("<cf_get_lang dictionary_id='57535.Kaydetmek İstediğinizden Emin Misiniz?'>");
				if(sor==true)
				{
					var convert_list = '';
					<cfoutput query="GET_QUALITY_ROW_group">
						type_id = #GET_QUALITY_ROW_group.QUALITY_TYPE_ID#;
						quality_control_row = document.getElementById('quality_control_row_id_'+type_id).value;
						convert_list += type_id+'-'+quality_control_row+',';
					</cfoutput>
					convert_list = convert_list.substr(0,convert_list.length-1);
					window.location='<cfoutput>#request.self#?fuseaction=production.addoperationresult_ezgi&quality_control_process_stage=#get_process_type.PROCESS_ROW_ID#&trace_no=#attributes.trace_no#</cfoutput>&upd_id='+document.getElementById('upd_id').value+'&operation_id_='+document.getElementById('operation_id_').value+'&station_id_='+document.getElementById('station_id_').value+'&realized_amount_='+document.getElementById('realized_amount_').value+'&employee_id_='+document.getElementById('employee_id_').value+'&operation_gurup_id='+document.getElementById('operation_gurup_id').value+'&process_stage='+document.getElementById('process_stage').value+'&process_cat='+document.getElementById('process_cat').value+'&success_id_='+document.getElementById('success_id').value+'&convert_list_='+convert_list;
				}
				else
					return false;
			}
			
		}
	}
</script>
