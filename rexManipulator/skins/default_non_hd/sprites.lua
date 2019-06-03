sprites = {
	sprite_0 = "/assetmissing.png?crop=;0;0;1;1?setcolor=fff?replace;0000=0a00;fff0=0a00;fff=0a00?scalenearest=2?blendscreen=/objects/outpost/customsign/signplaceholder.png?replace;01aa0000=80aa0000;00aa0100=00aa8000;01aa0100=80aa8000?scale=128;128?crop=0;0;12;11?replace;04aa0200=404040;04aa0300=404040;04aa0400=404040;05aa0200=808080;05aa0300=808080;05aa0400=808080;05aa0500=404040;05aa0600=404040;05aa0700=404040;05aa0800=404040;06aa0500=808080;06aa0600=808080;06aa0700=808080;06aa0800=404040",
	sprite_1 = "/assetmissing.png?crop=;0;0;1;1?setcolor=fff?replace;0000=0a00;fff0=0a00;fff=0a00?scalenearest=2?blendscreen=/objects/outpost/customsign/signplaceholder.png?replace;01aa0000=80aa0000;00aa0100=00aa8000;01aa0100=80aa8000?scale=128;128?crop=0;0;12;11?replace;06aa0100=663b14;06aa0200=663b14;06aa0800=663b14;06aa0900=663b14;07aa0000=663b14;07aa0100=8d581c;07aa0200=8d581c;07aa0300=663b14;07aa0700=663b14;07aa0800=8d581c;07aa0900=8d581c;07aa0a00=8d581c;08aa0000=8d581c;08aa0100=c88b28;08aa0200=e7c474;08aa0300=663b14;08aa0400=663b14;08aa0600=663b14;08aa0700=663b14;08aa0800=e7c474;08aa0900=6d0103;08aa0a00=663b14;09aa0000=8d581c;09aa0100=c88b28;09aa0200=c88b28;09aa0300=e7c474;09aa0400=404040;09aa0500=404040;09aa0600=404040;09aa0700=e7c474;09aa0800=028020;09aa0900=c88b28;09aa0a00=663b14;0aaa0100=8d581c;0aaa0200=c88b28;0aaa0300=e7c474;0aaa0400=808080;0aaa0600=808080;0aaa0700=e7c474;0aaa0800=c88b28;0aaa0900=8d581c;0baa0200=8d581c;0baa0300=8d581c;0baa0400=8d581c;0baa0600=8d581c;0baa0700=8d581c;0baa0800=8d581c",
	sprite_2 = "/assetmissing.png?crop=;0;0;1;1?setcolor=fff?replace;0000=0a00;fff0=0a00;fff=0a00?scalenearest=2?blendscreen=/objects/outpost/customsign/signplaceholder.png?replace;01aa0000=80aa0000;00aa0100=00aa8000;01aa0100=80aa8000?scale=128;128?crop=0;0;12;11?replace;09aa0800=02da37",
	sprite_3 = "/assetmissing.png?crop=;0;0;1;1?setcolor=fff?replace;0000=0a00;fff0=0a00;fff=0a00?scalenearest=2?blendscreen=/objects/outpost/customsign/signplaceholder.png?replace;01aa0000=80aa0000;00aa0100=00aa8000;01aa0100=80aa8000?scale=128;128?crop=0;0;12;11?replace;00aa0800=663b14;00aa0900=663b14;00aa0a00=663b14;01aa0700=663b14;01aa0800=c88b28;01aa0900=c88b28;01aa0a00=663b14;02aa0700=663b14;02aa0800=c88b28;02aa0900=8d581c;02aa0a00=8d581c;03aa0700=663b14;03aa0800=c88b28;03aa0900=8d581c;03aa0a00=663b14;04aa0700=663b14;04aa0800=c88b28;04aa0900=8d581c;04aa0a00=8d581c;05aa0700=663b14;05aa0800=c88b28;05aa0900=e7c474;05aa0a00=663b14;06aa0700=663b14;06aa0800=8d581c;06aa0900=8d581c;06aa0a00=8d581c",
	sprite_4 = "/assetmissing.png?crop=;0;0;1;1?setcolor=fff?replace;0000=0a00;fff0=0a00;fff=0a00?scalenearest=2?blendscreen=/objects/outpost/customsign/signplaceholder.png?replace;01aa0000=80aa0000;00aa0100=00aa8000;01aa0100=80aa8000?scale=128;128?crop=0;0;12;11?replace;0a00=663b14;00aa0100=663b14;00aa0200=663b14;01aa0000=663b14;01aa0100=808080;01aa0200=e7c474;01aa0300=663b14;02aa0000=663b14;02aa0100=404040;02aa0200=e7c474;02aa0300=663b14;03aa0000=663b14;03aa0100=808080;03aa0200=e7c474;03aa0300=663b14;04aa0000=663b14;04aa0100=404040;04aa0200=e7c474;04aa0300=663b14;05aa0000=663b14;05aa0100=e7c474;05aa0200=e7c474;05aa0300=663b14;06aa0000=663b14;06aa0100=8d581c;06aa0200=8d581c;06aa0300=663b14",
}

for i,v in pairs(sprites) do
	animator.setGlobalTag(i,v)
end

sprites = nil