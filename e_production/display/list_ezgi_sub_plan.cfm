<!---
    File: list_ezgi_sub_plan.cfm
    Folder: Add_Ons\ezgi\e-production\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_default" datasource="#dsn3#">
	SELECT       
    	EMAD.POINT_METHOD,
        EMAD.FABRIC_CAT,
        EMAD.CONTROL_METHOD
	FROM            
    	EZGI_MASTER_PLAN_DEFAULTS AS EMAD WITH (NOLOCK) INNER JOIN
     	EZGI_MASTER_PLAN AS EMAP WITH (NOLOCK) ON EMAD.SHIFT_ID = EMAP.MASTER_PLAN_CAT_ID
	WHERE        
    	EMAP.MASTER_PLAN_ID = #attributes.upd#
</cfquery>
<cfquery name="GET_MASTER_ALT_PLAN" datasource="#DSN3#">
	<cfif get_default.POINT_METHOD eq 1>		
        WITH PlanData AS 
    	(
            SELECT 
                EMPR.MASTER_ALT_PLAN_ID, 
                SUM(PO.QUANTITY) AS TOTAL_POINT,
                SUM(CASE WHEN PO.IS_STAGE = 2 THEN PO.QUANTITY ELSE 0 END) AS G_POINT,
                COUNT(*) AS EMIR_ADET
            FROM 
                EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) INNER JOIN 
                PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPR.P_ORDER_ID = PO.P_ORDER_ID
            GROUP BY 
                EMPR.MASTER_ALT_PLAN_ID
        )
        SELECT
            MAP.MASTER_ALT_PLAN_ID,
            MAP.MASTER_ALT_PLAN_NO,
            MAP.PROCESS_ID,
            (SELECT 
            	STAGE 
             FROM 
             	#dsn_alias#.PROCESS_TYPE_ROWS AS PTR WITH (NOLOCK)
             WHERE 
             	PROCESS_ROW_ID = MAP.MASTER_ALT_PLAN_STAGE
         	) AS MASTER_ALT_PLAN_NAME,
            MAP.MASTER_ALT_PLAN_STAGE,
            MAP.RECORD_EMP,
            MAP.RECORD_DATE,
            MAP.PLAN_START_DATE,
            MAP.PLAN_FINISH_DATE,
            ISNULL(MAP.PLAN_POINT, 0) AS W_POINT,
            LTRIM(MAP.PLAN_DETAIL) AS PLAN_DETAIL,
            ISNULL(PD.TOTAL_POINT, 0) AS TOTAL_POINT,
            ISNULL(PD.G_POINT, 0) AS G_POINT,
            ISNULL(PD.EMIR_ADET, 0) AS EMIR_ADET
        FROM 
            EZGI_MASTER_ALT_PLAN AS MAP WITH (NOLOCK) LEFT JOIN 
            PlanData AS PD ON MAP.MASTER_ALT_PLAN_ID = PD.MASTER_ALT_PLAN_ID
        WHERE 
            MAP.MASTER_PLAN_ID = #attributes.upd# 
            AND MAP.PROCESS_ID = #islem_id#
        ORDER BY 
            MAP.PLAN_FINISH_DATE DESC
	<cfelseif get_default.POINT_METHOD eq 2>
    	WITH WeightedPoints AS 
        (
            SELECT 
                EMPR.MASTER_ALT_PLAN_ID,
                SUM(PO.QUANTITY * ISNULL(CAST(PTIP.PROPERTY2 AS float), 0)) AS TOTAL_POINT,
                SUM(CASE WHEN PO.IS_STAGE = 2 THEN PO.QUANTITY * ISNULL(CAST(PTIP.PROPERTY2 AS float), 0) ELSE 0 END) AS G_POINT,
                COUNT(*) AS EMIR_ADET
            FROM 
                EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) INNER JOIN 
                PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPR.P_ORDER_ID = PO.P_ORDER_ID LEFT JOIN 
                PRODUCT_TREE_INFO_PLUS AS PTIP WITH (NOLOCK) ON PO.STOCK_ID = PTIP.STOCK_ID
            GROUP BY 
                EMPR.MASTER_ALT_PLAN_ID
        )
        SELECT
            MAP.MASTER_ALT_PLAN_ID, 
            MAP.MASTER_ALT_PLAN_NO, 
            MAP.PROCESS_ID,
            (SELECT STAGE 
             FROM #dsn_alias#.PROCESS_TYPE_ROWS AS PTR WITH (NOLOCK) 
             WHERE PROCESS_ROW_ID = MAP.MASTER_ALT_PLAN_STAGE) AS MASTER_ALT_PLAN_NAME,
            MAP.MASTER_ALT_PLAN_STAGE, 
            MAP.RECORD_EMP, 
            MAP.RECORD_DATE, 
            MAP.PLAN_START_DATE,
            MAP.PLAN_FINISH_DATE,
            ISNULL(MAP.PLAN_POINT, 0) AS W_POINT, 
            LTRIM(MAP.PLAN_DETAIL) AS PLAN_DETAIL,
            ISNULL(WP.TOTAL_POINT, 0) AS TOTAL_POINT,
            ISNULL(WP.G_POINT, 0) AS G_POINT,
            ISNULL(WP.EMIR_ADET, 0) AS EMIR_ADET
        FROM 
            EZGI_MASTER_ALT_PLAN AS MAP WITH (NOLOCK) LEFT JOIN 
            WeightedPoints AS WP ON MAP.MASTER_ALT_PLAN_ID = WP.MASTER_ALT_PLAN_ID
        WHERE 
            MAP.MASTER_PLAN_ID = #attributes.upd# 
            AND MAP.PROCESS_ID = #islem_id#
        ORDER BY 
            MAP.PLAN_FINISH_DATE DESC
    
    
    
    </cfif>
<!---
	SELECT
		MASTER_ALT_PLAN_ID, 
        MASTER_ALT_PLAN_NO, 
        PROCESS_ID,
        (
        SELECT     
        	STAGE
		FROM         
        	#dsn_alias#.PROCESS_TYPE_ROWS AS PTR WITH (NOLOCK)
		WHERE     
        	PROCESS_ROW_ID = MASTER_ALT_PLAN_STAGE
        ) as MASTER_ALT_PLAN_NAME,
        MASTER_ALT_PLAN_STAGE, 
        RECORD_EMP, 
        RECORD_DATE, 
        PLAN_START_DATE,
        PLAN_FINISH_DATE,
        ISNULL(PLAN_POINT,0) AS W_POINT, 
      	LTRIM(PLAN_DETAIL) AS PLAN_DETAIL,
        <cfif get_default.POINT_METHOD eq 1>
            ISNULL(
                (
                    SELECT     
                        SUM(PO.QUANTITY) AS P_POINT
                    FROM         
                        EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) INNER JOIN
                        PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPR.P_ORDER_ID = PO.P_ORDER_ID
                    WHERE     
                        EMPR.MASTER_ALT_PLAN_ID = EZGI_MASTER_ALT_PLAN.MASTER_ALT_PLAN_ID
          	),0) AS TOTAL_POINT,
            ISNULL(
                (
                    SELECT     
                        SUM(PO.QUANTITY) AS P_POINT
                    FROM         
                        EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) INNER JOIN
                        PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPR.P_ORDER_ID = PO.P_ORDER_ID
                    WHERE     
                        EMPR.MASTER_ALT_PLAN_ID = EZGI_MASTER_ALT_PLAN.MASTER_ALT_PLAN_ID AND PO.IS_STAGE = 2
         	),0) AS G_POINT,
    	<cfelseif get_default.POINT_METHOD eq 2>
        	ISNULL(
                	(	
                    SELECT     
                		SUM(PO.QUANTITY * ISNULL(CAST(PTIP.PROPERTY2 AS float),0)) AS P_POINT
                    FROM         
                        EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) INNER JOIN
                        PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPR.P_ORDER_ID = PO.P_ORDER_ID LEFT OUTER JOIN
                        PRODUCT_TREE_INFO_PLUS AS PTIP WITH (NOLOCK) ON PO.STOCK_ID = PTIP.STOCK_ID
                    WHERE     
                        EMPR.MASTER_ALT_PLAN_ID =  EZGI_MASTER_ALT_PLAN.MASTER_ALT_PLAN_ID
        	),0) AS TOTAL_POINT,
        	ISNULL(
                	(	
                    SELECT     
                		SUM(PO.QUANTITY * ISNULL(CAST(PTIP.PROPERTY2 AS float),0)) AS P_POINT
                    FROM         
                        EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) INNER JOIN
                        PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPR.P_ORDER_ID = PO.P_ORDER_ID LEFT OUTER JOIN
                        PRODUCT_TREE_INFO_PLUS AS PTIP WITH (NOLOCK) ON PO.STOCK_ID = PTIP.STOCK_ID
                    WHERE     
                        EMPR.MASTER_ALT_PLAN_ID =  EZGI_MASTER_ALT_PLAN.MASTER_ALT_PLAN_ID AND PO.IS_STAGE = 2
         	),0) AS G_POINT,
      	</cfif>
      	ISNULL(
            (
            	SELECT     
                	COUNT(*) AS EMIR_ADET
				FROM         
                	EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) INNER JOIN
                    PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPR.P_ORDER_ID = PO.P_ORDER_ID
				WHERE     
                	EMPR.MASTER_ALT_PLAN_ID = EZGI_MASTER_ALT_PLAN.MASTER_ALT_PLAN_ID
				GROUP BY 
                	EMPR.MASTER_ALT_PLAN_ID
            ),0) AS EMIR_ADET    
	FROM
		EZGI_MASTER_ALT_PLAN WITH (NOLOCK)
	WHERE
		MASTER_PLAN_ID = #attributes.upd# AND 
        PROCESS_ID = #islem_id#
	ORDER BY
		PLAN_FINISH_DATE DESC--->
</cfquery>
<cfquery name="get_w" datasource="#dsn3#">
	SELECT     
    	SIRA
	FROM         
    	EZGI_MASTER_PLAN_SABLON WITH (NOLOCK)
	WHERE     
    	PROCESS_ID = #islem_id#
</cfquery>
<cf_grid_list> 
<thead>
  	<tr height="22">
      	<th width="60"><cf_get_lang dictionary_id='1019.Alt Plan No'> </th>
        <th width="100" nowrap><cf_get_lang dictionary_id='57879.İşlem Tarihi'></th>
        <th ><cf_get_lang dictionary_id='36765.İşlemi Yapan'></th>
        <th width="60"><cf_get_lang dictionary_id='57951.Hedef'></th>
        <th width="60"><cf_get_lang dictionary_id='58869.Planlanan'></th>
        <th width="60"><cf_get_lang dictionary_id='39725.Gerçekleşen'></th>
        <th width="100"><cf_get_lang dictionary_id='45356.Hedef Başlama'></th>
        <th width="100"><cf_get_lang dictionary_id='36606.Hedef Bitiş'></th>
        <th><cf_get_lang dictionary_id='57629.Açıklama'></th>
        <th width="20" align="center">
        	<a href="javascript://" onClick="secim(-4);"><img src="../images/print.gif" border="0"></a>
        </th>
        <th width="20" align="center">
        	<a href="javascript://" onClick=<cfoutput>"windowopen('#request.self#?fuseaction=prod.popup_add_ezgi_master_sub_plan_manual&master_plan_id=#attributes.upd#&islem_id=#islem_id#','list');"</cfoutput>><img src="/images/plus_list.gif" align="absmiddle" border="0"  alt="<cf_get_lang dictionary_id='546.Alt Plan Ekleme'>">
            </a>
       	</th>
  	</tr>
</thead>
<tbody>
	<cfoutput query="GET_MASTER_ALT_PLAN">
      	<tr height="20">
            <td>
                <a href="#request.self#?fuseaction=prod.upd_ezgi_master_sub_plan_manual&master_plan_id=#attributes.upd#&master_alt_plan_id=#master_alt_plan_id#&islem_id=#islem_id#" class="tableyazi" title="<cf_get_lang dictionary_id='604.Alt Plana Git'>">#MASTER_ALT_PLAN_NO#
                </a>
            </td>
            <td style="text-align:center">#dateformat(RECORD_DATE,dateformat_style)# #timeformat(RECORD_DATE,'HH:mm')#</td>
            <td>&nbsp;#get_emp_info(RECORD_EMP,0,1)#</td>
            <td style="text-align:right">#TlFormat(W_POINT,2)#&nbsp;</td>
            <td style="text-align:right;<cfif total_point neq 0>color:white</cfif>" bgcolor="<cfif total_point neq 0><cfif total_point gte w_point>red<cfelseif total_point gte w_point/2>orange<cfelse>green</cfif></cfif>">#Tlformat(TOTAL_POINT,2)#&nbsp;</td>
            <td style="text-align:right;<cfif g_point neq 0>color:white</cfif>" bgcolor="<cfif g_point neq 0><cfif g_point gte total_point>red<cfelseif g_point gte total_point/2>orange<cfelse>green</cfif></cfif>">#TlFormat(G_POINT,2)#&nbsp;</td>
            <td style="text-align:center">#dateformat(PLAN_START_DATE,dateformat_style)# #timeformat(PLAN_START_DATE,'HH:mm')#</td>
            <td style="text-align:center">#dateformat(PLAN_FINISH_DATE,dateformat_style)# #timeformat(PLAN_FINISH_DATE,'HH:mm')#</td>
            <td>&nbsp;#PLAN_DETAIL#&nbsp;</td>
            <td width="20" align="center">
                <cfif EMIR_ADET lte 0>
                    <a href="#request.self#?fuseaction=prod.del_ezgi_master_sub_plan&master_plan_id=#attributes.upd#&master_alt_plan_id=#master_alt_plan_id#&islem_id=#islem_id#">
                        <img src="/images/delete_list.gif" align="absmiddle" border="0"/>
                    </a>
                <cfelse>
                    <input type="checkbox" name="select_sub_plan" value="#MASTER_ALT_PLAN_ID#">
                </cfif>
            </td>
            <td width="20">
            	<a href="#request.self#?fuseaction=prod.upd_ezgi_master_sub_plan_manual&master_plan_id=#attributes.upd#&master_alt_plan_id=#master_alt_plan_id#&islem_id=#islem_id#"><i class="fa fa-pencil" title="<cf_get_lang dictionary_id='57464.Güncelle'>" alt="<cf_get_lang dictionary_id='57464.Güncelle'>"></i></a>
          	</td>
      	</tr>
  	</cfoutput>
    <tr class="color-row">
    	<td colspan="8" align="right"></td>
    	<td align="right" nowrap="nowrap">&nbsp;&nbsp;
        	<button  value="" name="malzeme" onClick="secim(-2);" style="height:20px;font-size:9px">&nbsp;<cf_get_lang dictionary_id='443.Malzeme İhtiyacı'></button>
		</td>
        <td align="right">
        	<input type="checkbox" alt="<cf_get_lang dictionary_id ='206.Hepsini Seç'>" onClick="secim(-1);">
        </td>
        <td align="right">
        </td>
	</tr>
</tbody>
</cf_grid_list> 
<script language="javascript">
	function secim(type)
	{//type sadece -1 olarak gelir,-1 geliyorsa hepsini seç demektir.
		sub_plan_id_list = '';
		chck_leng = document.getElementsByName('select_sub_plan').length;
		for(ci=0;ci<chck_leng;ci++)
		{
			var my_objets = document.all.select_sub_plan[ci];
			if(chck_leng == 1)
				var my_objets =document.all.select_sub_plan;
			if(type == -1){//hepsini seç denilmişse	
				if(my_objets.checked == true)
					my_objets.checked = false;
				else
					my_objets.checked = true;
			}
			else
			{
				if(my_objets.checked == true)
					sub_plan_id_list +=my_objets.value+',';
			}
		}
		sub_plan_id_list = sub_plan_id_list.substr(0,sub_plan_id_list.length-1);//sondaki virgülden kurtarıyoruz.
		if(list_len(sub_plan_id_list,','))
		{
			<cfoutput>
				var master_alt_plan_id=#GET_MASTER_ALT_PLAN.MASTER_ALT_PLAN_ID#;
				var master_plan_id=#attributes.upd#;
				var islem_id=#GET_MASTER_ALT_PLAN.PROCESS_ID#;
			</cfoutput>
			if(type == -2)
			{
				windowopen('<cfoutput>#request.self#</cfoutput>?fuseaction=prod.popup_dsp_ezgi_iflow_product_metarial_need&master_up_plan_id_list='+sub_plan_id_list,'longpage')
			}
			else if(type == -4)
			{
				window.open('<cfoutput>#request.self#</cfoutput>?fuseaction=objects.popup_print_files&print_type=289&action_id='+sub_plan_id_list);	
			}
		}
	}
</script>