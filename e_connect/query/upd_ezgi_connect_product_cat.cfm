	<cfquery name="del_connect_product_cat_price" datasource="#dsn3#"> 
    	DELETE FROM EZGI_CONNECT_CAT_PRICE WHERE EZGI_CONNECT_ID = #attributes.connect_id#
    </cfquery> 
	<cfquery name="get_related_company" datasource="#dsn3#">
     	SELECT RELATED_COMPANY FROM #dsn_alias#.BRANCH WHERE BRANCH_ID = #ListGetAt(session.ep.user_location,2,'-')#
 	</cfquery>
                
  	<cfif len(ListLen(get_related_company.RELATED_COMPANY) eq 2)>
     	<cfquery name="get_partner" datasource="#DSN3#">
          	SELECT COMPANY_ID, FULLNAME, MANAGER_PARTNER_ID FROM #dsn_alias#.COMPANY WHERE COMPANY_ID = #ListGetAt(get_related_company.RELATED_COMPANY,1)#
    	</cfquery>
	<cfelse>
    	<script type="text/javascript">
			alert("Kurumsal veya Bireysel Üye Bulunamamıştır!");
		</script>
     	<cfabort>
  	</cfif>
    <cfquery name="get_discount" datasource="#dsn3#">
    	SELECT        
        	ISNULL(DISCOUNT_RATE,0) AS DISCOUNT_RATE,
            ISNULL(DISCOUNT_RATE_2,0) AS DISCOUNT_RATE_2,
            ISNULL(DISCOUNT_RATE_3,0) AS DISCOUNT_RATE_3
		FROM            
        	PRICE_CAT_EXCEPTIONS
		WHERE        
        	ACT_TYPE = 1 AND 
            COMPANY_ID = #get_partner.COMPANY_ID#
		ORDER BY 
        	PRICE_CAT_EXCEPTION_ID DESC
 	</cfquery> 
    <cfif get_discount.recordcount and get_discount.DISCOUNT_RATE gt 0>
    	<cfquery name="GET_BAREM" datasource="#dsn3#">
                SELECT        
                    P.PRODUCT_CATID, 
                    SUM(ECR.PRICE*ECR.QUANTITY) AS PRICE, 
                    TBL.CAT_PRICE, 
                    PC.PRODUCT_CAT, 
                    PC.HIERARCHY
                FROM            
                    EZGI_CONNECT_ROW AS ECR INNER JOIN
                    #dsn1_alias#.PRODUCT AS P ON ECR.PRODUCT_ID = P.PRODUCT_ID INNER JOIN
                    #dsn1_alias#.PRODUCT_CAT AS PC ON P.PRODUCT_CATID = PC.PRODUCT_CATID LEFT OUTER JOIN
                    (
                        SELECT        
                            PRODUCT_CATID, 
                            CAT_PRICE
                        FROM            
                            PRODUCT_CAT_PRICE
                        WHERE        
                            NOT (CAT_PRICE IS NULL) AND 
                            NOT (PRODUCT_CATID IS NULL)
                    ) AS TBL ON P.PRODUCT_CATID = TBL.PRODUCT_CATID
                WHERE        
                    ECR.CONNECT_ID = #attributes.connect_id#
                GROUP BY 
                    P.PRODUCT_CATID, 
                    TBL.CAT_PRICE, 
                    PC.PRODUCT_CAT, 
                    PC.HIERARCHY
     
        </cfquery>
        <cfif GET_BAREM.recordcount>
        	<cfloop query="GET_BAREM">
           		<cfquery name="UPD_ROW" datasource="#DSN3#">
                        UPDATE       
                            EZGI_CONNECT_ROW
                        SET                
                            DISCOUNT_1 = <cfif PRICE gte CAT_PRICE>#get_discount.DISCOUNT_RATE#<cfelse>0</cfif>,
                            DISCOUNT_2 = <cfif PRICE gte CAT_PRICE>#get_discount.DISCOUNT_RATE_2#<cfelse>0</cfif>,
                            DISCOUNT_3 = <cfif PRICE gte CAT_PRICE>#get_discount.DISCOUNT_RATE_3#<cfelse>0</cfif>
                        WHERE        
                            CONNECT_ROW_ID IN
                                            (
                                                SELECT        
                                                    ECR.CONNECT_ROW_ID
                                                FROM            
                                                    EZGI_CONNECT_ROW AS ECR INNER JOIN
                                                    #dsn1_alias#.PRODUCT AS P ON ECR.PRODUCT_ID = P.PRODUCT_ID INNER JOIN
                                                    #dsn1_alias#.PRODUCT_CAT AS PC ON P.PRODUCT_CATID = PC.PRODUCT_CATID
                                                WHERE        
                                                    ECR.CONNECT_ID = #attributes.connect_id# AND 
                                                    P.PRODUCT_CATID = #GET_BAREM.PRODUCT_CATID#
                                            )
            	</cfquery>
                
                <cfquery name="add_connect_product_cat_price" datasource="#dsn3#"> 
                	INSERT INTO 
                    	EZGI_CONNECT_CAT_PRICE
                        (
                        	EZGI_CONNECT_ID, 
                            PRODUCT_CAT_ID,
                            HIERARCHY,
                            PRODUCT_CAT,
                            CAT_PRICE, 
                            CONNCET_PRICE,
                            CAT_DISCOUNT_RATE,
                            CAT_DISCOUNT_RATE_2,
                            CAT_DISCOUNT_RATE_3
                       	)
					VALUES        
                    	(
                        	#attributes.connect_id#,
                            #GET_BAREM.PRODUCT_CATID#,
                            '#GET_BAREM.HIERARCHY#',
                            '#GET_BAREM.PRODUCT_CAT#',
                            <cfif len(GET_BAREM.CAT_PRICE)>#GET_BAREM.CAT_PRICE#<cfelse>0</cfif>,
                            <cfif len(GET_BAREM.PRICE)>#GET_BAREM.PRICE#<cfelse>0</cfif>,
                            #get_discount.DISCOUNT_RATE#,
                            #get_discount.DISCOUNT_RATE_2#,
                            #get_discount.DISCOUNT_RATE_3#
                      	)
				</cfquery>
          	</cfloop>
        </cfif>
    </cfif>