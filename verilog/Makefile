
ps:
	iverilog -g2012 -o pixelSensor -c pixelSensor.fl
	vvp -n pixelSensor

pa:
	iverilog -g2012 -o pixelArray -c pixelArray.fl
	vvp -n pixelArray

clean:
	-rm pixelArray
	-rm pixelArray_tb.vcd
	-rm pixelSensor_tb.vcd
	-rm pixelSensor_tb.gtkw
	