// Android In App Purchase
//
// Copyright 2013 Martin Leidel, all rights reserved.
//
// This software is provided 'as-is', without any express or implied
// warranty.  In no event will the authors be held liable for any damages
// arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose,
// including commercial applications, and to alter it and redistribute it
// freely, subject to the following restrictions:
//
// 1. The origin of this software must not be misrepresented; you must not
// claim that you wrote the original software. If you use this software
// in a product, an acknowledgment in the product documentation would be
// appreciated but is not required.
// 2. Altered source versions must be plainly marked as such, and must not be
// misrepresented as being the original software.
// 3. This notice may not be removed or altered from any source distribution.

class IAPWrapper
{
  public IabHelper _helper;
  private Inventory _inventory;
  private IabResult _lastResult;
  public boolean _isInitialized = false;
  private boolean _isPurchasedItemsQueryFinished = false;
  private boolean _isConsumeFinished = false;
  private boolean _isPurchaseFinished = false;

  public boolean isInitialized()
  {
    return _isInitialized;
  }
  
  public int getLastResult()
  {
    int res = -1;
    if( _lastResult != null )
      res = _lastResult.getResponse();
    return res;
  }
  
  public String getResponseDescription( int code )
  {
    if( _helper != null )
      return _helper.getResponseDesc( code );
    return "";
  }
 
  public void queryPurchasedItems()
  {
    if( !_isInitialized )
      return;
    
    _isPurchasedItemsQueryFinished = false;
    _helper.queryInventoryAsync( _gotInventoryListener );
  }

  public boolean isQueryForPurchasedItemsFinished()
  {
    return _isPurchasedItemsQueryFinished;
  }
  
  public boolean hasBeenPurchased( String itemId )
  {
    if( !_isInitialized || !_isPurchasedItemsQueryFinished )
      return false;
    
    if( _inventory != null )
      return _inventory.hasPurchase( itemId );
    return false;
  }
  
  public boolean consume( String itemId )
  {
    if( _inventory != null )
    {
      Purchase p = _inventory.getPurchase( itemId );
      if( p != null )
      {
        _isConsumeFinished = false;
        _helper.consumeAsync( p, _consumeFinishedListener );
        return true;
      }
    }
    return false;
  }
  
  public boolean isConsumeFinished()
  {
    return _isConsumeFinished;
  }

  public void purchase( String itemId, String payload )
  {
    _isPurchaseFinished = false;
    Activity activity = BBAndroidGame.AndroidGame().GetActivity();
    _helper.launchPurchaseFlow( activity, itemId, 10001, _purchaseFinishedListener, payload );
  }

  public boolean isPurchaseFinished()
  {
    return _isPurchaseFinished;
  }

  public String getPrice( String itemId )
  {
    String price = "";
    if( _inventory != null )
    {
      SkuDetails sku = _inventory.getSkuDetails( itemId );
      if( sku != null )
        price = sku.getPrice();
    }
    return price;
  }

  public String getTitle( String itemId )
  {
    String title = "";
    if( _inventory != null )
    {
      SkuDetails sku = _inventory.getSkuDetails( itemId );
      if( sku != null )
        title = sku.getTitle();
    }
    return title;
  }
  
  public String getDescription( String itemId )
  {
    String desc = "";
    if( _inventory != null )
    {
      SkuDetails sku = _inventory.getSkuDetails( itemId );
      if( sku != null )
        desc = sku.getDescription();
    }
    return desc;
  }

  /**
   * ------------------------------------------------------------------------------------------------------------
   */

  IabHelper.QueryInventoryFinishedListener _gotInventoryListener = new IabHelper.QueryInventoryFinishedListener()
  {
    public void onQueryInventoryFinished( IabResult result, Inventory inventory )
    {
      _lastResult = result;
      if( result.isFailure() )
      {
        // handle error here
        _isPurchasedItemsQueryFinished = false;
      }
      else
      {
        _inventory = inventory;
        _isPurchasedItemsQueryFinished = true;
      }
    }
  };

  // Called when consumption is complete
  IabHelper.OnConsumeFinishedListener _consumeFinishedListener = new IabHelper.OnConsumeFinishedListener()
  {
    public void onConsumeFinished( Purchase purchase, IabResult result )
    {
      _lastResult = result;
      if( result.isSuccess() )
        _isConsumeFinished = true;
      else
        _isConsumeFinished = false;
    }
  };

  // Callback for when a purchase is finished
  IabHelper.OnIabPurchaseFinishedListener _purchaseFinishedListener = new IabHelper.OnIabPurchaseFinishedListener()
  {
    public void onIabPurchaseFinished( IabResult result, Purchase purchase )
    {
      _lastResult = result;
      if( result.isSuccess() )
        _isPurchaseFinished = true;
      else
        _isPurchaseFinished = false;
    }
  };
};
