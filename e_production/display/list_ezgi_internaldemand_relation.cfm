<!---
    File: list_ezgi_internaldemand_relation.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---Ezgi Bilgisayar E-Furniture Malzeme İç Talep Karşılama Kontrol Raporu--->
<cfquery name="get_internald_info_group" datasource="#dsn3#">
	SELECT
		I.SUBJECT,
		I.INTERNAL_NUMBER,
		I.INTERNAL_ID
	FROM
		INTERNALDEMAND I
	WHERE
		I.REF_NO = '#attributes.subject#'
	GROUP BY
		I.SUBJECT,
		I.INTERNAL_NUMBER,
		I.INTERNAL_ID
</cfquery>
<!---<cfdump expand="yes" var="#attributes#">
<cfdump expand="yes" var="#get_internald_info_group#">
<cfabort>--->
<cfsavecontent variable="ic_talep_form"><cf_get_lang dictionary_id='3281.Malzeme İç Talep Karşılama Kontrol Raporu'></cfsavecontent>
<cf_medium_list_search title="#ic_talep_form#">
	<cf_medium_list_search_area>
		<table>
            <tr>
            <!-- sil --><td><cf_workcube_file_action pdf='1' mail='1' doc='1' print='1'></td><!-- sil -->
            </tr>
		</table>
	</cf_medium_list_search_area>
</cf_medium_list_search>
	<cf_medium_list>
		<thead>
			<tr>
            	<th><cf_get_lang dictionary_id='43583.İç Talep No'></th>
				<th><cf_get_lang dictionary_id='57657.Ürün'></th>
				<th width="70" style="text-align:right;"><cf_get_lang dictionary_id='57635.Miktar'></th>
				<th><cf_get_lang dictionary_id='57636.Birim'></th>
				<th style="text-align:right;"><cf_get_lang dictionary_id='57611.Sipariş'></th>
				<th><cf_get_lang dictionary_id='58444.Kalan'></th>
				<th style="text-align:right;"><cf_get_lang dictionary_id='57773.İrsaliye'></th>
				<th><cf_get_lang dictionary_id='58444.Kalan'></th>
			</tr>
		</thead>
		<tbody>
		<cfoutput query="get_internald_info_group">
            <cfquery name="get_internald_info" datasource="#dsn3#">
                SELECT
                    SUM(IR.QUANTITY) AS QUANTITY,
                    IR.PRODUCT_NAME,
                    IR.STOCK_ID,
                    IR.UNIT,
                    ISNULL(IR.SPECT_VAR_ID,0) AS SPECT_VAR_ID, 
                    I.SUBJECT,
                    I.INTERNAL_NUMBER,
                    I.INTERNAL_ID,
                    IR.WRK_ROW_ID
                FROM
                    INTERNALDEMAND I,
                    INTERNALDEMAND_ROW IR
                WHERE
                    I.INTERNAL_ID = IR.I_ID
                    AND I.INTERNAL_ID= #get_internald_info_group.INTERNAL_ID#
                GROUP BY
                    IR.PRODUCT_NAME,
                    IR.STOCK_ID,
                    IR.UNIT,
                    ISNULL(IR.SPECT_VAR_ID,0), 
                    I.SUBJECT,
                    I.INTERNAL_NUMBER,
                    I.INTERNAL_ID,
                    IR.WRK_ROW_ID
            </cfquery>
        	<cfquery name="get_internald_info2" dbtype="query">
                SELECT
                    SUM(QUANTITY) AS QUANTITY,
                    PRODUCT_NAME,
                    STOCK_ID,
                    UNIT,
                    SPECT_VAR_ID, 
                    SUBJECT,
                    INTERNAL_NUMBER,
                    INTERNAL_ID
                FROM
                    get_internald_info
                GROUP BY
                    PRODUCT_NAME,
                    STOCK_ID,
                    UNIT,
                    SPECT_VAR_ID, 
                    SUBJECT,
                    INTERNAL_NUMBER,
                    INTERNAL_ID
            </cfquery>
            <cfset order_id_list = ''>
			<cfset order_id_write_list = ''>
            <cfset ship_id_list = ''>
            <cfset ship_id_write_list = ''>
            <cfset order_wrk_id_list = ''>
            <cfquery name="get_period_info" datasource="#dsn#">
                SELECT PERIOD_YEAR,PERIOD_ID FROM SETUP_PERIOD WHERE OUR_COMPANY_ID = #session.ep.company_id#
            </cfquery>
            <cfloop query="get_internald_info">
				<!--- Bağlantılı Sipariş --->
                <cfquery name="get_order_relation" datasource="#dsn3#">
                    SELECT
                        O.ORDER_ID,
                        O.ORDER_NUMBER,
                        ORR.STOCK_ID,
                        SUM(ORR.QUANTITY) QUANTITY
                    FROM 
                        ORDERS O,
                        ORDER_ROW ORR
                    WHERE 
                        O.ORDER_ID = ORR.ORDER_ID AND
                        ORR.WRK_ROW_RELATION_ID = '#get_internald_info.WRK_ROW_ID#'
                    GROUP BY
                        O.ORDER_ID,
                        O.ORDER_NUMBER,
                        ORR.STOCK_ID
                    UNION ALL
                    SELECT
                        O.ORDER_ID,
                        O.ORDER_NUMBER,
                        ORR.STOCK_ID,
                        SUM(ORR.QUANTITY) QUANTITY
                    FROM 
                        ORDERS O,
                        ORDER_ROW ORR,
                        OFFER_ROW OFR
                    WHERE 
                        O.OFFER_ID = OFR.OFFER_ID AND
                        ORR.WRK_ROW_RELATION_ID = OFR.WRK_ROW_ID AND
                        OFR.WRK_ROW_RELATION_ID = '#get_internald_info.WRK_ROW_ID#'
                    GROUP BY
                        O.ORDER_ID,
                        O.ORDER_NUMBER,
                        ORR.STOCK_ID
                    UNION ALL
                    SELECT
                        O.ORDER_ID,
                        O.ORDER_NUMBER,
                        ORR.STOCK_ID,
                        SUM(ORR.QUANTITY) QUANTITY
                    FROM 
                        INTERNALDEMAND I,
                        INTERNALDEMAND_ROW IR,
                        OFFER OO,
                        OFFER_ROW OFR,
                        ORDERS O,
                        ORDER_ROW ORR
                    WHERE 
                        OO.OFFER_ID = OFR.OFFER_ID AND
                        I.INTERNAL_ID = IR.I_ID AND
                        O.ORDER_ID = ORR.ORDER_ID AND
                        IR.WRK_ROW_ID = OFR.WRK_ROW_RELATION_ID AND
                        OFR.WRK_ROW_ID = ORR.WRK_ROW_RELATION_ID AND
                        IR.WRK_ROW_RELATION_ID = '#get_internald_info.WRK_ROW_ID#'
                    GROUP BY
                        O.ORDER_ID,
                        O.ORDER_NUMBER,
                        ORR.STOCK_ID
                    UNION ALL
                    SELECT
                        O.ORDER_ID,
                        O.ORDER_NUMBER,
                        ORR.STOCK_ID,
                        SUM(ORR.QUANTITY) QUANTITY
                    FROM 
                        INTERNALDEMAND I,
                        INTERNALDEMAND_ROW IR,
                        OFFER OO,
                        OFFER_ROW OFR,
                        OFFER OO2,
                        OFFER_ROW OFR2,
                        ORDERS O,
                        ORDER_ROW ORR
                    WHERE 
                        OO.OFFER_ID = OFR.OFFER_ID AND
                        OO2.OFFER_ID = OFR2.OFFER_ID AND
                        I.INTERNAL_ID = IR.I_ID AND
                        O.ORDER_ID = ORR.ORDER_ID AND
                        IR.WRK_ROW_ID = OFR.WRK_ROW_RELATION_ID AND
                        OFR.WRK_ROW_ID = OFR2.WRK_ROW_RELATION_ID AND
                        OFR2.WRK_ROW_ID = ORR.WRK_ROW_RELATION_ID AND
                        IR.WRK_ROW_RELATION_ID = '#get_internald_info.WRK_ROW_ID#'
                    GROUP BY
                        O.ORDER_ID,
                        O.ORDER_NUMBER,
                        ORR.STOCK_ID
                    UNION ALL
                    SELECT
                        O.ORDER_ID,
                        O.ORDER_NUMBER,
                        ORR.STOCK_ID,
                        SUM(ORR.QUANTITY) QUANTITY
                    FROM 
                        OFFER OO,
                        OFFER_ROW OFR,
                        OFFER OO2,
                        OFFER_ROW OFR2,
                        ORDERS O,
                        ORDER_ROW ORR
                    WHERE 
                        OO.OFFER_ID = OFR.OFFER_ID AND
                        OO2.OFFER_ID = OFR2.OFFER_ID AND
                        O.ORDER_ID = ORR.ORDER_ID AND
                        OFR.WRK_ROW_ID = OFR2.WRK_ROW_RELATION_ID AND
                        OFR2.WRK_ROW_ID = ORR.WRK_ROW_RELATION_ID AND
                        OFR.WRK_ROW_RELATION_ID = '#get_internald_info.WRK_ROW_ID#'
                    GROUP BY
                        O.ORDER_ID,
                        O.ORDER_NUMBER,
                        ORR.STOCK_ID
                </cfquery>
                <cfquery name="get_order_relation2" datasource="#dsn3#">
                    SELECT
                        ORR.WRK_ROW_ID
                    FROM 
                        ORDERS O,
                        ORDER_ROW ORR
                    WHERE 
                        O.ORDER_ID = ORR.ORDER_ID AND
                        ORR.WRK_ROW_RELATION_ID = '#get_internald_info.WRK_ROW_ID#'
                    UNION ALL
                    SELECT
                        ORR.WRK_ROW_ID
                    FROM 
                        ORDERS O,
                        ORDER_ROW ORR,
                        OFFER_ROW OFR
                    WHERE 
                        O.OFFER_ID = OFR.OFFER_ID AND
                        ORR.WRK_ROW_RELATION_ID = OFR.WRK_ROW_ID AND
                        OFR.WRK_ROW_RELATION_ID = '#get_internald_info.WRK_ROW_ID#'
                    UNION ALL
                    SELECT
                        ORR.WRK_ROW_ID
                    FROM 
                        INTERNALDEMAND I,
                        INTERNALDEMAND_ROW IR,
                        OFFER OO,
                        OFFER_ROW OFR,
                        ORDERS O,
                        ORDER_ROW ORR
                    WHERE 
                        OO.OFFER_ID = OFR.OFFER_ID AND
                        I.INTERNAL_ID = IR.I_ID AND
                        O.ORDER_ID = ORR.ORDER_ID AND
                        IR.WRK_ROW_ID = OFR.WRK_ROW_RELATION_ID AND
                        OFR.WRK_ROW_ID = ORR.WRK_ROW_RELATION_ID AND
                        IR.WRK_ROW_RELATION_ID = '#get_internald_info.WRK_ROW_ID#'
                    UNION ALL
                    SELECT
                        ORR.WRK_ROW_ID
                    FROM 
                        INTERNALDEMAND I,
                        INTERNALDEMAND_ROW IR,
                        OFFER OO,
                        OFFER_ROW OFR,
                        OFFER OO2,
                        OFFER_ROW OFR2,
                        ORDERS O,
                        ORDER_ROW ORR
                    WHERE 
                        OO.OFFER_ID = OFR.OFFER_ID AND
                        OO2.OFFER_ID = OFR2.OFFER_ID AND
                        I.INTERNAL_ID = IR.I_ID AND
                        O.ORDER_ID = ORR.ORDER_ID AND
                        IR.WRK_ROW_ID = OFR.WRK_ROW_RELATION_ID AND
                        OFR.WRK_ROW_ID = OFR2.WRK_ROW_RELATION_ID AND
                        OFR2.WRK_ROW_ID = ORR.WRK_ROW_RELATION_ID AND
                        IR.WRK_ROW_RELATION_ID = '#get_internald_info.WRK_ROW_ID#'
                    UNION ALL
                    SELECT
                        ORR.WRK_ROW_ID
                    FROM 
                        OFFER OO,
                        OFFER_ROW OFR,
                        OFFER OO2,
                        OFFER_ROW OFR2,
                        ORDERS O,
                        ORDER_ROW ORR
                    WHERE 
                        OO.OFFER_ID = OFR.OFFER_ID AND
                        OO2.OFFER_ID = OFR2.OFFER_ID AND
                        O.ORDER_ID = ORR.ORDER_ID AND
                        OFR.WRK_ROW_ID = OFR2.WRK_ROW_RELATION_ID AND
                        OFR2.WRK_ROW_ID = ORR.WRK_ROW_RELATION_ID AND
                        OFR.WRK_ROW_RELATION_ID = '#get_internald_info.WRK_ROW_ID#'
                </cfquery>
                <cfloop query="get_order_relation">
                    <cfset order_id_list=listappend(order_id_list,'#ORDER_ID#;#ORDER_NUMBER#;#STOCK_ID#;#QUANTITY#')>
                    <cfset order_id_write_list=listappend(order_id_write_list,'#ORDER_ID#;#ORDER_NUMBER#')>
                    <cfset order_id_write_list = listdeleteduplicates(order_id_write_list)>
                </cfloop>
                <cfloop query="get_order_relation2">
                    <cfset order_wrk_id_list=listappend(order_wrk_id_list,'#get_order_relation2.WRK_ROW_ID#')>
                </cfloop>
                <!--- Bağlantılı Sipariş --->
          	</cfloop>
            <!--- Bağlantılı İrsaliyeler --->
			<cfif len(order_wrk_id_list)>
                <cfquery name="get_ship_relation" datasource="#dsn2#">
                    SELECT
                        SUM(SHIP_AMOUNT) SHIP_AMOUNT,
                        PERIOD_ID,
                        SHIP_ID,
                        SHIP_NUMBER,
                        STOCK_ID
                    FROM
                    (
                        SELECT
                            T1.SHIP_ID,
                            T1.SHIP_NUMBER,
                            T1.STOCK_ID,
                            SUM(T1.AMOUNT) AS SHIP_AMOUNT,
                            #session.ep.period_id# PERIOD_ID
                        FROM
                            (SELECT DISTINCT
                                S.SHIP_ID,
                                S.SHIP_NUMBER,
                                SR.STOCK_ID,
                                SR.AMOUNT,
                                #get_period_info.PERIOD_ID# PERIOD_ID
                            FROM
                                #dsn2_alias#.SHIP S,
                                #dsn2_alias#.SHIP_ROW SR,
                                #dsn3_alias#.INTERNALDEMAND_RELATION_ROW IRR
                            WHERE
                                S.SHIP_ID = SR.SHIP_ID
                                AND IRR.TO_SHIP_ID = SR.SHIP_ID
                                AND ISNULL(S.IS_SHIP_IPTAL,0)=0
                                AND IRR.INTERNALDEMAND_ID = #get_internald_info_group.INTERNAL_ID#
                            ) T1
                        GROUP BY
                            T1.SHIP_ID,
                            T1.SHIP_NUMBER,
                            T1.STOCK_ID
                        UNION ALL
                        <cfloop from="1" to="#listlen(order_wrk_id_list)#" index="kk">	
                            <cfloop query="get_period_info">
                                <cfset new_dsn2 = "#dsn#_#get_period_info.period_year#_#session.ep.company_id#">
                                    SELECT
                                        S.SHIP_ID,
                                        S.SHIP_NUMBER,
                                        SR.STOCK_ID,
                                        SUM(SR.AMOUNT) AS SHIP_AMOUNT,
                                        #get_period_info.PERIOD_ID# PERIOD_ID
                                    FROM
                                        #new_dsn2#.dbo.SHIP S,
                                        #new_dsn2#.dbo.SHIP_ROW SR
                                    WHERE
                                        S.SHIP_ID = SR.SHIP_ID
                                        AND SR.WRK_ROW_RELATION_ID = '#listgetat(order_wrk_id_list,kk)#'
                                        AND ISNULL(S.IS_SHIP_IPTAL,0)=0
                                    GROUP BY
                                        S.SHIP_ID,
                                        S.SHIP_NUMBER,
                                        SR.STOCK_ID
                                    UNION ALL
                                    SELECT
                                        S.SHIP_ID,
                                        S.SHIP_NUMBER,
                                        SR.STOCK_ID,
                                        SUM(SR.AMOUNT) AS SHIP_AMOUNT,
                                        #get_period_info.PERIOD_ID# PERIOD_ID
                                    FROM
                                        #new_dsn2#.dbo.SHIP S,
                                        #new_dsn2#.dbo.SHIP_ROW SR,
                                        #new_dsn2#.dbo.INVOICE_ROW IR
                                    WHERE
                                        S.SHIP_ID = SR.SHIP_ID
                                        AND IR.WRK_ROW_RELATION_ID = '#listgetat(order_wrk_id_list,kk)#'
                                        AND IR.WRK_ROW_ID = SR.WRK_ROW_RELATION_ID
                                        AND ISNULL(S.IS_SHIP_IPTAL,0)=0
                                    GROUP BY
                                        S.SHIP_ID,
                                        S.SHIP_NUMBER,
                                        SR.STOCK_ID
                                <cfif get_period_info.recordcount neq get_period_info.currentrow>UNION ALL</cfif>
                            </cfloop>
                            <cfif kk neq listlen(order_wrk_id_list)>UNION ALL</cfif>
                        </cfloop>
                    )T1
                    GROUP BY
                        PERIOD_ID,
                        SHIP_ID,
                        SHIP_NUMBER,
                        STOCK_ID
                </cfquery>
                <cfloop query="get_ship_relation">
                    <cfset ship_id_list=listappend(ship_id_list,'#SHIP_ID#;#SHIP_NUMBER#;#STOCK_ID#;#SHIP_AMOUNT#;#PERIOD_ID#')>
                    <cfset ship_id_write_list=listappend(ship_id_write_list,'#SHIP_ID#;#SHIP_NUMBER#;#PERIOD_ID#')>
                    <cfset ship_id_write_list = listdeleteduplicates(ship_id_write_list)>
                </cfloop>
            <cfelse>
                <cfquery name="get_ship_relation" datasource="#dsn2#">
                    SELECT
                        SUM(SHIP_AMOUNT) SHIP_AMOUNT,
                        PERIOD_ID,
                        SHIP_ID,
                        SHIP_NUMBER,
                        STOCK_ID
                    FROM
                    (
                        SELECT
                            T1.SHIP_ID,
                            T1.SHIP_NUMBER,
                            T1.STOCK_ID,
                            SUM(T1.AMOUNT) AS SHIP_AMOUNT,
                            #session.ep.period_id# PERIOD_ID
                        FROM
                            (SELECT DISTINCT
                                S.SHIP_ID,
                                S.SHIP_NUMBER,
                                SR.STOCK_ID,
                                SR.AMOUNT,
                                #get_period_info.PERIOD_ID# PERIOD_ID
                            FROM
                                #dsn2_alias#.SHIP S,
                                #dsn2_alias#.SHIP_ROW SR,
                                #dsn3_alias#.INTERNALDEMAND_RELATION_ROW IRR
                            WHERE
                                S.SHIP_ID = SR.SHIP_ID
                                AND IRR.TO_SHIP_ID = SR.SHIP_ID
                                AND ISNULL(S.IS_SHIP_IPTAL,0)=0
                                AND IRR.INTERNALDEMAND_ID = #get_internald_info_group.INTERNAL_ID#
                            ) T1
                        GROUP BY
                            T1.SHIP_ID,
                            T1.SHIP_NUMBER,
                            T1.STOCK_ID
                    )T1
                    GROUP BY
                        PERIOD_ID,
                        SHIP_ID,
                        SHIP_NUMBER,
                        STOCK_ID
                </cfquery>
                <cfloop query="get_ship_relation">
                    <cfset ship_id_list=listappend(ship_id_list,'#SHIP_ID#;#SHIP_NUMBER#;#STOCK_ID#;#SHIP_AMOUNT#;#PERIOD_ID#')>
                    <cfset ship_id_write_list=listappend(ship_id_write_list,'#SHIP_ID#;#SHIP_NUMBER#;#PERIOD_ID#')>
                    <cfset ship_id_write_list = listdeleteduplicates(ship_id_write_list)>
                </cfloop>
            </cfif>
        	<!--- Bağlantılı İrsaliyeler --->
            <cfif get_internald_info2.recordcount>
        	<cfloop query="get_internald_info2">
                <tr>
                    <td>
                        <a href="#request.self#?fuseaction=objects.popup_list_internaldemand_relation&internaldemand_id=#INTERNAL_ID#" target="_blank" style="color:##6699FF">#internal_number#</a>
                    </td>
                    <td>#product_name#</td>
                    <td style="text-align:right">#tlformat(quantity)#</td>
                    <td>#unit#</td>
                    <cfset total_amount_ = 0>
                    <cfif len(order_id_write_list)>
                        <cfloop list="#order_id_write_list#" index="i">
                            <cfset act_id = listgetat(i,1,';')>
                            <cfset amount_new = 0>
                            <cfloop list="#order_id_list#" index="j">
                                <cfset order_id_ = listgetat(j,1,';')>
                                <cfset stock_id_ = listgetat(j,3,';')>
                                <cfset amount_ = listgetat(j,4,';')>
                                <cfif order_id_ eq act_id and get_internald_info2.stock_id eq stock_id_>
                                    <cfset amount_new = amount_new + amount_>
                                    <cfset total_amount_ = total_amount_ + amount_>
                                </cfif>
                            </cfloop>
                        </cfloop>
                    </cfif>
                    <td style="text-align:right;">#tlformat(total_amount_)#</td>
                    <td style="text-align:right">#tlformat(quantity-total_amount_)#</td>
                    <cfset total_amount_ = 0>
                    <cfif len(ship_id_write_list)>
                        <cfloop list="#ship_id_write_list#" index="i">
                            <cfset act_id = listgetat(i,1,';')>
                            <cfset act_period_id = listgetat(i,3,';')>
                            <cfset amount_new = 0>
                            <cfloop list="#ship_id_list#" index="j">
                                <cfset ship_id_ = listgetat(j,1,';')>
                                <cfset ship_period_id_ = listgetat(j,5,';')>
                                <cfset stock_id_ = listgetat(j,3,';')>
                                <cfset amount_ = listgetat(j,4,';')>
                                <cfif ship_id_ eq act_id and get_internald_info2.stock_id eq stock_id_ and act_period_id eq ship_period_id_>
                                    <cfset amount_new = amount_new + amount_>
                                    <cfset total_amount_ = total_amount_ + amount_>
                                </cfif>
                            </cfloop>
                        </cfloop>
                    </cfif>
                    <td style="text-align:right;">#tlformat(total_amount_)#</td>
                    <td style="text-align:right">#tlformat(quantity-total_amount_)#</td>
                </tr>
            </cfloop>
            <cfelse>
            	<tfoot>
                	<tr><td style="height:3px" colspan="8"><cf_get_lang dictionary_id='479.İlişkili İç Talep Bulunamadı.'></td></tr>
                </tfoot>
            </cfif>
            
		</cfoutput>
	</tbody>
	</cf_medium_list>
