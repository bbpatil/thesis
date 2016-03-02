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
        using ProcessDataFunc = std::function<void(Data::Packet)>;

        // C-Tor / D-Tor
    public:
        Dispatcher(ProcessDataFunc processConfig, ProcessDataFunc processEvent, ProcessDataFunc processHistorical);
        virtual ~Dispatcher();

        // Methods
        void DispatchData(Data const & data);

        // Member
    private:
        ProcessDataFunc mProcessConfig;
        ProcessDataFunc mProcessEvent;
        ProcessDataFunc mProcessHistorical;
};

#endif /* DISPATCHER_H_ */
