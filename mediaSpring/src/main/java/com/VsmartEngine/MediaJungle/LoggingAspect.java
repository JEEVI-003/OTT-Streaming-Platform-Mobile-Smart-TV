package com.VsmartEngine.MediaJungle;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.AfterReturning;
import org.aspectj.lang.annotation.AfterThrowing;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.annotation.Pointcut;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;



@Aspect
@Component
public class LoggingAspect {
	
	 private static final Logger logger = LoggerFactory.getLogger(LoggingAspect.class);
	 
	 @Pointcut("within(com.VsmartEngine.MediaJungle.FrontController)")
	 public void frontControllerMethods() {}
	 
	// Log the request before the method execution
	    @Before("frontControllerMethods()")
	    public void logBefore(JoinPoint joinPoint) {
	        logger.info("Entering method: {} with arguments: {}", joinPoint.getSignature().getName(), joinPoint.getArgs());
	    }

	    // Log the response after the method execution
	    @AfterReturning(pointcut = "frontControllerMethods()", returning = "result")
	    public void logAfterReturning(JoinPoint joinPoint, Object result) {
	        logger.info("Exiting method: {} with result: {}", joinPoint.getSignature().getName(), result);
	    }

	    // Log exceptions thrown by the method
	    @AfterThrowing(pointcut = "frontControllerMethods()", throwing = "exception")
	    public void logAfterThrowing(JoinPoint joinPoint, Throwable exception) {
	        logger.error("Exception in method: {} with message: {}", joinPoint.getSignature().getName(), exception.getMessage(), exception);
	    }


}
