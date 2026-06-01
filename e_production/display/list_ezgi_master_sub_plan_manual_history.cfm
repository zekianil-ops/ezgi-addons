<!---Ezgi Bilgisayar E-Furniture Master alt Plan History--->
<!---
    File: list_ezgi_master_sub_plan_manual_history.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2023
    Description:
--->
<cfquery name="get_history" datasource="#dsn3#">
	SELECT 
    	 EH.MASTER_ALT_PLAN_ID, 
         EH.RECORD_ID, 
         EH.RECORD_DATE, 
         EH.RECORD_IP, 
         EMAP.MASTER_ALT_PLAN_NO, 
         EMAP.PLAN_DETAIL, 
         EMP.MASTER_PLAN_DETAIL, 
         EMP.MASTER_PLAN_NUMBER,
         (SELECT REASON_FOR_TRANSFER FROM EZGI_MASTER_ALT_PLAN_REASON_FOR_TRANSFER WITH (NOLOCK) WHERE REASON_FOR_TRANSFER_ID = EH.REASON_ID) AS REASON_FOR_TRANSFER
	FROM     
    	EZGI_MASTER_ALT_PLAN_HISTORY AS EH WITH (NOLOCK) INNER JOIN
        EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) ON EH.MASTER_ALT_PLAN_ID = EMAP.MASTER_ALT_PLAN_ID INNER JOIN
        EZGI_MASTER_PLAN AS EMP WITH (NOLOCK) ON EMAP.MASTER_PLAN_ID = EMP.MASTER_PLAN_ID
	WHERE  
    	EH.P_ORDER_ID = #attributes.upd#
</cfquery>
<cfsavecontent variable="ic_talep_form"><cf_get_lang dictionary_id='57473.Tarihçe'></cfsavecontent>
<cf_medium_list_search title="#ic_talep_form#">
	<cf_medium_list_search_area>
		<table>
            <tr>
            <!-- sil --><td><cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'></td><!-- sil -->
            </tr>
		</table>
	</cf_medium_list_search_area>
</cf_medium_list_search>
	<cf_medium_list>
		<thead>
			<tr>
            	<th width="25">Sıra No</th>
                <th>Master Plan Adı</th>
				<th>Master Alt Plan Adı</th>
                <th>Master Alt Plan No</th>
                <th><cf_get_lang dictionary_id='60743.Değişiklik Nedeni'></th>
                <th>Güncelleyen</th>
                <th>Güncelleme Tarihi</th>
                <th>IP</th>
		</thead>
		<tbody>
        	<cfif get_history.recordcount>
            	<cfoutput query="get_history">
                	<tr>
                    	<td style="text-align:right">#currentrow#</td>
                        <td>#MASTER_PLAN_DETAIL#</td>
                        <td>#PLAN_DETAIL#</td>
                        <td style="text-align:center">#MASTER_PLAN_NUMBER#</td>
                        <td>#REASON_FOR_TRANSFER#</td>
                        <td>#get_emp_info(RECORD_ID,0,0)# </td>
                        <td style="text-align:center">#DateFormat(RECORD_DATE,dateformat_style)#</td>
                        <td style="text-align:center">#RECORD_IP#</td>
                    </tr>
               	</cfoutput> 
            </cfif>
        </tbody>
   	</cf_medium_list>     