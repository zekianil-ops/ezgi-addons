<!---
    File: upd_ezgi_default_measure.cfm
    Folder: Add_Ons\ezgi\e-design\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
---> 


<!---Ölçü Kodu Kontrol İşlemi--->
<cfif isdefined('attributes.default_code') and len(attributes.default_code)> <!---Ölçü Kodu Tanımlanmamışsa--->
	<cfif attributes.default_code neq attributes.old_default_code> <!---Ölçü Kodu Değişmiş İse--->
    	<cfquery name="get_measure_code" datasource="#dsn3#">
        	SELECT MEASURE_NAME FROM EZGI_VIRTUAL_OFFER_ROW_MEASURE WHERE MEASURE_CODE = '#attributes.default_code#' AND MEASURE_ID <> #attributes.MEASURE_ID#
        </cfquery>
        <cfif get_measure_code.recordcount> <!---Değişen Kod Kayıtlarda var mı--->
        	<script type="text/javascript">
				alert('<cf_get_lang dictionary_id='36569.Ölçü Adı'> : <cfoutput>#get_measure_code.measure_NAME#</cfoutput> <cf_get_lang dictionary_id='992.Girilen Ölçü Kodu Bu Ölçü Adında Tanımlıdır. Değiştiriniz!'>')
				window.history.go(-1);
			</script>
        </cfif>
   	</cfif>
</cfif>
<!---Ölçü Adı Kontrol İşlemi--->
<cfif isdefined('attributes.default_name') and len(attributes.default_name)> <!---Ölçü Adı Tanımlanmamışsa--->
	<cfif attributes.default_name neq attributes.old_default_name> <!---Ölçü Adı Değişmiş İse--->
    	<cfquery name="get_measure_name" datasource="#dsn3#">
        	SELECT MEASURE_CODE FROM EZGI_VIRTUAL_OFFER_ROW_MEASURE WHERE MEASURE_NAME = '#attributes.default_name#' AND MEASURE_ID <> #attributes.MEASURE_ID#
        </cfquery>
        <cfif get_measure_name.recordcount> <!---Değişen Ad Kayıtlarda var mı--->
        	<script type="text/javascript">
				alert('<cf_get_lang dictionary_id='36570.Ölçü Kodu'> : <cfoutput>#get_measure_name.measure_CODE#</cfoutput> <cf_get_lang dictionary_id='36570.Girilen Ölçü Adı Bu Ölçü Kodunda Tanımlıdır. Değiştiriniz!'>')
				window.history.go(-1);
			</script>
        </cfif>
   	</cfif>
</cfif>
<cftransaction>     
    <cfquery name="upd_measure" datasource="#dsn3#">
        UPDATE      
        	EZGI_VIRTUAL_OFFER_ROW_MEASURE
    	SET                
        	MEASURE_NAME = '#attributes.default_name#', 
            MEASURE_CODE = '#attributes.default_code#', 
            IS_ACTIVE = <cfif isdefined('attributes.status')>1<cfelse>0</cfif>, 
            UPDATE_EMP = #session.ep.userid#, 
            UPDATE_DATE = #now()#,
            UPDATE_IP = '#cgi.remote_addr#'
    	WHERE        
        	MEASURE_ID = #attributes.MEASURE_ID#
    </cfquery>
    <cfquery name="del_measure_row" datasource="#dsn3#">
    	DELETE FROM EZGI_VIRTUAL_OFFER_ROW_MEASURE_ROW WHERE MEASURE_ID = #attributes.MEASURE_ID#
    </cfquery>
    <cfif attributes.record_num gt 0>
    	<cfloop from="1" to="#attributes.record_num#" index="i">
        	<cfif Evaluate('attributes.row_kontrol#i#') eq 1>
                <cfquery name="add_measure_row" datasource="#dsn3#">
                    INSERT INTO 
                    	EZGI_VIRTUAL_OFFER_ROW_MEASURE_ROW
                     	(
                        	MEASURE_ID, 
                            MEASURE, 
                            IS_STANDART, 
                            IS_DEFAULT, 
                            MEASURE_TYPE, 
                            PRIVATE_RATE, 
                            PRIVATE_PRICE, 
                            BIG_MEASURE, 
                            SMALL_MEASURE, 
                            PRIVATE_MEASURE, 
                            PRIVATE2_MEASURE, 
                            ALERT_MESSAGE,
                            IS_SPECIAL_MEASURE
                      	)
					VALUES        
                    	(
                            #attributes.MEASURE_ID#,
                            #Filternum(Evaluate('attributes.olcu_#i#'),0)#,
                            <cfif isdefined('attributes.is_standart_#i#')>1<cfelse>0</cfif>,
                            <cfif isdefined('attributes.is_default_#i#')>1<cfelse>0</cfif>,
                            #Evaluate('attributes.type_id#i#')#,
                            #Filternum(Evaluate('attributes.private_rate_#i#'),0)#,
                            #Filternum(Evaluate('attributes.private_price_#i#'),2)#,
                            #Filternum(Evaluate('attributes.olcu1_#i#'),0)#,
                            #Filternum(Evaluate('attributes.olcu2_#i#'),0)#,
                            #Filternum(Evaluate('attributes.olcu3_#i#'),0)#,
                            #Filternum(Evaluate('attributes.olcu4_#i#'),0)#,
                            <cfif len(Evaluate('attributes.alert_message_#i#'))>"#Evaluate('attributes.alert_message_#i#')#"<cfelse>NULL</cfif>,
                            <cfif isdefined('attributes.is_special_measure_#i#')>1<cfelse>0</cfif>
                        )
                </cfquery>
          	</cfif>
        </cfloop>
    </cfif>
</cftransaction>
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_default_measure&event=upd&measure_id=#attributes.MEASURE_ID#" addtoken="No">