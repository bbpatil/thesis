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

#include <memory>
#include <string>

#include "MonolithicSink.h"

#include "impl/Dispatcher.h"
#include "impl/ConfigurationManager.h"
#include "impl/EventManager.h"
#include "impl/HistoricalQueue.h"
#include "impl/HistoryManager.h"

#include "DataMessage_m.h"

Define_Module(MonolithicSink);

#define BUBBLE(msg) \
        if (ev.isGUI())\
            bubble(msg)

using namespace std;

void MonolithicSink::initialize()
{
    // create inner structure
    mHistoricalQueue = make_unique<HistoricalQueue>();
    mHistoryManager = make_unique < HistoryManager > (bind(&HistoricalQueue::PopData, *mHistoricalQueue));
    mEventManager = make_unique<EventManager>();
    mConfigManager = make_unique<ConfigurationManager>();
    mDispatcher = make_unique < Dispatcher
            > (bind(&ConfigurationManager::SetNewConfiguration, *mConfigManager, placeholders::_1), bind(
                    &EventManager::ProcessEvent, *mEventManager, placeholders::_1), bind(&HistoricalQueue::PushData,
                    *mHistoricalQueue, placeholders::_1));

    // resolve interval parmeter
    mPollingInterval = simtime_t(par("historyPollingInterval"), SimTimeUnit::SIMTIME_NS);

    // schedule inital self message
    scheduleAt(simtime_t() + mPollingInterval, new cMessage());
}

void MonolithicSink::handleMessage(cMessage *rawMsg)
{
    MsgPtr msgPtr(rawMsg);

    if (msgPtr != nullptr)
    {
        // check if self message (polling command)
        if (msgPtr->isSelfMessage())
        {
            BUBBLE("Process polling cmd");

            // process polling cmd
            mHistoryManager->PollHistory();

            // schedule self message
            scheduleAt(simtime_t() + mPollingInterval, new cMessage());
        }
        else // received data
        {
            // process data
            auto packet = dynamic_cast<DataMessage*>(msgPtr.get());
            if (packet != nullptr)
            {
                BUBBLE(("Dispatched Message of type: " + to_string(static_cast<int>(packet->getData().type))).c_str());

                // forward data packet to dispatcher
                mDispatcher->DispatchData(packet->getData());
            }
        }
    }
}
