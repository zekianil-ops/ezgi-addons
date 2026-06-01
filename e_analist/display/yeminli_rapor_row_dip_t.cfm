<tr style="height:20px" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-list';" class="color-list">
<cfoutput>
	<td style="text-align:right; width:50px"><strong>&nbsp;</strong></td>
    <td ><strong>SONUÇ</strong></td>
     <td style="text-align:right; width:80px">
     <strong>
       	<cfif isdefined('TOPLAM_')>
        	<font color="red">
				<cfif TOPLAM_ gt 0>
                    #Tlformat(TOPLAM_*1,2)#
                <cfelse>
                    #Tlformat(TOPLAM_*-1,2)#
                 </cfif>
             </font>     
       	<cfelse>
           	0,00&nbsp;
      	</cfif>
   	</strong>
    </td>
    <td style="text-align:right; width:5px">&nbsp;</td>
    <cfswitch expression="#list_type#" >
       	<cfcase value="1">
            <cfloop from="#sene1#" to="#sene2#" index="ii">
                <td style="text-align:right" >
                <strong>
                	<cfif isdefined('TOPLAM_1_#ii#')>
                    	<font color="red">
                    	<cfif Evaluate('TOPLAM_1_#ii#') gt 0>
                			#Tlformat(evaluate('TOPLAM_1_#ii#')*1,2)#
                       	<cfelse>
                        	#Tlformat(evaluate('TOPLAM_1_#ii#')*-1,2)#
                        </cfif>   
                        </font>  
                  	<cfelse>
                    	0,00&nbsp;
                  	</cfif>
                </strong>
                </td>
                <td style="text-align:right; width:5px">&nbsp;</td>
            </cfloop>
       	</cfcase>
      	<cfcase value="2">
         	<cfloop from="#sene1#" to="#sene2#" index="ii">
            	<cfloop from="1" to="#period_say#" index="i">
                	<td style="text-align:right; width:80px;<cfif DayofYear(evaluate('period_flu_#i#_#ii#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_#i#_#ii#')) eq Year(period_date_lock)>filter:alpha(Opacity=50,FinishOpacity=40);</cfif>" >
                    <strong>
                        <cfif isdefined('TOPLAM_#i#_#ii#')>
                            <font color="red">
                            <cfif Evaluate('TOPLAM_#i#_#ii#') gt 0>
                                #Tlformat(evaluate('TOPLAM_#i#_#ii#')*1,2)#
                            <cfelse>
                                #Tlformat(evaluate('TOPLAM_#i#_#ii#')*-1,2)#
                            </cfif>   
                            </font>  
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                   	</strong>
                   	</td>
               	</cfloop>
                <td style="text-align:right; width:5px">&nbsp;</td>
         	</cfloop>
      	</cfcase>
		<cfcase value="3">
        	<cfloop from="#sene1#" to="#sene2#" index="ii">
                 <cfloop from="1" to="#period_say#" index="i">
                	<td style="text-align:right; width:80px;<cfif DayofYear(evaluate('period_flu_#i#_#ii#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_#i#_#ii#')) eq Year(period_date_lock)>filter:alpha(Opacity=50,FinishOpacity=40);</cfif>" >
                    <strong>
						<cfif isdefined('TOPLAM_#i#_#ii#')>
                            <font color="red">
                            <cfif Evaluate('TOPLAM_#i#_#ii#') gt 0>
                                #Tlformat(evaluate('TOPLAM_#i#_#ii#')*1,2)#
                            <cfelse>
                                #Tlformat(evaluate('TOPLAM_#i#_#ii#')*-1,2)#
                            </cfif>   
                            </font>  
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                   	</strong>
                   	</td>
               	</cfloop>
                <td style="text-align:right; width:5px" >&nbsp;</td>
           	</cfloop>
      	</cfcase>
 	</cfswitch>
</cfoutput>
</tr>