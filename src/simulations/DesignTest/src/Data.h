/*
 * Data.h
 *
 *  Created on: Mar 2, 2016
 *      Author: franz
 */

#ifndef DATA_H_
#define DATA_H_

#include <ccommbuffer.h>

#include <array>
#include <memory>

using Packet = std::array<unsigned char, 64>;
using PacketPtr = std::unique_ptr<Packet>;

enum class DataType
{
    EventData = 0, HistoricalData = 1, ConfigData = 2
};

struct Data
{
        DataType type;
        Packet data;
};

NAMESPACE_BEGIN
// Packing functions
void doPacking(cCommBuffer *buffer, Data& data);

void doUnpacking(cCommBuffer *buffer, Data& data);

NAMESPACE_END

#endif /* DATA_H_ */
