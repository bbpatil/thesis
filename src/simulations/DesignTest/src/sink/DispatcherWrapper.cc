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

DispatcherWrapper::DispatcherWrapper()
//: mDispatcher(bind(&DispatcherWrapper::sendConfig, this, placeholders::_1),
//        bind(&DispatcherWrapper::sendEvent, this, placeholders::_1),
//        bind(&DispatcherWrapper::sendHistorical, this, placeholders::_1))
: mDispatcher(bind(&DispatcherWrapper::sendPacket, this, placeholders::_1, "config"),
        bind(&DispatcherWrapper::sendPacket, this, placeholders::_1, "event"),
        bind(&DispatcherWrapper::sendPacket, this, placeholders::_1, "historical"))
{
}

void DispatcherWrapper::initialize()
{
    // TODO - Generated method body
}


void DispatcherWrapper::handleMessage(cMessage *msg)
{
    if (msg != nullptr)
    {
        auto data = dynamic_cast<DataMessage*>(msg);

        if (data != nullptr)
        {
            mDispatcher.DispatchData(data->getData());
        }

        delete msg;
    }
}

void DispatcherWrapper::sendConfig(Packet config)
{
}

void DispatcherWrapper::sendEvent(Packet event)
{
}

void DispatcherWrapper::sendHistorical(Packet historicalPacket)
{
}

void DispatcherWrapper::sendPacket(const Packet& packet, const char* gateName)
{
    auto msg = new PacketMessage();
    msg->setPack(packet);
    send(msg, gateName);
}
