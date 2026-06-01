<!---
    File: get_ezgi_sub_plan_metarial.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfdump expand="yes" var="#attributes#">
<cfif attributes.type eq 1>
    <cfquery name="get_p_order_no" datasource="#dsn3#"> <!---E-Furniture İlişkili Alt Emirler--->
    	SELECT     
        	PO.P_ORDER_NO
		FROM         
        	EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) INNER JOIN
            EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) ON EMAP.MASTER_ALT_PLAN_ID = EMPR.MASTER_ALT_PLAN_ID INNER JOIN
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPR.P_ORDER_ID = PO.P_ORDER_ID
		WHERE     
        	EMAP.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id# AND 
            PO.LOT_NO IN 
            			(
            			SELECT     
                        	LOT_NO
						FROM         
                        	PRODUCTION_ORDERS AS PO1 WITH (NOLOCK)
						WHERE     
                        	P_ORDER_ID IN (#attributes.p_order_id_list#)
                       	)
    </cfquery>
<cfelseif attributes.type eq 2>  <!---E-Furniture İlişkili Alt Planlar--->
 	<cfquery name="get_p_order_no" datasource="#dsn3#">
    	SELECT     
        	PO.P_ORDER_NO
		FROM         
        	EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) INNER JOIN
            EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) ON EMAP.MASTER_ALT_PLAN_ID = EMPR.MASTER_ALT_PLAN_ID INNER JOIN
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPR.P_ORDER_ID = PO.P_ORDER_ID
		WHERE 
        	PO.LOT_NO IN 
            			(
            			SELECT     
                        	LOT_NO
						FROM         
                        	PRODUCTION_ORDERS AS PO1 WITH (NOLOCK)
						WHERE     
                        	P_ORDER_ID IN (#attributes.p_order_id_list#)
                       	) AND    
        	EMAP.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id# OR
            PO.LOT_NO IN 
            			(
            			SELECT     
                        	LOT_NO
						FROM         
                        	PRODUCTION_ORDERS AS PO1 WITH (NOLOCK)
						WHERE     
                        	P_ORDER_ID IN (#attributes.p_order_id_list#)
                       	) AND
            EMAP.RELATED_MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
    </cfquery>
<cfelseif attributes.type eq 3>  
 	<cfquery name="get_p_order_no" datasource="#dsn3#">
    	SELECT     
        	P_ORDER_NO
		FROM         
        	PRODUCTION_ORDERS WITH (NOLOCK)
		WHERE     
        	LOT_NO IN
                  	(
                    SELECT     
                    	LOT_NO
                  	FROM          
                    	PRODUCTION_ORDERS AS PRODUCTION_ORDERS_1 WITH (NOLOCK)
                 	WHERE      
                    	P_ORDER_ID IN (#attributes.p_order_id_list#)
                  	)
    </cfquery> 
<cfelseif attributes.type eq 5>  
 	<cfquery name="get_p_order_no" datasource="#dsn3#"> 
    	SELECT     
        	PO.P_ORDER_NO
		FROM         
        	EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) INNER JOIN
         	EZGI_MASTER_PLAN_RELATIONS AS EMPS WITH (NOLOCK) ON EMAP.MASTER_ALT_PLAN_ID = EMPS.MASTER_ALT_PLAN_ID INNER JOIN
        	PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPS.P_ORDER_ID = PO.P_ORDER_ID
		WHERE     
        	EMAP.MASTER_ALT_PLAN_ID IN (#attributes.sub_plan_id_list#) OR EMAP.RELATED_MASTER_ALT_PLAN_ID IN (#attributes.sub_plan_id_list#)
    </cfquery>
<cfelseif attributes.type eq 6>  
 	<cfquery name="get_p_order_no" datasource="#dsn3#"> 
    	SELECT     
        	PO.P_ORDER_NO
		FROM         
        	EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) INNER JOIN
         	EZGI_MASTER_PLAN_RELATIONS AS EMPS WITH (NOLOCK) ON EMAP.MASTER_ALT_PLAN_ID = EMPS.MASTER_ALT_PLAN_ID INNER JOIN
        	PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPS.P_ORDER_ID = PO.P_ORDER_ID
		WHERE     
        	EMAP.MASTER_ALT_PLAN_ID IN (#attributes.sub_plan_id_list#)
    
    </cfquery>
<cfelse>
    <cfquery name="get_p_order_no" datasource="#dsn3#"> <!---E-Furniture İstasyom Emirleri--->
    	SELECT     
        	PO.P_ORDER_NO
		FROM         
        	EZGI_MASTER_ALT_PLAN AS EMAP WITH (NOLOCK) INNER JOIN
            EZGI_MASTER_PLAN_RELATIONS AS EMPR WITH (NOLOCK) ON EMAP.MASTER_ALT_PLAN_ID = EMPR.MASTER_ALT_PLAN_ID INNER JOIN
            PRODUCTION_ORDERS AS PO WITH (NOLOCK) ON EMPR.P_ORDER_ID = PO.P_ORDER_ID
		WHERE     
        	EMAP.MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id# OR
            EMAP.RELATED_MASTER_ALT_PLAN_ID = #attributes.master_alt_plan_id#
    </cfquery>
</cfif>
<cfset p_order_no_list = Valuelist(get_p_order_no.P_ORDER_NO)>
<cfif type neq 3>
	<cflocation url="#request.self#?fuseaction=prod.list_materials_total&production_order_no=#p_order_no_list#&master_plan_id=#master_plan_id#&master_alt_plan_id=#master_alt_plan_id#&islem_id=#islem_id#" addtoken="No">
<cfelse>
	<cflocation url="#request.self#?fuseaction=prod.list_materials_total&production_order_no=#p_order_no_list#" addtoken="No">
</cfif>