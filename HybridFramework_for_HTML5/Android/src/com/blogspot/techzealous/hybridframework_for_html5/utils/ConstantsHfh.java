package com.blogspot.techzealous.hybridframework_for_html5.utils;

public class ConstantsHfh extends Object {

	/** This Class is not to be instantiated */
	private ConstantsHfh() {
		super();
	}
	
	public static final String PAGE_HOME = "file:///android_asset/wwwroot/index.html";
	public static final String JAVASCRIPT = "javascript:";
	public static final int CONTACTS_CODE = 1;
	public static final int CAMERA_CODE = 2;
	public static final String ORIENTATION_LANDSCAPE = "4";
	public static final String ORIENTATION_LANDSCAPE_UPSIDEDOWN = "3";
	public static final String ORIENTATION_PORTRAIT = "1";
	public static final String ORIENTATION_PORTRAIT_UPSIDEDOWN = "2";
	public static final String ORIENTATION_UNKNOWN = "0";
	
	/** HFH URI Schema prefix (jn - JavaScript to Native */
	public static final String HFH_SCHEMA_PREFIX = "jn://";

	/* HFH call keys in the JSON object passed as payload to the HFH URI Schema */
	/* Key with Objective C method name that is called */
	public static final String HFH_KEY_METHODNAME = "method";

	/* Key with name of the JavaScript function which will be called on success */
	public static final String HFH_KEY_SUCCESS_CALLBACK = "success";

	/* Key with name of the JavaScript function which will be called on error */
	public static final String HFH_KEY_ERROR_CALLBACK = "error";

	/* Key with x position (int) */
	public static final String HFH_KEY_POSX = "x";

	/* Key with y position (int) */
	public static final String HFH_KEY_POSY = "y";

	/* Key with width size (int)*/
	public static final String HFH_KEY_WIDTH = "width";

	/* Key with height size (int) */
	public static final String HFH_KEY_HEIGHT = "height";

	/* Key with view index (int). Index in the Array of views created by JavaScript. */
	public static final String HFH_KEY_VIEWIDX = "viewidx";

	/* Key with button type (int).
	 * One of:
	 * ButtonTypeCustom = 0
	 * ButtonTypeSystem = 1
	 * ButtonTypeDetailDisclosure = 2
	 * ButtonTypeInfoLight = 3
	 * ButtonTypeInfoDark = 4
	 * ButtonTypeContactAdd = 5
	 * ButtonTypeRoundedRect = 6
	 */
	public static final String HFH_KEY_BUTTONTYPE = "buttontype";

	/* Key with value for red color (int) */
	public static final String HFH_KEY_RED = "red";

	/* Key with value for green color (int) */
	public static final String HFH_KEY_GREEN = "green";

	/* Key with value for blue color (int) */
	public static final String HFH_KEY_BLUE = "blue";

	/* Key with value for alpha (int) */
	public static final String HFH_KEY_ALPHA = "alpha";

	/* Key with file path to an image */
	public static final String HFH_KEY_IMAGE = "img";

	/* Key with name of JavaScript function which will be used as callback onclick of native view */
	public static final String HFH_KEY_ONCLICK = "onclick";

	/* Key with name for title/lable of a view */
	public static final String HFH_KEY_TITLE = "title";

	/* Key with name of instance variable */
	public static final String HFH_KEY_NAME = "name";

	/* Key with value of instance variable */
	public static final String HFH_KEY_VALUE = "value";

	/* Key with file path */
	public static final String HFH_KEY_PATH = "path";

	/* Key with file path to docsdir */
	public static final String HFH_KEY_DOCSDIR = "docsdir";

	/* Key with file path to tempdir */
	public static final String HFH_KEY_TEMPDIR = "tempdir";

	/* Key with SQLite statement */
	public static final String HFH_KEY_SQL = "sql";

	/* Key with file path to HFH Command buffer file */
	public static final String HFH_KEY_BUFFER_FILEPATH = "hfh_bufferfile_path";

	/* Name of the HFH Command buffer file name */
	public static final String HFH_BUFFER_FILENAME = "hfh_buffer_name";

}
