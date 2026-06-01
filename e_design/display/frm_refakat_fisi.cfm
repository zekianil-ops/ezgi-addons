<!---
    File: frm_refakat_fisi.cfm
    Folder: Add_Ons\ezgi\e-design\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<!---<cfinclude template="/addOns/ezgi/e_design/query/get_ezgi_product_tree_creative_station_time.cfm">--->
<!---<cfinclude template="/addOns/ezgi/e_design/query/get_ezgi_product_tree_creative_material.cfm">--->
<cfquery name="get_material" datasource="#dsn3#">
	SELECT 
    	PRODUCT_NAME,
        MAIN_UNIT,
        SUM(AMOUNT) AMOUNT
  	FROM (
			SELECT        
            	E.AMOUNT, 
                E.PIECE_ROW_ROW_TYPE, 
                S.PRODUCT_NAME, 
                PU.MAIN_UNIT
			FROM         
            	EZGI_DESIGN_PIECE_ROW AS E INNER JOIN
             	STOCKS AS S ON E.STOCK_ID = S.STOCK_ID INNER JOIN
             	PRODUCT_UNIT AS PU ON S.PRODUCT_ID = PU.PRODUCT_ID
			WHERE        
            	E.PIECE_ROW_ID = #attributes.design_piece_row_id# AND 
                PU.IS_MAIN = 1
			UNION ALL
			SELECT        
            	E.AMOUNT, 
                E.PIECE_ROW_ROW_TYPE, 
                EE.PIECE_NAME, 
                'Adet' AS MAIN_UNIT
			FROM            
          		EZGI_DESIGN_PIECE_ROW AS E INNER JOIN
              	EZGI_DESIGN_PIECE_ROWS AS EE ON E.RELATED_PIECE_ROW_ID = EE.PIECE_ROW_ID
			WHERE        
            	E.PIECE_ROW_ID = #attributes.design_piece_row_id# AND 
                E.PIECE_ROW_ROW_TYPE = 4
      	) AS TBL
  	GROUP BY
    	PRODUCT_NAME,
        MAIN_UNIT
</cfquery>
<cfquery name="station_time_cal_group" datasource="#DSN3#">
	SELECT 
    	ER.OPERATION_TYPE_ID, 
        ER.SIRA, 
        OT.OPERATION_TYPE
	FROM     
    	EZGI_DESIGN_PIECE_ROTA AS ER INNER JOIN
        OPERATION_TYPES AS OT ON ER.OPERATION_TYPE_ID = OT.OPERATION_TYPE_ID
	WHERE  
    	ER.PIECE_ROW_ID = #attributes.design_piece_row_id#
	ORDER BY 
    	ER.SIRA
</cfquery>
<table cellpadding="0" cellspacing="0" style="height:139mm; width:200mm">
    <tr><td colspan="2" style="height:2mm"></td></tr>
    <tr>
		<td style="width:4mm"></td>
        <td>
      		<table border="1" bordercolor="black" cellpadding="1" cellspacing="0" style="height:138mm; width:200mm;">
             	<tr>
                	<td style="width:140mm;height:136mm" valign="top">
                     	<table bordercolor="black" cellpadding="1" cellspacing="0" border="0">
                         	<tr>
                           		<td rowspan="2" class="thc" style="text-align:center;height:8mm;width:40mm">
                                	<cfif len(CHECK.asset_file_name3)>
										<cfoutput><img src="#user_domain##file_web_path#settings/#CHECK.asset_file_name3#" border="0"></cfoutput>
                                  	</cfif>
                              	</td>
                                <td colspan="6" class="thc" style="text-align:center; width:98mm"><span class="Baslik1"><cf_get_lang dictionary_id="191.Üretim Takip Formu	"></span></td>
                         	</tr>
                         	<tr>
                           		<td colspan="6" class="thc" style="text-align:center;">
                                	<span class="Baslik3">
										<cfoutput>#DESIGN_MAIN_NAME# #left(get_product_print.PIECE_NAME,90)#</cfoutput>
                                   	</span>
                              	</td>
                         	</tr>
                          	<tr>
                          		<td class="thc" style="text-align:center;" rowspan="2">
                                	<cfoutput>
                                    	<span class="Baslik2">
                                    		<cfif isdefined('get_p_orders.P_ORDER_NO') and isdefined('get_product_print.PIECE_ROW_ID')>
                                            	<cfset id_boy = len(get_product_print.PIECE_ROW_ID)>
                                                <cfset ek_barcode = get_product_print.PIECE_ROW_ID>
                                                <cfset dongu = 6 - id_boy>
                                                <cfif dongu gt 0>
                                                    <cfloop from="1" to="#dongu#" index="i">
                                                    	<cfset ek_barcode = '0#ek_barcode#'>
                                                    </cfloop>
                                                </cfif>
                                            	<cf_workcube_barcode type="code128" value="#get_p_orders.P_ORDER_NO##ek_barcode#" show="1" width="40" height="20"><br>
                                            	#get_p_orders.P_ORDER_NO##ek_barcode#
                                            <cfelse>
                                            	<cf_workcube_barcode type="code128" value="#DateFormat(now(), 'DDMMYYYY')#" show="1" width="40" height="20"><br>
                                                #DateFormat(now(), 'DDMMYYYY')#
                                            </cfif>
                                   	 	</span>
                               		</cfoutput>
                           		</td>
                             	<td class="thc" style="text-align:center; width:24mm; height:5mm"><span class="Baslik2"><cf_get_lang dictionary_id="192.Emir Miktarı"></span></td>
                              	<td class="thc" style="text-align:center; width:17mm"><span class="Baslik2"><cf_get_lang dictionary_id="193.Kesim Boy"></span></td>
                            	<td class="thc" style="text-align:center; width:17mm"><span class="Baslik2"><cf_get_lang dictionary_id="194.Kesim En"></span></td>
                           		<td class="thc" style="text-align:center; width:17mm"><span class="Baslik2"><cf_get_lang dictionary_id="195.Net Boy"></span></td>
                            	<td class="thc" style="text-align:center; width:17mm"><span class="Baslik2"><cf_get_lang dictionary_id="196.Net En"></span></td>
                         	</tr>
                          	<tr>
                            	<td class="thc" style="text-align:center; width:8mm">
                                 	<span class="Baslik1">
										<cfoutput>
                                        	<cfif isnumeric(attributes.product_quantity)>
                                           		#PIECE_AMOUNT * attributes.product_quantity#
                                         	</cfif>
										</cfoutput>
                                	</span>
                            	</td>
                             	<td class="thc" style="text-align:center">
                                	<span class="Baslik2"><cfif len(#KESIM_BOYU#)><cfoutput>#KESIM_BOYU# mm.</cfoutput><cfelse>&nbsp;</cfif></span>
                               	</td>
                             	<td class="thc" style="text-align:center">
                                	<span class="Baslik2"><cfif len(#KESIM_ENI#)><cfoutput>#KESIM_ENI# mm.</cfoutput><cfelse>&nbsp;</cfif></span>
                               	</td>
                            	<td class="thc" style="text-align:center">
                                	<span class="Baslik2"><cfif len(#BOYU#)><cfoutput>#BOYU# mm.</cfoutput><cfelse>&nbsp;</cfif></span>
                               	</td>
                             	<td class="thc" style="text-align:center">
                                	<span class="Baslik2"><cfif len(#ENI#)><cfoutput>#ENI# mm.</cfoutput><cfelse>&nbsp;</cfif></span>
                              	</td>
                         	</tr>
                       		<tr>
                             	<td class="thc" style="text-align:center;height:5mm"><span class="Baslik2"><cf_get_lang dictionary_id="695.Plan No"></span></td>
                             	<td class="thc" style="text-align:center"><span class="Baslik2"><cf_get_lang dictionary_id="197.M. Cinsi"> </span></td>
                              	<td class="thc" style="text-align:center"><span class="Baslik2"><cf_get_lang dictionary_id="36554.Renk"></span></td>
                              	<td class="thc" style="text-align:center"><span class="Baslik2"><cf_get_lang dictionary_id="75.Kalınlık"></span></td>
                              	<td class="thc" style="text-align:center"><span class="Baslik2"><cf_get_lang dictionary_id="400.Paket No"></span></td>
                              	<td class="thc" style="text-align:center"><span class="Baslik2"><cf_get_lang dictionary_id="844.Parça No"></span></td>
                         	</tr>
                           	<tr>
                             	<td class="thc" style="text-align:center;height:8mm">
                                	<span class="Baslik1">
                                    	<cfif isdefined('get_p_orders.MASTER_PLAN_NUMBER')>
											<cfoutput>#get_p_orders.MASTER_PLAN_NUMBER#</cfoutput>
                                     	<cfelse>
                                         	<cfoutput>#DateFormat(now(), 'DDMMYYYY')#</cfoutput>
                                     	</cfif>
                                 	</span>
                            	</td>
                             	<td class="thc" style="text-align:center">
                                	<span class="Baslik2">
										<cfif isdefined('PRODUCT_CAT_#MATERIAL_ID#')><cfoutput>#Evaluate('PRODUCT_CAT_#MATERIAL_ID#')# </cfoutput><cfelse>&nbsp;</cfif>
                                  	</span>
                           		</td>
                             	<td class="thc" style="text-align:center">
                                	<span class="Baslik2">
										<cfif isdefined('COLOR_NAME_#PIECE_COLOR_ID#')><cfoutput>#Evaluate('COLOR_NAME_#PIECE_COLOR_ID#')# </cfoutput><cfelse>&nbsp;</cfif>
                                 	</span>
                              	</td>
                                <td class="thc" style="text-align:center">
                                	<span class="Baslik2" style="height:5mm"><cfoutput>#KALINLIK_#</cfoutput></span>
                               	</td>
                             	<td class="thc" style="text-align:center">
                                	<span class="Baslik2" style="height:5mm"><cfoutput><cfif USED_AMOUNT neq 0>K-#USED_AMOUNT#<cfelse>#PACKAGE_NUMBER#</cfif></cfoutput></span>
                              	</td>
                              	<td class="thc" style="text-align:center"><span class="Baslik2" style="height:5mm"><cfoutput>#PIECE_CODE#</cfoutput></span></td>
                          	</tr>
                           	<tr>
                           		<td valign="top"  colspan="6">
                                	<table bordercolor="black" cellpadding="1" cellspacing="0" border="0" width="100%">
                                    	<tr bgcolor="white">
                                        	<td class="thc" style="text-align:center;height:8mm; width:40mm"><span class="Baslik4"><cf_get_lang dictionary_id="57475.Mail Gönder"></span></td>
                                          	<td class="thc" style="text-align:center;width:14mm"><span class="Baslik4"><cf_get_lang dictionary_id="29513.Süre"></span></td>
                                        	<td rowspan="12" align="center" valign="middle" class="thc">
                                            	<cfquery name="get_pvc" datasource="#dsn3#">
                                                  	SELECT        
                                                     	E.STOCK_ID, 
                                                       	E.AMOUNT, 
                                                     	E.SIRA_NO, 
                                                      	S.PRODUCT_NAME, 
                                                      	E.PIECE_ROW_ID
													FROM            
                                                     	EZGI_DESIGN_PIECE_ROW AS E INNER JOIN
                         								STOCKS AS S ON E.STOCK_ID = S.STOCK_ID
													WHERE        
                                                    	E.PIECE_ROW_ID = #attributes.design_piece_row_id# AND 
                                                     	E.PIECE_ROW_ROW_TYPE = 1
                                                </cfquery>
                                            	<cfif PIECE_TYPE eq 1 and get_pvc.recordcount>
                                               		<cfoutput query="get_pvc">
                                                     	<cfset 'PRODUCT_NAME_#PIECE_ROW_ID#_#SIRA_NO#' = PRODUCT_NAME>
                                                      	<cfset 'AMOUNT_#PIECE_ROW_ID#_#SIRA_NO#' = AMOUNT>
                                                  	</cfoutput>
                                                 	<table width="100%" border="0">
                                                     	<cfoutput>
                                                         	<tr valign="top">
                                                             	<td rowspan="3" class="text_1" style=" width:17mm; height::100%" >
                                                                 	<cfif isdefined('PRODUCT_NAME_#PIECE_ROW_ID#_3')>
                                                                     	<div style="writing-mode:tb-rl;filter:fliph flipv">#Evaluate('PRODUCT_NAME_#PIECE_ROW_ID#_3')#</div>
                                                                	<cfelse>
                                                                     	&nbsp;
                                                                	</cfif>
                                                             	</td>
                                                             	<td class="text_1" style="height:10mm; width:100%" >
                                                               		<cfif isdefined('PRODUCT_NAME_#PIECE_ROW_ID#_1')>
                                                                    	#Evaluate('PRODUCT_NAME_#PIECE_ROW_ID#_1')#
                                                                 	<cfelse>
                                                                     	&nbsp;
                                                                	</cfif>
                                                              	</td>
                                                           		<td rowspan="3" class="text_1" style=" width:17mm; height::100%" >
                                                                 	<cfif isdefined('PRODUCT_NAME_#PIECE_ROW_ID#_4')>
                                                                     	<div style="writing-mode:tb-rl;filter:fliph flipv">#Evaluate('PRODUCT_NAME_#PIECE_ROW_ID#_4')#</div>
                                                                  	<cfelse>
                                                                      	&nbsp;
                                                                   	</cfif>
                                                              	</td>
                                                        	</tr>        
                                                        	<tr valign="top">             
                                                            	<td class="beyaz_3" style=" width:60mm" >
                                                                	<table bordercolor="black" cellpadding="0" cellspacing="0" border="0">
                                                                     	<tr>
                                                                        	<td class="Beyaz_3" style="height:30mm; width:60mm">
                                                                             	<cfif IS_FLOW_DIRECTION eq 1>
                                                                                  	<cfset s_1 = '='>
                                                                             	<cfelseif IS_FLOW_DIRECTION eq 0>
                                                                                  	<cfset s_1 = '||'>
                                                                            	<cfelse>
                                                                               		<cfset s_1 = ''>           
                                                                             	</cfif>
                                                                           		#s_1# 
                                                                       		</td>
                                                                     	</tr>
                                                                	</table>
                                                             	</td>
                                                          	</tr>
                                                         	<tr valign="top">
                                                            	<td class="text_1" style="height:10mm; width:100%" > 
                                                                	<cfif isdefined('PRODUCT_NAME_#PIECE_ROW_ID#_2')>
                                                                    	#Evaluate('PRODUCT_NAME_#PIECE_ROW_ID#_2')#
                                                                	<cfelse>
                                                                   		&nbsp;
                                                                 	</cfif>
                                                             	</td>
                                                         	</tr>
                                                       		<tr valign="top">
                                                             	<td colspan="3" style="height:8mm; text-align:center; vertical-align:middle">
                                                                  	Traşlama : <cfif TRIM_SIZE gt 0>#AmountFormat(TRIM_SIZE,1)#<cfelse>Yok</cfif>
                                                             	</td>
                                                        	</tr>  
                                                     	</cfoutput>
                                                	</table>
                                            	</cfif>
                                        	</td>
                                     	</tr>
                                    	<cfset i=1>
                                   		<cfif station_time_cal_group.recordcount gt 0>
                                        	<cfloop query="station_time_cal_group" startrow="1" endrow="11">
                                             	<tr>
                                                  	<td class="thc" style="text-align:center;height:4mm">
                                                    	<span class="icerik1">
															<cfif station_time_cal_group.recordcount>
																<cfoutput>&nbsp;#station_time_cal_group.OPERATION_TYPE#</cfoutput>
                                                            <cfelse>
                                                            	&nbsp;
                                                            </cfif>
                                                       	</span>
                                                  	</td>
                                                	<td class="thc" style="text-align:right;" >
                                                     	<span class="icerik1">

                                                     	</span>
                                                	</td>
                                             	</tr>
                                        	</cfloop>
                                     	</cfif>
                                     	<cfif station_time_cal_group.recordcount lt 11>
                                         	<cfset tur = 11 - station_time_cal_group.recordcount>
                                           	<cfloop from="1" to="#tur#" index="kz">
                                             	<tr>
                                                 	<td class="thc" style="text-align:center;height:4mm"><span class="icerik1">&nbsp;</span></td>
                                                 	<td class="thc">&nbsp;</td>
                                             	</tr>
                                        	</cfloop>
                                  		</cfif>
                                	</table>
                            	</td>
                        	</tr>  	    
                         	<tr>
                             	<td class="thc" colspan="6">
									<cfoutput>
                                     	#PIECE_DETAIL#<br>
                                     	<cfif isdefined('get_p_orders.DETAIL')>
                                         	#get_p_orders.DETAIL#
                                     	</cfif>
									</cfoutput> 
                              	</td>
                          	</tr>	
                      	</table>
                   	</td>
                 	<td align="center" valign="top" style=" width:58mm">
                      	<table bordercolor="black" cellpadding="1" cellspacing="0" border="0" width="100%">
                         	<tr>
                            	<td colspan="4" valign="top">
                               		<table width="100%" border="0">
                                    	<tr>
                                       		<td style="height:7mm; width:80%" align="left" valign="middle"><span class="Baslik4"><cf_get_lang dictionary_id="198.Kullanılan Malzeme"></span></td>
                                       		<td align="right" valign="middle"><span class="Baslik4"><cf_get_lang dictionary_id="57635.Miktar"></span></td>
                                     	</tr>
                                      	<cfset i=2>
                                       	<cfset ii=1>
                                       	<cfif get_material.recordcount>
                                           	<cfset i=2>
                                          	<cfset ii=1>
                                          	<cfloop from=1 to=12 index="i">
                                              	<tr>
                                                	<td bgcolor="White" style="text-align:left; height:3mm" >
                                                    	<span class="icerik2">
															<cfif get_material.recordcount gte ii>
                                                            	&nbsp;&nbsp;<cfoutput>#get_material.PRODUCT_NAME[ii]#</cfoutput>
                                                           	<cfelse>
                                                            	&nbsp;
                                                            </cfif>
                                                       	</span>
                                                   	</td>
                                               		<td bgcolor="White" style="text-align:right;">
                                                    	<span class="icerik2">
															<cfif get_material.recordcount gte ii>
																<cfoutput>#AmountFormat(get_material.AMOUNT[ii])# #get_material.MAIN_UNIT[ii]#</cfoutput>&nbsp;&nbsp;
                                                           	<cfelse>
                                                            	&nbsp;
                                                            </cfif>
                                                      	</span>
                                                  	</td>        
                                              	</tr>
                                             	<cfset ii=ii+1>
                                              	<tr>
                                                	<td bgcolor="Gainsboro" style="text-align:left; height:3mm" >
                                                    	<span class="icerik2">
															<cfif get_material.recordcount gte ii>
                                                            	&nbsp;&nbsp;<cfoutput>#get_material.PRODUCT_NAME[ii]#</cfoutput>
                                                            <cfelse>
                                                            	&nbsp;
                                                            </cfif>
                                                      	</span>
                                                  	</td>
                                               		<td bgcolor="Gainsboro" style="text-align:right;">
                                                    	<span class="icerik2">
															<cfif get_material.recordcount gte ii>
																<cfoutput>#AmountFormat(get_material.AMOUNT[ii])# #get_material.MAIN_UNIT[ii]#</cfoutput>&nbsp;&nbsp;
                                                           	<cfelse>
                                                            	&nbsp;
                                                            </cfif>
                                                       	</span>
                                                   	</td>        
                                               	</tr> 
                                           		<cfset ii=ii+1>       
                                          	</cfloop>
                                       	</cfif>
                                  	</table>
                            	</td>
                          	</tr>		
                     	</table>
                	</td>
               	</tr>													
           	</table>
       	</td>
   	</tr>
</table>
<p style="page-break-before: always"></p>
    