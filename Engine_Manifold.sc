Engine_Manifold : CroneEngine {

	var delaybuffer;
	var <>fadetime = 5;
	var input, delay, ampmod, pitchshift, freeze;

	*new { arg context, doneCallback;
		^super.new(context, doneCallback);
	}

	alloc {
		//Buffer for Delay
		delaybuffer = Buffer.alloc(Server.default, 15*48000, 1);//change max delaytime here (15 secs)

		//Add NodeProxies
		//Audio Input
		input = NodeProxy.new(context.server, \audio, 1);
		input.source = {In.ar(Mix.ar([context.in_b[0].index,context.in_b[1].index]))};

    //Crossfading Delay to avoid pitch shifts during delaytime changes
		delay = NodeProxy.new(context.server, \audio, 1);
		delay.source = {
			var local = LocalIn.ar(1) + input.ar(1);
			var select = ToggleFF.kr(\toggle.tr(1.neg));
			var delay1 = BufDelayL.ar(delaybuffer, local, Latch.kr(\time.kr(1), 1- select));
			var delay2 = BufDelayL.ar(delaybuffer, local, Latch.kr(\time.kr(1), select));
			var fade = MulAdd.new(Lag2.kr(select, 0.1), 2, 1.neg);
			var delay = XFade2.ar(delay1, delay2, fade);
			LocalOut.ar(delay * \feedback.kr(0.5));
			(delay!2)*\volume.kr(1);
		};

    //Amplitude Modulation with Triangle Wave and Gate
		ampmod = NodeProxy.new(context.server, \audio, 1);
		ampmod.source = {
			var off = Lag2.kr(A2K.kr(DetectSilence.ar(input.ar(1),0.05),0.3));
            var on = 1-off;
			var fade = MulAdd.new(on, 2, 1.neg);
			var out = XFade2.ar(Silent.ar(), input.ar(1), fade);
			var tri = LFTri.ar(\freq.ar(7), 0).unipolar;
		 	var am = out*tri*\volume.kr(1);
			am!2;
		};

		//Granular Pitchshifter
		pitchshift = NodeProxy.new(context.server, \audio, 1);
		pitchshift.source = {
		  var pitch = PitchShift.ar(input.ar(1), 0.2, \rate.kr(2.0));
		  (pitch!2)*\volume.kr(1.0);
		  };

		//FFT-based Freeze
		freeze = NodeProxy.new(context.server, \audio, 1);
		freeze.source = {
	    var chain = FFT(LocalBuf(1024), input.ar(1));
    	chain = PV_Freeze(chain, \freeze.kr(0));
      (IFFT(chain)!2)*\volume.kr(0,0.1)*\mastervol.kr(1)
    };

		context.server.sync;

		this.addCommand("delay", "i", {|msg|
			if(msg[1]==2,{delay.play},{delay.stop});
		});

		this.addCommand("delaytime", "f", {|msg|
			delay.set(\time, msg[1], \toggle, 1);
		});

		this.addCommand("delayfeedback", "f", {|msg|
			delay.set(\feedback, msg[1]);
		});

		this.addCommand("delayvolume", "f", {|msg|
			delay.set(\volume, msg[1]);
		});

		this.addCommand("ampmod", "i", {|msg|
			if(msg[1]==2,{ampmod.play},{ampmod.stop});
		});

		this.addCommand("ampmodvolume", "f", {|msg|
			ampmod.set(\volume, msg[1]);
		});

		this.addCommand("ampmodfreq", "f", {|msg|
			ampmod.set(\freq, msg[1]);
		});

		this.addCommand("pitchshift", "i", {|msg|
			if(msg[1]==2,{pitchshift.play},{pitchshift.stop});
		});

		this.addCommand("pitchshiftvolume", "f", {|msg|
			pitchshift.set(\volume, msg[1]);
		});

		this.addCommand("pitchshiftrate", "f", {|msg|
			pitchshift.set(\rate, msg[1]);
		});

		this.addCommand("freeze", "f", {|msg|
			if(msg[1]==1,{freeze.set(\freeze, 0, \volume, 0);freeze.stop;},{freeze.play;freeze.set(\freeze, 1, \volume, 1)});
		});

		this.addCommand("freezevolume", "f", {|msg|
			freeze.set(\mastervol, msg[1]);
		});
	}

	free {
    input.free;delay.free;ampmod.free;pitchshift.free;freeze.free;
	}

}
