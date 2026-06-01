<!---
    File: dsp_employee_ezgi_identification.cfm
    Folder: Add_Ons\ezgi\e-vts\display
    Author: Ezgi Yazılım
    Date: 01/01/2007
    Description:
--->

<cfparam name="attributes.deliver_code" default="">
<cfparam name="attributes.station_id" default="">

<cfquery name="get_deliver_name" datasource="#dsn3#">
    SELECT     	
    	E.EMPLOYEE_NAME + ' ' + E.EMPLOYEE_SURNAME AS DELIVER_NAME,
     	E.EMPLOYEE_ID
    FROM       	
    	EZGI_VTS_IDENTY AS EV INNER JOIN
     	#dsn_alias#.EMPLOYEES AS E ON EV.EMP_ID = E.EMPLOYEE_ID
	WHERE        
    	EV.PAROLA = '#attributes.deliver_code#'
</cfquery>
<cfif not get_deliver_name.recordcount>
	<script type="text/javascript">
		alert('<cf_get_lang dictionary_id='296.Kartınız Yetkili Değil'> - <cf_get_lang dictionary_id='297.İnsan Kaynaklarına Başvurunuz'>!');
		window.history.go(-1);
	</script>
    <cfabort>
</cfif>
<cfquery name="get_station_temp" datasource="#dsn3#">
   	SELECT TOP (1) 
    	W.STATION_ID,
        W.UP_STATION,
        W.EZGI_PACKAGE_CONTROL
	FROM         
    	PRODUCTION_OPERATION_RESULT AS P INNER JOIN
        WORKSTATIONS AS W ON W.STATION_ID = P.STATION_ID 
	WHERE     
    	P.ACTION_EMPLOYEE_ID = #GET_DELIVER_NAME.EMPLOYEE_ID#
	ORDER BY 
    	P.ACTION_START_DATE DESC		
</cfquery>
<cfif not get_station_temp.recordcount>
	<cfquery name="get_station_temp" datasource="#dsn3#">
		SELECT
        	TOP (1)     	
            UP_STATION,
            STATION_ID ,
			EZGI_PACKAGE_CONTROL
        FROM       	
            WORKSTATIONS
        WHERE     	
            DEPARTMENT = (SELECT DEFAULT_DEPARTMENT_ID FROM #dsn3_alias#.EZGI_VTS_IDENTY WHERE EMP_ID = #get_deliver_name.EMPLOYEE_ID#) AND
            ACTIVE = 1 AND
            UP_STATION IS NOT NULL
        ORDER BY
            STATION_NAME 
   	</cfquery>
</cfif>
<cfquery name="get_workstation" datasource="#dsn3#">
    SELECT     	
    	STATION_ID, 
    	UP_STATION, 
        STATION_NAME,
		EZGI_PACKAGE_CONTROL
    FROM       	
    	WORKSTATIONS
    WHERE     	
    	DEPARTMENT = (SELECT DEFAULT_DEPARTMENT_ID FROM #dsn3_alias#.EZGI_VTS_IDENTY WHERE EMP_ID = #get_deliver_name.EMPLOYEE_ID#) AND
        ACTIVE = 1
  	ORDER BY
    	STATION_NAME              
</cfquery>
<cfquery name="get_up_workstation" dbtype="query">
    SELECT     	
    	STATION_ID, 
    	UP_STATION, 
        STATION_NAME,
		EZGI_PACKAGE_CONTROL
    FROM       	
    	get_workstation
    WHERE     	
    	UP_STATION IS NULL
  	ORDER BY
    	STATION_NAME              
</cfquery>
<cfquery name="get_down_workstation" dbtype="query">
    SELECT     	
    	STATION_ID, 
    	UP_STATION, 
        STATION_NAME,
		EZGI_PACKAGE_CONTROL
    FROM       	
    	get_workstation
  	<cfif isdefined('get_station_temp.UP_STATION') and len(get_station_temp.UP_STATION) and get_up_workstation.recordcount gt 1>
    WHERE     	
    	UP_STATION = #get_station_temp.UP_STATION#
   	<cfelse>
   	WHERE
    	NOT(UP_STATION IS NULL)
    </cfif>
  	ORDER BY
    	STATION_NAME              
</cfquery>
<cfquery name="get_prod_pause" datasource="#dsn3#">
	SELECT     
    	P_ORDER_ID, 
        STATION_ID, 
        EMPLOYEE_ID, 
        OPERATION_ID
	FROM         
    	SETUP_PROD_PAUSE
	WHERE     
    	PROD_DURATION IS NULL AND 
        EMPLOYEE_ID = #GET_DELIVER_NAME.EMPLOYEE_ID#
</cfquery>
<cfif get_prod_pause.recordcount and len(get_prod_pause.P_ORDER_ID)>
	<script type="text/javascript">	
		window.location.href='<cfoutput>#request.self#?fuseaction=production.add_ezgi_production_order&upd=#get_prod_pause.P_ORDER_ID#&station_id=#get_prod_pause.STATION_ID#&employee_id=#get_prod_pause.EMPLOYEE_ID#&p_operation_id=#get_prod_pause.OPERATION_ID#&start_date=#Dateformat(now(),'DD/MM/YYYY')#</cfoutput>';
	</script>
</cfif>
<cfquery name="get_station_employee" datasource="#dsn3#">
	SELECT     
    	TOP (1) E.STATION_ID, 
        E.EMPLOYEE_ID, 
        E.START_DATE, 
        E.FINISH_DATE,
		ISNULL(W.EZGI_PACKAGE_CONTROL,0) AS EZGI_PACKAGE_CONTROL
	FROM         
    	EZGI_STATION_EMPLOYEE E,
		WORKSTATIONS W
	WHERE    
		E.STATION_ID = W.STATION_ID AND
    	E.EMPLOYEE_ID = #GET_DELIVER_NAME.EMPLOYEE_ID#
	ORDER BY 
    	START_DATE desc
</cfquery>
<cfif get_station_employee.recordcount and not len(get_station_employee.FINISH_DATE)>
	<script type="text/javascript">	
		<cfif get_station_employee.EZGI_PACKAGE_CONTROL eq 6>
			window.location.href='<cfoutput>#request.self#?fuseaction=production.list_ezgi_production_operation_sablon&station_id=#get_station_employee.STATION_ID#&employee_id=#get_station_employee.EMPLOYEE_ID#</cfoutput>';
		<cfelse>
			window.location.href='<cfoutput>#request.self#?fuseaction=production.list_ezgi_production_operation&station_id=#get_station_employee.STATION_ID#&employee_id=#get_station_employee.EMPLOYEE_ID#</cfoutput>';
		</cfif>
	</script>
</cfif>
<style>
    .new label,div{font-size:15px!important;}
    .ui-form-list .form-group select{font-size:15px!important;}
</style>
<cf_box>
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12 new">
        <cfform name="form_station" method="post" action="" >
        	<cfinput type="hidden" name="ezgi_package_control" id="ezgi_package_control" value="#get_station_temp.EZGI_PACKAGE_CONTROL#"> 
            <cf_box_elements>
                <cfoutput>
                    <div class="col col-3 col-md-3 col-sm-3 col-xs-3">
                    </div>
                    <div class="col col-6 col-md-6 col-sm-6 col-xs-12">
                        <input type="hidden" name="employee_id" value="#get_deliver_name.employee_id#">
                        <input type="hidden" name="new_employee" value="1" />

                        <div class="form-group">
                            <label class="col col-3 col-xs-12" style="font-size:25px!important;"><cf_get_lang dictionary_id='301.Operatör'></label>
                            <div class="col col-9 col-xs-12" style="font-size:25px!important;font-weight:bold;">#get_deliver_name.deliver_name#</div>
                        </div>
                        <div class="form-group">
                            <label class="col col-3 col-xs-12" style="font-size:25px!important;"><cf_get_lang dictionary_id='57995.Bölüm'></label>
                            <div class="col col-9 col-xs-12 sel">
                                <select name="up_station_id" id="up_station_id" style="width:300px; height:50px!important;font-size:18px!important;" onchange="station_select(this.value);">
                                    <cfloop query="get_up_workstation">
                                        <option value="#station_id#" <cfif station_id eq get_station_temp.up_station>selected</cfif>>#STATION_NAME#</option>
                                    </cfloop>
                                </select>
                            </div>
                        </div>
                        <div class="form-group">
                            <label class="col col-3 col-xs-12" style="font-size:25px!important;"><cf_get_lang dictionary_id='577.Makina'></label>
                            <div class="col col-9 col-xs-12">
                                <select name="station_id" id="station_id" style="width:300px; height:50px!important;font-size:18px!important;" onchange="sub_station_select(this.value);">
                                    <cfloop query="get_down_workstation">
                                        <option value="#station_id#" <cfif station_id eq get_station_temp.station_id>selected</cfif>>#STATION_NAME#</option>
                                    </cfloop>
                                </select>
                            </div>
                        </div>
                    </div>
                </cfoutput>
            </cf_box_elements>
            <cf_box_footer>
                <div class="col col-12 text-right">
                    <input type="button" name="buton" id="buton" style="height: 50px;width: 150px;font-size: 18px;" value="<cf_get_lang dictionary_id='57554.Giriş'>" onclick="kontrol()"/>
                </div>
            </cf_box_footer>
        </cfform>
</cf_box>

<script language="javascript">
	function kontrol()
	{
		if ((document.form_station.station_id.value) == '')
		{
			alert('<cf_get_lang dictionary_id='312.Bir Makina Seçiniz'>');
			return false;
		}
		else
		{
			if(document.getElementById('ezgi_package_control').value ==5)
			{
				document.getElementById("form_station").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=production.add_ezgi_fast_production_order";
				document.getElementById("form_station").submit();
			}
			else if(document.getElementById('ezgi_package_control').value ==6)
			{
				document.getElementById("form_station").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=production.list_ezgi_production_operation_sablon";
				document.getElementById("form_station").submit();
			}
			else
			{
				document.getElementById("form_station").action = "<cfoutput>#request.self#</cfoutput>?fuseaction=production.list_ezgi_production_operation";
				document.getElementById("form_station").submit();
			}
		}
	}
	function station_select(abc)
	{
		/*var station_names = 
		wrk_query("SELECT STATION_ID,UP_STATION,STATION_NAME FROM WORKSTATIONS WHERE UP_STATION = "+abc+" ORDER BY STATION_NAME","dsn3");*/
		
		var listParam =abc;
		var station_names = wrk_safe_query('get_station_names_upstationid_ezgi','dsn3',0,listParam);
			
		var option_count = document.getElementById('station_id').options.length; 
		for(x=option_count;x>=0;x--)
			document.getElementById('station_id').options[x] = null;
		if(station_names.recordcount != 0)
		{	
			document.getElementById('station_id').options[0] = new Option("<cf_get_lang dictionary_id ='57734.Seçiniz'>",'');
			for(var xx=0;xx<station_names.recordcount;xx++)
				document.getElementById('station_id').options[xx+1]=new Option(station_names.STATION_NAME[xx],station_names.STATION_ID[xx],station_names.UP_STATION[xx]);
		}
		else
			document.getElementById('station_id').options[0] = new Option("<cf_get_lang dictionary_id ='57734.Seçiniz'>",'');
	}
	function sub_station_select(station_id)
	{
		/*var sub_station_package_control = 
		wrk_query("SELECT ISNULL(EZGI_PACKAGE_CONTROL,0) AS EZGI_PACKAGE_CONTROL FROM WORKSTATIONS WHERE STATION_ID = "+station_id,"dsn3");*/
		
		var listParam =station_id;
		var sub_station_package_control = wrk_safe_query('get_station_info_stationid_ezgi','dsn3',0,listParam);
		
		if(sub_station_package_control.recordcount != 0 )
		{	
			document.getElementById('ezgi_package_control').value = sub_station_package_control.EZGI_PACKAGE_CONTROL;
		}			
	}
</script>
