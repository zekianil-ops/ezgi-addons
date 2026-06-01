<cfparam name="attributes.keyword" default=''>
<cfparam name="attributes.page" default=1>
<cfparam name="attributes.is_form_submitted" default="1">
<cfset s_toplam = 0>
<cfset t_toplam = 0>
<cfif isdefined('attributes.branch_id') and len(attributes.branch_id)>
    <cfquery name="get_department" datasource="#dsn#">
        SELECT 
        	DEPARTMENT_ID 
       	FROM 
        	DEPARTMENT 
       	WHERE 
        	BRANCH_ID = #attributes.branch_id# AND IS_STORE = 3
    </cfquery>
	<cfset department_id_list = Valuelist(get_department.DEPARTMENT_ID)>
<cfelse>
	<cfset department_id_list = ''>
</cfif>
<cfquery name="get_product_name" datasource="#dsn3#">
	SELECT     
        PRODUCT_NAME
	FROM         
    	STOCKS
	WHERE     
    	STOCK_ID = #attributes.sid#
</cfquery>
<cfif isdefined("attributes.is_form_submitted")>
	<cfquery name="get_internaldemand_list" datasource="#DSN3#">
		SELECT  
        	ORR.QUANTITY AS AMOUNT, 
            ORR.STOCK_ID, 
            ORR.UNIT,
            S.PRODUCT_NAME, 
            S.PRODUCT_CODE, 
            S.PRODUCT_ID, 
            SI.SHIP_RESULT_INTERNALDEMAND_ID, 
            SI.OUT_DATE, 
            SI.LOCATION_ID, 
            SI.DEPARTMENT_ID,
            SI.DEPARTMENT_IN_ID, 
       		SI.LOCATION_IN_ID,
            TBL.DEPO
        FROM  
        	EZGI_SHIP_RESULT_INTERNALDEMAND AS SI WITH (NOLOCK) INNER JOIN
         	EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS SIR WITH (NOLOCK) ON SI.SHIP_RESULT_INTERNALDEMAND_ID= SIR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
          	ORDER_ROW AS ORR WITH (NOLOCK) ON ORR.ORDER_ROW_ID = SIR.ORDER_ROW_ID INNER JOIN
         	STOCKS AS S ON ORR.STOCK_ID = S.STOCK_ID LEFT OUTER JOIN
         	(
            	SELECT        
                	D.DEPARTMENT_ID, 
                    SL.LOCATION_ID, 
                    D.DEPARTMENT_HEAD + '-' + SL.COMMENT AS DEPO
             	FROM            
                	#dsn_alias#.DEPARTMENT AS D INNER JOIN
                	#dsn_alias#.STOCKS_LOCATION AS SL ON D.DEPARTMENT_ID = SL.DEPARTMENT_ID
          	) AS TBL ON SI.DEPARTMENT_IN_ID = TBL.DEPARTMENT_ID AND SI.LOCATION_IN_ID = TBL.LOCATION_ID LEFT OUTER JOIN
        	#dsn2_alias#.SHIP AS SH ON SI.SHIP_RESULT_INTERNALDEMAND_ID = SH.DISPATCH_SHIP_ID
        WHERE
        	S.PRODUCT_STATUS=1 AND
            SH.SHIP_ID IS NULL
            <cfif isdefined('attributes.sid') and Len(attributes.sid)>
                AND S.STOCK_ID = #attributes.sid#
            </cfif>
            <cfif len(attributes.keyword)>
                AND TBL.DEPO LIKE '%#attributes.keyword#%'
    		</cfif> 
            <cfif isdefined('attributes.department_id') and listLen(attributes.department_id)>
                AND   
                 	(
                      	<cfloop from="1" to="#listlen(attributes.department_id)#" index="k">
                           	SI.DEPARTMENT_ID = #ListGetAt(ListGetAt(attributes.department_id,k),1,'-')# AND 
                       		SI.LOCATION_ID = #ListGetAt(ListGetAt(attributes.department_id,k),2,'-')#
                        	<cfif k neq listlen(attributes.department_id)>OR</cfif>
                   		</cfloop>
                	)
         	</cfif>
            <cfif Listlen(department_id_list)>
            	AND SI.DEPARTMENT_ID IN (#department_id_list#)
            </cfif>
	</cfquery>
    <cfif get_internaldemand_list.recordcount>
    	<cfoutput query="get_internaldemand_list">
        	<cfset t_toplam = t_toplam + AMOUNT>
        </cfoutput>
    </cfif>
<cfelse>
	<cfset get_internaldemand_list.recordcount =0>
</cfif>
<!---<cfdump expand="yes" var="#get_internaldemand_list#">
<cfabort>--->
<cfparam name="attributes.maxrows" default='#session.ep.maxrows#'>
<cfparam name="attributes.totalrecords" default=#get_internaldemand_list.recordcount#>
<cfset attributes.startrow=((attributes.page-1)*attributes.maxrows)+1>

<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    <cf_box scroll="0">
   	  	<cfform action="#request.self#?fuseaction=prod.popup_dsp_ezgi_production_internaldemand" method="post">
			<cfif isdefined('attributes.branch_id')>
            	<cfinput type="hidden" name="branch_id" value="#attributes.branch_id#">
            </cfif>
			<cfif isdefined('attributes.department_id')>
            	<cfinput type="hidden" name="department_id" value="#attributes.department_id#">
            </cfif>
            <cfinput type="hidden" name="is_form_submitted" value="1">
            <cfinput type="hidden" name="sid" value="#attributes.sid#">      	
    		<cf_box_search>
                <cfsavecontent variable="filter"><cf_get_lang dictionary_id='57460.Filtre'></cfsavecontent>
                <div class="form-group">
               	  <cfinput type="text" style="width:150px;" placeholder="#filter#" maxlength="50" name="keyword" value="">
               	</div>
                <div class="form-group small">
                 	<cfsavecontent variable="message"><cf_get_lang dictionary_id='57537.Kayıt Sayısı Hatalı!'></cfsavecontent>
                 	<cfinput type="text" name="maxrows" value="#attributes.maxrows#" validate="integer" range="1,1250" required="yes" message="#message#">
            	</div>
               	<div class="form-group">
                	<cf_wrk_search_button search_function='input_control()' button_type="4">
             	</div>
          	</cf_box_search>
      </cfform>
   	</cf_box>
    <cfsavecontent variable="message"><cf_get_lang dictionary_id="32034.Sevk Talepleri"></cfsavecontent>
    <cf_box title="#message#">
    	<cf_grid_list sort="1">
        	<thead>
             	<tr>
             		<th rowspan="2" style="width:30px;text-align:center" class="header_icn_txt"><cf_get_lang dictionary_id='58577.Sira'></th>
                    <th><cf_get_lang dictionary_id='57880.Belge No'></th>
                  	<th><cf_get_lang dictionary_id='33361.Talep Tarihi'></th>
                  	<th><cf_get_lang dictionary_id='51192.Giriş Depo'></th>
                  	<th><cf_get_lang dictionary_id='291.Talep Miktarı'></th>
                 	<th><cf_get_lang dictionary_id='57636.Birim'></th>
				 </tr>
         	</thead>
          	<tbody>
            	<cfif get_internaldemand_list.recordcount>
               		<cfoutput query="get_internaldemand_list" startrow="#attributes.startrow#" maxrows="#attributes.maxrows#">
                   		<tr>
							<td>#currentrow#</td>
                   		    <td style="text-align:center">
                   		    	#SHIP_RESULT_INTERNALDEMAND_ID#
                   		    </td>
									<td nowrap>#dateformat(OUT_DATE,dateformat_style)#</td>
                   		    <td nowrap>#DEPO#</td>
                   		    <td align="right">#AmountFormat(AMOUNT,2)#</td>
                   		    <td align="left">#UNIT#</td>
                   		</tr>
                   		<cfset s_toplam = s_toplam + AMOUNT>
                  	</cfoutput>
                 	<cfoutput>
                    	<cfif get_internaldemand_list.recordcount gt get_internaldemand_list.currentrow>
                       		<tfoot>
                   				<tr style="font-weight:bold">
                                    <td colspan="4">Sayfa Toplam</td>
                                    <td align="right">#AmountFormat(s_toplam,2)#</td>
                                    <td align="right"></td>
                   		    	</tr>
                   			</tfoot>
                      	<cfelse>
                          	<tfoot>
                   				<tr style="font-weight:bold">
                                	<td colspan="4">Genel Toplam</td>
                               		<td align="right">#AmountFormat(t_toplam,2)#</td>
                                 	<td align="right"></td>
                   		    	</tr>
                   			</tfoot>
                        </cfif>
               		</cfoutput>
           		<cfelse>
                 	<tr>
                   		<td colspan="7"><cf_get_lang dictionary_id='58486.Kayit Bulunamadi'>!</td>
                	</tr>
             	</cfif>
          	</tbody>
      	</cf_grid_list>
        <cfset url_str = ''>
      	<cfif isdefined("attributes.branch_id") and len(attributes.branch_id)>
         	<cfset url_str = url_str & "&branch_id=#attributes.branch_id#">
      	</cfif>
    	<cfif isdefined("attributes.department_id") and len(attributes.department_id)>
        	<cfset url_str = url_str & "&department_id=#attributes.department_id#">
    	</cfif>
      	<cfif isdefined("attributes.sid") and len(attributes.sid)>
      		<cfset url_str = url_str & "&sid=#attributes.sid#">
     	</cfif>
    	<cfif isdefined("attributes.keyword") and len(attributes.keyword)>
         	<cfset url_str = url_str & "&keyword=#attributes.keyword#">
   		</cfif>
     	<cf_paging 
                page="#attributes.page#"
                maxrows="#attributes.maxrows#"
                totalrecords="#attributes.totalrecords#"
                startrow="#attributes.startrow#"
                adres="#attributes.fuseaction#&#url_str#&is_form_submitted=1">
 	</cf_box>
</div>
<script language="javascript">
	function input_control()
	{
		return true
	}
</script>