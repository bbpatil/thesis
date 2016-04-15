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

#include <HistoricalQueue.h>

HistoricalQueue::HistoricalQueue()
{
}

HistoricalQueue::~HistoricalQueue()
{
}

void HistoricalQueue::PushData(Packet packet)
{
    // add packet to internal queue
    mQueue.push(packet);
}

PacketPtr HistoricalQueue::PopData()
{
    // check internal queue
    if (!mQueue.empty())
    {
        // get element and make pointer
        PacketPtr packet(new Packet(mQueue.front()));
        mQueue.pop();
        return std::move(packet);
    }

    return nullptr;
}
