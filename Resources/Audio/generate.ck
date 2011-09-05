"/Users/hannahkloidt/Documents/" => string path;
440 / 10 => int freq;

SinOsc sin => WvOut sinOut => blackhole;
SqrOsc sqr => WvOut sqrOut => blackhole;
TriOsc tri => WvOut triOut => blackhole;
SawOsc saw => WvOut sawOut => blackhole;

freq => sin.freq => sqr.freq => tri.freq => saw.freq;

path + "Sine.aif" => sinOut.aifFilename;
path + "Square.aif" => sqrOut.aifFilename;
path + "Triangle.aif" => triOut.aifFilename;
path + "Sawtooth.aif" => sawOut.aifFilename;

(1.0/freq)::second + now => now;

"close" => sinOut.closeFile;
"close" => sqrOut.closeFile;
"close" => triOut.closeFile;
"close" => sawOut.closeFile;