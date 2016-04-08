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

#include "DispatcherWrapper.h"
#include "DataMessage_m.h"
#include "PacketMessage_m.h"

Define_Module(DispatcherWrapper);

using namespace std;

void DispatcherWrapper::initialize()
{
    // create enclosed dispatcher
    mDispatcher = make_unique<Dispatcher>(bind(&DispatcherWrapper::sendPacket, this, placeholders::_1, "config"),
            bind(&DispatcherWrapper::sendEvent, this, placeholders::_1, placeholders::_2),
            bind(&DispatcherWrapper::sendPacket, this, placeholders::_1, "historical"));

    // resolve number of event manager
    mNumberOfEventManager = static_cast<int>(par("numberOfEventManager"));
}


void DispatcherWrapper::handleMessage(cMessage *msg)
{
    if (msg != nullptr)
    {
        auto data = dynamic_cast<DataMessage*>(msg);

        if (data != nullptr)
        {
            mDispatcher->DispatchData(data->getData());
        }

        delete msg;
    }
}

void DispatcherWrapper::sendEvent(const Packet& event, CounterType idx)
{
    auto msg = new PacketMessage();
    msg->setPack(event);
    send(msg, "event", idx % mNumberOfEventManager);
}

void DispatcherWrapper::sendPacket(const Packet& packet, const char* gateName)
{
    auto msg = new PacketMessage();
    msg->setPack(packet);
    send(msg, gateName);
}
