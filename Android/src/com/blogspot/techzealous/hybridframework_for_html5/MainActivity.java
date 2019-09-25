package com.blogspot.techzealous.hybridframework_for_html5;

import java.util.ArrayList;

import android.app.Activity;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.view.Menu;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup.LayoutParams;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.LinearLayout;

import com.blogspot.techzealous.hybridframework_for_html5.utils.ConstantsHfh;
import com.blogspot.techzealous.hybridframework_for_html5.utils.WebViewClientHfh;

public class MainActivity extends Activity {

	private final String LOG = "MainActivity";
	private LinearLayout linearLayoutMain;
	private WebView webViewMain;
	private Button myButton;
	
	private WebViewClientHfh mWebViewClient;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);
		
		linearLayoutMain = (LinearLayout) findViewById(R.id.LinearLayoutMain);
		webViewMain = (WebView) findViewById(R.id.webViewMain);
		
		webViewMain.getSettings().setJavaScriptEnabled(true);
		mWebViewClient = new WebViewClientHfh(this, this, linearLayoutMain, webViewMain);
		webViewMain.setWebViewClient(mWebViewClient);
		
		//webViewMain.loadUrl("javascript:myFunction()");
		
		webViewMain.loadUrl(ConstantsHfh.PAGE_HOME);
		
		myButton = new Button(MainActivity.this);
		myButton.setText("Home");
		LayoutParams params = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
		myButton.setLayoutParams(params);
		linearLayoutMain.addView(myButton, 0);
		myButton.requestLayout();
		
		myButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				webViewMain.loadUrl("javascript:loadHome();");
			}
		});
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		if (requestCode == ConstantsHfh.CONTACTS_CODE && resultCode == Activity.RESULT_OK) {
			Uri contact = data.getData();
			Cursor cursor = getContentResolver().query(contact, null, null, null, null);
			/*
			//added in API 11
			CursorLoader cl = new CursorLoader(this, contact, null, null, null, null);
			cl.loadInBackground();
			cl.registerListener(1, new OnLoadCompleteListener<Cursor> () {
				@Override
				public void onLoadComplete(Loader<Cursor> arg0, Cursor arg1) {
					if(arg1.moveToFirst()) {
						String contactId = arg1.getString(arg1.getColumnIndexOrThrow(ContactsContract.Contacts._ID));
						
					}
				}
			});
			*/
			if (cursor.moveToFirst()) {
				ArrayList<String> phonesList = new ArrayList<String>();
				String contactId = cursor.getString(cursor.getColumnIndexOrThrow(ContactsContract.Contacts._ID));
				//deprecated - Cursor phones = managedQuery(ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
				//		null, ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = " + contactId, null, null);
				Cursor phones = getContentResolver().query(ContactsContract.CommonDataKinds.Phone.CONTENT_URI, 
						null, ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = " + contactId, null, null);
				while (phones.moveToNext()) {
					String number = phones.getString(phones.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
					phonesList.add(number);
				}
				mWebViewClient.getBridgeHelper().onContactSelected(phonesList);
			}
		} else if(requestCode == ConstantsHfh.CAMERA_CODE) {
			if(resultCode == Activity.RESULT_OK) {
				String path = data.getDataString();
				mWebViewClient.getBridgeHelper().onCameraPicture(path);
			}
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}
}
