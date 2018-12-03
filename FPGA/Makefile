PROJ = top
TOP = top
PIN_DEF = pinmap.pcf
DEVICE = hx1k

all: $(PROJ).rpt $(PROJ).bin

%.blif: %.v
	yosys -p 'synth_ice40 -top $(TOP) -blif $@' $<

%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) -o $@ -p $^ -P vq100

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d $(DEVICE) -mtr $@ $<

iceprogduino: $(PROJ).bin
	iceprogduino $<


%_padded.bin: $(PROJ).bin
	rm -f $(PROJ)_padded.bin
	dd if=/dev/zero of=$(PROJ)_padded.bin bs=2097152 count=1
	dd if=$(PROJ).bin of=$(PROJ)_padded.bin conv=notrunc

flashrombp: $(PROJ)_padded.bin
	flashrom -p buspirate_spi:dev=/dev/ttyUSB0 -w $(PROJ)_padded.bin

flashrom: $(PROJ)_padded.bin
	flashrom -p ft2232_spi:type=2232H,port=A -n -w $(PROJ)_padded.bin
	
flashrompk2: $(PROJ)_padded.bin
	sudo flashrom -p pickit2_spi -n -w $(PROJ)_padded.bin

plot:
	yosys -s plot1.ys
	yosys -s plot2.ys
	yosys -s plot3.ys

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).bin $(PROJ).rpt $(PROJ)_padded.bin

.PHONY: all prog clean
