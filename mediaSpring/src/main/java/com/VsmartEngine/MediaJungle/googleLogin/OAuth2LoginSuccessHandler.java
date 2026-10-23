package com.VsmartEngine.MediaJungle.googleLogin;

import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;

//@Component
public class OAuth2LoginSuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

//	@Override
//    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
//                                        Authentication authentication) throws IOException, ServletException {
//        // Optionally, you can extract user details from the token:
//        // OAuth2AuthenticationToken oauthToken = (OAuth2AuthenticationToken) authentication;
//        // String userEmail = oauthToken.getPrincipal().getAttribute("email");
//        // String userName = oauthToken.getPrincipal().getAttribute("name");
//        // And then append these as query parameters if needed
//
//        // Redirect to the React front end
//        String targetUrl = "http://localhost:4203";
//        getRedirectStrategy().sendRedirect(request, response, targetUrl);
//    }

}

