<tr style="height:30px" onMouseOver="this.className='color-light';" onMouseOut="this.className='color-row';" class="color-row">
<cfif  t_islem_ gt 0>
	<cfswitch expression="#list_type#" >
       	<cfcase value="1">
			<cfset t_islem = t_islem_>
            <cfset t_oran = '#t_oran##Tlformat(t_islem,2)#'>
       	</cfcase>     
      	<cfcase value="2">
			<cfset t_islem = t_islem_/4>
            <cfset t_oran = '#t_oran##Tlformat(t_islem,2)#'>
       	</cfcase>     
      	<cfcase value="3">
			<cfset t_islem = t_islem_/12>
            <cfset t_oran = '#t_oran##Tlformat(t_islem,2)#'>
      	</cfcase>
  	</cfswitch>                        
</cfif>
<cfoutput>
    <td >#t_baslik#<br /><font style="font-style:italic">#t_baslik_1#</font></td>
    <td style="text-align:center"><font color="red">#t_oran#&nbsp;</font></td>
    <td style="text-align:right; width:50px" > <!---Açılış Değerleri--->
    	<cfif t_row eq 1>
			<cfif isdefined('t_list1') and isdefined('t_list3') and t_list1 neq 0 and t_list3 neq 0>
                #Tlformat((t_list1+t_list3)/1000,2)#
            <cfelse>
                0,00&nbsp;
            </cfif>
     	<cfelseif t_row eq 2>
        	<cfif isdefined('t_list1') and isdefined('t_list3') and t_list1 neq 0 and t_list3 neq 0>
                #Tlformat((t_list1/t_list3 *-1),2)#
            <cfelse>
                0,00&nbsp;
            </cfif>
       	<cfelseif t_row eq 3>
        	<cfif isdefined('t_list1') and isdefined('t_list3') and t_list1 neq 0 and t_list3 neq 0>
                <cfif t_list1/t_list3 *-1 gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>
            <cfelse>
                &nbsp;
            </cfif>
      	<cfelseif t_row eq 4>
        	<cfif isdefined('t_list1') and isdefined('t_list15') and isdefined('t_list3') and t_list1-t_list15 neq 0 and t_list3 neq 0>
                #Tlformat(((t_list1-t_list15)/t_list3 *-1),2)#
            <cfelse>
                0,00&nbsp;
            </cfif>
       	<cfelseif t_row eq 5>
        	<cfif isdefined('t_list1') and isdefined('t_list15') and isdefined('t_list3') and t_list1-t_list15 neq 0 and t_list3 neq 0>
                <cfif (t_list1-t_list15)/t_list3 *-1 gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>
            <cfelse>
                &nbsp;
            </cfif>
      	<cfelseif t_row eq 6>
        	<cfif isdefined('t_list10') and isdefined('t_list11') and isdefined('t_list3') and t_list10 + t_list11 neq 0 and t_list3 neq 0>
                #Tlformat(((t_list10 + t_list11)/t_list3 *-1),2)#
            <cfelse>
                0,00&nbsp;
            </cfif>
       	<cfelseif t_row eq 7>
        	<cfif isdefined('t_list10') and isdefined('t_list11') and isdefined('t_list3') and t_list10 + t_list11 neq 0 and t_list3 neq 0>
                <cfif (t_list10 + t_list11)/t_list3 *-1 gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>
            <cfelse>
                &nbsp;
            </cfif>          
        <cfelseif t_row eq 8>
        	<cfif isdefined('t_list1') and isdefined('t_list3') and isdefined('t_list15') and isdefined('t_list18') and t_list1-t_list15+t_list18 neq 0 and t_list3 neq 0>
                #Tlformat(((t_list1-(t_list15+t_list18))/t_list3 *-1),2)#
            <cfelse>
                0,00&nbsp;
            </cfif>
       	<cfelseif t_row eq 9>
        	<cfif isdefined('t_list1') and isdefined('t_list3') and isdefined('t_list15') and isdefined('t_list18') and t_list1-t_list15+t_list18 neq 0 and t_list3 neq 0>
           		<cfif ((t_list1-(t_list15+t_list18))/t_list3 *-1) gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>     
            <cfelse>
                &nbsp;
            </cfif>
       	<cfelseif t_row eq 10>
        	<cfif isdefined('t_gelr1') and isdefined('t_gelr2') and t_gelr1 neq 0 and t_gelr2 neq 0>
           		<cfif t_gelr2/t_gelr1*100 gte t_islem><font color="green">#Tlformat(t_gelr2/t_gelr1*100,2)#%</font><cfelse><font color="red">#Tlformat(t_gelr2/t_gelr1*-1,2)#</font></cfif>     
            <cfelse>
                0,00&nbsp;
            </cfif>
       	<cfelseif t_row eq 11>
        	<cfif isdefined('t_gelr1') and isdefined('t_gelr5') and t_gelr1 neq 0 and t_gelr5 neq 0>
           		<cfif t_gelr5/t_gelr1*100 gte t_islem><font color="green">#Tlformat(t_gelr5/t_gelr1*100,2)#%</font><cfelse><font color="red">#Tlformat(t_gelr5/t_gelr1*-1,2)#</font></cfif>     
            <cfelse>
                0,00&nbsp;
            </cfif>
       	<cfelseif t_row eq 12>
         	<cfif isdefined('t_gelr16') and isdefined('t_gelr5e') and isdefined('t_listp') and -evaluate('t_gelr16') + evaluate('t_gelr5e') neq 0 and evaluate('t_listp') neq 0>
            	#Tlformat((-(evaluate('t_gelr16') + evaluate('t_gelr5e'))/(evaluate('t_listp'))*100),2)#% 
           	<cfelse>
            	0,00&nbsp;
         	</cfif>
     	<cfelseif t_row eq 13>
         	<cfif isdefined('t_gelr16') and isdefined('t_gelr5e') and -evaluate('t_gelr16') + evaluate('t_gelr5e') neq 0 and evaluate('t_gelr16') neq 0>
            	#Tlformat((-(evaluate('t_gelr16') + evaluate('t_gelr5e'))/-(evaluate('t_gelr16'))*100),2)#% 
          	<cfelse>
                0,00&nbsp;
            </cfif>
     	<cfelseif t_row eq 14>
			<cfif isdefined('t_list1') and isdefined('t_lista') and t_list1 neq 0 and t_lista neq 0>
                <cfif t_list1/t_lista gte t_islem><font color="green">#Tlformat((t_list1/t_lista),2)#</font><cfelse><font color="red">#Tlformat((t_list1/t_lista),2)#</font></cfif>
            <cfelse>
                0,00&nbsp;
            </cfif>
       	<cfelseif t_row eq 15>
			<cfif isdefined('t_list2') and isdefined('t_lista') and t_list2 neq 0 and t_lista neq 0>
                <cfif t_list2/t_lista gte t_islem><font color="green">#Tlformat((t_list2/t_lista),2)#</font><cfelse><font color="red">#Tlformat((t_list2/t_lista),2)#</font></cfif>
            <cfelse>
                0,00&nbsp;
            </cfif>
       	<cfelseif t_row eq 16>
			<cfif isdefined('t_list3') and isdefined('t_listp') and t_list3 neq 0 and t_listp neq 0>
                <cfif t_list3/t_listp gte t_islem><font color="green">#Tlformat((t_list3/t_listp),2)#</font><cfelse><font color="red">#Tlformat((t_list3/t_listp),2)#</font></cfif>
            <cfelse>
                0,00&nbsp;
            </cfif>
       	<cfelseif t_row eq 17>
			<cfif isdefined('t_list4') and isdefined('t_listp') and t_list4 neq 0 and t_listp neq 0>
                <cfif t_list4/t_listp gte t_islem><font color="green">#Tlformat((t_list4/t_listp),2)#</font><cfelse><font color="red">#Tlformat((t_list4/t_listp),2)#</font></cfif>
            <cfelse>
                0,00&nbsp;
            </cfif>
       	<cfelseif t_row eq 18>
			<cfif isdefined('t_list5') and isdefined('t_listp') and t_list5 neq 0 and t_listp neq 0>
                <cfif t_list5/t_listp gte t_islem><font color="green">#Tlformat((t_list5/t_listp),2)#</font><cfelse><font color="red">#Tlformat((t_list5/t_listp),2)#</font></cfif>
            <cfelse>
                0,00&nbsp;
            </cfif>
        <cfelseif t_row eq 19>
			<cfif isdefined('t_list5') and isdefined('t_list4') and isdefined('t_list3') and t_list5 neq 0 and t_list3+t_list4 neq 0>
                <cfif (t_list3+t_list4)/t_list5 lt t_islem><font color="green">#Tlformat((t_list3+t_list4)/t_list5,2)#</font><cfelse><font color="red">#Tlformat((t_list3+t_list4)/t_list5,2)#</font></cfif>
            <cfelse>
                0,00&nbsp;
            </cfif>
       	<cfelseif t_row eq 20>
			<cfif isdefined('t_gelr1') and isdefined('t_lista') and t_gelr1 neq 0 and t_lista neq 0>
                <cfif -t_gelr1/t_lista gte t_islem><font color="green">#Tlformat((-t_gelr1/t_lista),2)#</font><cfelse><font color="red">#Tlformat((-t_gelr1/t_lista),2)#</font></cfif>
            <cfelse>
                0,00&nbsp;
            </cfif>
     	<cfelseif t_row eq 21>
         	0,00&nbsp;
       	<cfelseif t_row eq 22>
         	0,00&nbsp;
       	<cfelseif t_row eq 23>
         	0,00&nbsp;
       	<cfelseif t_row eq 24>
         	0,00&nbsp;
       	<cfelseif t_row eq 25>
         	0,00&nbsp;
       	<cfelseif t_row eq 26>
         	0,00&nbsp;
       	<cfelseif t_row eq 27>
         	0,00&nbsp;
       	<cfelseif t_row eq 28>
         	0,00&nbsp;
       	<cfelseif t_row eq 29>
         	0,00&nbsp;
       	<cfelseif t_row eq 30>
         	0,00&nbsp;
       	<cfelseif t_row eq 31>
			<cfif isdefined('t_gelr1') and isdefined('t_gelr5') and isdefined('t_lista') and evaluate('t_gelr1') neq 0 and evaluate('t_gelr5') neq 0 and evaluate('t_lista') neq 0>
             	<cfif (evaluate('t_gelr5')/evaluate('t_gelr1'))*(evaluate('t_gelr1')/evaluate('t_lista'))*100 gte t_islem><font color="green">#Tlformat((evaluate('t_gelr5')/evaluate('t_gelr1'))*(evaluate('t_gelr1')/evaluate('t_lista'))*100,2)#%</font><cfelse><font color="red">#Tlformat((evaluate('t_gelr5')/evaluate('t_gelr1'))*(evaluate('t_gelr1')/evaluate('t_lista'))*100,2)#%</font></cfif>     
         	<cfelse>
            	0,00&nbsp;
          	</cfif>
        <cfelseif t_row eq 32>
			<cfif isdefined('t_gelr1') and isdefined('t_gelr5') and isdefined('t_lista') and evaluate('t_gelr1') neq 0 and evaluate('t_gelr5') neq 0 and evaluate('t_lista') neq 0>
             	<cfif (evaluate('t_gelr5')/evaluate('t_gelr1'))*(evaluate('t_gelr1')/evaluate('t_lista'))*100 gte t_islem><font color="green">#Tlformat((evaluate('t_gelr5')/evaluate('t_gelr1'))*(evaluate('t_gelr1')/evaluate('t_lista'))*100,2)#%</font><cfelse><font color="red">#Tlformat((evaluate('t_gelr5')/evaluate('t_gelr1'))*(evaluate('t_gelr1')/evaluate('t_lista'))*100,2)#%</font></cfif>     
         	<cfelse>
            	0,00&nbsp;
          	</cfif>
         <cfelseif t_row eq 33>
			<cfif isdefined('t_gelr1') and isdefined('t_gelr5') and isdefined('t_list5') and evaluate('t_gelr1') neq 0 and evaluate('t_gelr5') neq 0 and evaluate('t_list5') neq 0>
             	<cfif (evaluate('t_gelr5')/evaluate('t_gelr1'))*(evaluate('t_gelr1')/evaluate('t_list5'))*100 gte t_islem><font color="green">#Tlformat((evaluate('t_gelr5')/evaluate('t_gelr1'))*(evaluate('t_gelr1')/evaluate('t_list5'))*100,2)#%</font><cfelse><font color="red">#Tlformat((evaluate('t_gelr5')/evaluate('t_gelr1'))*(evaluate('t_gelr1')/evaluate('t_list5'))*100,2)#%</font></cfif>     
         	<cfelse>
            	0,00&nbsp;
          	</cfif>
       	<cfelseif t_row eq 34>
         	0,00&nbsp;                                  
        </cfif>       
   	</td>
    <td style="text-align:right; width:5px">&nbsp;</td>
    
    
    <cfswitch expression="#list_type#" >
       	<cfcase value="1"> <!---Yıl Bazında--->
            <cfloop from="#sene1#" to="#sene2#" index="ii">
                <td style="text-align:right; width:100px" >
                	<cfif t_row eq 1>
						<cfif isdefined('t_list1_1_#ii#') and isdefined('t_list3_1_#ii#') and evaluate('t_list1_1_#ii#') neq 0 and evaluate('t_list3_1_#ii#') neq 0>
                            #Tlformat((evaluate('t_list1_1_#ii#')-evaluate('t_list3_1_#ii#'))/1000,2)#
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                 	<cfelseif t_row eq 2>
                    	<cfif isdefined('t_list1_1_#ii#') and isdefined('t_list3_1_#ii#') and evaluate('t_list1_1_#ii#') neq 0 and evaluate('t_list3_1_#ii#') neq 0>
                            #Tlformat((evaluate('t_list1_1_#ii#')/evaluate('t_list3_1_#ii#')*-1),2)#
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                 	<cfelseif t_row eq 3>
                    	<cfif isdefined('t_list1_1_#ii#') and isdefined('t_list3_1_#ii#') and evaluate('t_list1_1_#ii#') neq 0 and evaluate('t_list3_1_#ii#') neq 0>
                       		<cfif (evaluate('t_list1_1_#ii#')/evaluate('t_list3_1_#ii#')*-1) gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>
                        <cfelse>
                            &nbsp;
                        </cfif>
                  	<cfelseif t_row eq 4>
                    	<cfif isdefined('t_list1_1_#ii#') and isdefined('t_list15_1_#ii#') and isdefined('t_list3_1_#ii#') and evaluate('t_list1_1_#ii#') - evaluate('t_list15_1_#ii#') neq 0 and evaluate('t_list3_1_#ii#') neq 0>
                            #Tlformat(((evaluate('t_list1_1_#ii#')-evaluate('t_list15_1_#ii#'))/evaluate('t_list3_1_#ii#')*-1),2)#
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                 	<cfelseif t_row eq 5>
                    	<cfif isdefined('t_list1_1_#ii#') and isdefined('t_list15_1_#ii#') and isdefined('t_list3_1_#ii#') and evaluate('t_list1_1_#ii#') - evaluate('t_list15_1_#ii#') neq 0 and evaluate('t_list3_1_#ii#') neq 0>
                       		<cfif ((evaluate('t_list1_1_#ii#')-evaluate('t_list15_1_#ii#'))/evaluate('t_list3_1_#ii#')*-1) gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>
                        <cfelse>
                            &nbsp;
                        </cfif>
                   	<cfelseif t_row eq 6>
                    	<cfif isdefined('t_list10_1_#ii#') and isdefined('t_list11_1_#ii#') and isdefined('t_list3_1_#ii#') and evaluate('t_list10_1_#ii#') + evaluate('t_list11_1_#ii#') neq 0 and evaluate('t_list3_1_#ii#') neq 0>
                            #Tlformat(((evaluate('t_list10_1_#ii#')+evaluate('t_list11_1_#ii#'))/evaluate('t_list3_1_#ii#')*-1),2)#
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                 	<cfelseif t_row eq 7>
                    	<cfif isdefined('t_list10_1_#ii#') and isdefined('t_list11_1_#ii#') and isdefined('t_list3_1_#ii#') and evaluate('t_list10_1_#ii#') + evaluate('t_list11_1_#ii#') neq 0 and evaluate('t_list3_1_#ii#') neq 0>
                       		<cfif ((evaluate('t_list10_1_#ii#')-evaluate('t_list11_1_#ii#'))/evaluate('t_list3_1_#ii#')*-1) gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>
                        <cfelse>
                            &nbsp;
                        </cfif>
                    <cfelseif t_row eq 8>
                     	<cfif isdefined('t_list1_1_#ii#') and isdefined('t_list3_1_#ii#') and isdefined('t_list15_1_#ii#') and isdefined('t_list18_1_#ii#') and evaluate('t_list1_1_#ii#')-(evaluate('t_list15_1_#ii#')+evaluate('t_list18_1_#ii#')) neq 0 and evaluate('t_list3_1_#ii#') neq 0>
                			#Tlformat(((evaluate('t_list1_1_#ii#')-(evaluate('t_list15_1_#ii#')+evaluate('t_list18_1_#ii#')))/evaluate('t_list3_1_#ii#')*-1),2)#   
                        <cfelse>
                             0,00&nbsp;
                        </cfif>
                  	<cfelseif t_row eq 9>
                     	<cfif isdefined('t_list1_1_#ii#') and isdefined('t_list3_1_#ii#') and isdefined('t_list15_1_#ii#') and isdefined('t_list18_1_#ii#') and evaluate('t_list1_1_#ii#')-(evaluate('t_list15_1_#ii#')+evaluate('t_list18_1_#ii#')) neq 0 and evaluate('t_list3_1_#ii#') neq 0>
                			<cfif ((evaluate('t_list1_1_#ii#')-(evaluate('t_list15_1_#ii#')+evaluate('t_list18_1_#ii#')))/evaluate('t_list3_1_#ii#')*-1) gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>   
                        <cfelse>
                             0,00&nbsp;
                        </cfif>
                 	<cfelseif t_row eq 10>
						<cfif isdefined('t_gelr1_1_#ii#') and isdefined('t_gelr2_1_#ii#') and evaluate('t_gelr1_1_#ii#') neq 0 and evaluate('t_gelr2_1_#ii#') neq 0>
                            <cfif evaluate('t_gelr2_1_#ii#')/evaluate('t_gelr1_1_#ii#')*100 gte t_islem><font color="green">#Tlformat(evaluate('t_gelr2_1_#ii#')/evaluate('t_gelr1_1_#ii#')*100,2)#%</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr2_1_#ii#')/evaluate('t_gelr1_1_#ii#')*100,2)#%</font></cfif>     
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                   	<cfelseif t_row eq 11>
						<cfif isdefined('t_gelr1_1_#ii#') and isdefined('t_gelr5_1_#ii#') and evaluate('t_gelr1_1_#ii#') neq 0 and evaluate('t_gelr5_1_#ii#') neq 0>
                            <cfif evaluate('t_gelr5_1_#ii#')/evaluate('t_gelr1_1_#ii#')*100 gte t_islem><font color="green">#Tlformat(evaluate('t_gelr5_1_#ii#')/evaluate('t_gelr1_1_#ii#')*100,2)#%</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr5_1_#ii#')/evaluate('t_gelr1_1_#ii#')*100,2)#%</font></cfif>     
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                 	<cfelseif t_row eq 12>
                     	<cfif isdefined('t_gelr16_1_#ii#') and isdefined('t_gelr5e_1_#ii#') and isdefined('t_listp_1_#ii#') and -evaluate('t_gelr16_1_#ii#') + evaluate('t_gelr5e_1_#ii#') neq 0 and evaluate('t_listp_1_#ii#') neq 0>
                        	#Tlformat((-(evaluate('t_gelr16_1_#ii#') + evaluate('t_gelr5e_1_#ii#'))/(evaluate('t_listp_1_#ii#'))*100),2)#% 
                       	<cfelse>
                        	0,00&nbsp;
                       	</cfif>
                  	<cfelseif t_row eq 13>
                        <cfif isdefined('t_gelr16_1_#ii#') and isdefined('t_gelr5e_1_#ii#') and -evaluate('t_gelr16_1_#ii#') + evaluate('t_gelr5e_1_#ii#') neq 0 and evaluate('t_gelr16_1_#ii#') neq 0>
                            #Tlformat((-(evaluate('t_gelr16_1_#ii#') + evaluate('t_gelr5e_1_#ii#'))/-(evaluate('t_gelr16_1_#ii#'))*100),2)#% 
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                    <cfelseif t_row eq 14>
						<cfif isdefined('t_list1_1_#ii#') and isdefined('t_lista_1_#ii#') and evaluate('t_list1_1_#ii#') neq 0 and evaluate('t_lista_1_#ii#') neq 0>
                     		<cfif evaluate('t_list1_1_#ii#')/evaluate('t_lista_1_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list1_1_#ii#')/evaluate('t_lista_1_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list1_1_#ii#')/evaluate('t_lista_1_#ii#')),2)#</font></cfif>
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                   	<cfelseif t_row eq 15>
						<cfif isdefined('t_list2_1_#ii#') and isdefined('t_lista_1_#ii#') and evaluate('t_list2_1_#ii#') neq 0 and evaluate('t_lista_1_#ii#') neq 0>
                     		<cfif evaluate('t_list2_1_#ii#')/evaluate('t_lista_1_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list2_1_#ii#')/evaluate('t_lista_1_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list2_1_#ii#')/evaluate('t_lista_1_#ii#')),2)#</font></cfif>
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                   	<cfelseif t_row eq 16>
						<cfif isdefined('t_list3_1_#ii#') and isdefined('t_listp_1_#ii#') and evaluate('t_list3_1_#ii#') neq 0 and evaluate('t_listp_1_#ii#') neq 0>
                     		<cfif evaluate('t_list3_1_#ii#')/evaluate('t_listp_1_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list3_1_#ii#')/evaluate('t_listp_1_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list3_1_#ii#')/evaluate('t_listp_1_#ii#')),2)#</font></cfif>
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                    <cfelseif t_row eq 17>
						<cfif isdefined('t_list4_1_#ii#') and isdefined('t_listp_1_#ii#') and evaluate('t_list4_1_#ii#') neq 0 and evaluate('t_listp_1_#ii#') neq 0>
                     		<cfif evaluate('t_list4_1_#ii#')/evaluate('t_listp_1_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list4_1_#ii#')/evaluate('t_listp_1_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list4_1_#ii#')/evaluate('t_listp_1_#ii#')),2)#</font></cfif>
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                   	<cfelseif t_row eq 18>
						<cfif isdefined('t_list5_1_#ii#') and isdefined('t_listp_1_#ii#') and evaluate('t_list5_1_#ii#') neq 0 and evaluate('t_listp_1_#ii#') neq 0>
                     		<cfif evaluate('t_list5_1_#ii#')/evaluate('t_listp_1_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list5_1_#ii#')/evaluate('t_listp_1_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list5_1_#ii#')/evaluate('t_listp_1_#ii#')),2)#</font></cfif>
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                   	<cfelseif t_row eq 19>
						<cfif isdefined('t_list5_1_#ii#') and isdefined('t_list3_1_#ii#') and isdefined('t_list4_1_#ii#') and evaluate('t_list5_1_#ii#') neq 0 and evaluate('t_list3_1_#ii#')+evaluate('t_list4_1_#ii#') neq 0>
                     		<cfif (evaluate('t_list3_1_#ii#')+evaluate('t_list4_1_#ii#'))/evaluate('t_list5_1_#ii#') lt t_islem><font color="green">#Tlformat((evaluate('t_list3_1_#ii#')+evaluate('t_list4_1_#ii#'))/evaluate('t_list5_1_#ii#'),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list3_1_#ii#')+evaluate('t_list4_1_#ii#'))/evaluate('t_list5_1_#ii#'),2)#</font></cfif>
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                    <cfelseif t_row eq 20>
						<cfif isdefined('t_gelr1_1_#ii#') and isdefined('t_lista_1_#ii#') and evaluate('t_gelr1_1_#ii#') neq 0 and evaluate('t_lista_1_#ii#') neq 0>
                     		<cfif -evaluate('t_gelr1_1_#ii#')/evaluate('t_lista_1_#ii#') gte t_islem><font color="green">#Tlformat((-evaluate('t_gelr1_1_#ii#')/evaluate('t_lista_1_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((-evaluate('t_gelr1_1_#ii#')/evaluate('t_lista_1_#ii#')),2)#</font></cfif>
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                   	 <cfelseif t_row eq 21>
						<cfif  isdefined('t_listst_1_#ii#') and isdefined('t_gelr12_1_#ii#') and evaluate('t_listst_1_#ii#') neq 0 and evaluate('t_gelr12_1_#ii#') neq 0>
                            <cfif evaluate('t_gelr12_#1#_#ii#')/evaluate('t_listst_#1#_#ii#') gte t_islem><font color="green">#Tlformat(evaluate('t_gelr12_#1#_#ii#')/evaluate('t_listst_#1#_#ii#'),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr12_#1#_#ii#')/evaluate('t_listst_#1#_#ii#'),2)#</font></cfif>    
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                  	<cfelseif t_row eq 22>
						<cfif  isdefined('t_listst_1_#ii#') and isdefined('t_gelr12_1_#ii#') and evaluate('t_listst_1_#ii#') neq 0 and evaluate('t_gelr12_1_#ii#') neq 0>
                            <cfif 365/(evaluate('t_gelr12_#1#_#ii#')/evaluate('t_listst_#1#_#ii#')) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr12_#1#_#ii#')/evaluate('t_listst_#1#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr12_#1#_#ii#')/evaluate('t_listst_#1#_#ii#')),2)#</font></cfif>    
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                   	<cfelseif t_row eq 23>
						<cfif  isdefined('t_listsa_1_#ii#') and isdefined('t_gelrsa_1_#ii#') and evaluate('t_listsa_1_#ii#') neq 0 and evaluate('t_gelrsa_1_#ii#') neq 0>
                            <cfif evaluate('t_gelrsa_#1#_#ii#')/evaluate('t_listsa_#1#_#ii#') gte t_islem><font color="green">#Tlformat(evaluate('t_gelrsa_#1#_#ii#')/evaluate('t_listsa_#1#_#ii#'),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelrsa_#1#_#ii#')/evaluate('t_listsa_#1#_#ii#'),2)#</font></cfif>    
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                  	<cfelseif t_row eq 24>
						<cfif  isdefined('t_listsa_1_#ii#') and isdefined('t_gelrsa_1_#ii#') and evaluate('t_listsa_1_#ii#') neq 0 and evaluate('t_gelrsa_1_#ii#') neq 0>
                            <cfif 365/(evaluate('t_gelrsa_#1#_#ii#')/evaluate('t_listsa_#1#_#ii#')) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelrsa_#1#_#ii#')/evaluate('t_listsa_#1#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelrsa_#1#_#ii#')/evaluate('t_listsa_#1#_#ii#')),2)#</font></cfif>    
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                   	<cfelseif t_row eq 25>
						<cfif  isdefined('t_listsb_1_#ii#') and isdefined('t_gelrsb_1_#ii#') and evaluate('t_listsb_1_#ii#') neq 0 and evaluate('t_gelrsb_1_#ii#') neq 0>
                            <cfif evaluate('t_gelrsb_#1#_#ii#')/evaluate('t_listsb_#1#_#ii#') gte t_islem><font color="green">#Tlformat(evaluate('t_gelrsb_#1#_#ii#')/evaluate('t_listsb_#1#_#ii#'),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelrsb_#1#_#ii#')/evaluate('t_listsb_#1#_#ii#'),2)#</font></cfif>    
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                  	<cfelseif t_row eq 26>
						<cfif  isdefined('t_listsb_1_#ii#') and isdefined('t_gelrsb_1_#ii#') and evaluate('t_listsb_1_#ii#') neq 0 and evaluate('t_gelrsb_1_#ii#') neq 0>
                            <cfif 365/(evaluate('t_gelrsb_#1#_#ii#')/evaluate('t_listsb_#1#_#ii#')) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelrsb_#1#_#ii#')/evaluate('t_listsb_#1#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelrsb_#1#_#ii#')/evaluate('t_listsb_#1#_#ii#')),2)#</font></cfif>    
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                 	<cfelseif t_row eq 27>
						<cfif  isdefined('t_listtb_1_#ii#') and isdefined('t_gelr12_1_#ii#') and evaluate('t_listtb_1_#ii#') neq 0 and evaluate('t_gelr12_1_#ii#') neq 0>
                            <cfif evaluate('t_gelr12_#1#_#ii#')/evaluate('t_listtb_#1#_#ii#') gte t_islem><font color="green">#Tlformat(evaluate('t_gelr12_#1#_#ii#')/evaluate('t_listtb_#1#_#ii#'),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr12_#1#_#ii#')/evaluate('t_listtb_#1#_#ii#'),2)#</font></cfif>    
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                  	<cfelseif t_row eq 28>
						<cfif  isdefined('t_listta_1_#ii#') and isdefined('t_gelr12_1_#ii#') and evaluate('t_listta_1_#ii#') neq 0 and evaluate('t_gelr12_1_#ii#') neq 0>
                            <cfif 365/(evaluate('t_gelr12_#1#_#ii#')/evaluate('t_listta_#1#_#ii#')) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr12_#1#_#ii#')/evaluate('t_listta_#1#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr12_#1#_#ii#')/evaluate('t_listta_#1#_#ii#')),2)#</font></cfif>    
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                    <cfelseif t_row eq 29>
						<cfif  isdefined('t_listta_1_#ii#') and isdefined('t_gelr1_1_#ii#') and evaluate('t_listta_1_#ii#') neq 0 and evaluate('t_gelr1_1_#ii#') neq 0>
                            <cfif evaluate('t_gelr1_#1#_#ii#')/evaluate('t_listta_#1#_#ii#') gte t_islem><font color="green">#Tlformat(evaluate('t_gelr1_#1#_#ii#')/evaluate('t_listta_#1#_#ii#'),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr1_#1#_#ii#')/evaluate('t_listta_#1#_#ii#'),2)#</font></cfif>    
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                  	<cfelseif t_row eq 30>
						<cfif  isdefined('t_listta_1_#ii#') and isdefined('t_gelr1_1_#ii#') and evaluate('t_listta_1_#ii#') neq 0 and evaluate('t_gelr1_1_#ii#') neq 0>
                            <cfif 365/(evaluate('t_gelr1_#1#_#ii#')/evaluate('t_listta_#1#_#ii#')) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr1_#1#_#ii#')/evaluate('t_listta_#1#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr1_#1#_#ii#')/evaluate('t_listta_#1#_#ii#')),2)#</font></cfif>    
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                  	 <cfelseif t_row eq 31>
						<cfif isdefined('t_gelr1_1_#ii#') and isdefined('t_gelr5_1_#ii#') and isdefined('t_lista_1_#ii#') and evaluate('t_gelr1_1_#ii#') neq 0 and evaluate('t_gelr5_1_#ii#') neq 0 and evaluate('t_lista_1_#ii#') neq 0>
                            <cfif (evaluate('t_gelr5_1_#ii#')/evaluate('t_gelr1_1_#ii#'))*(evaluate('t_gelr1_1_#ii#')/evaluate('t_lista_1_#ii#'))*100 gte t_islem><font color="green">#Tlformat((evaluate('t_gelr5_1_#ii#')/evaluate('t_gelr1_1_#ii#'))*(evaluate('t_gelr1_1_#ii#')/evaluate('t_lista_1_#ii#'))*100,2)#%</font><cfelse><font color="red">#Tlformat((evaluate('t_gelr5_1_#ii#')/evaluate('t_gelr1_1_#ii#'))*(evaluate('t_gelr1_1_#ii#')/evaluate('t_lista_1_#ii#'))*100,2)#%</font></cfif>     
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                   	<cfelseif t_row eq 32>
						<cfif isdefined('t_gelr1_1_#ii#') and isdefined('t_gelr5_1_#ii#') and isdefined('t_lista_1_#ii#') and evaluate('t_gelr1_1_#ii#') neq 0 and evaluate('t_gelr5_1_#ii#') neq 0 and evaluate('t_lista_1_#ii#') neq 0>
                            <cfif (evaluate('t_gelr5_1_#ii#')/evaluate('t_gelr1_1_#ii#'))*(evaluate('t_gelr1_1_#ii#')/evaluate('t_lista_1_#ii#'))*100 gte t_islem><font color="green">#Tlformat((evaluate('t_gelr5_1_#ii#')/evaluate('t_gelr1_1_#ii#'))*(evaluate('t_gelr1_1_#ii#')/evaluate('t_lista_1_#ii#'))*100,2)#%</font><cfelse><font color="red">#Tlformat((evaluate('t_gelr5_1_#ii#')/evaluate('t_gelr1_1_#ii#'))*(evaluate('t_gelr1_1_#ii#')/evaluate('t_lista_1_#ii#'))*100,2)#%</font></cfif>     
                        <cfelse>
                            0,00&nbsp;
                        </cfif>
                    <cfelseif t_row eq 33>
						<cfif isdefined('t_gelr1_1_#ii#') and isdefined('t_gelr5_1_#ii#') and isdefined('t_list5_1_#ii#') and evaluate('t_gelr1_1_#ii#') neq 0 and evaluate('t_gelr5_1_#ii#') neq 0 and evaluate('t_list5_1_#ii#') neq 0>
                            <cfif (evaluate('t_gelr5_1_#ii#')/evaluate('t_gelr1_1_#ii#'))*(evaluate('t_gelr1_1_#ii#')/evaluate('t_list5_1_#ii#'))*100 gte t_islem><font color="green">#Tlformat((evaluate('t_gelr5_1_#ii#')/evaluate('t_gelr1_1_#ii#'))*(evaluate('t_gelr1_1_#ii#')/evaluate('t_list5_1_#ii#'))*100,2)#%</font><cfelse><font color="red">#Tlformat((evaluate('t_gelr5_1_#ii#')/evaluate('t_gelr1_1_#ii#'))*(evaluate('t_gelr1_1_#ii#')/evaluate('t_list5_1_#ii#'))*100,2)#%</font></cfif>     
                        <cfelse>
                            0,00&nbsp;
                        </cfif>                                 	       
                    </cfif> 
                </td>
                <td style="text-align:right; width:5px">&nbsp;</td>
            </cfloop>
       	</cfcase>
      	<cfcase value="2"><!---Üç Aylık Bazında--->
         	<cfloop from="#sene1#" to="#sene2#" index="ii">
            	<cfloop from="1" to="#period_say#" index="i">
                	<td style="text-align:right; width:80px" <cfif DayofYear(evaluate('period_flu_#i#_#ii#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_#i#_#ii#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>
                         <cfif t_row eq 1>
							 <cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and evaluate('t_list1_#i#_#ii#') neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                                #Tlformat((evaluate('t_list1_#i#_#ii#')+evaluate('t_list3_#i#_#ii#'))/1000,2)#
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                       	<cfelseif t_row eq 2>
                        	<cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and evaluate('t_list1_#i#_#ii#') neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                                #Tlformat((evaluate('t_list1_#i#_#ii#')/evaluate('t_list3_#i#_#ii#')*-1),2)#
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                    	<cfelseif t_row eq 3>
                        	<cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and evaluate('t_list1_#i#_#ii#') neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                            	<cfif (evaluate('t_list1_#i#_#ii#')/evaluate('t_list3_#i#_#ii#')*-1) gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>
                            <cfelse>
                                &nbsp;
                            </cfif>
                      	<cfelseif t_row eq 4>
                        	<cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_list15_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and evaluate('t_list1_#i#_#ii#')-evaluate('t_list15_#i#_#ii#') neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                                #Tlformat(((evaluate('t_list1_#i#_#ii#')-evaluate('t_list15_#i#_#ii#'))/evaluate('t_list3_#i#_#ii#')*-1),2)#
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                    	<cfelseif t_row eq 5>
                        	<cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_list15_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and evaluate('t_list1_#i#_#ii#')-evaluate('t_list15_#i#_#ii#') neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                            	<cfif ((evaluate('t_list1_#i#_#ii#')-evaluate('t_list15_#i#_#ii#'))/evaluate('t_list3_#i#_#ii#')*-1) gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>
                            <cfelse>
                                &nbsp;
                            </cfif>
                       	<cfelseif t_row eq 6>
                        	<cfif isdefined('t_list10_#i#_#ii#') and isdefined('t_list11_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and evaluate('t_list10_#i#_#ii#') + evaluate('t_list11_#i#_#ii#') neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                                #Tlformat(((evaluate('t_list10_#i#_#ii#')+evaluate('t_list11_#i#_#ii#'))/evaluate('t_list3_#i#_#ii#')*-1),2)#
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                    	<cfelseif t_row eq 7>
                        	<cfif isdefined('t_list10_#i#_#ii#') and isdefined('t_list11_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and evaluate('t_list10_#i#_#ii#') + evaluate('t_list11_#i#_#ii#') neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                            	<cfif ((evaluate('t_list10_#i#_#ii#')+evaluate('t_list11_#i#_#ii#'))/evaluate('t_list3_#i#_#ii#')*-1) gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>
                            <cfelse>
                                &nbsp;
                            </cfif>
                      	<cfelseif t_row eq 8>
							<cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and isdefined('t_list15_#i#_#ii#') and isdefined('t_list18_#i#_#ii#') and evaluate('t_list1_#i#_#ii#')-(evaluate('t_list15_#i#_#ii#')+evaluate('t_list18_#i#_#ii#')) neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                                #Tlformat(((evaluate('t_list1_#i#_#ii#')-(evaluate('t_list15_#i#_#ii#')+evaluate('t_list18_#i#_#ii#')))/evaluate('t_list3_#i#_#ii#')*-1),2)#   
                            <cfelse>
                                 0,00&nbsp;
                            </cfif>
                      	<cfelseif t_row eq 9>
                     		<cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and isdefined('t_list15_#i#_#ii#') and isdefined('t_list18_#i#_#ii#') and evaluate('t_list1_#i#_#ii#')-(evaluate('t_list15_#i#_#ii#')+evaluate('t_list18_#i#_#ii#')) neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                				<cfif ((evaluate('t_list1_#i#_#ii#')-(evaluate('t_list15_#i#_#ii#')+evaluate('t_list18_#i#_#ii#')))/evaluate('t_list3_#i#_#ii#')*-1) gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>   
                        	<cfelse>
                             	0,00&nbsp;
                        	</cfif>
                      	<cfelseif t_row eq 10>
							<cfif isdefined('t_gelr1_#i#_#ii#') and isdefined('t_gelr2_#i#_#ii#') and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('t_gelr2_#i#_#ii#') neq 0>
                                <cfif evaluate('t_gelr2_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#')*100 gte t_islem><font color="green">#Tlformat(evaluate('t_gelr2_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#')*100,2)#%</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr2_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#')*100,2)#%</font></cfif>     
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                     	<cfelseif t_row eq 11>
							<cfif isdefined('t_gelr1_#i#_#ii#') and isdefined('t_gelr5_#i#_#ii#') and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('t_gelr5_#i#_#ii#') neq 0>
                                <cfif evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#')*100 gte t_islem><font color="green">#Tlformat(evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#')*100,2)#%</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#')*100,2)#%</font></cfif>     
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
						<cfelseif t_row eq 12>
                            <cfif isdefined('t_gelr16_#i#_#ii#') and isdefined('t_gelr5e_#i#_#ii#') and isdefined('t_listp_#i#_#ii#') and -evaluate('t_gelr16_#i#_#ii#') + evaluate('t_gelr5e_#i#_#ii#') neq 0 and evaluate('t_listp_#i#_#ii#') neq 0>
                                #Tlformat((-(evaluate('t_gelr16_#i#_#ii#') + evaluate('t_gelr5e_#i#_#ii#'))/(evaluate('t_listp_#i#_#ii#'))*100),2)#% 
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                       	<cfelseif t_row eq 13>
                            <cfif isdefined('t_gelr16_#i#_#ii#') and isdefined('t_gelr5e_#i#_#ii#') and -evaluate('t_gelr16_#i#_#ii#') + evaluate('t_gelr5e_#i#_#ii#') neq 0 and evaluate('t_gelr16_#i#_#ii#') neq 0>
                                #Tlformat((-(evaluate('t_gelr16_#i#_#ii#') + evaluate('t_gelr5e_#i#_#ii#'))/-(evaluate('t_gelr16_#i#_#ii#'))*100),2)#% 
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                      	<cfelseif t_row eq 14>
							<cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_lista_#i#_#ii#') and evaluate('t_list1_#i#_#ii#') neq 0 and evaluate('t_lista_#i#_#ii#') neq 0>
                                <cfif evaluate('t_list1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#')),2)#</font></cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                       	<cfelseif t_row eq 15>
							<cfif isdefined('t_list2_#i#_#ii#') and isdefined('t_lista_#i#_#ii#') and evaluate('t_list2_#i#_#ii#') neq 0 and evaluate('t_lista_#i#_#ii#') neq 0>
                                <cfif evaluate('t_list2_#i#_#ii#')/evaluate('t_lista_#i#_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list2_#i#_#ii#')/evaluate('t_lista_#i#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list2_#i#_#ii#')/evaluate('t_lista_#i#_#ii#')),2)#</font></cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                        <cfelseif t_row eq 16>
							<cfif isdefined('t_list2_#i#_#ii#') and isdefined('t_listp_#i#_#ii#') and evaluate('t_list2_#i#_#ii#') neq 0 and evaluate('t_listp_#i#_#ii#') neq 0>
                                <cfif evaluate('t_list3_#i#_#ii#')/evaluate('t_listp_#i#_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list3_#i#_#ii#')/evaluate('t_listp_#i#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list3_#i#_#ii#')/evaluate('t_listp_#i#_#ii#')),2)#</font></cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                        <cfelseif t_row eq 17>
							<cfif isdefined('t_list4_#i#_#ii#') and isdefined('t_listp_#i#_#ii#') and evaluate('t_list4_#i#_#ii#') neq 0 and evaluate('t_listp_#i#_#ii#') neq 0>
                                <cfif evaluate('t_list4_#i#_#ii#')/evaluate('t_listp_#i#_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list4_#i#_#ii#')/evaluate('t_listp_#i#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list4_#i#_#ii#')/evaluate('t_listp_#i#_#ii#')),2)#</font></cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                       	<cfelseif t_row eq 18>
							<cfif isdefined('t_list5_#i#_#ii#') and isdefined('t_listp_#i#_#ii#') and evaluate('t_list5_#i#_#ii#') neq 0 and evaluate('t_listp_#i#_#ii#') neq 0>
                                <cfif evaluate('t_list5_#i#_#ii#')/evaluate('t_listp_#i#_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list5_#i#_#ii#')/evaluate('t_listp_#i#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list5_#i#_#ii#')/evaluate('t_listp_#i#_#ii#')),2)#</font></cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                        <cfelseif t_row eq 19>
							<cfif isdefined('t_list5_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and isdefined('t_list4_#i#_#ii#') and evaluate('t_list5_#i#_#ii#') neq 0 and evaluate('t_list3_#i#_#ii#')+evaluate('t_list4_#i#_#ii#') neq 0>
                                <cfif (evaluate('t_list3_#i#_#ii#')+evaluate('t_list4_#i#_#ii#'))/evaluate('t_list5_#i#_#ii#') lt t_islem><font color="green">#Tlformat((evaluate('t_list3_#i#_#ii#')+evaluate('t_list4_#i#_#ii#'))/evaluate('t_list5_#i#_#ii#'),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list3_#i#_#ii#')+evaluate('t_list4_#i#_#ii#'))/evaluate('t_list5_#i#_#ii#'),2)#</font></cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                        <cfelseif t_row eq 20>
							<cfif isdefined('t_gelr1_#i#_#ii#') and isdefined('t_lista_#i#_#ii#') and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('t_lista_#i#_#ii#') neq 0>
                                <cfif -evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#') gte t_islem><font color="green">#Tlformat((-evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((-evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#')),2)#</font></cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                         <cfelseif t_row eq 21>
							<cfif i eq 1>
                            	<cfif ii eq attributes.date1>
									<cfif isdefined('t_listst') and isdefined('t_listst_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listst_#i#_#ii#') + t_listst neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                        <cfif evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+t_listst)/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+t_listst)/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+t_listst)/2),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                               	<cfelse>
                                     <cfset ik = ii - 1>
                                     <cfset k = 4>
                                     <cfif isdefined('t_listst_#k#_#ik#') and isdefined('t_listst_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listst_#i#_#ii#') + evaluate('t_listst_#k#_#ik#') neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                        <cfif evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ik#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ik#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ik#'))/2),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                                     
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listst_#k#_#ii#') and isdefined('t_listst_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listst_#k#_#ii#') + evaluate('t_listst_#i#_#ii#') neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ii#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ii#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ii#'))/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                       	<cfelseif t_row eq 22>
							<cfif i eq 1>
                            	<cfif ii eq attributes.date1>
									<cfif isdefined('t_listst') and isdefined('t_listst_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listst_#i#_#ii#') + t_listst neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                        <cfif 365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+t_listst)/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+t_listst)/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+t_listst)/2)),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                               	<cfelse>
                                     <cfset ik = ii - 1>
                                     <cfset k = 4>
                                     <cfif isdefined('t_listst_#k#_#ik#') and isdefined('t_listst_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listst_#i#_#ii#') + evaluate('t_listst_#k#_#ik#') neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                        <cfif 365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ik#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ik#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ik#'))/2)),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                                     
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listst_#k#_#ii#') and isdefined('t_listst_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listst_#k#_#ii#') + evaluate('t_listst_#i#_#ii#') neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                    <cfif 365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ii#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ii#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ii#'))/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                       	<cfelseif t_row eq 23>
							<cfif i eq 1>
                            	<cfif ii eq attributes.date1>
									<cfif isdefined('t_listsa') and isdefined('t_listsa_#i#_#ii#') and isdefined('t_gelrsa_#i#_#ii#') and evaluate('t_listsa_#i#_#ii#') + t_listsa neq 0 and evaluate('t_gelrsa_#i#_#ii#') neq 0>
                                        <cfif evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+t_listsa)/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+t_listsa)/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+t_listsa)/2),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                               	<cfelse>
                                     <cfset ik = ii - 1>
                                     <cfset k = 4>
                                     <cfif isdefined('t_listsa_#k#_#ik#') and isdefined('t_listsa_#i#_#ii#') and isdefined('t_gelrsa_#i#_#ii#') and evaluate('t_listsa_#i#_#ii#') + evaluate('t_listsa_#k#_#ik#') neq 0 and evaluate('t_gelrsa_#i#_#ii#') neq 0>
                                        <cfif evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ik#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ik#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ik#'))/2),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                                     
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listsa_#k#_#ii#') and isdefined('t_listsa_#i#_#ii#') and isdefined('t_gelrsa_#i#_#ii#') and evaluate('t_listsa_#k#_#ii#') + evaluate('t_listsa_#i#_#ii#') neq 0 and evaluate('t_gelrsa_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ii#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ii#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ii#'))/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                       	<cfelseif t_row eq 24>
							<cfif i eq 1>
                            	<cfif ii eq attributes.date1>
									<cfif isdefined('t_listsa') and isdefined('t_listsa_#i#_#ii#') and isdefined('t_gelrsa_#i#_#ii#') and evaluate('t_listsa_#i#_#ii#') + t_listsa neq 0 and evaluate('t_gelrsa_#i#_#ii#') neq 0>
                                        <cfif 365/(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+t_listsa)/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+t_listsa)/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+t_listsa)/2)),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                               	<cfelse>
                                     <cfset ik = ii - 1>
                                     <cfset k = 4>
                                     <cfif isdefined('t_listsa_#k#_#ik#') and isdefined('t_listsa_#i#_#ii#') and isdefined('t_gelrsa_#i#_#ii#') and evaluate('t_listsa_#i#_#ii#') + evaluate('t_listsa_#k#_#ik#') neq 0 and evaluate('t_gelrsa_#i#_#ii#') neq 0>
                                        <cfif 365/(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ik#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ik#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ik#'))/2)),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                                     
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listsa_#k#_#ii#') and isdefined('t_listsa_#i#_#ii#') and isdefined('t_gelrsa_#i#_#ii#') and evaluate('t_listsa_#k#_#ii#') + evaluate('t_listsa_#i#_#ii#') neq 0 and evaluate('t_gelrsa_#i#_#ii#') neq 0>
                                    <cfif 365/(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ii#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ii#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ii#'))/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                       	<cfelseif t_row eq 25>
							<cfif i eq 1>
                            	<cfif ii eq attributes.date1>
									<cfif isdefined('t_listsb') and isdefined('t_listsb_#i#_#ii#') and isdefined('t_gelrsb_#i#_#ii#') and evaluate('t_listsb_#i#_#ii#') + t_listsb neq 0 and evaluate('t_gelrsb_#i#_#ii#') neq 0>
                                        <cfif evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+t_listsb)/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+t_listsb)/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+t_listsb)/2),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                               	<cfelse>
                                     <cfset ik = ii - 1>
                                     <cfset k = 4>
                                     <cfif isdefined('t_listsb_#k#_#ik#') and isdefined('t_listsb_#i#_#ii#') and isdefined('t_gelrsb_#i#_#ii#') and evaluate('t_listsb_#i#_#ii#') + evaluate('t_listsb_#k#_#ik#') neq 0 and evaluate('t_gelrsb_#i#_#ii#') neq 0>
                                        <cfif evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ik#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ik#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ik#'))/2),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                                     
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listsb_#k#_#ii#') and isdefined('t_listsb_#i#_#ii#') and isdefined('t_gelrsb_#i#_#ii#') and evaluate('t_listsb_#k#_#ii#') + evaluate('t_listsb_#i#_#ii#') neq 0 and evaluate('t_gelrsb_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ii#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ii#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ii#'))/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                       	<cfelseif t_row eq 26>
							<cfif i eq 1>
                            	<cfif ii eq attributes.date1>
									<cfif isdefined('t_listsb') and isdefined('t_listsb_#i#_#ii#') and isdefined('t_gelrsb_#i#_#ii#') and evaluate('t_listsb_#i#_#ii#') + t_listsb neq 0 and evaluate('t_gelrsb_#i#_#ii#') neq 0>
                                        <cfif 365/(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+t_listsb)/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+t_listsb)/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+t_listsb)/2)),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                               	<cfelse>
                                     <cfset ik = ii - 1>
                                     <cfset k = 4>
                                     <cfif isdefined('t_listsb_#k#_#ik#') and isdefined('t_listsb_#i#_#ii#') and isdefined('t_gelrsb_#i#_#ii#') and evaluate('t_listsb_#i#_#ii#') + evaluate('t_listsb_#k#_#ik#') neq 0 and evaluate('t_gelrsb_#i#_#ii#') neq 0>
                                        <cfif 365/(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ik#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ik#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ik#'))/2)),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                                     
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listsb_#k#_#ii#') and isdefined('t_listsb_#i#_#ii#') and isdefined('t_gelrsb_#i#_#ii#') and evaluate('t_listsb_#k#_#ii#') + evaluate('t_listsb_#i#_#ii#') neq 0 and evaluate('t_gelrsb_#i#_#ii#') neq 0>
                                    <cfif 365/(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ii#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ii#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ii#'))/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                       	<cfelseif t_row eq 27>
							<cfif i eq 1>
                            	<cfif ii eq attributes.date1>
									<cfif isdefined('t_listtb') and isdefined('t_listtb_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listtb_#i#_#ii#') + t_listtb neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                        <cfif evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+t_listtb)/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+t_listtb)/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+t_listtb)/2),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                               	<cfelse>
                                     <cfset ik = ii - 1>
                                     <cfset k = 4>
                                     <cfif isdefined('t_listtb_#k#_#ik#') and isdefined('t_listtb_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listtb_#i#_#ii#') + evaluate('t_listtb_#k#_#ik#') neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                        <cfif evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ik#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ik#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ik#'))/2),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                                     
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listtb_#k#_#ii#') and isdefined('t_listtb_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listtb_#k#_#ii#') + evaluate('t_listtb_#i#_#ii#') neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ii#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ii#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ii#'))/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                       	<cfelseif t_row eq 28>
							<cfif i eq 1>
                            	<cfif ii eq attributes.date1>
									<cfif isdefined('t_listtb') and isdefined('t_listtb_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listtb_#i#_#ii#') + t_listtb neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                        <cfif 365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+t_listtb)/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+t_listtb)/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+t_listtb)/2)),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                               	<cfelse>
                                     <cfset ik = ii - 1>
                                     <cfset k = 4>
                                     <cfif isdefined('t_listtb_#k#_#ik#') and isdefined('t_listtb_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listtb_#i#_#ii#') + evaluate('t_listtb_#k#_#ik#') neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                        <cfif 365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ik#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ik#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ik#'))/2)),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                                     
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listtb_#k#_#ii#') and isdefined('t_listtb_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listtb_#k#_#ii#') + evaluate('t_listtb_#i#_#ii#') neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                    <cfif 365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ii#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ii#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ii#'))/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                        <cfelseif t_row eq 29>
							<cfif i eq 1>
                            	<cfif ii eq attributes.date1>
									<cfif isdefined('t_listta') and isdefined('t_listta_#i#_#ii#') and isdefined('t_gelr1_#i#_#ii#') and evaluate('t_listta_#i#_#ii#') + t_listta neq 0 and evaluate('t_gelr1_#i#_#ii#') neq 0>
                                        <cfif evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+t_listta)/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+t_listta)/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+t_listta)/2),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                               	<cfelse>
                                     <cfset ik = ii - 1>
                                     <cfset k = 4>
                                     <cfif isdefined('t_listta_#k#_#ik#') and isdefined('t_listta_#i#_#ii#') and isdefined('t_gelr1_#i#_#ii#') and evaluate('t_listta_#i#_#ii#') + evaluate('t_listta_#k#_#ik#') neq 0 and evaluate('t_gelr1_#i#_#ii#') neq 0>
                                        <cfif evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ik#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ik#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ik#'))/2),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                                     
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listta_#k#_#ii#') and isdefined('t_listta_#i#_#ii#') and isdefined('t_gelr1_#i#_#ii#') and evaluate('t_listta_#k#_#ii#') + evaluate('t_listta_#i#_#ii#') neq 0 and evaluate('t_gelr1_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ii#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ii#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ii#'))/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                       	<cfelseif t_row eq 30>
							<cfif i eq 1>
                            	<cfif ii eq attributes.date1>
									<cfif isdefined('t_listta') and isdefined('t_listta_#i#_#ii#') and isdefined('t_gelr1_#i#_#ii#') and evaluate('t_listta_#i#_#ii#') + t_listta neq 0 and evaluate('t_gelr1_#i#_#ii#') neq 0>
                                        <cfif 365/(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+t_listta)/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+t_listta)/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+t_listta)/2)),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                               	<cfelse>
                                     <cfset ik = ii - 1>
                                     <cfset k = 4>
                                     <cfif isdefined('t_listta_#k#_#ik#') and isdefined('t_listta_#i#_#ii#') and isdefined('t_gelr1_#i#_#ii#') and evaluate('t_listta_#i#_#ii#') + evaluate('t_listta_#k#_#ik#') neq 0 and evaluate('t_gelr1_#i#_#ii#') neq 0>
                                        <cfif 365/(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ik#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ik#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ik#'))/2)),2)#</font></cfif>
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                                     
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listta_#k#_#ii#') and isdefined('t_listta_#i#_#ii#') and isdefined('t_gelr1_#i#_#ii#') and evaluate('t_listta_#k#_#ii#') + evaluate('t_listta_#i#_#ii#') neq 0 and evaluate('t_gelr1_#i#_#ii#') neq 0>
                                    <cfif 365/(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ii#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ii#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ii#'))/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                        <cfelseif t_row eq 31>
							<cfif isdefined('t_gelr1_#i#_#ii#') and isdefined('t_gelr5_#i#_#ii#') and isdefined('t_lista_#i#_#ii#') and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('t_gelr5_#i#_#ii#') neq 0 and evaluate('t_lista_#i#_#ii#') neq 0>
                                <cfif (evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#'))*100 gte t_islem><font color="green">#Tlformat((evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#'))*100,2)#%</font><cfelse><font color="red">#Tlformat((evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#'))*100,2)#%</font></cfif>     
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                        <cfelseif t_row eq 32>
							<cfif isdefined('t_gelr1_#i#_#ii#') and isdefined('t_gelr5_#i#_#ii#') and isdefined('t_lista_#i#_#ii#') and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('t_gelr5_#i#_#ii#') neq 0 and evaluate('t_lista_#i#_#ii#') neq 0>
                                <cfif (evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#'))*100 gte t_islem><font color="green">#Tlformat((evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#'))*100,2)#%</font><cfelse><font color="red">#Tlformat((evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#'))*100,2)#%</font></cfif>     
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                         <cfelseif t_row eq 33>
							<cfif isdefined('t_gelr1_#i#_#ii#') and isdefined('t_gelr5_#i#_#ii#') and isdefined('t_list5_#i#_#ii#') and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('t_gelr5_#i#_#ii#') neq 0 and evaluate('t_list5_#i#_#ii#') neq 0>
                                <cfif (evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_list5_#i#_#ii#'))*100 gte t_islem><font color="green">#Tlformat((evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_list5_#i#_#ii#'))*100,2)#%</font><cfelse><font color="red">#Tlformat((evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_list5_#i#_#ii#'))*100,2)#%</font></cfif>     
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                            
                       	<cfelseif t_row eq 34>
							<cfif i eq 1>
                            	<cfif ii eq attributes.date1>
									<cfif isdefined('t_gelr1') and isdefined('t_gelr1_#i#_#ii#') and isdefined('TUFE_RATE_#i#_#ii#') and t_gelr1 neq 0 and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('TUFE_RATE_#i#_#ii#') neq 0>
                                       #Tlformat((evaluate('t_gelr1_#i#_#ii#')/t_gelr1)/(100 + evaluate('TUFE_RATE_#i#_#ii#'))-1,2)#
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                               	<cfelse>
                                     <cfset ik = ii - 1>
                                     <cfset k = 4>
                                     <cfif isdefined('t_gelr1_#k#_#ii#') and isdefined('t_gelr1_#i#_#ii#') and isdefined('TUFE_RATE_#i#_#ii#') and evaluate('t_gelr1_#k#_#ii#') neq 0 and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('TUFE_RATE_#i#_#ii#') neq 0>
                                        #Tlformat((evaluate('t_gelr1_#i#_#ii#')/evaluate('t_gelr1_#k#_#ii#'))/(100 + evaluate('TUFE_RATE_#i#_#ii#'))-1,2)#
                                    <cfelse>
                                        0,00&nbsp;
                                    </cfif>
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_gelr1_#k#_#ii#') and isdefined('t_gelr1_#i#_#ii#') and isdefined('TUFE_RATE_#i#_#ii#') and evaluate('t_gelr1_#k#_#ii#') neq 0 and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('TUFE_RATE_#i#_#ii#') neq 0>
                                 	#Tlformat((evaluate('t_gelr1_#i#_#ii#')/evaluate('t_gelr1_#k#_#ii#'))/(100 + evaluate('TUFE_RATE_#i#_#ii#'))-1,2)#
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>                                                                                                                              
                    	</cfif>      
                   	</td>
               	</cfloop>
                <td width="5" >&nbsp;</td>
         	</cfloop>
      	</cfcase>
		<cfcase value="3"><!---Ay Bazında--->
        	<cfloop from="#sene1#" to="#sene2#" index="ii">
                 <cfloop from="1" to="#period_say#" index="i">
                	<td style="text-align:right; width:80px" <cfif DayofYear(evaluate('period_flu_#i#_#ii#')) gt DayofYear(period_date_lock) and Year(evaluate('period_flu_#i#_#ii#')) eq Year(period_date_lock)>style="filter:alpha(Opacity=50,FinishOpacity=40);"</cfif>>
						<cfif t_row eq 1>
							 <cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and evaluate('t_list1_#i#_#ii#') neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                                #Tlformat((evaluate('t_list1_#i#_#ii#')-evaluate('t_list3_#i#_#ii#'))/1000,2)#
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                       	<cfelseif t_row eq 2>
                    		<cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and evaluate('t_list1_#i#_#ii#') neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                                #Tlformat((evaluate('t_list1_#i#_#ii#')/evaluate('t_list3_#i#_#ii#')*-1),2)#
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                      	<cfelseif t_row eq 3>
                    		<cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and evaluate('t_list1_#i#_#ii#') neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                            	<cfif (evaluate('t_list1_#i#_#ii#')/evaluate('t_list3_#i#_#ii#')*-1) gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>
                            <cfelse>
                                &nbsp;
                            </cfif>
                      	<cfelseif t_row eq 4>
                        	<cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_list15_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and evaluate('t_list1_#i#_#ii#')-evaluate('t_list15_#i#_#ii#') neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                                #Tlformat(((evaluate('t_list1_#i#_#ii#')-evaluate('t_list15_#i#_#ii#'))/evaluate('t_list3_#i#_#ii#')*-1),2)#
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                    	<cfelseif t_row eq 5>
                        	<cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_list15_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and evaluate('t_list1_#i#_#ii#')-evaluate('t_list15_#i#_#ii#') neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                            	<cfif ((evaluate('t_list1_#i#_#ii#')-evaluate('t_list15_#i#_#ii#'))/evaluate('t_list3_#i#_#ii#')*-1) gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>
                            <cfelse>
                                &nbsp;
                            </cfif>
                       	<cfelseif t_row eq 6>
                        	<cfif isdefined('t_list10_#i#_#ii#') and isdefined('t_list11_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and (evaluate('t_list10_#i#_#ii#') + evaluate('t_list11_#i#_#ii#')) neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                                #Tlformat(((evaluate('t_list10_#i#_#ii#')+evaluate('t_list11_#i#_#ii#'))/evaluate('t_list3_#i#_#ii#')*-1),2)#
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                    	<cfelseif t_row eq 7>
                        	<cfif isdefined('t_list10_#i#_#ii#') and isdefined('t_list11_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and (evaluate('t_list10_#i#_#ii#') + evaluate('t_list11_#i#_#ii#')) neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                            	<cfif ((evaluate('t_list10_#i#_#ii#')+evaluate('t_list11_#i#_#ii#'))/evaluate('t_list3_#i#_#ii#')*-1) gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>
                            <cfelse>
                                &nbsp;
                            </cfif>
                     	<cfelseif t_row eq 8>
							<cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and isdefined('t_list15_#i#_#ii#') and isdefined('t_list18_#i#_#ii#') and evaluate('t_list1_#i#_#ii#')-(evaluate('t_list15_#i#_#ii#')+evaluate('t_list18_#i#_#ii#')) neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                                #Tlformat(((evaluate('t_list1_#i#_#ii#')-(evaluate('t_list15_#i#_#ii#')+evaluate('t_list18_#i#_#ii#')))/evaluate('t_list3_#i#_#ii#')*-1),2)#   
                            <cfelse>
                                 0,00&nbsp;
                            </cfif> 
                      	<cfelseif t_row eq 9>
                     		<cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and isdefined('t_list15_#i#_#ii#') and isdefined('t_list18_#i#_#ii#') and evaluate('t_list1_#i#_#ii#')-(evaluate('t_list15_#i#_#ii#')+evaluate('t_list18_#i#_#ii#')) neq 0 and evaluate('t_list3_#i#_#ii#') neq 0>
                				<cfif ((evaluate('t_list1_#i#_#ii#')-(evaluate('t_list15_#i#_#ii#')+evaluate('t_list18_#i#_#ii#')))/evaluate('t_list3_#i#_#ii#')*-1) gte t_islem><font color="green">OLUMLU</font><cfelse><font color="red">OLUMSUZ</font></cfif>   
                        	<cfelse>
                             	0,00&nbsp;
                        	</cfif>             
                       	<cfelseif t_row eq 10>
							<cfif isdefined('t_gelr1_#i#_#ii#') and isdefined('t_gelr2_#i#_#ii#') and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('t_gelr2_#i#_#ii#') neq 0>
                                <cfif evaluate('t_gelr2_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#')*100 gte t_islem><font color="green">#Tlformat(evaluate('t_gelr2_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#')*100,2)#%</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr2_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#')*100,2)#%</font></cfif>     
                            <cfelse>
                                0,00&nbsp;
                            </cfif> 
                      	<cfelseif t_row eq 11>
							<cfif isdefined('t_gelr1_#i#_#ii#') and isdefined('t_gelr5_#i#_#ii#') and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('t_gelr5_#i#_#ii#') neq 0>
                                <cfif evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#')*100 gte t_islem><font color="green">#Tlformat(evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#')*100,2)#%</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#')*100,2)#%</font></cfif>     
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                      	<cfelseif t_row eq 12>
                            <cfif isdefined('t_gelr16_#i#_#ii#') and isdefined('t_gelr5e_#i#_#ii#') and isdefined('t_listp_#i#_#ii#') and -evaluate('t_gelr16_#i#_#ii#') + evaluate('t_gelr5e_#i#_#ii#') neq 0 and evaluate('t_listp_#i#_#ii#') neq 0>
                                #Tlformat((-(evaluate('t_gelr16_#i#_#ii#') + evaluate('t_gelr5e_#i#_#ii#'))/(evaluate('t_listp_#i#_#ii#'))*100),2)#% 
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                       	<cfelseif t_row eq 13>
                            <cfif isdefined('t_gelr16_#i#_#ii#') and isdefined('t_gelr5e_#i#_#ii#') and -evaluate('t_gelr16_#i#_#ii#') + evaluate('t_gelr5e_#i#_#ii#') neq 0 and evaluate('t_gelr16_#i#_#ii#') neq 0>
                                #Tlformat((-(evaluate('t_gelr16_#i#_#ii#') + evaluate('t_gelr5e_#i#_#ii#'))/-(evaluate('t_gelr16_#i#_#ii#'))*100),2)#% 
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                      	<cfelseif t_row eq 14>
							<cfif isdefined('t_list1_#i#_#ii#') and isdefined('t_lista_#i#_#ii#') and evaluate('t_list1_#i#_#ii#') neq 0 and evaluate('t_lista_#i#_#ii#') neq 0>
                                <cfif evaluate('t_list1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#')),2)#</font></cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                       	<cfelseif t_row eq 15>
							<cfif isdefined('t_list2_#i#_#ii#') and isdefined('t_lista_#i#_#ii#') and evaluate('t_list2_#i#_#ii#') neq 0 and evaluate('t_lista_#i#_#ii#') neq 0>
                                <cfif evaluate('t_list2_#i#_#ii#')/evaluate('t_lista_#i#_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list2_#i#_#ii#')/evaluate('t_lista_#i#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list2_#i#_#ii#')/evaluate('t_lista_#i#_#ii#')),2)#</font></cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                       	<cfelseif t_row eq 16>
							<cfif isdefined('t_list3_#i#_#ii#') and isdefined('t_listp_#i#_#ii#') and evaluate('t_list3_#i#_#ii#') neq 0 and evaluate('t_listp_#i#_#ii#') neq 0>
                                <cfif evaluate('t_list3_#i#_#ii#')/evaluate('t_listp_#i#_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list3_#i#_#ii#')/evaluate('t_listp_#i#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list3_#i#_#ii#')/evaluate('t_listp_#i#_#ii#')),2)#</font></cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                        <cfelseif t_row eq 17>
							<cfif isdefined('t_list4_#i#_#ii#') and isdefined('t_listp_#i#_#ii#') and evaluate('t_list4_#i#_#ii#') neq 0 and evaluate('t_listp_#i#_#ii#') neq 0>
                                <cfif evaluate('t_list4_#i#_#ii#')/evaluate('t_listp_#i#_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list4_#i#_#ii#')/evaluate('t_listp_#i#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list4_#i#_#ii#')/evaluate('t_listp_#i#_#ii#')),2)#</font></cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                         <cfelseif t_row eq 18>
							<cfif isdefined('t_list5_#i#_#ii#') and isdefined('t_listp_#i#_#ii#') and evaluate('t_list5_#i#_#ii#') neq 0 and evaluate('t_listp_#i#_#ii#') neq 0>
                                <cfif evaluate('t_list5_#i#_#ii#')/evaluate('t_listp_#i#_#ii#') gte t_islem><font color="green">#Tlformat((evaluate('t_list5_#i#_#ii#')/evaluate('t_listp_#i#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list5_#i#_#ii#')/evaluate('t_listp_#i#_#ii#')),2)#</font></cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                         <cfelseif t_row eq 19>
							<cfif isdefined('t_list5_#i#_#ii#') and isdefined('t_list3_#i#_#ii#') and isdefined('t_list4_#i#_#ii#') and evaluate('t_list5_#i#_#ii#') neq 0 and evaluate('t_list3_#i#_#ii#')+evaluate('t_list4_#i#_#ii#') neq 0>
                                <cfif (evaluate('t_list3_#i#_#ii#')+evaluate('t_list4_#i#_#ii#'))/evaluate('t_list5_#i#_#ii#') lt t_islem><font color="green">#Tlformat((evaluate('t_list3_#i#_#ii#')+evaluate('t_list4_#i#_#ii#'))/evaluate('t_list5_#i#_#ii#'),2)#</font><cfelse><font color="red">#Tlformat((evaluate('t_list3_#i#_#ii#')+evaluate('t_list4_#i#_#ii#'))/evaluate('t_list5_#i#_#ii#'),2)#</font></cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                       	<cfelseif t_row eq 20>
							<cfif isdefined('t_gelr1_#i#_#ii#') and isdefined('t_lista_#i#_#ii#') and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('t_lista_#i#_#ii#') neq 0>
                                <cfif -evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#') gte t_islem><font color="green">#Tlformat((-evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#')),2)#</font><cfelse><font color="red">#Tlformat((-evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#')),2)#</font></cfif>
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                        <cfelseif t_row eq 21>
							<cfif i eq 1>
								<cfif isdefined('t_listst') and isdefined('t_listst_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listst_#i#_#ii#') + t_listst neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+t_listst)/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+t_listst)/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+t_listst)/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listst_#k#_#ii#') and isdefined('t_listst_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listst_#k#_#ii#') + evaluate('t_listst_#i#_#ii#') neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ii#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ii#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ii#'))/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                      	<cfelseif t_row eq 22>
							<cfif i eq 1>
								<cfif isdefined('t_listst') and isdefined('t_listst_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listst_#i#_#ii#') + t_listst neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                	<cfif 365 / (evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+t_listst)/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+t_listst)/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+t_listst)/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listst_#k#_#ii#') and isdefined('t_listst_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listst_#k#_#ii#') + evaluate('t_listst_#i#_#ii#') neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                    <cfif 365 / (evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ii#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ii#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listst_#i#_#ii#')+evaluate('t_listst_#k#_#ii#'))/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                    	<cfelseif t_row eq 23>
							<cfif i eq 1>
								<cfif isdefined('t_listsa') and isdefined('t_listsa_#i#_#ii#') and isdefined('t_gelrsa_#i#_#ii#') and evaluate('t_listsa_#i#_#ii#') + t_listsa neq 0 and evaluate('t_gelrsa_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+t_listsa)/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+t_listsa)/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+t_listsa)/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listsa_#k#_#ii#') and isdefined('t_listsa_#i#_#ii#') and isdefined('t_gelrsa_#i#_#ii#') and evaluate('t_listsa_#k#_#ii#') + evaluate('t_listsa_#i#_#ii#') neq 0 and evaluate('t_gelrsa_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ii#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ii#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ii#'))/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                      	<cfelseif t_row eq 24>
							<cfif i eq 1>
								<cfif isdefined('t_listsa') and isdefined('t_listsa_#i#_#ii#') and isdefined('t_gelrsa_#i#_#ii#') and evaluate('t_listsa_#i#_#ii#') + t_listsa neq 0 and evaluate('t_gelrsa_#i#_#ii#') neq 0>
                                	<cfif 365 / (evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+t_listsa)/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+t_listsa)/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+t_listsa)/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listsa_#k#_#ii#') and isdefined('t_listsa_#i#_#ii#') and isdefined('t_gelrsa_#i#_#ii#') and evaluate('t_listsa_#k#_#ii#') + evaluate('t_listsa_#i#_#ii#') neq 0 and evaluate('t_gelrsa_#i#_#ii#') neq 0>
                                    <cfif 365 / (evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ii#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ii#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelrsa_#i#_#ii#')/((evaluate('t_listsa_#i#_#ii#')+evaluate('t_listsa_#k#_#ii#'))/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                        <cfelseif t_row eq 25>
							<cfif i eq 1>
								<cfif isdefined('t_listsb') and isdefined('t_listsb_#i#_#ii#') and isdefined('t_gelrsb_#i#_#ii#') and evaluate('t_listsb_#i#_#ii#') + t_listsb neq 0 and evaluate('t_gelrsb_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+t_listsb)/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+t_listsb)/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+t_listsb)/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listsb_#k#_#ii#') and isdefined('t_listsb_#i#_#ii#') and isdefined('t_gelrsb_#i#_#ii#') and evaluate('t_listsb_#k#_#ii#') + evaluate('t_listsb_#i#_#ii#') neq 0 and evaluate('t_gelrsb_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ii#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ii#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ii#'))/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                      	<cfelseif t_row eq 26>
							<cfif i eq 1>
								<cfif isdefined('t_listsb') and isdefined('t_listsb_#i#_#ii#') and isdefined('t_gelrsb_#i#_#ii#') and evaluate('t_listsb_#i#_#ii#') + t_listsb neq 0 and evaluate('t_gelrsb_#i#_#ii#') neq 0>
                                	<cfif 365 / (evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+t_listsb)/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+t_listsb)/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+t_listsb)/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listsb_#k#_#ii#') and isdefined('t_listsb_#i#_#ii#') and isdefined('t_gelrsb_#i#_#ii#') and evaluate('t_listsb_#k#_#ii#') + evaluate('t_listsb_#i#_#ii#') neq 0 and evaluate('t_gelrsb_#i#_#ii#') neq 0>
                                    <cfif 365 / (evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ii#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ii#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelrsb_#i#_#ii#')/((evaluate('t_listsb_#i#_#ii#')+evaluate('t_listsb_#k#_#ii#'))/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                       	 <cfelseif t_row eq 27>
							<cfif i eq 1>
								<cfif isdefined('t_listtb') and isdefined('t_listtb_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listtb_#i#_#ii#') + t_listtb neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+t_listtb)/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+t_listtb)/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+t_listtb)/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listtb_#k#_#ii#') and isdefined('t_listtb_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listtb_#k#_#ii#') + evaluate('t_listtb_#i#_#ii#') neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ii#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ii#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ii#'))/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                      	<cfelseif t_row eq 28>
							<cfif i eq 1>
								<cfif isdefined('t_listtb') and isdefined('t_listtb_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listtb_#i#_#ii#') + t_listtb neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                	<cfif 365 / (evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+t_listtb)/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+t_listtb)/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+t_listtb)/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listtb_#k#_#ii#') and isdefined('t_listtb_#i#_#ii#') and isdefined('t_gelr12_#i#_#ii#') and evaluate('t_listtb_#k#_#ii#') + evaluate('t_listtb_#i#_#ii#') neq 0 and evaluate('t_gelr12_#i#_#ii#') neq 0>
                                    <cfif 365 / (evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ii#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ii#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr12_#i#_#ii#')/((evaluate('t_listtb_#i#_#ii#')+evaluate('t_listtb_#k#_#ii#'))/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                       	 <cfelseif t_row eq 29>
							<cfif i eq 1>
								<cfif isdefined('t_listta') and isdefined('t_listta_#i#_#ii#') and isdefined('t_gelr1_#i#_#ii#') and evaluate('t_listta_#i#_#ii#') + t_listta neq 0 and evaluate('t_gelr1_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+t_listta)/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+t_listta)/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+t_listta)/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listta_#k#_#ii#') and isdefined('t_listta_#i#_#ii#') and isdefined('t_gelr1_#i#_#ii#') and evaluate('t_listta_#k#_#ii#') + evaluate('t_listta_#i#_#ii#') neq 0 and evaluate('t_gelr1_#i#_#ii#') neq 0>
                                    <cfif evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ii#'))/2) gte t_islem><font color="green">#Tlformat(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ii#'))/2),2)#</font><cfelse><font color="red">#Tlformat(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ii#'))/2),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                      	<cfelseif t_row eq 30>
							<cfif i eq 1>
								<cfif isdefined('t_listta') and isdefined('t_listta_#i#_#ii#') and isdefined('t_gelr1_#i#_#ii#') and evaluate('t_listta_#i#_#ii#') + t_listta neq 0 and evaluate('t_gelr1_#i#_#ii#') neq 0>
                                	<cfif 365 / (evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+t_listta)/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+t_listta)/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+t_listta)/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                            <cfelse>
                                <cfset k = i - 1>
                                <cfif isdefined('t_listta_#k#_#ii#') and isdefined('t_listta_#i#_#ii#') and isdefined('t_gelr1_#i#_#ii#') and evaluate('t_listta_#k#_#ii#') + evaluate('t_listta_#i#_#ii#') neq 0 and evaluate('t_gelr1_#i#_#ii#') neq 0>
                                    <cfif 365 / (evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ii#'))/2)) lte t_islem><font color="green">#Tlformat(365/(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ii#'))/2)),2)#</font><cfelse><font color="red">#Tlformat(365/(evaluate('t_gelr1_#i#_#ii#')/((evaluate('t_listta_#i#_#ii#')+evaluate('t_listta_#k#_#ii#'))/2)),2)#</font></cfif>
                                <cfelse>
                                    0,00&nbsp;
                                </cfif>
                         	</cfif>
                       	<cfelseif t_row eq 31>
							<cfif isdefined('t_gelr1_#i#_#ii#') and isdefined('t_gelr5_#i#_#ii#') and isdefined('t_lista_#i#_#ii#') and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('t_gelr5_#i#_#ii#') neq 0 and evaluate('t_lista_#i#_#ii#') neq 0>
                                <cfif (evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#'))*100 gte t_islem><font color="green">#Tlformat((evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#'))*100,2)#%</font><cfelse><font color="red">#Tlformat((evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#'))*100,2)#%</font></cfif>     
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                        <cfelseif t_row eq 32>
							<cfif isdefined('t_gelr1_#i#_#ii#') and isdefined('t_gelr5_#i#_#ii#') and isdefined('t_lista_#i#_#ii#') and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('t_gelr5_#i#_#ii#') neq 0 and evaluate('t_lista_#i#_#ii#') neq 0>
                                <cfif (evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#'))*100 gte t_islem><font color="green">#Tlformat((evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#'))*100,2)#%</font><cfelse><font color="red">#Tlformat((evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_lista_#i#_#ii#'))*100,2)#%</font></cfif>     
                            <cfelse>
                                0,00&nbsp;
                            </cfif>
                       	<cfelseif t_row eq 33>
							<cfif isdefined('t_gelr1_#i#_#ii#') and isdefined('t_gelr5_#i#_#ii#') and isdefined('t_list5_#i#_#ii#') and evaluate('t_gelr1_#i#_#ii#') neq 0 and evaluate('t_gelr5_#i#_#ii#') neq 0 and evaluate('t_list5_#i#_#ii#') neq 0>
                                <cfif (evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_list5_#i#_#ii#'))*100 gte t_islem><font color="green">#Tlformat((evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_list5_#i#_#ii#'))*100,2)#%</font><cfelse><font color="red">#Tlformat((evaluate('t_gelr5_#i#_#ii#')/evaluate('t_gelr1_#i#_#ii#'))*(evaluate('t_gelr1_#i#_#ii#')/evaluate('t_list5_#i#_#ii#'))*100,2)#%</font></cfif>     
                            <cfelse>
                                0,00&nbsp;
                            </cfif>                                                                                                                          
                    	</cfif>
                   	</td>
               	</cfloop>
                <td style="width:5px">&nbsp;</td>
           	</cfloop>
      	</cfcase>
 	</cfswitch>
</cfoutput>
</tr>