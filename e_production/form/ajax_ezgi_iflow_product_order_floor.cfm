<!---
    File: ajax_ezgi_iflow_product_order_floor.cfm
    Folder: Add_Ons\ezgi\e-production\form
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_floor" datasource="#dsn3#">
	SELECT DISTINCT 
        EWOF.TIP, 
        EWOF.KONUM, 
        EWOF.DAIRE, 
        EWOF.MEKAN, 
        EWOF.EZGI_VIRTUAL_OFFER_ROW_FLOOR_ID, 
        EWOF.EZGI_ID,
        EWO.VIRTUAL_OFFER_NUMBER, 
        EWO.FINISHDATE,
        EPO.FLOOR_IDS,
        EPO.IFLOW_P_ORDER_ID,
        EPO.LOT_NO,
        (
        	SELECT TOP (1)       
            	EPP.P_ORDER_ID
			FROM  
            	EZGI_VIRTUAL_OFFER_ROW_FLOOR_ROW AS EPP INNER JOIN
            	PRODUCTION_ORDERS AS PO ON EPP.P_ORDER_ID = PO.P_ORDER_ID
			WHERE        
            	EPP.EZGI_VIRTUAL_OFFER_ROW_FLOOR_ID = EWOF.EZGI_VIRTUAL_OFFER_ROW_FLOOR_ID
        ) AS P_ORDER_ID
	FROM     
    	EZGI_IFLOW_PRODUCTION_ORDERS AS EPO INNER JOIN
      	ORDER_ROW AS ORR ON EPO.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
       	EZGI_VIRTUAL_OFFER_ROW AS EWOR ON ORR.WRK_ROW_RELATION_ID = EWOR.WRK_ROW_RELATION_ID INNER JOIN
      	EZGI_VIRTUAL_OFFER_ROW_FLOOR AS EWOF ON EWOR.EZGI_ID = EWOF.EZGI_ID INNER JOIN
      	EZGI_VIRTUAL_OFFER AS EWO ON EWOR.VIRTUAL_OFFER_ID = EWO.VIRTUAL_OFFER_ID
	WHERE        
    	EPO.IFLOW_P_ORDER_ID = #attributes.IFLOW_P_ORDER_ID#
</cfquery>
<cfset other_floor_id_list =''>
<cfif get_floor.recordcount>
    <cfquery name="get_other_floor" datasource="#dsn3#">
        SELECT     
            EPO.FLOOR_IDS
        FROM        
            EZGI_IFLOW_PRODUCTION_ORDERS AS EPO INNER JOIN
            ORDER_ROW AS ORR ON EPO.ORDER_ROW_ID = ORR.ORDER_ROW_ID INNER JOIN
            EZGI_VIRTUAL_OFFER_ROW AS EWOR ON ORR.WRK_ROW_RELATION_ID = EWOR.WRK_ROW_RELATION_ID
        WHERE     
            EWOR.EZGI_ID = #get_floor.EZGI_ID# AND 
            NOT (EPO.FLOOR_IDS IS NULL) AND 
            EPO.IFLOW_P_ORDER_ID <> #get_floor.IFLOW_P_ORDER_ID#
    </cfquery>
    <cfset other_floor_id_list = ValueList(get_other_floor.FLOOR_IDS)>
</cfif>
<!---<cfdump var="#get_floor#">--->
<cfset floor_id_list = get_floor.FLOOR_IDS>
<div class="col col-12 col-xs-12">
  	<cf_box>
    	 <cf_grid_list sort="0">
          	<thead>
             	<tr>
                 	<th width="30px" style="text-align:center"><cf_get_lang dictionary_id="58577.Sıra"></th>
                	<th><cf_get_lang dictionary_id="58212.Teklif No"></th>
                    <th><cf_get_lang dictionary_id="57630.Tip"></th>
                    <th><cf_get_lang dictionary_id="42307.Konum"></th>
                    <th><cf_get_lang dictionary_id="1055.Daire"></th>
                    <th><cf_get_lang dictionary_id="60371.Mekan"></th>
                    <th class="header_icn_none" style="text-align:center; width:20px">
                        <input type="checkbox" alt="<cf_get_lang dictionary_id='206.Hepsini Seç'>" onClick="grupla(-1);">
                    </th>
				</tr>
          	</thead>
        	<tbody name="new_row_ajax" id="new_row_ajax">
            	<cfif get_floor.recordcount>
                	<cfoutput query="get_floor">
                    	<tr height="20" id="frm_row#currentrow#">
                       		<td style="text-align:right">#currentrow#</td>
                            <td style="text-align:center">#VIRTUAL_OFFER_NUMBER#</td>
                            <td style="text-align:center">#TIP#</td>
                            <td style="text-align:center">#KONUM#</td>
                            <td style="text-align:center">#DAIRE#</td>
                            <td style="text-align:center">#MEKAN#</td>
                            <td style="text-align:center; <cfif Len(P_ORDER_ID)>background-color:turquoise</cfif>">
                            	<cfif ListFind(floor_id_list,EZGI_VIRTUAL_OFFER_ROW_FLOOR_ID)>
                                	<img src="images/c_ok.gif" />
                               	<cfelseif ListFind(other_floor_id_list,EZGI_VIRTUAL_OFFER_ROW_FLOOR_ID)>
                                	<img src="images/b_ok.gif" />
                                <cfelse>
                                	<input type="checkbox" name="select_production" value="#EZGI_VIRTUAL_OFFER_ROW_FLOOR_ID#">
                                </cfif>
                            </td>
                       	</tr>
                    </cfoutput>
                </cfif>
            </tbody>
      	</cf_grid_list>
    </cf_box>
    <cf_box>
        <cf_box_footer>
        <br />
            <div class="col col-1 col-xs-12">
                <button type="button" name="buton_" value="1" onClick="grupla();" style="width:100px; height:30px; background-color:mediumturquoise;color:white; border-color:gray">Tanımla</button>
            </div>
        </cf_box_footer>
    </cf_box>
</div>
<script type="text/javascript">
	function grupla(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
		floor_id_list = '';
		chck_leng = document.getElementsByName('select_production').length;
		for(ci=0;ci<chck_leng;ci++)
		{
			var my_objets = document.all.select_production[ci];
			if(chck_leng == 1)
				var my_objets =document.all.select_production;
			if(type == -1)
			{//hepsini seç denilmişse	
				if(my_objets.checked == true)
					my_objets.checked = false;
				else
					my_objets.checked = true;
			}
			else
			{
				if(my_objets.checked == true)
					floor_id_list +=my_objets.value+',';
			}
		}
		floor_id_list = floor_id_list.substr(0,floor_id_list.length-1);//sondaki virgülden kurtarıyoruz.
		if(floor_id_list!='')
		{
			sor = confirm('<cf_get_lang dictionary_id="57535.Kaydetmek İstediğinizden Emin Misiniz?">')	
			if(sor == true)
			{
				window.location ="<cfoutput>#request.self#?fuseaction=prod.popup_upd_ezgi_iflow_production_order&iflow_p_order_id=#attributes.IFLOW_P_ORDER_ID#&master_plan_id=#attributes.master_plan_id#&rel_p_order_id=#attributes.rel_p_order_id#</cfoutput>&floor_id_list="+floor_id_list;
				return true;
			}
			else
				return false;
		}
	}

</script>