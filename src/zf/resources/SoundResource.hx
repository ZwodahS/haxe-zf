package zf.resources;

/**
	Individual sound.
**/
typedef SoundConf = {
	/**
		The name for the sound. Usually unused
	**/
	public var ?name: String;

	/**
		The path to load the ogg
	**/
	public var ?ogg: String;

	/**
		Pitch Effect
	**/
	public var ?pitch: Float;

	/**
		Volume
	**/
	public var ?volume: Float;
}

typedef SoundResourceConf = {
	/**
		Identifier for the sound
	**/
	public var id: String;

	/**
		The sounds in this sound
		Each "sound" can have multiple sound in it to provide variety
	**/
	public var items: Array<SoundConf>;
}

class Sound {
	public var name: String = null;
	public var ogg: hxd.res.Sound;
	public var pitch: Null<Float>;
	public var volume: Float = 1;

	public function new() {}

	public function play(loop: Bool, channelGroup: hxd.snd.ChannelGroup,
			soundGroup: hxd.snd.SoundGroup): hxd.snd.Channel {
		if (this.ogg != null && hxd.res.Sound.supportedFormat(OggVorbis)) {
			final chan = this.ogg.play(loop, this.volume, channelGroup, soundGroup);
			if (this.pitch != null) {
				var effect = new hxd.snd.effect.Pitch(this.pitch);
				chan.addEffect(effect);
			}
			return chan;
		}
		return null;
	}
}

/**
	A wrapper around sound
**/
class SoundResource {
	public var id: String;
	public var items: Array<Sound>;

	public function new(id: String) {
		this.id = id;
		this.items = [];
	}

	public function play(loop: Bool, channelGroup: hxd.snd.ChannelGroup,
			soundGroup: hxd.snd.SoundGroup): hxd.snd.Channel {
		if (this.items.length == 1) return items[0].play(loop, channelGroup, soundGroup);
		if (this.items.length == 0) return null;
		final s = this.items[Globals.game.r.random(this.items.length)];
		return s.play(loop, channelGroup, soundGroup);
	}
}
