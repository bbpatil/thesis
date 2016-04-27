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

NAMESPACE_BEGIN

void Generator::initialize()
{
    // resolve parameter and calc delay
    mDataDelay = simtime_t(par("generationInterval").longValue(), SimTimeUnit::SIMTIME_NS);

    // schedule starting data message
    scheduleAt(simTime(), new cMessage());

    mGenerationCounter = 0;
}

void Generator::handleMessage(cMessage *rawMsg)
{
    MsgPtr msgPtr(rawMsg);

    if (msgPtr->isSelfMessage())
    {
        // create new message
        auto pkt = new DataMessage();

        Data data;
        data.type = static_cast<DataType>(mGenerationCounter++ % 3);

        size_t i = 0;

        for (auto & d : data.data)
            d = ((i++) + mGenerationCounter) * 3 + 7;

        pkt->setData(data);

        // send message
        send((cMessage*) pkt, "data");

        // schedule next data cmd
        scheduleAt(simTime() + mDataDelay, new cMessage());
    }
}

NAMESPACE_END
