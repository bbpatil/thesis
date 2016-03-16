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

#include "Generator.h"
#include "DataMessage_m.h"

Define_Module(Generator);

void Generator::initialize()
{
    // resolve parameter and calc delay
    mDataDelay = simtime_t(par("generationInterval"), SimTimeUnit::SIMTIME_NS);
    mCmdDelay = mDataDelay;
    simtime_t cmdOffset = mDataDelay / 2;

    // schedule starting data message
    scheduleAt(simTime(), createSelfMessage(SelfMessageType::GenerateData));
    // schedule starting cmd message
    scheduleAt(simTime() + cmdOffset, createSelfMessage(SelfMessageType::PollingCmd));
}

void Generator::handleMessage(cMessage *msg)
{
    static size_t counter = 0;

    if (msg->isSelfMessage())
    {
        // check message kind
        switch (msg->getKind())
        {
            case static_cast<short>(SelfMessageType::GenerateData): {

                // create new message
                auto pkt = new DataMessage();

                Data data;
                data.type = static_cast<DataType>(counter++ % 3);
                data.data =
                {   123};

                pkt->setData(data);

                // send message
                send((cMessage*) pkt, "data");

                // schedule next data cmd
                scheduleAt(simTime() + mDataDelay, createSelfMessage(SelfMessageType::GenerateData));

                break;
            }
            case static_cast<short>(SelfMessageType::PollingCmd): {
                // send polling command
                send(new cMessage(), "pollingCmd");

                // schedule next polling cmd
                scheduleAt(simTime() + mCmdDelay, createSelfMessage(SelfMessageType::PollingCmd));
                break;
            }
            default:
                error("invalid message kind");
        }

    }

    delete msg;
}

cMessage* Generator::createSelfMessage(SelfMessageType type)
{
    auto msg = new cMessage();
    msg->setKind(static_cast<short>(type));
    return msg;
}
