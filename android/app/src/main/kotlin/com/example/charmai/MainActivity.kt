package com.appnexatech.charmai


import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.graphics.Color
import android.graphics.drawable.GradientDrawable
import android.widget.LinearLayout
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import android.widget.Toast
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugins.googlemobileads.NativeAdFactory
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity(){
    companion object {
        private const val NATIVE_CHANNEL = "nativeChannel"
        private var startColor: String = "#B7C342"
        private var endColor: String = "#0691A3"
        private var backgroundColor: String = "#000000"
        private var headLineTextColor: String = "#FFFFFF"
        private var bodyTextColor: String = "#FFFFFF"
        private var buttonTextColor: String = "#FFFFFF"
    }
    private fun setText(myText: String) {
        Toast.makeText(this, myText, Toast.LENGTH_SHORT).show()
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        super.configureFlutterEngine(flutterEngine)


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, NATIVE_CHANNEL).setMethodCallHandler { call: MethodCall, result ->
            if (call.method == "setToast") {
                try {
                    startColor = call.argument<String>("btnBgColorG1")!!
                    endColor = call.argument<String>("btnBgColorG2")!!
                    backgroundColor = call.argument<String>("nativeBGColor")!!
                    headLineTextColor = call.argument<String>("headerTextColor")!!
                    bodyTextColor = call.argument<String>("bodyTextColor")!!
                    buttonTextColor = call.argument<String>("btnTextColor")!!


                    Log.d("NativeAdFactoryBig", "startColor: $startColor")
                    Log.d("NativeAdFactoryBig", "endColor: $endColor")
                    Log.d("NativeAdFactoryBig", "backgroundColor: $backgroundColor")
                    Log.d("NativeAdFactoryBig", "headLineTextColor: $headLineTextColor")
                    Log.d("NativeAdFactoryBig", "bodyTextColor: $bodyTextColor")
                    Log.d("NativeAdFactoryBig", "buttonTextColor: $buttonTextColor")

                    // Register ad factories here, after initializing properties

                    GoogleMobileAdsPlugin.registerNativeAdFactory(
                        flutterEngine,
                        "smallNativeAds",
                        NativeAdFactorySmall(
                            layoutInflater,
                            startColor,
                            endColor,
                            backgroundColor,
                            headLineTextColor,
                            bodyTextColor,
                            buttonTextColor
                        )
                    )

                    GoogleMobileAdsPlugin.registerNativeAdFactory(
                        flutterEngine,
                        "bigNativeAds",
                        NativeAdFactoryBig(
                            layoutInflater,
                            startColor,
                            endColor,
                            backgroundColor,
                            headLineTextColor,
                            bodyTextColor,
                            buttonTextColor
                        )
                    )

                    GoogleMobileAdsPlugin.registerNativeAdFactory(
                        flutterEngine,
                        "fullNativeAds",
                        NativeAdFactoryFull(
                            layoutInflater,
                            startColor,
                            endColor,
                            backgroundColor,
                            headLineTextColor,
                            bodyTextColor,
                            buttonTextColor
                        )
                    )

                } catch (e: Exception) {
                    e.printStackTrace()
                }
                result.success(true)

            }
        }
        flutterEngine.plugins.add(GoogleMobileAdsPlugin())
        super.configureFlutterEngine(flutterEngine)
    }


    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "smallNativeAds")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "bigNativeAds")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "fullNativeAds")
    }

}


class NativeAdFactoryBig : NativeAdFactory {
    private var layoutInflater: LayoutInflater
    private var startColor: String
    private var endColor: String
    private var backgroundColor: String
    private var headLineTextColor: String
    private var bodyTextColor: String
    private var buttonTextColor: String

    constructor(layoutInflater: LayoutInflater, startColor : String,endColor : String, backgroundColor: String, headLineTextColor: String, bodyTextColor: String, buttonTextColor: String) {
        this.layoutInflater = layoutInflater
        this.startColor = startColor
        this.endColor = endColor
        this.backgroundColor = backgroundColor
        this.headLineTextColor = headLineTextColor
        this.bodyTextColor = bodyTextColor
        this.buttonTextColor = buttonTextColor
    }

    override fun createNativeAd(
        nativeAd: NativeAd?,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.big_template, null) as NativeAdView

//        val startColor = "#FFEB3B"
//        val endColor = "#FF5722"
//        val backgroundColor = "#2196F3"
//
//        val headLineTextColor = "#9C27B0"
//        val bodyTextColor = "#9C27B0"
//        val buttonTextColor = "#9C27B0"
//        val starColor = "#E6736B"

        // Background color
        val circularLayoutBackground: LinearLayout = adView.findViewById(R.id.circular_layout_background)
        val cornerRadius = 20f * adView.context.resources.displayMetrics.density
        val backgroundGradientDrawable = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            setColor(Color.parseColor(backgroundColor))
            this.cornerRadius = cornerRadius
        }
        circularLayoutBackground.background = backgroundGradientDrawable

        // Set the media view.
        adView.mediaView = adView.findViewById(R.id.native_ad_media)

        // Set other ad assets.
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        (adView.headlineView as? TextView)?.setTextColor(Color.parseColor(headLineTextColor))

        adView.bodyView = adView.findViewById(R.id.ad_body)
        (adView.bodyView as? TextView)?.setTextColor(Color.parseColor(bodyTextColor))

        // Button Background
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        val buttonGradientDrawable = GradientDrawable(
            GradientDrawable.Orientation.TL_BR,
            intArrayOf(Color.parseColor(startColor), Color.parseColor(endColor))
        )
        buttonGradientDrawable.cornerRadius = 14f * adView.context.resources.displayMetrics.density
        adView.callToActionView?.background = buttonGradientDrawable
        //Text Color
        (adView.callToActionView as? Button)?.setTextColor(Color.parseColor(buttonTextColor))

        adView.iconView = adView.findViewById(R.id.ad_app_icon)

        // "Ad" Text background
        adView.priceView = adView.findViewById(R.id.native_ad_attribution_small)
        val priceGradientDrawable = GradientDrawable(
            GradientDrawable.Orientation.TL_BR, // 135 degrees
            intArrayOf(Color.parseColor(startColor), Color.parseColor(endColor))
        ).apply {
            cornerRadii = floatArrayOf(
                10f * adView.context.resources.displayMetrics.density, 10f *  adView.context.resources.displayMetrics.density, // top-left radius
                0f, 0f, // top-right radius
                0f, 0f, // bottom-right radius
                5f *  adView.context.resources.displayMetrics.density, 5f *  adView.context.resources.displayMetrics.density  // bottom-left radius
            )
        }
        adView.priceView?.background = priceGradientDrawable
        (adView.priceView as? TextView)?.setTextColor(Color.parseColor(buttonTextColor))

        // Star Color
        adView.starRatingView = adView.findViewById(R.id.ad_stars)
//        val color = Color.parseColor(starColor)
//        adView.starRatingView.progressTintList = ColorStateList.valueOf(color)

        // Populate ad view
        (adView.headlineView as TextView).text = nativeAd?.headline
        adView.mediaView?.mediaContent = nativeAd?.mediaContent

        if (nativeAd?.body == null) {
            adView.bodyView?.visibility = View.INVISIBLE
        } else {
            adView.bodyView?.visibility = View.VISIBLE
            (adView.bodyView as TextView).text = nativeAd.body
        }

        if (nativeAd?.callToAction == null) {
            adView.callToActionView?.visibility = View.INVISIBLE
        } else {
            adView.callToActionView?.visibility = View.VISIBLE
            (adView.callToActionView as Button).text = nativeAd.callToAction
        }

        if (nativeAd?.icon == null) {
            adView.iconView?.visibility = View.GONE
        } else {
            (adView.iconView as ImageView).setImageDrawable(nativeAd.icon!!.drawable)
            adView.iconView?.visibility = View.VISIBLE
        }

        if (nativeAd?.starRating == null) {
            adView.starRatingView?.visibility = View.INVISIBLE
        } else {
            (adView.starRatingView as RatingBar).rating = nativeAd.starRating!!.toFloat()
            adView.starRatingView?.visibility = View.VISIBLE
        }

        if (nativeAd != null) {
            adView.setNativeAd(nativeAd)
        }

        return adView
    }
}


class NativeAdFactorySmall : NativeAdFactory {
    private var layoutInflater: LayoutInflater
    private var startColor: String
    private var endColor: String
    private var backgroundColor: String
    private var headLineTextColor: String
    private var bodyTextColor: String
    private var buttonTextColor: String

    constructor(layoutInflater: LayoutInflater, startColor : String, endColor : String, backgroundColor: String, headLineTextColor: String, bodyTextColor: String, buttonTextColor: String) {
        this.layoutInflater = layoutInflater
        this.startColor = startColor
        this.endColor = endColor
        this.backgroundColor = backgroundColor
        this.headLineTextColor = headLineTextColor
        this.bodyTextColor = bodyTextColor
        this.buttonTextColor = buttonTextColor
    }

    override fun createNativeAd(
        nativeAd: NativeAd?,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.small_template, null) as NativeAdView

//        val startColor = "#FFEB3B"
//        val endColor = "#FF5722"
//        val backgroundColor = "#2196F3"
//
//        val headLineTextColor = "#9C27B0"
//        val bodyTextColor = "#9C27B0"
//        val buttonTextColor = "#9C27B0"

        // Background color
        val circularLayoutBackground: LinearLayout = adView.findViewById(R.id.circular_layout_background)
        val cornerRadius = 20f * adView.context.resources.displayMetrics.density
        val backgroundGradientDrawable = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            setColor(Color.parseColor(backgroundColor))
            this.cornerRadius = cornerRadius
        }
        circularLayoutBackground.background = backgroundGradientDrawable

        // Set the media view.
        /*adView.mediaView = adView.findViewById(R.id.ad_media)*/

        // Set other ad assets.
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        (adView.headlineView as? TextView)?.setTextColor(Color.parseColor(headLineTextColor))

        adView.bodyView = adView.findViewById(R.id.ad_body)
        (adView.bodyView as? TextView)?.setTextColor(Color.parseColor(bodyTextColor))

        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        val buttonGradientDrawable = GradientDrawable(
            GradientDrawable.Orientation.TL_BR, // 135 degrees
            intArrayOf(Color.parseColor(startColor), Color.parseColor(endColor))
        )
        buttonGradientDrawable.cornerRadius = 14f * adView.context.resources.displayMetrics.density
        adView.callToActionView?.background = buttonGradientDrawable
        //Text Color
        (adView.callToActionView as? Button)?.setTextColor(Color.parseColor(buttonTextColor))

        adView.iconView = adView.findViewById(R.id.ad_app_icon)

        // "Ad" Text background
        adView.priceView = adView.findViewById(R.id.native_ad_attribution_small)
        val priceGradientDrawable = GradientDrawable(
            GradientDrawable.Orientation.TL_BR, // 135 degrees
            intArrayOf(Color.parseColor(startColor), Color.parseColor(endColor))
        ).apply {
            cornerRadii = floatArrayOf(
                10f * adView.context.resources.displayMetrics.density, 10f *  adView.context.resources.displayMetrics.density, // top-left radius
                0f, 0f, // top-right radius
                0f, 0f, // bottom-right radius
                5f *  adView.context.resources.displayMetrics.density, 5f *  adView.context.resources.displayMetrics.density  // bottom-left radius
            )
        }
        adView.priceView?.background = priceGradientDrawable
        (adView.priceView as? TextView)?.setTextColor(Color.parseColor(buttonTextColor))

        adView.starRatingView = adView.findViewById(R.id.ad_stars)
//        val color = Color.parseColor("#E6736B")
//        adView.starRatingView.progressTintList = ColorStateList.valueOf(color)

        /*adView.storeView = adView.findViewById(R.id.ad_store)*/
        /*adView.advertiserView = adView.findViewById(R.id.ad_advertiser)*/

        // The headline and mediaContent are guaranteed to be in every NativeAd.
        (adView.headlineView as TextView).text = nativeAd?.headline
        /*adView.mediaView?.mediaContent = nativeAd?.mediaContent*/

        // These assets aren't guaranteed to be in every NativeAd, so it's important to
        // check before trying to display them.
        if (nativeAd?.body == null) {
            adView.bodyView?.visibility = View.INVISIBLE
        } else {
            adView.bodyView?.visibility = View.VISIBLE
            (adView.bodyView as TextView).text = nativeAd.body
        }

        if (nativeAd?.callToAction == null) {
            adView.callToActionView?.visibility = View.INVISIBLE
        } else {
            adView.callToActionView?.visibility = View.VISIBLE
            (adView.callToActionView as Button).text = nativeAd.callToAction
        }

        if (nativeAd?.icon == null) {
            adView.iconView?.visibility = View.GONE
        } else {
            (adView.iconView as ImageView).setImageDrawable(nativeAd.icon!!.drawable)
            adView.iconView?.visibility = View.VISIBLE
        }

        /* if (nativeAd?.price == null) {
             adView.priceView?.visibility = View.INVISIBLE
         } else {
             adView.priceView?.visibility = View.VISIBLE
             (adView.priceView as TextView).text = nativeAd.price
         }*/

        /*   if (nativeAd?.store == null) {
               adView.storeView?.visibility = View.INVISIBLE
           } else {
               adView.storeView?.visibility = View.VISIBLE
               (adView.storeView as TextView).text = nativeAd.store
           }*/

        if (nativeAd?.starRating == null) {
            adView.starRatingView?.visibility = View.INVISIBLE
        } else {
            (adView.starRatingView as RatingBar).rating = nativeAd.starRating!!.toFloat()
            adView.starRatingView?.visibility = View.VISIBLE
        }

        /* if (nativeAd?.advertiser == null) {
             adView.advertiserView?.visibility = View.INVISIBLE
         } else {
             adView.advertiserView?.visibility = View.VISIBLE
             (adView.advertiserView as TextView).text = nativeAd.advertiser
         }*/

        // This method tells the Google Mobile Ads SDK that you have finished populating your
        // native ad view with this native ad.
        if (nativeAd != null) {
            adView.setNativeAd(nativeAd)
        }

        return adView
    }
}

class NativeAdFactoryFull : NativeAdFactory {
    private var layoutInflater: LayoutInflater
    private var startColor: String
    private var endColor: String
    private var backgroundColor: String
    private var headLineTextColor: String
    private var bodyTextColor: String
    private var buttonTextColor: String

    constructor(layoutInflater: LayoutInflater, startColor : String, endColor : String, backgroundColor: String, headLineTextColor: String, bodyTextColor: String, buttonTextColor: String) {
        this.layoutInflater = layoutInflater
        this.startColor = startColor
        this.endColor = endColor
        this.backgroundColor = backgroundColor
        this.headLineTextColor = headLineTextColor
        this.bodyTextColor = bodyTextColor
        this.buttonTextColor = buttonTextColor
    }

    override fun createNativeAd(
        nativeAd: NativeAd?,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.full_template, null) as NativeAdView


        // Background color
        val circularLayoutBackground: LinearLayout = adView.findViewById(R.id.circular_layout_background_full)
        val cornerRadius = 20f * adView.context.resources.displayMetrics.density
        val backgroundGradientDrawable = GradientDrawable().apply {
            shape = GradientDrawable.RECTANGLE
            setColor(Color.parseColor(backgroundColor))
            this.cornerRadius = cornerRadius
        }
        circularLayoutBackground.background = backgroundGradientDrawable

        // Set the media view.
        adView.mediaView = adView.findViewById(R.id.native_ad_media)

        // Set other ad assets.
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        (adView.headlineView as? TextView)?.setTextColor(Color.parseColor(headLineTextColor))

        adView.bodyView = adView.findViewById(R.id.ad_body)
        (adView.bodyView as? TextView)?.setTextColor(Color.parseColor(bodyTextColor))

        // Button Background
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        val buttonGradientDrawable = GradientDrawable(
            GradientDrawable.Orientation.TL_BR, // 135 degrees
            intArrayOf(Color.parseColor(startColor), Color.parseColor(endColor))
        )
        buttonGradientDrawable.cornerRadius = 14f * adView.context.resources.displayMetrics.density
        adView.callToActionView?.background = buttonGradientDrawable
        //Text Color
        (adView.callToActionView as? Button)?.setTextColor(Color.parseColor(buttonTextColor))

        adView.iconView = adView.findViewById(R.id.ad_app_icon)

        // "Ad" Text background
        adView.priceView = adView.findViewById(R.id.native_ad_attribution_small)
        val priceGradientDrawable = GradientDrawable(
            GradientDrawable.Orientation.TL_BR, // 135 degrees
            intArrayOf(Color.parseColor(startColor), Color.parseColor(endColor))
        ).apply {
            cornerRadii = floatArrayOf(
                10f * adView.context.resources.displayMetrics.density, 10f *  adView.context.resources.displayMetrics.density, // top-left radius
                0f, 0f, // top-right radius
                0f, 0f, // bottom-right radius
                5f *  adView.context.resources.displayMetrics.density, 5f *  adView.context.resources.displayMetrics.density  // bottom-left radius
            )
        }
        adView.priceView?.background = priceGradientDrawable
        (adView.priceView as? TextView)?.setTextColor(Color.parseColor(buttonTextColor))

        // Star Color
        adView.starRatingView = adView.findViewById(R.id.ad_stars)
//        val color = Color.parseColor(starColor)
//        adView.starRatingView.progressTintList = ColorStateList.valueOf(color)

        // Populate ad view
        (adView.headlineView as TextView).text = nativeAd?.headline
        adView.mediaView?.mediaContent = nativeAd?.mediaContent

        if (nativeAd?.body == null) {
            adView.bodyView?.visibility = View.INVISIBLE
        } else {
            adView.bodyView?.visibility = View.VISIBLE
            (adView.bodyView as TextView).text = nativeAd.body
        }

        if (nativeAd?.callToAction == null) {
            adView.callToActionView?.visibility = View.INVISIBLE
        } else {
            adView.callToActionView?.visibility = View.VISIBLE
            (adView.callToActionView as Button).text = nativeAd.callToAction
        }

        if (nativeAd?.icon == null) {
            adView.iconView?.visibility = View.GONE
        } else {
            (adView.iconView as ImageView).setImageDrawable(nativeAd.icon!!.drawable)
            adView.iconView?.visibility = View.VISIBLE
        }

        if (nativeAd?.starRating == null) {
            adView.starRatingView?.visibility = View.INVISIBLE
        } else {
            (adView.starRatingView as RatingBar).rating = nativeAd.starRating!!.toFloat()
            adView.starRatingView?.visibility = View.VISIBLE
        }

        if (nativeAd != null) {
            adView.setNativeAd(nativeAd)
        }

        return adView
    }
}
