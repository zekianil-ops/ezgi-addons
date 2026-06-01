<cfparam name="attributes.product_name" default="">
<cfparam name="attributes.product_id" default="">
<cfparam name="attributes.short_code_id" default="">
<cfparam name="attributes.short_code_name" default="">
<cfparam name="attributes.prod_cat" default="">
<cfparam name="attributes.select_year" default="#session.ep.period_year#">
<cfparam name="attributes.order_employee" default="">
<cfparam name="attributes.order_employee_id" default="">
<cfparam name="attributes.sales_departments" default="">
<cfparam name="attributes.sort_type" default="5">
<cfparam name="attributes.listing_type" default="1">
<cfparam name="attributes.report_type" default="">
<cfparam name="attributes.keyword" default="">
<cfparam name="attributes.branch_id" default="">
<cfparam name="attributes.city_name" default="">
<cfparam name="attributes.zone_id" default="">
<cfparam name="attributes.t_point" default="0">
<cfparam name="attributes.SHIP_METHOD_ID" default="">
<cfparam name="attributes.company_id" default="">
<cfparam name="attributes.consumer_id" default="">
<cfparam name="attributes.totalrecords" default="0">
<cfparam name="attributes.form_varmi" default="1">
<cfset ay = month(now())>
<cfparam name="attributes.select_month" default="#ay#">
<cfset son_gun = daysinmonth('01/#attributes.select_month#/#session.ep.period_year#')>
<cfquery name="SZ" datasource="#DSN#">
	SELECT * FROM SALES_ZONES WHERE IS_ACTIVE=1 ORDER BY SZ_NAME
</cfquery>
<cfif isdefined("attributes.form_varmi")>
	<cfif ListLen(attributes.branch_id)>
        <cfquery name="get_department" datasource="#dsn#">
            SELECT DEPARTMENT_ID FROM DEPARTMENT WHERE BRANCH_ID IN (#attributes.branch_id#)
        </cfquery>
        <cfset department_id_list = ValueList(get_department.DEPARTMENT_ID)>
    </cfif>
	<cfset t_puan = 0>
	<cfset t_tutar = 0>
   	<cfset t_tax_tutar = 0>
	<cfloop from="1" to="#son_gun#" index="i">
        <cfquery name="GET_SHIPPING" datasource="#dsn3#"><!---Sevk Planları ve Sevk Talepleri Listeleniyor--->
            SELECT
            	PUAN AS SATIR_PUAN,
                QUANTITY,
                NETTOTAL AS SATIR_NET_TOTAL,
                (NETTOTAL+(NETTOTAL*TAX/100)) AS SATIR_TAX_TOTAL,
                REPORT_DAY,
                REPORT_MONTH
            FROM
                (
                <cfif attributes.listing_type neq 3>
                    <cfif not len(attributes.branch_id)>
                        SELECT
                        	ISNULL(
                            (
                            SELECT 
                                TOP (1) PROPERTY1
                            FROM
                                PRODUCT_INFO_PLUS
                            WHERE
                                PRODUCT_ID = ORDER_ROW.PRODUCT_ID     
                            )
                            ,0) AS PUAN,     
                            ESR.DELIVERY_DATE, 
                            ESR.DEPARTMENT_ID, 
                            ESR.OUT_DATE, 
                            ESR.IS_TYPE, 
                            ESR.LOCATION_ID, 
                            ESR.SHIP_METHOD_TYPE, 
                            ORDER_ROW.STOCK_ID, 
                            ORDER_ROW.PRODUCT_ID, 
                            ISNULL(ORDER_ROW.QUANTITY,0) AS QUANTITY, 
                            ORDER_ROW.ORDER_ROW_CURRENCY, 
                            ORDER_ROW.ORDER_ROW_ID, 
                            ORDER_ROW.ORDER_ID,
                            ISNULL(ORDER_ROW.NETTOTAL,0) AS NETTOTAL,
                            ISNULL(ORDER_ROW.TAX,0) AS TAX,
                            SC.CITY_NAME,
                            SCO.COUNTY_NAME,
                            DAY(ESR.OUT_DATE) AS REPORT_DAY,
                            MONTH(ESR.OUT_DATE) AS REPORT_MONTH
                        FROM         
                            EZGI_SHIP_RESULT AS ESR INNER JOIN
                            #dsn_alias#.SHIP_METHOD AS SM ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID INNER JOIN
                            #dsn_alias#.EMPLOYEES AS E ON ESR.DELIVER_EMP = E.EMPLOYEE_ID INNER JOIN
                            #dsn_alias#.DEPARTMENT AS D ON ESR.DEPARTMENT_ID = D.DEPARTMENT_ID INNER JOIN
                            EZGI_SHIP_RESULT_ROW ON ESR.SHIP_RESULT_ID = EZGI_SHIP_RESULT_ROW.SHIP_RESULT_ID INNER JOIN
                            ORDER_ROW ON EZGI_SHIP_RESULT_ROW.ORDER_ROW_ID = ORDER_ROW.ORDER_ROW_ID INNER JOIN
                            ORDERS AS O ON ORDER_ROW.ORDER_ID = O.ORDER_ID LEFT OUTER JOIN
                            #dsn_alias#.SETUP_COUNTY AS SCO ON O.COUNTY_ID = SCO.COUNTY_ID LEFT OUTER JOIN
                            #dsn_alias#.SETUP_CITY AS SC ON O.CITY_ID = SC.CITY_ID
                        WHERE     
                            ESR.IS_TYPE = 1 
                          	AND DAY(ESR.OUT_DATE)= #i#
                            AND MONTH(ESR.OUT_DATE)= #attributes.select_month#
                            AND YEAR(ESR.OUT_DATE)= #session.ep.period_year#
                            <cfif isdefined('attributes.SALES_DEPARTMENTS') and len(attributes.SALES_DEPARTMENTS)>
                                AND ESR.DEPARTMENT_ID = #listgetat(attributes.SALES_DEPARTMENTS,1,'-')# 
                                AND ESR.LOCATION_ID = #listgetat(attributes.SALES_DEPARTMENTS,2,'-')#
                            </cfif>
                            <cfif attributes.listing_type eq 1>      
                                UNION ALL
                            </cfif>
                        </cfif>
                    </cfif>
                    <cfif attributes.listing_type neq 2>
						 SELECT
                        	ISNULL(
                            (
                            SELECT 
                                TOP (1) PROPERTY1
                            FROM
                                PRODUCT_INFO_PLUS
                            WHERE
                                PRODUCT_ID = ORDER_ROW.PRODUCT_ID     
                            )
                            ,0) AS PUAN,     
                            ESR.DELIVERY_DATE, 
                            ESR.DEPARTMENT_ID, 
                            ESR.OUT_DATE, 
                            ESR.IS_TYPE, 
                            ESR.LOCATION_ID, 
                            ESR.SHIP_METHOD_TYPE, 
                            ORDER_ROW.STOCK_ID, 
                            ORDER_ROW.PRODUCT_ID, 
                            ISNULL(ORDER_ROW.QUANTITY,0) AS QUANTITY, 
                            ORDER_ROW.ORDER_ROW_CURRENCY, 
                            ORDER_ROW.ORDER_ROW_ID, 
                            ORDER_ROW.ORDER_ID,
                            ISNULL(ORDER_ROW.NETTOTAL,0) AS NETTOTAL,
                            ISNULL(ORDER_ROW.TAX,0) AS TAX,
                            SC.CITY_NAME,
                            SCO.COUNTY_NAME,
                            DAY(ESR.OUT_DATE) AS REPORT_DAY,
                            MONTH(ESR.OUT_DATE) AS REPORT_MONTH
                        FROM         
                            EZGI_SHIP_RESULT_INTERNALDEMAND AS ESR INNER JOIN
                            #dsn_alias#.SHIP_METHOD AS SM ON ESR.SHIP_METHOD_TYPE = SM.SHIP_METHOD_ID INNER JOIN
                            #dsn_alias#.EMPLOYEES AS E ON ESR.DELIVER_EMP = E.EMPLOYEE_ID INNER JOIN
                            #dsn_alias#.DEPARTMENT AS D ON ESR.DEPARTMENT_ID = D.DEPARTMENT_ID INNER JOIN
                            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW ON ESR.SHIP_RESULT_INTERNALDEMAND_ID = EZGI_SHIP_RESULT_INTERNALDEMAND_ROW.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                            ORDER_ROW ON EZGI_SHIP_RESULT_INTERNALDEMAND_ROW.ORDER_ROW_ID = ORDER_ROW.ORDER_ROW_ID INNER JOIN
                            ORDERS AS O ON ORDER_ROW.ORDER_ID = O.ORDER_ID LEFT OUTER JOIN
                            #dsn_alias#.SETUP_COUNTY AS SCO ON O.COUNTY_ID = SCO.COUNTY_ID LEFT OUTER JOIN
                            #dsn_alias#.SETUP_CITY AS SC ON O.CITY_ID = SC.CITY_ID
                        WHERE     
                            ESR.IS_TYPE = 2
                            <cfif ListLen(attributes.branch_id) and ListLen(department_id_list)>
                                AND ESR.DEPARTMENT_IN_ID IN (#department_id_list#)
                            </cfif>
                          	AND DAY(ESR.OUT_DATE)= #i#
                            AND MONTH(ESR.OUT_DATE)= #attributes.select_month#
                            AND YEAR(ESR.OUT_DATE)= #session.ep.period_year#
                            <cfif isdefined('attributes.SALES_DEPARTMENTS') and len(attributes.SALES_DEPARTMENTS)>
                                AND ESR.DEPARTMENT_ID = #listgetat(attributes.SALES_DEPARTMENTS,1,'-')# 
                                AND ESR.LOCATION_ID = #listgetat(attributes.SALES_DEPARTMENTS,2,'-')#
                            </cfif>
                    </cfif>       
                )TBL
            WHERE
                1=1

                    <cfif isdefined('attributes.SHIP_METHOD_ID') and len(attributes.SHIP_METHOD_ID)>
                        AND SHIP_METHOD_TYPE ='#attributes.SHIP_METHOD_ID#' 
                    </cfif>
                    <cfif len(attributes.zone_id)>    
                        AND (
                            COMPANY_ID IN 	
                                        (
                                            SELECT     
                                                COMPANY_ID
                                            FROM         
                                                #dsn_alias#.COMPANY
                                            WHERE     
                                                SALES_COUNTY IN
                                                                (
                                                                    SELECT     
                                                                        SZ_ID
                                                                    FROM          
                                                                        #dsn_alias#.SALES_ZONES
                                                                    WHERE      
                                                                        SZ_HIERARCHY LIKE '#attributes.zone_id#%'
                                                                ) 
                                        )
                            OR
                            CONSUMER_ID IN 	
                                        (
                                            SELECT     
                                                CONSUMER_ID
                                            FROM         
                                                #dsn_alias#.CONSUMER
                                            WHERE     
                                                SALES_COUNTY IN
                                                                (
                                                                    SELECT     
                                                                        SZ_ID
                                                                    FROM          
                                                                        #dsn_alias#.SALES_ZONES
                                                                    WHERE      
                                                                        SZ_HIERARCHY LIKE '#attributes.zone_id#%'
                                                                ) 
                                        )
                                        
                            )  
                    </cfif>
        </cfquery>
        <cfset 't_puan_#i#' = 0>
		<cfset 't_tutar_#i#' = 0>
        <cfset 't_tax_tutar_#i#' = 0>
		<cfoutput query="GET_SHIPPING">
        	<cfif isnumeric(SATIR_PUAN) and len(SATIR_PUAN)>
        		<cfset 't_puan_#i#' = Evaluate('t_puan_#i#' )+(SATIR_PUAN*quantity)>
            </cfif>
            <cfset 't_tutar_#i#' = Evaluate('t_tutar_#i#')+SATIR_NET_TOTAL>
            <cfset 't_tax_tutar_#i#' = Evaluate('t_tax_tutar_#i#')+SATIR_TAX_TOTAL>
        </cfoutput>
   	</cfloop>     
    <cfset arama_yapilmali = 0>
    <cfset attributes.totalrecords = GET_SHIPPING.recordcount>
<cfelse>
	<cfset arama_yapilmali = 1>
	<cfset get_order_list.recordcount = 0>
</cfif>
<cfquery name="get_department_name" datasource="#DSN#">
	SELECT 
		SL.LOCATION_ID,
		SL.COMMENT,
		D.DEPARTMENT_ID,
		D.DEPARTMENT_HEAD,
		D.BRANCH_ID
	FROM
		STOCKS_LOCATION SL,
		DEPARTMENT D
	WHERE 
		SL.DEPARTMENT_ID = D.DEPARTMENT_ID
		AND D.BRANCH_ID IN (SELECT BRANCH_ID FROM BRANCH WHERE COMPANY_ID = #session.ep.company_id#)
	ORDER BY
		D.DEPARTMENT_HEAD,
		SL.COMMENT
</cfquery>
<cfquery name="get_branch" datasource="#dsn#">
	SELECT BRANCH_ID,BRANCH_NAME FROM BRANCH WHERE COMPANY_ID = #session.ep.company_id# ORDER BY BRANCH_NAME
</cfquery>
<cfquery name="get_kur" datasource="#dsn#">
	SELECT (RATE2/RATE1) RATE,MONEY,RECORD_DATE FROM MONEY_HISTORY ORDER BY MONEY_HISTORY_ID DESC
</cfquery>
<cfquery name="get_city" datasource="#dsn#">
	SELECT CITY_NAME FROM SETUP_CITY ORDER BY CITY_NAME
</cfquery>
<cfquery name="GET_SHIP_METHOD" datasource="#DSN#">
	SELECT SHIP_METHOD_ID, SHIP_METHOD FROM SHIP_METHOD ORDER BY SHIP_METHOD
</cfquery>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
    	<cfform name="order_form" method="post" action="#request.self#?fuseaction=#attributes.fuseaction#">
        	<input name="form_varmi" id="form_varmi" value="1" type="hidden">
            <cf_box_search>
                <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
                	 <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="#attributes.keyword#">
               	</div>
                <div class="form-group">
                	<select name="zone_id" id="zone_id" style="width:160px;height:20px">
						<option value=""><cf_get_lang dictionary_id='57659.Satis Bölgesi'></option>
						<cfoutput query="sz">
							<option value="#SZ_HIERARCHY#" <cfif attributes.zone_id eq SZ_HIERARCHY>selected</cfif>>#sz_name#</option>
						</cfoutput>
					</select>
                </div>
                <div class="form-group">
                	<select name="branch_id" id="branch_id" style="width:110px;height:20px" title="Şube Seçilirse Sadece Sevk Talepleri Listelenecektir.">
                   		<option value=""><cf_get_lang dictionary_id='57453.Sube'></option>
                    	<cfoutput query="get_branch">
                        	<option value="#branch_id#" <cfif isdefined("attributes.branch_id") and branch_id eq attributes.branch_id>selected</cfif>>#branch_name#</option>
                      	</cfoutput>
                 	</select>
                </div>
                <div class="form-group">
                	<select name="listing_type" id="sort_type" style="width:130px;height:20px">
                    	<option value="1" <cfif attributes.listing_type eq 1>selected</cfif>><cf_get_lang dictionary_id='57708.Tümü'></option>
                      	<option value="2" <cfif attributes.listing_type eq 2>selected</cfif>><cf_get_lang dictionary_id='717.Sevk Planları'></option>
                     	<option value="3" <cfif attributes.listing_type eq 3>selected</cfif>><cf_get_lang dictionary_id='32034.Sevk Talepleri'></option>
               		</select>
                </div>
                <div class="form-group">
               		<select name="SHIP_METHOD_ID" id="SHIP_METHOD_ID">
                   		<option value=""><cf_get_lang dictionary_id='29500.Sevk Yöntemi'></option>
                    	<cfoutput query="GET_SHIP_METHOD">
                        	<option value="#SHIP_METHOD_ID#" <cfif isdefined("attributes.SHIP_METHOD_ID") and ListFind(attributes.SHIP_METHOD_ID,SHIP_METHOD_ID)>selected</cfif>>#SHIP_METHOD#</option>
                   		</cfoutput>
               		</select> 
                </div>
                <div class="form-group">
                	<select name="select_month" style="width:130px;height:20px">
                     	<option value="1" <cfif attributes.select_month eq '1'>selected</cfif>><cf_get_lang dictionary_id='57592.Ocak'></option>
                     	<option value="2" <cfif attributes.select_month eq '2'>selected</cfif>><cf_get_lang dictionary_id='57593.Şubat'></option>
                    	<option value="3" <cfif attributes.select_month eq '3'>selected</cfif>><cf_get_lang dictionary_id='57594.Mart'></option>
                     	<option value="4" <cfif attributes.select_month eq '4'>selected</cfif>><cf_get_lang dictionary_id='57595.Nisan'></option>
                      	<option value="5" <cfif attributes.select_month eq '5'>selected</cfif>><cf_get_lang dictionary_id='57596.Mayıs'></option>
                    	<option value="6" <cfif attributes.select_month eq '6'>selected</cfif>><cf_get_lang dictionary_id='57597.Haziran'></option>
                      	<option value="7" <cfif attributes.select_month eq '7'>selected</cfif>><cf_get_lang dictionary_id='57598.Temmuz'></option>
                     	<option value="8" <cfif attributes.select_month eq '8'>selected</cfif>><cf_get_lang dictionary_id='57599.Ağustos'></option>
                       	<option value="9" <cfif attributes.select_month eq '9'>selected</cfif>><cf_get_lang dictionary_id='57600.Eylül'></option>
                      	<option value="10" <cfif attributes.select_month eq '10'>selected</cfif>><cf_get_lang dictionary_id='57601.Ekim'></option>
                    	<option value="11" <cfif attributes.select_month eq '11'>selected</cfif>><cf_get_lang dictionary_id='57602.Kasım'></option>
                     	<option value="12" <cfif attributes.select_month eq '12'>selected</cfif>><cf_get_lang dictionary_id='57603.Aralık'></option>
                 	</select>
                </div>
             	
                <div class="form-group">
                	<cf_wrk_search_button search_function='input_control()' button_type="4">
             	</div>
           	</cf_box_search>
       	</cfform>
   	</cf_box>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id='58857.Sevkiyat İşlemleri'>&nbsp;&nbsp;(X 1000)</cfsavecontent>
    <cf_box title="#message#" hide_table_column="1">
    	<cf_grid_list sort="1">
        	<thead>
            	<tr height="35">
                    <th rowspan="2" style="width:100px"><cf_get_lang dictionary_id='57486.Kategori'></th>
                    <th colspan="<cfoutput>#son_gun#</cfoutput>" style="text-align:center"><cf_get_lang dictionary_id ='58672.Aylar'></th>
                    <th rowspan="2" style="width:110px"><cf_get_lang dictionary_id='57492.Toplam'></th>
                </tr>
                <tr height="10">
                    <cfloop from="1" to="#son_gun#" index="i">
                        <th style="text-align:center;width:60px"><cfoutput>#i#</cfoutput></th>
                    </cfloop>
                </tr>
            </thead>
            <tbody>
				<cfif isdefined("attributes.form_varmi")>
                    <cfoutput>
                    <tr>
                        <td><strong><cf_get_lang dictionary_id='58984.Puan'></strong></td>
                        <cfloop from="1" to="#son_gun#" index="i">
                            <td style="text-align:right">#Tlformat(Evaluate('t_puan_#i#'),2)#</td>
                            <cfset t_puan = t_puan + Evaluate('t_puan_#i#')>
                        </cfloop>
                        <td style="text-align:right"><strong>#Tlformat(t_puan,2)#</strong></td>            
                    </tr>
                    <tr>
                        <td><strong><cf_get_lang dictionary_id='57673.Tutar'></strong></td>
                        <cfloop from="1" to="#son_gun#" index="i">
                            <td style="text-align:right">#Tlformat(Evaluate('t_tutar_#i#')/1000,2)#</td>
                            <cfset t_tutar = t_tutar + Evaluate('t_tutar_#i#')>
                        </cfloop>
                        <td style="text-align:right"><strong>#Tlformat(t_tutar/1000,2)#</strong></td>            
                    </tr>
                    <tr>
                        <td><strong><cf_get_lang dictionary_id='57673.Tutar'>+<cf_get_lang dictionary_id='57639.KDV'></strong></td>
                        <cfloop from="1" to="#son_gun#" index="i">
                            <td style="text-align:right">#Tlformat(Evaluate('t_tax_tutar_#i#')/1000,2)#</td>
                            <cfset t_tax_tutar = t_tax_tutar + Evaluate('t_tax_tutar_#i#')>
                        </cfloop>
                        <td style="text-align:right"><strong>#Tlformat(t_tax_tutar/1000,2)#</strong></td>            
                    </tr>
                    </cfoutput>    
                    <tfoot>
                        <tr>
                            <cfset son_col = son_gun+2>
                            <td style="text-align:left; width:100%" colspan="<cfoutput>#son_col#</cfoutput>">
                                <cfset color_count = 0>
                                <cfset color_list = "gray,purple,fuchsia,green,lime,olive,yellow,gold,orange,blue,navy,teal,aqua">
                                <!--- Aylık --->
                                <cfchart show3d="yes" labelformat="number" pieslicestyle="solid" format="jpg" chartwidth="1600" chartheight="300" >
                                    <cfchartseries type="bar" itemcolumn="Sevk Planı Tutarı (KDV Dahil) * 1000" seriescolor="blue"> 
                                        <cfloop from="1" to="#son_gun#" index="i">
                                            <cfif isdefined('t_tax_tutar_#i#')>
                                                <cfchartdata item="#i#" value="#Evaluate('t_tax_tutar_#i#')/1000#">
                                            <cfelse>
                                                <cfchartdata item="#i#" value="0">
                                            </cfif>
                                        </cfloop>
                                    </cfchartseries>
                                </cfchart>
                                <!--- //Aylık --->
                            </td>     
                        </tr>
                    </tfoot>
                <cfelse>
                    <tr>
                        <td colspan="14"><cfif arama_yapilmali neq 1><cf_get_lang dictionary_id='57484.Kayit Yok'>!<cfelse><cf_get_lang dictionary_id='57701.Filtre Ediniz '>!</cfif></td>
                    </tr>
                </cfif>	
            </tbody>
		</cf_grid_list>
   	</cf_box>
</div>
<script language="javascript">
	function input_control()
		{
			if(document.all.branch_id.value !='' && document.all.listing_type.value ==2)
			{
				alert('<cf_get_lang dictionary_id='748.Liste Tipi Olarak Sevk Planları İle Şubeyi Birlikte Seçemezsiniz'>!!!.');
				return false
			}
			else
			{
				return true
			}
		}
</script>