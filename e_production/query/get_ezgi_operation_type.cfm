<cfquery name="get_operation_type" datasource="#dsn3#">
	SELECT
	O.OPERATION_TYPE_ID
   , #dsn#.Get_Dynamic_Language(OPERATION_TYPE_ID,'#session.ep.language#', 'OPERATION_TYPES', 'OPERATION_TYPE', NULL, NULL, OPERATION_TYPE) AS OPERATION_TYPE
	, O.OPERATION_TYPE
	, O.O_HOUR
	, O.O_MINUTE
	, O.COMMENT
	, O.COMMENT2
	, O.FILE_NAME
	, O.OPERATION_COST
	, O.MONEY
	, O.FILE_SERVER_ID
	, O.OPERATION_CODE
	, O.OPERATION_STATUS
	, O.RECORD_DATE
	, O.RECORD_EMP
	, O.EZGI_H_SURE
	, O.EZGI_FORMUL
	, O.IS_VIRTUAL
		,E.EMPLOYEE_NAME
		,E.EMPLOYEE_SURNAME
	FROM
		OPERATION_TYPES O LEFT OUTER JOIN #dsn_alias#.EMPLOYEES E ON E.EMPLOYEE_ID=O.RECORD_EMP
	WHERE 
		1=1
	<cfif  isdefined("attributes.keyword") and len(attributes.keyword)>
		AND (O.OPERATION_TYPE LIKE '%#attributes.keyword#%' OR O.OPERATION_CODE LIKE '%#attributes.keyword#%')
	<cfelseif isdefined("attributes.operation_type_id") and len(attributes.operation_type_id)>
		AND O.OPERATION_TYPE_ID=#attributes.operation_type_id#
	</cfif>
	<cfif attributes.is_active eq 1>
		AND O.OPERATION_STATUS = 1
	<cfelseif attributes.is_active eq 0>
		AND O.OPERATION_STATUS = 0
	</cfif>
</cfquery>

