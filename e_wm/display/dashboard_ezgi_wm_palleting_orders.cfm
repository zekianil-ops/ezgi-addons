<cfset total_pck = 0>
<cfquery name="get_default_departments" datasource="#dsn3#">
	SELECT 
    	INTERMEDIATE_WAREHOUSE, 
        PRODUCTION_WAREHOUSE,
        SHELF_WAREHOUSE,
        FIRST_SHELF_ID
	FROM     
    	EZGI_WM_SETUP_ROW WITH (NOLOCK)
	WHERE  
    	EMPLOYEE_POSITION_ID = #session.ep.POSITION_CODE#
</cfquery>
<cfif not get_default_departments.recordcount>
	<script type="text/javascript">
		alert("<cf_get_lang dictionary_id='338.Default Depo Ayarları Yapılmamış'>! <cf_get_lang dictionary_id='29938.Sistem Yöneticisine Başvurun.'>");
		history.back();	
	</script>
</cfif>
<cfquery name="get_depo" datasource="#dsn#">
	SELECT 
    	D.DEPARTMENT_HEAD + ' - ' + SL.COMMENT AS DEPARTMENT_HEAD,
        CAST(SL.DEPARTMENT_ID AS VARCHAR) + '_' + CAST(SL.LOCATION_ID AS VARCHAR) AS DEPO
	FROM     
    	DEPARTMENT AS D WITH (NOLOCK) INNER JOIN
        BRANCH AS B WITH (NOLOCK) ON D.BRANCH_ID = B.BRANCH_ID INNER JOIN
        STOCKS_LOCATION AS SL WITH (NOLOCK) ON D.DEPARTMENT_ID = SL.DEPARTMENT_ID
	WHERE  
    	B.COMPANY_ID = #session.ep.company_id#
</cfquery>
<cfoutput query="get_depo">
	<cfset 'DEPARTMENT_HEAD_#DEPO#' = DEPARTMENT_HEAD>
</cfoutput>
<cfquery name="Get_Production_Store_Packets" datasource="#dsn3#">
	SELECT 
    	E.SERIAL_NO,
        E.IS_PROTOTYPE, 
        S.BARCOD,
        E.STOCK_ID, 
        E.PRODUCT_NAME
   	FROM 
    	EZGI_WM_SERIAL_NO_LAST_STATUS AS E WITH (NOLOCK) INNER JOIN
     	EZGI_WM_IS_SERIAL_NO_LIVE AS EL WITH (NOLOCK) ON E.SERIAL_NO = EL.SERIAL_NO LEFT OUTER JOIN
        STOCKS S ON S.STOCK_ID = E.STOCK_ID
        
   	WHERE 
    	DEPO = '#Replace(get_default_departments.PRODUCTION_WAREHOUSE,',','-')#'
</cfquery>
<cfquery name="Get_Production_Store_Packets_Group_Full" dbtype="query">
	SELECT 
    	STOCK_ID, 
        PRODUCT_NAME,
        BARCOD,
        COUNT(*) AS DEPO_STOK
	FROM     
    	Get_Production_Store_Packets
  	WHERE
    	STOCK_ID >0
  	GROUP BY
    	STOCK_ID, 
        PRODUCT_NAME,
        BARCOD
</cfquery>
<div class="display_area">	
	<div class="col col-4 col-md-3 col-sm-6 col-xs-12">
    	<div class="dashboard-stat2">
         	<div class="display">
             	<div class="number">
                  	<h4 class="font-green-sharp">
                      	<span data-counter="counterup"><cfoutput><!---#Get_Production_Store_Packets.recordcount#---></cfoutput></span>
                 		<small class="font-green-sharp"></small>
                  	</h4>
                 	<small>PALETLEME EMİRLERİ</small>
             	</div>
           		<div class="icon">
                    <img src="css/assets/icons/catalyst-icon-svg/ctl-045-warehouse.svg" width="30px" height="50px" style="cursor:pointer" onClick="genisle_frm(<cfoutput>#Get_Production_Store_Packets_Group_Full.recordcount#</cfoutput>,'pck')">
              	</div>
         	</div>
        	<div class="progress-info">
              	<div class="progress">
                 	<span style="width: 100%;" class="progress-bar progress-bar-success green-sharp"></span>
              	</div>
             	<div class="status">
                    <cf_box>
                    	<cf_grid_list>
                        	<thead>
                            	<tr>
                                    <th>S.No</th>
                                    <th>Barkod</th>
                                    <th>Ürün Adı</th>
                                    <th>Miktar</th>
                                </tr>
                            </thead>
                            <tbody>
								<cfif Get_Production_Store_Packets_Group_Full.recordcount>
                                    <cfoutput query="Get_Production_Store_Packets_Group_Full">
                                    	<input type="hidden" name="frm_pck_#Get_Production_Store_Packets_Group_Full.currentrow#" id="frm_pck_#Get_Production_Store_Packets_Group_Full.currentrow#" value="0">	
                                    	<tr onClick="genisle_frm_pck(#Get_Production_Store_Packets_Group_Full.currentrow#,#Get_Production_Store_Packets_Group_Full.DEPO_STOK#)">
                                        	<td style="text-align:right">#currentrow#</td>
                                         	<td style="text-align:center">#BARCOD#</td>   
                                            <td style="text-align:left">#PRODUCT_NAME#</td> 
                                            <td style="text-align:right">#DEPO_STOK#</td>
                                        </tr>
                                        <cfset total_pck = total_pck + DEPO_STOK>
                                        <cfquery name="Get_Production_Store_Packets_Serial" dbtype="query">
                                            SELECT 
                                              	PRODUCT_NAME, 
                                              	IS_PROTOTYPE, 
                                             	SERIAL_NO, 
                                              	STOCK_ID
                                            FROM     
                                                Get_Production_Store_Packets
                                            WHERE
                                                STOCK_ID = #STOCK_ID#
                                        </cfquery>
                                        <input type="hidden" name="frm_pck_alt#Get_Production_Store_Packets_Group_Full.currentrow#" id="frm_pck_alt#Get_Production_Store_Packets_Group_Full.currentrow#" value="#Get_Production_Store_Packets_Serial.recordcount#">
                                        <cfloop query="Get_Production_Store_Packets_Serial">
                                            <tr id="frm_pck_#Get_Production_Store_Packets_Group_Full.currentrow#_#Get_Production_Store_Packets_Serial.currentrow#" style=" font-weight:normal; display:none">
                                                <td style="text-align:right">#currentrow#</td>
                                                <td style="text-align:center">#SERIAL_NO#</td>
                                                <td style="text-align:left" colspan="2">#PRODUCT_NAME#</td>
                                            </tr>
                                        </cfloop>
                                    </cfoutput>
                                </cfif>
                            </tbody>
                            <tfoot>
                            	<tr>
                                	<td colspan="3">Tüm Paketler Toplamı</td>
                                    <td style="text-align:right"><cfoutput>#total_pck#</cfoutput></td>
                                </tr>
                            </tfoot>
                        </cf_grid_list>
                    </cf_box>
             	</div>
          	</div>
     	</div>
 	</div>   
</div>
<script type="text/javascript">
	function genisle_frm(total_sira,bolum)
	{
		for(j=1;j<=total_sira;j++)
		{
			adet=document.getElementById('frm_'+bolum+'_alt'+j).value;
			if(bolum=='pck')
				genisle_frm_pck(j,adet);
		}
	}
	function genisle_frm_pck(sira,adet)
	{	
		if(document.getElementById('frm_pck_'+sira).value==0)
		{
			for(i=1;i<=adet;i++)
			{
				document.getElementById('frm_pck_'+sira+'_'+i).style.display='';
			}
			document.getElementById('frm_pck_'+sira).value=1
		}
		else
		{
			for(i=1;i<=adet;i++)
			{
				document.getElementById('frm_pck_'+sira+'_'+i).style.display='none';
			}			
			document.getElementById('frm_pck_'+sira).value=0
		}
	}
</script>
        
      
        