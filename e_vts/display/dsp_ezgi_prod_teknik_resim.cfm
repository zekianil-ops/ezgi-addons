<!---
    File: dsp_ezgi_prod_teknik_resim.cfm
    Folder: Add_Ons\ezgi\e-vts\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<style>
	.box_yazi {font-size:12px;border-color:#666666;font:bold} 
	.box_yazi_td {font-size:12px;border-color:#666666;font:bold;} 
	.box_yazi_td2 {font-size:20px;border-color:#666666;font:bold}
</style>
<cfquery name="get_order" datasource="#dsn3#">
	SELECT STOCK_ID,OPERATION_TYPE_ID FROM EZGI_OPERATION_M WHERE P_ORDER_ID = #attributes.p_order_id#
    UNION ALL
    SELECT STOCK_ID,OPERATION_TYPE_ID FROM EZGI_OPERATION_S WHERE P_ORDER_ID = #attributes.p_order_id#
</cfquery>
<cfquery name="gt_stock" datasource="#dsn3#">
	SELECT        
    	S.PRODUCT_NAME
	FROM         
    	PRODUCTION_ORDERS AS PO INNER JOIN
      	STOCKS AS S ON PO.STOCK_ID = S.STOCK_ID
	WHERE        
    	PO.P_ORDER_ID = #attributes.p_order_id#
</cfquery>
<cfif ListLen(gt_stock.PRODUCT_NAME,'(')>
	<cfset isim = ListGetAt(gt_stock.PRODUCT_NAME,1,'(')>
<cfelse>
	<cfset isim = ''>	
</cfif>
<cfquery name="get_picture" datasource="#dsn3#">
	SELECT   
    	TOP (1)     
    	PI.DETAIL, 
        PI.PATH FILE_NAME,
        1 AS TYPE, 
        PI.PATH_SERVER_ID FILE_SERVER_ID
	FROM            
    	#dsn1_alias#.PRODUCT_IMAGES AS PI INNER JOIN
      	STOCKS AS S ON PI.PRODUCT_ID = S.PRODUCT_ID
	WHERE        
    	PI.IMAGE_SIZE = 0 AND 
        S.STOCK_ID = #get_order.STOCK_ID# 
  	UNION ALL
	SELECT  
    	TOP (1)   
    	DETAIL, 
        FILE_NAME, 
        TYPE, 
        FILE_SERVER_ID
	FROM         
    	EZGI_PRODUCTION_OPERATION_IMAGE
	WHERE     
    	OPERATION_TYPE_ID = #get_order.OPERATION_TYPE_ID# AND 
        STOCK_ID = #get_order.STOCK_ID# AND 
        STATUS = 1
  	UNION ALL
    SELECT        
    	PI.DETAIL, 
        PI.PATH AS FILE_NAME, 
        PI.IMAGE_SIZE AS TYPE,
        PI.PATH_SERVER_ID AS FILE_SERVER_ID
	FROM          
    	EZGI_DESIGN_PIECE_IMAGES AS PI INNER JOIN
     	EZGI_DESIGN_PIECE_ROWS AS EPR ON PI.DESIGN_PIECE_ROW_ID = EPR.PIECE_ROW_ID
	WHERE        
    	EPR.PIECE_RELATED_ID = #get_order.STOCK_ID#
 	UNION ALL
    SELECT        
        EDI.DETAIL, 
        EDI.PATH AS FILE_NAME, 
        EDI.IMAGE_SIZE AS TYPE, 
        EDI.PATH_SERVER_ID AS FILE_SERVER_ID
	FROM            
    	EZGI_DESIGN_PACKAGE AS EDP INNER JOIN
      	EZGI_DESIGN_PACKAGE_IMAGES AS EDI ON EDP.PACKAGE_ROW_ID = EDI.DESIGN_PACKAGE_ROW_ID
	WHERE        
    	EDP.PACKAGE_RELATED_ID = #get_order.STOCK_ID#
</cfquery>
<cfif get_picture.recordcount>
	<cfset file_name = get_picture.FILE_NAME>
<cfelse>
	<cfset file_name = ''>
</cfif>
<cfparam name="attributes.dsp_type" default="1">
<cfquery name="get_material_list" datasource="#dsn3#">
	SELECT DISTINCT
      	POS.STOCK_ID, 
    	POS.AMOUNT, 
        POS.PRODUCT_UNIT_ID, 
        POS.LOT_NO, 
        REPLACE(S.PRODUCT_NAME,'(','_____(')AS PRODUCT_NAME, 
        S.PRODUCT_CODE
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
            EZGI_DESIGN_PIECE_ROWS AS EDR ON POS.STOCK_ID = EDR.PIECE_RELATED_ID
        </cfif>
	WHERE        
    	POS.P_ORDER_ID = #attributes.p_order_id# AND 
        POS.TYPE = 2 and
        ISNULL(S.IS_LIMITED_STOCK,0) = 0
  	ORDER BY
    	S.PRODUCT_CODE       
        
        
        
</cfquery>

<table cellspacing="0" cellpadding="0" width="100%" height="100%" align="center" border="1" style="border-color:#666666;">
	<tr class="color-row">
		<td valign="top" style="text-align:center; width:65%">
            <cfform name="pause_form" method="post" action="">
                <table border="0" width="100%">
                    <tr>
                        <td style="text-align:center;vertical-align:middle"">
                            <cfif get_picture.recordcount and len(get_picture.FILE_NAME)>
                                <cf_get_server_file output_file="PRODUCT/#get_picture.FILE_NAME#" output_server="#get_picture.FILE_SERVER_ID#" output_type="0" image_width="1000" image_height="700">
                            <cfelse>
                                <cfoutput><img src="#user_domain##file_web_path#operationtype/no-photo.png" border="0"></cfoutput>
                            </cfif>
                        </td>
                    </tr>
                </table>
            </cfform>
     	</td>
        <td style="text-align:center; width:35%; vertical-align:top">
        	<table width="100%" height="100%">
                <tr>
                    <td style="vertical-align:top">
                        <cf_box title="#gt_stock.PRODUCT_NAME#">
                            <cf_ajax_list>
                                <thead>
                                    <tr height="20px">
                                        <th style="width:45px;text-align:center;"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                        <th style="text-align:left;"><cf_get_lang dictionary_id='57657.Ürün'></th>
                                        <th style="width:100px;text-align:left;"><cf_get_lang dictionary_id='45478.Ebat'></th>
                                        <th style="width:40px;text-align:left;"><cf_get_lang dictionary_id='36381.Rota'></th>
                                   		<th style="width:40px;text-align:left;"><cf_get_lang dictionary_id='102.Kat'></th>
                                        <th style="width:40px;text-align:right;"><cf_get_lang dictionary_id='57635.Miktar'></th>
                                    </tr>
                                </thead>
                                <tbody>
                                	<cfif get_material_list.recordcount>
										<cfoutput query="get_material_list">
                                            <tr style="height:20px">
                                                <td style="background-color:FFFFCC;text-align:center;">#currentrow#&nbsp;</td>
                                                <td style="background-color:FFFFCC;text-align:left;">
                                                	<cfif len(isim)>
                                                    	&nbsp;#Replace(PRODUCT_NAME,isim,'')#
                                                    <cfelse>
                                                    	&nbsp;#PRODUCT_NAME#
                                                    </cfif>
                                                </td>
                                                <td style="background-color:FFFFCC;text-align:center;">(#BOYU#*#ENI#*#KALIN#)</td>
                                                <td style="background-color:FFFFCC;text-align:center;">#PIECE_PACKAGE_ROTA#</td>
                                            	<td style="background-color:FFFFCC;text-align:center;">#PIECE_FLOOR#</td>
                                                <td style="background-color:FFFFCC;text-align:right;">#TlFormat(AMOUNT,0)#&nbsp;</td>
                                            </tr>
                                        </cfoutput>
                                    </cfif>
                                </tbody>
                         	</cf_ajax_list>
                      	</cf_box>
                  	</td>
              	</tr>
          	</table>
        </td>
  	</tr>   
</table>
<br>
<table border="0" width="100%">
	<tr height="20"><td class="box_yazi_td2" style="width:100%;text-align:right"><input type="button" value="<cfoutput><cf_get_lang dictionary_id='57553.Kapat'></cfoutput>" name="kapat" onClick="sw_start(3)" style=" width:100px; height:50px"></td></tr>
</table>
<script type="text/javascript">
	function sw_start(type)
	{
		if(type==3)
		{
			window.close();
		}
	}
</script>  