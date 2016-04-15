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

#include "HistoricalQueueWrapper.h"
#include "PacketMessage_m.h"

Define_Module(HistoricalQueueWrapper);

using namespace std;

#define BUBBLE(msg) \
        if (ev.isGUI())\
            bubble(msg)

void HistoricalQueueWrapper::initialize()
{
    mQueue = make_unique<HistoricalQueue>();

    mDataGate = gate("historicalIn");
    mCmdGate = gate("pollData");
}

void HistoricalQueueWrapper::handleMessage(cMessage *msg)
{
    if (msg != nullptr)
    {
        // check receiving gate
        auto id = msg->getArrivalGateId();

        if (id == mDataGate->getId())
        {
            // forward history data
            auto historical = dynamic_cast<PacketMessage*>(msg);

            if (historical != nullptr)
            {
                BUBBLE("Hisorical data received");

                mQueue->PushData(historical->getPack());
            }
        }
        else if (id == mCmdGate->getId())
        {
            BUBBLE("Polling cmd receievd");

            // poll queue
            auto data = mQueue->PopData();

            // check if valid packet
            if (data != nullptr)
            {
                // send polled packet
                auto packet = new PacketMessage();
                packet->setPack(*data);
                send(packet, "historicalOut");
            }
            else
                // send empty message
                send(new cMessage(), "historicalOut");

        }
        else
            error("invalid gate id");

        delete msg;
    }
}
