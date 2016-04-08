//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
// 
// You should have received a copy of the GNU Lesser General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/.
// 

#ifndef __DESIGNTEST_MONOLITHICSINK_H_
#define __DESIGNTEST_MONOLITHICSINK_H_

#include <omnetpp.h>
#include <memory>
#include <vector>

#include "Data.h"

// forward declarations
class Dispatcher;
class ConfigurationManager;
class EventManager;
class HistoricalQueue;
class HistoryManager;

/**
 * TODO - Generated class
 */
class MonolithicSink : public cSimpleModule
{
        // Definitions
    private:
        using CounterType = unsigned char;
        template<typename T>
        using Pointer = std::unique_ptr<T>;
        template<typename T>
        using Container = std::vector<T>;
        using MsgPtr = std::unique_ptr<cMessage>;


        // Methods
    public:
        void DispatchMultipleEventManager(Packet packet, CounterType idx);

    protected:
        virtual void initialize();
        virtual void handleMessage(cMessage *msg);

        // Member
    private:
        Pointer<Dispatcher> mDispatcher;
        Pointer<ConfigurationManager> mConfigManager;
        Container<Pointer<EventManager>> mEventManagerCont;
        Pointer<HistoricalQueue> mHistoricalQueue;
        Pointer<HistoryManager> mHistoryManager;

        int mNUmberOfEventManager;
        simtime_t mPollingInterval;
};

#endif
