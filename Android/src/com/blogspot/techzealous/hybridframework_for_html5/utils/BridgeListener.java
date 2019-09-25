package com.blogspot.techzealous.hybridframework_for_html5.utils;

import java.util.ArrayList;

import android.view.View;
import android.webkit.WebView;

public interface BridgeListener {

	public void callJsFunction(String aFunctionAndArgs);
	public void callJsFunction(String aFunctionName, String aArg);
	public void callJsFunction(String aFunctionName, ArrayList<String> aArgs);
}
