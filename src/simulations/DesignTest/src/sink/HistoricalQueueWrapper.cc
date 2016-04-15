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

HistoricalQueueWrapper::HistoricalQueueWrapper() :
        mQueue(
                bind(&HistoricalQueueWrapper::SendHistorical, this,
                        placeholders::_1))
{
}

void HistoricalQueueWrapper::initialize()
{

}

void HistoricalQueueWrapper::handleMessage(cMessage *msg)
{
    if (msg != nullptr)
    {
        auto historical = dynamic_cast<PacketMessage*>(msg);

        if (historical != nullptr)
        {
            mQueue.PushData(historical->getPack());
        }

        delete msg;
    }
}

void HistoricalQueueWrapper::SendHistorical(Packet historical)
{
    auto msg = new PacketMessage();
    msg->setPack(historical);
    send(msg, "historicalOut");
}
