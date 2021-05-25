package pt.nos.cordova.plugin;

import android.app.Activity;
import android.app.FragmentManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Color;
import android.net.Uri;
import android.support.customtabs.CustomTabsIntent;
import android.support.customtabs.CustomTabsSession;
import android.util.Log;
import android.widget.Toast;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Set;

import pt.nos.cordova.plugin.helpers.CustomTabServiceHelper;

import static android.support.customtabs.CustomTabsService.ACTION_CUSTOM_TABS_CONNECTION;

/**
 * This class echoes a string called from JavaScript.
 */

interface NOSCordovaPluginInterface {
    public void logout(boolean routerLogout);
}

public class NOSCordovaPlugin extends CordovaPlugin implements NOSCordovaPluginInterface {
    
    public static final int NOSPluginRequestCode = 50;
    
    private CallbackContext callbackContext = null;
    private CustomTabServiceHelper mCustomTabPluginHelper;

    public static final int CUSTOM_TAB_REQUEST_CODE = 1;
    public static final int INTERNAL_WEBVIEW_CODE = 20;


    private String packageName = null;


    private boolean isLogEnable = false;

    public static String SCHEME = "";


    enum RequestType {
        LOGIN("login"),
        LOGOUT("logout"),
        OTHER("other");

        public final String label;

        private RequestType(String label) {
            this.label = label;
        }
    }


    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        try{
            this.callbackContext = callbackContext;

            this.packageName = null;


            if(true){
                //showTest();
                //return false;
            }
            /*
            this.showExternalWebView(true, "https://google.com", "", "", null, "", callbackContext);


            if(true)
                return true;
            */
            boolean showBottomBar = true;
            if (action.equals("showExternalWebViewLogout") && args != null) {

                String url = "", title = "", headers = "", color = "", callbackSuccess = "", buttonsAlignment = "";
                int timeoutInSeconds = 10;
                boolean logging = false;

                for (int index = 0; index < args.length(); index++) {
                    switch (index){
                        case 0:
                            logging = args.getBoolean(index); break;
                        case 1:
                            url = args.getString(index); break;
                        case 2:
                            title = args.getString(index); break;
                        case 3:
                            headers = args.getString(index); break;
                        case 4:
                            color = args.getString(index); break;
                        case 5:
                            callbackSuccess = args.getString(index); break;
                        case 6:
                            showBottomBar = args.getBoolean(index); break;
                        case 7:
                            buttonsAlignment = args.getString(index); break;
                        case 8:
                            timeoutInSeconds = args.getInt(index); break;
                        default:
                            break;
                    }
                }
                //this.showExternalWebViewLogout(logging, url, title, headers, color, callbackSuccess, callbackContext, NOSPluginRequestCode, false, RequestType.OTHER.label, showBottomBar, buttonsAlignment);
                FragmentManager fm =   this.cordova.getActivity().getFragmentManager();

                NOSPluginExternalWebViewLogout alertDialog = NOSPluginExternalWebViewLogout.newInstance("Some title", url, callbackSuccess, NOSCordovaPlugin.this, timeoutInSeconds);
                alertDialog.show(fm, "fragment_alert");

                return true;
            }



            if (action.equals("showExternalWebView") && args != null) {

                String url = "", title = "", headers = "", color = "", callbackSuccess = "", buttonsAlignment = "";

                boolean logging = false;
                boolean forceResetWebview = false;
                for (int index = 0; index < args.length(); index++) {
                    switch (index){
                        case 0:
                            logging = args.getBoolean(index); break;
                        case 1:
                            url = args.getString(index); break;
                        case 2:
                            title = args.getString(index); break;
                        case 3:
                            headers = args.getString(index); break;
                        case 4:
                            color = args.getString(index); break;
                        case 5:
                            callbackSuccess = args.getString(index); break;
                        case 6:
                            showBottomBar = args.getBoolean(index); break;
                        case 7:
                            buttonsAlignment = args.getString(index); break;
                        case 8:
                            forceResetWebview = args.getBoolean(index); break;
                        default:
                            break;
                    }
                }
                this.showExternalWebView(logging, url, title, headers, color, callbackSuccess, callbackContext, NOSPluginRequestCode, false, RequestType.OTHER.label, showBottomBar, buttonsAlignment, forceResetWebview);
                return true;
            }else if((action.equals("showInternalBrowser") || action.equals("logout")) && args != null) {

                String url = "", title = "", headers = "", color = "", callbackSuccess = "", requestTypeStr = "", buttonsAlignment = "";
                boolean logging = false;
                boolean forceLogin = false;

                for (int index = 0; index < args.length(); index++) {
                    switch (index){
                        case 0:
                            logging = args.getBoolean(index); break;
                        case 1:
                            url = args.getString(index); break;
                        case 2:
                            title = args.getString(index); break;
                        case 3:
                            headers = args.getString(index); break;
                        case 4:
                            color = args.getString(index); break;
                        case 5:
                            callbackSuccess = args.getString(index); break;
                        case 6:
                            forceLogin = args.getBoolean(index); break;
                        case 7:
                            requestTypeStr = args.getString(index); break;
                        case 8:
                            SCHEME = args.getString(index); break;
                        case 9:
                            showBottomBar = args.getBoolean(index); break;
                        case 10:
                            buttonsAlignment = args.getString(index); break;
                        default:
                            break;
                    }
                }

                RequestType requestType = RequestType.OTHER;
                if(requestTypeStr != null && requestTypeStr.equals("login"))
                    requestType = RequestType.LOGIN;
                else if(requestTypeStr != null && requestTypeStr.equals("logout"))
                    requestType = RequestType.LOGOUT;


                packageName = getPackageNameToUse(this.cordova.getActivity());


                if (packageName != null && packageName.contains("chrome")) {

                    mCustomTabPluginHelper = new CustomTabServiceHelper(this.cordova.getActivity());

                    CustomTabsIntent.Builder builder = new CustomTabsIntent.Builder(getSession());

                    if(color != null && !color.equals(""))
                        builder.setToolbarColor(Color.parseColor(color));


                        //TODO if(showDefaultShareMenuItem)
                    //builder.addDefaultShareMenuItem();
                    //if(!TextUtils.isEmpty(transition))
                    //  addTransition(builder, transition);

                    builder.setShowTitle(true);
                    //builder.enableUrlBarHiding();


                    CustomTabsIntent customTabsIntent = builder.build();

                    showDebugToast("Open - " + packageName);

                    callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, ""));

                    customTabsIntent.intent.setPackage(packageName);
                    startCustomTabActivity(this.cordova.getActivity(), url, customTabsIntent.intent);

                }else{
                    showDebugToast("Open - INTERNAL WEBVIEW");
                    /*
                    Intent intent = new Intent(this.cordova.getActivity(), NOSPluginInternalLogin.class);
                    intent.putExtra("url" , url);
                    this.cordova.startActivityForResult((CordovaPlugin) this, intent, INTERNAL_WEBVIEW_CODE);
                    */

                    packageName = "Internal WebView";

                    this.showExternalWebView(logging, url, title, headers, color, callbackSuccess, callbackContext, INTERNAL_WEBVIEW_CODE, forceLogin, requestTypeStr, showBottomBar, buttonsAlignment, false);
                    return true;
                }

            }
            
        }catch (Exception e){
            e.printStackTrace();
        }
        return false;
    }


    /*
    private void showTest() {
        callbackContext.success();

        this.cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                webView.loadUrl("javascript:onLoginSuccess('" + "TESTE JS" + "', '" + "" +  "');"); //TODO

            }
        });

    }
    */

    private void startCustomTabActivity(Activity activity, String url, Intent intent) {
        intent.setData(Uri.parse(url));
        activity.startActivityForResult(intent, CUSTOM_TAB_REQUEST_CODE);
    }
    
    private void showExternalWebView(boolean logging, String url, String title, String headers, String color, String callbackSuccess, CallbackContext callbackContext, int requestCode, boolean clearCache, String requestType, boolean showBottomBar, String buttonsAlignment, boolean forceResetWebview) {


        try {
            Context context = this.cordova.getActivity();
            Intent intent=new Intent(context, NOSPluginExternalWebView.class);
            intent.putExtra("url", url);
            intent.putExtra("title", title);
            intent.putExtra("color", color);
            intent.putExtra("headersText", headers);
            intent.putExtra("logging", logging);
            intent.putExtra("callbackSuccess", callbackSuccess);
            intent.putExtra("clearCache", clearCache);
            intent.putExtra("requestType", requestType);
            intent.putExtra("showBottomBar", showBottomBar);
            intent.putExtra("buttonsAlignment", buttonsAlignment);
            intent.putExtra("forceResetWebview", forceResetWebview);


            HashMap<String, String> hashMapHeaders = new HashMap<String, String>();
            if(headers != null){

                String[] headersArray = ((String) headers).split("!!!");

                for (int i = 0; i < headersArray.length; i++) {
                    //try {

                        Object header =  headersArray[i];
                        if(header instanceof String) {
                            String[] split = ((String) header).split(";");
                            if(split.length > 1)
                                hashMapHeaders.put(split[0], split[1]);
                        }

                    //} catch (JSONException e) {
                    //    e.printStackTrace();
                    //}
                }

            }

            intent.putExtra("hashMapHeaders", hashMapHeaders);


            this.cordova.startActivityForResult((CordovaPlugin) this, intent, requestCode);
            return;
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        
        
        /*
         if (message != null && message.length() > 0) {
         callbackContext.success(message);
         } else {
         callbackContext.error("Expected one non-empty string argument.");
         }*/
    }

    private void showExternalWebViewLogout(boolean logging, String url, String title, String headers, String color, String callbackSuccess, CallbackContext callbackContext, int requestCode, boolean clearCache, String requestType, boolean showBottomBar, String buttonsAlignment) {


        try {
            Context context = this.cordova.getActivity();
            Intent intent=new Intent(context, NOSPluginExternalWebViewLogout.class);
            intent.putExtra("url", url);
            intent.putExtra("title", title);
            intent.putExtra("color", color);
            intent.putExtra("headersText", headers);
            intent.putExtra("logging", logging);
            intent.putExtra("callbackSuccess", callbackSuccess);
            intent.putExtra("clearCache", clearCache);
            intent.putExtra("requestType", requestType);
            intent.putExtra("showBottomBar", showBottomBar);
            intent.putExtra("buttonsAlignment", buttonsAlignment);


            HashMap<String, String> hashMapHeaders = new HashMap<String, String>();
            if(headers != null){

                String[] headersArray = ((String) headers).split("!!!");

                for (int i = 0; i < headersArray.length; i++) {
                    //try {

                    Object header =  headersArray[i];
                    if(header instanceof String) {
                        String[] split = ((String) header).split(";");
                        if(split.length > 1)
                            hashMapHeaders.put(split[0], split[1]);
                    }

                    //} catch (JSONException e) {
                    //    e.printStackTrace();
                    //}
                }

            }

            intent.putExtra("hashMapHeaders", hashMapHeaders);


            this.cordova.startActivityForResult((CordovaPlugin) this, intent, requestCode);
            return;
        } catch (Exception e) {
            e.printStackTrace();
        }



        /*
         if (message != null && message.length() > 0) {
         callbackContext.success(message);
         } else {
         callbackContext.error("Expected one non-empty string argument.");
         }*/
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        try {
            super.onActivityResult(requestCode, resultCode, intent);

            String statusCode = "";
            if(intent != null && intent.hasExtra("statuscode"))
                statusCode = intent.getStringExtra("statuscode");


            if(requestCode == NOSPluginRequestCode){

                if(resultCode == 0){
                    callbackContext.success();
                }else if(resultCode == -1){
                    callbackContext.error(statusCode);
                }

            }else if(requestCode == INTERNAL_WEBVIEW_CODE){

                if(resultCode == 0){
                    callbackContext.success();
                    if(intent != null && intent.hasExtra("url")) {
                        String url =intent.getStringExtra("url");


                        callJavaScripLoginSuccess(url, packageName);
                    }

                }else if(resultCode == -1){
                    callbackContext.error(statusCode);
                }

            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }


    /*  Internal Browser  */


    private CustomTabsSession getSession() {
        return mCustomTabPluginHelper.getSession();
    }

    private static String sPackageNameToUse;
    static final String STABLE_PACKAGE = "com.android.chrome";
    static final String BETA_PACKAGE = "com.chrome.beta";
    static final String DEV_PACKAGE = "com.chrome.dev";
    static final String LOCAL_PACKAGE = "com.google.android.apps.chrome";

    public static String getPackageNameToUse(Context context) {
        try {
            if (sPackageNameToUse != null) return sPackageNameToUse;

            PackageManager pm = context.getPackageManager();
            // Get default VIEW intent handler.
            Intent activityIntent = new Intent(Intent.ACTION_VIEW, Uri.parse("http://www.example.com"));
            ResolveInfo defaultViewHandlerInfo = pm.resolveActivity(activityIntent, 0);
            String defaultViewHandlerPackageName = null;
            if (defaultViewHandlerInfo != null) {
                defaultViewHandlerPackageName = defaultViewHandlerInfo.activityInfo.packageName;
            }

            // Get all apps that can handle VIEW intents.
            List<ResolveInfo> resolvedActivityList = pm.queryIntentActivities(activityIntent, 0);
            List<String> packagesSupportingCustomTabs = new ArrayList<>();
            for (ResolveInfo info : resolvedActivityList) {
                Intent serviceIntent = new Intent();
                serviceIntent.setAction(ACTION_CUSTOM_TABS_CONNECTION);
                serviceIntent.setPackage(info.activityInfo.packageName);
                if (pm.resolveService(serviceIntent, 0) != null) {
                    packagesSupportingCustomTabs.add(info.activityInfo.packageName);
                }
            }

            // Now packagesSupportingCustomTabs contains all apps that can handle both VIEW intents
            // and service calls.
            if (packagesSupportingCustomTabs.isEmpty()) {
                sPackageNameToUse = null;
           /* } else if (packagesSupportingCustomTabs.size() == 1) {
                sPackageNameToUse = packagesSupportingCustomTabs.get(0);
            } else if (!TextUtils.isEmpty(defaultViewHandlerPackageName)
                    && !hasSpecializedHandlerIntents(context, activityIntent)
                    && packagesSupportingCustomTabs.contains(defaultViewHandlerPackageName)) {
                sPackageNameToUse = defaultViewHandlerPackageName;*/
            } else if (packagesSupportingCustomTabs.contains(STABLE_PACKAGE)) {
                sPackageNameToUse = STABLE_PACKAGE;
            } else if (packagesSupportingCustomTabs.contains(BETA_PACKAGE)) {
                sPackageNameToUse = BETA_PACKAGE;
            } else if (packagesSupportingCustomTabs.contains(DEV_PACKAGE)) {
                sPackageNameToUse = DEV_PACKAGE;
            } else if (packagesSupportingCustomTabs.contains(LOCAL_PACKAGE)) {
                sPackageNameToUse = LOCAL_PACKAGE;
            }
            return sPackageNameToUse;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }


    //////////////////////////////////////

    @Override
    public void onNewIntent(Intent intent) {
        try {

            //String PACKAGE_NAME = this.cordova.getActivity().getPackageName();


            super.onNewIntent(intent);
            String action = intent.getAction();
            String data = intent.getDataString();


            Uri uri = Uri.parse(data);
            String protocol = uri.getScheme();
            String server = uri.getAuthority();
            String path = uri.getPath();
            Set<String> args = uri.getQueryParameterNames();


            if(isLogEnable) {
                String joined = "";

                for (String i : args)
                    joined += i + " - " + uri.getQueryParameter(i) + "\n";

                showDebugToast(joined);
            }


            callJavaScripLoginSuccess(data, packageName);

            //callbackContext.error(joined);
            //callbackContext.sendPluginResult(new PluginResult(PluginResult.Status.OK, joined));

            if (Intent.ACTION_VIEW.equals(action) && data != null) {
                try {


                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void callJavaScripLoginSuccess(String data, String packageName){
        this.cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                webView.loadUrl("javascript:onLoginSuccess('" + data + "', '" + packageName +  "');"); //TODO

            }
        });
    }


    private void showDebugToast(String str){
        if(isLogEnable)
            Toast.makeText(this.cordova.getActivity(), str, Toast.LENGTH_SHORT).show();

    }

    /*
    private boolean resetIntent;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        this.resetIntent = preferences.getBoolean("resetIntent", false) ||
                preferences.getBoolean("CustomURLSchemePluginClearsAndroidIntent", false);
    }

    */

    @Override
    public void logout(boolean routerLogout) {
        Log.d("", "");
        this.cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                webView.loadUrl("javascript:onRouterLogout('" + routerLogout + "');");

            }
        });
    }
}
