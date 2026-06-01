<cftransaction>
    <cfquery name="del_demand" datasource="#dsn3#">
        DELETE
            EZGI_PRODUCTION_DEMAND
      	WHERE
        	EZGI_DEMAND_ID = #attributes.upd_id#
    </cfquery>
    <cfquery name="del_demand_row" datasource="#dsn3#">
        DELETE FROM EZGI_PRODUCTION_DEMAND_ROW WHERE EZGI_DEMAND_ID = #attributes.upd_id#
    </cfquery>
</cftransaction>
<cflocation url="#request.self#?fuseaction=prod.list_ezgi_e_planning" addtoken="No">
