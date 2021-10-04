
	
ps:
	iverilog -g2012 -o synthesis/pixelSensor -c pixelSensor.fl
	vvp -n synthesis/pixelSensor

pa:
	iverilog -g2012 -o synthesis/pixelArray -c pixelArray.fl
	vvp -n synthesis/pixelArray

pac:
	iverilog -g2012 -o synthesis/pixelArrayCounter -c pixelArrayCounter.fl
	vvp -n synthesis/pixelArrayCounter

clean:
	-rm synthesis/pixelArray
	-rm simulation/pixelArray_tb.vcd
	-rm synthesis/pixelSensor
	-rm simulation/pixelSensor_tb.vcd
	-rm simulation/pixelSensor_tb.gtkw

all:
	${MAKE} ps
	${MAKE} pa
	${MAKE} pac
