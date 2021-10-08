
	
ps:
	iverilog -g2012 -o synthesis/pixelSensor -c pixelSensor.fl
	vvp -n synthesis/pixelSensor

pa:
	iverilog -g2012 -o synthesis/pixelArray -c pixelArray.fl
	vvp -n synthesis/pixelArray

pac:
	iverilog -g2012 -o synthesis/pixelArrayCounter -c pixelArrayCounter.fl
	vvp -n synthesis/pixelArrayCounter

pab:
	iverilog -g2012 -o synthesis/pixelArrayBus -c pixelArrayBus.fl
	vvp -n synthesis/pixelArrayBus

clean:
	-rm synthesis/pixelArray
	-rm synthesis/pixelArrayCounter
	-rm synthesis/pixelSensor
	-rm synthesis/pixelArrayBus
	-rm simulation/*.vcd
	-rm simulation/*.gtkw

all:
	${MAKE} ps
	${MAKE} pac
	${MAKE} pa
	
