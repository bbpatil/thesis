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

#include <EventManager.h>
#include <algorithm>
#include <numeric>
#include <functional>

using namespace std;

EventManager::EventManager()
{
    // TODO Auto-generated constructor stub

}

EventManager::~EventManager()
{
    // TODO Auto-generated destructor stub
}

void EventManager::ProcessEvent(Packet packet)
{
    // dummy procesing

    using intType = long;
    using floatType = float;
    intType dummySum = 0;
    floatType dummyProduct = 1.2345;
    multiplies<floatType> multiply;
    auto mult = bind(multiply, placeholders::_1, ref(dummyProduct));

    for (auto i = 1; i < packet[0] * 12345; i++)
    {
        dummySum = accumulate(packet.begin(), packet.end(), dummySum);
        for_each(packet.begin(), packet.end(), mult);
    }
}
