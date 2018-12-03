import spidev, time
spi = spidev.SpiDev()
spi.open(0,0)
spi.max_speed_hz = 1000

def reset():
  spi.xfer2([0x00, 0x00, 0x00, 0x00])
  spi.xfer2([0x00, 0x00, 0x00, 0x01])

def setLed(led):
  return spi.xfer2([0x00, 0x00, 0x00, 0x03 + ((led&0x0F)<<2)])

def setMotor(hi, lo):
  return spi.xfer2([0x00, 0x00, (lo&0x01), 0x01 + (0x01<<6) + ((hi&0x01)<<7)])

def readTacho():
  spi.xfer2([0x00, 0x00, 0x02, 0x01])
  data = spi.xfer2([0x00, 0x00, 0x00, 0x01])
  return int.from_bytes(data, byteorder='big', signed=True)

def readStatus():
  return spi.xfer2([0x00, 0x00, 0x00, 0x01]);

print("Reset...")
reset()
setLed(1)
time.sleep(0.1)
setLed(2)
time.sleep(0.1)
setLed(4)
time.sleep(0.1)
setLed(8)
time.sleep(0.1)
setLed(0)

position = 0

setMotor(True, True)

prevTime = 0
prevPosition = 0
interval = 0.05

history = [0]*round(1/0.01)

while True:
  curTime = time.time()

  if (curTime - prevTime >= interval):
    prevTime = curTime
    change = readTacho()
    position = position + change
    rpm = (change/112)*(60/interval);

    history.pop(0)
    history.append(change)

    meanChange = sum(history)/len(history)
    meanRpm = (meanChange/112)*(60/interval);

    print("RPM: "+str(round(rpm)).zfill(3)+"\t RPM (mean last second): "+str(round(meanRpm)).zfill(3)+"\t Absolute position: "+str(position))
