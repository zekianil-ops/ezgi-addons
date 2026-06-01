<!---
    File: list_ezgi_iflow_production_operation_result.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_production_operations" datasource="#dsn3#">
	SELECT  
        EOM.LOT_NO, 
        EOM.P_ORDER_NO, 
        EOM.P_ORDER_ID,
        EOM.PO_RELATED_ID,
        EOM.PRODUCTION_LEVEL, 
        EOM.IS_STAGE, 
        EOM.STOCK_CODE, 
      	EOM.STOCK_ID,
        EOM.PRODUCT_ID, 
        EOM.PRODUCT_NAME, 
        EOM.QUANTITY, 
        EOM.P_OPERATION_ID, 
        EOM.OPERATION_TYPE_ID, 
        EOM.OPERATION_CODE, 
        EOM.OPERATION_TYPE, 
        EOM.AMOUNT, 
     	EOM.STAGE, 
        ISNULL(EOM.REAL_TIME,0) REAL_TIME, 
        ISNULL(EOM.WAIT_TIME,0) WAIT_TIME,
        EOM.ACTION_EMPLOYEE_ID,
        DateAdd(hour,#session.ep.time_zone#,EOM.ACTION_START_DATE) AS ACTION_START_DATE,
        ISNULL(EOM.REAL_AMOUNT,0) REAL_AMOUNT, 
        EOM.LOSS_AMOUNT, 
        EOM.STATION_NAME O_STATION_NAME, 
        EOM.O_START_DATE, 
        EOM.O_STATION_IP, 
        EOM.O_TOTAL_PROCESS_TIME, 
    	EOM.IS_VIRTUAL, 
        EOM.OPERATION_GRUP_ID, 
        EOM.OPERATION_RESULT_ID, 
        EOM.OPERATION_GRUP_END_ID, 
        EOM.O_CURRENT_NUMBER,
        ISNULL((SELECT SUM(REAL_AMOUNT) AS REAL_AMOUNT FROM EZGI_OPERATION_M WHERE P_OPERATION_ID=EOM.P_OPERATION_ID),0) TOTAL_AMOUNT
	FROM            
		EZGI_OPERATION_M AS EOM WITH (NOLOCK)
	WHERE 
    	EOM.P_OPERATION_ID = #attributes.operation_id# AND
        EOM.ACTION_EMPLOYEE_ID > 0
  	ORDER BY
    	EOM.OPERATION_RESULT_ID
</cfquery>
<cfparam name="attributes.totalrecords" default='#get_production_operations.recordcount#'>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="search" method="post" action="#request.self#?fuseaction=#url.fuseaction#">
			<input name="is_form_submitted" id="is_form_submitted" type="hidden" value="1">
            <cfinput type="hidden" name="operation_id" value="#attributes.operation_id#">
            <cf_box_search>
            	<div class="form-group"  id="item-process">
                	<span style="color:red;font-weight:bold">
                	 	<cfif (get_production_operations.IS_STAGE neq 2 and get_production_operations.STAGE eq 3 and get_production_operations.AMOUNT gt get_production_operations.TOTAL_AMOUNT) or not get_production_operations.recordcount>
                        	<cfquery name="upd_operation_stage" datasource="#dsn3#">
                            	UPDATE      
                                	PRODUCTION_OPERATION
								SET                
                                	STAGE = <cfif get_production_operations.TOTAL_AMOUNT gt 0>1<cfelse>0</cfif>
								WHERE        
                                	P_OPERATION_ID = #attributes.operation_id#
                           	</cfquery> 
                            <cf_get_lang dictionary_id='29724.Güncellendi'>
                        <cfelseif (get_production_operations.IS_STAGE eq 2 and (get_production_operations.STAGE eq 0 or get_production_operations.STAGE eq 1) and get_production_operations.AMOUNT eq get_production_operations.TOTAL_AMOUNT)>
                        	<cfquery name="upd_operation_stage" datasource="#dsn3#">
                            	UPDATE      
                                	PRODUCTION_OPERATION
								SET                
                                	STAGE = 3
								WHERE        
                                	P_OPERATION_ID = #attributes.operation_id#
                           	</cfquery> 
                            <cf_get_lang dictionary_id='29724.Güncellendi'>
                        </cfif>
                   	</span>
               	</div>
                <div class="form-group small">
                    <cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Sayi_Hatasi_Mesaj'></cfsavecontent>
                    <cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,999" required="yes" onKeyUp="isNumber(this)" message="#message#" maxlength="3" style="width:25px;">
                </div>
          		<div class="form-group">
                    <cf_wrk_search_button search_function='input_control()' button_type="4">
                </div>
			</cf_box_search>
    		<cfsavecontent variable="title"><cfoutput><cf_get_lang dictionary_id='36633.Gerçekleşen Üretim'> : #get_production_operations.OPERATION_TYPE#</cfoutput></cfsavecontent>
    		<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
      			<cf_grid_list>
                	<thead>
                        <tr valign="middle">
                        	<th style="width:25px; height:20px; text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58577.Sıra'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='36498.Üretim Miktarı'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='36510.Gerçekleşen Miktar'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='137.Fire Miktarı'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='58834.İstasyon'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='36519.Gerçekleştiren'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='57655.Başlama Tarihi'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='36512.Gerçekleşen Süre'></th>
                            <th style="text-align:center; vertical-align:middle" ><cf_get_lang dictionary_id='36985.Duraklamalar'></th>
                            <!-- sil -->
                            <th style="width:20px; text-align:center; vertical-align:middle" class="header_icn_none" ></th>
                            <!-- sil -->
                        </tr>
                    </thead>
                    
                    <tbody>
                    	<cfif get_production_operations.recordcount>
							<cfoutput query="get_production_operations">
                                <tr>
                                    <td style="text-align:right; height:20px;">#CURRENTROW#</td>
                                    <td style="text-align:right;">#AmountFormat(AMOUNT,2)#</td>
                                    <td style="text-align:right;">#AmountFormat(REAL_AMOUNT,2)#</td>
                                    <td style="text-align:right;">#AmountFormat(LOSS_AMOUNT,2)#</td>
                                    <td style="text-align:left;">#O_STATION_NAME#</td>
                                    <td style="text-align:left;">#get_emp_info(ACTION_EMPLOYEE_ID,0,0)#</td>
                                    <td style="text-align:center;">#DateFormat(ACTION_START_DATE,dateformat_style)# #TimeFormat(ACTION_START_DATE,'HH:MM:SS')#</td>
                                    <td style="text-align:right;">
                                    	<cfif len(Int(REAL_TIME/3600)) eq 1>0</cfif>#Int(REAL_TIME/3600)#:<cfif len(Int((REAL_TIME/60) Mod 60)) eq 1>0</cfif>#Int((REAL_TIME/60) Mod 60)#:<cfif len(Int(REAL_TIME Mod 60)) eq 1>0</cfif>#Int(REAL_TIME Mod 60)#
                                 	</td>
                                    <td style="text-align:right;">
                                    	<cfif len(Int(WAIT_TIME/3600)) eq 1>0</cfif>#Int(WAIT_TIME/3600)#:<cfif len(Int((WAIT_TIME/60) Mod 60)) eq 1>0</cfif>#Int((WAIT_TIME/60) Mod 60)#:<cfif len(Int(WAIT_TIME Mod 60)) eq 1>0</cfif>#Int(WAIT_TIME Mod 60)#
                                    </td>
                                    <td style="text-align:center; background-color:<cfif REAL_AMOUNT eq 0 and LOSS_AMOUNT eq 0>springgreen</cfif>">
                                        <a href="#request.self#?fuseaction=prod.popup_upd_ezgi_iflow_production_operation_result&upd_id=#OPERATION_RESULT_ID#">
                                        	<cfif REAL_AMOUNT neq 0>
                                            	<img src="/images/update_list.gif" title="<cf_get_lang dictionary_id='57464.Güncelle'>">
                                            </cfif>
                                        </a>
                                    </td>
                                </tr>
                            </cfoutput>	
                        <cfelse>
                            <tr> 
                                <td colspan="20" height="20"><cf_get_lang dictionary_id='57484.Kayıt Yok'>!</td>
                            </tr>
                        </cfif>
                    </tbody>
               	 </cf_grid_list>
           	</cf_box>
     	</cfform>
   	</cf_box>
</div>
<script type="text/javascript">
	function input_control()
	{
		return true;	
	}
</script>