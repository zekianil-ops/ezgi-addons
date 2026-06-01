<cfquery name="GET_SHIP_PACKAGE_LIST" datasource="#dsn2#">
        SELECT     
        	PAKET_ID, 
            SUM(PAKET_SAYISI) AS PAKETSAYISI, 
            ISNULL(
                    	(
                        	SELECT     
                            	SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                           	FROM         
                            	#dsn3_alias#.EZGI_SHIPPING_PACKAGE_LIST_COLLECT_STORE
                        	WHERE     
                            	STOCK_ID = TBL_3.PAKET_ID AND 
                                COLLECT_ID = TBL_3.COLLECT_ID
                      	), 
                        0) AS CONTROL_AMOUNT, 
            SUM(CONTROL_AMOUNT1) AS CONTROL_AMOUNT1, 
        	STOCK_CODE, 
            BARCOD, 
            PRODUCT_NAME,
            COLLECT_ID
		FROM         
        	(
            	SELECT   
                	TBL.COLLECT_ID,  
                	TBL.PAKET_ID, 
                    TBL.PAKET_SAYISI, 
                    
              		ISNULL(
                    	(
                        	SELECT     
                            	SUM(CONTROL_AMOUNT) AS CONTROL_AMOUNT
                          	FROM         
                            	#dsn3_alias#.EZGI_SHIPPING_PACKAGE_LIST
                         	WHERE     
                            	TYPE = 2 AND 
                                STOCK_ID = TBL.PAKET_ID AND 
                                SHIPPING_ID = TBL.DISPATCH_SHIP_ID
                     	), 
                        0) AS CONTROL_AMOUNT1, 
                	S.STOCK_CODE, 
                    S.BARCOD, 
               		S.PRODUCT_NAME
              	FROM          
                	(
                    	SELECT     
                        	EC.DISPATCH_SHIP_ID, 
                            EPS.PAKET_ID, 
                            EC.COLLECT_ID, 
                            EC.DEPARTMENT_IN, 
                            EC.SHIP_METHOD, 
                            EC.DEPARTMENT_OUT, 
                            SUM(EPS.PAKET_SAYISI * SIR.AMOUNT) AS PAKET_SAYISI
                    	FROM          
                        	EZGI_SHIP_INTERNAL_COLLECT AS EC INNER JOIN
                            EZGI_SHIP_RESULT_INTERNALDEMAND_ROW AS SIR ON EC.DISPATCH_SHIP_ID = SIR.SHIP_RESULT_INTERNALDEMAND_ID INNER JOIN
                            #dsn3_alias#.EZGI_PAKET_SAYISI AS EPS ON SIR.STOCK_ID = EPS.MODUL_ID
                     	WHERE      
                        	EC.COLLECT_ID = '#attributes.collect_id#'
                     	GROUP BY 
                        	EC.DISPATCH_SHIP_ID, 
                            EPS.PAKET_ID, 
                            EC.COLLECT_ID, 
                            EC.DEPARTMENT_IN, 
                            EC.SHIP_METHOD, 
                            EC.DEPARTMENT_OUT
                 		) AS TBL INNER JOIN
                  	#dsn3_alias#.STOCKS S ON TBL.PAKET_ID = S.STOCK_ID
        		) AS TBL_3
		GROUP BY 
        	PAKET_ID, 
            STOCK_CODE, 
            BARCOD, 
            PRODUCT_NAME,
            COLLECT_ID
</cfquery>
<cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id="45694.Paket Kontrol Listesi"></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box title="#ezgi_header#" right_images="">
    	<cf_basket id="upd_default_measure_bask">
     		<cf_grid_list sort="0">
            	<thead>
                	<tr height="30px">
                        <th width="75px">Barkod</th>
                        <th width="120px">Kod</th>
                        <th>Ürün</th>
                        <th width="40px">Paket Sayısı</th>
                        <th width="40px">Çıkış Kontrol</th>
                        <th width="40px">Mağaza Kontrol</th>
                    </tr>
    			</thead>
                <tbody>
					<cfoutput query="GET_SHIP_PACKAGE_LIST">
                        <tr height="30">
                                <td>#BARCOD#</td>
                                <td>#STOCK_CODE#</td>
                                <td>#product_name#</td>
                                <td style="text-align:right"><strong>#Tlformat(PAKETSAYISI,0)#</strong></td>
                                <td style="text-align:right"><strong>#Tlformat(control_amount1,0)#</strong></td>
                                <td style="text-align:right"><strong>#Tlformat(control_amount,0)#</strong></td>
                        </tr>
                    </cfoutput>
            	</tbody>
                <tfoot>
                    <tr class="color-list">
                        <td colspan="6" align="right">
                        	<button  value="" name="kapat" onClick="kontrol()" style="width:100px; height:25px;"><cf_get_lang dictionary_id="57553.Kapat"></button>
                        </td>
                    </tr>
             	</tfoot>
           	</cf_grid_list>
		</cf_basket>
   	</cf_box>
</div>
<script language="javascript">
	function kontrol()
	{
		window.close();
	}
</script>