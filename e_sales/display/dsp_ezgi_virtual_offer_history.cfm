<!---
    File: dsp_ezgi_virtual_offer_history.cfm
    Folder: Add_Ons\ezgi\e_sales\display
    Author: Ezgi Yazılım
    Date: 01/10/2024
    Description:
--->

<style>
	.baslik {
	text-align:left;
	background-color: #CCC;
	font-weight: bold;
	font-size:10px
	}
	.icerik {
	text-align:left;
	font-weight: normal;
	font-size:10px;
	background-color:#FFF
	}
	.resim {
	text-align:center;
	background-color:#FFF
	}
</style>	
<cfquery name="get_virtual_offers" datasource="#DSN3#">
	SELECT
    	*
  	FROM
    	EZGI_VIRTUAL_OFFER_HISTORY
   	WHERE 
    	VIRTUAL_OFFER_ID = #attributes.virtual_offer_id#
</cfquery>
<!---<cfdump var="#get_virtual_offers#">--->
<!---<cfquery name="get_virtual_offer_row" datasource="#DSN3#">

</cfquery>--->
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<cf_box>
    	<cf_grid_list sort="1">
			<thead>
             	<tr>
               	  <th style="width:40px"><cf_get_lang dictionary_id='55657.Sıra No'></th>
                    <th><cf_get_lang dictionary_id='58820.Başlık'></th>
                  <th><cf_get_lang dictionary_id='58859.Süreç'></th>
                    <th><cf_get_lang dictionary_id='57891.Güncelleyen'></th>
                    <th><cf_get_lang dictionary_id='57742.Tarih'></th>
           	  </tr>
        	</thead>
            <tbody>
            	<cfif get_virtual_offers.recordcount>
                	<cfoutput query="get_virtual_offers">
                    	<cfset branch_name = ''>
                        <cfset project_name = ''>
                        <cfset paymethod_name = ''>
                        <cfset dept_name = "">
                    	<cfquery name="GET_PROCESS_TYPE" datasource="#DSN#">
                            SELECT
                              	STAGE
                            FROM
                                PROCESS_TYPE_ROWS
                            WHERE
                                PROCESS_ROW_ID = #get_virtual_offers.VIRTUAL_OFFER_STAGE#
                        </cfquery>
                        <cfif len(get_virtual_offers.branch_id)>
                            <cfquery name="get_branch" datasource="#dsn#">
                                SELECT 
                                    BRANCH_NAME 
                                FROM 
                                    BRANCH 
                                WHERE 
                                    BRANCH_ID = #get_virtual_offers.branch_id#
                            </cfquery>
                            <cfset branch_name = get_branch.BRANCH_NAME>
                        </cfif>
                        <cfif len(get_virtual_offers.PROJECT_ID)>
                            <cfquery name="get_project" datasource="#dsn#">
                            
                            	SELECT 
                                	PROJECT_HEAD
								FROM     
                                	PRO_PROJECTS
								WHERE  
                                	PROJECT_ID = #get_virtual_offers.PROJECT_ID#
                            </cfquery>
                            <cfset project_name = get_project.PROJECT_HEAD>
                        </cfif>
                        
                        <cfif len(get_virtual_offers.PAYMETHOD)>
                            <cfquery name="get_paymethod" datasource="#dsn#">
                            	SELECT 
                                	PAYMETHOD
								FROM     
                                	SETUP_PAYMETHOD
								WHERE  
                                	PAYMETHOD_ID = #get_virtual_offers.PAYMETHOD#
                            </cfquery>
                            <cfset paymethod_name = get_paymethod.PAYMETHOD>
                        </cfif>
                        
                        <cfif len(get_virtual_offers.DELIVER_DEPT_ID) and len(get_virtual_offers.LOCATION_ID)>
                            <cfquery name="get_dept" datasource="#dsn#">
                            	SELECT 
                                	D.DEPARTMENT_HEAD + ' - ' + SL.COMMENT AS DEPO
								FROM     
                                	STOCKS_LOCATION AS SL INNER JOIN
                  					DEPARTMENT AS D ON SL.DEPARTMENT_ID = D.DEPARTMENT_ID
								WHERE  
                                	SL.DEPARTMENT_ID = #get_virtual_offers.DELIVER_DEPT_ID# AND 
                                    SL.LOCATION_ID = #get_virtual_offers.LOCATION_ID#
                            </cfquery>
                            <cfset dept_name = get_dept.DEPO>
                        </cfif>
                        
                        <cfif len(get_virtual_offers.SHIP_METHOD)>
                        	<cfset attributes.ship_method = get_virtual_offers.SHIP_METHOD>
                        	<cfinclude template="../../../../v16/sales/query/get_ship_method.cfm">
                       		<cfset ship_method = GET_SHIP_METHOD.SHIP_METHOD>
                     	<cfelse>
                         	<cfset ship_method = ''>
                     	</cfif>
                        <cfquery name="get_virtual_offer_row" datasource="#DSN3#">
							SELECT * FROM EZGI_VIRTUAL_OFFER_ROW_HISTORY WHERE HISTORY_VIRTUAL_OFFER_ID = #get_virtual_offers.HISTORY_VIRTUAL_OFFER_ID#
						</cfquery>
                    	<tr> 
                        	<td style="text-align:right">#currentrow#</td>
                            <td style="text-align:left">
                            	<a style="cursor:pointer" onclick="seviyelendir(#currentrow#);">
                           		#Left(get_virtual_offers.VIRTUAL_OFFER_HEAD,240)#
                             	</a>
                            </td>
                            <td style="text-align:left">#GET_PROCESS_TYPE.STAGE#</td>
                            <td style="text-align:left">#get_emp_info(get_virtual_offers.UPDATE_EMP,0,0)#</td>
                            <td style="text-align:center">#DateFormat(get_virtual_offers.UPDATE_DATE,dateformat_style)#</td>
                     	</tr>
                        <tr style="display:none" id="frm_row_#currentrow#">
                        	<td style="text-align:right" colspan="5">
                            	<table style="width:100%" cellspacing="0" cellpadding="2" border="1">
                                	<tr height="15px">
                                    	<td class="baslik" style="width:7%"><cf_get_lang dictionary_id='57493.Aktif'></td>
                                        <td class="resim" style="width:18%">
                                        	<cfif get_virtual_offers.VIRTUAL_OFFER_STATUS eq 1>
                                            	<img src="images/production/true.png" width="15px" border="0">
                                            <cfelse>
                                            	<img src="images/production/false.png" width="15px" border="0">
                                            </cfif>
                                        </td>
                                        <td class="baslik" style="width:7%">Yurt Dışı</td>
                                        <td class="resim" style="width:18%">
                                        	<cfif get_virtual_offers.IS_FOREIGN eq 1>
                                            	<img src="images/production/true.png" width="15px" border="0">
                                            <cfelse>
                                            	<img src="images/production/false.png" width="15px" border="0">
                                            </cfif>
                                        </td>
                                        <td class="baslik" style="width:7%"></td>
                                        <td class="icerik" style="width:18%"></td>
                                        <td class="baslik" style="width:7%"></td>
                                        <td class="icerik" style="width:18%"></td>
                                    </tr>
                                    <tr height="15px">
                                    	<td class="baslik" style="width:7%"><cf_get_lang dictionary_id='58820.Başlık'></td>
                                        <td class="icerik" style="width:18%">#get_virtual_offers.VIRTUAL_OFFER_HEAD#</td>
                                        <td class="baslik" style="width:7%"><cf_get_lang dictionary_id='46831.Teklif Tarihi'></td>
                                        <td class="icerik" style="width:18%">#DateFormat(get_virtual_offers..virtual_offer_date,dateformat_style)#</td>
                                        <td class="baslik" style="width:7%"><cf_get_lang_main no='41.Şube'></td>
                                        <td class="icerik" style="width:18%">#branch_name#</td>
                                        <td class="baslik" style="width:7%"><cf_get_lang dictionary_id='41422.Bayi Adı'></td>
                                        <td class="icerik" style="width:18%">#get_par_info(get_virtual_offers.PARTNER_COMPANY_ID,0,-1,0)#</td>
                                    </tr>
                                    
                                    <tr height="15px">
                                    	<td class="baslik" style="width:7%"><cf_get_lang dictionary_id='57519.Cari Hesap'></td>
                                        <td class="icerik" style="width:18%">
                                        	<cfif isdefined('get_virtual_offers.company_id') and len(get_virtual_offers.company_id)>
                                            	#get_par_info(get_virtual_offers.company_id,1,1,0)#
											<cfelseif isdefined('get_virtual_offers.consumer_id') and len(get_virtual_offers.consumer_id)>
                                            	#get_cons_info(get_virtual_offers.consumer_id,0,0)#
                                            </cfif>
                                        </td>
                                        <td class="baslik" style="width:7%"><cf_get_lang dictionary_id='1196.Üretim Çıkış Tarihi'></td>
                                        <td class="icerik" style="width:18%">#DateFormat(get_virtual_offers.DELIVERDATE,dateformat_style)#</td>
                                        <td class="baslik" style="width:7%"><cf_get_lang dictionary_id='58763.Depo'></td>
                                        <td class="icerik" style="width:18%">#dept_name#</td>
                                        <td class="baslik" style="width:7%"><cf_get_lang dictionary_id='57629.Açıklama'></td>
                                        <td class="icerik" style="width:18%">#get_virtual_offers.virtual_offer_DETAIL#</td>
                                    </tr>
                                    
                                    <tr height="15px">
                                    	<td class="baslik" style="width:7%"><cf_get_lang dictionary_id='57578.Yetkili'></td>
                                        <td class="icerik" style="width:18%">
                                        	<cfif isdefined('get_virtual_offers.partner_id') and len(get_virtual_offers.partner_id)>
                                            	#get_par_info(get_virtual_offers.partner_id,0,-1,0)#
											<cfelseif isdefined('get_virtual_offers.consumer_id') and len(get_virtual_offers.consumer_id)>
                                            	#get_cons_info(get_virtual_offers.consumer_id,0,0,0)#
                                            </cfif>
                                        </td>
                                        <td class="baslik" style="width:7%"><cf_get_lang dictionary_id='57747.Sözleşme Tarihi'></td>
                                        <td class="icerik" style="width:18%">#DateFormat(get_virtual_offers.FINISHDATE,dateformat_style)#</td>
                                        <td class="baslik" style="width:7%"><cf_get_lang_main no ='228.Vade'></td>
                                        <td class="icerik" style="width:18%">#DateFormat(get_virtual_offers.DUE_DATE,dateformat_style)#</td>
                                        <td class="baslik" style="width:7%"><cf_get_lang dictionary_id='57416.Proje'></td>
                                        <td class="icerik" style="width:18%">#project_name#</td>
                                    </tr>
                                    
                                    <tr height="15px">
                                    	<td class="baslik" style="width:7%"><cf_get_lang dictionary_id='41159.Satış Çalışanı'></td>
                                        <td class="icerik" style="width:18%">
											<cfif Len(get_virtual_offers.VIRTUAL_OFFER_EMPLOYEE_ID)>
                                            	#get_emp_info(get_virtual_offers.VIRTUAL_OFFER_EMPLOYEE_ID,0,0)#
                                            </cfif>
                                       	</td>
                                        <td class="baslik" style="width:7%"><cf_get_lang_main no='1703.Sevk Yontemi'></td>
                                        <td class="icerik" style="width:18%">#ship_method#</td>
                                        <td class="baslik" style="width:7%"><cf_get_lang dictionary_id="58859.Süreç"></td>
                                        <td class="icerik" style="width:18%">#GET_PROCESS_TYPE.STAGE#</td>
                                        <td class="baslik" style="width:7%"><cf_get_lang dictionary_id='58516.Ödeme Yontemi'></td>
                                        <td class="icerik" style="width:18%">#paymethod_name#</td>
                                    </tr>
                                </table>
                                <cfif get_virtual_offer_row.recordcount>
                                    <table style="width:100%" cellspacing="0" cellpadding="2" border="1">
                                    	<tr>
                                        	<td class="baslik" style="width:35px; text-align:right">S.No</td>
                                            <td class="baslik" style="width:85px; text-align:center"><cf_get_lang dictionary_id="57756.Durum"></td>
                                            <td class="baslik" style="width:45px; text-align:center"><cf_get_lang dictionary_id="99.Boy"></td>
                                            <td class="baslik" style="width:45px; text-align:center"><cf_get_lang dictionary_id="98.En"></td>
                                            <td class="baslik" style="width:45px; text-align:center"><cf_get_lang dictionary_id="45200.Derinlik"></td>
                                            <td class="baslik" style="width:65px; text-align:center"><cf_get_lang dictionary_id="50847.Taraf"></td>
                                            <td class="baslik" style="text-align:center"><cf_get_lang dictionary_id="57564.Ürünler"></td>
                                            <td class="baslik" style="width:65px; text-align:center"><cf_get_lang dictionary_id="57635.Miktar"></td>
                                            <td class="baslik" style="width:55px; text-align:center"><cf_get_lang dictionary_id="57636.Birim"></td>
                                            <td class="baslik" style="width:75px; text-align:center"><cf_get_lang dictionary_id="57638.Birim Fiyat"></td>
                                            <td class="baslik" style="width:75px; text-align:center"><cf_get_lang dictionary_id="51716.Hizmetler"></td>
                                            <td class="baslik" style="width:45px; text-align:center"><cf_get_lang dictionary_id="57677.Döviz"></td>
                                            <td class="baslik" style="width:75px; text-align:center"><cf_get_lang dictionary_id="57641.İskonto"></td>
                                            <td class="baslik" style="width:35px; text-align:center">İsk 1</td>
                                            <td class="baslik" style="width:35px; text-align:center">İsk 2</td>
                                            <td class="baslik" style="width:35px; text-align:center">İsk 3</td>
                                        </tr>
                                    	<cfLOOP query="get_virtual_offer_row">
                                        	<tr height="20" id="frm_row#currentrow#">
        	            						<td class="icerik" nowrap style="text-align:right;">#currentrow#</td>
                                                <td class="icerik" nowrap style="text-align:center;">
                                                	<cfif VIRTUAL_OFFER_ROW_CURRENCY eq 3>
                                                    	<cf_get_lang dictionary_id='40941.İşlendi'>
                                                 	<cfelseif VIRTUAL_OFFER_ROW_CURRENCY eq 1>
                                                    	<cf_get_lang dictionary_id='58717.Açık'>
                                                   	<cfelseif VIRTUAL_OFFER_ROW_CURRENCY eq 4> 
                                                    	<cf_get_lang dictionary_id='41522.Son Onay'>   
                                                  	<cfelseif VIRTUAL_OFFER_ROW_CURRENCY eq 2> 
                                                    	<cf_get_lang dictionary_id='30975.Onaylandı'>
                                                  	<cfelseif VIRTUAL_OFFER_ROW_CURRENCY eq 9>
                                                    	<cf_get_lang dictionary_id='58506.İptal'>
                                                  	</cfif>
                                             	</td>
                                                <td class="icerik" nowrap style="text-align:center;">#BOY#</td>
                                                <td class="icerik" nowrap style="text-align:center;">#EN#</td>
                                                <td class="icerik" nowrap style="text-align:center;">#DERINLIK#</td>
                                               	<td class="icerik" nowrap style="text-align:center;"> 
													<cfif yon eq 1>
                                                        <cfsavecontent variable="yon_"><cf_get_lang dictionary_id="82.Sağ"></cfsavecontent>
                                                    <cfelseif yon eq 2>
                                                        <cfsavecontent variable="yon_"><cf_get_lang dictionary_id="85.Sol"></cfsavecontent>
                                                    <cfelseif yon eq 3>
                                                        <cfsavecontent variable="yon_"><cf_get_lang dictionary_id="1297.Dışa Sağ"></cfsavecontent>
                                                    <cfelseif yon eq 4>
                                                        <cfsavecontent variable="yon_"><cf_get_lang dictionary_id="1298.Dışa Sol"></cfsavecontent>
                                                    <cfelse>
                                                        <cfset yon_= ''>
                                                    </cfif>
                                                	#yon_#
                                                </td>
                                                <td class="icerik" nowrap style="text-align:LEFT;">#product_name#</td> 
                                                <td class="icerik" nowrap style="text-align:RIGHT;">#TlFormat(QUANTITY,4)#</td>
                                                <td class="icerik" nowrap style="text-align:LEFT;">#unit#</td>
                                                <td class="icerik" nowrap style="text-align:RIGHT;">#TlFormat(PRICE,4)#</td>
                                                <td class="icerik" nowrap style="text-align:RIGHT;">#TlFormat(COST,4)#</td>
                                                <td class="icerik" nowrap style="text-align:LEFT;">#OTHER_MONEY#</td>
                                                <td class="icerik" nowrap style="text-align:RIGHT;">#TlFormat(DISCOUNT_COST,4)#</td>
                                                <td class="icerik" nowrap style="text-align:center;">#TlFormat(DISCOUNT_1,2)#</td>
                                                <td class="icerik" nowrap style="text-align:center;">#TlFormat(DISCOUNT_2,2)#</td>
                                                <td class="icerik" nowrap style="text-align:center;">#TlFormat(DISCOUNT_3,2)#</td>
                                          	</tr>
                                        </cfLOOP>
                                    </table>
                              	</cfif>
                            </td>
                        </tr>
                    </cfoutput>
              	</cfif>
        	</tbody>
		</cf_grid_list>	
 	</cf_box>
</div>
<script type="text/javascript">
	totalrow = <cfoutput>#get_virtual_offers.recordcount#</cfoutput>;
	function seviyelendir(dsp_row)
	{
		for (var k=1;k<=totalrow;k++)
		{
			document.getElementById("frm_row_"+k).style.display = 'none';
		}
		document.getElementById("frm_row_"+dsp_row).style.display = '';
	}
</script>