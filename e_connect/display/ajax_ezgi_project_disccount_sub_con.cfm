<!---
    File: ajax_ezgi_project_disccount_sub_con.cfm
    Folder: Add_Ons\ezgi\e_connect\display
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description:
--->
<cfquery name="get_product" datasource="#dsn3#">
	SELECT
    	E.DISC_SUB_CONDITION_ID, 
        E.PROJECT_ID, 
        E.CON_PRODUCT_ID, 
        E.PRODUCT_ID, 
        E.QUANTITY, 
        P.PRODUCT_CODE, 
        P.BARCOD, 
        P.PRODUCT_NAME, 
        P.PRODUCT_STATUS
	FROM     
    	EZGI_CONNECT_PROJECT_DISCOUNT_SUB_CONDITIONS AS E INNER JOIN
        #dsn1_alias#.PRODUCT AS P ON E.PRODUCT_ID = P.PRODUCT_ID
	WHERE  
    	E.CON_PRODUCT_ID = #attributes.product_id# AND 
        E.PROJECT_ID = #attributes.project_id#
</cfquery>
<cf_grid_list sort="0">	
	<thead>
   		<tr style="height:15px">
        	<th width="20">
            	<input name="sub_record_num" id="sub_record_num" type="hidden" value="<cfoutput>#get_product.recordcount#</cfoutput>">
				<a href="javascript://" onclick="pencere_ac_product();"  title="<cf_get_lang_main no ='57464.Güncelle'>"><i class="fa fa-pencil"></i></a>
            </th>
         	<th><cf_get_lang dictionary_id='62946.Hediye Ürün'></th>
        	<th width="50"><cf_get_lang dictionary_id='57635.Miktar'></th>
      	</tr>
 	</thead>
 	<tbody name="sub_table" id="sub_table">
    	<cfoutput query="get_product">
    		<tr id="frm_row_sub#currentrow#">
            	<td style="text-align:center">#currentrow#</td>
          		<td>#PRODUCT_NAME#</td>
             	<td style="text-align:right">#QUANTITY#</td>
        	</tr>
    	</cfoutput>
	</tbody>
</cf_grid_list>
<script type="text/javascript">
	function pencere_ac_product()
	{
		windowopen('<cfoutput>#request.self#?fuseaction=sales.popup_dsp_ezgi_project_disccount_sub_con&product_id=#attributes.product_id#&project_id=#attributes.project_id#</cfoutput>','small');
	}
</script>