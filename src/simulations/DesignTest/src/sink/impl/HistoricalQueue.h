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

#ifndef HISTORICALQUEUE_H_
#define HISTORICALQUEUE_H_

#include <functional>
#include <memory>
#include <queue>
#include "Data.h"

class HistoricalQueue
{
        // Definitions
    private:
        using PacketQueue = std::queue<Packet>;

        // C-Tor / D-Tor
    public:
        HistoricalQueue();
        virtual ~HistoricalQueue();

        // Methods
    public:
        void PushData(Packet packet);
        PacketPtr PopData();

        // Member
    private:
        PacketQueue mQueue;
};

#endif /* HISTORICALQUEUE_H_ */
