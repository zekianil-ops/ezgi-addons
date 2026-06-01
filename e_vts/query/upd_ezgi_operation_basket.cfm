<!---
    File: upd_ezgi_operation_basket_row.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/09/2022
    Description:
--->
<cfparam name="attributes.lot_number" default="">
<cfparam name="attributes.is_show" default="1">
<cfparam name="attributes.master_plan" default="">
<cfset attributes.station_id = attributes.station_id_>
<cfset get_workstation_name.EZGI_PACKAGE_CONTROL = 3>
<cftransaction>
    <cfquery name="add_operation_basket_row" datasource="#dsn3#">
   		UPDATE 
        	EZGI_VTS_OPERATION_BASKET
		SET          
        	IS_STAGE =<cfif attributes.islem eq -1>1<cfelse>#attributes.islem#</cfif>,
       		UPDATE_DATE = #now()#, 
          	UPDATE_EMP = #session.ep.userid#, 
         	UPDATE_IP = '#CGI.REMOTE_ADDR#'
		WHERE  
       		EZGI_VTS_OPERATION_BASKET_ID = #attributes.basket_id#
  	</cfquery>
    <cfif isdefined('attributes.islem') and (attributes.islem eq 2 or attributes.islem eq -1)> <!---Üretimler Başlatılacaksa veya Terkedilecekse--->
    	<cfquery name="get_operation_basket" datasource="#dsn3#">
            SELECT DISTINCT
                E.EZGI_VTS_OPERATION_BASKET_ID, 
                E.BASKET_NO, 
                E.EMPLOYEE_ID, 
                E.STATION_ID, 
                ISNULL(E.REAL_RATE,0) AS REAL_RATE, 
                E.IS_STAGE, 
                E.RECORD_DATE, 
                E.RECORD_EMP, 
                E.UPDATE_DATE
            FROM     
                EZGI_VTS_OPERATION_BASKET AS E INNER JOIN
                EZGI_VTS_OPERATION_BASKET_ROW AS ER ON E.EZGI_VTS_OPERATION_BASKET_ID = ER.EZGI_VTS_OPERATION_BASKET_ID
            WHERE  
                E.EZGI_VTS_OPERATION_BASKET_ID = #attributes.basket_id#
            ORDER BY
                E.RECORD_DATE
        </cfquery>
      	<cfif get_operation_basket.recordcount and len(get_operation_basket.BASKET_NO)>
         	<cfset attributes.realized_amount_ = 0>
            <cfset attributes.loss_amount_ = 0>
            <cfset product_time_ = 0>
            <cfset attributes.duration_time_ = 0>
            <cfset attributes.lot_number = get_operation_basket.BASKET_NO>
            <cfinclude template="../query/get_ezgi_operations.cfm">
             <cfif get_po_det.recordcount>
             	<cfif attributes.islem eq 2><!---Üretimler Başlatılacaksa--->
                    <cfloop query="get_po_det">
                        <cfset attributes.upd_id = get_po_det.P_ORDER_ID>
                        <cfset attributes.operation_id_ = get_po_det.P_OPERATION_ID>
                        <cfif get_po_det.stage eq 2> <!---Eğer Üretim Sonlanmışsa--->
                            Operasyon Zaten Sonlandırılmış.
                            <cfdump var="#get_po_det#">
                            <cfabort>
                        <cfelse>
                            <cfinclude template="add_ezgi_operation_result.cfm"><!---Operasyon Sonuç Başlama Kaydı Açılıyor--->
                            <cfif get_ezgi_result_control_group.recordcount and get_ezgi_result_stocks_group.recordcount> <!---Eğer Malzemede ve sorun varsa --->
                                <script type="text/javascript">
                                    window.history.go(-1);
                                </script>
                                <cfabort>
                            </cfif>
                            <cfquery name="UPD_OPERATION" datasource="#dsn3#">
                                UPDATE  
                                    PRODUCTION_OPERATION
                                SET     
                                    STAGE = 1
                                WHERE 	
                                    P_OPERATION_ID = #attributes.operation_id_#
                            </cfquery>
                        </cfif>
                    </cfloop>
                <cfelseif attributes.islem eq -1><!---Üretimler Terkedilecekse--->
                	<cfset operation_control = 0>
                	<cfloop query="get_po_det"> <!---Sepete Bağlı Operasyonlar Döndürülüyor--->
                    	<cfquery name="get_result_id" datasource="#dsn3#"> <!---Kişinin İstasyonda Başladığı ve Sonuç Girmediği İlgili Operasyonun Başlama Zamanı Bulunuyor--->
                            SELECT
                                OPERATION_RESULT_ID,
                                ACTION_START_DATE
                            FROM
                                PRODUCTION_OPERATION_RESULT
                            WHERE     	
                                ACTION_EMPLOYEE_ID = #attributes.employee_id_# AND 
                                STATION_ID = #attributes.station_id_# AND 
                                OPERATION_ID = #get_po_det.P_OPERATION_ID# AND 
                                REAL_AMOUNT = 0	 AND 
                                LOSS_AMOUNT = 0	
                        </cfquery>
                        <cfif get_result_id.recordcount and len(get_result_id.OPERATION_RESULT_ID)>
                        	<cfquery name="del_employee_station" datasource="#dsn3#"> <!---Başlamış Operasyon Sonucu Siliniyor--->
                                DELETE FROM PRODUCTION_OPERATION_RESULT WHERE OPERATION_RESULT_ID = #get_result_id.OPERATION_RESULT_ID#
                            </cfquery>
                            <cfquery name="get_operation_control" datasource="#dsn3#">
                                SELECT * FROM PRODUCTION_OPERATION_RESULT WHERE OPERATION_ID = #get_po_det.P_OPERATION_ID#
                            </cfquery>
                            <cfif not get_operation_control.recordcount>
                                <cfquery name="upd_operation" datasource="#dsn3#">
                                    UPDATE    
                                        PRODUCTION_OPERATION
                                    SET              
                                        STAGE =0
                                    WHERE     
                                        P_OPERATION_ID = #get_po_det.P_OPERATION_ID#
                                </cfquery>
                           	<cfelse>
                        		<cfset operation_control = 1>
                            </cfif>
                        </cfif>
                    </cfloop>
                	<cfquery name="upd_operation_basket_row" datasource="#dsn3#">
                      	UPDATE 
                         	EZGI_VTS_OPERATION_BASKET
                     	SET          
                         	IS_STAGE =<cfif operation_control eq 1>3<cfelse>1</cfif>,
                          	UPDATE_DATE = #now()#, 
                          	UPDATE_EMP = #session.ep.userid#, 
                           	UPDATE_IP = '#CGI.REMOTE_ADDR#'
                      	WHERE  
                       		EZGI_VTS_OPERATION_BASKET_ID = #attributes.basket_id#
                 	</cfquery>
                </cfif>
             </cfif>
      	</cfif>      
    </cfif>
</cftransaction>    
<script type="text/javascript">
	<cfif isdefined('attributes.islem') and attributes.islem eq 0>
		alert("Sepet Onay Kaldırma İşlemi Tamamlanmıştır.!");
	</cfif>
	<cfif isdefined('attributes.islem') and attributes.islem eq 1>
		alert("Sepet Onaylama İşlemi Tamamlanmıştır.!");
	</cfif>
	<cfif isdefined('attributes.islem') and attributes.islem eq 2>
		alert("Toplu Operasyon Başlatılmıştır.!");
	</cfif>
	<cfif isdefined('attributes.islem') and attributes.islem eq -1>
		alert("Toplu Operasyon Durdurlulmuştur.!");
	</cfif>
	<cfif isdefined('attributes.islem') and attributes.islem eq 4>
		alert("Sepet Kapatılmıştır.!");
	</cfif>
	window.location ="<cfoutput>#request.self#?fuseaction=production.dsp_ezgi_operation_basket&is_form_submitted=1&station_id=#attributes.station_id_#&employee_id=#attributes.employee_id_#</cfoutput>";
</script>
