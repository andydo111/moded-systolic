# moded-systolic
Systolic array with modified MAC units.

The MAC unit features a Vedic Multiplier and a Carry Select Adder (CLSA).

The reason for these modifications is because they work well for machine learning applications. The Vedic multiplier and the clsa in theory could perform better than a regular array multiplier and a ripple carry adder, in terms of efficiency. ML accelerators are usually not compute bound, so we don’t need the fastest, therefore a multiplier like the Vedic Multiplier is the sweet spot. Similarly for the adder, the CLSA is faster than a ripple carry adder, but it's not the fastest adder, but it requires less area.


For power, timing, and area analysis, I used Synopsys Design Vision at 45nm and 90nm. Compared to a regular MAC, my modified mac has better timing at 90nm, but not by much. And unfortunately, it’s slower than a reg MAC at 45nm.

Since there was extra circuitry, power and area for both 90nm and 45nm increase. But like mentioned before, the additional area and power consumption should not be a lot. And the result is consistent with that.


The MAC has an extra register that holds the value of its input and pass that valur through so I could daisy chain them to make a systolic array. This way, the input is only read once from the memory and trickles down the whole array. The size of the array is 9x9, it can be used to multiply 2 9x9 matrices together.
