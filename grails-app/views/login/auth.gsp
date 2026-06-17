<!doctype html>
<html>
<head>
    <meta name="layout" content="${gspLayout ?: 'main'}"/>
    <title>Sign In</title>
</head>
<body>
<main class="auth-page" role="main">
    <section class="auth-panel" aria-labelledby="login-title">
        <p class="geospatial-status-board-kicker">Emergency Management</p>
        <h1 id="login-title">Sign in</h1>

        <g:if test="${params.logout}">
            <div class="auth-message auth-message-success">You have been signed out.</div>
        </g:if>

        <g:if test="${flash.message}">
            <div class="auth-message">${flash.message}</div>
        </g:if>

        <form action="${postUrl ?: request.contextPath + '/login/authenticate'}" method="POST" id="loginForm" autocomplete="off">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text"
                       class="form-control"
                       name="${usernameParameter ?: 'username'}"
                       id="username"
                       autocapitalize="none"
                       autofocus/>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password"
                       class="form-control"
                       name="${passwordParameter ?: 'password'}"
                       id="password"/>
            </div>

            <div class="form-check auth-check">
                <input type="checkbox"
                       class="form-check-input"
                       name="${rememberMeParameter ?: 'remember-me'}"
                       id="remember_me"
                       <g:if test="${hasCookie}">checked="checked"</g:if>/>
                <label class="form-check-label" for="remember_me">Remember me</label>
            </div>

            <button type="submit" class="btn btn-primary btn-block">Sign in</button>
        </form>
    </section>
</main>
</body>
</html>
