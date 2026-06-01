<!---
    File: ajax_ezgi_sheet_optimize.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 11/11/2025
    Description:
--->
<style>
 	.sheetTitle { font-size:18px; font-weight:bold; fill:black; }
  	.pieceText  { font-size:12px; font-weight:bold; fill:white; }
</style>
<cfscript>
  // --- SABİT TABAKA BOYUTLARI ---
  sheetWidth  = 2100;
  sheetHeight = 2800;
  kerf        = 4;     // Testere payı (mm)
</cfscript>
<cfif ListLen(attributes.encodeddata,'*')>
	<cfset piece_row_detail = queryNew("emir_no, x_point, y_point, width, height","cf_sql_varchar, Decimal, Decimal, Decimal, Decimal")>
    <cfloop from="1" to="#ListLen(attributes.encodeddata,'*')#" index="i">
    	<cfset Sub_Data_List = ListGetAt(attributes.encodeddata,i,'*')>
      	<!--- Satır ekle --->
      	<cfset QueryAddRow(piece_row_detail)>
    
      	<!--- Hücreleri doldur --->
        <cfset QuerySetCell(piece_row_detail, "emir_no", ListGetAt(Sub_Data_List,1,'_'))>
        <cfset QuerySetCell(piece_row_detail, "width", ListGetAt(Sub_Data_List,2,'_'))>
      	<cfset QuerySetCell(piece_row_detail, "height", ListGetAt(Sub_Data_List,3,'_'))>
      	<cfset QuerySetCell(piece_row_detail, "x_point", ListGetAt(Sub_Data_List,4,'_'))>
      	<cfset QuerySetCell(piece_row_detail, "y_point", ListGetAt(Sub_Data_List,5,'_'))>
    </cfloop>
    <cfquery name="piece_row_detail_group" dbtype="query">
  		SELECT 
       		emir_no,
         	width,
       		height,
            count(*) as amount
     	FROM
     		piece_row_detail
      	group by
        	emir_no,
         	width,
       		height
 		ORDER BY 
          	emir_no
	</cfquery>
    
    <cfset emir_no_list = ListDeleteDuplicates(ValueList(piece_row_detail_group.emir_no))>
    <cfquery name="get_p_order_info" datasource="#dsn3#">
    	SELECT
        	PO.P_ORDER_NO,
            PO.LOT_NO,
            EDP.PIECE_NAME
      	FROM
        	PRODUCTION_ORDERS PO WITH (NOLOCK) INNER JOIN
            STOCKS S WITH (NOLOCK) ON S.STOCK_ID = PO.STOCK_ID INNER JOIN
            EZGI_DESIGN_PIECE_ROWS EDP WITH (NOLOCK) ON EDP.PIECE_SPECT_RELATED_ID = PO.SPEC_MAIN_ID
      	WHERE
        	P_ORDER_NO IN (#emir_no_list#) AND
			S.IS_PROTOTYPE = 1
     	UNION ALL
        SELECT
        	PO.P_ORDER_NO,
            PO.LOT_NO,
            EDP.PIECE_NAME
      	FROM
        	PRODUCTION_ORDERS PO WITH (NOLOCK) INNER JOIN
            STOCKS S WITH (NOLOCK) ON S.STOCK_ID = PO.STOCK_ID INNER JOIN
            EZGI_DESIGN_PIECE_ROWS EDP WITH (NOLOCK) ON EDP.PIECE_RELATED_ID = PO.STOCK_ID
      	WHERE
        	P_ORDER_NO IN (#emir_no_list#) AND
			S.IS_PROTOTYPE = 1
    </cfquery>
	<cf_box>
     	<cf_grid_list>
       		<thead>  
       		    <tr align="right" class="color-list">
       		        <th style="width:20px; text-align:center">S.No</th>
       		        <th style="text-align:center">Lot No</th>
       		        <th style="text-align:center">Emir No</th>
       		        <th style="text-align:center">Parça Adı</th>
       		        <th style="text-align:center">Miktar (Adet)</th>
       		        <th style="text-align:center">Eni (mm)</th>
       		        <th style="text-align:center">Boyu (mm)</th>
       		    </tr>
       		</thead>
       		<tbody>
       		    <cfif piece_row_detail_group.recordcount>
                	<cfquery name="get_info" dbtype="query">
                    	SELECT * FROM get_p_order_info WHERE P_ORDER_NO = '#piece_row_detail_group.emir_no#'
                 	</cfquery>
       		        <cfoutput query="piece_row_detail_group">
       		          	<tr>
       		                <td style="text-align:center" >#piece_row_detail_group.currentrow#</td>
       		                <td style="text-align:center" >#get_info.LOT_NO#</td>
       		                <td style="text-align:center" >#piece_row_detail_group.emir_no#</td>
       		                <td style="text-align:left" >#get_info.PIECE_NAME#</td>
       		                <td style="text-align:right" >#piece_row_detail_group.amount#</td>
       		                <td style="text-align:right" >#piece_row_detail_group.width#</td>
       		                <td style="text-align:right" >#piece_row_detail_group.height#</td>
       		            </tr>
       		        </cfoutput>
       		    </cfif>
       		</tbody>
       	</cf_grid_list>
	</cf_box>
	<cf_box>
    	<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        	<cfoutput>
           		<h3>Tabaka : #attributes.sheet_name# - No: #attributes.sheet_no# (Fire: #attributes.fire_percent#%)</h3>
              	<svg xmlns="http://www.w3.org/2000/svg" width="#sheetWidth#" height="#sheetHeight#" style="border:1px solid silver; margin-bottom:40px; background-color:silver;">
               		<text x="20" y="25" class="sheetTitle">#attributes.sheet_name# / Tabaka #attributes.sheet_no#</text>
              		<!---<cfloop query="piece_row_detail">
                        <!-- Dikdörtgen -->
                        <rect 
                            x="#piece_row_detail.x_point#" 
                            y="#piece_row_detail.y_point#" 
                            width="#piece_row_detail.width#" 
                            height="#piece_row_detail.height#" 
                            fill="##{lcase(hash(piece_row_detail.piece)) mod 999999}" 
                            stroke="black" 
                            stroke-width="1" />
                    
                        <!-- Emir No -->
                        <text x="#piece_row_detail.x_point+5#" 
                              y="#piece_row_detail.y_point+15#" 
                              class="pieceText">#piece_row_detail.emir_no#</text>
                    
                        <!-- Ölçü Yazıları -->
                        <!-- Üst kenar uzunluğu -->
                        <text x="#piece_row_detail.x_point + (piece_row_detail.width/2 - 15)#"
                              y="#piece_row_detail.y_point - 3#"
                              font-size="10"
                              fill="black">
                            #piece_row_detail.width# mm
                        </text>
                    
                        <!-- Sol kenar uzunluğu (dikey yazı) -->
                        <text x="#piece_row_detail.x_point - 3#" 
                              y="#piece_row_detail.y_point + (piece_row_detail.height/2)#" 
                              transform="rotate(-90,#piece_row_detail.x_point-3#,#piece_row_detail.y_point + (piece_row_detail.height/2)#)" 
                              font-size="10"
                              fill="black">
                            #piece_row_detail.height# mm
                        </text>
                    </cfloop>--->

                    
                                                                                          
            		<!-- Her parça için dikdörtgen çiz -->
              		<cfloop query="piece_row_detail">
                                                                                                      
                   		<rect 
                         	x="#piece_row_detail.x_point#" 
                         	y="#piece_row_detail.y_point#" 
                         	width="#piece_row_detail.width#" 
                        	height="#piece_row_detail.height#" 
                          	fill="" 
                       		stroke="black" 
                       		stroke-width="1" />
                                                                                                              
                  		<text x="#piece_row_detail.x_point+5#" y="#piece_row_detail.y_point+15#" class="pieceText">
                        	#piece_row_detail.emir_no#
                    	</text>
              		</cfloop>
           		</svg>
   			</cfoutput>
        </div>
	</cf_box>
</cfif>