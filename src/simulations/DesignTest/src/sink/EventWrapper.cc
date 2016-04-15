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

#include "EventWrapper.h"
#include "PacketMessage_m.h"

Define_Module(EventWrapper);

void EventWrapper::initialize()
{
}

void EventWrapper::handleMessage(cMessage *rawMsg)
{
    MsgPtr msgPtr(rawMsg);
    // get packet from message
    if (msgPtr != nullptr)
    {
        auto event = dynamic_cast<PacketMessage*>(msgPtr.get());

        if (event != nullptr)
        {
            mEventManager.ProcessEvent(event->getPack());

            if (ev.isGUI())
                bubble("Event processed");
        }
    }
}
