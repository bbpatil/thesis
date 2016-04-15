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

#include <HistoryManager.h>
#include <algorithm>
#include <numeric>
#include <functional>

using namespace std;

HistoryManager::HistoryManager()
{
    // TODO Auto-generated constructor stub

}

HistoryManager::~HistoryManager()
{
    // TODO Auto-generated destructor stub
}

void HistoryManager::ProcessData(Packet packet)
{
    // dummy processing

    using intType = long;
    using floatType = float;
    intType dummySum = 0;
    floatType dummyProduct = 1.2375;
    multiplies<floatType> multiply;

    for (auto i = 0; i < packet[0] * 0.5; i++)
    {
        dummySum += accumulate(packet.begin(), packet.end(), 0);
        for_each(packet.begin(), packet.end(), bind(multiply, placeholders::_1, ref(dummyProduct)));
    }
}
