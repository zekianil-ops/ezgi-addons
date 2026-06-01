<!---
    File: dsp_ezgi_material_list.cfm
    Folder: Add_Ons\ezgi\e-vts\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.dsp_type" default="1">
<cfquery name="get_material_list" datasource="#dsn3#">
    SELECT
        POS.STOCK_ID, 
   		POS.AMOUNT / PO.QUANTITY AS AMOUNT,
        POS.PRODUCT_UNIT_ID, 
        POS.LOT_NO, 
        REPLACE(S.PRODUCT_NAME,'(','_____(')AS PRODUCT_NAME, 
        S.PRODUCT_CODE, 
        S.IS_ZERO_STOCK, 
        ISNULL(S.IS_LOT_NO,0) AS IS_LOT_NO, 
        ISNULL(S.IS_LIMITED_STOCK,0) IS_LIMITED_STOCK, 
        PU.MAIN_UNIT,
        ISNULL((
            		SELECT        
                    	LOT_NO
					FROM            
                    	EZGI_PRODUCTION_ORDERS_STOCKS_LOT_NO
					WHERE        
                    	STATION_ID = #attributes.station_id# AND 
                        P_OPERATION_ID = #attributes.p_operation_id# AND 
                        EMPLOYEE_ID = #attributes.employee_id# AND 
                        STOCK_ID = POS.STOCK_ID
          	),'') AS LOT_NO
         <cfif attributes.dsp_type eq 1>   
            ,
            EDR.PIECE_FLOOR, 
            EDR.PIECE_PACKAGE_ROTA,
            EDR.BOYU, 
         	EDR.ENI, 
            (SELECT PROPERTY_DETAIL FROM #dsn1_alias#.PRODUCT_PROPERTY_DETAIL WHERE PROPERTY_DETAIL_ID = EDR.KALINLIK) AS KALIN
        </cfif>
    FROM            
    	PRODUCTION_ORDERS_STOCKS AS POS INNER JOIN
    	STOCKS AS S ON POS.STOCK_ID = S.STOCK_ID INNER JOIN
      	PRODUCT_UNIT AS PU ON POS.PRODUCT_UNIT_ID = PU.PRODUCT_UNIT_ID INNER JOIN
      	PRODUCTION_ORDERS AS PO ON POS.P_ORDER_ID = PO.P_ORDER_ID 
        <cfif attributes.dsp_type eq 1>
            LEFT OUTER JOIN
              (
              	SELECT DISTINCT 
                	PIECE_RELATED_ID, 
                    PIECE_TYPE, 
                    BOYU, 
                    ENI, 
                    PIECE_FLOOR, 
                    PIECE_PACKAGE_ROTA, 
                    KALINLIK
              	FROM      
                	EZGI_DESIGN_PIECE_ROWS
     		) AS EDR ON POS.STOCK_ID = EDR.PIECE_RELATED_ID
        </cfif>
	WHERE        
    	POS.P_ORDER_ID = #attributes.p_order_id# AND 
        POS.TYPE = 2 and
        ISNULL(S.IS_LIMITED_STOCK,0) = 0
  	ORDER BY
    	<cfif attributes.dsp_type eq 1>
    		ISNULL(EDR.PIECE_FLOOR,9999),EDR.PIECE_PACKAGE_ROTA, LEFT(S.PRODUCT_CODE, 6) DESC
        <cfelse>
        	S.PRODUCT_CODE
        </cfif>
</cfquery>
<cfquery name="get_lot_no_stock" dbtype="query">
	SELECT * FROM get_material_list WHERE IS_LOT_NO = 1
</cfquery>
<cfif get_lot_no_stock.recordcount>
	<cfset stock_id_list = Valuelist(get_lot_no_stock.STOCK_ID)>
    <cfquery name="get_lot_no" datasource="#dsn3#">
    	SELECT        
        	LOT_NO LOTS, 
            STOCK_ID, 
            PRODUCT_STOCK
		FROM          
        	#dsn2_alias#.GET_STOCK_PRODUCT_LOT_NO
		WHERE        
        	STOCK_ID IN (#stock_id_list#) AND
            PRODUCT_STOCK <> 0
    </cfquery>
    <cfdump var="#get_lot_no#">
    <cfif get_lot_no.recordcount>
        <cfloop query="get_lot_no_stock">
            <cfquery name="get_lot_no_#get_lot_no_stock.STOCK_ID#" dbtype="query">
                SELECT * FROM get_lot_no WHERE STOCK_ID = #get_lot_no_stock.STOCK_ID# ORDER BY PRODUCT_STOCK DESC
            </cfquery>
        </cfloop>
  	</cfif>
<cfelse>
	<cfset stock_id_list = ''>
</cfif>
<table width="100%">
	<tr>
    	<td>
			<cfsavecontent variable="recete"><cf_get_lang dictionary_id='308.Reçete'></cfsavecontent>
            <cf_box title="#recete#">
                <cf_ajax_list>
                    <thead>
                        <tr height="20px">
                            <th style="width:45;text-align:center;"><cf_get_lang dictionary_id='58577.Sıra'></th>
                         	<th style="width:100;text-align:left;"><cf_get_lang dictionary_id='57518.Stok Kodu'></th>
                          	<th style="text-align:left;"><cf_get_lang dictionary_id='57657.Ürün'></th>
                            <cfif attributes.dsp_type eq 1>
                            	<th style="width:50;text-align:left;"><cf_get_lang dictionary_id='99.Boy'></th>
                                <th style="width:50;text-align:left;"><cf_get_lang dictionary_id='98.En'></th>
                                <th style="width:50;text-align:left;"><cf_get_lang dictionary_id='75.Kalınlık'></th>
                            	<th style="width:70;text-align:left;"><cf_get_lang dictionary_id='36381.Rota'></th>
                                <th style="width:70;text-align:left;"><cf_get_lang dictionary_id='102.Kat'></th>
                            </cfif>
                          	<th style="width:70;text-align:right;"><cf_get_lang dictionary_id='57635.Miktar'></th>
                            <th style="width:40;text-align:left;"><cf_get_lang dictionary_id='57636.Birim'></th>
                            <th style="width:70;text-align:center;"><cf_get_lang dictionary_id='36768.Sarf'></th>
                          	<th style="width:40;text-align:center;"><cf_get_lang dictionary_id='38869.Lot'></th>
                            <th style="width:100;text-align:center;"><cf_get_lang dictionary_id='36698.Lot No'></th>
                        </tr>
                    </thead>
                    <tbody>
                    	<cfif get_material_list.recordcount>
							<cfoutput query="get_material_list">
                   				<tr style="height:20px">
                                	<td style="background-color:FFFFCC;text-align:center;">#currentrow#&nbsp;</td>
                                    <td style="background-color:FFFFCC;text-align:left;">&nbsp;#PRODUCT_CODE#</td>
                                    <td style="background-color:FFFFCC;text-align:left;">&nbsp;#PRODUCT_NAME#</td>
                                    <cfif attributes.dsp_type eq 1>
                                    	<td style="background-color:FFFFCC;text-align:center;">#BOYU#</td>
                                        <td style="background-color:FFFFCC;text-align:center;">#ENI#</td>
                                        <td style="background-color:FFFFCC;text-align:center;">#KALIN#</td>
                                    	<td style="background-color:FFFFCC;text-align:center;">#PIECE_PACKAGE_ROTA#</td>
                                    	<td style="background-color:FFFFCC;text-align:center;">#PIECE_FLOOR#</td>
                                    </cfif>
                                    <td style="background-color:FFFFCC;text-align:right;">#TlFormat(AMOUNT,4)#&nbsp;</td>
                                    <td style="background-color:FFFFCC;text-align:left;">&nbsp;#MAIN_UNIT#</td>
                                    <td style="background-color:FFFFCC;text-align:center;">
                                    	<cfif IS_LIMITED_STOCK eq 1>
                                        	<cf_get_lang dictionary_id ='37922.Kanban'>
                                        <cfelse>
                                        	<cf_get_lang dictionary_id ='1151.MRP'>
                                        </cfif>
                                    </td>
                                    <td style="background-color:FFFFCC;text-align:center;">
                                    	<cfif IS_LOT_NO eq 1>
                                        	<cfif len(LOT_NO)>
                                            	<img src="/images/c_ok.gif" border="0" />
                                          	<cfelse>
                                        		<img src="/images/b_ok.gif" border="0" />
                                          	</cfif>
                                        <cfelse>
                                        	<img src="/images/control_empty.gif" border="0" />
                                        </cfif>
                                    </td>
                                    <td style="background-color:FFFFCC;text-align:center;" nowrap="nowrap">
                                    	<cfif IS_LOT_NO eq 1>
                                        	<input type="text" name="lot_no_#STOCK_ID#" id="lot_no_#STOCK_ID#" value="#LOT_NO#" style="width:100px" />
                                        </cfif>

                                        <cfif isdefined('get_lot_no_#STOCK_ID#')> 
                                            <select name="select_lot_no_#STOCK_ID#" id="select_lot_no_#STOCK_ID#" style="width:150px; height:20px" onchange="lot_no(#STOCK_ID#)">
                                            	<option value=""><cfoutput><cf_get_lang dictionary_id='36698.Lot No'>(<cf_get_lang dictionary_id='57635.Miktar'>)</cfoutput>	</option>
                                                <cfloop query="get_lot_no_#STOCK_ID#">
                                                    <option style="<cfif PRODUCT_STOCK lt 0>color:red</cfif>" value="#LOTS#">#LOTS#  (#TlFormat(PRODUCT_STOCK,4)#)</option>
                                                </cfloop>
                                            </select>
                                        </cfif>
                                    </td>
                    			</tr>
                          	</cfoutput>
                      	</cfif>
                    </tbody>
                </cf_ajax_list>
            </cf_box>
     	</td>
  	</tr>
</table>
<table border="0" width="100%">
	<tr height="20">
    	<td class="box_yazi_td2" style="width:100%;text-align:right">
        	<input type="button" value="<cfoutput><cf_get_lang dictionary_id='57553.Kapat'></cfoutput>" name="kapat" onClick="window.close();" style=" width:100px; height:50px">&nbsp;&nbsp;
            <input type="submit" value="<cfoutput><cf_get_lang dictionary_id='57461.Kaydet'></cfoutput>" name="kaydet" onclick="input_control();" style=" width:100px; height:50px">&nbsp;
       	</td>
  	</tr>
</table>
<script type="text/javascript">
	function lot_no(stock_id)
	{
		document.getElementById('lot_no_'+stock_id).value = document.getElementById('select_lot_no_'+stock_id).value;
	}
	function input_control()
	{
		<cfif ListLen(stock_id_list)>
			<cfloop list="#stock_id_list#" index="i">
				<cfoutput>stock_id = #i#;</cfoutput>
				if(document.getElementById('lot_no_'+stock_id).value=='')
				{
					sor = confirm('<cf_get_lang dictionary_id='58194.Zorunlu Alan'> - <cf_get_lang dictionary_id='42029.Lot No'>?')
					if(sor==true)
					{
						document.getElementById('lot_no_'+stock_id).focus();
						return false;
					}
					else
					{
						return true;	
					}
				}	
			</cfloop>
		</cfif>
	}
</script>