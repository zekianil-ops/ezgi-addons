<!---
    File: dsp_ezgi_shelf_info.cfm
    Folder: Add_Ons\ezgi\e-pda\form
    Author: Ezgi Yazılım
    Date: 01/01/2023
    Description:
--->
<cfparam name="attributes.keyword" default="">
<cfif isdefined('attributes.is_submitted') AND Len(attributes.keyword)>
	<cfquery name="get_shelf" datasource="#dsn3#">
   		SELECT 
        	CASE
            	WHEN O.COMPANY_ID IS NOT NULL THEN
             	(
                    SELECT     
                      	NICKNAME
					FROM         
                    	#dsn_alias#.COMPANY
					WHERE     
                   		COMPANY_ID = O.COMPANY_ID
               	)
              	WHEN O.CONSUMER_ID IS NOT NULL THEN      
             	(	
                  	SELECT     
                     	CONSUMER_NAME + ' ' + CONSUMER_SURNAME AS ISIM
					FROM         
                      	#dsn_alias#.CONSUMER
					WHERE     
                		CONSUMER_ID = O.CONSUMER_ID
             	)
           	END AS UNVAN,
         	PP.PRODUCT_PLACE_ID, 
 			PP.SHELF_CODE, 
       		PP.PLACE_STATUS, 
           	PP.STORE_ID, 
          	PP.LOCATION_ID, 
          	PP.SHELF_TYPE, 
           	PP.DETAIL, 
          	EPA.PACKING_ID, 
           	EP.BARCODE, 
         	EPA.PROCESS_DATE, 
         	EP.TYPE, 
          	EP.ORDER_ID, 
         	EPR.LOT_NO, 
         	EPR.AMOUNT, 
          	EPR.STOCK_ID, 
          	EPR.SERIAL_NO, 
         	O.ORDER_NUMBER,
            S.BARCOD, 
            S.PRODUCT_NAME, 
            PU.MAIN_UNIT, 
            EPR.SPECT_MAIN_ID
		FROM     
         	PRODUCT_PLACE AS PP INNER JOIN
          	EZGI_PACKING_ACTION AS EPA ON EPA.SHELF_NUMBER = PP.PRODUCT_PLACE_ID INNER JOIN
          	EZGI_PACKING AS EP ON EPA.PACKING_ID = EP.PACKING_ID INNER JOIN
          	EZGI_PACKING_ROW AS EPR ON EP.PACKING_ID = EPR.PACKING_ID INNER JOIN
          	STOCKS AS S ON EPR.STOCK_ID = S.STOCK_ID INNER JOIN
          	PRODUCT_UNIT AS PU ON S.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID LEFT OUTER JOIN
         	ORDERS AS O ON EP.ORDER_ID = O.ORDER_ID
		WHERE  
         	EP.STATUS = 1 
            AND PP.SHELF_CODE = '#attributes.keyword#'
            AND EPA.EZGI_PACKING_ACTION_ID IN
                                            (
                                                SELECT 
                                                    MAX(EZGI_PACKING_ACTION_ID) AS EZGI_PACKING_ACTION_ID
                                                FROM     
                                                    EZGI_PACKING_ACTION
                                                GROUP BY 
                                                    PACKING_ID
                                            )
            
	</cfquery>
   	<cfquery name="get_packings" dbtype="query">
    	SELECT 
        	PRODUCT_PLACE_ID, 
            SHELF_CODE, 
            PLACE_STATUS, 
            STORE_ID, 
            LOCATION_ID, 
            SHELF_TYPE, 
            PACKING_ID, 
            BARCODE, 
            PROCESS_DATE, 
            TYPE, 
            ORDER_ID, 
            ORDER_NUMBER,
            UNVAN
		FROM
        	get_shelf
      	GROUP BY 
        	PRODUCT_PLACE_ID, 
            SHELF_CODE, 
            PLACE_STATUS, 
            STORE_ID, 
            LOCATION_ID, 
            SHELF_TYPE, 
            PACKING_ID, 
            BARCODE, 
            PROCESS_DATE, 
            TYPE, 
            ORDER_ID, 
            ORDER_NUMBER,
            UNVAN
    </cfquery> 
    <cfif not get_packings.recordcount>
    	<script type="text/javascript">
			alert("Rafta Palet Yoktur!");
		</script>
    </cfif>
<cfelse>
	<cfset get_packings.recordcount=0>	
</cfif>
<cfform name="dsp_shelf" id="dsp_shelf" method="post" action="#request.self#?fuseaction=pda.dsp_ezgi_shelf_info"> 
	<input type="hidden" name="is_submitted" id="is_submitted" value="1">
	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
    	<cf_box scroll="0">
            <cf_box_search>
            	<div class="col col-12">
                    <div class="col col-3">
                    	<cf_get_lang dictionary_id='36714.Raf'>
                    </div>
                    <div class="col col-6">
                    	<div class="form-group">
                            <cfinput id="keyword" name="keyword" type="text" onfocus="islemtipi=0;"  maxlength="20" value="" />
                        </div>
                    </div>
                    <div class="col col-3">
                    	<div class="form-group">
                            <input id="onay" name="Onay" value="Ara" type="button" onClick="kontrol_kayit();" />
                        </div>
                    </div>
              	</div>
          	</cf_box_search>
        </cf_box>
        <cfsavecontent variable="title"><cf_get_lang dictionary_id="30001.Raf Bilgisi"></cfsavecontent>
       	<cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
            <cf_form_list>
                <thead>
                    <tr>
                    	<th width="20"><cf_get_lang dictionary_id='58577.Sıra'></th>
                        <th width="70"><cf_get_lang dictionary_id='57633.Barkod'></th>
                        <th width="80" nowrap><cf_get_lang dictionary_id='58211.Sipariş No'></th>
                        <th width="100%">Müşteri</th>
                    </tr>
                </thead>
            	<tbody name="table1" id="table1">
                 	<cfif get_packings.recordcount>
                    	<cfoutput query="get_packings">
                        	<tr>
                            	<td style="text-align:right; font-weight:bold" nowrap>#currentrow#</td>
                                <td style="text-align:CENTER; font-weight:bold" nowrap>#BARCODE#</td>
                                <td style="text-align:CENTER; font-weight:bold" nowrap>#ORDER_NUMBER#</td>
                                <td style="text-align:left; font-weight:bold">#left(UNVAN,30)#</td>
                            </tr>
                            <cfquery name="get_packing_detail" dbtype="query">
                            	SELECT
                                	AMOUNT,
                                	BARCOD, 
            						PRODUCT_NAME, 
           							MAIN_UNIT, 
          							SPECT_MAIN_ID
                               	FROM
        							get_shelf
                               	WHERE
                                	PRODUCT_PLACE_ID = #get_packings.PRODUCT_PLACE_ID#
                            </cfquery>
                            <cfif get_packing_detail.recordcount>
                            	<tr>
                                	<td colspan="4">
                                    	<table cellpadding="0" cellspacing="0" border="1" width="98%">
                                        	<cfloop query="get_packing_detail">
                                            <tr>
                                                <td style="text-align:right; width:10%; font-size:9px">#get_packing_detail.currentrow#</td>
                                                <td style="text-align:center; width:20%; font-size:9px">#get_packing_detail.BARCOD#</td>
                                                <td style="text-align:left; width:60%; font-size:9px">#get_packing_detail.PRODUCT_NAME#</td>
                                                <td style="text-align:right; width:10%; font-size:9px">#TlFormat(get_packing_detail.AMOUNT,2)#</td>
                                            </tr>
                                            </cfloop>
                                        </table>
                                    </td>
                                </tr>
                            </cfif>
                        </cfoutput>
                  	</cfif>
              	</tbody>
                <tfoot>
                    <tr>	
                        <td colspan="4"></td>
                    </tr>
                </tfoot>
            </cf_form_list>
        </cf_box>
    </div>
</cfform>
<script language="javascript" type="text/javascript">
	document.getElementById('keyword').focus();
	function kontrol_kayit()
	{
		if(document.getElementById('keyword').value == '')
		{
			alert('Raf Kodu Giriniz');
			return false;
		}
		else
			document.getElementById("dsp_shelf").submit();
	}
</script>
