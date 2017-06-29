
  var argscheck = require('cordova/argscheck'),
    utils = require('cordova/utils'),
    exec = require('cordova/exec'),
    cordova = require('cordova'),
    AMapPositionError = require('./PositionError'),
    AMapPosition = require('./Position');

  var timers = {}; // list of timers in use

  // Returns default params, overrides if provided with values
  function parseParameters(options) {
    var opt = {
      maximumAge: 0,
      enableHighAccuracy: false,
      timeout: Infinity
    };

    if (options) {
      if (options.maximumAge !== undefined && !isNaN(options.maximumAge) && options.maximumAge > 0) {
        opt.maximumAge = options.maximumAge;
      }
      if (options.enableHighAccuracy !== undefined) {
        opt.enableHighAccuracy = options.enableHighAccuracy;
      }
      if (options.timeout !== undefined && !isNaN(options.timeout)) {
        if (options.timeout < 0) {
          opt.timeout = 0;
        } else {
          opt.timeout = options.timeout;
        }
      }
    }

    return opt;
  }

  // Returns a timeout failure, closed over a specified timeout value and error callback.
  function createTimeout(errorCallback, timeout) {
    var t = setTimeout(function () {
      clearTimeout(t);
      t = null;
      errorCallback({
        code: AMapPositionError.TIMEOUT,
        message: "Position retrieval timed out."
      });
    }, timeout);
    return t;
  }


  function AMaplocation() {
    this.lastPosition = null; // reference to last known (cached) position returned
    var me = this;
  }


  /**
   * Asynchronously acquires the current position.
   *
   * @param {Function} successCallback    The function to call when the position data is available
   * @param {Function} errorCallback      The function to call when there is an error getting the heading position. (OPTIONAL)
   * @param {PositionOptions} options     The options for getting the position data. (OPTIONAL)
   */
  AMaplocation.prototype.getCurrentPosition = function (successCallback, errorCallback, options) {


    var me = this;

    argscheck.checkArgs('fFO', 'amapLocation.getCurrentPosition', arguments);
    options = parseParameters(options);

    // Timer var that will fire an error callback if no position is retrieved from native
    // before the "timeout" param provided expires
    var timeoutTimer = {
      timer: null
    };

    var win = function (location) {

     // alert(JSON.stringify(location));
      //
      //      clearTimeout(timeoutTimer.timer);
      //      if (!(timeoutTimer.timer)) {
      //        alert(timeoutTimer.timer);
      //        // Timeout already happened, or native fired error callback for
      //        // this geo request.
      //        // Don't continue with success callback.
      //        return;
      //      }

//
//      var pos = new AMapPosition({
//          latitude: location.latitude,
//          longitude: location.longitude,
//          altitude: location.altitude,
//          accuracy: location.accuracy,
//          heading: location.heading,
//          velocity: location.velocity,
//          altitudeAccuracy: location.altitudeAccuracy
//        },
//        location.timestamp
//      );
//
      //this.lastPosition = pos;
      successCallback(location);
    };
    var fail = function (e) {
      alert("e");
      clearTimeout(timeoutTimer.timer);
      timeoutTimer.timer = null;
      var err = new AMapPositionError(e.code, e.message);
      if (errorCallback) {
        errorCallback(err);
      }
    };

    exec(win, fail, "AMaplocation", "getLocation", [options.enableHighAccuracy, options.maximumAge]);


  };


  AMaplocation.prototype.getCurrentAdress = function (successCallback, errorCallback, options) {

    argscheck.checkArgs('fFO', 'amapLocation.getCurrentAdress', arguments);
    options = parseParameters(options);

    // Timer var that will fire an error callback if no position is retrieved from native
    // before the "timeout" param provided expires
    var timeoutTimer = {
      timer: null
    };

    var win = function (curLocation) {

      //                alert("s");
      alert(JSON.stringify(curLocation));
     
      successCallback(curLocation);
    };
    var fail = function (e) {
      alert("e");
      clearTimeout(timeoutTimer.timer);
      timeoutTimer.timer = null;
      var err = new AMapPositionError(e.code, e.message);
      if (errorCallback) {
        errorCallback(err);
      }
    };


    // alert("here");
    //
    exec(win, fail, "AMaplocation", "getCurrentAdress", [options.enableHighAccuracy, options.maximumAge]);


  }


  //    if(!window.plugins){
  //        window.plugins = {};
  //    }
  //    if(!window.plugins.amapLocation){
  //        window.plugins.amapLocation = new AMaplocation();
  //    }
  //    module.exports = new AMaplocation();


  AMaplocation.prototype.isPlatformIOS = function () {
    return device.platform == "iPhone" || device.platform == "iPad" || device.platform == "iPod touch" || device.platform == "iOS"
  }

  AMaplocation.prototype.init = function () {
    if (this.isPlatformIOS()) {
      var data = [];
      this.call_native("initial", data, null);
    } else {
      data = [];
      this.call_native("init", data, null);

    }
  }

  AMaplocation.prototype.error_callback = function (msg) {
    console.log("Javascript Callback Error: " + msg)
  }

  AMaplocation.prototype.call_native = function (name, args, callback) {

    ret = cordova.exec(callback, this.error_callback, 'AMaplocation', name, args);
    return ret;
  }
  var amapLocation = new AMaplocation();
  module.exports = amapLocation;
