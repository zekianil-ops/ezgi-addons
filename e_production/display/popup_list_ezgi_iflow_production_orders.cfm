<!---
    File: popup_list_ezgi_iflow_production_orders.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/06/2023
    Description:
--->
<cfset toplam = 0>
<cfsetting showdebugoutput="no">
<cfif isdefined('attributes.bugun') and isdate(attributes.bugun)>
	<cf_date tarih="attributes.bugun">
</cfif>
<cfparam name="attributes.modal_id" default="">
<cfquery name="GET_PRODUCTION" datasource="#DSN3#">
    SELECT 
    	  ISNULL((SELECT TOP (1) QUANTITY - ISNULL(RESULT_AMOUNT,0) AS KALAN FROM PRODUCTION_ORDERS WHERE PO_RELATED_ID IS NULL AND LOT_NO = E.LOT_NO ORDER BY RESULT_AMOUNT DESC),0) AS KALAN ,
        E.ACTION_TYPE, 
        E.PRODUCT_TYPE, 
        S.PRODUCT_ID, 
        S.PRODUCT_NAME, 
        S.PRODUCT_CODE, 
        E.STOCK_ID, 
        E.QUANTITY, 
        P.MAIN_UNIT AS UNIT, 
        E.SPECT_MAIN_ID, 
        EIM.MASTER_PLAN_FINISH_DATE, 
        EIM.MASTER_PLAN_STATUS, 
        EIM.MASTER_PLAN_DETAIL
    FROM     
        EZGI_IFLOW_PRODUCTION_ORDERS AS E WITH (NOLOCK) INNER JOIN
        STOCKS AS S WITH (NOLOCK) ON E.STOCK_ID = S.STOCK_ID INNER JOIN
        PRODUCT_UNIT AS P WITH (NOLOCK) ON S.PRODUCT_ID = P.PRODUCT_ID INNER JOIN
        EZGI_IFLOW_MASTER_PLAN AS EIM WITH (NOLOCK) ON E.MASTER_PLAN_ID = EIM.MASTER_PLAN_ID INNER JOIN
      	#dsn_alias#.SETUP_SHIFTS AS SS ON EIM.MASTER_PLAN_CAT_ID = SS.SHIFT_ID
    WHERE  
        EIM.MASTER_PLAN_STATUS = 1 AND 
        E.STOCK_ID = #attributes.stock_id# AND 
        ISNULL((
                SELECT 
                    IS_STAGE
                FROM      
                    EZGI_IFLOW_PRODUCTION_ORDER_LOT_NO_STAGE WITH (NOLOCK)
                WHERE   
                    IFLOW_P_ORDER_ID = E.IFLOW_P_ORDER_ID
      	), 4) <> 2  
      	<cfif isdefined('attributes.sonraki_ay') and len(attributes.sonraki_ay) and isdefined('attributes.sonraki_sene') and len(attributes.sonraki_sene)>
            AND MONTH(EIM.MASTER_PLAN_FINISH_DATE) = #attributes.sonraki_ay#
            AND YEAR(EIM.MASTER_PLAN_FINISH_DATE) = #attributes.sonraki_sene#
      	</cfif>
        <cfif isdefined('attributes.sonraki_gun') and len(attributes.sonraki_gun)>
        	 AND DAY(EIM.MASTER_PLAN_FINISH_DATE) = #attributes.sonraki_gun#
        </cfif>
        <cfif isdefined('attributes.bugun') and len(attributes.bugun)>
        	AND EIM.MASTER_PLAN_FINISH_DATE < #DateAdd('d',1,attributes.bugun)#
        </cfif>
        <cfif isdefined('attributes.spect_main_id') and Len(attributes.spect_main_id)>
            AND E.SPECT_MAIN_ID = #attributes.spect_main_id#
        </cfif>
        <cfif isdefined('attributes.department_id') and listLen(attributes.department_id)>
            AND   
            (
                <cfloop from="1" to="#listlen(attributes.department_id)#" index="k">
                    SS.DEPARTMENT_ID = #ListGetAt(ListGetAt(attributes.department_id,k),1,'-')#
                    <cfif k neq listlen(attributes.department_id)>OR</cfif>
                </cfloop>
            )
        </cfif>
  	ORDER BY
    	EIM.MASTER_PLAN_FINISH_DATE DESC
</cfquery>

<cfsavecontent variable="ezgi_head">
	<cf_get_lang dictionary_id='649.Üretim Emirleri'> : <cfoutput>#GET_PRODUCTION.PRODUCT_NAME#</cfoutput>
</cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#ezgi_head#" scroll="1" collapsable="1" resize="1" popup_box="#iif(isdefined("attributes.draggable"),1,0)#">
        <cf_grid_list>
        	<thead>
				<tr>
                	<th width="30"><cf_get_lang dictionary_id='58577.Sıra'></th>
                    <th width="70"><cf_get_lang dictionary_id='36469.Üretim tarihi'></th>
                    <th><cf_get_lang dictionary_id='40720.Üretim Programı'></th>
                    <th width="70"><cf_get_lang dictionary_id='49884.Üretim Emri'></th>
                    <th width="70"><cf_get_lang dictionary_id='36608.Üretilen'></th>
                    <th width="70"><cf_get_lang dictionary_id='58444.Kalan'></th>
                    <th width="40"><cf_get_lang dictionary_id='57636.Birim'></th>
              	</tr>
          	</thead>
            <tbody>
            	<cfif GET_PRODUCTION.recordcount>
                	<cfoutput query="GET_PRODUCTION">
                    	<tr>
                        	<td style=" height:20px; text-align:right">#currentrow#</td>
                            <td style=" text-align:center">#DateFormat(MASTER_PLAN_FINISH_DATE, dateformat_style)#</td>
                            <td style="text-align:left">#MASTER_PLAN_DETAIL#</td>
                            <td style="text-align:right">#TlFormat(QUANTITY,1)#</td>
                            <td style="text-align:right">#TlFormat(QUANTITY-KALAN,1)#</td>
                            <td style="text-align:right">#TlFormat(KALAN,1)#</td>
                            <td style="text-align:left">#UNIT#</td>
                    	</tr>
                        <cfset toplam = toplam +KALAN>
                  	</cfoutput>
              	</cfif>        
            </tbody>
            <tfoot>
            	<cfoutput>
            	<tr style="font-weight:bold">
                	<td colspan="5">Toplam</td>
                    <td style="text-align:right">#TlFormat(toplam,1)#</td>
                	<td style="text-align:left">#GET_PRODUCTION.UNIT#</td>
                </tr>
                </cfoutput>
            </tfoot>
       	</cf_grid_list>
	</cf_box>
</div>