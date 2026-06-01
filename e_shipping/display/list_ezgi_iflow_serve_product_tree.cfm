<!---
    File: _list_ezgi_iflow_serve_product_tree.cfm
    Folder: Add_Ons\ezgi\e-shipping\display
    Author: Ezgi Yazılım
    Date: 19/01/2024
    Description:
--->

<cfquery name="get_main_info" datasource="#dsn3#">
 	SELECT 
    	EDM.DESIGN_MAIN_ROW_ID, 
      	TBL.PATH, 
     	S.STOCK_ID, 
     	S.PRODUCT_CODE, 
      	S.PRODUCT_NAME
  	FROM     
     	EZGI_DESIGN_MAIN_ROW AS EDM INNER JOIN
     	STOCKS AS S ON EDM.DESIGN_MAIN_RELATED_ID = S.STOCK_ID LEFT OUTER JOIN
     	(
         	SELECT 
            	PRODUCT_ID, 
       			PATH
         	FROM      
         		#dsn1_alias#.PRODUCT_IMAGES
        	WHERE   
              	PRODUCT_IMAGEID IN
                             	(
                                 	SELECT 
                                     	MIN(PRODUCT_IMAGEID) AS PRODUCT_IMAGEID
                                 	FROM      
                                     	#dsn1_alias#.PRODUCT_IMAGES AS PRODUCT_IMAGES_1
                                  	WHERE   
                                    	IMAGE_SIZE = 2
                                  	GROUP BY 
                                    	PRODUCT_ID
                     			)
  		) AS TBL ON S.PRODUCT_ID = TBL.PRODUCT_ID
 	WHERE  
     	S.STOCK_ID= #attributes.stock_id# AND 
      	S.IS_PROTOTYPE = 0
</cfquery>
<cfif get_main_info.recordcount>
	<cfquery name="get_package_info" datasource="#dsn3#">
     	SELECT 
        	EDP.PACKAGE_ROW_ID,
          	TBL.PATH, 
        	S.STOCK_ID, 
          	P.PRODUCT_CODE, 
       		P.PRODUCT_NAME,
        	EDP.PACKAGE_AMOUNT AS AMOUNT,
       		'PK' AS NUMBER
   		FROM     
         	#dsn1_alias#.STOCKS AS S INNER JOIN
         	#dsn1_alias#.PRODUCT AS P ON P.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
       		EZGI_DESIGN_PACKAGE AS EDP ON S.STOCK_ID = EDP.PACKAGE_RELATED_ID LEFT OUTER JOIN
      		(
              	SELECT 
                 	PRODUCT_ID, 
                  	PATH
              	FROM      
                 	#dsn1_alias#.PRODUCT_IMAGES
             	WHERE   
                	PRODUCT_IMAGEID IN
                 	(
                     	SELECT 
                          	MIN(PRODUCT_IMAGEID) AS PRODUCT_IMAGEID
                      	FROM      
                         	#dsn1_alias#.PRODUCT_IMAGES AS PRODUCT_IMAGES_1
                       	WHERE   
                       		IMAGE_SIZE = 2
                    	GROUP BY 
                          	PRODUCT_ID
                 	)
         	) AS TBL ON P.PRODUCT_ID = TBL.PRODUCT_ID
    	WHERE  
         	EDP.DESIGN_MAIN_ROW_ID = #get_main_info.DESIGN_MAIN_ROW_ID# AND
         	ISNULL(P.IS_EXTRANET,0) = 1
     	ORDER BY 
          	EDP.PACKAGE_NUMBER
	</cfquery>
                            
	<cfquery name="get_piece_all_info" datasource="#dsn3#">
     	SELECT 
      		EDP.PIECE_ROW_ID,
          	TBL.PATH, 
         	S.STOCK_ID, 
          	P.PRODUCT_CODE, 
         	P.PRODUCT_NAME, 
        	EDP.PIECE_CODE AS NUMBER, 
        	EDP.PIECE_TYPE,
         	EDP.PIECE_AMOUNT AS AMOUNT
   		FROM     
         	#dsn1_alias#.STOCKS AS S INNER JOIN
       		#dsn1_alias#.PRODUCT AS P ON P.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
        	EZGI_DESIGN_PIECE AS EDP ON S.STOCK_ID = EDP.PIECE_RELATED_ID LEFT OUTER JOIN
         	(
              	SELECT 
                 	PRODUCT_ID, 
                  	PATH
              	FROM      
                 	#dsn1_alias#.PRODUCT_IMAGES
             	WHERE   
             	    PRODUCT_IMAGEID IN
             	                      (
             	                        SELECT 
             	                            MIN(PRODUCT_IMAGEID) AS PRODUCT_IMAGEID
             	                        FROM      
             	                            #dsn1_alias#.PRODUCT_IMAGES AS PRODUCT_IMAGES_1
             	                        WHERE   
             	                            IMAGE_SIZE = 2
             	                        GROUP BY 
             	                            PRODUCT_ID
             	                        )
       		) AS TBL ON P.PRODUCT_ID = TBL.PRODUCT_ID
      	WHERE  
      	    EDP.DESIGN_MAIN_ROW_ID = #get_main_info.DESIGN_MAIN_ROW_ID# AND
      	    ISNULL(P.IS_EXTRANET,0) = 1
      	ORDER BY 
      	    EDP.PIECE_CODE
	</cfquery>
	<cfquery name="get_piece_info" dbtype="query">
	    SELECT * FROM get_piece_all_info WHERE PIECE_TYPE <> 4
	</cfquery>
	<cfquery name="get_piece_raw_info" dbtype="query">
	    SELECT * FROM get_piece_all_info WHERE PIECE_TYPE = 4
	</cfquery>
	<cfif get_piece_info.recordcount>
	    <cfset PIECE_ROW_ID_list = ValueList(get_piece_info.PIECE_ROW_ID)>
	    <cfquery name="get_material_info" datasource="#dsn3#">
	        SELECT 
	        	'MLZ' AS NUMBER,
	            EDP.PIECE_ROW_ID,
	            TBL.PATH, 
	            S.STOCK_ID, 
	            P.PRODUCT_CODE, 
	            P.PRODUCT_NAME, 
	            EDP.AMOUNT
	        FROM     
	            #dsn1_alias#.STOCKS AS S INNER JOIN
	        	#dsn1_alias#.PRODUCT AS P ON P.PRODUCT_ID = S.PRODUCT_ID INNER JOIN
	            EZGI_DESIGN_PIECE_ROW AS EDP ON S.STOCK_ID = EDP.STOCK_ID LEFT OUTER JOIN
	            (
	                SELECT 
	                    PRODUCT_ID, PATH
	                FROM      
	                    #dsn1_alias#.PRODUCT_IMAGES
	                WHERE   
	                    PRODUCT_IMAGEID IN
		        						(
                                         	SELECT 
                                             	MIN(PRODUCT_IMAGEID) AS PRODUCT_IMAGEID
                                          	FROM      
                                            	#dsn1_alias#.PRODUCT_IMAGES AS PRODUCT_IMAGES_1
                                          	WHERE   
                                            	IMAGE_SIZE = 2
                                          	GROUP BY 
                                             	PRODUCT_ID
                                    	)
          	) AS TBL ON P.PRODUCT_ID = TBL.PRODUCT_ID
	        WHERE  
	            EDP.PIECE_ROW_ID IN (#PIECE_ROW_ID_list#) AND
	            EDP.PIECE_ROW_ROW_TYPE = 2  AND
	            ISNULL(P.IS_EXTRANET,0) = 1
	    </cfquery>
	    <cfquery name="get_all_material_info_group" dbtype="query">
	            SELECT
	            	NUMBER,
	                PATH, 
	                STOCK_ID, 
	                PRODUCT_CODE, 
	                PRODUCT_NAME, 
	                AMOUNT
	            FROM
	                get_material_info
	            UNION ALL
	            SELECT 
	            	NUMBER,
	                PATH, 
	                STOCK_ID, 
	                PRODUCT_CODE, 
	                PRODUCT_NAME, 
	                AMOUNT
	            FROM
	                get_piece_raw_info
	    </cfquery>
	    <cfif get_all_material_info_group.recordcount>
	        <cfquery name="get_all_material_info" dbtype="query">
	            SELECT
	            	NUMBER,
	                PATH, 
	                STOCK_ID, 
	                PRODUCT_CODE, 
	                PRODUCT_NAME,
	                SUM(AMOUNT) AS AMOUNT
	            FROM
	                get_all_material_info_group
	            GROUP BY
	            	NUMBER,
	                PATH, 
	                STOCK_ID, 
	                PRODUCT_CODE, 
	                PRODUCT_NAME	
	        </cfquery>
	    <cfelse>
	        <cfset get_all_material_info.recordcount=0>
	    </cfif>
	</cfif>
	<cfquery name="get_all" dbtype="query">
		SELECT
	    	2 AS TYPE,
	     	PATH, 
	      	STOCK_ID, 
	       	PRODUCT_CODE, 
	      	PRODUCT_NAME,
	     	AMOUNT,
	        NUMBER
	  	FROM
			get_package_info
	  	UNION ALL
	    SELECT
	    	3 AS TYPE,
	     	PATH, 
	      	STOCK_ID, 
	       	PRODUCT_CODE, 
	      	PRODUCT_NAME,
	     	AMOUNT,
	        NUMBER
	  	FROM
			get_piece_info
	  	<cfif isdefined('get_all_material_info') and get_all_material_info.recordcount>
	    UNION ALL
	 	SELECT
	    	4 AS TYPE,
	     	PATH, 
	      	STOCK_ID, 
	       	PRODUCT_CODE, 
	      	PRODUCT_NAME,
	     	AMOUNT,
	        NUMBER
	  	FROM
			get_all_material_info	
	 	</cfif>
	</cfquery>
    <cfsavecontent variable="ezgi_header"><cf_get_lang dictionary_id='709.SSH'></cfsavecontent>
    <div class="col col-12 col-md-12 col-sm-12 col-xs-12">
        <cf_box title="#ezgi_header#">
	    	<cfif LEN(get_main_info.PATH)>
	    		<div style="width:100%;text-align:center; vertical-align:middle">
	            	<cfoutput>
	            	<img src="/documents/product/#get_main_info.PATH#" style="width:100%;"/>
	                </cfoutput>
	            </div>
	    	</cfif>
	         <cf_grid_list sort="1">
	            <thead>
	                <tr>
	                    <th width="80"></th>
	                    <th width="40"><cf_get_lang dictionary_id='844.Parça No'></th>
	                    <th><cf_get_lang dictionary_id='57564.Ürünler'></th>
	                    <th width="70"><cf_get_lang dictionary_id='57635.Miktar'></th>
	                    <th width="40"></th>
	                </tr>
	            </thead>
	            <tbody>
	                <cfif get_all.recordcount>
	                    <cfoutput query="get_all">
	                        <tr height="40" id="a_frm_row#currentrow#" title="#PRODUCT_NAME#" style="background-color:<cfif get_all.type eq 2>snow<cfelseif get_all.type eq 4>lightcyan<cfelse>white</cfif>">
                                <td style="text-align:center;">
                                    <cfif len(get_piece_info.path)>
                                        <img  alt="product" src="/documents/product/#get_all.path#" style="height:60px;"/>
                                    <cfelse>
                                        <img  alt="product" src="/images/production/no-image.png" style="height:40px;"/>
                                    </cfif>
                                </td>
                                <td style="text-align:center;"><cfif get_all.type neq 4>#NUMBER#<cfelse>AKS</cfif></td>
                                <td style="text-align:left;">#PRODUCT_NAME#</td>
                                <td style="text-align:right;">
                                    <select name="a_connect_amount_#STOCK_ID#" id="a_connect_amount_#STOCK_ID#" style="font-size:14px; font-weight:bold; height:100%; width:100%; background-color:mintcream; border:none">
                                        <option value="1" >1</option>
                                        <option value="2" >2</option>
                                        <option value="3" >3</option>
                                        <option value="4" >4</option>
                                        <option value="5" >5</option>
                                        <option value="6" >6</option>
                                        <option value="7" >7</option>
                                        <option value="8" >8</option>
                                        <option value="9" >9</option>
                                    </select>
                                </td>
                                
                                <td style="text-align:center;">
                                    <input type="checkbox" name="a_select_production" value="#STOCK_ID#" >
                                </td>
	                        </tr>
	                    </cfoutput>
	                </cfif>
	            </tbody>
	        </cf_grid_list>
            <div id="ssh_buton" style="height:40px; width:100%;text-align:center; vertical-align:middle;">
   		<cfoutput>
        	<a href="javascript://" onclick="add_ssh_grupla();">
              	<button type="button" name="trasferring" style="width:45%; font-size:10px;border-radius:10px; font-weight:bold;height:35px;border:none;background-color: orange !important;color: white !important;">
                 	<i class="fa fa-shopping-basket" style="font-size:15px;"></i>
            	</button>
        	</a>
     	</cfoutput>
	</div>         
	    </cf_box>
  	</div>
    
</cfif>             	
<script type="text/javascript">
	function add_ssh_grupla()
	{
		ssh_stock_id_list = '';
		ssh_amount_list = '';
		chck_leng = document.getElementsByName('a_select_production').length;
		for(ci=0;ci<chck_leng;ci++)
		{
			var my_objets = document.all.a_select_production[ci];
			if(my_objets.checked == true)
			{
				stockid = my_objets.value;
				amount = document.getElementById('a_connect_amount_'+stockid).value;
				ssh_stock_id_list +=my_objets.value+',';
				ssh_amount_list +=amount+',';
			}
		}
		ssh_stock_id_list = ssh_stock_id_list.substr(0,ssh_stock_id_list.length-1);//sondaki virgülden kurtarıyoruz.
		ssh_amount_list = ssh_amount_list.substr(0,ssh_amount_list.length-1);//sondaki virgülden kurtarıyoruz.
		if(ssh_stock_id_list!='')
			window.location ="<cfoutput>#request.self#?fuseaction=sales.emptypopup_add_ezgi_iflow_serve_product_tree&order_id=#attributes.order_id#</cfoutput>&stock_id_list="+ssh_stock_id_list+"&amount_list="+ssh_amount_list
		else
		{
			alert('Ürün Seçimi Yapın!!!');
			return false;
		}
	}
</script>