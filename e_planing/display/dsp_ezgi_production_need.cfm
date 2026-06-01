<cfparam name="attributes.keyword" default=''>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.is_form_submitted" default="1">
<cfparam name="attributes.x_select_control" default="1">
<cfset this_year_max_month = Month(now())>
<cfset this_year_min_month = 1>
<cfset last_year_max_month = 12>
<cfset last_year_min_month = this_year_max_month>
<cfset this_year = Year(now())>
<cfset last_year = this_year -1>
<cfquery name="get_last_period" datasource="#dsn#">
	SELECT PERIOD_ID FROM SETUP_PERIOD WHERE OUR_COMPANY_ID = #session.ep.company_id# AND PERIOD_YEAR = #last_year#
</cfquery>
<cfquery name="get_product_name" datasource="#dsn3#">
	SELECT     
        PRODUCT_NAME
	FROM         
    	STOCKS
	WHERE     
    	STOCK_ID = #attributes.sid#
</cfquery>
<cfif isdefined("attributes.is_form_submitted")>
	<cfif isdefined('attributes.is_demonte')>
     		<cfquery name="get_all_sales_1" datasource="#dsn2#">
				SELECT
                	*,
                    CASE
                        WHEN TBL.COMPANY_ID IS NOT NULL THEN
                       (
                        SELECT     
                            NICKNAME
                        FROM         
                            #dsn_alias#.COMPANY
                        WHERE     
                            COMPANY_ID = TBL.COMPANY_ID
                        )
                        WHEN TBL.CONSUMER_ID IS NOT NULL THEN      
                        (	
                        SELECT     
                            CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                        FROM         
                            #dsn_alias#.CONSUMER
                        WHERE     
                            CONSUMER_ID = TBL.CONSUMER_ID
                        )
                        WHEN TBL.EMPLOYEE_ID IS NOT NULL THEN
                        (
                        SELECT     
                            EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
                        FROM         
                            #dsn_alias#.EMPLOYEES
                        WHERE     
                            EMPLOYEE_ID = TBL.EMPLOYEE_ID
                        )
                 	END AS UNVAN
               	FROM
                	(                	
                    SELECT  
                    	I.INVOICE_ID,
                    	I.COMPANY_ID,
                        I.CONSUMER_ID,
                        I.EMPLOYEE_ID,
                        I.INVOICE_DATE,  
                        I.INVOICE_NUMBER, 
                    	CASE WHEN I.PURCHASE_SALES = 0 THEN IR.AMOUNT * KP.PRODUCT_AMOUNT * - 1 ELSE IR.AMOUNT * KP.PRODUCT_AMOUNT END AS SATIS, 
                        MONTH(I.INVOICE_DATE) AS AY, 
                        YEAR(I.INVOICE_DATE) AS YIL, 
                      	KP.STOCK_ID
					FROM         
                    	INVOICE AS I INNER JOIN
                      	INVOICE_ROW AS IR ON I.INVOICE_ID = IR.INVOICE_ID INNER JOIN
                   		#dsn1_alias#.KARMA_PRODUCTS AS KP ON IR.PRODUCT_ID = KP.KARMA_PRODUCT_ID
                    WHERE
                        I.IS_IPTAL = 0 AND 
                        ISNULL(IR.IS_PROMOTION, 0) <> 1 AND 
                        <cfif isdefined('attributes.ihr_sat') and len(attributes.ihr_sat)>
                        	I.INVOICE_CAT IN (52,53,54,55,531) AND
                        <cfelse>
                        	I.INVOICE_CAT IN (52,53,54,55) AND
                        </cfif>
                        KP.STOCK_ID = #attributes.sid# AND
                        MONTH(I.INVOICE_DATE) >= #this_year_min_month# AND 
                        MONTH(I.INVOICE_DATE) <= #this_year_max_month# AND
                        MONTH(I.INVOICE_DATE) <> #month(now())#
                    <cfif get_last_period.recordcount>
                    	UNION ALL
                        SELECT 
                        	I.INVOICE_ID, 
                        	I.COMPANY_ID,
                            I.CONSUMER_ID,
                            I.EMPLOYEE_ID,
                            I.INVOICE_DATE,  
                            I.INVOICE_NUMBER,   
                          	CASE WHEN I.PURCHASE_SALES = 0 THEN IR.AMOUNT * KP.PRODUCT_AMOUNT * - 1 ELSE IR.AMOUNT * KP.PRODUCT_AMOUNT END AS SATIS, 
                            MONTH(I.INVOICE_DATE) AS AY, 
                            YEAR(I.INVOICE_DATE) AS YIL, 
                            KP.STOCK_ID
                        FROM         
                            #dsn#_#last_year#_#session.ep.company_id#.INVOICE AS I INNER JOIN
                         	#dsn#_#last_year#_#session.ep.company_id#.INVOICE_ROW AS IR ON I.INVOICE_ID = IR.INVOICE_ID INNER JOIN
                         	#dsn1_alias#.KARMA_PRODUCTS AS KP ON IR.PRODUCT_ID = KP.KARMA_PRODUCT_ID
                        WHERE
                            I.IS_IPTAL = 0 AND 
                            ISNULL(IR.IS_PROMOTION, 0) <> 1 AND 
                            <cfif isdefined('attributes.ihr_sat') and len(attributes.ihr_sat)>
                                I.INVOICE_CAT IN (52,53,54,55,531) AND
                            <cfelse>
                                I.INVOICE_CAT IN (52,53,54,55) AND
                            </cfif>
                            KP.STOCK_ID = #attributes.sid# AND
                            MONTH(I.INVOICE_DATE) >= #last_year_min_month#  AND 
                            MONTH(I.INVOICE_DATE) <= #LAST_year_max_month# 
                    </cfif>
                    ) AS TBL
            </cfquery>
    <cfelse>
    	<cfif attributes.x_select_control eq 1>
        	<!---SATIŞ FATURALARI--->
	 		<cfquery name="get_all_sales_1" datasource="#dsn2#">
				SELECT
                	*,
                    CASE
                        WHEN TBL.COMPANY_ID IS NOT NULL THEN
                       (
                        SELECT     
                            NICKNAME
                        FROM         
                            #dsn_alias#.COMPANY
                        WHERE     
                            COMPANY_ID = TBL.COMPANY_ID
                        )
                        WHEN TBL.CONSUMER_ID IS NOT NULL THEN      
                        (	
                        SELECT     
                            CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
                        FROM         
                            #dsn_alias#.CONSUMER
                        WHERE     
                            CONSUMER_ID = TBL.CONSUMER_ID
                        )
                        WHEN TBL.EMPLOYEE_ID IS NOT NULL THEN
                        (
                        SELECT     
                            EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ISIM
                        FROM         
                            #dsn_alias#.EMPLOYEES
                        WHERE     
                            EMPLOYEE_ID = TBL.EMPLOYEE_ID
                        )
                 	END AS UNVAN
               	FROM
                	(
                    SELECT 
                    	I.INVOICE_ID,    
                    	I.COMPANY_ID,
                        I.CONSUMER_ID,
                        I.EMPLOYEE_ID,
                        I.INVOICE_DATE,  
                        I.INVOICE_NUMBER,
                    	CASE WHEN I.PURCHASE_SALES = 0 THEN IR.AMOUNT * - 1 ELSE IR.AMOUNT END AS SATIS, 
                        MONTH(I.INVOICE_DATE) AS AY, 
                        YEAR(I.INVOICE_DATE) AS YIL, 
                      	IR.STOCK_ID
					FROM         
                    	INVOICE AS I INNER JOIN
                      	INVOICE_ROW AS IR ON I.INVOICE_ID = IR.INVOICE_ID
                    WHERE
                        I.IS_IPTAL = 0 AND 
                        ISNULL(IR.IS_PROMOTION, 0) <> 1 AND 
                        <cfif isdefined('attributes.ihr_sat') and len(attributes.ihr_sat)>
                        	I.INVOICE_CAT IN (52,53,54,55,531) AND
                        <cfelse>
                        	I.INVOICE_CAT IN (52,53,54,55) AND
                        </cfif>
                        IR.STOCK_ID = #attributes.sid# AND
                        MONTH(I.INVOICE_DATE) >= #this_year_min_month# AND 
                        MONTH(I.INVOICE_DATE) <= #this_year_max_month# AND
                        MONTH(I.INVOICE_DATE) <> #month(now())#
                    <cfif get_last_period.recordcount>
                    	UNION ALL
                        SELECT 
                        	I.INVOICE_ID, 
                        	I.COMPANY_ID,
                            I.CONSUMER_ID,
                            I.EMPLOYEE_ID,
                            I.INVOICE_DATE,  
                            I.INVOICE_NUMBER,   
                            CASE WHEN I.PURCHASE_SALES = 0 THEN IR.AMOUNT * - 1 ELSE IR.AMOUNT END AS SATIS, 
                            MONTH(I.INVOICE_DATE) AS AY, 
                            YEAR(I.INVOICE_DATE) AS YIL, 
                            IR.STOCK_ID
                        FROM         
                            #dsn#_#last_year#_#session.ep.company_id#.INVOICE AS I INNER JOIN
                            #dsn#_#last_year#_#session.ep.company_id#.INVOICE_ROW AS IR ON I.INVOICE_ID = IR.INVOICE_ID
                        WHERE
                            I.IS_IPTAL = 0 AND 
                            ISNULL(IR.IS_PROMOTION, 0) <> 1 AND 
                            <cfif isdefined('attributes.ihr_sat') and len(attributes.ihr_sat)>
                                I.INVOICE_CAT IN (52,53,54,55,531) AND
                            <cfelse>
                                I.INVOICE_CAT IN (52,53,54,55) AND
                            </cfif>
                            IR.STOCK_ID = #attributes.sid#  AND
                            MONTH(I.INVOICE_DATE) >= #last_year_min_month#  AND 
                            MONTH(I.INVOICE_DATE) <= #LAST_year_max_month# 
                    </cfif>
                    ) AS TBL
  	 		</cfquery>
       		<!---SATIŞ FATURALARI--->
    	<cfelseif attributes.x_select_control eq 2>
			<!---KOTALAR--->
            <cfset yil_list = ''>
          	<cfloop from="1" to="#attributes.uretim_ay#" index="ay">
            	<cfset buyil = Year(Dateadd('m',ay,now()))>
             	<cfset buay = Month(Dateadd('m',ay,now()))>
             	<cfif isdefined('ay_list_#buyil#')>
                	<cfset 'ay_list_#buyil#' = ListAppend(Evaluate('ay_list_#buyil#'),buay)>
             	<cfelse>
                 	<cfset 'ay_list_#buyil#' = buay>
             	</cfif>
               	<cfif not ListFind(yil_list,buyil)>
                 	<cfset yil_list = ListAppend(yil_list,buyil)>
             	</cfif>
          	</cfloop>
        	<cfquery name="get_all_sales" datasource="#dsn3#">
                	SELECT
                    	YIL,
                        AY,
                        STOCK_ID,
                        SUM(SATIS) AS SATIS
                   	FROM
                    	(
                    	<cfloop list="#yil_list#" index="yil">
                            SELECT 
                                ISNULL(SQR.QUANTITY,0) AS SATIS,
                                SQR.STOCK_ID,
                                MONTH(SQ.PLAN_DATE) AS AY,
                                YEAR(SQ.PLAN_DATE) AS YIL
                            FROM
                                SALES_QUOTAS SQ,
                                SALES_QUOTAS_ROW SQR
                            WHERE
                                SQ.SALES_QUOTA_ID = SQR.SALES_QUOTA_ID
                                AND MONTH(SQ.PLAN_DATE) IN (#Evaluate('ay_list_#yil#')#)
                                AND YEAR(SQ.PLAN_DATE) = #yil#
                                AND IS_SALES_PURCHASE = 1
                                AND SQR.STOCK_ID = #attributes.sid#
                            <cfif ListFind(yil_list,((yil*1)+1))>
                                UNION ALL
                            </cfif>
                     	</cfloop>
                        ) AS TBL
                  	GROUP BY
                        YIL,
                        AY,
                        STOCK_ID
                    ORDER BY
                        STOCK_ID,
                        YIL,
                        AY
         	</cfquery>
            <!---KOTALAR--->
     	<cfelseif attributes.x_select_control eq 3>
			<!---STOK STRATEJİLERİ MINIMUM STOK--->
           	
            <!---STOK STRATEJİLERİ MINIMUM STOK--->
    	</cfif>
  	</cfif>
    <cfif attributes.x_select_control eq 1>
    	<cfquery name="get_all_sales" dbtype="query">
            SELECT
                YIL,
                AY,
                STOCK_ID,
                SUM(SATIS) AS SATIS
            FROM
                get_all_sales_1
            GROUP BY
                YIL,
                AY,
                STOCK_ID
            ORDER BY
                STOCK_ID,
                YIL,
                AY  
        </cfquery>
		<cfif get_all_sales.recordcount>
            <cfparam name="attributes.ay" default="#get_all_sales.ay#">
            <cfparam name="attributes.yil" default="#get_all_sales.yil#">
            <cfquery name="GET_SALES_DETAIL" dbtype="query">
                SELECT 
                    * 
                FROM 
                    get_all_sales_1 
                WHERE
                    YIL = #attributes.YIL# AND
                    AY = #attributes.ay#
                ORDER BY
                    INVOICE_NUMBER
            </cfquery>
        <cfelse>
            <cfset GET_SALES_DETAIL.recordcount = 0>
        </cfif>
    </cfif>
 	<cfquery name="get_info" dbtype="query">
    	SELECT * FROM get_all_sales WHERE SATIS >0
 	</cfquery>
	<cfquery name="get_info_total" dbtype="query">
      	SELECT sum(SATIS) AS SATIS FROM get_info
  	</cfquery>
    <cfif get_info_total.SATIS gt 0>
 		<cfset ortalama = get_info_total.SATIS/get_info.recordcount>
   	<cfelse>     
       <cfset ortalama = 0> 
    </cfif>
<cfelse>
	<cfset GET_SALES_DETAIL.recordcount = 0>
</cfif>
<table width="100%">
	<tr>
    	<td>
            <cf_box title="<cfoutput>#get_product_name.PRODUCT_NAME#</cfoutput>" style="width:99%; margin-top:10px;">
            	<table width="100%">
                	<tr>
                    	<td width="100%">
                        	<cfif get_info.recordcount gt 0>
								<cfset color_count = 0>
                                <cfset color_list = "gray,purple,fuchsia,green,lime,olive,yellow,blue,navy,teal,aqua">
                                <!--- Aylık --->
                                <cfchart show3d="yes"  labelformat="number" pieslicestyle="solid" format="flash" chartwidth="540" chartheight="150" >
                                    <cfsavecontent variable="top_satis"><cf_get_lang dictionary_id='39561.Toplam Satış'></cfsavecontent>
                                    <cfchartseries type="bar" itemcolumn="#top_satis#" seriescolor="fuchsia" colorlist="#color_list#"> 
                                        <cfoutput query="get_info">
                                          	<cfchartdata item="#AY#/#Right(YIL,2)#" value="#SATIS#">
                                        </cfoutput>
                                    </cfchartseries>
                                </cfchart>
                                <!--- //Aylık --->
                            </cfif>
                        </td>
                    </tr>
                </table>
                <cf_ajax_list>
                    <thead>
                        <tr>
                            <th colspan="<cfoutput><cfif get_info.recordcount gt 0>#get_info.recordcount#<cfelse>1</cfif></cfoutput>"><cf_get_lang dictionary_id='32476.Dönemler'></th>
                      	<tr>
                        <tr>
                        	<cfoutput query="get_info">
                            	<th align="center">#AY#/#Right(YIL,2)#</th>
                            </cfoutput>
                        </tr>
                    </thead>
                    <tbody>
                        <cfif get_info.recordcount>
                        	<cfset sapma = 0>
                            <tr>
								<cfoutput query="get_info">
                                    <cfset sapma = sapma + (get_info.satis-ortalama)^2>
                                    <td align="center">
                                    	<cfif isdefined('attributes.is_demonte')>
                                    	<a href="#request.self#?fuseaction=prod.popup_dsp_ezgi_production_need&sid=#attributes.sid#&is_demonte=#attributes.is_demonte#&uretim_ay=#attributes.uretim_ay#&ay=#get_info.ay#&yil=#get_info.yil#" class="tableyazi">
                                    		#SATIS#
                                        </a>
                                        <cfelse>
                                        <a href="#request.self#?fuseaction=prod.popup_dsp_ezgi_production_need&sid=#attributes.sid#&&uretim_ay=#attributes.uretim_ay#&ay=#get_info.ay#&yil=#get_info.yil#" class="tableyazi">
                                    		#SATIS#
                                        </a>
                                        </cfif>
                                   	</td>
                                </cfoutput>
                            </tr>
                            <cfoutput>
                            <tr>
                            	<td width="100%" colspan="<cfoutput><cfif get_info.recordcount gt 0>#get_info.recordcount#<cfelse>1</cfif></cfoutput>">
                                	<table width="100%">
                                        <tr>
                                            <td colspan="3" style="text-align:center"><strong><cf_get_lang dictionary_id='1121.Aylık Ortalama Satış'> : #TlFormat(ortalama,2)#</strong></td>
                                        </tr>
                                        <cfif sapma gt 0>
                                            <tr>
                                                <cfset sapma= SQR(sapma/(get_info.recordcount-1))>
                                                <td style="text-align:center"><strong><cf_get_lang dictionary_id='40054.Sapma'> : #TlFormat(sapma,2)#</strong></td>
                                                <cfset sapma = sapma + ortalama>
                                                <td style="text-align:center"><strong><cf_get_lang dictionary_id='1122.Aylık İhtiyaç'> : #TlFormat(sapma,2)#</strong></td>
                                                <td style="text-align:center"><strong>#uretim_ay# <cf_get_lang dictionary_id='1122.Aylık İhtiyaç'> : #TlFormat(sapma*uretim_ay,2)#</strong></td>
                                            </tr>
                                        </cfif>
                                	</table>
                                </td>
                          	</tr>
                            </cfoutput>
                        <cfelse>
                            <tr>
                                <td colspan="6"><cf_get_lang dictionary_id='58486.Kayit Bulunamadi'>!</td>
                            </tr>
                        </cfif>
                    </tbody>
                </cf_ajax_list>
            </cf_box>
        </td>
    </tr>
</table>
<cfif attributes.x_select_control eq 1>
    <cf_popup_box_footer>
        <table class="big_list" style="width:100%; text-align:center">
            <thead>
                <tr class="color-head">
                    <th style="width:25px; text-align:center"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th style="width:60px; text-align:center"><cf_get_lang dictionary_id='57742.Tarih'></th>
                    <th style="width:65px; text-align:center"><cf_get_lang dictionary_id='57880.Belge No'></th>
                    <th style="width:150px; text-align:center"><cf_get_lang dictionary_id='57457.Müşteri'></th>
                    <th style="width:50px; text-align:center"><cf_get_lang dictionary_id='57635.Miktar'></th>
                </tr>
            </thead>
            <tbody>
                <cfif GET_SALES_DETAIL.recordcount>
                    <cfoutput query="GET_SALES_DETAIL">
                        <tr>
                            <td style="text-align:right">#currentrow#&nbsp;</td>
                            <td style="text-align:center">#DateFormat(INVOICE_DATE,dateformat_style)#</td>
                            <td style="text-align:center">
                                <cfif yil eq session.ep.period_year>
                                    <a href="javascript://" onclick="windowopen('#request.self#?fuseaction=invoice.form_add_bill&event=upd&iid=#INVOICE_ID#','longpage');" class="tableyazi">
                                        #INVOICE_NUMBER#
                                    </a>
                                <cfelse>
                                    #INVOICE_NUMBER#
                                </cfif>
                            </td>
                            <td>#UNVAN#</td>
                            <td style="text-align:right">#TlFormat(SATIS,2)#&nbsp;</td>
                        </tr>
                    </cfoutput>
                </cfif>
            </tbody>
        </table>
    </cf_popup_box_footer>
</cfif>