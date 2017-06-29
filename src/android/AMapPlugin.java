package cn.set.cordova.geolocation;


import android.Manifest;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationClientOption.AMapLocationMode;
import com.amap.api.location.AMapLocationListener;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONObject;


public class AMapPlugin extends CordovaPlugin implements AMapLocationListener {

    private static AMapPlugin instance;


    private AMapLocationClient locationClient = null;
    private AMapLocationClientOption locationOption = null;


    //    private Activity activity;
    private Context mContext;
    String TAG = "AMapPlugin->";
    CallbackContext context;

    String[] permissions = {Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION};

    // private static final String GET_ACTION = "getCurrentPosition";
    // private static final String STOP_ACTION = "stop";

    // public LocationClient locationClient = null;
    // public BDLocationListener myListener = null;

    // public JSONObject jsonObj = new JSONObject();
    // public boolean result = false;
    // public CallbackContext callbackContext;


    // private static final Map<Integer, String> ERROR_MESSAGE_MAP = new HashMap<Integer, String>();

    // private static final String DEFAULT_ERROR_MESSAGE = "服务端定位失败";

    // static {
    //     ERROR_MESSAGE_MAP.put(61, "GPS定位结果");
    //     ERROR_MESSAGE_MAP.put(62, "扫描整合定位依据失败。此时定位结果无效");
    //     ERROR_MESSAGE_MAP.put(63, "网络异常，没有成功向服务器发起请求。此时定位结果无效");
    //     ERROR_MESSAGE_MAP.put(65, "定位缓存的结果");
    //     ERROR_MESSAGE_MAP.put(66, "离线定位结果。通过requestOfflineLocaiton调用时对应的返回结果");
    //     ERROR_MESSAGE_MAP.put(67, "离线定位失败。通过requestOfflineLocaiton调用时对应的返回结果");
    //     ERROR_MESSAGE_MAP.put(68, "网络连接失败时，查找本地离线定位时对应的返回结果。");
    //     ERROR_MESSAGE_MAP.put(161, "表示网络定位结果");
    // };


    public AMapPlugin() {
        instance = this;
    }

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        // Device.uuid = getUuid();
        mContext = cordova.getActivity().getApplicationContext();
        //
        //init();
    }

    void init() {

        Log.i("TAG->", "init: ");
        //callbackContext.success();
        //locationClient = new AMapLocationClient(this.getApplicationContext());
        locationClient = new AMapLocationClient(mContext);
        locationOption = new AMapLocationClientOption();
        // 设置定位模式为高精度模式
        locationOption.setLocationMode(AMapLocationMode.Hight_Accuracy);
        // 设置定位监听
        locationClient.setLocationListener(this);

    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (null != locationClient) {
            /**
             * 如果AMapLocationClient是在当前Activity实例化的，
             * 在Activity的onDestroy中一定要执行AMapLocationClient的onDestroy
             */
            locationClient.onDestroy();
            locationClient = null;
            locationOption = null;
        }
    }


    // 根据控件的选择，重新设置定位参数
    private void initOption() {
        //设置是否需要显示地址信息

//        locationOption.setNeedAddress(cbAddress.isChecked());
        locationOption.setNeedAddress(true);
//        locationOption.setGpsFirst(true);


        /**
         * 设置是否优先返回GPS定位结果，如果30秒内GPS没有返回定位结果则进行网络定位
         * 注意：只有在高精度模式下的单次定位有效，其他方式无效
         */
        //locationOption.setGpsFirst(cbGpsFirst.isChecked());
        //String strInterval = etInterval.getText().toString();
        //if (!TextUtils.isEmpty(strInterval)) {
        // 设置发送定位请求的时间间隔,最小值为1000，如果小于1000，按照1000算
        // locationOption.setInterval(Long.valueOf(strInterval));
        //}

    }

    /*
    @Override
    public void onCheckedChanged(RadioGroup group, int checkedId) {
        switch (checkedId) {
            case R.id.rb_continueLocation:
                //只有持续定位设置定位间隔才有效，单次定位无效
                layoutInterval.setVisibility(View.VISIBLE);
                //只有在高精度模式单次定位的情况下，GPS优先才有效
                cbGpsFirst.setVisibility(View.GONE);
                locationOption.setOnceLocation(false);
                break;
            case R.id.rb_onceLocation:
                //只有持续定位设置定位间隔才有效，单次定位无效
                layoutInterval.setVisibility(View.GONE);
                //只有在高精度模式单次定位的情况下，GPS优先才有效
                cbGpsFirst.setVisibility(View.VISIBLE);
                locationOption.setOnceLocation(true);
                break;
        }
    }*/

    // public String getErrorMessage(int locationType) {
    //     String result = ERROR_MESSAGE_MAP.get(locationType);
    //     if (result == null) {
    //         result = DEFAULT_ERROR_MESSAGE;
    //     }
    //     return result;
    // }

    @Override
    public boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) {

        Log.i("TAG->", "execute: ");
        context = callbackContext;

        if (action.equals("init")) {
            init();
        }
        else if (action.equals("getLocation")) {
            //只有在高精度模式单次定位的情况下，GPS优先才有效
//             cbGpsFirst.setVisibility(View.VISIBLE);
            locationOption.setOnceLocation(true);

            // 设置定位参数
            locationClient.setLocationOption(locationOption);
            // 启动定位
            locationClient.startLocation();
            mHandler.sendEmptyMessage(Utils.MSG_LOCATION_START);

            return true;
        }

        return true;
    }


    Handler mHandler = new Handler() {
        public void dispatchMessage(android.os.Message msg) {
            switch (msg.what) {
                //开始定位
                case Utils.MSG_LOCATION_START:
                    Log.i(TAG, "正在定位...");
                    break;
                // 定位完成
                case Utils.MSG_LOCATION_FINISH:
                    AMapLocation amapLocation = (AMapLocation) msg.obj;
                    String result = Utils.getLocationStr(amapLocation);
                    //tvReult.setText(result);
                    Log.i(TAG, result);

                    JSONObject r = new JSONObject();

                    try {
                        if (amapLocation.getErrorCode() == 0) {
//                        //定位成功回调信息，设置相关消息
//                        amapLocation.getLocationType();//获取当前定位结果来源，如网络定位结果，详见定位类型表
//                        amapLocation.getLatitude();//获取纬度
//                        amapLocation.getLongitude();//获取经度
//                        amapLocation.getAccuracy();//获取精度信息
//                        SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
//                        Date date = new Date(amapLocation.getTime());
//                        df.format(date);//定位时间
//                        amapLocation.getAddress();//地址，如果option中设置isNeedAddress为false，则没有此结果，网络定位结果中会有地址信息，GPS定位不返回地址信息。
//                        amapLocation.getCountry();//国家信息
//                        amapLocation.getProvince();//省信息
//                        amapLocation.getCity();//城市信息
//                        amapLocation.getDistrict();//城区信息
//                        amapLocation.getStreet();//街道信息
//                        amapLocation.getStreetNum();//街道门牌号信息
//                        amapLocation.getCityCode();//城市编码
//                        amapLocation.getAdCode();//地区编码

                            r.put("latitude", amapLocation.getLatitude());
                            r.put("longitude", amapLocation.getLongitude());
                            r.put("accuracy", amapLocation.getAccuracy());
                            //r.put("altitude", this.getModel());
                            //r.put("heading", this.getManufacturer());
                            //r.put("altitudeAccuracy", this.isVirtual());
                            //r.put("velocity",);
                            r.put("address",amapLocation.getAddress());
                            r.put("country",amapLocation.getCountry());
                            r.put("citycode",amapLocation.getCityCode());
                            r.put("city",amapLocation.getCity());
                            r.put("province",amapLocation.getProvince());
                            r.put("district",amapLocation.getDistrict());
                            r.put("street",amapLocation.getStreet());
                            r.put("streetnum",amapLocation.getStreetNum());
                            r.put("adcode",amapLocation.getAdCode());

                            context.success(r);
                        }
                    }catch (Exception ex)
                    {
                        Log.i(TAG, ex.toString());
                    }
//                    PluginResult r = new PluginResult(PluginResult.Status.OK);
//                    context.sendPluginResult(r);
                    break;
                //停止定位
                case Utils.MSG_LOCATION_STOP:
                    //tvReult.setText("定位停止");
                    Log.i(TAG, "定位停止");
                    break;
                default:
                    break;
            }
        }
    };


    private  String getFormatString(String source)
    {
        String  sresult ="";
//        if (source)
//        {
//        }

        return sresult;
    }


    // 定位监听
    @Override
    public void onLocationChanged(AMapLocation loc) {
        if (null != loc) {
            Message msg = mHandler.obtainMessage();
            msg.obj = loc;
            msg.what = Utils.MSG_LOCATION_FINISH;
            mHandler.sendMessage(msg);
        }
    }

    // public class MyLocationListener implements BDLocationListener {
    //     @Override
    //     public void onReceiveLocation(BDLocation location) {
    //         if (location == null)
    //             return;
    //         try {
    //             JSONObject coords = new JSONObject();
    //             coords.put("latitude", location.getLatitude());
    //             coords.put("longitude", location.getLongitude());
    //             coords.put("radius", location.getRadius());
    //             jsonObj.put("coords", coords);
    //             int locationType = location.getLocType();
    //             jsonObj.put("locationType", locationType);
    //             jsonObj.put("code", locationType);
    //             jsonObj.put("message", getErrorMessage(locationType));
    //             switch (location.getLocType()) {
    //                 case BDLocation.TypeGpsLocation:
    //                     coords.put("speed", location.getSpeed());
    //                     coords.put("altitude", location.getAltitude());
    //                     jsonObj.put("SatelliteNumber",
    //                             location.getSatelliteNumber());
    //                     break;
    //                 case BDLocation.TypeNetWorkLocation:
    //                     jsonObj.put("addr", location.getAddrStr());
    //                     break;
    //             }
    //             Log.d("BaiduLocationPlugin", "run: " + jsonObj.toString());
    //             callbackContext.success(jsonObj);
    //             result = true;
    //         } catch (JSONException e) {
    //             callbackContext.error(e.getMessage());
    //             result = true;
    //         }

    //     }

    //     public void onReceivePoi(BDLocation poiLocation) {
    //         // TODO Auto-generated method stub
    //     }
    // }

    // @Override
    // public void onDestroy() {
    //     if (locationClient != null && locationClient.isStarted()) {
    //         locationClient.stop();
    //         locationClient = null;
    //     }
    //     super.onDestroy();
    // }

    // private void logMsg(String s) {
    //     System.out.println(s);
    // }

    // public CallbackContext getCallbackContext() {
    //     return callbackContext;
    // }

    // public void setCallbackContext(CallbackContext callbackContext) {
    //     this.callbackContext = callbackContext;
    // }
}
