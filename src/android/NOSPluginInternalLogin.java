package pt.nos.cordova.plugin;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.RelativeLayout;
import android.widget.Toast;

import java.util.Set;

public class NOSPluginInternalLogin extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        String package_name = getApplication().getPackageName();
        setContentView(getApplication().getResources().getIdentifier("layout_activity_internal_login", "layout", package_name));

        WebView webView = (WebView) findViewById(getResources().getIdentifier("webViewLogin", "id", getPackageName()));


        webView.getSettings().setJavaScriptEnabled(true);
        webView.getSettings().setJavaScriptCanOpenWindowsAutomatically(true);
        webView.getSettings().setDomStorageEnabled(true);

        webView.getSettings().setUseWideViewPort(true);


        webView.setWebViewClient(new WebViewClient(){


            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                return super.shouldOverrideUrlLoading(view, request);
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                return super.shouldOverrideUrlLoading(view, url);
            }
        });
        /*
        webView.setWebViewClient(new WebViewClient(){

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {

                if(url.startsWith("mynos://")){

                    Uri uri = Uri.parse(url);
                    String protocol = uri.getScheme();
                    String server = uri.getAuthority();
                    String path = uri.getPath();
                    Set<String> args = uri.getQueryParameterNames();




                    String joined = "";

                    for(String i : args)
                        joined += i + " - " + uri.getQueryParameter(i) + "\n";

                    Toast.makeText(NOSPluginInternalLogin.this, joined, Toast.LENGTH_SHORT).show();


                    Intent intentResult = new Intent();
                    intentResult.putExtra("url", url);
                    setResult(0, intentResult);

                    finish();

                    return true;
                }

                return super.shouldOverrideUrlLoading(view, url);

            }
        });
*/

        if(getIntent().getBooleanExtra("logout", false)){


            webView.clearCache(true);
            webView.clearHistory();
            webView.clearFormData();
            CookieSyncManager.createInstance(this);
            CookieManager cookieManager = CookieManager.getInstance();
            cookieManager.removeAllCookie();

        }else {



        }

        if(getIntent() != null && getIntent().hasExtra("url")) {
            String url = getIntent().getStringExtra("url");

            webView.loadUrl(url);
        }
        //webView.loadUrl("https://google.com");


    }

}
