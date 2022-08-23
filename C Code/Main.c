/*
 * Real-time Audio Equalizer Implementation in C and Assembly
 */

#include <usbstk5515.h>
#include <usbstk5515_i2c.h>
#include <AIC_func.h>
#include <stdio.h>
#include <fir.h>
#include <Dsplib.h>
#include <tms320.h>
#include <sar.h>

Int16 coef[TAPS] = {
#include "lpf.dat"
};

// Addresses of the MMIO for the GPIO out registers: 1,2
#define LED_OUT1 ((*ioport volatile * Uint16)(0x1C0A))
#define LED_OUT2 ((*ioport volatile * Uint16)(0x1C0B))

// Addresses of the MMIO for the GPIO direction registers: 1,2
#define LED_DIR1 ((*ioport volatile * Uint16)(0x1C06))
#define LED_DIR2 ((*ioport volatile * Uint16)(0x1C07))

Uint16 delta_time;
Uint16 start_time;
Uint16 end_time;

void run_audioeq()
{
  // Initialise variables for FIR Filter
  Uint16 i = 0;
  DATA right, left; // AIC inputs
  Uint16 val;
  Uint16 mode = 1;          // Mode = 1 --> Bypass, Mode = 2 --> Equalizer
  DATA out_right, out_left; // AIC output
  DATA dbuffer_left[TAPS + 2], dbuffer_right[TAPS + 2];

  while (1)
  {
    if (i >= TAPS)
      i = 0;
    AIC_read2(&right, &left);

    val = *SARDATA;

    if ((val < SW1 + 12) && (val > SW1 - 12))
    {
      mode = 1;
      // printf("mode 1");
    }
    else if ((val < SW2 + 12) && (val > SW2 - 12))
    {
      mode = 2;
      // printf("mode 2");
    }

    start_time = TIMCNT1_0;
    fir(
        &left,
        coef,
        &out_left,
        dbuffer_left,
        1,
        TAPS);
    fir(
        &right,
        coef,
        &out_right,
        dbuffer_right,
        1,
        TAPS);

    end_time = TIMCNT1_0;
    delta_time = start_time - end_time;

    if (mode == 2)
    {
      AIC_write2(out_right, out_left);

      LED_OUT2 &= ~(Uint16)(1 << (1)); // bitGpio17
      LED_OUT2 |= (Uint16)(1 << (0));  // bitGpio16
    }
    else
    {
      AIC_write2(right, left);
      LED_OUT2 |= (Uint16)(1 << (1));  // bitGpio17
      LED_OUT2 &= ~(Uint16)(1 << (0)); // bitGpio16
    }

    i++;
  }
}

void Peripherals_init()
{

  Uint16 temp = 0x00;
  Uint16 temp2 = 0x01;

  // Clock Initialisation
  TCR0 = TIME_STOP;
  TCR0 = TIME_START; // Resets the time register

  // LED Initialisation
  temp |= (1 << 14);
  temp |= (Uint16)(1 << 15);
  LED_DIR1 |= temp; // set Yellow, Blue (14,15) as OUTPUT
  temp2 |= (1 << 1);
  LED_DIR2 |= temp2; // set Red, Green (0,1) as OUTPUT

  LED_OUT1 |= temp;  // Set LEDs 0, 1 to off
  LED_OUT2 |= temp2; // Set LEDs 2, 3 to off

  // SAR Initialisation
  *SARCTRL = 0xB800;
}

void main(void)
{
  USBSTK5515_init(); // Initialise the Processor
  AIC_init();        // Initialise the Audio Codec

  Peripherals_init(); // Initialise the Peripherals used in the AudioEQ

  run_audioeq(); // Run the main program
}
