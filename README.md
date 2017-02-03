# Remex

This core is still experimental and exploratory in nature.

This core is given the preliminary KCP part number: KCP53005.

## Introduction

Porting the Kestrel-3 to the icoBoard Gamma FPGA board,
which uses the iCE40HX8K FPGA,
or to the myStorm BlackIce board,
which uses the iCE40HX4K part,
effectively prevents the use of keyboards, mice, SD cards, and other peripherals
without 3rd-party attachments.
Even with these attachments,
the number of LUT resources on the FPGA itself
remains quite limited,
preventing substantial growth of the computer's I/O capabilities.
You can probably fit a pair of PS/2 controllers and monochrome video on the chip,
but it's unlikely you'll also fit cache controllers,
MMUs and page table walkers,
or decent quality audio capabilities on the same FPGA chip.

To address this, I decided to devote the FPGA core purely to *computing*.
It, of course, will need to talk to the outside world;
as a bare minimum,
it'll need a terminal,
it'll need mass storage,
it'll need access to on-board RAM,
and, it'll need a means of performing **Initial Program Load** (IPL).
Moreover, it needs to do this with an absolute minimum of LUTs taken up by I/O,
since we *really* want most of the LUTs to be used by the CPU.

## Why Not Use \_\_\_\_\_\_\_\_?

### SPI

SPI is out, because of its strict master/slave relationship.
To support *asynchronous* bidirectional traffic flow,
you need more than 5 wires (GND, SS, MOSI, MISO, CLK, and IRQ),
which prevents use with a single 1x6 PMOD port.
Even when responding to a device interrupt,
the master must instruct the slave to explicitly send its data.

If you want hot-swap capabilities,
you'll need a sixth signal, for "device detect."
This is because Pmod ports are not designed with hot-swap in mind.

The master must have prior knowledge of the device's characteristics,
or must negotiate them.
In particular, it will need to know or discover:

* Minimum and maximum bit rate.
* MSB-first or LSB-first.
* Minimum inter-character gap.
* Minimum inter-frame gap.
* Is the Kestrel the master, or is the device the master?
* Is the payload 5-bits, 8-bits, 11-bits, 14-bits, 16-bits, 20-bits, or something else all-together?  Not all SPI devices are based on octets!

When interfacing to an MCU,
you'll often have limited SPI resources.
It's not inconceivable that you'd want an SPI interface to talk to the Kestrel,
and an SPI interface to talk to, e.g., SDHC cards, DACs, etc.
You can bit-bang one or more SPI interfaces easily enough.
However, you'll only ever achieve maximum performance on (typically) one of them.
The others will typically be bit-banged.

SPI also has a *very* complicated relationship with DMA-driven controllers.
Some controllers opt to control the SS pin, others don't.
How to handle reads, writes, or exchanges also differs from vendor to vendor.
For example, trying to implement a DMA-fed channel controller to implement the SD protocol
demonstrates to the practitioner the complexities involved.
If you succeed, you'll also note the loss of generality to other kinds of SPI devices.
There is no happy medium.

Looking to the future, mapping RapidIO to SPI is possible, albeit with extensive effort.

### I2C

I2C is out for several reasons,
but the biggest one is that it's just too slow
to be useful for things like bitmapped terminals and mass storage in interactive systems.
Another reason is that Phillips won't let people develop their own I2C slaves because
Phillips and Phillips alone controls the address space.
The address space is also quite limited.

I2C seems fundamentally incompatible with RapidIO,
due in large part to the preference for very small frames.
You'll need to use an adaptation layer in between I2C and RapidIO to make it work,
which just adds to the latency and overall system complexity.

### RS-232, RS-485, et. al.

(Collectively treated as RS-232.)

RS-232 is another option, and one that is quite popular in most hacker communities.
However, my own experience with RS-232 is not very good.
Former experiments getting RS-232 to function between two Arduino microcontrollers
resulted in very high BER for seemingly inexplicable reasons.
I was never able to diagnose the problem formally,
leading me to have to use a packet-switching framework on top of it.
This kind of defeated the purpose at the time.

Most recently, I researched what it would take to couple my PC to the icoBoard via RS-232:

* USB cable terminated with an FTDI RS-232 converter chip: $15.
* Digilent USB Pmod adapter: $15.
* CTS/RTS support: cable supports it; but, the USB Pmod only supports XON/XOFF handshaking, for it doesn't expose CTS/DTS pins to the Pmod interface.

RS-232 also suffers the disadvantage that the computer must pre-configure the port with baud rates and such.

RapidIO doesn't seem to be compatible with RS-232 either, at least without layering something like PPP or SLIP on top first.
Again, more complexity than I'd like.

## Why IEEE-1355 as the basis for Remex?

* A single Remex port consists of *five* wires: GND, DI, SI, DO, SO.
    * DI and SI are the data and strobe inputs from somewhere else.
    * DO and SO are the data and strobe outputs to somewhere else.
    * A board with a single 2x6 Pmod connector can support *two* Remex channels.
* Remex links are point-to-point: DI/SI of one port connects to DO/SO on the peer, and vice versa.
* Uses 3.3V logic levels, just like Pmod ports are specified to be.
* Line protocol clearly demarcates end of packets for efficient packet switching.  This makes future RapidIO upgrades possible later on.
* Spacewire packet semantics, particularly source-routing, supports effectively infinite expansion opportunities.
* Receivers are clocked by the transmitting peer; no need to auto-negotiate or hard-wire baud rates ahead of time.
* Peer-to-peer: attached devices do not need permission from the master to start transmitting.
* **Credit-based flow control:** Transmitters assume the peer's receive buffer is full unless told otherwise.  A single flow-control token is good for eight bytes.  To help prevent stuttering, a device can send up to seven FCTs in a batch.  Easier than XON/XOFF tracking, RR/RNR exchanges in (A)X.25, and yet still cheaper than CTS/RTS due to fewer wires needed.
* Link disconnect detection allows for hot-swapping without dedicated wires for this purpose.  Just make sure GND connects first.
* Negotiated parameters is reduced to a minimum, and even then, only for the benefit of bit-banged I/O on MCUs: maximum transmission speed supported.  Everything else is either automatic or irrelevant for the link to work.  It should be noted that, given hardware controllers on either end, even *this* requirement is obviated.
* Cheap to implement:
    * Bit-banging in an MCU is straight-forward, and consumes minimal program space.
    * Hardware implementations require not much more logic than any other RS-232 UART.
* First-class support for packets enables easier DMA engines than SPI or RS-232.

*(Commentary: it honestly baffles me why this technology didn't become more dominant in the microcontroller world.  This technology seems quite the no-brainer compared to RS-232 or SPI.)*

