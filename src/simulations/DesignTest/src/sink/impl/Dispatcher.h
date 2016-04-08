/*
 * Dispatcher.h
 *
 *  Created on: Mar 2, 2016
 *      Author: franz
 */

#ifndef DISPATCHER_H_
#define DISPATCHER_H_

#include <functional>
#include "Data.h"

class Dispatcher
{
        // Definitions
    private:
        using CounterType = unsigned char;
        using ProcessDataFunc = std::function<void(Packet)>;
        using ProcessEventFunc = std::function<void(Packet, CounterType)>;

        // C-Tor / D-Tor
    public:
        Dispatcher(ProcessDataFunc processConfig, ProcessEventFunc processEvent,
                ProcessDataFunc processHistorical);
        virtual ~Dispatcher();

        // Methods
        void DispatchData(Data const & data);

        // Member
    private:
        ProcessDataFunc mProcessConfig;
        ProcessEventFunc mProcessEvent;
        ProcessDataFunc mProcessHistorical;
        CounterType mEventCounter;
};

#endif /* DISPATCHER_H_ */
