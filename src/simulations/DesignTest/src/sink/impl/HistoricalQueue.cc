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

HistoricalQueue::HistoricalQueue(ProcessDataFunc processData) :
        mProcessData(processData)
{
}

HistoricalQueue::~HistoricalQueue()
{
    // TODO Auto-generated destructor stub
}

void HistoricalQueue::PushData(Packet packet)
{
    // add packet to internal queue
    mQueue.push(packet);

    // check if more than 4 elements are in the queue
    if (mQueue.size() > 4)
    {
        // process all elements
        while(!mQueue.empty())
        {
            mProcessData(mQueue.front());
            mQueue.pop();
        }
    }
}
