<cfif isdefined('BAKIYE_#ACCOUNT_CODE#') or isdefined('SIFIR_#ACCOUNT_CODE#') or  (not isdefined('SIFIR_#ACCOUNT_CODE#') and not isdefined('attributes.is_zero') and not isdefined('BAKIYE_#ACCOUNT_CODE#'))> 
    <tr style="height:15px" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
    <cfoutput>
        <td style="text-align:right; width:50px">#ACCOUNT_CODE#&nbsp;</td>
        <td>
            <cfif isdefined('ACCOUNT_NAME_#ACCOUNT_CODE#')>
                #evaluate('ACCOUNT_NAME_#ACCOUNT_CODE#')#
            <cfelse>
                Dikkat Tanımlanmamış Hesap !!!
            </cfif>
        </td>
        <td style="text-align:right;width:80px">
       		<cfif isdefined('BAKIYE_#ACCOUNT_CODE#') and isdefined('t1_#left(calc,5)#') and evaluate('t1_#left(calc,5)#') neq 0>
            	#Tlformat((evaluate('BAKIYE_#ACCOUNT_CODE#')/evaluate('t1_#left(calc,5)#'))*100,2)#%
       		<cfelse>
            	0,00%&nbsp;
     		</cfif>
      	</td>
        <td style="width:5px; text-align:right" >&nbsp;</td>
                    
                    
        <cfswitch expression="#list_type#" >
            <cfcase value="1">
                <cfloop from="#sene1#" to="#sene2#" index="ii">
                    <cfset tarih1 = evaluate('period_time1_1_#ii#')>
                    <cfset tarih2 = evaluate('period_time2_1_#ii#')>
                    <td style="text-align:right;width:80px">
                        <cfif isdefined('BAKIYE_1_#ii#_#ACCOUNT_CODE#')>
                        	<cfif ii eq session.ep.period_year>
                            	<cfif evaluate('BAKIYE_1_#ii#_#ACCOUNT_CODE#') gt 0>
                                <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=fintab.popup_list_scale&ACC_BRANCH_ID=#attributes.acc_branch_id#&STR_ACCOUNT_CODE=#ACCOUNT_CODE#&FORM_VARMI=1&DATE1=#tarih1#&DATE2=#tarih2#&IS_SYSTEM_MONEY=1','page');" class="tableyazi">
                                	 #Tlformat((evaluate('BAKIYE_1_#ii#_#ACCOUNT_CODE#')/evaluate('t1_#left(calc,5)#_1_#ii#'))*100,2)#%
                                </a>
                                <cfelse>
                                	0%
                                </cfif>
                            <cfelse>
                            	<cfif evaluate('BAKIYE_1_#ii#_#ACCOUNT_CODE#') gt 0>
                            	#Tlformat((evaluate('BAKIYE_1_#ii#_#ACCOUNT_CODE#')/evaluate('t1_#left(calc,5)#_1_#ii#'))*100,2)#%
                                <cfelse>
                                	0%
                                </cfif>
                            </cfif>      
                        <cfelse>
                            0,00%&nbsp;
                        </cfif>
                    </td>
                    <td style="width:5px; text-align:right" >&nbsp;</td>
                </cfloop>
            </cfcase>
            <cfcase value="2">
                <cfloop from="#sene1#" to="#sene2#" index="ii">
                    <cfloop from="1" to="#period_say#" index="i">
                        <td style="width:80px; text-align:right;<cfif DayofYear(evaluate('period_flu_#i#_#ii#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_#i#_#ii#')) eq Year(period_date_lock)>filter:alpha(Opacity=50,FinishOpacity=40)</cfif>">
                            <cfif isdefined('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#')>
                                <cfset tarih1 = evaluate('period_time1_#i#_#ii#')>
                                <cfset tarih2 = evaluate('period_time2_#i#_#ii#')>
                                <cfif ii eq session.ep.period_year>
									<cfif evaluate('BAKIYE_1_#ii#_#ACCOUNT_CODE#') gt 0 and evaluate('t1_#left(calc,5)#_#i#_#ii#') gt 0>
                                    <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=fintab.popup_list_scale&ACC_BRANCH_ID=#attributes.acc_branch_id#&STR_ACCOUNT_CODE=#ACCOUNT_CODE#&FORM_VARMI=1&DATE1=#tarih1#&DATE2=#tarih2#&IS_SYSTEM_MONEY=1','page');" class="tableyazi">
                                    	#Tlformat((evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#')/evaluate('t1_#left(calc,5)#_#i#_#ii#'))*100,2)#%
                                    </a>
                                    <cfelse>
                                    	0%
                                    </cfif>
                            	<cfelse>
                                	<cfif evaluate('BAKIYE_1_#ii#_#ACCOUNT_CODE#') gt 0 and evaluate('t1_#left(calc,5)#_#i#_#ii#') gt 0>
                                		#Tlformat((evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#')/evaluate('t1_#left(calc,5)#_#i#_#ii#'))*100,2)#%
                                    <cfelse>
                                    	0%
                                    </cfif>
                                </cfif>    
                            <cfelse>
                                0,00%&nbsp;
                            </cfif>
                        </td>
                    </cfloop>
                    <td style="width:5px" >&nbsp;</td>
                </cfloop>
            </cfcase>
            <cfcase value="3">
                <cfloop from="#sene1#" to="#sene2#" index="ii">
                     <cfloop from="1" to="#period_say#" index="i">
                        <td style="width:80px; text-align:right;<cfif DayofYear(evaluate('period_flu_#i#_#ii#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_#i#_#ii#')) eq Year(period_date_lock)>filter:alpha(Opacity=50,FinishOpacity=40);</cfif>">
                            <cfif isdefined('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#')>
                                <cfset tarih1 = evaluate('period_time1_#i#_#ii#')>
                                <cfset tarih2 = evaluate('period_time2_#i#_#ii#')>
                                <cfif ii eq session.ep.period_year>
                                    <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=fintab.popup_list_scale&ACC_BRANCH_ID=#attributes.acc_branch_id#&STR_ACCOUNT_CODE=#ACCOUNT_CODE#&FORM_VARMI=1&DATE1=#tarih1#&DATE2=#tarih2#&IS_SYSTEM_MONEY=1','page');" class="tableyazi">
                                    	<cfif evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#') gt 0 and evaluate('t1_#left(calc,5)#_#i#_#ii#') gt 0>
                                    		#Tlformat((evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#')/evaluate('t1_#left(calc,5)#_#i#_#ii#'))*100,2)#%
                                        <cfelse>
                                        	#TlFormat(0,2)#
                                        </cfif>
                                    </a>
                                <cfelse>
                                	<cfif evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#') gt 0 and evaluate('t1_#left(calc,5)#_#i#_#ii#') gt 0>
                                   		#Tlformat((evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_CODE#')/evaluate('t1_#left(calc,5)#_#i#_#ii#'))*100,2)#%
                                 	<cfelse>
                                     	#TlFormat(0,2)#
                                 	</cfif>
                                	
                                </cfif>       
                            <cfelse>
                               	0,00%&nbsp;
                            </cfif>
                        </td>
                    </cfloop>
                    <td style="width:5px" >&nbsp;</td>
                </cfloop>
            </cfcase>
        </cfswitch>
    </cfoutput>
    </tr>
</cfif>    