package com.VsmartEngine.MediaJungle.googleLogin;

import java.security.Principal;
import java.util.HashMap;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@CrossOrigin
public class AuthController {

    @GetMapping("/auth/userinfo")
    public ResponseEntity<Map<String, String>> getUserInfo(Principal principal) {
        if (principal == null) {
            return ResponseEntity.status(401).build();
        }
       
//        OAuth2AuthenticationToken token = (OAuth2AuthenticationToken) principal;
//        String name = token.getPrincipal().getAttribute("name"); // verify this attribute is present
//        String email = token.getPrincipal().getAttribute("email");

        Map<String, String> userInfo = new HashMap<>();
//        userInfo.put("name", "name" != null ? name : "No Name");
//        userInfo.put("email", "email" != null ? email : "No Email");
//        System.out.println("name"+" \n"+email );

        return ResponseEntity.ok(userInfo);
    }
}

