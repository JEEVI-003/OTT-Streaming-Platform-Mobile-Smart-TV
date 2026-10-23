package com.VsmartEngine.MediaJungle.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name="plan_features")
public class PlanFeatures {
	
		@Id
		@GeneratedValue(strategy=GenerationType.IDENTITY)
		private long id;
		
		@Column(name = "features")
		private String features;

		public PlanFeatures() {
			super();
		}

		public String getFeatures() {
			return features;
		}

		public void setFeatures(String features) {
			this.features = features;
		}

		public long getId() {
			return id;
		}

		public void setId(long id) {
			this.id = id;
		}

		public PlanFeatures(long id, String features) {
			super();
			this.id = id;
			this.features = features;
		}

		public void setFeature(PlanFeatures feature) {
			// TODO Auto-generated method stub
			this.features = features;
		}

		
	}



