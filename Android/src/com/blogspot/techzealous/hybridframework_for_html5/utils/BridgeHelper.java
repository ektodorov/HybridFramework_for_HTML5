package com.blogspot.techzealous.hybridframework_for_html5.utils;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.lang.ref.WeakReference;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteException;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Environment;
import android.os.Handler;
import android.provider.MediaStore;
import android.util.Log;
import android.view.Display;
import android.view.Surface;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.webkit.WebView;
import android.widget.Button;
import android.widget.LinearLayout;

public class BridgeHelper extends Object implements BridgeListener {
	
	private final String LOG = "BridgeHelper";
	
	private WeakReference<LinearLayout> mWeakLinearLayoutMain; 
	private WeakReference<WebView> mWeakWebView;
	private WeakReference<Context> mWeakCtx;
	private WeakReference<Activity> mWeakActivity;
	private Handler mHandlerBridge;
	private JSONObject mDictMethodInfo;
	private String mStrCallBackForDeviceOrientationChange;
	private SQLiteDatabase mDb;
	private Cursor mCursor;
	
	public BridgeHelper(Activity aAct, Context aCtx, LinearLayout aLinearLayoutMain, WebView aWebView, Handler aHandler) {
		super();
		mWeakActivity = new WeakReference<Activity>(aAct);
		mWeakLinearLayoutMain = new WeakReference<LinearLayout>(aLinearLayoutMain);
		mWeakCtx = new WeakReference<Context>(aCtx);
		mWeakWebView = new WeakReference<WebView>(aWebView);
		mHandlerBridge = aHandler;
	}
	
	public void callNativeMethod(String url) {
		String strJson = url.substring(ConstantsHfh.HFH_SCHEMA_PREFIX.length());
		JSONObject json = null;
		try {
			json = new JSONObject(strJson);
			//String strMethod = json.getString(ConstantsHfh.HFH_KEY_METHODNAME).replaceAll(":", "");
			String stringMethod = json.getString(ConstantsHfh.HFH_KEY_METHODNAME);
			String strMethod = stringMethod.substring(0, (stringMethod.length() - 1));
			
			Method method = BridgeHelper.this.getClass().getMethod(strMethod, new Class[] {JSONObject.class});
			method.invoke(BridgeHelper.this, new Object[] {json});
		} catch (JSONException e) {
			//call the JS error callback (if the HFH_KEY_METHODNAME does not exist an exception is thrown)
			callJsErrorCallback(json, "");
			e.printStackTrace();
		} catch (NoSuchMethodException e) {
			callJsErrorCallback(json, "NoSuchMethodException");
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			callJsErrorCallback(json, "IllegalAccessException");
			e.printStackTrace();
		} catch (IllegalArgumentException e) {
			callJsErrorCallback(json, "IllegalArgumentException");
			e.printStackTrace();
		} catch (InvocationTargetException e) {
			callJsErrorCallback(json, "InvocationtargetException");
			e.printStackTrace();
		}
	}
	
	private void callPerformJavaScript(View aView) {
		int idx = InstanceData.getInstanceData().getArrayViews().indexOf(aView);
		String strJavaScript = InstanceData.getInstanceData().getArrayPerformJavaScript().get(idx);
		callJsFunction(strJavaScript);
	}

	private void callJsErrorCallback(JSONObject aDict, String aMsg) {
		try {
			String fName = aDict.getString(ConstantsHfh.HFH_KEY_ERROR_CALLBACK);
			if(aMsg == null) {aMsg = "";}
			callJsFunction(fName, aMsg);
		} catch (JSONException e) {
			e.printStackTrace();
		}
	}
	
	public JSONObject getMethodInfo() {
		return mDictMethodInfo;
	}

	public String getCallBackForDeviceOrientationChange() {
		return mStrCallBackForDeviceOrientationChange;
	}
	
	/* Instance Variables Persistence */
	//'jn://{"method":"callGetInstanceVariable:", "name":"my_var_name", "success":"callback_function_name", "error":"callback_function_name"}'
	public void callGetInstanceVariable(JSONObject aDict) throws JSONException {
		String val = InstanceData.getInstanceData().getDictInstanceVariables().get(aDict.getString(ConstantsHfh.HFH_KEY_NAME));
		String fName = aDict.getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
		callJsFunction(fName, val);
	}

	//'jn://{"method":"callSaveInstanceVariable:", "name":"my_var_name", "value":"var_value", "success":"callback_function_name", "error":"callback_function_name"}'
	public void callSaveInstanceVariable(JSONObject aDict) throws JSONException {	
		String valName = aDict.getString(ConstantsHfh.HFH_KEY_NAME);
		String val = aDict.getString(ConstantsHfh.HFH_KEY_VALUE);
		InstanceData.getInstanceData().getDictInstanceVariables().put(valName, val);
			
		String fName = aDict.getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
		callJsFunction(fName, "");
	}

	//'jn://{"method":"callRemoveInstanceVariable:", "name":"my_var_name"}'
	public void callRemoveInstanceVariable(JSONObject aDict) throws JSONException {
		String valName = aDict.getString(ConstantsHfh.HFH_KEY_NAME);
		InstanceData.getInstanceData().getDictInstanceVariables().remove(valName);
	}

	/* Native View use */
	//'jn://{"method":"callSetSizeWebViewMain:", "x":"x_position", "y":"y_position", "width":"size_width", "height":"size_height"}'
	public void callSetSizeWebViewMain(JSONObject aDict) {
		//do nothing not needed in Android layout system
	}

	//'jn://{"method":callMakeButton:", "buttontype":"type_int", "red":"redcolorvalue", "green":"greencolorvalue", "blue":"bluecolorvalue", "alpha":"alpha_value", "x":"x_position", "y":"y_position", "width":"size_width", "height":"size_height", "onclick":"javascript_function_name", "title":"button_title"}'
	// Values for color - [0-255]
	public void callMakeButton(JSONObject aDict) throws JSONException {
		Log.i(LOG, "callMakeButton, aDict=" + aDict);
		Button myButton = new Button(mWeakCtx.get());
		myButton.setText("Home");
		LayoutParams params = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
		myButton.setLayoutParams(params);
		mWeakLinearLayoutMain.get().addView(myButton, 0);
		myButton.requestLayout();
				
		String idx = "" + InstanceData.getInstanceData().getArrayViews().size();
		InstanceData.getInstanceData().getArrayViews().add(myButton);
		String fName = aDict.getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
		
		try {
			aDict.getInt(ConstantsHfh.HFH_KEY_RED);
			setBackgroundColor(aDict);
		} catch (JSONException e) {
			//do nothing there were no colors set
		}
		
		try {
			aDict.getString(ConstantsHfh.HFH_KEY_IMAGE);
			setButtonBackgroundImage(aDict);
		} catch (JSONException e) {
			//do nothing there was no image set
		}
		
		try {
			aDict.getString(ConstantsHfh.HFH_KEY_ONCLICK);
			setButtonOnClickListener(aDict);
		} catch (JSONException e) {
			//do nothing there was no onClickListener set
		}
		
		try {
			aDict.getString(ConstantsHfh.HFH_KEY_TITLE);
			setButtonTitle(aDict);
		} catch (JSONException e) {
			//do nothing there was no title set
		}
		
		callJsFunction(fName, idx);
	}

	//'jn://{"method":"setButtonTitle:", "title":"button_title", "viewidx":"index_in_the_instance_views_array"}'
	public void setButtonTitle(JSONObject aDict) throws JSONException {
		final String strTitle = aDict.getString(ConstantsHfh.HFH_KEY_TITLE);
		final int viewIdx = aDict.getInt(ConstantsHfh.HFH_KEY_VIEWIDX);
		mHandlerBridge.post(new Runnable() {
			public void run() {
				Button button = (Button) InstanceData.getInstanceData().getArrayViews().get(viewIdx);
				button.setText(strTitle);
			}
		});	
	}

	//'jn://{"method":"setBackgroundColor:", "red":"color_value", "green":"color_value", "blue":"color_value", "alpha":"alpha_value", "viewidx":"index_in_the_instance_views_array"}'
	public void setBackgroundColor(JSONObject aDict) throws JSONException {
		int red = aDict.getInt(ConstantsHfh.HFH_KEY_RED);
		int green = aDict.getInt(ConstantsHfh.HFH_KEY_GREEN);
		int blue = aDict.getInt(ConstantsHfh.HFH_KEY_BLUE);
		int alpha = aDict.getInt(ConstantsHfh.HFH_KEY_ALPHA);
		final int viewIdx = aDict.getInt(ConstantsHfh.HFH_KEY_VIEWIDX);
		final int color = Color.argb(alpha, red, green, blue);
		mHandlerBridge.post(new Runnable() {
			public void run() {
				View view = (View) InstanceData.getInstanceData().getArrayViews().get(viewIdx);
				view.setBackgroundColor(color);
			}
		});
	}

	//'jn://{"method":"setButtonBackgroundImage:", "img":"filepath_toimage_file", "viewidx":"index_in_the_instance_views_array"}'
	public void setButtonBackgroundImage(JSONObject aDict) throws JSONException {
		String strImg = aDict.getString(ConstantsHfh.HFH_KEY_IMAGE);
		final int viewIdx = aDict.getInt(ConstantsHfh.HFH_KEY_VIEWIDX);
		final Drawable bg = BitmapDrawable.createFromPath(strImg);
		mHandlerBridge.post(new Runnable() {
			public void run() {
				Button button = (Button) InstanceData.getInstanceData().getArrayViews().get(viewIdx);
				button.setBackgroundDrawable(bg);
			}
		});
	}

	//'jn://{"method":"setPositionAndSize:", "x":"x_position", "y":"y_position", "width":"size_width", "height":"size_height", "viewidx":"index_in_the_instance_views_array"}'
	public void setPositionAndSize(JSONObject aDict) throws JSONException {		
		int posX = aDict.getInt(ConstantsHfh.HFH_KEY_POSX);
		int posY = aDict.getInt(ConstantsHfh.HFH_KEY_POSY);
		int width = aDict.getInt(ConstantsHfh.HFH_KEY_WIDTH);
		int height = aDict.getInt(ConstantsHfh.HFH_KEY_HEIGHT);
		int viewIdx = aDict.getInt(ConstantsHfh.HFH_KEY_VIEWIDX);
		View view = InstanceData.getInstanceData().getArrayViews().get(viewIdx);
		ViewGroup.MarginLayoutParams params = new ViewGroup.MarginLayoutParams(width, height);
		params.setMargins(posX, posY, 0, 0);
		view.setLayoutParams(params);
		view.requestLayout();
	}

	//'jn://{"method":"setButtonOnClickListener:", "onclick":"javascript_function_name", "viewidx":"index_in_the_instance_views_array"}'
	public void setButtonOnClickListener(JSONObject aDict) throws JSONException {
		Log.i(LOG, "setButonOnClickListener, aDict=" + aDict);
		String strOnClick = aDict.getString(ConstantsHfh.HFH_KEY_ONCLICK);
		int viewIdx = aDict.getInt(ConstantsHfh.HFH_KEY_VIEWIDX);
		InstanceData.getInstanceData().getArrayPerformJavaScript().add(viewIdx, strOnClick);
		Button button = ((Button) InstanceData.getInstanceData().getArrayViews().get(0));
		button.setOnClickListener(new OnClickListener() {
			public void onClick(View v) {
				Log.i("BridgeHelper", "OnClickListener");
				callPerformJavaScript(v);
			}
		});
	}

	//'jn://{"method":"setViewHidden:", "viewidx":"index_in_the_instance_views_array"}'
	public void setViewHidden(JSONObject aDict) throws JSONException {
		final int viewIdx = aDict.getInt(ConstantsHfh.HFH_KEY_VIEWIDX);
		mHandlerBridge.post(new Runnable() {
			public void run() {
				View view = InstanceData.getInstanceData().getArrayViews().get(viewIdx);
				view.setVisibility(View.GONE);
			}
		});
	}

	//'jn://{"method":"setViewShown:", "viewidx":"index_in_the_instance_views_array"}'
	public void setViewShown(JSONObject aDict) throws JSONException {
		final int viewIdx = aDict.getInt(ConstantsHfh.HFH_KEY_VIEWIDX);
		mHandlerBridge.post(new Runnable() {
			public void run() {
				View view = InstanceData.getInstanceData().getArrayViews().get(viewIdx);
				view.setVisibility(View.VISIBLE);
			}
		});
	}

	//'jn://{"method":"callRemoveFromSuperView:", "viewidx":"index_in_the_instance_views_array"}'
	public void callRemoveFromSuperView(JSONObject aDict) throws JSONException {
		final int viewIdx = aDict.getInt(ConstantsHfh.HFH_KEY_VIEWIDX);
		mHandlerBridge.post(new Runnable() {
			public void run() {
				View view = InstanceData.getInstanceData().getArrayViews().remove(viewIdx);
				mWeakLinearLayoutMain.get().removeView(view);
			}
		});
	}

	//'jn://{"method":"callReleaseView:", "viewidx":"index_in_the_instance_views_array"}'
	public void callReleaseView(JSONObject aDict) throws JSONException {
		int viewIdx = aDict.getInt(ConstantsHfh.HFH_KEY_VIEWIDX);
		InstanceData.getInstanceData().getArrayViews().remove(viewIdx);
		InstanceData.getInstanceData().getArrayPerformJavaScript().remove(viewIdx);
		callRemoveFromSuperView(aDict);
	}

	//'jn://{"method":"callRemoveView:", "viewidx":"index_in_the_instance_views_array"}'
	public void callRemoveView(JSONObject aDict) throws JSONException {
		int viewIdx = aDict.getInt(ConstantsHfh.HFH_KEY_VIEWIDX);
		InstanceData.getInstanceData().getArrayViews().remove(viewIdx);
		InstanceData.getInstanceData().getArrayPerformJavaScript().remove(viewIdx);
		callRemoveFromSuperView(aDict);
	}

	/* Disk storage */
	//'jn://{"method":"callGetPath:", "docsdir":"yes", "success":"callback_function_name"}'
	//callback should expect the path to be passed as a string argument
	//if key docsdir exists with some value the path to docsdir will be returned, if it does not exist, path temp dir will be returned.
	public void callGetPath(JSONObject aDict) {
		String fName = null;
		String path = null;
		try {
			fName = aDict.getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
			path = aDict.getString(ConstantsHfh.HFH_KEY_DOCSDIR);
			File filePath = Environment.getExternalStorageDirectory();
			callJsFunction(fName, filePath.getAbsolutePath());
		} catch (JSONException e) {
			if(path == null && fName != null) {
				File tempDir = mWeakCtx.get().getExternalCacheDir();
				callJsFunction(fName, tempDir.getAbsolutePath());
			}
			e.printStackTrace();
		}
	}

	//'jn://{"method":"callGetPathToDocsDir:", "success":"callback_function_name"}'
	//callback should expect the path to be passed as a string argument
	public void callGetPathToDocsDir(JSONObject aDict) throws JSONException {
		String fName = aDict.getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
		File filePath = Environment.getExternalStorageDirectory();
		callJsFunction(fName, filePath.getAbsolutePath());
	}

	//'jn://{"method":"callGetPathToTempDir:", "success":"callback_function_name"}'
	//callback should expect the path to be passed as a string argument
	public void callGetPathToTempDir(JSONObject aDict) throws JSONException {
		String fName = aDict.getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);		
		File tempDir = mWeakCtx.get().getExternalCacheDir();
		callJsFunction(fName, tempDir.getAbsolutePath());
	}

	/* File command buffer */
	//'jn://{"method":"callGetCommandBuffer:", "success":"callback_function_name"}'
	//callback should expect the path to command buffer file to be passed as argument
	public void callGetCommandBuffer(JSONObject aDict) throws JSONException {
		try {
			File buffFile = File.createTempFile(ConstantsHfh.HFH_BUFFER_FILENAME, "");
			String fName = aDict.getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
			callJsFunction(fName, buffFile.getAbsolutePath());
		} catch (IOException e) {
			callJsErrorCallback(aDict, "IOException");
			e.printStackTrace();
		}
	}

	//'jn://{"method":"callMethodWithCommandBuffer:", "hfh_bufferfile_path":"filepath_to_bufferfile", "error":"callback_function_name"}'
	//callback should expect error description to be passed as string argument
	public void callMethodWithCommandBuffer(JSONObject aDict) throws JSONException {
		try {
			String bufFilePath = aDict.getString(ConstantsHfh.HFH_KEY_BUFFER_FILEPATH);
			BufferedReader br = new BufferedReader(new FileReader(bufFilePath), 8192);
			String line = null;
			StringBuilder sb = new StringBuilder(500);
			while((line = br.readLine()) != null) {
				sb.append(line);
			}
			br.close();
			callNativeMethod(sb.toString());
		} catch (FileNotFoundException e) {
			callJsErrorCallback(aDict, "FileNotFoundException");
			e.printStackTrace();
		} catch (IOException e) {
			callJsErrorCallback(aDict, "IOException");
			e.printStackTrace();
		}
	}

	/* SQLite */
	//'jn://{"method":"callOpenOrCreateDb:", "path":"file_path_to_dbfile", "success":"callback_function_name", "error":"callback_function_name"}'
	public void callOpenOrCreateDb(JSONObject aDict) throws JSONException {
		String dbName = aDict.getString(ConstantsHfh.HFH_KEY_NAME);
		mDb = mWeakCtx.get().openOrCreateDatabase(dbName, Context.MODE_PRIVATE, null);
		if(mDb != null) {
			String fName = aDict.getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
			callJsFunction(fName, "");
		} else {
			String fName = aDict.getString(ConstantsHfh.HFH_KEY_ERROR_CALLBACK);
			callJsFunction(fName, "");
		}
	}

	//'jn://{"method":"callOpenOrCreateDbInDocsDir:", "name":"db_file_name", "success":"callback_function_name", "error":"callback_function_name"}'
	public void callOpenOrCreateDbInDocsDir(JSONObject aDict) throws JSONException {
		callOpenOrCreateDb(aDict);
	}

	//'jn://{"method":"callOpenOrCreateDbInTempDir:", "name":"db_file_name", "success":"callback_function_name", "error":"callback_function_name"}'
	public void callOpenOrCreateDbInTempDir(JSONObject aDict) throws JSONException {
		callOpenOrCreateDb(aDict);
	}

	//'jn://{"method":"callExecSQL:", "sql":"sqlite_statement", "success":"callback_function_name", "error":"callback_function_name"}'
	public void callExecSQL(JSONObject aDict) throws JSONException {
		try {
			String stmt = aDict.getString(ConstantsHfh.HFH_KEY_SQL);
			if(mDb == null) {
				String fName = aDict.getString(ConstantsHfh.HFH_KEY_ERROR_CALLBACK);
				String msg = LOG + "error - there is no database opened";
				callJsFunction(fName, msg);
				return;
			}
			mDb.execSQL(stmt);
			String fName = aDict.getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
			callJsFunction(fName, "");
		} catch (SQLiteException sqlEx) {
			callJsErrorCallback(aDict, "SQLiteException");
		}
	}

	//'jn://{"method":"callExecQuery:", "sql":"sqlite_query_statment", "success":"callback_function_name", "error":"callback_function_name"}'
	public void callExecQuery(JSONObject aDict) throws JSONException {
		String query = aDict.getString(ConstantsHfh.HFH_KEY_SQL);
		if(mDb == null) {
			String fName = aDict.getString(ConstantsHfh.HFH_KEY_ERROR_CALLBACK);
			String msg = LOG + "error - there is no database opened";
			callJsFunction(fName, msg);
			return;
		}
		mCursor = mDb.rawQuery(query, null);
		if(mCursor != null && mCursor.moveToFirst()) {
			getRowDataAsJsonString(mCursor, aDict);
		} else {
			callJsErrorCallback(aDict, "No rows");
		}
	}

	//'jn://{"method":"callMoveToNext:", "success":"callback_function_name", "error":"callback_function_name"}'
	public void callMoveToNext(JSONObject aDict) throws JSONException {
		if(mCursor.moveToNext()) {
			getRowDataAsJsonString(mCursor, aDict);
		} else {
			callJsErrorCallback(aDict, "No more rows");
		}
	}

	//'jn://{"method":"callCloseDb:", "success":"callback_function_name", "error":"callback_function_name"}'
	public void callCloseDb(JSONObject aDict) throws JSONException {
		mDb.close();
		String fName = aDict.getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
		callJsFunction(fName, "");
	}

	/* Camera use (pics, pics in photolibrary, video) */
	//'jn://{"method":"callCamera:"}'
	public void callCamera(JSONObject aDict) {
		mDictMethodInfo = aDict;
		Intent i = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
		mWeakActivity.get().startActivityForResult(i, ConstantsHfh.CAMERA_CODE);
	}
	
	public void onCameraPicture(String aPicturePath) {
		try {
			String fName = getMethodInfo().getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
			callJsFunction(fName, aPicturePath);
		} catch (JSONException e) {
			callJsErrorCallback(getMethodInfo(), "");
			e.printStackTrace();
		}
	}

	//'jn://{"method":"callPhotoLibrary:", "success":"callback_function_name"}'
	public void callPhotoLibrary(JSONObject aDict) throws JSONException {
		File dirPics = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES);
		String strPath = dirPics.getAbsolutePath();
		String fName = aDict.getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
		callJsFunction(fName, strPath);
	}

	/* Motion Sensor */
	//'jn://{"method":"callStartMonitorDeviceOrientation:", "success":"callback_function_name"}'
	public void callStartMonitorDeviceOrientation(JSONObject aDict) throws JSONException {
		Display disp = mWeakActivity.get().getWindowManager().getDefaultDisplay();
		String orientation = ConstantsHfh.ORIENTATION_UNKNOWN;
		switch(disp.getRotation()) {
            case Surface.ROTATION_0:
                orientation = ConstantsHfh.ORIENTATION_PORTRAIT;
            	break;
            case Surface.ROTATION_90:
                orientation = ConstantsHfh.ORIENTATION_LANDSCAPE;
            	break;
            case Surface.ROTATION_180:
                orientation = ConstantsHfh.ORIENTATION_PORTRAIT_UPSIDEDOWN;
            	break;
            case Surface.ROTATION_270:
            	orientation = ConstantsHfh.ORIENTATION_LANDSCAPE_UPSIDEDOWN;
            	break;
		}
		String fName = aDict.getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
		callJsFunction(fName, orientation);
	}

	//'jn://{"method":"callStopMonitorDeviceOrientation:"}'
	public void callStopMonitorDeviceOrientation(JSONObject aDict) throws JSONException {
		//do nothing
		String fName = aDict.getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
		callJsFunction(fName, "");
	}

	/* Contacts */
	//'jn://{"method":"callShowContacts:", "success":"callback_function_name"}'
	public void callShowContacts(JSONObject aDict) {
		mDictMethodInfo = aDict;
		Uri myUri = android.provider.ContactsContract.Contacts.CONTENT_URI;
		//Intent i = new Intent(Intent.ACTION_PICK, Uri.parse("content://contacts/people"));
		Intent i = new Intent(Intent.ACTION_PICK, myUri);
		mWeakActivity.get().startActivityForResult(i, ConstantsHfh.CONTACTS_CODE);
	}
	
	public void onContactSelected(ArrayList<String> aPhones) {
		try {
			String fName = getMethodInfo().getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
			callJsFunction(fName, aPhones);
		} catch (JSONException e) {
			callJsErrorCallback(getMethodInfo(), "");
			e.printStackTrace();
		}
	}

	/* Util methods */
	public String buildJsFunction(String aFunctionName, ArrayList<String> aArrayArgs) {
		StringBuilder sb = new StringBuilder(aFunctionName.length() + (aArrayArgs.size() * 10));
		sb.append(aFunctionName);
		sb.append("([");
		int arrayCount = aArrayArgs.size();
		int arrayCountForLoop = aArrayArgs.size();
		for(int x = 0; x < arrayCountForLoop; x++) {
			sb.append("'");
			sb.append(aArrayArgs.get(x));
			sb.append("'");
			arrayCount--;
			if(arrayCount > 0) {
				sb.append(", ");
			} else {
				sb.append("])");
			}
		}
		return sb.toString();
	}

	private void getRowDataAsJsonString(Cursor aCursor, JSONObject aDict) throws JSONException {
		JSONObject json = new JSONObject();
		int cols = aCursor.getColumnCount();
		for(int x = 0; x < cols; x++) {
			String colName = aCursor.getColumnName(x);
			String colVal = aCursor.getString(x);
			json.put(colName, colVal);
		}
		String fName = aDict.getString(ConstantsHfh.HFH_KEY_SUCCESS_CALLBACK);
		callJsFunction(fName, json.toString());
		
	}

	/* Additional Methods */
	public void callLoadHome(JSONObject aDict) {
		mHandlerBridge.post(new Runnable() {
			@Override
			public void run() {
				mWeakWebView.get().loadUrl(ConstantsHfh.JAVASCRIPT + "window.document.location = 'index.html'");
			}
		});
	}

	/* BridgeListener Interface */
	@Override
	public void callJsFunction(final String aFunctionAndArgs) {
		mHandlerBridge.post(new Runnable() {
			public void run() {
				Log.i(LOG, "callJsFunction, aFunctionAndArgs=" + aFunctionAndArgs);
				mWeakWebView.get().loadUrl(ConstantsHfh.JAVASCRIPT + aFunctionAndArgs);
			}
		});
	}
	
	@Override
	public void callJsFunction(String aFunctionName, String aArg) {
		if(aArg == null) {aArg = "";}
		StringBuilder sb = new StringBuilder(aFunctionName.length() + aArg.length() + 10);
		sb.append(aFunctionName);
		sb.append("('");
		sb.append(aArg);
		sb.append("')");
		callJsFunction(sb.toString());
	}

	@Override
	public void callJsFunction(String aFunctionName, ArrayList<String> aArgs) {
		StringBuilder sb = new StringBuilder(aFunctionName.length() + (aArgs.size() * 10));
		sb.append(aFunctionName);
		sb.append("([");
		int arrayCount = aArgs.size();
		int arrayCountForLoop = aArgs.size();
		for(int x = 0; x < arrayCountForLoop; x++) {
			sb.append("'");
			sb.append(aArgs.get(x));
			sb.append("'");
			arrayCount--;
			if(arrayCount > 0) {
				sb.append(", ");
			} else {
				sb.append("])");
			}
		}
		callJsFunction(sb.toString());
	}
}
