<!---
    File: logout.cfm
    Folder: AddOns/ezgi/e_partner/query
    Author: Ezgi Yazılım
    Date: 01/05/2025
    Description: B2B Partner Portal - Logout İşlemi
--->
<cfscript>
    // Session'ı temizle
    if (structKeyExists(session, "b2b")) {
        structClear(session.b2b);
    }
    session.b2b = structNew();
    session.b2b.loggedIn = false;
</cfscript>

<cflocation url="index.cfm?fuseaction=partner.login" addtoken="false">

