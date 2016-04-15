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

#include "MonolithicSink.h"

#include "impl/Dispatcher.h"
#include "impl/ConfigurationManager.h"
#include "impl/EventManager.h"
#include "impl/HistoricalQueue.h"
#include "impl/HistoryManager.h"

#include <memory>

Define_Module(MonolithicSink);


MonolithicSink::MonolithicSink()
{
    // create inner structure
    mHistoryManager = std::make_unique<HistoryManager>();
    mHistoricalQueue = std::make_unique<HistoricalQueue>(std::mem_fun(&HistoryManager::ProcessData, *mHistoryManager));
    mEventManager = std::make_unique<EventManager>();
    mConfigManager = std::make_unique<ConfigurationManager>();
    //mDispatcher = std::make_unique<Dispatcher>();
}

void MonolithicSink::initialize()
{
}

void MonolithicSink::handleMessage(cMessage *msg)
{
    delete msg;
}
