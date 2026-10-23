package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name="AddNewCategories")
public class AddNewCategories {
	
		@Id
		@GeneratedValue(strategy=GenerationType.IDENTITY)
		private long category_id;
		
		@Column(name = "categories")
		private String categories;
		
		

		public AddNewCategories() {
			super();
			// TODO Auto-generated constructor stub
		}

		public String getCategories() {
			return categories;
		}

		public void setCategories(String categories) {
			this.categories = categories;
		}

		public long getCategory_id() {
			return category_id;
		}

		public void setCategory_id(long category_id) {
			this.category_id = category_id;
		}

		public AddNewCategories(long category_id, String categories) {
			super();
			this.category_id = category_id;
			this.categories = categories;
		}

		@Override
		public String toString() {
			return "AddNewCategories [category_id=" + category_id + ", categories=" + categories + "]";
		}

		

		
		
		

	}



