<!---
    File: add_ezgi_my_partners.cfm
    Folder: Add_Ons\ezgi\e_wm\form
    Author: Ezgi Yazılım
    Date: 01/01/2025
    Description: Partner Sayfam
--->
<cfquery name="get_partner_control" datasource="#DSN3#">
 	SELECT 
     	EZGI_WM_MY_PARTNER_ID, 
      	START_DATE, 
    	EMPLOYEE_ID, 
 		MY_PARTNER_ID, 
    	(SELECT EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ADI FROM #dsn_alias#.EMPLOYEES WHERE EMPLOYEE_ID = EZGI_WM_MY_PARTNERS.EMPLOYEE_ID) AS ADI
  	FROM     
    	EZGI_WM_MY_PARTNERS
   	WHERE  
     	STATUS = 1 AND
  		MY_PARTNER_ID = #session.ep.userid#
</cfquery>
<cfif get_partner_control.recordcount>
	<script type="text/javascript">
		alert("Siz Şu Anda <cfoutput>#get_partner_control.ADI#</cfoutput> İle Çalışmaktasınız Lütfen Öncelikle Partnerlikten Ayrılın.!");
		window.location ="<cfoutput>#request.self#?fuseaction=myhome.welcome</cfoutput>";
	</script>
	<cfabort>
</cfif>
<cfparam name="attributes.anamenu" default="1">
<cfif isdefined('attributes.type')>
	<cfif attributes.type eq 'add'>
		<cfif len(attributes.new_partner) and isnumeric(attributes.new_partner)>
			<cfquery name="get_new_partner" datasource="#DSN3#">
                SELECT 
                    EZGI_WM_MY_PARTNER_ID, 
                    START_DATE, 
                    EMPLOYEE_ID, 
                    MY_PARTNER_ID, 
                    (SELECT EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ADI FROM #dsn_alias#.EMPLOYEES WHERE EMPLOYEE_ID = EZGI_WM_MY_PARTNERS.EMPLOYEE_ID) AS ADI
                FROM     
                    EZGI_WM_MY_PARTNERS
                WHERE  
                	STATUS = 1 AND
                    MY_PARTNER_ID = #attributes.new_partner# 
            </cfquery>
            <cfif get_new_partner.recordcount>
            	<script type="text/javascript">
					alert("İlgili Personel <cfoutput>#get_new_partner.ADI#</cfoutput> İle Çalışmaktadır.!");
					window.location ="<cfoutput>#request.self#?fuseaction=stock.add_ezgi_my_partners</cfoutput>";
				</script>
                <cfabort>
            </cfif>
            <cfquery name="get_new_partner" datasource="#DSN3#">
                SELECT 
                    EZGI_WM_MY_PARTNER_ID, 
                    START_DATE, 
                    EMPLOYEE_ID, 
                    MY_PARTNER_ID, 
                    (SELECT EMPLOYEE_NAME + ' ' + EMPLOYEE_SURNAME AS ADI FROM #dsn_alias#.EMPLOYEES WHERE EMPLOYEE_ID = EZGI_WM_MY_PARTNERS.MY_PARTNER_ID) AS ADI
                FROM     
                    EZGI_WM_MY_PARTNERS
                WHERE  
                	STATUS = 1 AND
                    EMPLOYEE_ID = #attributes.new_partner# 
            </cfquery>
            <cfif get_new_partner.recordcount>
            	<script type="text/javascript">
					alert("İlgili Personel <cfoutput>#get_new_partner.ADI#</cfoutput> İle Çalışmaktadır.!");
					window.location ="<cfoutput>#request.self#?fuseaction=stock.add_ezgi_my_partners</cfoutput>";
				</script>
                <cfabort>
            </cfif>
            <cfquery name="add_partner" datasource="#dsn3#">
            	INSERT INTO 
                	EZGI_WM_MY_PARTNERS
                  	(
                    	START_DATE, 
                        EMPLOYEE_ID, 
                        MY_PARTNER_ID, 
                        STATUS, 
                        RECORD_EMP, 
                        RECORD_IP, 
                        RECORD_DATE
                  	)
				VALUES 
                	(
                    	#now()#,
                        #session.ep.userid#,
                        #attributes.new_partner#,
                        1,
                        #session.ep.userid#,
                        '#cgi.remote_addr#',
                       	#now()# 
                  	)
            </cfquery>
		</cfif>
    <cfelseif attributes.type eq 'del'>
    	<cfquery name="del_partner" datasource="#DSN3#">
        	UPDATE 
            	EZGI_WM_MY_PARTNERS
			SET          
            	FINISH_DATE = #now()#, 
                STATUS = 0
			WHERE  
            	EZGI_WM_MY_PARTNER_ID = #attributes.ezgi_my_partner_id# 
      	</cfquery>
    	<script type="text/javascript">
			alert("İlgili Personel Partner Gurubunuzdan Çıkartılmıştır.!");
		</script>
    </cfif>
</cfif>
<cfquery name="get_my_partners" datasource="#DSN3#">
	SELECT 
    	EZGI_WM_MY_PARTNER_ID, 
        START_DATE, 
        EMPLOYEE_ID, 
        MY_PARTNER_ID, 
        STATUS, 
        RECORD_EMP, 
        RECORD_IP, 
        RECORD_DATE
	FROM     
    	EZGI_WM_MY_PARTNERS
	WHERE  
    	EMPLOYEE_ID = #session.ep.userid#   
        AND STATUS = 1  
</cfquery>
<cfset partner_list = ValueList(get_my_partners.MY_PARTNER_ID)>
<cfsavecontent variable="title_"><cf_get_lang dictionary_id='1370.WM- Partnerim'></cfsavecontent>
<div class="col col-12 col-md-12 col-sm-12 col-xs-12">
	<!---<cfform name="add_ezgi_my_partners" id="add_ezgi_my_partners" action="" method="post">--->
   		<cf_box>
          	<cf_basket_form id="add_ezgi_purchase_return">
                    <div class="row">
                        <div class="col col-12 uniqueRow">
                            <div class="row formContent">
                                <cf_box_elements>
                                 	<div class="col col-12 uniqueRow">
                                     	<div class="col col-12">
                                         	<div class="col col-3">
                                            	<label><cf_get_lang dictionary_id='57633.Barkod'></label>
                                          	</div>
                                       		<div class="col col-9">
                                             	<div class="form-group" id="item-barcod">
                                                 	<input id="add_other_barcod" name="add_other_barcod" type="text" value="">
                                              	</div>
                                          	</div>
                                      	</div>
                                 	</div>
                                </cf_box_elements>
                            	<cf_box_footer>
                                    <div class="col col-12">
                                        <div class="col col-6" style="text-align:right"></div>
                                        <div class="col col-6" style="text-align:right;display:none" id="onay_div">
                                            <input id="onay" name="Onay" value="<cf_get_lang dictionary_id="57461.Kaydet">" type="button" onClick="kontrol_kayit();" />
                                        </div>
                                    </div>
                                </cf_box_footer>
                            </div>
                        </div>
                    </div>
       		</cf_basket_form>
     	</cf_box>
   	<!---</cfform>--->
	<cfsavecontent variable="sekme1"><cf_get_lang dictionary_id='42025.Partnerler'></cfsavecontent>
 	<cfsavecontent variable="sekme2"><cf_get_lang dictionary_id="58003.Performans"></cfsavecontent>
	<div id="basket_main_div">
     	<div class="row">
            <div class="col col-12 uniqueRow">
                <cf_basket_form id="upd_connect" class="row">
                    <div id="tab-container" class="tabStandart margin-top-5">
                        <div id="tab-head">
                            <ul class="tabNav">
                                <li class="<cfif attributes.anamenu eq 1>active</cfif>"><a id="href_partners" href="#partners"><cfoutput>#sekme1#</cfoutput></a></li>
                                <li class="<cfif attributes.anamenu eq 2>active</cfif>"><a id="href_performans" href="#performance"><cfoutput>#sekme2#</cfoutput></a></li>
                            </ul>
                        </div>
                        <div id="tab-content" class="margin-top-10"> 
                            <div id="partners" class="content row"> 
                            	<cfsavecontent variable="title"></cfsavecontent>
                                <cf_box title="#title#">
                                    <cf_grid_list>
                                        <thead>
                                            <tr>
                                                <th style="width:20px"><cf_get_lang dictionary_id='58577.Sıra'></th>
                                                <th style="width:100%"><cf_get_lang dictionary_id='55757.Adı Soyadı'></th>
                                                <th style="width:70px"><cf_get_lang dictionary_id='57742.Tarih'></th>
                                                <th style="width:25px">&nbsp;</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <cfif get_my_partners.recordcount>
                                                <cfoutput query="get_my_partners">
                                                	<input type="hidden" name="row_control_#currentrow#" id="row_control_#currentrow#" value="#EZGI_WM_MY_PARTNER_ID#" >
                                                    <tr id="row#currentrow#" height="20">
                                                        <td style="text-align:right">#currentrow#</td>
                                                        <td>#get_emp_info(MY_PARTNER_ID,0,0)#</td> 
                                                        <td style="text-align:center">#DateFormat(START_DATE,dateformat_style)#</td>
                                                        <td style="text-align:center">
                                                        	<a onclick="sil(#EZGI_WM_MY_PARTNER_ID#);"><i class="fa fa-minus" alt="<cf_get_lang dictionary_id='57463.Sil'>" title="<cf_get_lang dictionary_id='57463.Sil'>"></i></a>
                                                        </td>
                                                    </tr>
                                                </cfoutput>
                                            </cfif>
                                        </tbody>
                                    </cf_grid_list>
                                </cf_box>
                            </div>
                            <div id="performance" class="content row">
                                <cf_box title="#title#" uidrop="1" hide_table_column="1" scroll="1">
                                    
                                </cf_box>
                            </div>
                        </div>
                    </div>
                </cf_basket_form>
            </div>
        </div>                    
 	</div>                         
</div>
<div id="serial_div"></div>
<script language="javascript" type="text/javascript">
	setTimeout("document.getElementById('add_other_barcod').select();",1000);
 	document.onkeydown = checkKeycode
 	function checkKeycode(e) /*Barkod Okuyup Enter Basıldığında*/
	{
      	var keycode;
    	if (window.event) keycode = window.event.keyCode;
       	else if (e) keycode = e.which;
       	if (keycode == 13)
     	{
        	if (document.getElementById('add_other_barcod').value.length == '') /*Barkod Boşsa*/
          	{
             	 alert('<cf_get_lang dictionary_id='62746.Barkod Giriniz'>'); 
               	document.getElementById('add_other_barcod').value = '';
               	document.getElementById('add_other_barcod').focus();	
         	}
       		else /*Barkod Doluysa*/
         	{
				<cfoutput>
					partner_list = '#partner_list#';
				</cfoutput>
				if(list_find(partner_list,document.getElementById('add_other_barcod').value))
				{
					alert('İlgili Personel Zaten Parteriniz');
					document.getElementById('add_other_barcod').value = '';
               		document.getElementById('add_other_barcod').focus();
				}
				else
				{
					window.location ="<cfoutput>#request.self#?fuseaction=stock.add_ezgi_my_partners&type=add</cfoutput>&new_partner="+document.getElementById('add_other_barcod').value;
				}
         	}
     	}
	}
	function sil(my_partner_id)
	{
		sor=confirm('Partnerinizi Gurubunuzdan Çıkarıyorum ?')
		if(sor==true)
		{
			window.location ="<cfoutput>#request.self#?fuseaction=stock.add_ezgi_my_partners&type=del</cfoutput>&ezgi_my_partner_id="+my_partner_id;
		}
		else
			return false;
	}
</script>
