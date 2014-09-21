/*
*
* @author Mateusz Bartkowiak
* @date   Feb 1, 2006
*/
#include <Timer.h>
#include "MacPerformance.h"

module MacPerformanceC 
{
    uses interface Boot;
    uses interface Timer<TMilli> as Timer0;
    uses interface Packet;
    uses interface AMPacket;
    uses interface AMSend;
    uses interface Receive;
    uses interface SplitControl as AMControl;
}
implementation 
{

    uint16_t counter = 0;
    uint32_t received_packets = 0;
    bool busy = FALSE;
    message_t pkt;
    uint32_t my_id = 0;
    
    event void Boot.booted() 
    {   
	my_id = 1000*TOS_NODE_ID;
	call AMControl.start();
    }

    event void AMControl.startDone(error_t err) 
    {
        if (SUCCESS == err) 
        {
            call Timer0.startPeriodic(TIMER_PERIOD_MILLI); 
        }
        else 
        {
            call AMControl.start();
        }
    }

    event void AMControl.stopDone(error_t err) {}

    event void Timer0.fired() 
    {
        MacPerformanceMsg* mppkt;
	if (!busy) 
        {
            mppkt = (MacPerformanceMsg*)(call Packet.getPayload(&pkt, sizeof(MacPerformanceMsg)));
            if (mppkt == NULL) {return;}
         
        #if defined(CLUSTER_TOPOLOGY_2) || defined(CLUSTER_TOPOLOGY_4) || defined(CLUSTER_TOPOLOGY_6) || defined(CLUSTER_TOPOLOGY_8) || defined(CLUSTER_TOPOLOGY_10)
	
        if (0 != TOS_NODE_ID)
        {        
            if (call AMSend.send(0, &pkt, sizeof(MacPerformanceMsg)) == SUCCESS) 
            {
		mppkt->counter = my_id + counter;
                counter++;
                busy = TRUE;
                dbg("PacketState", "Sent: %hu ; %llu\n", mppkt->counter, sim_time());
            }
        }
        #endif
        #if defined(CHAIN_TOPOLOGY_2)
        if (1 == TOS_NODE_ID)
        {        
            if (call AMSend.send(0, &pkt, sizeof(MacPerformanceMsg)) == SUCCESS) 
            {
		mppkt->counter = my_id + counter;
                counter++;
                busy = TRUE;
                dbg("PacketState", "Sent: %hu ; %llu\n", mppkt->counter, sim_time());
            }
        }
        #endif
        #if defined(CHAIN_TOPOLOGY_4)
        if (3 == TOS_NODE_ID)
        {        
            if (call AMSend.send(2, &pkt, sizeof(MacPerformanceMsg)) == SUCCESS) 
            {
		mppkt->counter = my_id + counter;
                counter++;
                busy = TRUE;
                dbg("PacketState", "Sent: %hu ; %llu\n", mppkt->counter, sim_time());
            }
        }
        #endif
        #if defined(CHAIN_TOPOLOGY_6)
        if (5 == TOS_NODE_ID)
        {        
            if (call AMSend.send(4, &pkt, sizeof(MacPerformanceMsg)) == SUCCESS) 
            {
		mppkt->counter = my_id + counter;
                counter++;
                busy = TRUE;
                dbg("PacketState", "Sent: %hu ; %llu\n", mppkt->counter, sim_time());
            }
        }
        #endif
        #if defined(CHAIN_TOPOLOGY_8)
        if (7 == TOS_NODE_ID)
        {        
            if (call AMSend.send(6, &pkt, sizeof(MacPerformanceMsg)) == SUCCESS) 
            {
		mppkt->counter = my_id + counter;
                counter++;
                busy = TRUE;
                dbg("PacketState", "Sent: %hu ; %llu\n", mppkt->counter, sim_time());
            }
        }
        #endif
        #if defined(CHAIN_TOPOLOGY_10)
        if (9 == TOS_NODE_ID)
        {        
            if (call AMSend.send(8, &pkt, sizeof(MacPerformanceMsg)) == SUCCESS)
            { 
		mppkt->counter = my_id + counter;
                counter++;
                busy = TRUE;
                dbg("PacketState", "Sent: %hu ; %llu\n", mppkt->counter, sim_time());
            }
        }
        #endif
}
    }


    event void AMSend.sendDone(message_t* msg, error_t err) 
    {
        if (&pkt == msg) {busy = FALSE;}
    }

    event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len)
    {
        received_packets++;
        if (len == sizeof(MacPerformanceMsg)) 
        {
            MacPerformanceMsg* mppkt = (MacPerformanceMsg*)payload;
            if(0 == TOS_NODE_ID)
            {
                dbg("PacketState", "Recieved: %hu ; %llu\n", mppkt->counter, sim_time());
            }
        }   


        #if defined(CHAIN_TOPOLOGY_10) || defined(CHAIN_TOPOLOGY_8) || defined(CHAIN_TOPOLOGY_6) || defined(CHAIN_TOPOLOGY_4) || defined(CHAIN_TOPOLOGY_2)
        if (0 != TOS_NODE_ID)
        {
            if (call AMSend.send(TOS_NODE_ID - 1, msg, len) == SUCCESS) 
            {
                busy = TRUE;
            }   
        }       
        #endif

        #if defined(TREE_TOPOLOGY_11)
        if (4 == TOS_NODE_ID)
        {
            if (call AMSend.send(1, msg, len) == SUCCESS) 
            {
                busy = TRUE;
            }   
        }
        if (3 == TOS_NODE_ID)
        {
            if (call AMSend.send(1, msg, len) == SUCCESS) 
            {
                busy = TRUE;
            }
        }
        if (2 == TOS_NODE_ID)
        {
            if (call AMSend.send(0, msg, len) == SUCCESS) 
            {
                busy = TRUE;
            }   
        }
        if (1 == TOS_NODE_ID)
        {
        if (call AMSend.send(0, msg, len) == SUCCESS) 
            {
                busy = TRUE;
            }
        }
        #endif
        #if defined(TREE_TOPOLOGY_9)
        if (3 == TOS_NODE_ID)
        {
            if (call AMSend.send(1, msg, len) == SUCCESS) 
            {
                busy = TRUE;
            }
        }
        if (2 == TOS_NODE_ID)
        {
            if (call AMSend.send(0, msg, len) == SUCCESS) 
            {
                busy = TRUE;
            }   
        }
        if (1 == TOS_NODE_ID)
        {
        if (call AMSend.send(0, msg, len) == SUCCESS) 
            {
                busy = TRUE;
            }
        }
        #endif
        #if defined(TREE_TOPOLOGY_7) || defined(TREE_TOPOLOGY_5)
        if (2 == TOS_NODE_ID)
        {
            if (call AMSend.send(0, msg, len) == SUCCESS) 
            {
                busy = TRUE;
            }   
        }
        if (1 == TOS_NODE_ID)
        {
            if (call AMSend.send(0, msg, len) == SUCCESS) 
            {
                busy = TRUE;
            }
        }
        #endif

    return msg;
    }
}
