package com.blogspot.techzealous.hybridframework_for_html5.utils;

import java.util.ArrayList;

import android.support.v4.util.SimpleArrayMap;
import android.view.View;

public class InstanceData extends Object {

	private static InstanceData instance;
	private SimpleArrayMap<String, String> dictInstanceVariables;
	private ArrayList<View> arrayViews;
	private ArrayList<String> arrayPerformJavaScript;
	
	public InstanceData() {
		super();
		
		dictInstanceVariables = new SimpleArrayMap<String, String>();
		arrayViews = new ArrayList<View>();
		arrayPerformJavaScript = new ArrayList<String>();
	}
	
	public static InstanceData getInstanceData() {
		if(instance == null) {
			instance = new InstanceData();	
		}
		return instance;
	}
	
	public void releaseInstanceData() {
		instance = null;
	}
	
	public SimpleArrayMap<String, String> getDictInstanceVariables() {
		return dictInstanceVariables;
	}
	
	public ArrayList<View> getArrayViews() {
		return arrayViews;
	}
	
	public ArrayList<String> getArrayPerformJavaScript() {
		return arrayPerformJavaScript;
	}
}
