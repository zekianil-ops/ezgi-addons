<cftransaction>
	<cfquery name="del_row" datasource="#dsn3#">
    	DELETE FROM EZGI_VIRTUAL_OFFER_ROW_FLOOR WHERE EZGI_ID = #attributes.ezgi_id# 
    </cfquery>
   	<cfif attributes.record_num gt 0>
    	<cfloop from="1" to="#attributes.record_num#" index="i">
            <cfquery name="add_row" datasource="#dsn3#">
            	INSERT INTO 
                	EZGI_VIRTUAL_OFFER_ROW_FLOOR
                   	(
                    	EZGI_ID, 
                        TIP, 
                        KONUM,
                        DAIRE,
                        MEKAN,
                        IS_PRINT
                   	)
				VALUES        
                	(
                    	#attributes.ezgi_id#,
                        <cfif isdefined('TIP_#i#') and Len(Evaluate('TIP_#i#'))>'#Evaluate('TIP_#i#')#'<cfelse>NULL</cfif>,
                        <cfif isdefined('KONUM_#i#') and Len(Evaluate('KONUM_#i#'))>'#Evaluate('KONUM_#i#')#'<cfelse>NULL</cfif>,
                        <cfif isdefined('DAIRE_#i#') and Len(Evaluate('DAIRE_#i#'))>'#Evaluate('DAIRE_#i#')#'<cfelse>NULL</cfif>,
                        <cfif isdefined('MEKAN_#i#') and Len(Evaluate('MEKAN_#i#'))>'#Evaluate('MEKAN_#i#')#'<cfelse>NULL</cfif>,
                    	<cfif isdefined('IS_PRINT_#i#') and isdefined('IS_PRINT_#i#')>1<cfelse>0</cfif>
                    )
            </cfquery>
        </cfloop>
    </cfif>
</cftransaction>
<script type="text/javascript">
	alert("<cf_get_lang_main no='1428.Güncelleme İşleminiz Başarıyla Tamamlanmıştır.'>!");
	window.close()
</script>