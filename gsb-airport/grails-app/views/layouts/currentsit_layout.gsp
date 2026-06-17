<!DOCTYPE html>
<!--[if lt IE 7 ]> <html lang="en" class="no-js ie6"> <![endif]-->
<!--[if IE 7 ]>    <html lang="en" class="no-js ie7"> <![endif]-->
<!--[if IE 8 ]>    <html lang="en" class="no-js ie8"> <![endif]-->
<!--[if IE 9 ]>    <html lang="en" class="no-js ie9"> <![endif]-->
<!--[if (gt IE 9)|!(IE)]><!--> <html lang="en" class="no-js"><!--<![endif]-->
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
    <title><g:layoutTitle default="GeoDB Dashboard"/></title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="shortcut icon" href="${assetPath(src: 'faviconL.ico')}" type="image/x-icon">
    <asset:stylesheet src="application.css"/>
    <asset:javascript src="application.js"/>

    <g:layoutHead/>
</head>

<body>
<div align="right" class="logintop"><sec:ifLoggedIn>User: <sec:loggedInUserInfo
        field="username"/></sec:ifLoggedIn></div>
<sec:ifNotLoggedIn><div align="right" class="buttonslogin"><g:link controller="login"
                                                                   action="auth">Login</g:link></div></sec:ifNotLoggedIn>
<div id="grailsLogo" role="banner">
    <a class="gsb-logo-link" href="${createLink(uri: '/')}">
        <span class="gsb-logo-mark" aria-hidden="true">GSB</span>
        <span class="gsb-logo-title"><gsb:bannerText slot="brandSubtitle" defaultText="Emergency Management"/></span>
    </a>
</div>
<gsb:quickLinks/>


<g:layoutBody/>
<div class="footer" role="contentinfo"></div>

<div id="spinner" class="spinner" style="display:none;"><g:message code="spinner.alt" default="Loading&hellip;"/></div>
</body>

<footer>


</footer>
</html>
