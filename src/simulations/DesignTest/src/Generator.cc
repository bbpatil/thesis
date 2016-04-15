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
    this->scheduleAt(simTime(), new cMessage);
}

void Generator::handleMessage(cMessage *msg)
{
    static size_t counter = 0;

    if (msg->isSelfMessage())
    {
        // create new message
        auto pkt = new DataMessage();

        Data data;
        data.type = static_cast<DataType>(counter++ % 3);
        auto i = 0;
        for (auto & d : data.data)
            d = i++;

        pkt->setData(data);

        // send message
        send(pkt, "data");

        // schedule next call
        this->scheduleAt(simTime() + par("generationInterval"), new cMessage);
    }

    delete msg;
}
