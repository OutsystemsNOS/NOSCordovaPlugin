package pt.nos.cordova.plugin;


import android.app.AlertDialog;
import android.app.Dialog;
import android.app.DialogFragment;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.support.annotation.Nullable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
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
import android.widget.ProgressBar;

import java.util.Set;

public class NOSPluginExternalWebViewLogout extends DialogFragment {

    private WebView webView;
    private ImageButton buttonRefresh, buttonBack, buttonForward, buttonClose, buttonToolbarRefresh;

    private int backgroundColor;
    private String mainColor;


    private String callbackSuccess = "";

    private NOSCordovaPlugin.RequestType requestType = NOSCordovaPlugin.RequestType.OTHER;

    private boolean showBottomBar = true;
    private String url;

    private int timeoutSeconds = 10;
    private String redirect_uri = null;

    public NOSCordovaPluginInterface nosCordovaPluginInterface;


    public NOSPluginExternalWebViewLogout() {
        // Empty constructor is required for DialogFragment
        // Make sure not to add arguments to the constructor
        // Use `newInstance` instead as shown below
    }

    public static NOSPluginExternalWebViewLogout newInstance(String title, String url, String redirect_uri, NOSCordovaPluginInterface nosCordovaPluginInterface, int timeoutInSeconds) {
        NOSPluginExternalWebViewLogout frag = new NOSPluginExternalWebViewLogout();

        Bundle args = new Bundle();

        args.putString("title", title);
        frag.setArguments(args);

        frag.url = url;
        frag.redirect_uri = redirect_uri;
        frag.timeoutSeconds = timeoutInSeconds;
        frag.nosCordovaPluginInterface = nosCordovaPluginInterface;

        return frag;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        webView = new WebView(getActivity());


        WebSettings settings = webView.getSettings();

        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);

        webView.setWebViewClient(webViewClient);


        webView.loadUrl(url);

    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        return super.onCreateView(inflater, container, savedInstanceState);
    }

    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        Dialog dialog = super.onCreateDialog(savedInstanceState);
        dialog.getWindow().setGravity(Gravity.BOTTOM);
        dialog.getWindow().setBackgroundDrawableResource(android.R.color.transparent);
        dialog.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_DIM_BEHIND);
        return dialog;
    }
    /*
    @Override
    public Dialog onCreateDialog(Bundle savedInstanceState) {
        ProgressDialog dialog = new ProgressDialog(getActivity(), getTheme());
        dialog.setTitle("Gerir o router");
        dialog.setMessage("a terminar sessão.......");
        dialog.setIndeterminate(true);
        dialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
        return dialog;
    }
    */




    //////////////////////////////////////////////////////////////////////////////////////////////////////

    WebViewClient webViewClient = new WebViewClient(){
        @Override
        public void onPageFinished(WebView view, String url) {
            try {
                super.onPageFinished(view, url);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }


        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            try {
                super.onPageStarted(view, url, favicon);

                Handler myHandler = new Handler(Looper.myLooper());
                myHandler.postDelayed(run, timeoutSeconds * 1000);


            } catch (Exception e) {
                e.printStackTrace();
            }

        }

        Runnable run = new Runnable() {
            @Override
            public void run() {
                if(webView != null){
                    webView.stopLoading();

                    logout(false);
                }
            }
        };
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            try {
                boolean result = super.shouldOverrideUrlLoading(view, url);

                if(redirect_uri != null && url.startsWith(redirect_uri)){

                    //Intent intent = new Intent();
                    //intent.putExtra("action", "0");
                    //setResult(0, intent); //OK
                    //finish();

                    logout(true);

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
                        //setResult(-1, intent);
                        //finish();
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
                    //setResult(-1, intent);
                    //finish();
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        private void logout(boolean routerLogout){

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


            NOSPluginExternalWebViewLogout.this.dismiss();

            if(nosCordovaPluginInterface != null){
                nosCordovaPluginInterface.logout(routerLogout);
            }

        }
    };
}
