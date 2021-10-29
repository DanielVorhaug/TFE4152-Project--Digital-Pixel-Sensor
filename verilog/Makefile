
	
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

parp:
	iverilog -g2012 -o synthesis/pixelArrayReadPointer -c pixelArrayReadPointer.fl
	vvp -n synthesis/pixelArrayReadPointer

pamc:
	iverilog -g2012 -o synthesis/pixelArrayMemoryController -c pixelArrayMemoryController.fl
	vvp -n synthesis/pixelArrayMemoryController

pstate:
	iverilog -g2012 -o synthesis/pixelState -c pixelState.fl
	vvp -n synthesis/pixelState

psfsm:
	iverilog -g2012 -o synthesis/pixelSensorFsm -c pixelSensorFsm.fl
	vvp -n synthesis/pixelSensorFsm

ysfsm:	# This might need changes as we changed the folder structure from Wulferns project
	yosys pixelSensorFsm.ys
	dot pixelSensorFsm.dot -Tpng > pixelSensorFsm.png

synth:
	yosys pixelArrayCounter.ys
	dot pixelArrayCounter.dot -Tpng > pixelArrayCounter.png

clean:
	-rm synthesis/pixelArray
	-rm synthesis/pixelArrayCounter
	-rm synthesis/pixelSensor
	-rm synthesis/pixelArrayReadPointer
	-rm synthesis/pixelArrayBus
	-rm synthesis/pixelArrayMemoryController
	-rm synthesis/pixelState
	-rm simulation/*.vcd
	-rm simulation/*.gtkw

all:
	${MAKE} ps
	${MAKE} pac
	${MAKE} pa
	
