<tr style="height:20px"  onMouseOver="this.className='color-light';" onMouseOut="this.className='color-list';" class="color-list">
<cfoutput>
	<td style="text-align:right; width:50px">#t_code#&nbsp;</td>
    <td>#t_baslik#</td>
   	<td style="text-align:right; width:80px">
       	<cfif isdefined('t_#calc#')>
       		<cfset 't2_#calc#' = evaluate('t_#calc#')>
     	<cfelse>
        	<cfset 't2_#calc#' = 0>
      	</cfif>
        100,00%
    </td>
    <td style="width:5px" >&nbsp;</td>
    <cfswitch expression="#list_type#" >
       	<cfcase value="1">
            <cfloop from="#sene1#" to="#sene2#" index="ii">
                <td style="text-align:right; width:80px">
                	<cfif isdefined('t_#calc#_1_#ii#') and isdefined('t2_#calc#') and evaluate('t2_#calc#') neq 0 and evaluate('t_#calc#_1_#ii#') neq 0 >
                        #Tlformat(evaluate('t_#calc#_1_#ii#')/evaluate('t2_#calc#')*100,2)#%
                  	<cfelse>
                    	0,00%&nbsp;
                  	</cfif>
                </td>
                <td style="width:5px" >&nbsp;</td>
            </cfloop>
       	</cfcase>
      	<cfcase value="2">
         	<cfloop from="#sene1#" to="#sene2#" index="ii">
            	<cfloop from="1" to="#period_say#" index="i">
                	<td style="text-align:right; width:80px;<cfif DayofYear(evaluate('period_flu_#i#_#ii#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_#i#_#ii#')) eq Year(period_date_lock)>filter:alpha(Opacity=50,FinishOpacity=40);</cfif>">
                        <cfif isdefined('t_#calc#_#i#_#ii#') and isdefined('t2_#calc#') and evaluate('t2_#calc#') neq 0 and evaluate('t_#calc#_#i#_#ii#') neq 0 >
                            #Tlformat(evaluate('t_#calc#_#i#_#ii#')/evaluate('t2_#calc#')*100,2)#%
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
                	<td style="text-align:right; width:80px;<cfif DayofYear(evaluate('period_flu_#i#_#ii#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_#i#_#ii#')) eq Year(period_date_lock)>filter:alpha(Opacity=50,FinishOpacity=40);</cfif>">
                    	<cfif isdefined('t_#calc#_#i#_#ii#') and isdefined('t2_#calc#') and evaluate('t2_#calc#') neq 0 and evaluate('t_#calc#_#i#_#ii#') neq 0 >
                            #Tlformat(evaluate('t_#calc#_#i#_#ii#')/evaluate('t2_#calc#')*100,2)#%
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