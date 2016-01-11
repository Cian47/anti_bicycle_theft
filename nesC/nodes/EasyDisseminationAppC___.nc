configuration EasyDisseminationAppC {}
implementation {
  components EasyDisseminationC;

  components MainC;
  EasyDisseminationC.Boot -> MainC;

  components ActiveMessageC;
  EasyDisseminationC.RadioControl -> ActiveMessageC;

  components DisseminationC;
  EasyDisseminationC.DisseminationControl -> DisseminationC;

  components new DisseminatorC(uint16_t, 0x1234) as Diss16C;
  EasyDisseminationC.Value -> Diss16C;
  EasyDisseminationC.Update -> Diss16C;

  components LedsC;
  EasyDisseminationC.Leds -> LedsC;

  components new TimerMilliC();
  EasyDisseminationC.Timer -> TimerMilliC;
}

