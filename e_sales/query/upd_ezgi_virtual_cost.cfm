<cftransaction>
    <cfquery name="del_montage_row" datasource="#dsn3#">
       	DELETE FROM EZGI_MONTAGE_ROW WHERE EZGI_ID = #attributes.ezgi_id#            
    </cfquery>
    <cfif attributes.RECORD_NUM gt 0>
     	<cfloop from="1" to="#attributes.RECORD_NUM#" index="i">
         	<cfif isdefined('attributes.SELECT_PRODUCT#i#')>
                <cfquery name="add_montage_row" datasource="#dsn3#">
                	INSERT INTO 
                    	EZGI_MONTAGE_ROW
                    	(
                        	STOCK_ID, 
                            PRODUCT_NAME, 
                            AMOUNT, 
                            MAIN_UNIT, 
                            PRODUCT_UNIT_ID, 
                            PRICE, 
                            OTHER_MONEY, 
                            EZGI_ID,
                            ROW_TOTAL,
							IS_HZM
                      	)
					VALUES        
                    	(
                            #Evaluate('attributes.stock_id#i#')#,
                            '#Evaluate('attributes.product_name#i#')#',
                            #Filternum(Evaluate('attributes.amount#i#'),2)#,
                            '#Evaluate('attributes.main_unit#i#')#',
                            #Evaluate('attributes.product_unit_id#i#')#,
                            #Filternum(Evaluate('attributes.price#i#'),2)#,
                            '#Evaluate('attributes.money#i#')#',
                        	#attributes.ezgi_id#,
                            #Filternum(Evaluate('attributes.totalm#i#'),2)#,
                            <cfif isdefined('attributes.is_mrk')>
                            	<cfif isdefined('attributes.select_hzm#i#')>1<cfelse>0</cfif>
                            <cfelse>
                            	1
                            </cfif>
                        )
                </cfquery>    
         	</cfif>
     	</cfloop>
    </cfif>
    <cfquery name="upd_virtual_offer_row_cost" datasource="#dsn3#">
    	UPDATE       
      		EZGI_VIRTUAL_OFFER_ROW
		SET                
        	COST = #Filternum(attributes.row_money_total,2)#
		WHERE        
        	EZGI_ID = #attributes.ezgi_id#
    </cfquery>
</cftransaction>
<script type="text/javascript">
		alert("Maliyet Güncellenmiştir!");
		wrk_opener_reload();
		window.close()
</script>