/*
 * Data.h
 *
 *  Created on: Mar 2, 2016
 *      Author: franz
 */

#ifndef DATA_H_
#define DATA_H_

#include <array>

using Packet = std::array<unsigned char, 64>;

enum class DataType
{
    EventData = 0, HistoricalData = 1, ConfigData = 2
};

struct Data
{
        DataType type;
        Packet data;
};

#endif /* DATA_H_ */
