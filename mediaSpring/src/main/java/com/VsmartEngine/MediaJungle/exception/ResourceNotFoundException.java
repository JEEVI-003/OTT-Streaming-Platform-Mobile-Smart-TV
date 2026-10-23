package com.VsmartEngine.MediaJungle.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(value = HttpStatus.NOT_FOUND)
public class ResourceNotFoundException extends RuntimeException  {
	
	private static final long serialVersionUID = 1L;
	
	public ResourceNotFoundException(String message) {
        super(message);
    }

	private boolean status;
	private String message;
	public ResourceNotFoundException(boolean b, String string) {
		// TODO Auto-generated constructor stub
	}
	public ResourceNotFoundException() {
		// TODO Auto-generated constructor stub
	}
	public boolean isStatus() {
		return status;
	}
	public void setStatus(boolean status) {
		this.status = status;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	
}
