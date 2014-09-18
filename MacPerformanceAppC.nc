#include <Timer.h>
#include "MacPerformance.h"

configuration MacPerformanceAppC {
}
implementation {
  components MainC;
  components MacPerformanceC as App;
  components new TimerMilliC() as Timer0;
  components ActiveMessageC;
  components new AMSenderC(AM_MACPERFORMANCE);
  components new AMReceiverC(AM_MACPERFORMANCE);

  App.Boot -> MainC;
  App.Timer0 -> Timer0;
  App.Packet -> AMSenderC;
  App.AMPacket -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Receive -> AMReceiverC;
}
