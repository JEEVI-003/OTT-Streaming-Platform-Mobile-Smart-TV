package com.VsmartEngine.MediaJungle.controller;

import java.util.List;
import java.util.Map;

import com.VsmartEngine.MediaJungle.model.AddUser;

public class UserWithStatus {

	private List<AddUser> userList;
    private boolean isEmpty;
    private boolean valid;
    private boolean type;
    private List<Map<String, Object>> dataList;

//    public UserListWithStatus(boolean isEmpty, boolean valid, boolean type, List<Map<String, Object>> dataList) {
//        this.isEmpty = isEmpty;
//        this.valid = valid;
//        this.type = type;
//        this.dataList = dataList;
//    }
    
    
    public List<AddUser> getUserList() {
        return userList;
    }



	public boolean getType() {
		return type;
	}
    
    public UserWithStatus(List<AddUser> userList, boolean isEmpty, boolean valid, boolean type,
		List<Map<String, Object>> dataList) {
	super();
	this.userList = userList;
	this.isEmpty = isEmpty;
	this.valid = valid;
	this.type = type;
	this.dataList = dataList;
}

	public List<Map<String, Object>> getDataList() {
        return dataList;
    }


	public void setType(boolean type) {
		this.type = type;
	}



	public boolean isEmpty() {
        return isEmpty;
    }

    public boolean isValid() {
        return valid;
    }
}
