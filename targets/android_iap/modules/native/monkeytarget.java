
class BBMonkeyGame extends BBAndroidGame{

	public BBMonkeyGame( AndroidGame game,AndroidGame.GameView view ){
		super( game,view );
	}
}

public class MonkeyGame extends AndroidGame{

  static IAPWrapper _iapWrapper;
  
  public static IAPWrapper InitIAP( String key )
  {
    if( _iapWrapper == null )
    {
      _iapWrapper = new IAPWrapper();
      _iapWrapper._isInitialized = false;
      Activity activity = BBAndroidGame.AndroidGame().GetActivity();
      _iapWrapper._helper = new IabHelper( activity, key );

      _iapWrapper._helper.startSetup( new IabHelper.OnIabSetupFinishedListener()
      {
        public void onIabSetupFinished( IabResult result )
        {
          if( result.isSuccess() )
            _iapWrapper._isInitialized = true;
        }
      } );
    }
      
    return _iapWrapper;
  }
  
	public static class GameView extends AndroidGame.GameView{

		public GameView( Context context ){
			super( context );
		}
		
		public GameView( Context context,AttributeSet attrs ){
			super( context,attrs );
		}
	}
	
	@Override
	public void onCreate( Bundle savedInstanceState ){
		super.onCreate( savedInstanceState );
		
		setContentView( R.layout.main );
		
		_view=(GameView)findViewById( R.id.gameView );
		
		_game=new BBMonkeyGame( this,_view );
		
		try{
				
			bb_.bbInit();
			bb_.bbMain();
			
		}catch( RuntimeException ex ){

			_game.Die( ex );

			finish();
		}

		if( _game.Delegate()==null ) finish();
		
		_game.Run();
	}

  @Override
  protected void onActivityResult(int requestCode, int resultCode, Intent data)
  {
    if( _iapWrapper == null )
      return;
    // Pass on the activity result to the helper for handling
    else if( !_iapWrapper._helper.handleActivityResult( requestCode, resultCode, data ) )
    {
      // not handled, so handle it ourselves (here's where you'd
      // perform any handling of activity results not related to in-app
      // billing...
      super.onActivityResult( requestCode, resultCode, data );
    }
  }

  @Override
  public void onDestroy()
  {
    super.onDestroy();

    // very important:
    if( _iapWrapper._helper != null )
      _iapWrapper._helper.dispose();
    _iapWrapper._helper = null;
  } 
};
