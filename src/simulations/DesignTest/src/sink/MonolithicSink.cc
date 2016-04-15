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

    // get resolve gates
    mDataGate = gate("data");
    mCmdGate = gate("pollingCmd");

    mSignalId = registerSignal("msgType");
}

void MonolithicSink::handleMessage(cMessage *msg)
{
    if (msg != nullptr)
    {
        // check receiving gate
        auto id = msg->getArrivalGateId();
        if (id == mDataGate->getId())
        {
            // process data
            auto packet = dynamic_cast<DataMessage*>(msg);
            if (packet != nullptr)
            {
                BUBBLE(("Dispatched Message of type: " + to_string(static_cast<int>(packet->getData().type))).c_str());

                emit(mSignalId, static_cast<int>(packet->getData().type));

                // forward data packet to dispatcher
                mDispatcher->DispatchData(packet->getData());
            }
        }
        else if (id == mCmdGate->getId())
        {
            BUBBLE("Process polling cmd");

            // process polling cmd
            mHistoryManager->PollHistory();
        }
        else
            error("unknown reiceiving gate");

        delete msg;
    }
}
