#ifndef MACPERFORMANCE_H
#define MACPERFORMANCE_H

enum {
  AM_MACPERFORMANCE = 6,
#if defined(TIMER_60)
  TIMER_PERIOD_MILLI = 60
#endif
#if defined(TIMER_70)
  TIMER_PERIOD_MILLI = 70
#endif
#if defined(TIMER_80)
  TIMER_PERIOD_MILLI = 80
#endif
#if defined(TIMER_90)
  TIMER_PERIOD_MILLI = 90
#endif
#if defined(TIMER_100)
  TIMER_PERIOD_MILLI = 100
#endif  
};

typedef nx_struct MacPerformanceMsg {
  nx_uint16_t route;
  nx_uint16_t counter;
#if defined(PACKET_SIZE_8kb)
  nx_uint32_t data1;
#endif
#if defined(PACKET_SIZE_12kb)
  nx_uint32_t data1;
  nx_uint32_t data2;
#endif
#if defined(PACKET_SIZE_16kb)
  nx_uint32_t data1;
  nx_uint32_t data2;
  nx_uint32_t data3;
#endif
#if defined(PACKET_SIZE_20kb)
  nx_uint32_t data1;
  nx_uint32_t data2;
  nx_uint32_t data3;
  nx_uint32_t data4;
#endif
} MacPerformanceMsg;

#endif
