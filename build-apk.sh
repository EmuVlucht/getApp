#!/bin/bash
# ============================================================
# build-apk.sh — Build APK sederhana (WebView) tanpa IDE
# Kebutuhan: JDK, Android SDK (build-tools, platform-tools)
# ============================================================
set -e

APP_NAME="Emuvlucht"
PACKAGE="com.kcstream.cing"
VERSION_NAME="2.5.3"
VERSION_CODE="25301"          # format: major minor patch build(2digit)
URL="https://get.emuvlucht.my.id/getApp/"

SDK="${ANDROID_HOME:-$HOME/Android/Sdk}"
BT=$(ls -d $SDK/build-tools/* | sort -V | tail -1)
PLATFORM=$(ls -d $SDK/platforms/android-* | sort -V | tail -1)

echo "Using build-tools: $BT"
echo "Using platform:    $PLATFORM"

WORK=/tmp/apk-build-$$
mkdir -p $WORK/{src,res/layout,res/values,res/drawable,obj,bin}

# ── AndroidManifest.xml ──────────────────────────────────────
cat > $WORK/AndroidManifest.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="$PACKAGE"
    android:versionCode="$VERSION_CODE"
    android:versionName="$VERSION_NAME">

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>

    <application
        android:label="$APP_NAME"
        android:usesCleartextTraffic="true"
        android:theme="@android:style/Theme.NoTitleBar">

        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# ── Layout XML ───────────────────────────────────────────────
cat > $WORK/res/layout/activity_main.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical">

    <WebView
        android:id="@+id/webview"
        android:layout_width="match_parent"
        android:layout_height="match_parent"/>
</LinearLayout>
EOF

# ── strings.xml ──────────────────────────────────────────────
cat > $WORK/res/values/strings.xml << EOF
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$APP_NAME</string>
</resources>
EOF

# ── MainActivity.java ────────────────────────────────────────
mkdir -p $WORK/src/$(echo $PACKAGE | tr '.' '/')
cat > $WORK/src/$(echo $PACKAGE | tr '.' '/')/MainActivity.java << EOF
package $PACKAGE;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.DownloadListener;
import android.content.Intent;
import android.net.Uri;

public class MainActivity extends Activity {
    private WebView webView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        webView = (WebView) findViewById(R.id.webview);
        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setLoadWithOverviewMode(true);
        settings.setUseWideViewPort(true);
        settings.setBuiltInZoomControls(false);

        webView.setWebViewClient(new WebViewClient());

        // Handle APK download links
        webView.setDownloadListener(new DownloadListener() {
            @Override
            public void onDownloadStart(String url, String userAgent,
                    String contentDisposition, String mimeType, long contentLength) {
                Intent intent = new Intent(Intent.ACTION_VIEW);
                intent.setData(Uri.parse(url));
                startActivity(intent);
            }
        });

        webView.loadUrl("$URL");
    }

    @Override
    public void onBackPressed() {
        if (webView.canGoBack()) {
            webView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
EOF

echo "Sumber disiapkan di $WORK"
echo ""
echo "Untuk build APK, jalankan perintah berikut (perlu Android SDK):"
echo ""
echo "  cd $WORK"
echo "  \$BT/aapt2 compile --dir res -o obj/res.zip"
echo "  \$BT/aapt2 link obj/res.zip -I \$PLATFORM/android.jar \\"
echo "       --manifest AndroidManifest.xml -o bin/app-unsigned.apk --java src"
echo "  javac -source 1.8 -target 1.8 -cp \$PLATFORM/android.jar src/**/*.java -d obj/"
echo "  \$BT/dx --dex --output=bin/classes.dex obj/"
echo "  \$BT/apksigner sign --ks debug.keystore bin/app-unsigned.apk"
echo ""
echo "Atau gunakan Android Studio / Gradle."
