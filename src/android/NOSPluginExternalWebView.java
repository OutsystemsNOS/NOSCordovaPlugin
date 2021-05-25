package pt.nos.cordova.plugin;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.PorterDuff;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebStorage;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import static pt.nos.cordova.plugin.NOSCordovaPlugin.NOSPluginRequestCode;


public class NOSPluginExternalWebView extends Activity {

    private WebView webView;
    private ImageButton buttonRefresh, buttonBack, buttonForward, buttonClose, buttonToolbarRefresh;
    private ProgressBar progressBar;
    private int backgroundColor;
    private String mainColor;

    public static final String APP_SCHEME = "selfcare://";

    private String callbackSuccess = "";

    private NOSCordovaPlugin.RequestType requestType = NOSCordovaPlugin.RequestType.OTHER;

    private boolean showBottomBar = true;

    public static final String FERA_APP_SCHEME = "fera://";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        try {
            super.onCreate(savedInstanceState);
            String package_name = getApplication().getPackageName();
            setContentView(getApplication().getResources().getIdentifier("layout_activity_external_webview", "layout", package_name));
            Intent intent = getIntent();
            String url = intent.getStringExtra("url");
            boolean clearCache = intent.getBooleanExtra("clearCache",false);

            showBottomBar = intent.getBooleanExtra("showBottomBar",true);

            String buttonsAlignment = intent.getStringExtra("buttonsAlignment");

            LinearLayout linearLayoutToBarButtons = (LinearLayout) findViewById(getResources().getIdentifier("linearLayoutToBarButtons", "id", getPackageName()));
            buttonToolbarRefresh = (ImageButton)findViewById(getResources().getIdentifier("iv_toolbar_refresh", "id", getPackageName()));

            if(buttonsAlignment == null || buttonsAlignment.equals("") || buttonsAlignment.equals("left")){
                buttonToolbarRefresh.setVisibility(View.GONE);
            }

            if(buttonsAlignment != null && buttonsAlignment.equals("right")){
                RelativeLayout.LayoutParams params = (RelativeLayout.LayoutParams)linearLayoutToBarButtons.getLayoutParams();
                params.addRule(RelativeLayout.ALIGN_PARENT_RIGHT);

                linearLayoutToBarButtons.setLayoutParams(params);
            }

            String title = intent.getStringExtra("title");
            callbackSuccess = intent.getStringExtra("callbackSuccess");

            if(callbackSuccess == null)
                callbackSuccess = "";

            try {

                if(intent.hasExtra("color")) {
                    mainColor = intent.getStringExtra("color");
                    if (mainColor != null && !mainColor.equals("")) {
                        backgroundColor = Color.parseColor(mainColor);
                    } else {
                        backgroundColor = Color.parseColor("#6EA514");
                    }
                }else{
                    backgroundColor = Color.parseColor("#6EA514");
                }
            }catch (Exception e){
                e.printStackTrace();
                backgroundColor = Color.parseColor("#6EA514");

            }


            LinearLayout relativeLayoutBottomBar = (LinearLayout) findViewById(getResources().getIdentifier("ll_bottom", "id", getPackageName()));
            if(!showBottomBar)
                relativeLayoutBottomBar.setVisibility(View.GONE);

            RelativeLayout relativeLayoutMain = (RelativeLayout) findViewById(getResources().getIdentifier("ll_top", "id", getPackageName()));
            relativeLayoutMain.setBackgroundColor(backgroundColor);

            webView = findViewById(getResources().getIdentifier("webViewMain", "id", getPackageName()));

            try {
                boolean forceResetWebview = intent.getBooleanExtra("forceResetWebview",false);
                if(forceResetWebview){
                    webView.clearCache(true);
                    webView.clearHistory();
                    webView.clearFormData();

                    CookieManager cookieManager = CookieManager.getInstance();
                    cookieManager.removeAllCookie();
                    cookieManager.removeSessionCookie();

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                        cookieManager.flush();
                    }

                    WebStorage.getInstance().deleteAllData();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            WebSettings settings = webView.getSettings();

            HashMap<String, String> hashMap = (HashMap<String, String>)intent.getSerializableExtra("hashMapHeaders");
            //Iterator it = hashMap.entrySet().iterator();
            for(Map.Entry<String, String> entry : hashMap.entrySet()) {

                //Map.Entry pair = (Map.Entry)it.next();
                //System.out.println(pair.getKey() + " = " + pair.getValue());

                if(((String)entry.getKey()).contains("UserAgent")){
                    webView.getSettings().setUserAgentString((String)entry.getValue());
                }
            }


            String headers = intent.getStringExtra("headersText");

        /*
        new AlertDialog.Builder(ActivityExternalWebView.this)
                .setTitle("Headers debug")
                .setMessage(headers)

                // Specifying a listener allows you to take an action before dismissing the dialog.
                // The dialog is automatically dismissed when a dialog button is clicked.
                .setPositiveButton(android.R.string.yes, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        // Continue with delete operation
                    }
                })

                // A null listener allows the button to dismiss the dialog and take no further action.
                .show();
        */

            settings.setJavaScriptEnabled(true);
            settings.setDomStorageEnabled(true);


            if(mainColor != null) {
                hashMap.put("X-NOS-Color", mainColor);
            }


            if(getIntent().hasExtra("requestType")){

                String requestTypeStr = getIntent().getStringExtra("requestType");

                if(requestTypeStr != null && requestTypeStr.equals("login"))
                    requestType = NOSCordovaPlugin.RequestType.LOGIN;
                else if(requestTypeStr != null && requestTypeStr.equals("logout"))
                    requestType = NOSCordovaPlugin.RequestType.LOGOUT;
            }

            if(clearCache
                    || getIntent().getBooleanExtra("logout", false)
                    ){


                webView.clearCache(true);
                webView.clearHistory();
                webView.clearFormData();
                CookieSyncManager.createInstance(this);
                CookieManager cookieManager = CookieManager.getInstance();
                cookieManager.removeAllCookie();

            }else {



            }

            webView.setWebViewClient(webViewClient);
            if(hashMap != null && hashMap.size() > 0)
                webView.loadUrl(url, hashMap);
            else
                webView.loadUrl(url);


            ActionBar actionBar = getActionBar();
            if(actionBar != null) actionBar.hide();


            TextView textViewTitle = (TextView) findViewById(getResources().getIdentifier("txt_title", "id", getPackageName()));
            if(title == null || title.equals("")){
                textViewTitle.setText("");
            }else {
                textViewTitle.setText(title);
            }


            Typeface face=Typeface.createFromAsset(getAssets(), "AzoSansWeb-Medium.ttf");
            textViewTitle.setTypeface(face);

            buttonBack = (ImageButton)findViewById(getResources().getIdentifier("iv_left", "id", getPackageName()));
            buttonBack.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if(webView.canGoBack())
                        webView.goBack();
                }
            });

            buttonForward = (ImageButton)findViewById(getResources().getIdentifier("iv_right", "id", getPackageName()));
            buttonForward.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if(webView.canGoForward())
                        webView.goForward();
                }
            });


            buttonRefresh = (ImageButton)findViewById(getResources().getIdentifier("iv_refresh", "id", getPackageName()));
            buttonRefresh.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    webView.reload();
                }
            });

            refreshButtonsState();


            buttonClose = (ImageButton)findViewById(getResources().getIdentifier("iv_toolbar_close", "id", getPackageName()));
            buttonClose.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    try {
                        String url = webView.getUrl();
                        if(url != null && !url.equals("")){

                            if(url.endsWith(callbackSuccess)){
                                Intent intent = new Intent();
                                intent.putExtra("action", "0");
                                setResult(0, intent); //OK
                            }else{
                                Intent intent = new Intent();
                                intent.putExtra("statuscode",  "0");
                                setResult(-1, intent);
                                finish();
                            }

                        }
                        finish();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });


            buttonToolbarRefresh.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    try {
                        webView.reload();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            });

            progressBar = (ProgressBar) findViewById(getResources().getIdentifier("progressBarMain", "id", getPackageName()));
            progressBar.getIndeterminateDrawable().setColorFilter(backgroundColor, PorterDuff.Mode.SRC_IN);
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    private void refreshButtonsState() {

        try {
            buttonForward.setEnabled(webView.canGoForward());
            buttonBack.setEnabled(webView.canGoBack());
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    WebViewClient webViewClient = new WebViewClient(){
        @Override
        public void onPageFinished(WebView view, String url) {
            try {
                super.onPageFinished(view, url);
                progressBar.setVisibility(View.INVISIBLE);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }


        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            try {
                super.onPageStarted(view, url, favicon);
                refreshButtonsState();
                progressBar.setVisibility(View.VISIBLE);
            } catch (Exception e) {
                e.printStackTrace();
            }

        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            try {
                boolean result = super.shouldOverrideUrlLoading(view, url);
                if(url.startsWith(APP_SCHEME + "success")){

                    Intent intent = new Intent();
                    intent.putExtra("action", "0");
                    setResult(0, intent); //OK
                    finish();

                }else if(url.startsWith(APP_SCHEME + "error")){

                    Intent intent = new Intent();
                    intent.putExtra("action", "0");
                    setResult(-1, intent);
                    finish();


                }else if(url.startsWith(APP_SCHEME + "webview_response")){

                    Uri uri = Uri.parse(url);
                    String statuscode = uri.getQueryParameter("statuscode");
                    if(statuscode!=null) {

                        int statusCode = Integer.parseInt(statuscode);

                        if(statusCode >= 400) {
                            Intent intent = new Intent();
                            intent.putExtra("statuscode", statusCode + "");
                            setResult(-1, intent);
                            finish();
                        }
                    }

                }

                if(url.startsWith(FERA_APP_SCHEME + "openurl")){

                    try {
                        Uri uri = Uri.parse(url);
                        String urlOpenInBrownserString = uri.getQueryParameter("url");
                        if(urlOpenInBrownserString!=null) {
                            Intent defaultBrowser = Intent.makeMainSelectorActivity(Intent.ACTION_MAIN, Intent.CATEGORY_APP_BROWSER);
                            defaultBrowser.setData(Uri.parse(urlOpenInBrownserString));
                            startActivity(defaultBrowser);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    return true;

                }

                /*
                if(url.startsWith("fera://logout_success")){

                    Intent intent = new Intent();
                    intent.putExtra("action", "0");
                    setResult(0, intent); //OK
                    finish();

                }*/

                if(NOSCordovaPlugin.SCHEME != null && !NOSCordovaPlugin.SCHEME.equals("") && url.startsWith(NOSCordovaPlugin.SCHEME)){

                    try {
                        if(requestType == NOSCordovaPlugin.RequestType.LOGOUT){
                            webView.clearCache(true);
                            webView.clearHistory();
                            webView.clearFormData();
                            CookieSyncManager.createInstance(NOSPluginExternalWebView.this);
                            CookieManager cookieManager = CookieManager.getInstance();
                            cookieManager.removeAllCookie();
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }


                    Uri uri = Uri.parse(url);
                    String protocol = uri.getScheme();
                    String server = uri.getAuthority();
                    String path = uri.getPath();
                    Set<String> args = uri.getQueryParameterNames();




                    String joined = "";

                    for(String i : args)
                        joined += i + " - " + uri.getQueryParameter(i) + "\n";

                    //Toast.makeText(NOSPluginExternalWebView.this, joined, Toast.LENGTH_SHORT).show();


                    Intent intentResult = new Intent();
                    intentResult.putExtra("url", url);
                    setResult(0, intentResult);

                    finish();

                    return true;
                }


                return result;
            } catch (Exception e) {
                e.printStackTrace();
            }
            return false;
        }



        @Override
        public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
            super.onReceivedError(view, request, error);
        }

        @Override
        public void onReceivedHttpError(WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {
            try {
                super.onReceivedHttpError(view, request, errorResponse);

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    if (errorResponse.getStatusCode() == 401){
                        Intent intent = new Intent();
                        intent.putExtra("action", "0");
                        setResult(-1, intent);
                        finish();
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        @Override
        public void onReceivedError(WebView view, int errorCode, String description, String failingUrl) {
            try {
                if (errorCode == 401){
                    Intent intent = new Intent();
                    intent.putExtra("action", "0");
                    setResult(-1, intent);
                    finish();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    };

    @Override
    public void onBackPressed() {
        try {
            Intent intent = new Intent();
            intent.putExtra("action", "0");
            setResult(Activity.RESULT_OK, intent);
            finish();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    public static Map<String, String> getQueryMap(String query)
    {
        String[] params = query.split("&");
        Map<String, String> map = new HashMap<String, String>();
        for (String param : params)
        {
            String name = param.split("=")[0];
            String value = param.split("=")[1];
            map.put(name, value);
        }
        return map;
    }
}
