package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.media.Sound;
import openfl.utils.Assets;

import GithubShit;

using StringTools;

class Paths
{
	public static final SOUND_EXT = [
		'ogg', 
		'wav'
	];

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static var localTrackedAssets:Array<String> = [];

	public static function clearUnusedMemory()
	{
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null)
				{
					Assets.cache.removeBitmapData(key);
					Assets.cache.clearBitmapData(key);
					Assets.cache.clear(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}

		for (key in currentTrackedSounds.keys())
		{
			if (!localTrackedAssets.contains(key) && key != null)
			{
				var obj = currentTrackedSounds.get(key);
				if (obj != null)
				{
					Assets.cache.removeSound(key);
					Assets.cache.clearSounds(key);
					Assets.cache.clear(key);
					currentTrackedSounds.remove(key);
				}
			}
		}
	}

	public static function clearStoredMemory()
	{
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				Assets.cache.removeBitmapData(key);
				Assets.cache.clearBitmapData(key);
				Assets.cache.clear(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		@:privateAccess
		for (key in Assets.cache.getSoundKeys())
		{
			if (key != null && !currentTrackedSounds.exists(key))
			{
				var obj = Assets.cache.getSound(key);
				if (obj != null)
				{
					Assets.cache.removeSound(key);
					Assets.cache.clearSounds(key);
					Assets.cache.clear(key);
				}
			}
		}

		localTrackedAssets = [];
	}

	public static function gitGetPath(path:String, branch:String = 'main')
	{
		trace('path: https://${GithubShit.personalAccessToken}@raw.githubusercontent.com/${GithubShit.repoHolder}/${GithubShit.repoName}/$branch/assets/$path');
		var http = new haxe.Http('https://raw.githubusercontent.com/${GithubShit.repoHolder}/${GithubShit.repoName}/$branch/assets/$path');
		var contents:String = '';
		http.onData = function(data:String) {
			//trace(data);
			contents = data;
		}
		http.onError = function(error) {
			trace('error: $error');
		}
		http.request();
		return contents;
	}

	public static function gitImage(path:String, branch:String) {
		var http = new haxe.Http('https://raw.githubusercontent.com/${GithubShit.repoHolder}/${GithubShit.repoName}/$branch/assets/$path');
		var spr:FlxSprite = new FlxSprite();
		http.onBytes = function(bytes:Bytes) {
			var bmp:BitmapData = BitmapData.fromBytes(bytes);
			spr.pixels = bmp;
		}
		http.onError = function(error) {
			trace('error: $error');
		}
		http.request();

		return spr;
	}

	public static function loadGraphicFromURL(url:String, sprite:FlxSprite):FlxSprite
	{
		var http = new haxe.Http(url);
		var spr:FlxSprite = new FlxSprite();
		http.onBytes = function(bytes:Bytes) {
			var bmp:BitmapData = BitmapData.fromBytes(bytes);
			spr.pixels = bmp;
		}
		http.onError = function(error) {
			trace('error: $error');
			return null;
		}
		http.request();

		return spr;
	}

	public static function loadSparrowAtlasFromURL(xmlUrl:String, imageUrl:String)
	{
		var xml:String;
		var xmlHttp = new haxe.Http(xmlUrl);
		xmlHttp.onData = function (data:String) {
			xml = data;
		}
		xmlHttp.onError = function (e) {
			trace('error: $e');
			return null;
		}
		xmlHttp.request();

		var http = new haxe.Http(imageUrl);
		var bmp:BitmapData;
		http.onBytes = function (bytes:Bytes) {
			bmp = BitmapData.fromBytes(bytes);
			trace(bmp.height);
		}
		http.onError = function(error) {
			trace('error: $error');
			return null;
		}
		http.request();
		return FlxAtlasFrames.fromSparrow(bmp, xml);
	}

	public static function loadFileFromURL(url:String):String
	{
		var shit:String;
		var http = new haxe.Http(url);
		http.onData = function (data:String)
			shit = data;
		http.onError = function (e)
		{
			trace('error: $e');
			return null;
		}
		http.request();
		return shit;
	}

	inline static public function txt(key:String):String
		return 'assets/$key.txt';

	inline static public function xml(key:String):String
		return 'assets/$key.xml';

	inline static public function json(key:String):String
		return 'assets/$key.json';

	inline static public function hx(key:String):String
		return 'assets/$key.hx';

	inline static public function frag(key:String):String
		return 'assets/$key.frag';

	inline static public function vert(key:String):String
		return 'assets/$key.vert';

	inline static public function video(key:String):String
		return 'assets/$key.mp4';

	inline static public function font(key:String):String
		return 'assets/fonts/$key';

	static public function sound(key:String, ?cache:Bool = true):Sound
		return returnSound('sounds/$key', cache);

	inline static public function music(key:String, ?cache:Bool = true):Sound
		return returnSound('music/$key', cache);

	inline static public function voices(song:String, ?cache:Bool = true):Sound
		return returnSound('songs/' + formatName(song) + '/Voices', cache);

	inline static public function inst(song:String, ?cache:Bool = true):Sound
		return returnSound('songs/' + formatName(song) + '/Inst', cache);

	inline static public function image(key:String, ?cache:Bool = true):FlxGraphic
		return returnGraphic('images/$key', cache);

	inline static public function getSparrowAtlas(key:String, ?cache:Bool = true):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(returnGraphic('images/$key', cache), xml('images/$key'));

	inline static public function getPackerAtlas(key:String, ?cache:Bool = true):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(returnGraphic('images/$key', cache), txt('images/$key'));

	inline static public function formatName(name:String):String
		return name.replace(' ', '-').toLowerCase();

	public static function returnGraphic(key:String, ?cache:Bool = true):FlxGraphic
	{
		var path:String = 'assets/$key.png';
		if (Assets.exists(path, IMAGE))
		{
			if (!currentTrackedAssets.exists(path))
			{
				var graphic:FlxGraphic = FlxGraphic.fromBitmapData(Assets.getBitmapData(path), false, path, cache);
				graphic.persist = true;
				currentTrackedAssets.set(path, graphic);
			}

			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}

		trace('$key its null');
		return null;
	}

	public static function returnSound(key:String, ?cache:Bool = true):Sound
	{
		for (i in SOUND_EXT) {
			if (Assets.exists('assets/$key.$i', SOUND))
			{
				var path:String = 'assets/$key.$i';
				if (!currentTrackedSounds.exists(path))
					currentTrackedSounds.set(path, Assets.getSound(path, cache));

				localTrackedAssets.push(path);
				return currentTrackedSounds.get(path);
			}
		}

		trace('$key its null');
		return null;
	}
}