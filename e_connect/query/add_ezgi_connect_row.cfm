<cfquery name="get_connect_defaults_row" datasource="#dsn3#">
     SELECT  ISNULL(IS_EXPORT,0) AS IS_EXPORT FROM EZGI_CONNECT_SETUP_ROW WHERE EMPLOYEE_ID = #session.ep.userid#
</cfquery>
<cfquery name="get_connect_money" datasource="#DSN3#">
	SELECT        
    	MONEY_TYPE, 
        RATE2, 
        RATE1, 
        IS_SELECTED
	FROM            
    	EZGI_CONNECT_MONEY
	WHERE        
    	ACTION_ID = #attributes.connect_id#
</cfquery>
<cfif isdefined('attributes.connect_id')>
	<cfoutput query="get_connect_money">
        <cfset 'RATE1_#MONEY_TYPE#' = RATE1>
        <cfset 'RATE2_#MONEY_TYPE#' = RATE2>
    </cfoutput>
</cfif>
<cfquery name="get_connect_money_selected" dbtype="query">
	SELECT 
    	MONEY_TYPE,
        RATE2
	FROM     
     	get_connect_money
	WHERE
   		IS_SELECTED = 1
</cfquery>
<cfquery name="get_connect" datasource="#DSN3#">
	SELECT 
		SALES_TYPE,
        PROJECT_ID,
        ISNULL((SELECT CAMPAIGN_TYPE FROM PROJECT_DISCOUNTS WHERE PROJECT_ID = EZGI_CONNECT.PROJECT_ID),0) AS CAMPAIGN_TYPE
   	FROM 
    	EZGI_CONNECT
   	WHERE 
    	CONNECT_ID = #attributes.connect_id#
</cfquery>
<cfif get_connect.sales_type eq 3 and Len(get_connect.project_id)>
  	<cfquery name="get_project_disc" datasource="#dsn3#">
     	SELECT ISNULL(DISCOUNT_1,0) AS DISCOUNT_1, ISNULL(DISCOUNT_2,0) AS DISCOUNT_2, ISNULL(DISCOUNT_3,0) AS DISCOUNT_3 FROM PROJECT_DISCOUNTS WHERE PROJECT_ID = #get_connect.project_id#
  	</cfquery>
  	<cfif get_project_disc.recordcount>
      	<cfif get_project_disc.DISCOUNT_1 gt 0>
        	<cfset proje_disc1 = get_project_disc.DISCOUNT_1>
     	</cfif>
    	<cfif get_project_disc.DISCOUNT_2 gt 0>
         	<cfset proje_disc2 = get_project_disc.DISCOUNT_2>
       	</cfif>
     	<cfif get_project_disc.DISCOUNT_3 gt 0>
       		<cfset proje_disc3 = get_project_disc.DISCOUNT_3>
    	</cfif>
	</cfif>
</cfif>
<cfset connect_rate2 = get_connect_money_selected.RATE2>
<cfset connect_money = get_connect_money_selected.MONEY_TYPE>
<cfset miktar = 1>
<cfif isdefined('attributes.type') and attributes.type eq 2><!--- SSh İşlemi--->
	<cfif isdefined('attributes.karma_stock_id_list')>
        <cfloop from="1" to="#Listlen(attributes.karma_stock_id_list)#" index="i">
            <cfset attributes.amount = ListGetAt(attributes.karma_amount_list,i)>
            <cfset attributes.stock_id = ListGetAt(attributes.karma_stock_id_list,i)>
            <cfif isdefined('proje_disc1')>
            	<cfset attributes.disc1= proje_disc1>
          	<cfelse>
            	<cfset attributes.disc1 = 0>
            </cfif>
          	<cfif isdefined('proje_disc2')>
            	<cfset attributes.disc2= proje_disc2>
           	<cfelse>
            	<cfset attributes.disc2 = 0>
            </cfif>
      		<cfif isdefined('proje_disc3')>
            	<cfset attributes.disc3= proje_disc3>
           	<cfelse>
            	<cfset attributes.disc3 = 0>
            </cfif>
            <cfif len(attributes.price_cat_id)>
            	<cfquery name="get_stock_info" datasource="#dsn1#">
                	SELECT 
                    	P.PRODUCT_ID 
                   	FROM 
                    	STOCKS AS S INNER JOIN
                   		PRODUCT AS P ON P.PRODUCT_ID = S.PRODUCT_ID
                    WHERE 
                    	S.STOCK_ID = #attributes.stock_id#
                </cfquery>
              	<cfquery name="GET_PRICE" datasource="#DSN3#">
                   	SELECT 
                    	PRICE_ID,
                      	PRODUCT_ID,
                      	PRICE, 
                  		PRICE_KDV, 
                    	IS_KDV, 
                      	MONEY
                  	FROM     
                      	PRICE
                 	WHERE  
                     	FINISHDATE IS NULL AND 
                     	PRODUCT_ID = #get_stock_info.PRODUCT_ID# AND 
                    	PRICE_CATID = #attributes.price_cat_id#
             	</cfquery>
      		</cfif>
          	<cfif GET_PRICE.recordcount>
              	<cfset attributes.price= GET_PRICE.PRICE>
             	<cfset attributes.money= GET_PRICE.MONEY>
          		<cfset attributes.net_price= GET_PRICE.PRICE>
        	<cfelse>
            	<cfset attributes.price= 0>
               	<cfset attributes.money= session.ep.money>
              	<cfset attributes.net_price= 0>
           	</cfif>
            <cfinclude template="add_ezgi_connect_row_include.cfm">
        </cfloop>
        <cfinclude template="hsp_ezgi_connect_row_include.cfm">
    </cfif>
<cfelseif isdefined('attributes.type') and attributes.type eq 3><!--- Hediye Ürün İşlemi--->
	<cflock timeout="90">
    	<cftransaction>
			<cfset attributes.amount = 1>
            
            <cfif isdefined('proje_disc1')>
                <cfset attributes.disc1= proje_disc1>
            <cfelse>
                <cfset attributes.disc1 = 0>
            </cfif>
            <cfif isdefined('proje_disc2')>
                <cfset attributes.disc2= proje_disc2>
            <cfelse>
                <cfset attributes.disc2 = 0>
            </cfif>
            <cfif isdefined('proje_disc3')>
                <cfset attributes.disc3= proje_disc3>
            <cfelse>
                <cfset attributes.disc3 = 0>
            </cfif>
            <cfset attributes.row_detail = 'Kampanya Hediye Ürünü'>
            <cfset attributes.is_campaign_product = 1>
            <cfset attributes.price= 0>
            <cfset attributes.money= session.ep.money>
            <cfset attributes.net_price= 0>
            <cfset attributes.amount =1>
            <cfset miktar =1>
            
            <cfif Listlen(attributes.stockid)>
            	<cfloop from="1" to="#Listlen(attributes.stockid)#" index="sy">
                	<cfset attributes.dizi = ListGetAt(attributes.stockid,sy)>
                    <cfif listlen(attributes.dizi,'*') eq 2>
                    	<cfset attributes.stock_id = ListGetAt(attributes.dizi,1,'*')>
                        <cfset attributes.amount = ListGetAt(attributes.dizi,2,'*')>
                    <cfelse>
						<cfset attributes.stock_id = attributes.dizi>
                  	</cfif>
                    <cfinclude template="add_ezgi_connect_row_include.cfm">
                </cfloop>
            </cfif>
    	</cftransaction>
 	</cflock>
<cfelse>
	<cfif Listlen(attributes.product_info_list,'-')>
        <cflock timeout="90">
            <cftransaction>
                <cfloop from="1" to="#Listlen(attributes.product_info_list,'-')#" index="sid">
                    <cfset attributes.amount= ListGetAt(attributes.amount_info_list,sid,'-')>
                    <cfset alt_list = ListGetAt(attributes.product_info_list,sid,'-')>
                    <cfset attributes.stock_id= ListGetAt(alt_list,1)>
                    <cfset attributes.price= ListGetAt(alt_list,2)>
                    <cfset attributes.money= ListGetAt(alt_list,3)>
                    <cfset attributes.net_price= ListGetAt(alt_list,5)>
                    <cfif isdefined('proje_disc1')>
                    	<cfset attributes.disc1= proje_disc1>
                    <cfelse>
                    	<cfset attributes.disc1= ListGetAt(alt_list,6)>
                    </cfif>
                    <cfif isdefined('proje_disc2')>
                    	<cfset attributes.disc2= proje_disc2>
                    <cfelse>
                    	<cfset attributes.disc2= ListGetAt(alt_list,7)>
                    </cfif>
					<cfif isdefined('proje_disc3')>
                    	<cfset attributes.disc3= proje_disc3>
                    <cfelse>
                    	<cfset attributes.disc3= ListGetAt(alt_list,8)>
                    </cfif>
                    
                    <cfquery name="get_karma_sevk" datasource="#dsn3#">
                        SELECT 
                            KP.PRODUCT_ID, 
                            KP.STOCK_ID, 
                            KP.PRODUCT_AMOUNT, 
                            KP.SPEC_MAIN_ID
                        FROM     
                            #dsn1_alias#.KARMA_PRODUCTS AS KP INNER JOIN
                            #dsn1_alias#.STOCKS AS S ON KP.KARMA_PRODUCT_ID = S.PRODUCT_ID
                        WHERE  
                            KP.KARMA_PRODUCT_ID IN
                                                (
                                                    SELECT 
                                                        PRODUCT_ID
                                                    FROM      
                                                        PRODUCT
                                                    WHERE   
                                                        IS_KARMA_SEVK = 1 AND 
                                                        IS_KARMA = 1
                                                ) AND 
                            S.STOCK_ID = #attributes.stock_id#
                    </cfquery>
                    <cfif get_karma_sevk.recordcount>
                        <cfset karma_price = attributes.price>
                        <cfset net_karma_price = attributes.net_price>
                        <cfloop query="get_karma_sevk">
                            <cfif len(attributes.price_cat_id)>
                                <cfquery name="GET_PRICE" datasource="#DSN3#">
                                    SELECT 
                                        PRICE_ID,
                                        PRODUCT_ID,
                                        PRICE, 
                                        PRICE_KDV, 
                                        IS_KDV, 
                                        MONEY
                                    FROM     
                                        PRICE
                                    WHERE  
                                        FINISHDATE IS NULL AND 
                                        PRODUCT_ID = #get_karma_sevk.PRODUCT_ID# AND 
                                        PRICE_CATID = #attributes.price_cat_id#
                                </cfquery>
                            </cfif>
                            <cfif GET_PRICE.recordcount>
                                <cfset attributes.price= GET_PRICE.PRICE>
                                <cfset attributes.money= GET_PRICE.MONEY>
                                <cfset attributes.net_price= GET_PRICE.PRICE>
                            <cfelse>
                                <cfset attributes.price= 0>
                                <cfset attributes.money= session.ep.money>
                                <cfset attributes.net_price= 0>
                            </cfif>
                            <cfset attributes.stock_id = get_karma_sevk.STOCK_ID>
                            <cfset miktar = get_karma_sevk.PRODUCT_AMOUNT>
                            <cfif karma_price gt 0>
                                <cfset attributes.price = GET_PRICE.PRICE>
                            <cfelse>
                                <cfset attributes.price = 0>
                            </cfif>
                            <cfif net_karma_price gt 0 and karma_price gt 0 and GET_PRICE.PRICE gt 0>
                                <cfset attributes.net_price = floor((net_karma_price/karma_price)*GET_PRICE.PRICE*100)/100>
                            <cfelse>
                                <cfset attributes.net_price = 0>
                            </cfif>
                            <cfif isdefined('attributes.karma_stock_id_list')>
                                <cfif ListFind(attributes.karma_stock_id_list,get_karma_sevk.STOCK_ID)> 
                                    <cfset sira = ListFind(attributes.karma_stock_id_list,get_karma_sevk.STOCK_ID)> 
                                    <cfset miktar = ListGetAt(attributes.karma_amount_list,sira)>
                                    <cfinclude template="add_ezgi_connect_row_include.cfm">
                                </cfif>
                            <cfelse>
                                <cfinclude template="add_ezgi_connect_row_include.cfm">
                            </cfif>
                        </cfloop>
                    <cfelse>
                        <cfinclude template="add_ezgi_connect_row_include.cfm">
                    </cfif>
                </cfloop>
                <cfinclude template="hsp_ezgi_connect_row_include.cfm">
            </cftransaction>
        </cflock>
    </cfif>
</cfif>
<cfset url_str = "">
<cfif isdefined('attributes.property_group_list') and ListLen(attributes.property_group_list)>
    <cfloop list="#attributes.property_group_list#" index="ii">
        <cfif isdefined('attributes.categori_id_list_#ii#') and len(Evaluate('attributes.categori_id_list_#ii#'))>
            <cfset url_str = "#url_str#&categori_id_list_#ii#=#Evaluate('attributes.categori_id_list_#ii#')#">
        </cfif>
    </cfloop>
</cfif>
<cfif isdefined('attributes.popup')>
	<script type="text/javascript">
		wrk_opener_reload();
        window.close();
	</script>
<cfelseif not isDefined("attributes.isAjax")>
	<script type="text/javascript">
        window.location ="<cfoutput>#request.self#?fuseaction=sales.list_ezgi_connect#url_str#&event=upd&is_form_submitted=1&id_list=#attributes.id_list#&connect_id=#attributes.connect_id#&keyword=#attributes.keyword#</cfoutput>";
    </script>
</cfif>