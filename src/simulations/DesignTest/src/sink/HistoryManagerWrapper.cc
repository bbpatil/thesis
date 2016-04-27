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

#include <functional>
#include <memory>

#include "HistoryManagerWrapper.h"
#include "PacketMessage_m.h"

Define_Module(HistoryManagerWrapper);

#define BUBBLE(msg) \
        if (ev.isGUI())\
            bubble(msg)

USING_NAMESPACE


HistoryManagerWrapper::HistoryManagerWrapper()
    : cSimpleModule(1)
{
    mHistoryManager = std::make_unique<HistoryManager>(std::bind(&HistoryManagerWrapper::ProcessPop, this));
}

// called within activity
PacketPtr HistoryManagerWrapper::ProcessPop()
{
    BUBBLE("Send poll cmd");

    // send poll message
    send(new cMessage(), "pollData");

    // receive data message
    MsgPtr msg(receive());

    // get packet from data
    auto historical = dynamic_cast<PacketMessage*>(msg.get());

    if (historical != nullptr)
    {
        BUBBLE("Historical Data received");
        return std::make_unique<Packet>(historical->getPack());
    }

    return nullptr;
}


void HistoryManagerWrapper::activity()
{
    bool running = true;

    auto pollingInt = simtime_t(par("pollingInterval").longValue(), SimTimeUnit::SIMTIME_NS);

    while(running)
    {
        // wait polling interval
        wait(pollingInt);

        // process polling
        mHistoryManager->PollHistory();
    }
}
