package com.slins.flutterfft;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class FlutterFftPlugin implements FlutterPlugin, MethodCallHandler {
  public static final String TAG = "FlutterFftPlugin";

  public static MethodChannel channel;
  public static Context context;

  public static int sampleRate = 44100;
  public static int bufferSize = 8192;
  public static int pitchFitting = 0;
  public static double tuning = 440.0;
  public static double subsDuration = 0.2;

  public static double frequency = 0.0;
  public static String note = "";
  public static double target = 0.0;
  public static double distance = 0.0;
  public static int octave = 0;

  public static String nearestNote = "";
  public static double nearestTarget = 0.0;
  public static double nearestDistance = 0.0;
  public static int nearestOctave = 0;

  public static boolean isRecording = false;

  public static Handler recordHandler = new Handler(Looper.getMainLooper());

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_fft");
    channel.setMethodCallHandler(this);
    context = flutterPluginBinding.getApplicationContext();
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "startRecorder":
        try {
          PitchModel.start();
          result.success("Recording started successfully");
        } catch (Exception e) {
          result.error("ERROR", "Could not start recording: " + e.getMessage(), null);
        }
        break;
      case "stopRecorder":
        try {
          PitchModel.stop();
          result.success("Recording stopped successfully");
        } catch (Exception e) {
          result.error("ERROR", "Could not stop recording: " + e.getMessage(), null);
        }
        break;
      case "getIsRecording":
        result.success(PitchModel.getIsRecording());
        break;
      case "setSubscriptionDuration":
        Double duration = call.argument("duration");
        if (duration != null) {
          PitchModel.setSubscriptionDuration(duration);
          result.success("Subscription duration set");
        } else {
          result.error("INVALID_ARGUMENT", "Duration cannot be null", null);
        }
        break;
      case "setSampleRate":
        Integer rate = call.argument("sampleRate");
        if (rate != null) {
          PitchModel.setSampleRate(rate);
          result.success("Sample rate set");
        } else {
          result.error("INVALID_ARGUMENT", "Sample rate cannot be null", null);
        }
        break;
      case "setBufferSize":
        Integer buf = call.argument("bufferSize");
        if (buf != null) {
          PitchModel.setBufferSize(buf);
          result.success("Buffer size set");
        } else {
          result.error("INVALID_ARGUMENT", "Buffer size cannot be null", null);
        }
        break;
      case "setPitchFitting":
        Integer fit = call.argument("pitchFitting");
        if (fit != null) {
          PitchModel.setPitchFitting(fit);
          result.success("Pitch fitting set");
        } else {
          result.error("INVALID_ARGUMENT", "Pitch fitting cannot be null", null);
        }
        break;
      case "setTuning":
        Object tunArg = call.argument("tuning");
        if (tunArg instanceof Number) {
          PitchModel.setTuning(((Number) tunArg).doubleValue());
          result.success("Tuning set");
        } else {
          result.error("INVALID_ARGUMENT", "Tuning cannot be null", null);
        }
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if (channel != null) {
      channel.setMethodCallHandler(null);
      channel = null;
    }
    PitchModel.stop();
  }

  public static void printError(String message, Exception e) {
    Log.e(TAG, message, e);
  }

  public static void printError(String message) {
    Log.e(TAG, message);
  }
}