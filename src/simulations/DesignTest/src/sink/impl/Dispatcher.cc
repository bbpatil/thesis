/*
 * Dispatcher.cpp
 *
 *  Created on: Mar 2, 2016
 *      Author: franz
 */

#include <impl/Dispatcher.h>
#include <stdexcept>

Dispatcher::Dispatcher(ProcessDataFunc processConfig, ProcessEventFunc processEvent, ProcessDataFunc processHistorical) :
        mProcessConfig(processConfig), mProcessEvent(processEvent), mProcessHistorical(processHistorical), mEventCounter(0)
{
}

Dispatcher::~Dispatcher()
{
}

void Dispatcher::DispatchData(const Data& data)
{
    // check data type
    switch (data.type)
    {
        case DataType::ConfigData:
            // process config
            mProcessConfig(data.data);
            break;
        case DataType::EventData:
            // process event
            mProcessEvent(data.data, mEventCounter++);
            break;
        case DataType::HistoricalData:
            // process historical
            mProcessHistorical(data.data);
            break;
        default:
            throw std::logic_error("invalid datatype");
    }
}
