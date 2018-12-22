package it.versionestabile.flutterapp000001;

import android.app.AlertDialog;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.content.FileProvider;

import java.io.File;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "it.versionestabile.flutterapp000001/pdfViewer";
  private static final String SINGLE_CHANNEL = "it.versionestabile.flutterapp000001/single";
  private static final String MULTI_CHANNEL = "it.versionestabile.flutterapp000001/multi";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), MULTI_CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                if (call.method.equals("op1")) {
                  new AlertDialog.Builder(MainActivity.this)
                          .setTitle(call.method)
                          .setMessage("I'm the " + call.method + " of the by design multi operation channel!")
                          .create()
                          .show();
                } else if (call.method.equals("op2")) {
                    new AlertDialog.Builder(MainActivity.this)
                            .setTitle(call.method)
                            .setMessage("I'm the " + call.method + " of the by design multi operation channel!")
                            .create()
                            .show();
                } else {
                  result.notImplemented();
                }
              }
            });

    new MethodChannel(getFlutterView(), SINGLE_CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                if (call.method.equals("hello")) {
                  new AlertDialog.Builder(MainActivity.this)
                          .setTitle("hello!")
                          .setMessage("I'm the by design single operation channel!")
                          .create()
                          .show();
                } else {
                  result.notImplemented();
                }
              }
            });

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                if (call.method.equals("viewPdf")) {
                  if (call.hasArgument("url")) {
                    String url = call.argument("url");
                    File file = new File(url);
                    //*
                    Uri photoURI = FileProvider.getUriForFile(MainActivity.this,
                            BuildConfig.APPLICATION_ID + ".provider",
                            file);
                            //*/
                    Intent target = new Intent(Intent.ACTION_VIEW);
                    target.setDataAndType(photoURI,"application/pdf");
                    target.setFlags(Intent.FLAG_ACTIVITY_NO_HISTORY);
                    target.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                    startActivity(target);
                    result.success(null);
                  }
                } else {
                  result.notImplemented();
                }
              }
            });
  }
}
