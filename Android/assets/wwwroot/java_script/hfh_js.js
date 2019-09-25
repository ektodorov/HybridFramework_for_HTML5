/** HFH URI Schema prefix (jn - JavaScript to Native */
var HFH_SCHEMA = "jn://";

/* Key with Objective C method name that is called */
var KEY_METHODNAME = "method";

/* Key with name of the JavaScript function which will be called on success */
var KEY_SUCCESS_CALLBACK = "success";

/* Key with name of the JavaScript function which will be called on error */
var KEY_ERROR_CALLBACK = "error";

/* Key with x position (int) */
var KEY_POSX = "x";

/* Key with y position (int) */
var KEY_POSY = "y";

/* Key with width size (int)*/
var KEY_WIDTH = "width";

/* Key with height size (int) */
var KEY_HEIGHT = "height";

/* Key with view index (int). Index in the Array of views created by JavaScript. */
var KEY_VIEWIDX = "viewidx";

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
var KEY_BUTTONTYPE = "buttontype";

/* Key with value for red color (int) */
var KEY_RED = "red";

/* Key with value for green color (int) */
var KEY_GREEN = "green";

/* Key with value for blue color (int) */
var KEY_BLUE = "blue";

/* Key with value for alpha (int) */
var KEY_ALPHA = "alpha";

/* Key with file path to an image */
var KEY_IMAGE = "img";

/* Key with name of JavaScript function which will be used as callback onclick of native view */
var KEY_ONCLICK = "onclick";

/* Key with name for title/lable of a view */
var KEY_TITLE = "title";

/* Key with name of instance variable */
var KEY_NAME = "name";

/* Key with value of instance variable */
var KEY_VALUE = "value";

/* Key with file path */
var KEY_PATH = "path";

/* Key with file path to docsdir */
var KEY_DOCSDIR = "docsdir";

/* Key with file path to tempdir */
var KEY_TEMPDIR = "tempdir";

/* Key with SQLite statement */
var KEY_SQL = "sql";

/* Key with file path to HFH Command buffer file */
var KEY_BUFFER_FILEPATH = "hfh_bufferfile_path";

function loadHome() {window.document.location = "index.html";}
