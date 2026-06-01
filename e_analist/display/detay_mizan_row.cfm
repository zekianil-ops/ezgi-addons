<cfif isdefined('BAKIYE_#ACCOUNT_ID#') or isdefined('SIFIR_#ACCOUNT_ID#')> 
    <tr style="height:15px" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
    <cfoutput>
        <td style="text-align:right; width:50px">
        	<cfif isdefined('ACCOUNT_CODE_#ACCOUNT_ID#')>
        		#Evaluate('ACCOUNT_CODE_#ACCOUNT_ID#')#&nbsp;
        	</cfif>
        </td>
        <td>
            <cfif isdefined('ACCOUNT_NAME_#ACCOUNT_ID#')>
                #evaluate('ACCOUNT_NAME_#ACCOUNT_ID#')#
            <cfelse>
                Dikkat Tanımlanmamış Hesap !!!
            </cfif>
        </td>
        <td style="text-align:right; width:80px">
			<cfif isdefined('BAKIYE_#ACCOUNT_ID#')>
             	#Tlformat(evaluate('BAKIYE_#ACCOUNT_ID#')*1,2)#
            <cfelse>
                0,00&nbsp;
            </cfif>
        </td>
        <td style="text-align:right; width:5px">&nbsp;</td>
        <cfswitch expression="#list_type#" >
            <cfcase value="1">
                <cfloop from="#sene1#" to="#sene2#" index="ii">
                    <cfset tarih1 = evaluate('period_time1_1_#ii#')>
                    <cfset tarih2 = evaluate('period_time2_1_#ii#')>
                    <td style="text-align:right" >
                        <cfif isdefined('BAKIYE_1_#ii#_#ACCOUNT_ID#')>
                        	<cfif ii eq session.ep.period_year>
                                <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=account.popup_list_scale&sub_accounts=-1&str_account_code=#Evaluate('ACCOUNT_CODE_#ACCOUNT_ID#')#&acc_code_type=0&acc_branch_id=#attributes.acc_branch_id#&project_id=&date1=#DateFormat(tarih1, 'DD/MM/YYYY')#&date2=#DateFormat(tarih2, 'DD/MM/YYYY')#&report_type=0&priority_type=0&money_type_=1','page');" class="tableyazi">#Tlformat(evaluate('BAKIYE_1_#ii#_#ACCOUNT_ID#')*1,2)#</a>
                            <cfelse>
                              	#Tlformat(evaluate('BAKIYE_1_#ii#_#ACCOUNT_ID#')*1,2)#
                       		</cfif>     
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                    </td>
                    <td style="text-align:right; width:5px">&nbsp;</td>
                </cfloop>
            </cfcase>
            <cfcase value="2">
                <cfloop from="#sene1#" to="#sene2#" index="ii">
                    <cfloop from="1" to="#period_say#" index="i">
                        <td style="text-align:right; width:80px;<cfif DayofYear(evaluate('period_flu_#i#_#ii#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_#i#_#ii#')) eq Year(period_date_lock)>filter:alpha(Opacity=50,FinishOpacity=40);</cfif>">
                            <cfif isdefined('BAKIYE_#i#_#ii#_#ACCOUNT_ID#')>
                                <cfset tarih1 = evaluate('period_time1_#i#_#ii#')>
                                <cfset tarih2 = evaluate('period_time2_#i#_#ii#')>
                                <cfif ii eq session.ep.period_year>
                                    <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=account.popup_list_scale&sub_accounts=-1&str_account_code=#Evaluate('ACCOUNT_CODE_#ACCOUNT_ID#')#&acc_code_type=0&acc_branch_id=#attributes.acc_branch_id#&project_id=&date1=#DateFormat(tarih1, 'DD/MM/YYYY')#&date2=#DateFormat(tarih2, 'DD/MM/YYYY')#&report_type=0&priority_type=0&money_type_=1','page');" class="tableyazi">#Tlformat(evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_ID#')*1,2)#</a>
                              	<cfelse>
                                    #Tlformat(evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_ID#')*1,2)#
                                </cfif>      
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                        </td>
                    </cfloop>
                    <td style="text-align:right; width:5px">&nbsp;</td>
                </cfloop>
            </cfcase>
            <cfcase value="3">
                <cfloop from="#sene1#" to="#sene2#" index="ii">
                     <cfloop from="1" to="#period_say#" index="i">
                        <td style="text-align:right; width:80px;<cfif DayofYear(evaluate('period_flu_#i#_#ii#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_#i#_#ii#')) eq Year(period_date_lock)>filter:alpha(Opacity=50,FinishOpacity=40);</cfif>" >
                            <cfif isdefined('BAKIYE_#i#_#ii#_#ACCOUNT_ID#')>
                                <cfset tarih1 = evaluate('period_time1_#i#_#ii#')>
                                <cfset tarih2 = evaluate('period_time2_#i#_#ii#')>
                                <cfif ii eq session.ep.period_year>
                                    <a href="javascript://" onClick="windowopen('#request.self#?fuseaction=account.popup_list_scale&sub_accounts=-1&str_account_code=#Evaluate('ACCOUNT_CODE_#ACCOUNT_ID#')#&acc_code_type=0&acc_branch_id=#attributes.acc_branch_id#&project_id=&date1=#DateFormat(tarih1, 'DD/MM/YYYY')#&date2=#DateFormat(tarih2, 'DD/MM/YYYY')#&report_type=0&priority_type=0&money_type_=1','page');" class="tableyazi">#Tlformat(evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_ID#')*1,2)#</a>
                            	<cfelse>
                                  	#Tlformat(evaluate('BAKIYE_#i#_#ii#_#ACCOUNT_ID#')*1,2)#
                            	</cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                        </td>
                    </cfloop>
                    <td style="text-align:right; width:5px">&nbsp;</td>
                </cfloop>
            </cfcase>
        </cfswitch>
    </cfoutput>
    </tr>
</cfif>    