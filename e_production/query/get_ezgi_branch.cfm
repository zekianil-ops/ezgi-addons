<cfquery name="GET_BRANCH" datasource="#DSN#">
	SELECT
		*
	FROM
		BRANCH
	WHERE 
		IS_PRODUCTION=1
		AND COMPANY_ID = #session.ep.company_id#
		AND BRANCH_ID IN(SELECT BRANCH_ID FROM EMPLOYEE_POSITION_BRANCHES WHERE POSITION_CODE = #session.ep.position_code#)
	ORDER BY 
		BRANCH_NAME
</cfquery>
