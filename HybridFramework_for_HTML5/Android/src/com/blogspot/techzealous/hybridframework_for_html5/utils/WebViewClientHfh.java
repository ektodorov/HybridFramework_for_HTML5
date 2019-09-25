package com.blogspot.techzealous.hybridframework_for_html5.utils;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.util.Log;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.LinearLayout;

public class WebViewClientHfh extends WebViewClient {

	private final String LOG = "WebViewClientHfh";
	
	private BridgeHelper mBridgeHelper;
	
	public WebViewClientHfh (Activity aAct, Context aCtx, LinearLayout aLinearLayoutMain, WebView aWebView) {
		super();
		Handler handlerMain = new Handler();
		mBridgeHelper = new BridgeHelper(aAct, aCtx, aLinearLayoutMain, aWebView, handlerMain);
	}
	
	@Override
    public boolean shouldOverrideUrlLoading(WebView view, String url) {
    	Log.i(LOG, "shouldLoadUrl url=" + url);
    	if (url.startsWith(ConstantsHfh.HFH_SCHEMA_PREFIX)) {
            //do not load the page
    		String strUrl = url;
    		mBridgeHelper.callNativeMethod(strUrl);
            return true;
        }
        //load the page
        return false;
    }
	
	public BridgeHelper getBridgeHelper() {
		return mBridgeHelper;
	}
}
