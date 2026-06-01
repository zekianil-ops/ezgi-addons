<!---
    File: del_ezgi_p_order_group.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_process" datasource="#dsn3#">
   	SELECT P_ORDER_ID, P_ORDER_NO, PROD_ORDER_STAGE FROM PRODUCTION_ORDERS WHERE P_ORDER_ID IN(#attributes.p_order_id_list#) AND IS_STAGE NOT IN (1,2)
</cfquery>
<cfset attributes.p_order_id_list = Valuelist(get_process.P_ORDER_ID)>
<cfif len(attributes.p_order_id_list)>
	<cfloop list="#attributes.p_order_id_list#" index="attributes.p_order_id">
		<cfscript>
            related_production_list=attributes.p_order_id;
            function WriteRelatedProduction(P_ORDER_ID)
                {
                    var i = 1;
                    QueryText = '
                            SELECT 
                                P_ORDER_ID
                            FROM 
                                PRODUCTION_ORDERS
                            WHERE 
                                PO_RELATED_ID = #P_ORDER_ID#';
                    'GET_RELATED_PRODUCTION#P_ORDER_ID#' = cfquery(SQLString : QueryText, Datasource : dsn3);
                    if(Evaluate('GET_RELATED_PRODUCTION#P_ORDER_ID#').recordcount) 
                    {
                        for(i=1;i lte Evaluate("GET_RELATED_PRODUCTION#P_ORDER_ID#").recordcount;i=i+1)
                        {
                            related_production_list = ListAppend(related_production_list,Evaluate("GET_RELATED_PRODUCTION#P_ORDER_ID#").P_ORDER_ID[i],',');
                            WriteRelatedProduction(Evaluate("GET_RELATED_PRODUCTION#P_ORDER_ID#").P_ORDER_ID[i]);
                        }
                    }
                }
            WriteRelatedProduction(attributes.p_order_id);
        </cfscript>
        <cfset attributes.p_order_id = related_production_list>
        <cfquery name="GET_RELATED_PRODUCTION_RESULT" datasource="#dsn3#">
            SELECT P_ORDER_ID FROM PRODUCTION_ORDER_RESULTS WHERE P_ORDER_ID IN (#attributes.p_order_id#)
        </cfquery>
        <cfif GET_RELATED_PRODUCTION_RESULT.recordcount>
            <script type="text/javascript">
                alert("<cf_get_lang dictionary_id ='1078.Bu Üretim Emrinin İlişkili Olduğu Üretimlerden Sonuç Girilenler Var,Öncelikle İlişkili Üretim Emirlerinin Sonuçlarını Siliniz'>!");
                history.go(-1);
            </script>
            <cfabort>
        </cfif>
        
        <cflock name="#CreateUUID()#" timeout="60">
            <cftransaction>
                <cfquery name="DEL_ROW" datasource="#dsn3#">
                    DELETE FROM PRODUCTION_ORDERS_ROW WHERE PRODUCTION_ORDER_ID IN(#attributes.p_order_id#)
                </cfquery>        
                <cfquery name="DEL_PROD_ORDER" datasource="#dsn3#">
                    DELETE FROM PRODUCTION_OPERATION WHERE P_ORDER_ID IN(#attributes.p_order_id#)
                </cfquery>
                <cfquery name="DEL_PROD_ORDER" datasource="#dsn3#">
                    DELETE FROM PRODUCTION_ORDERS WHERE P_ORDER_ID IN(#attributes.p_order_id#)
                </cfquery>
                <cfquery name="DEL_PROD_ORDER_STOCKS" datasource="#dsn3#">
                    DELETE FROM PRODUCTION_ORDERS_STOCKS WHERE P_ORDER_ID IN(#attributes.p_order_id#)
                </cfquery>
            </cftransaction>
        </cflock>
    </cfloop>
</cfif>
<cflocation url="#request.self#?fuseaction=prod.upd_ezgi_master_sub_plan_manual&master_plan_id=#attributes.master_plan_id#&master_alt_plan_id=#attributes.master_alt_plan_id#&islem_id=#attributes.islem_id#" addtoken="No">