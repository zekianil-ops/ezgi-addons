<!---
    File: add_ezgi_prod_pause.cfm
    Folder: Add_Ons\ezgi\e-vts\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->
<!---İstasyonda Çalışan Operatörler Bulunuyor--->
<cfquery name="get_work_team" datasource="#dsn3#">
	SELECT 
    	EMPLOYEE_ID
	FROM     
    	EZGI_STATION_EMPLOYEE
	WHERE  
    	FINISH_DATE IS NULL AND 
        STATION_ID = #attributes.station_id#
</cfquery>
<cfset employee_id_list = ValueList(get_work_team.employee_id)>
<cfset employee_id_list = ListDeleteDuplicates(employee_id_list,',')>

<cfif isdefined('pause_cat')><!---Duraklamadan Çıkış--->
    <cfif not Listlen(employee_id_list) and not ListFind(employee_id_list,attributes.employee_id)> <!---İstasyon Duraklama Halinde Değilse İşlevsiz Geri Çık--->
		<script type="text/javascript">
            wrk_opener_reload();
            window.close();
        </script>
        <cfabort>
    </cfif>
    <!---Kişi Hangi Duraklamada Kontrol Ediliyor.--->
    <cfloop list="#employee_id_list#" index="i"> <!---İstasyonda Çalışan Operatörlerin Tamamı için Duraklama Kaldırılıyor.--->
        <cfquery name="get_prod_pause" datasource="#dsn3#">
            SELECT     
                ACTION_DATE,
                PROD_PAUSE_ID
            FROM         
                SETUP_PROD_PAUSE
            WHERE  
                <cfif isdefined('attributes.p_order_id') and len(attributes.p_order_id)>   
                    P_ORDER_ID = #attributes.p_order_id# AND 
                </cfif>
                STATION_ID = #attributes.station_id# AND 
                EMPLOYEE_ID = #i# AND 
                <cfif isdefined('attributes.operation_id') and len(attributes.operation_id)>
                    OPERATION_ID = #attributes.operation_id# AND 
                </cfif>
                <cfif isdefined('attributes.result_id') and len(attributes.result_id)>
                    OPERATION_RESULT_ID = #attributes.result_id# AND
                </cfif>
                PROD_DURATION IS NULL
        </cfquery>
        <cfif get_prod_pause.recordcount>
            <cfset fark= DateDiff("s", #get_prod_pause.ACTION_DATE#, #now()#)>
            <cfquery name="upd_prod_pause" datasource="#dsn3#">
                UPDATE 
                    SETUP_PROD_PAUSE
                SET 
                    PROD_DURATION = #fark#
                WHERE
                    PROD_PAUSE_ID = #get_prod_pause.PROD_PAUSE_ID#       
            </cfquery>
        </cfif> 
 	</cfloop>     
<cfelse> <!---Duraklamaya Giriş--->
	<cfloop list="#employee_id_list#" index="i"> <!---İstasyonda Çalışan Operatörlerin Tamamı için Duraklama Veriliyor.--->
        <cfquery name="add_prod_pause" datasource="#dsn3#">
            INSERT INTO 
                SETUP_PROD_PAUSE
                (
                PROD_PAUSE_TYPE_ID, 
                ACTION_DATE,
                <cfif isdefined('attributes.operation_id') and len(attributes.operation_id)>
                    OPERATION_ID, 
                </cfif>
                <cfif isdefined('attributes.result_id') and len(attributes.result_id)>
                    OPERATION_RESULT_ID,
                </cfif>
                EMPLOYEE_ID,
                STATION_ID,
                <cfif isdefined('attributes.p_order_id') and len(attributes.p_order_id)> 
                    P_ORDER_ID,
                </cfif>
                RECORD_DATE, 
                RECORD_EMP, 
                RECORD_IP
                )
            VALUES     
                (
                #prod_pause#,
                #now()#,
                <cfif isdefined('attributes.operation_id') and len(attributes.operation_id)>
                    #attributes.operation_id#,
                </cfif>
                <cfif isdefined('attributes.result_id') and len(attributes.result_id)>
                    #attributes.result_id#,
                </cfif>
                #i#,
                #attributes.station_id#,
                <cfif isdefined('attributes.p_order_id') and len(attributes.p_order_id)> 
                    #attributes.p_order_id#,
                </cfif>
                #now()#,
                #session.ep.userid#,
                '#cgi.remote_addr#'
                )
        </cfquery>
    </cfloop>
</cfif>
<script type="text/javascript">
	wrk_opener_reload();
	window.close();
</script>