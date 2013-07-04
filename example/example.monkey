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

Import mojo
Import iap

Const STATE_INIT:Int = 1
Const STATE_IDLE:Int = 2
Const STATE_QUERY_ITEMS:Int = 3
Const STATE_QUERY_ITEMS_WAIT:Int = 4
Const STATE_PURCHASE:Int = 5
Const STATE_PURCHASE_WAIT:Int = 6
Const STATE_AFTER_PURCHASE_QUERY:Int = 7
Const STATE_AFTER_PURCHASE_QUERY_WAIT:Int = 8
Const STATE_CONSUME:Int = 9
Const STATE_CONSUME_WAIT:Int = 10
Const STATE_RESTART:Int = 11

Const APP_KEY:String = "TEST_KEY"
Const ITEM_ID:String = "android.test.purchased"

Function Main:Int()
  New TestApp()
  Return 0
End Function

Class TestApp Extends App
  Field _iap:IAP = Null

  Field _state:Int = STATE_INIT
  Field _scaleRatioX:Float
  Field _scaleRatioY:Float
  Field _translateX:Float
  Field _translateY:Float
  Field _isMousePressed:Bool
  Field _isButtonPressed:Bool
  
  Method OnCreate:Int()
    SetUpdateRate(30)

    checkForResolution()    
    _isMousePressed = False
    _isButtonPressed = False

    _iap = InitIAP( APP_KEY )
    Return 0
  End Method

  Method OnUpdate:Int()
    If( Not _iap ) Then Return 0

    If( KeyHit( KEY_ESCAPE ) )
      EndApp()
    End If
    
    'Check for touch events
    Local mx:Float = Float( MouseX() ) / _scaleRatioX - _translateX / _scaleRatioX
    Local my:Float = Float( MouseY() ) / _scaleRatioY - _translateY / _scaleRatioY

    _isButtonPressed = False
    If( TouchHit( 0 ) And Not _isMousePressed )
      _isMousePressed = True
      If( mx >= 10 And mx <= 310 And my >= 60 And my <= 90 )
        'Button pressed
        _isButtonPressed = True
      End If
    Else If( Not TouchHit( 0 ) And _isMousePressed )
      _isMousePressed = False
    End If

    'Right here starts the fun!
    Select _state
      'Init state, does nothing special, just checks if the IAP module is ready
      Case STATE_INIT
        If( _iap.isInitialized() ) Then _state = STATE_QUERY_ITEMS
      'Before ANY purchase or consume you have to query for purchased items first!
      Case STATE_QUERY_ITEMS
        If( _isButtonPressed )
          _iap.queryPurchasedItems()
          _state = STATE_QUERY_ITEMS_WAIT
        End If
      'query has been triggered, we wait for that async event to finish
      Case STATE_QUERY_ITEMS_WAIT
        If( _iap.isQueryForPurchasedItemsFinished() ) Then _state = STATE_PURCHASE
      'No we want to purchase something.
      'IMPORTANT to know: You can only purchase ONE consumable at once with Google's API V3
      'So purchase->consume, then you can purchase again.
      'Purchase is where you really BUY the item
      'Consume is where you tell the Google server that you've used it and be ready to purchase the next item with that id
      Case STATE_PURCHASE
        'Have we already purchased that item?
        If( _iap.hasBeenPurchased( ITEM_ID ) )
          'Yes, skip to consume state!
          _state = STATE_CONSUME
        Else If( _isButtonPressed )
          'No, wait for button click to consume it!
          _iap.purchase( ITEM_ID )
          _state = STATE_PURCHASE_WAIT
        End If
      'Purchase has been triggered, we wait for that async event to finish
      Case STATE_PURCHASE_WAIT
        If( _iap.isPurchaseFinished() ) Then _state = STATE_AFTER_PURCHASE_QUERY
      'After a purchase we have to query the list again for all purchased items
      Case STATE_AFTER_PURCHASE_QUERY
        _iap.queryPurchasedItems()
        _state = STATE_AFTER_PURCHASE_QUERY_WAIT
      'query has been triggered, we wait for that async event to finish
      Case STATE_AFTER_PURCHASE_QUERY_WAIT
        If( _iap.isQueryForPurchasedItemsFinished() )
          If( _iap.hasBeenPurchased( ITEM_ID ) )
            _state = STATE_CONSUME
          Else
            _state = STATE_QUERY_ITEMS
          End If
        End If
      'Right, that item has been purchased, now we can consume it!
      Case STATE_CONSUME
        If( _isButtonPressed )
          _iap.consume( ITEM_ID )
          _state = STATE_CONSUME_WAIT
        End If
      'Async stuff, you already know that, mhh? ;)
      Case STATE_CONSUME_WAIT
        If( _iap.isConsumeFinished() ) Then _state = STATE_RESTART
      'Restart it!
      Case STATE_RESTART
        If( _isButtonPressed )
          _state = STATE_QUERY_ITEMS
        End If
    End Select
    
    Return 0
  End Method
  
  Method OnSuspend:Int()
    Return 0
  End Method
  
  Method OnResume:Int()
    Return 0
  End Method

  Method OnRender:Int()
    PushMatrix()
      Translate( _translateX, _translateY )
      Scale( _scaleRatioX, _scaleRatioY )
  
      Cls

      SetColor( 255, 255, 0 )
      DrawRect( 10, 60, 300, 30 )

      Select _state
        Case STATE_INIT
          DrawText( "Initializing...", 20, 70 )
        Case STATE_QUERY_ITEMS
          DrawText( "Query Purchased Items", 20, 70 )
        Case STATE_QUERY_ITEMS_WAIT
          DrawText( "Query Purchased Items ... processing", 20, 70 )
        Case STATE_PURCHASE
          DrawText( "Purchase", 20, 70 )
        Case STATE_PURCHASE_WAIT
          DrawText( "Purchase ... processing", 20, 70 )
        Case STATE_AFTER_PURCHASE_QUERY
          DrawText( "Query Items", 20, 70 )
        Case STATE_AFTER_PURCHASE_QUERY_WAIT
          DrawText( "Query Items ... processing", 20, 70 )
        Case STATE_CONSUME
          DrawText( "Consume", 20, 70 )
        Case STATE_CONSUME_WAIT
          DrawText( "Consume ... processing", 20, 70 )
        Case STATE_RESTART
          DrawText( "Done ... Press To Restart", 20, 70 )
      End Select
  
      SetColor( 255, 255, 255 )
      If( Not _iap ) Then Return 0
      DrawText( "Purchased Title: " + _iap.getTitle( ITEM_ID ), 20, 150 )
      DrawText( "Purchased Price: " + _iap.getPrice( ITEM_ID ), 20, 170 )
      Local lr:Int = _iap.getLastResult()
      DrawText( "Result Desc: " + _iap.getResponseDescription( lr ), 20, 210 )
    PopMatrix()
    Return 0
  End Method
  
  'Helper method for same size on all devices independent from aspect ratio and device resolution
  Method checkForResolution:Void()
    _scaleRatioX = 1.0
    _scaleRatioY = 1.0
    _translateX = 0.0
    _translateY = 0.0
    Local fixWidth:Float = 320.0
    Local fixHeight:Float = 480.0
    'Aspect ratio
    Local dWidth:Float = Float( DeviceWidth() )
    Local dHeight:Float = Float( DeviceHeight() )
    Local aspectRatio:Float = dHeight / dWidth
    If( aspectRatio > 1.5 )
      _scaleRatioX = dWidth / fixWidth
      _scaleRatioY = dWidth / fixWidth
      _translateY = ( dHeight - fixHeight * _scaleRatioY ) / 2.0
    Else If( aspectRatio <= 1.5 )
      _scaleRatioX = dHeight / fixHeight
      _scaleRatioY = dHeight / fixHeight
      _translateX = ( dWidth - fixWidth * _scaleRatioX ) / 2.0
    End If
  End Method

End Class
