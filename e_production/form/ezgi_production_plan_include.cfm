<!---
    File: ezgi_production_plan_include.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfif GET_EZGI_MIP_1.recordcount>
 	<form name="add_production_demand" method="post" action="<cfoutput>#request.self#</cfoutput>?fuseaction=prod.add_ezgi_prod_order&is_collacted=1&<cfoutput>master_plan_id=#attributes.master_plan_id#&master_alt_plan_id=#attributes.master_alt_plan_id#&islem_id=#attributes.islem_id#</cfoutput>">
  		<cfoutput query="GET_EZGI_MIP_1">
        	<cfif isdefined('islem_type') and islem_type eq 1>
            	<cfset EZGI_MIP_STOK = SALEABLE_STOCK - MAXIMUM_STOCK>
            <cfelse>
           		<cfset EZGI_MIP_STOK = 0> 
                <cfif isdefined('PRODUCT_STOCK_#STOCK_ID#')>
                	<cfset EZGI_MIP_STOK = EZGI_MIP_STOK + Evaluate('PRODUCT_STOCK_#STOCK_ID#')>
                </cfif>
				<cfif isdefined('S_STOCK_ARTIR_#STOCK_ID#')>
                	<cfset EZGI_MIP_STOK = EZGI_MIP_STOK + Evaluate('S_STOCK_ARTIR_#STOCK_ID#')>
                </cfif>
                <cfif isdefined('P_STOCK_ARTIR_#STOCK_ID#')>
                	<cfset EZGI_MIP_STOK = EZGI_MIP_STOK + Evaluate('P_STOCK_ARTIR_#STOCK_ID#')>
                </cfif>
              	<cfif isdefined('S_STOCK_AZALT_#STOCK_ID#')>
                	<cfset EZGI_MIP_STOK = EZGI_MIP_STOK - Evaluate('S_STOCK_AZALT_#STOCK_ID#')>
                </cfif>
                <cfif isdefined('P_STOCK_AZALT_#STOCK_ID#')>
                	<cfset EZGI_MIP_STOK = EZGI_MIP_STOK - Evaluate('P_STOCK_AZALT_#STOCK_ID#')>
                </cfif>
                <cfif isdefined('TORBA_MIKTAR_AZALT_#STOCK_ID#')>
                	<cfset EZGI_MIP_STOK = EZGI_MIP_STOK - Evaluate('TORBA_MIKTAR_AZALT_#STOCK_ID#')>
                </cfif>
                <cfif isdefined('TORBA_MIKTAR_ARTIR_#STOCK_ID#')>
                	<cfset EZGI_MIP_STOK = EZGI_MIP_STOK + Evaluate('TORBA_MIKTAR_ARTIR_#STOCK_ID#')>
                </cfif>
         	</cfif>
    		<tr height="20" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
             	<td style="text-align:right">#currentrow#&nbsp;</td>
              	<td style="text-align:right">#GET_EZGI_MIP_1.PRODUCT_CODE#&nbsp;</td>
              	<td>#GET_EZGI_MIP_1.PRODUCT_NAME#&nbsp;</td>
            	<cfif isdefined('islem_type') and islem_type eq 1>
                   
              	<cfelse>	
                  	<td style="text-align:right">#Tlformat(GET_EZGI_MIP_1.MIKTAR,3)#&nbsp;</td>
             	</cfif>
             	<td>#GET_EZGI_MIP_1.MAIN_UNIT#&nbsp;</td>
                <cfif isdefined('islem_type') and islem_type eq 1>
                    <td style="text-align:right">
                        <cfif isdefined('islem_type') and islem_type eq 1>
                            #Tlformat(REAL_STOCK,3)#&nbsp;
                        <cfelse>
                            <cfif isdefined('PRODUCT_STOCK_#STOCK_ID#')>
                                #Tlformat(Evaluate('PRODUCT_STOCK_#STOCK_ID#'),3)#&nbsp;
                            <cfelse>
                                #Tlformat(0,3)#&nbsp;
                            </cfif>
                        </cfif>
                    </td>
                    <td style="text-align:right">
                        <cfif isdefined('islem_type') and islem_type eq 1>
                            #Tlformat(RESERVE_PURCHASE_ORDER_STOCK,3)#&nbsp;
                        <cfelse>
                            <cfif isdefined('S_STOCK_ARTIR_#STOCK_ID#')>
                                #Tlformat(Evaluate('S_STOCK_ARTIR_#STOCK_ID#'),3)#&nbsp;
                             <cfelse>
                                #Tlformat(0,3)#&nbsp;
                            </cfif>
                        </cfif>
                    </td>
                    <td style="text-align:right">
                        <cfif isdefined('islem_type') and islem_type eq 1>
                            #Tlformat(RESERVE_SALE_ORDER_STOCK,3)#&nbsp;
                        <cfelse>
                            <cfif isdefined('S_STOCK_AZALT_#STOCK_ID#')>
                                #Tlformat(Evaluate('S_STOCK_AZALT_#STOCK_ID#'),3)#&nbsp;
                             <cfelse>
                                #Tlformat(0,3)#&nbsp;
                            </cfif>
                        </cfif>
                    </td>
                    <td style="text-align:right">
                        <cfif isdefined('islem_type') and islem_type eq 1>
                            #Tlformat(RESERVED_PROD_STOCK,3)#&nbsp;
                        <cfelse>
                            <cfif isdefined('P_STOCK_AZALT_#STOCK_ID#')>
                                #Tlformat(Evaluate('P_STOCK_AZALT_#STOCK_ID#'),3)#&nbsp;
                             <cfelse>
                                #Tlformat(0,3)#&nbsp;
                            </cfif>
                        </cfif>
                    </td>
                    <td style="text-align:right">
                        <cfif isdefined('islem_type') and islem_type eq 1>
                            #Tlformat(PURCHASE_PROD_STOCK,3)#&nbsp;
                        <cfelse>
                            <cfif isdefined('P_STOCK_ARTIR_#STOCK_ID#')>
                                #Tlformat(Evaluate('P_STOCK_ARTIR_#STOCK_ID#'),3)#&nbsp;
                             <cfelse>
                                #Tlformat(0,3)#&nbsp;
                            </cfif>
                        </cfif>
                    </td>
                	<td style="text-align:right">#Tlformat(GET_EZGI_MIP_1.MAXIMUM_STOCK,3)#&nbsp;</td>
             		<td style="text-align:right"><cfif EZGI_MIP_STOK lt 0><font color="red">#Tlformat(EZGI_MIP_STOK,3)#&nbsp;</font><cfelse>#Tlformat(EZGI_MIP_STOK,3)#&nbsp;</cfif></td>
                </cfif>

             	<td style="text-align:right"><input type="text" name="production_amount_#currentrow#" value="<cfif isdefined('islem_type') and islem_type eq 1><cfif EZGI_MIP_STOK lt 0>#Tlformat(EZGI_MIP_STOK*-1,3)#<cfelse>0</cfif><cfelse>#Tlformat(GET_EZGI_MIP_1.MIKTAR,3)#</cfif>" style="width:60px;" class="box" /> &nbsp;</td>
             	<td style="text-align:center"><input type="checkbox" name="is_active" value="#currentrow#"/></td>
			</tr>
          	<cfset attributes.stock_id=stock_id>
           	<input type="hidden" name="production_start_date_#currentrow#" value="#DateFormat(GET_W.MASTER_PLAN_START_DATE,'DD/MM/YYYY')#">
           	<input type="hidden" name="production_finish_date_#currentrow#" value="#DateFormat(GET_W.MASTER_PLAN_FINISH_DATE,'DD/MM/YYYY')#">
          	<input type="hidden" name="work_prog_#currentrow#" readonly value="#works_prog#" style="width:120px;">
          	<input type="hidden" name="work_prog_id_#currentrow#"  value="#works_prog_id#">
           	<input type="hidden" name="spect_main_id#currentrow#"  value="#SPECT_MAIN_ID#">
         	<input type="hidden" name="spect_main_id"  value="#spect_main_id#">
          	<input type="hidden" name="main_unit#currentrow#"  value="#main_unit#">
        	<input type="hidden" name="STOCK_ID_#currentrow#"  value="#STOCK_ID#">
          	<input type="hidden" name="PRODUCT_NAME_#currentrow#"  value="#PRODUCT_NAME#">
           	<input type="hidden" name="STOCK_CODE_#currentrow#"  value="#PRODUCT_STOCK#">
        </cfoutput>       
   		<tr >
         	<td style="text-align:right" colspan="16">
            	<button name="send_to_production"><cf_get_lang dictionary_id='36825.Üretiem Gönder'></button>
         	</td>
     	</tr>
 	</form>
<cfelse>
  	<tr class="color-row" height="20">
     	<td colspan="16"><cf_get_lang dictionary_id='58486.Kayit Bulunamadi'>!</td>
 	</tr>       
</cfif>