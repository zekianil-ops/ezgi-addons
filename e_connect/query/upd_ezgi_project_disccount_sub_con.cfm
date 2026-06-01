<!---
    File: upd_ezgi_project_disccount_sub_con.cfm
    Folder: Add_Ons\ezgi\e_connect\query
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description:
--->
<cftransaction>
    <cfquery name="del_row" datasource="#dsn3#">
    	DELETE FROM 
        	EZGI_CONNECT_PROJECT_DISCOUNT_SUB_CONDITIONS
		WHERE  
        	PROJECT_ID = #attributes.project_id# AND 
            CON_PRODUCT_ID = #attributes.product_id#
    </cfquery>
    <cfif attributes.RECORD_NUM gt 0>
    	<cfloop from="1" to="#attributes.RECORD_NUM#" index="i">
        	<cfif isdefined('ROW_KONTROL#i#') and Evaluate('ROW_KONTROL#i#') eq 1>
        		<cfquery name="add_row" datasource="#dsn3#">
                	INSERT INTO 
                    	EZGI_CONNECT_PROJECT_DISCOUNT_SUB_CONDITIONS
                  		(
                        	PROJECT_ID, 
                            CON_PRODUCT_ID, 
                            PRODUCT_ID, 
                            QUANTITY
                      	)
					VALUES 
                    	(
                        	#attributes.project_id#,
                            #attributes.product_id#,
                            #Evaluate('attributes.product_id#i#')#,
                            #Evaluate('attributes.row_amount#i#')#
                      	)
                </cfquery> 
        	</cfif>
        </cfloop>
    </cfif>
</cftransaction>
<script type="text/javascript">
 	alert("Düzenleme İşlemi Tamamlanmıştır!");
  	window.close()
</script>