"~/chuck/" => string path;
1 => int seconds;

SinOsc sin => WvOut sinOut => blackhole;
SqrOsc sqr => WvOut sqrOut => blackhole;
TriOsc tri => WvOut triOut => blackhole;
SawOsc saw => WvOut sawOut => blackhole;

path + "Sine" + seconds + "s.aif" => sinOut.aifFilename;
path + "Square" + seconds + "s.aif" => sqrOut.aifFilename;
path + "Triangle" + seconds + "s.aif" => triOut.aifFilename;
path + "Sawtooth" + seconds + "s.aif" => sawOut.aifFilename;

seconds::second + now => now;

"close" => sinOut.closeFile;
"close" => sqrOut.closeFile;
"close" => triOut.closeFile;
"close" => sawOut.closeFile;