<!---
    File: upd_ezgi_master_plan_general_default_defination.cfm
    Folder: Add_Ons\ezgi\e-production\query
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfquery name="get_defaults" datasource="#dsn3#">
	SELECT * FROM EZGI_MASTER_PLAN_DEFAULTS
</cfquery>
<cftransaction>
	<cfif get_defaults.recordcount>
        <cfquery name="upd_master_plan_design_defaults" datasource="#dsn3#">
        	UPDATE       
           		EZGI_MASTER_PLAN_DEFAULTS
			SET                
            	DEFAULT_PRODUCTION_STORE_ID = <cfif len(attributes.PRODUCTION_DEPARTMENT_ID)>#ListGetAt(attributes.PRODUCTION_DEPARTMENT_ID,1,'-')#<cfelse>NULL</cfif>,
                DEFAULT_PRODUCTION_LOC_ID = <cfif len(attributes.PRODUCTION_DEPARTMENT_ID)>#ListGetAt(attributes.PRODUCTION_DEPARTMENT_ID,2,'-')#<cfelse>NULL</cfif>, 
                DEFAULT_RAW_STORE_ID = <cfif len(attributes.RAW_DEPARTMENT_ID)>#ListGetAt(attributes.RAW_DEPARTMENT_ID,1,'-')#<cfelse>NULL</cfif>, 
                DEFAULT_RAW_LOC_ID =<cfif len(attributes.RAW_DEPARTMENT_ID)>#ListGetAt(attributes.RAW_DEPARTMENT_ID,2,'-')#<cfelse>NULL</cfif>,
                DEFAULT_OPTIMIZE_CATAGORY = <cfif len(attributes.CAT)>'#attributes.CAT#'<cfelse>NULL</cfif>
        </cfquery>
  	<cfelse>
    	<cfquery name="add_master_plan_design_defaults" datasource="#dsn3#">
        	INSERT INTO 
           		EZGI_MASTER_PLAN_DEFAULTS
               	(
                	DEFAULT_PRODUCTION_STORE_ID,
                    DEFAULT_PRODUCTION_LOC_ID,
                    DEFAULT_RAW_STORE_ID,
                    DEFAULT_RAW_LOC_ID,
                    DEFAULT_OPTIMIZE_CATAGORY
               	)
          	VALUES
            	(
                	<cfif len(attributes.PRODUCTION_DEPARTMENT_ID)>#ListGetAt(attributes.PRODUCTION_DEPARTMENT_ID,1,'-')#<cfelse>NULL</cfif>,
              		<cfif len(attributes.PRODUCTION_DEPARTMENT_ID)>#ListGetAt(attributes.PRODUCTION_DEPARTMENT_ID,2,'-')#<cfelse>NULL</cfif>, 
              		<cfif len(attributes.RAW_DEPARTMENT_ID)>#ListGetAt(attributes.RAW_DEPARTMENT_ID,1,'-')#<cfelse>NULL</cfif>, 
              		<cfif len(attributes.RAW_DEPARTMENT_ID)>#ListGetAt(attributes.RAW_DEPARTMENT_ID,2,'-')#<cfelse>NULL</cfif>,
                	<cfif len(attributes.CAT)>'#attributes.CAT#'<cfelse>NULL</cfif>
                )	
        </cfquery>
    </cfif>
</cftransaction>
<cflocation url="#request.self#?fuseaction=prod.master_plan_general_default_defination" addtoken="no">