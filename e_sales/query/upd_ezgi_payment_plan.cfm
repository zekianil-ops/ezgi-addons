<cftransaction>
	<cfquery name="del_row" datasource="#dsn3#">
		DELETE FROM EZGI_VIRTUAL_OFFER_PAYMENT WHERE VIRTUAL_OFFER_ID = #attributes.virtual_offer_id#
	</cfquery>
    <cfif attributes.record_num gt 0>
    	<cfloop from="1" to="#attributes.record_num#" index="i">
        	<cfif Evaluate('attributes.row_kontrol#i#') eq 1>
            	<cfset attributes.tarih_ = Evaluate('attributes.duedate_#i#')>
            	<cf_date tarih="attributes.tarih_">
                <cfquery name="add_row" datasource="#dsn3#">
                    INSERT INTO 
                        EZGI_VIRTUAL_OFFER_PAYMENT
                        (
                            VIRTUAL_OFFER_ID, 
                            PAYMENT_TYPE_ID,
                            DUEDATE, 
                            AMOUNT, 
                            MONEY, 
                            TOTAL, 
                            TOTAL_MONEY, 
                            DETAIL,
                            ACCOUNT_ID
                        )
                    VALUES        
                        (
                            #attributes.virtual_offer_id#,
                            #Evaluate('attributes.PAYMENT_TYPE_ID_#i#')#,
                            #attributes.tarih_#,
                            #FilterNum(Evaluate('attributes.amount_#i#'),2)#,
                            '#Evaluate('attributes.money#i#')#',
                            #FilterNum(Evaluate('attributes.totalm#i#'),2)#,
                            '#attributes.total_money#',
                            <cfif Len(Evaluate('attributes.detail#i#'))>'#Left(Evaluate('attributes.detail#i#'),500)#'<cfelse>NULL</cfif>,
                            <cfif len(attributes.account)>#attributes.account#<cfelse>NULL</cfif>
                            )
                </cfquery>
            </cfif>
        </cfloop>
    </cfif>
</cftransaction>
<script type="text/javascript">
	alert("<cf_get_lang_main no='1428.Güncelleme İşleminiz Başarıyla Tamamlanmıştır.'>!");
	wrk_opener_reload()
	window.close()
</script>