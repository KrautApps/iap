' Copyright 2013 Martin Leidel
'
' This software is provided 'as-is', without any express or implied
' warranty.  In no event will the authors be held liable for any damages
' arising from the use of this software.
' 
' Permission is granted to anyone to use this software for any purpose,
' including commercial applications, and to alter it and redistribute it
' freely, subject to the following restrictions:
' 
' 1. The origin of this software must not be misrepresented; you must not
' claim that you wrote the original software. If you use this software
' in a product, an acknowledgment in the product documentation would be
' appreciated but is not required.
' 2. Altered source versions must be plainly marked as such, and must not be
' misrepresented as being the original software.
' 3. This notice may not be removed or altered from any source distribution.

Strict

#If TARGET <> "android"
  #Error "The IAP module is only available on the android target"
#End

#If TARGET = "android"
  Import "native/utils/Base64.java"
  Import "native/utils/Base64DecoderException.java"
  Import "native/utils/IabException.java"
  Import "native/utils/IabHelper.java"
  Import "native/utils/IabResult.java"
  Import "native/utils/Inventory.java"
  Import "native/utils/Purchase.java"
  Import "native/utils/Security.java"
  Import "native/utils/SkuDetails.java"
  Import "native/iap.android.java"
  #ANDROID_MANIFEST_APPLICATION += "<uses-permission android:name=~qcom.android.vending.BILLING~q />"
#Else
  Import "native/iap.ios.cpp"
#End

Extern

Class IAP Extends Null = "IAPWrapper"
  Function InitIAP:IAP( publicKey:String )

  Method isInitialized:Bool()
  Method getLastResult:Int()
  Method getResponseDescription:String( code:Int )
  Method queryPurchasedItems:Void()
  Method isQueryForPurchasedItemsFinished:Bool()
  Method hasBeenPurchased:Bool( itemId:String )
  Method getPrice:String( itemId:String )
  Method getTitle:String( itemId:String )
  Method getDescription:String( itemId:String )
  Method consume:Bool( itemId:String )
  Method isConsumeFinished:Bool()
  Method purchase:Void( itemId:String, payload:String = "" )
  Method isPurchaseFinished:Bool()
End Class
