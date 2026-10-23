package com.VsmartEngine.MediaJungle.model;

import java.util.List;

public class UserListWithStatus {

    private List<AddUser> userList;
    private boolean isEmpty;
    private boolean valid;

    public UserListWithStatus(List<AddUser> userList, boolean isEmpty, boolean valid) {
        this.userList = userList;
        this.isEmpty = isEmpty;
        this.valid = valid;
    }


	public List<AddUser> getUserList() {
        return userList;
    }

    public boolean isEmpty() {
        return isEmpty;
    }

    public boolean isValid() {
        return valid;
    }
}
